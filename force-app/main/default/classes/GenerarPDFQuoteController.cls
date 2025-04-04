/**
* =======================================================================================================================================================================================
* Developer:             VASS COMPANY
* Creation Date:         08/04/2024
* Created by:            edwinc.martinez@oc.vasscompany.com
* Description:           Creation of the controller class for the visualforce page Generate PDF where the necessary fields of the OpportunityLineItem are brought to show in the PDF.
* Last Modified by:      edwinc.martinez@oc.vasscompany.com (08/04/2024)
* Changes (Versions)

* -------------------------------------
* No.     Date        Author                  Description
* ------  ----------  ---------------------   ---------------
* 1.1     08/04/2024  Edwin Camilo Martinez   Initial version where the variables and constructor that contains the query to bring the fields are declared.
* =======================================================================================================================================================================================
*/
public class GenerarPDFQuoteController {
    public Opportunity opportunity { get; set; }
    public OpportunityLineItem opportunityProduct { get; set; }
    
    public GenerarPDFQuoteController(ApexPages.StandardController controller) {
        String opportunityId = ApexPages.currentPage().getParameters().get('id');
        System.debug('Oportunidad Id: ' + opportunityId);
        
        // Consulta para obtener campos de la oportunidad 
        opportunity = [SELECT Id, Name, Account.Name, AccountNameRL__c, TypeAgreement__c, ValidityProjection__c, CollectionMeans__c, Collectioncharge__c,
                       Comments__c, Intermediary1__c, NameIntermediary1__c, CommissionPercentageIntermediary1__c, Intermediary2__c,
                       NameIntermediary2__c, CommissionPercentageIntermediary2__c, SponsorReturn__c, ReturnPercentage__c,
                       CommercialIncentive__c, CommercialIncentivePercentage__c, Costo_Fijo_Asociado__c, FirstYear__c,
                       SecondYear__c, ThirdYear__c, FourthYear__c, FifthYear__c, TotalTargetPopulation__c, EstimatedpenetrationpercentageNew__c,
                       estimatedpenetrationCurrentPortfolio__c, Geographiccoverageofthetargetcustomer__c, EstimatedpenetrationunitsNew__c,
                       EstimatedPenetrationUnitsCurrentPortfoli__c, DistributionEconomicActivityEmployees__c,
                       IndependentEconomicActDistribution__c, DistributionGenderWomen__c, DistributionGenderMen__c,
                       Men18to30Years__c, Men31to40Years__c, Men41to50Years__c, Men51to60Years__c, Men61to70Years__c,
                       Men70Years__c, Women18to30Years__c, Women31to40Years__c, Women41to50Years__c, Women51to60Years__c,
                       Women61to70Years__c, Women70Years__c,YearsToConsiderRunoff__c
                       FROM Opportunity WHERE Id = :opportunityId LIMIT 1];
        
        // Consulta para obtener los campos del producto de la oportunidad
        opportunityProduct = [SELECT Name, RequiredProduct__c, ProductModality__c, PolicyType__c, ProductAimedCustomers__c,
                              PremiumCalculation__c, CommercializationChannel__c, MarketingManager__c, TentativeEffectiveDate__c,
                              DescriptionInsuranceObject__c, CoverageProtectionAssistance__c, SpecialConditions__c, InsuredValues__c,
                              CreditAmountAverage__c, CreditAmountMaxima__c, CreditAmountMinimum__c, CreditServiceTermAverage__c,
                              CreditservicetermMinimum__c, CreditTermserviceMaxima__c, MonthlyFeeAverage__c, MonthlyFeeMaximum__c,
                              MonthlyFeeMinimum__c, MonthlyPaymentsforProtectionMaxima__c, MonthlyPaymentsforProtectionMinimum__c,
                              ProtectionMonthlyPaymentsAverage__c, FeeType__c, AnnualorMonthlyInterestRate__c, Annualcustomerchurnrate__c,
                              TotalBalance0a12months__c, TotalBalance13a18months__c, TotalBalance19a24months__c, TotalBalance25a30months__c,
                              TotalBalance31a36months__c, TotalBalance37a42months__c, TotalBalance43a48months__c, TotalBalance49a54months__c,
                              TotalBalance55a60months__c, TotalBalancemorethan60months__c, TotalNumberofCredits0a12months__c,NumberofCredits0a12months__c,
                              TotalNumberofCredits13a18months__c, TotalNumberofCredits19a24months__c,TotalNumberofCredits25a30months__c,
                              TotalNumberofCredits31a36months__c, TotalNumberofCredits37a42months__c, TotalNumberofCredits43a48months__c,
                              TotalNumberofCredits49a54months__c, TotalNumberofCredits55a60months__c, TotalNumberofCreditsmorethan60months__c,
                              Disabilitywaitingperiod__c, DefinitionoftheBenefitIncapQuotas__c,TotalMonths__c,PremiumType__c,Description,
                              DisabilityBenefitPayment__c, UnemploymentWaitingPeriod__c, UnemploymentWaitPeriod__c, DefinitionofBenefitDesemFees__c,
                              UnemploymentBenefitPayment__c, Desciption__c,TargetRate__c,TransferOriginCompany__c,DisabilityWaitPeriod__c
                              FROM OpportunityLineItem 
                              WHERE OpportunityId = :opportunityId LIMIT 1];
    }
    
