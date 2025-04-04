/*********************************************************************************************************************************************
 Nombre de la Clase Apex: CS_Log_Helper
 Versión : 1.0
 Fecha de Creación : 13/05/2022
 Funcionalidad :  Helper del objeto de Logs
 Clase de Prueba: 
 Historial de Modificaciones:
 --------------------------------------------------------------------------------------------------------------------------------------------
 * Desarrollador -    Fecha –     Descripción
 * -----------------------------------------------------------------------------------------------------------------------------------------
 * Angel Cabezas     13/05/2022   Versión Original
 * Lidia Guerrero    25/05/2022   Errores en operaciones DML
 * Lidia Guerrero    06/06/2022   Se agregan métodos de HttpRequest con y sin id de caso relacionado
 * Lidia Guerrero    14/06/2022   Generar n numero de registros dependiendo el tamaño de request.body,request.bodyAsBlob, response.body
 *********************************************************************************************************************************************/
@SuppressWarnings('PMD')
public with sharing class CS_Log_Helper {
	//?-----------------------------------------------------------------------------------------------//
	//?                                               CONSTANTS                                       //
	//?-----------------------------------------------------------------------------------------------//

	//* Valores aceptados como parámetro de filtrado en los servicios web
	public static final String APEX_REST_CALLOUT_RECORD_TYPE = 'CS_ApexRestCallout';
	public static final String APEX_SFINTERNAL_ERROR_RECORD_TYPE = 'CS_SalesforceInternal';

	//?-----------------------------------------------------------------------------------------------//
	//?                                               METHODS                                         //
	//?-----------------------------------------------------------------------------------------------//

	public static void createLogApexRestCallout(String shortDescription, HttpResponse response, HttpRequest request) {
		Id recordTypeId = CS_Utilities.getRecordTypeIdByDevName(Schema.SObjectType.CS_Log__c, APEX_REST_CALLOUT_RECORD_TYPE);

		Integer sizeResponseBody = response.getBody() != null ? response.getBody().length() : 0;
		System.debug('sizeResponseBody: ' + sizeResponseBody);
		Integer sizeRequestBody = request.getBody() != null ? String.valueOf(request.getBody()).length() : 0;
		System.debug('sizeRequestBody: ' + sizeRequestBody);
		//Integer sizeRequestBodyAsBlob = request.getBodyAsBlob() != null ? String.valueOf(request.getBodyAsBlob()).length() : 0;
		//System.debug('sizeRequestBodyAsBlob: ' + sizeRequestBodyAsBlob);

		Decimal maxLength = /*Math.max(*/Math.max(sizeResponseBody, sizeRequestBody)/*, sizeRequestBodyAsBlob)*/;
		System.debug('El máximo de los 3 es: ' + maxLength);
		Decimal numberOfRecords = maxLength / 32000.00;
		Integer numberOfRecordsToCreate = (Integer) numberOfRecords.round(system.RoundingMode.CEILING);
		System.debug('numberOfRecordsToCreate: ' + numberOfRecordsToCreate);

		Decimal strNumberResponseBody = sizeResponseBody / 32000;
		System.debug('strNumberResponseBody: ' + strNumberResponseBody);
		Decimal strNumberRequestBody = sizeRequestBody / 32000;
		System.debug('strNumberRequestBody: ' + strNumberRequestBody);
		//Decimal strNumberRequestBodyAsBlob = sizeRequestBodyAsBlob / 32000;
		//System.debug('strNumberRequestBodyAsBlob: ' + strNumberRequestBodyAsBlob);

		Integer startIndex, startIndexRB, startIndexRBaB;
		startIndex = startIndexRB = startIndexRBaB = 0;
		Integer endIndex, endIndexRB, endIndexRBaB;
		endIndex = endIndexRB = endIndexRBaB = 32000;

		List<CS_Log__c> log = new List<CS_Log__c>();

		for (Integer i = 0; i < numberOfRecordsToCreate; i++) {
			CS_Log__c newLog = new CS_Log__c(
				RecordTypeId = recordTypeId,
				CS_ShortDescription__c = shortDescription,
				CS_ResponseStatus__c = response.getStatus(),
				CS_ResponseStatusCode__c = response.getStatusCode(),
				CS_RequestMethod__c = request.getMethod(),
				CS_RequestEndPoint__c = request.getEndpoint()
			);
			if (strNumberResponseBody < 1) {
				newLog.CS_ResponseBody__c = response.getBody();
				System.debug('CS_ResponseBody__c: ' + newLog.CS_ResponseBody__c);
			} else {
				newLog.CS_ResponseBody__c = 'Part ' + (i + 1) + ': ' + String.valueOf(response.getBody().substring(startIndex, endIndex));
				System.debug('CS_ResponseBody__c: ' + newLog.CS_ResponseBody__c);
				startIndexRB += 32000;
				endIndexRB += 32000;
				System.debug('ResponseBody startIndexRB: ' + startIndex);
				System.debug('ResponseBody endIndexRB: ' + endIndex);
			}
			if (strNumberRequestBody < 1) {
				newLog.CS_RequestBody__c = request.getBody();
				System.debug('CS_RequestBody__c: ' + newLog.CS_RequestBody__c);
			} else {
				newLog.CS_RequestBody__c =
					'Part ' +
					(i + 1) +
					': ' +
					String.valueOf(request.getBody().substring(startIndexRB, startIndexRB));
				System.debug('CS_RequestBody__c: ' + newLog.CS_RequestBody__c);
				startIndexRB += 32000;
				endIndexRB += 32000;
				System.debug('RequestBody startIndexRqB: ' + startIndexRB);
				System.debug('RequestBody endIndexRqB: ' + endIndexRB);
			}
			/*if (strNumberRequestBodyAsBlob < 1) {
				newLog.CS_RequestBodyAsBlob__c = String.valueOf(request.getBodyAsBlob());
				System.debug('CS_RequestBodyAsBlob__c: ' + newLog.CS_RequestBodyAsBlob__c);
			} else {
				newLog.CS_RequestBodyAsBlob__c =
					'Part ' +
					(i + 1) +
					': ' +
					String.valueOf(request.getBodyAsBlob()).substring(startIndexRBaB, endIndexRBaB);
				System.debug('CS_RequestBodyAsBlob__c: ' + newLog.CS_RequestBodyAsBlob__c);
				startIndexRBaB += 32000;
				endIndexRBaB += 32000;
				System.debug('RequestBody startIndexRqBaB: ' + startIndexRBaB);
				System.debug('RequestBody endIndexRqBaB: ' + endIndexRBaB);
			} //end else*/

			//* Add request headers to the log
			List<String> requestHeaderKeys = new List<String>();
			requestHeaderKeys.add('X-SFC-Signature');
			requestHeaderKeys.add('Content-Type');
			requestHeaderKeys.add('Accept');
			requestHeaderKeys.add('Authorization');

			Map<String, String> headers = new Map<String, String>();

			if (!requestHeaderKeys.isEmpty()) {
				String requestHeadersString = 'Headers:\n';
				String requestHeaderValue = '';
				for (String headerKey : requestHeaderKeys) {
					headers.put(headerKey, request.getHeader(headerKey));
					requestHeadersString += headerKey + ': ' + requestHeaderValue + request.getHeader(headerKey) + '\n';
					system.debug('header: \n' + headerKey + ' value: ' + request.getHeader(headerKey));
				}
				newLog.CS_RequestHeaders__c = requestHeadersString;
			}

			//* Add response headers to the log
			List<String> responseHeaderKeys = response.getHeaderKeys();
			if (!responseHeaderKeys.isEmpty()) {
				String responseHeadersString = 'Headers:\n';
				String responseHeaderValue = '';
				for (String headerKey : responseHeaderKeys) {
					responseHeaderValue = response.getHeader(headerKey);
					responseHeadersString += headerKey + ': ' + responseHeaderValue + '\n';
				}
				newLog.CS_ResponseHeaders__c = responseHeadersString;
			}
			log.add(newLog);
		} //end for
		insert log;
	}

	public static void createLogApexRestCallout(String shortDescription, HttpResponse response, HttpRequest request, Id caseId) {
		Id recordTypeId = CS_Utilities.getRecordTypeIdByDevName(Schema.SObjectType.CS_Log__c, APEX_REST_CALLOUT_RECORD_TYPE);
		Integer sizeResponseBody = response.getBody() != null ? response.getBody().length() : 0;
		System.debug('sizeResponseBody: ' + sizeResponseBody);
		Integer sizeRequestBody = request.getBody() != null ? String.valueOf(request.getBody()).length() : 0;
		System.debug('sizeRequestBody: ' + sizeRequestBody);
		//Integer sizeRequestBodyAsBlob = request.getBodyAsBlob() != null ? String.valueOf(request.getBodyAsBlob()).length() : 0;
		//System.debug('sizeRequestBodyAsBlob: ' + sizeRequestBodyAsBlob);

		Decimal maxLength = /*Math.max(*/Math.max(sizeResponseBody, sizeRequestBody)/*, sizeRequestBodyAsBlob)*/;
		System.debug('El máximo de los 3 es: ' + maxLength);
		Decimal numberOfRecords = maxLength / 32000.00;
		Integer numberOfRecordsToCreate = (Integer) numberOfRecords.round(system.RoundingMode.CEILING);
		System.debug('numberOfRecordsToCreate: ' + numberOfRecordsToCreate);

		Decimal strNumberResponseBody = sizeResponseBody / 32000;
		System.debug('strNumberResponseBody: ' + strNumberResponseBody);
		Decimal strNumberRequestBody = sizeRequestBody / 32000;
		System.debug('strNumberRequestBody: ' + strNumberRequestBody);
		/*Decimal strNumberRequestBodyAsBlob = sizeRequestBodyAsBlob / 32000;
		System.debug('strNumberRequestBodyAsBlob: ' + strNumberRequestBodyAsBlob);*/

		Integer startIndex, startIndexRB, startIndexRBaB;
		startIndex = startIndexRB = startIndexRBaB = 0;
		Integer endIndex, endIndexRB, endIndexRBaB;
		endIndex = endIndexRB = endIndexRBaB = 32000;

		List<CS_Log__c> log = new List<CS_Log__c>();

		for (Integer i = 0; i < numberOfRecordsToCreate; i++) {
			CS_Log__c newLog = new CS_Log__c(
				RecordTypeId = recordTypeId,
				CS_Case__c = caseId,
				CS_ShortDescription__c = shortDescription,
				CS_ResponseStatus__c = response.getStatus(),
				CS_ResponseStatusCode__c = response.getStatusCode(),
				CS_RequestMethod__c = request.getMethod(),
				CS_RequestEndPoint__c = request.getEndpoint()
			);
			if (strNumberResponseBody < 1) {
				newLog.CS_ResponseBody__c = response.getBody();
				System.debug('CS_ResponseBody__c: ' + newLog.CS_ResponseBody__c);
			} else {
				newLog.CS_ResponseBody__c = 'Part ' + (i + 1) + ': ' + String.valueOf(response.getBody().substring(startIndex, endIndex));
				System.debug('CS_ResponseBody__c: ' + newLog.CS_ResponseBody__c);
				startIndexRB += 32000;
				endIndexRB += 32000;
				System.debug('ResponseBody startIndexRB: ' + startIndex);
				System.debug('ResponseBody endIndexRB: ' + endIndex);
			}
			if (strNumberRequestBody < 1) {
				newLog.CS_RequestBody__c = request.getBody();
				System.debug('CS_RequestBody__c: ' + newLog.CS_RequestBody__c);
			} else {
				newLog.CS_RequestBody__c =
					'Part ' +
					(i + 1) +
					': ' +
					String.valueOf(request.getBody().substring(startIndexRB, startIndexRB));
				System.debug('CS_RequestBody__c: ' + newLog.CS_RequestBody__c);
				startIndexRB += 32000;
				endIndexRB += 32000;
				System.debug('RequestBody startIndexRqB: ' + startIndexRB);
				System.debug('RequestBody endIndexRqB: ' + endIndexRB);
			}
			/*if (strNumberRequestBodyAsBlob < 1) {
				newLog.CS_RequestBodyAsBlob__c = String.valueOf(request.getBodyAsBlob());
				System.debug('CS_RequestBodyAsBlob__c: ' + newLog.CS_RequestBodyAsBlob__c);
			} else {
				newLog.CS_RequestBodyAsBlob__c =
					'Part ' +
					(i + 1) +
					': ' +
					String.valueOf(request.getBodyAsBlob()).substring(startIndexRBaB, endIndexRBaB);
				System.debug('CS_RequestBodyAsBlob__c: ' + newLog.CS_RequestBodyAsBlob__c);
				startIndexRBaB += 32000;
				endIndexRBaB += 32000;
				System.debug('RequestBody startIndexRqBaB: ' + startIndexRBaB);
				System.debug('RequestBody endIndexRqBaB: ' + endIndexRBaB);
			} //end else*/

			//* Add request headers to the log
			List<String> requestHeaderKeys = new List<String>();
			requestHeaderKeys.add('X-SFC-Signature');
			requestHeaderKeys.add('Content-Type');
			requestHeaderKeys.add('Accept');
			requestHeaderKeys.add('Authorization');

			Map<String, String> headers = new Map<String, String>();

			if (!requestHeaderKeys.isEmpty()) {
				String requestHeadersString = 'Headers:\n';
				String requestHeaderValue = '';
				for (String headerKey : requestHeaderKeys) {
					headers.put(headerKey, request.getHeader(headerKey));
					requestHeadersString += headerKey + ': ' + requestHeaderValue + request.getHeader(headerKey) + '\n';
					system.debug('header: \n' + headerKey + ' value: ' + request.getHeader(headerKey));
				}
				newLog.CS_RequestHeaders__c = requestHeadersString;
			}

			//* Add response headers to the log
			List<String> responseHeaderKeys = response.getHeaderKeys();
			if (!responseHeaderKeys.isEmpty()) {
				String responseHeadersString = 'Headers:\n';
				String responseHeaderValue = '';
				for (String headerKey : responseHeaderKeys) {
					responseHeaderValue = response.getHeader(headerKey);
					responseHeadersString += headerKey + ': ' + responseHeaderValue + '\n';
				}
				newLog.CS_ResponseHeaders__c = responseHeadersString;
			}
			log.add(newLog);
		} //end for
		insert log;
	}

	public static void createLogApexRestCallout(
		String shortDescription,
		HttpResponse response,
		HttpRequest request,
		Id caseId,
		Id caseDocumentId
	) {
		Id recordTypeId = CS_Utilities.getRecordTypeIdByDevName(Schema.SObjectType.CS_Log__c, APEX_REST_CALLOUT_RECORD_TYPE);

		Integer sizeResponseBody = response.getBody() != null ? response.getBody().length() : 0;
		System.debug('sizeResponseBody: ' + sizeResponseBody);
		Integer sizeRequestBody = request.getBody() != null ? String.valueOf(request.getBody()).length() : 0;
		System.debug('sizeRequestBody: ' + sizeRequestBody);
		//Integer sizeRequestBodyAsBlob = request.getBodyAsBlob() != null ? String.valueOf(request.getBodyAsBlob()).length() : 0;
		//System.debug('sizeRequestBodyAsBlob: ' + sizeRequestBodyAsBlob);

		Decimal maxLength = /*Math.max(*/Math.max(sizeResponseBody, sizeRequestBody)/*, sizeRequestBodyAsBlob)*/;
		System.debug('El máximo de los 3 es: ' + maxLength);
		Decimal numberOfRecords = maxLength / 32000.00;
		Integer numberOfRecordsToCreate = (Integer) numberOfRecords.round(system.RoundingMode.CEILING);
		System.debug('numberOfRecordsToCreate: ' + numberOfRecordsToCreate);

		Decimal strNumberResponseBody = sizeResponseBody / 32000;
		System.debug('strNumberResponseBody: ' + strNumberResponseBody);
		Decimal strNumberRequestBody = sizeRequestBody / 32000;
		System.debug('strNumberRequestBody: ' + strNumberRequestBody);
		/*Decimal strNumberRequestBodyAsBlob = sizeRequestBodyAsBlob / 32000;
		System.debug('strNumberRequestBodyAsBlob: ' + strNumberRequestBodyAsBlob);*/

		Integer startIndex, startIndexRB, startIndexRBaB;
		startIndex = startIndexRB = startIndexRBaB = 0;
		Integer endIndex, endIndexRB, endIndexRBaB;
		endIndex = endIndexRB = endIndexRBaB = 32000;

		List<CS_Log__c> log = new List<CS_Log__c>();

		for (Integer i = 0; i < numberOfRecordsToCreate; i++) {
			CS_Log__c newLog = new CS_Log__c(
				RecordTypeId = recordTypeId,
				CS_Case__c = caseId,
				CS_DocumentoCaso__c = caseDocumentId,
				CS_ShortDescription__c = shortDescription,
				CS_ResponseStatus__c = response.getStatus(),
				CS_ResponseStatusCode__c = response.getStatusCode(),
				CS_RequestMethod__c = request.getMethod(),
				CS_RequestEndPoint__c = request.getEndpoint()
			);
			if (strNumberResponseBody < 1) {
				newLog.CS_ResponseBody__c = response.getBody();
				System.debug('CS_ResponseBody__c: ' + newLog.CS_ResponseBody__c);
			} else {
				newLog.CS_ResponseBody__c = 'Part ' + (i + 1) + ': ' + String.valueOf(response.getBody().substring(startIndex, endIndex));
				System.debug('CS_ResponseBody__c: ' + newLog.CS_ResponseBody__c);
				startIndexRB += 32000;
				endIndexRB += 32000;
				System.debug('ResponseBody startIndexRB: ' + startIndex);
				System.debug('ResponseBody endIndexRB: ' + endIndex);
			}
			if (strNumberRequestBody < 1) {
				newLog.CS_RequestBody__c = request.getBody();
				System.debug('CS_RequestBody__c: ' + newLog.CS_RequestBody__c);
			} else {
				newLog.CS_RequestBody__c =
					'Part ' +
					(i + 1) +
					': ' +
					String.valueOf(request.getBody().substring(startIndexRB, startIndexRB));
				System.debug('CS_RequestBody__c: ' + newLog.CS_RequestBody__c);
				startIndexRB += 32000;
				endIndexRB += 32000;
				System.debug('RequestBody startIndexRqB: ' + startIndexRB);
				System.debug('RequestBody endIndexRqB: ' + endIndexRB);
			}
			/*if (strNumberRequestBodyAsBlob < 1) {
				newLog.CS_RequestBodyAsBlob__c = String.valueOf(request.getBodyAsBlob());
				System.debug('CS_RequestBodyAsBlob__c: ' + newLog.CS_RequestBodyAsBlob__c);
			} else {
				newLog.CS_RequestBodyAsBlob__c =
					'Part ' +
					(i + 1) +
					': ' +
					String.valueOf(request.getBodyAsBlob()).substring(startIndexRBaB, endIndexRBaB);
				System.debug('CS_RequestBodyAsBlob__c: ' + newLog.CS_RequestBodyAsBlob__c);
				startIndexRBaB += 32000;
				endIndexRBaB += 32000;
				System.debug('RequestBody startIndexRqBaB: ' + startIndexRBaB);
				System.debug('RequestBody endIndexRqBaB: ' + endIndexRBaB);
			} //end else*/

			//* Add request headers to the log
			List<String> requestHeaderKeys = new List<String>();
			requestHeaderKeys.add('X-SFC-Signature');
			requestHeaderKeys.add('Content-Type');
			requestHeaderKeys.add('Accept');
			requestHeaderKeys.add('Authorization');

			Map<String, String> headers = new Map<String, String>();

			if (!requestHeaderKeys.isEmpty()) {
				String requestHeadersString = 'Headers:\n';
				String requestHeaderValue = '';
				for (String headerKey : requestHeaderKeys) {
					headers.put(headerKey, request.getHeader(headerKey));
					requestHeadersString += headerKey + ': ' + requestHeaderValue + request.getHeader(headerKey) + '\n';
					system.debug('header: \n' + headerKey + ' value: ' + request.getHeader(headerKey));
				}
				newLog.CS_RequestHeaders__c = requestHeadersString;
			}

			//* Add response headers to the log
			List<String> responseHeaderKeys = response.getHeaderKeys();
			if (!responseHeaderKeys.isEmpty()) {
				String responseHeadersString = 'Headers:\n';
				String responseHeaderValue = '';
				for (String headerKey : responseHeaderKeys) {
					responseHeaderValue = response.getHeader(headerKey);
					responseHeadersString += headerKey + ': ' + responseHeaderValue + '\n';
				}
				newLog.CS_ResponseHeaders__c = responseHeadersString;
			}
			log.add(newLog);
		} //end for
		insert log;
	}

	public static void createLogSFInternalError(String shortDescription, String methodName, Exception exceptionObj) {
		Id recordTypeId = CS_Utilities.getRecordTypeIdByDevName(Schema.SObjectType.CS_Log__c, APEX_SFINTERNAL_ERROR_RECORD_TYPE);
		CS_Log__c newLog = new CS_Log__c(
			RecordTypeId = recordTypeId,
			CS_ShortDescription__c = shortDescription,
			CS_Funcion__c = methodName,
			CS_ExceptionLineNumber__c = exceptionObj.getLineNumber(),
			CS_ExceptionMessage__c = exceptionObj.getMessage(),
			CS_ExceptionStackTrace__c = exceptionObj.getStackTraceString(),
			CS_ExceptionTypeName__c = exceptionObj.getTypeName()
		);
		insert newLog;
	}

	public static void createLogSFInternalError(String shortDescription, String methodName, Exception exceptionObj, Id caseId) {
		Id recordTypeId = CS_Utilities.getRecordTypeIdByDevName(Schema.SObjectType.CS_Log__c, APEX_SFINTERNAL_ERROR_RECORD_TYPE);
		CS_Log__c newLog = new CS_Log__c(
			RecordTypeId = recordTypeId,
			CS_Case__c = caseId,
			CS_ShortDescription__c = shortDescription,
			CS_Funcion__c = methodName,
			CS_ExceptionLineNumber__c = exceptionObj.getLineNumber(),
			CS_ExceptionMessage__c = exceptionObj.getMessage(),
			CS_ExceptionStackTrace__c = exceptionObj.getStackTraceString(),
			CS_ExceptionTypeName__c = exceptionObj.getTypeName()
		);
		insert newLog;
	}

	public static void createLogSFInternalDatabaseError(String shortDescription, String methodName, Database.Error databaseErrorObj) {
		Id recordTypeId = CS_Utilities.getRecordTypeIdByDevName(Schema.SObjectType.CS_Log__c, APEX_SFINTERNAL_ERROR_RECORD_TYPE);
		CS_Log__c newLog = new CS_Log__c(
			RecordTypeId = recordTypeId,
			CS_ShortDescription__c = shortDescription,
			CS_Funcion__c = methodName,
			CS_StatusCode__c = String.valueOf(databaseErrorObj.getStatusCode()),
			CS_ExceptionMessage__c = databaseErrorObj.getMessage()
		);
		for (String field : databaseErrorObj.getFields()) {
			newLog.CS_Fields__c += field + '\n';
		}
		insert newLog;
	}

	public static void createLogSFInternalDatabaseError(
		String shortDescription,
		String methodName,
		Database.Error databaseErrorObj,
		Id caseId
	) {
		Id recordTypeId = CS_Utilities.getRecordTypeIdByDevName(Schema.SObjectType.CS_Log__c, APEX_SFINTERNAL_ERROR_RECORD_TYPE);
		CS_Log__c newLog = new CS_Log__c(
			RecordTypeId = recordTypeId,
			CS_Case__c = caseId,
			CS_ShortDescription__c = shortDescription,
			CS_Funcion__c = methodName,
			CS_StatusCode__c = String.valueOf(databaseErrorObj.getStatusCode()),
			CS_ExceptionMessage__c = databaseErrorObj.getMessage()
		);

		for (String field : databaseErrorObj.getFields()) {
			newLog.CS_Fields__c += field + '\n';
		}

		insert newLog;
	}
}