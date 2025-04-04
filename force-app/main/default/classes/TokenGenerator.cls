public class TokenGenerator {
    private static final String CLIENT_ID = '3MVG9t9ADM8gwXaAvJKV5zK2XLdr3Q3YRuyXffVNWYtepyk4Isn9XsTvdHZnHP0F_RdaEQjPN.leWxpxudRCt';
    private static final String CLIENT_SECRET = '7977D3C557743682ADC6A8637DC76539F8C5AED35CF8A057B7F406AF17B7CD0E';
    private static final String USERNAME = 'melvin.escalante@devsle.co';
    private static final String PASSWORD = 'Hola0409';
    private static final String TOKEN_URL = 'https://colmenaseguros--devcolsle.sandbox.my.salesforce.com/services/oauth2/token';

    public static String generateAccessToken() {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(TOKEN_URL);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        
        // Construct the body of the request
        String body = 'grant_type=password' +
                      '&client_id=' + CLIENT_ID +
                      '&client_secret=' + CLIENT_SECRET +
                      '&username=' + USERNAME +
                      '&password=' + PASSWORD;
        
        req.setBody(body);

        Http http = new Http();
        HttpResponse res;
        try {
            res = http.send(req);
        } catch (Exception e) {
            System.debug('Exception: ' + e.getMessage());
            return null;
        }
        
        System.debug('HTTP Response Status: ' + res.getStatus());
        System.debug('HTTP Response Status Code: ' + res.getStatusCode());
        System.debug('HTTP Response Body: ' + res.getBody());
        
        if (res.getStatusCode() == 200) {
            // Parse the JSON response to get the access token
            Map<String, Object> authResponse = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            String accessToken = (String) authResponse.get('access_token');
            System.debug('Access Token: ' + accessToken);
            return accessToken;
        } else {
            // Handle errors
            System.debug('Error: ' + res.getBody());
            return null;
        }
    }
}