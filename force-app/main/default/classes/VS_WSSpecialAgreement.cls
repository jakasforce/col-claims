public class VS_WSSpecialAgreement {
    //Nombre del metadato que contiene el endpoint para este request
    public static String MDT_EDPOINT = 'SpecialAgreement';
    
    //Variables generales servicio
    public HttpResponse serviceResponse;
    @AuraEnabled
    public Boolean successful;

    //Variable de resultados
    public class DTOresult{
        @AuraEnabled 
        public String id;
        @AuraEnabled
        public String codeSpecialAgreement;
    }

	//Variables correspondientes al JSON de la respuesta del servicio  
    @AuraEnabled
    public list<DTOresult> resultList;
    
    public static VS_WSSpecialAgreement parse(String json){
        //Se convierte el JSON de las respuesta del servicio a una instancia de este clase
        list<DTOresult> listR = (list<DTOresult>) System.JSON.deserialize(json, list<DTOresult>.class);
        
        VS_WSSpecialAgreement result = new VS_WSSpecialAgreement();
        result.resultList = listR;

        return result;

    }
    
    public static VS_WSSpecialAgreement callout(String contractNumber, String action){
        
        try{
            HttpResponse response = calloutHTTResponse(contractNumber, action);
            
            VS_WSSpecialAgreement result =  new VS_WSSpecialAgreement();
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

    public static HttpResponse calloutHTTResponse(String contractNumber, String action){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        
        VS_Callout_Configuration__mdt met = VS_Callout_Configuration__mdt.getInstance(MDT_EDPOINT);
        
        request.setMethod('GET');
        //request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        request.setHeader('accept', 'application/json');
        request.setHeader('Authorization', 'bearer xxxx');
        //request.setHeader('grant_type', 'CLIENT_CREDENTIALS');
        
        //request.setHeader('client_id', met.Client_Id__c);
        //request.setHeader('client_secret', met.Client_Secret__c);

        // Agregar parametros a la URL
        Map<String, String> params = new Map<String, String>();
        params.put('contractNumber', contractNumber);
        params.put('action', action);
        
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