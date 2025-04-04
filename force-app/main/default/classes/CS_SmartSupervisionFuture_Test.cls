/***************************************************************************************************************************
 * Nombre de la Clase Apex : CS_SmartSupervisionFuture_Test
 * Versión                 : 1.0
 * Fecha de Creación       : 09/09/2022
 * Funcionalidad           : Generación de datos para pruebas
 *--------------------------------------------------------------------------------------------------------------------------
 *                                              HISTORIAL DE MODIFICACIONES:
 *--------------------------------------------------------------------------------------------------------------------------
 * Desarrollador         Fecha           Descripción
 *--------------------------------------------------------------------------------------------------------------------------
 * Fernanda Villafaña         09/09/2022     Modificación
 *--------------------------------------------------------------------------------------------------------------------------
 **************************************************************************************************************************/
@isTest
class CS_SmartSupervisionFuture_Test {
    //Get complains
    @isTest
	static void newComplainPersonalExito(){ 
        Test.setMock(HttpCalloutMock.class, new mockNewCP());
        CS_SmartSupervisionConstants__c cons= new CS_SmartSupervisionConstants__c();
        cons.CS_GetComplainsEndpoint__c='http://endpoint.com';
        cons.CS_GetFileEndpoint__c='http://endpoint.com';
        cons.CS_SmartSupervisionUsername__c='username';
        insert cons;
         test.startTest();
         CS_SmartSupervision_Future.getComplainsFuture('1');
         test.stopTest();
        Account newAcc= [SELECT Id FROM Account WHERE CS_TipoIdentificacionCP__pc='2' AND CS_NumeroIdentificacionCP__pc='999846'];
        Case caso= [SELECT Id, status FROM Case];
        System.assertNotEquals(null, newAcc, 'No se creo la personAccount');
        System.assertEquals('Réplica', caso.Status, 'No se creo el caso en la prioridad adecuada');
    }
    @isTest
    static void newComplainPersonalFallido(){ 
        Test.setMock(HttpCalloutMock.class, new mockNewCPError ());
        CS_SmartSupervisionConstants__c cons= new CS_SmartSupervisionConstants__c();
        cons.CS_GetComplainsEndpoint__c='http://endpoint.com';
        cons.CS_GetFileEndpoint__c='http://endpoint.com';
        cons.CS_SmartSupervisionUsername__c='username';
        insert cons;
         test.startTest();
         CS_SmartSupervision_Future.getComplainsFuture('1');
         test.stopTest();
        List<CS_Log__c> logs=[SELECT Id FROM CS_Log__c];
        //system.assertEquals(3, logs.size(), 'Error crear log');
       
    }
    
    /*@isTest
	static void newComplainJuridicalExito(){ 
        Test.setMock(HttpCalloutMock.class, new mockNewJ());
        CS_SmartSupervisionConstants__c cons= new CS_SmartSupervisionConstants__c();
        cons.CS_GetComplainsEndpoint__c='http://endpoint.com';
        cons.CS_GetFileEndpoint__c='http://endpoint.com';
        cons.CS_SmartSupervisionUsername__c='username';
        insert cons;
        test.startTest();
        CS_SmartSupervision_Future.getComplainsFuture('1');
        test.stopTest();
        Account newAcc= [SELECT Id FROM Account WHERE CS_TipoIdentificacion__c='3' AND CS_NumeroIdentificacion__c='999846'];
        Case caso= [SELECT Id, status FROM Case];
        System.assertNotEquals(null, newAcc, 'No se creo la personAccount');
        //System.assertEquals('Réplica', caso.Status, 'No se creo el caso en la prioridad adecuada');
    }*/

    @isTest
	static void newComplainJuridicalFallido(){ 
        Test.setMock(HttpCalloutMock.class, new mockNewJError());
        CS_SmartSupervisionConstants__c cons= new CS_SmartSupervisionConstants__c();
        cons.CS_GetComplainsEndpoint__c='http://endpoint.com';
        cons.CS_GetFileEndpoint__c='http://endpoint.com';
        cons.CS_SmartSupervisionUsername__c='username';
        insert cons;
        test.startTest();
        CS_SmartSupervision_Future.getComplainsFuture('1');
        test.stopTest();
        List<CS_Log__c> logs=[SELECT Id FROM CS_Log__c];
        system.assertEquals(3, logs.size(), 'Error crear log');
    }
@isTest
	static void prePersonalExito(){
        Map<Schema.SObjectField, Object> customFieldsMap= new Map<Schema.SObjectField, Object>();
        customFieldsMap.put(Account.CS_Empresa_Colmena__c, '1');
        customFieldsMap.put(Account.CS_NumeroIdentificacionCP__pc, '99999');
        customFieldsMap.put(Account.CS_TipoIdentificacionCP__pc, '1');
        customFieldsMap.put(Account.CS_Sexo__pc, '10');
        customFieldsMap.put(Account.CS_LGBTIQ__pc, '2');
        customFieldsMap.put(Account.CS_Condicionespecial__pc, '98');
        Account acc= CS_TestDataFactory.createPersonAccount(customFieldsMap,true);  
        Test.setMock(HttpCalloutMock.class, new mockPreCP());
        CS_SmartSupervisionConstants__c cons= new CS_SmartSupervisionConstants__c();
        cons.CS_GetComplainsEndpoint__c='http://endpoint.com';
        cons.CS_GetFileEndpoint__c='http://endpoint.com';
        cons.CS_SmartSupervisionUsername__c='username';
        insert cons;
         test.startTest();
         CS_SmartSupervision_Future.getComplainsFuture('1');
         test.stopTest();
        Account newAcc= [SELECT Id FROM Account WHERE CS_TipoIdentificacionCP__pc='1' AND CS_NumeroIdentificacionCP__pc='99999'];
        Case caso= [SELECT Id, status FROM Case];
        System.assertNotEquals(null, newAcc, 'No se encontró la personAccount');
        System.assertEquals('Réplica', caso.Status, 'No se creo el caso en la prioridad adecuada');
    }
@isTest
	static void prePersonalFallido(){
        Map<Schema.SObjectField, Object> customFieldsMap= new Map<Schema.SObjectField, Object>();
        customFieldsMap.put(Account.CS_Empresa_Colmena__c, '1');
        customFieldsMap.put(Account.CS_NumeroIdentificacionCP__pc, '99999');
        customFieldsMap.put(Account.CS_TipoIdentificacionCP__pc, '1');
        customFieldsMap.put(Account.CS_Sexo__pc, '10');
        customFieldsMap.put(Account.CS_LGBTIQ__pc, '2');
        customFieldsMap.put(Account.CS_Condicionespecial__pc, '98');
        Account acc= CS_TestDataFactory.createPersonAccount(customFieldsMap,true);  
        Test.setMock(HttpCalloutMock.class, new mockPreCPError());
        CS_SmartSupervisionConstants__c cons= new CS_SmartSupervisionConstants__c();
        cons.CS_GetComplainsEndpoint__c='http://endpoint.com';
        cons.CS_GetFileEndpoint__c='http://endpoint.com';
        cons.CS_SmartSupervisionUsername__c='username';
        insert cons;
         test.startTest();
         CS_SmartSupervision_Future.getComplainsFuture('1');
         test.stopTest();
        List<CS_Log__c> logs=[SELECT Id FROM CS_Log__c];
        system.assertEquals(2, logs.size(), 'Error crear log');
    }
 @isTest
	static void preJuridicalExito(){
        Map<Schema.SObjectField, Object> customFieldsMap= new Map<Schema.SObjectField, Object>();
        customFieldsMap.put(Account.CS_Empresa_Colmena__c, '1');
        customFieldsMap.put(Account.CS_NumeroIdentificacion__c, '99999');
        customFieldsMap.put(Account.CS_TipoIdentificacion__c, '3');
        Account acc= CS_TestDataFactory.createAccount(customFieldsMap,true);  
        Test.setMock(HttpCalloutMock.class, new mockPreJ());
        CS_SmartSupervisionConstants__c cons= new CS_SmartSupervisionConstants__c();
        cons.CS_GetComplainsEndpoint__c='http://endpoint.com';
        cons.CS_GetFileEndpoint__c='http://endpoint.com';
        cons.CS_SmartSupervisionUsername__c='username';
        insert cons;
         test.startTest();
         CS_SmartSupervision_Future.getComplainsFuture('1');
         test.stopTest();
        Account newAcc= [SELECT Id FROM Account WHERE CS_TipoIdentificacion__c='3' AND CS_NumeroIdentificacion__c='99999'];
        Case caso= [SELECT Id, status FROM Case];
        System.assertNotEquals(null, newAcc, 'No se encontró la personAccount');
        System.assertEquals('Réplica', caso.Status, 'No se creo el caso en la prioridad adecuada');
    }
    
