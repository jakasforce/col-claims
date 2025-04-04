@isTest
public class VS_QueueNotificationEventCaseTest {
    @testSetup
    static void setupTestData() {
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
        
        Id idRecordType;
        List<RecordType> rt = [SELECT Id FROM RecordType WHERE SObjectType = 'Event' AND Name = 'scheduling SLE' LIMIT 1];
        if (rt != null) {
            idRecordType = rt[0].Id;
            
            Event evento = new Event(
                RecordTypeId = idRecordType,
                Subject = 'Evento de Prueba',
                Agendamiento_SLE__c = 'Cita',
                StartDateTime = Datetime.now().addDays(1),
                Numero_de_Caso__c = caso.Id,
                DurationInMinutes = 5
            );
            insert evento;
        }
    }
    
    @isTest
    static void testQueueableExecution() {
        List<Event> eventos = [SELECT Id FROM Event WHERE Agendamiento_SLE__c = 'Cita'];
        List<Id> eventIds = new List<Id>();
        for (Event e : eventos) {
            eventIds.add(e.Id);
        }
        
        String responseBody = '{"access_token": "test_access_token", "successful": true, "errorcode": 0}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200, responseBody));
        
        Test.startTest();
        System.enqueueJob(new VS_QueueNotificationEventCase(eventIds));
        Test.stopTest();
        
        List<Event> eventosProcesados = [SELECT VS_Reminder_Appointment_Surgery__c FROM Event WHERE Id IN :eventIds];
        for (Event e : eventosProcesados) {
            System.assertEquals(true, e.VS_Reminder_Appointment_Surgery__c);
        }
    }
    
    public class MockHttpResponseGenerator implements HttpCalloutMock {
        Integer statusCode;
        String responseBody;
        
        public MockHttpResponseGenerator(Integer statusCode, String responseBody) {
            this.statusCode = statusCode;
            this.responseBody = responseBody;
        }
        
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(responseBody);
            res.setStatusCode(statusCode);
            return res;
        }
    }
}