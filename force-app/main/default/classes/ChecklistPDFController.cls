/**
 * @author Harold Garcia Vargas
 * @email harold.garcia@vasscompany.com
 * @create date 2024-06-07 09:03:52
 * @modify date 2024-06-07 09:03:52
 * @desc [La clase Apex `ChecklistPDFController` consulta elementos `CheckListProvider__c` para un prospecto específico y formatea la última fecha de modificación.]
 */

public with sharing class ChecklistPDFController {
    public List<CheckListProvider__c> checklistItems { get; set; }
    public String formattedLastModifiedDate { get; set; }

    public ChecklistPDFController() {
        Id prospectoId = ApexPages.currentPage().getParameters().get('prospectoId');
        // Consulta tus elementos de lista de verificación aquí
        checklistItems = [SELECT Id__c, State__c, Criterion__c, SubCriterion__c, Qualification__c, RatingObservation__c, ObservationInCaseOfInactivation__c, LastModifiedDate 
                          FROM CheckListProvider__c WHERE Lead__c = :prospectoId];

        // Si hay elementos, toma la última fecha de modificación del primer elemento (o ajusta según sea necesario)
        if (!checklistItems.isEmpty()) {
            Datetime lastModifiedDate = checklistItems[0].LastModifiedDate;
            formattedLastModifiedDate = lastModifiedDate.format('dd/MM/yyyy');
        }
    }
}