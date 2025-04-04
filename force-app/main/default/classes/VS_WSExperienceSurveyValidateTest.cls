@isTest
public class VS_WSExperienceSurveyValidateTest {
    
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
        String IdSurvey = 'IdSurvey';
        List<VS_WSExperienceSurveyValidate.AnswerData> answers = new List<VS_WSExperienceSurveyValidate.AnswerData>();
        answers.add(new VS_WSExperienceSurveyValidate.AnswerData('Q1', 'A1'));
        
        Test.startTest();
        VS_WSExperienceSurveyValidate token = VS_WSExperienceSurveyValidate.callout(bearerToken, acc, validationRegistry, IdSurvey, answers);
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
        String IdSurvey = 'IdSurvey';
        List<VS_WSExperienceSurveyValidate.AnswerData> answers = new List<VS_WSExperienceSurveyValidate.AnswerData>();
        answers.add(new VS_WSExperienceSurveyValidate.AnswerData('Q1', 'A1'));
        
        string body = '{"Validations":{"ValidLastName":"true","ValidName":"true","ValidExpeditionDate":"true"},"ExcludeClient":"false","Alerts":{"Alert":"false","AlertResponse":"03","AlertCode":"00"},"Result":"01","ValidationRegistry":"6306411","ProcessResult":"true","AvailableQueries":"1","Person":{"Identification":{"Number":"00000000000","Type":"1","ExpeditionDate":"123456700000"},"FullName":"AAAAA AAAAAAAA AAAAAAA"}}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200, body));
        
       
        Test.startTest();
        
        VS_WSExperienceSurveyValidate token = VS_WSExperienceSurveyValidate.callout(bearerToken, acc, validationRegistry, IdSurvey, answers);
        
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
        String IdSurvey = 'IdSurvey';
        List<VS_WSExperienceSurveyValidate.AnswerData> answers = new List<VS_WSExperienceSurveyValidate.AnswerData>();
        answers.add(new VS_WSExperienceSurveyValidate.AnswerData('Q1', 'A1'));
        
        string body = '{"Validations":{"ValidLastName":"true","ValidName":"true","ValidExpeditionDate":"true"},"ExcludeClient":"false","Alerts":{"Alert":"false","AlertResponse":"03","AlertCode":"00"},"Result":"01","ValidationRegistry":"6306411","ProcessResult":"true","AvailableQueries":"1","Person":{"Identification":{"Number":"00000000000","Type":"1","ExpeditionDate":"123456700000"},"FullName":"AAAAA AAAAAAAA AAAAAAA"}}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(400, body));
        
        
        Test.startTest();
        
        VS_WSExperienceSurveyValidate token = VS_WSExperienceSurveyValidate.callout(bearerToken, acc, validationRegistry, IdSurvey, answers);
        
        Test.stopTest();
        
        System.assertNotEquals(null, token.serviceResponse);
        System.assertEquals(false, token.successful);
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