 @isTest
	static void preJuridicalFallido(){
        Map<Schema.SObjectField, Object> customFieldsMap= new Map<Schema.SObjectField, Object>();
        customFieldsMap.put(Account.CS_Empresa_Colmena__c, '1');
        customFieldsMap.put(Account.CS_NumeroIdentificacion__c, '99999');
        customFieldsMap.put(Account.CS_TipoIdentificacion__c, '3');
        Account acc= CS_TestDataFactory.createAccount(customFieldsMap,true);  
        Test.setMock(HttpCalloutMock.class, new mockPreJError());
        CS_SmartSupervisionConstants__c cons= new CS_SmartSupervisionConstants__c();
        cons.CS_GetComplainsEndpoint__c='http://endpoint.com';
        cons.CS_GetFileEndpoint__c='http://endpoint.com';
        cons.CS_SmartSupervisionUsername__c='username';
        insert cons;
         test.startTest();
         CS_SmartSupervision_Future.getComplainsFuture('1');
         test.stopTest();
        List<CS_Log__c> logs=[SELECT Id FROM CS_Log__c];
        system.assertEquals(2, logs.size(), 'Error crear log');
    }
   @isTest
	static void updatePersonalExito(){
        Map<Schema.SObjectField, Object> customFieldsMap= new Map<Schema.SObjectField, Object>();
        customFieldsMap.put(Account.CS_Empresa_Colmena__c, '1');
        customFieldsMap.put(Account.CS_NumeroIdentificacionCP__pc, '99999');
        customFieldsMap.put(Account.CS_TipoIdentificacionCP__pc, '1');
        Account acc= CS_TestDataFactory.createPersonAccount(customFieldsMap,true);  
        Test.setMock(HttpCalloutMock.class, new mockUpdateCP());
        CS_SmartSupervisionConstants__c cons= new CS_SmartSupervisionConstants__c();
        cons.CS_GetComplainsEndpoint__c='http://endpoint.com';
        cons.CS_GetFileEndpoint__c='http://endpoint.com';
        cons.CS_SmartSupervisionUsername__c='username';
        insert cons;
         test.startTest();
         CS_SmartSupervision_Future.getComplainsFuture('1');
         test.stopTest();
        Account newAcc= [SELECT Id, CS_Sexo__pc FROM Account WHERE CS_TipoIdentificacionCP__pc='1' AND CS_NumeroIdentificacionCP__pc='99999'];
        Case caso= [SELECT Id, status FROM Case];
        System.assertEquals('3', newAcc.CS_Sexo__pc, 'No se actualizó la personAccount');
        System.assertEquals('Réplica', caso.Status, 'No se creo el caso en la prioridad adecuada');
    } 
   @isTest
	static void updatePersonalFallido(){
        Map<Schema.SObjectField, Object> customFieldsMap= new Map<Schema.SObjectField, Object>();
        customFieldsMap.put(Account.CS_Empresa_Colmena__c, '1');
        customFieldsMap.put(Account.CS_NumeroIdentificacionCP__pc, '99999');
        customFieldsMap.put(Account.CS_TipoIdentificacionCP__pc, '1');
        Account acc= CS_TestDataFactory.createPersonAccount(customFieldsMap,true);  
        Test.setMock(HttpCalloutMock.class, new mockUpdateCPError());
        CS_SmartSupervisionConstants__c cons= new CS_SmartSupervisionConstants__c();
        cons.CS_GetComplainsEndpoint__c='http://endpoint.com';
        cons.CS_GetFileEndpoint__c='http://endpoint.com';
        cons.CS_SmartSupervisionUsername__c='username';
        insert cons;
         test.startTest();
         CS_SmartSupervision_Future.getComplainsFuture('1');
         test.stopTest();
        List<CS_Log__c> logs=[SELECT Id FROM CS_Log__c];
        //system.assertEquals(3, logs.size(), 'Error crear log');
    } 
//Get complain files***********************************************************************************************************************
    @isTest
	static void getComplainFilesExito(){
		Case caso= CS_TestDataFactory.createCase(true);  
        Test.setMock(HttpCalloutMock.class, new mockGetFiles());
        CS_SmartSupervisionConstants__c cons= new CS_SmartSupervisionConstants__c();
        cons.CS_GetComplainsEndpoint__c='http://endpoint.com';
        cons.CS_GetFileEndpoint__c='http://endpoint.com';
        cons.CS_SmartSupervisionUsername__c='username';
        insert cons;
         test.startTest();
         CS_SmartSupervision_Future.getComplainFilesFuture(caso.Id);
         test.stopTest();
         CS_DocumentoCaso__c newFile=[SELECT Id FROM CS_DocumentoCaso__c];
         Case casoActualizado=[SELECT Id, CS_SmartSupervisionACK__c, CS_SmartSupervisionNuevosAdjuntos__c FROM Case WHERE Id=:caso.Id];
         System.assertNotEquals(null,newFile, 'No se creo el documento');
         System.assertEquals(true, casoActualizado.CS_SmartSupervisionACK__c, 'Error al actualizar el caso');
    }  
    
//Get ack***********************************************************************************************************************
    @isTest
	static void ackFutureExito(){
		Case caso= CS_TestDataFactory.createCase(true); 
        List<Id>lstCasos= new List<Id>();
        lstCasos.add(caso.Id);
        Test.setMock(HttpCalloutMock.class, new mockAck());
        CS_SmartSupervisionConstants__c cons= new CS_SmartSupervisionConstants__c();
        cons.CS_GetComplainsEndpoint__c='http://endpoint.com';
        cons.CS_GetFileEndpoint__c='http://endpoint.com';
        cons.CS_SmartSupervisionUsername__c='username';
        insert cons;
         test.startTest();
         CS_SmartSupervision_Future.ackFuture(lstCasos);
         test.stopTest();
        List<CS_Log__c> logs=[SELECT Id, CS_ShortDescription__c FROM CS_Log__c];
        system.assertEquals('Smart Supervision: Momento 1 - ACK (CORRECTO)', logs[0].CS_ShortDescription__c, 'Error crear log');
    }  
    @isTest
	static void ackFallido(){
		Case caso= CS_TestDataFactory.createCase(true); 
        List<Id>lstCasos= new List<Id>();
        lstCasos.add(caso.Id);
        Test.setMock(HttpCalloutMock.class, new mockAckError());
        CS_SmartSupervisionConstants__c cons= new CS_SmartSupervisionConstants__c();
        cons.CS_GetComplainsEndpoint__c='http://endpoint.com';
        cons.CS_GetFileEndpoint__c='http://endpoint.com';
        cons.CS_SmartSupervisionUsername__c='username';
        insert cons;
         test.startTest();
         CS_SmartSupervision_Future.ackFuture(lstCasos);
         test.stopTest();
        List<CS_Log__c> logs=[SELECT Id, CS_ShortDescription__c FROM CS_Log__c];
        system.assertEquals('Smart Supervision: Momento 1 - ACK (FALLIDO)', logs[0].CS_ShortDescription__c, 'Error crear log');
    } 
   
