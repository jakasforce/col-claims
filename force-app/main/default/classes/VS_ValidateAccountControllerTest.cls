@isTest
public class VS_ValidateAccountControllerTest {
    @isTest
    static void testExistingGetAccountIdWithLog() {
        Account acc = new Account();
        acc.CS_TipoIdentificacionCP__pc = '1';
        acc.CS_NumeroIdentificacionCP__pc = '1007389654';
        acc.CS_FechaExpedicion__pc = Date.valueOf('2018-06-26');
        acc.LastName = 'Account Test';
        acc.Suffix = 'Test';
        acc.FirstName = 'Account';
        acc.PersonMobilePhone = '1111111111';
        acc.Fecha_Ultima_Validacion_Cliente__c = DateTime.now();
        acc.CC_Tipo_de_Cuenta__c = 'Cuenta Prospecto';
        insert acc;

        // Crear datos de prueba para Task
        Task taskRecord = new Task();
        // Asigna valores a los campos relevantes del registro de Task
        taskRecord.Agrupacion__c = 'Información General';
        taskRecord.Razon__c = 'Cancelación de titulos';
        taskRecord.Tipo_de_llamada__c = 'Entrante';
        //taskRecord.AccountId = acc.Id;
        taskRecord.WhatId = acc.Id;
        insert taskRecord;
        
        Relacion_Tarea_Historial_Validacion__c auxRel = new Relacion_Tarea_Historial_Validacion__c();
        auxRel.Name = 'Relación Tarea - Historiales';        
        insert auxRel;
        
        Historial_de_Validacion__c history = new Historial_de_Validacion__c();
        history.Estado__c = 'Exitoso';
        history.Mensaje__c = 'test';
        history.Tipo__c = 'Registraduría';
        history.Tipo_de_identificacion__c = acc.CS_TipoIdentificacionCP__pc;
        history.Numero_de_identificacion__c = acc.CS_NumeroIdentificacionCP__pc;
        
        history.Relacion_Tarea_Historial_Validacion__c = auxRel.Id;
        history.Cuenta__c  = acc.Id;
        
        insert history;
        
        taskRecord.Relacion_Tarea_Historial_Validacion__c = auxRel.Id;
        update taskRecord;
        
        String accountId = VS_ValidateAccountController.getAccountId(taskRecord.Id);
        System.assertEquals(taskRecord.WhatId, accountId, 'Validación de cuenta incorrecta');
    }
    
    @isTest
    static void testInsertLog() {
        Account acc = new Account();
        acc.CS_TipoIdentificacionCP__pc = '1';
        acc.CS_NumeroIdentificacionCP__pc = '1007389654';
        acc.CS_FechaExpedicion__pc = Date.valueOf('2018-06-26');
        acc.LastName = 'Account Test';
        acc.Suffix = 'Test';
        acc.FirstName = 'Account';
        acc.PersonMobilePhone = '1111111111';
        acc.Fecha_Ultima_Validacion_Cliente__c = DateTime.now();
        acc.CC_Tipo_de_Cuenta__c = 'Cuenta Prospecto';
        insert acc;

        // Crear datos de prueba para Task
        Task taskRecord = new Task();
        // Asigna valores a los campos relevantes del registro de Task
        taskRecord.Agrupacion__c = 'Información General';
        taskRecord.Razon__c = 'Cancelación de titulos';
        taskRecord.Tipo_de_llamada__c = 'Entrante';
        //taskRecord.AccountId = acc.Id;
        taskRecord.WhatId = acc.Id;
        insert taskRecord;
        
        
        VS_ValidateAccountController.DtoResponse response = VS_ValidateAccountController.insertLogValidation(taskRecord.Id, 'Exitoso', 'test', 'Registraduría', acc.CS_TipoIdentificacionCP__pc,  acc.CS_NumeroIdentificacionCP__pc);
        System.assertEquals(response.successful, true, 'El log no fue creado correctamente');
    }
    
    
	@isTest
    static void testExistingGetAccountId() {
        // Crear datos de prueba para Task
        Task taskRecord = new Task();
        // Asigna valores a los campos relevantes del registro de Task
        taskRecord.Agrupacion__c = 'Información General';
        taskRecord.Razon__c = 'Cancelación de titulos';
        taskRecord.Tipo_de_llamada__c = 'Entrante';
        insert taskRecord;
        
        String accountId = VS_ValidateAccountController.getAccountId(taskRecord.Id);
        System.assertEquals(null, accountId, 'Validación de cuenta incorrecta.');
    }
    
