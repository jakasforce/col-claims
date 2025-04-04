public class ClaimCoverageReserveDetailHelper {
    public static void updateStatusOfClaimCoverage(List<ClaimCoverageReserveDetail> records) {
        try {
            List<Id> claimCoveragesIds = new List<Id>();

            for (ClaimCoverageReserveDetail reservDetail : records) {
                claimCoveragesIds.add(reservDetail.ClaimCoverageId);
            }

            List<ClaimCoverage> claimCoverages = [
                SELECT Id, Status
                FROM ClaimCoverage
                WHERE Id IN :claimCoveragesIds
            ];

            for (ClaimCoverageReserveDetail reservDetail : records) {
                for (ClaimCoverage claimCoverage : claimCoverages) {
                    if (reservDetail.ClaimCoverageId == claimCoverage.Id) {
                        if (reservDetail.Status == 'Objetado') {
                            claimCoverage.Status = 'Objetado';
                        } else if (reservDetail.Status == 'Aprobado') {
                            claimCoverage.CS_CompensationValue__c = reservDetail.ReserveAmount;
                            System.debug('Aprobado por :' + claimCoverage.CS_CompensationValue__c);
                        }
                        break;
                    }
                }
            }

            update claimCoverages;
        } catch (Exception e) {
            System.debug('Error: ' + e.getMessage());
        }
    }

    public static void updateNewReserve(List<ClaimCoverageReserveDetail> records) {
        try {
            for (ClaimCoverageReserveDetail reservDetail : records) {
                reservDetail.ReserveAmount = reservDetail.CS_InitialAdjustment__c;
                
                Boolean validateStatus = reservDetail.Status == 'Objetado' || reservDetail.Status == 'Aprobado';
                if(validateStatus){
                    reservDetail.CS_NewReserv__c = 0;
                }else{
                    reservDetail.CS_NewReserv__c = null;

                }
                
            }
        } catch (Exception e) {
            System.debug('Error: ' + e.getMessage());
        }
    }

    public static void updateClaimCovReserve(List<ClaimCoverageReserveDetail> records) {
        try {
            List<Id> reservDetailIds = new List<Id>();

            for (ClaimCoverageReserveDetail reservDetail : records) {
                reservDetailIds.add(reservDetail.Id);
            }

            List<ClaimCovReserveAdjustment> reservAdjustmentList = [
                SELECT Id, Adjustment_Type__c,ClaimCoverageReserveDetailId
                FROM ClaimCovReserveAdjustment
                WHERE ClaimCoverageReserveDetailId IN :reservDetailIds
            ];

            for (ClaimCoverageReserveDetail reservDetail : records) {
                Boolean validateStatus = reservDetail.Status == 'Objetado' || reservDetail.Status == 'Aprobado';
                
                if (reservAdjustmentList.size() > 0 && validateStatus) {
                    for (ClaimCovReserveAdjustment reservAdjustment : reservAdjustmentList) {
                        if (reservDetail.Id == reservAdjustment.ClaimCoverageReserveDetailId) {
                            if (reservAdjustment.Adjustment_Type__c == 'Endoso retroactivo') {
                                reservDetail.CS_NewReserv__c = 0;
                            } else if(reservAdjustment.Adjustment_Type__c == 'Liberación por objeción') {
                                reservDetail.CS_NewReserv__c = reservDetail.CS_InitialAdjustment__c;
                            }else{
                                reservDetail.CS_NewReserv__c = reservDetail.CS_InitialAdjustment__c - reservDetail.ReserveAmount;
                            }
                            break;
                        }
                    }
                } else if (validateStatus) {
                    reservDetail.CS_NewReserv__c = reservDetail.CS_InitialAdjustment__c - reservDetail.ReserveAmount;
                }else{
                    reservDetail.CS_NewReserv__c = null;
                }
                
            }
        } catch (Exception e) {
            System.debug('Error: ' + e.getMessage());
        }
    }
}