/***************************************************************************************************************************
 * Nombre de la Clase Apex : CS_LogHelper_Test
 * Versión                 : 1.0
 * Fecha de Creación       : 30/05/2022
 * Funcionalidad           : Pruebas Unitarias
 * Clase Principal         : CS_Log_Helper
 *--------------------------------------------------------------------------------------------------------------------------
 *                                              HISTORIAL DE MODIFICACIONES:
 *--------------------------------------------------------------------------------------------------------------------------
 * Desarrollador         Fecha           Descripción
 *--------------------------------------------------------------------------------------------------------------------------
 * Angel Cabezas         30/05/2022      Creación
 * Gerson Díaz			 31/05/2022		 Se agregó la lógica de todos los métodos y se colocó su System.AssertEquals
 * Lidia Guerrero        01/06/2022      Métodos para probar manejo de errores en instrucciones DML
 * Lidia Guerrero 		 06/06/2022      Modificación de métodos para probar el registro de request de peticiones en Log de errores
 * Lidia Guerrero 		 14/06/2022      Generar n numero de registros dependiendo el tamaño de request.body,request.bodyAsBlob, response.body
 *--------------------------------------------------------------------------------------------------------------------------
 **************************************************************************************************************************/
@isTest
private class CS_LogHelper_Test {
	public static final String APEX_REST_CALLOUT_RECORD_TYPE = 'CS_ApexRestCallout';
	public static final String APEX_SFINTERNAL_ERROR_RECORD_TYPE = 'CS_SalesforceInternal';

	@testsetup
	public static void setup() {
		Case oneCase = CS_TestMakeData.crearcase(true);
	}

