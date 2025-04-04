/**
  This custom LWC can be used in a OmniScript to leverage the Google reCaptcha tool.  

  Various examples were used to help with this final component.  
  @see https://www.learnexperiencecloud.com/s/article/Implementing-reCAPTCHA-in-Community-Cloud

  @see https://inevitableyogendra.blogspot.com/2021/09/introducing-google-recaptcha-in-einstein-bots.html
  
  @see https://unofficialsf.com/protect-a-flow-on-a-public-community-with-the-google-recaptcha-component/
  
  @author Derek Cassese - dcassese@salesforce.com
  @version 2.0

  In order to use this you need to setup an account here https://www.google.com/recaptcha/about/ Once you setup your reCaptcha you will have access to the keys needed. 
  Since we can not use anything outside the vlocity_ins namespace this solution leverages a Integration Procedure to handle the server side verification.  
  There are also a few steps require on the Experience Cloud site for this to work correctly as well.   See ReadMe file. 
 
  History
  =======
  May 25, 2022 - v1.0 - Initial Version
  July 28, 2022 - v2.0 - Response Error Handling
  
  Configuration
  =============
  Set the following custom LWC properties for this component
  
  debug                  - show extra debug information in the browser console (Optional, Default = false)

  Notes
  =====
  Response of reCaptcha is sent to the JSON in the key isHuman=(true/false)
  Ex: Step1:CustomLWC1:isHuman

  Error in the response due to incorrect keys or inactive IP are sent in the keys error-code & error
  Ex: Step1:CustomLWC1:error-code & Step1:CustomLWC1:error



 */


  import { LightningElement, api } from 'lwc';
  import { OmniscriptBaseMixin } from 'omnistudio/omniscriptBaseMixin';
  import { getNamespaceDotNotation } from "omnistudio/omniscriptInternalUtils";
  import { getDataHandler } from 'omnistudio/utility';
  
  
  export default class OmniInvisibleRecaptcha extends OmniscriptBaseMixin(LightningElement) {
  
      @api debug;
      _ns = getNamespaceDotNotation();
      isHuman;
      isRendered;
      
  
      connectedCallback() {
          document.addEventListener("grecaptchaVerified", this.handleVerify.bind(this));
          document.addEventListener("grecaptchaExpired", this.handleExpired.bind(this));
         
      }
      // After 2 mins the reCaptcha will expire and we will disable the next Step in the Omniscript which in turn hides the button. 
      handleExpired(e) {
          this.isHuman = false;
          this.omniUpdateDataJson({"isHuman":this.isHuman});
      }
  
      // Function that calls the verify_captcha Integration Procedure.   We look for the response value of "success:true|false"
      handleVerify(e){
        //llamado al servicio
        const options = {};	
        const params = {
            input: JSON.stringify(e.detail),
            sClassName: `${this._ns}IntegrationProcedureService`,
            sMethodName: "colmena_recaptcha",
            options: JSON.stringify(options)
        };
        
        // 7-28-22: Added checks for non-true reaponses from the Integration Procedure.  
        this.omniRemoteCall(params, true).then(response => {
          if(response!=null){
            this.isHuman = response.result.IPResult.success;
              if(this.isHuman) {
                this.omniUpdateDataJson({"isHuman":this.isHuman});
              }else{
                this.omniUpdateDataJson({"isHuman":this.isHuman});
                this.omniUpdateDataJson({"error-code":response.result.IPResult['error-codes']});
                this.omniUpdateDataJson({"error":response.result.IPResult['error']});
              }
          }else {
              this.omniUpdateDataJson({"isHuman":this.isHuman});
              this.omniUpdateDataJson({"error-code":"Check secret key"});
          }
        }).catch(error => {
                console.log(error, 'error');
        });
    }
      
      // In an Omniscript this will be called when we clock the next button so we want to remove the eventListener
      disconnectedCallback() {
          document.dispatchEvent(new CustomEvent("grecaptchaReset", {}));
          document.removeEventListener("grecaptchaVerified", this.handleVerify);
      }
  
      // this is what renders the Captcha.  
      renderedCallback() {
          var divElement = this.template.querySelector('div.recaptchaInvisible');
          var payload = {element: divElement, badge: 'bottomright'};
          document.dispatchEvent(new CustomEvent("grecaptchaRender", {"detail": payload}));
          this.isHuman = false;
          this.omniUpdateDataJson({"isHuman":this.isHuman});
      }
  
  
  }