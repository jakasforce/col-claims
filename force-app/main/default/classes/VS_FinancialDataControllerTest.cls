@isTest
public class VS_FinancialDataControllerTest {
    
    @testSetup
    static void setupTestData() {
        Account acc = new Account();
        acc.CS_TipoIdentificacionCP__pc = '1';
        acc.CS_NumeroIdentificacionCP__pc = '1007389654';
        acc.CS_FechaExpedicion__pc = Date.valueOf('2018-06-26');
        acc.AccountNumber = '123456789';
        acc.LastName = 'Account Test';
        acc.Suffix = 'Test';
        acc.FirstName = 'Account';
        acc.PersonMobilePhone = '1111111111';
        acc.Fecha_Ultima_Validacion_Cliente__c = DateTime.now();
        insert acc;
        
        List<RecordType> recordTypeList = [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Case' AND Name = 'Formulario' LIMIT 1];
        Case caso = new Case(
            Subject = 'Test Case',
            CS_Pais__c = '170',
            CS_Municipio__c = '23001',
            CS_Departamento__c = '23',
            RecordTypeId = recordTypeList[0].Id,
            AccountId = acc.Id
            // CS_Subtipo__c = '2',
            // CS_ProductoColmenaM2__c = 'Accidentes Personales',
            // CS_ProductoM2__c = '124',
            // CS_EstrategiaM2__c = 'Telemercadeo',
            // CS_RamoM2__c = 'Accidentes Personales',
        );
        insert caso;
        
        Case testCase2 = new Case(
            Subject = 'Caso de prueba sin cuenta',
            CS_Pais__c = '170',
            CS_Municipio__c = '23001',
            CS_Departamento__c = '23',
            RecordTypeId = recordTypeList[0].Id
        );
        insert testCase2;
        
        Task taskTest = new Task(
        	Subject = 'Test',
            Priority = 'Normal',
            Status = 'Open',
            WhatId = acc.Id,
            Modulo__c = 'Seguros de Vida',
            HandCalls__c = 'Llamadas de Salida',
            Tipo_de_llamada__c = 'Saliente'
        );
        insert taskTest;
    }
    
    @isTest
    static void testGetInfoFromCase() {
        Case caseWithoutAccount = [Select Id, Subject From Case Where Subject = 'Caso de prueba sin cuenta'];
        List<Case> caseTest = [SELECT Id, AccountId, Account.CS_TipoIdentificacionCP__pc, Account.CS_NumeroIdentificacionCP__pc
                               FROM Case
                               Where Subject != 'Caso de prueba sin cuenta'
                              ];
        
        String responseBody = '{"access_token": "test_access_token","token_type": "Bearer","expires_in": 3600, "successful": true}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200, responseBody));
        
        Test.startTest();
        VS_FinancialDataController.DtoResponse caseResponseGetInfo = VS_FinancialDataController.getInfo(caseTest[0].Id);
        VS_FinancialDataController.DtoResponse caseResponseGetInfoFailed = VS_FinancialDataController.getInfo('Invalid');
        VS_FinancialDataController.DtoResponse result = VS_FinancialDataController.getInfoFromCase(caseTest[0].Id);
        Test.stopTest();
        
        System.assertEquals(true, caseResponseGetInfo.successful, 'La respuesta del caso debería ser exitosa');
        System.assertEquals(false, caseResponseGetInfoFailed.successful, 'La respuesta del caso debería fallar');
        System.assertEquals(true, result.successful, 'La respuesta debería ser exitosa');
        
        System.assertNotEquals(null, result.bankList, 'La lista de bancos no debería ser nula');
        System.assertNotEquals(0, result.bankList.size(), 'La lista de bancos no debería estar vacía');
        
        System.assertNotEquals(null, result.typeFinancialAccountList, 'La lista de tipos de cuenta financiera no debería ser nula');
        System.assertNotEquals(0, result.typeFinancialAccountList.size(), 'La lista de tipos de cuenta financiera no debería estar vacía');
    }
    
    @isTest
    static void testGetInfoFromCaseFailed() {
        Case caseWithoutAccount = [Select Id, Subject From Case Where Subject = 'Caso de prueba sin cuenta'];
        List<Case> caseTest = [SELECT Id, AccountId, Account.CS_TipoIdentificacionCP__pc, Account.CS_NumeroIdentificacionCP__pc
                               FROM Case
                               Where Subject != 'Caso de prueba sin cuenta'
                              ];
        
        String responseBody = '{"access_token": "test_access_token","token_type": "Bearer","expires_in": 3600, "successful": "false"}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(400, responseBody));
        
        
        Test.startTest();
        VS_FinancialDataController.DtoResponse resultNullAccountId = VS_FinancialDataController.getInfoFromCase(caseWithoutAccount.Id);
        VS_FinancialDataController.DtoResponse resultVoidList = VS_FinancialDataController.getInfoFromCase('01231203123');
        VS_FinancialDataController.DtoResponse result = VS_FinancialDataController.getInfoFromCase(caseTest[0].Id);
        Test.stopTest();
        
        System.assertEquals(false, resultNullAccountId.successful, 'La respuesta debería arrojar un fallo');
        System.assertEquals(false, resultVoidList.successful, 'La respuesta debería arrojar un fallo');
        System.assertEquals(false, result.successful, 'La respuesta debería ser exitosa');
    }
    
    @isTest
    static void testGetInfoFromCase_AuthenticationFailure() {
        List<Case> caseTest = [SELECT Id, AccountId, Account.CS_TipoIdentificacionCP__pc, Account.CS_NumeroIdentificacionCP__pc
                               FROM Case
                               Where Subject != 'Caso de prueba sin cuenta'
                              ];
        Test.startTest();
        VS_FinancialDataController.DtoResponse result = VS_FinancialDataController.getInfoFromCase(caseTest[0].Id);
        Test.stopTest();
        
        System.assertEquals(false, result.successful, 'Se esperaba una respuesta sin éxito');
        System.assertEquals('Ocurrió un problema al obtener el token: consulte a su administrador', result.message, 'El mensaje de la respuesta no es el esperado');
    }	
	
    
    @isTest
    static void testGetInfoFromTaskSuccessful() {
        List<Task> taskTest = [Select Id, WhatId From Task];
        
        String responseBody = '{"access_token": "test_access_token","token_type": "Bearer","expires_in": 3600, "successful": true}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200, responseBody));
        
        Test.startTest();
        VS_FinancialDataController.DtoResponse responseGetInfo = VS_FinancialDataController.getInfo(taskTest[0].Id);
        VS_FinancialDataController.DtoResponse result = VS_FinancialDataController.getInfoFromTask(taskTest[0].Id);
        Test.stopTest();
        
        System.assertEquals(true, responseGetInfo.successful, 'La respuesta del caso debería ser exitosa');
        System.assertEquals(true, result.successful, 'Se esperaba una respuesta exitosa');
        System.assertEquals(taskTest[0].WhatId, result.accountId, 'El ID de la cuenta en la respuesta no coincide');
    }
    
    @isTest
    static void testGetInfoFromTaskFailed() {
        List<Task> taskTest = [Select Id, WhatId From Task];
        
        String responseBody = '{"access_token": "test_access_token","token_type": "Bearer","expires_in": 3600, "successful": "false"}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(400, responseBody));
        
        Test.startTest();
        VS_FinancialDataController.DtoResponse result = VS_FinancialDataController.getInfoFromTask('invalidTaskId');
        VS_FinancialDataController.DtoResponse resultResponseBodyFailed = VS_FinancialDataController.getInfoFromTask(taskTest[0].Id);
        taskTest[0].WhatId = null;
        update taskTest;
        System.debug(taskTest[0].WhatId);
        VS_FinancialDataController.DtoResponse resultResponseBodyFailedNull = VS_FinancialDataController.getInfoFromTask(taskTest[0].Id);
        Test.stopTest();
        
        System.assertEquals(false, result.successful, 'Se esperaba una respuesta sin éxito');
        System.assertEquals(false, resultResponseBodyFailed.successful, 'Se esperaba una respuesta sin éxito');
        System.assertEquals(false, resultResponseBodyFailedNull.successful, 'Se esperaba una respuesta sin éxito');
        System.assertEquals('Ocurrió un error: esta tarea no se encontró en la basa de datos', result.message, 'El mensaje de error no coincide');
    }
    
    @isTest
    static void testGetInfoFromTaskCatch() {
        List<Task> taskTest = [Select Id, WhatId From Task];
        Test.startTest();
        VS_FinancialDataController.DtoResponse result = VS_FinancialDataController.getInfoFromTask(taskTest[0].Id);
        Test.stopTest();
        
        System.assertEquals(false, result.successful, 'Se esperaba una respuesta sin éxito');
        System.assertEquals('Ocurrió un problema al obtener el token: consulte a su administrador', result.message, 'El mensaje de la respuesta no es el esperado');
    }

    @isTest
    static void testGetInfoFromAccountSuccessful() {
        List<Account> testAccount = [Select Id, Name From Account];
        
        String responseBody = '{"access_token": "test_access_token","token_type": "Bearer","expires_in": 3600, "successful": true}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200, responseBody));
        
        Test.startTest();
        VS_FinancialDataController.DtoResponse responseGetInfo = VS_FinancialDataController.getInfo(testAccount[0].Id);
        VS_FinancialDataController.DtoResponse result = VS_FinancialDataController.getInfoFromAccount(testAccount[0].Id);
        Test.stopTest();

        System.assertEquals(true, responseGetInfo.successful, 'La respuesta del caso debería ser exitosa');        
        System.assertEquals(true, result.successful, 'Se esperaba una respuesta exitosa');
        System.assertEquals(testAccount[0].Id, result.accountId, 'El ID de la cuenta en la respuesta no coincide');
    }
    
    @isTest
    static void testGetInfoFromAccountFailed() {
        List<Account> testAccount = [Select Id, Name From Account];
        String responseBody = '{"access_token": "test_access_token","token_type": "Bearer","expires_in": 3600, "successful": "false"}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(400, responseBody));
        
        Test.startTest();
        VS_FinancialDataController.DtoResponse result = VS_FinancialDataController.getInfoFromAccount('invalidAccountId');
        VS_FinancialDataController.DtoResponse resultResponseToken = VS_FinancialDataController.getInfoFromAccount(testAccount[0].Id);
        Test.stopTest();
        
        System.assertEquals(false, resultResponseToken.successful, 'Se esperaba una respuesta sin éxito');
        System.assertEquals(false, result.successful, 'Se esperaba una respuesta sin éxito');
        System.assertEquals('Ocurrió un error: esta cuenta no se encontró en la basa de datos', result.message, 'El mensaje de error no coincide');
    }
    
    @isTest
    static void testSaveFinancialAccountSuccessful() {
        List<Account> testAccount = [Select Id, AccountNumber From Account];

        String responseBody = '{"access_token": "test_access_token","token_type": "Bearer","expires_in": 3600, "successful": true}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200, responseBody));
		Id currentUserId = UserInfo.getUserId();
        
        Test.startTest();
        VS_FinancialDataController.DtoResponse result = VS_FinancialDataController.saveFinancialAccount(testAccount[0].AccountNumber, '07', '2', testAccount[0].Id, '2', currentUserId);
        Test.stopTest();

        System.assertEquals(true, result.successful, 'Se esperaba una respuesta exitosa');
    }
    
     @isTest
    static void testSaveFinancialAccountWhitFiniancialAccountExist() {
        List<Account> testAccount = [Select Id, AccountNumber From Account];
		FinServ__FinancialAccount__c finAccount = new FinServ__FinancialAccount__c();
        finAccount.BankName__c = '07';
        finAccount.FinServ__FinancialAccountType__c = 'Savings';
        finAccount.FinServ__FinancialAccountNumber__c = testAccount[0].AccountNumber;
        finAccount.FinServ__PrimaryOwner__c = testAccount[0].Id;
        
        insert finAccount;
        
        Account acc2 = new Account();
        acc2.CS_TipoIdentificacionCP__pc = '1';
        acc2.CS_NumeroIdentificacionCP__pc = '1207389654';
        acc2.CS_FechaExpedicion__pc = Date.valueOf('2018-07-26');
        acc2.AccountNumber = '122456789';
        acc2.LastName = 'Account Test 2';
        acc2.Suffix = 'Test 2';
        acc2.FirstName = 'Account 2';
        acc2.PersonMobilePhone = '1211111111';
        acc2.Fecha_Ultima_Validacion_Cliente__c = DateTime.now();
        insert acc2;
        
        finAccount.FinServ__PrimaryOwner__c = acc2.Id;
        update finAccount;
        
        List<FinServ__FinancialAccountRole__c> roleList = [SELECT Id, FinServ__FinancialAccount__c, FinServ__RelatedAccount__c, FinServ__Role__c
                                                           FROM FinServ__FinancialAccountRole__c
                                                           WHERE FinServ__RelatedAccount__c =:testAccount[0].Id and FinServ__FinancialAccount__c = :finAccount.Id];
        delete roleList[0];
        
        String responseBody = '{"access_token": "test_access_token","token_type": "Bearer","expires_in": 3600, "successful": true}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200, responseBody));
		Id currentUserId = UserInfo.getUserId();
        
        Test.startTest();
        VS_FinancialDataController.DtoResponse result = VS_FinancialDataController.saveFinancialAccount(testAccount[0].AccountNumber, '07', '2', testAccount[0].Id, '2', currentUserId);
        Test.stopTest();

        System.assertEquals(true, result.successful, 'Se esperaba una respuesta exitosa');
    }

    public class MockHttpResponseGenerator implements HttpCalloutMock {
        Integer statusCode;
        String responseBody;
        
        public MockHttpResponseGenerator(Integer statusCode, String responseBody) {
            this.statusCode = statusCode;
            this.responseBody = responseBody;
        }
        
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(responseBody);
            res.setStatusCode(statusCode);
            return res;
        }
    }

