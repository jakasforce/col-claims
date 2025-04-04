@isTest
public class VS_EventTriggerHandlerTest {
    @isTest
    static void testInsertTriggerCoverage() {
        Test.startTest();
        
        List<RecordType> recordTypeList = [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Case' AND Name = 'Formulario' LIMIT 1];
        Case caso = new Case(
            Subject = 'Test Case',
            CS_Pais__c = '170',
            CS_Municipio__c = '23001',
            CS_Departamento__c = '23',
            RecordTypeId = recordTypeList[0].Id
            // CS_Subtipo__c = '2',
            // CS_ProductoColmenaM2__c = 'Accidentes Personales',
            // CS_ProductoM2__c = '124',
            // CS_EstrategiaM2__c = 'Telemercadeo',
            // CS_RamoM2__c = 'Accidentes Personales',
        );
        insert caso;
        
        List<Event> events = new List<Event>();
        Id idRecordType;
        List<RecordType> rt = [SELECT Id FROM RecordType WHERE SObjectType = 'Event' AND Name = 'scheduling SLE' LIMIT 1];
        idRecordType = rt[0].Id;
        for(Integer i = 0; i < 2; i++) {
            events.add(new Event(
                RecordTypeId = idRecordType,
                Subject = 'Test Event' + i,
                Agendamiento_SLE__c = 'Cita',
                StartDateTime = Datetime.now(),
                Numero_de_Caso__c = caso.Id,
                DurationInMinutes = 5
            ));
        }
        insert events;
        
        Test.stopTest();
        
        Integer expectedEventCount = 2;
    	Integer actualEventCount = [SELECT COUNT() FROM Event];
        System.assertEquals(expectedEventCount, actualEventCount, 'Se esperaban 2 eventos creados');
    }
    
    @isTest
    static void testUpdateTriggerCoverage() {
        List<RecordType> recordTypeList = [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Case' AND Name = 'Formulario' LIMIT 1];
        Case caso = new Case(
            Subject = 'Test Case',
            CS_Pais__c = '170',
            CS_Municipio__c = '23001',
            CS_Departamento__c = '23',
            RecordTypeId = recordTypeList[0].Id
            // CS_Subtipo__c = '2',
            // CS_ProductoColmenaM2__c = 'Accidentes Personales',
            // CS_ProductoM2__c = '124',
            // CS_EstrategiaM2__c = 'Telemercadeo',
            // CS_RamoM2__c = 'Accidentes Personales',
        );
        insert caso;
        
        List<Event> events = new List<Event>();
        Id idRecordType;
        List<RecordType> rt = [SELECT Id FROM RecordType WHERE SObjectType = 'Event' AND Name = 'scheduling SLE' LIMIT 1];
        idRecordType = rt[0].Id;
        for(Integer i = 0; i < 2; i++) {
            events.add(new Event(
                RecordTypeId = idRecordType,
                Subject = 'Test Event' + i,
                Agendamiento_SLE__c = 'Cita',
                StartDateTime = Datetime.now().addHours(48),
                Numero_de_Caso__c = caso.Id,
                DurationInMinutes = 5
            ));
        }
        insert events;
        
        List<Event> eventsForUpdate = [Select Id, Subject, StartDateTime From Event];
        for (Event e : eventsForUpdate) {
            e.Subject = 'Updated Test Event';
            e.StartDateTime = Datetime.now().addHours(72);
        }
        
        Test.startTest();
        update eventsForUpdate;
        Test.stopTest();
        
        List<Event> updatedEvents = [SELECT Id, Subject FROM Event];
        for(Event e : updatedEvents) {
            System.assertEquals('Updated Test Event', e.Subject);
        }
    }
}