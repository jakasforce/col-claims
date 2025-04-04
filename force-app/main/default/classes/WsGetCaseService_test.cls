@isTest
public class WsGetCaseService_test {
 
    @testSetup
    public static void setupData() {
        //Caso
        case caso         = CS_TestDataFactory.createCase(true);
        
        //Case caso = new Case(CS_Departamento__c = '05', CS_Municipio__c = '05002');
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
    }
    
    @istest 
    static void WsGetCaseServicePart1() {
        //Enviar tipo y num doc
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/api/Case/getCases';
        
        req.params.put('tipoDoc', '1');
        req.params.put('numDoc', '123456789');

        // Establecer la solicitud y respuesta en el contexto de RestContext
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        List<WsGetCaseService.CaseWrapper> casosWrappers = WsGetCaseService.getCases();
        Test.stopTest();
    }
    
    @istest 
    static void WsGetCaseServicePart2() {
        //Enviar numAtel
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/api/Case/getCases';
        
        req.params.put('numAtel', '12345');

        // Establecer la solicitud y respuesta en el contexto de RestContext
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        List<WsGetCaseService.CaseWrapper> casosWrappers = WsGetCaseService.getCases();
        Test.stopTest();
    }
    
    @istest 
    static void WsGetCaseServicePart3() {
        //Enviar mal la estructura
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/api/Case/getCases';
        
        req.params.put('nuel', '12345');

        // Establecer la solicitud y respuesta en el contexto de RestContext
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        List<WsGetCaseService.CaseWrapper> casosWrappers = WsGetCaseService.getCases();
        Test.stopTest();
    }
    
    @isTest
    static void testGetCasesByTipoNumDocFind() {
        List<WsGetCaseService.CaseWrapper> casosWrappers = new List<WsGetCaseService.CaseWrapper>();
        
        // Caso 1: Probar cuando se encuentran casos con el tipo y número de documento especificados
        Test.startTest();
        casosWrappers = WsGetCaseService.getCaseByTipoNumDoc(casosWrappers,'1','123456789');
        Test.stopTest();
        System.assertNotEquals(null, casosWrappers, 'La lista de casos no debería ser nula');
    }
    
    @isTest
    static void testGetCasesByTipoNumDocNull() {
        List<WsGetCaseService.CaseWrapper> casosWrappers = new List<WsGetCaseService.CaseWrapper>();
        
        // Caso 2: Probar cuando no se encuentran registros
        Test.startTest();
        casosWrappers = WsGetCaseService.getCaseByTipoNumDoc(casosWrappers,'1','123456777');
        Test.stopTest();
        System.assertEquals(0, casosWrappers.size(), 'ok');
    }
    
    @isTest
    static void getCaseByNumAtelFind() {
        List<WsGetCaseService.CaseWrapper> casosWrappers = new List<WsGetCaseService.CaseWrapper>();
        
        //Caso 3: Buscar por Atel
        Test.startTest();
        WsGetCaseService.getCaseByNumAtel(casosWrappers, '12345');
        Test.stopTest();
        System.assertNotEquals(null, casosWrappers, 'La lista de casos no debería ser nula');
    }
    
    @isTest
    static void handleNoRecordsFound() {
        List<WsGetCaseService.CaseWrapper> casosWrappers = new List<WsGetCaseService.CaseWrapper>();
        RestResponse res = new RestResponse();
        
        //Caso 4: Registros no encontrados
        Test.startTest();
        WsGetCaseService.handleNoRecordsFound(res, casosWrappers);
        Test.stopTest();
    }
    
    @isTest
    static void handleInvalidParameters() {
        List<WsGetCaseService.CaseWrapper> casosWrappers = new List<WsGetCaseService.CaseWrapper>();
        RestResponse res = new RestResponse();

        //Caso 5: Parametros invalidos
        Test.startTest();
        WsGetCaseService.handleInvalidParameters(res,casosWrappers);
        Test.stopTest();
    }
    /*
    @isTest
    static void handleException() {
        RestResponse res = new RestResponse();
        
        //Caso 6: Error interno
        Test.startTest();
        try {
            // Lanzar una excepción para simular un error
            Integer i = 1 / 0; // Esto provocará una excepción de división por cero
        } catch (Exception ex) {
            WsGetCaseService.handleException(res, ex);
        }
        Test.stopTest();
    }
    */
}