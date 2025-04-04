/** 
* ===================================================================================
* @className        WSConsultClient
* @description      Esta clase es la controladora que se encargar de contener todos los metodos de integracion involucrados para habeas data.
* @author           GSVO
* @email            Gabriel.Velandia@VassCompany.com
* @version          V0.1
* @testClass        WSHabeasDataTest
* @dateCreated      2024/04/07
* ==============================================================================================================================
*/
@RestResource(urlMapping='/WSHabeasData/*')
global with sharing class WSHabeasData {

    @httpPost
    global static void doPost(){
        WS_HabeasDataWrapper.RequestWSWrapper requestF = new WS_HabeasDataWrapper.RequestWSWrapper();
        WS_HabeasDataWrapper.ResponseWSWrapper response = new WS_HabeasDataWrapper.ResponseWSWrapper();

        RestRequest requestContext = RestContext.request;
        RestResponse responseContext = RestContext.response;
        System.debug('requestContext--->'+requestContext);
        system.debug('RequestParams-->'+requestContext.params);
        system.debug('RequestURI-->'+requestContext.requestURI);

        try {
            //REQUEST - Obtain JSON from the request body and remove the white spaces.
            String params = requestContext.requestBody != null ? requestContext.requestBody.toString().trim() : '';
            System.debug('params--->'+params);

            //convierte el JSON Obtenido en un objeto tipo SF
            requestF = (WS_HabeasDataWrapper.RequestWSWrapper)System.JSON.deserialize(params, WS_HabeasDataWrapper.RequestWSWrapper.class);
            System.debug('requestF->'+requestF);
            System.debug('Entro a try');
            WSClientController clientManager = new WSClientController();
            WSHabeasDataController habeasDataManager = new WSHabeasDataController();
            WS_HabeasDataWrapper.RequestWSWrapper requestCC = clientManager.ValidacionIdentidad(requestF);
            System.debug('requestCC ->'+requestCC);
            
            if(requestCC.ClientController != null ){
                response.error = true;
                response.message = requestCC.ClientController;
                response.responseCode = '201';
                response.status = 'Failed';
            
            }else{
                response = habeasDataManager.controllerHD(requestCC);
            }

            
            responseContext.addHeader('Content-Type', 'application/json');
            responseContext.responseBody = Blob.valueOf(JSON.serialize(response));
            
            
           return;      
        } catch (Exception e) {
            System.debug('getWSHandler: '+e.getMessage());
            response.error = true;
            response.message = e.getMessage();
            response.responseCode = '400';
            response.status = 'failed';

            responseContext.addHeader('Content-Type', 'application/json');
            responseContext.responseBody = Blob.valueOf(JSON.serialize(response));
            return;  
            
        }
    }
}