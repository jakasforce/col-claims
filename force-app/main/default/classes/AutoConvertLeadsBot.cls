public with sharing class AutoConvertLeadsBot {

    @InvocableMethod(Label ='Conversión de prospecto' description='Convierte prospecto a cuenta personal')
        public static void leadAssing(List<Id> LeadIds)
        {
            LeadStatus cLeadStatus = [SELECT id, ApiName FROM leadStatus WHERE isConverted=true LIMIT 1];
            List<Database.LeadConvert> massLeadConvert = new List<Database.LeadConvert>();

            for(id currentLeadId : LeadIds){
                Lead currentLead = [SELECT id, FirstName, LastName, Tipo_de_documento__c, Numero_de_documento__c, Phone, Email FROM Lead LIMIT 1];
                Database.LeadConvert leadConvert = new Database.LeadConvert();
                leadConvert.setLeadId(currentLeadId);
                leadConvert.setConvertedStatus(cLeadStatus.ApiName);
                leadConvert.setDoNotCreateOpportunity(true);
                massLeadConvert.add(leadConvert);
            }

            if (!massLeadConvert.isEmpty()) {
                List<Database.LeadConvertResult> ResultConverts = Database.convertLead(massLeadConvert);
                for (Database.LeadConvertResult result : ResultConverts) {
                    if (result.isSuccess()) {
                        Account acc = [SELECT Id, recordTypeId FROM Account WHERE Id =: result.getAccountId()];
                        System.debug('acc-->'+acc);
                    }
                }
            }
        }
}