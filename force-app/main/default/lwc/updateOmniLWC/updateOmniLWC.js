import { LightningElement } from 'lwc';
import { OmniscriptBaseMixin } from 'omnistudio/omniscriptBaseMixin';

export default class UpdateOmniLWC extends OmniscriptBaseMixin(LightningElement) {

    connectedCallback() {
        
        console.log('Current OS JSON: '+JSON.stringify(this.omniJsonData));

        //this.handleVerify = this.handleVerify(this);
        document.addEventListener("grecaptchaVerified", this.handleVerify);
        document.addEventListener("grecaptchaExpired", this.handleExpired);
        
        console.log('Datos actualizados');
       
    }

    handleVerify(e){
        console.log('segundo error');
        console.log('Current event data: '+ JSON.stringify(e.detail));

        const data = {
            lwcMessage : 'Mensaje enviado desde LWC UpdateOmniLWC'
        }
        this.omniApplyCallResp(data);
    }
}