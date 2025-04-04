/***************************************************************************************************************************
 * Nombre de la Clase Apex : CS_SmartSupervisionFuture_Test
 * Versión                 : 1.0
 * Fecha de Creación       : 07/09/2022
 * Funcionalidad           : Generación de datos para pruebas
 *--------------------------------------------------------------------------------------------------------------------------
 *                                              HISTORIAL DE MODIFICACIONES:
 *--------------------------------------------------------------------------------------------------------------------------
 * Desarrollador         Fecha           Descripción
 *--------------------------------------------------------------------------------------------------------------------------
 * Fernanda Villafaña         07/09/2022      Modificacion
 * Frank Tovar                08/02/2024      Se añadieron test para forzar excepcion (Aumento de cobertura)
 *--------------------------------------------------------------------------------------------------------------------------
 **************************************************************************************************************************/

@isTest
class CS_SmartSupervisionWS_Test {

    @isTest
    static void loginExito(){
        Test.setMock(HttpCalloutMock.class, new mockExito());
        CS_WrapperSmartSupervision.LoginRequestType request= new CS_WrapperSmartSupervision.LoginRequestType();
        request.shortDescription='Description';
        request.caseEntity='1';
        request.caseId='50052000009HYWqAAO';
        CS_WrapperSmartSupervision.LoginResponseType response= CS_SmartSupervision_WS.login(request);
        system.debug('response loginExito: '+ response);
        system.assertEquals('refresh1234', response.refresh, 'No se recibió la respuesta esperada');
        system.assertEquals('access456', response.access, 'No se recibió la respuesta esperada');
    }

    @isTest
    static void loginException(){
        Test.setMock(HttpCalloutMock.class, new mockExito());
        CS_WrapperSmartSupervision.LoginRequestType request = new CS_WrapperSmartSupervision.LoginRequestType();
        request.shortDescription='excepcion_forze';
        request.caseEntity='1';
        Test.startTest();
        Case caso= CS_TestDataFactory.createCase(true);
        request.caseId = caso.Id;
        CS_WrapperSmartSupervision.LoginResponseType response= CS_SmartSupervision_WS.login(request);
        Test.stopTest();
        system.debug('response loginException: '+ response);
        system.assertEquals(null, response, 'No se recibió la respuesta esperada');
    }

    @isTest
    static void dummy(){
        CS_SmartSupervision_WS.dummySmartSupervisionMethod();
    }
    
    /*
    @isTest
    static void loginFallido(){   
        Test.setMock(HttpCalloutMock.class, new mockFallido());
        CS_WrapperSmartSupervision.LoginRequestType request= new CS_WrapperSmartSupervision.LoginRequestType();
        request.shortDescription='Description';
        request.caseEntity='1';
        request.caseId='50052000009HYWqAAO';
        test.startTest();
        CS_WrapperSmartSupervision.LoginResponseType response= CS_SmartSupervision_WS.login(request);
        test.stopTest();
        system.debug('response loginFallido: '+ response);
        //List<CS_Log__c> logs=[SELECT Id FROM CS_Log__c];
        //system.assertEquals(1, logs.size(), 'Error crear log');
        system.assertEquals(null, response);
    }
    */

    @isTest
    static void getComplainExito(){
        Test.setMock(HttpCalloutMock.class, new mockExitoComplain());
        CS_SmartSupervisionConstants__c cons= new CS_SmartSupervisionConstants__c();
        cons.CS_GetComplainsEndpoint__c='http://endpoint.com';
        cons.CS_GetFileEndpoint__c='http://endpoint.com';
        cons.CS_SmartSupervisionUsername__c='username';
        insert cons;
        CS_WrapperSmartSupervision.GetComplainsRequestType request= new CS_WrapperSmartSupervision.GetComplainsRequestType();
        request.token='Token123';
        request.caseEntity='1';
        test.startTest();
        CS_WrapperSmartSupervision.GetComplainsResponseType response= CS_SmartSupervision_WS.getComplains(request);
        test.stopTest();
        system.debug('response getComplainExito: '+ response);
        system.assertEquals(1, response.count, 'No se recibió la respuesta esperada');
        system.assertEquals('previous', response.previous, 'No se recibió la respuesta esperada');
    }

