/********************************************************************
Apex Class Name	:	XFLS_ServiceAppointmentTriggerHandler
Version			:	1.0
Created Date	:	16/05/2022
Function 		: 	 --------
Test Class		:	ServiceAppointmentTriggerHandlerTest   --------

Modification Log
*--------------------------------------------------------------------
* Developer		     	Date			   	Description
* -------------------------------------------------------------------
* José Quevedo   	    016/05/2022	        Original Version
* Sayra Martinez        23/05/22            Métodos future para las integraciones 4,5,8
*********************************************************************/
global class XFLS_ServiceAppointmentTriggerHandler {

    static final string ESTADO_RECHAZADA = 'Rechazado';
    static final string ESTADO_ELIMINADA = 'Eliminada';
    static final string ESTADO_SUSPENDIDO = 'Suspendido';
    static final string TIPO_SUSPENCION_TOTAL = 'Total';
    static final string TIPO_SUSPENCION_PARCIAL = 'Parcial';
    static final string ESTADO_SUSPENDIDO_TOTAL = 'Suspendido Total';
    static final string ESTADO_SUSPENDIDO_PARCIAL = 'Suspendido Parcial';

       public static  void handleTrigger(List<ServiceAppointment> TriggerNew, List<ServiceAppointment> TriggerOld,Map<Id, ServiceAppointment> TriggerOldMap, System.TriggerOperation triggerEvent){
       switch on triggerEvent{
           when AFTER_UPDATE{
               afterUpdate(TriggerNew, TriggerOldMap); // Servicios: 4 y 6
           }  
           when BEFORE_INSERT{
               beforeInsert(TriggerNew);
           }
           when AFTER_INSERT{
               afterInsert(TriggerNew);//Servicio 3 y 4
           } 
           when BEFORE_UPDATE{
              beforeUPDATE(TriggerNew, TriggerOldMap);
           } 
       }
    }
	public static void beforeInsert(List<ServiceAppointment> TriggerNew){
        system.debug('TriggerNewTriggerNewTriggerNewXFLS_HorasEjecutadas__c'+TriggerNew[0].XFLS_HorasEjecutadas__c);
            system.debug('TriggerNewTriggerNewTriggerNewXFLS_HorasProgramadas__c'+TriggerNew[0].XFLS_HorasProgramadas__c);
        Set<Id> woliIds = new Set<Id>();
        Map<Id,String> mapWoliIdStatus = new Map<Id,String>();
        Map<Id,Double> mapWoliIdHorasSuspencion = new Map<Id,Double>();
        Map<Id,Double> mapWoliIdHorasFaltantes = new Map<Id,Double>();
        Map<id,String> woliAccEmail = new Map<Id,String>();
        Map<id,String> woliConsEmail = new Map<Id,String>();
           for(ServiceAppointment sa : TriggerNew){
               woliIds.add(sa.ParentRecordId);
           }
        List<WorkOrderLineItem> woliRelated = [Select Id, WorkOrder.Account.PersonEmail, WorkOrder.XFLS_Consultor__r.XFLS_Email__c, Status, 
                                                XFLS_TipoSuspension__c, XFLS_HorasSuspendidas__c, XFLS_TiempoRestante__c  
                                                From WorkOrderLineItem Where ID IN: woliIds];
        
        // Recorrer Ordenes para capturar información de validaciones 
        for(WorkOrderLineItem woli : woliRelated){
            if(woli.WorkOrder.Account.PersonEmail != null){
                woliAccEmail.put(woli.Id,woli.WorkOrder.Account.PersonEmail);
            }
            if(woli.WorkOrder.XFLS_Consultor__r.XFLS_Email__c != null){
                woliConsEmail.put(woli.Id,woli.WorkOrder.XFLS_Consultor__r.XFLS_Email__c);
            }
          system.debug('woli.Status = '+ woli.Status);
             system.debug('woli.XFLS_TipoSuspension__c = '+ woli.XFLS_TipoSuspension__c);
            if (woli.Status == ESTADO_SUSPENDIDO && woli.XFLS_TipoSuspension__c == TIPO_SUSPENCION_TOTAL) {
                mapWoliIdStatus.put(woli.Id,ESTADO_SUSPENDIDO_TOTAL);
            }else if (woli.Status == ESTADO_SUSPENDIDO && woli.XFLS_TipoSuspension__c == TIPO_SUSPENCION_PARCIAL) {
                mapWoliIdStatus.put(woli.Id,ESTADO_SUSPENDIDO_PARCIAL); 
            }else {
                mapWoliIdStatus.put(woli.Id,woli.Status);
            }
            mapWoliIdHorasFaltantes.put(woli.Id,woli.XFLS_TiempoRestante__c);
            mapWoliIdHorasSuspencion.put(woli.Id,woli.XFLS_HorasSuspendidas__c);
        }

        // Recorrer Sesiones de trabajo y aplicar validaciones 
        for(ServiceAppointment sa : TriggerNew){
            if(woliConsEmail.size()>0){
            	sa.XFLS_De__c = woliConsEmail.get(sa.ParentRecordId);
            }
            if(woliAccEmail.size()>0){
            	sa.XFLS_Para__c = woliAccEmail.get(sa.ParentRecordId);
            }
            
            if(mapWoliIdStatus.get(sa.ParentRecordId) == ESTADO_ELIMINADA 
               || (mapWoliIdStatus.get(sa.ParentRecordId) == ESTADO_SUSPENDIDO_TOTAL)
               || mapWoliIdStatus.get(sa.ParentRecordId) == ESTADO_RECHAZADA){
                sa.addError('No se pudo crear la Sesión de trabajo. La orden se encuentra en estado '+mapWoliIdStatus.get(sa.ParentRecordId));
            }else if((mapWoliIdStatus.get(sa.ParentRecordId) == ESTADO_SUSPENDIDO_PARCIAL)){
                // Validar que las horas programadas no superen las horas disponibles en una orden con suspención parcial
                Double horasProgramadas = sa.XFLS_HorasProgramadas__c;
                Double horasSuspencion = mapWoliIdHorasSuspencion.get(sa.ParentRecordId);
                Double horasFaltantes = mapWoliIdHorasFaltantes.get(sa.ParentRecordId);
                if ((horasFaltantes-horasSuspencion) < horasProgramadas) {
                    sa.addError('No se pudo crear la Sesión de trabajo. Las horas programadas superan las horas por ejecutar');                    
                }
            }
        }
    }

    public static void afterInsert(List<ServiceAppointment> TriggerNew){
        System.debug('Entra After Insert');
        System.debug('Entra After InsertTriggerNew'+TriggerNew[0].ParentRecordId);
         System.debug('Entra After InsertTriggerNew'+TriggerNew[0].SchedStartTime);
        System.debug('Entra After InsertTriggerNew'+TriggerNew[0].EarliestStartTime);
        List <Id> saIds = new List <Id>();
        Set <Id> saIdsNews = new Set <Id>();
        List <Id> lstSA = new List <Id>();
        List <Id> lstSAAprobadas = new List <Id>();
        List <Id> lstNew = new List <Id>();
        Set<Id> ParentRecordIds = new Set<Id>();
        for(ServiceAppointment sa : TriggerNew){
            system.debug('sa.SchedStartTime ' +sa.SchedStartTime );
            if(sa.SchedStartTime != null){
            	ParentRecordIds.add(sa.ParentRecordId);
            }
            if(sa.Status == 'Programado'){
                saIds.add(sa.Id);
                System.debug('Programado: '+sa.Id);
            }
            if(sa.Status == 'Ejecutada'){
                System.debug('Ejecutada: '+sa.Id);
                lstSA.add(sa.Id);
            }
            saIdsNews.add(sa.Id);
            System.debug('saIdsNews '+saIdsNews);
            
        }
        List<WorkOrderLineItem> woliList = new  List<WorkOrderLineItem>();
        Map<Id,Id> woliConsultor = new Map<Id,Id>();
        if(ParentRecordIds.size()>0){
        woliList = [Select Id, WorkOrder.XFLS_Consultor__c From WorkOrderLineItem Where Id IN: ParentRecordIds];
            System.debug('woliList '+woliList);
        if(woliList.size()>0){
            for(WorkOrderLineItem woli: woliList){
                woliConsultor.put(woli.Id,woli.WorkOrder.XFLS_Consultor__c);
            }
        }
        System.debug('woliConsultor '+woliConsultor);
        List<AssignedResource> recursosAsignadosList = new List<AssignedResource>();
        for(ServiceAppointment sa : TriggerNew){
            if(woliConsultor.get(sa.ParentRecordId) != null){
                AssignedResource recursoAsignado = new AssignedResource();
                recursoAsignado.ServiceAppointmentId = sa.Id;
                recursoAsignado.ServiceResourceId = woliConsultor.get(sa.ParentRecordId);
     			recursosAsignadosList.add(recursoAsignado);
            }
        }
        System.debug('recursosAsignadosList '+recursosAsignadosList);
        if(recursosAsignadosList.size()>0){
            insert recursosAsignadosList;
        }
    	}
        if(saIdsNews.size() > 0){
            crearSesionesDeTrabajo(saIdsNews);
        }
        
        if(lstSA.size() > 0){
            //radicaSesionesEjecutadas(lstSA); // servicio 6
        }
        if(saIds.size() > 0){
            //radicarOrdenesDeTrabajo(saIds);//servicio 4
        }
    }
   public static void beforeUpdate(List<ServiceAppointment> TriggerNew, Map<Id, ServiceAppointment> TriggerOldMap){
       Set<Id> saEnviadas = new Set<Id>();
       for(ServiceAppointment sa : TriggerNew){
            if((sa.Status == 'En curso') && (sa.Status != TriggerOldMap.get(sa.Id).Status)){
                //sa.ActualStartTime = System.now();
            }
           if((sa.Status == 'Ejecutada') && (sa.Status != TriggerOldMap.get(sa.Id).Status)){
              // sa.ActualEndTime = System.now();
            }
           if((sa.Status == 'Enviada') && (sa.Status != TriggerOldMap.get(sa.Id).Status)){
               saEnviadas.add(sa.Id);
            }
       }
       if(saEnviadas.size()>0){
           List <XFLS_Soporte_Sesion__c> sopSesList = [SELECT Id,XFLS_ContentDocumentLinkId__c,XFLS_Codigo_de_Soporte__c,XFLS_SesionDeTrabajo__c FROM XFLS_Soporte_Sesion__c WHERE XFLS_SesionDeTrabajo__c IN: saEnviadas];
           if(sopSesList.size()>0){
                 Boolean haysoporte = false;
                 for(ServiceAppointment sa : TriggerNew){
                     for(XFLS_Soporte_Sesion__c sop : sopSesList){
                         if(sa.Id == sop.XFLS_SesionDeTrabajo__c){haysoporte = true;
                         }
                     }
                     if(haysoporte == false){sa.addError('no puede enviar una sesión de trabajo, sin antes haber cargados soportes relacionados');
                     }
                     haysoporte = false;
                 }
    
           }
           else{
                for(ServiceAppointment sa : TriggerNew){sa.addError('no puede enviar una sesión de trabajo, sin antes haber cargados soportes relacionados');
                }
           }
       }
   }
    public static void afterUpdate(List<ServiceAppointment> TriggerNew, Map<Id, ServiceAppointment> TriggerOldMap){
        List <Id> lstSA = new List <Id>();
        List <Id> lstSAAprobadas = new List <Id>();
        Set <Id> saIdsNews = new Set <Id>();
        for(ServiceAppointment sa : TriggerNew){
            if((sa.Status == 'Ejecutada') && (sa.Status != TriggerOldMap.get(sa.Id).Status)){
                saIdsNews.add(sa.Id);
            }
            if((sa.Status == 'Enviada') && (sa.Status != TriggerOldMap.get(sa.Id).Status)){
                lstSA.add(sa.Id);
                lstSAAprobadas.add(sa.Id);
            }
            
        }
        
        if(lstSA.size() > 0){
            radicaSesionesEjecutadas(lstSA); // servicio 6
            enviarhistorico(lstSA); // servicio 8
        }
        if(lstSAAprobadas.size() > 0){
            radicarOrdenesDeTrabajo(lstSAAprobadas); //servicio 4            
        }
        if(saIdsNews.size() > 0){
            crearSesionesDeTrabajo(saIdsNews);//servicio 3
        }
    }
    public static void crearSesionesDeTrabajo(Set <Id> saIds){
        for(ServiceAppointment sa : [Select Id,ParentRecordId From ServiceAppointment Where ID IN:saIds]){
              System.debug('sa '+sa);
            llamarCrearSesionesDeTrabajo(SA.ParentRecordId, sa.Id);
        }
    }
    @future(callout=true)
    public static void llamarCrearSesionesDeTrabajo(Id woliId, Id saId){
        System.debug('WO List: '+woliId);
        System.debug('SA List: '+saId);
        
		WorkOrderLineItem woli = [SELECT Id,XFLS_CodigoOS__c,WorkOrderId,XFLS_CodigoAutorizacion__c,
                                  XFLS_FechaAutorizacion__c,XFLS_CodEdoAuto__c,XFLS_EstadoAuto__c,XFLS_ProcesadaInterfaz__c
                                  ,XFLS_FechaProcesadaInt__c,XFLS_CodigoInterfaz__c,XFLS_Tarifa__c,XFLS_TarifaProveedor__c,
                                  XFLS_CodLoteImpre__c,XFLS_FechaEjeIniProv__c,XFLS_FechaInicio__c,XFLS_FechaFin__c
                                  ,XFLS_CodigoUserAutoriza__c,XFLS_NombreUserAutoriza__c,XFLS_FechaRadicacion__c, 
                                  XFLS_ProductoNoConforme__c FROM WorkOrderLineItem WHERE Id =: woliId LIMIT 1];
        System.debug('woli'+woli);
        ServiceAppointment sa = [SELECT Id,ParentRecordId,ActualStartTime,ActualEndTime,XFLS_NumeroAsistentes__c,
                                 ActualDuration,XFLS_CodigoDeSesion__c FROM ServiceAppointment WHERE Id =: saId LIMIT 1];
		System.debug('sa'+sa);
        if(XFLS_IntegracionCreacionSesionesTrabajo.crearSesionesDeTrabajo(woli,sa)){
            System.debug('Creada: '+sa.Id);
        }else{
            System.debug('No creada: '+sa.Id);
        }             
               
    }
    
    @future (callout = true)
    public static void enviarhistorico(List <Id> ServiceAppointmentIds){
        List <XFLS_Soporte_Sesion__c> sopSesList = [SELECT Id,XFLS_ContentDocumentLinkId__c,XFLS_Codigo_de_Soporte__c,
                                                    XFLS_SesionDeTrabajo__c FROM XFLS_Soporte_Sesion__c 
                                                    WHERE XFLS_SesionDeTrabajo__c IN: ServiceAppointmentIds];
        if(sopSesList.size()>0){
            for(XFLS_Soporte_Sesion__c sops : sopSesList){
                XFLS_IntegracionEnvioHistorialInfo.enviarHistorialInformes(sops);
            }
        }
    }
    @future (callout = true)
    public static void radicaSesionesEjecutadas(List <Id> ServiceAppointmentIds){
        System.debug('Servicio 6');
        
        List <ServiceAppointment> objsServiceA = [SELECT Id, ParentRecordId, Status , ParentRecordId__c,
                                                  XFLS_CodigoEstadoPed__c, XFLS_CodigoDeSesion__c FROM ServiceAppointment 
                                                  WHERE Id IN :ServiceAppointmentIds];
        System.debug('LIST SA:'+ objsServiceA);
        // SI (todas las sesiones Status = Aprobada) entonces (Orden de servicio Status = Ejecutada)        
        
        for(ServiceAppointment serviceAppointment :objsServiceA){
            if(XFLS_IntegracionRadicarSesionEjecutada.radicarSesionesDeTrabajo(serviceAppointment)){
                System.debug('Radicada: '+serviceAppointment.Id);
            }else{
                System.debug('No radicada: '+serviceAppointment.Id);
            }    
        }

    }
   /*--------------------------------------------------------------
    * Nombre del método: radicarOrdenesDeTrabajo 
    * Descripción      : Automatización para la clase de radicar ordenes de trabajo
    * @parámetro       : {List <Id>} saIds 
    * @return          : {void} 
    --------------------------------------------------------------*/
    
    @future (callout = true)
    public static void radicarOrdenesDeTrabajo(List <Id> saIds){
        List <ServiceAppointment> objService = [SELECT Id,ParentRecordId,XFLS_CodigoAutorizacion__c,XFLS_Codigo__c,XFLS_CodigoSoporte__c,
                                                XFLS_CodigoEstado__c, XFLS_FechaRegistro__c,XFLS_Mensaje__c,XFLS_Para__c,XFLS_EnvioExitoso__c,XFLS_FechaEnvio__c,XFLS_De__c,
                                                XFLS_Descripcion__c,XFLS_CodigoDeSesion__c
                                                FROM ServiceAppointment 
                                                WHERE Id IN :saIds];
        for(ServiceAppointment sa :objService){
            if(XFLS_RadicarSesionesTrabajoAprobadas.aprobarSesionesDeTrabajo(sa)){
                System.debug('Radicada: '+sa.Id);
            }else{
                System.debug('No radicada: '+sa.Id);
            }    
        }

    }
    
}