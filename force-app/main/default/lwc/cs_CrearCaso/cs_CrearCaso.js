import { LightningElement, wire, track, api } from 'lwc';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import { createRecord } from 'lightning/uiRecordApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';

//Methods - Controller "CS_CrearCasoController"
import getInsurancePolicy from '@salesforce/apex/CS_CrearCasoController.getInsurancePolicy';
import getClaim from '@salesforce/apex/CS_CrearCasoController.getClaim';
import getTituloCapitalizacion from '@salesforce/apex/CS_CrearCasoController.getTituloCapitalizacion';
import getContacts from '@salesforce/apex/CS_CrearCasoController.getContacts';

//Objects
import CASE_OBJECT from '@salesforce/schema/Case';

//Fields
import RECORDTYPE_FIELD from '@salesforce/schema/Case.RecordTypeId';
import ENTITY_FIELD from '@salesforce/schema/Case.CS_Subtipo__c';
import CONTACT_FIELD from '@salesforce/schema/Case.ContactId';
import ACCOUNT_FIELD from '@salesforce/schema/Case.AccountId';
import NUMERO_POLIZA_FIELD from '@salesforce/schema/Case.CS_Numero_Poliza_de_seguro__c';
import NUMERO_ATEL_FIELD from '@salesforce/schema/Case.CS_Numero_de_ATEL__c';
import NUMERO_SINIESTRO_FIELD from '@salesforce/schema/Case.CS_Siniestro__c';
import NUMERO_ARL_FIELD from '@salesforce/schema/Case.CS_Numero_de_Control_ARL__c';
import TITULO_CAPITALIZACION_FIELD from '@salesforce/schema/Case.CS_Titulo_de_Capitalizaci_n__c';

import PAIS_FIELD from '@salesforce/schema/Case.CS_Pais__c';
import PRODUCTO_FIELD from '@salesforce/schema/Case.ProductId';
import PRODUCTO_M2_FIELD from '@salesforce/schema/Case.CS_ProductoM2__c';
import PRODUCTO_COLMENA_M2_FIELD from '@salesforce/schema/Case.CS_ProductoColmenaM2__c';
import ESTRATEGIA_M2_FIELD from '@salesforce/schema/Case.CS_EstrategiaM2__c';
import RAMO_M2_FIELD from '@salesforce/schema/Case.CS_RamoM2__c';
import CANAL_VENTA_FIELD from '@salesforce/schema/Case.CS_Canal_de_venta__c';
import ESTADO_SINCRONIZACION_FIELD from '@salesforce/schema/Case.CS_EstadoSincronizacionSuperfinanciera__c';
import STATUS_FIELD from '@salesforce/schema/Case.Status';
import ESTADO_QUEJA_RECLAMO_FIELD from '@salesforce/schema/Case.CS_EstadoQuejaReclamo__c';

export default class Cs_CrearCaso extends NavigationMixin(LightningElement) {
    @api recordId;
    @api objectApiName;
    @track showLoading = false;
    @track buttonLabel = 'Siguiente';
    @track disableButton = false;
    @track disableCancelButton = false;
    @track showMessage = false;
    @track message = '';
    @track messageType;
    @track showForm = false;
    @track selectedRT = null;
    @track selectedRTObjName;
    @track selectedLabel;
    @track options = [];
    @track objSearch;
    @track caseRecord = {};
    
    @track isSegurosVida = false;
    @track isARL = false;
    @track isSiniestro = false;
    @track isATEL = false;
    @track isTituloCapitalizacion = false;

    //Entity
    @track selectedEntity;
    entityValues = [];

    //Contact
    @track selectedContact;
    @track contactOptions = [];
    @track contactValues = [];
    @track isPersonAccount;

    @track insurancePolicyName;
    @track insurancePolicyId;
    @track productId;
    @track productoM2;
    @track productoColmenaM2;
    @track estrategiaM2;
    @track canalVenta;
    @track ramo;

    @track numeroContrato;
    @track numeroReclamacion;
    @track numeroTituloCapitalizacion;
    
    @track accountName;
    @track accountId;

    @track caseId;

    arrValidObjects =  ['0YT', '0Zk', 'a1P', 'a1Q'];

    //URL's parameters
    currentPageReference = null;
    urlStateParameters = null;
    urlId = null;
    
    connectedCallback() {
        this.validateUrlParameters();
    }

