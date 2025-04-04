@isTest
public class VS_WSInfoFinancialWorkerTest {

    
	@isTest
    static void testCalloutHTTResponse200() {
        string body = '{"bankKey": "07","bankAccount": "10085111530","accountType": "2","typePay": "TE"}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200, body));
        
       
        Test.startTest();
        
        VS_WSInfoFinancialWorker result = VS_WSInfoFinancialWorker.callout('CC', '11111', 'test');
        
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
        Public Integer statusCode;
        Public String stringBody;
        
        public MockHttpResponseGenerator(Integer staCode, String body){
            statusCode = staCode;
            stringBody = body;
        }
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(stringBody);
            res.setStatusCode(statusCode);
            return res;
        }
    }
}