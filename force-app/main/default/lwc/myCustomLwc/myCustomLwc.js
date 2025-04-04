import { api , track } from 'lwc';
import { OmniscriptBaseMixin } from 'omnistudio/omniscriptBaseMixin';
import OmniscriptFile from 'omnistudio/omniscriptFile';
import tmpl from './myCustomLwc.html';
export default class MyCustomLwc extends OmniscriptBaseMixin(OmniscriptFile) {

    /*@api
    recordId;

    @track
    responseData;
    hasRequiredEmptyFields;
    document_by_coverage;

    @api checkValidity() { 
        return this.sum < 100;
    }*/

    connectedCallback(){
        super.connectedCallback();
    }

    get acceptedFormats() {
        return ['.pdf', '.png', '.docx'];
    }

   /* connectedCallback() {
        /*this.recordId = JSON.parse(JSON.stringify(this.omniJsonData))?.claimId;
        this.document_by_coverage = JSON.parse(JSON.stringify(this.omniJsonData))?.responseData;
        //If result it´s not an array, convert to array
        if (!Array.isArray(this.document_by_coverage)) {
          this.document_by_coverage = [this.document_by_coverage];  
        }
        console.log(JSON.stringify(this.document_by_coverage));
        this.checkRequiredDocuments();
    } 

    checkRequiredDocuments() {

      // Check required and empty documents
      this.hasRequiredEmptyFields = this.document_by_coverage.filter((document) => document.is_required && document.document_id == null);
      const data = {
        hasRequiredEmptyFields : this.hasRequiredEmptyFields.length > 0
      }
      this.omniApplyCallResp(data);
    } */

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