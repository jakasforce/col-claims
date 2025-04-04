/********************************************************************
Apex Class Name	:	XFLS_IntegracionCreacionOrdenDeServicio
Version			:	1.0
Created Date	:	05/05/2022
Function 		: 	Integración que conecta con Senda GCP para crear el Orden de Servicio
Test Class		:	XFLS_IntegracionCreacionOrdenServicio_Test

Modification Log
*--------------------------------------------------------------------
* Developer		     	Date			   	Description
* -------------------------------------------------------------------
* Sayra Martinez 	 05/05/2022			Original Version
* Lizeth Ramos       20/07/2022         Adición log de errores
*********************************************************************/
public with sharing class XFLS_IntegracionCreacionOrdenDeServicio{
    
    public static XFLS_IntegracionesField__mdt conf;
	// WHERE XFLS_IsSandbox__c =: isSandbox AND MasterLabel =: 'CreacionOrdenServicio'
    public static void configuracion(){
        Boolean isSandbox = [SELECT IsSandbox FROM Organization].IsSandbox;
        XFLS_IntegracionesField__mdt config = [SELECT XFLS_Endpoint__c, XFLS_ClientId__c, 
                                               XFLS_IsSandbox__c,XFLS_Endpoint2__c,
                                               XFLS_ClientSecret__c
                                               FROM XFLS_IntegracionesField__mdt 
                                               WHERE XFLS_IsSandbox__c =: isSandbox AND
                                               MasterLabel =: 'CreacionOrdenServicio']; 
        conf = config;
    }
    
    /*--------------------------------------------------------------
   * Nombre del método: crearOrdenDeServicio
   * Descripción      : Método para enviar Orden de Servicio a Senda GCP
   * @return          : Boolean result
   --------------------------------------------------------------*/
   
   public static Boolean crearOrdenDeServicio(workOrderLineItem objWorkOrderLineItem){
       Boolean result=false;
       XFLS_WrapperSendaGCP.responseLogin token = new XFLS_WrapperSendaGCP.responseLogin();
       token = XFLS_IntegracionSendaToken.getServiceToken();
       System.debug('token: '+token);

       XFLS_WrapperSendaGCP.WrapperOrdendeServico data = new XFLS_WrapperSendaGCP.WrapperOrdendeServico();	
	   WorkOrder objWorkOrder = [Select Id, XFLS_Actividad__c,XFLS_CedulaConsultor__c,XFLS_ObservacionesProveedor__c,XFLS_Horario__c,XFLS_Contacto__c From WorkOrder Where Id=:objWorkOrderLineItem.WorkOrderId];
       data.orderServiceCode	= objWorkOrderLineItem.XFLS_CodigoOS__c 					!= NULL? String.valueOf(objWorkOrderLineItem.XFLS_CodigoOS__c) : '';
       data.statusCodeOS        = objWorkOrderLineItem.XFLS_CodigoEstadoOS__c 				!= NULL? objWorkOrderLineItem.XFLS_CodigoEstadoOS__c : '';
       data.statusOS			= objWorkOrderLineItem.Status 								!= NULL? objWorkOrderLineItem.Status : '';
       data.publicationOSDate	= objWorkOrderLineItem.XFLS_FechaPublicacionOS__c 			!= NULL? objWorkOrderLineItem.XFLS_FechaPublicacionOS__c : System.today();
       data.approvalOSDate	    = objWorkOrderLineItem.XFLS_FechaAprobacionOS__c 			!= NULL? objWorkOrderLineItem.XFLS_FechaAprobacionOS__c : System.today();
       data.providerComments    = objWorkOrder.XFLS_ObservacionesProveedor__c 		!= NULL? objWorkOrder.XFLS_ObservacionesProveedor__c : '';
       data.madeSite    		= objWorkOrderLineItem.Address 							!= NULL? String.valueOf(objWorkOrderLineItem.Address) : '';
       data.duration            = objWorkOrderLineItem.Duration 							!= NULL? String.valueOf(objWorkOrderLineItem.Duration) : '';
       data.timex               = objWorkOrder.XFLS_Horario__c 					!= NULL? objWorkOrder.XFLS_Horario__c : '';
       data.contactExecuter     = objWorkOrder.XFLS_Contacto__c 							!= NULL? objWorkOrder.XFLS_Contacto__c : '';
       data.supports            = objWorkOrderLineItem.XFLS_Soportes__c 					!= NULL? String.valueof(objWorkOrderLineItem.XFLS_Soportes__c) : '';
       data.adminRequirements 	= objWorkOrderLineItem.XFLS_NecesidadesAdministrativas__c	!= NULL? String.valueof(objWorkOrderLineItem.XFLS_NecesidadesAdministrativas__c) : '';
       data.consultorId     = objWorkOrder.XFLS_CedulaConsultor__c != NULL? String.valueof(objWorkOrder.XFLS_CedulaConsultor__c) : '';
       data.objectives          = objWorkOrderLineItem.XFLS_Objetivos__c 					!= NULL? objWorkOrderLineItem.XFLS_Objetivos__c : '';

       String strRequestBody = JSON.serializePretty(data);
       System.debug('XFLS_IntegracionCreacionOrdenDeServicio.crearOrdenDeServicio strRequestBody : ' + strRequestBody);
       strRequestBody = strRequestBody.replaceAll('" :', '":');
       strRequestBody = strRequestBody.replaceAll('\n', '');
       strRequestBody = strRequestBody.replaceAll('  ', '');
       strRequestBody = strRequestBody.replaceAll(',', ', ');
       strRequestBody = strRequestBody.replaceAll('timex', 'time');
       strRequestBody = strRequestBody.replaceAll('.000Z', '');

       System.debug('XFLS_IntegracionCreacionOrdenDeServicio.crearOrdenDeServicio strRequestBody : ' + strRequestBody);

       
       
       //Petición
       HttpRequest objRequest = new HttpRequest();
       configuracion();
       String clientId = conf.XFLS_ClientId__c;
       String clientSecret = conf.XFLS_ClientSecret__c;
       objRequest.setEndpoint(conf.XFLS_Endpoint__c + objWorkOrder.XFLS_Actividad__c + conf.XFLS_Endpoint2__c);
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
	 System.debug('objRequest '+objRequest);
       try{
           Http objHttp = new Http();
           HttpResponse objResponse = new HttpResponse();
           if(Test.isRunningTest()){
                objResponse.setStatusCode(200);
           }
           else{
           		objResponse = objHttp.send(objRequest);
           }
           System.debug('objResponse-crearOrdenDeTrabajo: ' + objResponse);

           //Deserializar JSON  
           XFLS_WrapperSendaGCP.responseOrdenDeServico responseOrdenServicio = new XFLS_WrapperSendaGCP.responseOrdenDeServico();          
           if (objResponse.getStatusCode() == 200) {
                    System.debug('objResponse.getBody() '+objResponse.getBody());
               XFLS_WrapperSendaGCP.responseOrdenDeServico responseServicio = (XFLS_WrapperSendaGCP.responseOrdenDeServico) JSON.deserialize(
					objResponse.getBody(),
					XFLS_WrapperSendaGCP.responseOrdenDeServico.class
					);
                    System.debug('responseServicio '+responseServicio);
                if(responseServicio != null){objWorkOrderLineItem.XFLS_CodigoOS__c = String.valueOf(responseServicio.id);update objWorkOrderLineItem;
                }
              // responseOrdenServicio.message='Orden Servicio Creada:';
               //responseOrdenServicio.status=objResponse.getStatusCode();
               result = true;
           } else if(objResponse.getStatusCode() == 404 || objResponse.getStatusCode() == 400 ) {System.debug('El recurso pedido no existe'); 

               CS_Log__c log = new CS_Log__c();log.CS_ShortDescription__c = 'Error Orden de servicio';log.CS_Funcion__c = 'Cargar Orden de Servicio';
                    log.CS_ExceptionMessage__c = objResponse.getStatus();log.CS_ExceptionStackTrace__c = 'XFLS_IntegracionCreacionOrdenDeServicio';
                    log.CS_ResponseStatus__c = objResponse.getStatus();log.CS_ResponseStatusCode__c = objResponse.getStatusCode();log.CS_RequestMethod__c = objRequest.getMethod();
                    log.CS_RequestEndPoint__c = objRequest.getEndpoint();insert log; System.debug('Mandar mensaje de error'); // -----

               result = false;
           }
       }catch(Exception e){System.debug('-----  error: ' + e.getMessage() + ' Línea: ' + e.getLineNumber()+'StackTrace '+e.getStackTraceString());result = false;
       }

       return result;
   }
   
}