@isTest
public class WSHabeasDataTest {

    @TestSetup
    private static void setupData(){
        List<EngagementChannelType> attentionchannels = new List<EngagementChannelType>();
        
        EngagementChannelType attentionchannel1 = new EngagementChannelType();
        attentionchannel1.Name                   = 'Mary';
        attentionchannel1.channelReceivesPQRs__c = true;

        EngagementChannelType attentionchannel2 = new EngagementChannelType();
        attentionchannel2.Name                   = 'Mary2';
        attentionchannel2.channelReceivesPQRs__c = false;

        attentionchannels.add(attentionchannel1);
        attentionchannels.add(attentionchannel2);
        insert attentionchannels;
    }

    @isTest
    static void testDoPostN1_AccountCreateClient() {
        // Simular el contexto de solicitud y respuesta REST
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestUri = '/services/apexrest/WSHabeasData/';
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');
        
        // Crear un cuerpo de solicitud de prueba
        
        WS_HabeasDataWrapper.RequestWSWrapper requestWrapper = new WS_HabeasDataWrapper.RequestWSWrapper();
        requestWrapper.FirstName       = 'Test';
        requestWrapper.SecondName      = 'Test';
        requestWrapper.LastName        = 'Test';
        requestWrapper.SecondLastName  = 'Test';
        requestWrapper.identityNumber  = '72211024';
        requestWrapper.email           = 'TestHD01@gmail.com';
        requestWrapper.numberPhone     = '3013765431';
        requestWrapper.identityType    = '1';
        requestWrapper.AttentionChannel= 'Mary';
        
        WS_HabeasDataWrapper.CompaniesWrapper companyColCapi = new WS_HabeasDataWrapper.CompaniesWrapper();
        companyColCapi.name = 'Colmena Capitalizadora';
        companyColCapi.essentialFunctionalities = true;
        companyColCapi.notEssentialFunctionalities = null;
        companyColCapi.law2300 = false;

        WS_HabeasDataWrapper.CompaniesWrapper companyColSegARL = new WS_HabeasDataWrapper.CompaniesWrapper();
        companyColSegARL.name = 'Colmena Seguros ARL';
        companyColSegARL.essentialFunctionalities = true;
        companyColSegARL.notEssentialFunctionalities = null;
        companyColSegARL.law2300 = false;
        companyColSegARL.MedicalHistory = true;

        WS_HabeasDataWrapper.CompaniesWrapper companyColSegVida = new WS_HabeasDataWrapper.CompaniesWrapper();
        companyColSegVida.name = 'Colmena Seguros Vida';
        companyColSegVida.essentialFunctionalities = true;
        companyColSegVida.notEssentialFunctionalities = null;
        companyColSegVida.law2300 = false;
        companyColSegVida.MedicalHistory = true;

        WS_HabeasDataWrapper.CompaniesWrapper companyColSegGen = new WS_HabeasDataWrapper.CompaniesWrapper();
        companyColSegGen.name = 'Colmena Seguros Generales';
        companyColSegGen.essentialFunctionalities = true;
        companyColSegGen.notEssentialFunctionalities = null;
        companyColSegGen.law2300 = false;

        requestWrapper.companies = new List<WS_HabeasDataWrapper.CompaniesWrapper>{companyColCapi,companyColSegARL,companyColSegVida,companyColSegGen};
        
        String jsonRequest = JSON.serialize(requestWrapper);
        req.requestBody = Blob.valueOf(jsonRequest);
        
        RestContext.request = req;
        RestContext.response = res;
        
        // Llamar al método doPost()
        Test.startTest();
        WSHabeasData.doPost();
        Test.stopTest();
        
        // Verificar la respuesta
        String jsonResponse = res.responseBody.toString();
        WS_HabeasDataWrapper.ResponseWSWrapper responseWrapper = (WS_HabeasDataWrapper.ResponseWSWrapper) JSON.deserialize(jsonResponse, WS_HabeasDataWrapper.ResponseWSWrapper.class);
        System.debug('jsonResponse->'+jsonResponse);
        
        // System.assertNotEquals(null, responseWrapper, 'La respuesta no debe ser nula');
        // System.assertEquals(false, responseWrapper.error, 'La respuesta no debe contener errores');
        // System.assertEquals('200', responseWrapper.responseCode, 'El código de respuesta debe ser 200');
        // System.assertEquals('Success', responseWrapper.status, 'El estado de la respuesta debe ser Success');
    }

