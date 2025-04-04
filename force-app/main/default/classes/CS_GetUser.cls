/*
* ===================================================================================
* @className        CS_GetUser
* @description      Class to generate the request of moment 4
* @author           JP
* @version          V0.1 
* @testClass        CS_GetUser_Test
* @dateCreated      2022-11
* ==============================================================================================================================
*/ 
public class CS_GetUser {
    
    //?-----------------------------------------------------------------------------------------------//
	//?                                            MOMENTO 4                                          //
	//?-----------------------------------------------------------------------------------------------//

	@future(callout=true)
	public static void getUserFuture(String entityValue) {
		System.debug('--------------  CS_GetUser.getUserFuture  --------------');
		System.debug('4  entityValue: ' + entityValue);
        map<String,CS_WrapperSmartSupervision.GetUserResponseType> mapResp = new map<String,CS_WrapperSmartSupervision.GetUserResponseType>();
		List<Case> listUdpCase = new List<Case>();
        Set<String> setNumeroidCF = new Set<String>();
        id idQuejaSuper = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('CS_Queja_Superintendencia').getRecordTypeId();
		try {
			//* Realizar login para obtener el token de acceso
			CS_WrapperSmartSupervision.LoginRequestType loginRequest = new CS_WrapperSmartSupervision.LoginRequestType();
			loginRequest.caseEntity = entityValue;
			loginRequest.shortDescription = 'Smart Supervision: Momento 4 - Obtener Usuarios';
			CS_WrapperSmartSupervision.LoginResponseType loginResponse = CS_SmartSupervision_WS.login(loginRequest);
			if (loginResponse != null) {
				//* Consumir servicio de consulta de usuarios
				CS_WrapperSmartSupervision.GetUsersRequestType getUsersRequest = new CS_WrapperSmartSupervision.GetUsersRequestType();
				getUsersRequest.token = loginResponse.access;
                getUsersRequest.caseEntity =entityValue;
				CS_WrapperSmartSupervision.GetUsersResponseType getUsersResponse = CS_SmartSupervision_WS.getUsers(
					getUsersRequest
				);
				//* Manejar resultado de la consulta
				if (getUsersResponse != null && !getUsersResponse.results.isEmpty()) {
					List<String> idNumbersList = new List<String>();
					List<String> caseCodesList = new List<String>();
                    for (CS_WrapperSmartSupervision.GetUserResponseType user : getUsersResponse.results) {
                        setNumeroidCF.add(user.numero_id_CF);
						mapResp.put(user.numero_id_CF,user);
					}		
                    system.debug('Map resp' + mapResp);
                    String entityCodeValue = entityValue == '1' ? '25' : entityValue == '2' ? '32': '3'; 
                    list<Case> casosEnc = [SELECT
							Id,
							CS_SuperintendenciaName__c,
							CS_SuperintendenciaFechaNacimiento__c,
							CS_SuperintendenciaEmail__c,
							CS_SuperintendenciaPhone__c,
							CS_SuperintendenciaRazonSocial__c,
							CS_SuperintendenciaAddress__c,
							CS_SuperintendenciaDepartamento__c,
                        	CS_SuperintendenciaMunicipio__c,
                        	CS_CodigoEntidad__c,
                        	Account.CS_NumeroIdentificacionCP__pc
						FROM Case
						WHERE
                            (CS_EstadoQuejaReclamo__c != '4' OR (CS_EstadoSincronizacionSuperfinanciera__c != 'Actualizado' AND CS_EstadoQuejaReclamo__c = '4' ))
                        	AND CS_CodigoEntidad__c =: Integer.valueof(entityCodeValue)
                        	AND recordtypeid =: idQuejaSuper
							AND Account.CS_NumeroIdentificacionCP__pc IN :mapResp.keySet()
						WITH SECURITY_ENFORCED];
                    system.debug('Tamaño de lista: ' + casosEnc.size());
					for (Case casoUpdate : casosEnc) {
                        System.debug('Ingreso');
                        case udpcase = new case();
                        udpcase.id = casoUpdate.id;   
                        udpcase.CS_SuperintendenciaName__c				= mapResp.get(casoUpdate.Account.CS_NumeroIdentificacionCP__pc).nombre + ' ' + mapResp.get(casoUpdate.Account.CS_NumeroIdentificacionCP__pc).apellido;
                        udpcase.CS_SuperintendenciaFechaNacimiento__c	= Date.valueOf(mapResp.get(casoUpdate.Account.CS_NumeroIdentificacionCP__pc).fecha_nacimiento);
                        udpcase.CS_SuperintendenciaEmail__c				= mapResp.get(casoUpdate.Account.CS_NumeroIdentificacionCP__pc).correo;
                        udpcase.CS_SuperintendenciaPhone__c				= mapResp.get(casoUpdate.Account.CS_NumeroIdentificacionCP__pc).telefono;
                        udpcase.CS_SuperintendenciaRazonSocial__c		= String.isblank(mapResp.get(casoUpdate.Account.CS_NumeroIdentificacionCP__pc).razon_social) ? null: mapResp.get(casoUpdate.Account.CS_NumeroIdentificacionCP__pc).razon_social;
                        udpcase.CS_SuperintendenciaAddress__c			= String.isblank(mapResp.get(casoUpdate.Account.CS_NumeroIdentificacionCP__pc).direccion) ? null: mapResp.get(casoUpdate.Account.CS_NumeroIdentificacionCP__pc).direccion;
                        udpcase.CS_SuperintendenciaDepartamento__c		= String.isblank(mapResp.get(casoUpdate.Account.CS_NumeroIdentificacionCP__pc).departamento_cod) ? null: mapResp.get(casoUpdate.Account.CS_NumeroIdentificacionCP__pc).departamento_cod;
                        udpcase.CS_SuperintendenciaMunicipio__c			= String.isblank(mapResp.get(casoUpdate.Account.CS_NumeroIdentificacionCP__pc).municipio_cod) ? null: mapResp.get(casoUpdate.Account.CS_NumeroIdentificacionCP__pc).municipio_cod;
						listUdpCase.add(udpcase);
					}	
                    system.debug('Datos a actualizar 1 : ' + listUdpCase.size());
				}
			}
		} catch (Exception e) {
			CS_Log_Helper.createLogSFInternalError(
				'Smart Supervision: Momento 4 - Obtener Usuarios (FALLIDO)',
				'CS_GetUser.getUserFuture',
				e
			);
		}
        Database.SaveResult[] urListCases = Database.update(listUdpCase, false);
        system.debug('Datos a actualizar' + listUdpCase.size());
		for (Database.SaveResult ur : urListCases) {
			if (!ur.isSuccess()) {
				for (Database.Error errorDb : ur.getErrors()) {
					CS_Log_Helper.createLogSFInternalDatabaseError(
						'Smart Supervision: Momento 4 - Update Usuario (FALLIDO)',
						'CS_GetUser.getUserFuture',
						errorDb
					);
				}
			}
		}
        //Envio de ACK
        //Validamos si ahi respuestaa enviar, y enviamos ack
        if(setNumeroidCF.size() > 0){
            System.enqueueJob(new CS_QueubleUserACK(setNumeroidCF, entityValue));
        }
        
	}
    
    
    @future(callout=true)
	public static void ackUserFuture(Set<String> setNumeroidCF, String entityValue) {
		
		//* Realizar login para obtener el token de acceso
		CS_WrapperSmartSupervision.LoginRequestType loginRequest = new CS_WrapperSmartSupervision.LoginRequestType();
		loginRequest.caseEntity = entityValue;
		loginRequest.shortDescription = 'Smart Supervision: Momento 4 - ACK';
		CS_WrapperSmartSupervision.LoginResponseType loginResponse = CS_SmartSupervision_WS.login(loginRequest);

		if (loginResponse != null) {
			//* Consumir servicio de ACK
			CS_WrapperSmartSupervision.ACKUserRequestType request = new CS_WrapperSmartSupervision.ACKUserRequestType();
			request.token = loginResponse.access;
			request.caseEntity = entityValue;
			List<Id> caseIdsList = new List<Id>();
			List<String> numero_id_CF = new List<String>();
			for (String nId : setNumeroidCF) {
				numero_id_CF.add('"' + nId + '"');
			}
			request.numero_id_CF = numero_id_CF;
			CS_WrapperSmartSupervision.ACKUserResponseType ackResponse = CS_SmartSupervision_WS.userACk(request);
		}
	}
}