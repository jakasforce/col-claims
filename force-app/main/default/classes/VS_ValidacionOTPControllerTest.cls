@isTest
public class VS_ValidacionOTPControllerTest {
    
    public static Account createTestAccount() {
        Account testAccount = new Account();
        testAccount.CS_NumeroIdentificacionCP__pc = '1007389654';
		testAccount.CS_TipoIdentificacionCP__pc = '1';
        testAccount.FirstName = 'Test';
		testAccount.LastName = 'Test';
        testAccount.PersonMobilePhone = '3333333333';
        testAccount.CS_FechaExpedicion__pc = Date.today().addDays(-100);
        insert testAccount;
        return testAccount;
    }
    
    public static Contact createTestContact() {
        Contact con = new Contact();
        con.CS_NumeroIdentificacionCP__c = '1007389654';
		con.CS_TipoIdentificacionCP__c = '1';
        con.FirstName = 'Test';
		con.LastName = 'Test';
        con.MobilePhone = '3333333333';
        insert con;
        return con;
    }
    
    @isTest
    static void testGetAccountInfoWithAccountId() {
        Account testAccount = VS_ValidacionOTPControllerTest.createTestAccount();
        
   		Task testTask = new Task(Subject = 'Test Task');
        testTask.WhatId = testAccount.Id;
        insert testTask;
        
        Test.startTest();
            VS_ValidacionOTPController.DtoResponse response = VS_ValidacionOTPController.getAccountInfo(testTask.Id);
            System.assertEquals(true, response.successful);
            System.assertEquals(testAccount.Id, response.accountInfo.Id);
            System.assertEquals(testAccount.CS_TipoIdentificacionCP__pc, response.accountInfo.CS_TipoIdentificacionCP__pc);
        Test.stopTest();
    }
    @isTest
    static void testGetAccountInfoWithAccountInfo() {
        Account testAccount = VS_ValidacionOTPControllerTest.createTestAccount();
        
        Test.startTest();
            VS_ValidacionOTPController.DtoResponse response = VS_ValidacionOTPController.getAccountInfoWithAccountId(testAccount.Id);
        
            System.assertEquals(true, response.successful);
            System.assertEquals(testAccount.Id, response.accountInfo.Id);
            System.assertEquals(testAccount.CS_TipoIdentificacionCP__pc, response.accountInfo.CS_TipoIdentificacionCP__pc);
        Test.stopTest();
    }
    
    @isTest
    static void testGetAccountInfoWithAccountInfoAccountNull() {
        Account testAccount = VS_ValidacionOTPControllerTest.createTestAccount();
        
        Test.startTest();
            VS_ValidacionOTPController.DtoResponse response = VS_ValidacionOTPController.getAccountInfoWithAccountId(null);
        
            System.assertEquals(false, response.successful);
        Test.stopTest();
    }
    
    @isTest
    static void testGetAccountInfoWithContact() {
        Contact cont = VS_ValidacionOTPControllerTest.createTestContact();
        
   		Task testTask = new Task(Subject = 'Test Task');
        testTask.WhoId = cont.Id;
        insert testTask;
        
        Test.startTest();
            VS_ValidacionOTPController.DtoResponse response = VS_ValidacionOTPController.getAccountInfoFromContact(testTask.Id);
        
            System.assertEquals(true, response.successful);
            System.assertEquals(cont.Id, response.contactInfo.Id);
        Test.stopTest();
    }
    
    @isTest
    static void testGetAccountInfoWithContactNoContact() {
        
   		Account testAccount = VS_ValidacionOTPControllerTest.createTestAccount();
        
   		Task testTask = new Task(Subject = 'Test Task');
        testTask.WhatId = testAccount.Id;
        insert testTask;
        
        Test.startTest();
            VS_ValidacionOTPController.DtoResponse response = VS_ValidacionOTPController.getAccountInfoFromContact(testTask.Id);
        
            System.assertEquals(false, response.successful);
        Test.stopTest();
    }

    @isTest
    static void testGetAccountInfoWithoutAccountId() {
        // Crear un registro Task sin un registro Account relacionado para el escenario de prueba
        Task testTask = new Task(Subject = 'Test Task');
        insert testTask;
        
        Test.startTest();
        	VS_ValidacionOTPController.DtoResponse response = VS_ValidacionOTPController.getAccountInfo(testTask.Id);
        Test.stopTest();
        
        System.assertEquals(false, response.successful);
        System.assertEquals('No existe una cuenta asociada a esta tarea', response.message);
    }
    
