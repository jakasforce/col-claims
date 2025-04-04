import { LightningElement, api } from 'lwc';
import LightningAlert from 'lightning/alert';
import getAvaliableProducts from '@salesforce/apex/CR_lwcBudgetsController.getAvaliableProducts';

export default class lwcTipType extends LightningElement {
    @api recordId;
    @api productType;

    //vars to show frontend data Options
    avaliableProducts;

    // vars to save frontend data
    _product2;
    _concept;
    _quantity;
    _price;
    _description;

    //Map to save PricebookEntry -> Product2 relation
    _product2pricebookEntry = new Map();

    async connectedCallback() {
        let avaliableProductsList = [];
        getAvaliableProducts({productType: this.productType})
            .then( result=> { 
                JSON.parse(result).forEach( element => {
                    avaliableProductsList.push({value: element.Id, label: element.Name});
                    this._product2pricebookEntry.set(element.Id, element.PricebookEntries.records[0].Id);
                });
                this.avaliableProducts = avaliableProductsList;
            });
    }

    product2change(e) { this._product2 = e.detail.value; }
    conceptChange(e) { this._concept = e.detail.value; }
    quantityChange(e) { this._quantity = e.detail.value; }
    priceChange(e) { this._price = e.detail.value }
    descriptionChange(e) { this._description = e.detail.value }

    backToMain(event) {
        event.preventDefault();
        const backToMainEvent = new CustomEvent('main');
        this.dispatchEvent(backToMainEvent);  
    }

    async addProducts(event) {            
        let quoteLineItems = [];
        if (!this._concept || !this._product2 || !this._quantity || !this._price) {
            await LightningAlert.open({
                message: 'Por favor ingresa todos los datos requeridos *',
                theme: 'error', 
                label: 'Valores inválidos', 
            }); 
        } else {
                let quoteLineItem = {
                    CR_Concepto__c: this._concept,
                    CR_TipoProducto__c: this.productType,
                    Product2Id: this._product2,
                    PricebookEntryId: this._product2pricebookEntry.get(this._product2),
                    QuoteId: this.recordId,
                    Quantity: this._quantity,
                    UnitPrice: this._price,
                    Description: this._description
                }
                quoteLineItems.push(quoteLineItem);
                event.preventDefault();
                const addProductsEvent = new CustomEvent('addproducts', {
                    detail: { 
                        records : quoteLineItems,
                        message: 'Propina agregada correctamente'
                    }
                });
                this.dispatchEvent(addProductsEvent);
            }
        }
}