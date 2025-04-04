@isTest
public class VS_WSSpecialAgreementTest {

    
	@isTest
    static void testCalloutHTTResponse200() {
        string body = '[{"id": 1,"codeSpecialAgreement": "6,8,18,20,29"}]';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200, body));
        
       
        Test.startTest();
        
        VS_WSSpecialAgreement result = VS_WSSpecialAgreement.callout('CC', '11111');
        
        Test.stopTest();
        
        System.assertNotEquals(null, result.serviceResponse);
        System.assertEquals(true, result.successful);
    }
    
    @isTest
    static void testCalloutHTTResponse400() {
        string body = '';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(400, body));
        
        
        Test.startTest();
        
        VS_WSSpecialAgreement result = VS_WSSpecialAgreement.callout('CC', '11111');
        
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