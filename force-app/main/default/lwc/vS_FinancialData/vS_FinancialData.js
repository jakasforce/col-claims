import { LightningElement, api, track } from 'lwc';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import { CloseActionScreenEvent } from 'lightning/actions';

import USER_ID from '@salesforce/user/Id';

import getInfo from '@salesforce/apex/VS_FinancialDataController.getInfo';
import saveFinancialAccount from '@salesforce/apex/VS_FinancialDataController.saveFinancialAccount';

export default class VS_FinancialData extends LightningElement {
    @api recordId;
    @api userId = USER_ID;

    @track isCalled = false;

    @track isLoading = true;

    @track isError = false;
    @track warningMessage;

    @track disableNextButton = true;

    @track screenA = true;

    @track WSInfoFinancialWorker;
    @track bankList;
    @track typeFinancialAccountList;
    @track isNewAccount;

    @track accountId;

    @track showInput = true;
    @track isReadOnly = false;

    renderedCallback() {
        // Lógica que deseas ejecutar al iniciar el componente
        if (this.recordId && !this.isCalled) {
            this.getInformationForm();

            this.isCalled = true;
        }
    }

    getInformationForm() {
        this.isLoading = true;
        this.disableNextButton = true;

        getInfo({ recordId: this.recordId })
            .then((response) => {
                if (response !== undefined && response.successful) {
                    // console.log(JSON.stringify(response.wsFinancialWorker));
                    this.disableNextButton = false;
                    this.WSInfoFinancialWorker = JSON.parse(
                        JSON.stringify(response.wsFinancialWorker)
                    );

                    // console.log('>> 1: ' + response.isNewAccount);
                    this.isNewAccount = response.isNewAccount;

                    this.bankList = response.bankList;
                    this.typeFinancialAccountList =
                        response.typeFinancialAccountList;

                    this.accountId = response.accountId;
                } else {
                    this.warningMessage = response.message;
                    this.isError = true;
                    this.disableNextButton = true;
                }
                this.isLoading = false;
            })
            .catch((error) => {
                this.warningMessage =
                    'Error inesperado, consulte a su administrador: ' + error;
                this.isError = true;
                this.isLoading = false;
                this.disableNextButton = true;
            });
    }

    savingFinancialAccount() {
        this.isLoading = true;
        this.disableNextButton = true;

        if (this.WSInfoFinancialWorker.accountType === '4') {
            // 4 equal check option
            this.WSInfoFinancialWorker.bankAccount = '';
            this.WSInfoFinancialWorker.bankKey = null;
        }
        // console.log('>> isNewAccount: ' + this.WSInfoFinancialWorker.isNewAccount);
        saveFinancialAccount({
            accountNumber: this.WSInfoFinancialWorker.bankAccount,
            bank: this.WSInfoFinancialWorker.bankKey,
            accountType: this.WSInfoFinancialWorker.accountType,
            accountId: this.accountId,
            isNewAccount: this.isNewAccount,
            userId: this.userId
        })
            .then((response) => {
                // console.log('Respuesta: ' + JSON.stringify(response));
                if (response !== undefined && response.successful) {
                    this.dispatchEvent(new CloseActionScreenEvent());

                    this.showToast(
                        '¡Guardado!',
                        'Datos financieros guardados con éxito',
                        'success'
                    );
                    this.disableNextButton = false;
                } else {
                    this.warningMessage = response.message;
                    this.isError = true;
                    this.disableNextButton = true;
                }
                this.isLoading = false;
            })
            .catch((error) => {
                this.warningMessage =
                    'Error inesperado, consulte a su administrador: ' + error;
                this.isError = true;
                this.isLoading = false;
                this.disableNextButton = true;
            });
    }

    handleInputChange(event) {
        //alert(event.target.name);
        //alert(event.detail.value);

        switch (event.target.name) {
            case 'Banco':
                this.WSInfoFinancialWorker.bankKey = event.detail.value;
                break;
            case 'TipoCuenta':
                this.WSInfoFinancialWorker.accountType = event.detail.value;
                this.showInput = event.detail.value === '4' ? false : true;
                if (event.detail.value === '3') {
                    // 	51 DAvivienda
                    this.WSInfoFinancialWorker.bankKey = '51';
                    this.isReadOnly = true;
                    this.showToast(
                        'Cuentas Daviplata',
                        'Para tipos de cuenta Daviplata el banco debe ser BANCO DAVIVIENDA S.A',
                        'warning'
                    );
                } else {
                    this.isReadOnly = false;
                }
                break;
            case 'NumeroCuenta':
                this.WSInfoFinancialWorker.bankAccount = event.detail.value;
                break;
            default:
                break;
        }
    }

    showToast(title_, message_, variant_) {
        const event = new ShowToastEvent({
            title: title_,
            message: message_,
            variant: variant_
        });
        this.dispatchEvent(event);
    }
}