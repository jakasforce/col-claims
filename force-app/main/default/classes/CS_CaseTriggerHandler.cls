/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 03-27-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public without sharing class CS_CaseTriggerHandler {
    
    public static  void handleTrigger(List<Case> TriggerNew, List<Case> TriggerOld,
                                      Map<Id, Case> TriggerOldMap, System.TriggerOperation triggerEvent){
       System.debug('=======este es el trigger event================'+triggerEvent);                                
       switch on triggerEvent{
           when AFTER_UPDATE{
              after(TriggerNew);
           }  
           when AFTER_INSERT{
              after(TriggerNew);
           }
           when BEFORE_INSERT{
            beforeInsert(TriggerNew);
         }  
         when BEFORE_UPDATE{
            beforeUpdate(TriggerNew,TriggerOld);
         }           
       }
           
    }
    public static void beforeInsert(List<Case> TriggerNew){
        System.debug('=======entra a before Insert================');
        String entiId='';
        if(!Test.isRunningTest()){
         //entiId = [select Id from Entitlement where name like '%consulta%'].Id;
        }
        //String slaId = [select Id from SlaProcess where IsActive=true and Name like '%consulta%' order by CreatedDate desc limit 1].Id;
        //Entitlement e = new Entitlement(Id=entiId, SlaProcessId=slaId);
        //update e;
        for(case caso:TriggerNew){
            if(caso.RecordTypeId == Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Consulta').getRecordTypeId()){
                caso.entitlementId = entiId;
            }

        }
        
    }
    public static void beforeUpdate(List<Case> TriggerNew,List<Case> TriggerOld){
        System.debug('=======entra a before update================');
        integer bandera =0;
        for(case caso:TriggerNew){
            System.debug(caso.RecordTypeId);
            System.debug(caso.status);
            if(caso.RecordTypeId == Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Consulta').getRecordTypeId() && (caso.status=='Cerrado Atendido' || caso.status=='Cerrado Inactivo')){
                CS_Utilities.completeIndependentMilestone(caso.id,System.now(),TriggerOld[bandera].status);
            }
            bandera = bandera+1;
        }
        
    }
    public static void after(List<Case> TriggerNew){
        Set<Id> idsCasos = new Set<Id>();
        Set<String> subtipos = new Set<String>();
        Set<String> motivos = new Set<String>();
        Set<String> submotivos = new Set<String>();
        Set<String> tipos = new Set<String>();
        List<Case> casosAAsignar = new List<Case>();
        Set<Id> idsRecordType= new Set<Id>();
        Map<Id, String> mapeoRecType= new Map<Id, String> ();
        for(Case caso : TriggerNew){
            System.debug('dentro 1');
            if(caso.CS_Subtipo__c != null && 
               caso.CS_MacroMotivo__c != null && caso.CS_Submotivo__c != null && 
               caso.Status != 'Cerrado Atendido' && caso.Status != 'Cerrado Inactivo' 
               ){
                idsCasos.add(caso.Id);
                subtipos.add(caso.CS_Subtipo__c);
                motivos.add(caso.CS_MacroMotivo__c);
                submotivos.add(caso.CS_Submotivo__c);
                casosAAsignar.add(caso);
                idsRecordType.add(caso.RecordTypeId);

            }
        }
       
        if(idsCasos.size()>0){
            list<CS_AsginacionPasosAtencion__c> listAsignacionRelated = [Select Id,CS_CasoRelacionado__c
                                                            From CS_AsginacionPasosAtencion__c
                                                            Where CS_CasoRelacionado__c IN:idsCasos
                                                            ];
            if(listAsignacionRelated.size()>0){
                for(CS_AsginacionPasosAtencion__c asignacion :listAsignacionRelated){
                    if(idsCasos.contains(asignacion.CS_CasoRelacionado__c)){
                        idsCasos.remove(asignacion.CS_CasoRelacionado__c);
                    }
                }
            }
        }
        
        if(idsCasos.size()>0){
            
        List<RecordType> recTypeLst=[SELECT Id, DeveloperName FROM RecordType WHERE ID IN :idsRecordType];
        for(RecordType recType:recTypeLst){
            tipos.add(recType.DeveloperName);
            mapeoRecType.put(recType.Id,recType.DeveloperName);
        }
            
        List<CS_ProcesoAtencion__c> listProcesos = [Select Id,Name,
                                                    CS_Subtipo__c,CS_Submotivo__c,CS_MacroMotivo__c,
                                                    CS_TiempoGlobalAtencion__c
                                                    From CS_ProcesoAtencion__c
                                                    Where CS_Subtipo__c IN: subtipos AND
                                                    CS_Submotivo__c IN: submotivos AND
                                                    CS_MacroMotivo__c IN:motivos AND
                                                    CS_Tipo_de_caso__c IN:tipos];

            if(listProcesos.size()>0){
                List<CS_PasosAtencion__c> listPasos = [Select Id, Name,CS_Tiempoatencion__c,
                                                        CS_ProcesoAtencion__c,
                                                        CS_ProcesoAtencion__r.Name,
                                                        CS_ProcesoAtencion__r.CS_Subtipo__c,
                                                        CS_ProcesoAtencion__r.CS_Submotivo__c,
                                                        CS_ProcesoAtencion__r.CS_MacroMotivo__c,
                                                        CS_ProcesoAtencion__r.CS_TiempoGlobalAtencion__c,
                                                        CS_ProcesoAtencion__r.CS_Tipo_de_caso__c
                                                        From CS_PasosAtencion__c
                                                        Where CS_ProcesoAtencion__c IN: listProcesos];

                if(listPasos.size()>0){
                    list<CS_AsginacionPasosAtencion__c> listAsignacion = new List<CS_AsginacionPasosAtencion__c>();
                    Boolean primero = false;
                    String nombre;
                    for(Case caso : casosAAsignar){
                        
                        if( idsCasos.contains(caso.Id) ){
                            	for(CS_PasosAtencion__c paso: listPasos){
                           
                            if(mapeoRecType.get(caso.RecordTypeId)==paso.CS_ProcesoAtencion__r.CS_Tipo_de_caso__c &&
                               caso.CS_Subtipo__c == paso.CS_ProcesoAtencion__r.CS_Subtipo__c &&
                               caso.CS_MacroMotivo__c == paso.CS_ProcesoAtencion__r.CS_MacroMotivo__c &&
                               caso.CS_Submotivo__c == paso.CS_ProcesoAtencion__r.CS_Submotivo__c && primero == false ){
                                nombre = paso.Name ; 
                                   
                                if(Integer.valueOf(nombre.mid(5,1)) == 1){
                                    
                                    primero = true;
                                    CS_AsginacionPasosAtencion__c asignacion = new CS_AsginacionPasosAtencion__c();
                                    asignacion.CS_CasoRelacionado__c = caso.Id;
                                    asignacion.CS_Estado__c = 'Iniciado';
                                    asignacion.CS_ProcesoAtencion__c = paso.CS_ProcesoAtencion__c;
                                    asignacion.CS_PasoAtencionId__c = paso.Id;
                                    asignacion.CS_AsignacionFlujoSecundario__c = false;
                                    asignacion.Name = paso.Name;//paso.CS_ProcesoAtencion__r.Name + '-' +paso.Name;
                                    asignacion.CS_Es_un_paso_de_atencion_adicional__c = false;
                                    asignacion.CS_Tiempo_de_AtencionN__c = paso.CS_Tiempoatencion__c;
                                    asignacion.CS_TiempoGlobalDeAtencionN__c = paso.CS_ProcesoAtencion__r.CS_TiempoGlobalAtencion__c;
                                    listAsignacion.add(asignacion);
                                }
                            }
                        }
                        primero = false;
                        }
                        
                    }
                    if(listAsignacion.size()>0){

                        insert listAsignacion;
                    }                    
                }
            }
        }
    }
}