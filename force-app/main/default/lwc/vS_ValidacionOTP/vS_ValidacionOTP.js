import { LightningElement, api, wire, track } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';

import getAccountInfo from '@salesforce/apex/VS_ValidacionOTPController.getAccountInfo';
import getAccountInfoWithAccountId from '@salesforce/apex/VS_ValidacionOTPController.getAccountInfoWithAccountId';
import getAccountInfoFromContact from '@salesforce/apex/VS_ValidacionOTPController.getAccountInfoFromContact';
import getAccountInfoBeneficiario from '@salesforce/apex/VS_ValidacionOTPController.getAccountInfoBeneficiario';
import callRegistraduriaAndUpdateAccount from '@salesforce/apex/VS_ValidacionOTPController.callRegistraduriaAndUpdateAccount';
import sendOPTCode from '@salesforce/apex/VS_ValidacionOTPController.sendOPTCode';
import validateSendedOPTCode from '@salesforce/apex/VS_ValidacionOTPController.validateSendedOPTCode';
import saveValidatedDateInAccount from '@salesforce/apex/VS_ValidacionOTPController.saveValidatedDateInAccount';
import savePolicy from '@salesforce/apex/VS_ValidacionOTPController.savePolicy';

import insertLogValidation from '@salesforce/apex/VS_ValidacionOTPController.insertLogValidation';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import SobjectType from '@salesforce/schema/RecordType.SobjectType';

const tiposDeIdentificacion = [
    "Cédula de ciudadanía",
    "Cédula de extranjería",
    "Número de identificación tributaria (NIT)",
    "Tarjeta de identidad",
    "Pasaporte",
    "Carné diplomático",
    "Sociedad extranjera sin NIT en Colombia",
    "Fideicomiso, fondos de inversión colectiva, fondo o patrimonio autónomo",
    "Número único de identificación personal (NUIP)",
    "Permiso por protección temporal (PPT)",
    "Permiso especial de permanencia (PEP)"
  ];

export default class VS_ValidacionOTP extends LightningElement {
    // * Id del registro
    @api recordId;
    @api accountId;

    @track isLoading = false;

    @track isError = false
    @track warningMessage;

    @track disableNextButton = true;

    // * Información de la cuenta
    @api isCalled = false;

    @track accountInfo = {};
    @track isContactToValidate = false;

    @api accountTipIdenLabel;

    @track screenToSelectPerson = true;
    @track screenToSelectpolicyOrBen = false;
    @track screenA = false;
    @track screenB = false;
    @track screenC = false;

    @track approvedCodeOTP = false;
    @track ErrorApprovedCodeOTP = false;
    @track ErrorApprovedCodeOTPMessagge = 'No fue posible validar las respuestas del cliente';

    @track validationRegistry;
    @track transactionId;

    @track canalToSend = "SMS";

    @track OTPCode;

    @track beneficiariosList;
    @track policyList;
    @track areTherePolicyToSelect;

    @track selectedPolicy;
    @track selectedBene;

    /*
    @api tipoIdentificacion;
    @api numeroIdentificacion;
    @api firstName;
    @api middleName;
    @api lastName;
    @api suffix;
    @api expeditionDate;
    @api phone;
    */

    @api totalTimeInSeconds = 90;
    @track countTime;
    @track showCountTime = 100;

    intervalId;

    @track nextScreenAfterCorrectValidation = true;

    @wire(getRecord, { recordId: '$recordId' })

    connectedCallback() {
        // Lógica que deseas ejecutar al iniciar el componente
        if (this.accountId && !this.isCalled) {
            
            this.getInformationFormWithIdAccount();

            this.isCalled = true;
        }
    }
    