    @isTest
    static void getComplainFallido(){
        Test.setMock(HttpCalloutMock.class, new mockFallido());
        CS_SmartSupervisionConstants__c cons= new CS_SmartSupervisionConstants__c();
        cons.CS_GetComplainsEndpoint__c='http://endpoint.com';
        cons.CS_GetFileEndpoint__c='http://endpoint.com';
        cons.CS_SmartSupervisionUsername__c='username';
        insert cons;
        CS_WrapperSmartSupervision.GetComplainsRequestType request= new CS_WrapperSmartSupervision.GetComplainsRequestType();
        request.token='Token123';
        request.caseEntity='1';
        test.startTest();
        CS_WrapperSmartSupervision.GetComplainsResponseType response= CS_SmartSupervision_WS.getComplains(request);
        test.stopTest();
        system.debug('response getComplainFallido: '+ response);
        List<CS_Log__c> logs=[SELECT Id FROM CS_Log__c];
        system.assertEquals(1, logs.size(), 'Error crear log');
        system.assertEquals(null, response);
    }
    
    @isTest
    static void getComplainException(){
        Test.setMock(HttpCalloutMock.class, new mockExitoComplain());
        CS_SmartSupervisionConstants__c cons= new CS_SmartSupervisionConstants__c();
        cons.CS_GetComplainsEndpoint__c='http://endpoint.com';
        cons.CS_GetFileEndpoint__c='http://endpoint.com';
        cons.CS_SmartSupervisionUsername__c='username';
        insert cons;
        CS_WrapperSmartSupervision.GetComplainsRequestType request= new CS_WrapperSmartSupervision.GetComplainsRequestType();
        request.token='excepcion_forze';
        request.caseEntity='1';
        test.startTest();
        CS_WrapperSmartSupervision.GetComplainsResponseType response= CS_SmartSupervision_WS.getComplains(request);
        test.stopTest();
        system.debug('response getComplainException: '+ response);
        system.assertEquals(null, response, 'No se recibió la respuesta esperada');
    }
    
    /*
	 @isTest
    static void getComplainFilesExito(){
        Test.setMock(HttpCalloutMock.class, new mockExitoComplainFiles());
        CS_SmartSupervisionConstants__c cons= new CS_SmartSupervisionConstants__c();
        cons.CS_GetComplainsEndpoint__c='http://endpoint.com';
        cons.CS_GetFileEndpoint__c='http://endpoint.com';
        cons.CS_SmartSupervisionUsername__c='username';
        insert cons;
        CS_WrapperSmartSupervision.GetComplainFilesRequestType request= new CS_WrapperSmartSupervision.GetComplainFilesRequestType();
        request.token='Token123';
        request.caseEntity='1';
        request.caseCode='codigo123';
        request.caseId='50052000009HYWqAAO';
        test.startTest();
        CS_WrapperSmartSupervision.GetComplainFilesResponseType response= CS_SmartSupervision_WS.getComplainFiles(request);
        test.stopTest();
        system.debug('response getComplainFilesExito: '+ response);
        system.assertEquals(1, response.count, 'No se recibió la respuesta esperada');
        system.assertEquals('previous', response.previous, 'No se recibió la respuesta esperada'); 
    }*/
    
    @isTest
    static void getComplainFilesFallido(){
        Case caso= CS_TestDataFactory.createCase(true);
        
        Test.setMock(HttpCalloutMock.class, new mockFallido());
        CS_SmartSupervisionConstants__c cons= new CS_SmartSupervisionConstants__c();
        cons.CS_GetComplainsEndpoint__c='http://endpoint.com';
        cons.CS_GetFileEndpoint__c='http://endpoint.com';
        cons.CS_SmartSupervisionUsername__c='username';
        insert cons;
        CS_WrapperSmartSupervision.GetComplainFilesRequestType request= new CS_WrapperSmartSupervision.GetComplainFilesRequestType();
        request.token='Token123';
        request.caseEntity='1';
        request.caseCode='codigo123';
        request.caseId=caso.Id;
        test.startTest();
        CS_WrapperSmartSupervision.GetComplainFilesResponseType response= CS_SmartSupervision_WS.getComplainFiles(request);
        test.stopTest();
        List<CS_Log__c> logs=[SELECT Id, CS_Case__c FROM CS_Log__c];
        system.assertEquals(caso.Id, logs[0].CS_Case__c, 'Error crear log');
        system.assertEquals(null, response);
        
    }
    
