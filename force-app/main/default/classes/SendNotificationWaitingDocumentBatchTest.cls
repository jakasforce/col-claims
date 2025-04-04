/**
 * @description       : 
 * @author            : diego.jacanamijoy@oc.vasscompany.com
 * @group             : 
 * @last modified on  : 12-06-2024
 * @last modified by  : diego.jacanamijoy@oc.vasscompany.com
**/
@IsTest
public with sharing class SendNotificationWaitingDocumentBatchTest {

    static SuspendedNotificationConfiguration__mdt notificationSetting = SuspendedNotificationConfiguration__mdt.getInstance('NotifySuspended');

    static Date dateNotification = Date.today().addDays(Integer.valueOf(-notificationSetting.Frequency__c));
    static Date dateNotNotification = Date.today().addYears(Integer.valueOf(-notificationSetting.NotificationValidity__c)).addDays(1);
    
    @TestSetup
    static void makeData(){

        Claim testClaim = new Claim(
            Name = 'test claim',
            Status = 'Suspendido',
            ClaimEmail__c = 'testemail@test.com',
            CS_correoReclamante__c = 'testemail@test.com',
            LastNotificationDateWaitingForDocument__c = System.today().addDays(-10)
        );
        insert testClaim;
        
        // Create a ClaimCoverage record with the necessary fields for testing
        ClaimCoverage cc = new ClaimCoverage(
            CS_ClaimEmail__c = 'testemail@test.com',
            Status = 'Suspendido',
            CS_SubStatus__c = 'Documentos Solicitados',
            LastNotificationDateWaitingForDocument__c = dateNotification,
            FirstNotificationDateWaitingForDocument__c = dateNotNotification,
            Name = 'Test',
            ClaimId = testClaim.Id,
            InternalReserveMode = 'CoverageReserve'
        );

        insert cc;

        cc.CS_ClaimEmail__c = 'testemail@test.com';
        update cc;

    }

    @IsTest
    static void sendNotificationTest() {
        Claim testCoverageClaim = [SELECT Id, ClaimEmail__c FROM Claim LIMIT 1];
        //System.assertNotEquals(null, testCoverageClaim.ClaimEmail__c, 'ClaimEmail__c should not be null');

        // Verify that the test data has been set up correctly
        ClaimCoverage testCoverage = [SELECT Id, CS_ClaimEmail__c, Name, CS_SubStatus__c FROM ClaimCoverage LIMIT 1];
        System.assertNotEquals(null, testCoverage.CS_ClaimEmail__c, 'CS_ClaimEmail__c should not be null');

        Test.startTest();
            Id jobid = Database.executeBatch(new SendNotificationWaitingDocumentsBatch(), 5);
        Test.stopTest();

        ClaimCoverage updatedClaim = [SELECT LastNotificationDateWaitingForDocument__c FROM ClaimCoverage LIMIT 1];
        System.assertEquals(System.today(), updatedClaim.LastNotificationDateWaitingForDocument__c, 'It´s not the expected date');
    }

    @IsTest
    static void testSchedule() {
        Test.startTest();
            String CRON_EXP = '0 6 * * * ?';
            String jobId = system.schedule('Test status', CRON_EXP, new SendNotificationWaitingDocumentsBatch());
        Test.stopTest();

        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(CRON_EXP, ct.CronExpression, 'The cron expression is not the expected');
        System.assertEquals(0, ct.TimesTriggered, 'The TimesTriggered is not the expected');
    }
}