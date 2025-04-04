/********************************************************************
Apex Class Name	:	XFLS_IntegracionRadicarSesionEjecutada
Version			:	1.0
Created Date	:	05/05/2022
Function 		: 	Integración que conecta con Senda GCP para crear la actividad --------
Test Class		:	XFLS_IntegracionRadicarSesionEjecutadTest   --------

Modification Log
*--------------------------------------------------------------------
* Developer		     	Date			   	Description
* -------------------------------------------------------------------
* José Quevedo   	    05/05/2022	        Original Version
* Lizeth Ramos          20/07/2022          Adición Log de Errores
*********************************************************************/

public with sharing class XFLS_IntegracionRadicarSesionEjecutada {
    
    public static XFLS_IntegracionesField__mdt conf;
	
    public static void configuracion(){
        Boolean isSandbox = [SELECT IsSandbox FROM Organization].IsSandbox;
        XFLS_IntegracionesField__mdt config = [SELECT XFLS_Endpoint__c, XFLS_ClientId__c, 
                                               XFLS_IsSandbox__c,XFLS_Endpoint2__c,
                                               XFLS_ClientSecret__c
                                               FROM XFLS_IntegracionesField__mdt 
                                               WHERE XFLS_IsSandbox__c =: isSandbox AND
                                               MasterLabel =: 'RadicarSesionesEjecutadas']; 
        conf = config;
    }

    /*--------------------------------------------------------------
    * Nombre del método: radicarSesionesDeTrabajo
    * Descripción      : Método para enviar la actividad creada a Senda GCP --------
    * @return          : {Boolean} result --------
    --------------------------------------------------------------*/
    
    public static Boolean radicarSesionesDeTrabajo(ServiceAppointment objServiceApp){
        Boolean result = false;
        XFLS_WrapperSendaGCP.responseLogin token = new XFLS_WrapperSendaGCP.responseLogin();
        token = XFLS_IntegracionSendaToken.getServiceToken(); // cambio
	    String CodeOS = '';
        String Actividad = '1';
        WorkOrderLineItem woli = new WorkOrderLineItem();
        try{
        woli = [Select Id,XFLS_CodigoOS__C, WorkOrder.XFLS_Actividad__c From WorkOrderLineItem Where 
                                   Id =: objServiceApp.ParentRecordId];
            Actividad = woli.WorkOrder.XFLS_Actividad__c;
             CodeOS = woli.XFLS_CodigoOS__C;

            }catch(Exception e){
            system.debug('No mando servicios');
        }
        XFLS_WrapperSendaGCP2.WrapperRadicarSesionesEjecutadas data = new XFLS_WrapperSendaGCP2.WrapperRadicarSesionesEjecutadas();
        //data.activityCode      = Decimal.valueof(objServiceApp.XFLS_CodigoDeActividad__c); // Cambiado en SF de Integer a String
        data.codeOS             = CodeOS!= NULL? String.valueOf(CodeOS) : '';
        data.sessionCode 	 = objServiceApp.XFLS_CodigoDeSesion__c!= NULL? String.valueOf(objServiceApp.XFLS_CodigoDeSesion__c) : '';
        data.statusCodeSession= objServiceApp.XFLS_CodigoDeSesion__c!= NULL? String.valueOf(objServiceApp.XFLS_CodigoDeSesion__c) : '';

		System.debug('data: '+data);
        String strRequestBody = JSON.serializePretty(data);
        System.debug('XFLS_IntegracionRadicarSesionesEjecutadas.radicarSesionesDeTrabajo strRequestBody : ' + strRequestBody);
    	strRequestBody = strRequestBody.replaceAll('" :', '":');
        strRequestBody = strRequestBody.replaceAll('\n', '');
        strRequestBody = strRequestBody.replaceAll('  ', '');
        strRequestBody = strRequestBody.replaceAll(',', ', ');
        System.debug('XFLS_IntegracionRadicarSesionesEjecutadas.radicarSesionesDeTrabajo strRequestBody : ' + strRequestBody);

        //Petición
        HttpRequest objRequest = new HttpRequest();
       	configuracion();
       	String clientId = conf.XFLS_ClientId__c;
       	String clientSecret = conf.XFLS_ClientSecret__c;
       	objRequest.setEndpoint(conf.XFLS_Endpoint__c + Actividad +conf.XFLS_Endpoint2__c);
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
		System.debug('objRequest ' + objRequest);

        // Respuesta
        try{
            Http objHttp = new Http();
            HttpResponse objResponse = new HttpResponse();
                
            if(Test.isRunningTest()){
                objResponse.setStatusCode(404);
           	}
           	else{
           		objResponse = objHttp.send(objRequest);
           	}
            System.debug('objResponse: ' + objResponse);

            //Deserializar JSON            
            if (objResponse.getStatusCode() == 200) {
                XFLS_WrapperSendaGCP2.responseServicio responseServicio = new XFLS_WrapperSendaGCP2.responseServicio();
                result = true;
            } else {
                System.debug('Mandar mensaje de error'); // -----
                CS_Log__c log = new CS_Log__c();
                    log.CS_ShortDescription__c = 'Error Sesión Ejecutada';
                    log.CS_Funcion__c = 'Ejecutar Sesión';
                    log.CS_ExceptionMessage__c = objResponse.getStatus();
                    log.CS_ExceptionStackTrace__c = 'XFLS_IntegracionRadicarSesionEjecutada';
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

        return result; // arreglar este return 
    }   
}