    @isTest
    static void getComplainFilesException(){
        Case caso= CS_TestDataFactory.createCase(true);
        
        Test.setMock(HttpCalloutMock.class, new mockFallido());
        CS_SmartSupervisionConstants__c cons= new CS_SmartSupervisionConstants__c();
        cons.CS_GetComplainsEndpoint__c='http://endpoint.com';
        cons.CS_GetFileEndpoint__c='http://endpoint.com';
        cons.CS_SmartSupervisionUsername__c='username';
        insert cons;
        CS_WrapperSmartSupervision.GetComplainFilesRequestType request= new CS_WrapperSmartSupervision.GetComplainFilesRequestType();
        request.token='excepcion_forze';
        request.caseEntity='1';
        request.caseCode='codigo123';
        request.caseId=caso.Id;
        test.startTest();
        CS_WrapperSmartSupervision.GetComplainFilesResponseType response= CS_SmartSupervision_WS.getComplainFiles(request);
        test.stopTest();
        List<CS_Log__c> logs=[SELECT Id, CS_Case__c FROM CS_Log__c];
        system.assertEquals(caso.Id, logs[0].CS_Case__c, 'Error crear log');
        system.assertEquals(null, response);
        
    }

    @isTest
    static void getFileExito(){
        Test.setMock(HttpCalloutMock.class, new mockExitoFiles());
        CS_WrapperSmartSupervision.GetFileRequestType  request= new CS_WrapperSmartSupervision.GetFileRequestType ();
        Case caso= CS_TestDataFactory.createCase(true);
        request.link='www.link.com';
        request.caseId=caso.Id;
        test.startTest();
        CS_WrapperSmartSupervision.GetFileResponseType response= CS_SmartSupervision_WS.getFile(request);
        test.stopTest();
        system.debug('response getFileExito: '+ response);
        system.assertEquals('Blob[23]',String.valueOf(response.blobFile), 'No se recibió la respuesta esperada');    
    }
    
    @isTest
    static void getFileFallido(){
        Test.setMock(HttpCalloutMock.class, new mockFallido());
        Case caso= CS_TestDataFactory.createCase(true);
        
        CS_WrapperSmartSupervision.GetFileRequestType  request= new CS_WrapperSmartSupervision.GetFileRequestType ();
        request.link='www.link.com';
        request.caseId=caso.Id;
        test.startTest();
        CS_WrapperSmartSupervision.GetFileResponseType response= CS_SmartSupervision_WS.getFile(request);
        test.stopTest();
        List<CS_Log__c> logs=[SELECT Id, CS_Case__c FROM CS_Log__c];
        system.assertEquals(caso.Id, logs[0].CS_Case__c, 'Error crear log');
        system.assertEquals(null, response);
    } 

    @isTest
    static void getFileException(){
        Test.setMock(HttpCalloutMock.class, new mockFallido());
        Case caso= CS_TestDataFactory.createCase(true);
        CS_WrapperSmartSupervision.GetFileRequestType  request= new CS_WrapperSmartSupervision.GetFileRequestType ();
        request.link='excepcion_forze';
        request.caseId=caso.Id;
        test.startTest();
        CS_WrapperSmartSupervision.GetFileResponseType response= CS_SmartSupervision_WS.getFile(request);
        test.stopTest();
        system.assertEquals(null, response);
    }

    @isTest
    static void ackExito(){
        Test.setMock(HttpCalloutMock.class, new mockExitoAck());
        CS_SmartSupervisionConstants__c cons= new CS_SmartSupervisionConstants__c();
        cons.CS_GetComplainsEndpoint__c='http://endpoint.com';
        cons.CS_GetFileEndpoint__c='http://endpoint.com';
        cons.CS_SmartSupervisionUsername__c='username';
        insert cons;
        CS_WrapperSmartSupervision.ACKRequestType  request= new CS_WrapperSmartSupervision.ACKRequestType();
        request.token='token';
        request.caseEntity='1';
        List<Id> lstIds= new List<Id>();
        lstIds.add('50052000009HYWqAAO');
        List<String> lstCods= new List<String>();
        lstCods.add('0000');
        //request.caseIds=lstIds;
        request.caseCodes=lstCods;
        test.startTest();
        CS_WrapperSmartSupervision.ACKResponseType response= CS_SmartSupervision_WS.ack(request);
        test.stopTest();
        system.debug('response getAckExito: '+ response);
        //system.assertEquals('Mensaje',response.message, 'No se recibió la respuesta esperada');  
    }

