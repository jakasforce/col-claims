public class VS_RestrictiveListController {

    
    public class RestrictiveList{
        
        @InvocableVariable(required= true)
        public String ListasRestrictivas ;
        
        
        @InvocableVariable(required= true)
        public String ServiceError ;
                
    }
    
    
    public class infoClient{
        public String idRecord;
        public String firstName;
        public String middleName;
        public String lastName;
        public String secondLastName;
        public String documentType;
        public String documentNumber;
        public String phone;
        public String ExpeditionDate;
        
    }
    
    
    @AuraEnabled
    public static List<RestrictiveList> RestrictiveListRequest(String RecordID)
    {
        
        List<RestrictiveList> lstOutput = new List<RestrictiveList>();
        
            infoClient clientInformation = new infoClient();
            List<Account> clientInfo = [SELECT  id, FirstName, MiddleName, LastName, Suffix, CS_TipoIdentificacionCP__pc, CS_NumeroIdentificacionCP__pc 
                                        FROM  Account WHERE Id = :RecordID];
                                        
            //almaceno info en clase
            clientInformation.firstName         =   clientInfo[0].FirstName;
            clientInformation.middleName        =   clientInfo[0].MiddleName;
            clientInformation.lastName          =   clientInfo[0].lastName;
            clientInformation.secondLastName    =   clientInfo[0].Suffix;
            clientInformation.documentNumber    =   clientInfo[0].CS_NumeroIdentificacionCP__pc;

            System.debug('clientInformation--->'+clientInformation);

            RestrictiveList obj = new RestrictiveList();
            
            // Crear una instancia de requestListaRestrictiva y asignar valores
                System.debug('Entro a listas restrictivas');
                VS_WSGeneralExperienceService.requestListaRestrictiva ListasRestrictivasData = new VS_WSGeneralExperienceService.requestListaRestrictiva();
                ListasRestrictivasData.Numbe_r          = clientInformation.documentNumber;
                ListasRestrictivasData.FirstName        = clientInformation.firstName;
                ListasRestrictivasData.MiddleName       = clientInformation.middleName;
                ListasRestrictivasData.LastName         = clientInformation.lastName;
                ListasRestrictivasData.SecondLastName   = clientInformation.secondLastName;
                                
                // Llamar al método getListaRestrictiva y obtener los resultados
                Map<String, String> ListasRestrictivas = VS_WSGeneralExperienceService.getListaRestrictiva(ListasRestrictivasData);

                // Imprimir los resultados
                if(ListasRestrictivas.get('successful') != 'true'){
                    System.debug('FALLO EL SERVICIO DE LISTAS RESTRICTIVAS');
                    obj.ServiceError = 'El Servicio ListasRestrictivas Fallo Comuniquese con el administrador';
                    lstOutput.add(obj);
                    return  lstOutput;
                }
                if(ListasRestrictivas.get('emptyLists') == 'true'){
                    System.debug('EL CLIENTE SE ENCUENTRA REPORTADO');
                    obj.ListasRestrictivas = ListasRestrictivas.get('failureTrace');
                    lstOutput.add(obj);
                    return  lstOutput;
                }
                
            
            
        return  lstOutput;     
    }
    

}