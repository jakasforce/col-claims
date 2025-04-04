public class ClaimCoverageReserveDetailHandler {
    public static void onAfterUpdate(List<ClaimCoverageReserveDetail> newRecords, List<ClaimCoverageReserveDetail> oldRecords) {
        ClaimCoverageReserveDetailHelper.updateStatusOfClaimCoverage(newRecords);
    }

    public static void onBeforeInsert(List<ClaimCoverageReserveDetail> records) {
        ClaimCoverageReserveDetailHelper.updateNewReserve(records);
    }

    public static void onBeforeUpdate(List<ClaimCoverageReserveDetail> records) {
        ClaimCoverageReserveDetailHelper.updateClaimCovReserve(records);
    }
}