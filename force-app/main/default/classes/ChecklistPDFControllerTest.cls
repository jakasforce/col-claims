@isTest
private class ChecklistPDFControllerTest {
    @testSetup
    static void setup() {
        // Crear un Lead (Prospecto) de prueba
        String recordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'Proveedor' LIMIT 1].Id;

        Lead prospecto = new Lead(
            FirstName = 'Test',
            LastName = 'Test',
            RecordTypeId = recordTypeId,
            Numero_de_documento__c = '1119889845',
            Tipo_de_documento__c = '1',
            TypePerson__c = 'Persona Natural',
            Email = 'test@mail.com'
        );
        insert prospecto;

        // Crear registros de CheckListProvider__c asociados al prospecto
        List<CheckListProvider__c> checklistItems = new List<CheckListProvider__c>();
        checklistItems.add(new CheckListProvider__c(
            Lead__c = prospecto.Id,
            External_Id__c = 'extId1',
            Criterion__c = 'Criterio 1',
            SubCriterion__c = 'Subcriterio 1',
            State__c = 'Activo',
            Qualification__c = 'Cumple',
            RatingObservation__c = 'Observación 1',
            ObservationInCaseOfInactivation__c = 'Observación Inactivación 1'
        ));
        checklistItems.add(new CheckListProvider__c(
            Lead__c = prospecto.Id,
            External_Id__c = 'extId2',
            Criterion__c = 'Criterio 2',
            SubCriterion__c = 'Subcriterio 2',
            State__c = 'Inactivo',
            Qualification__c = 'No Cumple',
            RatingObservation__c = 'Observación 2',
            ObservationInCaseOfInactivation__c = 'Observación Inactivación 2'
        ));
        insert checklistItems;
    }

    @isTest
    static void testChecklistPDFController() {
        // Obtener el Lead (Prospecto) de prueba
        Lead prospecto = [SELECT Id FROM Lead WHERE Email = 'test@mail.com' LIMIT 1];
        
        // Simular la configuración del parámetro de la página
        Test.setCurrentPageReference(new PageReference('/apex/ChecklistPDFPage'));
        ApexPages.currentPage().getParameters().put('prospectoId', prospecto.Id);
        
        // Crear una instancia del controlador
        ChecklistPDFController controller = new ChecklistPDFController();

        // Verificar que los elementos de la lista de verificación se hayan consultado correctamente
        System.assertNotEquals(null, controller.checklistItems, 'La lista de verificación no debe ser null');
        System.assertEquals(2, controller.checklistItems.size(), 'Debe haber 2 elementos en la lista de verificación');

        // Verificar que la fecha de última modificación esté formateada correctamente
        System.assertNotEquals(null, controller.formattedLastModifiedDate, 'La fecha de última modificación formateada no debe ser null');
    }
}