  //Get files***********************************************************************************************************************
    @isTest
	static void getFiles(){
		Case caso= CS_TestDataFactory.createCase(true); 
        CS_DocumentoCaso__c doc= new CS_DocumentoCaso__c();
        doc.CS_Caso__c=caso.Id;
        doc.CS_SmartSupervisionTemporalURL__c='www.temporal.com/6498494?';
        insert doc;
        Test.setMock(HttpCalloutMock.class, new mockFiles());
        CS_SmartSupervisionConstants__c cons= new CS_SmartSupervisionConstants__c();
        cons.CS_GetComplainsEndpoint__c='http://endpoint.com';
        cons.CS_GetFileEndpoint__c='http://endpoint.com';
        cons.CS_SmartSupervisionUsername__c='username';
        insert cons;
         test.startTest();
         CS_SmartSupervision_Future.getFileFuture(doc.Id);
         test.stopTest();
         List <Attachment> att=[SELECT id FROM Attachment WHERE parentId=:doc.Id];
        System.assertEquals(1, att.size(), 'No se creo el attachment');
    }    
 //Create Case***********************************************************************************************************************
    @isTest
	static void createCaseExito(){
		Case caso= CS_TestDataFactory.createCase(true); 
        Map<Schema.SObjectField, Object> customFieldsMap= new Map<Schema.SObjectField, Object>();
        customFieldsMap.put(Account.CS_Empresa_Colmena__c, '1');
        customFieldsMap.put(Account.CS_NumeroIdentificacionCP__pc, '99999');
        customFieldsMap.put(Account.CS_TipoIdentificacionCP__pc, '1');
        Account acc= CS_TestDataFactory.createPersonAccount(customFieldsMap,true);
        Test.setMock(HttpCalloutMock.class, new mockCreateCase());
        CS_SmartSupervisionConstants__c cons= new CS_SmartSupervisionConstants__c();
        cons.CS_GetComplainsEndpoint__c='http://endpoint.com';
        cons.CS_GetFileEndpoint__c='http://endpoint.com';
        cons.CS_SmartSupervisionUsername__c='username';
        insert cons;
         test.startTest();
         CS_SmartSupervision_Future.createCaseFuture(caso.id, acc.Id);
         test.stopTest();
        Case casoActualizado=[SELECT Id, CS_EstadoSincronizacionSuperfinanciera__c FROM Case WHERE Id=:caso.id];
        //System.assertEquals('Actualizando', casoActualizado.CS_EstadoSincronizacionSuperfinanciera__c, 'No se creó correctamente la queja');
        
    }  
     @isTest
	static void createCaseFallido(){
		Case caso= CS_TestDataFactory.createCase(true); 
        Map<Schema.SObjectField, Object> customFieldsMap= new Map<Schema.SObjectField, Object>();
        customFieldsMap.put(Account.CS_Empresa_Colmena__c, '1');
        customFieldsMap.put(Account.CS_NumeroIdentificacionCP__pc, '99999');
        customFieldsMap.put(Account.CS_TipoIdentificacionCP__pc, '1');
        Account acc= CS_TestDataFactory.createPersonAccount(customFieldsMap,true);
        Test.setMock(HttpCalloutMock.class, new mockCreateCaseError());
        CS_SmartSupervisionConstants__c cons= new CS_SmartSupervisionConstants__c();
        cons.CS_GetComplainsEndpoint__c='http://endpoint.com';
        cons.CS_GetFileEndpoint__c='http://endpoint.com';
        cons.CS_SmartSupervisionUsername__c='username';
        insert cons;
         test.startTest();
         CS_SmartSupervision_Future.createCaseFuture(caso.id, acc.Id);
         test.stopTest();
        Case casoActualizado=[SELECT Id, CS_EstadoSincronizacionSuperfinanciera__c FROM Case WHERE Id=:caso.id];
        System.assertEquals('No radicado (error al radicar)', casoActualizado.CS_EstadoSincronizacionSuperfinanciera__c, 'No se creó correctamente la queja');
        
    }  
 //Update Case***********************************************************************************************************************
    @isTest
	static void updateCaseExito(){
		Case caso= CS_TestDataFactory.createCase(true); 
        Map<Schema.SObjectField, Object> customFieldsMap= new Map<Schema.SObjectField, Object>();
        customFieldsMap.put(Account.CS_Empresa_Colmena__c, '1');
        customFieldsMap.put(Account.CS_NumeroIdentificacionCP__pc, '99999');
        customFieldsMap.put(Account.CS_TipoIdentificacionCP__pc, '1');
        Account acc= CS_TestDataFactory.createPersonAccount(customFieldsMap,true);
        Test.setMock(HttpCalloutMock.class, new mockUpdateCase());
        CS_SmartSupervisionConstants__c cons= new CS_SmartSupervisionConstants__c();
        cons.CS_GetComplainsEndpoint__c='http://endpoint.com';
        cons.CS_GetFileEndpoint__c='http://endpoint.com';
        cons.CS_SmartSupervisionUsername__c='username';
        insert cons;
         test.startTest();
         CS_SmartSupervision_Future.updateCaseFuture(caso.id, acc.Id);
         test.stopTest();
        Case casoActualizado=[SELECT Id, CS_EstadoSincronizacionSuperfinanciera__c FROM Case WHERE Id=:caso.id];
        //System.assertEquals('Actualizando', casoActualizado.CS_EstadoSincronizacionSuperfinanciera__c, 'No se creó correctamente la queja');
        
    }  
     @isTest
	static void updateCaseFallido(){
		Case caso= CS_TestDataFactory.createCase(true);
        Map<Schema.SObjectField, Object> customFieldsMap= new Map<Schema.SObjectField, Object>();
        customFieldsMap.put(Account.CS_Empresa_Colmena__c, '1');
        customFieldsMap.put(Account.CS_NumeroIdentificacionCP__pc, '99999');
        customFieldsMap.put(Account.CS_TipoIdentificacionCP__pc, '1');
        Account acc= CS_TestDataFactory.createPersonAccount(customFieldsMap,true);
        Test.setMock(HttpCalloutMock.class, new mockUpdateCaseError());
        CS_SmartSupervisionConstants__c cons= new CS_SmartSupervisionConstants__c();
        cons.CS_GetComplainsEndpoint__c='http://endpoint.com';
        cons.CS_GetFileEndpoint__c='http://endpoint.com';
        cons.CS_SmartSupervisionUsername__c='username';
        insert cons;
         test.startTest();
         CS_SmartSupervision_Future.updateCaseFuture(caso.id, acc.Id);
         test.stopTest();
        Case casoActualizado=[SELECT Id, CS_EstadoSincronizacionSuperfinanciera__c FROM Case WHERE Id=:caso.id];
        //System.assertEquals('Actualizando', casoActualizado.CS_EstadoSincronizacionSuperfinanciera__c, 'No se creó correctamente la queja');
        
    }
    