    @isTest
    static void ackFallido(){
        Test.setMock(HttpCalloutMock.class, new mockAckFallido());
        CS_SmartSupervisionConstants__c cons= new CS_SmartSupervisionConstants__c();
        cons.CS_GetComplainsEndpoint__c='http://endpoint.com';
        cons.CS_GetFileEndpoint__c='http://endpoint.com';
        cons.CS_SmartSupervisionUsername__c='username';
        insert cons;
        Case caso= CS_TestDataFactory.createCase(true);
        CS_WrapperSmartSupervision.ACKRequestType  request= new CS_WrapperSmartSupervision.ACKRequestType();
        request.token='token';
        request.caseEntity='1';
        List<Id> lstIds= new List<Id>();
        lstIds.add(caso.Id);
        List<String> lstCods= new List<String>();
        lstCods.add('0000');
        request.caseIds=lstIds;
        request.caseCodes=lstCods;
        test.startTest();
        CS_WrapperSmartSupervision.ACKResponseType response= CS_SmartSupervision_WS.ack(request);
        test.stopTest();
        List<CS_Log__c> logs=[SELECT Id, CS_Case__c FROM CS_Log__c];
        system.assertEquals(1, logs.size(), 'Error crear log');
        system.assertEquals(null, response); 
    }
    
    @isTest
    static void ackException(){
        Test.setMock(HttpCalloutMock.class, new mockExitoAck());
        CS_SmartSupervisionConstants__c cons= new CS_SmartSupervisionConstants__c();
        cons.CS_GetComplainsEndpoint__c='http://endpoint.com';
        cons.CS_GetFileEndpoint__c='http://endpoint.com';
        cons.CS_SmartSupervisionUsername__c='username';
        insert cons;
        CS_WrapperSmartSupervision.ACKRequestType  request= new CS_WrapperSmartSupervision.ACKRequestType();
        request.token='excepcion_forze';
        request.caseEntity='1';
        List<Id> lstIds= new List<Id>();
        lstIds.add('50052000009HYWqAAO');
        List<String> lstCods= new List<String>();
        lstCods.add('0000');
        //request.caseIds=lstIds;
        request.caseCodes=lstCods;
        test.startTest();
        CS_WrapperSmartSupervision.ACKResponseType response= CS_SmartSupervision_WS.ack(request);
        test.stopTest();
        system.debug('response getAckExito: '+ response);
        //system.assertEquals('Mensaje',response.message, 'No se recibió la respuesta esperada');  
    }
    
    /*
    @isTest
    static void createComplainExito(){
        Test.setMock(HttpCalloutMock.class, new mockExitoCreateComplain());
        CS_SmartSupervisionConstants__c cons= new CS_SmartSupervisionConstants__c();
        cons.CS_GetComplainsEndpoint__c='http://endpoint.com';
        cons.CS_GetFileEndpoint__c='http://endpoint.com';
        cons.CS_SmartSupervisionUsername__c='username';
        insert cons;
        CS_WrapperSmartSupervision.CreateComplainRequestType  request= new CS_WrapperSmartSupervision.CreateComplainRequestType();
        request.token='token';
        request.caseEntity='1';
        request.caseId='50052000009HYWqAAO';
        CS_WrapperSmartSupervision.ComplainRequestType compl= new CS_WrapperSmartSupervision.ComplainRequestType();
        compl.nombres='nombres';
        compl.tipo_id_CF=1;
        compl.numero_id_CF='1';
        compl.tipo_persona=1;
        compl.codigo_queja='codigo queja';
        compl.codigo_pais='1';
        compl.canal_cod=1;
        compl.producto_cod=1;
        compl.macro_motivo_cod=1;
        compl.insta_recepcion=1;
        compl.punto_recepcion=1;
        compl.admision=1;
        compl.texto_queja='quejas';
        request.complain=compl;
        test.startTest();
        CS_WrapperSmartSupervision.CreateComplainResponseType response= CS_SmartSupervision_WS.createComplain(request);
        test.stopTest();
        system.debug('response createComplainExito: '+ response);
        system.assertEquals(1,response.tipo_entidad, 'No se recibió la respuesta esperada');
        system.assertEquals(10,response.entidad_cod, 'No se recibió la respuesta esperada');
    }*/