	@isTest
    static void testSaveValidatedDateInAccount() {
        // Crear una cuenta de prueba
        Account testAccount = new Account(
            Name = 'Test Account'
        );
        insert testAccount;
        
        Test.startTest();
        	VS_ValidacionOTPController.DtoResponse response = VS_ValidacionOTPController.saveValidatedDateInAccount(testAccount);
        Test.stopTest();

        // Verificar que la operación fue exitosa
        System.assertEquals(true, response.successful);

        // Verificar que la fecha de última validación se ha actualizado
            Account updatedAccount = [SELECT Fecha_Ultima_Validacion_Cliente__c FROM Account WHERE Id = :testAccount.Id LIMIT 1];
            System.assertNotEquals(null, updatedAccount.Fecha_Ultima_Validacion_Cliente__c);
    }

    @isTest
    static void testSaveValidatedDateInAccountWithException() {
        // Crear una cuenta de prueba
        Account testAccount = new Account(
            Name = 'Test Account'
        );
        insert testAccount;

        // Forzar una excepción DML al intentar actualizar la cuenta
        testAccount.Name = null; // Esto provocará una excepción de validación
        try {
            update testAccount;
        } catch (DmlException e) {
            // Llamar al método saveValidatedDateInAccount y verificar la respuesta con la excepción
            VS_ValidacionOTPController.DtoResponse response = VS_ValidacionOTPController.saveValidatedDateInAccount(testAccount);

            // Verificar que la operación no fue exitosa debido a la excepción
            System.assertEquals(false, response.successful);

            // Verificar que el mensaje de error contiene información sobre la excepción
            System.assertNotEquals(null, response.message);
        }
    }
    
