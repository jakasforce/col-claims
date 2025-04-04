/********************************************************************
Apex Class Name	:	XFLS_IntegracionSoporteDeSesiones
Version			:	1.0
Created Date	:	09/05/2022
Function 		: 	Integración que conecta con Senda GCP para dar Soporte de Sesiones
Test Class		:	XFLS_IntegracionSoporteDeSesionesTest

Modification Log
*--------------------------------------------------------------------
* Developer		     	Date			   	Description
* -------------------------------------------------------------------
* Sayra Martinez 	 09/05/2022			Original Version
* Lizeth Ramos      18/07/2022          Adición de ContentDocumentLink
* Lizeth Ramos      19/07/2022          Adición de Log de errores
*********************************************************************/
public with sharing class XFLS_IntegracionSoporteDeSesiones {
    
    public static XFLS_IntegracionesField__mdt conf;
	
    public static void configuracion(){
        Boolean isSandbox = [SELECT IsSandbox FROM Organization].IsSandbox;
        XFLS_IntegracionesField__mdt config = [SELECT XFLS_Endpoint__c, XFLS_ClientId__c, 
                                               XFLS_IsSandbox__c,
                                               XFLS_ClientSecret__c
                                               FROM XFLS_IntegracionesField__mdt 
                                               WHERE XFLS_IsSandbox__c =: isSandbox AND
                                               MasterLabel =: 'SoporteDeSesiones']; 
        conf = config;
    }
    
   /*--------------------------------------------------------------
   * Nombre del método: soporteDeSesiones
   * Descripción      : Método para enviar las Sesiones de Trabajo aprobadas a Senda GCP
   * @return          : Boolean result
   --------------------------------------------------------------*/
    
   public static Boolean soporteDeSesiones(ContentDocumentLink ContentdocumentL){
       
       Boolean result=false;
       ContentDocumentLink content = new ContentDocumentLink();
       XFLS_WrapperSendaGCP.responseLogin token = new XFLS_WrapperSendaGCP.responseLogin();
       token = XFLS_IntegracionSendaToken.getServiceToken();
       XFLS_WrapperSendaGCP.WrapperSoporteDeSesiones data = new XFLS_WrapperSendaGCP.WrapperSoporteDeSesiones();
       //data.activityCode = objServiceApp.XFLS_CodigoDeActividad__c; // Cambiado en SF de Integer a String
       //data.codeOS = objServiceApp.ParentRecordId;
       //data.codeSupport = objServiceApp.XFLS_CodigoSoporte__c;
       //data.authorizationCode = objServiceApp.XFLS_CodigoAutorizacion__c;
       
       ServiceAppointment sa = [Select Id, XFLS_CodigoAutorizacion__c,XFLS_CodigoDeSesion__c, XFLS_CodigoSoporte__c From ServiceAppointment Where Id=: ContentDocumentL.LinkedEntityID];
       XFLS_Soporte_Sesion__c soporteSesion = [Select Id, XFLS_Codigo_de_Soporte__c From XFLS_Soporte_Sesion__c Where XFLS_ContentDocumentLinkId__c =: ContentDocumentL.Id];
       data.supportId = soporteSesion.Id;
       data.authorizationCode = sa.XFLS_CodigoDeSesion__c!= NULL? String.valueOf(sa.XFLS_CodigoDeSesion__c) : '';
	   
       //ServiceAppointment authcode=[SELECT Id,XFLS_CodigoAutorizacion__c,(SELECT LinkedEntityId FROM ContentDocumentLink__r) FROM ServiceAppointment WHERE LinkedEntityId=:ServiceAppointment.Id ];
       //data.registrationDate = objServiceApp.XFLS_FechaRegistro__c;
       Datetime ahora = System.Now();
       String ahoraString = String.valueOf(ahora);
       System.debug('ahoraString1 '+ahoraString);
       ahoraString = ahoraString.left(10) +'T'+ahoraString.right(8);
       System.debug('ahoraString2 '+ahoraString);
       data.registrationDate= ahoraString;
       //data.supportRoute = objServiceApp.XFLS_CodigoAutorizacion__c;
       data.supportRoute = getOriginUrl() +'/sfc/servlet.shepherd/document/download/'+ContentdocumentL.ContentDocumentId+'?operationContext=S1';   
       //data.supportRoute = getOriginUrl() +'/sfc/servlet.shepherd/document/download/'+ContentdocumentL.ContentDocumentId+'?operationContext=S1';   
       //data.supportRoute = getOriginUrl() +'/lightning/r/ContentDocument/'+ContentdocumentL.ContentDocumentId+'/view';
       System.debug('data.supportRoute '+data.supportRoute);
       //data.rutaSoporte = objServiceApp.;
       
       String strRequestBody = JSON.serializePretty(data);
       System.debug('XFLS_IntegracionSoporteDeSesiones.soporteDeSesiones strRequestBody : ' + strRequestBody);
       strRequestBody = strRequestBody.replaceAll('" :', '":');
       strRequestBody = strRequestBody.replaceAll('\n', '');
       strRequestBody = strRequestBody.replaceAll('  ', '');
       strRequestBody = strRequestBody.replaceAll(',', ', ');
       strRequestBody = strRequestBody.replaceAll('.000Z', '');
       System.debug('XFLS_IntegracionSoporteDeSesiones.soporteDeSesiones strRequestBody : ' + strRequestBody);
       
       System.debug('si llegó bien');
       
       //Petición
       HttpRequest objRequest = new HttpRequest();
       configuracion();
       String clientId = conf.XFLS_ClientId__c;
       String clientSecret = conf.XFLS_ClientSecret__c;
       objRequest.setEndpoint(conf.XFLS_Endpoint__c);
       objRequest.setMethod('POST');
       
       if(Test.isRunningTest()){
           objRequest.setHeader('Authorization', 'Bearer ' +  '1341234453243245123');
       }
       else{
           objRequest.setHeader('Authorization', 'Bearer ' +  token.access_token);
           System.debug(token.access_token);
       }
       objRequest.setHeader('Content-Type', 'application/json');
       objRequest.setHeader('accept', '*/*');
       objRequest.setHeader('client_id', clientId);
       objRequest.setHeader('client_secret', clientSecret);
       objRequest.setHeader('Content-Length', String.valueOf(strRequestBody.length()));
       objRequest.setHeader('Connection', 'keep-alive');
       objRequest.setBody(strRequestBody);
       System.debug('objRequest: '+objRequest);
       try{
           Http objHttp = new Http();
           HttpResponse objResponse = new HttpResponse();
           
           if(Test.isRunningTest()){
               //objResponse.setStatusCode(200);
               objResponse.setStatusCode(404);
           }
           else{
               objResponse = objHttp.send(objRequest);
           }
           System.debug('objResponse: ' + objResponse);
           
           //Deserializar JSON  
           XFLS_WrapperSendaGCP.responseSoporteDeSesiones responseSoporteSesiones = new XFLS_WrapperSendaGCP.responseSoporteDeSesiones();          
           if (objResponse.getStatusCode() == 200) {
               XFLS_WrapperSendaGCP.responseSoporteDeSesiones responseServicio = (XFLS_WrapperSendaGCP.responseSoporteDeSesiones) JSON.deserialize(objResponse.getBody(),XFLS_WrapperSendaGCP.responseSoporteDeSesiones.class);
               System.debug('responseServicio '+responseServicio);
               if(responseServicio != null){ sa.XFLS_CodigoSoporte__c = responseServicio.id; soporteSesion.XFLS_Codigo_de_Soporte__c = responseServicio.id; 
       			update sa; update soporteSesion;} result = true; 
           } else if(objResponse.getStatusCode() == 404) {
               
               System.debug('El recurso pedido no existe'); 
               result = false;
               
               //log de errores
               CS_Log__c log = new CS_Log__c();
               log.CS_ShortDescription__c = 'Error soporte de sesión';
               log.CS_Funcion__c = 'Cargar soporte de sesión';
               log.CS_ExceptionMessage__c = objResponse.getStatus();
               log.CS_ExceptionStackTrace__c = 'XFLS_IntegracionSoporteDeSesiones';
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

    public static String getOriginUrl() {
        String prefix = URL.getSalesforceBaseURL().toExternalForm().replace('https://', '').split('\\.')[0];
        prefix = prefix.removeEnd('--c');
        return 'https://' + prefix.toLowerCase() + '.lightning.force.com';
    }
    
}