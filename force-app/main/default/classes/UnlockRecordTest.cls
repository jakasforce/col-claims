@isTest
private class UnlockRecordTest {

    @isTest
    static void testUnlockOpportunityById() {
        
        //Date fechaClose = date.parse('2023-10-04');
        // Crear datos de prueba, por ejemplo, una oportunidad bloqueada
        Opportunity testOpp = new Opportunity(Name='Test Opportunity', StageName='Diseño de Oferta', CloseDate=Date.valueOf('2024-10-04'),
                                              TypeAgreement__c='Directo', ValidityProjection__c= '1 año',
                                              YearsToConsiderRunoff__c='1 año');
        insert testOpp;

        // Obtener el ID de la oportunidad creada
        List<Opportunity> oppList = [SELECT Id FROM Opportunity WHERE Name='Test Opportunity' LIMIT 1];
        String oppId = oppList[0].Id;
        
		List<ProcessInstanceWorkitem> piwiList = [SELECT Id FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId = :oppId];
        //ProcessInstanceWorkitem piwi = piwiList.get(0);
        //insert piwi;
        // Llamar al método de desbloqueo con el ID de la oportunidad creada
        //UnlockRecord.unlockOpportunityById(new List<String>{oppId});
		
        // Realizar afirmaciones para verificar que la oportunidad ha sido desbloqueada correctamente
        //List<ProcessInstanceWorkitem> piwiList = [SELECT Id FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId = :oppId];
        
		test.startTest();
        UnlockRecord.unlockOpportunityById(new List<String>{oppId});
        test.stopTest();
        System.assertEquals(0, piwiList.size(), 'ProcessInstanceWorkitem should be removed');
        // Puedes agregar más afirmaciones según sea necesario para validar el comportamiento esperado

    }
}