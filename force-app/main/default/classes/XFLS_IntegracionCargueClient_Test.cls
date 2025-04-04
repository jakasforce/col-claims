/********************************************************************
Apex Class Name	:	XFLS_IntegracionCargueClient_Test
Version			:	1.0
Created Date	:	24/08/2022
Function 		: 	

Modification Log
*--------------------------------------------------------------------
* Developer		     	Date			   	Description
* -------------------------------------------------------------------
* Emilio Lara 	 24/08/2022	       			Original Version
*********************************************************************/

@isTest
public with sharing class XFLS_IntegracionCargueClient_Test {
    
    @testSetup
    public static void setup(){
        
        Account acc = new Account(LastName = 'Tester2',
                                  PersonMobilePhone = '5540005533',
                                  PersonEmail = 'tester0@test.com',
                                  FirstName = 'TestAcc2',
                                  XFLS_Nit__c = 'Texto Test NIT Test Texto',
                                  CS_NumeroIdentificacion__c = '1234567890',
                                  XFLS_Direccion__c = 'Direccio Test',
                                  Phone = '5544005539',
                                  XFLS_Representante_Legal__c = 'Representante Test',
                                  XFLS_Correo__c = 'tester8@test.com');
        insert acc;
    }
    
    @isTest
    static void integracionClientesTest(){
        
        Test.startTest();
        
        Account acc = [SELECT Id FROM Account WHERE LastName = 'Tester2' LIMIT 1];
        
        Contract contrato = new Contract();
        contrato.AccountId = acc.Id;
        insert contrato;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(contrato);

        XFLS_IntegracionCargueClient intClientes = new XFLS_IntegracionCargueClient(sc);
        PageReference result = intClientes.cargarClientes();
        System.assertNotEquals(null, result);
       
        
        Test.stopTest();
    }

}