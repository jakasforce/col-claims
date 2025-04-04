/**
 * @description       : Class to atend remote actions from IP
 * @author            : diego.jacanamijoy@oc.vasscompany.com
 * @group             : 
 * @last modified on  : 02-25-2025
 * @last modified by  : diego.jacanamijoy@oc.vasscompany.com
**/
global with sharing class CS_CallApexActionUtil implements Callable {

    public Object call(String action, Map<String, Object> args)
    {
        Map<String, Object> input = (Map<String, Object>) args.get('input');
        Map<String, Object> output = (Map<String, Object>) args.get('output');
        Map<String, Object> options = (Map<String, Object>) args.get('options');
        return invokeMethod(action, input, output, options);
    }
    
    /**
    * @description Aux method to call CS_UpdateClaimDocuments helper class
    * @author diego.jacanamijoy@oc.vasscompany.com | 02-14-2025 
    * @param claimId 
    * @param documentdataJSON 
    * @return String 
    **/
    public String updateDocumentData(String claimId, Object documentdataJSON) {

        CS_UpdateClaimDocuments.InputParams params = new CS_UpdateClaimDocuments.InputParams();
        params.claimId = claimId;
        params.documentdataJSON = documentdataJSON;
        
        CS_UpdateClaimDocuments.excecute(params);
        return 'OK';
    }


    
    /**
    * @description Main method to validate inputs params from a IP
    * @author diego.jacanamijoy@oc.vasscompany.com | 02-14-2025 
    * @param methodName 
    * @param inputMap 
    * @param outMap 
    * @param options 
    * @return Object 
    **/
    public Object invokeMethod(String methodName, Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options) {

        switch on methodName {
            when 'updateDocumentData' {
                return this.updateDocumentData((String)inputMap.get('claimId'), inputMap.get('responseData'));
            }
            when else {
                throw new ExtensionMalformedCallException('Method not implemented');
            }
        }
    }

    public class ExtensionMalformedCallException extends Exception {}
}