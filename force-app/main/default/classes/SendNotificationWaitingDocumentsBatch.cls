/**
 * @description       : 
 * @author            : diego.jacanamijoy@oc.vasscompany.com
 * @group             : 
 * @last modified on  : 08-11-2024
 * @last modified by  : carlos.vivas@oc.vasscompany.com
**/
public with sharing class SendNotificationWaitingDocumentsBatch implements Database.Batchable<sObject>, Database.Stateful, Schedulable {

    public static final String EMAIL_TEMPLATE_NAME = 'Email Template Status Suspended ClaimCoverage';

    public Database.QueryLocator start(Database.BatchableContext bc) {

        //Metodo para extraer la informacion de la metada valor de la fecuencia en dias.
        SuspendedNotificationConfiguration__mdt notificationSetting = SuspendedNotificationConfiguration__mdt.getInstance('NotifySuspended');

        //Se realiza la validacion de calcular ala fecha actual restarle el valor de la frecuencia en dias.
        Date dateNotification = Date.today().addDays(Integer.valueOf(-notificationSetting.Frequency__c));
        Date dateNotNotification = Date.today().addYears(Integer.valueOf(-notificationSetting.NotificationValidity__c));

        //Select que permite extraer la informacion del ClaimCoverage 
        String query = 'SELECT Id, CS_ClaimEmail__c, LastNotificationDateWaitingForDocument__c, FirstNotificationDateWaitingForDocument__c ' + 
                       'FROM ClaimCoverage ' +
                       'WHERE Status = \'Suspendido\' ' +
                       'AND CS_SubStatus__c = \'Documentos Solicitados\' ' +
                       'AND LastNotificationDateWaitingForDocument__c =: dateNotification ' +
                       'AND FirstNotificationDateWaitingForDocument__c >: dateNotNotification';
        return Database.getQueryLocator(query);
        
    }

    public void execute(Database.BatchableContext bc, List<sObject> records){
        // process each batch of records
        Boolean responseError = SendEmailHelper.sendMassEmails(EMAIL_TEMPLATE_NAME, 'CS_ClaimEmail__c', records);

        if (!responseError) {
            for (ClaimCoverage claimCov : (List<ClaimCoverage>)records) {
                claimCov.LastNotificationDateWaitingForDocument__c = System.today();
            }

            update records;
        }
    }

    public void finish(Database.BatchableContext bc){
        // execute any post-processing operations
    }
    
    public void execute(SchedulableContext sc) {
      SendNotificationWaitingDocumentsBatch batch = new SendNotificationWaitingDocumentsBatch(); 
      Database.executeBatch(batch);
   }
}