public class VS_WSAuthenticationGetToken {
    //Nombre del metadato que contiene el endpoint para este request
    public static String MDT_EDPOINT = 'Token_Colmena';
    
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
    
    public static VS_WSAuthenticationGetToken parse(String json){
        //Se convierte el JSON de las respuesta del servicio a una instancia de este clase
        return (VS_WSAuthenticationGetToken) System.JSON.deserialize(json, VS_WSAuthenticationGetToken.class);
    }
    
    public static HttpResponse calloutHTTResponse(){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        
        VS_Callout_Configuration__mdt met = VS_Callout_Configuration__mdt.getInstance(MDT_EDPOINT);
        
        request.setEndpoint(met.Endpoint__c);
        request.setMethod('POST');
        //request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        request.setHeader('accept', 'application/json');
        request.setHeader('grant_type', 'CLIENT_CREDENTIALS');
        
        request.setHeader('client_id', met.Client_Id__c);
        request.setHeader('client_secret', met.Client_Secret__c);
        
        HttpResponse response = http.send(request);
        
        System.debug('Request ' + MDT_EDPOINT + ': ' + request);
        
        return response;  
    }
    
    public static VS_WSAuthenticationGetToken callout(){
        
        try{
            HttpResponse response = calloutHTTResponse();
            
            VS_WSAuthenticationGetToken result =  new VS_WSAuthenticationGetToken();
            if(response.getStatusCode() != 200) {
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