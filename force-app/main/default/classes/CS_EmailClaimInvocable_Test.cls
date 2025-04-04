/**
 * @description       : 
 * @author            : diego.jacanamijoy@oc.vasscompany.com
 * @group             : 
 * @last modified on  : 08-02-2024
 * @last modified by  : diego.jacanamijoy@oc.vasscompany.com
**/
@IsTest
public with sharing class CS_EmailClaimInvocable_Test {
    
    @TestSetup
    static void makeData(){
        
        Map<Schema.SObjectField, Object> mapClaim = new Map<Schema.SObjectField, Object>();
        Account objAccount = CS_TestDataFactory.createPersonAccount(true);
        mapClaim.put(Claim.Name, 'Test');
        mapClaim.put(Claim.AccountId, objAccount.Id);
        Claim newClaim = CS_TestDataFactory.createClaim(mapClaim, true);

        InsurancePolicy policy = new InsurancePolicy(
            PolicyName = 'Policy Test',
            Name = 'Policy Test',
            NameInsuredId = objAccount.Id
        );
        insert policy;

        InsurancePolicyCoverage insurancePolicyCoverage = new InsurancePolicyCoverage();
        insurancePolicyCoverage.InsurancePolicyId = policy.Id;
        insurancePolicyCoverage.CategoryGroupType = '3';
        insert insurancePolicyCoverage;

        //Create coverage
        ClaimCoverage coverage = new ClaimCoverage(
            ClaimId = newClaim.Id,
            Name = 'Test claim coverage',
            InternalReserveMode = 'CoverageReserve',
            InsurancePolicyCoverageId = insurancePolicyCoverage.Id
        );
        insert coverage;
    }

    @IsTest
    static void emailClaimTest() {

        CS_EmailClaimInvocable.request request = new CS_EmailClaimInvocable.request();
        request.records = [SELECT Id FROM Claim ];

        Test.startTest();
        CS_EmailClaimInvocable.execute(new List<CS_EmailClaimInvocable.request>{request});
        Test.stopTest();
    }

    @IsTest
    static void emailClaimTestWithDoc() {

        List<Claim> claims = [SELECT Id FROM Claim ];

        ContentVersion content = new ContentVersion(); 
        content.Title = 'Header_Picture1'; 
        content.PathOnClient = '/' + content.Title + '.jpg'; 
        Blob bodyBlob = Blob.valueOf('Unit Test ContentVersion Body'); 
        content.VersionData = bodyBlob; 
        content.origin = 'H';
        insert content;

        ContentDocumentLink contentlink = new ContentDocumentLink();
        contentlink.LinkedEntityId = claims[0].id;
        contentlink.contentdocumentid = [select contentdocumentid from contentversion where id =: content.id].contentdocumentid;
        contentlink.ShareType = 'I';
        contentlink.Visibility = 'AllUsers'; 
        insert contentlink;

        CS_EmailClaimInvocable.request request = new CS_EmailClaimInvocable.request();
        request.records = claims;

        Test.startTest();
        CS_EmailClaimInvocable.execute(new List<CS_EmailClaimInvocable.request>{request});
        Test.stopTest();
    }
}