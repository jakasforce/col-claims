/**
* ===============================================================================================================================
* Developer:             VASS LATAM
* Creation Date:         24/08/2023
* Created by:            edwin.martinez@vasscompany.com
* Description:           This class encapsulates Experience services, including Registraduría, InitializeOTP, ValidateOTP,
*                        SurveyGenerate, SurveyValidate, IdentityValidate, and Listas Restrictivas.
*                        Provides methods to interact with various services for integration with COLMENA.
* Last Modified by:      edwin.martinez@vasscompany.com (04/09/2023)
* Version:               v1.0
* ===============================================================================================================================
**/

public class VS_WSGeneralExperienceService {
    //Nombre de los metadatos que contienen el endpoint para cada uno de los servicios
    public static String MDT_EDPOINREGISTRADURIA = 'Registraduria';
    public static String MDT_EDPOINOTP = 'IniciaOTP';
    public static String MDT_EDPOINVALIDAOTP = 'ValidaOTP';  
    public static String MDT_EDPOINTOKEN = 'Token_Colmena';
    public static String MDT_EDPOINSURVEYGENERATE = 'Experience_Survey_Generate';
    public static String MDT_EDPOINSURVEYVALIDATE = 'Experience_Survey_Validate';
    public static String MDT_EDPOINIDENTITYVALIDATE = 'Experience_Validate';
    public static String MDT_EDPOINLISTARESTRICTIVA = 'ListaRestrictiva';
    