	@isTest
	static void testCreateLogApexRestCallout() {
		HttpResponse response = new HttpResponse();
		HttpRequest request = new HttpRequest();
		String access = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNjU0NTU0NDc3LCJqdGkiOiI1MzUyMmVmMjlhOWI0NmUzOGRlZjA3ZDdiN2MyMDQ5MCIsInVzZXJfaWQiOjI1N30.y2ZCRzzGAOZhfre_l-QDWRkqAfSO1KIp0KBRorqz_q4';
		request.setHeader('X-SFC-Signature','B2CEBE8F2A089CDB695EFA6F4FA6F2A915C0D57C86325ED2B4F0F4460E3195FE');
        request.setHeader('Content-Type', 'aplication/json');
        request.setHeader('Accept','*/*');
        request.setHeader('Authorization', 'Bearer ' +access);
		request.setMethod('GET');
		request.setEndpoint('https://qasmart.superfinanciera.gov.co/api/queja/');
		response.setStatus('Ok');
		response.setStatusCode(200);
		response.setHeader('key', 'value');

		Test.startTest();
		request.setBodyAsBlob(Blob.valueof(CS_LogHelper_Test.createLongString(97000)));
		response.setBody(
			'{ "count": 2,"pages": 1,"current_page": 1,"next": null,"previous": null,"results": [{"tipo_entidad": 10,"entidad_cod": 3,"fecha_creacion": "2022-06-14T13:44:29","codigo_queja": "1031655232269147005","codigo_pais": "660","departamento_cod": null,"municipio_cod": null,"nombres": "Pruebas Colmenasvcsl","tipo_id_CF": 1,"numero_id_CF": "6424265171","telefono": "5623913140","correo": "lidia.guerrero@xertica.com","direccion": "","tipo_persona": 1,"sexo": null,"lgbtiq": 1,"canal_cod": 6,"condicion_especial": 5,"producto_cod": 125,"producto_nombre": "Prueba sin anexos.","macro_motivo_cod": 22,"texto_queja": "Prueba sin anexos. Prueba sin anexos. Prueba sin anexos. Prueba sin anexos.","anexo_queja": true,"tutela": 2,"ente_control": null,"escalamiento_DCF": 2,"replica": 2,"argumento_replica": null,"desistimiento_queja": 2,"queja_expres": 1},]}'
			);
		CS_Log_Helper.createLogApexRestCallout('shortDescription', response, request);
		
		request.setBodyAsBlob(Blob.valueof('String de prueba'));
		//request.setBody(CS_LogHelper_Test.createLongString(33000));
		response.setBody(
			'{ "count": 2,"pages": 1,"current_page": 1,"next": null,"previous": null,"results": [{"tipo_entidad": 10,"entidad_cod": 3,"fecha_creacion": "2022-06-14T13:44:29","codigo_queja": "1031655232269147005","codigo_pais": "660","departamento_cod": null,"municipio_cod": null,"nombres": "Pruebas Colmenasvcsl","tipo_id_CF": 1,"numero_id_CF": "6424265171","telefono": "5623913140","correo": "lidia.guerrero@xertica.com","direccion": "","tipo_persona": 1,"sexo": null,"lgbtiq": 1,"canal_cod": 6,"condicion_especial": 5,"producto_cod": 125,"producto_nombre": "Prueba sin anexos.","macro_motivo_cod": 22,"texto_queja": "Prueba sin anexos. Prueba sin anexos. Prueba sin anexos. Prueba sin anexos.","anexo_queja": true,"tutela": 2,"ente_control": null,"escalamiento_DCF": 2,"replica": 2,"argumento_replica": null,"desistimiento_queja": 2,"queja_expres": 1},]}'			);
		CS_Log_Helper.createLogApexRestCallout('shortDescription', response, request);
	
		request.setBodyAsBlob(Blob.valueof('String de prueba'));
		request.setBody('{}');
		response.setBody(
			'{ "count": 2,"pages": 1,"current_page": 1,"next": null,"previous": null,"results": [{"tipo_entidad": 10,"entidad_cod": 3,"fecha_creacion": "2022-06-14T13:44:29","codigo_queja": "1031655232269147005","codigo_pais": "660","departamento_cod": null,"municipio_cod": null,"nombres": "Pruebas Colmenasvcsl","tipo_id_CF": 1,"numero_id_CF": "6424265171","telefono": "5623913140","correo": "lidia.guerrero@xertica.com","direccion": "","tipo_persona": 1,"sexo": null,"lgbtiq": 1,"canal_cod": 6,"condicion_especial": 5,"producto_cod": 125,"producto_nombre": "Prueba sin anexos.","macro_motivo_cod": 22,"texto_queja": "Prueba sin anexos. Prueba sin anexos. Prueba sin anexos. Prueba sin anexos.","anexo_queja": true,"tutela": 2,"ente_control": null,"escalamiento_DCF": 2,"replica": 2,"argumento_replica": null,"desistimiento_queja": 2,"queja_expres": 1},]}'+
			'{ "count": 2,"pages": 1,"current_page": 1,"next": null,"previous": null,"results": [{"tipo_entidad": 10,"entidad_cod": 3,"fecha_creacion": "2022-06-14T13:44:29","codigo_queja": "1031655232269147005","codigo_pais": "660","departamento_cod": null,"municipio_cod": null,"nombres": "Pruebas Colmenasvcsl","tipo_id_CF": 1,"numero_id_CF": "6424265171","telefono": "5623913140","correo": "lidia.guerrero@xertica.com","direccion": "","tipo_persona": 1,"sexo": null,"lgbtiq": 1,"canal_cod": 6,"condicion_especial": 5,"producto_cod": 125,"producto_nombre": "Prueba sin anexos.","macro_motivo_cod": 22,"texto_queja": "Prueba sin anexos. Prueba sin anexos. Prueba sin anexos. Prueba sin anexos.","anexo_queja": true,"tutela": 2,"ente_control": null,"escalamiento_DCF": 2,"replica": 2,"argumento_replica": null,"desistimiento_queja": 2,"queja_expres": 1},]}'+
			'{ "count": 2,"pages": 1,"current_page": 1,"next": null,"previous": null,"results": [{"tipo_entidad": 10,"entidad_cod": 3,"fecha_creacion": "2022-06-14T13:44:29","codigo_queja": "1031655232269147005","codigo_pais": "660","departamento_cod": null,"municipio_cod": null,"nombres": "Pruebas Colmenasvcsl","tipo_id_CF": 1,"numero_id_CF": "6424265171","telefono": "5623913140","correo": "lidia.guerrero@xertica.com","direccion": "","tipo_persona": 1,"sexo": null,"lgbtiq": 1,"canal_cod": 6,"condicion_especial": 5,"producto_cod": 125,"producto_nombre": "Prueba sin anexos.","macro_motivo_cod": 22,"texto_queja": "Prueba sin anexos. Prueba sin anexos. Prueba sin anexos. Prueba sin anexos.","anexo_queja": true,"tutela": 2,"ente_control": null,"escalamiento_DCF": 2,"replica": 2,"argumento_replica": null,"desistimiento_queja": 2,"queja_expres": 1},]}'+
			'{ "count": 2,"pages": 1,"current_page": 1,"next": null,"previous": null,"results": [{"tipo_entidad": 10,"entidad_cod": 3,"fecha_creacion": "2022-06-14T13:44:29","codigo_queja": "1031655232269147005","codigo_pais": "660","departamento_cod": null,"municipio_cod": null,"nombres": "Pruebas Colmenasvcsl","tipo_id_CF": 1,"numero_id_CF": "6424265171","telefono": "5623913140","correo": "lidia.guerrero@xertica.com","direccion": "","tipo_persona": 1,"sexo": null,"lgbtiq": 1,"canal_cod": 6,"condicion_especial": 5,"producto_cod": 125,"producto_nombre": "Prueba sin anexos.","macro_motivo_cod": 22,"texto_queja": "Prueba sin anexos. Prueba sin anexos. Prueba sin anexos. Prueba sin anexos.","anexo_queja": true,"tutela": 2,"ente_control": null,"escalamiento_DCF": 2,"replica": 2,"argumento_replica": null,"desistimiento_queja": 2,"queja_expres": 1},]}');		
			CS_Log_Helper.createLogApexRestCallout('shortDescription', response, request);
		
		Test.stopTest();
		List<CS_Log__c> logs = [
			SELECT Id, 
			       CS_ShortDescription__c, 
				   CS_ResponseHeaders__c, 
				   CS_ResponseBody__c, 
				   CS_ResponseStatusCode__c, 
			       CS_RequestMethod__c,
				   CS_RequestBody__c, 
				   CS_RequestEndPoint__c,
				   CS_RequestBodyAsBlob__c, 
				   Recordtype.developername
			FROM CS_Log__c
		];
		/*System.assertEquals(7, logs.size(), 'No se registró correctamente el Log Apex Rest Callout.');*/	
	}

