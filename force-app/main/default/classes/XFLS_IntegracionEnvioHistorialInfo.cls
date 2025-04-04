/********************************************************************
Apex Class Name	:	XFLS_IntegracionEnvioHistorialInfo
Version			:	1.0
Created Date	:	06/05/2022
Function 		: 	Integración que conecta con Senda GCP para crear la actividad --------
Test Class		:	XFLS_IntegracionEnvioHistorialInfoTest   --------

Modification Log
*--------------------------------------------------------------------
* Developer		     	Date			   	Description
* -------------------------------------------------------------------
* José Quevedo   	    06/05/2022	        Original Version
* Lizeth Ramos          19/07/2022          Adición Log de errores
*********************************************************************/

public with sharing class XFLS_IntegracionEnvioHistorialInfo {
    
    public static XFLS_IntegracionesField__mdt conf;
	
    public static void configuracion(){
        Boolean isSandbox = [SELECT IsSandbox FROM Organization].IsSandbox;
        XFLS_IntegracionesField__mdt config = [SELECT XFLS_Endpoint__c, XFLS_ClientId__c, 
                                               XFLS_IsSandbox__c,XFLS_Endpoint2__c,
                                               XFLS_ClientSecret__c
                                               FROM XFLS_IntegracionesField__mdt 
                                               WHERE XFLS_IsSandbox__c =: isSandbox AND
                                               MasterLabel =: 'EnvioHistorial']; 
        conf = config;
    }

    /*--------------------------------------------------------------
    * Nombre del método: enviarHistorialInformes
    * Descripción      : Método para enviar la actividad creada a Senda GCP --------
    * @return          : {Boolean} result
    --------------------------------------------------------------*/
    
    public static Boolean enviarHistorialInformes(XFLS_Soporte_Sesion__c SoporteSesion) {
        ServiceAppointment objServiceA = [Select Id,ParentRecordId,XFLS_CodigoAutorizacion__c,XFLS_Codigo__c,
                                          XFLS_CodigoSoporte__c,XFLS_CodigoEstado__c,XFLS_FechaRegistro__c,
                                          XFLS_Mensaje__c,XFLS_De__c,XFLS_Para__c,XFLS_EnvioExitoso__c,XFLS_CodigoDeSesion__c
                                          From ServiceAppointment 
                                          Where Id =: SoporteSesion.XFLS_SesionDeTrabajo__c];
        System.debug('objServiceA: '+objServiceA);
		Boolean result = false;

        XFLS_WrapperSendaGCP.responseLogin token = new XFLS_WrapperSendaGCP.responseLogin();
        token = XFLS_IntegracionSendaToken.getServiceToken();
		String CodeOS = '';
        String Actividad = '1';
        WorkOrderLineItem woli = new WorkOrderLineItem();
        try{
        woli = [Select Id,XFLS_CodigoOS__C, WorkOrder.XFLS_Actividad__c, WorkOrder.Account.PersonEmail  From WorkOrderLineItem Where 
                                   Id =: objServiceA.ParentRecordId];
            Actividad = woli.WorkOrder.XFLS_Actividad__c;
             CodeOS = woli.XFLS_CodigoOS__C;

            }catch(Exception e){
            system.debug('No mando servicios');
        }
        
        XFLS_WrapperSendaGCP2.WrapperEnvioHistorialInformes data = new XFLS_WrapperSendaGCP2.WrapperEnvioHistorialInformes();

        //data.activityCode 		= objServiceA.XFLS_CodigoDeActividad__c;
        //hacer las validaciones de nulo
        data.codeOS 	 = CodeOS!= NULL? String.valueOf(CodeOS) : '';
        //data.codeOS 			= CodeOS;
        data.authorizationCode 	= SoporteSesion.XFLS_Codigo_de_Soporte__c!= NULL?String.valueOf(SoporteSesion.XFLS_Codigo_de_Soporte__c):'';
        //data.authorizationCode 	= '1684630';
        data.codeSupportFile 	= objServiceA.XFLS_Codigo__c!= NULL?String.valueOf(objServiceA.XFLS_Codigo__c):'';
        //data.codeSupportFile 	= objServiceA.XFLS_Codigo__c;
        data.codeSupport 			= SoporteSesion.XFLS_Codigo_de_Soporte__c!= NULL?String.valueOf(SoporteSesion.XFLS_Codigo_de_Soporte__c):'';
        //data.codeSupport 			= objServiceA.XFLS_CodigoSoporte__c;
        data.deliveryCode 			= objServiceA.XFLS_CodigoEstado__c!= NULL?String.valueOf(objServiceA.XFLS_CodigoEstado__c):'';
        //data.deliveryCode 		= objServiceA.XFLS_CodigoEstado__c;
        
        Datetime ahora = System.Now();
        String ahoraString = String.valueOf(ahora);
        ahoraString = ahoraString.left(10) +'T'+ahoraString.right(8);
        data.deliveryDate= ahoraString;
        
        //data.deliveryDate 			= objServiceA.XFLS_FechaRegistro__c;
        
        data.message 				= objServiceA.XFLS_Mensaje__c!= NULL?String.valueOf(objServiceA.XFLS_Mensaje__c):'0';        
        //data.message 				= objServiceA.XFLS_Mensaje__c;
        data.fromx 					= objServiceA.XFLS_De__c!= NULL?String.valueOf(objServiceA.XFLS_De__c):'0';
        //data.fromx 				= objServiceA.XFLS_De__c;
        data.to 					= objServiceA.XFLS_Para__c!= NULL?String.valueOf(objServiceA.XFLS_Para__c):'0';
        //data.to 					= objServiceA.XFLS_Para__c;
        data.deliveryStatus 		= String.valueOf(objServiceA.XFLS_EnvioExitoso__c)!= NULL?String.valueOf(objServiceA.XFLS_EnvioExitoso__c):'True';
        //data.deliveryStatus 		= String.valueOf(objServiceA.XFLS_EnvioExitoso__c);
        //data.FechaEnvio2 			= objServiceA.XFLS_FechaEnvio__c;

        
        String strRequestBody = JSON.serializePretty(data);
        System.debug('XFLS_IntegracionEnvioHistorialInfo.enviarHistorialInformes strRequestBody : ' + strRequestBody);
    	strRequestBody = strRequestBody.replaceAll('" :', '":');
        strRequestBody = strRequestBody.replaceAll('\n', '');
        strRequestBody = strRequestBody.replaceAll('  ', '');
        strRequestBody = strRequestBody.replaceAll(',', ', ');
        strRequestBody = strRequestBody.replaceAll('fromx', 'from');
        strRequestBody = strRequestBody.replaceAll('.000Z', '');
        
        System.debug('XFLS_IntegracionEnvioHistorialInfo.enviarHistorialInformes strRequestBody : ' + strRequestBody);

        //Petición
        HttpRequest objRequest = new HttpRequest();
       	configuracion();
       	String clientId = conf.XFLS_ClientId__c;
       	String clientSecret = conf.XFLS_ClientSecret__c;
       	objRequest.setEndpoint(conf.XFLS_Endpoint__c + Actividad + conf.XFLS_Endpoint2__c);
        objRequest.setMethod('POST');
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
		        System.debug('objRequest: '+objRequest);

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
                
                XFLS_WrapperSendaGCP2.responseServicio8 responseServicio = (XFLS_WrapperSendaGCP2.responseServicio8) JSON.deserialize(
					objResponse.getBody(), XFLS_WrapperSendaGCP2.responseServicio8.class
					);
                    System.debug('responseServicio '+responseServicio);
                if(responseServicio != null){enviarhistorioco(objServiceA.Id,responseServicio.id);}
                result = true;
            } else {
                System.debug('Mandar mensaje de error'); // -----
                CS_Log__c log = new CS_Log__c();
                log.CS_ShortDescription__c = 'Error en el envío de historial info';
                log.CS_Funcion__c = 'Cargar historial';
                log.CS_ExceptionMessage__c = objResponse.getStatus();
                log.CS_ExceptionStackTrace__c = 'XFLS_IntegracionEnvioHistorialInfo';
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
    @future (callout = true)
    public static void enviarhistorioco(Id saId, Id codigoId){
        ServiceAppointment ServiceApp1 = [Select Id,XFLS_Codigo__c From ServiceAppointment Where Id =: saId];
        ServiceApp1.XFLS_Codigo__c = codigoId; update ServiceApp1;
    }
}