/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 02-26-2025
 * @last modified by  : diego.jacanamijoy@oc.vasscompany.com
**/
@isTest
public with sharing class CS_CallApexActionUtilTest {

    @isTest
    static void invokeMethodTest() {
        CS_CallApexActionUtil util = new CS_CallApexActionUtil();
        
        Map<String, Object> inputMap = new Map<String, Object>{
            'claimId' => '12345',
            'responseData' => new Map<String, Object>{ 'key1' => 'value1', 'key2' => 123 }
        };
        
        Map<String, Object> outputMap = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();
        
        Test.startTest();
        Object result = util.invokeMethod('updateDocumentData', inputMap, outputMap, options);
        Test.stopTest();
        
        System.assertEquals('OK', result, 'El resultado debería ser OK');
    }

    @isTest
    static void invokeMethodTestKO() {

        CS_CallApexActionUtil util = new CS_CallApexActionUtil();
        Map<String, Object> inputMap = new Map<String, Object>();
        Map<String, Object> outputMap = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();

        //Build main object
        Map<String, Object> args = new Map<String, Object>{
            'input' => inputMap,
            'output' => outputMap,
            'options' => options
        };


        Boolean exceptionThrown = false;
        
        try {
            Test.startTest();
            util.call('invalidMethod', args);
            Test.stopTest();
        } catch (Exception e) {
            exceptionThrown = true;
        }
        
        System.assert(exceptionThrown, 'Se esperaba una excepción para un método no válido');
    }
}