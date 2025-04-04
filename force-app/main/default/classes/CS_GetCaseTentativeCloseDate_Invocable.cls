/*****************************************************************************************************************************
 * Apex Class Name	:	CS_SetCaseTentativeCloseDate_Invocable
 * Version			:	1.0
 * Created Date	    :	124/05/2022
 * Function 		: 	Clase con el método invocables utilizado por el flow Case After Update
 * Test Class		:	???
 *----------------------------------------------------------------------------------------------------------------------------
 *                                                MODIFICATION LOG
 *----------------------------------------------------------------------------------------------------------------------------
 * Developer		     	Date			   	Description
 * ---------------------------------------------------------------------------------------------------------------------------
 * Angel Cabezas            24/05/2022          Original Version
 *****************************************************************************************************************************/
global without sharing class CS_GetCaseTentativeCloseDate_Invocable {
	@InvocableMethod(
		label='Funcionalidades Caso: Calcular fecha tentativa de cierre.'
		description='Calcula la fecha tentativa de cierre para los casos relacionados a un proceso de Atención.'
		category='CS_ProcesoAtencion__c'
	)
	global static void calcularFechaTentativaCierreCasos(List<Requests> requestList) {
		System.debug('--------------  CS_GetCaseTentativeCloseDate_Invocable.calcularFechaTentativaCierreCasos --------------');
		System.debug('1.1 CS_GetCaseTentativeCloseDate_Invocable.calcularFechaTentativaCierreCasos requestList: ' + requestList);
		System.debug('1.2 CS_GetCaseTentativeCloseDate_Invocable.calcularFechaTentativaCierreCasos requestList.size(): ' + requestList.size());

		List<Case> casosActualizar = new List<Case>();
		for (Requests request : requestList) {
			Case casoActual = request.caso;
			Integer diasParaCierre = request.diasParaCierre;
			Datetime fechaCreacion = casoActual.CS_FechaCreacion__c != null ? casoActual.CS_FechaCreacion__c : casoActual.CreatedDate;
			Date fechaGMT = fechaCreacion.dateGMT();
			if(request.esProrroga != null && request.esProrroga && casoActual.CS_FechaTentativaDeCierre__c != null){
				casoActual.CS_FechaTentativaDeCierre__c = CS_Utilities.getDateAfterWorkingDays(casoActual.CS_FechaTentativaDeCierre__c, Integer.valueOf(casoActual.CS_Prorroga__c));
			}else if(request.esProrroga == null || !request.esProrroga){
				casoActual.CS_FechaTentativaDeCierre__c = CS_Utilities.getDateAfterWorkingDays(fechaGMT, diasParaCierre);
			}
			casosActualizar.add(casoActual);
		}
		update casosActualizar;
	}

	global class Requests {
		@InvocableVariable(label='Caso a actualizar' description='Caso relacionado al proceso.' required=true)
		public Case caso;
		@InvocableVariable(label='Dias hábiles' description='Días habiles esperados para cierre del Caso.' required=true)
		public Integer diasParaCierre;
		@InvocableVariable(label='Es prórroga' description='El caso es una prórroga' required=false)
		public Boolean esProrroga;
	}
}