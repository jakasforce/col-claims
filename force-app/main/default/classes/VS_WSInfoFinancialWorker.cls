public class VS_WSInfoFinancialWorker {
    //Nombre del metadato que contiene el endpoint para este request
    public static String MDT_EDPOINT = 'InfoFinancialWorker';
    
    //Variables generales servicio
    public HttpResponse serviceResponse;
    @AuraEnabled
    public Boolean successful;

	//Variables correspondientes al JSON de la respuesta del servicio   
	@AuraEnabled 
    public String bankKey;
    @AuraEnabled
    public String bankAccount;
    @AuraEnabled
    public String accountType;
    @AuraEnabled
    public String message;

    public String typePay;
    
    public static VS_WSInfoFinancialWorker parse(String json){
        //Se convierte el JSON de las respuesta del servicio a una instancia de este clase
        return (VS_WSInfoFinancialWorker) System.JSON.deserialize(json, VS_WSInfoFinancialWorker.class);
    }
    
    public static VS_WSInfoFinancialWorker callout(String bearerToken, String idType, String IdNumber){
        
        try{
            HttpResponse response = calloutHTTResponse(idType, IdNumber, bearerToken);
            
            VS_WSInfoFinancialWorker result =  new VS_WSInfoFinancialWorker();
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

    public static HttpResponse calloutHTTResponse(String idType, String IdNumber, String bearerToken){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        
        VS_Callout_Configuration__mdt met = VS_Callout_Configuration__mdt.getInstance(MDT_EDPOINT);
        
        request.setMethod('GET');
        //request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        request.setHeader('accept', 'application/json');
        request.setHeader('Authorization', 'Bearer ' + bearerToken);
        //request.setHeader('grant_type', 'CLIENT_CREDENTIALS');
        
        request.setHeader('client_id', met.Client_Id__c);
        request.setHeader('client_secret', met.Client_Secret__c);

        // Agregar parametros a la URL
        Map<String, String> params = new Map<String, String>();
        params.put('typeIdentification', idType);
        params.put('identificationNumber', IdNumber);
        
        String queryString = '';
        for (String key : params.keySet()) {
            if (queryString != '') {
                queryString += '&';
            }
            String auxValue = params.get(key) == Null ? '' : params.get(key);
            queryString += key + '=' + EncodingUtil.urlEncode(auxValue, 'UTF-8');
        }

        request.setEndpoint(met.Endpoint__c + '?' + queryString);
        
        HttpResponse response = http.send(request);
        
        System.debug('Request ' + MDT_EDPOINT + ': ' + request);
        
        return response;  
    }
}