/**
 * @description       : 
 * @author            : diego.jacanamijoy@oc.vasscompany.com
 * @group             : 
 * @last modified on  : 07-29-2024
 * @last modified by  : diego.jacanamijoy@oc.vasscompany.com
**/
public with sharing class reCAPTCHAv3ServerController {
    public reCAPTCHAv3ServerController(){

    }


    @AuraEnabled
    public static Boolean isReCAPTCHAValid(String tokenFromClient) {
        String SECRET_KEY = '6LcCThkqAAAAAHHb0FQ0ImoIzixODGec1a8fdE1u';
        String RECAPTCHA_SERVICE_URL = 'https://www.google.com/recaptcha/api/siteverify';
        Http http = new Http();

        HttpRequest request = new HttpRequest();

        request.setEndpoint(RECAPTCHA_SERVICE_URL + '?secret=' + SECRET_KEY + '&response' + tokenFromClient);
        request.setMethod('POST');
        request.setHeader('Content-Length', '0');
        HttpResponse response = http.send(request);

        Map<String, Object> mapOfBody = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());

        Boolean success = (Boolean) mapOfBody.get('success');

        return success;
    }

    @AuraEnabled(cacheable=true)
    public static List<Account> getAccountDetails(String accountId) {
        // Apex logic to fetch account details
        return [SELECT Id, Name FROM Account LIMIT 2];
    }

}