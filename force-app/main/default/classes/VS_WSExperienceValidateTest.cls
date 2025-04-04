@isTest
public class VS_WSExperienceValidateTest {
    @isTest
    static void instanceClass() {
        // Crear una instancia del objeto VS_WSExperienceValidate
        VS_WSExperienceValidate experienceValidate = new VS_WSExperienceValidate();

        // Llenar los campos con valores de ejemplo
        experienceValidate.Validations = new VS_WSExperienceValidate.Validations();
        experienceValidate.Validations.ValidLastName = 'Smith';
        experienceValidate.Validations.ValidName = 'John';
        experienceValidate.Validations.ValidExpeditionDate = '2023-07-18';

        experienceValidate.ExcludeClient = 'Exclude';
        
        experienceValidate.Alerts = new VS_WSExperienceValidate.Alerts();
        experienceValidate.Alerts.Alert = 'Alert message';
        experienceValidate.Alerts.AlertResponse = 'Alert response';
        experienceValidate.Alerts.AlertCode = 'AL001';

        experienceValidate.Result = 'Success';
        experienceValidate.ValidationRegistry = 'Validation123';
        experienceValidate.ProcessResult = 'Process success';
        experienceValidate.AvailableQueries = 5;

        experienceValidate.Person = new VS_WSExperienceValidate.Person();
        experienceValidate.Person.FullName = 'John Smith';
        experienceValidate.Person.Identification = new VS_WSExperienceValidate.Identification();
        experienceValidate.Person.Identification.Numbe_r = '12345';
        experienceValidate.Person.Identification.Typ_e = 'Type1';
        experienceValidate.Person.Identification.ExpeditionDate = '2022-06-15';
    }
    
    @isTest
    static void testCalloutHTTResponseFailed() {
        Account acc = new Account();
        acc.CS_TipoIdentificacionCP__pc = '1';
        acc.CS_NumeroIdentificacionCP__pc = '1007389654';
        acc.CS_FechaExpedicion__pc = Date.valueOf('2018-06-26');
        acc.LastName = 'Account Test';
        acc.Suffix = 'Test';
        acc.FirstName = 'Account';
        acc.PersonMobilePhone = '1111111111';
        
        insert acc;
        
        String bearerToken = 'token';
        
        Test.startTest();
        VS_WSExperienceValidate token = VS_WSExperienceValidate.callout(bearerToken, acc, false);
        Test.stopTest();
        
        // System.assertEquals();
    }
    
	@isTest
    static void testCalloutHTTResponse200() {
        Account acc = new Account();
        acc.CS_TipoIdentificacionCP__pc = '1';
        acc.CS_NumeroIdentificacionCP__pc = '1007389654';
        acc.CS_FechaExpedicion__pc = Date.valueOf('2018-06-26');
        acc.LastName = 'Account Test';
        acc.Suffix = 'Test';
        acc.FirstName = 'Account';
        acc.PersonMobilePhone = '1111111111';
        
        insert acc;
        
        String bearerToken = 'token';
        
        string body = '{"Validations":{"ValidLastName":"true","ValidName":"true","ValidExpeditionDate":"true"},"ExcludeClient":"false","Alerts":{"Alert":"false","AlertResponse":"03","AlertCode":"00"},"Result":"01","ValidationRegistry":"6306411","ProcessResult":"true","AvailableQueries":"1","Person":{"Identification":{"Number":"00000000000","Type":"1","ExpeditionDate":"123456700000"},"FullName":"AAAAA AAAAAAAA AAAAAAA"}}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200, body));
    
       
        Test.startTest();
        
        VS_WSExperienceValidate token = VS_WSExperienceValidate.callout(bearerToken, acc, false);
        
        Test.stopTest();
        
        System.assertNotEquals(null, token.serviceResponse);
        System.assertEquals(true, token.successful);
    }
    
    @isTest
    static void testCalloutHTTResponse400() {
        Account acc = new Account();
        acc.CS_TipoIdentificacionCP__pc = '1';
        acc.CS_NumeroIdentificacionCP__pc = '1007389654';
        acc.CS_FechaExpedicion__pc = Date.valueOf('2018-06-26');
        acc.LastName = 'Account Test';
        acc.Suffix = 'Test';
        acc.FirstName = 'Account';
        acc.PersonMobilePhone = '1111111111';
        
        insert acc;
        
        String bearerToken = 'token';
        
        string body = '{"Validations":{"ValidLastName":"true","ValidName":"true","ValidExpeditionDate":"true"},"ExcludeClient":"false","Alerts":{"Alert":"false","AlertResponse":"03","AlertCode":"00"},"Result":"01","ValidationRegistry":"6306411","ProcessResult":"true","AvailableQueries":"1","Person":{"Identification":{"Number":"00000000000","Type":"1","ExpeditionDate":"123456700000"},"FullName":"AAAAA AAAAAAAA AAAAAAA"}}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(400, body));
        
        
        Test.startTest();
        
        VS_WSExperienceValidate token = VS_WSExperienceValidate.callout(bearerToken, acc, false);
        
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