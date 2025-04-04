/*************************************************************************************/
/* Desarrollado por: VASS 
/* Autor:            Johan Becerra
/* Proyecto:         Colmena Seguros
/* Descripción:      Clase administradora de Correos electronicos (EmailMessage)
/* Clase de prueba:  CS_EmailMessageTriggerHandler_Test

/* Cambios (Versiones) 
/* ----------------------------------------------------------------------------------- 
/* No.  Fecha       Autor                   Descripción 
/* ---- ----------- ----------------------- ------------------------------------------
/* 1.0  02-05-2024  Johan Becerra           Creación del handler correspondiente al
/*                                          Trigger de EmailMessage
/*************************************************************************************/
public class CS_EmailMessageTriggerHandler {
    public static void OnBeforeInsert(List<EmailMessage> newEmailMessages) {
    	// Consulta para obtener todos los Address de EmailRoutingAddress
    	Set<String> addressesFromRoutingAddress = new Set<String>();
    	Set<String> domainsFromRoutingAddress = new Set<String>();
    	List<EmailRoutingAddress> routingAddresses = [SELECT Address FROM EmailRoutingAddress WHERE EmailServicesAddressId != null AND Address != null];		
    	
        Integer Limiter = Integer.valueOf(System.Label.Limiter);
    	// Iterar sobre cada mensaje de correo electrónico nuevo	
    	for (EmailMessage email : newEmailMessages) {
        	// Verificar si el campo 'Headers' contiene el texto 'X-SFDC-Original-RCPT:'
        	if (!String.isEmpty(email.Headers) && email.Headers.contains('X-SFDC-Original-RCPT:')) {
            	// Verificar si el campo 'ToAddress' excede los 4000 caracteres
           		if (!String.isEmpty(email.ToAddress) && email.ToAddress.length() >= Limiter || 
                   (!String.isEmpty(email.CcAddress) && email.CcAddress.length() >= Limiter)) {                       
                    	// Truncar el campo CcAddress si supera el límite
                	if (!String.isEmpty(email.CcAddress) && email.CcAddress.length() >= limiter) {
                    	Integer lastSemicolonIndex = email.CcAddress.lastIndexOf(';', limiter);
                    	if (lastSemicolonIndex != -1) {
                        	email.CcAddress = email.CcAddress.substring(0, lastSemicolonIndex);
                    	}
                	}
                       
                    for (EmailRoutingAddress routingAddress : routingAddresses) {
    					addressesFromRoutingAddress.add(routingAddress.Address);
    					System.debug('obtuvo de addresses From Routing Address: ' + addressesFromRoutingAddress);
    
    					// Extraer el dominio y agregarlo al conjunto
    					String[] parts = routingAddress.Address.split('@');
                        System.debug('obtuvo de parts 1: ' + parts);
    					if (parts.size() == 2) {
        					domainsFromRoutingAddress.add(parts[1]);
        					System.debug('obtuvo de domains From Routing Address: ' + domainsFromRoutingAddress);
    					}
					}
                	// Obtener correos electrónicos del campo 'ToAddress'
                	Set<String> toAddresses = new Set<String>();
                	List<String> emailAddresses = email.ToAddress.split(';');
                    System.debug('obtuvo de lista email Addresses: ' + emailAddresses);
                    
                	Integer currentLength = 0;              
                	// Iterar sobre cada dirección de correo electrónico
                	for (String emailAddr : emailAddresses) {
                    	if (!String.isEmpty(emailAddr.trim())) {
                        	// Verificar si la dirección está en la consulta de EmailRoutingAddress
                        	if (addressesFromRoutingAddress.contains(emailAddr.trim())) {
                            	toAddresses.add(emailAddr.trim());
                                System.debug('obtuvo de toAddresses 1: ' + toAddresses);
                            	currentLength += emailAddr.trim().length() + 1; // Sumar 1 para el ";"
                                System.debug('obtuvo de currentLength 1: ' + currentLength);
                        	}
                    	}
                	}
                
                	// Iterar nuevamente sobre cada dirección de correo electrónico
                	
                	for (String emailAddr : emailAddresses) {
                    	if (!String.isEmpty(emailAddr.trim())) {
                        	// Extraer el dominio de la dirección de correo electrónico actual
                        	String[] parts = emailAddr.trim().split('@');
                            System.debug('obtuvo de partss: ' + parts);
                        	if (parts.size() == 2) {
                            	String domain = parts[1];
                                System.debug('obtuvo de domain: ' + domain);
                            	// Comparar el dominio con los dominios obtenidos de EmailRoutingAddress
                            	if (domainsFromRoutingAddress.contains(domain)) {
                                	// Verificar si agregar esta dirección excederá el límite de caracteres
                                	if (currentLength + emailAddr.trim().length() + 1 <= Limiter) { // Sumar 1 para el ";"
                                    	if (!toAddresses.contains(emailAddr.trim())) {
                                        	if (currentLength > 0) {
                                            	currentLength++; // Sumar 1 para el ";" si no es el primer correo
                                                System.debug('obtuvo de currentLength 2: ' + currentLength);
                                        	}
                                        	toAddresses.add(emailAddr.trim());
                                        	currentLength += emailAddr.trim().length();
                                            System.debug('obtuvo de currentLength 3: ' + currentLength);
                                    	}
                                	} else {
                                    	break; // Detener la concatenación si excede el límite de caracteres
                                	}
                            	}
                        	}
                    	}
                	}
                
                	// Asignar los correos electrónicos coincidentes al campo 'ToAddress'
                	if (!toAddresses.isEmpty()) {
                    	email.ToAddress = String.join(new List<String>(toAddresses), ';');
                        System.debug('obtuvo de email.ToAddress: ' + email.ToAddress);
                	}
            	}
        	}
    	}        
	}
    

    public static void OnAfterInsert(EmailMessage[] newRecords){
		
	}
    
    public static void OnBeforeUpdate(EmailMessage[] oldRecords, EmailMessage[] updatedRecords, Map<ID, EmailMessage> recordMap){
		
	}
    
    public static void OnAfterUpdate(EmailMessage[] oldRecords, EmailMessage[] updatedRecords, Map<ID, EmailMessage> recordMap){
		
	}
    
    public static void OnBeforeDelete(EmailMessage[] recordsToDelete){
		
	}    
    
    public static void OnAfterDelete(EmailMessage[] deletedRecords){
		
	} 
}