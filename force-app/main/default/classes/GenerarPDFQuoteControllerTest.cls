/**
* ===========================================================================================================================================================
* Developer:             VASS COMPANY
* Creation Date:         12/04/2024
* Created by:            edwinc.martinez@oc.vasscompany.com
* Description:           Creation of test class for the GenerarPDFQuoteController controller.
* Last Modified by:      edwinc.martinez@oc.vasscompany.com (12/04/2024)
* Changes (Versions)

* -------------------------------------
* No.     Date        Author                  Description
* ------  ----------  ---------------------   ---------------
* 1.1     12/04/2024  Edwin Camilo Martinez   Initial version where the creation of the method and data necessary to cover the controller is carried out.
* =============================================================================================================================================================
*/
@isTest
public class GenerarPDFQuoteControllerTest {
    @isTest
    static void testGenerarPDFQuoteController() {
        // Obtener el ID del Pricebook estándar
        Id standardPricebookId = Test.getStandardPricebookId();
        
        System.assertNotEquals(null, standardPricebookId, 'No se encontró el Pricebook estándar.');
        
        // Crear un Pricebook estándar activo si no existe
        Pricebook2 standardPricebook = new Pricebook2(
            Id = standardPricebookId,
            IsActive = true
        );
        update standardPricebook;
        
        // Crear un producto de prueba
        Product2 testProduct = new Product2(
            Name = 'COLMENA ACCIDENTES PERSONALES',
            Family = '31',
            IsActive = true,
            CS_Entidad_Producto__c = '2'
        );
        insert testProduct;
        

        PricebookEntry testPricebookEntry = new PricebookEntry(
            Pricebook2Id = standardPricebookId,
            Product2Id = testProduct.Id,
            UnitPrice = 1000.00,
            IsActive = true
        );
        insert testPricebookEntry;
        
        // Crear una oportunidad de prueba
        Opportunity testOpportunity = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Diseño de Oferta',
            CloseDate = Date.valueOf('2024-10-04'),
            TypeAgreement__c = 'Directo',
            ValidityProjection__c = '1 año',
            YearsToConsiderRunoff__c = '1 año',
            ThirdYear__c = 20000,
            FirstYear__c = 20000,
            SecondYear__c = 20000,
            FourthYear__c = 20000,
            FifthYear__c = 20000
        );
        insert testOpportunity;
        
        OpportunityLineItem testOpportunityProduct = new OpportunityLineItem(
            OpportunityId = testOpportunity.Id,
            PricebookEntryId = testPricebookEntry.Id,
            UnitPrice = 1000.00,
            Quantity = 2,
            TotalBalance0a12months__c = 30000,
            TotalBalance13a18months__c = 40000,
            TotalBalance19a24months__c = 50000,
            TotalBalance25a30months__c = 60000,
            TotalBalance31a36months__c = 70000,
            TotalBalance37a42months__c = 80000,
            TotalBalance43a48months__c = 90000,
            TotalBalance49a54months__c = 100000,
            TotalBalance55a60months__c = 110000,
            TotalBalancemorethan60months__c = 120000,
            CreditAmountMinimum__c = 10000,
            CreditAmountAverage__c = 15000,
            CreditAmountMaxima__c = 20000,
            CreditServiceTermMinimum__c = 12000,
            CreditServiceTermAverage__c = 24000,
            CreditTermserviceMaxima__c = 36000,
            MonthlyFeeMinimum__c = 10000,
            MonthlyFeeAverage__c = 15000,
            MonthlyFeeMaximum__c = 20000,
            MonthlyPaymentsforProtectionMinimum__c = 10000,
            ProtectionMonthlyPaymentsAverage__c = 20000,
            MonthlyPaymentsforProtectionMaxima__c = 30000
        );
        insert testOpportunityProduct;
        
        Test.setCurrentPageReference(new PageReference('/apex/GenerarPDFQuoteController?id=' + testOpportunity.Id));
        
