public class ClaimCovReserveAdjustmentHandler {
    public static void onAfterInsert(List<ClaimCovReserveAdjustment> newRecords) {
        ClaimCovReserveAdjustmentHelper.updateClaimCovReserve(newRecords);
    }

    public static void onAfterUpdate(List<ClaimCovReserveAdjustment> newRecords, List<ClaimCovReserveAdjustment> oldRecords) {
        ClaimCovReserveAdjustmentHelper.updateClaimCovReserve(newRecords);
    }

    public static void onAfterDelete(List<ClaimCovReserveAdjustment> oldRecords) {
        ClaimCovReserveAdjustmentHelper.restoreClaimCovergeReserveToDefaulValues(oldRecords);
    }

    public static void onBeforeInsert(List<ClaimCovReserveAdjustment> newRecords) {
        ClaimCovReserveAdjustmentHelper.validateRecordExistence(newRecords);
    }

    public static void onBeforeUpdate(List<ClaimCovReserveAdjustment> newRecords, List<ClaimCovReserveAdjustment> oldRecords) {
        ClaimCovReserveAdjustmentHelper.validateRecordExistence(newRecords);
        ClaimCovReserveAdjustmentHelper.validateReserveStatusToUpdate(newRecords);
    }

    public static void onBeforeDelete(List<ClaimCovReserveAdjustment> newRecords, List<ClaimCovReserveAdjustment> oldRecords) {
        ClaimCovReserveAdjustmentHelper.validateStateOfReserveBeforeDelete(oldRecords);
    }
}