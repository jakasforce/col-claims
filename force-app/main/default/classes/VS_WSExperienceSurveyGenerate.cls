public class VS_WSExperienceSurveyGenerate {
    //Nombre del metadato que contiene el endpoint para este request
    public static String MDT_EDPOINT = 'Experience_Survey_Generate';
    
    //Variables generale servicio
    public HttpResponse serviceResponse;
    @AuraEnabled
    public Boolean successful;

	//Variables correspondientes al JSON de la respuesta del servicio
	@AuraEnabled 
    public SurveyData SurveyData { get; set; }
    
    public class SurveyData {
        @AuraEnabled
        public String Id { get; set; }
        @AuraEnabled
        public Alerts Alerts { get; set; }
        @AuraEnabled
        public String ExcludeClient { get; set; }
        @AuraEnabled
        public String Registry { get; set; }
        @AuraEnabled
        public String Result { get; set; }
        @AuraEnabled
        public List<Question> Question { get; set; }
    }
    
    public class Alerts {
        @AuraEnabled
        public String Alert { get; set; }
        @AuraEnabled
        public String Code { get; set; }
        @AuraEnabled
        public String Response { get; set; }
    }
    
    public class Question {
        @AuraEnabled
        public String Id { get; set; }
        @AuraEnabled
        public String Text { get; set; }
        @AuraEnabled
        public String Order { get; set; }
        @AuraEnabled
        public String CorrectAnswerId { get; set; }
        @AuraEnabled
        public String Weight { get; set; }
        @AuraEnabled
        public List<Answer> Answer { get; set; }
    }
    
    public class Answer {
        @AuraEnabled
        public String Id { get; set; }
        @AuraEnabled
        public String Text { get; set; }
    }
    
    public static VS_WSExperienceSurveyGenerate parse(String json){
		return (VS_WSExperienceSurveyGenerate) System.JSON.deserialize(json, VS_WSExperienceSurveyGenerate.class);
	}
    
    public static String setBodyRequest(Account acc, String validationRegistry){
        Map<String, Object> identificationMap = new Map<String, Object>();
        identificationMap.put('Number', acc.CS_NumeroIdentificacionCP__pc);
        identificationMap.put('Type', acc.CS_TipoIdentificacionCP__pc);
        
        Map<String, Object> surveyRequestMap = new Map<String, Object>();
        surveyRequestMap.put('Identification', identificationMap);
        surveyRequestMap.put('ValidationRegistry', validationRegistry);
        
        Map<String, Object> jsonMap = new Map<String, Object>();
        jsonMap.put('SurveyRequest', surveyRequestMap);
        
        String body = JSON.serialize(jsonMap);
        
        return  body;
    }
    
    public static HttpResponse calloutHTTResponse(Account acc, String bearerToken, String validationRegistry){
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
        
        String bodyString = setBodyRequest(acc, validationRegistry);
        request.setBody(bodyString);
        System.debug('Request Body ' + MDT_EDPOINT + ': ' + bodyString);
        request.setHeader('Authorization', 'Bearer ' + bearerToken);
        
        HttpResponse response = http.send(request);
        
        System.debug('Request ' + MDT_EDPOINT + ': ' + request);
        
        return response;  
    }
    
    public static VS_WSExperienceSurveyGenerate callout(String bearerToken, Account acc, String validationRegistry){
        
        try{
            HttpResponse response = calloutHTTResponse(acc, bearerToken, validationRegistry);
            
            VS_WSExperienceSurveyGenerate result =  new VS_WSExperienceSurveyGenerate();
            if(response.getStatusCode() != 200) {
                System.debug('Response (!=200) ' + MDT_EDPOINT + ': ' + response.getBody());
                result.serviceResponse = response;
                result.successful = false;
            } else {
                System.debug('Response (200) ' + MDT_EDPOINT + ': ' + response.getBody());
                if(response.getBody() != null){
                    //string body = '{"SurveyData":{"Id":"TestIdGenerate","Alerts":{"Alert":"false","Code":"","Response":""},"ExcludeClient":"false","Registry":"4512616","Result":"02","Question":[{"Id":"005003003","Text":"CON CUAL DE LAS SIGUIENTES ENTIDADES USTED TIENE O HA TENIDO EN LOS ULTIMOS 5 AÑOS (ENTRE NOVIEMBRE DE 2016 Y OCTUBRE DE 2021) UN/UNA CREDITO DE VIVIENDA  ?","Order":"1","CorrectAnswerId":"00","Weight":"3","Answer":[{"Id":"001","Text":"BANCO AV VILLAS S.A."},{"Id":"002","Text":"BANCO GNB SUDAMERIS S A"},{"Id":"003","Text":"BANCO DE BOGOTA S. A."},{"Id":"004","Text":"COMFAMA - CAJA DE COMPENSACION"},{"Id":"005","Text":"BANCO DAVIVIENDA S.A."},{"Id":"006","Text":"NINGUNA DE LAS ANTERIORES"}]},{"Id":"005013001","Text":"EL VALOR DE LA CUOTA DE AGOSTO DE 2021 DE SU CREDITO ROTATIVO CON BANCO COLPATRIA MULTIBANCA COLPATRIA S.A. ESTABA ENTRE:","Order":"2","CorrectAnswerId":"00","Weight":"3","Answer":[{"Id":"001","Text":"$30,001 Y $89,000"},{"Id":"002","Text":"$89,001 Y $148,000"},{"Id":"003","Text":"$148,001 Y $207,000"},{"Id":"004","Text":"$207,001 Y $266,000"},{"Id":"005","Text":"$266,001 Y $325,000"},{"Id":"006","Text":"NO TENGO CREDITO ROTATIVO CON LA ENTIDAD"}]},{"Id":"005006001","Text":"HACE CUANTO TIEMPO TIENE USTED UN/UNA CREDITO EDUCATIVO  CON ICETEX","Order":"3","CorrectAnswerId":"00","Weight":"4","Answer":[{"Id":"001","Text":"ENTRE 0 Y 3 AÑOS"},{"Id":"002","Text":"ENTRE 4 Y 7 AÑOS"},{"Id":"003","Text":"ENTRE 8 Y 12 AÑOS"},{"Id":"004","Text":"ENTRE 13 Y 16 AÑOS"},{"Id":"005","Text":"17 AÑOS O MAS"},{"Id":"006","Text":"NO TENGO CREDITO EDUCATIVO CON LA ENTIDAD"}]},{"Id":"005007002","Text":"HACE CUANTO TIEMPO TIENE SU CREDITO HIPOTECARIO CON BANCO COLPATRIA MULTIBANCA COLPATRIA S.A.?","Order":"4","CorrectAnswerId":"00","Weight":"1","Answer":[{"Id":"001","Text":"ENTRE 0 Y 2 AÑOS"},{"Id":"002","Text":"ENTRE 3 Y 4 AÑOS"},{"Id":"003","Text":"ENTRE 5 Y 7 AÑOS"},{"Id":"004","Text":"ENTRE 8 Y 14 AÑOS"},{"Id":"005","Text":"15 AÑOS O MAS"},{"Id":"006","Text":"NO TENGO CREDITO DE VIVIENDA CON LA ENTIDAD"}]}]}}';
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