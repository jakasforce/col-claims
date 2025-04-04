public with sharing class WSHabeasDataController {
    
    List<ContactPointEmail> clientEmailData = new List<ContactPointEmail>();
    List<ContactPointPhone> clientPhoneData = new List<ContactPointPhone>();
    WS_HabeasDataWrapper.ResponseWSWrapper response = new WS_HabeasDataWrapper.ResponseWSWrapper();
    Schema.SObjectType sobjectTypeEmail;
    Schema.SObjectType sobjectTypePhone;
    Individual newRecordInd = new Individual();

    public WS_HabeasDataWrapper.ResponseWSWrapper controllerHD(WS_HabeasDataWrapper.RequestWSWrapper params){
        System.debug('Entro a controlador de Habeas Data');
        System.debug('params.IdClient->'+params.IdClient);
        System.debug('param.Coomaniaes->'+params.companies.size());
        if( params.IdClient != null ){
            newRecordInd.id                         = params.idIndividual != null ? params.idIndividual : newRecordInd.id;
            newRecordInd.FirstName                  = params.FirstName;
            newRecordInd.MiddleName                 = params.SecondName; 
            newRecordInd.LastName                   = params.LastName;
            newRecordInd.Suffix                     = params.SecondLastName;
            newRecordInd.engagementChannelTypeId__c = [SELECT id FROM EngagementChannelType WHERE Name =:params.AttentionChannel].id;
            
            //Obtencion de contactPointsExistentes
            getContactPoints(params);

            System.debug('xxxxasasad');

            for (WS_HabeasDataWrapper.CompaniesWrapper company : params.companies) {
                System.debug('Company-->'+company.notEssentialFunctionalities);
    
                switch on company.Name {
                    when  'Colmena Capitalizadora' {
                        System.debug('Capitalizadora entro');
                        //Funcionalidades Esenciales
                        newRecordInd.essentialFunctionalitiesCap__c     = company.essentialFunctionalities;
                        //Funcionalidades No Esenciales
                        newRecordInd.notEssentialFunctionalitiesCap__c  = company.notessentialFunctionalities != null ? string.join(company.notessentialFunctionalities, ';') : null ;
                        newRecordInd.law2300Cap__c                      = company.law2300;
                    }
                    when  'Colmena Seguros Vida' {
                        System.debug('Seguros Vida entro');
                        //Funcionalidades Esenciales
                        newRecordInd.essentialFunctionalitiesSegVida__c     = company.essentialFunctionalities;
                        //Funcionalidades No Esenciales
                        newRecordInd.notEssentialFunctionalitiesSegVida__c  = company.notessentialFunctionalities != null ? string.join(company.notessentialFunctionalities, ';') : null ;
                        if (company.law2300 != null) {
                            newRecordInd.law2300SegVida__c                      = company.law2300;
                        }
                        if (company.MedicalHistory != null) {
                            newRecordInd.MedicalHistorySegVida__c               = company.MedicalHistory;
                        }
                    }
                    when  'Colmena Seguros ARL' {
                        System.debug('Seguros ARL entro');
                        //Funcionalidades Esenciales
                        newRecordInd.essentialFunctionalitiesARL__c = company.essentialFunctionalities;
                        //Funcionalidades No Esenciales
                        newRecordInd.notEssentialFunctionalitiesARL__c  = company.notessentialFunctionalities != null ? string.join(company.notessentialFunctionalities, ';') : null ;
                        newRecordInd.MedicalHistoryARL__c               = company.MedicalHistory;
                        newRecordInd.law2300ARL__c                       = company.law2300;
                    }
                    when  'Colmena Seguros Generales' {
                        System.debug('Seguros Generales entro');
                        //Funcionalidades Esenciales
                        newRecordInd.essentialFunctionalitiesSegGen__c      = company.essentialFunctionalities;
                        //Funcionalidades No Esenciales
                        newRecordInd.notEssentialFunctionalitiesSegGen__c   = company.notessentialFunctionalities != null ? string.join(company.notessentialFunctionalities, ';') : null ;
                        newRecordInd.law2300SegGen__c                       = company.law2300;
                    }
                    when else {
                        System.debug('No tiene ninguna empresa relacionada!');                    
                    }
                }
    
            }

            if(params.idIndividual == null && params.TypeObjectCreate == 'Account'){
                insert newRecordInd;
            
                Account updateAcc = new account();
                updateAcc.Id                    = params.IdClient;
                updateAcc.PersonIndividualId    = newRecordInd.id;
                update updateAcc;

            }else if(params.idIndividual == null && params.TypeObjectCreate == 'Lead'){
                insert newRecordInd;
                Lead updateLead = new Lead();
                updateLead.Id           = params.IdClient;
                updateLead.IndividualId = newRecordInd.id;
                update updateLead;
            }else{
                update newRecordInd;
            }
            
            System.debug('newRecordInd-->'+newRecordInd);

            assignContactPointToIndividual(params);

            createContactPointConsentToIndividual(params);

            response.error = false;
            response.message = 'successfull';
            response.responseCode = '200';
            response.status = 'Success';
            


        }else{
            response.error = false;
            response.message = 'id de cliente vacio para relacionar la autorización';
            response.responseCode = '202';
            response.status = 'Failed';
        }
        return response;
    }

    public void getContactPoints(WS_HabeasDataWrapper.RequestWSWrapper params){


        if(params.email != null){
            clientEmailData = [SELECT id, ParentId FROM ContactPointEmail WHERE Name =:params.email LIMIT 1];
            
            
            if(clientEmailData.size() > 0 ){
                sobjectTypeEmail = clientEmailData[0].ParentId.getSObjectType();
                system.debug('Correo--->'+clientEmailData); 
                System.debug('sobjectType-->'+sobjectTypeEmail); 
            }
        }

        if (params.numberPhone != null) {
            clientPhoneData = [SELECT id, ParentId FROM ContactPointPhone WHERE TelephoneNumber =:params.numberPhone LIMIT 1];

            if(clientPhoneData.size() > 0  ){
                system.debug('Celular--->'+clientPhoneData); 
                sobjectTypePhone = clientPhoneData[0].ParentId.getSObjectType();
                System.debug('sobjectType-->'+sobjectTypePhone); 

            }
             
        }
        
    }

    public void assignContactPointToIndividual(WS_HabeasDataWrapper.RequestWSWrapper params){


        ContactPointEmail emailClient = new ContactPointEmail();
        ContactPointPhone phoneClient = new ContactPointPhone();

        // si tiene puntos de contactos existentes relacionados a una cuenta, cambia la relación y la apunta al individuo creao o actualizado
        if(clientEmailData.size() > 0 && sobjectTypeEmail != null && String.valueOf(sobjectTypeEmail) != 'Individual'){
            System.debug('cambia relacion a individuo - correo');
                emailClient.id       = clientEmailData[0].id; 
                emailClient.ParentId = newRecordInd.id;
                update emailClient;
        }else if(clientEmailData.size() == 0 && (params.email != null || params.email != '')){
            System.debug('Crea punto de contacto dado que no encontro resultados de email');
            emailClient.EmailAddress = params.email;
            emailClient.ParentId = newRecordInd.id;
            insert emailClient;
            clientEmailData.add(emailClient);
        }
        
        if(clientPhoneData.size() > 0 && sobjectTypePhone != null && String.valueOf(sobjectTypePhone) != 'Individual'){
            System.debug('cambia relacion a individuo - celular');
            phoneClient.id = clientPhoneData[0].id;
            phoneClient.ParentId = newRecordInd.id;
            update phoneClient;
        }else if(clientPhoneData.size() == 0 && (params.numberPhone != null || params.numberPhone != '')){
            System.debug('Crea punto de contacto dado que no encontro resultados de Phone');
            phoneClient.TelephoneNumber = params.numberPhone;
            phoneClient.ParentId = newRecordInd.id;
            insert phoneClient;
            clientPhoneData.add(phoneClient);
        }
    }

    public void createContactPointConsentToIndividual(WS_HabeasDataWrapper.RequestWSWrapper params){
   
        if(clientEmailData.size() > 0){
            System.debug('Entro a Crear/Actualizar consentiminento');
            List<ContactPointConsent> searchContactPointConsent = [SELECT id FROM ContactPointConsent WHERE ContactPointId =:clientEmailData[0].id]; 
            System.debug('searchContactPointConsent-->'+searchContactPointConsent);

            ContactPointConsent newRecordCPCE = new ContactPointConsent();
            newRecordCPCE.name = params.FirstName +' '+ params.SecondName +' '+ params.LastName +' '+ params.SecondLastName;
            newRecordCPCE.ContactPointId = clientEmailData[0].id;

            for (WS_HabeasDataWrapper.CompaniesWrapper company : params.companies) {
                System.debug('Company-->'+company.name);

                switch on company.Name {
                    when  'Colmena Capitalizadora' {
                        System.debug('Capitalizadora CPC entro');
                        newRecordCPCE.colmenaCapitalization__c = true;
                    }
                    when  'Colmena Seguros Vida' {
                        System.debug('Seguros Vida CPC entro');
                        newRecordCPCE.colmenaLifeInsurance__c = true;
                    }
                    when  'Colmena Seguros ARL' {
                        System.debug('Seguros ARL CPC entro');
                        newRecordCPCE.colmenaInsuranceARL__c  = true;
                    }
                    when  'Colmena Seguros Generales' {
                        System.debug('Seguros Generales CPC entro');
                        newRecordCPCE.colmenaGeneralInsurance__c = true;
                    }
                    when else {
                        System.debug('No tiene ninguna empresa relacionada!');                    
                    }
                }

            }

            if(searchContactPointConsent.size()>0){
                newRecordCPCE.id = searchContactPointConsent[0].id;
                update newRecordCPCE;
            }else{
                insert newRecordCPCE;
            }
        }

        if(clientPhoneData.size() > 0 ){

            List<ContactPointConsent> searchContactPointConsent = [SELECT id FROM ContactPointConsent WHERE ContactPointId =:clientPhoneData[0].id]; 
            System.debug('searchContactPointConsent-->'+searchContactPointConsent);

            ContactPointConsent newRecordCPCP = new ContactPointConsent();
            newRecordCPCP.name = params.FirstName +' '+ params.SecondName +' '+ params.LastName +' '+ params.SecondLastName;
            newRecordCPCP.ContactPointId = clientPhoneData[0].id;

            for (WS_HabeasDataWrapper.CompaniesWrapper company : params.companies) {
                System.debug('Company-->'+company.name);

                switch on company.Name {
                    when  'Colmena Capitalizadora' {
                        System.debug('Capitalizadora CPC entro');
                        newRecordCPCP.colmenaCapitalization__c = true;
                    }
                    when  'Colmena Seguros Vida' {
                        System.debug('Seguros Vida CPC entro');
                        newRecordCPCP.colmenaLifeInsurance__c = true;
                    }
                    when  'Colmena Seguros ARL' {
                        System.debug('Seguros ARL CPC entro');
                        newRecordCPCP.colmenaInsuranceARL__c  = true;
                    }
                    when  'Colmena Seguros Generales' {
                        System.debug('Seguros Generales CPC entro');
                        newRecordCPCP.colmenaGeneralInsurance__c = true;
                    }
                    when else {
                        System.debug('No tiene ninguna empresa relacionada!');                    
                    }
                }

            }

            if(searchContactPointConsent.size()>0){
                newRecordCPCP.id = searchContactPointConsent[0].id;
                update newRecordCPCP;
            }else{
                insert newRecordCPCP;
            }
        }
    }
}