    @isTest
    static void testNotExistingGetAccountId() {
        Id accountId = VS_ValidateAccountController.getAccountId('');
        System.assertEquals(null, accountId);
    }
    
    /*@isTest
    static void testValidatedgetQuestions() {
        Account acc = new Account();
        acc.CS_TipoIdentificacionCP__pc = '1';
        acc.CS_NumeroIdentificacionCP__pc = '1007389654';
        acc.CS_FechaExpedicion__pc = Date.valueOf('2018-06-26');
        acc.LastName = 'Account Test';
        acc.Suffix = 'Test';
        acc.FirstName = 'Account';
        acc.PersonMobilePhone = '1111111111';
        acc.Fecha_Ultima_Validacion_Cliente__c = DateTime.now();
        insert acc;
        
        VS_ValidateAccountController.dtoResponse res = VS_ValidateAccountController.getQuestions('task', acc.Id);
        System.assertEquals(res.successful, true);
    }*/
    
    @isTest
    static void testGetQuestions() {
        Account acc = new Account();
        acc.CS_TipoIdentificacionCP__pc = '1';
        acc.CS_NumeroIdentificacionCP__pc = '1007389654';
        acc.CS_FechaExpedicion__pc = Date.valueOf('2018-06-26');
        acc.LastName = 'Account Test';
        acc.Suffix = 'Test';
        acc.FirstName = 'Account';
        acc.PersonMobilePhone = '1111111111';
        
        insert acc;
        
        Test.startTest();
        
        VS_ValidateAccountController.isCuentaProspecto(acc.Id);
        
        String body = '{"access_token":"valor_del_access_token","token_type":"valor_del_token_type","expires_in":3600}';
        Test.setMock(HttpCalloutMock.class, new VS_WSAuthenticationGetTokenTest.MockHttpResponseGenerator(200, body));
        VS_ValidateAccountController.dtoResponse res = VS_ValidateAccountController.getQuestions('task', acc.Id);
        
        body = '{"Validations":{"ValidLastName":"true","ValidName":"true","ValidExpeditionDate":"true"},"ExcludeClient":"false","Alerts":{"Alert":"false","AlertResponse":"03","AlertCode":"00"},"Result":"01","ValidationRegistry":"6306411","ProcessResult":"true","AvailableQueries":"1","Person":{"Identification":{"Number":"00000000000","Type":"1","ExpeditionDate":"123456700000"},"FullName":"AAAAA AAAAAAAA AAAAAAA"}}';
        Test.setMock(HttpCalloutMock.class, new VS_WSExperienceValidateTest.MockHttpResponseGenerator(200, body));
        VS_ValidateAccountController.dtoResponse resValidate = VS_ValidateAccountController.getQuestionsValidate('task', res.WSToken, res.accountList);
        
        body = '{"SurveyData":{"Id":"TestIdGenerate","Alerts":{"Alert":"false","Code":"","Response":""},"ExcludeClient":"false","Registry":"4512616","Result":"02","Question":[{"Id":"005003003","Text":"CON CUAL DE LAS SIGUIENTES ENTIDADES USTED TIENE O HA TENIDO EN LOS ULTIMOS 5 AÑOS (ENTRE NOVIEMBRE DE 2016 Y OCTUBRE DE 2021) UN/UNA CREDITO DE VIVIENDA  ?","Order":"1","CorrectAnswerId":"00","Weight":"3","Answer":[{"Id":"001","Text":"BANCO AV VILLAS S.A."},{"Id":"002","Text":"BANCO GNB SUDAMERIS S A"},{"Id":"003","Text":"BANCO DE BOGOTA S. A."},{"Id":"004","Text":"COMFAMA - CAJA DE COMPENSACION"},{"Id":"005","Text":"BANCO DAVIVIENDA S.A."},{"Id":"006","Text":"NINGUNA DE LAS ANTERIORES"}]},{"Id":"005013001","Text":"EL VALOR DE LA CUOTA DE AGOSTO DE 2021 DE SU CREDITO ROTATIVO CON BANCO COLPATRIA MULTIBANCA COLPATRIA S.A. ESTABA ENTRE:","Order":"2","CorrectAnswerId":"00","Weight":"3","Answer":[{"Id":"001","Text":"$30,001 Y $89,000"},{"Id":"002","Text":"$89,001 Y $148,000"},{"Id":"003","Text":"$148,001 Y $207,000"},{"Id":"004","Text":"$207,001 Y $266,000"},{"Id":"005","Text":"$266,001 Y $325,000"},{"Id":"006","Text":"NO TENGO CREDITO ROTATIVO CON LA ENTIDAD"}]},{"Id":"005006001","Text":"HACE CUANTO TIEMPO TIENE USTED UN/UNA CREDITO EDUCATIVO  CON ICETEX","Order":"3","CorrectAnswerId":"00","Weight":"4","Answer":[{"Id":"001","Text":"ENTRE 0 Y 3 AÑOS"},{"Id":"002","Text":"ENTRE 4 Y 7 AÑOS"},{"Id":"003","Text":"ENTRE 8 Y 12 AÑOS"},{"Id":"004","Text":"ENTRE 13 Y 16 AÑOS"},{"Id":"005","Text":"17 AÑOS O MAS"},{"Id":"006","Text":"NO TENGO CREDITO EDUCATIVO CON LA ENTIDAD"}]},{"Id":"005007002","Text":"HACE CUANTO TIEMPO TIENE SU CREDITO HIPOTECARIO CON BANCO COLPATRIA MULTIBANCA COLPATRIA S.A.?","Order":"4","CorrectAnswerId":"00","Weight":"1","Answer":[{"Id":"001","Text":"ENTRE 0 Y 2 AÑOS"},{"Id":"002","Text":"ENTRE 3 Y 4 AÑOS"},{"Id":"003","Text":"ENTRE 5 Y 7 AÑOS"},{"Id":"004","Text":"ENTRE 8 Y 14 AÑOS"},{"Id":"005","Text":"15 AÑOS O MAS"},{"Id":"006","Text":"NO TENGO CREDITO DE VIVIENDA CON LA ENTIDAD"}]}]}}';
        Test.setMock(HttpCalloutMock.class, new VS_WSExperienceSurveyGenerateTest.MockHttpResponseGenerator(200, body));
        VS_ValidateAccountController.dtoResponse resGenerate = VS_ValidateAccountController.getQuestionsgenerate('task', resValidate.WSToken, resValidate.accountList, resValidate.WSValidate);
        
        
        VS_ValidateAccountController.saveValidatedDateTime(acc.Id);
        Test.stopTest();
        
        System.assertEquals(true, resGenerate.successful);
    }
    
