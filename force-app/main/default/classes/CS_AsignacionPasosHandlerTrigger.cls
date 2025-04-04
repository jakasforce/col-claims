/**
 * @description       :
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             :
 * @last modified on  : 07-26-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 **/
public without sharing class CS_AsignacionPasosHandlerTrigger {
    public static void handleTrigger(
        List<CS_AsginacionPasosAtencion__c> TriggerNew,
        List<CS_AsginacionPasosAtencion__c> TriggerOld,
        Map<Id, CS_AsginacionPasosAtencion__c> TriggerOldMap,
        System.TriggerOperation triggerEvent
    ) {
        switch on triggerEvent {
            when AFTER_UPDATE {
                afterUpdate(TriggerNew, TriggerOldMap);
            }
            when AFTER_INSERT {
                afterInsert(TriggerNew);
            }
            when BEFORE_INSERT {
                beforeInsert(TriggerNew);
            }
            when BEFORE_UPDATE {
                beforeUpdate(TriggerNew, TriggerOldMap);
            }
        }
    }
    public static void beforeInsert(List<CS_AsginacionPasosAtencion__c> TriggerNew) {
        //* Consulta de información
        Set<Id> idsPasos = new Set<Id>();
        Set<Id> idsCasos = new Set<Id>();
        for (CS_AsginacionPasosAtencion__c apa : TriggerNew) {
            idsPasos.add(apa.CS_PasoAtencionId__c);
            idsCasos.add(apa.CS_CasoRelacionado__c);
        }

        Map<Id, Id> pasoPersona = new Map<Id, Id>();
        List<CS_PasosAtencion__c> pasosList = [SELECT Id, CS_PersonaAsignada__c FROM CS_PasosAtencion__c WHERE ID IN :idsPasos];
        for (CS_PasosAtencion__c paso : pasosList) {
            pasoPersona.put(paso.Id, paso.CS_PersonaAsignada__c);
        }

        Map<Id, Case> idCasoObjCasoMap = new Map<Id, Case>(
            [
                SELECT
                    Id,
                    (
                        SELECT CS_Tiempo_de_AtencionN__c, CS_PersonaAsignada__c, createddate
                        FROM Asignaciones_pasos_de_atenci_n__r
                        WHERE CS_Estado__c = 'Iniciado'
                        ORDER BY CreatedDate ASC
                        LIMIT 1
                    )
                FROM Case
                WHERE Id = :idsCasos
            ]
        );
        system.debug('idCasoObjCasoMap: ' + idCasoObjCasoMap);

        //* Asignación final de valores
        for (CS_AsginacionPasosAtencion__c apa : TriggerNew) {
            if (apa.CS_AsignacionFlujoSecundario__c == true) {
                //* Buscar el apaEstandar
                Id idCasoRelacionado = apa.CS_CasoRelacionado__c;
                System.debug('idCasoRelacionado: ' + idCasoRelacionado);
                Case casoRelacionado = idCasoObjCasoMap.get(idCasoRelacionado);
                System.debug('casoRelacionado: ' + casoRelacionado.Asignaciones_pasos_de_atenci_n__r.size());
                CS_AsginacionPasosAtencion__c apaEstandar = casoRelacionado.Asignaciones_pasos_de_atenci_n__r;
                System.debug('apaEstandar: ' + apaEstandar);
                apa.CS_Tiempo_de_AtencionN__c = apaEstandar.CS_Tiempo_de_AtencionN__c;

                if (pasoPersona.get(apa.CS_PasoAtencionId__c) != null) {
                    apa.CS_PersonaAsignada__c = pasoPersona.get(apa.CS_PasoAtencionId__c);
                    apa.Asignado__c = true;
                }
            } else if (pasoPersona.get(apa.CS_PasoAtencionId__c) != null) {
                apa.CS_PersonaAsignada__c = pasoPersona.get(apa.CS_PasoAtencionId__c);
                apa.Asignado__c = true;
            }
        }
    }
    public static void beforeUpdate(List<CS_AsginacionPasosAtencion__c> TriggerNew, Map<Id, CS_AsginacionPasosAtencion__c> TriggerOldMap) {
        for (CS_AsginacionPasosAtencion__c apa : TriggerNew) {
            if (
                apa.CS_PersonaAsignada__c != null &&
                TriggerOldMap.get(apa.Id).CS_PersonaAsignada__c == null &&
                TriggerOldMap.get(apa.Id).CS_PersonaAsignada__c != apa.CS_PersonaAsignada__c
            ) {
                apa.Asignado__c = true;
            }
        }
    }
    public static void afterInsert(List<CS_AsginacionPasosAtencion__c> TriggerNew) {
        Map<Id, Decimal> casoTiempoGlobal = new Map<Id, Decimal>();
        Set<Id> casosIds = new Set<Id>();
        Set<Id> casosIdNuevos = new Set<Id>();
        for (CS_AsginacionPasosAtencion__c apa : TriggerNew) {
            if (apa.CS_AsignacionFlujoSecundario__c == false) {
                casosIds.add(apa.CS_CasoRelacionado__c);
                casoTiempoGlobal.put(apa.CS_CasoRelacionado__c, apa.CS_TiempoGlobalDeAtencionN__c);
                if(apa.CS_Estado__c != 'Completado' ){
                    casosIdNuevos.add(apa.CS_CasoRelacionado__c);
                }
            }
        }
        List<Case> casosAAsignar = [SELECT Id, CS_TiempoGlobalAtencion__c FROM Case WHERE Id IN :casosIds];
        for (Case cs : casosAAsignar) {
            cs.CS_TiempoGlobalAtencion__c = casoTiempoGlobal.get(cs.Id);
            if(casosIdNuevos.contains(cs.Id)){
                cs.CS_PasosCompletados__c = false;
            }
        }
        update casosAAsignar;
    } //end afterInsert

    public static void afterUpdate(List<CS_AsginacionPasosAtencion__c> TriggerNew, Map<Id, CS_AsginacionPasosAtencion__c> TriggerOldMap) {
        //Set Id de pasos de los procesos que pasaron a completado
        Set<Id> pasosIds = new Set<Id>();
        //Set Id de casos de los procesos que pasaron a completado
        Set<Id> idsCasos = new Set<Id>();
        //Id del caso + número del paso de asignación
        Map<Id, Integer> casoAsignacionNumero = new Map<Id, Integer>();
        //Id del paso, + nombre del paso
        Map<Id, String> pasoName = new Map<Id, String>();
        //Caso Id, + Id del proceso original del caso
        Map<Id, Id> CasoProceso = new Map<Id, Id>();
        for (CS_AsginacionPasosAtencion__c apa : TriggerNew) {
            if (apa.CS_Estado__c == 'Completado' && TriggerOldMap.get(apa.Id).CS_Estado__c != apa.CS_Estado__c) {
                if(apa.CS_Es_un_paso_de_atencion_adicional__c == false){
                    idsCasos.add(apa.CS_CasoRelacionado__c);
                }
                pasosIds.add(apa.CS_PasoAtencionId__c);
            }
        }
        if (idsCasos.size() > 0) {
            List<CS_AsginacionPasosAtencion__c> procesosListCase = [
                SELECT Id, CS_ProcesoAtencion__c, CS_CasoRelacionado__c,
                CS_Es_un_paso_de_atencion_adicional__c 
                FROM CS_AsginacionPasosAtencion__c
                WHERE CS_CasoRelacionado__c IN :idsCasos
                ORDER BY CreatedDate ASC
            ];
            for (CS_AsginacionPasosAtencion__c asign : procesosListCase) {
                if (!CasoProceso.containsKey(asign.CS_CasoRelacionado__c)) {
                    CasoProceso.put(asign.CS_CasoRelacionado__c, asign.CS_ProcesoAtencion__c);
                }
            }
        }
        Set<Id> idsCasosCompletado = new Set<Id>();
        //Si hay pasosIds (hay procesos que pasaron a completado)
        if (pasosIds.size() > 0) {
            //Lista de los pasos relacionados a los procesos que pasaron a completado
            List<CS_PasosAtencion__c> pasosList = [SELECT Id, Name FROM CS_PasosAtencion__c WHERE Id IN :pasosIds];
            for (CS_PasosAtencion__c paso : pasosList) {
                pasoName.put(paso.Id, paso.Name);
            }
            String nombre = '';
            //recorremos la asignación nuevamente
            for (CS_AsginacionPasosAtencion__c apa : TriggerNew) {
                //tomamos solo los completados
                if (apa.CS_Estado__c == 'Completado' && TriggerOldMap.get(apa.Id).CS_Estado__c != apa.CS_Estado__c) {
                    //asignamoc al nombre el valor del name del paso, con ayuda del mapa
                    nombre = pasoName.get(apa.CS_PasoAtencionId__c);
                    //llenamos el mapa con el nomre del caso, más el número de paso con ayuda del método mid
                    //es decir si es "Paso 2 ---" toma como valor 2
                        System.debug('apa.CS_PasosDeAtencionN__c: ' + apa.CS_PasosDeAtencionN__c);
                        System.debug('nombre: ' + nombre);
                        //System.debug('nombre.mid(5, 1): ' + nombre.mid(5, 1));
                        System.debug('apa.CS_ProcesoAtencion__c: '+ apa.CS_ProcesoAtencion__c);
                        System.debug('CasoProceso.get(apa.CS_CasoRelacionado__c): ' + CasoProceso.get(apa.CS_CasoRelacionado__c));
                        if(apa.CS_Es_un_paso_de_atencion_adicional__c == false){
                            if (
                                Integer.valueOf(apa.CS_PasosDeAtencionN__c) == Integer.valueOf(nombre.mid(5, 1)) &&
                                apa.CS_ProcesoAtencion__c == CasoProceso.get(apa.CS_CasoRelacionado__c)
                            ) {
                                idsCasosCompletado.add(apa.CS_CasoRelacionado__c);
                            }
                            //valida si el proceso inicial relacionado es distinto del proceso que se está completando
                            if (apa.CS_ProcesoAtencion__c != CasoProceso.get(apa.CS_CasoRelacionado__c)) {
                                idsCasos.remove(apa.CS_CasoRelacionado__c);
                            }
                            casoAsignacionNumero.put(apa.CS_CasoRelacionado__c, Integer.valueOf(nombre.mid(5, 1)));
                        } else {
                            idsCasosCompletado.add(apa.CS_CasoRelacionado__c);
                        }   
                }
            }
        }
        if (idsCasosCompletado.size() > 0) {
            List<Case> casosCompletados = [SELECT Id, CS_PasosCompletados__c,(SELECT Id FROM Asignaciones_pasos_de_atenci_n__r WHERE CS_Estado__c != 'Completado') FROM Case WHERE Id IN :idsCasosCompletado];
            for (Case cs : casosCompletados) {
                if(cs.Asignaciones_pasos_de_atenci_n__r.size() == 0){
                    cs.CS_PasosCompletados__c = true;
                }
            }
            update casosCompletados;
        }
        //Si hay casos relacionados
        if (idsCasos.size() > 0) {
            //Consultamos los casos
            List<Case> casosAAsignar = [
                SELECT Id, CS_Subtipo__c, CS_MacroMotivo__c, CS_Submotivo__c, CS_TiempoGlobalAtencion__c, Status, RecordType.DeveloperName
                FROM Case
                WHERE Id IN :idsCasos AND Status != 'Cerrado Atendido' AND Status != 'Cerrado Inactivo'
            ];
            //creamos 3 sets para motivo, subtipo y submotivo
            Set<String> subtipos = new Set<String>();
            Set<String> motivos = new Set<String>();
            Set<String> submotivos = new Set<String>();
            Set<String> CaseDeveloperName = new Set<String>();
            Set<Id> idCasos2 = new Set<Id>();
            if (casosAAsignar.size() > 0) {
                for (Case caso : casosAAsignar) {
                    subtipos.add(caso.CS_Subtipo__c);
                    motivos.add(caso.CS_MacroMotivo__c);
                    submotivos.add(caso.CS_Submotivo__c);
                    CaseDeveloperName.add(caso.RecordType.DeveloperName);
                    idCasos2.add(caso.Id);
                }
                //buscamos las asignaciones relacionadas, que puedan ya existir
                list<CS_AsginacionPasosAtencion__c> listAsignacionRelated = [
                    SELECT Id, CS_CasoRelacionado__c
                    FROM CS_AsginacionPasosAtencion__c
                    WHERE CS_CasoRelacionado__c IN :idCasos2
                ];
                if (listAsignacionRelated.size() > 0) {
                    for (CS_AsginacionPasosAtencion__c asignacion : listAsignacionRelated) {
                        if (idCasos2.contains(asignacion.CS_CasoRelacionado__c)) {
                            idCasos2.remove(asignacion.CS_CasoRelacionado__c);
                        }
                    }
                }

                List<CS_ProcesoAtencion__c> listProcesos = [
                    SELECT Id, Name, CS_Subtipo__c, CS_Submotivo__c, CS_MacroMotivo__c, CS_TiempoGlobalAtencion__c
                    FROM CS_ProcesoAtencion__c
                    WHERE CS_Subtipo__c IN :subtipos AND CS_Submotivo__c IN :submotivos AND CS_MacroMotivo__c IN :motivos AND CS_Tipo_de_caso__c IN :CaseDeveloperName
                ];

                if (listProcesos.size() > 0) {
                    List<CS_PasosAtencion__c> listPasos = [
                        SELECT
                            Id,
                            Name,
                            CS_Tiempoatencion__c,
                            CS_ProcesoAtencion__c,
                            CS_ProcesoAtencion__r.Name,
                            CS_ProcesoAtencion__r.CS_TiempoGlobalAtencion__c,
                            CS_ProcesoAtencion__r.CS_Subtipo__c,
                            CS_ProcesoAtencion__r.CS_Submotivo__c,
                            CS_ProcesoAtencion__r.CS_MacroMotivo__c
                        FROM CS_PasosAtencion__c
                        WHERE CS_ProcesoAtencion__c IN :listProcesos
                    ];

                    if (listPasos.size() > 0) {
                        list<CS_AsginacionPasosAtencion__c> listAsignacion = new List<CS_AsginacionPasosAtencion__c>();
                        Boolean siguiente = false;
                        String nombre2;
                        for (Case caso : casosAAsignar) {
                            for (CS_PasosAtencion__c paso : listPasos) {
                                nombre2 = paso.Name;
                                if (Integer.ValueOf(nombre2.mid(5, 1)) - casoAsignacionNumero.get(caso.Id) == 1) {
                                    if (
                                        caso.CS_Subtipo__c == paso.CS_ProcesoAtencion__r.CS_Subtipo__c &&
                                        caso.CS_MacroMotivo__c == paso.CS_ProcesoAtencion__r.CS_MacroMotivo__c &&
                                        caso.CS_Submotivo__c == paso.CS_ProcesoAtencion__r.CS_Submotivo__c &&
                                        siguiente == false &&
                                        caso.Status != 'Cerrado Atendido' &&
                                        caso.Status != 'Cerrado Inactivo'
                                    ) {
                                        siguiente = true;
                                        caso.CS_TiempoGlobalAtencion__c = paso.CS_ProcesoAtencion__r.CS_TiempoGlobalAtencion__c;
                                        CS_AsginacionPasosAtencion__c asignacion = new CS_AsginacionPasosAtencion__c();
                                        asignacion.CS_CasoRelacionado__c = caso.Id;
                                        asignacion.CS_Estado__c = 'Iniciado';
                                        asignacion.CS_ProcesoAtencion__c = paso.CS_ProcesoAtencion__c;
                                        asignacion.CS_PasoAtencionId__c = paso.Id;
                                        asignacion.CS_AsignacionFlujoSecundario__c = false;
                                        asignacion.Name =  paso.Name;//paso.CS_ProcesoAtencion__r.Name + '-' + paso.Name;
                                        asignacion.CS_Tiempo_de_AtencionN__c = paso.CS_Tiempoatencion__c;
                                        asignacion.CS_TiempoGlobalDeAtencionN__c = paso.CS_ProcesoAtencion__r.CS_TiempoGlobalAtencion__c;
                                        listAsignacion.add(asignacion);
                                    }
                                }
                            }
                            siguiente = false;
                        }
                        if (listAsignacion.size() > 0) {
                            update casosAAsignar;
                            insert listAsignacion;
                        }
                    }
                }
            }
        } //end if ids casos > 0
        
    } // end after update
}