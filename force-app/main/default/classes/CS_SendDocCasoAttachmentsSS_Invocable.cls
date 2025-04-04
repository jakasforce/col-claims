/*****************************************************************************************************************************
 * Apex Class Name	:	CS_SmartSupervision_Invocable
 * Version			:	1.0
 * Created Date	    :	23/05/2022
 * Function 		: 	Clase con el método invocables utilizado por el flow Case After Update
 * Test Class		:	CS_SmartSupervision_Test
 *----------------------------------------------------------------------------------------------------------------------------
 *                                                MODIFICATION LOG
 *----------------------------------------------------------------------------------------------------------------------------
 * Developer		     	Date			   	Description
 * ---------------------------------------------------------------------------------------------------------------------------
 * Angel Cabezas           23/05/2022          Original Version
 *****************************************************************************************************************************/
global with sharing class CS_SendDocCasoAttachmentsSS_Invocable {
	@InvocableMethod(
		label='Smart Supervision Enviar Documento Caso (MOMENTO 3)'
		description='Envía un documento adjuntos a un caso a la Superintendencia Financiera de Colombia'
		category='CS_DocumentoCaso__c'
	)
	global static void sendAttachedFile(List<CS_DocumentoCaso__c> documentosCasos) {
		System.debug('--------------  CS_SmartSupervision_Invocable.sendAttachedFile --------------');
		System.debug('1. CS_SmartSupervision_Invocable.sendAttachedFile documentosCasos: ' + documentosCasos);

		Set<Id> setIdDocumentosCasos = new Set<Id>();
		for (CS_DocumentoCaso__c documentoCaso : documentosCasos) {
			setIdDocumentosCasos.add(documentoCaso.Id);
		}

		List<ContentDocumentLink> fileLinks = [
			SELECT Id, LinkedEntityId, ContentDocumentId,ContentDocument.Title
			FROM ContentDocumentLink
			WHERE LinkedEntityId IN :setIdDocumentosCasos order by ContentDocument.CreatedDate desc
		];
		System.debug('2. CS_SmartSupervision_Invocable.sendAttachedFile fileLinks: ' + fileLinks);

		Map<Id, Id> mapIdDocumentoCasoIdContentDocument = new Map<Id, Id>();
		
		System.debug(
			'3. CS_SmartSupervision_Invocable.sendAttachedFilesCase mapIdDocumentoCasoIdContentDocument: ' +
			mapIdDocumentoCasoIdContentDocument
		);

		for (CS_DocumentoCaso__c documentoCaso : documentosCasos) {
            for (ContentDocumentLink fileLink : fileLinks) {
                
                if(fileLink.LinkedEntityId == documentoCaso.Id ){
                mapIdDocumentoCasoIdContentDocument.put(fileLink.LinkedEntityId, fileLink.ContentDocumentId);
                CS_SmartSupervision_Future.addFileFuture(
				documentoCaso.CS_Caso__c,
				mapIdDocumentoCasoIdContentDocument.get(documentoCaso.Id),
				documentoCaso.Id
			); 
                }
		
		}
			
		}
	}

	
}