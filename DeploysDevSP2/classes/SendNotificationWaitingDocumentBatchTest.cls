/**
 * @description       : 
 * @author            : diego.jacanamijoy@oc.vasscompany.com
 * @group             : 
 * @last modified on  : 12-18-2023
 * @last modified by  : diego.jacanamijoy@oc.vasscompany.com
**/
@IsTest
public with sharing class SendNotificationWaitingDocumentBatchTest {
    
    @TestSetup
    static void makeData(){
        
        Claim testClaim = new Claim(
            Name = 'test claim',
            Status = 'Suspendido',
            ClaimEmail__c = 'testemail@test.com',
            LastNotificationDateWaitingForDocument__c = System.today().addDays(-10)
        );

        insert testClaim;
    }

    @IsTest
    static void sendNotificationTest() {

        Test.startTest();
            Id jobid= Database.executeBatch(new SendNotificationWaitingDocumentsBatch(),5);
        Test.stopTest();

        Claim testClaim = [SELECT LastNotificationDateWaitingForDocument__c FROM Claim LIMIT 1];
        System.assertEquals(System.today(), testClaim.LastNotificationDateWaitingForDocument__c, 'It´s not the expected date');
    }

    @IsTest
    static void testSchedule() {

		Test.StartTest();
            String CRON_EXP = '0 6 * * * ?';
            String jobId =  system.schedule('Test status', CRON_EXP, new SendNotificationWaitingDocumentsBatch() );
		Test.stopTest();

        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
		System.assertEquals(CRON_EXP, ct.CronExpression, 'The crom expresion is not the expected');
		System.assertEquals(0, ct.TimesTriggered, 'The TimesTriggered is not the expected');
	}
}