/********************************************************************
Apex Class Name	:	XFLS_RadicarSesionesTrabajoAprobadas
Version			:	1.0
Created Date	:	09/05/2022
Function 		: 	Integración que conecta con Senda GCP para radicar las Sesiones de Trabajo Aprobadas
Test Class		:	XFLS_RadicarSesionesTrabajoAprobadasTest

Modification Log
*--------------------------------------------------------------------
* Developer		     	Date			   	Description
* -------------------------------------------------------------------
* Sayra Martinez 	 09/05/2022			Original Version
* Lizeth Ramos       20/07/2022         Adición Log de Errores
*********************************************************************/
public with sharing class XFLS_RadicarSesionesTrabajoAprobadas{
    
    public static XFLS_IntegracionesField__mdt conf;
	
    public static void configuracion(){
        Boolean isSandbox = [SELECT IsSandbox FROM Organization].IsSandbox;
        XFLS_IntegracionesField__mdt config = [SELECT XFLS_Endpoint__c, XFLS_ClientId__c, 
                                               XFLS_IsSandbox__c,XFLS_Endpoint2__c,
                                               XFLS_ClientSecret__c
                                               FROM XFLS_IntegracionesField__mdt 
                                               WHERE XFLS_IsSandbox__c =: isSandbox AND
                                               MasterLabel =: 'RadicarSesionesAprobadas']; 
        conf = config;
   }
    
    /*--------------------------------------------------------------
   * Nombre del método: aprobarSesionesDeTrabajo
   * Descripción      : Método para enviar las Sesiones de Trabajo aprobadas a Senda GCP
   * @return          : Boolean result
   --------------------------------------------------------------*/
   
    public static Boolean aprobarSesionesDeTrabajo(ServiceAppointment objServiceApp){
        
        Boolean result=false;
        XFLS_WrapperSendaGCP.responseLogin token = new XFLS_WrapperSendaGCP.responseLogin();
        token = XFLS_IntegracionSendaToken.getServiceToken();
        String Actividad = '1';
         String CodeOS = '';
        WorkOrderLineItem woli = new WorkOrderLineItem();
        try{
        woli = [Select Id,XFLS_CodigoOS__C, WorkOrder.XFLS_Actividad__c From WorkOrderLineItem Where 
                                   Id =: objServiceApp.ParentRecordId];
            Actividad = woli.WorkOrder.XFLS_Actividad__c;
             CodeOS = woli.XFLS_CodigoOS__C;

            }catch(Exception e){
            system.debug('No mando servicios');
        }
        XFLS_WrapperSendaGCP.WrapperSesionesDeTrabajoAprobadas 	data 	= new XFLS_WrapperSendaGCP.WrapperSesionesDeTrabajoAprobadas();
        XFLS_WrapperSendaGCP.Soporte 							dataSup = new XFLS_WrapperSendaGCP.Soporte();
        XFLS_WrapperSendaGCP.EntregaSesionesDeTrabajoAprobadas 	dataDel = new XFLS_WrapperSendaGCP.EntregaSesionesDeTrabajoAprobadas();
        
        
        data.activityCode 			= Actividad; 
        data.codeOS 				= CodeOS; 
        
        dataSup.codeSupportFile 	= objServiceApp.XFLS_Codigo__c 				!= NULL? objServiceApp.XFLS_Codigo__c : '0'; 
        dataSup.codeSupport 		= objServiceApp.XFLS_CodigoSoporte__c 		!= NULL? objServiceApp.XFLS_CodigoSoporte__c : '0'; 
		dataSup.codeStatusSupport 	= objServiceApp.XFLS_CodigoEstado__c 		!= NULL? objServiceApp.XFLS_CodigoEstado__c : '0';
        dataSup.statusSupport 		= objServiceApp.XFLS_Descripcion__c 		!= NULL? objServiceApp.XFLS_Descripcion__c : '0';
        dataSup.recordSupportDate 	= objServiceApp.XFLS_FechaRegistro__c 		!= NULL? objServiceApp.XFLS_FechaRegistro__c : System.today();
		dataSup.codeSupport1 		= objServiceApp.XFLS_Codigo__c 				!= NULL? String.valueOf(objServiceApp.XFLS_Codigo__c) : '0';
        dataSup.authorizationCode	= objServiceApp.XFLS_CodigoDeSesion__c 	!= NULL? String.valueOf(objServiceApp.XFLS_CodigoDeSesion__c) : '0';
        data.support = dataSup;
        
        dataDel.deliverableName		= objServiceApp.XFLS_Mensaje__c 			!= NULL? objServiceApp.XFLS_Mensaje__c : '0';
        dataDel.fromx 				= objServiceApp.XFLS_De__c 					!= NULL? objServiceApp.XFLS_De__c : '0';
        dataDel.To 					= objServiceApp.XFLS_Para__c 				!= NULL? objServiceApp.XFLS_Para__c : '0';
        dataDel.deliveryStatus 		= objServiceApp.XFLS_EnvioExitoso__c 		!= NULL? String.valueOf(objServiceApp.XFLS_EnvioExitoso__c) : '0';
        dataDel.deliveryDate 		= objServiceApp.XFLS_FechaEnvio__c 			!= NULL? objServiceApp.XFLS_FechaEnvio__c : System.today();
        data.delivery 				= dataDel;

        String strRequestBody = JSON.serializePretty(data);
        System.debug('XFLS_RadicarSesionesTrabajoAprobadas.aprobarSesionesDeTrabajo strRequestBody : ' + strRequestBody);
        strRequestBody = strRequestBody.replaceAll('" :', '":');
        strRequestBody = strRequestBody.replaceAll('\n', '');
        strRequestBody = strRequestBody.replaceAll('  ', '');
        strRequestBody = strRequestBody.replaceAll(',', ', ');
        strRequestBody = strRequestBody.replaceAll('fromx', 'from');
        strRequestBody = strRequestBody.replaceAll('.000Z', '');
        System.debug('XFLS_RadicarSesionesTrabajoAprobadas.aprobarSesionesDeTrabajo strRequestBody : ' + strRequestBody);

        //Petición
        HttpRequest objRequest = new HttpRequest();
       	configuracion();
       	String clientId = conf.XFLS_ClientId__c;
       	String clientSecret = conf.XFLS_ClientSecret__c;
       	objRequest.setEndpoint(conf.XFLS_Endpoint__c + Actividad +conf.XFLS_Endpoint2__c);
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

        try{
            Http objHttp = new Http();
            HttpResponse objResponse = new HttpResponse();
                
            if(Test.isRunningTest()){
                objResponse.setStatusCode(404);
           	}
           	else{
           		objResponse = objHttp.send(objRequest);
           	}
            System.debug('objResponse-sesionesAprobadas: ' + objResponse);

            //Deserializar JSON  
            XFLS_WrapperSendaGCP.responseSesionesDeTrabajoAprobadas responseSesionesTrabajoAprob = new XFLS_WrapperSendaGCP.responseSesionesDeTrabajoAprobadas();          
            if (objResponse.getStatusCode() == 200) {
                responseSesionesTrabajoAprob.message='Sesión Trabajo Aprobada.';
                responseSesionesTrabajoAprob.status=objResponse.getStatusCode();
                result = true;
            } else if(objResponse.getStatusCode() == 404) {
                System.debug('El recurso pedido no existe'); 
                responseSesionesTrabajoAprob.message='El recurso pedido no existe ';
                responseSesionesTrabajoAprob.status=objResponse.getStatusCode();
                result = false;
                CS_Log__c log = new CS_Log__c();
                    log.CS_ShortDescription__c = 'Error Sesión de Trabajo';
                    log.CS_Funcion__c = 'Cargar Aprobación de Sesión de Trabajo';
                    log.CS_ExceptionMessage__c = objResponse.getStatus();
                    log.CS_ExceptionStackTrace__c = 'XFLS_IntegracionCargueConsultores';
                    log.CS_ResponseStatus__c = objResponse.getStatus();
                    log.CS_ResponseStatusCode__c = objResponse.getStatusCode();
                    log.CS_RequestMethod__c = objRequest.getMethod();
                    log.CS_RequestEndPoint__c = objRequest.getEndpoint();
                    insert log;
                    System.debug('Mandar mensaje de error'); // -----
            }
        }catch(Exception e){
            System.debug('-----  error: ' + e.getMessage() + ' Línea: ' + e.getLineNumber()+'StackTrace '+e.getStackTraceString());
            result = false;
        }

        return result;
    }

}