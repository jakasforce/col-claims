public class ClaimCovReserveAdjustmentHelper {
    public static void updateClaimCovReserve(List<ClaimCovReserveAdjustment> reservsAdjustment) {
        List<Id> reservIds = new List<Id>();

        for (ClaimCovReserveAdjustment adjustment : reservsAdjustment) {
            reservIds.add(adjustment.ClaimCoverageReserveDetailId);
        }

        List<ClaimCoverageReserveDetail> reservsToUpdate = [
            SELECT Id, ReserveAmount, CS_InitialAdjustment__c, CS_NewReserv__c, Status, ClaimCoverageId
            FROM ClaimCoverageReserveDetail
            WHERE Id IN :reservIds
        ];
        if (reservsToUpdate.size() > 0) {
            for (ClaimCoverageReserveDetail reserv : reservsToUpdate) {
                for (ClaimCovReserveAdjustment reservAdjustment : reservsAdjustment) {
                    if (reserv.Id == reservAdjustment.ClaimCoverageReserveDetailId) {
                        if (reservAdjustment.Adjustment_Type__c == 'Endoso retroactivo') {
                            reserv.ReserveAmount = reserv.CS_InitialAdjustment__c + reservAdjustment.AdjustmentAmount;
                            if(reserv.Status == 'Aprobado' || reserv.Status == 'Objetado'){
                                // punto 5.1
                            	reserv.CS_NewReserv__c = 0;  
                            }
                            
                            System.debug('Endoso retroactivo - Nueva reserva: ' + reserv.CS_NewReserv__c);
                        } else if (reservAdjustment.Adjustment_Type__c == 'Disminución') {
                            reserv.ReserveAmount = reserv.CS_InitialAdjustment__c - reservAdjustment.AdjustmentAmount;
                            if(reserv.Status == 'Aprobado' || reserv.Status == 'Objetado'){
                                // punto 5.1
                                reserv.CS_NewReserv__c = reserv.CS_InitialAdjustment__c - reserv.ReserveAmount;
                            }
                        } else if (reservAdjustment.Adjustment_Type__c == 'Liberación por objeción') {
                            reserv.Status = 'Objetado';
                            reserv.ReserveAmount = reserv.CS_InitialAdjustment__c;
                            if(reserv.Status == 'Aprobado' || reserv.Status == 'Objetado'){
                                reserv.CS_NewReserv__c = reserv.CS_InitialAdjustment__c;
                            }
                        } else {
                            reserv.ReserveAmount = reserv.CS_InitialAdjustment__c;
                        }
                        
                        if(reserv.Status != 'Aprobado' && reserv.Status != 'Objetado'){
                            reserv.CS_NewReserv__c = 0;
                        }
                        break;
                    }
                }
            }
            update reservsToUpdate;
        } else {
            System.debug('No se encontraron reservas');
        }
    }

    public static void restoreClaimCovergeReserveToDefaulValues(List<ClaimCovReserveAdjustment> reservsAdjustment) {

        List<Id> reservIds = new List<Id>();

        for (ClaimCovReserveAdjustment adjustment : reservsAdjustment) {
            reservIds.add(adjustment.ClaimCoverageReserveDetailId);
        }

        List<ClaimCoverageReserveDetail> reservsToUpdate = [
            SELECT Id, ReserveAmount, CS_InitialAdjustment__c, CS_NewReserv__c
            FROM ClaimCoverageReserveDetail
            WHERE Id IN :reservIds
        ];

        if (reservsToUpdate.size() > 0) {
            for (ClaimCoverageReserveDetail reserv : reservsToUpdate) {
                reserv.ReserveAmount = reserv.CS_InitialAdjustment__c;
                reserv.CS_NewReserv__c = reserv.CS_InitialAdjustment__c - reserv.ReserveAmount;
            }
        }

        update reservsToUpdate;
    }

    public static void validateRecordExistence(List<ClaimCovReserveAdjustment> newRecords) {
        List<Id> reservDetailIds = new List<Id>();

        for (ClaimCovReserveAdjustment reservAdjustment : newRecords) {
            reservDetailIds.add(reservAdjustment.ClaimCoverageReserveDetailId);
        }

        List<ClaimCovReserveAdjustment> adjusmentListToCompare = [
            SELECT Id, ClaimCoverageReserveDetailId
            FROM ClaimCovReserveAdjustment
            WHERE ClaimCoverageReserveDetailId IN :reservDetailIds
        ];

        for (ClaimCovReserveAdjustment reservAdjustment : newRecords) {
            for (ClaimCovReserveAdjustment adjCompare : adjusmentListToCompare) {
                if (reservAdjustment.Id != adjCompare.Id && reservAdjustment.ClaimCoverageReserveDetailId == adjCompare.ClaimCoverageReserveDetailId) {
                    reservAdjustment.addError('Ya existe un movimiento para el Detalle de reserva de cobertura de reclamación seleccionado.');
                    break;
                }
            }
        }
    }

    public static void validateReserveStatusToUpdate(List<ClaimCovReserveAdjustment> newRecords) {
        List<Id> reservDetailIds = new List<Id>();

        for (ClaimCovReserveAdjustment reservAdjustment : newRecords) {
            reservDetailIds.add(reservAdjustment.ClaimCoverageReserveDetailId);
        }

        List<ClaimCoverageReserveDetail> reserveToUpdate = [
            SELECT Id, Status
            FROM ClaimCoverageReserveDetail
            WHERE Id IN :reservDetailIds
        ];
        System.debug('reserveToUpdate: ' + reserveToUpdate);
        
        for (ClaimCoverageReserveDetail reserve : reserveToUpdate) {
            Boolean validationStatus = reserve.Status == 'Aprobado' || reserve.Status == 'Objetado';
            if (validationStatus) {
                for (ClaimCovReserveAdjustment reservAdjustment : newRecords) {
                    if (reservAdjustment.ClaimCoverageReserveDetailId == reserve.Id) {
                        reservAdjustment.addError('No se puede modificar el movimiento de la reserva de cobertura de reclamación porque su estado es "' + reserve.Status + '".');
                        break;
                    }
                }
            }
        }
    }

    public static void validateStateOfReserveBeforeDelete(List<ClaimCovReserveAdjustment> oldRecords) {
        List<Id> reservDetailIds = new List<Id>();
        System.debug('oldRecords: ' + oldRecords);
        for (ClaimCovReserveAdjustment reservAdjustment : oldRecords) {
            reservDetailIds.add(reservAdjustment.ClaimCoverageReserveDetailId);
        }
        //System.debug('reservDetailIds: ' + reservDetailIds);

        List<ClaimCoverageReserveDetail> reservsToUpdate = [
            SELECT Id, Status
            FROM ClaimCoverageReserveDetail
            WHERE Id IN :reservDetailIds
        ];
        //System.debug('reservsToUpdate: ' + reservsToUpdate);

        for (ClaimCovReserveAdjustment reservAdjustment : oldRecords) {
            for (ClaimCoverageReserveDetail reserveToCompare : reservsToUpdate) {
                if (reservAdjustment.ClaimCoverageReserveDetailId == reserveToCompare.Id) {
                    //System.debug('reserveToCompare.Status: ' + reserveToCompare.Status);
                    Boolean validationStatus = reserveToCompare.Status == 'Aprobado' || reserveToCompare.Status == 'Objetado';
                    if (validationStatus) {
                        reservAdjustment.addError('No se puede eliminar el movimiento de ajuste de reserva de cobertura de reclamación porque el estado de la reserva es "' + reserveToCompare.Status + '".');
                        //System.debug('No se puede eliminar el movimiento de ajuste de reserva de cobertura de reclamación porque el estado de la reserva es ' + reserveToCompare.Status + '.');
                        break;
                    }
                }
            }
        }
    }
}