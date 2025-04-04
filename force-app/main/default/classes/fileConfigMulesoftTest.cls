@isTest(SeeAllData = True)
private class fileConfigMulesoftTest {
     // Test method to verify the behavior of the constructor
    @isTest
    static void testConstructor() {
        // Create test data
        file_config_mulesoft__c testConfig = new file_config_mulesoft__c(
            Name = 'Test Config',
            client_id__c = 'TestClientId',
            client_secret__c = 'TestClientSecret',
            grant_type__c = 'TestGrantType',
            url_mulesoft__c = 'https://example.com/mulesoft'
        );
        insert testConfig;

        // Instantiate FileConfigMulesoft with the test data name
        FileConfigMulesoft config = new FileConfigMulesoft('Test Config');

        // Verify that the instance variables are initialized correctly
        System.assertEquals('TestClientId', config.client_id, 'client_id should be initialized correctly');
        System.assertEquals('TestClientSecret', config.client_secret, 'client_secret should be initialized correctly');
        System.assertEquals('TestGrantType', config.grant_type, 'grant_type should be initialized correctly');
        System.assertEquals('https://example.com/mulesoft', config.urlMulesoft, 'urlMulesoft should be initialized correctly');
    }
}