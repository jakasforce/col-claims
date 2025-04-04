@isTest
public with sharing class ClaimCoverageReserveDetailTriggerTest {
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
    }

    @isTest
    static void testBeforeInsert() {
        // Id recordTypeId = [SELECT Id, DeveloperName, Name FROM RecordType WHERE DeveloperName = 'CS_Monopoliza' LIMIT 1].Id;
        Claim claim = [SELECT Id FROM Claim LIMIT 1];
        ClaimCoverage claimCoverage = [SELECT Id FROM ClaimCoverage LIMIT 1];

        List<ClaimCoverageReserveDetail> claimCoverageReserveDetails = new List<ClaimCoverageReserveDetail>();
        for (Integer i = 0; i < 2; i++) {
            claimCoverageReserveDetails.add(
                new ClaimCoverageReserveDetail(
                    Name = 'Test Reserve Detail ' + i,
                    CS_InitialAdjustment__c = 1000000,
                    Origin__c = 'Visual Time',
                    ClaimCoverageId = claimCoverage.Id,
                    Date_of_Constitution_of_the_Reserve__c = Date.today() + 10
                )
            );
        }
        insert claimCoverageReserveDetails;
        ClaimCovReserveAdjustment adjusment = new ClaimCovReserveAdjustment(
            ClaimCoverageId = claimCoverage.Id,
            ClaimCoverageReserveDetailId = claimCoverageReserveDetails[0].Id,
            Name = 'Test Adjustment #1',
            AdjustmentAmount = 100000,
            Adjustment_Type__c = 'Disminución'
        );
        

        // Test execution
        Test.startTest();
        List<ClaimCoverageReserveDetail> claimCoverageReserveDetailsToUpdate = new List<ClaimCoverageReserveDetail>();
        for (
            ClaimCoverageReserveDetail claimCoverageReserveDetail : claimCoverageReserveDetails
        ) {
            claimCoverageReserveDetail.ReserveAmount = 2000;
            claimCoverageReserveDetail.Status = 'Objetado';
            claimCoverageReserveDetailsToUpdate.add(claimCoverageReserveDetail);
        }
        update claimCoverageReserveDetailsToUpdate;
        insert adjusment;

        Test.stopTest();

        // Test verification
        List<ClaimCoverageReserveDetail> updatedClaimCoverageReserveDetails = [
            SELECT Id, ReserveAmount
            FROM ClaimCoverageReserveDetail
            WHERE Id IN :claimCoverageReserveDetailsToUpdate
        ];
        ClaimCoverage claimCoverageToReview = [
            SELECT Id, Status
            FROM ClaimCoverage
            WHERE Id = :claimCoverage.Id
        ];
        System.assertEquals(
            'Objetado',
            claimCoverageToReview.Status,
            'ClaimCoverage.Status should be updated to "Objetado"'
        );
        System.assertEquals(
            2,
            updatedClaimCoverageReserveDetails.size(),
            'All ClaimCoverageReserveDetail records should be updated'
        );
        System.assertEquals(
                900000,
                updatedClaimCoverageReserveDetails[0].ReserveAmount,
                'ClaimCoverageReserveDetail.ReserveAmount should be updated to 2000'
            );
        System.assertEquals(
                2000,
                updatedClaimCoverageReserveDetails[1].ReserveAmount,
                'ClaimCoverageReserveDetail.ReserveAmount should be updated to 2000'
            );
    }

    @isTest
    static void insertClaimCoverageReserveDetailWithStatusAprobado() {
        Claim claim = [SELECT Id FROM Claim LIMIT 1];
        ClaimCoverage claimCoverage = [SELECT Id FROM ClaimCoverage LIMIT 1];

        List<ClaimCoverageReserveDetail> claimCoverageReserveDetails = new List<ClaimCoverageReserveDetail>();
        for (Integer i = 0; i < 2; i++) {
            claimCoverageReserveDetails.add(
                new ClaimCoverageReserveDetail(
                    Name = 'Test Reserve Detail ' + i,
                    CS_InitialAdjustment__c = 1000000,
                    Origin__c = 'Visual Time',
                    ClaimCoverageId = claimCoverage.Id,
                    Status = 'Objetado',
                    Date_of_Constitution_of_the_Reserve__c = Date.today() + 10
                )
            );
        }

        Test.startTest();
        insert claimCoverageReserveDetails;
        // actualizar el estado a Aprobado del segundo registro
        claimCoverageReserveDetails[1].Status = 'Aprobado';
        update claimCoverageReserveDetails;
        Test.stopTest();

        List<ClaimCoverageReserveDetail> updatedClaimCoverageReserveDetails = [
            SELECT Id, Status
            FROM ClaimCoverageReserveDetail
            WHERE Id IN :claimCoverageReserveDetails AND Status = 'Aprobado'
        ];

        System.assertEquals(
            'Aprobado',
            updatedClaimCoverageReserveDetails[0].Status,
            'ClaimCoverageReserveDetail.Status should be updated to "Aprobado"'
        );
    }
}