	@isTest
	static void testCreateLogApexRestCalloutWithCase() {
		HttpResponse response = new HttpResponse();
		HttpRequest request = new HttpRequest();
		String access = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNjU0NTU0NDc3LCJqdGkiOiI1MzUyMmVmMjlhOWI0NmUzOGRlZjA3ZDdiN2MyMDQ5MCIsInVzZXJfaWQiOjI1N30.y2ZCRzzGAOZhfre_l-QDWRkqAfSO1KIp0KBRorqz_q4';
		request.setHeader('X-SFC-Signature','B2CEBE8F2A089CDB695EFA6F4FA6F2A915C0D57C86325ED2B4F0F4460E3195FE');
        request.setHeader('Content-Type', 'aplication/json');
        request.setHeader('Accept','*/*');
        request.setHeader('Authorization', 'Bearer ' +access);
		request.setMethod('GET');
		request.setEndpoint('https://qasmart.superfinanciera.gov.co/api/queja/');
		response.setStatus('Ok');
		response.setStatusCode(200);
		response.setHeader('key', 'value');

		request.setBodyAsBlob(Blob.valueof(CS_LogHelper_Test.createLongString(48000)));
		request.setBody(CS_LogHelper_Test.createLongString(62000));
		response.setBody(
			'{ "count": 2,"pages": 1,"current_page": 1,"next": null,"previous": null,"results": [{"tipo_entidad": 10,"entidad_cod": 3,"fecha_creacion": "2022-06-14T13:44:29","codigo_queja": "1031655232269147005","codigo_pais": "660","departamento_cod": null,"municipio_cod": null,"nombres": "Pruebas Colmenasvcsl","tipo_id_CF": 1,"numero_id_CF": "6424265171","telefono": "5623913140","correo": "lidia.guerrero@xertica.com","direccion": "","tipo_persona": 1,"sexo": null,"lgbtiq": 1,"canal_cod": 6,"condicion_especial": 5,"producto_cod": 125,"producto_nombre": "Prueba sin anexos.","macro_motivo_cod": 22,"texto_queja": "Prueba sin anexos. Prueba sin anexos. Prueba sin anexos. Prueba sin anexos.","anexo_queja": true,"tutela": 2,"ente_control": null,"escalamiento_DCF": 2,"replica": 2,"argumento_replica": null,"desistimiento_queja": 2,"queja_expres": 1},'
			+'{ "count": 2,"pages": 1,"current_page": 1,"next": null,"previous": null,"results": [{"tipo_entidad": 10,"entidad_cod": 3,"fecha_creacion": "2022-06-14T13:44:29","codigo_queja": "1031655232269147005","codigo_pais": "660","departamento_cod": null,"municipio_cod": null,"nombres": "Pruebas Colmenasvcsl","tipo_id_CF": 1,"numero_id_CF": "6424265171","telefono": "5623913140","correo": "lidia.guerrero@xertica.com","direccion": "","tipo_persona": 1,"sexo": null,"lgbtiq": 1,"canal_cod": 6,"condicion_especial": 5,"producto_cod": 125,"producto_nombre": "Prueba sin anexos.","macro_motivo_cod": 22,"texto_queja": "Prueba sin anexos. Prueba sin anexos. Prueba sin anexos. Prueba sin anexos.","anexo_queja": true,"tutela": 2,"ente_control": null,"escalamiento_DCF": 2,"replica": 2,"argumento_replica": null,"desistimiento_queja": 2,"queja_expres": 1}]}'
			+'{ "count": 2,"pages": 1,"current_page": 1,"next": null,"previous": null,"results": [{"tipo_entidad": 10,"entidad_cod": 3,"fecha_creacion": "2022-06-14T13:44:29","codigo_queja": "1031655232269147005","codigo_pais": "660","departamento_cod": null,"municipio_cod": null,"nombres": "Pruebas Colmenasvcsl","tipo_id_CF": 1,"numero_id_CF": "6424265171","telefono": "5623913140","correo": "lidia.guerrero@xertica.com","direccion": "","tipo_persona": 1,"sexo": null,"lgbtiq": 1,"canal_cod": 6,"condicion_especial": 5,"producto_cod": 125,"producto_nombre": "Prueba sin anexos.","macro_motivo_cod": 22,"texto_queja": "Prueba sin anexos. Prueba sin anexos. Prueba sin anexos. Prueba sin anexos.","anexo_queja": true,"tutela": 2,"ente_control": null,"escalamiento_DCF": 2,"replica": 2,"argumento_replica": null,"desistimiento_queja": 2,"queja_expres": 1}]}'
			+'{ "count": 2,"pages": 1,"current_page": 1,"next": null,"previous": null,"results": [{"tipo_entidad": 10,"entidad_cod": 3,"fecha_creacion": "2022-06-14T13:44:29","codigo_queja": "1031655232269147005","codigo_pais": "660","departamento_cod": null,"municipio_cod": null,"nombres": "Pruebas Colmenasvcsl","tipo_id_CF": 1,"numero_id_CF": "6424265171","telefono": "5623913140","correo": "lidia.guerrero@xertica.com","direccion": "","tipo_persona": 1,"sexo": null,"lgbtiq": 1,"canal_cod": 6,"condicion_especial": 5,"producto_cod": 125,"producto_nombre": "Prueba sin anexos.","macro_motivo_cod": 22,"texto_queja": "Prueba sin anexos. Prueba sin anexos. Prueba sin anexos. Prueba sin anexos.","anexo_queja": true,"tutela": 2,"ente_control": null,"escalamiento_DCF": 2,"replica": 2,"argumento_replica": null,"desistimiento_queja": 2,"queja_expres": 1}]}'
			);
		Case caso = [SELECT Id FROM Case LIMIT 1];

		Test.startTest();
		CS_Log_Helper.createLogApexRestCallout('shortDescription', response, request, caso.Id);
		Test.stopTest();
		List<CS_Log__c> logs = [
			SELECT
				Id,
				   CS_Case__c,
			       CS_ShortDescription__c, 
				   CS_ResponseHeaders__c, 
				   CS_ResponseBody__c, 
				   CS_ResponseStatusCode__c, 
			       CS_RequestMethod__c,
				   CS_RequestBody__c, 
				   CS_RequestEndPoint__c,
				   CS_RequestBodyAsBlob__c, 
				   Recordtype.developername
			FROM CS_Log__c
		];
		System.assertEquals(2, logs.size(), 'No se registró correctamente el Log Apex Rest Callout.');
	}

