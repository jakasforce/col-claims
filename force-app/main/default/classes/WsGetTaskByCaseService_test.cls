@isTest
public class WsGetTaskByCaseService_test {

    @testSetup
    public static void setupData() {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            //Caso
            case caso         = CS_TestDataFactory.createCase(true);
            caso.recordTypeId = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('CS_Novedad').getRecordTypeId();        
            caso.CS_Subtipo__c = '1';
            caso.CS_ProductoM2__c = '121';

            //contact
            contact contacto = new contact();
            contacto.FirstName = 'prueba';
            contacto.LastName  = 'contacto';
            contacto.Email     = 'justTest@yopomail.com';
            contacto.CS_TipoIdentificacionCP__c   = '1';
            contacto.CS_NumeroIdentificacionCP__c = '123456789';
            insert contacto;

            //producto2        
            Product2 productos2 = new Product2();
            productos2.name = 'TITULOS DE producto';
            productos2.CS_Canal__c = '107';
            productos2.CS_Entidad_Producto__c = '1';
            productos2.Family = '31';
            productos2.CS_Estrategia_M2__c = '12';
            productos2.CS_Producto_M2__c = '121';
            productos2.CS_Producto_Colmena_M2__c = 'Accidentes Personales';
            insert productos2;
            caso.ProductId    = productos2.id;
        
            // Insertar la cuenta
            Account cuenta = new Account();
            cuenta.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
            cuenta.CS_TipoIdentificacionCP__pc = '1';
            cuenta.CS_NumeroIdentificacionCP__pc = '123456789';
            cuenta.PersonEmail = 'justTest@yopomail.com';
            cuenta.FirstName = 'prueba';
            cuenta.LastName = 'contacto';
            cuenta.PersonMobilePhone = '1231231231';
        
            insert cuenta;
            //Id accountId = [SELECT AccountId FROM Case WHERE Id =: caso.Id].AccountId;
            caso.AccountId  = cuenta.id;
        
            //poliza
            InsurancePolicy poliza = new InsurancePolicy();
            poliza.Name = '1234';
            poliza.NameInsuredId = cuenta.id; // Establecer el ID de la cuenta asociada al caso
            poliza.RecordTypeId = Schema.SObjectType.InsurancePolicy.getRecordTypeInfosByDeveloperName().get('CS_Contrato_ARL').getRecordTypeId();
            poliza.ProductId = productos2.Id;
            poliza.NameInsuredId = cuenta.id;
            insert poliza;
        
            //claim
            claim at = new claim();
            at.Name  = '12345';
            at.PolicyNumberId = poliza.id;
            at.AccountId = cuenta.id;
            at.RecordTypeId = Schema.SObjectType.claim.getRecordTypeInfosByDeveloperName().get('CS_AT').getRecordTypeId();
            insert at;
            id atelId = [select id from claim where id =: at.id].id;
        
            //Título de Capitalización
            CS_Titulo_de_Capitalizacion__c tituloCap = new CS_Titulo_de_Capitalizacion__c();
            tituloCap.Name = 'nameTitulo';
            tituloCap.CS_Cuenta__c = cuenta.id;
            insert tituloCap;
        
            //caso
            caso.ContactId    = contacto.id;
            caso.CS_Numero_de_ATEL__c = atelId;
            //caso.CS_Titulo_de_Capitalizaci_n__c = tituloCap.id;
            caso.CS_Numero_de_Control_ARL__c    = poliza.id;
            //caso.CS_Numero_Poliza_de_seguro__c = poliza.id;
            update caso;
        
            //Crear tarea
            task tarea = new task();
            tarea.WhatId       = caso.id;
            tarea.RecordTypeId = Schema.SObjectType.task.getRecordTypeInfosByDeveloperName().get('CS_Tareas').getRecordTypeId();
            tarea.Subject      = 'Asunto';
            tarea.Description  = 'Comentario';
            tarea.ActivityDate = Date.today().addDays(7);
            //tarea.OwnerId      = [select id from user limit 1].id;
            tarea.Status       = 'Abierto';
            insert tarea;
        
            //Crear usuario
            list<string> roles = label.ws_rolesValidar.split(';');
            user usuario = new user();
            usuario.Username = 'pepitoPrueba@yopmail.com';
            usuario.UserRoleId = [SELECT Id FROM UserRole WHERE Name =: roles[0] LIMIT 1].Id;
            //[LastName, Email, Alias, TimeZoneSidKey, LocaleSidKey, EmailEncodingKey, ProfileId, LanguageLocaleKey]: [LastName, Email, Alias, TimeZoneSidKey, LocaleSidKey, EmailEncodingKey, ProfileId, LanguageLocaleKey]
            usuario.LastName = 'Apellido';
            usuario.Email = 'correo@ejemplo.com';
            usuario.Alias = 'alias';
            usuario.TimeZoneSidKey = 'America/Los_Angeles';
            usuario.LocaleSidKey = 'en_US';
            usuario.EmailEncodingKey = 'UTF-8';
            usuario.ProfileId = [select id from profile where name = 'Administrador del Sistema' limit 1].id;
            usuario.LanguageLocaleKey = 'en_US';
            insert usuario;
        }
    }
    
    @isTest
    static void handleNoRecordsFound() {
        List<WsGetTaskByCaseService.TaskWrapper> tareasWrapper = new List<WsGetTaskByCaseService.TaskWrapper>();
        RestResponse res = new RestResponse();
        
        Test.startTest();
        WsGetTaskByCaseService.handleNoRecordsFound(res, tareasWrapper);
        Test.stopTest();
    }
    
    @isTest
    static void handleInvalidParameters() {
        List<WsGetTaskByCaseService.TaskWrapper> tareasWrapper = new List<WsGetTaskByCaseService.TaskWrapper>();
        RestResponse res = new RestResponse();

        Test.startTest();
        WsGetTaskByCaseService.handleInvalidParameters(res, tareasWrapper);
        Test.stopTest();
    }
    
    @isTest
    static void invalidos1() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/api/Task/getTask/*';
        RestContext.request = req;
        RestContext.response = res;

        req.params.put('id', 'abc');
        Test.startTest();
        List<WsGetTaskByCaseService.TaskWrapper> tareasWrappers = WsGetTaskByCaseService.getTask();
        Test.stopTest();
    }
    
    @isTest
    static void invalidos2() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/api/Task/getTask/*';
        RestContext.request = req;
        RestContext.response = res;

        req.params.put('i', 'abc');
        Test.startTest();
        List<WsGetTaskByCaseService.TaskWrapper> tareasWrappers = WsGetTaskByCaseService.getTask();
        Test.stopTest();
    }
    
    @isTest
    static void getTaskQuery() {
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/api/Task/getTask/*';

        RestContext.request = req;
        RestContext.response = res;
        req.params.put('id', [select id from case limit 1].id);
        
        id usuarioId = [select id from user where email = 'correo@ejemplo.com'].id;
        task tareas = [select id from task];
        tareas.ownerId = usuarioId;
        update tareas;
        
        Test.startTest();
        List<WsGetTaskByCaseService.TaskWrapper> tareasWrappers = WsGetTaskByCaseService.getTask();
        Test.stopTest();
    }
}