    @isTest
    static void testGetAccountIdFromAccount() {
        List<Account> testAccount = [Select Id, Name From Account];
        Test.startTest();
        VS_FinancialDataController.DtoResponse response = VS_FinancialDataController.getAccountId(testAccount[0].Id);
        Test.stopTest();
        System.assertEquals(testAccount[0].Id, response.accountId, 'El ID de la cuenta no coincide');
    }

    @isTest
    static void testGetAccountIdFromCase() {
        List<Case> caseTest = [Select Id, AccountId From Case];
        
        Test.startTest();
        VS_FinancialDataController.DtoResponse response = VS_FinancialDataController.getAccountId(caseTest[0].Id);
        Test.stopTest();
        System.assertEquals(caseTest[0].AccountId, response.accountId, 'El ID de la cuenta no coincide con el del caso.');
    }

    @isTest
    static void testGetAccountIdFromTask() {
        List<Task> taskTest = [Select Id, WhatId From Task];
        
        Test.startTest();
        VS_FinancialDataController.DtoResponse response = VS_FinancialDataController.getAccountId(taskTest[0].Id);
        Test.stopTest();
        System.assertEquals(taskTest[0].WhatId, response.accountId, 'El ID de la cuenta no coincide con el de la tarea.');
    }

    @isTest
    static void testGetAccountIdFailure() {        
        Test.startTest();
        VS_FinancialDataController.DtoResponse response = VS_FinancialDataController.getAccountId('');
        Test.stopTest();
        System.assertEquals(false, response.successful, 'Se esperaba una respuesta sin éxito');
    }

    @isTest
    static void testSaveFinancialAccount_DMLException_FinancialAccount() {
        Account acc = [
            SELECT Id, AccountNumber
            FROM Account
            LIMIT 1
        ];
        String isNewAccount = '2';
        Id currentUserId = UserInfo.getUserId();

        Test.startTest();
        VS_FinancialDataController.DtoResponse response = VS_FinancialDataController.saveFinancialAccount(acc.AccountNumber, '07', '2', acc.Id, isNewAccount, currentUserId);
        Test.stopTest();

        System.assertEquals(false, response.successful);
    }

    @isTest
    static void testSaveFinancialAccount_DMLException_FinancialRole() {
        Account acc = [
            SELECT Id, AccountNumber
            FROM Account
            LIMIT 1
        ];
        String isNewAccount = '2';
        Id currentUserId = UserInfo.getUserId();

        Test.startTest();
        VS_FinancialDataController.DtoResponse response = VS_FinancialDataController.saveFinancialAccount(acc.AccountNumber, '07', '02', acc.Id, isNewAccount, currentUserId);
        Test.stopTest();

        System.assertEquals(false, response.successful);
    }
}