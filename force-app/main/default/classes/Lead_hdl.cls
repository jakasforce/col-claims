/*************************************************************************************/
/* Desarrollado por: VASS 
/* Autor:            Fernando Torres
/* Proyecto:         CRM
/* Descripción:      Clase administradora de los eventos de Prospecto (Lead)
/* Clase de prueba:  LeadTrigerTest

/*************************************************************************************/ 

public class Lead_hdl {
    
    
    
    // Campos
    private boolean blnIsExecuting = false;
    private integer intBatchSize = 0;    
    
    // Constructor
    public Lead_hdl(boolean isExecuting, integer size){
        blnIsExecuting = isExecuting;
        intBatchSize = size;
    }
    
    public void OnBeforeInsert(Lead[] newRecords){}
    
    public void OnAfterInsert(Lead[] newRecords){
        // Crear una lista para almacenar los IDs de los leads
        List<Id> leadIds = new List<Id>();
        
        // Recorrer los registros de Lead y agregar los IDs a la lista
        for (Lead leadRecord : newRecords) {
            leadIds.add(leadRecord.Id);
        }
        
        // Convertir la lista de IDs en una cadena JSON
        String leadIdsJson = JSON.serialize(leadIds);
        
        // Llamar al método redistributeLeads pasando la cadena JSON con los IDs
        UtilsClass.redistributeLeads(leadIdsJson);
    }
    
    public void OnBeforeUpdate(Lead[] oldRecords, Lead[] updatedRecords, Map<ID, Lead> recordMap){
        system.debug('**'+oldRecords[0].OwnerId);
        system.debug('**'+updatedRecords[0].OwnerId);
    }
    
    public void OnAfterUpdate(Lead[] oldRecords, Lead[] updatedRecords, Map<ID, Lead> recordMap){}
    
}