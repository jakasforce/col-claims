/*****************************************************************************************************************************
 * Apex Class Name	:	CS_GetCaseTentativeCloseDateInv_Test
 * Version			:	1.0
 * Created Date	    :	14/09/2022
 * Function 		: 	Prueba el funcionamiento de la clase CS_GetCaseTentativeCloseDateInvocable
 * Test Class		:	???
 *----------------------------------------------------------------------------------------------------------------------------
 *                                                MODIFICATION LOG
 *----------------------------------------------------------------------------------------------------------------------------
 * Developer		     	Date			   	Description
 * ---------------------------------------------------------------------------------------------------------------------------
 * Fernanda Villafaña           14/09/2022          Original Version
 *****************************************************************************************************************************/
@istest
class CS_GetCaseTentativeCloseDateInv_Test {
    @isTest
	static void getCloseDate() {
        Case caso= CS_TestDataFactory.createCase(true);
        caso=[SELECT Id, CS_FechaTentativaDeCierre__c, CS_FechaCreacion__c, CreatedDate FROM Case WHERE Id=:caso.Id];
        CS_GetCaseTentativeCloseDate_Invocable.Requests req= new CS_GetCaseTentativeCloseDate_Invocable.Requests();
        req.caso=caso;
        req.diasParaCierre=10;
        List<CS_GetCaseTentativeCloseDate_Invocable.Requests> lstReq= new List<CS_GetCaseTentativeCloseDate_Invocable.Requests>();
        lstReq.add(req);
        DateTime fecha= DateTime.newInstance(2022, 9, 15);
        caso.CS_FechaCreacion__c = fecha;
        //test.setCreatedDate(caso.Id, fecha);
        test.startTest();
        CS_GetCaseTentativeCloseDate_Invocable.calcularFechaTentativaCierreCasos(lstReq);
        System.debug('***** caso *****: ' + caso);
        test.stopTest();
        DateTime fechaEsperada= DateTime.newInstance(2022, 9, 30);
        Case casoActualizado= [SELECT Id, CS_FechaTentativaDeCierre__c FROM Case WHERE Id=:caso.Id];
        //System.assertEquals(fechaEsperada.date(), casoActualizado.CS_FechaTentativaDeCierre__c, 'Error al calcular la fecha tentativa de cierre');
        
    }
}