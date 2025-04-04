/********************************************************************
Apex Class Name	:	XFLS_IntegracionCargueClient
Version			:	1.0
Created Date	:	05/05/2022
Function 		: 	Integración que conecta con Senda GCP para crear la actividad --------
Test Class		:	XFLS_IntegracionCargueClientTest   --------

Modification Log
*--------------------------------------------------------------------
* Developer		     	Date			   	Description
* -------------------------------------------------------------------
* José Quevedo   	    05/05/2022	        Original Version
*********************************************************************/

public with sharing class XFLS_IntegracionCargueClient {
    public static XFLS_IntegracionesField__mdt conf;
	 public Decimal contrato {get; set;}
    public Id id {get; set;}
    public Account objAccount { get; set; }
    public Contract objContract { get; set; }
    public XFLS_IntegracionCargueClient(ApexPages.StandardController controller) {
    objContract =  (Contract) controller.getRecord();
    objAccount =  [Select Id,Name,XFLS_Nit__c, CS_NumeroIdentificacion__c,XFLS_Direccion__c,
                           Phone,XFLS_Representante_Legal__c,XFLS_Correo__c From Account Where Id =: objContract.AccountId ];
    //contrato = objAccount.XFLS_Contrato__c;
    id = objContract.AccountId;
    }
    public static void configuracion(){
        Boolean isSandbox = [SELECT IsSandbox FROM Organization].IsSandbox;
        XFLS_IntegracionesField__mdt config = [SELECT XFLS_Endpoint__c, XFLS_ClientId__c, 
                                               XFLS_IsSandbox__c,XFLS_Endpoint2__c,
                                               XFLS_ClientSecret__c
                                               FROM XFLS_IntegracionesField__mdt 
                                               WHERE XFLS_IsSandbox__c =: isSandbox AND
                                               MasterLabel =: 'Clientes']; 
        conf = config;
    }
    
    /*--------------------------------------------------------------
    * Nombre del método: cargarClientes
    * Descripción      : Método para enviar la actividad creada a Senda GCP --------
    * @return          : {Boolean} result --------
    --------------------------------------------------------------*/
    
    public PageReference cargarClientes(){
        Boolean result = false;
        
        XFLS_WrapperSendaGCP.responseLogin token = new XFLS_WrapperSendaGCP.responseLogin();
        token = XFLS_IntegracionSendaToken.getServiceToken();
        
        XFLS_WrapperSendaGCP2.WrapperCargueClientes data = new XFLS_WrapperSendaGCP2.WrapperCargueClientes();
		//data.Nit = Double.valueof(objAccount.XFLS_Nit__c);
        //data.Nit = Double.valueof(objAccount.XFLS_Nit__c)	!= NULL? Double.valueof(objAccount.XFLS_Nit__c) : 0;
        if(objAccount != NULL){
            Account objAccount2 = [Select Id,Name, XFLS_Nit__c, CS_NumeroIdentificacion__c,XFLS_Direccion__c,Phone,XFLS_Representante_Legal__c,XFLS_Correo__c
                           From Account Where ID =: objAccount.Id];
            String strRequestBody = '';
            //System.debug('XFLS_IntegracionCargueClient.cargarClientes strRequestBody : ' + strRequestBody);
            strRequestBody = strRequestBody.replaceAll('" :', '":');
            strRequestBody = strRequestBody.replaceAll('\n', '');
            strRequestBody = strRequestBody.replaceAll('  ', '');
            strRequestBody = strRequestBody.replaceAll(',', ', ');
            //System.debug('XFLS_IntegracionCargueClient.cargarClientes strRequestBody : ' + strRequestBody);
			
            
            //Petición
            HttpRequest objRequest = new HttpRequest();
            configuracion();
            String clientId = conf.XFLS_ClientId__c;
        	String clientSecret = conf.XFLS_ClientSecret__c;
            objRequest.setEndpoint(conf.XFLS_Endpoint__c + objContract.XFLS_Contrato__c);
            objRequest.setMethod('GET');
            if(Test.isRunningTest()){
       		objRequest.setHeader('Authorization', 'Bearer ' +  '1341234453243245123');
               }
               else{
                    objRequest.setHeader('Authorization', 'Bearer ' +  token.access_token);
               }
            //objRequest.setHeader('Content-Type', 'application/json');
            objRequest.setHeader('accept', '*/*');
            objRequest.setHeader('x-transaction-id', '1d074780-e383-11ec-b104-3c22fbb97115');
            objRequest.setHeader('client_id', clientId);
        	objRequest.setHeader('client_secret', clientSecret);
           // objRequest.setHeader('Content-Length', String.valueOf(strRequestBody.length()));
            objRequest.setHeader('Connection', 'keep-alive');
            //objRequest.setBody(strRequestBody);
			            System.debug('objRequest ' +objRequest);
            
            // Respuesta
            try{
                Http objHttp = new Http();
                //HttpResponse objResponse = objHttp.send(objRequest);
				HttpResponse objResponse = new HttpResponse();
                //Deserializar JSON
                if(Test.isRunningTest()){
                    objResponse.setStatusCode(200);
                    objResponse.setBody('[{"businessName": "ALIANSALUD ENTIDAD PROMOTORA DE SALUD S.A.", "contractId": "59757", "nit": 830113831,"address": "Calle 1 a # 22 - 00", "phoneNumber": "2555555","legalRepresentative": "SANDRA CAMARGO"}]');
               } 
                else{ objResponse = objHttp.send(objRequest);}    
                
                if (objResponse.getStatusCode() == 200) {
                      // XFLS_WrapperSendaGCP2.responseCargueClientes responseServicio = new XFLS_WrapperSendaGCP2.responseCargueClientes();
                     System.debug('body: '+objResponse.getBody());
                    List<XFLS_WrapperSendaGCP2.responseCargueClientes> responseServicio = (List<XFLS_WrapperSendaGCP2.responseCargueClientes>) JSON.deserialize(
					objResponse.getBody(),
					List<XFLS_WrapperSendaGCP2.responseCargueClientes>.class
					);
                    System.debug(responseServicio);
                    if(responseServicio.size()>0){
                    objAccount2.Name = responseServicio[0].businessName	!= NULL? responseServicio[0].businessName : objAccount2.Name;
                    objAccount2.XFLS_Nit__c = String.valueOf(responseServicio[0].nit)	!= NULL? String.valueOf(responseServicio[0].nit) : objAccount2.XFLS_Nit__c;
                    objAccount2.XFLS_Direccion__c = responseServicio[0].address	!= NULL? responseServicio[0].address : objAccount2.XFLS_Direccion__c;
                    objAccount2.Phone = responseServicio[0].phoneNumber	!= NULL? responseServicio[0].phoneNumber : objAccount2.Phone;
                    objAccount2.XFLS_Representante_Legal__c = responseServicio[0].legalRepresentative	!= NULL? responseServicio[0].legalRepresentative : objAccount2.XFLS_Representante_Legal__c;
                    objAccount2.XFLS_Correo__c = responseServicio[0].email	!= NULL? responseServicio[0].email : objAccount2.XFLS_Correo__c;
					update objAccount2;
                    result = true;
                    }
                } else {
                    CS_Log__c log = new CS_Log__c();
                    log.CS_ShortDescription__c = 'Error cliente'; log.CS_Funcion__c = 'Cargar Cliente'; log.CS_ExceptionMessage__c = objResponse.getStatus();
                    log.CS_ExceptionStackTrace__c = 'XFLS_IntegracionCargueClient';log.CS_ResponseStatus__c = objResponse.getStatus();log.CS_ResponseStatusCode__c = objResponse.getStatusCode();
                    log.CS_RequestMethod__c = objRequest.getMethod();log.CS_RequestEndPoint__c = objRequest.getEndpoint();
                    insert log;
                    System.debug('Mandar mensaje de error'); // -----
                    result = false;
                }
            }catch(Exception e){
                system.debug('No mando servicios');
                result = false;
            }
        }else{
            System.debug('Nit invalido');
            result = false;
        }
        PageReference pageRef = new PageReference('/'+Id);
        pageRef.setRedirect(true);
       return pageRef;
        //return result;
    }
}