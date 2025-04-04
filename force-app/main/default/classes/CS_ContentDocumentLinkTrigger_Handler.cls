/**
 * @description       :
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             :
 * @last modified on  : 07-29-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 **/
public with sharing class CS_ContentDocumentLinkTrigger_Handler {
	public static void beforeInsert(List<ContentDocumentLink> newContentDocumentLinkList) {
		System.debug('--------------  CS_ContentDocumentLinkTrigger_Handler.beforeInsert  --------------');
		List<ContentDocumentLink> caseContentDocumentLinkList = new List<ContentDocumentLink>();
		List<ContentDocumentLink> emailMessageContentDocumentLinkList = new List<ContentDocumentLink>();
		Set<Id> caseContentDocumentIdSet = new Set<Id>();
		Set<Id> emailMessageContentDocumentIdSet = new Set<Id>();
        Set<Id> contentDocumentLinkedEntityIdSet = new Set<Id>();
		for (ContentDocumentLink newContentDocumentLink : newContentDocumentLinkList) {
			System.debug(
				'2. CS_ContentDocumentLinkTrigger_Handler.beforeInsert newContentDocumentLink.ParentId: ' +
				newContentDocumentLink.LinkedEntityId
			);
			if (newContentDocumentLink.LinkedEntityId != null) {
                contentDocumentLinkedEntityIdSet.add(newContentDocumentLink.LinkedEntityId);
				Schema.DescribeSObjectResult parentObjectType = newContentDocumentLink.LinkedEntityId.getSobjectType().getDescribe();
				if (parentObjectType == Schema.SObjectType.Case) {
					caseContentDocumentLinkList.add(newContentDocumentLink);
					caseContentDocumentIdSet.add(newContentDocumentLink.ContentDocumentId);
				} else if (parentObjectType == Schema.SObjectType.emailMessage) {
					emailMessageContentDocumentLinkList.add(newContentDocumentLink);
					emailMessageContentDocumentIdSet.add(newContentDocumentLink.ContentDocumentId);
				}
			}
			CS_ContentDocumentLink_Helper.reparentCaseContentDocumentLinks(caseContentDocumentIdSet, caseContentDocumentLinkList);
			CS_ContentDocumentLink_Helper.addNewLinkEmailContentDocumentLinks(
				emailMessageContentDocumentIdSet,
				emailMessageContentDocumentLinkList,
                contentDocumentLinkedEntityIdSet
			);
		}
	}
}