@isTest
public class VS_WSExperienceSurveyGenerateTest {
    
    @isTest
    static void testVS_WSExperienceSurveyGenerate() {
        // Crear una instancia del objeto VS_WSExperienceSurveyGenerate
        VS_WSExperienceSurveyGenerate experienceSurveyGenerate = new VS_WSExperienceSurveyGenerate();

        // Llenar los campos SurveyData con valores de ejemplo
        experienceSurveyGenerate.SurveyData = new VS_WSExperienceSurveyGenerate.SurveyData();
        experienceSurveyGenerate.SurveyData.Id = 'Survey123';

        experienceSurveyGenerate.SurveyData.Alerts = new VS_WSExperienceSurveyGenerate.Alerts();
        experienceSurveyGenerate.SurveyData.Alerts.Alert = 'Survey alert message';
        experienceSurveyGenerate.SurveyData.Alerts.Code = 'AL002';
        experienceSurveyGenerate.SurveyData.Alerts.Response = 'Survey alert response';

        experienceSurveyGenerate.SurveyData.ExcludeClient = 'Exclude';
        experienceSurveyGenerate.SurveyData.Registry = 'Registry123';
        experienceSurveyGenerate.SurveyData.Result = 'Success';

        experienceSurveyGenerate.SurveyData.Question = new List<VS_WSExperienceSurveyGenerate.Question>();

        // Llenar los campos de la lista Question con valores de ejemplo
        VS_WSExperienceSurveyGenerate.Question question1 = new VS_WSExperienceSurveyGenerate.Question();
        question1.Id = 'Q1';
        question1.Text = 'What is your name?';
        question1.Order = '1';
        question1.CorrectAnswerId = 'A1';
        question1.Weight = '1';
        question1.Answer = new List<VS_WSExperienceSurveyGenerate.Answer>();

        // Llenar los campos de la lista Answer con valores de ejemplo
        VS_WSExperienceSurveyGenerate.Answer answer1 = new VS_WSExperienceSurveyGenerate.Answer();
        answer1.Id = 'A1';
        answer1.Text = 'John';
        question1.Answer.add(answer1);

        VS_WSExperienceSurveyGenerate.Answer answer2 = new VS_WSExperienceSurveyGenerate.Answer();
        answer2.Id = 'A2';
        answer2.Text = 'Mary';
        question1.Answer.add(answer2);

        experienceSurveyGenerate.SurveyData.Question.add(question1);
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
        String validationRegistry = 'validationRegistry';
        
        Test.startTest();
        VS_WSExperienceSurveyGenerate token = VS_WSExperienceSurveyGenerate.callout(bearerToken, acc, validationRegistry);
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
        String validationRegistry = 'validationRegistry';
        
        string body = '{"Validations":{"ValidLastName":"true","ValidName":"true","ValidExpeditionDate":"true"},"ExcludeClient":"false","Alerts":{"Alert":"false","AlertResponse":"03","AlertCode":"00"},"Result":"01","ValidationRegistry":"6306411","ProcessResult":"true","AvailableQueries":"1","Person":{"Identification":{"Number":"00000000000","Type":"1","ExpeditionDate":"123456700000"},"FullName":"AAAAA AAAAAAAA AAAAAAA"}}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200, body));
        
       
        Test.startTest();
        
        VS_WSExperienceSurveyGenerate token = VS_WSExperienceSurveyGenerate.callout(bearerToken, acc, validationRegistry);
        
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
        String validationRegistry = 'validationRegistry';
        
        string body = '{"Validations":{"ValidLastName":"true","ValidName":"true","ValidExpeditionDate":"true"},"ExcludeClient":"false","Alerts":{"Alert":"false","AlertResponse":"03","AlertCode":"00"},"Result":"01","ValidationRegistry":"6306411","ProcessResult":"true","AvailableQueries":"1","Person":{"Identification":{"Number":"00000000000","Type":"1","ExpeditionDate":"123456700000"},"FullName":"AAAAA AAAAAAAA AAAAAAA"}}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(400, body));
        
        
        Test.startTest();
        
        VS_WSExperienceSurveyGenerate token = VS_WSExperienceSurveyGenerate.callout(bearerToken, acc, validationRegistry);
        
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