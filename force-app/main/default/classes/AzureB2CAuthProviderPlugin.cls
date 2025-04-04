/**
 * @description       : 
 * @author            : diego.jacanamijoy@vass.com
 * @group             : 
 * @last modified on  : 02-24-2025
 * @last modified by  : diego.jacanamijoy@oc.vasscompany.com
**/
global class AzureB2CAuthProviderPlugin extends Auth.AuthProviderPluginClass {

    private static final String ORG_SUFFIX = System.DomainParser.parse(URL.getOrgDomainUrl()).getSandboxName();
    private static final String TIME_ZONE = 'America/Bogota';
    private String codeChallenge;
    private String codeVerifier;
    private String codeChallengeMethod;
    
    class AzureB2CAuthProviderPluginException extends Exception {}
    
    public String redirectUrl; // use this URL for the endpoint that the authentication provider calls back to for configuration
    private String key;
    private String secret;
    private String authUrl;    // application redirection to the B2C website for authentication and authorization
    private String accessTokenUrl; // uri to get the new access token from B2C  using the GET verb
    private String customMetadataTypeApiName = 'AzureB2CAuthProvider__mdt'; // api name for the custom metadata type created for this auth provider
    private String userAPIUrl; // api url to access the user in concur
    private String userAPIVersionUrl; // version of the user api url to access data from B2C
    private String policy;
    private String authProvider;
    private String portal;
    private Cache.OrgPartition orgPartition;
    private String partitionInput = 'PKCEParams';
    private String PKCE_PARAMS_KEY = 'PKCEPARAMS';
    
    public class RegPluginException extends Exception {}
    global String getCustomMetadataType() {
        return customMetadataTypeApiName;
    }
    
    /**
    * @description 
    * @author diego.jacanamijoy@oc.vasscompany.com | 12-20-2023 
    * @param authProviderConfiguration 
    * @param stateToPropagate 
    * @return PageReference 
    **/
    global PageReference initiate(Map<string,string> authProviderConfiguration, String stateToPropagate) {

        //Call method to generate PKCE code
        generatePKCECode();
        Map<String, String> mapParams = (Map<String, String>)JSON.deserialize((String)orgPartition.get(PKCE_PARAMS_KEY), Map<String, String>.class);
        authUrl = authProviderConfiguration.get('Auth_Url__c');
        key = authProviderConfiguration.get('Consumer_Key__c');
        redirectUrl = authProviderConfiguration.get('Proxy_Redirect_URL__c');
        policy = authProviderConfiguration.get('Policy__c'); 
        codeChallenge = mapParams.get('code_challenge');
        codeChallengeMethod = authProviderConfiguration.get('codeChallengeMethod__c'); 
        String url = authUrl + '?p=' + policy + '&client_id='+ key +'&redirect_uri='+ redirectUrl + '&scope=openid&response_type=code&prompt=login&state=' + stateToPropagate;
        url += '&code_challenge=' + codeChallenge + '&code_challenge_method=' + codeChallengeMethod;
        return new PageReference(url);
    }
    
    /**
    * @description 
    * @author diego.jacanamijoy@oc.vasscompany.com | 12-20-2023 
    * @param authProviderConfiguration 
    * @param state 
    * @return Auth.AuthProviderTokenResponse 
    **/
    global Auth.AuthProviderTokenResponse handleCallback(Map<string,string> authProviderConfiguration, Auth.AuthProviderCallbackState state ) {
        
        codeVerifier = '';
        //Get org partition o get PKCE params
        orgPartition = getPartition();
        if (orgPartition != null && orgPartition.contains(PKCE_PARAMS_KEY)) {
            Map<String, String> mapParams = (Map<String, String>)JSON.deserialize((String)orgPartition.get(PKCE_PARAMS_KEY), Map<String, String>.class);
            codeVerifier = mapParams.get('code_verifier');    
        }
        
        key = authProviderConfiguration.get('Consumer_Key__c');
        secret = authProviderConfiguration.get('Consumer_Secret__c');
        accessTokenUrl = authProviderConfiguration.get('Access_Token_Url__c');
        authProvider = authProviderConfiguration.get('AuthProviderName__c');
        policy = authProviderConfiguration.get('Policy__c'); 
        
        Map<String,String> queryParams = state.queryParameters;
        String code = queryParams.get('code');
        String sfdcState = queryParams.get('state');
        
        HttpRequest req = new HttpRequest();
        String url = accessTokenUrl+'?p=' + policy;
        req.setEndpoint(url);
        req.setHeader('Content-Type','application/x-www-form-urlencoded');
        req.setMethod('POST');

        String reqbody = 'code=' + code + '&client_id=' + key + '&client_secret=' + secret + '&grant_type=authorization_code' + '&code_verifier=' + codeVerifier;
        System.debug('reqbody: ' + reqbody);
        req.setBody(reqbody); 
        
        try{
            Http http = new Http();
            HTTPResponse res = http.send(req);
            String responseBody = res.getBody();
            system.debug('RESPONSE_ToString'+res.toString()); 
            system.debug(responseBody);         
            String token = getTokenValueFromResponse(responseBody, 'id_token', false);
            
            return new Auth.AuthProviderTokenResponse(authProvider, token, secret, sfdcState);
        } catch(RegPluginException e){
            throw new RegPluginException(e.getMessage());
        }
    }
    
    
    /**
    * @description 
    * @author diego.jacanamijoy@oc.vasscompany.com | 12-20-2023 
    * @param authProviderConfiguration 
    * @param response 
    * @return Auth.UserData 
    **/
    global Auth.UserData  getUserInfo(Map<string,string> authProviderConfiguration, Auth.AuthProviderTokenResponse response) {
        String id ;
        String fname;
        String lname;
        String flname;
        String email;
        String userName;
        String locale;
        Map<String,String> provMap = new Map<String,String>();
        
        authProvider = authProviderConfiguration.get('AuthProviderName__c');
        portal = authProviderConfiguration.get('PortalName__c');

        try{
            HttpRequest req = new HttpRequest();
            String url = 'https://login.salesforce.com/';
            req.setEndpoint(url);
            req.setMethod('GET');
            Http http = new Http();
            HTTPResponse res = http.send(req);
        } catch(RegPluginException e){
            throw new RegPluginException('Salesforce mock callout failed. ' + e.getMessage());
        }
        
        try{
            List<String> splitToken =  response.OAuthToken.split('\\.');
            
            Blob tokenPayloadBlob = EncodingUtil.base64decode(splitToken[1]);
            
            String decrypted = tokenPayloadBlob.toString();
            
            id = getTokenValueFromResponse(decrypted, 'sub',false);
            fname = getTokenValueFromResponse(decrypted, 'given_name', false);
            lname = getTokenValueFromResponse(decrypted, 'family_name', false);
            flname = fname + ' ' + lname;
            email = getTokenValueFromResponse(decrypted, 'mail', false);
            userName = email + (ORG_SUFFIX == null ? '' : ('.' + ORG_SUFFIX));
            locale = TIME_ZONE;
            provMap.put('oid', id);
            //provMap.put('sfdc_networkid', networkid);
        } catch(RegPluginException e){
            throw new RegPluginException(key + ' is not available in response.' + e.getMessage());
        }
        return new Auth.UserData(id, fname, lname, flname, email,
                                 null, userName, locale, authProvider, null, provMap);
    }
    
    /**
    * @description 
    * @author diego.jacanamijoy@oc.vasscompany.com | 12-20-2023 
    * @param response 
    * @param key 
    * @param isArray 
    * @return String 
    **/
    public String getTokenValueFromResponse(String response, String key, Boolean isArray) {
        String ret = null;

        System.debug('Response: ' + JSON.serialize(response));
        
        try{
            Map<String, Object> jsonResponse =  (Map<String, Object>) json.deserializeUntyped(response);
            system.debug('jsonResponse: ' + jsonResponse);

            if (!jsonResponse.containsKey(key)) {
                return ret;
            }

            if(!isArray){
                ret=jsonResponse.get(key).toString();
            } else{
                List<Object> emailsArray =  (List<Object>) jsonResponse.get(key);
                ret= emailsArray[0].toString();
            }
        } catch(RegPluginException e){
            throw new RegPluginException(key + ' is not available in response.' + e.getMessage());    
        }
        return ret;
    }

    /**
    * @description Method to generate PKCE params
    * @author diego.jacanamijoy@oc.vasscompany.com | 12-13-2024 
    **/
    public void generatePKCECode() {

        /*Http http = new Http();
        HttpRequest request = new HttpRequest();

        // End point to get PKCE params
        String instanceUrl = URL.getOrgDomainUrl().toExternalForm(); // URL org
        String endpoint = instanceUrl + '/services/oauth2/pkce/generator';

        request.setEndpoint(endpoint);
        request.setMethod('GET');
        request.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());

        HttpResponse response = http.send(request);
        Map<String, object> results = (Map<String, object>) JSON.deserializeUntyped(response.getBody());
        
        codeChallenge = (String)results.get('code_challenge');
        codeChallengeMethod = (String)results.get('code_challenge_method');
        codeVerifier = (String)results.get('code_verifier');*/

        String PKCEParams = JSON.serialize(PKCEUtils.generatePKCEParameters());
        //Save params in session cache
        orgPartition = getPartition();

        if (orgPartition.contains(PKCE_PARAMS_KEY)) {
            orgPartition.remove(PKCE_PARAMS_KEY);   
        }
        orgPartition.put(PKCE_PARAMS_KEY, PKCEParams);
    }

    private Cache.OrgPartition getPartition() {
        if (orgPartition == null) {
             orgPartition = Cache.Org.getPartition(partitionInput);
        }
        
        return orgPartition;
    }
    
}