/********************************************************************
Apex Class Name :   ServicioArchivo
Version         :   1.0
Created Date    :   31/10/2022
Function        :   Integración que expone el servicio #12 
Test Class      :   

Modification Log
*--------------------------------------------------------------------
* Developer             Date                Description
* ------------------------------------------------------------------
* Luis Naranjo    31/10/2022         Versión original
* 
*********************************************************************/
@RestResource(urlMapping='/servicio-archivo')
global with sharing class ServicioArchivo {

    final static String CLOUD_FIELDSERVICE = 'field';

    @HttpGet
    global static String doGet() {
        return 'se invocó get';
    }
    
     @HttpPost
    global static String doPost(String idCloud, String idSoporte){

        // Para que se usa el parametro IdCloud en esta implementación?
        if(idCloud != null && idSoporte != null && CLOUD_FIELDSERVICE.equals(idCloud.toLowerCase())){
            
            // Validar si existe ID en Salesforce (Soporte Sesión)
            String contentDocumentLinkId = [SELECT XFLS_ContentDocumentLinkId__c FROM XFLS_Soporte_Sesion__c WHERE Id = :idSoporte WITH SECURITY_ENFORCED]?.XFLS_ContentDocumentLinkId__c; 
            if (contentDocumentLinkId != null){

                // Validar si el archivo vive en Salesforce
                String contentDocumentId = [SELECT contentDocumentId from ContentDocumentLink WHERE id = :contentDocumentLinkId WITH SECURITY_ENFORCED]?.contentDocumentId;
                if (contentDocumentId != null) {
                    
                    // Obtención del contentVersión
                    Contentversion cv = [SELECT versionData, fileExtension, fileType from ContentVersion where ContentDocumentId = :contentDocumentId WITH SECURITY_ENFORCED];
                    String base64 = EncodingUtil.base64Encode(cv.versionData);
                    String MIMEType = cv.fileType+'/'+cv.fileExtension;

                    // Se envia en soporte en formado base 64
                    XFLS_WrapperSendaGCP2.responseArchivoSoporte responseBodyAS = new XFLS_WrapperSendaGCP2.responseArchivoSoporte();                
                    responseBodyAS.id = idSoporte;
                    responseBodyAS.message = 'Soporte desde Salesforce';
                    responseBodyAS.status = 200;
                    responseBodyAS.archivoSoporte = 'data:'+MIMEType+';base64:'+base64;
                    responseBodyAS.pathAzure = null;
                    return JSON.serialize(responseBodyAS);
                } else {
                    
                     return 'El recurso pedido no existe';
                    
                    
                    /* Validar si existe en Azure
                    /* TODO: Implementar en segunda etapa
					String pathAzure = null;
                    if(pathAzure != null){
                        
                        // Respuesta correcta
                        XFLS_WrapperSendaGCP2.responseArchivoSoporte responseBodyAS = new XFLS_WrapperSendaGCP2.responseArchivoSoporte();
                        responseBodyAS.id = idSoporte;
                        responseBodyAS.message = 'Soporte desde Azure';
                        responseBodyAS.status = 200;
                        responseBodyAS.archivoSoporte = null;                    
                        responseBodyAS.pathAzure = '';
                        return JSON.serialize(responseBodyAS);
                    }                  
                        
                    // Respuesta incorrecta
                    XFLS_WrapperSendaGCP2.responseArchivoSoporte responseBodyAS = new XFLS_WrapperSendaGCP2.responseArchivoSoporte();
                    responseBodyAS.id = 0;
                    responseBodyAS.message = 'El recurso pedido no existe';
                    responseBodyAS.status = 404;                    
                    responseBodyAS.archivoSoporte = null;                    
                    responseBodyAS.pathAzure = null;
                    return JSON.serialize(responseBodyAS);
                    */
                }
            }else {

                // Operation failed
                CS_Log__c logSA = new CS_Log__c(); logSA.CS_ShortDescription__c='Error. No existe Id en Salesforce'; logSA.CS_Funcion__c='Consultar Archivo';
                logSA.CS_ExceptionStackTrace__c='ServicioArchivo'; logSA.CS_RequestMethod__c='POST'; logSA.CS_RequestEndPoint__c='/services/apexrest/servicio-archivo';
                insert logSA; return logSA.CS_ShortDescription__c;
            }
        }else {
            
            // Operation failed
            CS_Log__c logSA = new CS_Log__c(); logSA.CS_ShortDescription__c='Error. Datos incorrectos'; logSA.CS_Funcion__c='Consultar Archivo';
            logSA.CS_ExceptionStackTrace__c='ServicioArchivo'; logSA.CS_RequestMethod__c='POST'; logSA.CS_RequestEndPoint__c='/services/apexrest/servicio-archivo';
            insert logSA; return logSA.CS_ShortDescription__c;            
        }        
    }
}