    startTime() {
        this.countTime = this.totalTimeInSeconds;
        this.intervalId = setInterval(() => {
          if (this.countTime > 0) {
            // console.log("Tiempo restante: " + this.countTime);
            this.countTime--;

            this.showCountTime = parseInt((this.countTime * 100) / this.totalTimeInSeconds, 10);
          } else {
            // Cuando los segundos llegan a cero, puedes realizar una acción aquí.
            clearInterval(this.intervalId); // Detiene el temporizador.

            this.ErrorApprovedCodeOTPMessagge = 'Código OTP expirado: Código 6';
            insertLogValidation({ taskId: this.recordId, status: 'Fallido', messagge: this.ErrorApprovedCodeOTPMessagge, type: "Validación OTP", idenType: this.accountInfo.CS_TipoIdentificacionCP__pc, idenNum: this.accountInfo.CS_NumeroIdentificacionCP__pc})
            .then(response => {
                if(response != undefined && response.successful){
                    // console.log("Historial guardado correctamente");
                }
                
            })
            .catch(error => {
                this.showToast("¡Error inesperado guardando historial, consulte a su administrador!", error, "error");
                //alert('error: ' + JSON.stringify(error));

                this.isLoading = false;
                this.disableNextButton = false;
            });

            this.changeScreen("None");
            this.ErrorApprovedCodeOTP = true;
            this.disableNextButton = false;
            this.isLoading = false;
          }
        }, 1000); // 1000 milisegundos = 1 segundo
    }

    noInformaCodigo() {
        this.isLoading = true;
        this.disableNextButton = true;

        clearInterval(this.intervalId); // Detiene el temporizador.
        
        this.ErrorApprovedCodeOTPMessagge = 'No informa código: código 4';

        insertLogValidation({ taskId: this.recordId, status: 'Fallido', messagge: this.ErrorApprovedCodeOTPMessagge, type: "Validación OTP", idenType: this.accountInfo.CS_TipoIdentificacionCP__pc, idenNum: this.accountInfo.CS_NumeroIdentificacionCP__pc})
            .then(response => {
                if(response != undefined && response.successful){
                    // console.log("Historial guardado correctamente");
                }
            })
            .catch(error => {
                this.showToast("¡Error inesperado guardando historial, consulte a su administrador!", error, "error");
                //alert('error: ' + JSON.stringify(error));

                this.isLoading = false;
                this.disableNextButton = false;
            });

        this.changeScreen("None");
        this.ErrorApprovedCodeOTP = true;
        this.disableNextButton = false;
        this.isLoading = false;
    }

    getInformationForm() {
        this.isLoading = true;
        this.disableNextButton = true;
        getAccountInfo({ taskId: this.recordId })
        .then(response => {
            if(response != undefined && response.successful){
                this.accountInfo =JSON.parse(JSON.stringify(response.accountInfo));
                this.isContactToValidate = false;
                this.accountInfo.CS_FechaExpedicion__pc = '';

                let tipoIdent;
                const accountTipoIdent = this.accountInfo.IsPersonAccount ? this.accountInfo.CS_TipoIdentificacionCP__pc : this.accountInfo.CS_TipoIdentificacion__c;
                const index = accountTipoIdent != undefined && accountTipoIdent != null && accountTipoIdent != '' ? parseInt(accountTipoIdent) : undefined;
                if(index != undefined){
                    tipoIdent = tiposDeIdentificacion[index - 1];
                }
                this.accountTipIdenLabel = tipoIdent;
                this.disableNextButton = false;

                this.changeScreen("screenA");

            }else{
                this.warningMessage = response.message;
                this.isError = true;
                this.disableNextButton = true;
            }
            this.isLoading = false;
            
        })
        .catch(error => {
            this.warningMessage = 'Error inesperado, consulte a su administrador: ' + error;
            this.isError = true;
            this.isLoading = false;
            this.disableNextButton = true;
        });
    }

