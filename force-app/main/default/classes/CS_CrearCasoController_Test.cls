/********************************************************************************************************************************************************************************************
Apex Class Name	:	CS_CrearCasoController_Test
Version			:	1.0
Created Date	:	04/04/2023 by Jorge Martínez (jorge.martinez-miranda@viseo.com / martinezmiranda.jorge@gmail.com)
Test Class      :   CS_CrearCasoController
Function 		:   Clase test para el controlador CS_CrearCasoController

Modification Log:
*--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*    Developer                    Date                    Description                    Changes
*--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*    Jorge Martinez               23/03/2023              Original Version               
*--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*********************************************************************************************************************************************************************************************/

@isTest
private class CS_CrearCasoController_Test {

    @isTest
	static void testGetInsurancePolicy(){
        Map<Schema.SObjectField, Object> mapProduct2 = new Map<Schema.SObjectField, Object>();
        mapProduct2.put(Product2.Name, 'Desempleo');
        mapProduct2.put(Product2.Family, '24');
        mapProduct2.put(Product2.CS_Producto_M2__c, '121');
        mapProduct2.put(Product2.CS_Producto_Colmena_M2__c, 'Desempleo Individual');
        mapProduct2.put(Product2.CS_Estrategia_M2__c, '14');
        Product2 newProduct2 = CS_TestDataFactory.createProduct(mapProduct2, true);

        Map<Schema.SObjectField, Object> mapInsurancePolicy = new Map<Schema.SObjectField, Object>();
        Account objAccount = CS_TestDataFactory.createPersonAccount(true);
        Id devRecordTypeId = Schema.SObjectType.InsurancePolicy.getRecordTypeInfosByDeveloperName().get('CS_Contrato_ARL').getRecordTypeId();
        mapInsurancePolicy.put(InsurancePolicy.RecordTypeId, devRecordTypeId);
        mapInsurancePolicy.put(InsurancePolicy.Name, 'Test');
        mapInsurancePolicy.put(InsurancePolicy.ProductId, newProduct2.Id);
        mapInsurancePolicy.put(InsurancePolicy.NameInsuredId, objAccount.Id);
        mapInsurancePolicy.put(InsurancePolicy.CS_NumeroContrato__c, '00112233');
        InsurancePolicy newInsurancePolicy = CS_TestDataFactory.createInsurancePolicy(mapInsurancePolicy, true);

        Test.startTest();
            List<InsurancePolicy> lstInsurancePolicy =  CS_CrearCasoController.getInsurancePolicy(newInsurancePolicy.Id);
		Test.stopTest();

        System.assert(lstInsurancePolicy.size() > 0, 'No se creo la póliza');
    }

    @isTest
	static void testGetClaim(){
        Map<Schema.SObjectField, Object> mapClaim = new Map<Schema.SObjectField, Object>();
        Account objAccount = CS_TestDataFactory.createPersonAccount(true);
        Id devRecordTypeId = Schema.SObjectType.Claim.getRecordTypeInfosByDeveloperName().get('CS_Siniestro').getRecordTypeId();
        mapClaim.put(Claim.Name, 'Test');
        mapClaim.put(Claim.AccountId, objAccount.Id);
        Claim newClaim = CS_TestDataFactory.createClaim(mapClaim, true);

        Test.startTest();
            List<Claim> lstClaim =  CS_CrearCasoController.getClaim(newClaim.Id);
        Test.stopTest();
    
        System.assert(lstClaim.size() > 0, 'No se creo la reclamación');
    }

    @isTest
	static void testGetTituloCapitalizacion(){
        Map<Schema.SObjectField, Object> mapProduct2 = new Map<Schema.SObjectField, Object>();
        mapProduct2.put(Product2.Name, 'Desempleo');
        mapProduct2.put(Product2.Family, '24');
        mapProduct2.put(Product2.CS_Producto_M2__c, '121');
        mapProduct2.put(Product2.CS_Producto_Colmena_M2__c, 'Desempleo Individual');
        mapProduct2.put(Product2.CS_Estrategia_M2__c, '14');
        Product2 newProduct2 = CS_TestDataFactory.createProduct(mapProduct2, true);

        Map<Schema.SObjectField, Object> mapTituloCapitalizacion = new Map<Schema.SObjectField, Object>();
        Account objAccount = CS_TestDataFactory.createPersonAccount(true);
        Id devRecordTypeId = Schema.SObjectType.Claim.getRecordTypeInfosByDeveloperName().get('CS_Siniestro').getRecordTypeId();
        mapTituloCapitalizacion.put(CS_Titulo_de_Capitalizacion__c.Name, 'Test');
        mapTituloCapitalizacion.put(CS_Titulo_de_Capitalizacion__c.CS_Cuenta__c, objAccount.Id);
        mapTituloCapitalizacion.put(CS_Titulo_de_Capitalizacion__c.CS_Producto__c, newProduct2.Id);

        CS_Titulo_de_Capitalizacion__c newTituloCapitalizacion = CS_TestDataFactory.createTituloCapitalizacion(mapTituloCapitalizacion, true);

        Test.startTest();
            List<CS_Titulo_de_Capitalizacion__c> lstTituloCapitalizacion =  CS_CrearCasoController.getTituloCapitalizacion(newTituloCapitalizacion.Id);
        Test.stopTest();
    
        System.assert(lstTituloCapitalizacion.size() > 0, 'No se creo el titulo de capitalización');
    }

    @isTest
	static void testGetContacts(){
        Account objAccount = CS_TestDataFactory.createAccount(true);

        Map<Schema.SObjectField, Object> mapContact = new Map<Schema.SObjectField, Object>();
        mapContact.put(Contact.AccountId, objAccount.Id);
        mapContact.put(Contact.FirstName, 'Test');
        mapContact.put(Contact.LastName, 'Contact');
        mapContact.put(Contact.email, 'test@test.com');
        Contact newContact = CS_TestDataFactory.createContact(mapContact, true);

        /*
        Map<Schema.SObjectField, Object> mapAccountContactRelation = new Map<Schema.SObjectField, Object>();
        mapAccountContactRelation.put(AccountContactRelation.AccountId, objAccount.Id);
        mapAccountContactRelation.put(AccountContactRelation.ContactId, newContact.Id);
        mapAccountContactRelation.put(AccountContactRelation.IsActive, true);
        AccountContactRelation newAccountContactRelation = CS_TestDataFactory.createAccountContactRelation(mapAccountContactRelation, true);
        */
        
        Test.startTest();
            List<AccountContactRelation> lstAccountContactRelation =  CS_CrearCasoController.getContacts(objAccount.Id);
        Test.stopTest();

        System.assert(lstAccountContactRelation.size() > 0, 'No se creo la relación del contacto con la cuenta');
        
    }
}