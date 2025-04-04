@isTest
public class CS_GetWorkingDaysBetweenDates_Inv_Test {
	@isTest
    static void getWorkingDaysBetweenDatesTest() {
        
        List<CS_GetWorkingDaysBetweenDates_Invocable.Requests> listrequestTemp = new List<CS_GetWorkingDaysBetweenDates_Invocable.Requests>();
        CS_GetWorkingDaysBetweenDates_Invocable.Requests requestTemp = new CS_GetWorkingDaysBetweenDates_Invocable.Requests();
        requestTemp.initialDate = Date.today().AddDays(-3);
        requestTemp.finalDate = Date.today();
        listrequestTemp.add(requestTemp);
        
        Test.startTest();
        	CS_GetWorkingDaysBetweenDates_Invocable.getWorkingDaysBetweenDates(listrequestTemp);
        Test.stopTest();
    }
}