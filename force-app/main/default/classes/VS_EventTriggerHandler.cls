public with sharing class VS_EventTriggerHandler {
    public static void beforeUpdate(List<Event> oldList, List<Event> newList) {
        system.debug('--- Trigger Before Update ---');
        for(Integer i = 0; i < newList.size(); i++) {
            if(isNotifiableCitaCirugia(newList[i])){
                if(newList[i].StartDateTime != null && newList[i].StartDateTime != oldList[i].StartDateTime){
                    newList[i].VS_Reminder_Appointment_Surgery__c = false;

                    if(newList[i].VS_Reminder_Date__c >= DateTime.now()){
                        newList[i].VS_Reminder_Appointment_Surgery_24h__c = false;
                    }else{
                        newList[i].VS_Reminder_Appointment_Surgery_24h__c = true;
                    }
                }
            }
        }
    }
    public static void afterInsert(List<Event> newList) {
        system.debug('--- Trigger After Insert ---');

        sendNotificationCitaCirugia(newList);

    }
    public static void afterUpdate(List<Event> oldList, List<Event> newList) {
        system.debug('--- Trigger After Update ---');
        List<Event> eventsToValidateNotification = new List<Event>();
		for(Integer i = 0; i < newList.size(); i++) {
            if(isNotifiableCitaCirugia(newList[i])){
                if(newList[i].StartDateTime != null && newList[i].StartDateTime != oldList[i].StartDateTime){
                    eventsToValidateNotification.add(newList[i]);
                }
            }
        }
        sendNotificationCitaCirugia(eventsToValidateNotification);
        
    }

    public static void sendNotificationCitaCirugia(List<Event> newList){
        List<Id> eventToSendNotification = new List<Id>();
        for(Event eve : newList){
            if(isNotifiableCitaCirugia(eve) && !eve.VS_Reminder_Appointment_Surgery__c){
                eventToSendNotification.add(eve.Id);
            }
        }

        if(eventToSendNotification.size() > 0){
            if(!Test.isRunningTest()){
                System.enqueueJob(new VS_QueueNotificationEventCase(eventToSendNotification));
            }
        }
    }

    public static Boolean isNotifiableCitaCirugia(Event eve){
        if(eve.RecordTypeId != null){
            String recordTypeName = Schema.getGlobalDescribe().get('Event').getDescribe().getRecordTypeInfosById().get(eve.RecordTypeId).getName();
        	Datetime now = Datetime.now();
        	return (recordTypeName == 'scheduling SLE' && (eve.Agendamiento_SLE__c == 'Cita' || eve.Agendamiento_SLE__c == 'Cirugía')
                && eve.Numero_de_Caso__c != null && eve.StartDateTime != null && eve.StartDateTime > now);
        }
        return false;
        
    }
}