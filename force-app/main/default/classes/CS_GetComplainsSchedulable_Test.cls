/*****************************************************************************************************************************
 * Apex Class Name	:	CS_GetComplainsSchedulable_Test
 * Version			:	1.0
 * Created Date	    :	14/09/2022
 * Function 		: 	Prueba el funcionamiento de la clase CS_GetComplainsSchedulable
 * Test Class		:	???
 *----------------------------------------------------------------------------------------------------------------------------
 *                                                MODIFICATION LOG
 *----------------------------------------------------------------------------------------------------------------------------
 * Developer		     	Date			   	Description
 * ---------------------------------------------------------------------------------------------------------------------------
 * Fernanda Villafaña           14/09/2022          Original Version
 *****************************************************************************************************************************/
@isTest
public class CS_GetComplainsSchedulable_Test {
	@isTest
	static void contactUpdateTest_Schedule() {
		Test.startTest();
        String CRON_EXP = '0 0 0 3 9 ? 2099';
		// Schedule the test job
		String jobId = System.schedule(
			'testBasicScheduledApex',
			CRON_EXP,
			new CS_GetComplains_Schedulable()
		);
		Test.stopTest();       
	}
}