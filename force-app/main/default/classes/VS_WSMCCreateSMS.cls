public class VS_WSMCCreateSMS {
    //Nombre del metadato que contiene el endpoint para este request
    public static String MDT_EDPOINT = 'Create_SMS_MC';
    //Variables generale servicio
    public HttpResponse serviceResponse;
    @AuraEnabled
    public Boolean successful;
 
	//Variables correspondientes al JSON de la respuesta del servicio   
	@AuraEnabled 
    public String requestId { get; set; }
    @AuraEnabled
    public Integer errorcode { get; set; }
    @AuraEnabled
    public String message { get; set; }
    
    @AuraEnabled
    public List<Response> responses { get; set; }
    
    public class Response {
        @AuraEnabled
    	public String messageKey { get; set; }
        @AuraEnabled
    	public Integer errorcode { get; set; }
        @AuraEnabled
    	public String message { get; set; }
    }

    public static VS_WSMCCreateSMS parse(String json){
        //Se convierte el JSON de las respuesta del servicio a una instancia de este clase
        return (VS_WSMCCreateSMS) System.JSON.deserialize(json, VS_WSMCCreateSMS.class);
    }
    public static HttpResponse calloutHTTResponse(String token, String celNumber, String message, String messageKey){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        
        VS_Callout_Configuration__mdt met = VS_Callout_Configuration__mdt.getInstance(MDT_EDPOINT);
        request.setEndpoint(met.Endpoint__c + messageKey);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Authorization', 'Bearer ' + token);
        //request.setHeader('accept', 'application/json');
        //request.setHeader('grant_type', 'CLIENT_CREDENTIALS');
        //request.setHeader('client_id', met.Client_Id__c);
        //request.setHeader('client_secret', met.Client_Secret__c);
        //
        String bodyString = setBodyRequest(celNumber, message, met.definitionKey__c);
        System.debug(bodyString);
        request.setBody(bodyString);
        
        HttpResponse response = http.send(request);
        System.debug('Request ' + MDT_EDPOINT + ': ' + request);
        
        return response;  
    }
    public static String setBodyRequest(String celNumber, String message, String definitionKey){
        Map<String, Object> jsonMap = new Map<String, Object>();
        
        Map<String, Object> attributes = new Map<String, Object>();
        attributes.put('message', message);
        
        Map<String, Object> recipient = new Map<String, Object>();
        recipient.put('to', celNumber);
        recipient.put('contactKey', 'ServiceCloud');
        recipient.put('attributes', attributes);
        
        Map<String, Object> subscriptions = new Map<String, Object>();
        subscriptions.put('resubscribe', true);
        
        jsonMap.put('definitionKey', definitionKey);
        jsonMap.put('recipient', recipient);
        jsonMap.put('subscriptions', subscriptions);
        
        String body = JSON.serialize(jsonMap);
        
        return  body;
    }
    public static VS_WSMCCreateSMS callout(String token, String celNumber, String message, String messageKey){
        try{
            HttpResponse response = calloutHTTResponse(token, celNumber, message, messageKey);
            VS_WSMCCreateSMS result =  new VS_WSMCCreateSMS();
            if(response.getStatusCode() != 200 && response.getStatusCode() != 202 && response.getStatusCode() != 201) {
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