    @isTest
    static void createComplainFallido(){
        Test.setMock(HttpCalloutMock.class, new mockFallido());
        CS_SmartSupervisionConstants__c cons= new CS_SmartSupervisionConstants__c();
        cons.CS_GetComplainsEndpoint__c='http://endpoint.com';
        cons.CS_GetFileEndpoint__c='http://endpoint.com';
        cons.CS_SmartSupervisionUsername__c='username';
        insert cons;
        Case caso= CS_TestDataFactory.createCase(true);
        
        CS_WrapperSmartSupervision.CreateComplainRequestType  request= new CS_WrapperSmartSupervision.CreateComplainRequestType();
        request.token='token';
        request.caseEntity='1';
        request.caseId=caso.Id;
        CS_WrapperSmartSupervision.ComplainRequestType compl= new CS_WrapperSmartSupervision.ComplainRequestType();
        compl.nombres='nombres';
        compl.tipo_id_CF=1;
        compl.numero_id_CF='1';
        compl.tipo_persona=1;
        compl.codigo_queja='codigo queja';
        compl.codigo_pais='1';
        compl.canal_cod=1;
        compl.producto_cod=1;
        compl.macro_motivo_cod=1;
        compl.insta_recepcion=1;
        compl.punto_recepcion=1;
        compl.admision=1;
        compl.texto_queja='quejas';
        request.complain=compl;
        test.startTest();
        CS_WrapperSmartSupervision.CreateComplainResponseType response= CS_SmartSupervision_WS.createComplain(request);
        test.stopTest();
        List<CS_Log__c> logs=[SELECT Id, CS_Case__c FROM CS_Log__c];
        system.assertEquals(caso.Id, logs[0].CS_Case__c, 'Error crear log');
        system.assertEquals(null, response);
    }
    
    @isTest
    static void createComplainException(){
        Test.setMock(HttpCalloutMock.class, new mockFallido());
        CS_SmartSupervisionConstants__c cons= new CS_SmartSupervisionConstants__c();
        cons.CS_GetComplainsEndpoint__c='http://endpoint.com';
        cons.CS_GetFileEndpoint__c='http://endpoint.com';
        cons.CS_SmartSupervisionUsername__c='username';
        insert cons;
        Case caso= CS_TestDataFactory.createCase(true);
        
        CS_WrapperSmartSupervision.CreateComplainRequestType  request= new CS_WrapperSmartSupervision.CreateComplainRequestType();
        request.token='excepcion_forze';
        request.caseEntity='1';
        request.caseId=caso.Id;
        CS_WrapperSmartSupervision.ComplainRequestType compl= new CS_WrapperSmartSupervision.ComplainRequestType();
        compl.nombres='nombres';
        compl.tipo_id_CF=1;
        compl.numero_id_CF='1';
        compl.tipo_persona=1;
        compl.codigo_queja='codigo queja';
        compl.codigo_pais='1';
        compl.canal_cod=1;
        compl.producto_cod=1;
        compl.macro_motivo_cod=1;
        compl.insta_recepcion=1;
        compl.punto_recepcion=1;
        compl.admision=1;
        compl.texto_queja='quejas';
        request.complain=compl;
        test.startTest();
        CS_WrapperSmartSupervision.CreateComplainResponseType response= CS_SmartSupervision_WS.createComplain(request);
        test.stopTest();
        system.assertEquals(null, response);
    }

    /*
   @isTest
    static void updateComplainExito(){
        Test.setMock(HttpCalloutMock.class, new mockExitoUpdateComplain());
        CS_SmartSupervisionConstants__c cons= new CS_SmartSupervisionConstants__c();
        cons.CS_GetComplainsEndpoint__c='http://endpoint.com';
        cons.CS_GetFileEndpoint__c='http://endpoint.com';
        cons.CS_SmartSupervisionUsername__c='username';
        insert cons;
        CS_WrapperSmartSupervision.UpdateComplainRequestType  request= new CS_WrapperSmartSupervision.UpdateComplainRequestType();
        request.token='token';
        request.caseEntity='1';
        request.caseId='50052000009HYWqAAO';
        CS_WrapperSmartSupervision.ComplainChangesRequestType compl= new CS_WrapperSmartSupervision.ComplainChangesRequestType();
        compl.producto_cod=1;
        compl.macro_motivo_cod=1;
        compl.estado_cod=1;
        compl.producto_digital=1;
        compl.admision=1;
        compl.aceptacion_queja=1;
        compl.rectificacion_queja=1;
        compl.anexo_queja=false;
        compl.documentacion_rta_final=false;
        request.complainChanges=compl;
        test.startTest();
        CS_WrapperSmartSupervision.UpdateComplainResponseType response= CS_SmartSupervision_WS.updateComplain(request);
        test.stopTest();
        system.debug('response updateComplainExito: '+ response);
        system.assertEquals('codigo123',response.codigo_queja, 'No se recibió la respuesta esperada');
        system.assertEquals(2,response.producto_cod, 'No se recibió la respuesta esperada');
        
    }*/
    
