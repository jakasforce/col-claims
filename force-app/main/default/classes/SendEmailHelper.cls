/**
 * @description       : 
 * @author            : diego.jacanamijoy@oc.vasscompany.com
 * @group             : 
 * @last modified on  : 04-26-2024
 * @last modified by  : diego.jacanamijoy@oc.vasscompany.com
**/
public with sharing class SendEmailHelper {

    private static final string COLMENA_FROM_EMAIL = 'Colmena Seguros de Vida';

    
    /**
    * @description Method to send mass emails
    * @author diego.jacanamijoy@oc.vasscompany.com | 12-18-2023 
    * @param emailtemplateName 
    * @param emailField 
    * @param sobjectList 
    * @return Boolean 
    **/
    public static Boolean sendMassEmails(String emailtemplateName, String emailField, List<sObject> sobjectList) {

        OrgWideEmailAddress owea = [SELECT Id FROM OrgWideEmailAddress WHERE DisplayName =: COLMENA_FROM_EMAIL LIMIT 1];

        Boolean isError = false;
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

        // Get the email template
        EmailTemplate emailTemplate = [
            SELECT Id, Subject, Body, HtmlValue
            FROM EmailTemplate
            WHERE Name = :emailtemplateName
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];

        // Iterate through the collection of records and construct personalized email messages
        for (sObject record : sobjectList) {
            // Construct the email message using Apex Email Messaging classes
            Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(emailTemplate.Id, null, (Id)record.get('Id'));

            email.setToAddresses(new String[] { (String) record.get(emailField) });
            email.setWhatId((Id) record.get('Id'));
            email.setTreatTargetObjectAsRecipient(false);
            email.setTreatBodiesAsTemplate(true);
            email.setOrgWideEmailAddressId(owea.Id);
    
            emails.add(email);
        }

        // Send the batch of email messages
        Messaging.SendEmailResult[] results = Messaging.sendEmail(emails);

        // Process the results if needed
        for (Messaging.SendEmailResult result : results) {
            if (!result.isSuccess()) {
                isError = true;
                break;
            }
        }

        return isError;
    }
}