    /**
* Realiza una llamada al servicio de Registraduría para obtener información.
* @param requestDataRegistraduria Los datos de solicitud para la consulta.
* @return Mapa con la respuesta del servicio y el indicador de éxito.
*/
    public static Map<String, String> getRegistraduria(requestRegistraduria requestDataRegistraduria) {
        // Crear un mapa para almacenar los resultados internos
        Map<String, String> internalResults = new Map<String, String>(); 
        
        try {

            System.debug('Entro a consumir registraduria');
            // Obtener el token de autenticación utilizando el método getToken
            String tokenResponse = VS_WSGeneralExperienceService.getToken();
            Map<String, Object> tokenJsonResponse = (Map<String, Object>) JSON.deserializeUntyped(tokenResponse);
            String accessToken = (String) tokenJsonResponse.get('access_token');
            
            // Obtener la configuración de llamada desde los metadatos personalizados
            VS_Callout_Configuration__mdt met = VS_Callout_Configuration__mdt.getInstance(MDT_EDPOINREGISTRADURIA);
            
            // Crear una instancia de la clase Http para hacer la solicitud
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            //Acceder a los campos de requestData para construir los parametros que se pasaran al servicio
            request.setEndpoint(met.Endpoint__c + '?typeId=' + requestDataRegistraduria.idType + '&id=' + requestDataRegistraduria.id + '&lastName=' + requestDataRegistraduria.lastName);
            request.setMethod('GET');
            //request.setHeader('Content-Type', 'application/json');
            //request.setHeader('grant_type', 'CLIENT_CREDENTIALS');
            request.setHeader('Authorization', 'Bearer ' + accessToken); // Agregar el token en los headers
            request.setHeader('client_id', met.Client_Id__c);
            request.setHeader('client_secret', met.Client_Secret__c);
            System.debug('request--->'+request);
            System.debug('request--->'+request.getEndpoint());
            System.debug('request client_id--->'+request.getHeader('client_id'));
            System.debug('request client_secret--->'+request.getHeader('client_secret'));
            System.debug('request- Authorization -->'+request.getHeader('Authorization'));
            
            // Enviar la solicitud y obtener la respuesta
            HttpResponse response = http.send(request);
            System.debug('response--->'+response);
            system.debug('@@@@@@: ' + response.getBody());
            
            if (response.getStatusCode() == 200) {                
                // Deserializar el JSON de la respuesta en una lista de mapas de objetos
                 System.debug('cuerpooo: ' + response.getBody());
                List<Object> jsonDataList = (List<Object>) JSON.deserializeUntyped(response.getBody());
                
                // Validar el valor de 'state' y establecer 'isValid' en el mapa de respuesta
                Map<String, Object> jsonData = (Map<String, Object>) jsonDataList[0];
                requestDataRegistraduria.statement = (Map<String, Object>) jsonData.get('statement');
                requestDataRegistraduria.naturalNational = (Map<String, Object>) requestDataRegistraduria.statement.get('naturalNational');
                requestDataRegistraduria.idDetails = (Map<String, Object>) requestDataRegistraduria.naturalNational.get('idDetails');
                requestDataRegistraduria.state = (String) requestDataRegistraduria.idDetails.get('state');
				
                // Validar el valor de 'state' y establecer 'isValid' para saber si es una persona fallecida
                if(requestDataRegistraduria.state == '21'){
                    // Almacenar la respuesta y establecer el indicador de éxito en el mapa
                    internalResults.put('serviceResponse', JSON.serialize(jsonDataList)); 
                    internalResults.put('successful', 'true');
                    internalResults.put('isValid', 'false');
                    internalResults.put('failureTrace', 'Se finaliza proceso por fallo de registraduria');                   
                }else{
                    internalResults.put('serviceResponse', JSON.serialize(jsonDataList)); 
                    internalResults.put('successful', 'true');
                    internalResults.put('isValid', 'true'); 
                }
            } else {
                // Si no se recibe un código de estado 200, indicar un fallo en el servicio
                internalResults.put('serviceResponse', 'Fallo el servicio');
                internalResults.put('successful', 'false');
            }
        } catch (Exception e) {
            // Capturar cualquier excepción que ocurra durante el proceso y manejarla
            internalResults.put('serviceResponse', 'Error en la llamada al servicio: ' + e.getMessage());
            system.debug('linea79' + e.getLineNumber());
            internalResults.put('successful', 'false');
        }
        // Devolver el mapa con los resultados internos
        return internalResults;
    }
    /**
* Valida la identidad de una persona utilizando el servicio correspondiente.
* @param requestDataIdentityValidate Datos necesarios para validar la identidad.
* @return Mapa con la respuesta de la validación de identidad y el indicador de éxito.
*/
    public static Map<String, String> getIdentityValidate(requestIdentityValidate requestDataIdentityValidate) {
        // Crear un mapa para almacenar los resultados internos de la validación de identidad
        Map<String, String> internalResultsIdentityValidate = new Map<String, String>();
        
        try {
            // Obtener el token de autenticación utilizando el método getToken
            String tokenResponse = VS_WSGeneralExperienceService.getToken();
            Map<String, Object> tokenJsonResponse = (Map<String, Object>) JSON.deserializeUntyped(tokenResponse);
            String accessToken = (String) tokenJsonResponse.get('access_token');
            
            // Obtener la configuración de llamada desde los metadatos personalizados
            VS_Callout_Configuration__mdt met = VS_Callout_Configuration__mdt.getInstance(MDT_EDPOINIDENTITYVALIDATE);
            
            // Acceder a los campos de requestData para construir los parametros que se pasaran al servicio
            String FirstName = requestDataIdentityValidate.FirstName;
            String SecondLastName = requestDataIdentityValidate.SecondLastName;
            String LastName = requestDataIdentityValidate.LastName;
            String ExpeditionDate = requestDataIdentityValidate.ExpeditionDate; // Fecha de expedicion en el siguiente formato "ddMMyyyyHHmm" (03052000)
            String Typ_e = requestDataIdentityValidate.Typ_e; //Tipo de documento (Cedula, NIT, Pasaporte)
            String Numb_er = requestDataIdentityValidate.Numbe_r; //Número de identificacion
            Boolean ForceOTP = requestDataIdentityValidate.ForceOTP; //Para generacion de OTP se debe pasar en true, cuando es para la generacion de preguntas pasar como false.
            
            // Crear una instancia de la clase Http y HttpRequest para la solicitud POST
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            // Construir la URL de la solicitud con los parametros necesarios
            request.setEndpoint(met.Endpoint__c);
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('grant_type', 'CLIENT_CREDENTIALS');
            request.setHeader('Authorization', 'Bearer ' + accessToken); // Agregar el token en los headers
            request.setHeader('client_id', met.Client_Id__c);
            request.setHeader('client_secret', met.Client_Secret__c);
            request.setBody('{"DataValidation":{"Person":{"FirstName":"' + FirstName + '","SecondLastName":"' + SecondLastName + '","LastName":"' + LastName + '","Identification":{"ExpeditionDate":"' + ExpeditionDate + '","Type":"' + Typ_e + '","Number":"' + Numb_er + '"}},"ForceOTP":' + ForceOTP + '}}');
            System.debug('BodydeIncialOTP--->'+request.getBody());
            // Enviar la solicitud y obtener la respuesta
            HttpResponse response = http.send(request);
            System.debug('response.getBody--->'+response.getBody());
            if (response.getStatusCode() == 200) {
                // Parsear la respuesta como un JSON directamente
                Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                // Almacenar la respuesta y establecer el indicador de éxito en el mapa
                internalResultsIdentityValidate.put('serviceResponseIdentityValidate', JSON.serialize(jsonResponse));
                internalResultsIdentityValidate.put('successful', 'true');
                // Obtener el valor de ValidationRegistry y guardarlo en una clave del mapa
                requestDataIdentityValidate.ValidationRegistry = (String) jsonResponse.get('ValidationRegistry');
                internalResultsIdentityValidate.put('ValidationRegistry', requestDataIdentityValidate.ValidationRegistry);
            } else {
                // Si no se recibe un código de estado 200, indicar un fallo en el servicio
                
                internalResultsIdentityValidate.put('serviceResponseIdentityValidate', 'Fallo el servicio');
                internalResultsIdentityValidate.put('successful', 'false');
            }
        } catch (Exception e) {
            // Capturar cualquier excepción que ocurra durante el proceso y manejarla
            internalResultsIdentityValidate.put('serviceResponseIdentityValidate', 'Error en la llamada al servicio: ' + e.getMessage());
            internalResultsIdentityValidate.put('successful', 'false');
        }
        
        // Devolver el mapa con los resultados internos de la validación de identidad
        System.debug('internalResultsIdentityValidate--->'+internalResultsIdentityValidate);
        return internalResultsIdentityValidate;
    }
    
