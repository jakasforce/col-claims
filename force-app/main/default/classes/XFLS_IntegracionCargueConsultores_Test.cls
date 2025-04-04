/********************************************************************
Apex Class Name	:	XFLS_IntegracionCargueConsultores_Test
Version			:	1.0
Created Date	:	23/08/2022
Function 		: 	

Modification Log
*--------------------------------------------------------------------
* Developer		     	Date			   	Description
* -------------------------------------------------------------------
* Emilio Lara 	 23/08/2022	       			Original Version
*********************************************************************/

@isTest
public with sharing class XFLS_IntegracionCargueConsultores_Test {
        
       @testsetup
        public static void setup(){
            
            Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Usuario estándar' OR Name = 'Standard User' LIMIT 1];
            
            User u = new user();
            u.LastName = 'Test U2';
            u.Email = 'test@test.com';
            u.Alias = 'Tcode';
            u.Username = 'test123test896@test.com';
            u.CommunityNickname = 'test12';
            u.LocaleSidKey = 'en_US';
            u.TimeZoneSidKey = 'GMT';
            u.ProfileId = profileId.id;
            u.LanguageLocaleKey = 'en_US';
            u.EmailEncodingKey = 'UTF-8';
            insert u;
        }
    
    @isTest
    static void integracionConsultoresTest(){
        
        Test.startTest();
        
        User u = [SELECT Id FROM User WHERE LastName = 'Test U2' LIMIT 1];
         
        ServiceResource consultor = new ServiceResource();
        consultor.XFLS_document__c = '1128480989';
        consultor.RelatedRecordId = u.Id;
        consultor.Name = 'Emilio';
        insert consultor;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(consultor);

        XFLS_IntegracionCargueConsultores intConsultores = new XFLS_IntegracionCargueConsultores(sc);
        PageReference result = intConsultores.cargarConsultores();
        System.assertNotEquals(null, result);
       
        Test.stopTest();
    }

}