    @isTest
    static void testCallRegistraduriaAndUpdateAccountSuccess() {
        // Crear una cuenta de prueba
        Account testAccount = VS_ValidacionOTPControllerTest.createTestAccount();

        // Establecer un objeto simulado para la respuesta del servicio de registraduría
        string body = '[{"statement":{"dateOfQuery":"2023-09-06T15:14:16","response":"10","securityCode":"DM39B73","idType":"1","id":"1007389654","lastName":"Test","naturalNational":{"isValid":"","rut":"","idDetails":{},"age":{}}}}]';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200, body));

		Test.startTest();	
        	VS_ValidacionOTPController.DtoResponse response = VS_ValidacionOTPController.callRegistraduriaAndUpdateAccount('', testAccount, false);
        Test.stopTest();

        // Verificar que la operación fue exitosa
        System.assertEquals(true, response.successful);
        
    }
    
    @isTest
    static void testCallRegistraduriaAndUpdateAccountFailure() {
        // Crear una cuenta de prueba
        Account testAccount = VS_ValidacionOTPControllerTest.createTestAccount();

        // Establecer un objeto simulado para la respuesta del servicio de registraduría
        string body = '{"status":500,"code":"CANNOT_DISPATCH","message":{"message":"HTTP POST on resource "https://servicesesb.datacredito.com.co:443/wss/dhws3/services/DHServicePlus" failed: internal server error (500)."},"messageServer":"null","cause":[{"origin":"security-experience-api","message":"org.mule.extension.http.api.request.validator.ResponseValidatorTypedException"}]}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(500, body));

        // Llamar al método callRegistraduriaAndUpdateAccount y verificar la respuesta
        VS_ValidacionOTPController.DtoResponse response = VS_ValidacionOTPController.callRegistraduriaAndUpdateAccount('', testAccount, false);

        // Verificar que la operación no fue exitosa debido a la respuesta simulada del servicio de registraduría
        System.assertEquals(false, response.successful);

        // Verificar que el mensaje de error contiene información adecuada
        System.assertNotEquals(null, response.message);
    }
    
    @isTest
    static void testSendOPTCodeSuccess() {
        // Crear una cuenta de prueba
        Account testAccount = VS_ValidacionOTPControllerTest.createTestAccount();

        // Establecer un objeto simulado para la respuesta del servicio de autenticación
        string body = '{"access_token":"jWYTltSomPtzkXIyRM0zSX0cWN1QnHhYSMWHnpdWmzH7F9h-SRn8XwZcOQ8nUnqm6SmEJE-obX3G0VXuLK17EQ","token_type":"Bearer","expires_in":7200}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200, body));

        // Llamar al método sendOPTCode y verificar la respuesta
        Test.startTest();
        	VS_ValidacionOTPController.DtoResponse response = VS_ValidacionOTPController.sendOPTCode('test', testAccount);
        Test.stopTest();

        // Verificar que la operación fue exitosa
        System.assertEquals(true, response.successful);
    }
    
    @isTest
    static void testSendOPTCodeTokenError() {
        // Crear una cuenta de prueba
        Account testAccount = VS_ValidacionOTPControllerTest.createTestAccount();

        // Establecer un objeto simulado para la respuesta del servicio de autenticación
        string body = '{"access_token":"jWYTltSomPtzkXIyRM0zSX0cWN1QnHhYSMWHnpdWmzH7F9h-SRn8XwZcOQ8nUnqm6SmEJE-obX3G0VXuLK17EQ","token_type":"Bearer","expires_in":7200}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(400, body));

        // Llamar al método sendOPTCode y verificar la respuesta
        Test.startTest();
        	VS_ValidacionOTPController.DtoResponse response = VS_ValidacionOTPController.sendOPTCode('test', testAccount);
        Test.stopTest();

        // Verificar que la operación fue exitosa
        System.assertEquals(false, response.successful);
    }
    
	@isTest
    static void testvalidateSendedOPTCodeSuccess() {
        // Crear una cuenta de prueba
        Account testAccount = VS_ValidacionOTPControllerTest.createTestAccount();
        
        string body = '{"access_token":"jWYTltSomPtzkXIyRM0zSX0cWN1QnHhYSMWHnpdWmzH7F9h-SRn8XwZcOQ8nUnqm6SmEJE-obX3G0VXuLK17EQ","token_type":"Bearer","expires_in":7200}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200, body));

        String codeOtp = '739599';
        String vRegistry = '1234567';
        String tranId = 'f2e8faef-d259-4882-a15d-81d7824a128f';
        
        Test.startTest();
        	VS_ValidacionOTPController.DtoResponse response = VS_ValidacionOTPController.validateSendedOPTCode('test', testAccount, codeOtp, vRegistry, tranId);
        Test.stopTest();
        
        System.assertEquals(true, response.successful);
    }

    public class MockHttpResponseGenerator implements HttpCalloutMock {
        // Implement this interface method
        Public Integer statusCode;
        Public String stringBody;
        
        public MockHttpResponseGenerator(Integer staCode, String body){
            statusCode = staCode;
            stringBody = body;
        }
        public HTTPResponse respond(HTTPRequest req) {
            // Optionally, only send a mock response for a specific endpoint
            // and method.
            
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(stringBody);
            res.setStatusCode(statusCode);
            return res;
        }
    }
    
    @isTest
    static void testTaskWithPolicyAndBeneficiaries() {
        Account testAccount = VS_ValidacionOTPControllerTest.createTestAccount();
        
        // Crear una tarea con información relevante
        Task testTask = new Task(Subject = 'Test Task');
        testTask.WhatId = testAccount.Id;
        insert testTask;
        
        // Crear una póliza de seguro asociada a la tarea
        InsurancePolicy testPolicy = new InsurancePolicy(Name = 'Test Policy', NameInsuredId = testAccount.Id);
        insert testPolicy;
        
        // Crear beneficiarios asociados a la póliza
        Account beneficiaryAccount = new Account(
            FirstName = 'John',
            LastName = 'Doe',
            PersonEmail = 'john.doe@example.com',
            PersonMobilePhone = '3333333333',
            CS_NumeroIdentificacionCP__pc = '10000000',
            CS_TipoIdentificacionCP__pc = '1'
            // Agregar otros campos necesarios
        );
        insert beneficiaryAccount;
        
        InsurancePolicyParticipant beneficiary = new InsurancePolicyParticipant(
            Role = 'Beneficiario',
            PrimaryParticipantAccountId = beneficiaryAccount.Id,
            InsurancePolicyId = testPolicy.Id
            // Agregar otros campos necesarios
        );
        insert beneficiary;

		testTask.Poliza_de_seguro__c = testPolicy.Id;
        update testTask;
            
        Test.startTest();
        // Llamar al método que se va a probar
        VS_ValidacionOTPController.DtoResponse result = VS_ValidacionOTPController.getAccountInfoBeneficiario(testTask.Id);
        
        Test.stopTest();
        
        
    }
    
    @isTest
    static void testTaskWithPolicyAndBeneficiariesNoPoliza() {
        Account testAccount = VS_ValidacionOTPControllerTest.createTestAccount();
        
        // Crear una tarea con información relevante
        Task testTask = new Task(Subject = 'Test Task');
        testTask.WhatId = testAccount.Id;
        insert testTask;
        
        // Crear una póliza de seguro asociada a la tarea
        InsurancePolicy testPolicy = new InsurancePolicy(Name = 'Test Policy', NameInsuredId = testAccount.Id);
        insert testPolicy;
        
        // Crear beneficiarios asociados a la póliza
        Account beneficiaryAccount = new Account(
            FirstName = 'John',
            LastName = 'Doe',
            PersonEmail = 'john.doe@example.com',
            PersonMobilePhone = '3333333333',
            CS_NumeroIdentificacionCP__pc = '10000000',
            CS_TipoIdentificacionCP__pc = '1'
            // Agregar otros campos necesarios
        );
        insert beneficiaryAccount;
        
        InsurancePolicyParticipant beneficiary = new InsurancePolicyParticipant(
            Role = 'Beneficiario',
            PrimaryParticipantAccountId = beneficiaryAccount.Id,
            InsurancePolicyId = testPolicy.Id
            // Agregar otros campos necesarios
        );
        insert beneficiary;
            
        Test.startTest();
        // Llamar al método que se va a probar
        VS_ValidacionOTPController.DtoResponse result = VS_ValidacionOTPController.getAccountInfoBeneficiario(testTask.Id);
        
        // Verificar los resultados esperados
        System.assert(result.successful, 'Se esperaba una ejecución exitosa');
        System.assertEquals(null, result.participantList, 'la lista de participantes debería estar vacía');
        System.assertEquals(1, result.policyList.size(), 'Debería haber una póliza disponible');
        
        VS_ValidacionOTPController.DtoResponse result2 = VS_ValidacionOTPController.savePolicy(testTask.Id, result.policyList[0].Id);
        System.assert(result2.successful, 'Se esperaba una ejecución exitosa');
        
        delete testTask;
        VS_ValidacionOTPController.DtoResponse result3 = VS_ValidacionOTPController.savePolicy(testTask.Id, result.policyList[0].Id);
        System.assert(!result3.successful, 'Se esperaba una ejecución fallida');
        Test.stopTest();
        
        
    }
    
    @isTest
    static void testTaskWithPolicyAndBeneficiariesNoPolizaAndNoPolizaList() {
        Account testAccount = VS_ValidacionOTPControllerTest.createTestAccount();
        
        // Crear una tarea con información relevante
        Task testTask = new Task(Subject = 'Test Task');
        testTask.WhatId = testAccount.Id;
        insert testTask;
            
        Test.startTest();
        // Llamar al método que se va a probar
        VS_ValidacionOTPController.DtoResponse result = VS_ValidacionOTPController.getAccountInfoBeneficiario(testTask.Id);
        Test.stopTest();
        
        // Verificar los resultados esperados
        System.assert(!result.successful, 'Se esperaba una ejecución fallida');
        // Agregar más aserciones según las salidas esperadas del método
    }
    /*@isTest
    static void testTaskWithoutPolicy() {
        // Escenario: Task sin póliza asociada
        Account testAccount = VS_ValidacionOTPControllerTest.createTestAccount();
        
        // Crear una tarea con información relevante
        Task testTask = new Task(Subject = 'Test Task');
        testTask.WhatId = testAccount.Id;
        insert testTask;
        
        Test.startTest();
        VS_ValidacionOTPController.DtoResponse result = VS_ValidacionOTPController.getAccountInfoBeneficiario(testTask.Id);
        Test.stopTest();
        
        // Verificar los resultados esperados
        System.assert(!result.successful, 'Se esperaba una ejecución sin éxito');
        System.assertEquals('La póliza seleccionada no tiene beneficiarios disponibles para consultar', result.message, 'Mensaje incorrecto');
        // Agregar más aserciones según las salidas esperadas del método
    }
    
    @isTest
    static void testTaskWithoutBeneficiaries() {
        // Escenario: Task con póliza pero sin beneficiarios
        Account testAccount = VS_ValidacionOTPControllerTest.createTestAccount();
        
        // Crear una tarea con información relevante
        Task testTask = new Task(Subject = 'Test Task');
        testTask.WhatId = testAccount.Id;
        insert testTask;
        
        InsurancePolicy testPolicy = new InsurancePolicy(Name = 'Test Policy', NameInsuredId = testTask.WhatId);
        insert testPolicy;
        
        Test.startTest();
        VS_ValidacionOTPController.DtoResponse result = VS_ValidacionOTPController.getAccountInfoBeneficiario(testTask.Id);
        Test.stopTest();
        
        // Verificar los resultados esperados
        System.assert(!result.successful, 'Se esperaba una ejecución sin éxito');
        System.assertEquals('La póliza seleccionada no tiene beneficiarios disponibles para consultar', result.message, 'Mensaje incorrecto');
        // Agregar más aserciones según las salidas esperadas del método
    }*/
    
}