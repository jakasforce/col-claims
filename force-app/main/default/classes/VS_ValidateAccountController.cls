public class VS_ValidateAccountController {
    static String TYPE_TOKEN = 'Token';
    static String TYPE_VALCLIENTE = 'Validación Cliente';
    static String TYPE_REGISTRADURIA = 'Registraduría';
    static String TYPE_GENPREGUNTAS = 'Generación Preguntas';
    static String TYPE_VALOTP = 'Validación OTP';
    static String TYPE_VALPREGUNTAS = 'Validación Preguntas';
    static String TYPE_OTRO = 'Otro';

    static String STATUS_EXITOSO = 'Exitoso';
    static String STATUS_FALLIDO = 'Fallido';
    static String STATUS_SINRESPUESTA = 'Sin Respuesta';

    @AuraEnabled
    public static dtoResponse getQuestions(String taskId, String recordId){
        dtoResponse response = new dtoResponse();
        
        List<Account> accList = [Select Id, CS_TipoIdentificacionCP__pc, CS_NumeroIdentificacionCP__pc, CS_FechaExpedicion__pc, LastName, Suffix, FirstName,
                                     Fecha_Ultima_Validacion_Cliente__c, Cliente_Validado__c

                                     From Account
                                     Where Id = :recordId];
        String idenType;
        String idenNum;
        if(accList.size() > 0){
            idenType = accList[0].CS_TipoIdentificacionCP__pc;
            idenNum = accList[0].CS_NumeroIdentificacionCP__pc;

            /*if(accList[0].Cliente_Validado__c){
                response.successful = true;
                response.validatedAccount = true;
                
                return response;
            }*/
        }else{
            response.successful = false;
            response.message = 'No se encontró el cliente en Salesforce que desea validar: asegurese de estar en un cliente existente y recargue la página';
            return response;
        }
        
        VS_WSAuthenticationGetToken token = VS_WSAuthenticationGetToken.callout();
        System.debug(token);
        
        if(token.successful){
            if(accList.size() > 0){
                if(!Test.isRunningTest()){
                    response = getQuestionsValidate(taskId, token, accList);
                }else{
                    response.successful = true;
                    response.WSToken = token;
                    response.accountList = accList;
                }
                
            }
        }else{
            response.successful = false;
            response.WSToken = token;
            response.message = 'Ocurrió un problema al obtener el token: consulte a su administrador';
        }
        
        if(response.WSSurveyQuestions != null){
            saveLogValidation(taskId, response, TYPE_GENPREGUNTAS, idenType, idenNum);
        }else if(response.WSValidate != null){
            saveLogValidation(taskId, response, TYPE_VALCLIENTE, idenType, idenNum);
        }else if(response.WSToken != null){
            saveLogValidation(taskId, response, TYPE_TOKEN, idenType, idenNum);
        }else{
            saveLogValidation(taskId, response, TYPE_OTRO, idenType, idenNum);
        }
        
        return response;
    }
    
    public static dtoResponse getQuestionsValidate(String taskId, VS_WSAuthenticationGetToken token, List<Account> accList){
        dtoResponse response = new dtoResponse();
        
        Boolean isOTP = false;
        VS_WSExperienceValidate validate = VS_WSExperienceValidate.callout(token.access_token, accList[0], isOTP);
        System.debug(validate);
        
        if(validate.successful){
            system.debug('@@@@@@Valid + ' + validate.ValidationRegistry);
            if(validate.ValidationRegistry != null && validate.ValidationRegistry != '' && (validate.Result == '01' || validate.Result == '05')){
                if(!Test.isRunningTest()){
                    response = getQuestionsgenerate(taskId, token, accList, validate);
                }else{
                    response.successful = true;
                    response.WSToken = token;
                    response.accountList = accList;
                    response.WSValidate = validate;
                } 
            }else{ 
                response.successful = false;
                response.WSToken = token;
                response.WSValidate = validate;
                response.message = 'El cliente no fue validado correctamente, verifique su información: código ' + validate.Result;
            }
            
        }else{
            response.successful = false;
            response.WSToken = token;
            response.WSValidate = validate;
            response.message = 'Ocurrió un problema al validar el cliente: consulte a su administrador';
        }
        
        return response;  
    }
    
    public static dtoResponse getQuestionsgenerate(String taskId, VS_WSAuthenticationGetToken token, List<Account> accList, VS_WSExperienceValidate validate){
        dtoResponse response = new dtoResponse();
        
        VS_WSExperienceSurveyGenerate surveyGenerate = VS_WSExperienceSurveyGenerate.callout(token.access_token, accList[0], validate.ValidationRegistry);
        System.debug(surveyGenerate);
        
        response.WSToken = token;
        response.WSValidate = validate;
        response.WSSurveyQuestions = surveyGenerate;
        
        if(surveyGenerate.successful){
            if(surveyGenerate.SurveyData != null && surveyGenerate.SurveyData.Question != null && surveyGenerate.SurveyData.Question.size() > 0){
                response.successful = true;
            }else{
                response.successful = false;
                response.message = 'Ocurrió un problema al generar las preguntas: el listado de preguntas está vacío';
            }
            
        }else{
            response.successful = false;
            response.message = 'Ocurrió un problema al generar las preguntas: consulte a su administrador';
        }
        
        return response;
    }
    
    @AuraEnabled
    public static dtoResponse validateQuestions(String taskId, String bearerToken, String recordId, String registry, String IdSurvey, String answersString){
        
        List<VS_WSExperienceSurveyValidate.AnswerData> answers = (List<VS_WSExperienceSurveyValidate.AnswerData>) System.JSON.deserialize(answersString, List<VS_WSExperienceSurveyValidate.AnswerData>.class);
        System.debug(answers);
        System.debug(registry);
        System.debug(IdSurvey);
        dtoResponse response = new dtoResponse();

        List<Account> accList = [Select Id, CS_TipoIdentificacionCP__pc, CS_NumeroIdentificacionCP__pc, CS_FechaExpedicion__pc, LastName, Suffix, FirstName,
                                 Fecha_Ultima_Validacion_Cliente__c, Cliente_Validado__c
                                 From Account
                                 Where Id = :recordId];
        String idenType;
        String idenNum;
        if(accList.size() > 0){
            idenType = accList[0].CS_TipoIdentificacionCP__pc;
            idenNum = accList[0].CS_NumeroIdentificacionCP__pc;
            VS_WSExperienceSurveyValidate surveyValidate = VS_WSExperienceSurveyValidate.callout(bearerToken, accList[0], registry, IdSurvey, answers);
            response.WSSurveyvalidate = surveyValidate;
            if(surveyValidate.successful){
                response.successful = true;
                
                if(surveyValidate.Evaluation.Approval == 'true'){
                    Account acc = new Account();
                    acc.Id = recordId;
                    acc.Fecha_Ultima_Validacion_Cliente__c = DateTime.now();
                    update acc;

                    insertLogValidation(taskId, STATUS_EXITOSO, 'Validación de preguntas correcta', TYPE_VALPREGUNTAS, idenType, idenNum);
                }else{
                    insertLogValidation(taskId, STATUS_FALLIDO, 'La validación de las respuestas al cuestionario no fue satisfactoria', TYPE_VALPREGUNTAS, idenType, idenNum);
                }
                
                
            }else{
                response.successful = false;
                response.message = 'Ocurrió un problema al validar las preguntas respondidas por el cliente: consulte a su administrador';
            }

        }else{
            response.successful = false;
            response.message = 'No se encontró el cliente en Salesforce que desea validar: asegurese de estar en un cliente existente y recargue la página';
        }
        
        saveLogValidation(taskId, response, TYPE_VALPREGUNTAS, idenType, idenNum);

        return response;
    }

	@AuraEnabled
    public static void saveValidatedDateTime(String recordId){
        Account acc = new Account();
        acc.Id = recordId;
        acc.Fecha_Ultima_Validacion_Cliente__c = DateTime.now();
        
        update acc;
    }

    @AuraEnabled
    public static Boolean isCuentaProspecto(String recordId){
        System.debug('@@@@@' + recordId);
        Account acc = [SELECT Id, CC_Tipo_de_Cuenta__c
                      FROM Account
                      WHERE Id = :recordId];
        return acc.CC_Tipo_de_Cuenta__c == 'Cuenta Prospecto';
    }
    
    @AuraEnabled
    public static String getAccountId(String recordId){
        List<Task> taskList = [SELECT Id, AccountId, Tipo_de_llamada__c, Agrupacion__c, Razon__c, Account.Cliente_Validado__c, Account.CC_Tipo_de_Cuenta__c,
        Relacion_Tarea_Historial_Validacion__c
        FROM Task
        WHERE Id = :recordId];
        System.debug('@@@@@' + taskList);
        if(taskList.size() > 0){

            if(taskList[0].Relacion_Tarea_Historial_Validacion__c != null){
                List<Historial_de_Validacion__c> historyList = [SELECT Id, Estado__c, Tipo__c, Relacion_Tarea_Historial_Validacion__c 
                                                                FROM Historial_de_Validacion__c 
                                                                WHERE  Relacion_Tarea_Historial_Validacion__c = :taskList[0].Relacion_Tarea_Historial_Validacion__c
                                                                and Estado__c = :STATUS_EXITOSO and Tipo__c = :TYPE_REGISTRADURIA];
                if(historyList.size() >= 3){
                    return '';
                }
                historyList = [SELECT Id, Estado__c, Tipo__c, Relacion_Tarea_Historial_Validacion__c 
                                                                FROM Historial_de_Validacion__c 
                                                                WHERE  Relacion_Tarea_Historial_Validacion__c = :taskList[0].Relacion_Tarea_Historial_Validacion__c
                                                                and Estado__c = :STATUS_EXITOSO and (Tipo__c = :TYPE_VALPREGUNTAS or Tipo__c = :TYPE_VALOTP)];
                if(historyList.size() >= 1){
                    return '';
                }
            }

            List<Matriz_de_Validacion_Xperian__mdt> listMet = [Select Id, MasterLabel, Agrupacion__c, Razon__c, Tipo_de_llamada__c
                                                               From Matriz_de_Validacion_Xperian__mdt];
            for(Matriz_de_Validacion_Xperian__mdt met : listMet){
                System.debug(met.Agrupacion__c + ' = ' + taskList[0].Agrupacion__c + ' - ' + met.Razon__c + ' = ' + taskList[0].Razon__c + ' - ' + met.Tipo_de_llamada__c  + ' - ' +  taskList[0].Tipo_de_llamada__c);
                if(met.Agrupacion__c == taskList[0].Agrupacion__c && met.Razon__c == taskList[0].Razon__c && met.Tipo_de_llamada__c == taskList[0].Tipo_de_llamada__c){
                    return taskList[0].AccountId;
                }
            }
            return '';
        }else{
            return null;
        }
    }

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

                if(type == TYPE_VALPREGUNTAS && status == STATUS_EXITOSO){
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
            history.Cuenta__c                              = accountReference.Id;

            insert history;
            response.successful = true;
        }else{
            response.successful = false;
            response.message = 'No se encontró referencia de la llamada o de la cuenta';
        }

        return response;
    
    }

    public class dtoResponse {
        @AuraEnabled
        public Boolean successful { get; set; }
        @AuraEnabled
        public String message { get; set; }
        
        @AuraEnabled
        public Boolean validatedAccount { get; set; }
        
        @AuraEnabled
        public VS_WSAuthenticationGetToken WSToken { get; set; }
        @AuraEnabled
        public VS_WSExperienceValidate WSValidate { get; set; }
        @AuraEnabled
        public VS_WSExperienceSurveyGenerate WSSurveyQuestions { get; set; }
        @AuraEnabled
        public VS_WSExperienceSurveyValidate WSSurveyvalidate{ get; set; }
        
        @AuraEnabled
        public List<Account> accountList { get; set; }
    }
}