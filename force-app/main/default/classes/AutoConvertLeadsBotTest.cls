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
public class AutoConvertLeadsBotTest {
    @TestSetup
    private static void setupData(){
        Lead newLead = new Lead();
        newLead.recordTypeId                        = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('General').getRecordTypeId();
        newLead.Status                              = 'InProcess';
        newLead.LeadSource                          = 'Base de datos propia';
        newLead.Tipo_de_documento__c                = '1';
        newLead.Numero_de_documento__c              = '1000350343';
        newLead.FirstName                           = 'PruebaConversión';
        newLead.LastName                            = 'PruebaConversion';
        newLead.MobilePhone                         = '3013926543';
        newLead.Email                               = 'Prueba@gmail.com';
        newLead.TypePerson__c                       = 'Persona Natural';
        insert newLead;
        System.debug('---->'+newLead.id);
    }

    @isTest
    private static void AutoConvertLeadsBot(){

        list<Id> LeadsRecords = new List<Id>();
        Lead lead = [SELECT id FROM lead WHERE Numero_de_documento__c = '1000350343' LIMIT 1];
        LeadsRecords.add(lead.id);
        Test.startTest();
        AutoConvertLeadsBot.leadAssing(LeadsRecords);
        Test.stopTest();

    }
}