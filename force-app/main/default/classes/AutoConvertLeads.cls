/**
* ===============================================================================================================================
* Developer:             VASS LATAM
* Creation Date:         09/10/2023
* Created by:            edwin.martinez@vasscompany.com
* Description:           Esta clase realiza la conversión automática del lead, además se implementa una lógica personalizada para COLMENA.
* Last Modified by:      edwin.martinez@vasscompany.com (10/10/2023)
* Version:               v1.0
* ===============================================================================================================================
**/
public class AutoConvertLeads {

    Public static boolean recordNameRL;
    
    @InvocableMethod(label = 'convertedProspect')
    public static List<ouputVariables> assignLeads(List<Id> LeadIds) {
        List<ouputVariables> ouputVariables = new List<ouputVariables>();
        Lead currentLead = New Lead();
        Map<String,String> recordsTypeNames = new Map<String,String>();
        String prospectStrategyValue;
        
		/*inputVariables iVar = new inputVariables();
        iVar.LeadIds = inputVariables.get(0).LeadIds;
        List<String> LeadIds = iVar.LeadIds;*/
        
        try {
            LeadStatus cLeadStatus = [SELECT Id, ApiName FROM LeadStatus WHERE IsConverted = true LIMIT 1];

            List<Database.LeadConvert> massLeadConvert = new List<Database.LeadConvert>();

            // Consultar los nombres de los tipos de registro de Opportunity por su nombre
            Set<String> opportunityRecordTypeNames = new Set<String>();
            for (RecordType rt : [SELECT Name FROM RecordType WHERE SObjectType = 'Opportunity']) {
                opportunityRecordTypeNames.add(rt.Name);
            }

            //Id targetRecordTypeId; // Variable para almacenar el Id de los RecordTpes
            for (Id currentLeadId : LeadIds) {
                currentLead = [SELECT Id, ProspectStrategy__c,TypePerson__c, LeadSource, IntermediaryNameNotAcredited__c,NitNonAccreditedIntermediaries__c,IntermediaryLead__c,IntermediaryAccount__c,IndependentLinkedCompany__c FROM Lead WHERE Id = :currentLeadId LIMIT 1];
                if (currentLead != null && currentLead.ProspectStrategy__c != null) {
                    // Obtener el valor del campo ProspectStrategy__c del Lead
                    prospectStrategyValue = currentLead.ProspectStrategy__c;
                    recordsTypeNames.put('Opportunity',currentLead.ProspectStrategy__c);
                    recordsTypeNames.put('Account', 'Cuenta Jurídica');

                    System.debug('ID del Lead: ' + currentLeadId);
                    System.debug('Valor de Estrategia de Prospecto: ' + prospectStrategyValue);

                    if (opportunityRecordTypeNames.contains(prospectStrategyValue)) {
                        System.debug('El Lead con ID ' + currentLeadId + ' será convertido.');

                        // Obtener el ID del tipo de registro correspondiente
                        //targetRecordTypeId = getRecordTypeIdByName(prospectStrategyValue);

                        // Crear un objeto LeadConvert y configurar los valores necesarios
                        Database.LeadConvert LeadConvert = new Database.LeadConvert();
                        LeadConvert.setLeadId(currentLeadId);
                        LeadConvert.setConvertedStatus(cLeadStatus.ApiName);
                        LeadConvert.setDoNotCreateOpportunity(false);

                        massLeadConvert.add(LeadConvert);
                    } else {
                        System.debug('El Lead con ID ' + currentLeadId + ' no será convertido porque el Valor de Estrategia de Prospecto no coincide.');
                    }
                } else {
                    System.debug('El Lead con ID ' + currentLeadId + ' no tiene un Valor de Estrategia de Prospecto válido.');
                }
            }

            if (!massLeadConvert.isEmpty()) {
                // Realizar la conversión masiva de Leads
                List<Database.LeadConvertResult> lcr = Database.convertLead(massLeadConvert);
                Map<String,Id> getRT = new map<String, Id>();
                getRT = getRecordTypeIdByName(recordsTypeNames);
                // Actualizar la oportunidad recién creada
                for (Database.LeadConvertResult result : lcr) {

                    if (result.isSuccess()) {
                        Opportunity opp = [SELECT Id,AccountId, ContactId FROM Opportunity WHERE Id = :result.getOpportunityId() LIMIT 1];
                        Account acc = [SELECT Id, IsIntermediary__c, IntermediaryNameNotAcredited__c, NitNonAccreditedIntermediaries__c, IntermediaryAccount__c FROM Account WHERE Id =: opp.AccountId];
                        if (opp != null) {
                            System.debug('Creo la oportunidad');
                            ouputVariables oVar = new ouputVariables();
                            oVar.accountId = opp.AccountId;
                            oVar.opportunityId = opp.Id;
                            oVar.contactId = opp.ContactId;	
                            system.debug('oVar.accountId-->'+oVar.accountId);
                            ouputVariables.add(oVar);
                            
                            opp.RecordTypeId = getRT.get('Opportunity');
                            opp.Type = 'New Business';
                            update opp;
                            
                            // Si la estrategia del prospecto es'Afinidad', establecer la cuenta a 'Cuenta Aliada'
                            if (currentLead.ProspectStrategy__c == 'Afinidad') {
                                acc.CC_Tipo_de_Cuenta__c = 'Cuenta Aliada';
                            }
                            
                            if (currentLead.IndependentLinkedCompany__c == true) {
                                acc.CC_Tipo_de_Cuenta__c = 'Cuenta Prospecto';
                            }
                            
                            acc.IntermediaryAccount__c 				= currentLead.IntermediaryAccount__c != null ? currentLead.IntermediaryAccount__c : null ;
                            acc.IntermediaryNameNotAcredited__c 	= currentLead.IntermediaryNameNotAcredited__c != null ? currentLead.IntermediaryNameNotAcredited__c : null;
                            acc.IsIntermediary__c 					= currentLead.IntermediaryLead__c;
                            acc.NitNonAccreditedIntermediaries__c 	= currentLead.NitNonAccreditedIntermediaries__c;
                            acc.AccountSource						= currentLead.LeadSource;
                            acc.RecordTypeId = getRT.get('Account');
                            System.debug('acc--->'+acc);
                            update acc;
                            
                            //System.debug('ID de Oportunidad: ' + opp.Id + ' actualizado con ID de Tipo de Registro: ' + targetRecordTypeId);
                            System.debug('ID de TYPE:'+ opp.Type);
                        }
                    }
                }
            }
            System.debug('ouputVariables-->'+ouputVariables);
            Return ouputVariables;
        } catch (Exception e) {
            System.debug('Excepción capturada: ' + e.getMessage());
			ouputVariables oVar = new ouputVariables();

            if(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')){
                System.debug('1-->');
                    String mensaje = e.getMessage().substringAfter('FIELD_CUSTOM_VALIDATION_EXCEPTION,');
                    oVar.exceptionMessage = mensaje.substringBefore(': []');
            }else if(e.getMessage().contains('DUPLICATES_DETECTED')){
                System.debug('2--->');
                oVar.exceptionMessage = 'No se puede Cargar el Registro: Actualmente Cuenta con otro registro que contienen la misma información ';
            }else{
                oVar.exceptionMessage = 'ERROR: '+e.getMessage();
            }

            //oVar.exceptionMessage = e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION,') ? e.getMessage().substringAfter('FIELD_CUSTOM_VALIDATION_EXCEPTION,') : e.getMessage();
            
            System.debug('oVar.Cuenta-->'+oVar.accountId);
            System.debug('oVar.Contacto-->'+oVar.contactId);
            System.debug('oVar.oportunidad-->'+oVar.opportunityId);
            System.debug('oVar.Excepcion-->'+oVar.exceptionMessage);
            ouputVariables.add(oVar);
            Return ouputVariables;
        }
    }

