public without sharing class XFLS_AssignedResourceTriggerHandler {
    public static  void handleTrigger(List<AssignedResource> TriggerNew, List<AssignedResource> TriggerOld,
                                      Map<Id, AssignedResource> TriggerOldMap, System.TriggerOperation triggerEvent){
       switch on triggerEvent{
            when BEFORE_INSERT{
                beforeInsert(TriggerNew);
            } 
           
       }
   }
   public static void beforeInsert(List<AssignedResource> TriggerNew){
        Map<Id,Id> woliConsultor = new Map<Id,Id>();
        Map<Id,Id> saIdParentRecordId = new Map<Id,Id>();
       Set<Id> ParentRecordIds = new Set<Id>();
       Set<Id> saIds = new SET<Id>();
        for(AssignedResource ares : TriggerNew){
            saIds.add(ares.ServiceAppointmentId);
        }
       System.debug('saIds '+saIds);
       for(ServiceAppointment sa : [Select Id, ParentRecordId From ServiceAppointment Where Id IN: saIds]){
           ParentRecordIds.add(sa.ParentRecordId);
           saIdParentRecordId.put(sa.Id, sa.ParentRecordId);
       }
        List<WorkOrderLineItem> woliList = new  List<WorkOrderLineItem>();
        woliList = [Select Id, WorkOrder.XFLS_Consultor__c From WorkOrderLineItem Where Id IN: ParentRecordIds];
        if(woliList.size()>0){
            for(WorkOrderLineItem woli: woliList){
                woliConsultor.put(woli.Id,woli.WorkOrder.XFLS_Consultor__c);
            }
        }
               for(AssignedResource ares : TriggerNew){
                   if( woliConsultor.get(saIdParentRecordId.get(ares.ServiceAppointmentId)) != null){
                   		ares.ServiceResourceId = woliConsultor.get(saIdParentRecordId.get(ares.ServiceAppointmentId));
                   }
               }


   }
      
}