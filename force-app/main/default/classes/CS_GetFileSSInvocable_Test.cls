/*****************************************************************************************************************************
 * Apex Class Name	:	CS_GetFileSSInvocable_Test
 * Version			:	1.0
 * Created Date	    :	14/09/2022
 * Function 		: 	Prueba el funcionamiento de la clase CS_GetFileSSInvocable
 * Test Class		:	???
 *----------------------------------------------------------------------------------------------------------------------------
 *                                                MODIFICATION LOG
 *----------------------------------------------------------------------------------------------------------------------------
 * Developer		     	Date			   	Description
 * ---------------------------------------------------------------------------------------------------------------------------
 * Fernanda Villafaña           14/09/2022          Original Version
 *****************************************************************************************************************************/
@istest
class CS_GetFileSSInvocable_Test {
    @isTest
	static void getFile() {
        Case caso= CS_TestDataFactory.createCase(true); 
        CS_DocumentoCaso__c doc= new CS_DocumentoCaso__c();
        doc.CS_Caso__c=caso.Id;
        doc.CS_SmartSupervisionTemporalURL__c='www.temporal.com/6498494?';
        insert doc;
        List <CS_DocumentoCaso__c> lstDocs= new List <CS_DocumentoCaso__c>();
        lstDocs.add(doc);
        Test.setMock(HttpCalloutMock.class, new mockFiles());
        CS_SmartSupervisionConstants__c cons= new CS_SmartSupervisionConstants__c();
        cons.CS_GetComplainsEndpoint__c='http://endpoint.com';
        cons.CS_GetFileEndpoint__c='http://endpoint.com';
        cons.CS_SmartSupervisionUsername__c='username';
        insert cons;
        test.startTest();
        CS_GetFileSS_Invocable.obtenerDocumentoCaso(lstDocs);
        test.stopTest();
        List <Attachment> att=[SELECT id FROM Attachment WHERE parentId=:doc.Id];
        System.assertEquals(1, att.size(), 'No se creo el attachment');
        
    }
private class mockFiles implements HttpCalloutMock {
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
        CS_WrapperSmartSupervision.GetFileResponseType res= new CS_WrapperSmartSupervision.GetFileResponseType();
       	res.blobFile=Blob.valueOf('File');
        response.setBody(JSON.serialize(res));
        response.setStatusCode(200);
        response.setStatus('Success');
        return response;
        }   
    	}
} 
}