	@isTest
	static void testCreateLogApexRestCalloutWithDocument() {
		HttpResponse response = new HttpResponse();
		HttpRequest request = new HttpRequest();
		String access = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNjU0NTU0NDc3LCJqdGkiOiI1MzUyMmVmMjlhOWI0NmUzOGRlZjA3ZDdiN2MyMDQ5MCIsInVzZXJfaWQiOjI1N30.y2ZCRzzGAOZhfre_l-QDWRkqAfSO1KIp0KBRorqz_q4';
		request.setHeader('X-SFC-Signature','B2CEBE8F2A089CDB695EFA6F4FA6F2A915C0D57C86325ED2B4F0F4460E3195FE');
        request.setHeader('Content-Type', 'aplication/json');
        request.setHeader('Accept','*/*');
        request.setHeader('Authorization', 'Bearer ' +access);
		request.setMethod('GET');
		request.setEndpoint('https://qasmart.superfinanciera.gov.co/api/queja/');
		request.setBodyAsBlob(Blob.valueof(CS_LogHelper_Test.createLongString(33000)));
		request.setBody(CS_LogHelper_Test.createLongString(62000));

		response.setBody(
			'{ "count": 2,"pages": 1,"current_page": 1,"next": null,"previous": null,"results": [{"tipo_entidad": 10,"entidad_cod": 3,"fecha_creacion": "2022-06-14T13:44:29","codigo_queja": "1031655232269147005","codigo_pais": "660","departamento_cod": null,"municipio_cod": null,"nombres": "Pruebas Colmenasvcsl","tipo_id_CF": 1,"numero_id_CF": "6424265171","telefono": "5623913140","correo": "lidia.guerrero@xertica.com","direccion": "","tipo_persona": 1,"sexo": null,"lgbtiq": 1,"canal_cod": 6,"condicion_especial": 5,"producto_cod": 125,"producto_nombre": "Prueba sin anexos.","macro_motivo_cod": 22,"texto_queja": "Prueba sin anexos. Prueba sin anexos. Prueba sin anexos. Prueba sin anexos.","anexo_queja": true,"tutela": 2,"ente_control": null,"escalamiento_DCF": 2,"replica": 2,"argumento_replica": null,"desistimiento_queja": 2,"queja_expres": 1},'
			+'{ "count": 2,"pages": 1,"current_page": 1,"next": null,"previous": null,"results": [{"tipo_entidad": 10,"entidad_cod": 3,"fecha_creacion": "2022-06-14T13:44:29","codigo_queja": "1031655232269147005","codigo_pais": "660","departamento_cod": null,"municipio_cod": null,"nombres": "Pruebas Colmenasvcsl","tipo_id_CF": 1,"numero_id_CF": "6424265171","telefono": "5623913140","correo": "lidia.guerrero@xertica.com","direccion": "","tipo_persona": 1,"sexo": null,"lgbtiq": 1,"canal_cod": 6,"condicion_especial": 5,"producto_cod": 125,"producto_nombre": "Prueba sin anexos.","macro_motivo_cod": 22,"texto_queja": "Prueba sin anexos. Prueba sin anexos. Prueba sin anexos. Prueba sin anexos.","anexo_queja": true,"tutela": 2,"ente_control": null,"escalamiento_DCF": 2,"replica": 2,"argumento_replica": null,"desistimiento_queja": 2,"queja_expres": 1}'
			+'{ "count": 2,"pages": 1,"current_page": 1,"next": null,"previous": null,"results": [{"tipo_entidad": 10,"entidad_cod": 3,"fecha_creacion": "2022-06-14T13:44:29","codigo_queja": "1031655232269147005","codigo_pais": "660","departamento_cod": null,"municipio_cod": null,"nombres": "Pruebas Colmenasvcsl","tipo_id_CF": 1,"numero_id_CF": "6424265171","telefono": "5623913140","correo": "lidia.guerrero@xertica.com","direccion": "","tipo_persona": 1,"sexo": null,"lgbtiq": 1,"canal_cod": 6,"condicion_especial": 5,"producto_cod": 125,"producto_nombre": "Prueba sin anexos.","macro_motivo_cod": 22,"texto_queja": "Prueba sin anexos. Prueba sin anexos. Prueba sin anexos. Prueba sin anexos.","anexo_queja": true,"tutela": 2,"ente_control": null,"escalamiento_DCF": 2,"replica": 2,"argumento_replica": null,"desistimiento_queja": 2,"queja_expres": 1}' 	
		);
		response.setStatus('Ok');
		response.setStatusCode(200);
		response.setHeader('key', 'value');
		Case caso = [SELECT Id FROM Case LIMIT 1];
		CS_DocumentoCaso__c	docCase = new CS_DocumentoCaso__c(Name='test.doc'); 
		
		Test.startTest();
		CS_Log_Helper.createLogApexRestCallout('shortDescription', response, request, caso.Id, docCase.Id);
		Test.stopTest();
		List<CS_Log__c> logs = [
			SELECT
				Id,
				   CS_Case__c,
				   CS_DocumentoCaso__c,
			       CS_ShortDescription__c, 
				   CS_ResponseHeaders__c, 
				   CS_ResponseBody__c, 
				   CS_ResponseStatusCode__c, 
			       CS_RequestMethod__c,
				   CS_RequestBody__c, 
				   CS_RequestEndPoint__c,
				   CS_RequestBodyAsBlob__c, 
				   Recordtype.developername
			FROM CS_Log__c
		];
		System.assertEquals(2, logs.size(), 'No se registró corretamente el Log Apex Rest Callout.');
	}


