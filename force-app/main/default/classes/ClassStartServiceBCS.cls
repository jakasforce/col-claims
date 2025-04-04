/*****************************************************************************************************************************
 * Apex Class Name	:	ClassStartServiceBCS
 * Version			:	1.0
 * Created Date	    :	18/06/2024
 * Created By       :   VASS COMPANY
 * Function 		: 	Clase con los metodos invocables para integracion con StarServices
 * Test Class		:	ClassStartServiceBCSTest
 *----------------------------------------------------------------------------------------------------------------------------
 *                     MODIFICATION LOG
 *----------------------------------------------------------------------------------------------------------------------------
 * Developer		     	Date			   	Description
 * ---------------------------------------------------------------------------------------------------------------------------
 * Fernando Torres        18/06/2024         Original Version
 *****************************************************************************************************************************/

public class ClassStartServiceBCS {
    
    public static String IdCasoLog {get;set;}
    public static String idDocumentoLog {get;set;}

    
    //***************************************************************************************************************************//
    //------------------Metodo invocable para descargar documento se llama desde el flujo de pantalla ---------------------------//
    
    @InvocableMethod(label='Metodo descargar docuemento')
    public static void DowloadDocumento(List<String> recordIds) {
        
        try{
            // Fetch document data
            List<CS_DocumentoCaso__c> documentoCaso = [SELECT id, CS_Caso__c,FileExtension__c,Name, CS_Caso__r.CS_CodigoQueja__c FROM CS_DocumentoCaso__c WHERE id =: recordIds[0]];
            String codigoDocumento = documentoCaso[0].CS_Caso__r.CS_CodigoQueja__c;
            IdCasoLog = documentoCaso[0].CS_Caso__c;
            idDocumentoLog = documentoCaso[0].Id;
            String extension = documentoCaso[0].FileExtension__c;
            String name = documentoCaso[0].Name;
    
            // Obtain token (improved error handling)
            modelToken tokenResponse = obtenerToken();
            if (tokenResponse == null) {
                System.debug('@Error obtaining token.');
                return;
            }
    
            // Use the access token for further calls (assuming service requires it)
            String accessToken = tokenResponse.access_token;
            String idContentVersion = obtenerIdContentVersion(accessToken,codigoDocumento,extension,name);
            guardarDocumento(documentoCaso[0].Id,idContentVersion);
            
        }catch(Exception e){
            if(IdCasoLog != ''){
                CS_Log_Helper.createLogSFInternalError('Integracion StarServices obtener documento (FALLIDO)','ClassStartServiceBCS.DowloadDocumento',e , IdCasoLog);
            }else{
                CS_Log_Helper.createLogSFInternalError('Integracion StarServices obtener documento (FALLIDO)','ClassStartServiceBCS.DowloadDocumento',e);
            }
        }
       
    }
    
    
    //***************************************************************************************************************************//
    //-----------------------------------Metodo para relacionar el ContentVersion al DocumentoCaso-------------------------------//
    
