/**
* ===============================================================================================================================
* Developer:             VASS LATAM
* Creation Date:         20/09/2023
* Created by:            edgar.mora@vasscompany.com
* Description:           Esta es una Clase invocable que consume el servicio de VS_WSGeneralExperienceService,
*                        Recibe un Id de prospecto y lo procesa para consultar si tiene lista restrictiva.
*                        y la información la almacena en 3 campos personalizados de prospectos.
* Last Modified by:      edgar.mora@vasscompany.com (25/09/2023)
* Version:               v1.0
* ===============================================================================================================================
**/

public class RestrictedListQuery_Cls {

   @InvocableMethod(label='Procesar String para Lead')
    public static void procesarStringParaLead(List<String> inputStrings) {
         String inputString = inputStrings[0];
         system.debug('@1  ' + inputString);
            
         Call_VS_WSGeneralExperienceService(inputString);
        
        

    }
     @future(callout=true)
    public static void Call_VS_WSGeneralExperienceService(string leadId) {
        // variable DateTime
        Datetime  currentDate = Datetime.NOW();         
        boolean Save =false;
        //Consulta de Leads con ese ID. 
        Lead lead = [SELECT id, Numero_de_documento__c, FirstName, MiddleName, LastName,TypePerson__c,Company FROM Lead WHERE id = :leadId LIMIT 1];
        system.debug('@2.0  ' + lead);
        
        if (leadId != null && lead != null ) {           
            system.debug('@2  ' + lead);
            //Consumo de Metodo de estructura para consumo de listas restrictivas.
            VS_WSGeneralExperienceService.requestListaRestrictiva ListasRestrictivasData = new VS_WSGeneralExperienceService.requestListaRestrictiva();
           //En esta sección define si es Persona Natural o Juridica. 
            if(lead.TypePerson__c == 'Persona Natural'){
                ListasRestrictivasData.Numbe_r = lead.Numero_de_documento__c;
                ListasRestrictivasData.FirstName = lead.FirstName;
                ListasRestrictivasData.MiddleName = lead.MiddleName;
                ListasRestrictivasData.LastName = lead.LastName;                
            } else
            {
                ListasRestrictivasData.Numbe_r = lead.Numero_de_documento__c;
                ListasRestrictivasData.FirstName = lead.Company;                
            }
                           
                system.debug ('@3  ' + ListasRestrictivasData);
 //Consumo de Metodo de listas restrictivas. y retorna las respectivas mensajes predefinidos.              
                Map<String, String> ListasRestrictivas = VS_WSGeneralExperienceService.getListaRestrictiva(ListasRestrictivasData);
                system.debug('@4  ' + JSON.serializePretty(ListasRestrictivas));
                system.debug('@5  ' + ListasRestrictivas.get('successful'));
				               
               if(ListasRestrictivas.get('emptyLists') == 'true' && ListasRestrictivas.get('successful') == 'true'){
                   lead.ConsultationDate__c = currentDate;lead.ContainsRestrictedList__c = 'Si';
                   lead.ResultRestrictiveLists__c =JSON.serialize( ListasRestrictivas);  Save=true;                   
                }  
                if(ListasRestrictivas.get('emptyLists') == 'false' && ListasRestrictivas.get('successful') == 'true'){
                   lead.ConsultationDate__c = currentDate; lead.ContainsRestrictedList__c = 'No';
                   lead.ResultRestrictiveLists__c =JSON.serialize( ListasRestrictivas);           Save=true;
                } 
                if(ListasRestrictivas.get('successful') == 'false'){
                   lead.ConsultationDate__c = currentDate;
                   lead.ContainsRestrictedList__c = '';
                   lead.ResultRestrictiveLists__c =JSON.serialize( ListasRestrictivas);
                   Save=true;
                }
            
            if (Save==true){
                try {
                		update lead;
            		}	
            	catch(DmlException e) {
        								System.debug('Error updating Lead: ' + e);
   			 						  }
            }  
        }
    }
}