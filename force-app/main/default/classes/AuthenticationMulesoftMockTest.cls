@IsTest
global class AuthenticationMulesoftMockTest implements HttpCalloutMock {
    
    
    global HTTPResponse respond(HTTPRequest request) {
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setHeader('client_id', '123');
        response.setHeader('client_secret', '123');
        response.setHeader('grant_type', '123');
        response.setBody('{ "access_token": "dcxepAOlJ1fcZfcJ_3FCPkOnC4H4gRjZ8ZEseEPjRz9en2QYIpC6IQplWPKCK7aFtSEwM_D-dJihGE-qUtG85w", "token_type": "Bearer", "expires_in": 7200}');
        response.setStatusCode(200);
        return response;
    }
}