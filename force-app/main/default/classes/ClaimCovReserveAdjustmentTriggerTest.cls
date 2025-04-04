@isTest
public with sharing class ClaimCovReserveAdjustmentTriggerTest {
    @TestSetup
    static void makeData() {
        Claim claim = new Claim(Name = 'Test Claim');
        insert claim;

        ClaimCoverage claimCoverage = new ClaimCoverage(
            Name = 'Test Claim Coverage',
            ClaimId = claim.Id,
            InternalReserveMode = 'CoverageReserve'
        );
        insert claimCoverage;

        List<ClaimCoverageReserveDetail> claimCoverageReserveDetails = new List<ClaimCoverageReserveDetail>();
        for (Integer i = 0; i < 4; i++) {
            String status;
            if (i == 3) {
                status = 'Abierto';
            } else {
                status = 'Objetado';
            }
            claimCoverageReserveDetails.add(
                new ClaimCoverageReserveDetail(
                    Name = 'Test Reserve Detail ' + i,
                    CS_InitialAdjustment__c = 1000000,
                    Origin__c = 'Visual Time',
                    ClaimCoverageId = claimCoverage.Id,
                    Status = status,
                    Date_of_Constitution_of_the_Reserve__c = Date.today() + 10
                )
            );
        }
        insert claimCoverageReserveDetails;
    }

    @isTest
    static void testBeforeInsert() {
        // Id recordTypeId = [SELECT Id, DeveloperName, Name FROM RecordType WHERE DeveloperName = 'CS_Monopoliza' LIMIT 1].Id;
        Claim claim = [SELECT Id FROM Claim LIMIT 1];
        ClaimCoverage claimCoverage = [SELECT Id FROM ClaimCoverage LIMIT 1];
        List<ClaimCoverageReserveDetail> claimCoverageReserveDetails = [
            SELECT Id
            FROM ClaimCoverageReserveDetail
            WHERE ClaimCoverageId = :claimCoverage.Id AND Status = 'Objetado'
        ];
        
        
        Test.startTest();
        List<ClaimCovReserveAdjustment> claimCovReserveAdjustments = new List<ClaimCovReserveAdjustment>();
        for (Integer i = 0; i < 3; i++) {
            String type;
            if (i == 0) {
                type = 'Endoso retroactivo';
            } else if (i == 1){
                type = 'Disminución';
            } else {
                type = 'Liberación por objeción';
            }
            ClaimCovReserveAdjustment adjusment = new ClaimCovReserveAdjustment();
            adjusment.ClaimCoverageId = claimCoverage.Id;
            adjusment.ClaimCoverageReserveDetailId = claimCoverageReserveDetails[i].Id;
            adjusment.Name = 'Test Adjustment #'+ i;
            adjusment.AdjustmentAmount = 100000;
            adjusment.Adjustment_Type__c = type;
            
            claimCovReserveAdjustments.add(adjusment);
        }

        insert claimCovReserveAdjustments;
        Test.stopTest();

        // Test verification
        List<ClaimCoverageReserveDetail> updatedClaimCoverageReserveDetails = [
            SELECT Id, ReserveAmount
            FROM ClaimCoverageReserveDetail
            WHERE Id IN :claimCoverageReserveDetails
        ];

        System.assertEquals(3, updatedClaimCoverageReserveDetails.size());
    }

    @isTest
    static void testOnBeforeDelete() {
        Claim claim = [SELECT Id FROM Claim LIMIT 1];
        ClaimCoverage claimCoverage = [SELECT Id FROM ClaimCoverage LIMIT 1];
        List<ClaimCoverageReserveDetail> claimCoverageReserveDetails = [
            SELECT Id
            FROM ClaimCoverageReserveDetail
            WHERE ClaimCoverageId = :claimCoverage.Id AND Status = 'Abierto'
            Limit 1
        ];

        List<ClaimCovReserveAdjustment> adjusments = new List<ClaimCovReserveAdjustment>();
        ClaimCovReserveAdjustment adjusment = new ClaimCovReserveAdjustment();
        adjusment.ClaimCoverageId = claimCoverage.Id;
        adjusment.ClaimCoverageReserveDetailId = claimCoverageReserveDetails[0].Id;
        adjusment.Name = 'Test Adjustment #1';
        adjusment.AdjustmentAmount = 100000;
        adjusment.Adjustment_Type__c = 'Disminución';

        adjusments.add(adjusment);
        insert adjusments;

        Test.startTest();
        delete adjusments;
        Test.stopTest();

        // Test verification
        List<ClaimCoverageReserveDetail> updatedClaimCoverageReserveDetails = [
            SELECT Id, ReserveAmount
            FROM ClaimCoverageReserveDetail
            WHERE Id IN :claimCoverageReserveDetails
        ];
        List<ClaimCovReserveAdjustment> claimCovReserveAdjustments = [
            SELECT Id
            FROM ClaimCovReserveAdjustment
            WHERE Id IN :adjusments
        ];

        System.assertEquals(1, updatedClaimCoverageReserveDetails.size(), 'All ClaimCoverageReserveDetail records should be updated');
        System.assertEquals(0, claimCovReserveAdjustments.size(), 'All ClaimCovReserveAdjustment records should be deleted');
    }

    @isTest
    static void testOnUpdate() {
        Claim claim = [SELECT Id FROM Claim LIMIT 1];
        ClaimCoverage claimCoverage = [SELECT Id FROM ClaimCoverage LIMIT 1];
        List<ClaimCoverageReserveDetail> claimCoverageReserveDetails = [
            SELECT Id
            FROM ClaimCoverageReserveDetail
            WHERE ClaimCoverageId = :claimCoverage.Id AND Status = 'Abierto'
        ];

        List<ClaimCovReserveAdjustment> claimCovReserveAdjustments = new List<ClaimCovReserveAdjustment>();
        ClaimCovReserveAdjustment adjusment = new ClaimCovReserveAdjustment();
        adjusment.ClaimCoverageId = claimCoverage.Id;
        adjusment.ClaimCoverageReserveDetailId = claimCoverageReserveDetails[0].Id;
        adjusment.Name = 'Test Adjustment #0';
        adjusment.AdjustmentAmount = 100000;
        adjusment.Adjustment_Type__c = 'Endoso retroactivo';
        claimCovReserveAdjustments.add(adjusment);

        insert claimCovReserveAdjustments;

        Test.startTest();
        for (ClaimCovReserveAdjustment claimCovReserveAdj : claimCovReserveAdjustments) {
            claimCovReserveAdj.AdjustmentAmount = 50000;
        }

        update claimCovReserveAdjustments;
        Test.stopTest();

        // Test verification
        List<ClaimCovReserveAdjustment> updatedClaimCovReserveAdjustments = [
            SELECT Id, AdjustmentAmount
            FROM ClaimCovReserveAdjustment
            WHERE Id IN :claimCovReserveAdjustments
        ];

        System.assertEquals(1, updatedClaimCovReserveAdjustments.size(), 'All ClaimCovReserveAdjustment records should be updated');
        for (ClaimCovReserveAdjustment updatedClaimCovReserveAdjustment : updatedClaimCovReserveAdjustments) {
            System.assertEquals(50000, updatedClaimCovReserveAdjustment.AdjustmentAmount, 'ClaimCovReserveAdjustment.AdjustmentAmount should be updated to 50000');
        }
    }
}