    @isTest
    static void testGetQuestionsNoToken() {
        Account acc = new Account();
        acc.CS_TipoIdentificacionCP__pc = '1';
        acc.CS_NumeroIdentificacionCP__pc = '1007389654';
        acc.CS_FechaExpedicion__pc = Date.valueOf('2018-06-26');
        acc.LastName = 'Account Test';
        acc.Suffix = 'Test';
        acc.FirstName = 'Account';
        acc.PersonMobilePhone = '1111111111';
        
        insert acc;
        
        Test.startTest();
        String body = '{"access_token":"valor_del_access_token","token_type":"valor_del_token_type","expires_in":3600}';
        Test.setMock(HttpCalloutMock.class, new VS_WSAuthenticationGetTokenTest.MockHttpResponseGenerator(400, body));
        VS_ValidateAccountController.dtoResponse res = VS_ValidateAccountController.getQuestions('task', acc.Id);
        
        
        VS_ValidateAccountController.saveValidatedDateTime(acc.Id);
        Test.stopTest();
        
        System.assertEquals(false, res.successful);
    }
    
    @isTest
    static void testGetQuestionsNoValidate() {
        Account acc = new Account();
        acc.CS_TipoIdentificacionCP__pc = '1';
        acc.CS_NumeroIdentificacionCP__pc = '1007389654';
        acc.CS_FechaExpedicion__pc = Date.valueOf('2018-06-26');
        acc.LastName = 'Account Test';
        acc.Suffix = 'Test';
        acc.FirstName = 'Account';
        acc.PersonMobilePhone = '1111111111';
        
        insert acc;
        
        Test.startTest();
        String body = '{"access_token":"valor_del_access_token","token_type":"valor_del_token_type","expires_in":3600}';
        Test.setMock(HttpCalloutMock.class, new VS_WSAuthenticationGetTokenTest.MockHttpResponseGenerator(200, body));
        VS_ValidateAccountController.dtoResponse res = VS_ValidateAccountController.getQuestions('task', acc.Id);
        
        body = '{"Validations":{"ValidLastName":"true","ValidName":"true","ValidExpeditionDate":"true"},"ExcludeClient":"false","Alerts":{"Alert":"false","AlertResponse":"03","AlertCode":"00"},"Result":"01","ValidationRegistry":"6306411","ProcessResult":"true","AvailableQueries":"1","Person":{"Identification":{"Number":"00000000000","Type":"1","ExpeditionDate":"123456700000"},"FullName":"AAAAA AAAAAAAA AAAAAAA"}}';
        Test.setMock(HttpCalloutMock.class, new VS_WSExperienceValidateTest.MockHttpResponseGenerator(400, body));
        VS_ValidateAccountController.dtoResponse resValidate = VS_ValidateAccountController.getQuestionsValidate('task', res.WSToken, res.accountList);
        
        
        VS_ValidateAccountController.saveValidatedDateTime(acc.Id);
        Test.stopTest();
        
        System.assertEquals(false, resValidate.successful);
    }
    
    
    @isTest
    static void testGetQuestionsNoGenerate() {
        Account acc = new Account();
        acc.CS_TipoIdentificacionCP__pc = '1';
        acc.CS_NumeroIdentificacionCP__pc = '1007389654';
        acc.CS_FechaExpedicion__pc = Date.valueOf('2018-06-26');
        acc.LastName = 'Account Test';
        acc.Suffix = 'Test';
        acc.FirstName = 'Account';
        acc.PersonMobilePhone = '1111111111';
        
        insert acc;
        
        Test.startTest();
        String body = '{"access_token":"valor_del_access_token","token_type":"valor_del_token_type","expires_in":3600}';
        Test.setMock(HttpCalloutMock.class, new VS_WSAuthenticationGetTokenTest.MockHttpResponseGenerator(200, body));
        VS_ValidateAccountController.dtoResponse res = VS_ValidateAccountController.getQuestions('task', acc.Id);
        
        body = '{"Validations":{"ValidLastName":"true","ValidName":"true","ValidExpeditionDate":"true"},"ExcludeClient":"false","Alerts":{"Alert":"false","AlertResponse":"03","AlertCode":"00"},"Result":"01","ValidationRegistry":"6306411","ProcessResult":"true","AvailableQueries":"1","Person":{"Identification":{"Number":"00000000000","Type":"1","ExpeditionDate":"123456700000"},"FullName":"AAAAA AAAAAAAA AAAAAAA"}}';
        Test.setMock(HttpCalloutMock.class, new VS_WSExperienceValidateTest.MockHttpResponseGenerator(200, body));
        VS_ValidateAccountController.dtoResponse resValidate = VS_ValidateAccountController.getQuestionsValidate('task', res.WSToken, res.accountList);
        
        body = '{"SurveyData":{"Id":"TestIdGenerate","Alerts":{"Alert":"false","Code":"","Response":""},"ExcludeClient":"false","Registry":"4512616","Result":"02","Question":[{"Id":"005003003","Text":"CON CUAL DE LAS SIGUIENTES ENTIDADES USTED TIENE O HA TENIDO EN LOS ULTIMOS 5 AÑOS (ENTRE NOVIEMBRE DE 2016 Y OCTUBRE DE 2021) UN/UNA CREDITO DE VIVIENDA  ?","Order":"1","CorrectAnswerId":"00","Weight":"3","Answer":[{"Id":"001","Text":"BANCO AV VILLAS S.A."},{"Id":"002","Text":"BANCO GNB SUDAMERIS S A"},{"Id":"003","Text":"BANCO DE BOGOTA S. A."},{"Id":"004","Text":"COMFAMA - CAJA DE COMPENSACION"},{"Id":"005","Text":"BANCO DAVIVIENDA S.A."},{"Id":"006","Text":"NINGUNA DE LAS ANTERIORES"}]},{"Id":"005013001","Text":"EL VALOR DE LA CUOTA DE AGOSTO DE 2021 DE SU CREDITO ROTATIVO CON BANCO COLPATRIA MULTIBANCA COLPATRIA S.A. ESTABA ENTRE:","Order":"2","CorrectAnswerId":"00","Weight":"3","Answer":[{"Id":"001","Text":"$30,001 Y $89,000"},{"Id":"002","Text":"$89,001 Y $148,000"},{"Id":"003","Text":"$148,001 Y $207,000"},{"Id":"004","Text":"$207,001 Y $266,000"},{"Id":"005","Text":"$266,001 Y $325,000"},{"Id":"006","Text":"NO TENGO CREDITO ROTATIVO CON LA ENTIDAD"}]},{"Id":"005006001","Text":"HACE CUANTO TIEMPO TIENE USTED UN/UNA CREDITO EDUCATIVO  CON ICETEX","Order":"3","CorrectAnswerId":"00","Weight":"4","Answer":[{"Id":"001","Text":"ENTRE 0 Y 3 AÑOS"},{"Id":"002","Text":"ENTRE 4 Y 7 AÑOS"},{"Id":"003","Text":"ENTRE 8 Y 12 AÑOS"},{"Id":"004","Text":"ENTRE 13 Y 16 AÑOS"},{"Id":"005","Text":"17 AÑOS O MAS"},{"Id":"006","Text":"NO TENGO CREDITO EDUCATIVO CON LA ENTIDAD"}]},{"Id":"005007002","Text":"HACE CUANTO TIEMPO TIENE SU CREDITO HIPOTECARIO CON BANCO COLPATRIA MULTIBANCA COLPATRIA S.A.?","Order":"4","CorrectAnswerId":"00","Weight":"1","Answer":[{"Id":"001","Text":"ENTRE 0 Y 2 AÑOS"},{"Id":"002","Text":"ENTRE 3 Y 4 AÑOS"},{"Id":"003","Text":"ENTRE 5 Y 7 AÑOS"},{"Id":"004","Text":"ENTRE 8 Y 14 AÑOS"},{"Id":"005","Text":"15 AÑOS O MAS"},{"Id":"006","Text":"NO TENGO CREDITO DE VIVIENDA CON LA ENTIDAD"}]}]';
        Test.setMock(HttpCalloutMock.class, new VS_WSExperienceSurveyGenerateTest.MockHttpResponseGenerator(400, body));
        VS_ValidateAccountController.dtoResponse resGenerate = VS_ValidateAccountController.getQuestionsgenerate('task', resValidate.WSToken, resValidate.accountList, resValidate.WSValidate);
        
        
        VS_ValidateAccountController.saveValidatedDateTime(acc.Id);
        Test.stopTest();
        
        System.assertEquals(false, resGenerate.successful);
    }
    
