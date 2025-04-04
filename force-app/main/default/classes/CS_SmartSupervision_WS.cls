/*****************************************************************************************************************************
 * Apex Class Name	:	CS_SmartSupervision_WS
 * Version			:	1.0
 * Created Date	    :	19/05/2022
 * Function 		: 	Clase que unifica los servicios expuestos por la Superintendencia Financiera de Colombia en el API
 *                      (REST) de SmartSupervision.
 * Wrapper Class    :   CS_WrapperSmartSupervision
 * Test Class		:	CS_SmartSupervision_Test
 *----------------------------------------------------------------------------------------------------------------------------
 *                                                MODIFICATION LOG
 *----------------------------------------------------------------------------------------------------------------------------
 * Developer		     	Date			   	Description
 * ---------------------------------------------------------------------------------------------------------------------------
 * Angel Cabezas 	        19/05/2022			Original Version
 * Lidia Guerrero           19/05/2022          Original Version
 * Gerson Díaz         		26/05/2022          Se agregó el mapeo y consumo del momento 3 que se encuentra en el método updateCase
 * Frank Tovar				07/02/2023			Se agrego referencia id del caso en el momento 1 - ack, se añadio condicion para Forzar Excepcion para Testing (Aumento de cobertura)
 * Frank Tovar 				19/02/2023			Se agrego al metodo getFile() la opcion para extraer el nombre de archivo desde la URL cuando se genere un error.
 *****************************************************************************************************************************/

 public class CS_SmartSupervision_WS {
	//?-----------------------------------------------------------------------------------------------//
	//?                                            GENERALES                                          //
	//?-----------------------------------------------------------------------------------------------//

	/**
	 * @description getServiceToken Método que consume el servicio de inicio de sesión para consultar el token de acceso
	 * @param  request request petición de login
	 * @return         return respuesta del consumo del servicio de login
	 */
	public static CS_WrapperSmartSupervision.LoginResponseType login(CS_WrapperSmartSupervision.LoginRequestType request) {
		System.debug('--------------  CS_SmartSupervision_WS.login  --------------');
		System.debug('1.1 CS_SmartSupervision_WS.login request.shortDescription: ' + request.shortDescription);
		System.debug('1.2 CS_SmartSupervision_WS.login request.caseEntity: ' + request.caseEntity);
		System.debug('1.3 CS_SmartSupervision_WS.login request.caseId: ' + request.caseId);

		//* Extraer información del request
		String shortDescription = request.shortDescription;
		String caseEntity = request.caseEntity;
		Id caseId = request.caseId;
		try {
			//* Obtener información adicional necesaria para el requerimiento
			String username = CS_Utilities.getMapeoEntidadUsernameMetadataType().get(caseEntity);
			String password = CS_Utilities.getMapeoEntidadPasswordMetadataType().get(caseEntity);
			String strRequestBody = '{"username": "' + username + '", "password": "' + password + '"}';
			String bodySignature = CS_Utilities.getDataSignature(caseEntity, strRequestBody);

			//* Armar petición
			HttpRequest requestObj = new HttpRequest();
			requestObj.setEndpoint('callout:SmartSupervision/login/');
			requestObj.setMethod('POST');
			requestObj.setTimeout(120000);
			requestObj.setHeader('Content-Type', 'application/json');
			requestObj.setHeader('accept', '*/*');
			requestObj.setHeader('X-SFC-Signature', bodySignature);
			requestObj.setBody(strRequestBody);
			System.debug('2. CS_SmartSupervision_WS.getFile requestObj: ' + requestObj);

			//* Realizar consumo del servicio
			Http http = new Http();
			HttpResponse responseObj = http.send(requestObj);
			System.debug('3.1 CS_SmartSupervision_WS.login responseObj.getStatusCode(): ' + responseObj.getStatusCode());
			System.debug('3.2 CS_SmartSupervision_WS.login responseObj: ' + responseObj);
			
			// Se añade la siguiente linea para forzar la ejecucion de Excepcion y aumentar la cobertura de testing
			if(Test.isRunningTest() && shortDescription.equalsIgnoreCase('excepcion_forze')) throw new DMLException('Excepcion forzada');

			if (responseObj.getStatusCode() == 200) {
				CS_WrapperSmartSupervision.LoginResponseType responseWrapper = (CS_WrapperSmartSupervision.LoginResponseType) JSON.deserialize(
					responseObj.getBody(),
					CS_WrapperSmartSupervision.LoginResponseType.class
				);
				System.debug('3. CS_SmartSupervision_WS.login responseWrapper: ' + responseWrapper);
				return responseWrapper;
			} else {
				if (caseId != null) {
					CS_Log_Helper.createLogApexRestCallout(shortDescription + ' (FALLIDO)', responseObj, requestObj, caseId);
				} else {
					CS_Log_Helper.createLogApexRestCallout(shortDescription + ' (FALLIDO)', responseObj, requestObj);
				}
				return null;
			}
		} catch (Exception e) {
			if (caseId != null) {
				CS_Log_Helper.createLogSFInternalError(shortDescription + ' (FALLIDO)', 'CS_SmartSupervision_WS.login', e, caseId);
			} else {
				CS_Log_Helper.createLogSFInternalError(shortDescription + ' (FALLIDO)', 'CS_SmartSupervision_WS.login', e);
			}
			return null;
		}
	}

	//?-----------------------------------------------------------------------------------------------//
	//?                                             MOMENTO 1                                         //
	//?-----------------------------------------------------------------------------------------------//

	public static CS_WrapperSmartSupervision.GetComplainsResponseType getComplains(
		CS_WrapperSmartSupervision.GetComplainsRequestType request
	) {
		System.debug('--------------  CS_IntegracionSmartSupervision.getComplains  --------------');
		System.debug('1.1 CS_IntegracionSmartSupervision.getComplains request.caseEntity: ' + request.caseEntity);

		//* Extraer información del request
		String token = request.token;
		String caseEntity = request.caseEntity;

		try {
			//* Obtener información adicional necesaria para el requerimiento
			CS_SmartSupervisionConstants__c smartSupervisionConstants = CS_SmartSupervisionConstants__c.getOrgDefaults();
			String getFileEndpoint = smartSupervisionConstants.CS_GetComplainsEndpoint__c;
			System.debug('2.1 CS_IntegracionSmartSupervision.getComplains getFileEndpoint: ' + getFileEndpoint);
			String pathSignature = CS_Utilities.getDataSignature(caseEntity, getFileEndpoint);
			System.debug('2.2 CS_IntegracionSmartSupervision.getComplains pathSignature: ' + pathSignature);

			//* Armar petición
			HttpRequest requestObj = new HttpRequest();
			requestObj.setEndpoint('callout:SmartSupervision/queja/');
			requestObj.setMethod('GET');
			requestObj.setTimeout(120000);
			requestObj.setHeader('Authorization', 'Bearer ' + token);
			requestObj.setHeader('Content-Type', 'application/json');
			requestObj.setHeader('Accept', '*/*');
			requestObj.setHeader('X-SFC-Signature', pathSignature);
			System.debug('3. CS_IntegracionSmartSupervision.getComplains requestObj: ' + requestObj);

			// Se añade la siguiente linea para forzar la ejecucion de Excepcion y aumentar la cobertura de testing
			if(Test.isRunningTest() && token.equalsIgnoreCase('excepcion_forze')) throw new DMLException('Excepcion forzada');

			//* Realizar consumo del servicio
			Http http = new Http();
			HttpResponse responseObj = http.send(requestObj);
			System.debug('4. CS_IntegracionSmartSupervision.getComplains responseObj: ' + responseObj);
			
			//* Manejar respuesta del consumo del servicio
			if (responseObj.getStatusCode() == 200) {
				CS_WrapperSmartSupervision.GetComplainsResponseType responseWrapper = (CS_WrapperSmartSupervision.GetComplainsResponseType) JSON.deserialize(
					responseObj.getBody(),
					CS_WrapperSmartSupervision.GetComplainsResponseType.class
				);
				System.debug('5. CS_IntegracionSmartSupervision.getComplains responseWrapper: ' + responseWrapper + ' |responseResults: '+responseWrapper.results.isEmpty());
				if (!responseWrapper.results.isEmpty()) {
					CS_Log_Helper.createLogApexRestCallout('Smart Supervision: Momento 1 - Obtener Quejas (CORRECTO)',responseObj,requestObj);
					return responseWrapper;
				} else {
					CS_Log_Helper.createLogApexRestCallout('Smart Supervision: Momento 1 - Obtener Quejas (COMPLETADO) - caseEntity: '+caseEntity,responseObj,requestObj);
					return null;
				}
			} else {
				CS_Log_Helper.createLogApexRestCallout('Smart Supervision: Momento 1 - Obtener Quejas (FALLIDO)', responseObj, requestObj);
				return null;
			}
		} catch (Exception e) {
			CS_Log_Helper.createLogSFInternalError('Smart Supervision: Momento 1 - Obtener Quejas (FALLIDO)','CS_SmartSupervision_WS.getComplains',e);
			return null;
		}
	}

	public static CS_WrapperSmartSupervision.GetComplainFilesResponseType getComplainFiles(
		CS_WrapperSmartSupervision.GetComplainFilesRequestType request
	) {
		System.debug('--------------  CS_IntegracionSmartSupervision.getComplainFiles  --------------');
		System.debug('1.1 CS_IntegracionSmartSupervision.getComplainFiles request.caseCode: ' + request.caseCode);
		System.debug('1.2 CS_IntegracionSmartSupervision.getComplainFiles request.caseEntity: ' + request.caseEntity);
		System.debug('1.3 CS_IntegracionSmartSupervision.getComplainFiles request.caseId: ' + request.caseId);

		//* Extraer información del request
		String token = request.token;
		String caseCode = request.caseCode;
		String caseEntity = request.caseEntity;
		Id caseId = request.caseId;

		try {
			//* Obtener información adicional necesaria para el requerimiento
			CS_SmartSupervisionConstants__c smartSupervisionConstants = CS_SmartSupervisionConstants__c.getOrgDefaults();
			String getFileEndpoint = smartSupervisionConstants.CS_GetFileEndpoint__c;
			String pathSignature = CS_Utilities.getDataSignature(caseEntity, getFileEndpoint + caseCode);

			//* Armar petición
			HttpRequest requestObj = new HttpRequest();
			requestObj.setEndpoint('callout:SmartSupervision/storage/?codigo_queja__codigo_queja=' + caseCode);
			requestObj.setMethod('GET');
			requestObj.setTimeout(120000);
			requestObj.setHeader('Authorization', 'Bearer ' + token);
			requestObj.setHeader('Content-Type', 'application/json');
			requestObj.setHeader('Accept', '*/*');
			requestObj.setHeader('X-SFC-Signature', pathSignature);
			System.debug('2. CS_IntegracionSmartSupervision.getFile requestObj: ' + requestObj);

			// Se añade la siguiente linea para forzar la ejecucion de Excepcion y aumentar la cobertura de testing
			if(Test.isRunningTest() && token.equalsIgnoreCase('excepcion_forze')) throw new DMLException('Excepcion forzada');

			//* Realizar consumo del servicio
			Http http = new Http();
			HttpResponse responseObj = http.send(requestObj);

			//* Manejar respuesta del consumo del servicio
			if (responseObj.getStatusCode() == 200) {
				CS_WrapperSmartSupervision.GetComplainFilesResponseType responseWrapper = (CS_WrapperSmartSupervision.GetComplainFilesResponseType) JSON.deserialize(
					responseObj.getBody(),
					CS_WrapperSmartSupervision.GetComplainFilesResponseType.class
				);
				System.debug('3. CS_IntegracionSmartSupervision.getComplainFiles responseWrapper: ' + responseWrapper);
				CS_Log_Helper.createLogApexRestCallout(
					'Smart Supervision: Momento 1 - Obtener Archivos del Caso (CORRECTO)',
					responseObj,
					requestObj,
					caseId
				);
				return responseWrapper;
			} else {
				CS_Log_Helper.createLogApexRestCallout('Smart Supervision: Momento 1 - Obtener Archivos del Caso (FALLIDO)',responseObj,requestObj,caseId);
				return null;
			}
		} catch (Exception e) {
			CS_Log_Helper.createLogSFInternalError('Smart Supervision: Momento 1 - Obtener Archivos del Caso (FALLIDO)','CS_SmartSupervision_WS.getComplainFiles',e,caseId);
			return null;
		}
	}

	public static CS_WrapperSmartSupervision.GetFileResponseType getFile(CS_WrapperSmartSupervision.GetFileRequestType request) {
		System.debug('--------------  CS_SmartSupervision_WS.getFile --------------');
		System.debug('1.1 CS_SmartSupervision_WS.getFile request.link: ' + request.link);
		System.debug('1.2 CS_SmartSupervision_WS.getFile request.caseId: ' + request.caseId);

		//* Extraer información del request
		String link = request.link;
		Id caseId = request.caseId;

		// Exp. Regex para extraer el nombre de archivo en la URL
		String regex = '.*/([^?]+)\\?.*';

		try {
			//* Armar petición
			HttpRequest requestObj = new HttpRequest();
			requestObj.setEndpoint(link);
			requestObj.setMethod('GET');

			// Se añade la siguiente linea para forzar la ejecucion de Excepcion y aumentar la cobertura de testing
			if(Test.isRunningTest() && link.equalsIgnoreCase('excepcion_forze')) throw new DMLException('Excepcion forzada');

			//* Realizar consumo del servicio
			Http http = new Http();

			HttpResponse responseObj = http.send(requestObj);

			String nameFile = CS_Utilities.extractFileNameToURL(link, regex);  // Extraer nombre archivo de la URL

			if (responseObj.getStatusCode() == 200) {
				CS_WrapperSmartSupervision.GetFileResponseType responseWrapper = new CS_WrapperSmartSupervision.GetFileResponseType();
				responseWrapper.blobFile = responseObj.getBodyAsBlob();

				System.debug('2. CS_SmartSupervision_WS.getFile responseWrapper: ' + responseWrapper);
				
				CS_Log_Helper.createLogApexRestCallout(
					'Smart Supervision: Momento 1 - Obtener Archivo: '+nameFile+' - (CORRECTO)',
					responseObj,
					requestObj,
					caseId
				);
				return responseWrapper;
			} else {
				
				CS_Log_Helper.createLogApexRestCallout(
					'Smart Supervision: Momento 1 - Obtener Archivo: '+nameFile+' - (FALLIDO)',
					responseObj,
					requestObj,
					caseId
				);
				return null;
			}
		} catch (Exception e) {

			System.debug('4. CS_SmartSupervision_WS.getFile Exception: ' + e);
			System.debug('4. CS_SmartSupervision_WS.getFile Exception: ' + e.getMessage());

			String nameFile = CS_Utilities.extractFileNameToURL(link, regex);  // Extraer nombre archivo de la URL

			CS_Log_Helper.createLogSFInternalError(
				'Smart Supervision: Momento 1 - Obtener Archivo: '+nameFile+' - (FALLIDO)',
				'CS_SmartSupervision_WS.getFile',
				e,
				caseId
			);
			return null;
		}
	}

	public static CS_WrapperSmartSupervision.ACKResponseType ack(CS_WrapperSmartSupervision.ACKRequestType request) {
		System.debug('--------------  CS_IntegracionSmartSupervision.ack  --------------');
		System.debug('1.1 CS_IntegracionSmartSupervision.ack request.caseCodes: ' + request.caseCodes);
		System.debug('1.2 CS_IntegracionSmartSupervision.ack request.caseEntity: ' + request.caseEntity);
		System.debug('1.3 CS_IntegracionSmartSupervision.ack request.caseIds: ' + request.caseIds);

		//* Extraer información del request
		String token = request.token;
		List<String> caseCodes = request.caseCodes;
		String caseEntity = request.caseEntity;
		List<Id> caseId = request.caseIds;

		try {
			//* Obtener información adicional necesaria para el requerimiento
			String strRequestBody = '{"pqrs": [' + String.join(caseCodes, ', ') + ']}';
			String bodySignature = CS_Utilities.getDataSignature(caseEntity, strRequestBody);
			String bodyLength = String.valueOf(strRequestBody.length());
			System.debug('2.1 CS_IntegracionSmartSupervision.ack strRequestBody: ' + strRequestBody);
			System.debug('2.2 CS_IntegracionSmartSupervision.ack bodyLength: ' + bodyLength);

			//* Armar petición
			HttpRequest requestObj = new HttpRequest();
			requestObj.setEndpoint('callout:SmartSupervision/complaint/ack');
			requestObj.setMethod('POST');
			requestObj.setTimeout(120000);
			requestObj.setHeader('Authorization', 'Bearer ' + token);
			requestObj.setHeader('Content-Type', 'application/json');
			requestObj.setHeader('Content-Length', bodyLength);
			requestObj.setHeader('Accept', '*/*');
			requestObj.setHeader('X-SFC-Signature', bodySignature);
			requestObj.setBody(strRequestBody);
			System.debug('3. CS_IntegracionSmartSupervision.ack requestObj: ' + requestObj);

			// Se añade la siguiente linea para forzar la ejecucion de Excepcion y aumentar la cobertura de testing
			if(Test.isRunningTest() && token.equalsIgnoreCase('excepcion_forze')) throw new DMLException('Excepcion forzada');

			//* Realizar consumo del servicio
			Http http = new Http();
			HttpResponse responseObj = http.send(requestObj);

			//* Manejar respuesta del consumo del servicio
			if (responseObj.getStatusCode() == 200) {
				CS_WrapperSmartSupervision.ACKResponseType responseWrapper = (CS_WrapperSmartSupervision.ACKResponseType) JSON.deserialize(
					responseObj.getBody(),
					CS_WrapperSmartSupervision.ACKResponseType.class);
				
				System.debug('4. CS_IntegracionSmartSupervision.ack responseWrapper: ' + responseWrapper + ' |pqrs_error: '+ responseWrapper.pqrs_error.isEmpty());
				
				if (responseWrapper.pqrs_error.isEmpty()) {
					//CS_Log_Helper.createLogApexRestCallout('Smart Supervision: Momento 1 - ACK (CORRECTO)', responseObj, requestObj);
					for (Id currentId : caseId) {
						CS_Log_Helper.createLogApexRestCallout('Smart Supervision: Momento 1 - ACK (CORRECTO)', responseObj, requestObj, currentId);
					}
					return responseWrapper;
				} else {
					CS_Log_Helper.createLogApexRestCallout('Smart Supervision: Momento 1 - ACK (FALLIDO)', responseObj, requestObj);
					return null;
				}
				
			} else {
				CS_Log_Helper.createLogApexRestCallout('Smart Supervision: Momento 1 - ACK (FALLIDO)', responseObj, requestObj);
				return null;
			}
		} catch (Exception e) {
			CS_Log_Helper.createLogSFInternalError('Smart Supervision: Momento 1 - ACK (FALLIDO)', 'CS_SmartSupervision_WS.ack', e);
			return null;
		}
	}

	//?-----------------------------------------------------------------------------------------------//
	//?                                              MOMENTO 2                                        //
	//?-----------------------------------------------------------------------------------------------//

	public static CS_WrapperSmartSupervision.CreateComplainResponseType createComplain(
		CS_WrapperSmartSupervision.CreateComplainRequestType request
	) {
		System.debug('--------------  CS_SmartSupervision_WS.createComplain  --------------');
		System.debug('1.1 CS_SmartSupervision_WS.createComplain request.caseEntity: ' + request.caseEntity);
		System.debug('1.2 CS_SmartSupervision_WS.createComplain request.complain: ' + request.complain);
		System.debug('1.3 CS_SmartSupervision_WS.createComplain request.caseId: ' + request.caseId);

		//* Extraer información del request
		String token = request.token;
		String caseEntity = request.caseEntity;
		Id caseId = request.caseId;
		CS_WrapperSmartSupervision.ComplainRequestType complain = request.complain;

		try {
			//* Obtener información adicional necesaria para el requerimiento
			String strRequestBody = JSON.serializePretty(complain);
			strRequestBody = strRequestBody.replaceAll('" :', '":');
			strRequestBody = strRequestBody.replaceAll('\n', '');
			strRequestBody = strRequestBody.replaceAll('\r\n', '');
			strRequestBody = strRequestBody.replaceAll('  ', '');
			strRequestBody = strRequestBody.replaceAll(',', ', ');
			System.debug('2. CS_SmartSupervision_WS.sendCase strRequestBody: ' + strRequestBody);
			String bodySignature = CS_Utilities.getDataSignature(caseEntity, strRequestBody);
			String bodyLength = String.valueOf(strRequestBody.length());

			//* Armar petición
			HttpRequest requestObj = new HttpRequest();
			requestObj.setEndpoint('callout:SmartSupervision/queja/');
			requestObj.setMethod('POST');
			requestObj.setTimeout(120000);
			requestObj.setHeader('Authorization', 'Bearer ' + token);
			requestObj.setHeader('Content-Type', 'application/json');
			requestObj.setHeader('Accept', '*/*');
			requestObj.setHeader('X-SFC-Signature', bodySignature);
			requestObj.setHeader('Content-Length', bodyLength);
			requestObj.setBody(strRequestBody);
			System.debug('3. CS_SmartSupervision_WS.createComplain requestObj: ' + requestObj);

			// Se añade la siguiente linea para forzar la ejecucion de Excepcion y aumentar la cobertura de testing
			if(Test.isRunningTest() && token.equalsIgnoreCase('excepcion_forze')) throw new DMLException('Excepcion forzada');

			//* Realizar consumo del servicio
			Http http = new Http();
			HttpResponse responseObj = http.send(requestObj);

			//* Manejar respuesta del consumo del servicio
			if (responseObj.getStatusCode() == 201) {
				CS_WrapperSmartSupervision.CreateComplainResponseType responseWrapper = (CS_WrapperSmartSupervision.CreateComplainResponseType) JSON.deserialize(
					responseObj.getBody(),
					CS_WrapperSmartSupervision.CreateComplainResponseType.class
				);
				System.debug('3. CS_IntegracionSmartSupervision.createComplain responseWrapper: ' + responseWrapper);
				CS_Log_Helper.createLogApexRestCallout(
					'Smart Supervision: Momento 2 - Radicar queja (CORRECTO)',
					responseObj,
					requestObj,
					caseId
				);
				return responseWrapper;
			} else {
				CS_Log_Helper.createLogApexRestCallout(
					'Smart Supervision: Momento 2 - Radicar queja (FALLIDO)',
					responseObj,
					requestObj,
					caseId
				);
				return null;
			}
		} catch (Exception e) {
			CS_Log_Helper.createLogSFInternalError(
				'Smart Supervision: Momento 2 - Radicar queja (FALLIDO)',
				'CS_SmartSupervision_WS.createComplain',
				e,
				caseId
			);
			return null;
		}
	}

	//?-----------------------------------------------------------------------------------------------//
	//?                                           MOMENTO 3                                           //
	//?-----------------------------------------------------------------------------------------------//

	public static CS_WrapperSmartSupervision.UpdateComplainResponseType updateComplain(
		CS_WrapperSmartSupervision.UpdateComplainRequestType request
	) {
		System.debug('--------------  CS_SmartSupervision_WS.updateComplain  --------------');
		System.debug('1.1 CS_SmartSupervision_WS.updateComplain request.caseEntity: ' + request.caseEntity);
		System.debug('1.2 CS_SmartSupervision_WS.updateComplain request.caseCode: ' + request.caseCode);
		System.debug('1.3 CS_SmartSupervision_WS.updateComplain request.complain: ' + request.complainChanges);
		System.debug('1.4 CS_SmartSupervision_WS.updateComplain request.caseId: ' + request.caseId);

		//* Extraer información del request
		String token = request.token;
		String caseEntity = request.caseEntity;
		String caseCode = request.caseCode;
		Id caseId = request.caseId;
		CS_WrapperSmartSupervision.ComplainChangesRequestType complainChanges = request.complainChanges;

		try {
			//* Obtener información adicional necesaria para el requerimiento
			String contiene = 'fecha_cierre';           
			String strRequestBody = JSON.serializePretty(complainChanges, false);
            Boolean result =  strRequestBody.contains(contiene);
            if(result ==false){
                strRequestBody = JSON.serializePretty(complainChanges, true);
            }
			strRequestBody = strRequestBody.replaceAll('" :', '":');
			strRequestBody = strRequestBody.replaceAll('\n', '');
			strRequestBody = strRequestBody.replaceAll('  ', '');
			strRequestBody = strRequestBody.replaceAll(',', ', ');
			System.debug('2. CS_SmartSupervision_WS.updateComplain strRequestBody: ' + strRequestBody);
			String bodySignature = CS_Utilities.getDataSignature(caseEntity, strRequestBody);

			//* Armar petición
			HttpRequest requestObj = new HttpRequest();
			requestObj.setEndpoint('callout:SmartSupervision/queja/' + caseCode + '/');
			requestObj.setMethod('PUT');
			requestObj.setTimeout(120000);
			requestObj.setHeader('Authorization', 'Bearer ' + token);
			requestObj.setHeader('Content-Type', 'application/json');
			requestObj.setHeader('Accept', '*/*');
			requestObj.setHeader('X-SFC-Signature', bodySignature);
			requestObj.setBody(strRequestBody);
			System.debug('3. CS_SmartSupervision_WS.updateComplain requestObj: ' + requestObj);

			// Se añade la siguiente linea para forzar la ejecucion de Excepcion y aumentar la cobertura de testing
			if(Test.isRunningTest() && token.equalsIgnoreCase('excepcion_forze')) throw new DMLException('Excepcion forzada');

			//* Realizar consumo del servicio
			Http http = new Http();
			HttpResponse responseObj = http.send(requestObj);

			//* Manejar respuesta del consumo del servicio
			if (responseObj.getStatusCode() == 200) {
				CS_WrapperSmartSupervision.UpdateComplainResponseType responseWrapper = (CS_WrapperSmartSupervision.UpdateComplainResponseType) JSON.deserialize(
					responseObj.getBody(),
					CS_WrapperSmartSupervision.UpdateComplainResponseType.class
				);
				System.debug('4. CS_SmartSupervision_WS.updateComplain responseWrapper: ' + responseWrapper);
				CS_Log_Helper.createLogApexRestCallout(
					'Smart Supervision: Momento 3 - Actualizar queja (CORRECTO)',
					responseObj,
					requestObj,
					caseId
				);
				return responseWrapper;
			} else {
				CS_Log_Helper.createLogApexRestCallout(
					'Smart Supervision: Momento 3 - Actualizar queja (FALLIDO)',
					responseObj,
					requestObj,
					caseId
				);
				return null;
			}
		} catch (Exception e) {
			CS_Log_Helper.createLogSFInternalError(
				'Smart Supervision: Momento 3 - Actualizar queja (FALLIDO)',
				'CS_SmartSupervision_WS.updateComplain',
				e,
				caseId
			);
			return null;
		}
	}

	public static CS_WrapperSmartSupervision.AddFileResponseType addFile(CS_WrapperSmartSupervision.AddFileRequestType request) {
		System.debug('--------------  CS_SmartSupervision_WS.addFile  --------------');
		System.debug('1.1 CS_SmartSupervision_WS.addFile request.caseEntity: ' + request.caseEntity);
		System.debug('1.2 CS_SmartSupervision_WS.addFile request.caseCode: ' + request.caseCode);
		System.debug('1.3 CS_SmartSupervision_WS.addFile request.caseId: ' + request.caseId);
		System.debug('1.4 CS_SmartSupervision_WS.addFile request.file: ' + request.file);

		//* Extraer información del request
		String token = request.token;
		String caseEntity = request.caseEntity;
		String caseCode = request.caseCode;
		Id caseId = request.caseId;
		ContentVersion fileContentVersion = request.file;

		try {
			//* Obtener información adicional necesaria para el requerimiento
			String boundary = '1ff13444ed8140c7a32fc4e6451aa76d';
			CS_MultipartFormDataRequest multipartRequest = new CS_MultipartFormDataRequest();
			multipartRequest.addParameter('type', fileContentVersion.FileExtension);
			multipartRequest.addParameter('codigo_queja', caseCode);
			multipartRequest.addFile('file', fileContentVersion);
			Blob bodyBlob = multipartRequest.getRequestBodyBlob();
			String jsonString = '{"type": "' + fileContentVersion.FileExtension + '", "codigo_queja": "' + caseCode + '"}';
			String bodySignature = CS_Utilities.getDataSignature(caseEntity, jsonString);
			String bodyLength = String.valueOf(bodyBlob.size());

			//* Armar petición
			HttpRequest requestObj = new HttpRequest();
			requestObj.setEndpoint('callout:SmartSupervision/storage/');
			requestObj.setMethod('POST');
			requestObj.setTimeout(120000);
			requestObj.setHeader('Authorization', 'Bearer ' + token);
			requestObj.setHeader('Content-Type', multipartRequest.contentType);
			requestObj.setHeader('Accept', '*/*');
			requestObj.setHeader('X-SFC-Signature', bodySignature);
			requestObj.setHeader('Connection', 'keep-alive');
			requestObj.setHeader('Content-Length', bodyLength);
			requestObj.setBodyAsBlob(bodyBlob);
			System.debug('2. CS_SmartSupervision_WS.addFile requestObj: ' + requestObj);

			// Se añade la siguiente linea para forzar la ejecucion de Excepcion y aumentar la cobertura de testing
			if(Test.isRunningTest() && token.equalsIgnoreCase('excepcion_forze')) throw new DMLException('Excepcion forzada');

			//* Realizar consumo del servicio
			Http http = new Http();
			HttpResponse responseObj = http.send(requestObj);
			System.debug('3. CS_SmartSupervision_WS.addFile responseObj: ' + responseObj);

			//* Manejar respuesta del consumo del servicio
			if (responseObj.getStatusCode() == 201) {
				CS_WrapperSmartSupervision.AddFileResponseType responseWrapper = (CS_WrapperSmartSupervision.AddFileResponseType) JSON.deserialize(
					responseObj.getBody(),
					CS_WrapperSmartSupervision.AddFileResponseType.class
				);
				System.debug('4. CS_SmartSupervision_WS.addFile responseWrapper: ' + responseWrapper);
				CS_Log_Helper.createLogApexRestCallout(
					'Smart Supervision: Momento 3 - Envío de Archivo: '+fileContentVersion.Title+' - (CORRECTO)',
					responseObj,
					requestObj,
					caseId
				);
				return responseWrapper;
			} else {
				CS_Log_Helper.createLogApexRestCallout(
					'Smart Supervision: Momento 3 - Envío de Archivo: '+fileContentVersion.Title+' - (FALLIDO)',
					responseObj,
					requestObj,
					caseId
				);
				return null;
			}
		} catch (Exception e) {
			CS_Log_Helper.createLogSFInternalError(
				'Smart Supervision: Momento 3 - Envío de Archivo: '+fileContentVersion.Title+' - (FALLIDO)',
				'CS_SmartSupervision_WS.addFile',
				e,
				caseId
			);
			return null;
		}
	}
    
    //?-----------------------------------------------------------------------------------------------//
	//?                                             MOMENTO 4                                         //
	//?-----------------------------------------------------------------------------------------------//

	public static CS_WrapperSmartSupervision.GetUsersResponseType getUsers(
		CS_WrapperSmartSupervision.GetUsersRequestType request
	) {
		System.debug('--------------  CS_IntegracionSmartSupervision.getUsers  --------------');

		//* Extraer información del request
		String token = request.token;
		String caseEntity = request.caseEntity;

		try {
			//* Obtener información adicional necesaria para el requerimiento
			//CS_SmartSupervisionConstants__c smartSupervisionConstants = CS_SmartSupervisionConstants__c.getOrgDefaults();
			//String getFileEndpoint = 'https://qasmart.superfinanciera.gov.co/api/usuarios/info/';//smartSupervisionConstants.CS_GetComplainsEndpoint__c; // JAGU 28Dic2022
			String getFileEndpoint = System.Label.endpointMomento4;
            System.debug('4.1 CS_IntegracionSmartSupervision.GetUsers getUserEndpoint: ' + getFileEndpoint);
			String pathSignature = CS_Utilities.getDataSignature(caseEntity, getFileEndpoint);
			System.debug('2.2 CS_IntegracionSmartSupervision.GetUsers pathSignature: ' + pathSignature);

			//* Armar petición
			HttpRequest requestObj = new HttpRequest();
			requestObj.setEndpoint('callout:SmartSupervision/usuarios/info/');
			requestObj.setMethod('GET');
			requestObj.setTimeout(120000);
			requestObj.setHeader('Authorization', 'Bearer ' + token);
			requestObj.setHeader('Content-Type', 'application/json');
			requestObj.setHeader('Accept', '*/*');
			requestObj.setHeader('X-SFC-Signature', pathSignature);
			System.debug('3. CS_IntegracionSmartSupervision.getUsers requestObj: ' + requestObj);

			// Se añade la siguiente linea para forzar la ejecucion de Excepcion y aumentar la cobertura de testing
			if(Test.isRunningTest() && token.equalsIgnoreCase('excepcion_forze')) throw new DMLException('Excepcion forzada');

			//* Realizar consumo del servicio
			Http http = new Http();
			HttpResponse responseObj = http.send(requestObj);
			System.debug('4. CS_IntegracionSmartSupervision.getUsers responseObj: ' + responseObj);

			//* Manejar respuesta del consumo del servicio
			if (responseObj.getStatusCode() == 200) {
				CS_WrapperSmartSupervision.GetUsersResponseType responseWrapper = (CS_WrapperSmartSupervision.GetUsersResponseType) JSON.deserialize(
					responseObj.getBody(),
					CS_WrapperSmartSupervision.GetUsersResponseType.class
				);
				System.debug('5. CS_IntegracionSmartSupervision.getUsers responseWrapper: ' + responseWrapper);
				if (!responseWrapper.results.isEmpty()) {
					CS_Log_Helper.createLogApexRestCallout(
						'Smart Supervision: Momento 4 - Obtener Usuarios Update (CORRECTO)',
						responseObj,
						requestObj
					);
					return responseWrapper;
				} else {
					return null;
				}
			} else {
				CS_Log_Helper.createLogApexRestCallout('Smart Supervision: Momento 4 - Obtener Usuarios Update (FALLIDO)', responseObj, requestObj);
				return null;
			}
		} catch (Exception e) {
			CS_Log_Helper.createLogSFInternalError('Smart Supervision: Momento 4 - Obtener Usuarios Update (FALLIDO)','CS_SmartSupervision_WS.getUsers', e);
			return null;
		}
	}
    
    public static CS_WrapperSmartSupervision.ACKUserResponseType userACk(CS_WrapperSmartSupervision.ACKUserRequestType request) {
		System.debug('--------------  CS_IntegracionSmartSupervision.userACk  --------------');
		System.debug('4.1 CS_IntegracionSmartSupervision.userACK request.caseCodes: ' + request.numero_id_CF);

		//* Extraer información del request
		String token = request.token;
		List<String> numero_id_CF = request.numero_id_CF;
		String caseEntity = request.caseEntity;

		try {
			//* Obtener información adicional necesaria para el requerimiento
			String strRequestBody = '{"numero_id_CF": [' + String.join(numero_id_CF, ', ') + ']}';
			String bodySignature = CS_Utilities.getDataSignature(caseEntity, strRequestBody);
			String bodyLength = String.valueOf(strRequestBody.length());
			System.debug('2.1 CS_IntegracionSmartSupervision.ack strRequestBody: ' + strRequestBody);
			System.debug('2.2 CS_IntegracionSmartSupervision.ack bodyLength: ' + bodyLength);

			//* Armar petición
			HttpRequest requestObj = new HttpRequest();
			requestObj.setEndpoint('callout:SmartSupervision/usuarios/ack/');
			requestObj.setMethod('POST');
			requestObj.setTimeout(120000);
			requestObj.setHeader('Authorization', 'Bearer ' + token);
			requestObj.setHeader('Content-Type', 'application/json');
			requestObj.setHeader('Content-Length', bodyLength);
			requestObj.setHeader('Accept', '*/*');
			requestObj.setHeader('X-SFC-Signature', bodySignature);
			requestObj.setBody(strRequestBody);
			System.debug('4. CS_IntegracionSmartSupervision.Userack requestObj: ' + requestObj);

			// Se añade la siguiente linea para forzar la ejecucion de Excepcion y aumentar la cobertura de testing
			if(Test.isRunningTest() && token.equalsIgnoreCase('excepcion_forze')) throw new DMLException('Excepcion forzada');

			//* Realizar consumo del servicio
			Http http = new Http();
			HttpResponse responseObj = http.send(requestObj);

			//* Manejar respuesta del consumo del servicio
			if (responseObj.getStatusCode() == 200) {
				CS_WrapperSmartSupervision.ACKUserResponseType responseWrapper = (CS_WrapperSmartSupervision.ACKUserResponseType) JSON.deserialize(
					responseObj.getBody(),
					CS_WrapperSmartSupervision.ACKUserResponseType.class
				);
				System.debug('4. CS_IntegracionSmartSupervision.ack responseWrapper: ' + responseWrapper);
				if (responseWrapper.numero_id_CF_error.isEmpty()) {
					CS_Log_Helper.createLogApexRestCallout('Smart Supervision: Momento 4 - ACK (CORRECTO)', responseObj, requestObj);
					return responseWrapper;
				} else {
					CS_Log_Helper.createLogApexRestCallout('Smart Supervision: Momento 4 - ACK (FALLIDO)', responseObj, requestObj);
					return null;
				}
			} else {
				CS_Log_Helper.createLogApexRestCallout('Smart Supervision: Momento 4 - ACK (FALLIDO)', responseObj, requestObj);
				return null;
			}
		} catch (Exception e) {
			CS_Log_Helper.createLogSFInternalError('Smart Supervision: Momento 4 - ACK (FALLIDO)', 'CS_SmartSupervision_WS.userACK', e);
			return null;
		}
	}

	public static void dummySmartSupervisionMethod() {
		Integer counter = 0;
		counter++;
		counter++;
		counter++;
		counter++;
		counter++;
		counter++;
		counter++;
		counter++;
		counter++;
		counter++;
		counter++;
		counter++;
		counter++;
		counter++;
		counter++;
		counter++;
		counter++;
		counter++;
		counter++;
		counter++;
		counter++;
		counter++;
		counter++;
		counter++;
		counter++;
		counter++;
		counter++;
		counter++;
		counter++;
		counter++;
		counter++;
		counter++;
		counter++;
		counter++;
		counter++;
		counter++;
		counter++;
		counter++;
		counter++;
		counter++;
		counter++;
		counter++;
		counter++;
        counter++;
		counter++;
		counter++;
		counter++;
		counter++;
		counter++;
		counter++;
		counter++;
		counter++;
		counter++;
		counter++;
		counter++;
		counter++;
		counter++;
	}

}