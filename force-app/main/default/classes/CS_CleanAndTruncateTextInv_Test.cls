/*****************************************************************************************************************************
 * Apex Class Name	:	CS_CleanAndTruncateTextInv_Test
 * Version			:	1.0
 * Created Date	    :	23/04/2024
 * Function 		: 	Prueba el funcionamiento de la clase CS_CleanAndTruncateText_Invocable
 * Test Class		:	N/A
 *----------------------------------------------------------------------------------------------------------------------------
 *                                                MODIFICATION LOG
 *----------------------------------------------------------------------------------------------------------------------------
 * Developer		     	Date			   	Description
 * ---------------------------------------------------------------------------------------------------------------------------
 * Frank Tovar           23/04/2024          Original Version
 *****************************************************************************************************************************/
@isTest
public with sharing class CS_CleanAndTruncateTextInv_Test {
    
    @isTest
    static void CS_CleanAndTruncateTextInv_Test() {
        CS_CleanAndTruncateText_Invocable.Requests req= new CS_CleanAndTruncateText_Invocable.Requests();
        req.text='Lorem \n\n Ipsum \n\n is simply \n\n dummy text of the printing and typesetting industry. Lorem Ipsum has been the industrys standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.';
        req.rangeLimit=1000;
        List<CS_CleanAndTruncateText_Invocable.Requests> lstReq= new List<CS_CleanAndTruncateText_Invocable.Requests>();
        lstReq.add(req);
        CS_CleanAndTruncateText_Invocable.Results result = new CS_CleanAndTruncateText_Invocable.Results();
        List<CS_CleanAndTruncateText_Invocable.Results> lstResults= new List<CS_CleanAndTruncateText_Invocable.Results>();
        test.startTest();
        lstResults = CS_CleanAndTruncateText_Invocable.execute(lstReq);
        test.stopTest();
        System.debug('ResultText => '+lstResults[0].textResult);
    }

}