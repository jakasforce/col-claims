import { LightningElement, api, track } from 'lwc';
import { OmniscriptBaseMixin } from 'omnistudio/omniscriptBaseMixin';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import util from "omnistudio/utility";

export default class CsUploadFileComponent extends OmniscriptBaseMixin(LightningElement) {
    @api recordId;
    @api classifications;
    @api profile;
    @track clasificacionOptions = [];
    @track tipoDocumentoOptions = [];
    @track selectedClasificacion = '';
    @track selectedTipoDocumento = '';
    @track isUploadDisabled = true;

    @track inputFiles;
    get disableImport() {
        return !this.inputFiles || this.inputFiles.files.length === 0;
    }

    connectedCallback() {
        //console.log('profile', this.profile);
        this.fetchClasificacionOptions();
    }

    fetchClasificacionOptions() {
        if (this.classifications) {
            this.clasificacionOptions = this.classifications.map(doc => ({
                label: doc.Description__c,
                value: doc.Id + '&' + doc.Description__c

            }));
        }
    }

    fetchTipoDocumentoOptions(selectedClasificacionId) {
        if(selectedClasificacionId) {
            let request_data = {
                type: "DataRaptor",
                value: {
                    bundleName: "CS_GetDocumentType",
                    inputMap: "{}",
                    optionsMap: "{}",
                }
            };
    
            request_data.value.inputMap = JSON.stringify({
                ClassificationId: selectedClasificacionId
            });
    
            util.getDataHandler(JSON.stringify(request_data))
                .then((result) => {
                    const jsonResult = JSON.parse(result);
    
                    if (jsonResult.length > 0 && jsonResult[0].DocumentType) {
                        if(this.profile == 'Usuario estándar' || this.profile == 'Community User Indemnizaciones') {
                            const allowedTypes = ['Autorización del asegurado', 
                                'Fotocopia del documento de identidad', 
                                'Registro civil o certificado de defunción', 
                                'Informe resultado Firma investigadora'];

                            this.tipoDocumentoOptions = jsonResult[0].DocumentType
                                .filter(item => allowedTypes.includes(item.Description__c))
                                .map(item => ({
                                    label: item.Description__c,
                                    value: item.Description__c
                                }));

                        } else {
                            this.tipoDocumentoOptions = jsonResult[0].DocumentType.map(item => ({
                                label: item.Description__c,
                                value: item.Description__c
                            }));
                        }
                    } else {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Error',
                                message: 'No Document Types found.',
                                variant: 'error'
                            })
                        );
                    }
    
                })
                .catch((err) => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error fetching Tipo Documento options',
                            message: err,
                            variant: 'error'
                        })
                    );
                });
        }
        
    }

    handleClasificacionChange(event) {
        this.selectedClasificacion = '';
        this.selectedTipoDocumento = '';
        this.selectedClasificacion = event.detail.value;
        let selected = this.selectedClasificacion.split('&');
        this.validateRequiredFields();
        this.fetchTipoDocumentoOptions(selected[0]);
    }

    handleTipoDocumentoChange(event) {
        this.selectedTipoDocumento = event.detail.value;
        this.validateRequiredFields();
    }


    validateRequiredFields() {
        if(this.selectedClasificacion && this.selectedTipoDocumento) {
            this.isUploadDisabled = false;
        } else {
            this.isUploadDisabled = true;
        }
    }

    handleUploadFinished(event) {
        const uploadedFiles = event.detail.files;
        uploadedFiles.forEach(file => {
            this.handleUpload(file.contentVersionId);
        });
    }

    handleUpload(contentVersionId) {
        let request_data = {
            type: "DataRaptor",
            value: {
                bundleName: "CS_CreateFile",
                inputMap: "{}",
                optionsMap: "{}",
            }
        };

        let selected = this.selectedClasificacion.split('&');

        request_data.value.inputMap = JSON.stringify({
            Data: {
                Classification: selected[1],
                DocumentType: this.selectedTipoDocumento,
                Id: contentVersionId
            }
        });

        util.getDataHandler(JSON.stringify(request_data))
            .then((result) => {
                this.selectedClasificacion = null;
                this.selectedTipoDocumento = null;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Exito',
                        message: 'Documento Cargado Satisfactoriamente.',
                        variant: 'success'
                    })
                );

            })
            .catch((err) => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'handleUpload',
                        message: err,
                        variant: 'error'
                    })
                );
            });
    }
}