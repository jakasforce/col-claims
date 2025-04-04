public class VS_WSExperienceValidate {
    //Nombre del metadato que contiene el endpoint para este request
    public static String MDT_EDPOINT = 'Experience_Validate';
    
    //Variables generale servicio
    public HttpResponse serviceResponse;
    @AuraEnabled
    public Boolean successful;
    
    //Variables correspondientes al JSON de la respuesta del servicio 
    @AuraEnabled
    public Validations Validations { get; set; }
    @AuraEnabled
    public String ExcludeClient { get; set; }
    @AuraEnabled
    public Alerts Alerts { get; set; }
    @AuraEnabled
    public String Result { get; set; }
    @AuraEnabled
    public String ValidationRegistry { get; set; }
    @AuraEnabled
    public String ProcessResult { get; set; }
    @AuraEnabled
    public Integer AvailableQueries { get; set; }
    @AuraEnabled
    public Person Person { get; set; }
    
    public class Validations {
        @AuraEnabled
        public String ValidLastName { get; set; }
        @AuraEnabled
        public String ValidName { get; set; }
        @AuraEnabled
        public String ValidExpeditionDate { get; set; }
    }
    
    public class Alerts {
        @AuraEnabled
        public String Alert { get; set; }
        @AuraEnabled
        public String AlertResponse { get; set; }
        @AuraEnabled
        public String AlertCode { get; set; }
    }
    
    public class Person {
        @AuraEnabled
        public Identification Identification { get; set; }
        @AuraEnabled
        public String FullName { get; set; }
    }
    
    public class Identification {
        @AuraEnabled
        public String Numbe_r { get; set; }
        @AuraEnabled
        public String Typ_e { get; set; }
        @AuraEnabled
        public String ExpeditionDate { get; set; }
    }
    
    public static VS_WSExperienceValidate parse(String json){
        json = setSystemNames(json);
        return (VS_WSExperienceValidate) System.JSON.deserialize(json, VS_WSExperienceValidate.class);
    }
    
    public static String setSystemNames(String json){
        json = json.replace('"Number":', '"Numbe_r":');
        json = json.replace('"Type":', '"Typ_e":');
        
        return json;
    }
    
    public static String setBodyRequest(Account acc, Boolean isOTP){
        Map<String, Object> dataValidationMap = new Map<String, Object>();
        Map<String, Object> identificationMap = new Map<String, Object>();
        Map<String, Object> personMap = new Map<String, Object>();
        Map<String, Object> jsonMap = new Map<String, Object>();
        
        identificationMap.put('Number', acc.CS_NumeroIdentificacionCP__pc != null ? acc.CS_NumeroIdentificacionCP__pc : '');
        identificationMap.put('Type', acc.CS_TipoIdentificacionCP__pc != null ? acc.CS_TipoIdentificacionCP__pc : '');
        
        Datetime auxDT= DateTime.newInstance(acc.CS_FechaExpedicion__pc, Time.newInstance(0, 0, 0, 0));
		Long milliseconds = auxDT.getTime();
        identificationMap.put('ExpeditionDate', String.valueOf(milliseconds));
        
        personMap.put('Identification', identificationMap);
        personMap.put('LastName', acc.LastName != null ? acc.LastName : '');
        personMap.put('SecondLastName', acc.Suffix != null ? acc.Suffix  : '');
        personMap.put('FirstName', acc.FirstName != null ? acc.FirstName : '');
        
        dataValidationMap.put('ForceOTP', !isOTP);//Esto siempre irá OTP
        dataValidationMap.put('Person', personMap);
        
        jsonMap.put('DataValidation', dataValidationMap);
        
        String body = JSON.serialize(jsonMap);
        
        return  body;
    }
    
    public static HttpResponse calloutHTTResponse(Account acc, String bearerToken, Boolean isOTP){
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
        
        String bodyString = setBodyRequest(acc, isOTP);
        request.setBody(bodyString);
        System.debug('Request Body ' + MDT_EDPOINT + ': ' + bodyString);
        request.setHeader('Authorization', 'Bearer ' + bearerToken);
        
        HttpResponse response = http.send(request);
        
        System.debug('Request ' + MDT_EDPOINT + ': ' + request);
        
        return response;  
    }
    
    public static VS_WSExperienceValidate callout(String bearerToken, Account acc, Boolean isOTP){
        
        try{
            HttpResponse response = calloutHTTResponse(acc, bearerToken, isOTP);
            
            VS_WSExperienceValidate result =  new VS_WSExperienceValidate();
            if(response.getStatusCode() != 200) {
                System.debug('Response (!=200) ' + MDT_EDPOINT + ': ' + response.getBody());
                result.serviceResponse = response;
                result.successful = false;
            } else {
                System.debug('Response (200) ' + MDT_EDPOINT + ': ' + response.getBody());
                if(response.getBody() != null){
                    //String body = '{"Validations":{"ValidLastName":"true","ValidName":"true","ValidExpeditionDate":"true"},"ExcludeClient":"false","Alerts":{"Alert":"false","AlertResponse":"03","AlertCode":"00"},"Result":"01","ValidationRegistry":"6306411","ProcessResult":"true","AvailableQueries":"1","Person":{"Identification":{"Number":"00000000000","Type":"1","ExpeditionDate":"123456700000"},"FullName":"AAAAA AAAAAAAA AAAAAAA"}}';
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