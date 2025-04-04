import { FlexCardMixin } from "omnistudio/flexCardMixin";
    import { CurrentPageReference } from 'lightning/navigation';
    import {interpolateWithRegex, interpolateKeyValue, loadCssFromStaticResource } from "omnistudio/flexCardUtility";
    
          import { LightningElement, api, track, wire } from "lwc";
          import pubsub from "omnistudio/pubsub";
          import { getRecord } from "lightning/uiRecordApi";
          import { OmniscriptBaseMixin } from "omnistudio/omniscriptBaseMixin";
          import data from "./definition";
          
          import styleDef from "./styleDefinition";
              
          export default class cfTestFormulario8_1_Ardila extends FlexCardMixin(OmniscriptBaseMixin(LightningElement)){
              currentPageReference;        
              @wire(CurrentPageReference)
              setCurrentPageReference(currentPageReference) {
                this.currentPageReference = currentPageReference;
              }
              @api debug;
              @api recordId;
              @api objectApiName;
              @track _omniSupportKey = 'cfTestFormulario8_1_Ardila';
                  @api get omniSupportKey() {
                    return this._omniSupportKey;
                  }
                  set omniSupportKey(parentRecordKey) {
                    this._omniSupportKey = this._omniSupportKey  + '_' + parentRecordKey;
                  }
              @track record;
              
              
              pubsubEvent = [];
              customEvent = [];
              
              connectedCallback() {
                super.connectedCallback();
                this.setThemeClass(data);
                this.setStyleDefinition(styleDef);
                data.Session = {} //reinitialize on reload
                
                this.flexiPageWidthAwareCB = this.flexiPageWidthAware.bind(this);
                  window.addEventListener('resize', this.flexiPageWidthAwareCB);
                
                this.setDefinition(data);
 this.registerEvents();
                
                
              }
              
              disconnectedCallback(){
                super.disconnectedCallback();
                    this.omniSaveState(this.records,this.omniSupportKey,true);
                    window.removeEventListener('resize', this.flexiPageWidthAwareCB);

                  this.unregisterEvents();
              }

              registerEvents() {
                
              }

              unregisterEvents(){
                
              }
            
              renderedCallback() {
                super.renderedCallback();
                
                if(!this.containerWidthInitialised) {
                  this.containerWidthInitialised = true;
                  this.flexiPageWidthAware();
                }
              }
          }