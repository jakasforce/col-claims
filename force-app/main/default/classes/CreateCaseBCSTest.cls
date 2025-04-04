/*****************************************************************************************************************************
 * Apex Class Name	:	CreateCaseBCSTest
 * Version			:	1.0
 * Created Date	    :	18/06/2024
 * Created By       :   VASS COMPANY
 * Function 		: 	Clase con los metodos invocables para integracion con StarServices
 * Clase Cubre  	:	CreateCaseBCS
 *----------------------------------------------------------------------------------------------------------------------------
 *                     MODIFICATION LOG
 *----------------------------------------------------------------------------------------------------------------------------
 * Developer		     	Date			   	Description
 * ---------------------------------------------------------------------------------------------------------------------------
 * Fernando Torres        18/06/2024         Original Version
 *****************************************************************************************************************************/


@isTest
private class CreateCaseBCSTest {

    //Test exitoso para el metodo principal de la clase 
    @isTest
    static void testDoGPost() {
        
        String bodytemporal = '{"cuenta": {"TipoIdentificacionNatural":null,"NumeroIdentificacionContacto":"1004587878","TipoIdentificacionContacto":"1","NombreContacto":"prueba 4-5-2025","CorreoElectronicoContacto": "PRUEBA@gmail.com","TipoIdentificacionNatural":"","NumeroIdentificacionNatural": "","TipoIdentificacionJuridica" : "3","NumeroIdentificacionJuridica" : "987456248", "PrimerNombre": "a b c ", "PrimerApellido": "d e f ", "NombreDeLaCuenta" : "Juridica prueba hoy 7-04-2024", "CorreoElectronico": "pruebauno@gmail.com", "Telefono": "3114587955", "Ciudad":"1", "Sexo":"2" }, "caso": { "CodigoQueja": "123-tyu", "FechaRadicacionEnLaCompania": "2024-08-08", "FechaRecepcionEnte":"2024-08-08", "FechaTentativaCierre":"2024-08-08", "Descripcion": "prueba start service hoy 8-04-2024",  "Asunto": "Asunto del caso", "Estado": "3", "PuntoDeRecepcion": "Internet",  "Canal": "1", "PaisDeIncidencia": "170", "DepartamentoDeIncidencia": "05", "MunicipioDeIncidencia": "05002", "Motivo": "P2_0001", "Submotivo": "P2_0001_0009",  "QuejaExpres": "2", "Enlace": "asd",  "TipoEnlace":"",  "Replica" : false,  "ArgumentoReplica" : ""  },  "listAttachments": [   {   "comments": "Comentario del adjunto 1",  "extensionFile": "pdf",  "fileName": "adjunto1.pdf",  "pathSourceFile":"",  "sourceFileType":"",  "confirmationCode":"",  "idActivity":""  },  {  "comments": "Comentario del adjunto 2",  "extensionFile": "jpg",  "fileName": "adjunto2.jpg",  "pathSourceFile":"",  "sourceFileType":"",  "confirmationCode":"",   "idActivity":""  },  {  "comments": "Comentario del adjunto 3",  "extensionFile": "docx",  "fileName": "adjunto3.docx",  "pathSourceFile":"",  "sourceFileType":"",  "confirmationCode":"",  "idActivity":""  }    ]  }';
		
        
        RestRequest restRequest = new RestRequest();
        restRequest.requestURI = '/services/apexrest/CreateCaseBCS';
        restRequest.httpMethod = 'POST';
        restRequest.requestBody = Blob.valueOf(bodytemporal);

        RestContext.request = restRequest;
        RestContext.response = new RestResponse();

        // Ejecutar el método doGPost
        Test.startTest();
        CreateCaseBCS.doGPost();
        Test.stopTest();

        // Verificar la respuesta
        RestResponse restResponse = RestContext.response;
        System.assertEquals(200, restResponse.statusCode, 'Status code should be 200');
        System.assertEquals('{"message": "Caso creado exitosamente"}', restResponse.responseBody.toString(), 'Response body is incorrect');
    }
    
    
    //Test para las replicas 
    @isTest
    static void testDoGPostReplica() {
        
        String bodytemporalreplica = '{"cuenta": {"TipoIdentificacionNatural":"1","NumeroIdentificacionNatural": "1002477777","TipoIdentificacionJuridica" : "","NumeroIdentificacionJuridica" : "", "PrimerNombre": "a b c ", "PrimerApellido": "d e f ", "NombreDeLaCuenta" : "Juridica prueba hoy 7-04-2024", "CorreoElectronico": "pruebauno@gmail.com", "Telefono": "3114587955", "Ciudad":"1", "Sexo":"2" }, "caso": { "CodigoQueja": "123-tyu", "FechaRadicacionEnLaCompania": "2024-08-08", "FechaRecepcionEnte":"2024-08-08", "FechaTentativaCierre":"2024-08-08", "Descripcion": "prueba start service hoy 8-04-2024",  "Asunto": "Asunto del caso", "Estado": "3", "PuntoDeRecepcion": "Internet",  "Canal": "1", "PaisDeIncidencia": "170", "DepartamentoDeIncidencia": "05", "MunicipioDeIncidencia": "05002", "Motivo": "P2_0001", "Submotivo": "P2_0001_0009",  "QuejaExpres": "2", "Enlace": "asd",  "TipoEnlace":"01",  "Replica" : false,  "ArgumentoReplica" : ""  },  "listAttachments": [{}] }';
		
        
        RestRequest restRequest = new RestRequest();
        restRequest.requestURI = '/services/apexrest/CreateCaseBCS';
        restRequest.httpMethod = 'POST';
        restRequest.requestBody = Blob.valueOf(bodytemporalreplica);

        RestContext.request = restRequest;
        RestContext.response = new RestResponse();

        // Ejecutar el método doGPost
        Test.startTest();
        CreateCaseBCS.doGPost();
        Test.stopTest();

        // Verificar la respuesta
        RestResponse restResponse = RestContext.response;
        System.assertEquals(200, restResponse.statusCode, 'Status code should be 200');
        System.assertEquals('{"message": "Caso creado exitosamente"}', restResponse.responseBody.toString(), 'Response body is incorrect');
    }
    
    
    //Test en caso de un error del servicio 
    @isTest
    static void testDoGPostError() {
        
        String bodytemporalreplica = '{"cuenta": {"TipoIdentificacionNatural":"1","NumeroIdentificacionNatural": "1002477777","TipoIdentificacionJuridica" : "","NumeroIdentificacionJuridica" : "", "PrimerNombre": "a b c ", "PrimerApellido": "d e f ", "NombreDeLaCuenta" : "Juridica prueba hoy 7-04-2024", "CorreoElectronico": "pruebauno@gmail.com", "Telefono": "3114587955", "Ciudad":"1", "Sexo":"2" }, "caso": { "CodigoQueja": "123-tyu", "FechaRadicacionEnLaCompania": "2024-08-08", "FechaRecepcionEnte":"2024-08-08", "FechaTentativaCierre":"2024-08-08", "Descripcion": "prueba start service hoy 8-04-2024",  "Asunto": "Asunto del caso", "Estado":"01", "PuntoDeRecepcion": "Internet",  "Canal": "1", "PaisDeIncidencia": "170", "DepartamentoDeIncidencia": "05", "MunicipioDeIncidencia": "05002", "Motivo": "P2_0001", "Submotivo": "P2_0001_0009",  "QuejaExpres": "2", "Enlace": "asd",  "TipoEnlace":"01",  "Replica" : false,  "ArgumentoReplica" : ""  },  "listAttachments": [{}] }';
		
        
        RestRequest restRequest = new RestRequest();
        restRequest.requestURI = '/services/apexrest/CreateCaseBCS';
        restRequest.httpMethod = 'POST';
        restRequest.requestBody = Blob.valueOf(bodytemporalreplica);

        RestContext.request = restRequest;
        RestContext.response = new RestResponse();

        // Ejecutar el método doGPost
        Test.startTest();
        CreateCaseBCS.doGPost();
        Test.stopTest();

        // Verificar la respuesta
        RestResponse restResponse = RestContext.response;
        System.assertEquals(400, restResponse.statusCode, 'Status code should be 200');
    }
}