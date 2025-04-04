/*****************************************************************************************************************************
 * Apex Class Name	:	CS_CleanAndTruncateText_Invocable
 * Version			:	1.0
 * Created Date	    :	23/04/2024
 * Function 		: 	Clase con el método invocables utilizado por el Flow: Crear Réplica Caso <CS_CreateCaseReplication>
 * Test Class		:	CS_CleanAndTruncateTextInv_Test
 *----------------------------------------------------------------------------------------------------------------------------
 *                                                MODIFICATION LOG
 *----------------------------------------------------------------------------------------------------------------------------
 * Developer		     	Date			   	Description
 * ---------------------------------------------------------------------------------------------------------------------------
 * Frank Tovar            23/04/2024          Original Version
 *****************************************************************************************************************************/
public class CS_CleanAndTruncateText_Invocable {

    @InvocableMethod(
		label='CS_CleanAndTruncateText_Invocable'
		description='Limpiar y Truncar un texto'
		category='CS_CleanAndTruncateText_Invocable'
	)
    public static List<Results> execute(List<Requests> requestList) {
        System.debug('--------------  CS_CleanAndTruncateText_Invocable.cleanAndTruncateText --------------');
		        
		List<Results> responseWrapper = new List<Results>();
        for (Requests request : requestList) {
            System.debug('----- CS_CleanAndTruncateText_Invocable.text = '+request.text);
			System.debug('----- CS_CleanAndTruncateText_Invocable.rangeLimit = '+request.rangeLimit);
			String textResult = CS_Utilities.truncateString(request.text, request.rangeLimit);
			System.debug('----- CS_CleanAndTruncateText_Invocable.textResult = '+textResult);
            //* Create a Results object to hold the return values
			Results response = new Results();
			//* Add the return values to the Results object
			response.textResult = textResult;
			responseWrapper.add(response);
        }
        return responseWrapper;
    }
    
    public class Requests {
		//* Add input fields of the invocable action (ONLY FOR MULTIPLE INCOMES).
		@InvocableVariable(label='Text' description='Text required for validation' required=true)
		public String text;

        @InvocableVariable(label='RangeLimit' description='Integer for range limit' required=true)
		public Integer rangeLimit;
	}

	public class Results {
		//* Add output fields of the invocable action (ONLY FOR MULTIPLE OUTCOMES).
		@InvocableVariable(label='Result text' description='Text result' required=true)
		public String textResult;
	}
    
}