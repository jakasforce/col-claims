public with sharing class VS_FinancialDataController {

    @AuraEnabled(cacheable=true)
    public static DtoResponse getAccountId(String recordId) {
        DtoResponse response = new DtoResponse();
        if(isIdTask(recordId)){
            list<Task> taskInfo = [
                SELECT Id, WhatId
                FROM Task
                WHERE Id =: recordId
            ];
            response.accountId = taskInfo[0].WhatId;
        }else if(isIdCase(recordId)){
            list<Case> caseInfo = [
                SELECT Id, AccountId
                FROM Case
                WHERE Id = :recordId
            ];
            response.accountId = caseInfo[0].AccountId;
        }else if(isIdAccount(recordId)){
            response.accountId = recordId;
        }else{
            response.successful = false;
            response.message = 'No se pudo obtener el Id de la cuenta';
        }

        return response;
    }

    @AuraEnabled(cacheable=true)
    public static DtoResponse getInfo(String recordId) {
        DtoResponse response = new DtoResponse();
        if(isIdTask(recordId)){
            response = getInfoFromTask(recordId);
        }else if(isIdCase(recordId)){
            response = getInfoFromCase(recordId);
        }else if(isIdAccount(recordId)){
            response = getInfoFromAccount(recordId);
        }else{
            response.successful = false;
            response.message = 'Tipo de objeto no definido';
        }
        
        return response;
    }

    public static Boolean isIdTask(String recordId) {
        // '00T' es el prefijo para objetos Task en Salesforce
        return recordId.startsWith('00T');
    }

    public static Boolean isIdCase(String recordId) {
        // '500' es el prefijo para objetos Case en Salesforce
        return recordId.startsWith('500');
    }

    public static Boolean isIdAccount(String recordId) {
        // '001' es el prefijo para objetos Account en Salesforce
        return recordId.startsWith('001');
    }

    @AuraEnabled(cacheable=true)
    public static DtoResponse getInfoFromCase(String caseId) {
        DtoResponse response = new DtoResponse();

        list<Case> caseList = [SELECT Id, AccountId, Account.CS_TipoIdentificacionCP__pc, Account.CS_NumeroIdentificacionCP__pc
                               FROM Case
                               WHERE Id = :caseId];

        if(caseList.size() > 0){
            if(caseList[0].AccountId == null){
                response.successful = false;
                response.message = 'Este caso no se encuentra asociado a ninguna cuenta';
                return response;
            }
            try {
                VS_WSAuthenticationGetToken token = VS_WSAuthenticationGetToken.callout();
                System.debug(token);
                
                if(token == null || !token.successful){
                    response.successful = false;
                    response.message = 'Ocurrió un problema al obtener el token: consulte a su administrador';
                    return response;
                }

                VS_WSInfoFinancialWorker financialWorker = VS_WSInfoFinancialWorker.callout(token.access_token, getHomoFromIdType(caseList[0].Account.CS_TipoIdentificacionCP__pc), caseList[0].Account.CS_NumeroIdentificacionCP__pc);
                System.debug('@@@ ' + financialWorker);
                
                if(financialWorker != Null && financialWorker.successful){

                    response.successful = true;
                    response.wsFinancialWorker = financialWorker;

                    response.bankList = getBankList();
                    response.typeFinancialAccountList = getFinancialAccountTypeList();

                    response.accountId = caseList[0].AccountId;
                }else{
                    response.successful = false;
                    if (financialWorker != Null && financialWorker.serviceResponse != Null ) {
                        response.message = 'El servicio de consulta de datos financieros falló. Status Code: ' + financialWorker.serviceResponse.getStatusCode();
                    } else{
                         response.message = 'Ocurrió un problema al consultar los datos financieros, consulte a su administrador';
                    }
                }
                
            } catch (Exception e) {
                System.debug('Error deserialize response: ' + e.getMessage());
    
                response.successful = false;
                response.message = 'Ocurrió un problema al consultar los datos financieros, consulte a su administrador: ' + e.getMessage();
            }

        }else{
            response.successful = false;
            response.message = 'Ocurrió un error: este caso no se encontró en la basa de datos';
        }

        return response;
    }

    @AuraEnabled(cacheable=true)
    public static DtoResponse getInfoFromTask(String taskId) {
        DtoResponse response = new DtoResponse();

        list<Task> taskInfo = [SELECT Id, WhatId
                               FROM Task
                               WHERE Id =: taskId
        ];

        if(taskInfo.size() > 0){
            if(taskInfo[0].WhatId == null){
                response.successful = false;
                response.message = 'Este caso no se encuentra asociado a ninguna cuenta';
                return response;
            }

            List<Account> acc =  [
                SELECT Id, CS_TipoIdentificacionCP__pc, CS_NumeroIdentificacionCP__pc
                FROM Account
                WHERE Id =: taskInfo[0].WhatId
            ];

            try {
                VS_WSAuthenticationGetToken token = VS_WSAuthenticationGetToken.callout();
                System.debug(token);
                
                if(token == Null || !token.successful){
                    response.successful = false;
                    response.message = 'Ocurrió un problema al obtener el token: consulte a su administrador';
                    return response;
                }

                VS_WSInfoFinancialWorker financialWorker = VS_WSInfoFinancialWorker.callout(token.access_token, getHomoFromIdType(acc[0].CS_TipoIdentificacionCP__pc), acc[0].CS_NumeroIdentificacionCP__pc);
                System.debug('@@@ ' + financialWorker);
                
                if(financialWorker != Null && financialWorker.successful){
                    response.successful = true;
                    response.wsFinancialWorker = financialWorker;

                    response.bankList = getBankList();
                    response.typeFinancialAccountList = getFinancialAccountTypeList();

                    response.accountId = taskInfo[0].WhatId;
                }else{
                    response.successful = false;
                    if (financialWorker != Null && financialWorker.serviceResponse != Null ) {
                        response.message = 'El servicio de consulta de datos financieros falló. Status Code: ' + financialWorker.serviceResponse.getStatusCode();
                    } else{
                         response.message = 'Ocurrió un problema al consultar los datos financieros, consulte a su administrador';
                    }
                }
    
                
            } catch (Exception e) {
                System.debug('Error deserialize response: ' + e.getMessage());
    
                response.successful = false;
                response.message = 'Ocurrió un problema al consultar los datos financieros, consulte a su administrador: ' + e.getMessage();
            }

        }else{
            response.successful = false;
            response.message = 'Ocurrió un error: esta tarea no se encontró en la basa de datos';
        }

        return response;
    }

    @AuraEnabled(cacheable=true)
    public static DtoResponse getInfoFromAccount(String accountId) {
        DtoResponse response = new DtoResponse();

        List<Account> acc =  [
                SELECT Id, CS_TipoIdentificacionCP__pc, CS_NumeroIdentificacionCP__pc
                FROM Account
                WHERE Id =: accountId
            ];

        if(acc.size() > 0){

            try {

                VS_WSAuthenticationGetToken token = VS_WSAuthenticationGetToken.callout();
                System.debug(token);
                
                if(token == Null || !token.successful){
                    response.successful = false;
                    response.message = 'Ocurrió un problema al obtener el token: consulte a su administrador';
                    return response;
                }

                VS_WSInfoFinancialWorker financialWorker = VS_WSInfoFinancialWorker.callout(token.access_token, getHomoFromIdType(acc[0].CS_TipoIdentificacionCP__pc), acc[0].CS_NumeroIdentificacionCP__pc);
                System.debug('@@@ Account ' + financialWorker);
                
                if(financialWorker != null && financialWorker.successful){
                    /*if(financialWorker.message != null){
                        response.successful = false;
                        response.message = 'Error de validación en consulta de Datos Financieros: ' + financialWorker.message;
                        return response;
                    }*/
                    response.isNewAccount = financialWorker.bankAccount != '' && financialWorker.bankAccount != null ? '2' : '1'; // 1: new, 2: existing
                    System.debug('@@@ isNewAccount: ' + response.isNewAccount);
                    response.successful = true;
                    response.wsFinancialWorker = financialWorker;

                    response.bankList = getBankList();
                    response.typeFinancialAccountList = getFinancialAccountTypeList();

                    response.accountId = accountId;
                }else{
                    response.successful = false;
                    if(financialWorker != null && financialWorker.serviceResponse != null){
                        response.message = 'El servicio de consulta de datos financieros falló. Status Code: ' + financialWorker.serviceResponse.getStatusCode();
                    }else{
                         response.message = 'Ocurrió un problema al consultar los datos financieros, consulte a su administrador';
                    }
                    
                }
    
                
            } catch (Exception e) {
                System.debug('Error deserialize response: ' + e.getMessage());
    
                response.successful = false;
                response.message = 'Ocurrió un problema al consultar los datos financieros, consulte a su administrador: ' + e.getMessage();
            }

        }else{
            response.successful = false;
            response.message = 'Ocurrió un error: esta cuenta no se encontró en la basa de datos';
        }

        return response;
    }

    @AuraEnabled
    public static DtoResponse saveFinancialAccount(String accountNumber, String bank, String accountType, String accountId, String isNewAccount, Id userId) {
        DtoResponse response = new DtoResponse();

        List<Account> acc =  [
                SELECT Id, CS_TipoIdentificacionCP__pc, CS_NumeroIdentificacionCP__pc
                FROM Account
                WHERE Id =: accountId
            ];

        List<User> user =  [
            SELECT Id, Username
            FROM User
            WHERE Id =: userId
        ];

        try {
            VS_WSAuthenticationGetToken token = VS_WSAuthenticationGetToken.callout();
            System.debug(token);
            
            if(token == Null || !token.successful){
                response.successful = false;
                response.message = 'Ocurrió un problema al obtener el token: consulte a su administrador';
                return response;
            }

            List<PicklistData> typeList = getFinancialAccountTypeList();
            String paymentMethodCode = '';
            for(PicklistData tip : typeList){
                if(tip.value == accountType){
                    System.debug('@ TIP: '+ tip.paymentCode);
                    paymentMethodCode = tip.paymentCode;
                    break;
                }
            }
            System.debug('>> ' + isNewAccount);
            String typeNew = isNewAccount;
			//984691742
			
            String minUserName = user[0].Username.substring(0, 8);
            
			System.debug('Username: ' + minUserName);
            System.debug('@@@ ISNEWACCOUNT: ' + typeNew);
            
            VS_WSInfoFinancialWorkerPUT financialWorker = VS_WSInfoFinancialWorkerPUT.callout(token.access_token, 
            getHomoFromIdType(acc[0].CS_TipoIdentificacionCP__pc), acc[0].CS_NumeroIdentificacionCP__pc, paymentMethodCode, bank, accountNumber, accountType, 
            typeNew, '', minUserName);
            System.debug(financialWorker);
            
            if(financialWorker != null && financialWorker.successful){
                if(financialWorker.error == '1'){
                    response.successful = false;
                    response.message = 'Error de actualización de Datos Financieros (Servicio Web): ' + financialWorker.message;
                    return response;
                }
                response.successful = true;
                response.wsFinancialWorkerPut = financialWorker;

            }else{
                response.successful = false;
                if(financialWorker != null && financialWorker.serviceResponse != null){
                    response.message = 'El servicio de actualizar de datos financieros falló. Status Code (' + financialWorker.serviceResponse.getStatusCode() + ')';
                    if(financialWorker.message != null){
                       response.message +=  ': ' + financialWorker.message;
                    }
                }else{
                    response.message = 'Ocurrió un problema al consultar los datos financieros, consulte a su administrador';
                }
                return response;
            }

            
        } catch (Exception e) {
            System.debug('Error deserialize response: ' + e.getMessage());

            response.successful = false;
            response.message = 'Ocurrió un problema al actualizar los datos financieros (Servicio Web), consulte a su administrador: ' + e.getMessage();
        }

        List<FinServ__FinancialAccount__c> financialAccount = [SELECT Id, FinServ__FinancialAccountNumber__c, BankName__c, 
                                                               FinServ__FinancialAccountType__c
                                                               FROM FinServ__FinancialAccount__c
                                                               WHERE FinServ__FinancialAccountNumber__c = : accountNumber];

        FinServ__FinancialAccount__c finAccount = new FinServ__FinancialAccount__c();
        Boolean isNew = false;
        try {
            String accountHomologationType = getHomologationAccountTypeValue(accountType);
            if(financialAccount.size() > 0){
                finAccount.Id = financialAccount[0].Id;
                finAccount.BankName__c = bank;
                finAccount.FinServ__FinancialAccountType__c = accountHomologationType;

                update finAccount;

            }else{
                finAccount.BankName__c = bank;
                finAccount.FinServ__FinancialAccountType__c = accountHomologationType;
                finAccount.FinServ__FinancialAccountNumber__c = accountNumber;
                finAccount.FinServ__PrimaryOwner__c = accountId;

                insert finAccount;
                isNew = true;
            }
        } catch (DMLException e) {
            //System.debug('Error deserialize response: ' + e.getMessage());

            response.successful = false;
            response.message = 'Ocurrió un error, la cuenta finaciera no pudo ser guardada: ' + e.getDmlMessage(0);
            return response;
        }

        List<FinServ__FinancialAccountRole__c> roleList = [SELECT Id, FinServ__FinancialAccount__c, FinServ__RelatedAccount__c, FinServ__Role__c
                                                           FROM FinServ__FinancialAccountRole__c
                                                           WHERE FinServ__RelatedAccount__c = : accountId and FinServ__FinancialAccount__c = :finAccount.Id];
        if(roleList.size() > 0){
            response.successful = true;
        }else{
            try {
                FinServ__FinancialAccountRole__c financialRole = new FinServ__FinancialAccountRole__c();
                financialRole.FinServ__FinancialAccount__c = finAccount.Id;
                financialRole.FinServ__RelatedAccount__c = accountId;
                financialRole.FinServ__Role__c = 'Primary Owner';

                insert financialRole;

                response.successful = true;
            } catch (DMLException e) {
                //System.debug('Error deserialize response: ' + e.getMessage());

                response.successful = false;
                response.message = 'Ocurrió un error, el rol de la cuenta finaciera no pudo ser creado: ' + e.getDmlMessage(0);
                return response;
            }
        }

        return response;
    }

    public static List<PicklistData> getBankList(){
        List<PicklistData>  pickListValuesList = new List<PicklistData>();
        Schema.DescribeFieldResult fieldResult = FinServ__FinancialAccount__c.BankName__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            PicklistData aux = new PicklistData();
            aux.label = pickListVal.getLabel();
            aux.value = pickListVal.getValue();

            pickListValuesList.add(aux);
        }     
        return pickListValuesList;
    }

    public static String getHomoFromIdType(String idType){
        Map<String, String> listIdType = new Map<String, String>();
        listIdType.put('1', 'CC');

        if(listIdType.containsKey(idType)){
            return listIdType.get(idType);
        }
        return idType;
    }

    public static List<PicklistData> getFinancialAccountTypeList(){
        List<PicklistData>  pickListValuesList = new List<PicklistData>();

        PicklistData aux = new PicklistData();
        aux.label = 'Valor no definido';//Screen
        aux.value = '0';//Web Service
        aux.homologation = 'Undefined';//API Salesforce
        aux.paymentCode = '00';

        PicklistData aux2 = new PicklistData();
        aux2.label = 'Cuenta corriente';
        aux2.value = '1';
        aux2.homologation = 'Checking';
        aux2.paymentCode = 'TE';

        PicklistData aux3 = new PicklistData();
        aux3.label = 'Cuenta de ahorros';
        aux3.value = '2';
        aux3.homologation = 'Savings';
        aux3.paymentCode = 'TE';

        PicklistData aux4 = new PicklistData();
        aux4.label = 'Daviplata';
        aux4.value = '3';
        aux4.homologation = 'Daviplata';
        aux4.paymentCode = 'D';
        
        PicklistData aux5 = new PicklistData();
        aux5.label = 'Cheque';
        aux5.value = '4'; // to define
        aux5.homologation = 'Check';
        aux5.paymentCode = 'CH';
        
        PicklistData aux6 = new PicklistData();
        aux6.label = 'Tpaga';
        aux6.value = '5';// to define
        aux6.homologation = 'Tpaga';
        aux6.paymentCode = 'G';

        pickListValuesList.add(aux);
        pickListValuesList.add(aux2);
        pickListValuesList.add(aux3);
        pickListValuesList.add(aux4);
        pickListValuesList.add(aux5);
        pickListValuesList.add(aux6);

        return pickListValuesList;
    }

    public static String getHomologationAccountTypeValue(String value){
        List<PicklistData> typeList = getFinancialAccountTypeList();

        for(PicklistData tip : typeList){
            if(tip.value == value){
                return tip.homologation;
            }
        }
        return null;
    }



    public class DtoResponse {
        @AuraEnabled
        public Boolean successful { get; set; }
        @AuraEnabled
        public String message { get; set; }

        @AuraEnabled
        public VS_WSInfoFinancialWorker wsFinancialWorker { get; set; } 

        @AuraEnabled
        public VS_WSInfoFinancialWorkerPUT wsFinancialWorkerPut { get; set; } 

        @AuraEnabled
        public List<PicklistData> bankList { get; set; }
        @AuraEnabled
        public List<PicklistData> typeFinancialAccountList { get; set; }

        @AuraEnabled
        public String accountId { get; set; }

        @AuraEnabled
        public String isNewAccount { get; set; }
    }

    public class PicklistData {
        @AuraEnabled
        public String label { get; set; }

        @AuraEnabled
        public String value { get; set; }

        @AuraEnabled
        public String homologation { get; set; }

        @AuraEnabled
        public String paymentCode { get; set; }
    }
}