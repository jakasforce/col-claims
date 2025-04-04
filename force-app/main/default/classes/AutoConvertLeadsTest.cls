/**
* ===============================================================================================================================
* Developer:             VASS LATAM
* Creation Date:         09/10/2023
* Created by:            Gabriel.Velandia@vasscompany.com
* Description:           TEST de la clase AutoConvertLeads.
* Last Modified by:      edwin.martinez@vasscompany.com (10/10/2023)
* Version:               v1.0
* ===============================================================================================================================
**/
@isTest
public class AutoConvertLeadsTest {
    @TestSetup
    private static void setupData(){
        
        Profile p = [SELECT Id FROM Profile WHERE Name IN ('Administrador del sistema', 'System Administrator') LIMIT 1];
        
        user u = New User(
            UserName            = 'test_' + math.random() + '@test.com',
            FirstName           = 'Test-First',
            LastName            = 'Test-Last',
            Alias               = 'test',
            email               = 'test' + math.random() + '@test.com',
            CommunityNickName   = string.valueOf(math.random()).substring(0,6),
            ProfileID           = p.id,
            TimeZoneSidKey      = 'America/New_York', 
            LocaleSidKey        = 'en_US', 
            EmailEncodingKey    = 'UTF-8', 
            LanguageLocaleKey   = 'en_US',
            ProspectStrategy__c = 'Negocios Institucionales',
            Branch__c           = 'Bogotá'
        );
        insert u;

        Schema.Location testUbicaicon = new Schema.Location();
        testUbicaicon.Name = 'test';
        testUbicaicon.LocationType = 'Almacén';
        insert testUbicaicon;

        
        Lead newLead = new Lead();
        newLead.RecordTypeId                        = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('General').getRecordTypeId();
        newLead.Status                              = 'InProcess';
        newLead.LeadSource                          = 'Base de datos propia';
        newLead.Tipo_de_documento__c                = '3';
        newLead.SponsorCategory__c                  = 'Corresponsales';
        newLead.Numero_de_documento__c              = '795231355';
        newLead.NumberOfEmployees                   =  20000;
        newLead.TypePerson__c                       = 'Persona Jurídica';
        newLead.FirstName                           = 'PruebaConversiónLead';
        newLead.LastName                            = 'PruebaConversiónLead';
        newLead.Company                             = 'PruebaConversiónLead PruebaConversiónLead';
        newLead.Ciudad__c                           = testUbicaicon.id;
        newLead.MobilePhone                         = '3013926543';
        newLead.Email                               = 'Prueba@gmail.com';
        newLead.ContactType__c                      = 'Comercial';
        newLead.IndependentLinkedCompany__c         = true;
        newLead.NumberDependentWorkers__c           = 10;
        newLead.NumberIndependentWorkers__c         = 10;
        newLead.NumberPotentialCustomers__c         = 10;
        newLead.NumberPotentialWorkers__c         = 10;
        newLead.EstimatedPremiumsYear__c         = 100;
        newLead.AverageIndependentMoContribution__c = 10;
        newLead.AverageMonthlyDependentContributions__c = 10;
        newLead.Procedure_type__c                   = 'Afiliación';
        newLead.Title                               = 'Pruebas';
        newLead.IndependentLinkedCompany__c  = false;
        newLead.OwnerId=u.Id;
        insert newLead;
        System.debug('Lead: '+ newLead);
    }
 	
    @isTest
    private static void AutoConvertLeadsTest(){
 
        list<Id> LeadsRecords = new List<Id>();
        Lead lead = [SELECT id FROM lead WHERE Numero_de_documento__c = '795231355' LIMIT 1];
        LeadsRecords.add(lead.id);
 
        Test.startTest();
        AutoConvertLeads.assignLeads(LeadsRecords);
        Test.stopTest();
 
    }
}