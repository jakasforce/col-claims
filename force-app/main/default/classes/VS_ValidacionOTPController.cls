public with sharing class VS_ValidacionOTPController {
    static String TYPE_TOKEN = 'Token';
    static String TYPE_REGISTRADURIA = 'Registraduría';
    static String TYPE_VALCLIENTE = 'Validación Cliente';
    static String TYPE_GENOTP = 'Generación OTP';
    static String TYPE_VALOTP = 'Validación OTP';
    static String TYPE_OTRO = 'Otro';

    static String STATUS_EXITOSO = 'Exitoso';
    static String STATUS_FALLIDO = 'Fallido';
    static String STATUS_SINRESPUESTA = 'Sin Respuesta';
    
    @AuraEnabled
    public static DtoResponse getAccountInfoWithAccountId(String accountId) {
        DtoResponse response = new DtoResponse();

        if(accountId != null){
            List<Account> acc =  [
                SELECT Id, FirstName, MiddleName, LastName, Suffix, PersonMobilePhone, CS_TipoIdentificacionCP__pc, CS_NumeroIdentificacionCP__pc, IsPersonAccount, CS_TipoIdentificacion__c,
                CS_FechaExpedicion__pc, PersonEmail
                FROM Account
                WHERE Id =: accountId
                LIMIT 1
            ];
            List<Account> accToGetLabel =  [
                SELECT Id, tolabel(CS_TipoIdentificacionCP__pc)
                FROM Account
                WHERE Id =: accountId
                LIMIT 1
            ];

            response.successful = true;
            response.accountInfo = acc[0];
            response.accountTipIdenLabel = accToGetLabel[0].CS_TipoIdentificacionCP__pc;
        }else{
            response.successful = false;
            response.message = 'No existe una cuenta asociada a esta tarea';
        }
        return response;
    }

    @AuraEnabled
    public static DtoResponse getAccountInfo(String taskId) {
        DtoResponse response = new DtoResponse();
        System.debug('Task Id: ' + taskId);

        Task taskInfo = [
            SELECT Id, WhatId
            FROM Task
            WHERE Id =: taskId
            LIMIT 1
        ];
        System.debug('Account Id: ' + taskInfo.WhatId);

        String idenType;
        String idenNum;

        if(taskInfo.WhatId != null){
            List<Account> acc =  [
                SELECT Id, FirstName, MiddleName, LastName, Suffix, PersonMobilePhone, CS_TipoIdentificacionCP__pc, CS_NumeroIdentificacionCP__pc, IsPersonAccount, CS_TipoIdentificacion__c,
                CS_FechaExpedicion__pc, PersonEmail
                FROM Account
                WHERE Id =: taskInfo.WhatId
                LIMIT 1
            ];
            List<Account> accToGetLabel =  [
                SELECT Id, tolabel(CS_TipoIdentificacionCP__pc)
                FROM Account
                WHERE Id =: taskInfo.WhatId
                LIMIT 1
            ];
            idenType = acc[0].CS_TipoIdentificacionCP__pc;
            idenNum = acc[0].CS_NumeroIdentificacionCP__pc;

            response.successful = true;
            response.accountInfo = acc[0];
            response.accountTipIdenLabel = accToGetLabel[0].CS_TipoIdentificacionCP__pc;
        }else{
            response.successful = false;
            response.message = 'No existe una cuenta asociada a esta tarea';
        }
        saveLogValidation(taskId, response, TYPE_OTRO, idenType, idenNum);
        return response;
    }

    @AuraEnabled
    public static DtoResponse getAccountInfoFromContact(String taskId) {
        DtoResponse response = new DtoResponse();
        System.debug('Task Id: ' + taskId);

        Task taskInfo = [
            SELECT Id, WhoId
            FROM Task
            WHERE Id =: taskId
            LIMIT 1
        ];
        System.debug('Contact Id: ' + taskInfo.WhoId);

        String idenType;
        String idenNum;

        if(taskInfo.WhoId != null){
            List<Contact> cont =  [
                SELECT Id, FirstName, MiddleName, LastName, Suffix, MobilePhone, CS_NumeroIdentificacionCP__c, CS_TipoIdentificacionCP__c, IsPersonAccount, CS_FechaExpedicion__c, Email
                FROM Contact
                WHERE Id =: taskInfo.WhoId
                LIMIT 1
            ];

            List<Contact> contToGetLabel =  [
                SELECT Id, tolabel(CS_TipoIdentificacionCP__c)
                FROM Contact
                WHERE Id =: taskInfo.WhoId
                LIMIT 1
            ];

            idenType = cont[0].CS_TipoIdentificacionCP__c;
            idenNum = cont[0].CS_NumeroIdentificacionCP__c;

            response.successful = true;
            response.contactInfo = cont[0];
            response.accountTipIdenLabel = contToGetLabel[0].CS_TipoIdentificacionCP__c;
        }else{
            response.successful = false;
            response.message = 'No existe un contacto asociado a esta tarea';
        }

        saveLogValidation(taskId, response, TYPE_OTRO, idenType, idenNum);
        return response;
    }

    @AuraEnabled
    public static DtoResponse callRegistraduriaAndUpdateAccount(String taskId, Account acc, Boolean isContactToValidate) {
        DtoResponse response = new DtoResponse();

        String idenType;
        String idenNum;

        try {
            VS_WSGeneralExperienceService.requestRegistraduria dataWS = new VS_WSGeneralExperienceService.requestRegistraduria();
            dataWS.id = acc.CS_NumeroIdentificacionCP__pc;
            dataWS.idType = acc.CS_TipoIdentificacionCP__pc;
            
            String lastNameCode = EncodingUtil.urlEncode(acc.LastName, 'UTF-8');
            dataWS.lastName = lastNameCode;

            idenType = acc.CS_TipoIdentificacionCP__pc;
            idenNum = acc.CS_NumeroIdentificacionCP__pc;

            Map<String, String> results = VS_WSGeneralExperienceService.getRegistraduria(dataWS);

            System.debug('Service Response: ' + results.get('serviceResponse'));
            System.debug('Successful: ' + results.get('successful'));

            if (results != null && results.containsKey('successful') && results.get('successful') == 'true') {
                if(!isContactToValidate){
                    try {
                        update acc;

                        response.successful = true;
                        response.returnResponse = results.get('serviceResponse');
                    } catch (DMLException e) {
                        response.successful = false;
                        response.message = 'Ocurrió un error al guardar la cuenta: ' + e.getDmlMessage(0);  
                    }
                }else{
                    response.successful = true;
                    response.returnResponse = results.get('serviceResponse');
                }
            }else{
                response.successful = false;
                response.message = 'Ocurrio un problema al consultar el servicio de la registraduría: consulte a su administrador';
            }
        } catch (Exception e) {
            System.debug('Error deserialize response: ' + e.getMessage());

            response.successful = false;
            response.message = 'Ocurrio un error inesperado, consulte a su administrador: ' + e.getMessage();
        }

        saveLogValidation(taskId, response, TYPE_REGISTRADURIA, idenType, idenNum);
        return response;
    }

    @AuraEnabled
    public static DtoResponse sendOPTCode(String taskId, Account acc) {
        DtoResponse response = new DtoResponse();

        String idenType = acc.CS_TipoIdentificacionCP__pc;
        String idenNum = acc.CS_NumeroIdentificacionCP__pc;

        Boolean isLogged = false;
        try {

            VS_WSAuthenticationGetToken token = VS_WSAuthenticationGetToken.callout();
            System.debug(token);
            
            if(token.successful){
                if(Test.isRunningTest()){
                    string body = '{"Validations":{"ValidLastName":"true","ValidName":"true","ValidExpeditionDate":"true"},"ExcludeClient":"false","Alerts":{"Alert":"false","AlertResponse":"03","AlertCode":"00"},"Result":"01","ValidationRegistry":"6306411","ProcessResult":"true","AvailableQueries":"1","Person":{"Identification":{"Number":"00000000000","Type":"1","ExpeditionDate":"123456700000"},"FullName":"AAAAA AAAAAAAA AAAAAAA"}}';
        			Test.setMock(HttpCalloutMock.class, new VS_ValidacionOTPControllerTest.MockHttpResponseGenerator(200, body));
                }
                //response = getQuestionsValidate(token, accList);
                
                Boolean isOTP = true;
                VS_WSExperienceValidate validate = VS_WSExperienceValidate.callout(token.access_token, acc, isOTP);
                System.debug(validate);
                
                if(validate.successful){
                    system.debug('@@@@@@Valid + ' + validate.ValidationRegistry);
                    if(validate.ValidationRegistry != null && validate.ValidationRegistry != '' && (validate.Result == '01' || validate.Result == '05')){
                        if(Test.isRunningTest()){
                            string body = '{"ParameterizationCode":"","ValidationResult":{"ValidNumber":"","ReconocerRanking":""},"GenerationResult":{"SurveyRequired":"","OTP":{"Timestamp":"","ResultCode":"7","TransactionId":"","Result":"false"}},"SurveyData":{"EvidenteProcess":""}}';
                            Test.setMock(HttpCalloutMock.class, new VS_ValidacionOTPControllerTest.MockHttpResponseGenerator(200, body));
                        }  
                        
                        //response = getQuestionsgenerate(token, accList, validate);
                        VS_WSGeneralExperienceService.requestIniciaOTP requestData = new VS_WSGeneralExperienceService.requestIniciaOTP();
                        requestData.Numb_er = acc.CS_NumeroIdentificacionCP__pc;
                        requestData.ValidationRegistry = validate.ValidationRegistry;
                        requestData.PhoneNum = acc.PersonMobilePhone;
                        requestData.Typ_e = acc.CS_TipoIdentificacionCP__pc;
                        
                        // Llamar al método getIniciarOTP y obtener los resultados
                        Map<String, String> results = VS_WSGeneralExperienceService.getIniciarOTP(requestData);
                        
                        
                        if (results != null && results.containsKey('successful') && results.get('successful') == 'true'){
                            // Imprimir los resultados para ver la respuesta
                            System.debug('Resultado del servicio OTP: ' + results.get('serviceResponseOTP'));
                            System.debug('Éxito: ' + results.get('successful'));
                            
                            response.successful = true;
                            response.returnResponse = results.get('serviceResponseOTP');
                            response.validationRegistry = validate.ValidationRegistry;
                            
                        }else{
                            response.successful = false;
                            response.message = 'Ocurrió un problema en el servicio al inicializar OTP: consulte a su administrador';
                        }
                    }else{ 
                        String messagge = 'El cliente no fue validado correctamente, verifique su información: código ' + validate.Result;
                        if(validate.Result == '06'){
                            messagge = 'No coinciden datos';
                        }else if(validate.Result == '07'){
                            messagge = 'No existe identificación';
                        }else if(validate.Result == '08'){
                            messagge = 'Valido con documento no vigente';
                        }else if(validate.Result == '09'){
                            messagge = 'Superado el número de intentos de validación máximo del día';
                        }
                        response.successful = false;
                        response.message = messagge;
                        
                        saveLogValidation(taskId, response, TYPE_VALCLIENTE, idenType, idenNum);
                        isLogged = true;
                    }
                    
                }else{
                    response.successful = false;
                    response.message = 'Ocurrió un problema al validar el cliente: consulte a su administrador';
                    
                    saveLogValidation(taskId, response, TYPE_VALCLIENTE, idenType, idenNum);
                    isLogged = true;
                }
            }else{
                response.successful = false;
                response.message = 'Ocurrió un problema al obtener el token: consulte a su administrador';

                saveLogValidation(taskId, response, TYPE_TOKEN, idenType, idenNum);
                isLogged = true;
            }
        } catch (Exception e) {
            System.debug('Error deserialize response: ' + e.getMessage());

            response.successful = false;
            response.message = 'Ocurrió un problema al enviar el código OTP, consulte a su administrador: ' + e.getMessage();
        }

        if(!isLogged){
            saveLogValidation(taskId, response, TYPE_GENOTP, idenType, idenNum);
        }
        return response;
    }

    @AuraEnabled
    public static DtoResponse validateSendedOPTCode(String taskId, Account acc, String otpCode, String vRegistry, String tranId) {
        DtoResponse response = new DtoResponse();
        String idenType = acc.CS_TipoIdentificacionCP__pc;
        String idenNum = acc.CS_NumeroIdentificacionCP__pc;
        try {

            VS_WSAuthenticationGetToken token = VS_WSAuthenticationGetToken.callout();
            System.debug(token);
            
            if(token.successful){
                if(Test.isRunningTest()){
                    string body = '{"ValidateOTPCodeResponse":{"ValidationResult":"8","ParameterizationCode":"","ValidationMessage":"Transaccion invalidada por verificacion adicional.","ValidCode":"false","OTP":{"TransactionId":""}}}';
        			Test.setMock(HttpCalloutMock.class, new VS_ValidacionOTPControllerTest.MockHttpResponseGenerator(200, body));
                }
                //response = getQuestionsValidate(token, accList);
                
                VS_WSGeneralExperienceService.requestValidaOTP requestData = new VS_WSGeneralExperienceService.requestValidaOTP();
                
                requestData.ValidationRegistry = vRegistry; // ValidationRegistry
                requestData.Numb_er = acc.CS_NumeroIdentificacionCP__pc; //Número de identificacion
                requestData.Code = otpCode;   //Codigo OTP Generado 
                requestData.TransactionId = tranId; //ID de la transaccion
                requestData.Typ_e = acc.CS_TipoIdentificacionCP__pc; 
                
                // Llamar al método getIniciarOTP y obtener los resultados
                Map<String, String> results = VS_WSGeneralExperienceService.getValidaOTP(requestData);
                
                if (results != null && results.containsKey('successful') && results.get('successful') == 'true'){
                    // Imprimir los resultados para ver la respuesta
                    System.debug('Resultado del servicio OTP: ' + results.get('serviceResponseValidaOTP'));
                    System.debug('Éxito: ' + results.get('successful'));
                    
                    response.successful = true;
                    response.returnResponse = results.get('serviceResponseValidaOTP');
                }else{
                    response.successful = false;
                    response.message = 'Ocurrió un problema en el servicio al validar el código OTP: consulte a su administrador';
                }
            }else{
                response.successful = false;
                response.message = 'Ocurrió un problema al obtener el token: consulte a su administrador';
            }
        } catch (Exception e) {
            System.debug('Error deserialize response: ' + e.getMessage());

            response.successful = false;
            response.message = 'Ocurrió un problema al validar el código OTP, consulte a su administrador: ' + e.getMessage();
            
        }

        saveLogValidation(taskId, response, TYPE_VALOTP, idenType, idenNum);
        return response;
    }
    
    @AuraEnabled
    public static DtoResponse saveValidatedDateInAccount(Account acc) {
        DtoResponse response = new DtoResponse();
        try {
            acc.Fecha_Ultima_Validacion_Cliente__c = DateTime.now();
            update acc;
            response.successful = true;

        } catch (DMLException e) {
            response.successful = false;
            response.message = 'Se realizó corectamente la validación del cliente, pero ocurrió un error al guardar la cuenta: ' + e.getDmlMessage(0);
            return response;   
        }
        

        return response;
    }

    @AuraEnabled
    public static DtoResponse getAccountInfoBeneficiario(String taskId) {
        DtoResponse response = new DtoResponse();
        System.debug('Task Id: ' + taskId);

        Task taskInfo = [SELECT Id, WhatId, Poliza_de_seguro__c
                         FROM Task
                         WHERE Id =: taskId
                         LIMIT 1
                         ];

        if(taskInfo.WhatId != null){
            List<InsurancePolicy> policyList;
            if(taskInfo.Poliza_de_seguro__c != null){
                policyList = [SELECT Id, Name, (SELECT Id, Role, PrimaryParticipantAccountId, PrimaryParticipantAccount.Id, PrimaryParticipantAccount.FirstName, 
                                                PrimaryParticipantAccount.MiddleName, PrimaryParticipantAccount.LastName, PrimaryParticipantAccount.Suffix, 
                                                PrimaryParticipantAccount.PersonMobilePhone, tolabel(PrimaryParticipantAccount.CS_TipoIdentificacionCP__pc), 
                                                PrimaryParticipantAccount.CS_NumeroIdentificacionCP__pc, 
                                                PrimaryParticipantAccount.CS_FechaExpedicion__pc, PrimaryParticipantAccount.PersonEmail
                                                FROM InsurancePolicyParticipants 
                                                WHERE Role includes ('Beneficiario'))
                                                    FROM InsurancePolicy
                                                    WHERE Id =: taskInfo.Poliza_de_seguro__c
                                                    LIMIT 1
                                                    ];


            }else{
                policyList = [SELECT Id, Name, Status, ProductId, Product.Name, CS_Ramo__c, PolicyDescription, (SELECT Id, Role, PrimaryParticipantAccountId, PrimaryParticipantAccount.FirstName FROM InsurancePolicyParticipants WHERE Role includes ('Beneficiario'))
                                                    FROM InsurancePolicy
                                                    WHERE NameInsuredId =: taskInfo.WhatId
                                                    ];
            }

            if(policyList.size() > 0){
                if(taskInfo.Poliza_de_seguro__c != null){
                    List<Id> listAccountId = new List<Id>();
                    for(InsurancePolicy pol : policyList){
                        for(InsurancePolicyParticipant participant : pol.InsurancePolicyParticipants){
                            if(participant.PrimaryParticipantAccountId != null){
                                listAccountId.add(participant.PrimaryParticipantAccountId);
                            }
                        }
                    }
                    if(listAccountId.size() > 0){
                        Boolean areThereAccount = False;
                        Map<Id, Account> mapAccount = new Map<Id, Account>([SELECT Id, FirstName, MiddleName, LastName, Suffix, PersonMobilePhone, CS_TipoIdentificacionCP__pc, 
                                                    CS_NumeroIdentificacionCP__pc, CS_FechaExpedicion__pc, PersonEmail, Name, CS_NumeroIdentificacion__c, CS_TipoIdentificacion__c, IsPersonAccount
                                                    FROM Account
                                                    WHERE Id in :listAccountId]);


                        List<DtoParticipant> participantList = new List<DtoParticipant>();
                        for(InsurancePolicy pol : policyList){
                            for(InsurancePolicyParticipant participant : pol.InsurancePolicyParticipants){
                                DtoParticipant aux =  new DtoParticipant();

                                aux.participant = participant;

                                if(participant.PrimaryParticipantAccountId != null){
                                    if(mapAccount.containsKey(participant.PrimaryParticipantAccountId)){
                                        areThereAccount = true;
                                        aux.participantAccount = mapAccount.get(participant.PrimaryParticipantAccountId);
                                        System.debug('@@@@: ' + mapAccount.get(participant.PrimaryParticipantAccountId));
                                        response.accountInfo = mapAccount.get(participant.PrimaryParticipantAccountId);
                                    }
                                }

                                participantList.add(aux);
                            }
                        }
                        if(areThereAccount){
                            response.successful = true;
                            response.participantList = participantList;
                        }else{
                            response.successful = false;
                            response.message = 'Los beneficiarios disponibles no tienes una cuenta asociada';
                        }
                        
                    }else{
                        response.successful = false;
                        response.message = 'La póliza seleccionada no tiene beneficiarios disponibles para consultar';
                    }
                }
                else{
                    response.successful = true;
                    response.participantList =  null;
                    response.policyList = policyList;
                }
            }else{
                response.successful = false;
                response.message = taskInfo.Poliza_de_seguro__c != null ? 'No fue posible encontrar la póliza seleccionada' : 'No hay pólizas con beneficiarios disponibles para consultar';
            }
        }else{
            response.successful = false;
            response.message = 'No existe una cuenta asociada a esta tarea';
        }

        return response;
    }

    @AuraEnabled
    public static DtoResponse savePolicy(String taskId, String policyId) {
        DtoResponse response = new DtoResponse();
        try {
            Task ta = new Task();
            ta.Id = taskId;
            ta.Poliza_de_seguro__c = policyId;
            update ta;

            response.successful = true;
            return response;

        } catch (DMLException e) {
            response.successful = false;
            response.message = 'Ocurrió un error al guardar la póliza en la tarea: ' + e.getDmlMessage(0);
            return response;   
        }
    }

    @AuraEnabled
    public static void saveLogValidation(String taskId, DtoResponse response, String type, String idenType, String idenNum){
        if(!response.successful){
            insertLogValidation(taskId, STATUS_FALLIDO, response.message, type, idenType, idenNum);
        }
    }

    @AuraEnabled
    public static DtoResponse insertLogValidation(String taskId, String status, String messagge, String type, String idenType, String idenNum) {
        DtoResponse response = new DtoResponse();

        Account accountReference;
        List<Account> accList = [SELECT Id
                                 FROM Account
                                 WHERE CS_TipoIdentificacionCP__pc = :idenType and CS_NumeroIdentificacionCP__pc = :idenNum
                                 LIMIT 1];

        accountReference = accList.size() > 0 ? accList[0] : null;

        System.debug('@@@@Insert: ' + idenType + ' ' + idenNum);

        Id relId;
        if(taskId != null && taskId != ''){
            
            List<Task> listTaskInfo = [SELECT Id, Relacion_Tarea_Historial_Validacion__c
                                FROM Task
                                WHERE Id =: taskId
                                LIMIT 1];
            if(listTaskInfo.size() > 0){
                Task taskInfo = listTaskInfo[0];
                Boolean updateTask = false;

                if(taskInfo.Relacion_Tarea_Historial_Validacion__c == null){
                    Relacion_Tarea_Historial_Validacion__c auxRel = new Relacion_Tarea_Historial_Validacion__c();
                    auxRel.Name = 'Relación Tarea - Historiales';

                    insert auxRel;
                    relId = auxRel.Id;

                    taskInfo.Relacion_Tarea_Historial_Validacion__c = relId;
                    updateTask = true;
                    
                }else{
                    relId = taskInfo.Relacion_Tarea_Historial_Validacion__c;
                }

                if(type == TYPE_VALOTP && status == STATUS_EXITOSO){
                    taskInfo.Fecha_Ultima_Validacion_Cliente__c = DateTime.now();
                    updateTask = true;
                }
                if(updateTask){
                    update taskInfo;
                }
            }else{
                response.successful = false;
                response.message = 'No se encontró la tarea';
                return response;
            }
        }

        if(relId != null || accountReference != null){
            Historial_de_Validacion__c history = new Historial_de_Validacion__c();
            history.Estado__c = status;
            history.Mensaje__c = messagge;
            history.Tipo__c = type;
            history.Tipo_de_identificacion__c = idenType;
            history.Numero_de_identificacion__c = idenNum;

            history.Relacion_Tarea_Historial_Validacion__c = relId;
            history.Cuenta__c                              = accountReference != null ? accountReference.Id : null;

            insert history;
            response.successful = true;
        }else{
            response.successful = false;
            response.message = 'No se encontró referencia de la llamada o de la cuenta';
        }

        return response;
    
    }

    public class DtoResponse {
        @AuraEnabled
        public Boolean successful { get; set; }
        @AuraEnabled
        public String message { get; set; }
        
        @AuraEnabled
        public Account accountInfo { get; set; }

        @AuraEnabled
        public Contact contactInfo { get; set; }

        @AuraEnabled
        public String returnResponse { get; set; }

        @AuraEnabled
        public String accountTipIdenLabel { get; set; }

        @AuraEnabled
        public String validationRegistry { get; set; }

        @AuraEnabled
        public List<InsurancePolicy> policyList { get; set; }

        @AuraEnabled
        public List<DtoParticipant> participantList { get; set; }

    }

    public class DtoParticipant{
        @AuraEnabled
        public InsurancePolicyParticipant participant { get; set; }
        @AuraEnabled
        public Account participantAccount { get; set; }
    }
}