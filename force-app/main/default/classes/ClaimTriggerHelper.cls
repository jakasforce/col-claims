public with sharing class ClaimTriggerHelper {
    public static void updateOwnerOfQueue(List<Claim> newClaims, Map<Id, Claim> newClaimsMap, List<Claim> oldClaims) {
        // Get Monopoliza RecordType
        RecordType monopolizaRecordType = [
            SELECT Id, Name, DeveloperName FROM RecordType
            WHERE DeveloperName = 'CS_Monopoliza'
            LIMIT 1
        ];
        // Get information from the claims
        List<Id> claimIds = new List<Id>();
        for (Claim claim : newClaims) {
            if (claim.Status == 'Análisis' && claim.CS_SubEstado__c == 'Nuevo' && claim.RecordTypeId == monopolizaRecordType.Id) {
            	claimIds.add(claim.Id);
            }
        }
        
        if(claimIds.size() > 0){
            List<Claim> claims = [
                SELECT Id, OwnerId, Status, CS_SubEstado__c, RecordTypeId, PolicyNumberId, PolicyNumber.ProductId, 
                (SELECT Id, Name, LossReserveAmount  FROM ClaimCoverages),
                InsurancePolicyCoverage__c, InsurancePolicyCoverage__r.CoverageCode
                FROM Claim
                WHERE Id IN :claimIds
            ];
            
            // Get ProductIds from the claims
            List<Id> productIds = new List<Id>();
            for (Claim claim : claims) {
                productIds.add(claim.PolicyNumber.ProductId);
            }
            
            // Get Products information
            List<Product2> products = [
                SELECT Id, ProductCode, Family
                FROM Product2
                WHERE Id IN :productIds
            ];
            
            Map<Id, Product2> productMap = new Map<Id, Product2>();
            for (Product2 product : products) {
                productMap.put(product.Id, product);
            }
            
            // Get Queues
            Map<String, Id> queues = getQueues();
            
            String ramosIndemnizacionesRamoDesempleo = '24';
            String ramosIndemnizacionesRamoVidaGrupo = '34';
            String ramosIndemnizacionesLineaRapida = '30,31,34,35,37';
            String ramosIndemnizacionesAltaComplejidad = '30,31,34,35,37';
            String ramosIndemnizacionesAltaComplejidadAmparo = '30,31,34,35,37';
            
            for (Claim claim : claims) {
                if(newClaimsMap.containsKey(claim.Id) && claim.PolicyNumberId != null && claim.ClaimCoverages.size() > 0 && claim.InsurancePolicyCoverage__c != null){
                    Claim claimToUpdate = newClaimsMap.get(claim.Id);
                    Product2 product = productMap.get(claim.PolicyNumber.ProductId);
                        
                    String ramo = product.Family;
                    String producto = product.ProductCode;
                    Decimal valor = claim.ClaimCoverages[0].LossReserveAmount;
                    String cobertura = claim.InsurancePolicyCoverage__r.CoverageCode;
                    System.debug('ramo: ' + ramo);
                    System.debug('producto: ' + producto);
                    System.debug('valor: ' + valor);
                    System.debug('cobertura: ' + cobertura);
                    
                    system.debug(product.Family + ' - ' + product.ProductCode + ' - ' + claim.ClaimCoverages[0].LossReserveAmount + ' - ' + claim.InsurancePolicyCoverage__r.CoverageCode);
                    
                    String newOwnerId;
                    
                    if (ramosIndemnizacionesRamoDesempleo.contains(ramo)) {
                        newOwnerId = queues.get('Indemnizaciones_Ramo_Desempleo');
                    } else if (ramosIndemnizacionesRamoVidaGrupo.contains(ramo) && producto == '34224') {
                        newOwnerId = queues.get('Indemnizaciones_Ramo_Vida_Grupo');
                    } else if (ramosIndemnizacionesLineaRapida.contains(ramo) && producto != '34224' && valor > 6000000) {
                        newOwnerId = queues.get('Indemnizaciones_Linea_Rapida');
                    } else if (ramosIndemnizacionesAltaComplejidad.contains(ramo) && cobertura != 'ITP' && valor <= 6000000) {
                        newOwnerId = queues.get('Indemnizaciones_Alta_Complejidad');
                    } else if (ramosIndemnizacionesAltaComplejidad.contains(ramo) && cobertura == 'ITP' && valor <= 6000000) {
                        newOwnerId = queues.get('Indemnizaciones_Alta_Complejidad_Amparo');
                    }
                    if(newOwnerId != null){
                        claimToUpdate.OwnerId = newOwnerId;
                    }
                }
            }
            
        }  
        
    }

    private static Map<String,Id> getQueues() {
        Map<String, Id> queues = new Map<String, Id>();

        List<Group> groups = [
            SELECT Id, DeveloperName
            FROM Group
            WHERE Type = 'Queue' AND DeveloperName IN (
                'Indemnizaciones_Ramo_Desempleo',
                'Indemnizaciones_Ramo_Vida_Grupo',
                'Indemnizaciones_Linea_Rapida',
                'Indemnizaciones_Alta_Complejidad',
                'Indemnizaciones_Alta_Complejidad_Amparo'
            )
        ];
        
        for (Group que : groups) {
            String queueName = que.DeveloperName;
            queues.put(queueName, que.Id);
        }

        return queues;
    }
}