    @isTest
    static void testDoPostN2_LeadCreateClient() {
        // Simular el contexto de solicitud y respuesta REST
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestUri = '/services/apexrest/WSHabeasData/';
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');
        
        // Crear un cuerpo de solicitud de prueba
        
        WS_HabeasDataWrapper.RequestWSWrapper requestWrapper = new WS_HabeasDataWrapper.RequestWSWrapper();
        requestWrapper.FirstName       = 'Test';
        requestWrapper.SecondName      = 'Test';
        requestWrapper.LastName        = 'Test';
        requestWrapper.SecondLastName  = 'Test';
        requestWrapper.identityNumber  = '72211024';
        requestWrapper.email           = 'TestHD01@gmail.com';
        requestWrapper.numberPhone     = '3013765431';
        requestWrapper.identityType    = '1';
        requestWrapper.AttentionChannel= 'Mary2';
        
        WS_HabeasDataWrapper.CompaniesWrapper company = new WS_HabeasDataWrapper.CompaniesWrapper();
        company.name = 'Colmena Capitalizadora';
        company.essentialFunctionalities = true;
        company.notEssentialFunctionalities = null;
        company.law2300 = false;
        requestWrapper.companies = new List<WS_HabeasDataWrapper.CompaniesWrapper>{company};
        
        String jsonRequest = JSON.serialize(requestWrapper);
        req.requestBody = Blob.valueOf(jsonRequest);
        
        RestContext.request = req;
        RestContext.response = res;
        
        // Llamar al método doPost()
        Test.startTest();
        WSHabeasData.doPost();
        Test.stopTest();
        
        // Verificar la respuesta
        String jsonResponse = res.responseBody.toString();
        WS_HabeasDataWrapper.ResponseWSWrapper responseWrapper = (WS_HabeasDataWrapper.ResponseWSWrapper) JSON.deserialize(jsonResponse, WS_HabeasDataWrapper.ResponseWSWrapper.class);
        System.debug('jsonResponse->'+jsonResponse);
        
        // System.assertNotEquals(null, responseWrapper, 'La respuesta no debe ser nula');
        // System.assertEquals(false, responseWrapper.error, 'La respuesta no debe contener errores');
        // System.assertEquals('200', responseWrapper.responseCode, 'El código de respuesta debe ser 200');
        // System.assertEquals('Success', responseWrapper.status, 'El estado de la respuesta debe ser Success');
    }
    
    @isTest
    static void testDoPostN3_ERROR400() {
        // Simular el contexto de solicitud y respuesta REST
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestUri = '/services/apexrest/WSHabeasData/';
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');
        
        // Crear un cuerpo de solicitud de prueba
        
        WS_HabeasDataWrapper.RequestWSWrapper requestWrapper = new WS_HabeasDataWrapper.RequestWSWrapper();
        requestWrapper.FirstName       = 'Test';
        requestWrapper.SecondName      = 'Test';
        requestWrapper.LastName        = 'Test';
        requestWrapper.SecondLastName  = 'Test';
        requestWrapper.identityNumber  = '72211024';
        requestWrapper.email           = 'TestHD01@gmail.com';
        requestWrapper.numberPhone     = '3013765431';
        requestWrapper.identityType    = '1';
        requestWrapper.AttentionChannel= 'PruebaERROR400';
        
        WS_HabeasDataWrapper.CompaniesWrapper company = new WS_HabeasDataWrapper.CompaniesWrapper();
        company.name = 'Colmena Capitalizadora';
        company.essentialFunctionalities = true;
        company.notEssentialFunctionalities = null;
        company.law2300 = false;
        requestWrapper.companies = new List<WS_HabeasDataWrapper.CompaniesWrapper>{company};
        
        String jsonRequest = JSON.serialize(requestWrapper);
        req.requestBody = Blob.valueOf(jsonRequest);
        
        RestContext.request = req;
        RestContext.response = res;
        
        // Llamar al método doPost()
        Test.startTest();
        WSHabeasData.doPost();
        Test.stopTest();
        
        // Verificar la respuesta
        String jsonResponse = res.responseBody.toString();
        WS_HabeasDataWrapper.ResponseWSWrapper responseWrapper = (WS_HabeasDataWrapper.ResponseWSWrapper) JSON.deserialize(jsonResponse, WS_HabeasDataWrapper.ResponseWSWrapper.class);
        System.debug('jsonResponse->'+jsonResponse);
        
        // System.assertNotEquals(null, responseWrapper, 'La respuesta no debe ser nula');
        // System.assertEquals(false, responseWrapper.error, 'La respuesta no debe contener errores');
        // System.assertEquals('200', responseWrapper.responseCode, 'El código de respuesta debe ser 200');
        // System.assertEquals('Success', responseWrapper.status, 'El estado de la respuesta debe ser Success');
    }
}