import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';

import POLICY_COVERAGE_FIELD from '@salesforce/schema/Opportunity.Policy_Coverage_Continuity__c';
import POLICY_ACCIDENT_FIELD from '@salesforce/schema/Opportunity.Policy_with_Accident_Rate__c';
import POLICY_DEPENDENT_FIELD from '@salesforce/schema/Opportunity.Policy_with_Dependent_Insured__c';

export default class ShowToastQuestionsMessageLWC extends LightningElement {

    @api recordId;

     policyCoverageContinuity;
     policyWithAccidentRate;
     policyWithDependentInsured;
     showMessage = false;
 
     @wire(getRecord, { recordId: '$recordId', fields: [POLICY_COVERAGE_FIELD, POLICY_ACCIDENT_FIELD, POLICY_DEPENDENT_FIELD] })
     wiredOpportunity({ error, data }) {
         if (data) {

             this.policyCoverageContinuity = data.fields.Policy_Coverage_Continuity__c.value;
             this.policyWithAccidentRate = data.fields.Policy_with_Accident_Rate__c.value;
             this.policyWithDependentInsured = data.fields.Policy_with_Dependent_Insured__c.value;
 
             console.log('Valor de Policy_Coverage_Continuity__c:', this.policyCoverageContinuity);
             console.log('Valor de Policy_with_Accident_Rate__c:', this.policyWithAccidentRate);
             console.log('Valor de Policy_with_Dependent_Insured__c:', this.policyWithDependentInsured);
 
             if (this.policyCoverageContinuity === 'NO' && this.policyWithAccidentRate === 'NO' && this.policyWithDependentInsured === 'NO') {
                 console.log('Todos los campos tienen el valor NO');
                 this.showMessage = true; 
             } else {
                 console.log('No todos los campos tienen el valor SI');
                 this.showMessage = false; 
             }
         } else if (error) {
             console.error('Error al cargar la oportunidad', error);
         }
     }
}