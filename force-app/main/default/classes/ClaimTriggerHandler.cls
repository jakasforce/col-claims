public with sharing class ClaimTriggerHandler {
    public static void onBeforeUpdate(List<Claim> newClaims, Map<Id, Claim> newClaimsMap, List<Claim> oldClaims) {
        ClaimTriggerHelper.updateOwnerOfQueue(newClaims, newClaimsMap, oldClaims);
    }
    public static void onBeforeInsert(List<Claim> newClaims, Map<Id, Claim> newClaimsMap) {
        ClaimTriggerHelper.updateOwnerOfQueue(newClaims, newClaimsMap, newClaims);
    }
}