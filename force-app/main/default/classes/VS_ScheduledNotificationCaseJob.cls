public with sharing class VS_ScheduledNotificationCaseJob implements Schedulable {
    public void execute(SchedulableContext sc) {
        // Get the current date and time
        Datetime now = Datetime.now();
        
        // Get all events that meet the conditions
        List<Event> eventsToProcess = [SELECT Id
                                      FROM Event
                                      WHERE VS_Reminder_Appointment_Surgery_24h__c != true AND VS_Reminder_Date__c != null AND VS_Reminder_Date__c <= :now
                                      AND RecordType.Name = 'scheduling SLE' 
                                      AND (Agendamiento_SLE__c = 'Cita' OR Agendamiento_SLE__c = 'Cirugía')
                                      AND Numero_de_Caso__c != null 
                                      AND StartDateTime != null AND StartDateTime > :now];

        // If there are Events that meet the conditions, send them to VS_QueueNotificationEventCase
        if (!eventsToProcess.isEmpty()) {
            List<Id> eventIds = new List<Id>();
            for (Event eventRecord : eventsToProcess) {
                eventIds.add(eventRecord.Id);
            }

            system.debug(eventIds);

            System.enqueueJob(new VS_QueueNotificationEventCase(eventIds, true));
        }
    }
}