    getInformationFormWithIdAccount() {
        this.isLoading = true;
        this.disableNextButton = true;
        getAccountInfoWithAccountId({ accountId: this.accountId })
        .then(response => {
            if(response != undefined && response.successful){
                this.accountInfo =JSON.parse(JSON.stringify(response.accountInfo));
                this.isContactToValidate = false;
                this.accountInfo.CS_FechaExpedicion__pc = '';

                let tipoIdent;
                const accountTipoIdent = this.accountInfo.IsPersonAccount ? this.accountInfo.CS_TipoIdentificacionCP__pc : this.accountInfo.CS_TipoIdentificacion__c;
                const index = accountTipoIdent != undefined && accountTipoIdent != null && accountTipoIdent != '' ? parseInt(accountTipoIdent) : undefined;
                if(index != undefined){
                    tipoIdent = tiposDeIdentificacion[index - 1];
                }
                this.accountTipIdenLabel = tipoIdent;
                this.disableNextButton = false;

                this.changeScreen("screenA");

            }else{
                this.warningMessage = response.message;
                this.isError = true;
                this.disableNextButton = true;
            }
            this.isLoading = false;
            
        })
        .catch(error => {
            this.warningMessage = 'Error inesperado, consulte a su administrador: ' + error;
            this.isError = true;
            this.isLoading = false;
            this.disableNextButton = true;
        });
    }

    getInformationFormFromContact() {
        this.isLoading = true;
        this.disableNextButton = true;
        getAccountInfoFromContact({ taskId: this.recordId })
        .then(response => {
            if(response != undefined && response.successful){
                
                let accountContact = {
                    Id: null,
                    FirstName: response.contactInfo.FirstName,
                    MiddleName: response.contactInfo.MiddleName,
                    LastName: response.contactInfo.LastName,
                    Suffix: response.contactInfo.Suffix,
                    PersonMobilePhone: response.contactInfo.MobilePhone,
                    CS_TipoIdentificacionCP__pc: response.contactInfo.CS_TipoIdentificacionCP__c,
                    CS_NumeroIdentificacionCP__pc: response.contactInfo.CS_NumeroIdentificacionCP__c,
                    IsPersonAccount: response.contactInfo.IsPersonAccount,
                    CS_TipoIdentificacion__c: response.contactInfo.CS_TipoIdentificacionCP__c,
                    CS_FechaExpedicion__pc: response.contactInfo.CS_NumeroIdentificacionCP__c,
                    PersonEmail: response.contactInfo.Email,
                }


                this.accountInfo = accountContact;
                this.isContactToValidate = true;
                this.accountInfo.CS_FechaExpedicion__pc = '';

                let tipoIdent;
                const accountTipoIdent = this.accountInfo.IsPersonAccount ? this.accountInfo.CS_TipoIdentificacionCP__pc : this.accountInfo.CS_TipoIdentificacion__c;
                const index = accountTipoIdent != undefined && accountTipoIdent != null && accountTipoIdent != '' ? parseInt(accountTipoIdent) : undefined;
                if(index != undefined){
                    tipoIdent = tiposDeIdentificacion[index - 1];
                }
                this.accountTipIdenLabel = tipoIdent;
                this.disableNextButton = false;

                this.changeScreen("screenA");

            }else{
                this.warningMessage = response.message;
                this.isError = true;
                this.disableNextButton = true;
            }
            this.isLoading = false;
            
        })
        .catch(error => {
            // console.log(JSON.stringify(error));
            this.warningMessage = 'Error inesperado, consulte a su administrador: ' + JSON.stringify(error);
            this.isError = true;
            this.isLoading = false;
            this.disableNextButton = true;
        });
    }

