/**
 * @author Harold Garcia Vargas
 * @email harold.garcia@vasscompany.com
 * @create date 2024-06-07 09:01:40
 * @modify date 2024-06-07 09:01:40
 * @desc [La clase Apex `ChecklistController` inserta y actualiza registros `CheckListProvider__c` desde datos JSON, 
 * asignándolos a un prospecto específico, y genera un PDF codificado en base64 desde una página Visualforce usando el `prospectoId`.]
 */

public with sharing class ChecklistController {
    
    @AuraEnabled
    public static String guardarEvaluaciones(String jsonData, Id prospectoId) {
        List<CheckListProvider__c> recordsToUpsert = new List<CheckListProvider__c>();
        
        // Convertir el JSON a lista de objetos CheckListProvider__c
        List<Object> jsonObjects = (List<Object>) JSON.deserializeUntyped(jsonData);
        for(Object obj : jsonObjects) {
            Map<String, Object> recordMap = (Map<String, Object>) obj;
            // Verificar si el registro ya existe utilizando el campo externo
            String externalId = (String) recordMap.get('id');
            List<CheckListProvider__c> existingRecords = [SELECT Id, External_Id__c FROM CheckListProvider__c WHERE External_Id__c = :externalId LIMIT 1];
            CheckListProvider__c newRecord;
            if (!existingRecords.isEmpty()) {
                // Si el registro existe, actualizarlo
                newRecord = existingRecords[0];
            } else {
                // Si el registro no existe, crear uno nuevo
                newRecord = new CheckListProvider__c();
            }
            // Asignar los valores del objeto
            newRecord.Lead__c = prospectoId; // Asignar el ID del prospecto
            newRecord.Id__c =  (String) recordMap.get('ids');
            newRecord.External_Id__c = externalId;
            newRecord.Criterion__c = (String) recordMap.get('criterio');
            newRecord.SubCriterion__c = (String) recordMap.get('subCriterio');
            newRecord.State__c = (String) recordMap.get('estado');
            newRecord.Qualification__c = (String) recordMap.get('calificacion');
            newRecord.RatingObservation__c = (String) recordMap.get('observacionCalificacion');
            newRecord.ObservationInCaseOfInactivation__c = (String) recordMap.get('observacionInactivacion');
            recordsToUpsert.add(newRecord);
        }

        // Insertar o actualizar los registros en Salesforce
        try {
            upsert recordsToUpsert CheckListProvider__c.Fields.External_Id__c;
            return 'Registros guardados exitosamente';
        } catch(Exception e) {
            throw new AuraHandledException('Error al guardar los registros: ' + e.getMessage());
        }
    }
    @AuraEnabled
    public static String generarPDF(Id prospectoId) {
        PageReference pdfPage = Page.ChecklistPDFPage; // Nombre de la página Visualforce que se creará
        pdfPage.getParameters().put('prospectoId', prospectoId);
        Blob pdfBlob = pdfPage.getContentAsPDF();
        return EncodingUtil.base64Encode(pdfBlob);
    }
}