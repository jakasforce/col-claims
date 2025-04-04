/*************************************************************************************/
/* Desarrollado por: VASS 
/* Autor:            Fernando Andres Torres Saavedra
/* Proyecto:         Colmena
/* Descripción:      Clase para exponer el servicio de la Integracion de IVR
/* Fecha:            20/06/2023
/*************************************************************************************/
@RestResource(urlMapping='/consultivr/*')
global  class ConsultIvrAPI {

    private static List<String> listHirdrocarburos = getMetadato('hidrocarburos').split(',');
    private static List<String> listExceptionCase = getMetadato('excepcionPQRS').split(',');

    //---------------------------Metodo principal de el servicio-----------------------------//
    @HttpGet
    global static void info() {

        RestRequest request = RestContext.request;
        RestResponse response = RestContext.response;

        String tipoIdentificacion = request.params.get('documentType');
        String numeroIdentificacion = request.params.get('documentNumber');
        String valorAc;
        String valorHidro;
        

        Boolean hidrocarburos = false;
        Boolean PQRS = false;
        Boolean ATEL = false;

        Map<String, Object> jsonResponseMap = new Map<String, Object>();
        Map<String, Object> CasosMap = new Map<String, Object>();
		
        
        
        //------------------------------Logica de el servicio------------------------------//
        if (String.isBlank(tipoIdentificacion) || String.isBlank(numeroIdentificacion)) {
            response.statusCode = 400;
            response.responseBody = Blob.valueOf('{"error": "Los parámetros son requeridos"}');
            return;
        }
        
        List<Account> accounts = new List<Account>();
        accounts = [SELECT Id,Name,CS_ClienteActivo__c,RecordType.DeveloperName,ACC_Empresa_cliente__c,Industry
                    FROM Account
                    WHERE (CS_TipoIdentificacion__c = :tipoIdentificacion
                        AND CS_NumeroIdentificacion__c = :numeroIdentificacion)
                    OR (CS_TipoIdentificacionCP__pc = :tipoIdentificacion
                        AND CS_NumeroIdentificacionCP__pc = :numeroIdentificacion)
                    ORDER BY CS_ClienteActivo__c DESC, CreatedDate ASC
                    LIMIT 1];

        if (!accounts.isEmpty()) {

            Account account = accounts[0];
            if(account.RecordType.DeveloperName == 'CS_Juridico'){
                // cuenta juridica
                hidrocarburos = hidrocarburoJuridico(account);
            }else{
                //cuenta personal
                hidrocarburos = hidrocarburoPersonal(account);
            }         
            //---------------------------Construcion de json de respuesta-----------------------------// 
            jsonResponseMap.put('business',(account.ACC_Empresa_cliente__c != null)?Integer.valueOf(getMetadato(account.ACC_Empresa_cliente__c.replaceAll('\\s+', ''))):0);          
            jsonResponseMap.put('hydrocarbons',(hidrocarburos)?1:0);
            jsonResponseMap.put('activeClaim', estadoClaim(account));
            jsonResponseMap.put('activePQR', pqrsActiva(account));
            jsonResponseMap.put('clientName', account.Name);
            jsonResponseMap.put('clientActive', (account.CS_ClienteActivo__c)?1:0);
            jsonResponseMap.put('clientId', account.Id);
            jsonResponseMap.put('status',1);

        }else {
            //---------------------Respuesta en caso de no encontrar la cuenta------------------------//
            jsonResponseMap.put('status',0);
        }
        String jsonResponse = JSON.serialize(jsonResponseMap);
        response.statusCode = 200;
        response.responseBody = Blob.valueOf(jsonResponse);
    }

    //--------------Acontinuacion los metodos con la logica para cada campo---------------------------//


    //--------------Metodo que consulta el metadato IVRMetadatos-------------------------------------//
    private static String getMetadato(String metaDato){
        try{
            IVRMetadatos__mdt datoResultado = IVRMetadatos__mdt.getInstance(metaDato);
            return datoResultado.valor__c;
        }catch(Exception e){
            return '0';
        }    
    }  

    //----Metodo que consulta si la empresa de colmena puede pertenecer a un sector hidrocarburos--//
    private static Boolean empresaHidrocarburo(String empresa){
        try{
            IVRMetadatos__mdt datoResult = IVRMetadatos__mdt.getInstance(empresa);
            return datoResult.hidrocarburo__c;
        }catch(Exception e){
            return false;
        } 
    }

    //----Metododo para identificar si la cuenta juridica tiene algun sector de hidrocarburos-----//
    private static Boolean hidrocarburoJuridico(Account acc){
        if((acc.ACC_Empresa_cliente__c != null)?empresaHidrocarburo(acc.ACC_Empresa_cliente__c.replaceAll('\\s+', '')):false){
        	if(listHirdrocarburos.contains(acc.Industry)){
            	return  true;
        	}else{
            	return  false;
        	}
        }else{
            return false;
        }
    }

    //-Metododo para identificar si la cuenta personal pertenece a algun sector de hidrocarburos-//
    private static Boolean hidrocarburoPersonal(Account cuent){
        if((cuent.ACC_Empresa_cliente__c != null)?empresaHidrocarburo(cuent.ACC_Empresa_cliente__c.replaceAll('\\s+', '')):false){
            // Obtener los InsurancePolicyIds de los InsurancePolicyParticipant
            Set<Id> participantIds = new Set<Id>();
            List<InsurancePolicyParticipant> policyParticipants = [
                SELECT InsurancePolicyId
                FROM InsurancePolicyParticipant
                WHERE PrimaryParticipantAccountId IN (
                    SELECT Id
                    FROM Account
                    WHERE Id = :cuent.Id
                    )
                ];
            if (!policyParticipants.isEmpty()) {
                for (InsurancePolicyParticipant participant : policyParticipants) {
                    participantIds.add(participant.InsurancePolicyId);
                }
                // Consulta principal utilizando los InsurancePolicyIds obtenidos
                List<Account> accountsHidro = [
                    SELECT Id, Name, Industry
                    FROM Account
                    WHERE Id IN (
                        SELECT NameInsuredId
                        FROM InsurancePolicy
                        WHERE RecordType.DeveloperName = 'CS_Contrato_ARL'
                        AND Id IN :participantIds
                    )
                    AND Industry IN :listHirdrocarburos
                ];
                if (!accountsHidro.isEmpty()) {
                    return true;
                }
            }
        }
        return false;
    }

    //--------Metododo para identificar si la cuenta tiene alguna PQRS en estado activo-----------//
    private static Integer pqrsActiva(Account cuen){
        Integer pqrActiva = 0; 
        List<Case> ListCasos = [SELECT Id FROM Case WHERE RecordType.DeveloperName NOT IN : listExceptionCase  AND AccountId =: cuen.Id  AND IsClosed = false ];
        if (!ListCasos.isEmpty()) {
            pqrActiva = 1;
        }
        return pqrActiva;
    }

    //------------------Metododo para establecer el estado de las reclamaciones ----------------//
    private static Integer estadoClaim(Account acc){
        Integer claimStatus = 0;
        List<AggregateResult> Claims = [SELECT RecordType.DeveloperName recordTypeName 
                                            FROM Claim
                                            WHERE Status='Abierto' 
                                            AND AccountId = :acc.Id
                                            GROUP BY RecordType.DeveloperName];
        


        if (!Claims.isEmpty()) {
            Set<String> setClaims = new Set<String>();
            for (AggregateResult result : claims){
                String developerName = (String)result.get('recordTypeName');
                setClaims.add(developerName);
            }
            if (setClaims.size() == 1){
                if (setClaims.contains('CS_Siniestro')) {
                    claimStatus = 1;
                } else {
                    claimStatus = 2; 
                }
            } else{
                if (setClaims.contains('CS_Siniestro')) {
                    claimStatus = 3; 
                } else {
                    claimStatus = 2; 
                }
            }    
        }
        return claimStatus;
    }




}