    @isTest
    static void updateComplainFallido(){
        Test.setMock(HttpCalloutMock.class, new mockFallido());
        Case caso= CS_TestDataFactory.createCase(true);
        
        CS_SmartSupervisionConstants__c cons= new CS_SmartSupervisionConstants__c();
        cons.CS_GetComplainsEndpoint__c='http://endpoint.com';
        cons.CS_GetFileEndpoint__c='http://endpoint.com';
        cons.CS_SmartSupervisionUsername__c='username';
        insert cons;
        CS_WrapperSmartSupervision.UpdateComplainRequestType  request= new CS_WrapperSmartSupervision.UpdateComplainRequestType();
        request.token='token';
        request.caseEntity='1';
        request.caseId=caso.Id;
        CS_WrapperSmartSupervision.ComplainChangesRequestType compl= new CS_WrapperSmartSupervision.ComplainChangesRequestType();
        compl.producto_cod=1;
        compl.macro_motivo_cod=1;
        compl.estado_cod=1;
        compl.producto_digital=1;
        compl.admision=1;
        compl.aceptacion_queja=1;
        compl.rectificacion_queja=1;
        compl.anexo_queja=false;
        compl.documentacion_rta_final=false;
        request.complainChanges=compl;
        test.startTest();
        CS_WrapperSmartSupervision.UpdateComplainResponseType response= CS_SmartSupervision_WS.updateComplain(request);
        test.stopTest();
        List<CS_Log__c> logs=[SELECT Id, CS_Case__c FROM CS_Log__c];
        system.assertEquals(caso.Id, logs[0].CS_Case__c, 'Error crear log');
        system.assertEquals(null, response);
        
    } 
    
    @isTest
    static void updateComplainException(){
        Test.setMock(HttpCalloutMock.class, new mockFallido());
        Case caso= CS_TestDataFactory.createCase(true);
        
        CS_SmartSupervisionConstants__c cons= new CS_SmartSupervisionConstants__c();
        cons.CS_GetComplainsEndpoint__c='http://endpoint.com';
        cons.CS_GetFileEndpoint__c='http://endpoint.com';
        cons.CS_SmartSupervisionUsername__c='username';
        insert cons;
        CS_WrapperSmartSupervision.UpdateComplainRequestType  request= new CS_WrapperSmartSupervision.UpdateComplainRequestType();
        request.token='excepcion_forze';
        request.caseEntity='1';
        request.caseId=caso.Id;
        CS_WrapperSmartSupervision.ComplainChangesRequestType compl= new CS_WrapperSmartSupervision.ComplainChangesRequestType();
        compl.producto_cod=1;
        compl.macro_motivo_cod=1;
        compl.estado_cod=1;
        compl.producto_digital=1;
        compl.admision=1;
        compl.aceptacion_queja=1;
        compl.rectificacion_queja=1;
        compl.anexo_queja=false;
        compl.documentacion_rta_final=false;
        request.complainChanges=compl;
        test.startTest();
        CS_WrapperSmartSupervision.UpdateComplainResponseType response= CS_SmartSupervision_WS.updateComplain(request);
        test.stopTest();
        system.assertEquals(null, response);        
    }

    /*
    @isTest
    static void addFileExito(){
		Test.setMock(HttpCalloutMock.class, new mockExitoAddFile());
        CS_SmartSupervisionConstants__c cons= new CS_SmartSupervisionConstants__c();
        cons.CS_GetComplainsEndpoint__c='http://endpoint.com';
        cons.CS_GetFileEndpoint__c='http://endpoint.com';
        cons.CS_SmartSupervisionUsername__c='username';
        insert cons;
        CS_WrapperSmartSupervision.AddFileRequestType  request= new CS_WrapperSmartSupervision.AddFileRequestType();
        request.token='token';
        request.caseEntity='1';
        request.caseId='50052000009HYWqAAO';
        request.caseCode='000';
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Test',
            PathOnClient = 'Test.pdf',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion;
        ContentVersion content= [Select ID, FileExtension, VersionData, title FROM ContentVersion LIMIT 1];
        request.file=content;
        test.startTest();
        CS_WrapperSmartSupervision.AddFileResponseType response= CS_SmartSupervision_WS.addFile(request);
        test.stopTest();
        system.debug('response updateComplainExito: '+ response);
        system.assertEquals(1212,response.id, 'No se recibió la respuesta esperada');
        system.assertEquals('tipo',response.type, 'No se recibió la respuesta esperada');
               
    }*/