    consultClient() {
        //console.log(JSON.stringify(this.accountInfo ));
        const componentsList = this.template.querySelectorAll('lightning-input'); 

        let isValid = true;
        componentsList.forEach((input) => {
            input.showHelpMessageIfInvalid();
            isValid = isValid && input.checkValidity();
        });

        if(isValid){
            this.isLoading = true;
            this.disableNextButton = true;
            callRegistraduriaAndUpdateAccount({ taskId: this.recordId, acc: this.accountInfo, isContactToValidate: this.isContactToValidate })
            .then(response => {
                if(response != undefined && response.successful){
                    // console.log(response);
                    // console.log(JSON.parse(response.returnResponse));
                    let data = JSON.parse(response.returnResponse);
                    let messageToLog;
                    // console.log(data[0].statement.naturalNational.idDetails.state);
                    let statusLog = "Exitoso";
                    if(data[0].statement.naturalNational.idDetails.state == "21"){
                        statusLog = 'Fallido';
                        messageToLog = "La validación del documento " +  this.accountInfo.CS_NumeroIdentificacionCP__pc + " con estado 21: Cancelada por muerte o fallecido";
                        this.warningMessage = messageToLog;
                        this.isError = true;
                        this.disableNextButton = true;

                    }else if (data[0].statement.naturalNational.idDetails.state == undefined || data[0].statement.naturalNational.idDetails.state == ''){
                        messageToLog = "La validación del servicio de registraduría arroja un error inesperado: state undefined";
                        statusLog = 'Fallido';
                        this.warningMessage = messageToLog;
                        this.isError = true;
                        this.disableNextButton = true;

                    }else if (data[0].statement.naturalNational.idDetails.state != "21"){
                        messageToLog = "Respuesta con código " + data[0].statement.naturalNational.idDetails.state;
                        this.changeScreen("screenB");
                        this.disableNextButton = false;
                    }else{

                    }

                    insertLogValidation({ taskId: this.recordId, status: statusLog , messagge: messageToLog, type: "Registraduría", idenType: this.accountInfo.CS_TipoIdentificacionCP__pc, idenNum: this.accountInfo.CS_NumeroIdentificacionCP__pc})
                    .then(response => {
                        if(response != undefined && response.successful){
                            // console.log("Historial guardado correctamente");
                        }
                        
                    })
                    .catch(error => {
                        this.showToast("¡Error inesperado guardando historial, consulte a su administrador!", error, "error");
                        //alert('error: ' + JSON.stringify(error));

                        this.isLoading = false;
                        this.disableNextButton = false;
                    });

                }else{
                    this.showToast("¡Cuidado!", response.message, "warning");
                    this.disableNextButton = false;
                }
                this.isLoading = false;
                
            })
            .catch(error => {
                this.showToast("¡Error inesperado, consulte a su administrador!", error, "error");
                //alert('error: ' + JSON.stringify(error));

                this.isLoading = false;
                this.disableNextButton = false;
            });
        }
    }

    sendingOTPCode(){
        this.isLoading = true;
        this.disableNextButton = true;
        sendOPTCode({ taskId: this.recordId, acc: this.accountInfo })
        .then(response => {
            if(response != undefined && response.successful){
                
                // console.log(response.returnResponse);
                let data = JSON.parse(response.returnResponse);
                // console.log(data.GenerationResult.OTP.Result);
                // console.log(data.GenerationResult.OTP.Result);
                
                if(data.GenerationResult.OTP.Result == "true"){
                    this.changeScreen("screenC");

                    this.validationRegistry = response.validationRegistry;
                    this.transactionId      = data.GenerationResult.OTP.TransactionId;
                }else{
                    let messageToLog = 'El servicio no permitió el envío del código OTP';
                    insertLogValidation({ taskId: this.recordId, status: "Fallido", messagge: messageToLog, type: "Generación OTP", idenType: this.accountInfo.CS_TipoIdentificacionCP__pc, idenNum: this.accountInfo.CS_NumeroIdentificacionCP__pc})
                    .then(response => {
                        if(response != undefined && response.successful){
                            // console.log("Historial guardado correctamente");
                        }
                        
                    })
                    .catch(error => {
                        this.showToast("¡Error inesperado guardando historial, consulte a su administrador!", error, "error");
                        //alert('error: ' + JSON.stringify(error));

                        this.isLoading = false;
                        this.disableNextButton = false;
                    });

                    this.warningMessage = messageToLog;
                    this.isError = true;
                    this.ErrorApprovedCodeOTP = true
                    this.screenB = false;
                }
                
                this.startTime();
                this.disableNextButton = false;

            }else{
                this.warningMessage = response.message;
                this.isError = true;
                this.disableNextButton = true;
                this.screenB = false;
            }
            this.isLoading = false;
            
        })
        .catch(error => {
            this.warningMessage = 'Error inesperado, consulte a su administrador: ' + error;
            this.isError = true;
            this.isLoading = false;
            this.disableNextButton = true;
            this.screenB = false;
        });

    }

