import { LightningElement, track } from 'lwc';
import pageUrl from '@salesforce/resourceUrl/recaptchaV2';
 
export default class RecaptchaV2 extends LightningElement {
    @track navigateTo;
 
    constructor(){
        super();
        this.navigateTo = pageUrl;
        window.addEventListener("message", this.listenForMessage);//add event listener for message that we post in our recaptchaV2 static resource html file.
    }
 
    captchaLoaded(event){
        if(event.target.getAttribute('src') == pageUrl){
            console.log('Google reCAPTCHA is loaded.');
        } 
    }
 
    listenForMessage(message){
        console.log('message data : ' + message.data);//message.data - The object passed from the other window.
        console.log('message origin : ' + message.origin);//message.origin - The origin of the window that sent the message at the time postMessage was called.
    }
}