    @isTest
    static void addFileFallido(){
        Test.setMock(HttpCalloutMock.class, new mockFallido());
        Case caso= CS_TestDataFactory.createCase(true);
        CS_SmartSupervisionConstants__c cons= new CS_SmartSupervisionConstants__c();
        cons.CS_GetComplainsEndpoint__c='http://endpoint.com';
        cons.CS_GetFileEndpoint__c='http://endpoint.com';
        cons.CS_SmartSupervisionUsername__c='username';
        insert cons;
        CS_WrapperSmartSupervision.AddFileRequestType  request= new CS_WrapperSmartSupervision.AddFileRequestType();
        request.token='token';
        request.caseEntity='1';
        request.caseId=caso.Id;
        request.caseCode='000';
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Test',
            PathOnClient = 'Test.pdf',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion;
        ContentVersion content= [Select ID, FileExtension, VersionData, title FROM ContentVersion LIMIT 1];
        request.file=content;
        test.startTest();
        CS_WrapperSmartSupervision.AddFileResponseType response= CS_SmartSupervision_WS.addFile(request);
        test.stopTest();
        List<CS_Log__c> logs=[SELECT Id, CS_Case__c FROM CS_Log__c];
        system.assertEquals(caso.Id, logs[0].CS_Case__c, 'Error crear log');
        system.assertEquals(null, response);
        
    }

