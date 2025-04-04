global class UnlockRecord {
    @InvocableMethod(label='UnlockRecord' description='Desbloquea un registro pendiente de aprobación')
    public static void unlockOpportunityById(List<String> ids) {
        List<Opportunity> oppList=[Select Id From Opportunity Where id=:ids];
        Opportunity opp= oppList.get(0);
         List<Approval.UnlockResult> ulrList = Approval.unlock(oppList, false);
            List<ProcessInstanceWorkitem> piwi = [SELECT Id, ProcessInstanceId, ProcessInstance.TargetObjectId FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId =: ids];
            Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
            req.setAction('Removed');   
        if(!Test.isRunningTest()){
            req.setWorkitemId(piwi.get(0).Id);
       }
            Approval.process(req,false);
        
            // Iterate through each returned result
    	for(Approval.UnlockResult  ulr : ulrList) {
            if (ulr.isSuccess()) {
                //Operation was successful, so get the ID of the record that was processed
                System.debug('Successfully locked account with ID: ' + ulr.getId());
            }
            else {
                //Operation failed, so get all errors                
                for(Database.Error err : ulr.getErrors()) {
                    System.debug('The following error has occurred.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('Account fields that affected this error: ' + err.getFields());
                }
            }

		}         
       
    }
}