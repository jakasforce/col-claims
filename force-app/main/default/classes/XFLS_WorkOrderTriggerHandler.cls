/********************************************************************
Apex Class Name	:	XFLS_WorkOrderTriggerHandler
Version			:	1.0
Created Date	:	16/05/2022
Function 		: 	Clase Handler del objeto Orden de Trabajo
Test Class		:	XFLS_WorkOrderTriggerTest   --------

Modification Log
*--------------------------------------------------------------------
* Developer		     	Date			   	Description
* -------------------------------------------------------------------
* Luis Sandoval   	 16/05/2022	        Original Version
* Sayra Martinez     23/05/22           Métodos future para la integración 2
*********************************************************************/
public without sharing class XFLS_WorkOrderTriggerHandler {
    public static  void handleTrigger(List<WorkOrder> TriggerNew, List<WorkOrder> TriggerOld,
                                      Map<Id, WorkOrder> TriggerOldMap, System.TriggerOperation triggerEvent){
       switch on triggerEvent{
            when BEFORE_INSERT{
                beforeInsert(TriggerNew);
            } 
            when BEFORE_UPDATE{
              beforeUpdate(TriggerNew, TriggerOldMap);
            }     
       }
           
    }
    public static void beforeUpdate(List<WorkOrder> TriggerNew, Map<Id, WorkOrder> TriggerOldMap){
        Set<String> consultorCodigo = new Set<String>();
        Set<String> consultorId = new Set<String>();
        Map<Id,String> mapConsultorIdCodigo = new Map<Id,String>();
        Map<String,Id> mapConsultorCodigoId = new Map<String,Id>();

        for(WorkOrder wo : TriggerNew){
            if((wo.XFLS_CedulaConsultor__c != null) && (wo.XFLS_CedulaConsultor__c != TriggerOldMap.get(wo.Id).XFLS_CedulaConsultor__c)){
            consultorCodigo.add(wo.XFLS_CedulaConsultor__c);
            }
            
            if ((wo.XFLS_Consultor__c != null) && (wo.XFLS_Consultor__c != TriggerOldMap.get(wo.Id).XFLS_Consultor__c)) {
                consultorId.add(wo.XFLS_Consultor__c);
            }
        }
        
        if(consultorCodigo.size()>0){
            List<ServiceResource> listConsultores1 = new List<ServiceResource>();
            listConsultores1 = [Select Id, XFLS_Document__c From ServiceResource Where XFLS_Document__c IN :consultorCodigo];
            if(listConsultores1.size()>0){
                for(ServiceResource sr : listConsultores1){
                    mapConsultorCodigoId.put(sr.XFLS_Document__c,sr.Id);
                }
                for(WorkOrder wo : TriggerNew){
                    wo.XFLS_Consultor__c = mapConsultorCodigoId.get(wo.XFLS_CedulaConsultor__c);
                }
            }
        }
        if(consultorId.size()>0){
            List<ServiceResource> listConsultores2 = new List<ServiceResource>();            
            listConsultores2 = [Select Id, XFLS_Document__c From ServiceResource Where Id IN :consultorId];
            if(listConsultores2.size()>0){
                for(ServiceResource sr : listConsultores2){
                    mapConsultorIdCodigo.put(sr.Id,sr.XFLS_Document__c);
                }
                for(WorkOrder wo : TriggerNew){
                    wo.XFLS_CedulaConsultor__c = mapConsultorIdCodigo.get(wo.XFLS_Consultor__c);
                }
            }
        }
    }

    public static void beforeInsert(List<WorkOrder> TriggerNew){
        Set<String> consultorCodigo = new Set<String>();
        Map<String,Id> mapConsultorCodigoId = new Map<String,Id>();
        for(WorkOrder wo : TriggerNew){
            if(wo.XFLS_CedulaConsultor__c != null && wo.XFLS_Consultor__c == null){
            	consultorCodigo.add(wo.XFLS_CedulaConsultor__c);
            }
            if(wo.XFLS_CedulaConsultor__c == null && wo.XFLS_Consultor__c != null){
                wo.XFLS_CedulaConsultor__c  = wo.XFLS_Consultor__r.XFLS_Document__C;
            }
             
        } 
        if(consultorCodigo.size()>0){
            List<ServiceResource> listConsultores = new List<ServiceResource>();

            listConsultores = [Select Id, XFLS_Document__c From ServiceResource Where XFLS_Document__c IN: consultorCodigo];
            if(listConsultores.size()>0){
                for(ServiceResource sr : listConsultores){
                    mapConsultorCodigoId.put(sr.XFLS_Document__c,sr.Id);
                }
                for(WorkOrder wo : TriggerNew){
                    wo.XFLS_Consultor__c = mapConsultorCodigoId.get(wo.XFLS_CedulaConsultor__c);
                }
            }
   
        }
    }
    
    
}