    validateOTPCode(){
        const componentsList = this.template.querySelectorAll('lightning-input'); 

        let isValid = true;
        componentsList.forEach((input) => {
            input.showHelpMessageIfInvalid();
            isValid = isValid && input.checkValidity();
        });

        if(isValid){
            this.isLoading = true;
            this.disableNextButton = true;

            clearInterval(this.intervalId); // Detiene el temporizador.


            validateSendedOPTCode({ taskId: this.recordId, acc: this.accountInfo, otpCode: this.OTPCode, vRegistry: this.validationRegistry, tranId: this.transactionId })
            .then(response => {
                if(response != undefined && response.successful){
                    
                    // console.log(response.returnResponse);
                    let data = JSON.parse(response.returnResponse);
                    this.changeScreen("None");
                    
                    let messageToLog;
                    let statusToLog;
                    if(data.ValidateOTPCodeResponse.ValidCode == "true"){
                        statusToLog = "Exitoso";
                        messageToLog = "Código OTP validado correctamente";
                        if(!this.isContactToValidate){
                            this.saveAccount();
                        }else{
                            this.approvedCodeOTP = true;
                            this.disableNextButton = false;
                            this.isLoading = false;
                        }
                    }else{
                        statusToLog = "Fallido";
                        this.ErrorApprovedCodeOTPMessagge = "Validación del OTP no fue correcta";
                        messageToLog = "No fue posible validar el código OTP correctamente: " + data.ValidateOTPCodeResponse.ValidationResult;
                        this.ErrorApprovedCodeOTP = true;
                        this.disableNextButton = false;
                        this.isLoading = false;
                    }

                    insertLogValidation({ taskId: this.recordId, status: statusToLog, messagge: messageToLog, type: "Validación OTP", idenType: this.accountInfo.CS_TipoIdentificacionCP__pc, idenNum: this.accountInfo.CS_NumeroIdentificacionCP__pc})
                    .then(response => {
                        if(response != undefined && response.successful){
                            // console.log("Historial guardado correctamente");
                        }
                        
                    })
                    .catch(error => {
                        this.showToast("¡Error inesperado guardando historial, consulte a su administrador!", error, "error");
                        //alert('error: ' + JSON.stringify(error));

                        this.isLoading = false;
                        this.disableNextButton = false;
                    });

                }else{
                    this.warningMessage = response.message;
                    this.isError = true;
                    this.disableNextButton = true;
                    this.screenB = false;
                    this.isLoading = false;
                }
                
            })
            .catch(error => {
                this.warningMessage = 'Error inesperado, consulte a su administrador: ' + error;
                this.isError = true;
                this.isLoading = false;
                this.disableNextButton = true;
                this.screenB = false;
            });

        }

    }

    saveAccount(){
        this.isLoading = true;
        this.disableNextButton = true;

        saveValidatedDateInAccount({ acc: this.accountInfo})
        .then(response => {
            if(response != undefined && response.successful){

                this.approvedCodeOTP = true;
                this.disableNextButton = false;

            }else{
                this.warningMessage = response.message;
                this.isError = true;
                this.disableNextButton = true;
                this.screenB = false;
            }

            this.isLoading = false;
            
        })
        .catch(error => {
            this.warningMessage = 'Error inesperado, consulte a su administrador: ' + error;
            this.isError = true;
            this.isLoading = false;
            this.disableNextButton = true;
            this.screenB = false;
        });
    }

    changeScreen(screenName) {
        this.screenA = false;
        this.screenB = false;
        this.screenC = false;
        this.screenToSelectPerson = false;
        this.screenToSelectpolicyOrBen = false;

        switch (screenName) {
            case 'screenA':
                this.screenA = true;
                break;
            case 'screenB':
                this.screenB = true;
                break;
            case 'screenC':
                this.screenC = true;
                break;
            case 'screenToSelectPerson':
                this.screenToSelectPerson = true;
                break;
            case 'screenToSelectpolicyOrBen':
                this.screenToSelectpolicyOrBen = true;
                break;
            default:
                break;

        }
    }

