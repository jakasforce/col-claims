/***************************************************************************************************************************
 * Nombre de la Clase Apex : CS_Utilities_Test
 * Versión                 : 1.0
 * Fecha de Creación       : 25/05/2022
 * Funcionalidad           : Pruebas Unitarias
 * Clase Principal         : CS_Utilities
 *--------------------------------------------------------------------------------------------------------------------------
 *                                              HISTORIAL DE MODIFICACIONES:
 *--------------------------------------------------------------------------------------------------------------------------
 * Desarrollador         Fecha           Descripción
 *--------------------------------------------------------------------------------------------------------------------------
 * Angel Cabezas         25/05/2022      Creación
 * Lidia Guerrero        26/05/2022      Implementación inicial
 *--------------------------------------------------------------------------------------------------------------------------
 **************************************************************************************************************************/
@isTest
private class CS_Utilities_Test {
	@testSetup
    static void setup(){
        account ACC= CS_TestDataFactory.createPersonAccount(true);
        Entitlement ent = new Entitlement(Name='ans consulta', AccountId=ACC.Id, 
        StartDate=Date.valueof(System.now().addDays(-2)), EndDate=Date.valueof(System.now().addYears(2)));
        insert ent;
        Map<Schema.SObjectField, Object> mapCase= new Map<Schema.SObjectField, Object>();
        mapCase.put(Case.CS_Subtipo__c, '2');
        mapCase.put(Case.CS_MacroMotivo__c, 'Defensor del consumidor SV');
        mapCase.put(Case.CS_Submotivo__c, 'Novedades');
        mapCase.put(Case.Status, 'Nuevo');
        mapCase.put(Case.Origin, 'Facebook');
        mapCase.put(Case.CS_FechaTentativaDeCierre__c, date.Today());
        Case caso= CS_TestDataFactory.createCase(mapCase, true);
        CS_ProcesoAtencion__c pa= new CS_ProcesoAtencion__c();
        pa.CS_MacroMotivo__c='Defensor del consumidor SV';
        pa.CS_Submotivo__c='Novedades';
        pa.CS_Subtipo__c='2';
        insert pa;
        CS_PasosAtencion__c paAt= new CS_PasosAtencion__c();
        paAt.CS_ProcesoAtencion__c=pa.Id; 
        paAt.Name='111111';
        paAt.CS_Tiempoatencion__c=3;
    	insert paAt;
        


    }
    @isTest
    static void caseConAsignacion(){
               map<Schema.SObjectField, Object> mapCase= new Map<Schema.SObjectField, Object>();
        mapCase.put(Case.Type , 'Problem');
        mapCase.put(Case.CS_PasosCompletados__c , true);
        mapCase.put(Case.CS_ProductoM2__c , '124');
        mapCase.put(Case.Status, 'Nuevo');
        mapCase.put(Case.Origin, 'Facebook');
        mapCase.put(Case.CS_MacroMotivo__c, 'Defensor del consumidor SV');
        mapCase.put(Case.CS_Subtipo__c , '2');
         mapCase.put(Case.CS_ProductoColmenaM2__c , 'Accidentes Personales');
         mapCase.put(Case.CS_FechaTentativaDeCierre__c, date.Today());
        Case caso= CS_TestDataFactory.createCase(mapCase, true);
        CS_AsginacionPasosAtencion__c paso= new CS_AsginacionPasosAtencion__c();
        paso.CS_CasoRelacionado__c=Caso.Id;
        paso.CS_Tiempo_de_AtencionN__c=1;
        paso.CS_Estado__c='Iniciado';
        paso.CS_AsignacionFlujoSecundario__c=false;
        insert paso;
        update caso;
        List <CS_AsginacionPasosAtencion__c> lst= [SELECT ID FROM CS_AsginacionPasosAtencion__c WHERE CS_CasoRelacionado__c=:caso.Id];
		CS_Utilities.completeIndependentMilestone(caso.id,system.today(),'');
        System.assertEquals(1, lst.size(), 'Se asignaron pasos de atención a pesar de que el caso ya tenía previamente');

        
    }
	@isTest
	static void testGetDataSignatureBody() {
        map<Schema.SObjectField, Object> mapCase= new Map<Schema.SObjectField, Object>();
        mapCase.put(Case.Type , 'Problem');
        mapCase.put(Case.CS_PasosCompletados__c , true);
        mapCase.put(Case.CS_ProductoM2__c , '124');
        mapCase.put(Case.Status, 'Nuevo');
        mapCase.put(Case.Origin, 'Facebook');
        mapCase.put(Case.CS_Subtipo__c , '2');
        mapCase.put(Case.CS_MacroMotivo__c, 'Defensor del consumidor SV');
        mapCase.put(Case.CS_ProductoColmenaM2__c , 'Accidentes Personales');
        Case caso= CS_TestDataFactory.createCase(mapCase, true);
		
		Test.startTest();
		String inputString = '{"username": "test@test.com", "password": "password12345"}';
		String caseEntity = caso.CS_Subtipo__c;
		String hexUppercaseMac = CS_Utilities.getDataSignature(caseEntity, inputString);
		Test.stopTest();
		//System.assertEquals('006AA5CA25BFC8DADB3F03F178BAA77672F49658742690C16DDE96497B1007DA', hexUppercaseMac, '');
	}