	@isTest
	static void testCreateLogSFInternalError() {
		Test.startTest();
		try {
			CS_Log__c log = [SELECT Id FROM CS_Log__c];
		} catch (Exception ex) {
			CS_Log_Helper.createLogSFInternalError('shortDescription', 'methodName', ex);
			system.debug(ex.getTypeName());
		}
		Test.stopTest();
		List<CS_Log__c> logs = [
			SELECT Id, CS_ExceptionTypeName__c, CS_ShortDescription__c, CS_Funcion__c, Recordtype.developername
			FROM CS_Log__c
		];
		System.assertEquals(1, logs.size(), 'No se registró correctamente el Log SF Internal Errors.');
		System.assertEquals(
			APEX_SFINTERNAL_ERROR_RECORD_TYPE,
			logs[0].recordtype.developername,
			'No se registró corretamente el Log con el tipo SF Internal Errors.'
		);
		System.assertEquals(
			'shortDescription',
			logs[0].CS_ShortDescription__c,
			'No se registró corretamente el ShortDescription en el Log'
		);
		System.assertEquals('methodName', logs[0].CS_Funcion__c, 'No se registró correctamente el nombre del metodo en el Log.');
		System.assertEquals(
			'System.QueryException',
			logs[0].CS_ExceptionTypeName__c,
			'No se registró correctamente el nombre de la excepción en el Log.'
		);
	}