    /**
* Inicia una transacción OTP (One-Time Password) utilizando el servicio correspondiente.
* @param requestDataIniciaOTP Datos necesarios para iniciar la transacción.
* @return Mapa con la respuesta de la transacción OTP y el indicador de éxito.
*/
    public static Map<String, String> getIniciarOTP(requestIniciaOTP requestDataIniciaOTP) {
        // Crear un mapa para almacenar los resultados internos de la transacción OTP
        Map<String, String> internalResultsOTP = new Map<String, String>();  
        
        try {
            // Obtener el token de autenticación utilizando el método getToken
            String tokenResponse = VS_WSGeneralExperienceService.getToken();
            Map<String, Object> tokenJsonResponse = (Map<String, Object>) JSON.deserializeUntyped(tokenResponse);
            String accessToken = (String) tokenJsonResponse.get('access_token');
            System.debug('Tercer Control');
            // Obtener la configuración de llamada desde los metadatos personalizados
            VS_Callout_Configuration__mdt met = VS_Callout_Configuration__mdt.getInstance(MDT_EDPOINOTP);
            System.debug('Cuarto control-->'+met);
            
            // Acceder a los campos de requestData para construir los parametros que se pasaran al servicio
            String NIT = '800226175'; //NIT COLMENA;
            String Numb_er = requestDataIniciaOTP.Numb_er; //Número de identificacion
            String valRegistry = requestDataIniciaOTP.ValidationRegistry; // ValidationRegistry
            String PhoneNum = requestDataIniciaOTP.PhoneNum; //Número de telefono
            
            String Typ_e = requestDataIniciaOTP.Typ_e; //Tipo de documento (Cedula, NIT, Pasaporte)
                    
            // Crear una instancia de la clase Http y HttpRequest para la solicitud POST
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            // Construir la URL de la solicitud con los parametros necesarios
            request.setEndpoint(met.Endpoint__c);
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('grant_type', 'CLIENT_CREDENTIALS');
            request.setHeader('Authorization', 'Bearer ' + accessToken); // Agregar el token en los headers
            request.setHeader('client_id', met.Client_Id__c);
            request.setHeader('client_secret', met.Client_Secret__c);
            request.setBody('{"XmlInitializeOTPTransaction":{"InitializeOTPTransactionRequest":{"Nit":"' + NIT + '","Identification":{"Number":"' + Numb_er + '","Type":"' + Typ_e + '"},"SurveyData":{"ValidationRegistry":"' + valRegistry + '","EvidenteProcess":"VALDCN"},"Person":{"PhoneNum":"' + PhoneNum + '"}}}}');          
            System.debug('request Envio de OTP--->'+request.getBody());
            // Enviar la solicitud y obtener la respuesta
            HttpResponse response = http.send(request);
            System.debug('response Envio de OTP---->'+response.getBody());
            
            if (response.getStatusCode() == 200) {
                // Parsear la respuesta como un JSON directamente
                Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                
                // Obtener el valor de ResultCode, TransactionId y guardarlo en una clave del mapa
                requestDataIniciaOTP.GenerationResult = (Map<String, Object>) jsonResponse.get('GenerationResult');
                requestDataIniciaOTP.OTP = (Map<String, Object>) requestDataIniciaOTP.GenerationResult.get('OTP');
                requestDataIniciaOTP.ResultCode = (String) requestDataIniciaOTP.OTP.get('ResultCode');
                requestDataIniciaOTP.TransactionId = (String) requestDataIniciaOTP.OTP.get('TransactionId'); 
                internalResultsOTP.put('ResultCode', requestDataIniciaOTP.ResultCode);
                internalResultsOTP.put('TransactionId', requestDataIniciaOTP.TransactionId);

                // Almacenar la respuesta y establecer el indicador de éxito en el mapa
                internalResultsOTP.put('serviceResponseOTP', JSON.serialize(jsonResponse));
                internalResultsOTP.put('successful', 'true');
                internalResultsOTP.put('ResultCode', requestDataIniciaOTP.ResultCode);
                internalResultsOTP.put('TransactionId', requestDataIniciaOTP.TransactionId);
            } else {
                // Si no se recibe un código de estado 200, indicar un fallo en el servicio
                internalResultsOTP.put('serviceResponseOTP', 'Fallo el servicio');
                internalResultsOTP.put('successful', 'false');
            }
        } catch (Exception e) {
            // Capturar cualquier excepción que ocurra durante el proceso y manejarla
            internalResultsOTP.put('serviceResponseOTP', 'Error en la llamada al servicio: ' + e.getMessage());
            internalResultsOTP.put('successful', 'false');
        }
        // Devolver el mapa con los resultados internos de la transacción OTP
        return internalResultsOTP;
    }
    /**
* Valida un código OTP utilizando el servicio correspondiente.
* @param requestDataValidaOTP Datos necesarios para validar el código OTP.
* @return Mapa con la respuesta de la validación OTP y el indicador de éxito.
*/
    public static Map<String, String> getValidaOTP(requestValidaOTP requestDataValidaOTP) {
        // Crear un mapa para almacenar los resultados internos de la validación OTP
        Map<String, String> internalResultsValidaOTP = new Map<String, String>();
        
        try {
            // Obtener el token de autenticación utilizando el método getToken
            String tokenResponse = VS_WSGeneralExperienceService.getToken();
            Map<String, Object> tokenJsonResponse = (Map<String, Object>) JSON.deserializeUntyped(tokenResponse);
            String accessToken = (String) tokenJsonResponse.get('access_token');
            
            // Obtener la configuración de llamada desde los metadatos personalizados
            VS_Callout_Configuration__mdt met = VS_Callout_Configuration__mdt.getInstance(MDT_EDPOINVALIDAOTP);
            
            // Acceder a los campos de requestData para construir los parametros que se pasaran al servicio
            String valRegistry = requestDataValidaOTP.ValidationRegistry; // ValidationRegistry
            String Numb_er = requestDataValidaOTP.Numb_er; //Número de identificacion
            String codeOTP = requestDataValidaOTP.Code;   //Codigo OTP Generado 
            String TransactionId = requestDataValidaOTP.TransactionId; //ID de la transaccion
            String Typ_e = requestDataValidaOTP.Typ_e; //Tipo de documento (Cedula, NIT, Pasaporte)

            // Crear una instancia de la clase Http y HttpRequest para la solicitud POST
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            // Construir la URL de la solicitud con los parametros necesarios
            request.setEndpoint(met.Endpoint__c);
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('grant_type', 'CLIENT_CREDENTIALS');
            request.setHeader('Authorization', 'Bearer ' + accessToken); // Agregar el token en los headers
            request.setHeader('client_id', met.Client_Id__c);
            request.setHeader('client_secret', met.Client_Secret__c);
            request.setBody('{"XmlInitializeOTPTransaction":{"ValidateOTPCodeRequest":{"SurveyData":{"ValidationRegistry":"' + valRegistry + '","EvidenteProcess":"VALDCN"},"Identification":{"Number":"' + Numb_er + '","Type":"' + Typ_e + '"},"OTP":{"Code":"' + codeOTP + '","TransactionId":"' + TransactionId + '"}}}}');          
            // Enviar la solicitud y obtener la respuesta
            System.debug('----->Request validacion opt '+JSON.serializePretty(request.getBody()));
            HttpResponse response = http.send(request);
            System.debug('Response validateOTP 1'+response);
            System.debug('Response validateOTP'+response.getBody());
            
            if (response.getStatusCode() == 200) {
                System.debug('FUNCIONO VALIDACION OTP');
                // Parsear la respuesta como un JSON directamente
                Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                // Almacenar la respuesta y establecer el indicador de éxito en el mapa
                internalResultsValidaOTP.put('serviceResponseValidaOTP', JSON.serialize(jsonResponse));
                internalResultsValidaOTP.put('successful', 'true');
                // Obtener el valor de ValidCode y guardarlo en una clave del mapa
                requestDataValidaOTP.ValidateOTPCodeResponse = (Map<String, Object>) jsonResponse.get('ValidateOTPCodeResponse');
                requestDataValidaOTP.ValidCode = (String) requestDataValidaOTP.ValidateOTPCodeResponse.get('ValidCode');
                internalResultsValidaOTP.put('ValidCode', requestDataValidaOTP.ValidCode);
            } else {
                // Si no se recibe un código de estado 200, indicar un fallo en el servicio
                internalResultsValidaOTP.put('serviceResponseValidaOTP', 'Fallo el servicio');
                internalResultsValidaOTP.put('successful', 'false');
            }
        } catch (Exception e) {
            // Capturar cualquier excepción que ocurra durante el proceso y manejarla
            internalResultsValidaOTP.put('serviceResponseValidaOTP', 'Error en la llamada al servicio: ' + e.getMessage());
            internalResultsValidaOTP.put('successful', 'false');
        }   
        // Devolver el mapa con los resultados internos de la validación OTP
        return internalResultsValidaOTP;
    }
    /**
* Obtiene el token de autenticación necesario para las llamadas a los servicios.
* @return Cadena JSON que contiene el token y su información.
*/
    public static String getToken() {
        try {
            // Obtener la configuración de llamada desde los metadatos personalizados
            VS_Callout_Configuration__mdt met = VS_Callout_Configuration__mdt.getInstance(MDT_EDPOINTOKEN);
            
            // Crear una instancia de la clase Http y HttpRequest para la solicitud POST
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            // Construir la URL de la solicitud con los parametros necesarios
            request.setEndpoint(met.Endpoint__c);
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('grant_type', 'CLIENT_CREDENTIALS');
            request.setHeader('client_id', met.Client_Id__c);
            request.setHeader('client_secret', met.Client_Secret__c);
            
            // Enviar la solicitud y obtener la respuesta
            HttpResponse response = http.send(request);
            System.debug('token--->'+response.getBody());
            if (response.getStatusCode() == 200) {
                // Parsear la respuesta como un JSON y extraer los valores necesarios
                Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                String accessToken = (String) jsonResponse.get('access_token');
                String tokenType = (String) jsonResponse.get('token_type');
                Integer expiresIn = (Integer) jsonResponse.get('expires_in');
                
                // Construir una cadena JSON con la información del token
                String jsonResponseString = '{"access_token":"' + accessToken + '","token_type":"' + tokenType + '","expires_in":' + expiresIn + '}';
                // Devolver la cadena JSON con la información del token
                return jsonResponseString;
            } else {
                // Si no se recibe un código de estado 200, devolver un mensaje de fallo
                return '{"serviceResponse":"Fallo el servicio","successful":"false"}';
            }
        } catch (Exception e) {
            // Capturar cualquier excepción que ocurra durante el proceso y manejarla
            return '{"serviceResponse":"Error en la llamada al servicio: ' + e.getMessage() + '","successful":"false"}';
        }
    }
    /**
* Genera una encuesta utilizando el servicio correspondiente.
* @param requestDataSurveyGenerate Datos necesarios para generar la encuesta.
* @return Mapa con la respuesta de la generación de la encuesta y el indicador de éxito.
*/
    public static Map<String, Object> getSurveyGenerate(requestSurveyGenerate requestDataSurveyGenerate) {
        // Crear un mapa para almacenar los resultados internos de la generación de la encuesta
        Map<String, Object> internalResultsurveyGenerate = new Map<String, Object>();
        
        try {
            // Obtener el token de autenticación utilizando el método getToken
            String tokenResponse = VS_WSGeneralExperienceService.getToken();
            Map<String, Object> tokenJsonResponse = (Map<String, Object>) JSON.deserializeUntyped(tokenResponse);
            String accessToken = (String) tokenJsonResponse.get('access_token');
            
            // Obtener la configuración de llamada desde los metadatos personalizados
            VS_Callout_Configuration__mdt met = VS_Callout_Configuration__mdt.getInstance(MDT_EDPOINSURVEYGENERATE);
            
            // Acceder a los campos de requestData para construir los parametros que se pasaran al servicio
            String valRegistry = requestDataSurveyGenerate.ValidationRegistry; // ValidationRegistry
            String Numb_er = requestDataSurveyGenerate.Numb_er; //Número de telefono
            String Typ_e = requestDataSurveyGenerate.Typ_e; //Tipo de documento (Cedula, NIT, Pasaporte)
            
            // Crear una instancia de la clase Http y HttpRequest para la solicitud POST
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            // Construir la URL de la solicitud con los parametros necesarios
            request.setEndpoint(met.Endpoint__c);
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('grant_type', 'CLIENT_CREDENTIALS');
            request.setHeader('Authorization', 'Bearer ' + accessToken); // Agregar el token en los headers
            request.setHeader('client_id', met.Client_Id__c);
            request.setHeader('client_secret', met.Client_Secret__c);
            request.setBody('{"SurveyRequest":{"Identification":{"Number":"' + Numb_er + '","Type":"' + Typ_e + '"},"ValidationRegistry":"' + valRegistry + '"}}');
            System.debug('Envio de request preguntas Reto--->'+request.getBody());
            // Enviar la solicitud y obtener la respuesta
            HttpResponse response = http.send(request);
            System.debug('Response Preguntas reto'+ response.getBody());
            
            if (response.getStatusCode() == 200) {
                // Parsear la respuesta como un JSON directamente
                Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                system.debug('respuesta servicio   '+jsonResponse);
                //
                requestDataSurveyGenerate.surveyData = (Map<String, Object>) jsonResponse.get('SurveyData');
                requestDataSurveyGenerate.IdSurvey = (String) requestDataSurveyGenerate.surveyData.get('Id');
                requestDataSurveyGenerate.Registry = (String) requestDataSurveyGenerate.surveyData.get('Registry');
                
                // Almacenar la respuesta y establecer el indicador de éxito en el mapa
                internalResultsurveyGenerate.put('serviceResponseSurveyGenerate', JSON.serialize(jsonResponse));
                internalResultsurveyGenerate.put('successful', 'true');
                // Obtener la lista de preguntas (Questions) dentro de "SurveyData"
                List<Object> questionsResponse = (List<Object>) ((Map<String, Object>) jsonResponse.get('SurveyData')).get('Question');
                
                // Listas para almacenar preguntas y respuestas
                List<String> questions = new List<String>();
                List<List<String>> answersList = new List<List<String>>();
                List<String> answers = new List<String>();
                List<String> answers2 = new List<String>();
                List<String> answers3 = new List<String>();
                List<String> answers4 = new List<String>();
                
                // Verificar si questionsResponse no es nulo antes de iterar sobre él
                if (questionsResponse != null) {
                    for (Object questionObj : questionsResponse) {
                        Map<String, Object> question = (Map<String, Object>) questionObj;
                        String textQuestion = (String) question.get('Text');
                        String orderId = (String) question.get('Order'); // Obtener el order de la pregunta
                        
                        questions.add(textQuestion);
                        
                        List<Object> answersResponse = (List<Object>) question.get('Answer');
                        List<String> answerTextList = new List<String>();
                        
                        // Iterar sobre las respuestas y extraer la información
                        for (Object answerObj : answersResponse) {
                            Map<String, Object> answer = (Map<String, Object>) answerObj;
                            String textAnswer = (String) answer.get('Text');
                            String answerId = (String) answer.get('Id'); // Obtener el Id de la respuesta
                            
                            answerTextList.add(/*answerId*/ + ' ' + textAnswer);
                            
                            // Almacenar respuestas en listas separadas para cada pregunta
                            if (questions.size() == 1) {
                                answers.add(/*answerId*/ + ' ' + textAnswer);
                            } else if (questions.size() == 2) {
                                answers2.add(/*answerId*/ + ' ' + textAnswer);
                            } else if (questions.size() == 3) {
                                answers3.add(/*answerId*/ + ' ' + textAnswer);
                            } else if (questions.size() == 4) {
                                answers4.add(/*answerId*/ + ' ' + textAnswer);
                            }

                        }       
                        system.debug(answerTextList);
                        answersList.add(answerTextList);
                    }
                } else {
                    System.debug('No se encontraron preguntas en la respuesta.');
                }
                // Almacenar las listas de preguntas y respuestas en el mapa de resultados internos
                internalResultsurveyGenerate.put('Questions', questions);
                internalResultsurveyGenerate.put('Answers', answersList);
                internalResultsurveyGenerate.put('IdSurvey', requestDataSurveyGenerate.IdSurvey);
                internalResultsurveyGenerate.put('Registry', requestDataSurveyGenerate.Registry);
            } else {
                // Si no se recibe un código de estado 200, indicar un fallo en el servicio
                internalResultsurveyGenerate.put('serviceResponseSurveyGenerate', 'Fallo el servicio');
                internalResultsurveyGenerate.put('successful', 'false');
            }
        } catch (Exception e) {
            // Capturar cualquier excepción que ocurra durante el proceso y manejarla
            internalResultsurveyGenerate.put('serviceResponseSurveyGenerate', 'Error en la llamada al servicio: ' + e.getMessage());
            internalResultsurveyGenerate.put('successful', 'false');
        }
        // Devolver el mapa con los resultados internos de la generación de la encuesta
        return internalResultsurveyGenerate;
    }

