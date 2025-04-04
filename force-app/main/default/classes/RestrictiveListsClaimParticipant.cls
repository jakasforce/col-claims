/**
* @author Melvin Escalante
* @email melvin.escalante@oc.vasscompany.com
* @create date 2024-08-13 16:44:17
* @desc [Esta es una Clase invocable que consume el servicio de VS_WSGeneralExperienceService,
*         Recibe un Id de Beneficiario y lo procesa para consultar si tiene lista restrictiva.
*         y la información la almacena en 3 campos personalizados de ClaimParticipant]
*/

public with sharing class RestrictiveListsClaimParticipant {
    @InvocableMethod(label='Procesar String para Participante')
    public static void processStringForContracts(List<String> inputStrings) {
        String inputString = inputStrings[0];
        system.debug('@1  ' + inputString);
        
        Call_VS_WSGeneralExperienceService(inputString);
    }
    @future(callout=true)
    public static void Call_VS_WSGeneralExperienceService(string ClaimParticipantId) {
        // variable DateTime
        Datetime  currentDate = Datetime.NOW();       
        boolean Save =false;
        //Consulta de contracts con ese ID. 
        ClaimParticipant ClaimParticipant = [SELECT Id, CS_DocumentNumber__c, CS_FirstName__c, CS_SecondName__c, CS_LastName__c,CS_NameorSocialReason__c FROM ClaimParticipant WHERE Id = :ClaimParticipantId LIMIT 1];
        system.debug('@2.0  ' + ClaimParticipant);
        
        if (ClaimParticipantId != null && ClaimParticipant != null ) {           
            system.debug('@2  ' + ClaimParticipant);
            //Consumo de Metodo de estructura para consumo de listas restrictivas.
            VS_WSGeneralExperienceService.requestListaRestrictiva RestrictiveListsData = new VS_WSGeneralExperienceService.requestListaRestrictiva();
            if(ClaimParticipant.CS_FirstName__c != null || ClaimParticipant.CS_SecondName__c != null){
                RestrictiveListsData.Numbe_r = ClaimParticipant.CS_DocumentNumber__c;
                RestrictiveListsData.FirstName = ClaimParticipant.CS_FirstName__c;
                RestrictiveListsData.MiddleName = ClaimParticipant.CS_SecondName__c;
                RestrictiveListsData.LastName = ClaimParticipant.CS_LastName__c;                
            }else
            {
                RestrictiveListsData.Numbe_r = ClaimParticipant.CS_DocumentNumber__c;
                RestrictiveListsData.FirstName = ClaimParticipant.CS_NameorSocialReason__c;                
            }
            system.debug ('@3  ' + RestrictiveListsData);
            //Consumo de Metodo de listas restrictivas. y retorna las respectivas mensajes predefinidos.              
            Map<String, String> RestrictiveLists = VS_WSGeneralExperienceService.getListaRestrictiva(RestrictiveListsData);
            system.debug('@4  ' + JSON.serializePretty(RestrictiveLists));
            system.debug('@5  ' + RestrictiveLists.get('successful'));
            if(RestrictiveLists.get('emptyLists') == 'true' && RestrictiveLists.get('successful') == 'true'){
                ClaimParticipant.CS_DatetimeRestrictiveListRequest__c = currentDate;
                ClaimParticipant.CS_ContainsRestrictedList__c = 'Si';
                ClaimParticipant.CS_RestrictiveListResult__c =JSON.serialize( RestrictiveLists);  
                String SListRestrictive=String.valueOf(RestrictiveLists.get('ResponseListaRestrictiva'));
                
                Map<String, Object> jsonMap = (Map<String, Object>) JSON.deserializeUntyped(SListRestrictive);
                
                List<Object> lists = (List<Object>) jsonMap.get('Lists');
                
                String ListRest ='';
                for (Object item : lists) {
                    Map<String, Object> listItem = (Map<String, Object>) item;
                    
                    String listType = (String) listItem.get('ListType');
                    
                    ListRest += listType +' \n';
                }
                ClaimParticipant.CS_RestrictiveLists__c =ListRest;
                
                Save=true;    
                
            }  
            if(RestrictiveLists.get('emptyLists') == 'false' && RestrictiveLists.get('successful') == 'true'){
                ClaimParticipant.CS_DatetimeRestrictiveListRequest__c = currentDate; 
                ClaimParticipant.CS_ContainsRestrictedList__c = 'No';
                ClaimParticipant.CS_RestrictiveListResult__c =JSON.serialize( RestrictiveLists);           
                Save=true;
            } 
            if(RestrictiveLists.get('successful') == 'false'){
                ClaimParticipant.CS_DatetimeRestrictiveListRequest__c = currentDate;
                ClaimParticipant.CS_ContainsRestrictedList__c = '';
                ClaimParticipant.CS_RestrictiveLists__c ='Error Consulta';
                ClaimParticipant.CS_RestrictiveListResult__c =JSON.serialize( RestrictiveLists);
                Save=true;
            }
            if (Save==true){
                try {
                    update ClaimParticipant;
                }	
                catch(DmlException e) {
                    System.debug('Error Updating ClaimParticipant: ' + e);
                }
            }  
        }
    }
   
}