  //AddFile***********************************************************************************************************************
    @isTest
	static void AddFileExito(){
		Case caso= CS_TestDataFactory.createCase(true); 
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Test',
            PathOnClient = 'Test.pdf',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion;
        ContentVersion content= [Select ID, FileExtension, VersionData, title, ContentDocumentId FROM ContentVersion WHERE isLatest=true LIMIT 1];
        CS_DocumentoCaso__c doc= new CS_DocumentoCaso__c();
        doc.CS_Caso__c=caso.Id;
        doc.CS_SmartSupervisionTemporalURL__c='www.temporal.com/6498494?';
        insert doc;
        Test.setMock(HttpCalloutMock.class, new mockAddFile());
        CS_SmartSupervisionConstants__c cons= new CS_SmartSupervisionConstants__c();
        cons.CS_GetComplainsEndpoint__c='http://endpoint.com';
        cons.CS_GetFileEndpoint__c='http://endpoint.com';
        cons.CS_SmartSupervisionUsername__c='username';
        insert cons;
         test.startTest();
         CS_SmartSupervision_Future.addFileFuture(caso.id, content.ContentDocumentId, doc.Id);
         test.stopTest();
        CS_DocumentoCaso__c docActualizado=[SELECT Id, CS_EstadoSincronizacionSuperfinanciera__c FROM CS_DocumentoCaso__c WHERE Id=:doc.Id];  
        System.assertEquals('Enviado', docActualizado.CS_EstadoSincronizacionSuperfinanciera__c, 'No se creó correctamente la queja');
        
    }
      @isTest
	static void AddFileFallido(){
		Case caso= CS_TestDataFactory.createCase(true); 
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Test',
            PathOnClient = 'Test.pdf',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion;
        ContentVersion content= [Select ID, FileExtension, VersionData, title, ContentDocumentId FROM ContentVersion WHERE isLatest=true LIMIT 1];
        CS_DocumentoCaso__c doc= new CS_DocumentoCaso__c();
        doc.CS_Caso__c=caso.Id;
        doc.CS_SmartSupervisionTemporalURL__c='www.temporal.com/6498494';
        insert doc;
        Test.setMock(HttpCalloutMock.class, new mockAddFileFallido());
        CS_SmartSupervisionConstants__c cons= new CS_SmartSupervisionConstants__c();
        cons.CS_GetComplainsEndpoint__c='http://endpoint.com';
        cons.CS_GetFileEndpoint__c='http://endpoint.com';
        cons.CS_SmartSupervisionUsername__c='username';
        insert cons;
         test.startTest();
         CS_SmartSupervision_Future.addFileFuture(caso.id, content.ContentDocumentId, doc.Id);
         test.stopTest();
        CS_DocumentoCaso__c docActualizado=[SELECT Id, CS_EstadoSincronizacionSuperfinanciera__c FROM CS_DocumentoCaso__c WHERE Id=:doc.Id];  
        System.assertEquals('Fallido', docActualizado.CS_EstadoSincronizacionSuperfinanciera__c, 'No se creó correctamente la queja');
        
    }
    
    @isTest
    static void clasePruebaMaster(){
        CS_SmartSupervision_Future.clasePruebaMaster();
    }
     