    /**
* Valida una encuesta utilizando el servicio correspondiente.
* @param requestDataSurveyValidate Datos necesarios para validar la encuesta.
* @return Mapa con la respuesta de la validación de la encuesta y el indicador de éxito.
*/
    public static Map<String, String> getSurveyValidate(requestSurveyValidate requestDataSurveyValidate, List<String> answerIds) {
        // Crear un mapa para almacenar los resultados internos de la validación de la encuesta
        Map<String, String> internalResultsurveyValidate = new Map<String, String>();
        
        try {
            // Obtener el token de autenticación utilizando el método getToken
            String tokenResponse = VS_WSGeneralExperienceService.getToken();
            Map<String, Object> tokenJsonResponse = (Map<String, Object>) JSON.deserializeUntyped(tokenResponse);
            String accessToken = (String) tokenJsonResponse.get('access_token');
            
            // Obtener la configuración de llamada desde los metadatos personalizados
            VS_Callout_Configuration__mdt met = VS_Callout_Configuration__mdt.getInstance(MDT_EDPOINSURVEYVALIDATE);
            
            // Acceder a los campos de requestData para construir los parametros que se pasarán al servicio
            String Registry = requestDataSurveyValidate.Registry; // Registry de la encuesta
            String idSurvey = requestDataSurveyValidate.Id; //Id de la encuesta 
            String Typ_e = requestDataSurveyValidate.Typ_e; //Tipo de documento (Cedula, NIT, Pasaporte)
            String Numb_er = requestDataSurveyValidate.Numb_er; //Número de identificacion
            
            // Crear una instancia de la clase Http y HttpRequest para la solicitud POST
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            // Construir la URL de la solicitud con los parametros necesarios
            request.setEndpoint(met.Endpoint__c);
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('grant_type', 'CLIENT_CREDENTIALS');
            request.setHeader('Authorization', 'Bearer ' + accessToken); // Agregar el token en los headers
            request.setHeader('client_id', met.Client_Id__c);
            request.setHeader('client_secret', met.Client_Secret__c);
            
            // Construir el cuerpo del request utilizando las variables
            String requestBody = '{"Answers":{"SurveyData":{"Id":"' + idSurvey + '","Registry":"' + Registry + '"},"Identification":{"Number":"' + Numb_er + '","Type":"' + Typ_e + '"},"Answer":[{"QuestionId":"1","AnswerId":"00' + answerIds[0] + '"},{"QuestionId":"2","AnswerId":"00' + answerIds[1] + '"},{"QuestionId":"3","AnswerId":"00' + answerIds[2] + '"},{"QuestionId":"4","AnswerId":"00' + answerIds[3] + '"}]}}';
            System.debug('requestBody Validarte request-->'+requestBody);
            request.setBody(requestBody);
            
            // Enviar la solicitud y obtener la respuesta
            HttpResponse response = http.send(request);
            
            if (response.getStatusCode() == 200) {
                // Parsear la respuesta como un JSON directamente
                Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                //
                requestDataSurveyValidate.Evaluation = (Map<String, Object>) jsonResponse.get('Evaluation');
                requestDataSurveyValidate.FullyApproval = (String) requestDataSurveyValidate.Evaluation.get('FullyApproval');
                // Almacenar la respuesta y establecer el indicador de éxito en el mapa
                internalResultsurveyValidate.put('serviceResponseSurveyValidate', JSON.serialize(jsonResponse));
                internalResultsurveyValidate.put('successful', 'true');
                internalResultsurveyValidate.put('FullyApproval', requestDataSurveyValidate.FullyApproval);
            } else {
                // Si no se recibe un código de estado 200, indicar un fallo en el servicio
                internalResultsurveyValidate.put('serviceResponseSurveyValidate', 'Fallo el servicio');
                internalResultsurveyValidate.put('successful', 'false');
            }
        } catch (Exception e) {
            // Capturar cualquier excepción que ocurra durante el proceso y manejarla
            internalResultsurveyValidate.put('serviceResponseSurveyValidate', 'Error en la llamada al servicio: ' + e.getMessage());
            internalResultsurveyValidate.put('successful', 'false');
        }
        // Devolver el mapa con los resultados internos de la validación de la encuesta
        return internalResultsurveyValidate;
    }

