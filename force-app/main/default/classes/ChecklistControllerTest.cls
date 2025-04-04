@isTest
private class ChecklistControllerTest {

    private static Id prospectoId;

    @testSetup
    static void setup() {
        String recordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'Proveedor' LIMIT 1].Id;

        // Crear e insertar Lead (Prospecto)
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

        // Asignar el ID del prospecto a la variable de clase
        prospectoId = prospecto.Id;
    }

    @isTest
    static void testGuardarEvaluaciones() {
        // Crear datos de prueba
        String jsonData = '[{"id": "extId1", "ids": "001", "criterio": "criterio1", "subCriterio": "subCriterio1", "estado": "Activo", "calificacion": "Cumple", "observacionCalificacion": "observacion1", "observacionInactivacion": "observacionInactivacion1"}]';

        // Llamar al método guardarEvaluaciones
        Test.startTest();
        String resultado = ChecklistController.guardarEvaluaciones(jsonData, prospectoId);
        Test.stopTest();

        // Verificar los resultados
        System.assertEquals('Registros guardados exitosamente', resultado);

        // Verificar que el registro se ha insertado/actualizado correctamente
        CheckListProvider__c[] checkListRecords = [SELECT Id, Lead__c, External_Id__c, Criterion__c, SubCriterion__c, State__c, Qualification__c, RatingObservation__c, ObservationInCaseOfInactivation__c FROM CheckListProvider__c WHERE Lead__c = :prospectoId];
        System.assertEquals(1, checkListRecords.size());
        CheckListProvider__c record = checkListRecords[0];
        System.assertEquals('extId1', record.External_Id__c);
        System.assertEquals('criterio1', record.Criterion__c);
        System.assertEquals('subCriterio1', record.SubCriterion__c);
        System.assertEquals('Activo', record.State__c);
        System.assertEquals('Cumple', record.Qualification__c);
        System.assertEquals('observacion1', record.RatingObservation__c);
        System.assertEquals('observacionInactivacion1', record.ObservationInCaseOfInactivation__c);
    }

    @isTest
    static void testGuardarEvaluaciones_Actualizar() {
        // Insertar un registro inicial para actualizarlo después
        CheckListProvider__c initialRecord = new CheckListProvider__c(
            Lead__c = prospectoId,
            External_Id__c = 'extId1',
            Criterion__c = 'criterioAntiguo',
            SubCriterion__c = 'subCriterioAntiguo',
            State__c = 'Inactivo',
            Qualification__c = 'No Cumple',
            RatingObservation__c = 'observacionAntigua',
            ObservationInCaseOfInactivation__c = 'observacionInactivacionAntigua'
        );
        insert initialRecord;

        // Crear datos de prueba para actualizar el registro existente
        String jsonData = '[{"id": "extId1", "ids": "001", "criterio": "criterio1", "subCriterio": "subCriterio1", "estado": "Activo", "calificacion": "Cumple", "observacionCalificacion": "observacion1", "observacionInactivacion": "observacionInactivacion1"}]';

        // Llamar al método guardarEvaluaciones
        Test.startTest();
        String resultado = ChecklistController.guardarEvaluaciones(jsonData, prospectoId);
        Test.stopTest();

        // Verificar los resultados
        System.assertEquals('Registros guardados exitosamente', resultado);

        // Verificar que el registro se ha actualizado correctamente
        CheckListProvider__c updatedRecord = [SELECT Id, Lead__c, External_Id__c, Criterion__c, SubCriterion__c, State__c, Qualification__c, RatingObservation__c, ObservationInCaseOfInactivation__c FROM CheckListProvider__c WHERE External_Id__c = 'extId1' LIMIT 1];
        System.assertEquals('criterio1', updatedRecord.Criterion__c);
        System.assertEquals('subCriterio1', updatedRecord.SubCriterion__c);
        System.assertEquals('Activo', updatedRecord.State__c);
        System.assertEquals('Cumple', updatedRecord.Qualification__c);
        System.assertEquals('observacion1', updatedRecord.RatingObservation__c);
        System.assertEquals('observacionInactivacion1', updatedRecord.ObservationInCaseOfInactivation__c);
    }

    /*@isTest
    static void testGenerarPDF() {
        Test.startTest();
        String pdfBase64 = ChecklistController.generarPDF(prospectoId);
        Test.stopTest();

        // Verificar que se ha generado un PDF
        System.assertNotEquals(null, pdfBase64, 'El PDF generado no debería ser null');
        System.assert(pdfBase64.startsWith('JVBERi0xL'), 'El PDF generado debería comenzar con la cabecera correcta en base64');
    }*/
}