     private class mockAddFile implements HttpCalloutMock {
  	public HTTPResponse respond(HTTPRequest req) {
        if(req.getEndpoint()=='callout:SmartSupervision/login/'){
			HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"refresh":"refresh1234", "access":"access456"}');
            response.setStatusCode(200);
            response.setStatus('Success');
            return response;               
        }else{
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            CS_WrapperSmartSupervision.AddFileResponseType res= new CS_WrapperSmartSupervision.AddFileResponseType();
            res.type='tipo';
            res.id=1212;
            response.setBody(JSON.serialize(res));
            response.setStatusCode(201);
            response.setStatus('Success');
            return response; 
        }   
    	}
}
         private class mockAddFileFallido implements HttpCalloutMock {
  	public HTTPResponse respond(HTTPRequest req) {
        if(req.getEndpoint()=='callout:SmartSupervision/login/'){
			HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"refresh":"refresh1234", "access":"access456"}');
            response.setStatusCode(200);
            response.setStatus('Success');
            return response;               
        }else{
            HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"status_code":"400", "detail":"error", "message":"mensaje"}');
        response.setStatusCode(400);
        response.setStatus('Error');
        return response;
        }   
    	}
}
  private class mockUpdateCase implements HttpCalloutMock {
  	public HTTPResponse respond(HTTPRequest req) {
        if(req.getEndpoint()=='callout:SmartSupervision/login/'){
			HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"refresh":"refresh1234", "access":"access456"}');
            response.setStatusCode(200);
            response.setStatus('Success');
            return response;               
        }else{
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            CS_WrapperSmartSupervision.UpdateComplainResponseType res= new CS_WrapperSmartSupervision.UpdateComplainResponseType();
            res.codigo_queja='codigo123';
            res.producto_cod=2;
            response.setBody(JSON.serialize(res));
            response.setStatusCode(200);
            response.setStatus('Success');
            return response; 
        }   
    	}
}     
  private class mockUpdateCaseError implements HttpCalloutMock {
  	public HTTPResponse respond(HTTPRequest req) {
        if(req.getEndpoint()=='callout:SmartSupervision/login/'){
			HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"refresh":"refresh1234", "access":"access456"}');
            response.setStatusCode(200);
            response.setStatus('Success');
            return response;               
        }else{
            HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"status_code":"400", "detail":"error", "message":"mensaje"}');
        response.setStatusCode(400);
        response.setStatus('Error');
        return response; 
        }   
    	}
}     
  private class mockCreateCase implements HttpCalloutMock {
  	public HTTPResponse respond(HTTPRequest req) {
        if(req.getEndpoint()=='callout:SmartSupervision/login/'){
			HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"refresh":"refresh1234", "access":"access456"}');
            response.setStatusCode(200);
            response.setStatus('Success');
            return response;               
        }else{
            HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        CS_WrapperSmartSupervision.CreateComplainResponseType res= new CS_WrapperSmartSupervision.CreateComplainResponseType();
       	res.tipo_entidad=1;
        res.entidad_cod=10;
        response.setBody(JSON.serialize(res));
        response.setStatusCode(201);
        response.setStatus('Success');
        return response;  
        }   
    	}
}   
  private class mockCreateCaseError implements HttpCalloutMock {
  	public HTTPResponse respond(HTTPRequest req) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"status_code":"400", "detail":"error", "message":"mensaje"}');
        response.setStatusCode(400);
        response.setStatus('Error');
        return response; 
        }   
    	
}
  private class mockFiles implements HttpCalloutMock {
  	public HTTPResponse respond(HTTPRequest req) {
        if(req.getEndpoint()=='callout:SmartSupervision/login/'){
			HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"refresh":"refresh1234", "access":"access456"}');
            response.setStatusCode(200);
            response.setStatus('Success');
            return response;               
        }else{
            HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        CS_WrapperSmartSupervision.GetFileResponseType res= new CS_WrapperSmartSupervision.GetFileResponseType();
       	res.blobFile=Blob.valueOf('File');
        response.setBody(JSON.serialize(res));
        response.setStatusCode(200);
        response.setStatus('Success');
        return response;
        }   
    	}
}   
    
  private class mockAck implements HttpCalloutMock {
  	public HTTPResponse respond(HTTPRequest req) {
        if(req.getEndpoint()=='callout:SmartSupervision/login/'){
			HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"refresh":"refresh1234", "access":"access456"}');
            response.setStatusCode(200);
            response.setStatus('Success');
            return response;               
        }else{
            HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        CS_WrapperSmartSupervision.ACKResponseType res= new CS_WrapperSmartSupervision.ACKResponseType();
       	res.message='Mensaje';
        List<String> lstErrs= new List<String>();
        res.pqrs_error=lstErrs;
        response.setBody(JSON.serialize(res));
        response.setStatusCode(200);
        response.setStatus('Success');
        return response;
        }   
    	}
}    
   private class mockAckError implements HttpCalloutMock {
  	public HTTPResponse respond(HTTPRequest req) {
        if(req.getEndpoint()=='callout:SmartSupervision/login/'){
			HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"refresh":"refresh1234", "access":"access456"}');
            response.setStatusCode(200);
            response.setStatus('Success');
            return response;               
        }else{
            HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        CS_WrapperSmartSupervision.ACKResponseType res= new CS_WrapperSmartSupervision.ACKResponseType();
       	res.message='Mensaje';
        List<String> lstErrs= new List<String>();
        res.pqrs_error=lstErrs;
        response.setBody(JSON.serialize(res));
        response.setStatusCode(400);
        response.setStatus('Success');
        return response;
        }   
    	}
}    
   private class mockGetFiles implements HttpCalloutMock {
  	public HTTPResponse respond(HTTPRequest req) {
        if(req.getEndpoint()=='callout:SmartSupervision/login/'){
			HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"refresh":"refresh1234", "access":"access456"}');
            response.setStatusCode(200);
            response.setStatus('Success');
            return response;               
        }else{
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            CS_WrapperSmartSupervision.GetComplainFilesResponseType res= new CS_WrapperSmartSupervision.GetComplainFilesResponseType();
            res.count=1;
            res.pages=1;
            res.current_page=1;
            res.next='next';
            res.previous='previous';
            CS_WrapperSmartSupervision.ComplainFileResponseType com= new CS_WrapperSmartSupervision.ComplainFileResponseType();
            List<CS_WrapperSmartSupervision.ComplainFileResponseType> lstcom= new List<CS_WrapperSmartSupervision.ComplainFileResponseType>();
            com.id=1216;
            com.file='Files';
            lstcom.add(com);
            res.results=lstcom;
            response.setBody(JSON.serialize(res));
            response.setStatusCode(200);
            response.setStatus('Success');
            return response; 
        }   
    	}
}
    

    
    //Mock get complains***********************************************************************************************************************
    private class mockUpdateCP implements HttpCalloutMock {
  	public HTTPResponse respond(HTTPRequest req) {
        if(req.getEndpoint()=='callout:SmartSupervision/login/'){
			HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"refresh":"refresh1234", "access":"access456"}');
            response.setStatusCode(200);
            response.setStatus('Success');
            return response;               
        }else{
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            CS_WrapperSmartSupervision.GetComplainsResponseType res= new CS_WrapperSmartSupervision.GetComplainsResponseType();
            res.count=1;
            res.pages=1;
            res.current_page=1;
            res.next='next';
            res.previous='previous';
            CS_WrapperSmartSupervision.GetComplainResponseType com= new CS_WrapperSmartSupervision.GetComplainResponseType();
            List<CS_WrapperSmartSupervision.GetComplainResponseType> lstcom= new List<CS_WrapperSmartSupervision.GetComplainResponseType>();
            com.tipo_entidad=1;
            com.tipo_id_CF=1;
            com.departamento_cod='05';
            com.entidad_cod=0004;
            com.numero_id_CF='99999';
            com.municipio_cod='05002';
            com.codigo_pais='170';
            com.queja_expres=1;
            com.replica=1;
            com.argumento_replica='argumento';
            com.producto_nombre='prod';
            com.fecha_creacion='2022-02-27T19:44:52';
            com.producto_cod=101;
            com.anexo_queja=false;
            com.sexo=3;
            com.lgbtiq=2;
            com.condicion_especial=98;
            com.direccion='direccion';
            com.correo='test@prueba.com';
            com.nombres='nombre';
            com.telefono='458468';
            com.texto_queja='queja';
            lstcom.add(com);
            res.results=lstcom;
            response.setBody(JSON.serialize(res));
            response.setStatusCode(200);
            response.setStatus('Success');
            return response;   
        }   
    	}
}
private class mockUpdateCPError implements HttpCalloutMock {
  	public HTTPResponse respond(HTTPRequest req) {
        if(req.getEndpoint()=='callout:SmartSupervision/login/'){
			HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"refresh":"refresh1234", "access":"access456"}');
            response.setStatusCode(200);
            response.setStatus('Success');
            return response;               
        }else{
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            CS_WrapperSmartSupervision.GetComplainsResponseType res= new CS_WrapperSmartSupervision.GetComplainsResponseType();
            res.count=1;
            res.pages=1;
            res.current_page=1;
            res.next='next';
            res.previous='previous';
            CS_WrapperSmartSupervision.GetComplainResponseType com= new CS_WrapperSmartSupervision.GetComplainResponseType();
            List<CS_WrapperSmartSupervision.GetComplainResponseType> lstcom= new List<CS_WrapperSmartSupervision.GetComplainResponseType>();
            com.tipo_entidad=1;
            com.tipo_id_CF=1;
            com.departamento_cod='05';
            com.entidad_cod=0004;
            com.numero_id_CF='99999';
            com.municipio_cod='05';
            com.codigo_pais='170';
            com.queja_expres=8;
            com.replica=1;
            com.argumento_replica='argumento';
            com.producto_nombre='prod';
            com.fecha_creacion='2022-02-27T19:44:52';
            com.producto_cod=101;
            com.anexo_queja=false;
            com.sexo=3;
            com.lgbtiq=2;
            com.condicion_especial=98;
            com.direccion='';
            com.correo='';
            com.nombres='nombre';
            com.telefono='458468';
            com.texto_queja='queja';
            lstcom.add(com);
            res.results=lstcom;
            response.setBody(JSON.serialize(res));
            response.setStatusCode(200);
            response.setStatus('Success');
            return response;   
        }   
    	}
}
    private class mockPreCP implements HttpCalloutMock {
  	public HTTPResponse respond(HTTPRequest req) {
        if(req.getEndpoint()=='callout:SmartSupervision/login/'){
			HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"refresh":"refresh1234", "access":"access456"}');
            response.setStatusCode(200);
            response.setStatus('Success');
            return response;               
        }else{
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            CS_WrapperSmartSupervision.GetComplainsResponseType res= new CS_WrapperSmartSupervision.GetComplainsResponseType();
            res.count=1;
            res.pages=1;
            res.current_page=1;
            res.next='next';
            res.previous='previous';
            CS_WrapperSmartSupervision.GetComplainResponseType com= new CS_WrapperSmartSupervision.GetComplainResponseType();
            List<CS_WrapperSmartSupervision.GetComplainResponseType> lstcom= new List<CS_WrapperSmartSupervision.GetComplainResponseType>();
            com.tipo_entidad=1;
            com.tipo_id_CF=1;
            com.departamento_cod='05';
            com.entidad_cod=0004;
            com.numero_id_CF='99999';
            com.municipio_cod='05002';
            com.codigo_pais='170';
            com.queja_expres=1;
            com.replica=1;
            com.argumento_replica='argumento';
            com.producto_nombre='prod';
            com.fecha_creacion='2022-02-27T19:44:52';
            com.producto_cod=101;
            com.anexo_queja=false;
            com.sexo=10;
            com.lgbtiq=2;
            com.condicion_especial=98;
            com.direccion='direccion';
            com.correo='test@prueba.com';
            com.nombres='nombre';
            com.telefono='458468';
            com.texto_queja='queja';
            lstcom.add(com);
            res.results=lstcom;
            response.setBody(JSON.serialize(res));
            response.setStatusCode(200);
            response.setStatus('Success');
            return response;   
        }   
    	}
}
private class mockPreCPError implements HttpCalloutMock {
  	public HTTPResponse respond(HTTPRequest req) {
        if(req.getEndpoint()=='callout:SmartSupervision/login/'){
			HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"refresh":"refresh1234", "access":"access456"}');
            response.setStatusCode(200);
            response.setStatus('Success');
            return response;               
        }else{
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            CS_WrapperSmartSupervision.GetComplainsResponseType res= new CS_WrapperSmartSupervision.GetComplainsResponseType();
            res.count=1;
            res.pages=1;
            res.current_page=1;
            res.next='next';
            res.previous='previous';
            CS_WrapperSmartSupervision.GetComplainResponseType com= new CS_WrapperSmartSupervision.GetComplainResponseType();
            List<CS_WrapperSmartSupervision.GetComplainResponseType> lstcom= new List<CS_WrapperSmartSupervision.GetComplainResponseType>();
            com.tipo_entidad=1;
            com.tipo_id_CF=1;
            com.departamento_cod='05';
            com.entidad_cod=0004;
            com.numero_id_CF='99999';
            com.municipio_cod='052';
            com.codigo_pais='170';
            com.queja_expres=1;
            com.replica=8;
            com.argumento_replica='argumento';
            com.producto_nombre='prod';
            com.fecha_creacion='2022-02-27T19:44:52';
            com.producto_cod=101;
            com.anexo_queja=false;
            com.sexo=10;
            com.lgbtiq=2;
            com.condicion_especial=98;
            com.direccion='direccion';
            com.correo='test@prueba.com';
            com.nombres='nombre';
            com.telefono='458468';
            com.texto_queja='queja';
            lstcom.add(com);
            res.results=lstcom;
            response.setBody(JSON.serialize(res));
            response.setStatusCode(200);
            response.setStatus('Success');
            return response;   
        }   
    	}
}
private class mockPreJ implements HttpCalloutMock {
  	public HTTPResponse respond(HTTPRequest req) {
        if(req.getEndpoint()=='callout:SmartSupervision/login/'){
			HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"refresh":"refresh1234", "access":"access456"}');
            response.setStatusCode(200);
            response.setStatus('Success');
            return response;               
        }else{
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            CS_WrapperSmartSupervision.GetComplainsResponseType res= new CS_WrapperSmartSupervision.GetComplainsResponseType();
            res.count=1;
            res.pages=1;
            res.current_page=1;
            res.next='next';
            res.previous='previous';
            CS_WrapperSmartSupervision.GetComplainResponseType com= new CS_WrapperSmartSupervision.GetComplainResponseType();
            List<CS_WrapperSmartSupervision.GetComplainResponseType> lstcom= new List<CS_WrapperSmartSupervision.GetComplainResponseType>();
            com.tipo_entidad=1;
            com.tipo_id_CF=3;
            com.departamento_cod='05';
            com.entidad_cod=0004;
            com.numero_id_CF='99999';
            com.municipio_cod='05002';
            com.codigo_pais='170';
            com.queja_expres=1;
            com.replica=1;
            com.argumento_replica='argumento';
            com.producto_nombre='prod';
            com.fecha_creacion='2022-02-27T19:44:52';
            com.producto_cod=101;
            com.anexo_queja=false;
            com.sexo=10;
            com.lgbtiq=2;
            com.condicion_especial=98;
            com.direccion='direccion';
            com.correo='test@prueba.com';
            com.nombres='nombre';
            com.telefono='458468';
            com.texto_queja='queja';
            com.tipo_persona=2;
            lstcom.add(com);
            res.results=lstcom;
            response.setBody(JSON.serialize(res));
            response.setStatusCode(200);
            response.setStatus('Success');
            return response;   
        }   
    	}
}
private class mockPreJError implements HttpCalloutMock {
  	public HTTPResponse respond(HTTPRequest req) {
        if(req.getEndpoint()=='callout:SmartSupervision/login/'){
			HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"refresh":"refresh1234", "access":"access456"}');
            response.setStatusCode(200);
            response.setStatus('Success');
            return response;               
        }else{
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            CS_WrapperSmartSupervision.GetComplainsResponseType res= new CS_WrapperSmartSupervision.GetComplainsResponseType();
            res.count=1;
            res.pages=1;
            res.current_page=1;
            res.next='next';
            res.previous='previous';
            CS_WrapperSmartSupervision.GetComplainResponseType com= new CS_WrapperSmartSupervision.GetComplainResponseType();
            List<CS_WrapperSmartSupervision.GetComplainResponseType> lstcom= new List<CS_WrapperSmartSupervision.GetComplainResponseType>();
            com.tipo_entidad=1;
            com.tipo_id_CF=3;
            com.departamento_cod='05';
            com.entidad_cod=0004;
            com.numero_id_CF='99999';
            com.municipio_cod='052';
            com.codigo_pais='170';
            com.queja_expres=1;
            com.replica=8;
            com.argumento_replica='argumento';
            com.producto_nombre='prod';
            com.fecha_creacion='2022-02-27T19:44:52';
            com.producto_cod=101;
            com.anexo_queja=false;
            com.sexo=10;
            com.lgbtiq=2;
            com.condicion_especial=98;
            com.direccion='direccion';
            com.correo='test@prueba.com';
            com.nombres='nombre';
            com.telefono='458468';
            com.texto_queja='queja';
            com.tipo_persona=2;
            lstcom.add(com);
            res.results=lstcom;
            response.setBody(JSON.serialize(res));
            response.setStatusCode(200);
            response.setStatus('Success');
            return response;   
        }   
    	}
}    
private class mockNewCP implements HttpCalloutMock {
  	public HTTPResponse respond(HTTPRequest req) {
        if(req.getEndpoint()=='callout:SmartSupervision/login/'){
			HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"refresh":"refresh1234", "access":"access456"}');
            response.setStatusCode(200);
            response.setStatus('Success');
            return response;               
        }else{
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            CS_WrapperSmartSupervision.GetComplainsResponseType res= new CS_WrapperSmartSupervision.GetComplainsResponseType();
            res.count=1;
            res.pages=1;
            res.current_page=1;
            res.next='next';
            res.previous='previous';
            CS_WrapperSmartSupervision.GetComplainResponseType com= new CS_WrapperSmartSupervision.GetComplainResponseType();
            List<CS_WrapperSmartSupervision.GetComplainResponseType> lstcom= new List<CS_WrapperSmartSupervision.GetComplainResponseType>();
            com.tipo_entidad=1;
            com.tipo_id_CF=2;
            com.departamento_cod='05';
            com.entidad_cod=0004;
            com.numero_id_CF='999846';
            com.municipio_cod='05002';
            com.codigo_pais='170';
            com.queja_expres=1;
            com.replica=1;
            com.argumento_replica='argumento';
            com.producto_nombre='prod';
            com.fecha_creacion='2022-02-27T19:44:52';
            com.producto_cod=101;
            com.anexo_queja=false;
            com.sexo=10;
            com.lgbtiq=2;
            com.condicion_especial=98;
            com.direccion='direccion';
            com.correo='test@prueba.com';
            com.nombres='nombre';
            com.telefono='458468';
            com.texto_queja='queja';
            lstcom.add(com);
            res.results=lstcom;
            response.setBody(JSON.serialize(res));
            response.setStatusCode(200);
            response.setStatus('Success');
            return response;   
        }   
    	}
}
    private class mockNewCPError implements HttpCalloutMock {
  	public HTTPResponse respond(HTTPRequest req) {
        if(req.getEndpoint()=='callout:SmartSupervision/login/'){
			HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"refresh":"refresh1234", "access":"access456"}');
            response.setStatusCode(200);
            response.setStatus('Success');
            return response;               
        }else{
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            CS_WrapperSmartSupervision.GetComplainsResponseType res= new CS_WrapperSmartSupervision.GetComplainsResponseType();
            res.count=1;
            res.pages=1;
            res.current_page=1;
            res.next='next';
            res.previous='previous';
            CS_WrapperSmartSupervision.GetComplainResponseType com= new CS_WrapperSmartSupervision.GetComplainResponseType();
            List<CS_WrapperSmartSupervision.GetComplainResponseType> lstcom= new List<CS_WrapperSmartSupervision.GetComplainResponseType>();
            com.tipo_entidad=1;
            com.tipo_id_CF=2;
            com.departamento_cod='05';
            com.entidad_cod=0004;
            com.numero_id_CF='999846';
            com.municipio_cod='050';
            com.codigo_pais='170';
            com.queja_expres=1;
            com.replica=3;
            com.argumento_replica='argumento';
            com.producto_nombre='prod';
            com.fecha_creacion='2022-02-27T19:44:52';
            com.producto_cod=101;
            com.anexo_queja=false;
            com.sexo=10;
            com.lgbtiq=2;
            com.condicion_especial=98;
            com.direccion='direccion';
            com.correo='';
            com.nombres='nombre';
            com.telefono='458468';
            com.texto_queja='queja';
            lstcom.add(com);
            res.results=lstcom;
            response.setBody(JSON.serialize(res));
            response.setStatusCode(200);
            response.setStatus('Success');
            return response;   
        }   
    	}
}
private class mockNewJ implements HttpCalloutMock {
  	public HTTPResponse respond(HTTPRequest req) {
        if(req.getEndpoint()=='callout:SmartSupervision/login/'){
			HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"refresh":"refresh1234", "access":"access456"}');
            response.setStatusCode(200);
            response.setStatus('Success');
            return response;               
        }else{
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            CS_WrapperSmartSupervision.GetComplainsResponseType res= new CS_WrapperSmartSupervision.GetComplainsResponseType();
            res.count=1;
            res.pages=1;
            res.current_page=1;
            res.next='next';
            res.previous='previous';
            CS_WrapperSmartSupervision.GetComplainResponseType com= new CS_WrapperSmartSupervision.GetComplainResponseType();
            List<CS_WrapperSmartSupervision.GetComplainResponseType> lstcom= new List<CS_WrapperSmartSupervision.GetComplainResponseType>();
            com.tipo_entidad=1;
            com.tipo_id_CF=3;
            com.departamento_cod='05';
            com.entidad_cod=0004;
            com.numero_id_CF='999846';
            com.municipio_cod='05002';
            com.codigo_pais='170';
            com.queja_expres=1;
            com.replica=1;
            com.argumento_replica='argumento';
            com.producto_nombre='prod';
            com.fecha_creacion='2022-02-27T19:44:52';
            com.producto_cod=101;
            com.anexo_queja=false;
            com.sexo=10;
            com.lgbtiq=2;
            com.condicion_especial=98;
            com.direccion='direccion';
            com.correo='test@prueba.com';
            com.nombres='nombre';
            com.telefono='458468';
            com.texto_queja='queja';
            com.tipo_persona=2;
            lstcom.add(com);
            res.results=lstcom;
            response.setBody(JSON.serialize(res));
            response.setStatusCode(200);
            response.setStatus('Success');
            return response;   
        }   
    	}
}   
     
