/**
* ===============================================================================================================================
* Developer:             VASS LATAM
* Creation Date:         15/09/2023
* Created by:            edwin.martinez@vasscompany.com
* Description:           This is the test class that covers the method of the AccountValidateChatbot Apex class.
* Last Modified by:      edwin.martinez@vasscompany.com (19/09/2023)
* Version:               v1.0
* ===============================================================================================================================
**/
@IsTest
public class AccountValidateChatbot_Test {
    // Método para creacion de los Mucks
    private class HTTPMockFactory implements HttpCalloutMock {
        protected Integer code;
        protected String status;
        protected String body;
        protected Map<String, String> responseHeaders;
        public HTTPMockFactory(
            Integer code,
            String status,
            String body,
            Map<String, String> responseHeaders
        ) {
            this.code = code;
            this.status = status;
            this.body = body;
            this.responseHeaders = responseHeaders;
        }
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            for (String key : this.responseHeaders.keySet()) {
                res.setHeader(key, this.responseHeaders.get(key));
            }
            res.setBody(this.body);
            res.setStatusCode(this.code);
            res.setStatus(this.status);
            return res;
        }
    }
    // Método para crear un Lead de prueba
    static Account crearAcc() {
        Account newAcc = new Account(
            FirstName = 'Edwin',
            MiddleName = 'Camilo',
            Suffix = 'Merchan',
            LastName = 'Martinez',
            CS_TipoIdentificacionCP__pc = '1',
            CS_NumeroIdentificacionCP__pc = '1010137397',
            PersonMobilePhone = '6014585858',
            PersonEmail = 'Pruebas@gmail.com'
        );
        
        insert newAcc;
        return newAcc;
    }
    
    @IsTest
    static void testListaExito() {
        
        Account accountR = crearAcc();
        
        // Crear una lista de input
        List<AccountValidateChatbot.ChatBotTempInput> inputList = new List<AccountValidateChatbot.ChatBotTempInput>();
        
        // Crear una instancia de ChatBotTempInput para simular los datos de entrada
        AccountValidateChatbot.ChatBotTempInput input = new AccountValidateChatbot.ChatBotTempInput();
        //valores de input 
        input.City = accountR.id;
        input.FechaExpedicionDocumento = '04072018';
        input.PrimeraInteraccion = 'si';
        
        // Crear mocks condicionales para los servicios
        HTTPMockFactory mockListarestrictiva = new HTTPMockFactory(
            200, 'OK', '{"Matches":"true","QueryNumber":"6765436","Lists":[{"IdList":5115069,"Priority":"1","ListType":"Perú- Contribuyentes en condición No Hallados y No Habidos SUNAT","Identification":{"Type":"RUC","Number":"10062699260"},"FullName":"SALDIVAR FLORES JESSICA MARIA","IdListType":123}]}', new Map<String, String>()
        );
        Test.setMock(HttpCalloutMock.class, mockListarestrictiva);
        
        // verificación antes de llamar al método ValidacionIdentidad
        if (input.City != null) {
            inputList.add(input);
        }
        
        // Verificar que haya al menos un objeto en inputList antes de llamar al método
        // Método ValidacionIdentidad del controlador
        Test.startTest();
        List<AccountValidateChatbot.ChatBotTempOutput> result = AccountValidateChatbot.ValidacionIdentidad(inputList);
        Test.stopTest();
        system.debug('resulttest ' + result);
        // Asegurar que las respuestas simuladas hayan sido procesadas adecuadamente
        System.assertEquals(1, result.size());
    }
    
    @IsTest
    static void testListaRegistraduriafalla() {
        
        Account accountR = crearAcc();
        
        // Crear una lista de input
        List<AccountValidateChatbot.ChatBotTempInput> inputList = new List<AccountValidateChatbot.ChatBotTempInput>();
        
        // Crear una instancia de ChatBotTempInput para simular los datos de entrada
        AccountValidateChatbot.ChatBotTempInput input = new AccountValidateChatbot.ChatBotTempInput();
        //valores de input
        input.City = accountR.id;
        input.FechaExpedicionDocumento = '04072018';
        input.PrimeraInteraccion = 'si';
        
        // Crear mocks condicionales para los servicios
        HTTPMockFactory mockListarestrictivaPaso = new HTTPMockFactory(
            200, 'OK', '{"Matches":false,"QueryNumber":262090,"Lists":[]}', new Map<String, String>()
        );
        Test.setMock(HttpCalloutMock.class, mockListarestrictivaPaso);
        
        // verificación antes de llamar al método ValidacionIdentidad
        if (input.City != null) {
            inputList.add(input);
        }
        
        // Verificar que haya al menos un objeto en inputList antes de llamar al método
        // Método ValidacionIdentidad del controlador
        Test.startTest();
        List<AccountValidateChatbot.ChatBotTempOutput> result = AccountValidateChatbot.ValidacionIdentidad(inputList);
        Test.stopTest();
        system.debug('resulttest ' + result);
        // Asegurar que las respuestas simuladas hayan sido procesadas adecuadamente
        System.assertEquals(1, result.size());
    }
    
    @IsTest
    static void testOTPExito() {
        
        Account accountR = crearAcc();
        
        // Crear una lista de input
        List<AccountValidateChatbot.ChatBotTempInput> inputList = new List<AccountValidateChatbot.ChatBotTempInput>();
        
        // Crear una instancia de ChatBotTempInput para simular los datos de entrada
        AccountValidateChatbot.ChatBotTempInput input = new AccountValidateChatbot.ChatBotTempInput();
        //valores de input 
        input.City = accountR.id;
        input.IniciaOTPRequest = 'si';
        input.FechaExpedicionDocumento = '27012021';
        //-------------------------------------------------
        input.CodigoOTP = '0';
        input.ValidaOTPResponse = '0';
        input.PreguntaRetoGenerateRequest = '0';
        input.PreguntaRetoValidateRequest = '0' ;
        input.answer = '0';
        input.answer2 = '0';
        input.answer3 ='0';
        input.answer4 = '0';
        // input.PrimeraInteraccion = '0';
        input.IdSurvey = '0';
        input.validationRegistry = '0' ;
        input.Registry = '0';
        input.ResultCode = '0';  
        input.TransactionId = '0';
        
   
        
        HTTPMockFactory mockIniciarOTP = new HTTPMockFactory(
            200, 'OK', '{"ValidateOTPCodeResponse":{"ValidationResult":"8","ParameterizationCode":"","ValidationMessage":"Transaccion invalidada por verificacion adicional.","ValidCode":true,"OTP":{"TransactionId":"f2e8faef-d259-4882-a15d-81d7824a128f"}}}', new Map<String, String>()
        );

        // Configurar los mocks condicionales según las condiciones de prueba
        
        Test.setMock(HttpCalloutMock.class, mockIniciarOTP);
        
        //verificación antes de llamar al método ValidacionIdentidad
        if (input.City != null) {
            inputList.add(input);
        }
        
        // Verificar que haya al menos un objeto en inputList antes de llamar al método
        // Método ValidacionIdentidad del controlador
        Test.startTest();
        List<AccountValidateChatbot.ChatBotTempOutput> result = AccountValidateChatbot.ValidacionIdentidad(inputList);
        Test.stopTest();
        system.debug('resulttest ' + result);
        // Asegurar que las respuestas simuladas hayan sido procesadas adecuadamente
        //System.assertEquals(2, result.size());
    }
    
    @IsTest
    static void testOTPFallo() {
        
        Account accountR = crearAcc();
        
        // Crear una lista de input
        List<AccountValidateChatbot.ChatBotTempInput> inputList = new List<AccountValidateChatbot.ChatBotTempInput>();
        
        // Crear una instancia de ChatBotTempInput para simular los datos de entrada
        AccountValidateChatbot.ChatBotTempInput input = new AccountValidateChatbot.ChatBotTempInput();
        //valores de input
        input.City = accountR.id;
        input.CodigoOTP = '123456';
        input.FechaExpedicionDocumento = '04072018';
        input.IdSurvey = 'Survey123';
        input.Registry = 'Registro123';
        input.ResultCode = 'Result123';
        input.validationRegistry = '232';
        input.IniciaOTPRequest = 'si';
        
        
        HTTPMockFactory mockIniciarOTP = new HTTPMockFactory(
            200, 'OK', '{"ParameterizationCode":"","ValidationResult":{"ValidNumber":"","ReconocerRanking":""},"GenerationResult":{"SurveyRequired":"","OTP":{"Timestamp":"","ResultCode":"7","TransactionId":"","Result":"false"}},"SurveyData":{"EvidenteProcess":""}}', new Map<String, String>()
        );
        
        // Configurar los mocks condicionales según las condiciones de prueba
        
        Test.setMock(HttpCalloutMock.class, mockIniciarOTP);
        
        // verificación antes de llamar al método ValidacionIdentidad
        if (input.City != null) {
            inputList.add(input);
        }
        
        // Verificar que haya al menos un objeto en inputList antes de llamar al método
        // Método ValidacionIdentidad del controlador
        Test.startTest();
        List<AccountValidateChatbot.ChatBotTempOutput> result = AccountValidateChatbot.ValidacionIdentidad(inputList);
        Test.stopTest();
        system.debug('resulttest ' + result);
        // Asegurar que las respuestas simuladas hayan sido procesadas adecuadamente
        //System.assertEquals(2, result.size());
    }
    
    @IsTest
    static void testValidaOTPExito() {
        
        Account accountR = crearAcc();
        
        // Crear una lista de input
        List<AccountValidateChatbot.ChatBotTempInput> inputList = new List<AccountValidateChatbot.ChatBotTempInput>();
        
        // Crear una instancia de ChatBotTempInput para simular los datos de entrada
        AccountValidateChatbot.ChatBotTempInput input = new AccountValidateChatbot.ChatBotTempInput();
        //valores de input 
        input.City = accountR.id;
        input.CodigoOTP = '123456';
        input.FechaExpedicionDocumento = '04072018';
        input.IdSurvey = 'Survey123';
        input.Registry = 'Registro123';
        input.ResultCode = 'Result123';
        input.TransactionId = 'Transaction123';
        input.validationRegistry = '232';
        input.ValidaOTPResponse = 'si';
        
        // Crear mocks condicionales para los servicios
        HTTPMockFactory mockValidaOTP = new HTTPMockFactory(
            200, 'OK', '{"ValidateOTPCodeResponse":{"ValidationResult":null,"ParameterizationCode":null,"ValidationMessage":null,"ValidCode":null,"OTP":{"TransactionId":null}}}', new Map<String, String>()
        );
        Test.setMock(HttpCalloutMock.class, mockValidaOTP);
        
        // verificación antes de llamar al método ValidacionIdentidad
        if (input.City != null) {
            inputList.add(input);
        }
        
        // Verificar que haya al menos un objeto en inputList antes de llamar al método
        // Método ValidacionIdentidad del controlador
        Test.startTest();
        List<AccountValidateChatbot.ChatBotTempOutput> result = AccountValidateChatbot.ValidacionIdentidad(inputList);
        Test.stopTest();
        system.debug('resulttest ' + result);
        // Asegurar que las respuestas simuladas hayan sido procesadas adecuadamente
        System.assertEquals(1, result.size());
    }   
    
    @IsTest
    static void testPreguntaRetoGenerate() {
        
        Account accountR = crearAcc();
        
        // Crear una lista de input
        List<AccountValidateChatbot.ChatBotTempInput> inputList = new List<AccountValidateChatbot.ChatBotTempInput>();
        
        // Crear una instancia de ChatBotTempInput para simular los datos de entrada
        AccountValidateChatbot.ChatBotTempInput input = new AccountValidateChatbot.ChatBotTempInput();
        //valores de input
        input.City = accountR.id;
        input.CodigoOTP = '123456';
        input.FechaExpedicionDocumento = '04072018';
        input.IdSurvey = 'Survey123';
        input.Registry = 'Registro123';
        input.ResultCode = 'Result123';
        input.TransactionId = 'Transaction123';
        input.validationRegistry = '232';
        input.PreguntaRetoGenerateRequest = 'si';
        input.answer = 'Answer1';
        input.answer2 = 'Answer2';
        input.answer3 = 'Answer3';
        input.answer4 = 'Answer4';
 
        // Crear mocks condicionales para los servicios
        HTTPMockFactory mockPreguntaRetoGenerate = new HTTPMockFactory(
            200, 'OK', '{"SurveyData":{"Id":"","Alerts":{"Alert":"false","Code":"","Response":""},"ExcludeClient":"false","Registry":"4512616","Result":"02","Question":[{"Id":"005003003","Text":"CON CUAL DE LAS SIGUIENTES ENTIDADES USTED TIENE O HA TENIDO EN LOS ULTIMOS 5 AÑOS (ENTRE NOVIEMBRE DE 2016 Y OCTUBRE DE 2021) UN/UNA CREDITO DE VIVIENDA  ?","Order":"1","CorrectAnswerId":"00","Weight":"3","Answer":[{"Id":"001","Text":"BANCO AV VILLAS S.A."},{"Id":"002","Text":"BANCO GNB SUDAMERIS S A"},{"Id":"003","Text":"BANCO DE BOGOTA S. A."},{"Id":"004","Text":"COMFAMA - CAJA DE COMPENSACION"},{"Id":"005","Text":"BANCO DAVIVIENDA S.A."},{"Id":"006","Text":"NINGUNA DE LAS ANTERIORES"}]},{"Id":"005013001","Text":"EL VALOR DE LA CUOTA DE AGOSTO DE 2021 DE SU CREDITO ROTATIVO CON BANCO COLPATRIA MULTIBANCA COLPATRIA S.A. ESTABA ENTRE:","Order":"2","CorrectAnswerId":"00","Weight":"3","Answer":[{"Id":"001","Text":"$30,001 Y $89,000"},{"Id":"002","Text":"$89,001 Y $148,000"},{"Id":"003","Text":"$148,001 Y $207,000"},{"Id":"004","Text":"$207,001 Y $266,000"},{"Id":"005","Text":"$266,001 Y $325,000"},{"Id":"006","Text":"NO TENGO CREDITO ROTATIVO CON LA ENTIDAD"}]}]}}', new Map<String, String>()
        );

        Test.setMock(HttpCalloutMock.class, mockPreguntaRetoGenerate);
        
        //verificación antes de llamar al método ValidacionIdentidad
        if (input.City != null) {
            inputList.add(input);
        }
        
        
        // Método ValidacionIdentidad del controlador
        Test.startTest();
        List<AccountValidateChatbot.ChatBotTempOutput> result = AccountValidateChatbot.ValidacionIdentidad(inputList);
        Test.stopTest();
        system.debug('resulttest ' + result);
        // Asegurar que las respuestas simuladas hayan sido procesadas adecuadamente
        System.assertEquals(1, result.size());
    }
    
    @IsTest
    static void testPreguntaRetoValidate() {
        
        Account accountR = crearAcc();
        
        // Crear una lista de input
        List<AccountValidateChatbot.ChatBotTempInput> inputList = new List<AccountValidateChatbot.ChatBotTempInput>();
        
        // Crear una instancia de ChatBotTempInput para simular los datos de entrada
        AccountValidateChatbot.ChatBotTempInput input = new AccountValidateChatbot.ChatBotTempInput();
        //valores de input 
        input.City = accountR.id;
        input.CodigoOTP = '123456';
        input.FechaExpedicionDocumento = '04072018';
        input.IdSurvey = 'Survey123';
        input.Registry = 'Registro123';
        input.ResultCode = 'Result123';
        input.TransactionId = 'Transaction123';
        input.validationRegistry = '232';
        input.PreguntaRetoGenerateRequest = 'si';
        input.PreguntaRetoValidateRequest = 'si';
        input.answer = 'Answer1';
        input.answer2 = 'Answer2';
        input.answer3 = 'Answer3';
        input.answer4 = 'Answer4';
        
        // Crear mocks condicionales para los servicios
        HTTPMockFactory mockPreguntaRetoValidate = new HTTPMockFactory(
            200, 'OK', '{"Evaluation":{"Result":null,"Approval":null,"CompleteSurvey":null,"Score":null,"SecurityCode":null,"SurveyData":{"Id":null,"Registry":null},"FullyApproval":null}}', new Map<String, String>()
        );
        Test.setMock(HttpCalloutMock.class, mockPreguntaRetoValidate);
        
        //Verificación antes de llamar al método ValidacionIdentidad
        if (input.City != null) {
            inputList.add(input);
        }
        
      
        // Método ValidacionIdentidad del controlador
        Test.startTest();
        List<AccountValidateChatbot.ChatBotTempOutput> result = AccountValidateChatbot.ValidacionIdentidad(inputList);
        Test.stopTest();
        system.debug('resulttest ' + result);
        // Asegurar que las respuestas simuladas hayan sido procesadas adecuadamente
        System.assertEquals(1, result.size());
    }
    
    @IsTest
    static void testRegistraduriaExito() {
        
        Account accountR = crearAcc();
        
        // Crear una lista de input
        List<AccountValidateChatbot.ChatBotTempInput> inputList = new List<AccountValidateChatbot.ChatBotTempInput>();
        
        // Crear una instancia de ChatBotTempInput para simular los datos de entrada
        AccountValidateChatbot.ChatBotTempInput input = new AccountValidateChatbot.ChatBotTempInput();
        input.City = accountR.id;
        input.PrimeraInteraccion = 'si';
        
        HTTPMockFactory mockRegistraduria = new HTTPMockFactory(
            200, 'OK', '[{"statement":{"naturalNational":{"age":{"max":"28","min":"22"},"idDetails":{"number":"01010137397","colony":"BOYACA","city":"NUEVO COLON","expeditionDate":"2018-07-04","state":"00"},"rut":false,"isValid":true,"fullName":"MARTINEZ MERCHAN EDWIN CAMILO","secondLastName":"MERCHAN","firstLastName":"MARTINEZ","name":"EDWIN CAMILO"},"lastName":"MARTINEZ","id":"1010137397","idType":"1","securityCode":"PZ17336","response":"14","dateOfQuery":"2023-08-27T21:05:04"}}]', new Map<String, String>()
        );
        
        Test.setMock(HttpCalloutMock.class, mockRegistraduria);
        
        // verificación antes de llamar al método ValidacionIdentidad
        if (input.City != null) {
            inputList.add(input);
        }
        
        // Método ValidacionIdentidad del controlador
        Test.startTest();
        List<AccountValidateChatbot.ChatBotTempOutput> result = AccountValidateChatbot.ValidacionIdentidad(inputList);
        Test.stopTest();
        system.debug('resulttest ' + result);
        // Asegurar que las respuestas simuladas hayan sido procesadas adecuadamente
        System.assertEquals(1, result.size());
    }
    
    @IsTest
    static void testValidaOTPFallo() {
        
        Account accountR = crearAcc();
        
        // Crear una lista de input
        List<AccountValidateChatbot.ChatBotTempInput> inputList = new List<AccountValidateChatbot.ChatBotTempInput>();
        
        // Crear una instancia de ChatBotTempInput para simular los datos de entrada
        AccountValidateChatbot.ChatBotTempInput input = new AccountValidateChatbot.ChatBotTempInput();
        input.City = accountR.id;
        input.ValidaOTPResponse = 'si';
        
        // Crear mocks condicionales para los servicios
        HTTPMockFactory mockValidaOTP = new HTTPMockFactory(
            200, 'OK', '{"ValidateOTPCodeResponse":{"ValidationResult":"8","ParameterizationCode":"","ValidationMessage":"Transaccion invalidada por verificacion adicional.","ValidCode":"false","OTP":{"TransactionId":""}}}', new Map<String, String>()
        );

        Test.setMock(HttpCalloutMock.class, mockValidaOTP);
        
        // verificación antes de llamar al método ValidacionIdentidad
        if (input.City != null) {
            inputList.add(input);
        }
        
        // Método ValidacionIdentidad del controlador
        Test.startTest();
        List<AccountValidateChatbot.ChatBotTempOutput> result = AccountValidateChatbot.ValidacionIdentidad(inputList);
        Test.stopTest();
        system.debug('resulttest ' + result);
        // Asegurar que las respuestas simuladas hayan sido procesadas adecuadamente
        System.assertEquals(1, result.size());
    }  
    
    @IsTest
    static void testValidaOTPFalloCode() {
        Account accountR = crearAcc();
        
        // Crear una lista de input
        List<AccountValidateChatbot.ChatBotTempInput> inputList = new List<AccountValidateChatbot.ChatBotTempInput>();
        
        // Crear una instancia de ChatBotTempInput para simular los datos de entrada
        AccountValidateChatbot.ChatBotTempInput input = new AccountValidateChatbot.ChatBotTempInput();
        input.City = accountR.id;
        input.ValidaOTPResponse = 'si';
        
        // Crear mocks condicionales para los servicios
        HTTPMockFactory mockValidaOTP = new HTTPMockFactory(
            200, 'OK', '{"ValidateOTPCodeResponse":{"ValidationResult":"4","ParameterizationCode":"","ValidationMessage":"Transaccion exitosa","ValidCode":"true","OTP":{"TransactionId":"rwerwer"}}}', new Map<String, String>()
        );
        
        Test.setMock(HttpCalloutMock.class, mockValidaOTP);
        
        //verificación antes de llamar al método ValidacionIdentidad
        if (input.City != null) {
            inputList.add(input);
        }
        
        // Método ValidacionIdentidad del controlador
        Test.startTest();
        List<AccountValidateChatbot.ChatBotTempOutput> result = AccountValidateChatbot.ValidacionIdentidad(inputList);
        Test.stopTest();
        system.debug('resulttest ' + result);
        // Asegurar que las respuestas simuladas hayan sido procesadas adecuadamente
        System.assertEquals(1, result.size());
    }  
    
    @IsTest
    static void testValidaIdentidad() {
        // Crear datos de prueba 
        Account accountR = crearAcc();
        
        // Crear una lista de input
        List<AccountValidateChatbot.ChatBotTempInput> inputList = new List<AccountValidateChatbot.ChatBotTempInput>();
        
        // Crear una instancia de ChatBotTempInput para simular los datos de entrada
        AccountValidateChatbot.ChatBotTempInput input = new AccountValidateChatbot.ChatBotTempInput();
        //valores de input
        input.City = accountR.id;
        input.CodigoOTP = '123456';
        input.FechaExpedicionDocumento = '04072018';
        input.IdSurvey = 'Survey123';
        input.Registry = 'Registro123';
        input.ResultCode = 'Result123';
        input.TransactionId = 'Transaction123';
        input.validationRegistry = '232';
        input.ValidaOTPResponse = 'si';
        
        // Crear mocks condicionales para los servicios
        HTTPMockFactory mockValidaIdentidad = new HTTPMockFactory(
            200, 'OK', '{"Validations":{"ValidLastName":"false","ValidName":"false","ValidExpeditionDate":"true"},"ExcludeClient":"false","Alerts":{"Alert":"false","AlertResponse":"03","AlertCode":"00"},"Result":"06","ValidationRegistry":"7199521","ProcessResult":"true","AvailableQueries":"0","Person":{"Identification":{"Number":"01010137397","Type":"1","ExpeditionDate":"1530662400000"},"FullName":"MARTINEZ MERCHAN EDWIN CAMILO"}}', new Map<String, String>()
        );

        Test.setMock(HttpCalloutMock.class, mockValidaIdentidad);
        
        //verificación antes de llamar al método ValidacionIdentidad
        if (input.City != null) {
            inputList.add(input);
        }
        
        // Verificar que haya al menos un objeto en inputList antes de llamar al método
        // Método ValidacionIdentidad del controlador
        Test.startTest();
        List<AccountValidateChatbot.ChatBotTempOutput> result = AccountValidateChatbot.ValidacionIdentidad(inputList);
        Test.stopTest();
        system.debug('resulttest ' + result);
        // Asegurar que las respuestas simuladas hayan sido procesadas adecuadamente
        System.assertEquals(1, result.size());
    }   
}