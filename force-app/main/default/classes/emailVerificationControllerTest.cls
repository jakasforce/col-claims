/*
* ===============================================================================================================================
* Developer:             VASS COMPANY
* Creation Date:         23/02/2024
* Created by:            edwinc.martinez@oc.vasscompany.com
* Description:           Clase de prueba para el controlador de verificación de correo electrónico.
* Last Modified by:      edwinc.martinez@oc.vasscompany.com (29/02/2024)
* Changes (Versions)
*
* -------------------------------------
* No.     Date        Author                    Description
* ------  ----------  ---------------------     ---------------
* 1.1     29/02/2024  Edwin Camilo Martinez     Se realizan los metodos necesarios para cubrir la clase
* ===============================================================================================================================
*/

@isTest
public class emailVerificationControllerTest {

    @isTest
    static void testVerificarEmail() {
        
        Id generalRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('General').getRecordTypeId();
        
        // Crear un Lead de prueba
        Lead newLead = new Lead();
        newLead.Status                              = 'InProcess';
        newLead.LeadSource                          = 'Base de datos propia';
        newLead.Tipo_de_documento__c                = '1';
        newLead.Numero_de_documento__c              = '1000350348';
        newLead.FirstName                           = 'PruebaConversión';
        newLead.LastName                            = 'PruebaConversion';
        newLead.RecordTypeId                        =  generalRecordTypeId;
        newLead.MobilePhone                         = '3013926543';
        newLead.Email                               = 'Prueba@gmail.com';
        newLead.TypePerson__c                       = 'Persona Natural';
        insert newLead;

        Database.LeadConvert lc = new Database.LeadConvert();
        lc.setLeadId(newLead.Id);

        lc.setConvertedStatus('Converted');
        lc.setDoNotCreateOpportunity(true); 

        // Ejecutar la conversión
        Database.LeadConvertResult lcr = Database.convertLead(lc);

        System.assert(lcr.isSuccess());

        // Obtener el Lead convertido 
        Lead convertedLead = [SELECT Id, ConvertedAccountId, ConvertedContactId, Email FROM Lead WHERE Id = :newLead.Id LIMIT 1];

        // Verificar que el Lead este convertido 
        System.assertNotEquals(null, convertedLead.ConvertedAccountId);

        // Crear un ContactPointEmail
        ContactPointEmail testContactPointEmail = new ContactPointEmail(
            ParentId = convertedLead.ConvertedAccountId,
            EmailAddress = convertedLead.Email
        );
        insert testContactPointEmail;

        emailVerificationController controllerUnderTest = new emailVerificationController();
        ApexPages.currentPage().getParameters().put('leadId', newLead.Id);

        Test.startTest();
        controllerUnderTest.verificarEmail();
        Test.stopTest();

        // Verificar que el ContactPointEmail se actualizo
        ContactPointEmail updatedCPE = [SELECT Id, verifiedEmailContact__c FROM ContactPointEmail WHERE Id = :testContactPointEmail.Id LIMIT 1];
        System.assertEquals(true, updatedCPE.verifiedEmailContact__c);
    }
}