	@isTest
	static void testGetDataSignaturePath() {
		 Map<Schema.SObjectField, Object> mapCase= new Map<Schema.SObjectField, Object>();
        mapCase.put(Case.Type , 'Problem');
        mapCase.put(Case.CS_PasosCompletados__c , true);
        mapCase.put(Case.CS_ProductoM2__c , '132');
        mapCase.put(Case.Status, 'Nuevo');
        mapCase.put(Case.Origin, 'Facebook');
        mapCase.put(Case.CS_Subtipo__c , '1');
        mapCase.put(Case.CS_MacroMotivo__c, 'Defensor del consumidor RL');
        Case c= CS_TestDataFactory.createCase(mapCase, true);
		
		Test.startTest();
		String inputString = 'https://www.test.com';
		String caseEntity = c.CS_Subtipo__c;
		String hexUppercaseMac = CS_Utilities.getDataSignature(caseEntity, inputString);
		Test.stopTest();
		//System.assertEquals('E46AF8F0CCE0139BF37A7D4A6633C481055FF5787BB3CA7C4D4BFA77F66130B3', hexUppercaseMac, 'Valor correcto');
	}

	@isTest
	static void testGetRecordTypeIdByDevName() {
		Schema.DescribeSObjectResult dsr = Account.sObjectType.getDescribe();
		String developerName = 'CS_Juridico';
		Test.startTest();
		Id getRecordTypeIdByDevName = CS_Utilities.getRecordTypeIdByDevName(dsr, developerName);
		Test.stopTest();
		List<RecordType> rt = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'CS_Juridico' LIMIT 1];
		System.assertEquals(getRecordTypeIdByDevName, rt[0].Id, 'Los IDs son iguales');
	}

	@isTest
	static void testCheckIfItIsWorkingDayWeekend() {
		Date saturday = Date.newInstance(2023, 6, 25);
		Date sunday = Date.newInstance(2023, 6, 24);
		List<Holiday> holidays = new List<Holiday>();
		Test.startTest();
		Boolean isWorkingDaySaturday = CS_Utilities.checkIfItIsWorkingDay(saturday, holidays);
		Boolean isWorkingDaySunday = CS_Utilities.checkIfItIsWorkingDay(sunday, holidays);
		Test.stopTest();
		System.assertEquals(false, isWorkingDaySaturday, 'Error al validar con los días sábado');
		System.assertEquals(false, isWorkingDaySunday, 'Error al validar con los días domingo');
	}

	@isTest
	static void testCheckIfItIsWorkingDayHoliday() {
		Date holiday = Date.newInstance(2022, 1, 1);
		Holiday newHoliday = new Holiday();
		newHoliday.Name = 'Año nuevo';
		newHoliday.ActivityDate = holiday;
		insert newHoliday;
		List<Holiday> holidays = [SELECT StartTimeInMinutes, Name, ActivityDate, IsRecurrence, RecurrenceType, RecurrenceDayOfMonth FROM Holiday WITH SECURITY_ENFORCED];
		Test.startTest();
		Boolean isWorkingDayholiiday = CS_Utilities.CheckIfItIsWorkingDay(holiday, holidays);
		Test.stopTest();
		System.assertEquals(false, isWorkingDayholiiday, 'Error al validar con los Holidays');
	}

	@isTest
	static void testGetDateAfterWorkingDaysSuccessful() {
		Date initialDate = Date.newInstance(2024, 12, 31);
		Test.startTest();
		// Code to isolate with fresh governor limits
		Date finalDate = CS_Utilities.getDateAfterWorkingDays(initialDate, 1);
		Test.stopTest();
		System.assertEquals(finalDate, Date.newInstance(2025, 01, 02), 'Error al validar con los días laborales');
	}
    
    @isTest
	static void testGetDateAfterWorkingDaysSuccessful_02() {
		Date initialDate = Date.newInstance(2024, 04, 28);
		Test.startTest();
		// Code to isolate with fresh governor limits
		Date finalDate = CS_Utilities.getDateAfterWorkingDays(initialDate, 3);
		Test.stopTest();
		System.assertEquals(finalDate, Date.newInstance(2024, 05, 02), 'Error al validar con los días laborales');
	}

	@isTest
	static void testCheckIfItIsWorkingDayWorkingDay() {
		Date today = Date.newInstance(2022, 7, 7);
		Date saturday = Date.newInstance(2022, 7, 9);
		Date sunday = Date.newInstance(2022, 7, 10);
		List<Holiday> holidays = [SELECT StartTimeInMinutes, Name, ActivityDate, IsRecurrence, RecurrenceType, RecurrenceDayOfMonth FROM Holiday WITH SECURITY_ENFORCED];
		Test.startTest();
		// Code to isolate with fresh governor limits
		Boolean isWorkingDayToday = CS_Utilities.checkIfItIsWorkingDay(today, holidays);
		Boolean isWorkingDaySaturday = CS_Utilities.checkIfItIsWorkingDay(saturday, holidays);
		Boolean isWorkingDaySunday = CS_Utilities.checkIfItIsWorkingDay(sunday, holidays);
		Test.stopTest();
		System.assertEquals(true, isWorkingDayToday, 'Error al validar con los días laborales');
		System.assertEquals(false, isWorkingDaySaturday, 'Error al validar con los días sábado');
		System.assertEquals(false, isWorkingDaySunday, 'Error al validar con los días domingo');
	}
    @isTest
    static void calculaDiasHabiles(){
        Date fechaInicial= date.newInstance(2023, 09, 22);
        Date fechaFinal=fechaInicial.addDays(8);
        Integer dias= CS_Utilities.calculaDiasHabiles(fechaInicial, fechaFinal);
        System.assertEquals(6, dias, 'Error al calcular días habiles');
        Map<String, String> mapPrueb = CS_Utilities.getMapeoOrigenCasoValorSuperMetadataType();
        Map<String, String> mapPrueb1 = CS_Utilities.getMapeoValorSuperOrigenCasoMetadataType();
    }

	@isTest
	static void testGetExtensionContentTypeSuccessful() {
		String fileExtensionJpg = 'jpg';
		String fileExtensionPng = 'png';
		String fileExtensionJpeg = 'jpeg';
		String fileExtensionPdf = 'pdf';
		Test.startTest();
		String contentTypeJpg = CS_Utilities.getExtensionContentType(fileExtensionJpg);
		String contentTypePng = CS_Utilities.getExtensionContentType(fileExtensionPng);
		String contentTypeJpeg = CS_Utilities.getExtensionContentType(fileExtensionJpeg);
		String contentTypePdf = CS_Utilities.getExtensionContentType(fileExtensionPdf);
		Test.stopTest();
		System.assertEquals('image/jpeg', contentTypeJpg, 'La extensión fue la correcta');
		System.assertEquals('image/png', contentTypePng, 'La extensión fue la correcta');
		System.assertEquals('image/jpeg', contentTypeJpeg, 'La extensión fue la correcta');
		System.assertEquals('application/pdf', contentTypePdf, 'La extensión fue la correcta');
	}

	@isTest
	static void testGetExtensionContentTypeFailed() {
		String fileExtension = 'NotDefined';
		Test.startTest();
		String contentType = CS_Utilities.getExtensionContentType(fileExtension);
		Test.stopTest();
		System.assertEquals(null, contentType, 'No se muestra un correcto mensaje de error');
	}

	@isTest
	static void testGetMapeoEntidadTipoMetadataType() {
		CS_MapeoEntidades__mdt mapeoEntidad = [
			SELECT CS_Entidad__c, CS_TipoEntidad__c
			FROM CS_MapeoEntidades__mdt
			WHERE CS_Entidad__c = '3'
			WITH SECURITY_ENFORCED
			LIMIT 1
		];
		Map<Schema.SObjectField, Object> mapCase= new Map<Schema.SObjectField, Object>();
        mapCase.put(Case.Type , 'Problem');
        mapCase.put(Case.CS_PasosCompletados__c , true);
        mapCase.put(Case.CS_ProductoM2__c , '198');
        mapCase.put(Case.Status, 'Nuevo');
        mapCase.put(Case.Origin, 'Facebook');
        mapCase.put(Case.CS_Subtipo__c , '3');
        mapCase.put(Case.CS_MacroMotivo__c , 'Capitalizadora');
        Case caso= CS_TestDataFactory.createCase(mapCase, true);
		Test.startTest();
		Map<String, Decimal> getMapeoEntidadTipoMetadataTypeMap = CS_Utilities.getMapeoEntidadTipoMetadataType();
		Test.stopTest();
		System.assertEquals(mapeoEntidad.CS_TipoEntidad__c, getMapeoEntidadTipoMetadataTypeMap.get('3'), 'Tipo de entidad correcto');
	}

	@isTest
	static void testGetMapeoEntidadCodigoMetadataType() {
		CS_MapeoEntidades__mdt mapeoEntidad = [
			SELECT CS_Entidad__c, CS_CodigoEntidad__c
			FROM CS_MapeoEntidades__mdt
			WHERE CS_Entidad__c = '1'
			WITH SECURITY_ENFORCED
			LIMIT 1
		];
        Map<Schema.SObjectField, Object> mapCase= new Map<Schema.SObjectField, Object>();
        mapCase.put(Case.Type , 'Problem');
        mapCase.put(Case.CS_PasosCompletados__c , true);
        mapCase.put(Case.CS_ProductoM2__c , '132');
        mapCase.put(Case.Status, 'Nuevo');
        mapCase.put(Case.Origin, 'Facebook');
        mapCase.put(Case.CS_Subtipo__c , '1');
        mapCase.put(Case.CS_MacroMotivo__c, 'Defensor del consumidor RL');
        Case c= CS_TestDataFactory.createCase(mapCase, true);
		
		Test.startTest();
		Map<String, Decimal> getMapeoEntidadCodigoMetadataTypeMap = CS_Utilities.getMapeoEntidadCodigoMetadataType();
		Test.stopTest();
		System.assertEquals(mapeoEntidad.CS_CodigoEntidad__c, getMapeoEntidadCodigoMetadataTypeMap.get('1'), 'Código de entidad correcto');
	}

	@isTest
	static void testGetMapeoEntidadNombreMetadataType() {
		CS_MapeoEntidades__mdt mapeoEntidad = [
			SELECT CS_Entidad__c, MasterLabel
			FROM CS_MapeoEntidades__mdt
			WHERE CS_Entidad__c = '1'
			WITH SECURITY_ENFORCED
			LIMIT 1
		];
         Map<Schema.SObjectField, Object> mapCase= new Map<Schema.SObjectField, Object>();
        mapCase.put(Case.Type , 'Problem');
        mapCase.put(Case.CS_PasosCompletados__c , true);
        mapCase.put(Case.CS_ProductoM2__c , '132');
        mapCase.put(Case.Status, 'Nuevo');
        mapCase.put(Case.Origin, 'Facebook');
        mapCase.put(Case.CS_Subtipo__c , '1');
        mapCase.put(Case.CS_MacroMotivo__c, 'Defensor del consumidor RL');
        Case c= CS_TestDataFactory.createCase(mapCase, true);
		
		Test.startTest();
		Map<String, String> getMapeoEntidadNombreMetadataTypeMap = CS_Utilities.getMapeoEntidadNombreMetadataType();
		Test.stopTest();
		System.assertEquals(mapeoEntidad.MasterLabel, getMapeoEntidadNombreMetadataTypeMap.get('1'), 'Nombre de entidad correcto');
	}

	@isTest
	static void testGetMapeoEntidadUsernameMetadataType() {
		CS_MapeoEntidades__mdt mapeoEntidad = [
			SELECT CS_Entidad__c, CS_IntegrationUsername__c
			FROM CS_MapeoEntidades__mdt
			WHERE CS_Entidad__c = '3'
			WITH SECURITY_ENFORCED
			LIMIT 1
		];
		Map<Schema.SObjectField, Object> mapCase= new Map<Schema.SObjectField, Object>();
        mapCase.put(Case.Type , 'Problem');
        mapCase.put(Case.CS_PasosCompletados__c , true);
        mapCase.put(Case.CS_ProductoM2__c , '198');
        mapCase.put(Case.Status, 'Nuevo');
        mapCase.put(Case.Origin, 'Facebook');
        mapCase.put(Case.CS_Subtipo__c , '3');
        mapCase.put(Case.CS_MacroMotivo__c , 'Capitalizadora');
        Case caso= CS_TestDataFactory.createCase(mapCase, true);
		Test.startTest();
		Map<String, String> getMapeoEntidadUsernameMetadataTypeMap = CS_Utilities.getMapeoEntidadUsernameMetadataType();
		Test.stopTest();
		System.assertEquals(
			mapeoEntidad.CS_IntegrationUsername__c,
			getMapeoEntidadUsernameMetadataTypeMap.get('3'),
			'Username de entidad correcto'
		);
	}

	@isTest
	static void testGetMapeoEntidadPasswordMetadataType() {
		CS_MapeoEntidades__mdt mapeoEntidad = [
			SELECT CS_Entidad__c, CS_IntegrationPassword__c
			FROM CS_MapeoEntidades__mdt
			WHERE CS_Entidad__c = '2'
			WITH SECURITY_ENFORCED
			LIMIT 1
		];
         Map<Schema.SObjectField, Object> mapCase= new Map<Schema.SObjectField, Object>();
        mapCase.put(Case.Type , 'Problem');
        mapCase.put(Case.CS_PasosCompletados__c , true);
        mapCase.put(Case.CS_ProductoM2__c , '124');
        mapCase.put(Case.Status, 'Nuevo');
        mapCase.put(Case.Origin, 'Facebook');
        mapCase.put(Case.CS_ProductoColmenaM2__c , 'Accidentes Personales');
        mapCase.put(Case.CS_MacroMotivo__c, 'Defensor del consumidor SV');
        mapCase.put(Case.CS_Subtipo__c , '2');
        Case c= CS_TestDataFactory.createCase(mapCase, true);
		
		Test.startTest();
		Map<String, String> getMapeoEntidadPasswordMetadataTypeMap = CS_Utilities.getMapeoEntidadPasswordMetadataType();
		Test.stopTest();
		System.assertEquals(
			mapeoEntidad.CS_IntegrationPassword__c,
			getMapeoEntidadPasswordMetadataTypeMap.get('2'),
			'Password de entidad correcto'
		);
	}

	@isTest
	static void testGetMapeoEntidadSecretKeyMetadataType() {
         Map<Schema.SObjectField, Object> mapCase= new Map<Schema.SObjectField, Object>();
         mapCase.put(Case.Type , 'Problem');
        mapCase.put(Case.CS_PasosCompletados__c , true);
        mapCase.put(Case.CS_ProductoM2__c , '124');
        mapCase.put(Case.Status, 'Nuevo');
        mapCase.put(Case.Origin, 'Facebook');
        mapCase.put(Case.CS_ProductoColmenaM2__c , 'Accidentes Personales');
        mapCase.put(Case.CS_Subtipo__c , '2');
        mapCase.put(Case.CS_MacroMotivo__c, 'Defensor del consumidor SV');
        Case c= CS_TestDataFactory.createCase(mapCase, true);
		
		CS_MapeoEntidades__mdt mapeoEntidad = [
			SELECT CS_Entidad__c, CS_IntegrationSecretKey__c
			FROM CS_MapeoEntidades__mdt
			WHERE CS_Entidad__c = '2'
			WITH SECURITY_ENFORCED
			LIMIT 1
		];
		Test.startTest();
		Map<String, String> getMapeoEntidadSecretKeyMetadataTypeMap = CS_Utilities.getMapeoEntidadSecretKeyMetadataType();
		Test.stopTest();
		System.assertEquals(
			mapeoEntidad.CS_IntegrationSecretKey__c,
			getMapeoEntidadSecretKeyMetadataTypeMap.get('2'),
			'Secret Key de entidad correcto'
		);
	}
    @isTest
	static void getWorkingDaysBetweenDates(){
        Test.startTest();
            Date fechainicial = Date.today().addDays(-15);
            Date fechaFinal = Date.today();
            CS_Utilities.getWorkingDaysBetweenDates(fechainicial,fechaFinal);
        Test.stopTest();
	}

	@isTest
	static void testExtractFileNameToURL_Success(){
		String URL = 'https://storage.googleapis.com/unscanned3-sfc-smartsupervision-qa/14321708097335758412/TestFileNameTesting.png?Expires=1708098255';
		String regex = '.*/([^?]+)\\?.*';
		Test.startTest();
		String fileName = CS_Utilities.extractFileNameToURL(URL, regex);
		Test.stopTest();
		String fileNameExpected = 'TestFileNameTesting.png';
		Assert.areEqual(fileNameExpected, fileName, 'Error - Expected fileName: '+fileNameExpected);
	}

	@isTest
	static void testExtractFileNameToURL_Error(){
		String URL = '';
		String regex = '.*/([^?]+)\\?.*';
		Test.startTest();
		String fileName = CS_Utilities.extractFileNameToURL(URL, regex);
		Test.stopTest();
		String fileNameExpected = null;
		Assert.areEqual(fileNameExpected, fileName, 'Error - Expected fileName: '+fileNameExpected);
	}

}