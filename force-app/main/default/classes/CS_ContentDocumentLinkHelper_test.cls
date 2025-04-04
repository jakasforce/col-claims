/*****************************************************************************************************************************
 * Apex Class Name	:	CS_ContentDocumentLinkHelper_test
 * Version			:	1.0
 * Created Date	    :	20/09/2022
 * Function 		: 	Prueba el funcionamiento de la clase CS_ContentDocumentLinkHelper_test
 * Test Class		:	???
 *----------------------------------------------------------------------------------------------------------------------------
 *                                                MODIFICATION LOG
 *----------------------------------------------------------------------------------------------------------------------------
 * Developer		     	Date			   	Description
 * ---------------------------------------------------------------------------------------------------------------------------
 * Fernanda Villafaña           20/09/2022          Original Version
 *****************************************************************************************************************************/
@isTest
public class CS_ContentDocumentLinkHelper_test {
	@isTest
    static void reparentCaseContentDocumentLinks(){
        Map<Schema.SObjectField, Object> customFieldsMap= new Map<Schema.SObjectField, Object>();
        customFieldsMap.put(Case.Status, 'Escalado');
        Case caso= CS_TestDataFactory.createCase(customFieldsMap,true);
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Test',
            PathOnClient = 'Test.pdf',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion;
        ContentVersion content= [Select ID, FileExtension, VersionData, title, ContentDocumentId FROM ContentVersion WHERE isLatest=true LIMIT 1];
        ContentDocumentLink con= new ContentDocumentLink();
        con.ContentDocumentId= content.ContentDocumentId;
        con.LinkedEntityId=caso.Id;
        insert con;
        Set<Id> ids= new set<Id>();
        ids.add(content.ContentDocumentId);
        List<ContentDocumentLink> listCD= new List<ContentDocumentLink>();
        listCD.add(con);
        List <CS_DocumentoCaso__c> lstDocs1= [SELECT Id FROM CS_DocumentoCaso__c WHERE CS_Caso__c=:caso.Id];
        System.assertEquals(1,lstDocs1.size(), 'Antes de actualizarse no se creo el documentoCaso');
        CS_ContentDocumentLink_Helper.reparentCaseContentDocumentLinks(ids,listCD);
        List <CS_DocumentoCaso__c> lstDocs= [SELECT Id FROM CS_DocumentoCaso__c WHERE CS_Caso__c=:caso.Id];
        System.assertEquals(2,lstDocs.size(), 'No se creo el DocumentoCaso correctamente');

    }
    @isTest
    static void addNewLink(){
        Map<Schema.SObjectField, Object> customFieldsMap= new Map<Schema.SObjectField, Object>();
        customFieldsMap.put(Case.Status, 'Escalado');
        Case caso= CS_TestDataFactory.createCase(customFieldsMap,true);
        EmailMessage email= new EmailMessage();
        email.ParentId=caso.Id;
        insert email;
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Test',
            PathOnClient = 'Test.pdf',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion;
        ContentVersion content= [Select ID, FileExtension, VersionData, title, ContentDocumentId FROM ContentVersion WHERE isLatest=true LIMIT 1];
        ContentDocumentLink con= new ContentDocumentLink();
        con.ContentDocumentId= content.ContentDocumentId;
        con.LinkedEntityId=email.Id;
        insert con;
        Set<Id> ids= new set<Id>();
        ids.add(content.ContentDocumentId);
        Set<Id>setLinks= new set<Id>();
        setLinks.add(con.LinkedEntityId);
        List<ContentDocumentLink> listCD= new List<ContentDocumentLink>();
        listCD.add(con);
        List<ContentDocumentLink> listCDL1=[SELECT Id FROM ContentDocumentLink WHERE ContentDocumentId= :content.ContentDocumentId];
        System.assertEquals(3,listCDL1.size(), 'Antes de actualizarse no se crearon los ContentDocumentLink correctamente');
        CS_ContentDocumentLink_Helper.addNewLinkEmailContentDocumentLinks(ids,listCD,setLinks );
        List <CS_DocumentoCaso__c> lstDocs= [SELECT Id FROM CS_DocumentoCaso__c WHERE CS_Caso__c=:caso.Id];
        System.assertEquals(2,lstDocs.size(), 'No se creo el DocumentoCaso correctamente');
        List<ContentDocumentLink> listCDL=[SELECT Id FROM ContentDocumentLink WHERE ContentDocumentId= :content.ContentDocumentId];
        System.assertEquals(4,listCDL.size(), 'No se creo el ContentDocumentLink correctamente');

    }
}