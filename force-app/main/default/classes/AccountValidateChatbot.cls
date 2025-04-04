public class AccountValidateChatbot {
    
    public class ChatBotTempInput{
        @InvocableVariable(required= true)
        public String City ;
        @InvocableVariable(required= true)
        public String FechaExpedicionDocumento ;
        @InvocableVariable(required= true)
        public String CodigoOTP ;
        @InvocableVariable(required= true)
        public String IniciaOTPRequest ;
        @InvocableVariable(required= true)
        public String ValidaOTPResponse ;
        @InvocableVariable(required= true)
        public String PreguntaRetoGenerateRequest ;
        @InvocableVariable(required= true)
        public String PreguntaRetoValidateRequest ;
        @InvocableVariable(required= true)
        public String answer ;
        @InvocableVariable(required= true)
        public String answer2 ;
        @InvocableVariable(required= true)
        public String answer3 ;
        @InvocableVariable(required= true)
        public String answer4 ;
        @InvocableVariable(required= true)
        public String PrimeraInteraccion ;
        @InvocableVariable(required= true)
        public String IdSurvey ;
        @InvocableVariable(required= true)
        public String validationRegistry ;
        @InvocableVariable(required= true)
        public String Registry ;
        @InvocableVariable(required= true)
        public String ResultCode ;
        
        @InvocableVariable(required= true)
        public String TransactionId ;
        
    }
    public class ChatBotTempOutput{
        
        @InvocableVariable(required= true)
        public String ResultCode ;
        
        @InvocableVariable(required= true)
        public String TransactionId ;
        
        @InvocableVariable(required= true)
        public String PreguntasReto ;
        
        @InvocableVariable(required= true)
        public String OTP ;
        
        @InvocableVariable(required= true)
        public String ListasRestrictivas ;
        
        @InvocableVariable(required= true)
        public String Registraduria ;
        
        @InvocableVariable(required= true)
        public String ServiceError ;
        
        @InvocableVariable(required= true)
        public String validationRegistry ;
        
        @InvocableVariable(required= true)
        public String IdSurvey ;
        
        @InvocableVariable(required= true)
        public String Registry ;
        
        @InvocableVariable(required= true)
        public Boolean Temp ;
        
        @InvocableVariable(required= true)
        public List<String> question = new List<String>();
        @InvocableVariable(required= true)
        public List<String> answers = new List<String>();
        @InvocableVariable(required= true)
        public List<String> answers2 = new List<String>();
        @InvocableVariable(required= true)
        public List<String> answers3 = new List<String>();
        @InvocableVariable(required= true)
        public List<String> answers4 = new List<String>();
    }
    
    
    public class infoClient{
        public String idRecord;
        public String firstName;
        public String middleName;
        public String lastName;
        public String secondLastName;
        public String documentType;
        public String documentNumber;
        public String phone;
        public String ExpeditionDate;
        
    }
    
    
    @InvocableMethod(Label ='Validacion Identidad' description='return temp')
    public static List<ChatBotTempOutput> ValidacionIdentidad(List<ChatBotTempInput> input)
    {
        
        List<ChatBotTempOutput> lstOutput = new List<ChatBotTempOutput>();
        for( ChatBotTempInput ChatBI : input){
            infoClient clientInformation = new infoClient();
            List<Account> clientInfo = [SELECT  id, FirstName, MiddleName, LastName, Suffix, CS_TipoIdentificacionCP__pc, CS_NumeroIdentificacionCP__pc, 
                                                PersonMobilePhone, CS_FechaExpedicion__pc 
                                        FROM  Account WHERE Id = :ChatBI.City];
                                        
            //almaceno info en clase
            clientInformation.firstName         =   clientInfo[0].FirstName;
            clientInformation.middleName        =   clientInfo[0].MiddleName;
            clientInformation.lastName          =   clientInfo[0].lastName;
            clientInformation.secondLastName    =   clientInfo[0].Suffix;
            clientInformation.documentType      =   clientInfo[0].CS_TipoIdentificacionCP__pc;
            clientInformation.documentNumber    =   clientInfo[0].CS_NumeroIdentificacionCP__pc;
            clientInformation.phone             =   clientInfo[0].PersonMobilePhone;
            clientInformation.ExpeditionDate    =   String.valueOf(clientInfo[0].CS_FechaExpedicion__pc).replace('-','');

            System.debug('clientInformation--->'+clientInformation);

            ChatBotTempOutput obj = new ChatBotTempOutput();
            
            // Crear una instancia de requestListaRestrictiva y asignar valores
            if(ChatBi.PrimeraInteraccion == 'si'){
                System.debug('Entro a experian a listas restrictivas');
                VS_WSGeneralExperienceService.requestListaRestrictiva ListasRestrictivasData = new VS_WSGeneralExperienceService.requestListaRestrictiva();
                ListasRestrictivasData.Numbe_r          = clientInformation.documentNumber;
                ListasRestrictivasData.FirstName        = clientInformation.firstName;
                ListasRestrictivasData.MiddleName       = clientInformation.middleName;
                ListasRestrictivasData.LastName         = clientInformation.lastName;
                ListasRestrictivasData.SecondLastName   = clientInformation.secondLastName;
                
                
                
                // Llamar al método getListaRestrictiva y obtener los resultados
                Map<String, String> ListasRestrictivas = VS_WSGeneralExperienceService.getListaRestrictiva(ListasRestrictivasData);

                // Imprimir los resultados
                if(ListasRestrictivas.get('successful') != 'true'){
                    System.debug('FALLO EL SERVICIO DE LISTAS RESTRICTIVAS');
                    obj.ServiceError = 'El Servicio ListasRestrictivas Fallo Comuniquese con el administrador';
                    lstOutput.add(obj);
                    return  lstOutput;
                }
                if(ListasRestrictivas.get('emptyLists') == 'true'){
                    System.debug('EL CLIENTE SE ENCUENTRA REPORTADO');
                    obj.ListasRestrictivas = ListasRestrictivas.get('failureTrace');
                    lstOutput.add(obj);
                    return  lstOutput;
                }
                VS_WSGeneralExperienceService.requestRegistraduria RegistraduriaData = new VS_WSGeneralExperienceService.requestRegistraduria();
                System.debug('Sigue a comprobar en registraduria');
                RegistraduriaData.id        = clientInformation.documentNumber;
                RegistraduriaData.idType    = '1';
                RegistraduriaData.lastName  = clientInformation.lastName;

                Map<String, String> Registraduria = VS_WSGeneralExperienceService.getRegistraduria(RegistraduriaData);
      
                if(Registraduria.get('successful') != 'true'){
                    System.debug('FALLO EL SERVICIO DE REGISTRADURIA');
                    obj.ServiceError = 'El Servicio Registraduria Fallo Comuniquese con el administrador';
                    lstOutput.add(obj);
                    return  lstOutput;
                }
                system.debug('Registraduria + ' + Registraduria.get('isValid'));
                if(Registraduria.get('isValid') == 'false'){
                    System.debug('EL CLIENTE SE ENCUENTRA MUERTO');
                    obj.Registraduria = Registraduria.get('failureTrace');
                    lstOutput.add(obj);
                    return  lstOutput;
                }
            }
            
            if(ChatBI.IniciaOTPRequest == 'si'){
                System.debug('Entro a OTP');
                VS_WSGeneralExperienceService.requestIdentityValidate IdentityValidateData = new VS_WSGeneralExperienceService.requestIdentityValidate();
                IdentityValidateData.FirstName      = clientInformation.firstName;
                IdentityValidateData.SecondLastName = clientInformation.secondLastName;
                IdentityValidateData.LastName       = clientInformation.lastName;
                IdentityValidateData.ExpeditionDate = clientInformation.ExpeditionDate;
                // String fechaIngresada = ChatBI.FechaExpedicionDocumento; // La fecha ingresada en formato 'yyyy-MM-dd'
                // Datetime formattedExpeditionDateTime = DateTime.newInstance(Integer.valueOf(fechaIngresada.substring(4,7)), Integer.valueOf(fechaIngresada.substring(2,3)), Integer.valueOf(fechaIngresada.substring(1,2)), 0, 0, 0);
                // String formattedExpeditionDate = formattedExpeditionDateTime.format('ddMMyyyyHHmm');
                
                // Asignar el valor formateado a IdentityValidateData.ExpeditionDate
                // IdentityValidateData.ExpeditionDate = formattedExpeditionDate;     
                //IdentityValidateData.ExpeditionDate = ChatBI.FechaExpedicionDocumento;
                IdentityValidateData.Typ_e = '1';
                IdentityValidateData.ForceOTP = false;
                IdentityValidateData.Numbe_r = clientInformation.documentNumber; // Corregido el nombre de la variable
                
                // Llamar al método getIniciarOTP y obtener los resultados
                Map<String, String> IdentityValidate = VS_WSGeneralExperienceService.getIdentityValidate(IdentityValidateData);
                if(IdentityValidate.get('successful') != 'true'){
                    obj.ServiceError = 'El Servicio validateOTP Fallo Comuniquese con el administrador';
                    lstOutput.add(obj);
                    return  lstOutput;
                } 
                obj.validationRegistry = IdentityValidate.get('ValidationRegistry');
                lstOutput.add(obj);
                VS_WSGeneralExperienceService.requestIniciaOTP IniciaOTPData = new VS_WSGeneralExperienceService.requestIniciaOTP();
                IniciaOTPData.ValidationRegistry = IdentityValidate.get('ValidationRegistry');
                IniciaOTPData.Numb_er = clientInformation.documentNumber;
                IniciaOTPData.Typ_e = '1';  
                if(clientInformation.phone.contains('+57') && clientInformation.phone.contains(' ')){
                    List<String> array2 = clientInformation.phone.split(' ');
                    clientInformation.phone = array2[1];
                    
                }else if(clientInformation.phone.contains('57')){
                    clientInformation.phone = clientInformation.phone.replace('57', '');
                }
                IniciaOTPData.PhoneNum = clientInformation.phone;

                Map<String, String> IniciaOTP = VS_WSGeneralExperienceService.getIniciarOTP(IniciaOTPData);

                // Imprimir los resultados para ver la respuesta
                if(IniciaOTP.get('successful') != 'true'){
                    System.debug('Fallo el segundo punto de OTP :(');
                    obj.ServiceError = 'El Servicio Inicia OTP Fallo Comuniquese con el administrador';
                    lstOutput.add(obj);
                    return  lstOutput;
                }
                obj.ValidationRegistry = IdentityValidate.get('ValidationRegistry');
                obj.ResultCode = IniciaOTP.get('ResultCode') ;
                obj.TransactionId = IniciaOTP.get('TransactionId'); 
                lstOutput.add(obj);
                return  lstOutput;
            }
            if(ChatBI.ValidaOTPResponse == 'si'){
                System.debug('Entro a validar codigo OTP');
                VS_WSGeneralExperienceService.requestValidaOTP ValidaOTPData = new VS_WSGeneralExperienceService.requestValidaOTP();
                ValidaOTPData.Code = ChatBI.CodigoOTP;
                ValidaOTPData.ValidationRegistry = ChatBI.ValidationRegistry;
                ValidaOTPData.Numb_er = clientInformation.documentNumber;
                ValidaOTPData.TransactionId = ChatBI.TransactionId;
                ValidaOTPData.Typ_e = '1';   
                
                // Llamar al método getIniciarOTP y obtener los resultados
                Map<String, String> ValidaOTP = VS_WSGeneralExperienceService.getValidaOTP(ValidaOTPData);

                // Imprimir los resultados para ver la respuesta
                if(ValidaOTP.get('successful') != 'true'){
                    obj.ServiceError = 'El Servicio Valida OTP Fallo Comuniquese con el administrador';
                    lstOutput.add(obj);
                    return  lstOutput;
                }
                System.debug('Resultado del servicio OTP: ' + ValidaOTP.get('serviceResponseValidaOTP'));
                System.debug('Éxito: ' + ValidaOTP.get('successful'));
                System.debug('codeCorrect--->'+ValidaOTP.get('ValidCode'));
                if(ValidaOTP.get('ValidCode') == 'true'){
                    obj.OTP = 'true';
                    lstOutput.add(obj);
                    return  lstOutput;
                }else{
                    obj.OTP = 'false';
                    lstOutput.add(obj);
                    return  lstOutput;
                }
            }
            if(ChatBI.PreguntaRetoGenerateRequest == 'si'){
                System.debug('Entro a validar preguntas retro');
                VS_WSGeneralExperienceService.requestIdentityValidate IdentityValidateData = new VS_WSGeneralExperienceService.requestIdentityValidate();
                IdentityValidateData.FirstName      = clientInformation.firstName;
                IdentityValidateData.SecondLastName = clientInformation.secondLastName;
                IdentityValidateData.LastName       = clientInformation.lastName;
                IdentityValidateData.ForceOTP       = true; //Si ForceOTP es false es porque veridfica para OTP, si es true es porque verifica para pasar a preguntas reto
                IdentityValidateData.ExpeditionDate = clientInformation.ExpeditionDate;
                IdentityValidateData.Typ_e          = '1';
                IdentityValidateData.Numbe_r        = clientInformation.documentNumber; // Corregido el nombre de la variable
                
                // Llamar al método getIniciarOTP y obtener los resultados
                System.debug('Validacion de existencia en experian');
                Map<String, String> IdentityValidate = VS_WSGeneralExperienceService.getIdentityValidate(IdentityValidateData);
                system.debug('validate........' + IdentityValidate);
                if(IdentityValidate.get('successful') != 'true'){
                    obj.ServiceError = 'El Servicio validateOTP Fallo Comuniquese con el administrador';
                    lstOutput.add(obj);
                    return  lstOutput;
                } 
                
                VS_WSGeneralExperienceService.requestSurveyGenerate SurveyGenerateData = new VS_WSGeneralExperienceService.requestSurveyGenerate();
                
                SurveyGenerateData.ValidationRegistry = IdentityValidate.get('ValidationRegistry');
                SurveyGenerateData.Typ_e = '1';
                SurveyGenerateData.Numb_er = clientInformation.documentNumber;
                
                // Llamar al método getIniciarOTP y obtener los resultados
                Map<String, Object> SurveyGenerate = VS_WSGeneralExperienceService.getSurveyGenerate(SurveyGenerateData);
                system.debug('respuestas'+SurveyGenerate);
                System.debug('Preguntas-->'+SurveyGenerate.get('Questions'));
                System.debug('Respuestas-->'+SurveyGenerate.get('Answers'));
                // Procesar las preguntas y respuestas del servicio
                if (SurveyGenerate.get('Questions') != null && SurveyGenerate.get('Answers') != null) {
                    List<String> questions = (List<String>) SurveyGenerate.get('Questions');
                    List<List<String>> answersList = (List<List<String>>) SurveyGenerate.get('Answers');
                    
                    
                    // Asignar preguntas
                    obj.question = questions;
                    System.debug('Formula Rara---->' + Math.min(answersList.size(), 4));
                    // Asignar respuestas
                    for (Integer i = 0; i < Math.min(answersList.size(), 4); i++) {
                        if (i == 0) {
                            obj.answers = answersList.get(i);
                        } else if (i == 1) {
                            obj.answers2 = answersList.get(i);
                        } else if (i == 2) {
                            obj.answers3 = answersList.get(i);
                        } else if (i == 3) {
                            obj.answers4 = answersList.get(i);
                        }
                    }
                    obj.IdSurvey = String.valueof(SurveyGenerate.get('IdSurvey'));
                    obj.Registry = String.valueof(SurveyGenerate.get('Registry'));
                    lstOutput.add(obj);
                }
            }
            //Validar preguntas
            if (ChatBI.PreguntaRetoValidateRequest == 'si') {
                // Obtener las respuestas de donde las tengas en tu controlador
                
                List<String> answerIds = new List<String>{
                    ChatBI.Answer,
                        ChatBI.Answer2,
                        ChatBI.Answer3,
                        ChatBI.Answer4
                        }; 
                            // Crear una instancia de la clase VS_WSGeneralExperienceService.requestSurveyValidate
                            VS_WSGeneralExperienceService.requestSurveyValidate surveyValidateData = new VS_WSGeneralExperienceService.requestSurveyValidate();
                
                // Asignar valores a surveyValidateData
                surveyValidateData.Registry = ChatBI.Registry;
                surveyValidateData.Id = ChatBI.IdSurvey;
                surveyValidateData.Typ_e = '1';
                surveyValidateData.Numb_er = clientInformation.documentNumber;
                
                // Llamar al método getSurveyValidate y obtener los resultados
                Map<String, String> surveyValidate = VS_WSGeneralExperienceService.getSurveyValidate(surveyValidateData, answerIds);
                System.debug('respuestas' + surveyValidate);
                obj.PreguntasReto = surveyValidate.get('FullyApproval') == 'false' ? 'No paso filtro de codigo OTP ni preguntas Reto de Experian': surveyValidate.get('FullyApproval');
                lstOutput.add(obj);               
            }
            
            
        }
        System.debug('lstOutput FINAL--->'+lstOutput);
        return  lstOutput;     
    }
    
}