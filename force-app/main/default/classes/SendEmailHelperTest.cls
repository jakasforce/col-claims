/**
 * @description       : 
 * @author            : diego.jacanamijoy@oc.vasscompany.com
 * @group             : 
 * @last modified on  : 12-18-2023
 * @last modified by  : diego.jacanamijoy@oc.vasscompany.com
**/
@IsTest
public with sharing class SendEmailHelperTest {
    
    @TestSetup
    static void makeData(){
        
        EmailTemplate emailTemplate = new EmailTemplate();
        emailTemplate.isActive = true;
        emailTemplate.Name = 'testTemplate';
        emailTemplate.DeveloperName = 'testTemplate' + System.now().getTime();
        emailTemplate.TemplateType = 'text';
        emailTemplate.FolderId = UserInfo.getUserId();
        emailTemplate.Body = '<html>' +
        '<body>' +
        '{{{Claim.CS_DocumentosFaltantes__c}}}<br />' +
        '</body>' +
        '</html>';
        insert emailTemplate;
    }

    @IsTest
    static void sendEmailTest() {

        String templateName = [SELECT Name FROM EmailTemplate WHERE Name = 'testTemplate' LIMIT 1].Name;

        Claim testClaim = new Claim(
            Name = 'test claim',
            Status = 'Suspendido',
            ClaimEmail__c = 'testemail@test.com',
            LastNotificationDateWaitingForDocument__c = System.today().addDays(-10)
        );

        insert testClaim;

        Test.startTest();
            Boolean isError = SendEmailHelper.sendMassEmails(templateName, 'ClaimEmail__c',new List<Claim>{testClaim});
        Test.stopTest();

        System.assertEquals(false, isError, 'The expected result is false');
    }
}