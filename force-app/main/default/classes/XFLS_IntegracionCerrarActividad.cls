/********************************************************************
Apex Class Name	:	XFLS_IntegracionCerrarActividad
Version			:	1.0
Created Date	:	06/05/2022
Function 		: 	Integración que conecta con Senda GCP para crear la actividad --------
Test Class		:	XFLS_IntegracionCerrarActividadTest   --------

Modification Log
*--------------------------------------------------------------------
* Developer		     	Date			   	Description
* -------------------------------------------------------------------
* José Quevedo   	    06/05/2022	        Original Version
* Lizeth Ramos          20/07/2022          Adición Log de Errores
*********************************************************************/

public with sharing class XFLS_IntegracionCerrarActividad {
    
    public static XFLS_IntegracionesField__mdt conf;
	
    public static void configuracion(){
        Boolean isSandbox = [SELECT IsSandbox FROM Organization].IsSandbox;
        XFLS_IntegracionesField__mdt config = [SELECT XFLS_Endpoint__c, XFLS_ClientId__c, 
                                               XFLS_IsSandbox__c,XFLS_Endpoint2__c,
                                               XFLS_ClientSecret__c
                                               FROM XFLS_IntegracionesField__mdt 
                                               WHERE XFLS_IsSandbox__c =: isSandbox AND
                                               MasterLabel =: 'CerrarActividad']; 
        conf = config;
    }
    

    /*--------------------------------------------------------------
    * Nombre del método: cerrarActividad
    * Descripción      : Método para enviar la actividad creada a Senda GCP --------
    * @return          : {Boolean} result --------
    --------------------------------------------------------------*/
    
    public static Boolean cerrarActividad(String CodigoActividad, String CodigoEstado){
        Boolean result = false;

        XFLS_WrapperSendaGCP.responseLogin token = new XFLS_WrapperSendaGCP.responseLogin();
        token = XFLS_IntegracionSendaToken.getServiceToken();

        XFLS_WrapperSendaGCP2.WrapperCerradoActividad data = new XFLS_WrapperSendaGCP2.WrapperCerradoActividad();
        //data.activityCode      = Integer.valueOf(CodigoActividad);
        data.status         = 'closed';
        
        String strRequestBody = JSON.serializePretty(data);
        System.debug('XFLS_IntegracionCerrarActividad.cerrarActividad strRequestBody : ' + strRequestBody);
    	strRequestBody = strRequestBody.replaceAll('" :', '":');
        strRequestBody = strRequestBody.replaceAll('\n', '');
        strRequestBody = strRequestBody.replaceAll('  ', '');
        strRequestBody = strRequestBody.replaceAll(',', ', ');
        System.debug('XFLS_IntegracionCerrarActividad.cerrarActividad strRequestBody : ' + strRequestBody);

        //Petición
        HttpRequest objRequest = new HttpRequest();
       	configuracion();
       	String clientId = conf.XFLS_ClientId__c;
       	String clientSecret = conf.XFLS_ClientSecret__c;
       	objRequest.setEndpoint(conf.XFLS_Endpoint__c + CodigoActividad + conf.XFLS_Endpoint2__c);
        objRequest.setMethod('PUT');
       
        if(Test.isRunningTest()){
        	objRequest.setHeader('Authorization', 'Bearer ' +  '1341234453243245123');
       	}
       	else{
       		objRequest.setHeader('Authorization', 'Bearer ' +  token.access_token);
       	}
        objRequest.setHeader('Content-Type', 'application/json');
        objRequest.setHeader('accept', '*/*');
        objRequest.setHeader('client_id', clientId);
        objRequest.setHeader('client_secret', clientSecret);
        objRequest.setHeader('Content-Length', String.valueOf(strRequestBody.length()));
        objRequest.setHeader('Connection', 'keep-alive');
        objRequest.setBody(strRequestBody);
	    System.debug('objRequest '+objRequest);

        // Respuesta
        try{
            Http objHttp = new Http();
            HttpResponse objResponse = new HttpResponse();
                
            if(Test.isRunningTest()){
                //objResponse.setStatusCode(200);
                objResponse.setStatusCode(400);
           	}
           	else{
           		objResponse = objHttp.send(objRequest);
           	}
            System.debug('objResponse: ' + objResponse);

            //Deserializar JSON            
            if (objResponse.getStatusCode() == 200) {
                XFLS_WrapperSendaGCP2.responseServicio responseServicio = new XFLS_WrapperSendaGCP2.responseServicio();
                
                System.debug(responseServicio);
                
                result = true;
            } else {
                CS_Log__c log = new CS_Log__c();
                    log.CS_ShortDescription__c = 'Error al Cerrar Actividad';
                    log.CS_Funcion__c = 'Cerrar Actividad';
                    log.CS_ExceptionMessage__c = objResponse.getStatus();
                    log.CS_ExceptionStackTrace__c = 'XFLS_IntegracionCerrarActividad';
                    log.CS_ResponseStatus__c = objResponse.getStatus();
                    log.CS_ResponseStatusCode__c = objResponse.getStatusCode();
                    log.CS_RequestMethod__c = objRequest.getMethod();
                    log.CS_RequestEndPoint__c = objRequest.getEndpoint();
                    insert log;
                    System.debug('Mandar mensaje de error'); // -----
                result = false;
            }
        }catch(Exception e){
            system.debug('No mando servicios');
            result = false;
        }
		
        return result; 
    }   
}