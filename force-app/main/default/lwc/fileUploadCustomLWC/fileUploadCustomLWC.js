import { api } from 'lwc';
import { OmniscriptBaseMixin } from 'omnistudio/omniscriptBaseMixin';
import OmniscriptFile from 'omnistudio/omniscriptFile'
import tmpl from './fileUploadCustomLWC.html';
const MAX_FILE_SIZE = 25000000;
export default class FileUploadCustomLWC extends OmniscriptBaseMixin(OmniscriptFile) {
    sum = 0;
    @api checkValidity() { 
        return this.sum < 100;
    }

    connectedCallback(){
        super.connectedCallback();
    }

    get acceptedFormats() {
        return ['.pdf', '.png' , '.mpg' ,'.jpg' , '.gif', '.zip'];
    }

    /*handleUploadFinished(event) {


        console.log('event: ' + event);
        //console.log('event: ' + JSON.stringify(event));

        //this.checkValidity();
        
        //this.notifyError('Archivo muy pesado ' + this._value);
    }*/

    render() {
        return tmpl;
    }

}