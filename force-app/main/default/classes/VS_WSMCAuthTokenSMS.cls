public class VS_WSMCAuthTokenSMS {
    //Nombre del metadato que contiene el endpoint para este request
    public static String MDT_EDPOINT = 'Token_SMS_MC';
    
    //Variables generale servicio
    public HttpResponse serviceResponse;
    @AuraEnabled
    public Boolean successful;

	//Variables correspondientes al JSON de la respuesta del servicio   
	@AuraEnabled 
    public String access_token { get; set; }
    @AuraEnabled
    public String token_type { get; set; }
    @AuraEnabled
    public Integer expires_in { get; set; }
    
    @AuraEnabled
    public String scope { get; set; }
    @AuraEnabled
    public String soap_instance_url { get; set; }
    @AuraEnabled
    public String rest_instance_url { get; set; }
    
    public static VS_WSMCAuthTokenSMS parse(String json){
        //Se convierte el JSON de las respuesta del servicio a una instancia de este clase
        return (VS_WSMCAuthTokenSMS) System.JSON.deserialize(json, VS_WSMCAuthTokenSMS.class);
    }
    
    public static HttpResponse calloutHTTResponse(String scope){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        
        VS_Callout_Configuration__mdt met = VS_Callout_Configuration__mdt.getInstance(MDT_EDPOINT);
        
        request.setEndpoint(met.Endpoint__c);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        //request.setHeader('accept', 'application/json');
        //request.setHeader('grant_type', 'CLIENT_CREDENTIALS');
        
        //request.setHeader('client_id', met.Client_Id__c);
        //request.setHeader('client_secret', met.Client_Secret__c);
        
        String bodyString = setBodyRequest('client_credentials', met.Client_Id__c, met.Client_Secret__c, scope);
        system.debug(bodyString);
        request.setBody(bodyString);
        
        HttpResponse response = http.send(request);
        
        System.debug('Request ' + MDT_EDPOINT + ': ' + request);
        
        return response;  
    }
    
    public static String setBodyRequest(String grant_type, String client_id, String client_secret, String scope){
        Map<String, Object> jsonMap = new Map<String, Object>();
        
        jsonMap.put('grant_type', grant_type);
        jsonMap.put('client_id', client_id);
        jsonMap.put('client_secret', client_secret);
        jsonMap.put('scope', scope);
        
        String body = JSON.serialize(jsonMap);
        
        return  body;
    }
    
    public static VS_WSMCAuthTokenSMS callout(String scope){
        
        try{
            HttpResponse response = calloutHTTResponse(scope);
            
            VS_WSMCAuthTokenSMS result =  new VS_WSMCAuthTokenSMS();
            if(response.getStatusCode() != 200 && response.getStatusCode() != 202) {
                System.debug('Response (!=200) ' + MDT_EDPOINT + ': ' + response.getBody());
                result.serviceResponse = response;
                result.successful = false;
            } else {
                System.debug('Response (200) ' + MDT_EDPOINT + ': ' + response.getBody());
                if(response.getBody() != null){
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