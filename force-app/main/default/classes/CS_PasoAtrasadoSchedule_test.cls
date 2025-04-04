/*****************************************************************************************************************************
 * Apex Class Name	:	CS_PasoAtrasadoSchedule_test
 * Version			:	1.0
 * Created Date	    :	20/09/2022
 * Function 		: 	Prueba el funcionamiento de la clase CS_FinalDateWorkingDaysCalculator
 * Test Class		:	???
 *----------------------------------------------------------------------------------------------------------------------------
 *                                                MODIFICATION LOG
 *----------------------------------------------------------------------------------------------------------------------------
 * Developer		     	Date			   	Description
 * ---------------------------------------------------------------------------------------------------------------------------
 * Fernanda Villafaña           20/09/2022          Original Version
 *****************************************************************************************************************************/
@isTest
public class CS_PasoAtrasadoSchedule_test {
    @isTest
    static void pasoAtrasado(){
        Case caso= CS_TestDataFactory.createCase(true);
        caso.CS_FechaTentativaDeCierre__c= date.Today();
        update caso;
        CS_AsginacionPasosAtencion__c paso= new CS_AsginacionPasosAtencion__c();
        paso.CS_CasoRelacionado__c=Caso.Id;
        paso.CS_Tiempo_de_AtencionN__c=1;
        paso.CS_Estado__c='Iniciado';
        paso.CS_AsignacionFlujoSecundario__c=false;
        insert paso;
        Date fecha= date.Today().addDays(-5);
        test.setCreatedDate(paso.id,fecha);
       Test.startTest();
        String CRON_EXP = '0 0 0 3 9 ? 2099';
		// Schedule the test job
		String jobId = System.schedule(
			'testPasoAtrasadoSchedule',
			CRON_EXP,
			new CS_PasoAtrasadoSchedule()
		);
		Test.stopTest();  
        List<Case> casosList = [Select Id,CS_PasoAtrasado__c From Case];
        System.assertEquals(true, casosList[0].CS_PasoAtrasado__c, 'No se actualizó correctamente el caso');
    }

}