/*****************************************************************************************************************************
 * Apex Class Name	:	CS_UpdateCaseSSInvocable_Test 
 * Version			:	1.0
 * Created Date	    :	14/09/2022
 * Function 		: 	Prueba el funcionamiento de la clase CS_UpdateCaseSSInvocable
 * Test Class		:	???
 *----------------------------------------------------------------------------------------------------------------------------
 *                                                MODIFICATION LOG
 *----------------------------------------------------------------------------------------------------------------------------
 * Developer		     	Date			   	Description
 * ---------------------------------------------------------------------------------------------------------------------------
 * Fernanda Villafaña           14/09/2022          Original Version
 *****************************************************************************************************************************/
@istest
class CS_UpdateCaseSSInvocable_Test {
    @isTest
	static void updateCase() {
        Map<Schema.SObjectField, Object> customFieldsMap= new Map<Schema.SObjectField, Object>();
        customFieldsMap.put(Account.CS_Empresa_Colmena__c, '1');
        customFieldsMap.put(Account.CS_NumeroIdentificacionCP__pc, '99999');
        customFieldsMap.put(Account.CS_TipoIdentificacionCP__pc, '1');
        Account acc= CS_TestDataFactory.createPersonAccount(customFieldsMap,true);
        Map<Schema.SObjectField, Object> customFieldsMap1= new Map<Schema.SObjectField, Object>();
        customFieldsMap1.put(Case.AccountId, acc.Id);
        Case caso= CS_TestDataFactory.createCase(customFieldsMap1,true);
        List<Case>lstCasos= new List<Case>();
        lstCasos.add(caso);
        Test.setMock(HttpCalloutMock.class, new mockUpdateCase());
        CS_SmartSupervisionConstants__c cons= new CS_SmartSupervisionConstants__c();
        cons.CS_GetComplainsEndpoint__c='http://endpoint.com';
        cons.CS_GetFileEndpoint__c='http://endpoint.com';
        cons.CS_SmartSupervisionUsername__c='username';
        insert cons;
        test.startTest();
        CS_UpdateCaseSS_Invocable.actualizarQuejaSuperFinanciera(lstCasos);
        test.stopTest();
        Case casoActualizado=[SELECT Id, CS_EstadoSincronizacionSuperfinanciera__c FROM Case WHERE Id=:caso.id];
        //System.assertEquals('Actualizando', casoActualizado.CS_EstadoSincronizacionSuperfinanciera__c, 'No se creó correctamente la queja');
        
    }
private class mockUpdateCase implements HttpCalloutMock {
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
            CS_WrapperSmartSupervision.UpdateComplainResponseType res= new CS_WrapperSmartSupervision.UpdateComplainResponseType();
            res.codigo_queja='codigo123';
            res.producto_cod=2;
            response.setBody(JSON.serialize(res));
            response.setStatusCode(200);
            response.setStatus('Success');
            return response; 
        }   
    	}
}  
}