import { LightningElement, api, track } from 'lwc';
import { OmniscriptBaseMixin } from 'omnistudio/omniscriptBaseMixin'
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const actions = [
    { label: 'Eliminar', name: 'delete'}
];

export default class CsListFilesDocuments extends OmniscriptBaseMixin(NavigationMixin(LightningElement)) {
    @api documents;
    @api recordId;
    @api objectApiName;
    @track documentsData = [];
    @track columns = [
        { 
            label: 'Nombre', 
            fieldName: 'ContentDocumentId', 
            type: 'button', 
            typeAttributes: { 
                label: { fieldName: 'Title' }, 
                name: 'viewFile',
                variant: 'base' 
            }
        },
        { label: 'Clasificacion', fieldName: 'CS_Classification__c', type: 'text' },
        { label: 'Tipo', fieldName: 'CS_DocumentType__c', type: 'text' },
        {
            type: 'action',
            typeAttributes: {
                rowActions: actions,
                menuAlignment: 'right'
            }
        }
    ];

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        switch (actionName) {
                case 'viewFile':
                    this[NavigationMixin.Navigate]({
                        type: 'standard__namedPage',
                        attributes: {
                            pageName: 'filePreview'
                        },
                        state: {
                            recordIds: row.ContentDocumentId
                        }
                    });
                break;
            case 'delete':
                this.deleteDocument(row.ContentDocumentId);
                break;
            default:
                break;
        }
    }

    /*state:{ 
            selectedRecordId: row.ContentDocumentId
        }
    });*/

    handleViewAllFiles() {
        let Subid = this.recordId.substring(0, 3);
        let objName ='Claim';
        let RelObjname='AttachedContentDocuments';
        if(Subid === '0kP'){
            objName = 'ClaimCoverage';
            RelObjname = 'CombinedAttachments';
        }
        this[NavigationMixin.Navigate]({
            type: 'standard__recordRelationshipPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: objName,
                relationshipApiName: RelObjname, // Correct relationship API name for Files
                actionName: 'view'
            }
        });
    }
    connectedCallback() {
        if (this.documents) {
            let documentsArray = Array.isArray(this.documents) ? this.documents : [this.documents];
            //console.log('Sicas', JSON.stringify(documentsArray))
            this.documentsData = documentsArray.map(doc => ({
                ContentDocumentId: doc.ContentDocumentId,
                Title: doc.Title,
                CS_Classification__c: doc.CS_Classification__c,
                CS_DocumentType__c: doc.CS_DocumentType__c
            }));
        }
    }
    
    deleteDocument(contentDocumentId) {
        const options = {
            chainable: true,
            useFuture: true
        };
        const params = {
            input: JSON.stringify({ DocumentId: contentDocumentId, ContextId : this.recordId }),
            sClassName: `omnistudio.IntegrationProcedureService`,
            sMethodName: 'document_delete', // Integration Procedure for deleting the document
            options: JSON.stringify(options),
        };

        this.omniRemoteCall(params, true)
            .then(response => {
                this.refreshData(contentDocumentId);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Exito',
                        message: 'Documento Eliminado Satisfactoriamente.',
                        variant: 'success'
                    })
                );
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Algo ocurrio',
                        message: 'Error eliminando el documento',
                        variant: 'error'
                    })
                );
            });
    }

    refreshData(contentDocumentId) {
        this.documentsData = this.documentsData.filter(doc => doc.ContentDocumentId !== contentDocumentId);
    }
}