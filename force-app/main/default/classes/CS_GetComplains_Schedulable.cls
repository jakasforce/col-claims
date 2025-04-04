/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 07-01-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
global class CS_GetComplains_Schedulable implements Schedulable{
    global void execute(SchedulableContext SC){
        Map<String, Decimal> mapEntidadTipo = CS_Utilities.getMapeoEntidadTipoMetadataType();
        
        for(String apiEntidad: mapEntidadTipo.keySet() ){
            CS_GetUser.getUserFuture(apiEntidad);
            CS_SmartSupervision_Future.getComplainsFuture(apiEntidad);
        }
    }
}