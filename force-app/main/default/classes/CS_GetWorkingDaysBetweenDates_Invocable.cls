/**
 * @description       :
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             :
 * @last modified on  : 10-25-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 **/
public with sharing class CS_GetWorkingDaysBetweenDates_Invocable {
	@InvocableMethod(label='Obtener días hábiles entre fechas' description='Retorna los días hábiles entre dos fechas.' category='Case')
	public static List<Results> getWorkingDaysBetweenDates(List<Requests> requestList) {
		List<Results> results = new List<Results>();
		for (Requests request : requestList) {
			Results result = new Results();
			result.cantidadDias = CS_Utilities.getWorkingDaysBetweenDates(request.initialDate, request.finalDate);
			results.add(result);
		}
		return results;
	}

	public class Requests {
		@InvocableVariable(label='Fecha inicial' description='Fecha inicial del intervalo.' required=true)
		public Date initialDate;

		@InvocableVariable(label='Fecha final' description='Fecha final del intervalo.' required=true)
		public Date finalDate;
	}

	public class Results {
		@InvocableVariable(label='Cantidad de días' description='Días hábiles entre las fehcas' required=true)
		public Integer cantidadDias;
	}
}