    handleInputChange(event) {
        this.textValue = event.detail.value;

        switch (event.target.name) {
            case 'PrimerNombre':
                this.accountInfo.FirstName = event.detail.value;
                break;
            case 'SegundoNombre':
                this.accountInfo.MiddleName = event.detail.value;
                break;
            case 'PrimerApellido':
                this.accountInfo.LastName = event.detail.value;
                break;
            case 'SegundoApellido':
                this.accountInfo.Suffix = event.detail.value;
                break;
            case 'FechaExpedicion':
                this.accountInfo.CS_FechaExpedicion__pc = event.detail.value;
                break;
            case 'Celular':
                this.accountInfo.PersonMobilePhone = event.detail.value;
                break;
            default:
                break;
        }
    }

    handleOPTCode(event) {
        this.OTPCode = event.detail.value;
    }

    handleCanalChange(event) {
        this.canalToSend = event.detail.value;
        
        this.disableNextButton = this.canalToSend === 'Email';
    }

    get IsSMS() {
        return this.canalToSend === 'SMS';
    }

    get IsEmail() {
        return this.canalToSend === 'Email';
    }

    initQuestionM(event) {
        this.dispatchEvent(new CustomEvent('initQuestion', {
            detail: {
                message : 'Hey! Welcome to SalesforceBlue :)'
            }
        }));
    }

    eventAfterCorrectValidation(event) {
        this.dispatchEvent(new CustomEvent('eventAfterCorrectValidation', {
            detail: {
                message : 'Hey! Welcome to SalesforceBlue :)'
            }
        }));
    }

    get options() {
        return [
            { label: 'SMS', value: 'SMS' },
            { label: 'Correo Electrónico', value: 'Email' },
        ];
    }

    handleGoTitular(event) {
        this.getInformationForm();
    }

    handleGoSelectPerson(event) {
        this.changeScreen("screenToSelectPerson");
    }

    getInformationFormBeneficiario() {
        this.isLoading = true;
        this.disableNextButton = true;
        getAccountInfoBeneficiario({ taskId: this.recordId })
        .then(response => {
            if(response != undefined && response.successful){
                // console.log('@@@@ 1');
                // console.log(response.participantList);
                if(response.participantList != undefined && response.participantList != null && response.participantList.length > 0){
                    // console.log('@@@@ 2');
                    //Si hay póliza seleccionada y se debe seleccionar el beneficiario al que se debe hacer la validación de identidad
                    // console.log(this.beneficiariosList);

                    // console.log('@@@@ 3');
                    this.beneficiariosList = [];
                    for (let i = 0; i < response.participantList.length; i++) {
                        // console.log(JSON.stringify(response.participantList[i]));
                        // console.log(response.participantList[i]);
                        // console.log(response.accountInfo);

                        let tipoIdent;
                        const accountTipoIdent = response.participantList[i].participantAccount.IsPersonAccount ? response.participantList[i].participantAccount.CS_TipoIdentificacionCP__pc : response.participantList[i].participantAccount.CS_TipoIdentificacion__c;
                        const index = accountTipoIdent != undefined && accountTipoIdent != null && accountTipoIdent != '' ? parseInt(accountTipoIdent) : undefined;
                        if(index != undefined){
                            tipoIdent = tiposDeIdentificacion[index - 1];
                        }
                        const aux = {
                            ben: response.participantList[i].participant,
                            isAccount: response.participantList[i].participantAccount != undefined && response.participantList[i].participantAccount != null,
                            account: response.participantList[i].participantAccount,
                            className: "custom-all-rows",
                            tipoIdent: tipoIdent, 
                            selected: false
                        }
                        this.beneficiariosList.push(aux);

                    }
                    // console.log('@@@@ 4');

                    this.areTherePolicyToSelect = false;

                    if(this.beneficiariosList.length == 1){
                        this.beneficiariosList[0].claseName = "custom-selected custom-all-rows";
                        this.beneficiariosList[0].selected = true;
                        this.selectedBene = this.beneficiariosList[0].account;

                        this.selectBene();
                    }else{

                        this.changeScreen("screenToSelectpolicyOrBen");
                    }
                }else{
                    // console.log('@@@@ 5');
                    this.policyList = [];
                    for (let i = 0; i < response.policyList.length; i++) {
                        const prod = response.policyList[i].Product != undefined && response.policyList[i].Product != null ? response.policyList[i].Product : {Name: ''};
                        const aux = {
                            pol: response.policyList[i],
                            className: "custom-all-rows",
                            product: prod,
                            selected: false
                        }
                        this.policyList.push(aux);

                    }
                    // console.log('@@@@ 6');
                    this.areTherePolicyToSelect = true;
                    // console.log(this.policyList);

                    this.changeScreen("screenToSelectpolicyOrBen");
                }
            }else{
                this.warningMessage = response.message;
                this.isError = true;
                this.disableNextButton = true;
            }

            this.disableNextButton = false;
            this.isLoading = false;
            
        })
        .catch(error => {
            this.warningMessage = 'Error inesperado, consulte a su administrador: ' + error;
            this.isError = true;
            this.isLoading = false;
            this.disableNextButton = fals;
        });
    }