    @isTest
    static void testGetQuestionsNoAccount() {
        Test.startTest();
        
        VS_ValidateAccountController.dtoResponse res = VS_ValidateAccountController.getQuestions('task', '');
        
        Test.stopTest();
        
        System.assertNotEquals(null, res);
    }
    
    @isTest
    static void testValidateQuestions() {
        Account acc = new Account();
        acc.CS_TipoIdentificacionCP__pc = '1';
        acc.CS_NumeroIdentificacionCP__pc = '1007389654';
        acc.CS_FechaExpedicion__pc = Date.valueOf('2018-06-26');
        acc.LastName = 'Account Test';
        acc.Suffix = 'Test';
        acc.FirstName = 'Account';
        acc.PersonMobilePhone = '1111111111';
        
        insert acc;
        
        Test.startTest();
        string body = '{"Evaluation":{"Result":"true","Approval":"true","CompleteSurvey":"true","Score":"000","SecurityCode":"ZSU34E4","SurveyData":{"Id":"50080915","Registry":"4512617"},"FullyApproval":"false"}}';
        Test.setMock(HttpCalloutMock.class, new VS_WSExperienceSurveyValidateTest.MockHttpResponseGenerator(200, body));
        VS_ValidateAccountController.dtoResponse res = VS_ValidateAccountController.validateQuestions('task', 'String bearerToken', acc.Id, 'String validationRegistry', 'String IdSurvey', '[{"QuestionId":"test","AnswerId":"test"}]');
        Test.stopTest();
        
        System.assertNotEquals(null, res);
    }
    
    @isTest
    static void testValidateQuestionsNoAccount() {
        
        Test.startTest();
        VS_ValidateAccountController.dtoResponse res = VS_ValidateAccountController.validateQuestions('task', 'String bearerToken', '', 'String validationRegistry', 'String IdSurvey', '[{"QuestionId":"test","AnswerId":"test"}]');
        Test.stopTest();
        
        System.assertNotEquals(null, res);
    }
}