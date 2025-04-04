/*
* ===============================================================================================================================
* Developer:             VASS COMPANY
* Creation Date:         23/02/2024
* Created by:            edwinc.martinez@oc.vasscompany.com
* Description:           Clase controladora para la página de autenticación en Salesforce.
* Last Modified by:      edwinc.martinez@oc.vasscompany.com (23/02/2024)
* Changes (Versions)

* -------------------------------------
* No.     Date        Author                      Description
* ------  ----------  ---------------------       ---------------
* 1.1     27/02/2024  Edwin Camilo Martinez       Se agrega la logica para actualizar el lead o el contacto en caso de que el prospecto ya fue convertido.
* ===============================================================================================================================
*/
public class emailVerificationController {

    public emailVerificationController() {
    }  
    
    public PageReference verificarEmail() {
        String idLead = ApexPages.currentPage().getParameters().get('leadId');
        
        if (idLead != null) {
            Lead lead = [SELECT Id, FirstName, LastName, Email, convertedAccountId, convertedContactId, verifiedEmail__c, IsConverted FROM Lead WHERE Id = :idLead LIMIT 1];
            
            if (lead != null && !lead.verifiedEmail__c) {
                lead.verifiedEmail__c = true;

                // Verificar si el Lead se ha convertido
                if (lead.IsConverted) {
                    // El Lead se ha convertido
                    Account convertedAccount = [SELECT Id FROM Account WHERE Id = :lead.convertedAccountId LIMIT 1];
                    if (convertedAccount != null) {
                        // Actualiza el campo
                        List<ContactPointEmail> contactPointEmails = [SELECT Id, verifiedEmailContact__c FROM ContactPointEmail WHERE ParentId = :lead.convertedAccountId AND EmailAddress = :lead.Email];
                        for (ContactPointEmail cpe : contactPointEmails) {
                            cpe.verifiedEmailContact__c = true;
                        }
                        update contactPointEmails;
                    }
                } else {
                    // Actualizar el lead solo si no está convertido
                    update lead;
                }

                return null;
            }
        }
        return null;
    }
}