	@isTest
	static void testCreateLogSFInternalErrorWithCaseId() {
		Test.startTest();
		try {
			CS_Log__c log = [SELECT Id FROM CS_Log__c];
		} catch (Exception ex) {
			Case caso = [SELECT Id FROM Case LIMIT 1];
			CS_Log_Helper.createLogSFInternalError('shortDescription', 'methodName', ex, caso.Id);
			system.debug(ex.getTypeName());
		}
		Test.stopTest();
		List<CS_Log__c> logs = [
			SELECT Id, CS_ExceptionTypeName__c, CS_ShortDescription__c, CS_Funcion__c, Recordtype.developername
			FROM CS_Log__c
		];
		System.assertEquals(1, logs.size(), 'No se registró correctamente el Log SF Internal Errors.');
		System.assertEquals(
			APEX_SFINTERNAL_ERROR_RECORD_TYPE,
			logs[0].recordtype.developername,
			'No se registró corretamente el Log con el tipo SF Internal Errors.'
		);
		System.assertEquals(
			'shortDescription',
			logs[0].CS_ShortDescription__c,
			'No se registró corretamente el ShortDescription en el Log'
		);
		System.assertEquals('methodName', logs[0].CS_Funcion__c, 'No se registró correctamente el nombre del metodo en el Log.');
		System.assertEquals(
			'System.QueryException',
			logs[0].CS_ExceptionTypeName__c,
			'No se registró correctamente el nombre de la excepción en el Log.'
		);
	}

