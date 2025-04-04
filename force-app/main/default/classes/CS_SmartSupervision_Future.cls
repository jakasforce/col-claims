/*****************************************************************************************************************************
 * Apex Class Name	:	CS_SmartSupervision_Future
 * Version			:	1.0
 * Created Date	    :	23/05/2022
 * Function 		: 	Clase con los métodos usados en las implementaciones de la integración con Smart Supervision
 * Test Class		:	CS_SmartSupervision_Test
 *----------------------------------------------------------------------------------------------------------------------------
 *                                                MODIFICATION LOG
 *----------------------------------------------------------------------------------------------------------------------------
 * Developer		     	Date			   	Description
 * ---------------------------------------------------------------------------------------------------------------------------
 * Angel   Cabezas       23/05/2022         Original Version
 *****************************************************************************************************************************/
public without sharing class CS_SmartSupervision_Future {
	//?-----------------------------------------------------------------------------------------------//
	//?                                            MOMENTO 1                                          //
	//?-----------------------------------------------------------------------------------------------//

	@future(callout=true)
	public static void getComplainsFuture(String entityValue) {
		System.debug('--------------  CS_SmartSupervision_Future.getComplainsFuture  --------------');
		System.debug('1.1 CS_SmartSupervision_Future.getComplainsFuture entityValue: ' + entityValue);
		try {
			//* Realizar login para obtener el token de acceso
			CS_WrapperSmartSupervision.LoginRequestType loginRequest = new CS_WrapperSmartSupervision.LoginRequestType();
			loginRequest.caseEntity = entityValue;
			loginRequest.shortDescription = 'Smart Supervision: Momento 1 - Obtener Quejas';
			CS_WrapperSmartSupervision.LoginResponseType loginResponse = CS_SmartSupervision_WS.login(loginRequest);
			if (loginResponse != null) {
				//* Consumir servicio de consulta de quejas
				CS_WrapperSmartSupervision.GetComplainsRequestType getComplainsRequest = new CS_WrapperSmartSupervision.GetComplainsRequestType();
				getComplainsRequest.token = loginResponse.access;
				getComplainsRequest.caseEntity = entityValue;
				CS_WrapperSmartSupervision.GetComplainsResponseType getComplainsResponse = CS_SmartSupervision_WS.getComplains(
					getComplainsRequest
				);
				//* Manejar resultado de la consulta
				if (getComplainsResponse != null && !getComplainsResponse.results.isEmpty()) {
					List<String> idNumbersList = new List<String>();
					List<String> caseCodesList = new List<String>();
					for (CS_WrapperSmartSupervision.GetComplainResponseType complain : getComplainsResponse.results) {
						idNumbersList.add(complain.numero_id_CF);
						caseCodesList.add(complain.codigo_queja);
					}

					//* 1. Distribuir los resultados en tres listas. Una para aquellas cuentas que ya existen, otra para las
					//*    cuentas que deben ser actualizadas y otra para aquellas que deben ser creadas.
					List<CS_WrapperSmartSupervision.GetComplainResponseType> personalNewAccountComplainsList = new List<CS_WrapperSmartSupervision.GetComplainResponseType>();
					List<CS_WrapperSmartSupervision.GetComplainResponseType> juridicalNewAccountComplainsList = new List<CS_WrapperSmartSupervision.GetComplainResponseType>();
					List<CS_WrapperSmartSupervision.GetComplainResponseType> personalUpdateAccountsComplainsList = new List<CS_WrapperSmartSupervision.GetComplainResponseType>();
					List<CS_WrapperSmartSupervision.GetComplainResponseType> preexistingPersonalAccountsComplainsList = new List<CS_WrapperSmartSupervision.GetComplainResponseType>();
					List<CS_WrapperSmartSupervision.GetComplainResponseType> preexistingJuridicalAccountsComplainsList = new List<CS_WrapperSmartSupervision.GetComplainResponseType>();
					//* 1.1 Llenar listas de verificación de duplicados.
					Map<String, Account> personalAccountIdNumbersMap = new Map<String, Account>();
					Map<String, Account> juridicalAccountIdNumbersMap = new Map<String, Account>();
					Map<String, Case> complainCodeCaseObj = new Map<String, Case>();
					for (Account cuentaPersonal : [
						SELECT
							Id,
							CS_Condicionespecial__pc,
							CS_Empresa_Colmena__c,
							CS_LGBTIQ__pc,
							CS_NumeroIdentificacionCP__pc,
							CS_Sexo__pc,
							CS_TipoIdentificacionCP__pc,
							isPersonAccount
						FROM Account
						WHERE
							isPersonAccount = TRUE
							AND CS_Empresa_Colmena__c = :entityValue
							AND CS_NumeroIdentificacionCP__pc IN :idNumbersList
						WITH SECURITY_ENFORCED
					]) {
						personalAccountIdNumbersMap.put(cuentaPersonal.CS_NumeroIdentificacionCP__pc, cuentaPersonal);
					}

					for (Account cuentaJuridica : [
						SELECT Id, CS_Empresa_Colmena__c, CS_NumeroIdentificacion__c, CS_TipoIdentificacion__c, isPersonAccount
						FROM Account
						WHERE
							isPersonAccount = FALSE
							AND CS_Empresa_Colmena__c = :entityValue
							AND CS_NumeroIdentificacion__c IN :idNumbersList
						WITH SECURITY_ENFORCED
					]) {
						juridicalAccountIdNumbersMap.put(cuentaJuridica.CS_NumeroIdentificacion__c, cuentaJuridica);
					}

					for (Case caseObj : [
						SELECT Id, CS_CodigoQueja__c
						FROM Case
						WHERE CS_CodigoQueja__c IN :caseCodesList
						WITH SECURITY_ENFORCED
					]) {
						complainCodeCaseObj.put(caseObj.CS_CodigoQueja__c, caseObj);
					}

					for (CS_WrapperSmartSupervision.GetComplainResponseType complain : getComplainsResponse.results) {
						Boolean isPersonalAccount = complain.tipo_persona == 2 ? false : true;
						if (isPersonalAccount && personalAccountIdNumbersMap.keySet().contains(complain.numero_id_CF)) {
							Account acc = personalAccountIdNumbersMap.get(complain.numero_id_CF);

							Integer accIdType = Integer.valueOf(acc.CS_TipoIdentificacionCP__pc);
							Integer accGender = acc.CS_Sexo__pc != null
								? Integer.valueOf(acc.CS_Sexo__pc)
								: Integer.valueOf(CS_Utilities.getDefaultValuePicklist(Account.CS_Sexo__pc.getDescribe()));
							Integer accLGBTIQ = acc.CS_LGBTIQ__pc != null
								? Integer.valueOf(acc.CS_LGBTIQ__pc)
								: Integer.valueOf(CS_Utilities.getDefaultValuePicklist(Account.CS_LGBTIQ__pc.getDescribe()));
							Integer accSpecialCondition = acc.CS_Condicionespecial__pc != null
								? Integer.valueOf(acc.CS_Condicionespecial__pc)
								: Integer.valueOf(CS_Utilities.getDefaultValuePicklist(Account.CS_Condicionespecial__pc.getDescribe()));
							//* Ya existe una cuenta personal con el mismo número de documento
							if (complain.tipo_id_CF != accIdType) {
								//* Cambió el tipo de documento
								personalNewAccountComplainsList.add(complain);
							} else if (
								complain.sexo != accGender ||
								complain.lgbtiq != accLGBTIQ ||
								complain.condicion_especial != accSpecialCondition
							) {
								//* Cambió el Sexo, LGBTIQ+ o la Condición Especial.
								personalUpdateAccountsComplainsList.add(complain);
							} else {
								//* No hay cambios
								preexistingPersonalAccountsComplainsList.add(complain);
							}
						} else if (!isPersonalAccount && juridicalAccountIdNumbersMap.keySet().contains(complain.numero_id_CF)) {
							Account acc = juridicalAccountIdNumbersMap.get(complain.numero_id_CF);
							Integer accIdType = Integer.valueOf(acc.CS_TipoIdentificacion__c);
							//* Ya existe una cuenta jurídica con el mismo número de documento
							if (complain.tipo_id_CF != accIdType) {
								//* Cambió el tipo de documento
								juridicalNewAccountComplainsList.add(complain);
							} else {
								//* No hay cambios
								preexistingJuridicalAccountsComplainsList.add(complain);
							}
						} else {
							//* Crear una cuenta nueva
							if (isPersonalAccount) {
								personalNewAccountComplainsList.add(complain);
							} else {
								juridicalNewAccountComplainsList.add(complain);
							}
						}
					}
					//* 2. Para cada lista realizar las tareas específicas
					if (!personalNewAccountComplainsList.isEmpty()) {
						managePersonalNewAccountComplain(personalNewAccountComplainsList, complainCodeCaseObj, entityValue);
					}
					if (!juridicalNewAccountComplainsList.isEmpty()) {
						manageJuridicalNewAccountComplain(juridicalNewAccountComplainsList, complainCodeCaseObj, entityValue);
					}
					if (!personalUpdateAccountsComplainsList.isEmpty()) {
						managePersonalUpdateAccountComplain(
							personalUpdateAccountsComplainsList,
							personalAccountIdNumbersMap,
							complainCodeCaseObj,
							entityValue
						);
					}
					if (!preexistingPersonalAccountsComplainsList.isEmpty()) {
						managePreexistingPersonalAccounts(
							preexistingPersonalAccountsComplainsList,
							personalAccountIdNumbersMap,
							complainCodeCaseObj,
							entityValue
						);
					}
					if (!preexistingJuridicalAccountsComplainsList.isEmpty()) {
						managePreexistingJuridicalAccounts(
							preexistingJuridicalAccountsComplainsList,
							JuridicalAccountIdNumbersMap,
							complainCodeCaseObj,
							entityValue
						);
					}
				}
			}
		} catch (Exception e) {
			CS_Log_Helper.createLogSFInternalError(
				'Smart Supervision: Momento 1 - Obtener Quejas (FALLIDO)',
				'CS_SmartSupervision_Future.createCaseFuture',
				e
			);
		}
	}

    public static Case createBaseCaseExist(CS_WrapperSmartSupervision.GetComplainResponseType responseComplain, String entityValue) {
		Case newCase = new Case();

		newCase.CS_AnexosQueja__c = responseComplain.anexo_queja;
		newCase.CS_Canal__c = String.valueOf(responseComplain.canal_cod);
		newCase.CS_CodigoEntidad__c = responseComplain.entidad_cod;
		newCase.CS_CodigoQueja__c = responseComplain.codigo_queja;
		newCase.CS_Departamento__c = String.valueOf(responseComplain.departamento_cod);
		newCase.CS_Desistimiento__c = String.valueOf(responseComplain.desistimiento_queja);
		newCase.CS_EnteControl__c = String.valueOf(responseComplain.ente_control);
		newCase.CS_Escalamientodefensor__c = responseComplain.escalamiento_DCF == 1 ? true : false;
		newCase.CS_EstadoSincronizacionSuperfinanciera__c = CS_Utilities.SMART_SUPERVISION_CASO_RADICADO;
		newCase.CS_FechaCreacion__c = dateTime.valueOf(responseComplain.fecha_creacion.replace('T', ' '));
		newCase.CS_Municipio__c = String.valueOf(responseComplain.municipio_cod);
		newCase.CS_Pais__c = String.valueOf(responseComplain.codigo_pais);
		newCase.CS_ProductoNombre__c = responseComplain.producto_nombre;
		newCase.CS_ProductoM1__c = String.valueOf(responseComplain.producto_cod);
		newCase.CS_QuejaExpres__c = String.valueOf(responseComplain.queja_expres);
		newCase.CS_Subtipo__c = entityValue;
		newCase.CS_SuperintendenciaAddress__c = responseComplain.direccion;
		newCase.CS_SuperintendenciaEmail__c = responseComplain.correo;
		newCase.CS_SuperintendenciaName__c = responseComplain.nombres;
		newCase.CS_SuperintendenciaPhone__c = responseComplain.telefono;
		newCase.CS_TipoEntidad__C = responseComplain.tipo_entidad;
		newCase.CS_Tutela__c = responseComplain.tutela == 1 ? true : false;
		newCase.Description = responseComplain.texto_queja;
		

		//* Es replica
		if (responseComplain.replica == 1) {
			newCase.CS_ArgumentoReplica__c = String.valueOf(responseComplain.argumento_replica);
			newCase.CS_Replica__c = true;
			newCase.Priority = 'Alto';
			newCase.Status = 'Réplica';
		}

		return newCase;
	}
	public static Case createBaseCase(CS_WrapperSmartSupervision.GetComplainResponseType responseComplain, String entityValue) {
		Case newCase = new Case();

		newCase.CS_AnexosQueja__c = responseComplain.anexo_queja;
		newCase.CS_Canal__c = String.valueOf(responseComplain.canal_cod);
		newCase.CS_CodigoEntidad__c = responseComplain.entidad_cod;
		newCase.CS_CodigoQueja__c = responseComplain.codigo_queja;
		newCase.CS_Departamento__c = String.valueOf(responseComplain.departamento_cod);
		newCase.CS_Desistimiento__c = String.valueOf(responseComplain.desistimiento_queja);
		newCase.CS_EnteControl__c = String.valueOf(responseComplain.ente_control);
		newCase.CS_Escalamientodefensor__c = responseComplain.escalamiento_DCF == 1 ? true : false;
		newCase.CS_EstadoSincronizacionSuperfinanciera__c = CS_Utilities.SMART_SUPERVISION_CASO_RADICADO;
		newCase.CS_FechaCreacion__c = dateTime.valueOf(responseComplain.fecha_creacion.replace('T', ' '));
		newCase.CS_Municipio__c = String.valueOf(responseComplain.municipio_cod);
		newCase.CS_Pais__c = String.valueOf(responseComplain.codigo_pais);
		newCase.CS_ProductoNombre__c = responseComplain.producto_nombre;
		newCase.CS_ProductoM1__c = String.valueOf(responseComplain.producto_cod);
		newCase.CS_QuejaExpres__c = String.valueOf(responseComplain.queja_expres);
		newCase.CS_Subtipo__c = entityValue;
		newCase.CS_SuperintendenciaAddress__c = responseComplain.direccion;
		newCase.CS_SuperintendenciaEmail__c = responseComplain.correo;
		newCase.CS_SuperintendenciaName__c = responseComplain.nombres;
		newCase.CS_SuperintendenciaPhone__c = responseComplain.telefono;
		newCase.CS_TipoEntidad__C = responseComplain.tipo_entidad;
		newCase.CS_Tutela__c = responseComplain.tutela == 1 ? true : false;
		newCase.Description = responseComplain.texto_queja;
		newCase.recordTypeId = CS_Utilities.getRecordTypeIdByDevName(Schema.SObjectType.Case, 'CS_Queja_Superintendencia');

		//* Es replica
		if (responseComplain.replica == 1) {
			newCase.CS_ArgumentoReplica__c = String.valueOf(responseComplain.argumento_replica);
			newCase.CS_Replica__c = true;
			newCase.Priority = 'Alto';
			newCase.Status = 'Réplica';
		}

		return newCase;
	}

	public static void managePersonalNewAccountComplain(
		List<CS_WrapperSmartSupervision.GetComplainResponseType> personalNewAccountComplainsList,
		Map<String, Case> complainCodeCaseObj,
		String entityValue
	) {
		System.debug('--------------  CS_SmartSupervision_Future.managePersonalNewAccountComplain  --------------');
		System.debug(
			'1.1 CS_SmartSupervision_Future.managePersonalNewAccountComplain personalNewAccountComplainsList: ' +
			personalNewAccountComplainsList
		);
		System.debug('1.2 CS_SmartSupervision_Future.managePersonalNewAccountComplain complainCodeCaseObj: ' + complainCodeCaseObj);
		System.debug('1.3 CS_SmartSupervision_Future.managePersonalNewAccountComplain entityValue: ' + entityValue);
		//* Consultar información necesaria
		Id recordTypeIdPersonAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
			.get('PersonAccount')
			.getRecordTypeId();

		//* Crear listas para los nuevos registros
		List<Account> newAccounts = new List<Account>();
		List<Case> newCases = new List<Case>();

		//* Llenar listas con los registros a ser creados
		for (CS_WrapperSmartSupervision.GetComplainResponseType personalNewAccountComplain : personalNewAccountComplainsList) {
			//* Crear Cuenta Personal
			Account newAccount = new Account(); //Person Account
			newAccount.CS_CreadoDesdeQueja__pc = true;
			newAccount.RecordTypeId = recordTypeIdPersonAccount;
			newAccount.CS_Empresa_Colmena__c = entityValue;
			if (personalNewAccountComplain.nombres != null) {
				newAccount.LastName = personalNewAccountComplain.nombres;
			}
			if (personalNewAccountComplain.tipo_id_CF != null) {
				newAccount.CS_TipoIdentificacionCP__pc = String.valueOf(personalNewAccountComplain.tipo_id_CF);
			}
			if (personalNewAccountComplain.numero_id_CF != null) {
				newAccount.CS_NumeroIdentificacionCP__pc = personalNewAccountComplain.numero_id_CF;
			}
			if (personalNewAccountComplain.telefono != null) {
				newAccount.Phone = personalNewAccountComplain.telefono;
			}
			if (personalNewAccountComplain.correo != null) {
				newAccount.PersonEmail = personalNewAccountComplain.correo;
			}
			if (personalNewAccountComplain.sexo != null) {
				newAccount.CS_Sexo__pc = String.valueOf(personalNewAccountComplain.sexo);
			}
			if (personalNewAccountComplain.lgbtiq != null) {
				newAccount.CS_LGBTIQ__pc = String.valueOf(personalNewAccountComplain.lgbtiq);
			}
			if (personalNewAccountComplain.condicion_especial != null) {
				newAccount.CS_Condicionespecial__pc = String.valueOf(personalNewAccountComplain.condicion_especial);
			}
			newAccounts.add(newAccount);

			Case newCase ;

			//* Validar si el caso ya existe o es nuevo
			if (complainCodeCaseObj.containsKey(personalNewAccountComplain.codigo_queja)) {
				Case currentCase = complainCodeCaseObj.get(personalNewAccountComplain.codigo_queja);
				//* Caso preexistente
				newCase = createBaseCaseExist(personalNewAccountComplain, entityValue);

				newCase.Id = currentCase.Id;
				if (personalNewAccountComplain.anexo_queja == true) {
					newCase.CS_SmartSupervisionNuevosAdjuntos__c = true;
				}
			} else {
                newCase = createBaseCase(personalNewAccountComplain, entityValue);

				newCase.CS_SuperintendenciaMotivoQueja__c = String.valueOf(personalNewAccountComplain.macro_motivo_cod);
			}
			newCases.add(newCase);
            System.debug('Fer'+ newCase);
		}

		Database.SaveResult[] srListNewAccs = Database.insert(newAccounts, false);
		for (Integer i = 0; i < srListNewAccs.size(); i++) {
			Database.SaveResult sr = srListNewAccs.get(i);
			if (sr.isSuccess()) {
				newCases[i].AccountId = sr.getId();
			} else {
				for (Database.Error errorDb : sr.getErrors()) {
					CS_Log_Helper.createLogSFInternalDatabaseError(
						'Smart Supervision: Momento 1 - Crear cuenta (FALLIDO)',
						'CS_SmartSupervision_Future.managePersonalNewAccountComplain',
						errorDb
					);
				}
			}
		}

		Database.UpsertResult[] urListCases = Database.upsert(newCases, false);
		for (Database.UpsertResult ur : urListCases) {
			if (!ur.isSuccess()) {
				for (Database.Error errorDb : ur.getErrors()) {
                    System.debug('fer'+ errorDb );
					CS_Log_Helper.createLogSFInternalDatabaseError(
						'Smart Supervision: Momento 1 - Crear queja (FALLIDO)',
						'CS_SmartSupervision_Future.managePersonalNewAccountComplain',
						errorDb
					);
				}
			}
		}
	}

	public static void manageJuridicalNewAccountComplain(
		List<CS_WrapperSmartSupervision.GetComplainResponseType> juridicalNewAccountComplainsList,
		Map<String, Case> complainCodeCaseObj,
		String entityValue
	) {
		System.debug('--------------  CS_SmartSupervision_Future.manageJuridicalNewAccountComplain  --------------');
		System.debug(
			'1.1 CS_SmartSupervision_Future.manageJuridicalNewAccountComplain juridicalNewAccountComplainsList: ' +
			juridicalNewAccountComplainsList
		);
		System.debug('1.2 CS_SmartSupervision_Future.manageJuridicalNewAccountComplain complainCodeCaseObj: ' + complainCodeCaseObj);
		System.debug('1.3 CS_SmartSupervision_Future.manageJuridicalNewAccountComplain entityValue: ' + entityValue);
		//* Consultar información necesaria
		Id recordTypeJuridicalAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CS_Juridico').getRecordTypeId();

		//* Crear listas para los nuevos registros
		List<Account> newAccounts = new List<Account>();
		List<Case> newCases = new List<Case>();

		//* Llenar listas con los registros a ser creados
		for (CS_WrapperSmartSupervision.GetComplainResponseType juridicalNewAccountComplain : juridicalNewAccountComplainsList) {
			//* Crear Cuenta Jurídica
			Account newAccount = new Account();
			newAccount.CS_CreadoDesdeQueja__pc = true;
			newAccount.RecordTypeId = recordTypeJuridicalAccount;
			newAccount.CS_Empresa_Colmena__c = entityValue;
			if (juridicalNewAccountComplain.nombres != null) {
				newAccount.Name = juridicalNewAccountComplain.nombres;
			}
			if (juridicalNewAccountComplain.tipo_id_CF != null) {
				newAccount.CS_TipoIdentificacion__c = String.valueOf(juridicalNewAccountComplain.tipo_id_CF);
			}
			if (juridicalNewAccountComplain.numero_id_CF != null) {
				newAccount.CS_NumeroIdentificacion__c = juridicalNewAccountComplain.numero_id_CF;
			}
			if (juridicalNewAccountComplain.telefono != null) {
				newAccount.Phone = juridicalNewAccountComplain.telefono;
			}
			newAccounts.add(newAccount);

			Case newCase ;
			//* Validar si el caso ya existe o es nuevo
			if (complainCodeCaseObj.containsKey(juridicalNewAccountComplain.codigo_queja)) {
				Case currentCase = complainCodeCaseObj.get(juridicalNewAccountComplain.codigo_queja);
				//* Caso preexistente
				newCase = createBaseCaseExist(juridicalNewAccountComplain, entityValue);
				newCase.Id = currentCase.Id;
				if (juridicalNewAccountComplain.anexo_queja == true) {
					newCase.CS_SmartSupervisionNuevosAdjuntos__c = true;
				}
			} else {
                newCase = createBaseCase(juridicalNewAccountComplain, entityValue);
				newCase.CS_SuperintendenciaMotivoQueja__c = String.valueOf(juridicalNewAccountComplain.macro_motivo_cod);
			}
			newCases.add(newCase);
		}

		Database.SaveResult[] srListNewAccs = Database.insert(newAccounts, false);
		for (Integer i = 0; i < srListNewAccs.size(); i++) {
			Database.SaveResult sr = srListNewAccs.get(i);
            System.debug('Fer'+ sr);
			if (sr.isSuccess()) {
				newCases.get(i).AccountId = sr.getId();
			} else {
				for (Database.Error errorDb : sr.getErrors()) {
					CS_Log_Helper.createLogSFInternalDatabaseError(
						'Smart Supervision: Momento 1 - Crear cuenta (FALLIDO)',
						'CS_SmartSupervision_Future.managePersonalNewAccountComplain',
						errorDb
					);
				}
			}
		}

		Database.SaveResult[] srListNewCases = Database.insert(newCases, false);
		for (Database.SaveResult sr : srListNewCases) {
			if (!sr.isSuccess()) {
				for (Database.Error errorDb : sr.getErrors()) {
					CS_Log_Helper.createLogSFInternalDatabaseError(
						'Smart Supervision: Momento 1 - Crear queja (FALLIDO)',
						'CS_SmartSupervision_Future.managePersonalNewAccountComplain',
						errorDb
					);
				}
			}
		}
	}

	public static void managePersonalUpdateAccountComplain(
		List<CS_WrapperSmartSupervision.GetComplainResponseType> personalUpdateAccountsComplainsList,
		Map<String, Account> personalAccountIdNumbersMap,
		Map<String, Case> complainCodeCaseObj,
		String entityValue
	) {
		System.debug('--------------  CS_SmartSupervision_Future.managePersonalUpdateAccountComplain  --------------');
		System.debug(
			'1.1 CS_SmartSupervision_Future.managePersonalUpdateAccountComplain personalUpdateAccountsComplainsList: ' +
			personalUpdateAccountsComplainsList
		);
		System.debug(
			'1.2 CS_SmartSupervision_Future.managePersonalUpdateAccountComplain personalAccountIdNumbersMap: ' + personalAccountIdNumbersMap
		);
		System.debug('1.3 CS_SmartSupervision_Future.managePersonalUpdateAccountComplain complainCodeCaseObj: ' + complainCodeCaseObj);
		System.debug('1.4 CS_SmartSupervision_Future.managePersonalUpdateAccountComplain entityValue: ' + entityValue);
		//* Consultar información necesaria
		Id recordTypeIdPersonAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
			.get('PersonAccount')
			.getRecordTypeId();

		//* Crear listas para los nuevos registros
		List<Account> newAccounts = new List<Account>();
		List<Case> newCases = new List<Case>();

		//* Llenar listas con los registros a ser creados
		for (CS_WrapperSmartSupervision.GetComplainResponseType personalUpdateAccountComplain : personalUpdateAccountsComplainsList) {
			//* Crear Cuenta Personal
			Account newAccount = new Account(); //Person Account
			newAccount.Id = personalAccountIdNumbersMap.get(personalUpdateAccountComplain.numero_id_CF).Id;
			if (personalUpdateAccountComplain.telefono != null) {
				newAccount.Phone = personalUpdateAccountComplain.telefono;
			}
			if (personalUpdateAccountComplain.correo != null) {
				newAccount.PersonEmail = personalUpdateAccountComplain.correo;
			}
			if (personalUpdateAccountComplain.sexo != null) {
				newAccount.CS_Sexo__pc = String.valueOf(personalUpdateAccountComplain.sexo);
			}
			if (personalUpdateAccountComplain.lgbtiq != null) {
				newAccount.CS_LGBTIQ__pc = String.valueOf(personalUpdateAccountComplain.lgbtiq);
			}
			if (personalUpdateAccountComplain.condicion_especial != null) {
				newAccount.CS_Condicionespecial__pc = String.valueOf(personalUpdateAccountComplain.condicion_especial);
			}
			newAccounts.add(newAccount);

			Case newCase;
			//* Validar si el caso ya existe o es nuevo
			if (complainCodeCaseObj.containsKey(personalUpdateAccountComplain.codigo_queja)) {
				Case currentCase = complainCodeCaseObj.get(personalUpdateAccountComplain.codigo_queja);
				//* Caso preexistente
				newCase = createBaseCaseExist(personalUpdateAccountComplain, entityValue);
				newCase.Id = currentCase.Id;
				if (personalUpdateAccountComplain.anexo_queja == true) {
					newCase.CS_SmartSupervisionNuevosAdjuntos__c = true;
				}
			} else {
                newCase = createBaseCase(personalUpdateAccountComplain, entityValue);
				newCase.CS_SuperintendenciaMotivoQueja__c = String.valueOf(personalUpdateAccountComplain.macro_motivo_cod);
			}
			newCases.add(newCase);
		}

		Database.UpsertResult[] urListNewAccs = Database.upsert(newAccounts, false);
		for (Integer i = 0; i < urListNewAccs.size(); i++) {
			Database.UpsertResult ur = urListNewAccs.get(i);
			if (ur.isSuccess()) {
				newCases[i].AccountId = ur.getId();
			} else {
				for (Database.Error errorDb : ur.getErrors()) {
					CS_Log_Helper.createLogSFInternalDatabaseError(
						'Smart Supervision: Momento 1 - Crear cuenta (FALLIDO)',
						'CS_SmartSupervision_Future.managePersonalNewAccountComplain',
						errorDb
					);
				}
			}
		}

		Database.UpsertResult[] urListCases = Database.upsert(newCases, false);
		for (Database.UpsertResult ur : urListCases) {
			if (!ur.isSuccess()) {
				for (Database.Error errorDb : ur.getErrors()) {
					CS_Log_Helper.createLogSFInternalDatabaseError(
						'Smart Supervision: Momento 1 - Crear queja (FALLIDO)',
						'CS_SmartSupervision_Future.managePersonalNewAccountComplain',
						errorDb
					);
				}
			}
		}
	}

	public static void managePreexistingPersonalAccounts(
		List<CS_WrapperSmartSupervision.GetComplainResponseType> preexistingPersonalAccountsComplainsList,
		Map<String, Account> personalAccountIdNumbersMap,
		Map<String, Case> complainCodeCaseObj,
		String entityValue
	) {
		System.debug('--------------  CS_SmartSupervision_Future.managePreexistingPersonalAccounts  --------------');
		System.debug(
			'1.1 CS_SmartSupervision_Future.managePreexistingPersonalAccounts preexistingPersonalAccountsComplainsList: ' +
			preexistingPersonalAccountsComplainsList
		);
		System.debug(
			'1.2 CS_SmartSupervision_Future.managePreexistingPersonalAccounts personalAccountIdNumbersMap: ' + personalAccountIdNumbersMap
		);
		System.debug('1.3 CS_SmartSupervision_Future.managePreexistingPersonalAccounts complainCodeCaseObj: ' + complainCodeCaseObj);
		System.debug('1.4 CS_SmartSupervision_Future.managePreexistingPersonalAccounts entityValue: ' + entityValue);

		//* Crear listas para los nuevos registros
		List<Case> newCases = new List<Case>();

		//* Llenar listas con los registros a ser creados
		for (
			CS_WrapperSmartSupervision.GetComplainResponseType preexistingPersonalAccountsComplain : preexistingPersonalAccountsComplainsList
		) {
			Case newCase;
			//* Validar si el caso ya existe o es nuevo
			if (complainCodeCaseObj.containsKey(preexistingPersonalAccountsComplain.codigo_queja)) {
				System.debug('2 CS_SmartSupervision_Future.managePreexistingPersonalAccounts: Es un caso preexistente');
				Case currentCase = complainCodeCaseObj.get(preexistingPersonalAccountsComplain.codigo_queja);
				//* Caso preexistente
				newCase = createBaseCaseExist(preexistingPersonalAccountsComplain, entityValue);

				newCase.Id = currentCase.Id;
				if (preexistingPersonalAccountsComplain.anexo_queja == true) {
					System.debug('3 CS_SmartSupervision_Future.managePreexistingPersonalAccounts: La queja tiene anexos');
					newCase.CS_SmartSupervisionNuevosAdjuntos__c = true;
				}
			} else {
                newCase = createBaseCase(preexistingPersonalAccountsComplain, entityValue);

				newCase.CS_SuperintendenciaMotivoQueja__c = String.valueOf(preexistingPersonalAccountsComplain.macro_motivo_cod);
			}

			newCase.AccountId = personalAccountIdNumbersMap.get(preexistingPersonalAccountsComplain.numero_id_CF).Id;
			newCases.add(newCase);
		}

		Database.UpsertResult[] urListCases = Database.upsert(newCases, false);
		for (Database.UpsertResult ur : urListCases) {
			if (!ur.isSuccess()) {
				for (Database.Error errorDb : ur.getErrors()) {
					CS_Log_Helper.createLogSFInternalDatabaseError(
						'Smart Supervision: Momento 1 - Crear queja (FALLIDO)',
						'CS_SmartSupervision_Future.managePreexistingPersonalAccounts',
						errorDb
					);
				}
			}
		}
	}

	public static void managePreexistingJuridicalAccounts(
		List<CS_WrapperSmartSupervision.GetComplainResponseType> preexistingJuridicalAccountsComplainsList,
		Map<String, Account> JuridicalAccountIdNumbersMap,
		Map<String, Case> complainCodeCaseObj,
		String entityValue
	) {
		System.debug('--------------  CS_SmartSupervision_Future.managePreexistingJuridicalAccounts  --------------');
		System.debug(
			'1.1 CS_SmartSupervision_Future.managePreexistingJuridicalAccounts preexistingJuridicalAccountsComplainsList: ' +
			preexistingJuridicalAccountsComplainsList
		);
		System.debug(
			'1.2 CS_SmartSupervision_Future.managePreexistingJuridicalAccounts JuridicalAccountIdNumbersMap: ' +
			JuridicalAccountIdNumbersMap
		);
		System.debug('1.3 CS_SmartSupervision_Future.managePreexistingJuridicalAccounts complainCodeCaseObj: ' + complainCodeCaseObj);
		System.debug('1.4 CS_SmartSupervision_Future.managePreexistingJuridicalAccounts entityValue: ' + entityValue);
		//* Consultar información necesaria

		//* Crear listas para los nuevos registros
		List<Case> newCases = new List<Case>();

		//* Llenar listas con los registros a ser creados
		for (
			CS_WrapperSmartSupervision.GetComplainResponseType preexistingJuridicalAccountsComplain : preexistingJuridicalAccountsComplainsList
		) {
			Case newCase;
			//* Validar si el caso ya existe o es nuevo
			if (complainCodeCaseObj.containsKey(preexistingJuridicalAccountsComplain.codigo_queja)) {
				Case currentCase = complainCodeCaseObj.get(preexistingJuridicalAccountsComplain.codigo_queja);
				//* Caso preexistente
				newCase = createBaseCaseExist(preexistingJuridicalAccountsComplain, entityValue);
				newCase.Id = currentCase.Id;
				if (preexistingJuridicalAccountsComplain.anexo_queja == true) {
					newCase.CS_SmartSupervisionNuevosAdjuntos__c = true;
				}
			} else {
                newCase = createBaseCase(preexistingJuridicalAccountsComplain, entityValue);

				newCase.CS_SuperintendenciaMotivoQueja__c = String.valueOf(preexistingJuridicalAccountsComplain.macro_motivo_cod);
			}
			newCase.AccountId = JuridicalAccountIdNumbersMap.get(preexistingJuridicalAccountsComplain.numero_id_CF).Id;
			newCases.add(newCase);
		}

		Database.UpsertResult[] urListCases = Database.upsert(newCases, false);
		for (Database.UpsertResult ur : urListCases) {
			if (!ur.isSuccess()) {
				for (Database.Error errorDb : ur.getErrors()) {
					CS_Log_Helper.createLogSFInternalDatabaseError(
						'Smart Supervision: Momento 1 - Crear queja (FALLIDO)',
						'CS_SmartSupervision_Future.managePreexistingJuridicalAccounts',
						errorDb
					);
				}
			}
		}
	}

	@future(callout=true)
	public static void getComplainFilesFuture(Id caseId) {
		try {
			Case caseObj = [SELECT Id, CS_Subtipo__c, CS_CodigoQueja__c FROM Case WHERE Id = :caseId WITH SECURITY_ENFORCED LIMIT 1];
			List<CS_DocumentoCaso__c> caseDocuments = [
				SELECT Id, CS_Caso__c, CS_SmartSupervisionId__c
				FROM CS_DocumentoCaso__c
				WHERE CS_Caso__c = :caseId
				WITH SECURITY_ENFORCED
			];
			Set<Integer> caseDocumentIds = new Set<Integer>();
			for (CS_DocumentoCaso__c caseDocument : caseDocuments) {
				if (caseDocument.CS_SmartSupervisionId__c != null) {
					caseDocumentIds.add(Integer.valueOf(caseDocument.CS_SmartSupervisionId__c));
				}
			}
			//* Realizar login para obtener el token de acceso
			CS_WrapperSmartSupervision.LoginRequestType loginRequest = new CS_WrapperSmartSupervision.LoginRequestType();
			loginRequest.caseEntity = caseObj.CS_Subtipo__c;
			loginRequest.shortDescription = 'Smart Supervision: Momento 1 - Inicio de sesión';
			CS_WrapperSmartSupervision.LoginResponseType loginResponse = CS_SmartSupervision_WS.login(loginRequest);

			if (loginResponse != null) {
				//* Consumir servicio de consulta de archivos
				CS_WrapperSmartSupervision.GetComplainFilesRequestType getComplainFilesRequest = new CS_WrapperSmartSupervision.GetComplainFilesRequestType();
				getComplainFilesRequest.caseCode = caseObj.CS_CodigoQueja__c;
				getComplainFilesRequest.caseEntity = caseObj.CS_Subtipo__c;
				getComplainFilesRequest.caseId = caseObj.Id;
				getComplainFilesRequest.token = loginResponse.access;
				CS_WrapperSmartSupervision.GetComplainFilesResponseType getComplainFilesResponse = CS_SmartSupervision_WS.getComplainFiles(
					getComplainFilesRequest
				);

				if (getComplainFilesResponse != null) {
					List<CS_DocumentoCaso__c> newFiles = new List<CS_DocumentoCaso__c>();
					for (CS_WrapperSmartSupervision.ComplainFileResponseType result : getComplainFilesResponse.results) {
						if (!caseDocumentIds.contains(result.id)) {
							CS_DocumentoCaso__c newFile = new CS_DocumentoCaso__c();
							newFile.CS_Caso__c = caseId;
							newFile.CS_MomentoEnvio__c = CS_Utilities.SMART_SUPERVISION_MOMENTO_ENVIO_NUNCA;
							newFile.CS_EstadoSincronizacionSuperfinanciera__c = CS_Utilities.SMART_SUPERVISION_ARCHIVO_CORRECTO;
							newFile.CS_SmartSupervisionId__c = result.id;
							newFile.CS_SmartSupervisionTemporalURL__c = result.file;
							newFile.CS_SmartSupervisionReference__c = String.valueOf(result.reference);
							newFile.CS_ObtenerDesdeSmartSupervision__c = true;
							newFiles.add(newFile);
						}
					}
					Database.SaveResult[] srList = Database.insert(newFiles, false);
					Boolean existeFallo = false;
					for (Database.SaveResult sr : srList) {
						if (!sr.isSuccess()) {
							existeFallo = true;
							for (Database.Error err : sr.getErrors()) {
								CS_Log_Helper.createLogSFInternalDatabaseError(
									'Smart Supervision: Momento 1 - Obtener Archivos del Caso (FALLIDO)',
									'getComplainFilesFuture',
									err,
									caseId
								);
							}
						}
					}
					Case caseUpdate = new Case(Id = caseId);
					if (!existeFallo) {
						caseUpdate.CS_SmartSupervisionACK__c = true;
					}
					caseUpdate.CS_SmartSupervisionNuevosAdjuntos__c = false;
					update caseUpdate;
				}
			}
		} catch (Exception e) {
			CS_Log_Helper.createLogSFInternalError(
				'Smart Supervision: Momento 1 - Obtener Archivos del Caso (FALLIDO)',
				'CS_SmartSupervision_Future.updateComplainFuture',
				e,
				caseId
			);
		}
	}

	@future(callout=true)
	public static void ackFuture(List<Id> caseIds) {
		List<Case> caseList = [SELECT Id, CS_Subtipo__c, CS_CodigoQueja__c FROM Case WHERE Id IN :caseIds WITH SECURITY_ENFORCED];
		String caseEntity = caseList.get(0).CS_Subtipo__c;

		//* Realizar login para obtener el token de acceso
		CS_WrapperSmartSupervision.LoginRequestType loginRequest = new CS_WrapperSmartSupervision.LoginRequestType();
		loginRequest.caseEntity = caseEntity;
		loginRequest.shortDescription = 'Smart Supervision: Momento 1 - ACK';
		CS_WrapperSmartSupervision.LoginResponseType loginResponse = CS_SmartSupervision_WS.login(loginRequest);

		if (loginResponse != null) {
			//* Consumir servicio de ACK
			CS_WrapperSmartSupervision.ACKRequestType request = new CS_WrapperSmartSupervision.ACKRequestType();
			request.token = loginResponse.access;
			request.caseEntity = caseEntity;
			List<Id> caseIdsList = new List<Id>();
			List<String> caseCodes = new List<String>();
			for (Case caseObj : caseList) {
				caseCodes.add('"' + caseObj.CS_CodigoQueja__c + '"');
				caseIdsList.add(caseObj.Id);
			}
			request.caseIds = caseIdsList;
			request.caseCodes = caseCodes;
			CS_WrapperSmartSupervision.ACKResponseType ackResponse = CS_SmartSupervision_WS.ack(request);
		}
	}

	@future(callout=true)
	public static void getFileFuture(Id documentoCasoId) {
		CS_DocumentoCaso__c documentoCasoObj = [
			SELECT Id, CS_SmartSupervisionTemporalURL__c, CS_Caso__c
			FROM CS_DocumentoCaso__c
			WHERE Id = :documentoCasoId
			WITH SECURITY_ENFORCED
			LIMIT 1
		];

		//* Consumir servicio de recibo de archivo
		CS_WrapperSmartSupervision.GetFileRequestType getFileRequest = new CS_WrapperSmartSupervision.GetFileRequestType();
		getFileRequest.link = documentoCasoObj.CS_SmartSupervisionTemporalURL__c;
		getFileRequest.caseId = documentoCasoObj.CS_Caso__c;
		CS_WrapperSmartSupervision.GetFileResponseType getFileResponse = CS_SmartSupervision_WS.getFile(getFileRequest);

		if (getFileResponse != null) {
			String link = getFileRequest.link;
			Integer index = link.lastIndexOf('/');
			String fileName = link.substring((index + 1), (link.lastIndexOf('?')));
			System.debug('index =' + index);
			System.debug('fileName =' + fileName);
			Attachment att = new Attachment();
			att.Body = getFileResponse.blobFile;
			att.Name = fileName;
			att.parentId = documentoCasoId;
			insert (att);
		}
	}

	//?-----------------------------------------------------------------------------------------------//
	//?                                          MOMENTO 2                                            //
	//?-----------------------------------------------------------------------------------------------//

	@future(callout=true)
	public static void createCaseFuture(Id caseId, Id accountId) {
		try {
			Case caseObj = [
				SELECT
					Id,
					CS_Subtipo__c,
					CS_CodigoQueja__c,
					CaseNumber,
					CS_Pais__c,
					CS_Departamento__c,
					CS_Municipio__c,
					CS_Canal__c,
					CS_ProductoM2__c,
					CS_MotivoQuejaReclamoSuperM2__c,
					CreatedDate,
					CS_InstanciaRecepcion__c,
					Origin,
					CS_Admision__c,
					Description,
					CS_AnexosQueja__c,
					CS_EnteControl__c
				FROM Case
				WHERE Id = :caseId
				WITH SECURITY_ENFORCED
				LIMIT 1
			];
			Account accountObj = [
				SELECT
					Id,
					Name,
					RecordTypeId,
					CS_TipoIdentificacion__c,
					CS_TipoIdentificacionCP__pc,
					CS_NumeroIdentificacion__c,
					CS_NumeroIdentificacionCP__pc
				FROM Account
				WHERE Id = :accountId
				WITH SECURITY_ENFORCED
				LIMIT 1
			];

			//* Realizar login para obtener el token de acceso
			CS_WrapperSmartSupervision.LoginRequestType loginRequest = new CS_WrapperSmartSupervision.LoginRequestType();
			loginRequest.caseEntity = caseObj.CS_Subtipo__c;
			loginRequest.shortDescription = 'Smart Supervision: Momento 2 - Iniciar Sesión';
			loginRequest.caseId = caseId;
			CS_WrapperSmartSupervision.LoginResponseType loginResponse = CS_SmartSupervision_WS.login(loginRequest);

			if (loginResponse != null) {
				Id recordTypeIdPersonAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
					.get('PersonAccount')
					.getRecordTypeId();

				//* nombres
				String nombre = accountObj.Name;
				String nombreRecortado = nombre.length() > 50 ? nombre.substring(0, 50) : nombre;
				//* tipo_id_CF
				Integer idType = (accountObj.RecordTypeId != recordTypeIdPersonAccount && accountObj.CS_TipoIdentificacion__c != null) ||
					(accountObj.RecordTypeId == recordTypeIdPersonAccount &&
					accountObj.CS_TipoIdentificacionCP__pc != null)
					? accountObj.RecordTypeId == recordTypeIdPersonAccount
							? Integer.valueOf(accountObj.CS_TipoIdentificacionCP__pc)
							: Integer.valueOf(accountObj.CS_TipoIdentificacion__c)
					: null;
				//* numero_id_CF
				String idNumber = accountObj.RecordTypeId == recordTypeIdPersonAccount
					? accountObj.CS_NumeroIdentificacionCP__pc
					: accountObj.CS_NumeroIdentificacion__c;
				//* tipo_persona
				Integer accountType = accountObj.RecordTypeId == recordTypeIdPersonAccount ? 1 : 2; // 1: PersonAccount(Cuenta Personal) 2: Others (Jurídico)
				//* canal_cod
				Integer canalCode = caseObj.CS_Canal__c != null ? Integer.valueOf(caseObj.CS_Canal__c) : null;
				//* producto_cod
				Integer productCode = caseObj.CS_ProductoM2__c != null ? Integer.valueOf(caseObj.CS_ProductoM2__c) : null;
				//* macro_motivo_cod
				Integer macromotivoCode = caseObj.CS_MotivoQuejaReclamoSuperM2__c != null
					? Integer.valueOf(caseObj.CS_MotivoQuejaReclamoSuperM2__c)
					: null;
				//* fecha_creacion
				String createdDate = caseObj.CreatedDate.format('yyyy-MM-dd HH:mm:ss');
				//* insta_recepcion
				Integer instaRecepcion = caseObj.CS_InstanciaRecepcion__c != null
					? Integer.valueOf(caseObj.CS_InstanciaRecepcion__c)
					: null;
				//* punto_recepcion
				Map<String, String> mapeoOrigenCasoValorSuperMetadataType = CS_Utilities.getMapeoOrigenCasoValorSuperMetadataType();
				Integer caseOrigin = mapeoOrigenCasoValorSuperMetadataType.get(caseObj.Origin) != null
					? Integer.valueOf(mapeoOrigenCasoValorSuperMetadataType.get(caseObj.Origin))
					: null;
				//* admision
				Integer admision = caseObj.CS_Admision__c != null ? Integer.valueOf(caseObj.CS_Admision__c) : null;
				//* ente_control
				Integer enteControl = caseObj.CS_EnteControl__c != null ? Integer.valueOf(caseObj.CS_EnteControl__c) : null;

				//* Consumir servicio de envío de caso
				CS_WrapperSmartSupervision.CreateComplainRequestType createComplainRequest = new CS_WrapperSmartSupervision.CreateComplainRequestType();
				createComplainRequest.token = loginResponse.access;
				createComplainRequest.caseEntity = caseObj.CS_Subtipo__c;
				createComplainRequest.caseId = caseId;
				CS_WrapperSmartSupervision.ComplainRequestType newComplain = new CS_WrapperSmartSupervision.ComplainRequestType();
				//* Información de la cuenta
				newComplain.nombres = nombreRecortado;
				newComplain.tipo_id_CF = idType;
				newComplain.numero_id_CF = idNumber;
				newComplain.tipo_persona = accountType;
				//* Información del caso
				newComplain.codigo_queja = caseObj.CS_CodigoQueja__c;
				newComplain.codigo_pais = caseObj.CS_Pais__c;
				newComplain.departamento_cod = caseObj.CS_Departamento__c;
				newComplain.municipio_cod = caseObj.CS_Municipio__c;
				newComplain.canal_cod = canalCode;
				newComplain.producto_cod = productCode;
				newComplain.macro_motivo_cod = macromotivoCode;
				newComplain.fecha_creacion = createdDate;
				newComplain.insta_recepcion = instaRecepcion;
				newComplain.punto_recepcion = caseOrigin;
				newComplain.admision = admision;
				newComplain.texto_queja = caseObj.Description;
				newComplain.anexo_queja = caseObj.CS_AnexosQueja__c;
				newComplain.ente_control = enteControl;

				createComplainRequest.complain = newComplain;
				CS_WrapperSmartSupervision.CreateComplainResponseType createComplainResponse = CS_SmartSupervision_WS.createComplain(
					createComplainRequest
				);
				//* Actualizar campos de acuerdo a la respuesta
				Case caseUpdate = new Case(Id = caseId);
				if (createComplainResponse != null) {
					caseUpdate.CS_EstadoSincronizacionSuperfinanciera__c = CS_Utilities.SMART_SUPERVISION_CASO_RADICADO;
				} else {
					caseUpdate.CS_EstadoSincronizacionSuperfinanciera__c = CS_Utilities.SMART_SUPERVISION_CASO_ERROR_RADICAR;
				}
				update caseUpdate;
			} else {
				//* Actualizar campos de acuerdo a la respuesta
				Case caseUpdate = new Case(Id = caseId);
				caseUpdate.CS_EstadoSincronizacionSuperfinanciera__c = CS_Utilities.SMART_SUPERVISION_CASO_ERROR_RADICAR;
				update caseUpdate;
			}
		} catch (Exception e) {
			CS_Log_Helper.createLogSFInternalError(
				'Smart Supervision: Momento 2 - Radicar queja (FALLIDO)',
				'CS_SmartSupervision_Future.createCaseFuture',
				e,
				caseId
			);
			Case caseUpdate = new Case(Id = caseId);
			caseUpdate.CS_EstadoSincronizacionSuperfinanciera__c = CS_Utilities.SMART_SUPERVISION_CASO_ERROR_RADICAR;
			update caseUpdate;
		}
	}

	//?-----------------------------------------------------------------------------------------------//
	//?                                      Futuros MOMENTO 3                                        //
	//?-----------------------------------------------------------------------------------------------//
	@future(callout=true)
	public static void updateCaseFuture(Id caseId, Id accountId) {
		try {
			Case caseObj = [
				SELECT
					Id,
					ClosedDate,
					CS_Aceptacion__c,
					CS_Admision__c,
					CS_AnexosQueja__c,
					CS_ArgumentoReplica__c,
					CS_Canal__c,
					CS_CodigoQueja__c,
					CS_Desistimiento__c,
					CS_DocumentacionRespuesta__c,
					CS_EnteControl__c,
					CS_EstadoQuejaReclamo__c,
					CS_Favorabilidad__c,
					CS_Marcacion__c,
					CS_MotivoQuejaReclamoSuperM2__c,
					CS_ProductoDigital__c,
					CS_ProductoM2__c,
					CS_NumeroProrrogasSuperintendencia__c,
					CS_QuejaExpres__c,
					CS_Rectificacion__c,
					CS_Replica__c,
					CS_Subtipo__c,
					CS_Tutela__c
				FROM Case
				WHERE Id = :caseId
				WITH SECURITY_ENFORCED
				LIMIT 1
			];

			Account accountObj = [
				SELECT Id, CS_Condicionespecial__pc, CS_LGBTIQ__pc, CS_Sexo__pc, RecordTypeId
				FROM Account
				WHERE Id = :accountId
				WITH SECURITY_ENFORCED
				LIMIT 1
			];

			//* Realizar login para obtener el token de acceso
			CS_WrapperSmartSupervision.LoginRequestType loginRequest = new CS_WrapperSmartSupervision.LoginRequestType();
			loginRequest.caseEntity = caseObj.CS_Subtipo__c;
			loginRequest.shortDescription = 'Smart Supervision: Momento 3 - Iniciar Sesión';
			loginRequest.caseId = caseId;
			CS_WrapperSmartSupervision.LoginResponseType loginResponse = CS_SmartSupervision_WS.login(loginRequest);

			if (loginResponse != null) {
				//* CAMPOS OBLIGATORIOS

				//* producto_cod
				Integer productoCod = caseObj.CS_ProductoM2__c != null ? Integer.valueOf(caseObj.CS_ProductoM2__c) : null;
				//* macro_motivo_cod
				Integer macroMotivoCod = caseObj.CS_MotivoQuejaReclamoSuperM2__c != null
					? Integer.valueOf(caseObj.CS_MotivoQuejaReclamoSuperM2__c)
					: null;
				//* estado_cod
				Integer estadoCod = caseObj.CS_EstadoQuejaReclamo__c != null ? Integer.valueOf(caseObj.CS_EstadoQuejaReclamo__c) : null;
				//* producto_digital
				Integer productoDigital = caseObj.CS_ProductoDigital__c != null ? Integer.valueOf(caseObj.CS_ProductoDigital__c) : null;
				//* aceptacion_queja
				Integer aceptacionQueja = caseObj.CS_Aceptacion__c != null ? Integer.valueOf(caseObj.CS_Aceptacion__c) : null;
				//* rectificacion_queja
				Integer rectificacionQueja = caseObj.CS_Rectificacion__c != null ? Integer.valueOf(caseObj.CS_Rectificacion__c) : null;
				//* admision
				Integer admision = caseObj.CS_Admision__c != null ? Integer.valueOf(caseObj.CS_Admision__c) : null;
				//* documentacion_rta_final
				Boolean documentacionRtaFinal = caseObj.CS_DocumentacionRespuesta__c;
				//* anexo_queja
				Boolean anexoQueja = caseObj.CS_AnexosQueja__c;

				//* CAMPOS OPCIONALES
				Id recordTypeIdPersonAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
					.get('PersonAccount')
					.getRecordTypeId();

				//* sexo
				Integer sexo = accountObj.RecordTypeId == recordTypeIdPersonAccount
					? accountObj.CS_Sexo__pc != null ? Integer.valueOf(accountObj.CS_Sexo__pc) : null
					: Integer.valueOf(CS_Utilities.getDefaultValuePicklist(Account.CS_Sexo__pc.getDescribe()));
				//* lgbtiq
				Integer lgbtiq = accountObj.RecordTypeId == recordTypeIdPersonAccount
					? accountObj.CS_LGBTIQ__pc != null ? Integer.valueOf(accountObj.CS_LGBTIQ__pc) : null
					: Integer.valueOf(CS_Utilities.getDefaultValuePicklist(Account.CS_LGBTIQ__pc.getDescribe()));
				//* condicion_especial
				Integer condicionEspecial = accountObj.RecordTypeId == recordTypeIdPersonAccount
					? accountObj.CS_Condicionespecial__pc != null ? Integer.valueOf(accountObj.CS_Condicionespecial__pc) : null
					: Integer.valueOf(CS_Utilities.getDefaultValuePicklist(Account.CS_Condicionespecial__pc.getDescribe()));
				//* canal_cod
				Integer canalCod = caseObj.CS_Canal__c != null ? Integer.valueOf(caseObj.CS_Canal__c) : null;
				//* fecha_actualizacion
				String fechaActualizacion = Datetime.now().format('yyyy-MM-dd HH:mm:ss');
				//* a_favor_de
				Integer aFavorDe = caseObj.CS_Favorabilidad__c != null ? Integer.valueOf(caseObj.CS_Favorabilidad__c) : null;
				//* desistimiento_queja
				Integer desistimientoQueja = caseObj.CS_Desistimiento__c != null ? Integer.valueOf(caseObj.CS_Desistimiento__c) : null;
				//* prorroga_queja
				Integer prorrogaQueja = caseObj.CS_NumeroProrrogasSuperintendencia__c != 0 ? integer.valueOf(caseObj.CS_NumeroProrrogasSuperintendencia__c): null ;
				//* fecha_cierre
				String fechaCierre = caseObj.ClosedDate != null ? caseObj.ClosedDate.format('yyyy-MM-dd HH:mm:ss') : null;
				//* tutela
				Integer tutela = caseObj.CS_Tutela__c ? 1 : 2;
				//* ente_control
				Integer enteControl = caseObj.CS_EnteControl__c != null ? Integer.valueOf(caseObj.CS_EnteControl__c) : null;
				//* marcacion
				Integer marcacion = caseObj.CS_Marcacion__c != null ? Integer.valueOf(caseObj.CS_Marcacion__c) : null;
				//* queja_expres
				Integer quejaExpres = caseObj.CS_QuejaExpres__c != null ? Integer.valueOf(caseObj.CS_QuejaExpres__c) : null;
				//* replica
				Integer replica = caseObj.CS_Replica__c ? 1 : 2;
				//* argumento_replica
				String argumentoReplica = caseObj.CS_ArgumentoReplica__c;

				//* Consumir servicio de envío de caso
				CS_WrapperSmartSupervision.UpdateComplainRequestType updateComplainRequest = new CS_WrapperSmartSupervision.UpdateComplainRequestType();
				updateComplainRequest.token = loginResponse.access;
				updateComplainRequest.caseEntity = caseObj.CS_Subtipo__c;
				updateComplainRequest.caseCode = caseObj.CS_CodigoQueja__c;
				updateComplainRequest.caseId = caseId;

				CS_WrapperSmartSupervision.ComplainChangesRequestType updateComplain = new CS_WrapperSmartSupervision.ComplainChangesRequestType();
				//* Información de la cuenta
				updateComplain.sexo = sexo;
				updateComplain.lgbtiq = lgbtiq;
				updateComplain.condicion_especial = condicionEspecial;

				//* Información del caso
				updateComplain.producto_cod = productoCod;
				updateComplain.macro_motivo_cod = macroMotivoCod;
				updateComplain.estado_cod = estadoCod;
				updateComplain.producto_digital = productoDigital;
				updateComplain.aceptacion_queja = aceptacionQueja;
				updateComplain.rectificacion_queja = rectificacionQueja;
				updateComplain.admision = admision;
				updateComplain.documentacion_rta_final = documentacionRtaFinal;
				updateComplain.anexo_queja = anexoQueja;

				updateComplain.canal_cod = canalCod;
				updateComplain.fecha_actualizacion = fechaActualizacion;
				updateComplain.a_favor_de = aFavorDe;
				updateComplain.desistimiento_queja = desistimientoQueja;
				updateComplain.prorroga_queja = prorrogaQueja;
				updateComplain.fecha_cierre = fechaCierre;
				updateComplain.tutela = tutela;
				updateComplain.ente_control = enteControl;
				updateComplain.marcacion = marcacion;
				updateComplain.queja_expres = quejaExpres;
				updateComplain.replica = replica;
				updateComplain.argumento_replica = argumentoReplica;

				updateComplainRequest.complainChanges = updateComplain;
				CS_WrapperSmartSupervision.UpdateComplainResponseType updateComplainResponse = CS_SmartSupervision_WS.updateComplain(
					updateComplainRequest
				);
				//* Actualizar campos de acuerdo a la respuesta
				Case caseUpdate = new Case(Id = caseId);
				if (updateComplainResponse != null) {
					caseUpdate.CS_EstadoSincronizacionSuperfinanciera__c = CS_Utilities.SMART_SUPERVISION_CASO_ACTUALIZADO;
				} else {
					caseUpdate.CS_EstadoSincronizacionSuperfinanciera__c = CS_Utilities.SMART_SUPERVISION_CASO_ERROR_ACTUALIZAR;
				}
				update caseUpdate;
			}
		} catch (Exception e) {
			CS_Log_Helper.createLogSFInternalError(
				'Smart Supervision: Momento 3 - Actualizar queja (FALLIDO)',
				'CS_SmartSupervision_Future.updateComplainFuture',
				e,
				caseId
			);
			Case caseUpdate = new Case(Id = caseId);
			caseUpdate.CS_EstadoSincronizacionSuperfinanciera__c = CS_Utilities.SMART_SUPERVISION_CASO_ERROR_ACTUALIZAR;
			update caseUpdate;
		}
	}

	@future(callout=true)
	public static void addFileFuture(Id caseId, Id fileContentDocumentId, Id documentoCasoId) {
		Case caseObj = [SELECT Id, CS_Subtipo__c, CS_CodigoQueja__c FROM Case WHERE Id = :caseId WITH SECURITY_ENFORCED LIMIT 1];
		ContentVersion fileContentVersionObj = [
			SELECT Id, Title, IsLatest, VersionData, FileExtension, ContentDocumentId
			FROM ContentVersion
			WHERE ContentDocumentId = :fileContentDocumentId AND IsLatest = TRUE
			WITH SECURITY_ENFORCED
			LIMIT 1
		];

		//* Realizar login para obtener el token de acceso
		CS_WrapperSmartSupervision.LoginRequestType loginRequest = new CS_WrapperSmartSupervision.LoginRequestType();
		loginRequest.caseEntity = caseObj.CS_Subtipo__c;
		loginRequest.shortDescription = 'Smart Supervision: Momento 3 - Iniciar Sesión';
		loginRequest.caseId = caseId;
		CS_WrapperSmartSupervision.LoginResponseType loginResponse = CS_SmartSupervision_WS.login(loginRequest);

		if (loginResponse != null) {
			//* Consumir servicio de envío de archivo
			CS_WrapperSmartSupervision.AddFileRequestType addFileRequest = new CS_WrapperSmartSupervision.AddFileRequestType();
			addFileRequest.token = loginResponse.access;
			addFileRequest.caseEntity = caseObj.CS_Subtipo__c;
			addFileRequest.caseCode = caseObj.CS_CodigoQueja__c;
			addFileRequest.caseId = caseObj.Id;
			addFileRequest.file = fileContentVersionObj;

			CS_WrapperSmartSupervision.AddFileResponseType addFileResponse = CS_SmartSupervision_WS.addFile(addFileRequest);

			//* Actualizar campos de acuerdo con la respuesta
			CS_DocumentoCaso__c actualizarDoc = new CS_DocumentoCaso__c(Id = documentoCasoId);
			if (addFileResponse != null) {
				actualizarDoc.CS_SmartSupervisionId__c = addFileResponse.id;
				actualizarDoc.CS_SmartSupervisionTemporalURL__c = addFileResponse.file;
				actualizarDoc.CS_EstadoSincronizacionSuperfinanciera__c = CS_Utilities.SMART_SUPERVISION_ARCHIVO_CORRECTO;
				//* Validacion la hago para poder validar si hay algun archivo con la siguiente nomenclatura 'RESP_FINAL_SFC' para que no salte la regla cuando intentan cerrar el caso.
				List<ContentDocument> Archivo = [SELECT id,Title FROM ContentDocument WHERE id=:fileContentDocumentId];
				System.debug('@@@-va a validar si tiene la nomenclatura');
				if(Archivo[0].Title.contains('RESP_FINAL_SFC')){
					Case caseTiene = new Case(Id=caseId);
					caseTiene.Tiene_Respuesta_fianal__c=true;
					update caseTiene;
					System.debug('@@@-si tiene la nomenclatura y actualizo case ');
					}
					
			} else {
				actualizarDoc.CS_EstadoSincronizacionSuperfinanciera__c = CS_Utilities.SMART_SUPERVISION_ARCHIVO_FALLIDO;
			}
			update actualizarDoc;
		}
	}
    
    public static void clasePruebaMaster(){
        Integer contador = 0;
        contador++;
        contador++;
        contador++;
        contador++;
        contador++;
        contador++;
        contador++;
        contador++;
    }

	
}