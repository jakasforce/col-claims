/**
* ===============================================================================================================================
* Developer:             VASS LATAM
* Creation Date:         20/09/2023
* Created by:            edgar.mora@vasscompany.com
* Description:           Clase Test que cubre la clase RestrictedListQuery_Cls.
* Last Modified by:      edgar.mora@vasscompany.com (25/09/2023)
* Version:               v1.0
* ===============================================================================================================================
**/
 
@isTest
public class RestrictedListQuery_Tst {
@isTest
    static void testProcesarStringParaLead() {
        // Crear un Lead de prueba
        // Crear una respuesta HTTP simulada con los datos 
        String jsonResponse = '[{"statement":{"naturalNational":{"age":{"max":"28","min":"22"},"idDetails":{"number":"01010137397","colony":"BOYACA","city":"NUEVO COLON","expeditionDate":"2018-07-04","state":"00"},"rut":false,"isValid":true,"fullName":"MARTINEZ MERCHAN EDWIN CAMILO","secondLastName":"MERCHAN","firstLastName":"MARTINEZ","name":"EDWIN CAMILO"},"lastName":"MARTINEZ","id":"1010137397","idType":"1","securityCode":"PZ17336","response":"14","dateOfQuery":"2023-08-27T21:05:04"}}]';
        // Configurar la respuesta simulada
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(jsonResponse, 200));
        Lead lead = new Lead();
        lead.Numero_de_documento__c = '1006269926';
        lead.Tipo_de_documento__c = '1';
        lead.FirstName = 'John';
        lead.MiddleName = 'Doe';
        lead.LastName = 'Smith';
        Lead.Email= 'e@mail.com';
        Lead.Company='John Smith';
        Lead.MobilePhone='3102325542';
        lead.TypePerson__c = 'Persona Natural';
        insert lead;

        List<String> inputStrings = new List<String>();
        inputStrings.add(lead.Id);
        Test.startTest();
        RestrictedListQuery_Cls.procesarStringParaLead(inputStrings);
        Test.stopTest();
 
 
    }
    @isTest
    static void testProcesarStringParaLead2() {
        // Crear un Lead de prueba
        Lead lead = new Lead();
        lead.Numero_de_documento__c = '1006269926';
        lead.Tipo_de_documento__c = '1';
        lead.FirstName = 'John';
        lead.MiddleName = 'Doe';
        lead.LastName = 'Smith';
        Lead.Email= 'e@mail.com';
        Lead.Company='John Smith';
        Lead.MobilePhone='3102322222';
        lead.TypePerson__c = 'Persona Jurídica';
        insert lead;

        List<String> inputStrings = new List<String>();
        inputStrings.add(lead.Id);
        //Test.startTest();
        RestrictedListQuery_Cls.procesarStringParaLead(inputStrings);
       // Test.stopTest();
 
       
 
    }
        // Clase MockHttpResponse
    private class MockHttpResponse implements HttpCalloutMock {
        private String response;
        private Integer statusCode;
        private CalloutException ex; // Cambiar el nombre de la variable
        public MockHttpResponse(String response, Integer statusCode) {
            this.response = response;
            this.statusCode = statusCode;
        }
        public MockHttpResponse(CalloutException ex) {
            this.ex = ex; // Cambiar la asignación
        }
        public HttpResponse respond(HttpRequest req) {
            if (ex != null) {
                throw ex; // Lanzar la excepción aquí si está configurada
            }
            HttpResponse res = new HttpResponse();
            res.setBody(response);
            res.setStatusCode(statusCode);
            return res;
        }
    }
}