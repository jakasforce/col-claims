public class VS_WSExperienceSurveyValidate {
    //Nombre del metadato que contiene el endpoint para este request
    public static String MDT_EDPOINT = 'Experience_Survey_Validate';
    
    //Variables generales servicio
    public HttpResponse serviceResponse;
    @AuraEnabled
    public Boolean successful;

	//Variables correspondientes al JSON de la respuesta del servicio 
	@AuraEnabled
    public Evaluation Evaluation { get; set; }
    
    public class Evaluation {
        @AuraEnabled
        public String Result { get; set; }
        @AuraEnabled
        public String Approval { get; set; }
        @AuraEnabled
        public String CompleteSurvey { get; set; }
        @AuraEnabled
        public String Score { get; set; }
        @AuraEnabled
        public String SecurityCode { get; set; }
        @AuraEnabled
        public SurveyData SurveyData { get; set; }
        @AuraEnabled
        public String FullyApproval { get; set; }
    }
    
    public class SurveyData {
        @AuraEnabled
        public String Id { get; set; }
        @AuraEnabled
        public String Registry { get; set; }
    }
    
    //Clase DTO para armar el body del request
    public class AnswerData {
        @AuraEnabled
        public String QuestionId { get; set; }
        @AuraEnabled
        public String AnswerId { get; set; }
        
        public AnswerData(String questionId, String answerId) {
            this.QuestionId = questionId;
            this.AnswerId = answerId;
        }
    }
    
    public static VS_WSExperienceSurveyValidate parse(String json){
		return (VS_WSExperienceSurveyValidate) System.JSON.deserialize(json, VS_WSExperienceSurveyValidate.class);
	}
    
    public static String setBodyRequest(Account acc, String registry, String IdSurvey, List<AnswerData> answers){ 
        Map<String, Object> jsonMap = new Map<String, Object>();
        
        Map<String, Object> answersMap = new Map<String, Object>();
        Map<String, Object> surveyDataMap = new Map<String, Object>();
        Map<String, Object> identificationMap = new Map<String, Object>();
        
        surveyDataMap.put('Id', IdSurvey);
        surveyDataMap.put('Registry', registry);
        
        identificationMap.put('Number', acc.CS_NumeroIdentificacionCP__pc);
        identificationMap.put('Type', acc.CS_TipoIdentificacionCP__pc);
        
        answersMap.put('SurveyData', surveyDataMap);
        answersMap.put('Identification', identificationMap);
        
        List<Map<String, Object>> answerList = new List<Map<String, Object>>();
        for (AnswerData answer : answers) {
            Map<String, Object> answerMap = new Map<String, Object>();
            answerMap.put('QuestionId', answer.QuestionId);
            answerMap.put('AnswerId', answer.AnswerId);
            answerList.add(answerMap);
        }
        
        answersMap.put('Answer', answerList);
        
        jsonMap.put('Answers', answersMap);
        
        String body = JSON.serialize(jsonMap);
        
        return  body;
    }
    
    public static HttpResponse calloutHTTResponse(Account acc, String bearerToken, String registry, String IdSurvey, List<AnswerData> answers){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        
        VS_Callout_Configuration__mdt met = VS_Callout_Configuration__mdt.getInstance(MDT_EDPOINT);
        
        request.setEndpoint(met.Endpoint__c);
        request.setMethod('POST');
        //request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        request.setHeader('accept', 'application/json');
        request.setHeader('content-type', 'application/json');
        
        request.setHeader('client_id', met.Client_Id__c);
        request.setHeader('client_secret', met.Client_Secret__c);
        
        String bodyString = setBodyRequest(acc, registry, IdSurvey, answers);
        request.setBody(bodyString);
        System.debug('Request Body ' + MDT_EDPOINT + ': ' + bodyString);
        request.setHeader('Authorization', 'Bearer ' + bearerToken);
        
        HttpResponse response = http.send(request);
        
        System.debug('Request ' + MDT_EDPOINT + ': ' + request);
        
        return response;  
    }
    
    public static VS_WSExperienceSurveyValidate callout(String bearerToken, Account acc, String registry, String IdSurvey, List<AnswerData> answers){
        
        try{
            HttpResponse response = calloutHTTResponse(acc, bearerToken, registry, IdSurvey, answers);
            
            VS_WSExperienceSurveyValidate result =  new VS_WSExperienceSurveyValidate();
            if(response.getStatusCode() != 200) {
                System.debug('Response (!=200) ' + MDT_EDPOINT + ': ' + response.getBody());
                result.serviceResponse = response;
                result.successful = false;
            } else {
                System.debug('Response (200) ' + MDT_EDPOINT + ': ' + response.getBody());
                if(response.getBody() != null){
                    //String body = '{"Evaluation":{"Result":"true","Approval":"true","CompleteSurvey":"true","Score":"000","SecurityCode":"ZSU34E4","SurveyData":{"Id":"50080915","Registry":"4512617"},"FullyApproval":"false"}}';
                    //result = parse(body);
                    result = parse(response.getBody());
                }
                result.serviceResponse = response;
                result.successful = true;
            }
            
            return result;
        }catch(Exception e){
            System.debug('Error deserialize response: ' + e.getMessage());
            return null;
        } 
    }
}