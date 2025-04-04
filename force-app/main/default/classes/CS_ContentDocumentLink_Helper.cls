/**
 * @description       :
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             :
 * @last modified on  : 07-29-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 **/
public with sharing class CS_ContentDocumentLink_Helper {
	public static void reparentCaseContentDocumentLinks(Set<Id> contentDocumentIdSet, List<ContentDocumentLink> contentDocumentLinkList) {
		System.debug('--------------  CS_ContentDocumentLink_Helper.reparentCaseContentDocumentLinks  --------------');
		System.debug(
			'1.1 CS_ContentDocumentLink_Helper.reparentCaseContentDocumentLinks contentDocumentLinkList.size(): ' +
			contentDocumentLinkList.size()
		);
		System.debug(
			'1.2 CS_ContentDocumentLink_Helper.reparentCaseContentDocumentLinks contentDocumentLinkList: ' + contentDocumentLinkList
		);
		Map<Id, ContentDocument> contentDocumentMap = new Map<Id, ContentDocument>(
			[SELECT Id, Title, FileType FROM ContentDocument WHERE Id IN :contentDocumentIdSet]
		);
		List<CS_DocumentoCaso__c> newDocumentoCasoList = new List<CS_DocumentoCaso__c>();
		for (ContentDocumentLink contDocLink : contentDocumentLinkList) {
			ContentDocument currentContentDocument = contentDocumentMap.get(contDocLink.ContentDocumentId);
			CS_DocumentoCaso__c newDocumentoCaso = CS_DocumentoCaso_Helper.createDocumentoCaso(
				contDocLink.LinkedEntityId,
				currentContentDocument.Title,
				CS_DocumentoCaso_Helper.MomentosEnvio.NUNCA,
				false
			);
			//newDocumentoCasoList.add(newDocumentoCaso);
            if(currentContentDocument.FileType != 'SNOTE'){
                newDocumentoCasoList.add(newDocumentoCaso);
            }
            
		}

		Database.SaveResult[] srList = Database.insert(newDocumentoCasoList, false);

		for (Integer i = 0; i < srList.size(); i++) {
			Database.SaveResult sr = srList.get(i);
			if (sr.isSuccess()) {
				//contentDocumentLinkList[i].LinkedEntityId = sr.getId();
			} else {
			}
		}
	}

	public static void addNewLinkEmailContentDocumentLinks(
		Set<Id> contentDocumentIdSet,
		List<ContentDocumentLink> contentDocumentLinkList,
		Set<Id> contentDocumentLinkedEntityIdSet
	) {
		System.debug('--------------  CS_ContentDocumentLink_Helper.addNewLinkEmailContentDocumentLinks  --------------');
		System.debug(
			'1.1 CS_ContentDocumentLink_Helper.addNewLinkEmailContentDocumentLinks contentDocumentLinkList.size(): ' +
			contentDocumentLinkList.size()
		);
		System.debug(
			'1.2 CS_ContentDocumentLink_Helper.addNewLinkEmailContentDocumentLinks contentDocumentLinkList: ' + contentDocumentLinkList
		);
		Map<Id, ContentDocument> contentDocumentMap = new Map<Id, ContentDocument>(
			[SELECT Id, Title FROM ContentDocument WHERE Id IN :contentDocumentIdSet]
		);
		Map<Id, EmailMessage> emailMessageMap = new Map<Id, EmailMessage>(
			[SELECT Id, ParentId FROM EmailMessage WHERE Id IN :contentDocumentLinkedEntityIdSet]
		);
		List<CS_DocumentoCaso__c> newDocumentoCasoList = new List<CS_DocumentoCaso__c>();
		for (ContentDocumentLink contDocLink : contentDocumentLinkList) {
			ContentDocument currentContentDocument = contentDocumentMap.get(contDocLink.ContentDocumentId);
			EmailMessage currentEmailMessage = emailMessageMap.get(contDocLink.LinkedEntityId);
			CS_DocumentoCaso__c newDocumentoCaso = CS_DocumentoCaso_Helper.createDocumentoCaso(
				currentEmailMessage.ParentId,
				currentContentDocument.Title,
				CS_DocumentoCaso_Helper.MomentosEnvio.NUNCA,
				false
			);
			newDocumentoCasoList.add(newDocumentoCaso);
		}

		Database.SaveResult[] srList = Database.insert(newDocumentoCasoList, false);

		List<ContentDocumentLink> newContentDocumentLinkList = new List<ContentDocumentLink>();
		for (Integer i = 0; i < srList.size(); i++) {
			Database.SaveResult sr = srList.get(i);
			if (sr.isSuccess()) {
				ContentDocumentLink currentContentDocumentLink = contentDocumentLinkList.get(i);
				ContentDocumentLink newContentDocumentLink = new ContentDocumentLink();
				newContentDocumentLink.LinkedEntityId = sr.getId();
				newContentDocumentLink.ContentDocumentId = currentContentDocumentLink.ContentDocumentId;
				newContentDocumentLink.ShareType = currentContentDocumentLink.ShareType;
                newContentDocumentLinkList.add(newContentDocumentLink);
			} else {
			}
		}

		Database.SaveResult[] cdlSrList = Database.insert(newContentDocumentLinkList, false);
	}
}