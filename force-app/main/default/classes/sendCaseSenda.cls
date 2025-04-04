public class sendCaseSenda {
    
     @future(callout=true)
     public static void createOrUpdateCaseSenda(String idString)
     {
        Set<id> parentIdSet = new Set<id>();
        try{
			Case caso = [Select Id, CaseNumber, RecordType.Name, Description, CS_MacroMotivo__c, 
                    	CS_Submotivo__c, Status, CS_FechaTentativaDeCierre__c, CS_Semaforotexto__c, CS_Numero_de_ATEL__c,CS_Fecha_de_radicacion_en_la_Compania__c From Case where id =: idString];
            
            if (caso != null && ((caso.RecordType.Name == 'Queja' || caso.RecordType.Name == 'Derecho de peticion' || caso.RecordType.Name == 'Incidente' || caso.RecordType.Name == 'Queja Supersalud' || caso.RecordType.Name == 'Requerimiento Jurídico' || caso.RecordType.Name == 'Queja Superintendencia') && caso.CS_Numero_de_ATEL__c != null)){
            	Claim indemnizacionATEL = [Select Id, RecordType.Name, Name From Claim where id =: caso.CS_Numero_de_ATEL__c AND RecordType.Name IN ('AT','EL')];
				parentIdSet.add(caso.Id);
                CaseTaskWrapper caseTaskWrapper = new CaseTaskWrapper(caso, indemnizacionATEL);
        		TaskWrapper tasks1 = null;
        		List<TaskWrapper> tasksList = new List<TaskWrapper>();
				Map<Id, List<TaskWrapper>> mapOfChildObject = new Map<Id, List<TaskWrapper>>();
				For(Task tarea : [Select Id, Subject,ActivityDate,Status,Description,OwnerId, createdDate, RecordType.Name,
            	          	  	  WhatId, Owner.Name,  Owner.UserRole.Name From Task Where WhatId In:parentIdSet]){
            	    //Solo se envian tareas de usuarios con funciones de CONSULTA RIESGOS LABORALES
            		if (tarea.Owner.UserRole.Name == 'CONSULTA RIESGOS LABORALES'){
            	    	tasks1 = new TaskWrapper(tarea);
        				tasksList.add(tasks1);
            		}
				}
        		caseTaskWrapper.taskWrapper = tasksList; 
        		String token = AuthenticationMulesoft.GenerateToken();
        		//llamado al fileConfig
        		FileConfigMulesoft fileConfMulesoft = new FileConfigMulesoft('cs-salesforce-crm-xapi');
        		Http http = new Http();
				HttpRequest request = new HttpRequest();
				request.setEndpoint(fileConfMulesoft.urlMulesoft);
				request.setMethod('POST');
				request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        		request.setHeader('Authorization', 'Bearer '+token);
        		request.setHeader('client_id', fileConfMulesoft.client_id);	
        		request.setHeader('client_secret', fileConfMulesoft.client_secret);
				// Set the body as a JSON object
				request.setBody(JSON.serialize(caseTaskWrapper));
				HttpResponse response = http.send(request);
				System.debug('despues de mule');
				// Parse the JSON response
				if(response.getStatusCode() != 200) {
    				System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
				}
        	}
        } catch (Exception e) {
        	System.debug(e);
        }
  	}
}