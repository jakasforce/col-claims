/**
 * @description       :
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             :
 * @last modified on  : 07-28-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 **/
public with sharing class CS_DocumentoCaso_Helper {
	public enum MomentosEnvio {
		NUNCA
	}
	public static final String MOMENTO_ENVIO_NUNCA = 'Nunca';

	public static final String ESTADO_SINCRONIZACION_SUPERFINANCIERA_NO_ENVIADO = 'No enviado';

	public static CS_DocumentoCaso__c createDocumentoCaso(Id idCaso, String name, MomentosEnvio momentoEnvio, Boolean doInsert) {
		CS_DocumentoCaso__c newDocumentoCaso = new CS_DocumentoCaso__c();
		newDocumentoCaso.CS_Caso__c = idCaso;
		newDocumentoCaso.Name = name;
		newDocumentoCaso.CS_EstadoSincronizacionSuperfinanciera__c = ESTADO_SINCRONIZACION_SUPERFINANCIERA_NO_ENVIADO;

		switch on momentoEnvio {
			when NUNCA {
				newDocumentoCaso.CS_MomentoEnvio__c = MOMENTO_ENVIO_NUNCA;
			}
			when else {
			}
		}

		if (doInsert) {
			insert newDocumentoCaso;
		}

		return newDocumentoCaso;
	}
}