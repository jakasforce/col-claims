/*****************************************************************************************************************************
 * Apex Class Name	:	ClassStartServiceBCSTest
 * Version			:	1.0
 * Created Date	    :	18/06/2024
 * Created By       :   VASS COMPANY
 * Function 		: 	Clase con los metodos invocables para integracion con StarServices
 * Clase Cubre  	:	ClassStartServiceBCS
 *----------------------------------------------------------------------------------------------------------------------------
 *                     MODIFICATION LOG
 *----------------------------------------------------------------------------------------------------------------------------
 * Developer		     	Date			   	Description
 * ---------------------------------------------------------------------------------------------------------------------------
 * Fernando Torres        18/06/2024         Original Version
 *****************************************************************************************************************************/


@isTest
public class ClassStartServiceBCSTest {
    
    // Clase mock para simular las respuestas HTTP
    public class MockHttpResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"compositeResponse":[ {"body": {id:"21325465465231"}}]}'); // base64 de 'testbinary'
            res.setStatusCode(200);
            
            return res;
        }
    }
    
    
    //test del metodo especifico de guardar documento
    @isTest
    static void testGuardarDocumentoCaso(){
        CS_DocumentoCaso__c documentoCaso = new CS_DocumentoCaso__c(FileCode__c = '12345');
        insert documentoCaso;
        
        Test.startTest();
        ClassStartServiceBCS.guardarDocumento(documentoCaso.id,'dGVzdGJpbmFyeQ==');
        Test.stopTest();
    }

    
    //test del metodo especifico de descargar el doucumento 
    @isTest
    static void testDowloadDocumento() {
        // Insertar datos de prueba
        CS_DocumentoCaso__c documentoCaso = new CS_DocumentoCaso__c(FileCode__c = '12345');
        insert documentoCaso;
        
        Test.startTest();
        // Establecer el mock
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        String variableTest = ClassStartServiceBCS.obtenerIdContentVersion('test','test','test','test');
        Test.stopTest();
        
        // Validar los resultados
        System.assertEquals('21325465465231', variableTest, 'ra respuesta deberia ser la misma que se envia');
    }

    
    //test en caso de error al obtener el token 
    @isTest
    static void testErrorToken() {
        // Insertar datos de prueba
        CS_DocumentoCaso__c documentoCaso = new CS_DocumentoCaso__c(FileCode__c = '12345');
        insert documentoCaso;

        // Modificar el mock para devolver error en la obtención de token
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseErrorToken());

        Test.startTest();
        List<String> recordIds = new List<String>{documentoCaso.Id};
        ClassStartServiceBCS.DowloadDocumento(recordIds);
        Test.stopTest();

        // Validar que no se creó ningún ContentVersion ni ContentDocumentLink
        Integer contentVersionCount = [SELECT COUNT() FROM ContentVersion WHERE Title = 'pruebapdf1'];
        System.assertEquals(0, contentVersionCount, 'No debería haberse creado ningún ContentVersion');

        Integer contentLinkCount = [SELECT COUNT() FROM ContentDocumentLink WHERE LinkedEntityId = :documentoCaso.Id];
        System.assertEquals(0, contentLinkCount, 'No debería haberse creado ningún ContentDocumentLink');
    }
    

    // Clase mock para simular errores en la obtención de token
    public class MockHttpResponseErrorToken implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(400);
            return res;
        }
    }
    
    
}