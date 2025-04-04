import { LightningElement, api, track } from 'lwc';
import LightningAlert from 'lightning/alert';
import getRoomTypes from '@salesforce/apex/CR_lwcBudgetsController.getRoomTypes';
import getAvaliableProducts from '@salesforce/apex/CR_lwcBudgetsController.getAvaliableProducts';

export default class LwcRoomType extends LightningElement {
    @api recordId;
    @api productType;
    @api defaultIsh;

    // In order to show options for formulary
    _roomTypes = [];

    _room2quantity = new Map();
    _room2price = new Map();

    _concept;
    _endDate;
    _startDate;
    _iva = 16;
    _avaliableRoomsByHotel;

    _product2info;

    async connectedCallback() {
        getRoomTypes().then(result=> { this._avaliableRoomsByHotel = JSON.parse(result); console.log('recordId:'+this.recordId);});
        getAvaliableProducts({productType: this.productType})
            .then( result=> { 
                let res = JSON.parse(result);
                this._product2info = {
                    name: res[0].Name,
                    id: res[0].Id,
                    pricebookEntryId: res[0].PricebookEntries.records[0].Id
                };
                console.log('_product2info: '+this._product2info)
            });
    }
    
    roomTypeChange(e) {
        this._roomTypes = e.detail.value;
    }

    startDateChange(e) {
        this._startDate = e.detail.value;
    }

    endDateChange(e) {
        this._endDate = e.detail.value;
    }

    conceptChange(e) {
        this._concept = e.detail.value;
    }

    quantityChange(event) {
        this._room2quantity.set(event.target.dataset.room, event.detail.value);
    }

    priceChange(event) {
        this._room2price.set(event.target.dataset.room, event.detail.value);
    }

    ivaChange(e) {
        this._iva = e.detail.value;
        console.log('_iva: '+this._iva);
    }

    ishChange(e) {
        this.defaultIsh = e.detail.value;
    }

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
                this._roomTypes.length <= 0 || !this._iva || !this.defaultIsh || !this._startDate || 
                !this._endDate || this._room2quantity.size <= 0 ||  this._room2price.size <= 0 ) {
            await LightningAlert.open({
                message: 'Valores ingresados con conflicto, revisar y corregir',
                theme: 'error', 
                label: 'Valores inválidos', 
            }); 
        } else {
            let initialDate = new Date(this._startDate.replace(/-/g, '\/'));
            let elementDate = new Date(initialDate);
            for(let i=0; i< days; i++) {
                this._roomTypes.forEach( type => {
                    let quoteLineItem = {
                        CR_TipoHabitacion__c: type,
                        CR_Concepto__c: this._concept,
                        CR_ISH__c: this.defaultIsh,
                        CR_IVA__c: this._iva,
                        CR_TipoProducto__c: this.productType,
                        Product2Id: this._product2info.id,
                        PricebookEntryId: this._product2info.pricebookEntryId,
                        QuoteId: this.recordId,
                        Quantity: this._room2quantity.get(type),
                        UnitPrice: this._room2price.get(type),
                        CR_Fecha__c: elementDate.toISOString().slice(0,10)
                    }
                    quoteLineItems.push(quoteLineItem);
                });
                elementDate.setDate(elementDate.getDate() + 1);
            }
            event.preventDefault();
            const addProductsEvent = new CustomEvent('addproducts', {
                detail: { 
                    records : quoteLineItems,
                    message: 'Habitaciones agregadas correctamente'
                }
            });
            this.dispatchEvent(addProductsEvent);
        }
    }

}