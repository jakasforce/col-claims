/**
 * @description       : 
 * @author            : Diego Jacanamijoy -> diego.jacanamijoy@vass.com
 * @group             : 
 * @last modified on  : 21/10/2023
 * @last modified by  : diego.jacanamijoy@vass.com
**/
@IsTest
public with sharing class InsuranceCoveragePicklistTest {

    @TestSetup
    static void makeData(){

        Account injured = new Account();
        injured.Name = 'Injured Test';
        insert injured;
        
        InsurancePolicy policy = new InsurancePolicy();
        policy.Name = 'Test policy';
        policy.NameInsuredId = injured.Id;
        insert policy;
        
        InsurancePolicyCoverage coveragePicklist = new InsurancePolicyCoverage();
        coveragePicklist.CoverageName = 'Coverage Test';
        coveragePicklist.InsurancePolicyId = policy.Id;
        insert coveragePicklist;
    }
    
    @IsTest
    static void invoqueMethodOK() {

        Map<String, Object> input = new Map<String, Object>();
        Map<String, Object> outMap = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();

        InsuranceCoveragePicklist coveragePicklist = new InsuranceCoveragePicklist();
        coveragePicklist.invokeMethod('populatePicklist', input, outMap, options);
    }
}