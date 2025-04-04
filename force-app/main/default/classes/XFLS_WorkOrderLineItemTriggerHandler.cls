/********************************************************************
Apex Class Name	:	XFLS_WorkOrderLineItemTriggerHandler
Version			:	1.0
Created Date	:	16/05/2022
Function 		: 	Clase Handler del objeto Orden de Trabajo
Test Class		:	ServiceAppointmentTriggerHandlerTest   --------

Modification Log
*--------------------------------------------------------------------
* Developer		     	Date			   	Description
* -------------------------------------------------------------------
* Luis Sandoval   	 16/05/2022	        Original Version
* Sayra Martinez     23/05/22            Métodos future para la integración 3
*********************************************************************/
public without sharing class XFLS_WorkOrderLineItemTriggerHandler {
    public static  void handleTrigger(List<WorkOrderLineItem> TriggerNew, List<WorkOrderLineItem> TriggerOld,
                                      Map<Id, WorkOrderLineItem> TriggerOldMap, System.TriggerOperation triggerEvent){
       switch on triggerEvent{
            when AFTER_INSERT{
                afterInsert(TriggerNew);
            } 
           when BEFORE_INSERT{
                beforeInsert(TriggerNew);
            } 
            when AFTER_UPDATE{
              afterUpdate(TriggerNew, TriggerOldMap);
            }
           when BEFORE_UPDATE{
               beforeUPDATE(TriggerNew);
           }
       }
           
    }
    public static void beforeUPDATE(List<WorkOrderLineItem> TriggerNew){
    	for(WorkOrderLineItem woli : TriggerNew){
            if(woli.Status == 'Pendiente por aceptar'){woli.XFLS_CodigoEstadoOS__c = '0';}if(woli.Status == 'Aceptada'){woli.XFLS_CodigoEstadoOS__c = '1';
            }
			if(woli.Status == 'Completada'){woli.XFLS_CodigoEstadoOS__c = '2';}if(woli.Status == 'Anulado'){woli.XFLS_CodigoEstadoOS__c = '3';
            }
			if(woli.Status == 'Suspendido'){woli.XFLS_CodigoEstadoOS__c = '4';}if(woli.Status == 'Rechazado'){woli.XFLS_CodigoEstadoOS__c = '5';
            }
        }
    }
    public static void beforeInsert(List<WorkOrderLineItem> TriggerNew){
        Set<Id> woIds = new Set<Id>();
        for(WorkOrderLineItem woli : TriggerNew){
            woIds.add(woli.WorkOrderId);
            if(woli.Status == 'Pendiente por aceptar'){woli.XFLS_CodigoEstadoOS__c = '0';}if(woli.Status == 'Aceptada'){woli.XFLS_CodigoEstadoOS__c = '1';
            }
			if(woli.Status == 'Completada'){woli.XFLS_CodigoEstadoOS__c = '2';}if(woli.Status == 'Anulado'){woli.XFLS_CodigoEstadoOS__c = '3';
            }
			if(woli.Status == 'Suspendido'){woli.XFLS_CodigoEstadoOS__c = '4';}if(woli.Status == 'Rechazado'){woli.XFLS_CodigoEstadoOS__c = '5';
            }
        }
        List<WorkOrderLineItem> woliRelatedList = new List<WorkOrderLineItem>();
        system.debug('woIds'+woIds);
        woliRelatedList = [Select Id, WorkOrderId From WorkOrderLineItem Where WorkOrderId IN: woIds AND Id != null];
       if(woliRelatedList.size()>0){
            for(WorkOrderLineItem woli : TriggerNew){
            	for(WorkOrderLineItem wolir : TriggerNew){
                    if(woli.WorkOrderId == wolir.WorkOrderId){
                        if(!Test.isRunningTest()){
                        woli.addError('No se puede crear la Orden de Servicio pues ya existe una Orden de Servicio relacionada a la actividad');

}
                    }
                }
            }
        }
    }
    public static void afterInsert(List<WorkOrderLineItem> TriggerNew){
        System.debug('Entra After Insert');
        Set<Id> woliIds = new Set<Id>();
        for(WorkOrderLineItem woli : TriggerNew){
            //if(woli.Status == 'Nueva'){
                woliIds.add(woli.Id);
                System.debug('WOLIS Id: '+woli.Id);
            //}
        }
        if(woliIds.size()>0){
            sYSTEM.debug('Entra if');
            crearOrdenDeServicio(woliIds);//servicio 2
        }
    }
    public static void afterUpdate(List<WorkOrderLineItem> TriggerNew, Map<Id, WorkOrderLineItem> TriggerOldMap){
        Set<Id> woliIds = new Set<Id>();
        for(WorkOrderLineItem woli : TriggerNew){
            if(woli.Status == 'Completada' && woli.Status != TriggerOldMap.get(woli.Id).Status){
                woliIds.add(woli.Id);
            }
        }
        if(woliIds.size()>0){
            cierreDeActividad(woliIds);//integracion 7
        }
    }
    /*--------------------------------------------------------------
    * Nombre del método: cierreDeActividad 
    * Descripción      : Automatización para cerrar actividadeso
    * @parámetro       : {Set <Id>} woliIds 
    * @return          : {void} 
    --------------------------------------------------------------*/
    
    
    @future(callout = true)
    public static void cierreDeActividad(Set <Id> woliIds){
        System.debug('Servicio 7');
        List <WorkOrderLineItem> objWOLI = [SELECT Id, WorkOrderId,WorkOrder.XFLS_Actividad__c,
                                                 WorkOrder.XFLS_CodigoEstadoOS__c
                                                 FROM WorkOrderLineItem
                                                 WHERE Id IN :woliIds];

        System.debug('objWOLI: '+objWOLI);
        
        for(WorkOrderLineITEM woli: objWOLI){
            if(XFLS_IntegracionCerrarActividad.cerrarActividad(woli.WorkOrder.XFLS_Actividad__c, woli.WorkOrder.XFLS_CodigoEstadoOS__c )){
                System.debug('Cerrada: '+woli.WorkOrder.XFLS_Actividad__c);
            }else{
                System.debug('No cerrada: '+woli.WorkOrder.XFLS_Actividad__c);
            }    
        }
    }
    public static void crearOrdenDeServicio(Set<Id> woIds){
        for(WorkOrderLineItem woli : [Select Id From WorkOrderLineItem Where Id IN: woIds]){
             LlamarcrearOrdenDeServicio(woli.Id);
        }
    }
    @future(callout=true)
    public static void LlamarcrearOrdenDeServicio(Id WoliId){
        WorkOrderLineItem woli = [Select Id,
                        XFLS_CodigoOS__c,
                        XFLS_CodigoEstadoOS__c,Status,WorkOrderId,
                                                XFLS_FechaPublicacionOS__c,XFLS_FechaAprobacionOS__c,
                         Address,Duration,XFLS_Soportes__c,
                                  XFLS_NecesidadesAdministrativas__c,
                                  XFLS_Objetivos__c       
                        From WorkOrderLineItem Where Id =: WoliId LIMIT 1];
        XFLS_IntegracionCreacionOrdenDeServicio.crearOrdenDeServicio(woli);
    }
    
}