/********************************************************************
Apex Class Name:	InsurancePolicyParticipantTriggerHandler
Version			:	1.0
Created Date	:	20/09/2023
Function 		: 	Trigger Handler Class
Class Test      :   InsurancePolicyParticipantTest

Modification Log
*--------------------------------------------------------------------
* Developer		     	Date			   	Description
* -------------------------------------------------------------------
* Alejandro Giraldo   	 20/09/2023       Original Version
*********************************************************************/
public class InsurancePolicyParticipantTriggerHandler {
  public static  void handleTrigger(List<InsurancePolicyParticipant> TriggerNew, List<InsurancePolicyParticipant> TriggerOld,Map<Id, InsurancePolicyParticipant> TriggerOldMap, System.TriggerOperation triggerEvent){
       switch on triggerEvent{
           when AFTER_UPDATE{
               afterUpdate(TriggerNew, TriggerOldMap);
           }  
           
           when AFTER_INSERT{
               afterInsert(TriggerNew);
           } 
           
       }
    }
    public static void afterInsert(List<InsurancePolicyParticipant> TriggerNew){
         boolean RLpolicy= false;
        boolean SVpolicy = false;
        string variable;
        List<Id> policyIds = new List<Id>();
        List<Id> AccIds = new List<Id>();
        Map <id, String> AccIdsAndComp = new Map <id, String>();
        Map <id, String> DevNameTypes = new Map <id, String>();
        Map <id, String> DevNameTypesPart = new Map <id, String>();
        Map <id, String> idsAccPoliPart = new Map <id, String>();
        List<InsurancePolicyParticipant> ListInsurancePolicyParticipant;
        List<InsurancePolicyParticipant> ListInsurancePolicyParticipantAct ; 
        List<InsurancePolicy> ListInsurancePolicytAct ; 
        List<InsurancePolicy> ListInsurancePolicy;
         for(InsurancePolicyParticipant insPo1 : TriggerNew){
          // SE ALMACENAN TODOS LOS IDS DE CUENTAS EN LA LISTA policyIds
            policyIds.add(insPo1.PrimaryParticipantAccountId);
        }
        for(InsurancePolicyParticipant insPo : TriggerNew){
            system.debug('PrimaryParticipantAccountId = ' + insPo.PrimaryParticipantAccountId);
             // SOLO SI EL PARTICIPANTE DE LA POLIZA TIENE UNA CUENTA ASOCIADA ENTRA A ESTE FLUJO
            if(insPo.PrimaryParticipantAccountId != null){
                system.debug('dentro del if particimante');
                  // SI LA LISTA ES VACIA SE REALIZA LA CONSULTA DE LOS PARTICIPANTES QUE HACEN PARTE DE TODA LA LISTA DE CUETNAS

                if(ListInsurancePolicyParticipant == null){
                    ListInsurancePolicyParticipant= [Select Id,InsurancePolicyId,RecordTypeId,RecordType.DeveloperName,PrimaryParticipantAccountId
                                                From InsurancePolicyParticipant Where PrimaryParticipantAccountId in :policyIds  and InsurancePolicy.isactive = true];
                }
               
                
               for (integer t = 0; t < ListInsurancePolicyParticipant.size() ;t++){
                    // SE RECORRE TODAS LOS PARTICIPANTES DE LAS POLIZAS QUE ESTAN ASOCIADOS A LA CUENTA ACTUAL DE LA POLIZA EN EL FOR
                    if(ListInsurancePolicyParticipant[t].PrimaryParticipantAccountId ==insPo.PrimaryParticipantAccountId){
                     if(ListInsurancePolicyParticipant[t].RecordType.DeveloperName == 'CS_Asegurado'){
                        SVpolicy = TRUE;
                    }
                   if (ListInsurancePolicyParticipant[t].RecordType.DeveloperName == 'CS_Trabajador'){
                        RLpolicy = true;
                    }
                    }
                }
                // SI LA LISTA ES VACIA SE REALIZA LA CONSULTAN LAS POLIZAS QUE HACEN PARTE DE TODA LA LISTA DE CUETNAS

                if(ListInsurancePolicy == null){
                     ListInsurancePolicy= [Select Id,RecordTypeId,RecordType.DeveloperName,NameInsuredId
                                                From InsurancePolicy Where NameInsuredId  in :policyIds and isactive = true];
                }

                

               for (integer u = 0; u < ListInsurancePolicy.size() ;u++){
                    // SE RECORRE TODAS LAS POLIZAS QUE ESTAN ASOCIADOS A LA CUENTA ACTUAL DE LA POLIZA EN EL FOR
                    if(ListInsurancePolicy[u].NameInsuredId ==insPo.PrimaryParticipantAccountId){
                     if(ListInsurancePolicy[u].RecordType.DeveloperName== 'CS_Seguro_de_vida'){
                     SVpolicy = TRUE;
                }
                 if(ListInsurancePolicy[u].RecordType.DeveloperName == 'CS_Contrato_ARL'){
                     RLpolicy = true;
                }
                    }
                }
               // DEPENDIENDO DE LOS PROCESOS ANTERIORES SE LE ASIGNA UN VALOR A LA VARIABLE 'VARIABLE'
        if (SVpolicy== true && RLpolicy== false){
            //Seguros de vida
            variable = 'Colmena Seguros de Vida';
            
        }
        else if (SVpolicy== false && RLpolicy== true){
            // ARL
              variable = 'Colmena Riesgos Laborales';
        }
        else if (SVpolicy== false && RLpolicy== false){
            //NINGUNO
              variable = 'Ninguno';
        }
        else if (SVpolicy== true && RLpolicy== true){
            //MIXTO
              variable = 'Mixto';
        }
// SE VUELVE A DEJAR EN FALSE LAS VARIABLES DE TIPO BOOL PARA QUE INICIE EL PROCESO NUEVAMENTE SIN INCONVENIENTES       
         RLpolicy= false;
         SVpolicy = false;
                system.debug('valor variable = ' + variable );
                // SE AGREGA EL ID DE LA CUENTA ACTUAL EN UNA LISTA
              AccIds.add(insPo.PrimaryParticipantAccountId);
                // SE AGREGA EL ID DE LA CUENTA EN UN MAPA CON EL VALOR DE LA VARIABLE LA CUAL SERA ASIGNADA MAS ADELANTE
              AccIdsAndComp.put(insPo.PrimaryParticipantAccountId,variable);
             
             
                         
               
            }
              
           }
         // SE CONSULTAN LAS CUENTAS CON RESPECTO A LA LISTA DE CUENTAS QUE SE TUVIERON PRESENTES EN EL ANTERIOR PROCESO
         List<account> accountUpdate= [Select Id,ACC_Empresa_cliente__c
                                                From account Where id in :AccIds];
        // SE RECORRE TODAS LAS  CUENTAS CONSULTADAS Y SE LES ALMACENA EN VALOR DE LA VARIABLE ANTERIOR EN EL CAMPO ACC_Empresa_cliente__c

        for (integer h = 0; h < accountUpdate.size() ;h++){
                      
                 accountUpdate[h].ACC_Empresa_cliente__c =AccIdsAndComp.get(accountUpdate[h].id);
                
            
        }
        update accountUpdate;
    }
    public static void afterUpdate(List<InsurancePolicyParticipant> TriggerNew, Map<Id, InsurancePolicyParticipant> TriggerOldMap){
       boolean RLpolicy= false;
        boolean SVpolicy = false;
        string variable;
          boolean SVpolicyOld = false;
        boolean RLpolicyOld = false;
        string variableOld;   
        List<Id> policyIds = new List<Id>();
        Map <id, String> DevNameTypes = new Map <id, String>();
         List<Id> AccIds = new List<Id>();
        Map <id, String> AccIdsAndComp = new Map <id, String>();
         List<InsurancePolicyParticipant> ListInsurancePolicyParticipant;
        List<InsurancePolicyParticipant> ListInsurancePolicyParticipantAct ; 
        List<InsurancePolicy> ListInsurancePolicytAct ; 
        List<InsurancePolicy> ListInsurancePolicy;
           for(InsurancePolicyParticipant insPo1 : TriggerNew){
          // SE ALMACENAN TODOS LOS IDS DE CUENTAS EN LA LISTA policyIds
            policyIds.add(insPo1.PrimaryParticipantAccountId);
        }
        for(InsurancePolicyParticipant sa : TriggerNew){
            system.debug('sa.RecordType.DeveloperName'+sa.RecordType.DeveloperName);
            system.debug('TriggerOldMap.get(sa.Id).RecordType.DeveloperName'+TriggerOldMap.get(sa.Id).RecordType.DeveloperName);
           // SE CREA ESTE IF PARA QUE SOLO SE REALICEN ESTOS PROCESOS CUANDO SE CAMBIA EL TIPO DE REGISTRO DEL PARTICIPANTE DE LA POLIZA
            if ((sa.RecordTypeId != TriggerOldMap.get(sa.Id).RecordTypeId)  ||
                ((sa.PrimaryParticipantAccountId != TriggerOldMap.get(sa.Id).PrimaryParticipantAccountId)&& sa.PrimaryParticipantAccountId != null) ){
                    
                 

   // SI SE ACTUALIZA UNA POLIZA QUE TENIA UNA CUENTA ASOCIADA Y SE LE DA UN NUEVO VALOR A ESTE CAMPO
                   //  SE VALIDA NUEVAMENTE EL CAMPO 'EMPRESA' PARA LA CUENTA ANTERIOR DE LA POLIZA
                    
                    if(((sa.PrimaryParticipantAccountId != TriggerOldMap.get(sa.Id).PrimaryParticipantAccountId)
                        && sa.PrimaryParticipantAccountId   != null && TriggerOldMap.get(sa.Id).PrimaryParticipantAccountId != null)){
                           
                    List<InsurancePolicyParticipant>     ListInsurancePolicyParticipantOld= [Select Id,InsurancePolicyId,RecordTypeId,RecordType.DeveloperName,PrimaryParticipantAccountId
                                                From InsurancePolicyParticipant Where PrimaryParticipantAccountId = :TriggerOldMap.get(sa.Id).PrimaryParticipantAccountId and InsurancePolicy.isactive = true ];
                   

                   for (integer t = 0; t < ListInsurancePolicyParticipantOld.size() ;t++){
                    // SE RECORRE TODAS LOS PARTICIPANTES DE LAS POLIZAS QUE ESTAN ASOCIADOS A LA CUENTA ACTUAL DE LA POLIZA EN EL FOR
                   
                     if(ListInsurancePolicyParticipantOld[t].RecordType.DeveloperName == 'CS_Asegurado'){
                        SVpolicyOld = TRUE;
                    }
                   if (ListInsurancePolicyParticipantOld[t].RecordType.DeveloperName == 'CS_Trabajador'){
                       RLpolicyOld = true;
                    }
                   
                }
                      List<InsurancePolicy> ListInsurancePolicyOld= [Select Id,RecordTypeId,RecordType.DeveloperName,NameInsuredId
                                                From InsurancePolicy Where NameInsuredId = :TriggerOldMap.get(sa.Id).PrimaryParticipantAccountId and isactive = true];
                   
                          for (integer u = 0; u < ListInsurancePolicyOld.size() ;u++){
                    // SE RECORRE TODAS LAS POLIZAS QUE ESTAN ASOCIADOS A LA CUENTA ACTUAL DE LA POLIZA EN EL FOR
                  
                     if(ListInsurancePolicyOld[u].RecordType.DeveloperName== 'CS_Seguro_de_vida'){
                     SVpolicyOld = TRUE;
                }
                 if(ListInsurancePolicyOld[u].RecordType.DeveloperName == 'CS_Contrato_ARL'){
                     RLpolicyOld = true;
                }
                    
                }
                    // DEPENDIENDO DE LOS PROCESOS ANTERIORES SE LE ASIGNA UN VALOR A LA VARIABLE 'VARIABLE'
         
                      
            if (SVpolicyOld== true && RLpolicyOld== false){
            //Seguros de vida
            variableOld = 'Colmena Seguros de Vida';
            
        }
        else if (SVpolicyOld== false && RLpolicyOld== true){
            // ARL
              variableOld = 'Colmena Riesgos Laborales';
        }
        else if (SVpolicyOld== false && RLpolicyOld== false){
            //NINGUNO
              variableOld = 'Ninguno';
        }
        else if (SVpolicyOld== true && RLpolicyOld== true){
            //MIXTO
              variableOld = 'Mixto';
        }

SVpolicyOld = false;
                            RLpolicyOld= false;
                         List<account> accountUpdateOld= [Select Id,ACC_Empresa_cliente__c
                                                From account Where id = :TriggerOldMap.get(sa.Id).PrimaryParticipantAccountId FOR UPDATE];
                    
                     for (integer t = 0; t < accountUpdateOld.size() ;t++){
             
                 accountUpdateOld[t].ACC_Empresa_cliente__c = variableOld;
                
      
        } update accountUpdateOld;
                    
                    } 
                     
                    
                    
                    
                    // SI LA LISTA ES VACIA SE REALIZA LA CONSULTA DE LOS PARTICIPANTES QUE HACEN PARTE DE TODA LA LISTA DE CUETNAS

                    if(ListInsurancePolicyParticipant == null){
                         ListInsurancePolicyParticipant= [Select Id,InsurancePolicyId,RecordTypeId,RecordType.DeveloperName,PrimaryParticipantAccountId
                                                From InsurancePolicyParticipant Where PrimaryParticipantAccountId in :policyIds and InsurancePolicy.isactive = true ];
                    
                    }
                   for (integer t = 0; t < ListInsurancePolicyParticipant.size() ;t++){
                    // SE RECORRE TODAS LOS PARTICIPANTES DE LAS POLIZAS QUE ESTAN ASOCIADOS A LA CUENTA ACTUAL DE LA POLIZA EN EL FOR
                    if(ListInsurancePolicyParticipant[t].PrimaryParticipantAccountId ==sa.PrimaryParticipantAccountId){
                     if(ListInsurancePolicyParticipant[t].RecordType.DeveloperName == 'CS_Asegurado'){
                        SVpolicy = TRUE;
                    }
                   if (ListInsurancePolicyParticipant[t].RecordType.DeveloperName == 'CS_Trabajador'){
                        RLpolicy = true;
                    }
                    }
                }
                
                    // SI LA LISTA ES VACIA SE REALIZA LA CONSULTAN LAS POLIZAS QUE HACEN PARTE DE TODA LA LISTA DE CUETNAS
                    if(ListInsurancePolicy == null){
                         ListInsurancePolicy= [Select Id,RecordTypeId,RecordType.DeveloperName,NameInsuredId
                                                From InsurancePolicy Where NameInsuredId in :policyIds and isactive = true];
                    }   
                      for (integer u = 0; u < ListInsurancePolicy.size() ;u++){
                    // SE RECORRE TODAS LAS POLIZAS QUE ESTAN ASOCIADOS A LA CUENTA ACTUAL DE LA POLIZA EN EL FOR
                    if(ListInsurancePolicy[u].NameInsuredId ==sa.PrimaryParticipantAccountId){
                     if(ListInsurancePolicy[u].RecordType.DeveloperName== 'CS_Seguro_de_vida'){
                     SVpolicy = TRUE;
                }
                 if(ListInsurancePolicy[u].RecordType.DeveloperName == 'CS_Contrato_ARL'){
                     RLpolicy = true;
                }
                    }
                }
        // DEPENDIENDO DE LOS PROCESOS ANTERIORES SE LE ASIGNA UN VALOR A LA VARIABLE 'VARIABLE'            
        if (SVpolicy== true && RLpolicy== false){
            //Seguros de vida
            variable = 'Colmena Seguros de Vida';
            
        }
        else if (SVpolicy== false && RLpolicy== true){
            // ARL
              variable = 'Colmena Riesgos Laborales';
        }
        else if (SVpolicy== false && RLpolicy== false){
            //NINGUNO
              variable = 'Ninguno';
        }
        else if (SVpolicy== true && RLpolicy== true){
            //MIXTO
              variable = 'Mixto';
        }   // SE VUELVE A DEJAR EN FALSE LAS VARIABLES DE TIPO BOOL PARA QUE INICIE EL PROCESO NUEVAMENTE SIN INCONVENIENTES 

                    SVpolicy= false ;
                    RLpolicy= false;
                     // SE AGREGA EL ID DE LA CUENTA ACTUAL EN UNA LISTA
                 AccIds.add(sa.PrimaryParticipantAccountId);
                       // SE AGREGA EL ID DE LA CUENTA EN UN MAPA CON EL VALOR DE LA VARIABLE LA CUAL SERA ASIGNADA MAS ADELANTE

              AccIdsAndComp.put(sa.PrimaryParticipantAccountId,variable);
             // SE CONSULTAN LAS CUENTAS CON RESPECTO A LA LISTA DE CUENTAS QUE SE TUVIERON PRESENTES EN EL ANTERIOR PROCESO
                    List<account> accountUpdate= [Select Id,ACC_Empresa_cliente__c
                                                From account Where id in :AccIds FOR UPDATE];
                     // SE RECORRE TODAS LAS  CUENTAS CONSULTADAS Y SE LES ALMACENA EN VALOR DE LA VARIABLE ANTERIOR EN EL CAMPO ACC_Empresa_cliente__c

        for (integer h = 0; h < accountUpdate.size() ;h++){
             
                 accountUpdate[h].ACC_Empresa_cliente__c =AccIdsAndComp.get(accountUpdate[h].id);
                
       
        } update accountUpdate;
               }
                  
        }
    }
}