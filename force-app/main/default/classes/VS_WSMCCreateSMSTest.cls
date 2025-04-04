@isTest
public class VS_WSMCCreateSMSTest {
    
    // Test method to verify successful service response.
    @isTest
    static void testCalloutHTTResponse200() {
        String responseBody = '{"requestId": "test_request_id","errorcode": null,"message": "Success","responses": [{"messageKey": "test_message_key","errorcode": null,"message": "Success"}]}';
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200, responseBody));
        
        Test.startTest();
        VS_WSMCCreateSMS result = VS_WSMCCreateSMS.callout('test_token', '123456789', 'Test message', 'test_message_key');
        Test.stopTest();
        
        Assert.isNotNull(result.requestId);
        Assert.isNull(result.errorcode);
        Assert.isNotNull(result.message);
        System.assertNotEquals(null, result.serviceResponse);
        System.assertEquals(true, result.successful);
    }
    
    // Test method to verify service error response.
    @isTest
    static void testCalloutHTTResponseError() {
        String responseBody = ''; // Empty body to simulate an error response.
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(400, responseBody));
        
        Test.startTest();
        VS_WSMCCreateSMS result = VS_WSMCCreateSMS.callout('test_token', '123456789', 'Test message', 'test_message_key');
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