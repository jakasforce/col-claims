/*****************************************************************************************************************************
 * Apex Class Name	:	CS_ACKSS_Invocable
 * Version			:	1.0
 * Created Date	    :	14/09/2022
 * Function 		: 	Prueba el funcionamiento de la clase CS_GetComplainFilesSS_Invocable
 * Test Class		:	???
 *----------------------------------------------------------------------------------------------------------------------------
 *                                                MODIFICATION LOG
 *----------------------------------------------------------------------------------------------------------------------------
 * Developer		     	Date			   	Description
 * ---------------------------------------------------------------------------------------------------------------------------
 * Fernanda Villafaña           14/09/2022          Original Version
 *****************************************************************************************************************************/
@istest
class CS_GetComplainFilesSSInvocable_Test {
    @isTest
	static void complainFiles() {
        Case caso= CS_TestDataFactory.createCase(true);  
        Test.setMock(HttpCalloutMock.class, new mockGetFiles());
        CS_SmartSupervisionConstants__c cons= new CS_SmartSupervisionConstants__c();
        cons.CS_GetComplainsEndpoint__c='http://endpoint.com';
        cons.CS_GetFileEndpoint__c='http://endpoint.com';
        cons.CS_SmartSupervisionUsername__c='username';
        insert cons;
        List <Case> lstCasos= new List <Case>();
        lstCasos.add(caso);
        test.startTest();
        CS_GetComplainFilesSS_Invocable.getComplainFiles(lstCasos);
         test.stopTest();
         CS_DocumentoCaso__c newFile=[SELECT Id FROM CS_DocumentoCaso__c];
         Case casoActualizado=[SELECT Id, CS_SmartSupervisionACK__c, CS_SmartSupervisionNuevosAdjuntos__c FROM Case WHERE Id=:caso.Id];
         System.assertNotEquals(null,newFile, 'No se creo el documento');
         System.assertEquals(true, casoActualizado.CS_SmartSupervisionACK__c, 'Error al actualizar el caso');
        
    }
      private class mockGetFiles implements HttpCalloutMock {
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
            CS_WrapperSmartSupervision.GetComplainFilesResponseType res= new CS_WrapperSmartSupervision.GetComplainFilesResponseType();
            res.count=1;
            res.pages=1;
            res.current_page=1;
            res.next='next';
            res.previous='previous';
            CS_WrapperSmartSupervision.ComplainFileResponseType com= new CS_WrapperSmartSupervision.ComplainFileResponseType();
            List<CS_WrapperSmartSupervision.ComplainFileResponseType> lstcom= new List<CS_WrapperSmartSupervision.ComplainFileResponseType>();
            com.id=1216;
            com.file='Files';
            lstcom.add(com);
            res.results=lstcom;
            response.setBody(JSON.serialize(res));
            response.setStatusCode(200);
            response.setStatus('Success');
            return response; 
        }   
    	}
}
}