    handleRowClick(event) {
        const index = event.currentTarget.dataset.index;

        if(this.areTherePolicyToSelect){
            for (let i = 0; i < this.policyList.length; i++) {
                if(i.toString() === index.toString()){
                    this.policyList[i].claseName = "custom-selected custom-all-rows";
                    this.policyList[i].selected = true;
                    this.selectedPolicy = this.policyList[i].pol.Id;
                }else{
                    this.policyList[i].claseName = "custom-all-rows";
                    this.policyList[i].selected = false;
                }
            }
        }else{
            for (let i = 0; i < this.beneficiariosList.length; i++) {
                if(i.toString() === index.toString()){
                    this.beneficiariosList[i].claseName = "custom-selected custom-all-rows";
                    this.beneficiariosList[i].selected = true;
                    this.selectedBene = this.beneficiariosList[i].account;
                }else{
                    this.beneficiariosList[i].claseName = "custom-all-rows";
                    this.beneficiariosList[i].selected = false;
                }
            }

        }

        
    }

    savingPoliza(){
        if(this.selectedPolicy != undefined && this.selectedPolicy != null && this.selectedPolicy != ''){
            this.isLoading = true;
            this.disableNextButton = true;

            // console.log(this.recordId);
            // console.log(this.selectedPolicy);

            savePolicy({ taskId: this.recordId, policyId: this.selectedPolicy})
            .then(response => {
                if(response != undefined && response.successful){

                    this.getInformationFormBeneficiario();
    
                }else{
                    this.warningMessage = response.message;
                    this.isError = true;
                    this.disableNextButton = true;

                    this.isLoading = false;
                }
                
            })
            .catch(error => {
                this.warningMessage = 'Error inesperado, consulte a su administrador: ' + error;
                this.isError = true;
                this.isLoading = false;
                this.disableNextButton = true;
            });
        }else{
            this.showToast("¡Cuidado!", "Es necesario seleccionar una póliza antes de continuar", "warning");

        }
    }

    selectBene() {
        this.isLoading = true;
        this.disableNextButton = true;
        // console.log(this.selectedBene);
        if(this.selectedBene != undefined && this.selectedBene != null){

            this.accountInfo = JSON.parse(JSON.stringify(this.selectedBene));
            this.accountInfo.CS_FechaExpedicion__pc = '';
            // console.log(this.selectedBene.CS_TipoIdentificacion__c);

            let tipoIdent;
            const accountTipoIdent = this.accountInfo.IsPersonAccount ? this.accountInfo.CS_TipoIdentificacionCP__pc : this.accountInfo.CS_TipoIdentificacion__c;
            const index = accountTipoIdent != undefined && accountTipoIdent != null && accountTipoIdent != '' ? parseInt(accountTipoIdent) : undefined;
            if(index != undefined){
                tipoIdent = tiposDeIdentificacion[index - 1];
            }
            this.accountTipIdenLabel = tipoIdent;

            this.changeScreen("screenA");

        }
        // console.log('5');
        this.isLoading = false;
        this.disableNextButton = false;
    }

    showToast(title_, message_, variant_) {
        const event = new ShowToastEvent({
            title: title_,
            message: message_,
            variant: variant_,
        });
        this.dispatchEvent(event);

    }
}