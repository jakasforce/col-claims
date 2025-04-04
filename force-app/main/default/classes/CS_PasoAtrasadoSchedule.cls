public class CS_PasoAtrasadoSchedule implements Schedulable {
    public void execute(SchedulableContext ctx) {
        List<CS_AsginacionPasosAtencion__c> asignacionList = [SELECT Id,CS_CasoRelacionado__c
            FROM CS_AsginacionPasosAtencion__c
            WHERE CS_Estado__c != 'Completado' AND
            CS_TiempoRestante__c <= 0];
        Set<Id> casoIds = new Set<Id>();
        if(asignacionList.size()>0){
            for(CS_AsginacionPasosAtencion__c asign : asignacionList){
                casoIds.add(asign.CS_CasoRelacionado__c);
            }
            List<Case> casosList = [Select Id,CS_PasoAtrasado__c 
                                    From Case 
                                    Where Id IN: casoIds
                                    AND CS_PasoAtrasado__c =: false];
            if(casosList.size()>0){
                for(Case caso: casosList){
                    caso.CS_PasoAtrasado__c = true;
                }
                Database.SaveResult[] srList = Database.update(casosList, false);
            }
        }
        
        
    }

}