    @isTest
    static void addFileException(){
        Test.setMock(HttpCalloutMock.class, new mockFallido());
        Case caso= CS_TestDataFactory.createCase(true);
        CS_SmartSupervisionConstants__c cons= new CS_SmartSupervisionConstants__c();
        cons.CS_GetComplainsEndpoint__c='http://endpoint.com';
        cons.CS_GetFileEndpoint__c='http://endpoint.com';
        cons.CS_SmartSupervisionUsername__c='username';
        insert cons;
        CS_WrapperSmartSupervision.AddFileRequestType  request= new CS_WrapperSmartSupervision.AddFileRequestType();
        request.token='excepcion_forze';
        request.caseEntity='1';
        request.caseId=caso.Id;
        request.caseCode='000';
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Test',
            PathOnClient = 'Test.pdf',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion;
        ContentVersion content= [Select ID, FileExtension, VersionData, title FROM ContentVersion LIMIT 1];
        request.file=content;
        test.startTest();
        CS_WrapperSmartSupervision.AddFileResponseType response= CS_SmartSupervision_WS.addFile(request);
        test.stopTest();
        system.assertEquals(null, response);
        
    }


private class mockExito implements HttpCalloutMock {
  	public HTTPResponse respond(HTTPRequest req) {
      	HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"refresh":"refresh1234", "access":"access456"}');
        response.setStatusCode(200);
        response.setStatus('Success');
        return response;      
    	}
}
private class mockExitoComplain implements HttpCalloutMock {
  	public HTTPResponse respond(HTTPRequest req) {
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
        com.entidad_cod=000;
        lstcom.add(com);
        res.results=lstcom;
        response.setBody(JSON.serialize(res));
        response.setStatusCode(200);
        response.setStatus('Success');
        return response;      
    	}
}
private class mockExitoComplainFiles implements HttpCalloutMock {
  	public HTTPResponse respond(HTTPRequest req) {
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
private class mockExitoFiles implements HttpCalloutMock {
  	public HTTPResponse respond(HTTPRequest req) {
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
private class mockExitoAck implements HttpCalloutMock {
  	public HTTPResponse respond(HTTPRequest req) {
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
private class mockExitoCreateComplain implements HttpCalloutMock {
  	public HTTPResponse respond(HTTPRequest req) {
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
private class mockExitoUpdateComplain implements HttpCalloutMock {
  	public HTTPResponse respond(HTTPRequest req) {
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

private class mockExitoAddFile implements HttpCalloutMock {
  	public HTTPResponse respond(HTTPRequest req) {
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
private class mockFallido implements HttpCalloutMock {
  	public HTTPResponse respond(HTTPRequest req) {
      	HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"status_code":"400", "detail":"error", "message":"mensaje"}');
        response.setStatusCode(400);
        response.setStatus('Error');
        return response;      
    	}
}
private class mockAckFallido implements HttpCalloutMock {
  	public HTTPResponse respond(HTTPRequest req) {
      	HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        CS_WrapperSmartSupervision.ACKResponseType res= new CS_WrapperSmartSupervision.ACKResponseType();
       	res.message='Mensaje';
        List<String> lstErrs= new List<String>();
        lstErrs.add('error');
        res.pqrs_error=lstErrs;
        response.setBody(JSON.serialize(res));
        response.setStatusCode(200);
        response.setStatus('Success');
        return response;      
    	}
}

    //?-----------------------------------------------------------------------------------------------//
	//?                                             MOMENTO 4                                         //
	//?-----------------------------------------------------------------------------------------------//

    @isTest
    static void getUsersFallido(){
        Test.setMock(HttpCalloutMock.class, new mockFallido());
        Case caso= CS_TestDataFactory.createCase(true);
        
        CS_SmartSupervisionConstants__c cons= new CS_SmartSupervisionConstants__c();
        cons.CS_GetComplainsEndpoint__c='http://endpoint.com';
        cons.CS_GetFileEndpoint__c='http://endpoint.com';
        cons.CS_SmartSupervisionUsername__c='username';
        insert cons;

        CS_WrapperSmartSupervision.GetUsersRequestType request = new CS_WrapperSmartSupervision.GetUsersRequestType();
        request.token='token';
        request.caseEntity='1';
        
        test.startTest();
        CS_WrapperSmartSupervision.GetUsersResponseType response= CS_SmartSupervision_WS.getUsers(request);
        test.stopTest();

        List<CS_Log__c> logs=[SELECT Id, CS_Case__c FROM CS_Log__c];
        system.assertEquals(null, response);
    }

    @isTest
    static void getUsersException(){
        Test.setMock(HttpCalloutMock.class, new mockFallido());
        Case caso= CS_TestDataFactory.createCase(true);
        CS_SmartSupervisionConstants__c cons= new CS_SmartSupervisionConstants__c();
        cons.CS_GetComplainsEndpoint__c='http://endpoint.com';
        cons.CS_GetFileEndpoint__c='http://endpoint.com';
        cons.CS_SmartSupervisionUsername__c='username';
        insert cons;
        CS_WrapperSmartSupervision.GetUsersRequestType request = new CS_WrapperSmartSupervision.GetUsersRequestType();
        request.token='excepcion_forze';
        request.caseEntity='1';        
        test.startTest();
        CS_WrapperSmartSupervision.GetUsersResponseType response= CS_SmartSupervision_WS.getUsers(request);
        test.stopTest();
        system.assertEquals(null, response);
    }

    @isTest
    static void userACKFallido(){
        Test.setMock(HttpCalloutMock.class, new mockAckFallido());
        CS_SmartSupervisionConstants__c cons= new CS_SmartSupervisionConstants__c();
        cons.CS_GetComplainsEndpoint__c='http://endpoint.com';
        cons.CS_GetFileEndpoint__c='http://endpoint.com';
        cons.CS_SmartSupervisionUsername__c='username';
        insert cons;
        Case caso= CS_TestDataFactory.createCase(true);
        CS_WrapperSmartSupervision.ACKUserRequestType request= new CS_WrapperSmartSupervision.ACKUserRequestType();
        request.token='token';
        request.caseEntity='1';
        List<Id> lstIds= new List<Id>();
        lstIds.add(caso.Id);
        List<String> lstCods= new List<String>();
        lstCods.add('0000');
        request.numero_id_CF=lstCods;
        test.startTest();
        CS_WrapperSmartSupervision.ACKUserResponseType response= CS_SmartSupervision_WS.userACk(request);
        test.stopTest();
        List<CS_Log__c> logs=[SELECT Id, CS_Case__c FROM CS_Log__c];
        //system.assertEquals(1, logs.size(), 'Error crear log');
        system.assertEquals(null, response); 
    }

    @isTest
    static void userACKException(){
        Test.setMock(HttpCalloutMock.class, new mockAckFallido());
        CS_SmartSupervisionConstants__c cons= new CS_SmartSupervisionConstants__c();
        cons.CS_GetComplainsEndpoint__c='http://endpoint.com';
        cons.CS_GetFileEndpoint__c='http://endpoint.com';
        cons.CS_SmartSupervisionUsername__c='username';
        insert cons;
        Case caso= CS_TestDataFactory.createCase(true);
        CS_WrapperSmartSupervision.ACKUserRequestType request= new CS_WrapperSmartSupervision.ACKUserRequestType();
        request.token='excepcion_forze';
        request.caseEntity='1';
        List<Id> lstIds= new List<Id>();
        lstIds.add(caso.Id);
        List<String> lstCods= new List<String>();
        lstCods.add('0000');
        request.numero_id_CF=lstCods;
        test.startTest();
        CS_WrapperSmartSupervision.ACKUserResponseType response= CS_SmartSupervision_WS.userACk(request);
        test.stopTest();
        system.assertEquals(null, response); 
    }
 
}