	public static void guardarDocumento(String idDocumentoCaso,String idContentVersion){
        
  		try {
            // Obtener el ID del ContentDocument asociado al ContentVersion recién creado por mulesoft
            Id contentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :idContentVersion].ContentDocumentId;
            
            // Crear un nuevo enlace de contenido (ContentDocumentLink) para agregar el documento al registro deseado
            ContentDocumentLink contentlink = new ContentDocumentLink();
            contentlink.LinkedEntityId = idDocumentoCaso;
            contentlink.ContentDocumentId = contentDocumentId;
            contentlink.ShareType = 'I';
            contentlink.Visibility = 'AllUsers';         
            insert contentlink;
            
        } catch (Exception e) {
            System.debug('Error al guardar el documento: ' + e.getMessage());
            CS_Log_Helper.createLogSFInternalError('Integracion StarServices obtener documento (FALLIDO)','ClassStartServiceBCS.guardarDocumento',e);
        }

	}

    
    //***************************************************************************************************************************//
    //-----------------------------Metodo para consumir servicio de mulesoft de obtener documento--------------------------------//
    
    
    public static String obtenerIdContentVersion(String token, String codigoDocumento, String extensionFile, String fileName){
        
		ConfiguracionStartService__mdt endpointDocumento = ConfiguracionStartService__mdt.getInstance('EndpointDocumento');	
        ConfiguracionStartService__mdt govIsType = ConfiguracionStartService__mdt.getInstance('govIssueIdentType');	
        ConfiguracionStartService__mdt clientId = ConfiguracionStartService__mdt.getInstance('ClientIdDocumento');
        ConfiguracionStartService__mdt clientSecret = ConfiguracionStartService__mdt.getInstance('ClientSecretDocumento');
        
        HttpRequest requestObj = new HttpRequest();
        requestObj.setEndpoint(endpointDocumento.value__c);
        requestObj.setMethod('POST');
        requestObj.setTimeout(120000);
        requestObj.setHeader('client_id', clientId.value__c);
        requestObj.setHeader('client_secret', clientSecret.value__c);
        requestObj.setHeader('Content-Type', 'application/json');
        requestObj.setHeader('Authorization','Bearer '+token);
        String jsonBody = createJsonBody(codigoDocumento, extensionFile, fileName);
        requestObj.setBody(jsonBody);
		
        System.debug('endpoint: '+requestObj.getEndpoint());
        System.debug('Request: ' + requestObj.getBody());

        try {
            Http http = new Http();
            HttpResponse responseObj = http.send(requestObj);
            System.debug('Response: ' + responseObj);
            String responseBodyy = responseObj.getBody();
            if (responseObj.getStatusCode() == 200) {
                String responseBody = responseObj.getBody();
                // Analizar el JSON
                CompositeResponse response = (CompositeResponse) JSON.deserialize(responseBody, CompositeResponse.class);
        
                // Obtener el ID del primer elemento de la lista compositeResponse
                String id = response.compositeResponse[0].body.id;
                System.debug('@1@1@1'+id);
                String idversion = '068Nq0000045np0IAA';
				return idversion;
            } else {
                System.debug('Error retrieving document: ' + responseObj.getStatus());
                CS_Log_Helper.createLogApexRestCallout('Integracion StarServices obtener documento (FALLIDO)',responseObj,requestObj,IdCasoLog,idDocumentoLog);
                return null; // Indicate error
            }
        } catch (Exception e) {
            System.debug('Error obtaining document: ' + e.getMessage());
            CS_Log_Helper.createLogSFInternalError('Integracion StarServices obtener documento (FALLIDO)','ClassStartServiceBCS.obtenerIdContentVersion',e);
            return null; // Indicate error
        }
        
        
     } 
    
    
    
    //***************************************************************************************************************************//
    //------------------------------------------------Metodo para obtener token -------------------------------------------------//   

    public static modelToken obtenerToken() {
        ConfiguracionStartService__mdt endpointToken = ConfiguracionStartService__mdt.getInstance('EndpointToken');
        ConfiguracionStartService__mdt clientId = ConfiguracionStartService__mdt.getInstance('ClientIdToken');
        ConfiguracionStartService__mdt clientSecret = ConfiguracionStartService__mdt.getInstance('ClientSecretToken');
        ConfiguracionStartService__mdt grantType = ConfiguracionStartService__mdt.getInstance('GrantTypeToken');

        HttpRequest requestObj = new HttpRequest();
        requestObj.setEndpoint(endpointToken.value__c);
        requestObj.setMethod('POST');
        requestObj.setTimeout(120000);
        requestObj.setHeader('client_id', clientId.value__c);
        requestObj.setHeader('client_secret', clientSecret.value__c);
        requestObj.setHeader('grant_type', grantType.value__c);

        System.debug('Request: ' + requestObj.getBody());

        try {
            Http http = new Http();
            HttpResponse responseObj = http.send(requestObj);
            System.debug('Response: ' + responseObj);

            if (responseObj.getStatusCode() == 200) {
                String responseBody = responseObj.getBody();
                // Parse JSON response using a JSON parser library (e.g., gson or Jackson)
                modelToken tokenResponse = (modelToken) JSON.deserialize(responseBody, modelToken.class);
                return tokenResponse;
            } else {
                System.debug('Error retrieving token: ' + responseObj.getStatus());
                CS_Log_Helper.createLogApexRestCallout('Integracion StarServices obtener documento (FALLIDO) Token',responseObj,requestObj,IdCasoLog,idDocumentoLog);
                return null; // Indicate error
            }
        }catch (Exception e) {
            System.debug('Error obtaining token: ' + e.getMessage());
            return null; // Indicate error
        }
    }
    
    //***************************************************************************************************************************//
    //-----------------------------Metodo para crear json del body para el servicio de mulesoft----------------------------------//
    
    private static String createJsonBody(String claimNumber, String extensionFile, String fileName) {
        // Usar JSONGenerator para construir el JSON
        JSONGenerator gen = JSON.createGenerator(true);
        
        gen.writeStartObject(); // {
        gen.writeFieldName('request');
        gen.writeStartObject(); // "request": {
        gen.writeStringField('claimNumber', claimNumber); // "claimNumber": "1-271711416"
        gen.writeEndObject(); // }
        
        gen.writeFieldName('listAttachments');
        gen.writeStartArray(); // "listAttachments": [
        
        gen.writeStartObject(); // {
        gen.writeFieldName('file');
        gen.writeStartObject(); // "file": {
        gen.writeStringField('extensionFile', extensionFile); // "extensionFile": "docx"
        gen.writeStringField('fileName', fileName); // "fileName": "ARCHIVO_DE_PRUEBA_ADJUNTO_M1"
        gen.writeEndObject(); // }
        gen.writeEndObject(); // }
        
        gen.writeEndArray(); // ]
        gen.writeEndObject(); // }
        
        return gen.getAsString();
    }
    
    // Clases separadas para las respuestas JSON
    // 
    public class CompositeResponse {
        public List<ResponseItem> compositeResponse;
    }
    
    public class ResponseItem {
        public Body body;
        public Map<String, String> httpHeaders;
        public Integer httpStatusCode;
        public String referenceId;
    }
    
    public class Body {
        public String id;
        public Boolean success;
        public List<String> errors;
    }

    public class modelToken {
        public String access_token;
        public String token_type;
        public String expires_in;
    }
}