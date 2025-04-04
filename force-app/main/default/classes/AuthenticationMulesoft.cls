public class AuthenticationMulesoft {
    
    public static String GenerateToken(){
        String token = '';
        
        //llamado al fileConfig
        FileConfigMulesoft fileConfMulesoft = new FileConfigMulesoft('authentication-services-colmena');
        
        Http http = new Http();
		HttpRequest request = new HttpRequest();
		request.setEndpoint(fileConfMulesoft.urlMulesoft);
		request.setMethod('POST');
		request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        request.setHeader('client_id', fileConfMulesoft.client_id);
        request.setHeader('client_secret', fileConfMulesoft.client_secret);
        request.setHeader('grant_type', fileConfMulesoft.grant_type);
		// Set the body as a JSON object
		HttpResponse response = http.send(request);

		if(response.getStatusCode() == 200) {
    		// Deserializes the JSON string into collections of primitive data types.
			Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            token = (String) results.get('access_token');
		} else {
    		System.debug(response.getBody());
		}
        return token;
    	
    }

}