    //Valida el parámetro enviado por URL "c__recordId"
    validateUrlParameters(){
        if (this.recordId == undefined || this.recordId == ''){
            this.message = 'No se puede crear el caso porque no se envió el id del registro en la URL [c__recordId]';
        }else{
            
            let objectPrefix = this.recordId.substring(0, 3);
            if (!this.arrValidObjects.includes(objectPrefix)) { 
                this.message = 'No se puede crear el caso porque el id del registro no es: Póliza de seguro, reclamo o título de capitalización';
            } else {
                switch (objectPrefix) {
                    case "0YT":
                        this.objSearch = 'InsurancePolicy';
                        break;
                    case "0Zk":
                        this.objSearch = 'Claim';
                        break;
                    case "a1P":
                        this.objSearch = 'CS_Titulo_de_Capitalizacion__c';
                        break;
                    case "a1Q":
                        this.objSearch = 'CS_Titulo_de_Capitalizacion__c';
                        break;
                }
            }
        }
        
        if (this.message != ''){
            this.showToast('Importante', this.message, 'info');
            this.showMessage = true;
        }
    }

    //Obtiene los tipos de registros del caso
    @wire(getObjectInfo, { objectApiName: CASE_OBJECT })
    caseObjectInfo({data, error}) {
        if (data) {
            let optionsValues = [];
            const rtInfos = data.recordTypeInfos;
            let rtValues = Object.values(rtInfos);

            for (let i = 0; i < rtValues.length; i++) {
                if ((rtValues[i].name !== 'Principal') && (rtValues[i].name !== 'Queja Superintendencia') && (rtValues[i].name !== 'Buzón') && (rtValues[i].available !==  false)) {
                    optionsValues.push({
                        label: rtValues[i].name,
                        value: rtValues[i].recordTypeId
                    })
                }
            }

            this.options = this.sortByLabel(optionsValues);
        } else if(error) {
            window.console.log('Error ===> '+JSON.stringify(error));
        }
        this.showLoading = false;
    }

