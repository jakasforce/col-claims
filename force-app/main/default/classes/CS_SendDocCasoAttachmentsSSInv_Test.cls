/*****************************************************************************************************************************
 * Apex Class Name	:	CS_SendDocCasoAttachmentsSSInv_Test 
 * Version			:	1.0
 * Created Date	    :	14/09/2022
 * Function 		: 	Prueba el funcionamiento de la clase CS_SendCaseSSInvocable CS_SendDocCasoAttachmentsSSInv
 * Test Class		:	???
 *----------------------------------------------------------------------------------------------------------------------------
 *                                                MODIFICATION LOG
 *----------------------------------------------------------------------------------------------------------------------------
 * Developer		     	Date			   	Description
 * ---------------------------------------------------------------------------------------------------------------------------
 * Fernanda Villafaña           14/09/2022          Original Version
 *****************************************************************************************************************************/
@istest
class CS_SendDocCasoAttachmentsSSInv_Test {
    @isTest
	static void sendDocCaso() {
        Map<Schema.SObjectField, Object> customFieldsMap= new Map<Schema.SObjectField, Object>();
        customFieldsMap.put(Case.Status, 'Escalado');
        Case caso= CS_TestDataFactory.createCase(customFieldsMap,true);
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Test',
            PathOnClient = 'Test.pdf',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion;
        ContentVersion content= [Select ID, FileExtension, VersionData, title, ContentDocumentId FROM ContentVersion WHERE isLatest=true LIMIT 1];
        CS_DocumentoCaso__c doc= new CS_DocumentoCaso__c();
        doc.CS_Caso__c=caso.Id;
        doc.CS_SmartSupervisionTemporalURL__c='www.temporal.com/6498494?';
        doc.CS_MomentoEnvio__c='Escalado';
        doc.CS_EstadoSincronizacionSuperfinanciera__c = 'No enviado';
        insert doc;
        ContentDocumentLink con= new ContentDocumentLink();
        con.ContentDocumentId= content.ContentDocumentId;
        con.LinkedEntityId=doc.Id;
        insert con;
        List<CS_DocumentoCaso__c> lstDocs = new List<CS_DocumentoCaso__c>();
        lstDocs.add(doc);
        Test.setMock(HttpCalloutMock.class, new mockAddFile());
        CS_SmartSupervisionConstants__c cons= new CS_SmartSupervisionConstants__c();
        cons.CS_GetComplainsEndpoint__c='http://endpoint.com';
        cons.CS_GetFileEndpoint__c='http://endpoint.com';
        cons.CS_SmartSupervisionUsername__c='username';
        insert cons;
        test.startTest();
        CS_SendDocCasoAttachmentsSS_Invocable.sendAttachedFile(lstDocs);
        test.stopTest();
        CS_DocumentoCaso__c docActualizado=[SELECT Id, CS_EstadoSincronizacionSuperfinanciera__c FROM CS_DocumentoCaso__c WHERE Id=:doc.Id];  
        System.assertEquals('Enviado', docActualizado.CS_EstadoSincronizacionSuperfinanciera__c, 'No se creó correctamente la queja');
        
    }
private class mockAddFile implements HttpCalloutMock {
  	public HTTPResponse respond(HTTPRequest req) {
        if(req.getEndpoint()=='callout:SmartSupervision/login/'){
			HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"refresh":"refresh1234", "access":"access456"}');
            response.setStatusCode(200);
            response.setStatus('Success');
            return response;               
        }else{
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            CS_WrapperSmartSupervision.AddFileResponseType res= new CS_WrapperSmartSupervision.AddFileResponseType();
            res.type='tipo';
            res.id=1212;
            response.setBody(JSON.serialize(res));
            response.setStatusCode(201);
            response.setStatus('Success');
            return response; 
        }   
    	}
}
}