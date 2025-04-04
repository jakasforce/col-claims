import { LightningElement, api } from 'lwc';
import LightningAlert from 'lightning/alert';
import getMountingTypes from '@salesforce/apex/CR_lwcBudgetsController.getMountingTypes';
import getEventTypes from '@salesforce/apex/CR_lwcBudgetsController.getEventTypes';
import getAvaliableProducts from '@salesforce/apex/CR_lwcBudgetsController.getAvaliableProducts';

export default class CrProgrammedEventType extends LightningElement {
    @api recordId;
    @api productType;
    @api loungesInHotel;
    // Vars to show picklist options
    mountingTypes;
    eventTypes;
    avaliableProducts;
    
    // vars to save frontend data
    _product2;
    _event;
    _mounting;
    _startDate;
    _endDate;
    _startTime;
    _endTime;
    _lounge;
    _concept;
    _detail;
    _quantity;
    _price;
    _iva;
    _service;

    _product2pricebookEntry = new Map();

    async connectedCallback() {
        console.log('loungesInHotel: '+this.loungesInHotel);
        let avaliableProductsList = [];
        getAvaliableProducts({productType: this.productType})
            .then( result=> { 
                JSON.parse(result).forEach( element => {
                    avaliableProductsList.push({value: element.Id, label: element.Name});
                    this._product2pricebookEntry.set(element.Id, element.PricebookEntries.records[0].Id);
                });
                this.avaliableProducts = avaliableProductsList;
            });
        getMountingTypes().then( result=> { this.mountingTypes = JSON.parse(result); console.log('mountingTypes: '+this.mountingTypes);});
        getEventTypes().then( result=> { this.eventTypes = JSON.parse(result); });
    }

    product2change(e) { this._product2 = e.detail.value; }
    mountingTypeChange(e) { this._mounting = e.detail.value; }
    eventTypeChange(e) { this._event = e.detail.value; }
    startDateChange(e) { this._startDate = e.detail.value; }
    endDateChange(e) { this._endDate = e.detail.value; }
    startTimeChange(e) { this._startTime = e.detail.value; }
    endTimeChange(e) { this._endTime = e.detail.value; }
    loungeChange(e) { this._lounge = e.detail.value; }
    conceptChange(e) { this._concept = e.detail.value; }
    detailChange(e) { this._detail = e.detail.value; }
    quantityChange(e) { this._quantity = e.detail.value; }
    priceChange(e) { this._price = e.detail.value; }
    ivaChange(e) { this._iva = e.detail.value; }
    serviceChange(e) { this._service = e.detail.value; }

    // Metod to return main menu
    backToMain(event) {
        event.preventDefault();
        const backToMainEvent = new CustomEvent('main');
        this.dispatchEvent(backToMainEvent);  
    }

    async addProducts(event) {            
        let timeDifference = new Date(this._endDate).getTime() - new Date(this._startDate).getTime();
        let days = timeDifference / (1000 * 3600 * 24);
        let quoteLineItems = [];
        if(days < 0) {
            await LightningAlert.open({
                message: 'La fecha de salida no puede ser anterior a la fecha de entrada',
                theme: 'error', 
                label: 'Fechas no válidas', 
            });
        } else if (
            !this._concept || !this._startDate || !this._endDate || !this._startTime || !this._endTime) {
            await LightningAlert.open({
                message: 'Valores ingresados con conflicto, revisar y corregir',
                theme: 'error', 
                label: 'Valores inválidos', 
            }); 
        } else {
            let initialDate = new Date(this._startDate.replace(/-/g, '\/'));
            let elementDate = new Date(initialDate);
            for(let i=0; i<= days; i++) {
                let quoteLineItem = {
                    CR_TipoEvento__c: this._event,
                    CR_Concepto__c: this._concept,
                    CR_DetalleRenta__c : this._detail,
                    CR_Servicio__c: this._service,
                    CR_IVA__c: this._iva,
                    CR_TipoProducto__c: this.productType,
                    Product2Id: this._product2,
                    PricebookEntryId: this._product2pricebookEntry.get(this._product2),
                    QuoteId: this.recordId,
                    Quantity: this._quantity,
                    UnitPrice: this._price,
                    CR_Montaje__c: this._mounting,
                    CR_Salon__c: this._lounge,
                    CR_Fecha__c: elementDate.toISOString().slice(0,10),
                    CR_HoraInicio__c: this._startTime.slice(0, 5),
                    CR_HoraFin__c: this._endTime.slice(0, 5)
                }
                quoteLineItems.push(quoteLineItem);
                elementDate.setDate(elementDate.getDate() + 1);
            }
            event.preventDefault();
            const addProductsEvent = new CustomEvent('addproducts', {
                detail: { 
                    records : quoteLineItems,
                    message: 'Eventos agregados correctamente'
                }
            });
            this.dispatchEvent(addProductsEvent);
        }
    }
}