    //Obtiene los parámetros de la URL
    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.urlStateParameters = currentPageReference.state;
            this.setParametersBasedOnUrl();
        }
    }

    setParametersBasedOnUrl() {
        this.urlId = this.urlStateParameters.recordId || null;
        console.log('URL:'+this.urlId);
    }

    //Carga el picklist para el campo Entidad
    @wire(getPicklistValues, {recordTypeId: '$selectedRT',fieldApiName: ENTITY_FIELD})
    getCaseEntityValues
    ({data, error}){
        if(data){
            data.values.forEach(item => this.entityValues.push({label: item.label,value:item.value}) );
        }else if(error){
            console.log('Error'+JSON.stringify(error));
        }
    }

    //Define los datos del objeto
    setObjectData() {
        if ((this.recordId !== '') && (this.objSearch !== '')) {
            switch (this.objSearch) {
                case "InsurancePolicy":
                    this.getInsurancePolicy();
                    break;
                case "Claim":
                    this.getClaim();
                    break;
                case "CS_Titulo_de_Capitalizacion__c":
                    this.getTituloCapitalizacion();
                    break;
            }
        }
    }

    //Manejador para cambio en el tipo de registro
    handleChange(event) {
        this.selectedRT = event.detail.value;
        this.selectedLabel = event.target.options.find(opt => opt.value === event.detail.value).label;
    }

    //Manejador para el cambio en campos
    handleFieldChange(event) {
        if (event.target.type === 'checkbox') {
            this.caseRecord[event.target.name] = event.target.checked;
        }else{
            this.caseRecord[event.target.name] = event.target.value;
            console.log('VALOR-CAMPO:'+event.target.value);
        }
    }

    //Manejador de acción para botón guardar
    handleSave() {
        if (!this.validateForm()) { return false;  }
            
        if (!this.showForm) {
            this.showForm = true;
            this.buttonLabel = 'Guardar';
            this.setObjectData();
        }else{
            this.createCase();
        }
        
    }

    //Manejador de acción para botón cancelar
    handleCancel(){
        this.redirect('/lightning/r/'+this.objSearch+'/'+this.recordId+'/view');
    }

    //Crea el caso
    createCase(){
        try {
            this.showLoading = true;
            this.disableButton = true;
            this.disableCancelButton = true;
            this.buttonLabel = 'Guardando';

            const fields = {};
            fields[RECORDTYPE_FIELD.fieldApiName] = this.selectedRT;
            fields[ENTITY_FIELD.fieldApiName] = this.selectedEntity;
            fields[ACCOUNT_FIELD.fieldApiName] = this.accountId;
            fields[CONTACT_FIELD.fieldApiName] = this.caseRecord['contact'];
            fields[PAIS_FIELD.fieldApiName] = '';

            let caseStatus = 'Nuevo';
            if (this.selectedLabel == 'Queja'){
                caseStatus = 'Borrador';
            }
            fields[STATUS_FIELD.fieldApiName] = caseStatus;
        
            if ((this.isSegurosVida) && (this.insurancePolicyId != undefined && this.insurancePolicyId != '')) {
                fields[NUMERO_POLIZA_FIELD.fieldApiName] = this.insurancePolicyId;
            } else if ((this.isARL) && (this.insurancePolicyId != undefined && this.insurancePolicyId != '')) {
                fields[NUMERO_ARL_FIELD.fieldApiName] = this.insurancePolicyId;
            } else  if ((this.isSiniestro) && (this.claimId != undefined && this.claimId != '')) {
                fields[NUMERO_SINIESTRO_FIELD.fieldApiName] = this.claimId;
            } else  if ((this.isATEL) && (this.claimId != undefined && this.claimId != '')) {
                fields[NUMERO_ATEL_FIELD.fieldApiName] = this.claimId;
            } else if ((this.isTituloCapitalizacion) && (this.tituloCapitalizacionId != undefined && this.tituloCapitalizacionId != '')) {
                fields[TITULO_CAPITALIZACION_FIELD.fieldApiName] = this.tituloCapitalizacionId;
            }

            fields[PRODUCTO_FIELD.fieldApiName] = this.productId;
            fields[PRODUCTO_M2_FIELD.fieldApiName] = this.productoM2;
            fields[PRODUCTO_COLMENA_M2_FIELD.fieldApiName] = this.productoColmenaM2;
            fields[ESTRATEGIA_M2_FIELD.fieldApiName] = this.estrategiaM2;
            fields[RAMO_M2_FIELD.fieldApiName] = this.ramo;
            fields[CANAL_VENTA_FIELD.fieldApiName] = this.canalVenta;
            fields[ESTADO_SINCRONIZACION_FIELD.fieldApiName] = 'Sin Radicar';
            fields[ESTADO_QUEJA_RECLAMO_FIELD.fieldApiName] = '';

            const recordInput = { apiName: CASE_OBJECT.objectApiName, fields };
            createRecord(recordInput)
            .then(CaseObj=> {
                this.caseId = CaseObj.id;
            })
            .catch(error => {
                let message = '';
                console.log('ERROR:'+JSON.stringify(error));
                console.log('FIELDS:'+JSON.stringify(fields));
                if (error.body.output.fieldErrors != undefined && error.body.output.fieldErrors != null) {
                    this.messageType = 'info';
                    console.log('ERROR:'+JSON.stringify(error.body.output.fieldErrors));
                    let fieldErrors = error.body.output.fieldErrors;
                    for (var property in fieldErrors) {
                        var val = Object.values(fieldErrors[property]);
                        message += '-'+val[0]["fieldLabel"]+'('+val[0]["message"] + ') \n ';
                    }
                } else {
                    this.messageType = 'error';
                    message = error.body.message;
                }

                this.showToast('Error', message , this.messageType);
            })
            .finally(() => {
                this.showLoading = false;
                //this.disableButton = false;
                console.log('CASE-ID:'+this.caseId);
                
                if (this.caseId != undefined && this.caseId != '') {
                    this.buttonLabel = 'Guardado';
                    let url = '/lightning/r/Case/'+this.caseId+'/view';
                    this.showToastWithLink('Caso creado', 'Se creó Caso: '+this.caseId, 'success', url);
                    this.redirect(url);
                    
                } else {
                    if (this.messageType == 'info'){
                        this.buttonLabel = 'Guardar';
                        this.disableButton = false;
                    }else{
                        this.buttonLabel = 'Error';
                    }
                    
                }
                this.disableCancelButton = false;
                
            })

        } catch (error) {
            console.log('ERROR:'+ error.message);
            this.showToast('Error', error.message, 'error');
        } 
    }

    //Valida los campos para envío de formulario
    validateForm(){
        let camposFaltantes = '';

        if (this.selectedRT == undefined) {
            this.showForm = false;
            camposFaltantes = '-Tipo de registro del caso ';
        }else{
            
            if (this.showForm){
                if (this.selectedEntity == undefined ||  this.selectedEntity == ''){
                    camposFaltantes += '-Entidad ';
                }

                if (this.caseRecord['contact'] == undefined || this.caseRecord['contact'] == ''){
                    camposFaltantes += '-Contacto ';
                }
            }

            if ((this.isARL) && (this.insurancePolicyName == undefined || this.insurancePolicyName == '')){
                camposFaltantes += '-Número de contrato ';
            }

            if ((this.isSegurosVida) && (this.insurancePolicyName == undefined || this.insurancePolicyName == '')){
                camposFaltantes += '-Número Póliza de seguro ';
            }

            if ((this.isSiniestro) && (this.numeroReclamacion == undefined || this.numeroReclamacion == '')){
                camposFaltantes += '-Número de siniestro ';
            }

            if ((this.isATEL) && (this.numeroReclamacion == undefined || this.numeroReclamacion == '')){
                camposFaltantes += '-Número de ATEL ';
            }

            if ((this.isTituloCapitalizacion) && (this.numeroTituloCapitalizacion == undefined || this.numeroTituloCapitalizacion == '')){
                camposFaltantes += '-Título de capitalización';
            }

            if ((this.isSiniestro) || (this.isSegurosVida) || (this.isATEL)) {
                if (this.ramo == '') {
                    camposFaltantes += '-Ramo ';
                }

                if (this.productoM2 == undefined || this.productoM2 == '') {
                    camposFaltantes += '-Producto M2 ';
                }

                if (this.productoColmenaM2 == undefined || this.productoColmenaM2 == '') {
                    camposFaltantes += '-Producto Colmena M2 ';
                }

                if (this.estrategiaM2 == undefined || this.estrategiaM2 == '') {
                    camposFaltantes += '-Estrategia ';
                } 

                if (this.canalVenta == undefined || this.canalVenta == '') {
                    camposFaltantes += '-Canal de venta ';
                }
            }


            if ((this.isARL) || (this.isATEL) || (this.isTituloCapitalizacion)) {
                if (this.productoM2 == undefined || this.productoM2 == '') {
                    camposFaltantes += '-Producto M2 ';
                }
            }
        }

        if (camposFaltantes != '') {
            this.showToast('Completa los campos obligatorios', camposFaltantes, 'info');
            return false;
        }

        return true;
    }

    //Obtiene la póliza de seguro -> "insurancePolicy"
    getInsurancePolicy() {
        getInsurancePolicy({"id":this.recordId})
          .then((data) => {
            let insurancePolicy = data[0];
            console.log('POLIZA:'+JSON.stringify(insurancePolicy));
            this.selectedRTObjName = insurancePolicy.RecordType.DeveloperName;
            this.insurancePolicyName = insurancePolicy.Name;
            this.insurancePolicyId = insurancePolicy.Id;
            this.accountName = insurancePolicy.NameInsured.Name;
            this.accountId = insurancePolicy.NameInsuredId;
            this.isPersonAccount = insurancePolicy.NameInsured.IsPersonAccount;
            
            if (insurancePolicy.ProductId != undefined && insurancePolicy.ProductId != ''){
                this.productId = insurancePolicy.ProductId;
                this.productoM2 = insurancePolicy.Product.CS_Producto_M2__c;
                this.productoColmenaM2 = insurancePolicy.Product.CS_Producto_Colmena_M2__c;
                this.estrategiaM2 = insurancePolicy.CS_Estrategia__c;  //SE TRAN DE LA POLIZA
                this.canalVenta = insurancePolicy.RenewalChannel; //SE TRAN DE LA POLIZA
                this.ramo = insurancePolicy.Product.Family;
            }

            if (this.isPersonAccount){
                this.setContact(insurancePolicy.NameInsured.PersonContact.Name, insurancePolicy.NameInsured.PersonContactId);
            }
            
            this.getContacts();
            if (this.selectedRTObjName == 'CS_Seguro_de_vida') {
                this.selectedEntity = '2';
                this.isSegurosVida = true;
                
            } else if (this.selectedRTObjName == 'CS_Contrato_ARL') {
                this.selectedEntity = '1';
                this.numeroContrato = insurancePolicy.CS_NumeroContrato__c;
                this.isARL = true;
            }
          })
          .catch((error) => {
            console.log(error);
          }
        )
    }

    //Obtiene la reclamación -> "insurancePolicy"
    getClaim() {
        getClaim({"id":this.recordId})
          .then((data) => {
            let claim = data[0];
            console.log('RECLAMACION:'+JSON.stringify(claim));
            this.selectedRTObjName = claim.RecordType.DeveloperName;
            //this.claimName = claim.Name;
            this.claimId = claim.Id;
            this.accountName = claim.Account.Name;
            this.accountId = claim.AccountId;
            this.isPersonAccount = claim.Account.IsPersonAccount;
            this.numeroReclamacion = claim.Name;
            this.estrategiaM2 = claim.PolicyNumber.CS_Estrategia__c;
            this.canalVenta = claim.PolicyNumber.RenewalChannel;
        
            if (claim.PolicyNumber.ProductId != undefined && claim.PolicyNumber.ProductId != ''){
                this.productId = claim.PolicyNumber.ProductId;
                this.productoM2 = claim.PolicyNumber.Product.CS_Producto_M2__c;
                this.productoColmenaM2 = claim.PolicyNumber.Product.CS_Producto_Colmena_M2__c;
                this.ramo = claim.PolicyNumber.Product.Family;
            }

            if (this.isPersonAccount){
                this.setContact(claim.Account.PersonContact.Name, claim.Account.PersonContactId);
            }
            
            this.getContacts();
            console.log('TIPO-REGISTRO:'+this.selectedRTObjName);

            if (this.selectedRTObjName == 'CS_Siniestro') {
                this.selectedEntity = '2';
                this.isSiniestro = true;
            } else if (this.selectedRTObjName == 'CS_AT' || this.selectedRTObjName == 'CS_EL') {
                this.selectedEntity = '1';
                this.isATEL = true;
            }
          })
          .catch((error) => {
            console.log(error);
          }
        )
    }

    //Obtiene la reclamación -> "insurancePolicy"
    getTituloCapitalizacion() {
        getTituloCapitalizacion({"id":this.recordId})
          .then((data) => {
            let tituloCapitalizacion = data[0];
            console.log('TITULO-CAPITALIZACION:'+JSON.stringify(tituloCapitalizacion));
            this.numeroTituloCapitalizacion = tituloCapitalizacion.Name;
            this.tituloCapitalizacionId = tituloCapitalizacion.Id;
            this.accountName = tituloCapitalizacion.CS_Cuenta__r.Name;
            this.accountId = tituloCapitalizacion.CS_Cuenta__c;
            this.isPersonAccount = tituloCapitalizacion.CS_Cuenta__r.IsPersonAccount;
            this.estrategiaM2 = tituloCapitalizacion.CS_Estrategia__c;
            this.canalVenta = tituloCapitalizacion.CS_Canal_de_venta__c;
            
            if (tituloCapitalizacion.CS_Producto__c != undefined && tituloCapitalizacion.CS_Producto__c != ''){
                this.productId = tituloCapitalizacion.CS_Producto__c;
                this.productoM2 = tituloCapitalizacion.CS_Producto__r.CS_Producto_M2__c;
                this.productoColmenaM2 = tituloCapitalizacion.CS_Producto__r.CS_Producto_Colmena_M2__c;
                this.ramo = tituloCapitalizacion.CS_Producto__r.Family;
            }
        
            if (this.isPersonAccount){
                this.setContact(tituloCapitalizacion.CS_Cuenta__r.PersonContact.Name, tituloCapitalizacion.CS_Cuenta__r.PersonContactId);
            }
            
            this.getContacts();
            this.isTituloCapitalizacion = true;
            this.selectedEntity = '3';
          })
          .catch((error) => {
            console.log(error);
          }
        )
    }

    //Obtiene los contactos
    getContacts() {
        getContacts({"id":this.accountId})
          .then((data) => {
            let contactOptionsList = [];
            contactOptionsList = data.map((cls) => Object.assign({}, { label: cls.Contact.Name, value: cls.ContactId })); 
            this.contactOptions = this.contactOptions.concat(contactOptionsList);
            this.contactValues = this.sortByLabel(this.contactOptions);            
          })
          .catch((error) => {
            console.log(error);
        })
    }

    //Define el contacto por defecto
    setContact(personContactName, personContactId){
        this.contactOptions.push({label:personContactName, value:personContactId});
        this.selectedContact = personContactId;
        this.caseRecord['contact'] = personContactId;
    }

    //Ordena por la etiqueta "label"
    sortByLabel(optionsValues){
        optionsValues.sort((a, b) => {
            let fa = a.label,
                fb = b.label;
        
            if (fa < fb) {
                return -1;
            }
            if (fa > fb) {
                return 1;
            }
            return 0;
        });

        return optionsValues;
    }

    //Realiza una redirección
    redirect(pUrl) {
        window.location.href = pUrl;
    }

    //Muestra mensaje toast
    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message:message,
            variant:variant
        });
        this.dispatchEvent(event);
    }

    //Muestra mensaje toast con hipervinculo
    showToastWithLink(title, pMessage, variant, pUrl) {
        const event = new ShowToastEvent({
            title: title,
            message:'Se ha creado el {0}! Ver registro {1}',
            variant:variant,
            messageData: [
                'caso',
                {
                    url: pUrl,  
                    label: 'aquí'
                },
            ],
        });
        this.dispatchEvent(event);
    }
}