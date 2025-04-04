/**
 * @description       : 
 * @author            : diego.jacanamijoy@oc.vasscompany.com
 * @group             : 
 * @last modified on  : 02-14-2025
 * @last modified by  : diego.jacanamijoy@oc.vasscompany.com
**/
@isTest
public with sharing class CS_UpdateClaimDocumentsTest {
    
    @isTest
    static void testExecuteWithMultipleDocuments() {

        Case testCase = createCase();
        String contentDocId1 = createContentDocument();
        String contentDocId2 = createContentDocument();

        CS_UpdateClaimDocuments.InputParams params = new CS_UpdateClaimDocuments.InputParams();
        params.claimId = testCase.Id;
        params.documentdataJSON = new List<Object>{
            new Map<String, Object>{
                'document_code' => 101,
                'documentFile' => new List<Object>{
                    new Map<String, Object>{ 'data' => contentDocId1 }
                }
            },
            new Map<String, Object>{
                'document_code' => 102,
                'documentFile' => new List<Object>{
                    new Map<String, Object>{ 'data' => contentDocId2 }
                }
            }
        };

        Test.startTest();
        CS_UpdateClaimDocuments.excecute(params);
        Test.stopTest();

        System.assertEquals(2, [SELECT COUNT() FROM ContentDocumentLink WHERE LinkedEntityId = :testCase.Id],
                            'Deberían haberse insertado 2 ContentDocumentLink');

        System.assertEquals(2, [SELECT COUNT() FROM ContentVersion WHERE DocumentCode_fileupload__c != NULL],
                            'Deberían haberse actualizado 2 ContentVersion');
    }
    
    @isTest
    static void testExecuteWithSingleDocument() {

        Case testCase = createCase();
        String contentDocId = createContentDocument();

        CS_UpdateClaimDocuments.InputParams params = new CS_UpdateClaimDocuments.InputParams();
        params.claimId = testCase.Id;
        params.documentdataJSON = new Map<String, Object>{
            'document_code' => 103,
            'documentFile' => new Map<String, Object>{ 'data' => contentDocId }
        };

        Test.startTest();
        CS_UpdateClaimDocuments.excecute(params);
        Test.stopTest();

        System.assertEquals(1, [SELECT COUNT() FROM ContentDocumentLink WHERE LinkedEntityId = :testCase.Id],
                            'Debería haberse insertado 1 ContentDocumentLink');

        System.assertEquals(1, [SELECT COUNT() FROM ContentVersion WHERE DocumentCode_fileupload__c != NULL],
                            'Debería haberse actualizado 1 ContentVersion');
    }

    private static Case createCase() {
        Case testCase = new Case();
        insert testCase;
        return [SELECT Id FROM Case WHERE Id = :testCase.Id LIMIT 1];
    }

    private static String createContentDocument() {
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Test Document',
            VersionData = Blob.valueOf('Test Data'),
            PathOnClient = 'Test.pdf'
        );
        insert contentVersion;

        return [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id LIMIT 1].ContentDocumentId;
    }
}