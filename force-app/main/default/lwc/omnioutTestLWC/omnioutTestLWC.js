import { LightningElement, wire } from 'lwc';
import { OmniscriptBaseMixin } from 'omnistudio/omniscriptBaseMixin';
import validateCaptcha from '@salesforce/apex/TestRecpatcha.validateCaptcha';
//import { getNamespaceDotNotation } from "omnistudio/omniscriptInternalUtils";
//import { OmniscriptActionCommonUtil } from 'omnistudio/omniscriptActionUtils';
import { getDataHandler } from 'omnistudio/utility';


export default class OmnioutTestLWC extends OmniscriptBaseMixin(LightningElement) {

    //_ns = getNamespaceDotNotation();
    //_actionUtilClass; 

    connectedCallback() {
        //this._actionUtilClass = new OmniscriptActionCommonUtil();
        //console.log('Namespace omniout: ' + this._ns);
        //this.callIP();
        console.log('JSON from OS: ' + JSON.stringify(this.omniJsonData));
        //this.handleIPMethod();
        this.handleKeyChange();
    }

    handleKeyChange(){
		validateCaptcha({ userToken: '' })
		.then(result => {
			console.log('result: ' + result);
		})
		.catch(error => {
            console.log('error: ' + error);
		})
	}

    handleIPMethod() {

        const options = {};	
        const tempObject = {};	

        const datasource = JSON.stringify({
            type: 'integrationprocedure',
            value: {
                ipMethod: 'getAccount_test',  //This will be dataraptor name(required)
                inputMap: tempObject,//which contains the values to update(required)
                optionsMap: options // which contains the options(optional)
            }
        });

        console.log('datasource: ' + datasource);
        
     getDataHandler(datasource).then(data => { //getDatahandler method to call dataraptor
         console.log('outputload-->'+data);
        this.omniUpdateDataJson(JSON.parse(data));
     }). catch (error=> {
        console.log('error:'+ JSON.stringify(error));
    });
    }



    /*callIP(){

            console.log('Namespace: ' + this._ns);
          
          const options = {};	
          const params = {
              input: undefined,
              sClassName: `${this._ns}IntegrationProcedureService`,
              sMethodName: "getAccount_test",
              options: JSON.stringify(options)
          };
          console.log('IP Params: '+ JSON.stringify(params));
          
          // 7-28-22: Added checks for non-true reaponses from the Integration Procedure.  
          this.omniRemoteCall(params, true).then(response => {
            if(response!=null){
                console.log('Respuesta: ' + JSON.stringify(response));
               
                
            }else {

                //this.omniUpdateDataJson({"isHuman":this.isHuman});
                //this.omniUpdateDataJson({"error-code":"Check secret key"});
            }
          }).catch(error => {
                  console.log(error, 'error');
              });
      }*/
}