	@isTest
	static void testcreateLogSFInternalDatabaseError() {
		Account a = new Account();
		String msg = 'Demo = New error method in SObject';
		a.addError('Name', msg);
		List<Database.Error> errors = a.getErrors();
		Database.Error error = errors.get(0);

		Test.startTest();
		CS_Log_Helper.createLogSFInternalDatabaseError('Test error', 'Database.insert accounts', error);
		Test.stopTest();
		System.assertEquals(1, errors.size(), 'Error size');
		System.assertEquals(msg, error.getMessage(), 'Error message');
		System.assertEquals(StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION, error.getStatusCode(), 'Error Status code');
	}

    @isTest
	static void testcreateLogSFInternalDatabaseErrorId() {
		Account a = new Account();
		Case c = new Case();
		String msg = 'Demo = New error method in SObject';
		a.addError('Name', msg);
		List<Database.Error> errors = a.getErrors();
		Database.Error error = errors.get(0);

		Test.startTest();
		CS_Log_Helper.createLogSFInternalDatabaseError('Test error', 'Database.insert accounts', error, c.Id);
		Test.stopTest();
		System.assertEquals(1, errors.size(), 'Error size');
		System.assertEquals(msg, error.getMessage(), 'Error message');
		System.assertEquals(StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION, error.getStatusCode(), 'Error Status code');
	}

	static String createLongString(Integer length){
		final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
    	String randStr = '';
    	while (randStr.length() < length) {
       		Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
       		randStr += chars.substring(idx, idx+1);
    	}
		return randStr;	
	}

}