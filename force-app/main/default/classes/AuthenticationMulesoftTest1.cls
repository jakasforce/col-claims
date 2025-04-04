@IsTest
public class AuthenticationMulesoftTest1{
    @isTest
    static void testPostCalloutToken(){
        
        
        file_config_mulesoft__c testConfig = new file_config_mulesoft__c(
            Name = 'authentication-services-colmena',
            client_id__c = '8f423f7742274e768dae98f20629c8f9',
            client_secret__c = '35af0ac4EC324166bf5FE31659C83193',
            grant_type__c = 'CLIENT_CREDENTIALS',
            url_mulesoft__c = 'https://authentication-services-colmena-qa.us-e1.cloudhub.io/token'
        );
        insert testConfig;
		// Set mock callout class
    	Test.setMock(HttpCalloutMock.class, new AuthenticationMulesoftMockTest());
    	// This causes a fake response to be sent
    	// from the class that implements HttpCalloutMock.
    	Test.startTest();
    	AuthenticationMulesoft.GenerateToken();
        Test.stopTest();
    	// Verify that the response received contains fake values
    }
}