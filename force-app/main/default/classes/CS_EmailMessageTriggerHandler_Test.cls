@isTest
public class CS_EmailMessageTriggerHandler_Test {
    
    @isTest
    static void testOnBeforeInsert() {
        EmailMessage Email = CS_TestDataFactory.createEmailmessage(true);
        List<EmailMessage> lstemails = new List<EmailMessage>{Email};
        List<Id> idemail = new List<Id>();
        
        Test.startTest();
        CS_EmailMessageTriggerHandler.OnBeforeInsert(lstemails);
        insert lstemails;
        update lstemails;        
        delete lstemails;
        Test.stopTest();
        
    }
    
   /* @isTest
	static void testOnBeforeDelete() {    
    	EmailMessage email = CS_TestDataFactory.createEmailmessage1(true);
    	insert email; 
        
    	CS_EmailMessageTriggerHandler emailHandler = new CS_EmailMessageTriggerHandler();
    
    	Test.startTest();
    	emailHandler.OnBeforeDelete(new List<EmailMessage>{email});
    	delete email;
    	Test.stopTest();
	}
    @isTest
	static void testOnAfterDelete() {    
    	EmailMessage email = CS_TestDataFactory.createEmailmessage1(true);
    	insert email; 
        
    	CS_EmailMessageTriggerHandler emailHandler = new CS_EmailMessageTriggerHandler();
    
    	Test.startTest();
    	emailHandler.OnAfterDelete(new List<EmailMessage>{email});
    	delete email;
    	Test.stopTest();
	}
     @isTest
	static void testOnUndelete() {    
    	EmailMessage email = CS_TestDataFactory.createEmailmessage1(true);
    	insert email; 
        
    	CS_EmailMessageTriggerHandler emailHandler = new CS_EmailMessageTriggerHandler();
    
    	Test.startTest();
    	emailHandler.OnUndelete(new List<EmailMessage>{email});
    	Test.stopTest();
	}*/
}