private class mockNewJError implements HttpCalloutMock {
  	public HTTPResponse respond(HTTPRequest req) {
        if(req.getEndpoint()=='callout:SmartSupervision/login/'){
			HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"refresh":"refresh1234", "access":"access456"}');
            response.setStatusCode(200);
            response.setStatus('Success');
            return response;               
        }else{
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            CS_WrapperSmartSupervision.GetComplainsResponseType res= new CS_WrapperSmartSupervision.GetComplainsResponseType();
            res.count=1;
            res.pages=1;
            res.current_page=1;
            res.next='next';
            res.previous='previous';
            CS_WrapperSmartSupervision.GetComplainResponseType com= new CS_WrapperSmartSupervision.GetComplainResponseType();
            List<CS_WrapperSmartSupervision.GetComplainResponseType> lstcom= new List<CS_WrapperSmartSupervision.GetComplainResponseType>();
            com.tipo_entidad=1;
            com.tipo_id_CF=1;
            com.departamento_cod='05';
            com.entidad_cod=0004;
            com.numero_id_CF='999846';
            com.municipio_cod='05';
            com.codigo_pais='170';
            com.queja_expres=1;
            com.replica=1;
            com.argumento_replica='argumento';
            com.producto_nombre='prod';
            com.fecha_creacion='2022-02-27T19:44:52';
            com.producto_cod=101;
            com.anexo_queja=false;
            com.sexo=10;
            com.lgbtiq=2;
            com.condicion_especial=98;
            com.direccion='direccion';
            com.correo='test@prueba.com';
            com.nombres='nombre';
            com.telefono='458468';
            com.texto_queja='queja';
            com.tipo_persona=2;
            lstcom.add(com);
            res.results=lstcom;
            response.setBody(JSON.serialize(res));
            response.setStatusCode(200);
            response.setStatus('Success');
            return response;   
        }   
    	}
}  
    
    @isTest
	static void CaseCreated(){
		Case caso= CS_TestDataFactory.createCase(true);
        CS_WrapperSmartSupervision.GetComplainResponseType com= new CS_WrapperSmartSupervision.GetComplainResponseType();
            List<CS_WrapperSmartSupervision.GetComplainResponseType> lstcom= new List<CS_WrapperSmartSupervision.GetComplainResponseType>();
            com.tipo_entidad=1;
            com.tipo_id_CF=1;
            com.departamento_cod='05';
            com.entidad_cod=0004;
            com.numero_id_CF='999846';
            com.municipio_cod='05';
            com.codigo_pais='170';
            com.queja_expres=1;
            com.replica=1;
            com.argumento_replica='argumento';
            com.producto_nombre='prod';
            com.fecha_creacion='2022-02-27T19:44:52';
            com.producto_cod=101;
            com.anexo_queja=false;
            com.sexo=10;
            com.lgbtiq=2;
            com.condicion_especial=98;
            com.direccion='direccion';
            com.correo='test@prueba.com';
            com.nombres='nombre';
            com.telefono='458468';
            com.texto_queja='queja';
            com.tipo_persona=2;
        
        test.startTest();		        
        CS_SmartSupervision_Future.createBaseCaseExist(com,'1');
        test.stopTest();
    }
}