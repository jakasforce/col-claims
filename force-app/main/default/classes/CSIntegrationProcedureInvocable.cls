/**
 * @description       : 
 * @author            : diego.jacanamijoy@oc.vasscompany.com
 * @group             : 
 * @last modified on  : 08-20-2024
 * @last modified by  : diego.jacanamijoy@oc.vasscompany.com
**/
global with sharing class CSIntegrationProcedureInvocable {
    
    @InvocableMethod(label = 'Integration Procedure')
    global static List < IntegrationProcedureOutput > runIntegrationServiceInvocable(List <IntegrationProcedureInput> input) {
    
        IntegrationProcedureOutput result = new IntegrationProcedureOutput();
        Map <String, Object> params;

        if (input[0].params != null) {
            params = buildMapParams(input[0].params);
        } else {
            params = new Map <String, Object>{'ClaimId' => input[0].input};
        }

        result.output = JSON.serialize(
        omnistudio.IntegrationProcedureService.runIntegrationService(
        input[0].procedureAPIName,
        params,
        new Map <String, Object> ()));
        System.debug('result' + JSON.serialize(result));
        return new List <IntegrationProcedureOutput>{result};
    }

    private static Map<String, Object> buildMapParams(List<IPInputParams> params) {
        Map<String, Object> paramValueByName = new Map<String, Object>();
        for (IPInputParams inputParam : params) {
            paramValueByName.put(inputParam.paramName, inputParam.paramValue);
        }
        return paramValueByName;
    }

    global class IntegrationProcedureInput{
        @InvocableVariable(label = 'Procedure Name')
        global String procedureAPIName;
        @InvocableVariable(label = 'Input')
        global String input;
        @InvocableVariable(label = 'Input params')
        global List<IPInputParams> params;
    }

    global class IntegrationProcedureOutput{
        @InvocableVariable(label = 'Output')
        global String output;
    }

    /*global class InputParams{
        @InvocableVariable(label = 'Param name') 
        @AuraEnabled
        global String paramName;
        @InvocableVariable(label = 'Param value')
        @AuraEnabled 
        global String paramValue;
        global InputParams(){}
    }*/
}