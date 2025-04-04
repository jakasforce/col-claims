@isTest
public with sharing class ClaimTriggerTest {
    @TestSetup
    static void makeData(){
        Id recordTypeId = Schema.SObjectType.Claim.getRecordTypeInfosByDeveloperName().get('CS_Monopoliza').getRecordTypeId();
        
        Claim claimTest = new Claim();
        claimTest.Name = 'Test Claim';
        claimTest.RecordTypeId = recordTypeId;
        insert claimTest;

        Account accountTest = new Account();
        accountTest.Name = 'Test Account';
        insert accountTest;

        // product2
        Product2 product2Test = new Product2();
        product2Test.Name = 'COLMENA EXEQUIAL INTEGRAL';
        product2Test.Family = '30';
        product2Test.ProductCode = '30218';
        product2Test.CS_Estrategia_M2__c = '13';
        product2Test.IsActive = true;
        product2Test.CS_Canal__c = '101';
        product2Test.CS_Producto_M2__c = '123';
        product2Test.CS_Producto_Colmena_M2__c = 'Seguro Acompañamiento Exequial';
        insert product2Test;

        InsurancePolicy insurancePolicyTest = new InsurancePolicy();
        insurancePolicyTest.Name = 'Test Insurance Policy';
        insurancePolicyTest.NameInsuredId = accountTest.Id;
        insurancePolicyTest.ProductId = product2Test.Id;
        insert insurancePolicyTest;

        ClaimCoverage claimCoverage = new ClaimCoverage(
            Name = 'Test Claim Coverage',
            ClaimId = claimTest.Id,
            InternalReserveMode = 'CoverageReserve',
            CS_CompensationValue__c = 6000000
        );
        insert claimCoverage;

        // CoverageCode
        InsurancePolicyCoverage insurancePolicyCoverageTest = new InsurancePolicyCoverage();
        insurancePolicyCoverageTest.InsurancePolicyId = insurancePolicyTest.Id;
        insurancePolicyCoverageTest.CoverageName = 'Test Coverage';
        insurancePolicyCoverageTest.CoverageCode = '';
        insert insurancePolicyCoverageTest;

        claimTest.InsurancePolicyCoverage__c = insurancePolicyCoverageTest.Id;
        claimTest.PolicyNumberId = insurancePolicyTest.Id;
        update claimTest;
    }

    @IsTest
    static void testOnBeforeUpdateRamoDesempleo(){
        Claim claimTest = [
            SELECT Id, Status, CS_SubEstado__c, OwnerId
            FROM Claim
            WHERE Name = 'Test Claim'
            LIMIT 1
        ];
        InsurancePolicy insurancePolicyTest = [SELECT Id FROM InsurancePolicy WHERE Name = 'Test Insurance Policy' LIMIT 1]; 

        Product2 product2Desempleo = new Product2();
        product2Desempleo.Name = 'DESEMPLEO';
        product2Desempleo.Family = '24';
        product2Desempleo.ProductCode = '2401';
        product2Desempleo.CS_Estrategia_M2__c = '14';
        product2Desempleo.IsActive = true;
        product2Desempleo.CS_Canal__c = '104';
        product2Desempleo.CS_Producto_M2__c = '121';
        product2Desempleo.CS_Producto_Colmena_M2__c = 'Desempleo Individual';
        
        Id queueId = [
            SELECT Id
            FROM Group
            WHERE Type = 'Queue' AND DeveloperName = 'Indemnizaciones_Ramo_Desempleo'
            LIMIT 1
        ].Id;
        
        Test.startTest();
        insert product2Desempleo;
        insurancePolicyTest.ProductId = product2Desempleo.Id;
        update insurancePolicyTest;
        claimTest.Status = 'Análisis';
        claimTest.CS_SubEstado__c = 'Nuevo';
        update claimTest;
        Test.stopTest();

        Claim claimTestToValidate = [
            SELECT Id, OwnerId
            FROM Claim
            WHERE Name = 'Test Claim'
            LIMIT 1
        ];
        System.assertEquals(queueId, claimTestToValidate.OwnerId, 'Owner Id should be Indemnizaciones_Ramo_Desempleo');
    }

    @IsTest
    static void testOnBeforeUpdateRamoVidaGrupo(){
        Claim claimTest = [
            SELECT Id, Status, CS_SubEstado__c, OwnerId
            FROM Claim
            WHERE Name = 'Test Claim'
            LIMIT 1
        ];
        InsurancePolicy insurancePolicyTest = [SELECT Id FROM InsurancePolicy WHERE Name = 'Test Insurance Policy' LIMIT 1]; 

        Product2 product2Desempleo = new Product2();
        product2Desempleo.Name = 'VIDA GRUPO DEUDOR - NEGOCIOS INSTITUCIONALES';
        product2Desempleo.Family = '34';
        product2Desempleo.ProductCode = '34224';
        product2Desempleo.CS_Estrategia_M2__c = '13';
        product2Desempleo.IsActive = true;
        product2Desempleo.CS_Canal__c = '101';
        product2Desempleo.CS_Producto_M2__c = '127';
        product2Desempleo.CS_Producto_Colmena_M2__c = 'Proteccion Creciente';
        
        Id queueId = [
            SELECT Id
            FROM Group
            WHERE Type = 'Queue' AND DeveloperName = 'Indemnizaciones_Ramo_Vida_Grupo'
            LIMIT 1
        ].Id;
        
        Test.startTest();
        insert product2Desempleo;
        insurancePolicyTest.ProductId = product2Desempleo.Id;
        update insurancePolicyTest;
        claimTest.Status = 'Análisis';
        claimTest.CS_SubEstado__c = 'Nuevo';
        update claimTest;
        Test.stopTest();

        Claim claimTestToValidate = [
            SELECT Id, OwnerId
            FROM Claim
            WHERE Name = 'Test Claim'
            LIMIT 1
        ];
        System.assertEquals(queueId, claimTestToValidate.OwnerId, 'Owner Id should be Indemnizaciones_Ramo_Vida_Grupo');
    }
}