    public String getFormattedFirstYear() {
        return formatDecimal(opportunity.FirstYear__c);
    }
    
    public String getFormattedSecondYear() {
        return formatDecimal(opportunity.SecondYear__c);
    }
    
    public String getFormattedThirdYear() {
        return formatDecimal(opportunity.ThirdYear__c);
    }
    
    public String getFormattedFourthYear() {
        return formatDecimal(opportunity.FourthYear__c);
    }
    
    public String getFormattedFifthYear() {
        return formatDecimal(opportunity.FifthYear__c);
    }
    
    public String getFormattedTotalBalance0a12months() {
        return formatDecimal(opportunityProduct.TotalBalance0a12months__c);
    }
    
    public String getFormattedTotalBalance13a18months() {
        return formatDecimal(opportunityProduct.TotalBalance13a18months__c);
    }
    
    public String getFormattedTotalBalance19a24months() {
        return formatDecimal(opportunityProduct.TotalBalance19a24months__c);
    }
    
    public String getFormattedTotalBalance25a30months() {
        return formatDecimal(opportunityProduct.TotalBalance25a30months__c);
    }
    
    public String getFormattedTotalBalance31a36months() {
        return formatDecimal(opportunityProduct.TotalBalance31a36months__c);
    }
    
    public String getFormattedTotalBalance37a42months() {
        return formatDecimal(opportunityProduct.TotalBalance37a42months__c);
    }
    
    public String getFormattedTotalBalance43a48months() {
        return formatDecimal(opportunityProduct.TotalBalance43a48months__c);
    }
    
    public String getFormattedTotalBalance49a54months() {
        return formatDecimal(opportunityProduct.TotalBalance49a54months__c);
    }
    
    public String getFormattedTotalBalance55a60months() {
        return formatDecimal(opportunityProduct.TotalBalance55a60months__c);
    }
    
    public String getFormattedTotalBalancemorethan60months() {
        return formatDecimal(opportunityProduct.TotalBalancemorethan60months__c);
    }
    
    public String getFormattedTotalMonths() {
        return formatDecimal(opportunityProduct.TotalMonths__c);
    }
    
     public String getFormattedCreditAmountMinimum() {
        return formatDecimal(opportunityProduct.CreditAmountMinimum__c);
    }
    
    public String getFormattedCreditAmountAverage() {
        return formatDecimal(opportunityProduct.CreditAmountAverage__c);
    }
    
    public String getFormattedCreditAmountMaxima() {
        return formatDecimal(opportunityProduct.CreditAmountMaxima__c);
    }
    
    public String getFormattedCreditServiceTermMinimum() {
        return formatDecimal(opportunityProduct.CreditServiceTermMinimum__c);
    }
    
    public String getFormattedCreditServiceTermAverage() {
        return formatDecimal(opportunityProduct.CreditServiceTermAverage__c);
    }
    
    public String getFormattedCreditServiceTermMaxima() {
        return formatDecimal(opportunityProduct.CreditTermserviceMaxima__c);
    }
    
    public String getFormattedMonthlyFeeMinimum() {
        return formatDecimal(opportunityProduct.MonthlyFeeMinimum__c);
    }
    
    public String getFormattedMonthlyFeeAverage() {
        return formatDecimal(opportunityProduct.MonthlyFeeAverage__c);
    }
    
    public String getFormattedMonthlyFeeMaximum() {
        return formatDecimal(opportunityProduct.MonthlyFeeMaximum__c);
    }
    
    public String getFormattedMonthlyPaymentsforProtectionMinimum() {
        return formatDecimal(opportunityProduct.MonthlyPaymentsforProtectionMinimum__c);
    }
    
    public String getFormattedProtectionMonthlyPaymentsAverage() {
        return formatDecimal(opportunityProduct.ProtectionMonthlyPaymentsAverage__c);
    }
    
    public String getFormattedMonthlyPaymentsforProtectionMaxima() {
        return formatDecimal(opportunityProduct.MonthlyPaymentsforProtectionMaxima__c);
    }
    
    private String formatDecimal(Decimal value) {
        if (value == null) return '';
        return value.setScale(2, RoundingMode.HALF_UP).format();
    }
    
}