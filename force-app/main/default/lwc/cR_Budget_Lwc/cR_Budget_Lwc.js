import { LightningElement, api, wire } from 'lwc';
import LightningAlert from 'lightning/alert';
import getQuoteLineItems from '@salesforce/apex/CR_lwcBudgetsController.getQuoteLineItems';
import getProductTypes from '@salesforce/apex/CR_lwcBudgetsController.getProductTypes';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import LOUGE_ROOMS from '@salesforce/schema/Quote.CR_Hotel__r.CR_Salones__c';
import ISH_FIELD from '@salesforce/schema/Quote.CR_Hotel__r.CR_ISH__c';
import { getRecord, getFieldValue, deleteRecord, updateRecord } from 'lightning/uiRecordApi';

export default class CR_Budget_Lwc extends LightningElement {
    @api recordId;

    productTypes;
    productType = null;
    
    principal = true;
    createProductsLwc = false;

    quoteLineItemsByType;

    @api isLoaded = false;

    @wire(getRecord, { recordId: '$recordId', fields: [LOUGE_ROOMS, ISH_FIELD], optionalFields: [] })
    hotelData;
    @api loungesInHotel;
    @api defaultIsh;

    saveDraftValues;

    get loungesInHotel() {
        let response = [];
        let res = getFieldValue(this.hotelData.data, LOUGE_ROOMS);
        if(res) {
            const loungeList = res.split(";");
            loungeList.forEach( element => {
                response.push({value: element, label: element});
            })
            return response;
        }
    }

    get defaultIsh() {
        return getFieldValue(this.hotelData.data, ISH_FIELD);
    }
    
    connectedCallback() {
        this.isLoaded = false;
        getProductTypes()
            .then(result=> { this.productTypes = JSON.parse(result); console.log('productTypes'+this.productTypes); });
        getQuoteLineItems({recordId: this.recordId})
            .then(result=> { this.quoteLineItemsByType = JSON.parse(result); this.isLoaded = !this.isLoaded;});
    } 

    handleChange(event) {
        this.productType = event.detail.value;
    }

    async launchAddProducts(event) {
        if(this.productType == null) {
            await LightningAlert.open({
                message: 'Selecciona un opción válida',
                theme: 'error', 
                label: 'Opción no válida', 
            });
        } else {
            this.principal = false;
            this.createProductsLwc = true;
        }
    }

    backToMain(event) {
        this.connectedCallback();
        this.principal = true;
        this.createProductsLwc = false;
    }

    async rowAction(event) {
        const recordId =  event.detail.row.Id;
        const action = event.detail.action.name;
        switch (action) {
            case 'Eliminar':
                console.log('Delete Record');
                deleteRecord(recordId)
                    .then(() => {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Exitoso',
                                message: 'Registro eliminado',
                                variant: 'success'
                            })
                        )
                        this.connectedCallback();
                    });
                break;
        }
    }

    async saveRecords(event) {
        this.isLoaded = false;
        this.saveDraftValues = event.detail.draftValues;
        const recordInputs =  this.saveDraftValues.slice().map(draft => {
            const fields = Object.assign({}, draft);
            return { fields };
        });
        const promises = recordInputs.map(recordInput => updateRecord(recordInput));
        Promise.all(promises).then(res => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Exitoso',
                    message: 'Registros actualizados',
                    variant: 'success'
                })
            );              
            this.connectedCallback();
        }).catch(error => {
             this.dispatchEvent(
                new ShowToastEvent({
                   title: 'Error en la actualización',
                   message: error.body.message,
                   variant: 'error'
                })
             );
        }).finally(() => {
            this.saveDraftValues = [];
        });
    }
}