    /**
* Realiza una llamada al servicio de Lista Restrictiva con los datos proporcionados.
* @param requestDataListaRestrictiva Los datos de la solicitud de Lista Restrictiva.
* @return Un mapa que contiene los resultados de la transacción.
*/
    public static Map<String, String> getListaRestrictiva(requestListaRestrictiva requestDataListaRestrictiva) {
        Map<String, String> ResultsListaRestrictiva = new Map<String, String>();  
        
        try {
            // Obtener el token de autenticación utilizando el método getToken
            String tokenResponse = VS_WSGeneralExperienceService.getToken();
            Map<String, Object> tokenJsonResponse = (Map<String, Object>) JSON.deserializeUntyped(tokenResponse);
            String accessToken = (String) tokenJsonResponse.get('access_token');
            
            // Obtener la configuración de llamada desde los metadatos personalizados
            VS_Callout_Configuration__mdt met = VS_Callout_Configuration__mdt.getInstance(MDT_EDPOINLISTARESTRICTIVA);
            
            // Acceder a los campos de requestData para construir los parámetros que se pasarán al servicio
            String Numbe_r = requestDataListaRestrictiva.Numbe_r; //Número de identificacion
            String FirstName = requestDataListaRestrictiva.FirstName;
            String MiddleName = requestDataListaRestrictiva.MiddleName;
            String LastName = requestDataListaRestrictiva.LastName;
            String SecondLastName = requestDataListaRestrictiva.SecondLastName;
            
            // Crear una instancia de la clase Http y HttpRequest para la solicitud POST
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            // Construir la URL de la solicitud con los parámetros necesarios
            request.setEndpoint(met.Endpoint__c);
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('grant_type', 'CLIENT_CREDENTIALS');
            request.setHeader('Authorization', 'Bearer ' + accessToken); // Agregar el token en los headers
            request.setHeader('client_id', met.Client_Id__c);
            request.setHeader('client_secret', met.Client_Secret__c);
            // Ajustar el tiempo (120,000 milisegundos)
            request.setTimeout(120000);
            request.setBody('{"Applicant":{"Identification":{"Number":"' + Numbe_r + '"},"Person":{"FirstName":"' + FirstName + '","MiddleName":"' + MiddleName + '","LastName":"' + LastName + '","SecondLastName":"' + SecondLastName + '"}}}');
            
            // Enviar la solicitud y obtener la respuesta
            HttpResponse response = http.send(request);
            // Imprimir el contenido del cuerpo de la solicitud
            System.debug('Cuerpo de la solicitud: ' + request.getBody());
            
            if (response.getStatusCode() == 200) {
                // Parsear la respuesta como un JSON directamente
                Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());           
                ResultsListaRestrictiva.put('ResponseListaRestrictiva', JSON.serialize(jsonResponse));             
                // Agregar emptyLists para indicar si el nodo "Lists" está vacío o es nulo
                if (jsonResponse.containsKey('Lists') && jsonResponse.get('Lists') != null && !((List<Object>)jsonResponse.get('Lists')).isEmpty()) {
                    System.debug('1---');
                    ResultsListaRestrictiva.put('ResponseListaRestrictiva', JSON.serialize(jsonResponse));
                    ResultsListaRestrictiva.put('emptyLists', 'true');
                    ResultsListaRestrictiva.put('failureTrace', 'Se finaliza proceso por fallo de Lista restrictivas');
                } else {
                    System.debug('2---');
                    ResultsListaRestrictiva.put('ResponseListaRestrictiva', JSON.serialize(jsonResponse));
                    ResultsListaRestrictiva.put('emptyLists', 'false');
                }             
                // Agregar successful para indicar el estado general de la llamada
                ResultsListaRestrictiva.put('successful', 'true');
            } else {
                // Si no se recibe un código de estado 200, indicar un fallo en el servicio
                ResultsListaRestrictiva.put('ResponseListaRestrictiva', 'Fallo el servicio');
                ResultsListaRestrictiva.put('successful', 'false');
            }
        } catch (Exception e) {
            // Capturar excepciones
            ResultsListaRestrictiva.put('ResponseListaRestrictiva', 'Error en la llamada al servicio: ' + e.getMessage());
            ResultsListaRestrictiva.put('successful', 'false');
        }
        // Devolver el mapa con los resultados internos de la transacción Lista Restrictiva
        return ResultsListaRestrictiva;
    }
    
    //Clases internas de solicitud definidas dentro de VS_WSGeneralExperienceService
    
    public class requestRegistraduria {
        //Variables correspondientes al JSON de la respuesta del servicio Registraduria
        
        //Statement 
        public Map<String, Object> statement { get; set; }
        public DateTime dateOfQuery { get; set; }
        public String response { get; set; }
        public String securityCode { get; set; }
        public String idType { get; set; }
        public String id { get; set; }
        public String lastName { get; set; }
        public Map<String, Object> naturalNational { get; set; }
        
        //NaturalNational 
        public String name { get; set; }
        public String firstLastName { get; set; }
        public String secondLastName { get; set; }
        public String fullName { get; set; }
        public Boolean isValid { get; set; }
        public Boolean rut { get; set; }
        public Map<String, Object> idDetails { get; set; }
        public Map<String, Object> age { get; set; }
        
        //IdDetails 
        public String state { get; set; }
        public String expeditionDate { get; set; }
        public String city { get; set; }
        public String colony { get; set; }
        public String numbe_r { get; set; }
        
        //Age 
        public String min { get; set; }
        public String max { get; set; }    
    }
    
    public class requestIniciaOTP{
        
        //Variables correspondientes al JSON de la respuesta del servicio IniciaOTP
        
        //ValidationResult 
        public String ValidNumber { get; set; }
        public String ReconocerRanking { get; set; }
        
        //GenerationResult 
		Map<String, Object> GenerationResult = new Map<String, Object>();
        public String SurveyRequired { get; set; }
        
        //OTP 
		Map<String, Object> OTP = new Map<String, Object>();
        public String Timestamp { get; set; }
        public String ResultCode { get; set; }
        public String TransactionId { get; set; }
        public String Result { get; set; }
        
        //Variables correspondientes al JSON request 
        //NIT
        public String NIT { get; set; }   
        
        //Identification 
        public String Numb_er { get; set; }
        public String Typ_e { get; set; }
        
        //SurveyData 
        public String ValidationRegistry { get; set; }
        public String EvidenteProcess { get; set; }
        
        //Person 
        public String PhoneNum { get; set; }        
    }
    
    public class requestvalidaOTP{
        
        //Variables correspondientes al JSON de la respuesta del servicio validaOTP  
        
        //ValidateOTPCodeResponse 
        Map<String, Object> ValidateOTPCodeResponse = new Map<String, Object>();
        public String ValidationResult { get; set; }
        public String ParameterizationCode { get; set; }
        public String ValidationMessage { get; set; }
        public String ValidCode { get; set; }
        
        //Variables correspondientes al JSON request  
        
        //SurveyData 
        public String ValidationRegistry { get; set; }
        public String EvidenteProcess { get; set; }
        
        //Identification 
        public String Numb_er { get; set; }
        public String Typ_e { get; set; }
        
        //OTP 
        public String Code { get; set; }
        public String TransactionId { get; set; }        
    }
    
    public class requestGetToken{
        
        //Variables correspondientes al JSON de la respuesta del servicio del Token
        
        public String access_token { get; set; }
        public String token_type { get; set; }
        public Integer expires_in { get; set; }
    }
    
    public class requestSurveyGenerate{
        //Variables correspondientes al JSON de la respuesta del servicio SurveyGenerate
        
        Map<String, Object> surveyData = new Map<String, Object>();
        
        //SurveyData 
        public String IdSurvey { get; set; }
        public Map<String, Object> Alerts { get; set; }
        public String ExcludeClient { get; set; }
        public String Registry { get; set; }
        public String Result { get; set; }
        public List<Map<String, Object>> Questions { get; set; }
        
        //Alerts 
        public String Alert { get; set; }
        public String Code { get; set; }
        public String Response { get; set; }
        
        //Question 
        //public String Id { get; set; }
        public String QuestionId { get; set; }
        public String TextQuestion { get; set; }
        public String Order { get; set; }
        public String CorrectAnswerId { get; set; }
        public String Weight { get; set; }
        public List<Map<String, Object>> Answer { get; set; }
        
        //Answer 
        public String IdAnswer { get; set; }
        public String TextAnswer { get; set; }
        
        //Variables correspondientes al JSON request
        
        public String IdUserEntity { get; set; }
        public String Channel { get; set; }
        public String ParameterizationCode { get; set; }
        public String Product { get; set; }
        
        //SurveyRequest 
        //Identification
        public String Numb_er { get; set; }
        public String Typ_e { get; set; }
        
        // Constructor
        public requestSurveyGenerate() {
            questions = new List<Map<String, Object>>();
            answersList = new List<List<String>>();
        }

        // Nuevas propiedades para almacenar las preguntas y respuestas
        public List<String> questionss { get; set; }
        public List<List<String>> answersList { get; set; }
        
        public String ValidationRegistry { get; set; }       
    }
    
    public class requestSurveyValidate { 
        //Variables correspondientes al JSON de la respuesta del servicio SurveyValidate
        
        //Evaluation 
        public Map<String, Object> Evaluation { get; set; }
        public String Result { get; set; }
        public String Approval { get; set; }
        public String CompleteSurvey { get; set; }
        public String Score { get; set; }
        public String SecurityCode { get; set; }
        public Map<String, Object> SurveyData { get; set; }
        public String FullyApproval { get; set; }
        
        //SurveyData 
        public String Id { get; set; }
        public String Registry { get; set; }
        
        //Variables correspondientes al JSON request
        
        public String idUsuarioEntidad { get; set; }
        public String ParameterizationCode { get; set; }
        public String Product { get; set; }
        
        //Identification
        public String Numb_er { get; set; }
        public String Typ_e { get; set; }
        
        //Answer
        public List<Map<String, Object>> Answer { get; set; }
        // Propiedades para QuestionId y AnswerId individuales
        public String QuestionId { get; set; }
        public String AnswerId { get; set; }
        
        // Método para construir las respuestas dinámicamente
        public List<Map<String, Object>> buildAnswerList(List<List<String>> questionAnswerPairs) {
            List<Map<String, Object>> answerList = new List<Map<String, Object>>();
            for (List<String> pair : questionAnswerPairs) {
                String questionId = pair[0];
                String answerId = pair[1];
                answerList.add(new Map<String, Object>{'QuestionId' => questionId, 'AnswerId' => answerId});
            }
            return answerList;
        }
    }
    
    public class requestIdentityValidate{
        //Variables correspondientes al JSON de la respuesta del servicio IdentityValidate
        
        public Map<String, Object> Validations { get; set; }
        public String ExcludeClient { get; set; }
        public Map<String, Object> Alerts { get; set; }
        public String Result { get; set; }
        public String ValidationRegistry { get; set; }
        public String ProcessResult { get; set; }
        public Integer AvailableQueries { get; set; }
        public Map<String, Object> Person { get; set; }
        
        //Validations 
        public String ValidLastName { get; set; }
        public String ValidName { get; set; }
        public String ValidExpeditionDate { get; set; }
        
        //Alerts 
        public String Alert { get; set; }
        public String AlertResponse { get; set; }
        public String AlertCode { get; set; }
        
        //Person
        //Identification  
        public String Numbe_r { get; set; }
        public String Typ_e { get; set; }
        public String ExpeditionDate { get; set; }
        public Map<String, Object> Identification { get; set; }
        public String FullName { get; set; } 
        
        //Variables correspondientes al JSON request
        
        //DataValidation
        //Person
        public String FirstName { get; set; }
        public String SecondLastName { get; set; }
        public String LastName { get; set; }
        
        //ForceOTP
        public Boolean ForceOTP { get; set; }
    } 
    public class requestListaRestrictiva{
        
        //Variables correspondientes al JSON de la respuesta del servicio check_bls
        
        //Applicant 
        //Identification 
        public String Numbe_r { get; set; }
        
        //Person 
        public String FirstName { get; set; }
        public String MiddleName { get; set; }
        public String LastName { get; set; }
        public String SecondLastName { get; set; }
        
        //Variables correspondientes al JSON request 
        
        public String Matches { get; set; }
        public String QueryNumber { get; set; }
        
        //Lists 
        public Map<String, Object> Lists { get; set; }
        //public List<Map<String, Object>> Lists { get; set; }
        public String IdList { get; set; }
        public String Priority { get; set; }
        public String ListType { get; set; }
        
        //Identification
        public String Typ_e { get; set; }
        public String Numb_er { get; set; }
        
        public String FullName { get; set; }
        public String IdListType { get; set; }
        
    }
}