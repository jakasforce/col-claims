@isTest
public class VS_WSAuthenticationGetTokenTest {
    
    @isTest
    static void testCalloutHTTResponseFailed() {
        Test.startTest();
        VS_WSAuthenticationGetToken token = VS_WSAuthenticationGetToken.callout();
        Test.stopTest();
        
        System.assertEquals(null, token);
    }
    
	@isTest
    static void testCalloutHTTResponse200() {
        string body = '{"access_token":"valor_del_access_token","token_type":"valor_del_token_type","expires_in":3600}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200, body));
        
       
        Test.startTest();
        
        VS_WSAuthenticationGetToken token = VS_WSAuthenticationGetToken.callout();
        
        Test.stopTest();
        
        System.assertNotEquals(null, token.serviceResponse);
        System.assertEquals(true, token.successful);
    }
    
    @isTest
    static void testCalloutHTTResponse400() {
        string body = '{"access_token":"valor_del_access_token","token_type":"valor_del_token_type","expires_in":3600}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(400, body));
        
        
        Test.startTest();
        
        VS_WSAuthenticationGetToken token = VS_WSAuthenticationGetToken.callout();
        
        Test.stopTest();
        
        System.assertNotEquals(null, token.serviceResponse);
        System.assertEquals(false, token.successful);
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