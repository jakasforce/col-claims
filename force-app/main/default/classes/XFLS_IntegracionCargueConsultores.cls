/********************************************************************
Apex Class Name	:	XFLS_IntegracionCargueConsultores
Version			:	1.0
Created Date	:	05/05/2022
Function 		: 	Integración que conecta con Senda GCP para crear la actividad --------
Test Class		:	XFLS_IntegracionCargueConsultores_Test   --------

Modification Log
*--------------------------------------------------------------------
* Developer		     	Date			   	Description
* -------------------------------------------------------------------
* José Quevedo   	    05/05/2022	        Original Version
*********************************************************************/

public with sharing class XFLS_IntegracionCargueConsultores {
    /*--------------------------------------------------------------
    * Nombre del método: cerrarActividad
    * Descripción      : Método para enviar la actividad creada a Senda GCP --------
    * @return          : {Boolean} result --------
    --------------------------------------------------------------*/
    public static XFLS_IntegracionesField__mdt conf;
    public String idServiceDoc {get; set;}
    public Id id {get; set;}
    public ServiceResource consultor { get; set; }
    public XFLS_IntegracionCargueConsultores(ApexPages.StandardController controller) {
    consultor =  (ServiceResource) controller.getRecord();
    idServiceDoc = consultor.XFLS_document__c;
    id = consultor.Id;
    }
    public static void configuracion(){
        Boolean isSandbox = [SELECT IsSandbox FROM Organization].IsSandbox;
        XFLS_IntegracionesField__mdt config = [SELECT XFLS_Endpoint__c, XFLS_ClientId__c, 
                                               XFLS_IsSandbox__c,XFLS_Endpoint2__c,
                                               XFLS_ClientSecret__c
                                               FROM XFLS_IntegracionesField__mdt 
                                               WHERE XFLS_IsSandbox__c =: isSandbox AND
                                               MasterLabel =: 'Consultores']; 
        conf = config;
    }
    
    public PageReference cargarConsultores(){
        Boolean result = false;

        XFLS_WrapperSendaGCP.responseLogin token = new XFLS_WrapperSendaGCP.responseLogin();
        token = XFLS_IntegracionSendaToken.getServiceToken();

        XFLS_WrapperSendaGCP2.WrapperCargueConsultores data = new XFLS_WrapperSendaGCP2.WrapperCargueConsultores();
        ServiceResource objServiceResource = new ServiceResource();
        try{
            objServiceResource = [SELECT Id, XFLS_document__c,Name,IsActive,XFLS_Email__c,Description
                                  FROM ServiceResource WHERE XFLS_document__c =: idServiceDoc];}catch(Exception e){
            system.debug('No mando servicios no encuentra consultor');
        }
        
         String documento = objServiceResource.XFLS_document__c;
       // data.Documento = objServiceResource.XFLS_document__c;
        //System.debug(data.Documento);

        if(documento != NULL){ // Si es nulo lo cre y si no, lo actualizo
            String strRequestBody = '';
            //System.debug('XFLS_IntegracionRadicarSesionesEjecutadas.radicarSesionesDeTrabajo strRequestBody : ' + strRequestBody);
            strRequestBody = strRequestBody.replaceAll('" :', '":');
            strRequestBody = strRequestBody.replaceAll('\n', '');
            strRequestBody = strRequestBody.replaceAll('  ', '');
            strRequestBody = strRequestBody.replaceAll(',', ', ');
            //System.debug('XFLS_IntegracionRadicarSesionesEjecutadas.radicarSesionesDeTrabajo strRequestBody : ' + strRequestBody);

            //Petición
            HttpRequest objRequest = new HttpRequest();
            configuracion();
            String clientId = conf.XFLS_ClientId__c;
        	String clientSecret = conf.XFLS_ClientSecret__c;
            objRequest.setEndpoint(conf.XFLS_Endpoint__c + documento);
            objRequest.setMethod('GET');
            if(Test.isRunningTest()){
       		objRequest.setHeader('Authorization', 'Bearer ' +  '1341234453243245123');} else{ objRequest.setHeader('Authorization', 'Bearer ' +  token.access_token);
               }
            objRequest.setHeader('Content-Type', 'application/json');
            objRequest.setHeader('accept', '*/*');
            objRequest.setHeader('client_id', clientId);
        	objRequest.setHeader('client_secret', clientSecret);
            objRequest.setHeader('Content-Length', String.valueOf(strRequestBody.length()));
            objRequest.setHeader('Connection', 'keep-alive');
            //objRequest.setBody(strRequestBody);
                            System.debug('objRequest: ' + objRequest);

            // Respuesta
            try{
                Http objHttp = new Http();
                HttpResponse objResponse = new HttpResponse();
                //Deserializar JSON  
                 if(Test.isRunningTest()){objResponse.setStatusCode(404);}else{ objResponse = objHttp.send(objRequest);}          
                if (objResponse.getStatusCode() == 200) {
                    XFLS_WrapperSendaGCP2.responseCargueConsultores responseServicio = new XFLS_WrapperSendaGCP2.responseCargueConsultores();
                    responseServicio = (XFLS_WrapperSendaGCP2.responseCargueConsultores)JSON.deserialize(
                    objResponse.getBody(), XFLS_WrapperSendaGCP2.responseCargueConsultores.class);
                    objServiceResource.Name = responseServicio.fullName; objServiceResource.XFLS_Email__c = responseServicio.email;objServiceResource.Description = responseServicio.code;
                    if(responseServicio.status == 'Activo'){ objServiceResource.IsActive = true;}else{objServiceResource.IsActive = false;}update objServiceResource;
                    //responseServicio = objResponse.getBody();
                    System.debug(responseServicio);
                    result = true;
                } else {
                //throw new AuraHandledException('Error with Status:'+objResponse.getStatusCode());
                    CS_Log__c log = new CS_Log__c();
                    log.CS_ShortDescription__c = 'Error consultor';
                    log.CS_Funcion__c = 'Cargar Consultor';
                    log.CS_ExceptionMessage__c = objResponse.getStatus();
                    log.CS_ExceptionStackTrace__c = 'XFLS_IntegracionCargueConsultores';
                    log.CS_ResponseStatus__c = objResponse.getStatus();
                    log.CS_ResponseStatusCode__c = objResponse.getStatusCode();
                    log.CS_RequestMethod__c = objRequest.getMethod();
                    log.CS_RequestEndPoint__c = objRequest.getEndpoint();
                    insert log;
                    System.debug('Mandar mensaje de error'); // -----
                    //result = false;
                }
            }catch(Exception e){
                system.debug('No mando servicios');
                result = false;
            }
        }else{
            result = false; 
        }
         PageReference pageRef = new PageReference('/'+Id);
        pageRef.setRedirect(true);
       return pageRef; //Returns to the serviceResource page
        //return result;
    }
}