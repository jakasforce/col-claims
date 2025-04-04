/**
**************************************************************************************************************
* @Desarrollado por Vass
* @Autor            Darien Romero
* @Projecto         Colmena
* @Descripcion      API casos (Tipo y Numero documento o Numero de Atel)
* Cambios (Versiones)
* --------   ---   ----------   ---------------------------   ------------------------------------------------
*            No.   Fecha         Autor                        Descripcion
* --------   ---   ----------   ---------------------------   ------------------------------------------------
*            1.0   21-MAR-2024  Darien Romero                 Creacion Clase.
**************************************************************************************************************
***/
@RestResource(urlMapping='/api/Case/getCases/*')
global with sharing class WsGetCaseService {

    @HttpGet
    global static List<CaseWrapper> getCases() {
        List<CaseWrapper> casosWrappers = new List<CaseWrapper>();
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;

        try {
            String tipoDoc = req.params.get('tipoDoc');
            String numDoc  = req.params.get('numDoc');
            String numAtel = req.params.get('numAtel');

            if (tipoDoc != null && numDoc != null) {
                casosWrappers = getCaseByTipoNumDoc(casosWrappers, tipoDoc, numDoc);
                if ( casosWrappers.isEmpty() ) handleNoRecordsFound(res, casosWrappers);
            } else if (numAtel != null) {
                casosWrappers = getCaseByNumAtel(casosWrappers, numAtel);
                if ( casosWrappers.isEmpty() ) handleNoRecordsFound(res, casosWrappers);
            } else { 
                handleInvalidParameters(res, casosWrappers); 
            }
            return casosWrappers;
        } catch (Exception ex) {
            handleException(res, ex);
            return null;
        }
    }
    
    public static List<CaseWrapper> getCaseByTipoNumDoc( List<CaseWrapper> casosWrappers, string tipoDoc, string numDoc ) {
        
            List<Case> casos = 
                [
                    SELECT Id, CaseNumber, RecordType.Name, Description, CS_MacroMotivo__c, 
                    CS_Submotivo__c, Status, CS_FechaTentativaDeCierre__c, CS_Semaforotexto__c 
                    FROM Case 
                    WHERE Contact.CS_TipoIdentificacionCP__c =: tipoDoc 
                    AND Contact.CS_NumeroIdentificacionCP__c =: numDoc
                    AND (RecordType.DeveloperName = 'CS_Solicitud' OR RecordType.DeveloperName = 'CS_Novedad' OR RecordType.DeveloperName = 'CS_Incidente') 
                    AND CS_Numero_de_ATEL__c <> null
                ];

        if ( !casos.isEmpty() ) {
            for (Case c : casos) {
                casosWrappers.add(new CaseWrapper(c));
            }
        }
        
        return casosWrappers;
    }
    
    public static List<CaseWrapper> getCaseByNumAtel( List<CaseWrapper> casosWrappers, string numAtel ) {
        
        List<Case> casos = 
            [
                SELECT id, CaseNumber, RecordType.name, Description, CS_MacroMotivo__c, CS_Submotivo__c, 
                Status, CS_FechaTentativaDeCierre__c, CS_Semaforotexto__c 
                FROM case 
                WHERE CS_Numero_de_ATEL__r.name =: numAtel
                AND (RecordType.DeveloperName = 'CS_Solicitud' OR RecordType.DeveloperName = 'CS_Novedad' OR RecordType.DeveloperName = 'CS_Incidente') 
                AND CS_Numero_de_ATEL__c <> null
            ];
        
        if ( !casos.isEmpty() ) {
            for (Case c : casos) {
                casosWrappers.add(new CaseWrapper(c));
            }
        }
        
        return casosWrappers;
    }
    
    public static void handleNoRecordsFound(RestResponse res, List<CaseWrapper> casosWrappers) {
        res.statusCode = 404;
        CaseWrapper ress = new CaseWrapper(new case());
        ress.msg = 'No se encontraron registros para los criterios especificados';
        casosWrappers.add(ress);
        res.responseBody = Blob.valueOf('No se encontraron registros para los criterios especificados.');
    }

    public static void handleInvalidParameters(RestResponse res, List<CaseWrapper> casosWrappers) {
        res.statusCode = 400; // Código de estado HTTP 400 - Bad Request
        CaseWrapper ress = new CaseWrapper(new case());
        ress.msg = 'Se requieren parámetros válidos para realizar la consulta';
        casosWrappers.add(ress);
        res.responseBody = Blob.valueOf('Se requieren parámetros válidos para realizar la consulta.');
    }

    public static void handleException(RestResponse res, Exception ex) {
        res.statusCode = 500; // Código de error interno del servidor
        res.responseBody = Blob.valueOf('Se produjo un error al procesar la solicitud: ' + ex.getMessage());
    }
    
    global class CaseWrapper {
        public string msg;
        public String Id;
        public String CaseNumber;
        public String RecordTypeName;
        public String Description;
        public String CS_MacroMotivo;
        public String CS_Submotivo;
        public String Status;
        public Date   CS_FechaTentativaDeCierre;
        public String CS_Semaforotexto;
        
        public CaseWrapper(Case c) {
            if (c != null) {
                this.Id = c.Id;
                this.CaseNumber = c.CaseNumber;
                this.RecordTypeName = c.RecordType.Name;
                this.Description = c.Description;
                this.CS_MacroMotivo = c.CS_MacroMotivo__c;
                this.CS_Submotivo = c.CS_Submotivo__c;
                this.Status = c.Status;
                this.CS_FechaTentativaDeCierre = c.CS_FechaTentativaDeCierre__c;
                this.CS_Semaforotexto = c.CS_Semaforotexto__c;
            }
        }
    }
}