    // Método para buscar el ID del tipo de registro por su nombre
    private static Map<String, Id> getRecordTypeIdByName(Map<String,String> recordTypeName) {
        Map<String, Id> recordTypes = new Map<String, Id>();
        RecordType rtOpp = [SELECT Id, Name FROM RecordType WHERE Name = :recordTypeName.get('Opportunity') AND SObjectType = 'Opportunity' LIMIT 1];
        RecordType rtAcc = [SELECT Id, Name FROM RecordType WHERE Name = :recordTypeName.get('Account') AND SObjectType = 'Account' LIMIT 1];
        System.debug('rtOpp--->'+rtOpp);
        System.debug('rtAcc--->'+rtAcc);
        if (rtOpp != null && rtAcc != null) {
            recordTypes.put('Account', rtAcc.id);
            recordTypes.put('Opportunity', rtOpp.id);
            return recordTypes;
        }
       
        System.debug('Tipo de Registro con Nombre "' + recordTypeName + '" no encontrado.');
        return null;
    }
    
    /*public class inputVariables {
        @InvocableVariable
        public List<String> LeadIds;	
    }*/
    
    public class ouputVariables {
        @InvocableVariable
        public Id accountId;
        @InvocableVariable
        public Id opportunityId;
        @InvocableVariable
        public Id contactId;
        @InvocableVariable
        public String exceptionMessage;
    }    
}