/**
 * @description       : 
 * @author            : diego.jacanamijoy@oc.vasscompany.com
 * @group             : 
 * @last modified on  : 08-16-2024
 * @last modified by  : diego.jacanamijoy@oc.vasscompany.com
**/
global with sharing class IPInputParams {
    
    
    //@AuraEnabled annotation exposes the methods to Lightning Components and Flows
    @InvocableVariable(label = 'Param name') 
    @AuraEnabled
    global String paramName;
    @InvocableVariable(label = 'Param value')
    @AuraEnabled 
    global String paramValue;
 
    // Define the structure of the Apex-Defined Variable
    public IPInputParams(
            String paramName,
            String paramValue
    ) {
        this.paramName = paramName;
        this.paramValue = paramValue;
    }
 
    // Required no-argument constructor
    public IPInputParams() {}
}