public with sharing class WSClientController {
	
    //WS_HabeasDataWrapper.RequestWSWrapper request = new WS_HabeasDataWrapper.RequestWSWrapper();
    String responseString;
    
    public WS_HabeasDataWrapper.RequestWSWrapper ValidacionIdentidad(WS_HabeasDataWrapper.RequestWSWrapper requestParams)
    {
        System.debug('Entro a controlador');
			 
        if((requestParams.identityNumber != null && requestParams.identityNumber != '')  && (requestParams.identityType != null || requestParams.identityType != '')){
            List<Account> accountClient;
            List<Lead> leadClient;            

            System.debug('request.identityType--->'+requestParams.identityType);

            System.debug('request.identityNumber--_>'+requestParams.identityNumber);
            accountClient = [SELECT Id, PersonIndividualId FROM Account WHERE CS_TipoIdentificacionCP__pc =: requestParams.identityType AND CS_NumeroIdentificacionCP__pc =: requestParams.identityNumber];
            
            if(accountClient.size() > 0){
                System.debug('1IF');
                requestParams.TypeObjectCreate    = 'Account';
                requestParams.IdClient            = accountClient[0].id;
                requestParams.idIndividual        = accountClient[0].PersonIndividualId != null ? accountClient[0].PersonIndividualId : null; 
                System.debug('Cliente encontrado [Account] - '+accountClient);

            }else if(accountClient.size() == 0){
                System.debug('2IF');
                leadClient  = [SELECT Id, IndividualId FROM Lead WHERE Tipo_de_documento__c =: requestParams.identityType AND Numero_de_documento__c =: requestParams.identityNumber];

                if(leadClient.size() > 0){
                    requestParams.TypeObjectCreate = 'Lead';
                    requestParams.IdClient         = leadClient[0].id;
                    requestParams.idIndividual     = leadClient[0].IndividualId != null ? leadClient[0].IndividualId : null;
                    System.debug('Cliente encontrado [Lead] - '+leadClient);
                } 
            } 
            
            // System.debug('cÑIENS ACC-->'+accountClient.size());
            // System.debug('cÑIENS LEAD-->'+leadClient.size());

            if(accountClient.size() == 0 && leadClient.size() == 0){
                System.debug('3IF');
                System.debug('ENTRO A CREAR');
                EngagementChannelType searchChannel = [SELECT id, Name, channelReceivesPQRs__c FROM EngagementChannelType WHERE Name =: requestParams.AttentionChannel];
                requestParams.TypeObjectCreate = searchChannel.channelReceivesPQRs__c == true ? 'Account' : 'Lead';
                WSClientController CreateCli = new WSClientController();
                requestParams = CreateCli.CreateClient(requestParams);   
            }

        }else{ 
            System.debug('FALLO CONTROLADOR CLIENTE');
            requestParams.ClientController = 'los valores de Tipo o numero de documento se encuentran vacios';
        }
        
        return requestParams;
    }

    public WS_HabeasDataWrapper.RequestWSWrapper CreateClient(WS_HabeasDataWrapper.RequestWSWrapper requestParams){
        String TypeClient;
        System.debug('Entro a crear cliente');
        switch on requestParams.TypeObjectCreate {
				when 'Account'{
                    System.debug('Creo cuenta');
					Account newClient = new Account();
                    newClient.RecordTypeId 					= Schema.SObjectType.Account.getRecordTypeInfosByName().get('Cuenta Personal').getRecordTypeId();
                    newClient.FirstName 					= requestParams.FirstName;
                    newClient.MiddleName 					= requestParams.SecondName;
                    newClient.LastName 						= requestParams.LastName;
                    newClient.Suffix 						= requestParams.SecondLastName;
                    newClient.CS_TipoIdentificacionCP__pc 	= requestParams.identityType;
                    newClient.CS_NumeroIdentificacionCP__pc = requestParams.identityNumber;
                    newClient.PersonEmail 					= requestParams.email;
                    newClient.PersonMobilePhone				= requestParams.numberPhone;
                    newClient.CS_Empresa_Colmena__c			= '1';
                    newClient.CC_Tipo_de_Cuenta__c			= 'Cuenta Prospecto';
                    insert newClient;   
                    System.debug('Creo una cuenta:'+newClient.Id);
                    requestParams.IdClient = newClient.id;
				}
            	when 'Lead'{
                    System.debug('Creo un prospecto');
					Lead newClient = new Lead();
                    newClient.RecordTypeId 					= Schema.SObjectType.Lead.getRecordTypeInfosByName().get('General').getRecordTypeId();
                    newClient.FirstName 					= requestParams.FirstName;
                    newClient.MiddleName 					= requestParams.SecondName;
                    newClient.LastName 						= requestParams.LastName;
                    newClient.Suffix 						= requestParams.SecondLastName;
                    newClient.Tipo_de_documento__c			= requestParams.identityType;
                    newClient.Numero_de_documento__c		= requestParams.identityNumber;
                    newClient.Email							= requestParams.email;
                    newClient.MobilePhone					= requestParams.numberPhone;
                    insert newClient;
                    System.debug('Creo un prospecto:'+newClient.Id);
                    requestParams.IdClient = newClient.id;
				}
				when else {
					requestParams.ClientController = 'Objeto de Creación de cliente desconocido';
				}

			} 
            return requestParams;
    }
}