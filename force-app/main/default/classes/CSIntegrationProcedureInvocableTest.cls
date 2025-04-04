/**
 * @description       : 
 * @author            : diego.jacanamijoy@oc.vasscompany.com
 * @group             : 
 * @last modified on  : 08-16-2024
 * @last modified by  : diego.jacanamijoy@oc.vasscompany.com
**/
@IsTest
public with sharing class CSIntegrationProcedureInvocableTest {
    
    @IsTest
    static void invokeIP() {

        CSIntegrationProcedureInvocable.IntegrationProcedureInput input = new CSIntegrationProcedureInvocable.IntegrationProcedureInput();
        input.procedureAPIName = 'flow_test';

        IPInputParams params = new  IPInputParams('accountId', '123456');

        input.params = new List<IPInputParams>{params};

        List <CSIntegrationProcedureInvocable.IntegrationProcedureOutput> result = CSIntegrationProcedureInvocable.runIntegrationServiceInvocable(
            new List<CSIntegrationProcedureInvocable.IntegrationProcedureInput>{input}
        );

        System.debug('result: ' + result);
    }
}