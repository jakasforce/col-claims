@isTest
public class VS_WSMCAuthTokenSMSTest {
    
    // Test method to verify successful service response.
    @isTest
    static void testCalloutHTTResponse200() {
        String responseBody = '{"access_token": "test_access_token","token_type": "Bearer","expires_in": 3600,"scope": "sms","soap_instance_url": "https://example.com","rest_instance_url": "https://example.com"}';
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200, responseBody));
        
        Test.startTest();
        VS_WSMCAuthTokenSMS result = VS_WSMCAuthTokenSMS.callout('sms');
        Test.stopTest();
        
        Assert.isNotNull(result.access_token);
        Assert.isNotNull(result.token_type);
        Assert.isNotNull(result.expires_in);
        Assert.isNotNull(result.scope);
        Assert.isNotNull(result.soap_instance_url);
        Assert.isNotNull(result.rest_instance_url);
        System.assertNotEquals(null, result.serviceResponse);
        System.assertEquals(true, result.successful);
    }
    
    // Test method to verify service error response.
    @isTest
    static void testCalloutHTTResponseError() {
        String responseBody = '';
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(400, responseBody));
        
        Test.startTest();
        VS_WSMCAuthTokenSMS result = VS_WSMCAuthTokenSMS.callout('sms');
        Test.stopTest();
        
        System.assertEquals(false, result.successful);
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