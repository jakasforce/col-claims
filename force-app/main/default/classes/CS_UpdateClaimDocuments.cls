/**
 * @description       : Class for create document links and update code in contenversions
 * @author            : diego.jacanamijoy@oc.vasscompany.com
 * @group             : 
 * @last modified on  : 02-14-2025
 * @last modified by  : diego.jacanamijoy@oc.vasscompany.com
**/
public with sharing class CS_UpdateClaimDocuments {

    private static String claimId; 
    private static Object documentdataJSON;
    private static List<ContentDocumentLink> documentsByClaim;//Contentdocumentlinks to create
    private static Map<String,Integer> fileCodeByDocumentId;
    
    /**
    * @description main method to recibe params and call validateDocumentData method
    * @author diego.jacanamijoy@oc.vasscompany.com | 02-14-2025 
    * @param params 
    **/
    public static void excecute(InputParams params) {

        claimId = params.claimId;
        documentdataJSON = params.documentdataJSON;

        validateDocumentData();
    }

    /**
    * @description Method to check JSON object from IP
    * @author diego.jacanamijoy@oc.vasscompany.com | 02-14-2025 
    **/
    @TestVisible
    private static void validateDocumentData() {

        //Initialice variables
        documentsByClaim = new List<ContentDocumentLink>();
        fileCodeByDocumentId = new Map<String,Integer>();

        //Check if JSON is a list or object to parse in Map
        if (documentdataJSON instanceof List<Object>) {
            //Iterate List of object
            for (Object documentObject : (List<Object>)documentdataJSON) {
                Map<String,Object> documentDataMap = (Map<String,Object>)documentObject;
                //Call method to check files by document
                checkDocumentFiles((Integer)documentDataMap.get('document_code'), documentDataMap.get('documentFile'));
            }
        } else {
            Map<String,Object> documentDataMap = (Map<String,Object>)documentdataJSON;
            //Call method to check files by document
            checkDocumentFiles((Integer)documentDataMap.get('document_code'), documentDataMap.get('documentFile'));
        }

        //Check if there are records to process
        if (!documentsByClaim.isEmpty()) {
            //Insert content document links
            insert documentsByClaim;

            //Clall method to update content document code
            updateContentVersionCode();
        }
    }

    /**
    * @description Method to check the object of each file
    * @author diego.jacanamijoy@oc.vasscompany.com | 02-14-2025 
    * @param documentCode 
    * @param documentFiles 
    **/
    @TestVisible
    private static void checkDocumentFiles(Integer documentCode, Object documentFiles) {

        //Check if JSON is a list or object to parse in Map
        if (documentFiles != null && documentFiles instanceof List<Object>) {
            //Iterate list of object
            for (Object documentObject : (List<Object>)documentFiles) {
                Map<String,Object> documentFileMap = (Map<String,Object>)documentObject;
                //create content document link
                documentsByClaim.add(
                    new ContentDocumentLink (
                        LinkedEntityId = claimId,
                        ContentDocumentId = (String)documentFileMap.get('data')
                    )
                );
                //Put data into map
                fileCodeByDocumentId.put((String)documentFileMap.get('data'), documentCode);
            }
            
        } else if (documentFiles != null) {
            Map<String,Object> documentFileMap = (Map<String,Object>)documentFiles;
            //create content document link
            documentsByClaim.add(
                new ContentDocumentLink (
                    LinkedEntityId = claimId,
                    ContentDocumentId = (String)documentFileMap.get('data')
                )
            );
            //Put data into map
            fileCodeByDocumentId.put((String)documentFileMap.get('data'), documentCode);
        }
    }

    /**
    * @description Method to update code in content version records
    * @author diego.jacanamijoy@oc.vasscompany.com | 02-14-2025 
    **/
    @TestVisible
    private static void updateContentVersionCode() {

        //Get content document version
        List<ContentVersion> contentVersions = [SELECT ContentDocumentId FROM ContentVersion WHERE ContentDocumentId IN: fileCodeByDocumentId.keySet()];

        //Iterate list of content version and update code
        for (ContentVersion version : contentVersions) {
            version.DocumentCode_fileupload__c = String.valueOf(fileCodeByDocumentId.get(version.ContentDocumentId));
        }

        //Update code
        if (!contentVersions.isEmpty()) {
            update contentVersions;
        }
    }

    /** Inner class to model input params */
    public class InputParams {

        public String claimId; 
        public Object documentdataJSON;
    }
}