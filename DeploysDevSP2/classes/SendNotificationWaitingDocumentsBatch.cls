/**
 * @description       : 
 * @author            : diego.jacanamijoy@oc.vasscompany.com
 * @group             : 
 * @last modified on  : 12-14-2023
 * @last modified by  : diego.jacanamijoy@oc.vasscompany.com
**/
public with sharing class SendNotificationWaitingDocumentsBatch implements Database.Batchable<sObject>, Database.Stateful, Schedulable {

    public static final String EMAIL_TEMPLATE_NAME = 'Email Template Status Suspended';

    public Database.QueryLocator start(Database.BatchableContext bc) {

        //Metodo para extraer la informacion de la metada valor de la fecuencia en dias.
        SuspendedNotificationConfiguration__mdt notificationSetting = SuspendedNotificationConfiguration__mdt.getInstance('NotifySuspended');

        //Se realiza la validacion de calcular ala fecha actual restarle el valor de la frecuencia en dias.
        Date dateNotification = Date.today().addDays(Integer.valueOf(-notificationSetting.Frequency__c));
        Date dateNotNotification = Date.today().addYears(Integer.valueOf(-notificationSetting.NotificationValidity__c));

        //Select que permite extraer la informacion del Claim 
            String query = 'SELECT ClaimEmail__c  FROM Claim WHERE Status = \'Suspendido\' AND CS_SubEstado__c = \'Documentos Solicitados\'';
 			query += 'AND LastNotificationDateWaitingForDocument__c =: dateNotification AND FirstNotificationDateWaitingForDocument__c >: dateNotNotification';
        return Database.getQueryLocator(query);
        
    }

    public void execute(Database.BatchableContext bc, List<sObject> records){
        // process each batch of records
        SendEmailHelper.sendMassEmails(EMAIL_TEMPLATE_NAME, 'ClaimEmail__c', records);
    }

    public void finish(Database.BatchableContext bc){
        // execute any post-processing operations
    }
    
    public void execute(SchedulableContext sc) {
      SendNotificationWaitingDocumentsBatch batch = new SendNotificationWaitingDocumentsBatch(); 
      Database.executeBatch(batch);
   }
}