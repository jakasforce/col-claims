/*********************************************************************************************************************************************
 Nombre de la Clase Apex: CS_Utilities
 Versión : 1.0
 Fecha de Creación : 07/03/2022
 Funcionalidad :  Clase con métodos de uso general.
 Clase de Prueba: CS_Utilities_Test
 Historial de Modificaciones:
 --------------------------------------------------------------------------------------------------------------------------------------------
 *Desarrollador -    Fecha –     Descripción
 * -----------------------------------------------------------------------------------------------------------------------------------------
 * Sayra Martinez    07/03/2022   Versión Original
 * Angel Cabezas     20/04/2022   Adición de métodos para encriptación y para consulta de metadata
 * Angel Cabezas     13/05/2022   Reestructuración y nuevo método
 * Angel Cabezas     23/06/2022   Reestructuración y nuevo método
 * Frank Tovar		 19/02/2024	  Adicion de metodo para extraer nombre de archivo de una URL mediante expresion regular
 *********************************************************************************************************************************************/
public with sharing class CS_Utilities {
	//?-----------------------------------------------------------------------------------------------//
	//?                                 		  	Constants                                         //
	//?-----------------------------------------------------------------------------------------------//

	//* CONSTANTES ESTADOS DE SINCRONIZACIÓN CASOS SUPERINTENDENCIA FINANCIERA
	public static final String SMART_SUPERVISION_CASO_RADICADO = 'Radicado';
	public static final String SMART_SUPERVISION_CASO_ERROR_RADICAR = 'No radicado (error al radicar)';
	public static final String SMART_SUPERVISION_CASO_ACTUALIZADO = 'Actualizado';
	public static final String SMART_SUPERVISION_CASO_ERROR_ACTUALIZAR = 'No Actualizado (error al actualizar)';

	//* CONSTANTES ESTADOS DE SINCRONIZACIÓN DOCUMENTOS SUPERINTENDENCIA FINANCIERA
	public static final String SMART_SUPERVISION_ARCHIVO_PENDIENTE = 'No enviado';
	public static final String SMART_SUPERVISION_ARCHIVO_CORRECTO = 'Enviado';
	public static final String SMART_SUPERVISION_ARCHIVO_FALLIDO = 'Fallido';

	//* CONSTANTES MOMENTOS DE ENVÍO DOCUMENTOS SUPERINTENDENCIA FINANCIERA
	public static final String SMART_SUPERVISION_MOMENTO_ENVIO_NUNCA = 'Nunca';
	public static final String SMART_SUPERVISION_MOMENTO_ENVIO_ESCALADO = 'Escalado';
	public static final String SMART_SUPERVISION_MOMENTO_ENVIO_REPLICA = 'Réplica';
	public static final String SMART_SUPERVISION_MOMENTO_ENVIO_CERRADO_ATENDIDO = 'Cerrado Atendido';
	public static final String SMART_SUPERVISION_MOMENTO_ENVIO_CERRADO_INACTIVO = 'Cerrado Inactivo';

	//?-----------------------------------------------------------------------------------------------//
	//?                              		      Normal Methods                                      //
	//?-----------------------------------------------------------------------------------------------//

	/**
	 * @description getDataSignature Genera el código de autenticacion de mensaje (HMAC-256) para la entrada de texto, usando una llave privada específica.
	 * @param  caseEntity  caseEntity valor de la entidad con la que se realizará el logeo. El valor está definido por el picklist.
	 * @param  inputString inputString Entrada de texto utilizada para generar la firma
	 * @return             return HMAC-256 hexagecimal y en mayúsculas
	 */
	public static String getDataSignature(String caseEntity, String inputString) {
		System.debug('--------------    CS_Utilities.getDataSignature     --------------');
		System.debug('1. CS_Utilities.getDataSignature caseEntity: ' + caseEntity);
		System.debug('2. CS_Utilities.getDataSignature inputString: ' + inputString);
		//* Get Secret Key
		String secretKey = getMapeoEntidadSecretKeyMetadataType().get(caseEntity);
		System.debug('3. CS_Utilities.getDataSignature secretKey: ' + secretKey);
		//* Computes a message authentication code (MAC) for the input string, using the private key and the specified algorithm.
		Blob mac = crypto.generateMac('hmacSHA256', Blob.valueOf(inputString), Blob.valueOf(secretKey));
		//* Converts the specified hexadecimal (base 16) string to a Blob value and returns this Blob value, also transform to uppercase.
		String hexUppercaseMac = EncodingUtil.convertToHex(mac).toUpperCase();
		System.debug('4. CS_Utilities.getDataSignature signature: ' + hexUppercaseMac);
		System.debug('------------------------------------------------------------------');
		return hexUppercaseMac;
	}

	/**
	 * @description getRecordTypeId Método que obtiene el id de un tipo de registro por su nombre de desarrollador.
	 * @pre Se asume que el tipo de registro ya fué creado para el Objeto deseado.
	 * @param  sObjectDescribing sObjectDescribing descripción del objeto
	 * @param  developerName     inputString nombre de desarrollador del tipo de registro
	 * @return                   return Id del Record Type buscado
	 */
	public static Id getRecordTypeIdByDevName(Schema.DescribeSObjectResult sObjectDescribing, String developerName) {
		Map<String, Schema.RecordTypeInfo> rtMapByDevName = sObjectDescribing.getRecordTypeInfosByDeveloperName();
		Schema.RecordTypeInfo rtByDevName = rtMapByDevName.get(developerName);
		return rtByDevName.getRecordTypeId();
	}

	/**
	 * @description getExtensionContentType obtiene el valor del mapeo entre la extensión y el Content Type asociado
	 * @param  fileExtension fileExtension extensión del archivo
	 * @return               return Content Type asociado a la extensión
	 */
	public static String getExtensionContentType(String fileExtension) {
		Map<String, String> mimeTypesMap = new Map<String, String>();
		for (CS_MIMETypes__mdt mimeType : [SELECT CS_Extension__c, CS_MIMEType__c FROM CS_MIMETypes__mdt WITH SECURITY_ENFORCED]) {
			mimeTypesMap.put(mimeType.CS_Extension__c, mimeType.CS_MIMEType__c);
		}
		return mimeTypesMap.get(fileExtension);
	}

	/*--------------------------------------------------------------
	 * Nombre del método: getMapeoOrigenCasoValorSuperMetadataType
	 * Descripción      : Obtiene todos los mapeos de los posibles orígenes de los casos
	 * @return          : {Map<String, String>} Mapa con las relaciones Salesforce-Super
	 --------------------------------------------------------------*/
	public static Map<String, String> getMapeoOrigenCasoValorSuperMetadataType() {
		System.debug('--------------    CS_Utilities.getMapeoOrigenCasoValorSuperMetadataType     --------------');
		Map<String, String> origenesCasosMap = new Map<String, String>();
		for (CS_MapeoOrigenesCasos__mdt mapeoOrigenCaso : [
			SELECT CS_CaseOrigin__c, CS_ValorSuperintendencia__c
			FROM CS_MapeoOrigenesCasos__mdt
			WITH SECURITY_ENFORCED
		]) {
			origenesCasosMap.put(mapeoOrigenCaso.CS_CaseOrigin__c, mapeoOrigenCaso.CS_ValorSuperintendencia__c);
		}
		System.debug('1. CS_Utilities.getMapeoOrigenCasoValorSuperMetadataType origenesCasosMap: ' + origenesCasosMap);
		System.debug('------------------------------------------------------------------');
		return origenesCasosMap;
	}

	/*--------------------------------------------------------------
	 * Nombre del método: getMapeoValorSuperOrigenCasoMetadataType
	 * Descripción      : Obtiene todos los mapeos de los posibles orígenes de los casos
	 * @return          : {Map<String, String>} Mapa con las relaciones Super-Salesforce
	 --------------------------------------------------------------*/
	public static Map<String, String> getMapeoValorSuperOrigenCasoMetadataType() {
		System.debug('--------------    CS_Utilities.getMapeoValorSuperOrigenCasoMetadataType     --------------');
		Map<String, String> origenesCasosMap = new Map<String, String>();
		for (CS_MapeoOrigenesCasos__mdt mapeoOrigenCaso : [
			SELECT CS_CaseOrigin__c, CS_ValorSuperintendencia__c
			FROM CS_MapeoOrigenesCasos__mdt
			WITH SECURITY_ENFORCED
		]) {
			origenesCasosMap.put(mapeoOrigenCaso.CS_ValorSuperintendencia__c, mapeoOrigenCaso.CS_CaseOrigin__c);
		}
		System.debug('1. CS_Utilities.getMapeoValorSuperOrigenCasoMetadataType origenesCasosMap: ' + origenesCasosMap);
		System.debug('------------------------------------------------------------------');
		return origenesCasosMap;
	}

	/*--------------------------------------------------------------
	 * Nombre del método: getDefaultValuePicklist
	 * Descripción      : Obtiene el valor por defecto de un campo de lista de selección deseado
	 * @param  picklistFieldDescribe  picklistFieldDescribe Ejemplo: Account.SamplePicklist__c.getDescribe()
	 * @return          : {String} Valor por defecto del picklist
	 --------------------------------------------------------------*/
	public static String getDefaultValuePicklist(Schema.DescribeFieldResult picklistFieldDescribe) {
		String defaultVal;
		List<Schema.PicklistEntry> pickVals = picklistFieldDescribe.getPicklistValues();
		for (Schema.PicklistEntry pv : pickVals) {
			if (pv.isDefaultValue()) {
				defaultVal = pv.getValue();
			}
		}
		return defaultVal;
	}

	//?-----------------------------------------------------------------------------------------------//
	//?                                 SINGLETON  Working days                                       //
	//?-----------------------------------------------------------------------------------------------//

	private static List<Holiday> holidays = new List<Holiday>();

	/*--------------------------------------------------------------
	 * Nombre del método: getDateAfterWorkingDays
	 * Descripción      : Asigna fecha de caso omitiendo dias festivos y fines de semana
	 * @param  initialDate  initialDate campo que obtiene el día en el que se registra un caso
	 * @param  days  days Determina el límite de días
	 * @return  checkIfItIsWorkingDay: {Date} Regresa la Final Date que es igual a la Initial Date
	 --------------------------------------------------------------*/
	public static Date getDateAfterWorkingDays(Date initialDate, Integer days) {
		if (holidays.isEmpty()) {
			holidays = [SELECT Name, ActivityDate, IsRecurrence, RecurrenceType, RecurrenceDayOfMonth FROM Holiday WITH SECURITY_ENFORCED];
		}
        
		Date finalDate = initialDate;
		Integer i = 0;
		integer limite = days;
		while (i < limite) {
			finalDate = finalDate.addDays(1);           
            if (checkifItisWorkingDay(finalDate, holidays)) {
				i++;
			}
		}
		return finalDate;
	}
    
	/*--------------------------------------------------------------
	 * Nombre del método: checkIfItIsWorkingDay
	 * Descripción      : Asigna fecha de caso omitiendo dias festivos y fines de semana
	 * @param  currentDate  initialDate campo que obtiene el día en el que se registra un caso
	 * @param  List<Holiday> Lista de los días Holidays en la Org.
	 * @param  holidays: Variable Holidays
	 * @return isWorkingDay: {Boolean} regresa el valor por defecto del boolean
	 --------------------------------------------------------------*/
	public static Boolean checkIfItIsWorkingDay(Date currentDate, List<Holiday> holidays) {
		Boolean isWorkingDay = true;
		//* Verificar que el día actual es un día de fin de semana.
		Date weekStart = currentDate.toStartofWeek();
		Integer dayNumber = weekStart.daysBetween(currentDate);
		if (dayNumber == 0 || dayNumber == 6) {
			isWorkingDay = false;
            return isWorkingDay; // Añade return para detener la ejecucion posterior.
		}
        
        //*Verificar si es un día festivo.
		for (Holiday currentHoliday : holidays) {   
            // Verificamos si la fecha festiva es Recurrente y con frecuenta Anual.
            if(currentHoliday.IsRecurrence && currentHoliday.RecurrenceType == 'RecursYearly'){
                Date nextOccurrenceDate; // Almacena el calculo de la proxima fecha valida
                Integer targetYear = currentHoliday.ActivityDate.year(); // Almacena el año valido para la comparacion posterior
            	// Verificamos si la fecha festiva registrada es menor a la fecha actual, incrementamos 1 año
				while(Date.today() > currentHoliday.ActivityDate){
					currentHoliday.ActivityDate = Date.newInstance(currentHoliday.ActivityDate.year() + 1, currentHoliday.ActivityDate.month(), currentHoliday.ActivityDate.day());
				}
				targetYear = currentHoliday.ActivityDate.year();
                // Se almacena la proxima fecha festiva valida
        		nextOccurrenceDate = Date.newInstance(targetYear, currentHoliday.ActivityDate.month(), currentHoliday.RecurrenceDayOfMonth);
                // Comparamos la proxima fecha festiva calcula vs la fecha en proceso de verificacion
                if (nextOccurrenceDate.daysBetween(currentDate) == 0) {
                    isWorkingDay = false;
                }                   
            } else if (currentHoliday.ActivityDate.daysBetween(currentDate) == 0) {
				isWorkingDay = false;
			}
		}
		return isWorkingDay;
	}
    
    public static Boolean checkIfItIsWorkingDay(Date currentDate) {
        if (holidays.isEmpty()) {
			holidays = [SELECT Name, ActivityDate, IsRecurrence, RecurrenceType, RecurrenceDayOfMonth FROM Holiday WITH SECURITY_ENFORCED];
		}
		Boolean isWorkingDay = true;
		//* Verificar que el día actual es un día de fin de semana.
		Date weekStart = currentDate.toStartofWeek();
		Integer dayNumber = weekStart.daysBetween(currentDate);
		if (dayNumber == 0 || dayNumber == 6) {
			isWorkingDay = false;
		}

		//*Verificar si es un día festivo.
		for (Holiday currentHoliday : holidays) {
			// Verificamos si la fecha festiva es Recurrente y con frecuenta Anual.
            if(currentHoliday.IsRecurrence && currentHoliday.RecurrenceType == 'RecursYearly'){
                Date nextOccurrenceDate; // Almacena el calculo de la proxima fecha valida
                Integer targetYear = currentHoliday.ActivityDate.year(); // Almacena el año valido para la comparacion posterior
            	// Verificamos si la fecha festiva registrada es menor a la fecha actual, incrementamos 1 año
				while(Date.today() > currentHoliday.ActivityDate){
					currentHoliday.ActivityDate = Date.newInstance(currentHoliday.ActivityDate.year() + 1, currentHoliday.ActivityDate.month(), currentHoliday.ActivityDate.day());
				}
				targetYear = currentHoliday.ActivityDate.year();
                // Se almacena la proxima fecha festiva valida
        		nextOccurrenceDate = Date.newInstance(targetYear, currentHoliday.ActivityDate.month(), currentHoliday.RecurrenceDayOfMonth);
                // Comparamos la proxima fecha festiva calcula vs la fecha en proceso de verificacion
                if (nextOccurrenceDate.daysBetween(currentDate) == 0) {
                    isWorkingDay = false;
                }                   
            } else if (currentHoliday.ActivityDate.daysBetween(currentDate) == 0) {
				isWorkingDay = false;
			}

		}
		return isWorkingDay;
	}

    /*--------------------------------------------------------------
	 * Nombre del método: checkIfItIsWorkingDay
	 * Descripción      : Asigna fecha de caso omitiendo dias festivos y fines de semana
	 * @param  currentDate  initialDate campo que obtiene el día en el que se registra un caso
	 * @param  List<Holiday> Lista de los días Holidays en la Org.
	 * @param  holidays: Variable Holidays
	 * @return isWorkingDay: {Boolean} regresa el valor por defecto del boolean
	 --------------------------------------------------------------*/
	public static Integer calculaDiasHabiles(Date initialDate, Date finalDate) {
        if (holidays.isEmpty()) {
			holidays = [SELECT Name, ActivityDate, IsRecurrence, RecurrenceType, RecurrenceDayOfMonth FROM Holiday WITH SECURITY_ENFORCED];
		}
        Integer dias=0;
		 for(integer i=0;i<= initialDate.daysBetween(finalDate); i++) {  
             Date fecha= initialDate.addDays(i);
             if(checkIfItIsWorkingDay(fecha, holidays)){
                 dias=dias+1;
             }
               
        }  
        return dias;
	}

	public static Integer getWorkingDaysBetweenDates(Date initialDate, Date finalDate){
		Integer daysCounter = 0;
		Date currentDate = initialDate;
		while(currentDate < finalDate){
			if(checkIfItIsWorkingDay(currentDate)){
				daysCounter++;
			}
			currentDate = currentDate.addDays(1);
		}
		return daysCounter;
	}

	//?-----------------------------------------------------------------------------------------------//
	//?                                 SINGLETON  CS_MapeoEntidades__mdt                             //
	//?-----------------------------------------------------------------------------------------------//

	private static Map<String, Decimal> mapEntidadTipo = new Map<String, Decimal>();
	private static Map<String, Decimal> mapEntidadCodigo = new Map<String, Decimal>();
	private static Map<String, String> mapEntidadNombre = new Map<String, String>();
	private static Map<String, String> mapEntidadUsername = new Map<String, String>();
	private static Map<String, String> mapEntidadPassword = new Map<String, String>();
	private static Map<String, String> mapEntidadSecretKey = new Map<String, String>();

	/*--------------------------------------------------------------
	 * Nombre del método: loadMapeoEntidadMetadataType
	 * Descripción      : Carga las variable para usar por transacción con la información requerida
	 --------------------------------------------------------------*/
	public static void loadMapeoEntidadMetadataType() {
		System.debug('--------------    CS_Utilities.loadMapeoEntidadMetadataType     --------------');
		List<CS_MapeoEntidades__mdt> mapeosEntidades = [
			SELECT
				CS_Entidad__c,
				CS_CodigoEntidad__c,
				CS_TipoEntidad__c,
				MasterLabel,
				CS_IntegrationUsername__c,
				CS_IntegrationPassword__c,
				CS_IntegrationSecretKey__c
			FROM CS_MapeoEntidades__mdt
			WITH SECURITY_ENFORCED
		];
		for (CS_MapeoEntidades__mdt mapeoEntidad : mapeosEntidades) {
			mapEntidadTipo.put(mapeoEntidad.CS_Entidad__c, mapeoEntidad.CS_TipoEntidad__c);
			mapEntidadCodigo.put(mapeoEntidad.CS_Entidad__c, mapeoEntidad.CS_CodigoEntidad__c);
			mapEntidadNombre.put(mapeoEntidad.CS_Entidad__c, mapeoEntidad.MasterLabel);
			mapEntidadUsername.put(mapeoEntidad.CS_Entidad__c, mapeoEntidad.CS_IntegrationUsername__c);
			mapEntidadPassword.put(mapeoEntidad.CS_Entidad__c, mapeoEntidad.CS_IntegrationPassword__c);
			mapEntidadSecretKey.put(mapeoEntidad.CS_Entidad__c, mapeoEntidad.CS_IntegrationSecretKey__c);
		}
		System.debug('1. CS_Utilities.loadMapeoEntidadMetadataType mapEntidadTipo: ' + mapEntidadTipo);
		System.debug('2. CS_Utilities.loadMapeoEntidadMetadataType mapEntidadCodigo: ' + mapEntidadCodigo);
		System.debug('3. CS_Utilities.loadMapeoEntidadMetadataType mapEntidadNombre: ' + mapEntidadNombre);
		System.debug('4. CS_Utilities.loadMapeoEntidadMetadataType mapEntidadUsername: ' + mapEntidadUsername);
		System.debug('5. CS_Utilities.loadMapeoEntidadMetadataType mapEntidadNombre: ' + mapEntidadNombre);
		System.debug('6. CS_Utilities.loadMapeoEntidadMetadataType mapEntidadSecretKey: ' + mapEntidadSecretKey);
		System.debug('------------------------------------------------------------------');
	}

	/*--------------------------------------------------------------
	 * Nombre del método: getMapeoEntidadTipoMetadataType
	 * Descripción      : Obtiene todos los mapeos de entidades y sus tipos
	 * @return          : {Map<String, Decimal>} Mapa con las relaciones
	 --------------------------------------------------------------*/
	public static Map<String, Decimal> getMapeoEntidadTipoMetadataType() {
		if (mapEntidadTipo.isEmpty()) {
			loadMapeoEntidadMetadataType();
		}
		return mapEntidadTipo;
	}

	/*--------------------------------------------------------------
	 * Nombre del método: getMapeoEntidadCodigoMetadataType
	 * Descripción      : Obtiene todos los mapeos de entidades y sus códigos
	 * @return          : {Map<String, Decimal>} Mapa con las relaciones
	 --------------------------------------------------------------*/
	public static Map<String, Decimal> getMapeoEntidadCodigoMetadataType() {
		if (mapEntidadCodigo.isEmpty()) {
			loadMapeoEntidadMetadataType();
		}
		return mapEntidadCodigo;
	}

	/*--------------------------------------------------------------
	 * Nombre del método: getMapeoEntidadCodigoMetadataType
	 * Descripción      : Obtiene todos los mapeos de entidades y sus códigos
	 * @return          : {Map<String, String>} Mapa con las relaciones
	 --------------------------------------------------------------*/
	public static Map<String, String> getMapeoEntidadNombreMetadataType() {
		if (mapEntidadNombre.isEmpty()) {
			loadMapeoEntidadMetadataType();
		}
		return mapEntidadNombre;
	}

	/*--------------------------------------------------------------
	 * Nombre del método: getMapeoEntidadTipoMetadataType
	 * Descripción      : Obtiene todos los mapeos de entidades y sus usuarios asignados para integrar
	 * @return          : {Map<String, String>} Mapa con las relaciones
	 --------------------------------------------------------------*/
	public static Map<String, String> getMapeoEntidadUsernameMetadataType() {
		if (mapEntidadUsername.isEmpty()) {
			loadMapeoEntidadMetadataType();
		}
		return mapEntidadUsername;
	}

	/*--------------------------------------------------------------
	 * Nombre del método: getMapeoEntidadCodigoMetadataType
	 * Descripción      : Obtiene todos los mapeos de entidades y sus claves asignados para integrar
	 * @return          : {Map<String, String>} Mapa con las relaciones
	 --------------------------------------------------------------*/
	public static Map<String, String> getMapeoEntidadPasswordMetadataType() {
		if (mapEntidadPassword.isEmpty()) {
			loadMapeoEntidadMetadataType();
		}
		return mapEntidadPassword;
	}

	/*--------------------------------------------------------------
	 * Nombre del método: getMapeoEntidadCodigoMetadataType
	 * Descripción      : Obtiene todos los mapeos de entidades y sus secret key asignadas para integrar
	 * @return          : {Map<String, String>} Mapa con las relaciones
	 --------------------------------------------------------------*/
	public static Map<String, String> getMapeoEntidadSecretKeyMetadataType() {
		if (mapEntidadSecretKey.isEmpty()) {
			loadMapeoEntidadMetadataType();
		}
		return mapEntidadSecretKey;
	}
	//completar ANS de los casos
	public static void completeIndependentMilestone(Id caseId, DateTime complDate,String status) {  
        system.debug('Entro a cmsToUpdate');
        List<CaseMilestone> cmsToUpdate = [select Id, completionDate
                                           from CaseMilestone cm
                                           where caseId =: caseId
                                           and completionDate = null  limit 1];
        
        if (cmsToUpdate.isEmpty() == false){
            
        	system.debug('Entro a cmsToUpdate'+cmsToUpdate);
                cmsToUpdate[0].completionDate = complDate;
            
            update cmsToUpdate;
        }
    }

	/*--------------------------------------------------------------
	 * Nombre del método: extractFileNameToURL
	 * Descripción      : Extraer el nombre de archivo de la URL obtenida del WS SmartSupervision
	 * Ejemplo URL		: https://storage.googleapis.com/unscanned3-sfc-smartsupervision-qa/<CodigoQueja>/<NombreArchivo.png>?Expires=1707858414(...)					
	 * 
	 * @param  url 		: URL obtenida del WS SmartSupervision que contiene el nombre del archivo.
	 * @param regex 	: Expresion regular para extraer el nombre del archivo de acuerdo a la estructura de URL
	 * @return          : Nombre del archivo
	 --------------------------------------------------------------*/
	public static String extractFileNameToURL(String url, String regex) {
		Pattern pattern = Pattern.compile(regex);
		Matcher matcher = pattern.matcher(url);
		if (matcher.find()) {
			return matcher.group(1);
		} else {
			return null; // Handle cases where no filename is found
		}
	}
}