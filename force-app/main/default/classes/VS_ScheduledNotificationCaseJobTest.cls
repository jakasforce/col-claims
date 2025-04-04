@isTest
public class VS_ScheduledNotificationCaseJobTest {
    @isTest
    static void testExecute() {
        // Create test data required for the test context
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
        
        // Create an event associated with the case
        Event evento = new Event(
            RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Event' AND Name = 'scheduling SLE' LIMIT 1].Id,
            Subject = 'Test Event',
            Agendamiento_SLE__c = 'Cita',
            StartDateTime = Datetime.now().addHours(2),
            Numero_de_Caso__c = caso.Id,
            VS_Reminder_Appointment_Surgery_24h__c = false,
            DurationInMinutes = 5
        );
        insert evento;
        
        Test.startTest();
        VS_ScheduledNotificationCaseJob job = new VS_ScheduledNotificationCaseJob();
        job.execute(null);
        Test.stopTest();
        
        Integer expectedEventCount = 1;
    	Integer actualEventCount = [SELECT COUNT() FROM Event];
        System.assertEquals(expectedEventCount, actualEventCount, 'Se esperaba 1 evento creado');
    }
}