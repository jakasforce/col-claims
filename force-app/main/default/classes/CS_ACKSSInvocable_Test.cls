/*****************************************************************************************************************************
 * Apex Class Name	:	CS_ACKSS_Invocable
 * Version			:	1.0
 * Created Date	    :	14/09/2022
 * Function 		: 	Prueba el funcionamiento de la clase CS_ACKSS_Invocable
 * Test Class		:	???
 *----------------------------------------------------------------------------------------------------------------------------
 *                                                MODIFICATION LOG
 *----------------------------------------------------------------------------------------------------------------------------
 * Developer		     	Date			   	Description
 * ---------------------------------------------------------------------------------------------------------------------------
 * Fernanda Villafaña           14/09/2022          Original Version
 *****************************************************************************************************************************/
@istest
class CS_ACKSSInvocable_Test {
    @isTest
	static void ackss() {
        Case caso= CS_TestDataFactory.createCase(true); 
        List<Case>lstCasos= new List<Case>();
        lstCasos.add(caso);
        Test.setMock(HttpCalloutMock.class, new mockAck());
        CS_SmartSupervisionConstants__c cons= new CS_SmartSupervisionConstants__c();
        cons.CS_GetComplainsEndpoint__c='http://endpoint.com';
        cons.CS_GetFileEndpoint__c='http://endpoint.com';
        cons.CS_SmartSupervisionUsername__c='username';
        insert cons;
        test.startTest();
        CS_ACKSS_Invocable.ack(lstCasos);
        test.stopTest();
        List<CS_Log__c> logs=[SELECT Id, CS_ShortDescription__c FROM CS_Log__c];
        system.assertEquals('Smart Supervision: Momento 1 - ACK (CORRECTO)', logs[0].CS_ShortDescription__c, 'Error crear log');
    }
    
private class mockAck implements HttpCalloutMock {
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
        CS_WrapperSmartSupervision.ACKResponseType res= new CS_WrapperSmartSupervision.ACKResponseType();
       	res.message='Mensaje';
        List<String> lstErrs= new List<String>();
        res.pqrs_error=lstErrs;
        response.setBody(JSON.serialize(res));
        response.setStatusCode(200);
        response.setStatus('Success');
        return response;
        }   
    	}
}
}