        ApexPages.StandardController sc = new ApexPages.StandardController(testOpportunity);
        
        GenerarPDFQuoteController controller = new GenerarPDFQuoteController(sc);
        
        System.assertEquals('20.000', controller.getFormattedFirstYear(), 'Error en el formato del primer año.');
        System.assertEquals('20.000', controller.getFormattedSecondYear(), 'Error en el formato del segundo año.');
        System.assertEquals('20.000', controller.getFormattedThirdYear(), 'Error en el formato del tercer año.');
        System.assertEquals('20.000', controller.getFormattedFourthYear(), 'Error en el formato del cuarto año.');
        System.assertEquals('20.000', controller.getFormattedFifthYear(), 'Error en el formato del quinto año.');
        
        System.assertEquals('30.000', controller.getFormattedTotalBalance0a12months(), 'Error en el formato del balance total [0-12] meses.');
        System.assertEquals('40.000', controller.getFormattedTotalBalance13a18months(), 'Error en el formato del balance total [13-18] meses.');
        System.assertEquals('50.000', controller.getFormattedTotalBalance19a24months(), 'Error en el formato del balance total [19-24] meses.');
        System.assertEquals('60.000', controller.getFormattedTotalBalance25a30months(), 'Error en el formato del balance total [25-30] meses.');
        System.assertEquals('70.000', controller.getFormattedTotalBalance31a36months(), 'Error en el formato del balance total [31-36] meses.');
        System.assertEquals('80.000', controller.getFormattedTotalBalance37a42months(), 'Error en el formato del balance total [37-42] meses.');
        System.assertEquals('90.000', controller.getFormattedTotalBalance43a48months(), 'Error en el formato del balance total [43-48] meses.');
        System.assertEquals('100.000', controller.getFormattedTotalBalance49a54months(), 'Error en el formato del balance total [49-54] meses.');
        System.assertEquals('110.000', controller.getFormattedTotalBalance55a60months(), 'Error en el formato del balance total [55-60] meses.');
        System.assertEquals('120.000', controller.getFormattedTotalBalancemorethan60months(), 'Error en el formato del balance total > a 60 meses.');
        
        System.assertEquals('10.000', controller.getFormattedCreditAmountMinimum(), 'Error en el formato del monto de crédito mínimo.');
        System.assertEquals('15.000', controller.getFormattedCreditAmountAverage(), 'Error en el formato del monto de crédito promedio.');
        System.assertEquals('20.000', controller.getFormattedCreditAmountMaxima(), 'Error en el formato del monto de crédito máximo.');
        System.assertEquals('12.000', controller.getFormattedCreditServiceTermMinimum(), 'Error en el formato del plazo de crédito mínimo.');
        System.assertEquals('24.000', controller.getFormattedCreditServiceTermAverage(), 'Error en el formato del plazo de crédito promedio.');
        System.assertEquals('36.000', controller.getFormattedCreditServiceTermMaxima(), 'Error en el formato del plazo de crédito máximo.');
        System.assertEquals('10.000', controller.getFormattedMonthlyFeeMinimum(), 'Error en el formato de la cuota mensual mínima.');
        System.assertEquals('15.000', controller.getFormattedMonthlyFeeAverage(), 'Error en el formato de la cuota mensual promedio.');
        System.assertEquals('20.000', controller.getFormattedMonthlyFeeMaximum(), 'Error en el formato de la cuota mensual máxima.');
        System.assertEquals('10.000', controller.getFormattedMonthlyPaymentsforProtectionMinimum(), 'Error en el formato de mensualidades para protección de ingresos mínimo.');
        System.assertEquals('20.000', controller.getFormattedProtectionMonthlyPaymentsAverage(), 'Error en el formato de mensualidades para protección de ingresos promedio.');
        System.assertEquals('30.000', controller.getFormattedMonthlyPaymentsforProtectionMaxima(), 'Error en el formato de mensualidades para protección de ingresos máximo.');
    }
}