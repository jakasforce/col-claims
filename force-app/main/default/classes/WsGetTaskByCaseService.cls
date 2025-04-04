/**
**************************************************************************************************************
* @Desarrollado por Vass
* @Autor            Darien Romero
* @Projecto         Colmena
* @Descripcion      API Tareas (Filtros)
* Cambios (Versiones)
* --------   ---   ----------   ---------------------------   ------------------------------------------------
*            No.   Fecha         Autor                        Descripcion
* --------   ---   ----------   ---------------------------   ------------------------------------------------
*            1.0   27-MAR-2024  Darien Romero                 Creacion Clase.
*            1.1   03-ABR-2024  Darien Romero                 Se ajusta para que retorne tambien createDate 
**************************************************************************************************************
**/
@RestResource(urlMapping='/api/Task/getTask/*')
global with sharing class WsGetTaskByCaseService {

    @HttpGet
    global static List<TaskWrapper> getTask() {
        list<TaskWrapper> tareasWrapper = new list<TaskWrapper>();
        RestRequest  req = RestContext.request;
        RestResponse res = RestContext.response;

        try {
            String idPQR = req.params.get('id');
            id pqrId = null;
            
            if ( idPQR != null ) {
                try {
                    pqrId = id.valueOf(idPQR);
                    tareasWrapper = getTaskQuery(tareasWrapper,pqrId);
                    if ( tareasWrapper.isEmpty() ) handleNoRecordsFound(res, tareasWrapper);
                } catch(exception e) {
                    handleInvalidParameters(res, tareasWrapper);
                }
            } else {
                handleInvalidParameters(res, tareasWrapper);
            }
            return tareasWrapper;
        } catch(exception ex) {
            handleException(res, ex);
            return null;
        }
    }
    
    public static List<TaskWrapper> getTaskQuery( list<TaskWrapper> tareasWrapper, id pqrId ) {
        
        //Buscar los roles válidos
        list<string> roles = label.ws_rolesValidar.split(';');
        
        list<task> tareas = 
            [
                SELECT id, WhatId, RecordType.name, Subject, Description, ActivityDate, OwnerId, Status, Owner.UserRole.name, CreatedDate
                FROM task
                WHERE (What.RecordType.DeveloperName = 'CS_Solicitud' OR What.RecordType.DeveloperName = 'CS_Novedad' OR What.RecordType.DeveloperName = 'CS_Incidente')
                AND WhatId =: pqrId
            ];
        
        if (!tareas.isEmpty()) {
            
            for ( task act : tareas ) {
                //tareasWrapper.add(new TaskWrapper(act)); //para test
                
                if ( roles.contains(act.Owner.UserRole.name) ) {
                    tareasWrapper.add(new TaskWrapper(act));
                }
            }
            
        }
        return tareasWrapper;
    }
    
    public static void handleNoRecordsFound(RestResponse res, List<TaskWrapper> tareasWrapper) {
        res.statusCode = 404;
        TaskWrapper ress = new TaskWrapper(new task());
        ress.msg = 'No se encontraron registros';
        tareasWrapper.add(ress);
        res.responseBody = Blob.valueOf('No se encontraron registros.');
    }
    
    public static void handleInvalidParameters(RestResponse res, List<TaskWrapper> tareasWrapper) {
        res.statusCode = 400; // Código de estado HTTP 400 - Bad Request
        TaskWrapper ress = new TaskWrapper(new task());
        ress.msg = 'Se requieren parámetros válidos para realizar la consulta';
        tareasWrapper.add(ress);
        res.responseBody = Blob.valueOf('Se requieren parámetros válidos para realizar la consulta.');
    }
    
    public static void handleException(RestResponse res, Exception ex) {
        res.statusCode = 500; // Código de error interno del servidor
        res.responseBody = Blob.valueOf('Se produjo un error al procesar la solicitud: ' + ex.getMessage());
    }
        
    global class TaskWrapper {
        public string msg;
        public String Id;
        public String Relacionado;       //WhatId;
        public String RecordTypeName;
        public String Asunto;           //Subject;
        public String Comentario;       //Description;
        public date   FechaVencimiento; //ActivityDate;
        public String Asignado;         //OwnerId;
        public String Estado;           //Status;
        public Date   fechaCreacion;    //CreateDate
            
        public TaskWrapper(Task t) {
            if ( t != null ) {
                this.Id               = t.id;
                this.Relacionado      = t.WhatId;
                this.RecordTypeName   = t.RecordType.name;
                this.Asunto           = t.Subject;
                this.Comentario       = t.Description;
                this.FechaVencimiento = t.ActivityDate;
                this.Asignado         = t.OwnerId;
                this.Estado           = t.Status;
                this.fechaCreacion    = date.valueOf(t.CreatedDate);
            }
        }
    }
}