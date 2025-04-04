public class VS_WSInfoFinancialWorkerPUT {
    //Nombre del metadato que contiene el endpoint para este request
    public static String MDT_EDPOINT = 'InfoFinancialWorker';
    
    //Variables generales servicio
    public HttpResponse serviceResponse;
    @AuraEnabled
    public Boolean successful;

	//Variables correspondientes al JSON de la respuesta del servicio   
	@AuraEnabled 
    public String error;
    @AuraEnabled
    public String errorType;
    @AuraEnabled
    public String message;
    @AuraEnabled
    public String transactionId;
    
    public static VS_WSInfoFinancialWorkerPUT parse(String json){
        //Se convierte el JSON de las respuesta del servicio a una instancia de este clase
        return (VS_WSInfoFinancialWorkerPUT) System.JSON.deserialize(json, VS_WSInfoFinancialWorkerPUT.class);
    }
    
    public static VS_WSInfoFinancialWorkerPUT callout(String bearerToken, String idType, String IdNumber, String typePay, String bankKey, String bankAccount, String accountType, String typeNew, String authorizationNumber, String username){
        
        try{
            HttpResponse response = calloutHTTResponse(bearerToken, idType, IdNumber, typePay, bankKey, bankAccount, accountType, typeNew, authorizationNumber, username);
            
            VS_WSInfoFinancialWorkerPUT result =  new VS_WSInfoFinancialWorkerPUT();
            if(response.getStatusCode() != 200) {
                System.debug('Response (!=200) ' + MDT_EDPOINT + ': ' + response.getBody());
                
                if(response.getBody() != null){
                    result = parse(response.getBody());
                }
                
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

    public static HttpResponse calloutHTTResponse(String bearerToken, String idType, String IdNumber, String typePay, String bankKey, String bankAccount, String accountType, String typeNew, String authorizationNumber, String username){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        
        VS_Callout_Configuration__mdt met = VS_Callout_Configuration__mdt.getInstance(MDT_EDPOINT);
        
        request.setMethod('PUT');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('accept', 'application/json');
        request.setHeader('Authorization', 'Bearer ' + bearerToken);
        //request.setHeader('grant_type', 'CLIENT_CREDENTIALS');
        
        request.setHeader('client_id', met.Client_Id__c);
        request.setHeader('client_secret', met.Client_Secret__c);

        String bodyString = setBodyRequest(idType, IdNumber, typePay, bankKey, bankAccount, accountType, typeNew, authorizationNumber, username);
        request.setBody(bodyString);
        System.debug('Request ' + bodyString);

        request.setEndpoint(met.Endpoint__c);
        
        HttpResponse response = http.send(request);
        
        System.debug('Request ' + MDT_EDPOINT + ': ' + request);
        
        return response;  
    }

    public static String setBodyRequest(String idType, String IdNumber, String typePay, String bankKey, String bankAccount, String accountType, String typeNew, String authorizationNumber, String username){

        Map<String, Object> jsonMap = new Map<String, Object>();
        
        jsonMap.put('typeIdentification', idType);
        jsonMap.put('identificationNumber', IdNumber);
        jsonMap.put('typePay', typePay);
        jsonMap.put('bankKey', bankKey);
        jsonMap.put('bankAccount', bankAccount);
        jsonMap.put('accountType', accountType);
        jsonMap.put('typeNew', typeNew);
        jsonMap.put('authorizationNumber', authorizationNumber);
        jsonMap.put('username', username);
        
        String body = JSON.serialize(jsonMap);
        
        return  body;
    }
}