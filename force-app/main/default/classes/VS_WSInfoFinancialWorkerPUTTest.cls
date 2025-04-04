@isTest
public class VS_WSInfoFinancialWorkerPUTTest {
	@isTest
    static void testCalloutHTTResponse200() {
        string body = '{"bankKey": "07","bankAccount": "10085111530","accountType": "2","typePay": "TE"}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200, body));
        
       
        Test.startTest();
        
        VS_WSInfoFinancialWorkerPUT result = VS_WSInfoFinancialWorkerPUT.callout('CC', '11111', '12345678', 'Cash', 'bankKey', 'bankAccount', 'accountType', 'typeNew', 'authorizationNumber', 'username');
        
        Test.stopTest();
        
        System.assertNotEquals(null, result.serviceResponse);
        System.assertEquals(true, result.successful);
    }
    
    @isTest
    static void testCalloutHTTResponse400() {
        string body = '';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(400, body));
        
        
        Test.startTest();
        
        VS_WSInfoFinancialWorker result = VS_WSInfoFinancialWorker.callout('CC', '11111', 'test');
        
        Test.stopTest();
        
        System.assertEquals(false, result.successful);
    }
    
    public class MockHttpResponseGenerator implements HttpCalloutMock {
        // Implement this interface method
        Public Integer statusCode;
        Public String stringBody;
        
        public MockHttpResponseGenerator(Integer staCode, String body){
            statusCode = staCode;
            stringBody = body;
        }
        public HTTPResponse respond(HTTPRequest req) {
            // Optionally, only send a mock response for a specific endpoint
            // and method.
            
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(stringBody);
            res.setStatusCode(statusCode);
            return res;
        }
    }
}