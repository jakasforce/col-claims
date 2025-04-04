import { LightningElement, api } from 'lwc';
import LightningAlert from 'lightning/alert';
import createRecords from '@salesforce/apex/CR_lwcBudgetsController.createRecords';

export default class LwcAddProductsCR extends LightningElement {
    // Values recieved from parent component
    @api recordId;
    @api productType;
    @api loungesInHotel;
    @api defaultIsh;

    // In order to show correct part of component depending on productType
    typeRoom = false;
    typeEvent = false;
    typeTip = false;

    async connectedCallback() {
        console.log('loungesInHotel: '+this.loungesInHotel);
        switch (this.productType) {
            case 'HABITACIONES':
                console.log('typeRoom');
                this.typeRoom = true;
                break;
            case 'EVENTOS PROGRAMADOS':
                console.log('typeEvent');
                this.typeEvent = true;
                break;
            case 'PROPINAS':
                console.log('typeTip');
                this.typeTip = true; 
                break;
        }
    }

    // Metod to return main menu
    backToMain(event) {
        event.preventDefault();
        const backToMainEvent = new CustomEvent('main');
        this.dispatchEvent(backToMainEvent);  
    }

    // Method to add products
    addProducts(event) {
        console.log('addProductsEvent: '+JSON.stringify(event.detail));
        createRecords({records: JSON.stringify(event.detail.records)}).then( result=> { 
            let res = JSON.parse(result);
            if(!res.success) {
                LightningAlert.open({
                    message: res.message,
                    theme: 'error', 
                    label: 'Ocurrió un error al agregar las partidas de presupuesto', 
                });
            } else {
                LightningAlert.open({
                    message: event.detail.message,
                    theme: 'success', 
                    label: 'Se agregaron los registros', 
                });
                this.backToMain(event);
            }
        });
    }
}