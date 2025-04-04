/********************************************************************
Apex Class Name	:	ServicioWorkOrder_Test
Version			:	1.0
Created Date	:	 19/07/2022
Function 		:    Clase test para ServicioWorkOrder
Test Class		:	ServicioWorkOrder_Test

Modification Log
*--------------------------------------------------------------------
* Developer		     		Date			   	Description
* -------------------------------------------------------------------
* Lizeth Ramos  		 	19/07/2022			Original Version-
*********************************************************************/
//XFLS_Proceso_WS_Senda_Test
@isTest
public with sharing class ServicioWorkOrder_Test {
    
    public static final string DEV_RECORDTYPE_CUENTA_JURIDICA = 'CS_Juridico';

    @testSetup
    static void setup(){

        Id RecordTypeIdAcct = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(DEV_RECORDTYPE_CUENTA_JURIDICA).getRecordTypeId();
        String NIT = '32121322';
        
        List<Account> accountList = new List<Account>();
        Account cuentaDuplicada1 = new Account();    
    	cuentaDuplicada1.RecordTypeId=RecordTypeIdAcct;
        cuentaDuplicada1.CS_NumeroIdentificacion__c=NIT;
        cuentaDuplicada1.Name='Cuenta duplicada Test';
        accountList.add(cuentaDuplicada1);

        Account cuentaDuplicada2 = new Account();    
        cuentaDuplicada2.RecordTypeId=RecordTypeIdAcct;
        cuentaDuplicada2.CS_NumeroIdentificacion__c=NIT;
        cuentaDuplicada2.Name='Cuenta duplicada 2';
        accountList.add(cuentaDuplicada2);

        insert accountList;
    }
    
    @isTest
    static void createServicioWOTest(){
        
        XFLS_WrapperSendaGCP2.CuentaWO cuenta= new XFLS_WrapperSendaGCP2.CuentaWO();
        XFLS_WrapperSendaGCP2.OrdenDeTrabajo data= new XFLS_WrapperSendaGCP2.OrdenDeTrabajo();
        XFLS_WrapperSendaGCP2.OrdenDeServicio dataOS=new XFLS_WrapperSendaGCP2.OrdenDeServicio();
        XFLS_WrapperSendaGCP2.SesionDeTrabajo dataST=new XFLS_WrapperSendaGCP2.SesionDeTrabajo();
        List<ServiceAppointment> listaOS=new List<ServiceAppointment> ();

        cuenta.RTAcct='344234';
        cuenta.codigoEmpresaAcct='32121322';
        cuenta.Name='factorytest';

        data.AnoCronograma=123;
        data.TipoPrevencion='ts';
        data.DescripcionUnidad='tst';
        data.NombreCiudad='tst';
        data.Responsable='tst';
        data.Proyecto='tst';
        data.CodigoEstadoAsignacionProveedor=123;
        data.DescripcionEstado='tst';
        data.NitProveedor='tst';
        data.CodigoDisRemision='tst';
        data.NombreDisRemision='tst';
        data.CentroDeCosto='tst';
        data.CiudadesDesarrollo='tst';
        data.CantidadEntregada=2;
        data.CodigoContacto=1;
        data.Contacto='tst';
        data.CiudadContacto='tst';
        data.EnviadaACoordinadorAIS=true;
        data.Negocio='tst';
        data.Actividad='tstsss12';
        data.FechaPedido=(Datetime)JSON.deserialize('"1900-01-01T00:00:00.000Z"', Datetime.class);
        data.Fecha_FechaInicio=(Datetime)JSON.deserialize('"2022-11-29T00:00:00.000Z"', Datetime.class);
        data.Fecha_FechaFin=(Datetime)JSON.deserialize('"2022-12-31T00:00:00.000Z"', Datetime.class);
        data.ResaltarActividad=true;
        data.TarifaTecho=123;
        data.SucursalDisRemision='tst';
        data.FechaInicioMod='2022-01-01';
        data.FechaFinMod='2022-01-01';
        data.codigoCreador='tst';
        data.CodigoProveedor_TipoProveedor='tst';
        data.cedulaConsultor = '1234';
        
        
        

        dataOS.CodigoActividad='234122';
        dataOS.CodigoGrupo='tst';
        dataOS.DescripcionGrupo='tst';
        dataOS.Cantidad=10;
        dataOS.CodigoSubGrupo='tst';
        dataOS.DescripcionSubGrupo='tst';
        
                
        dataST.CodigoSesion='434242211';
        dataST.CodigoEstado='1';
        dataST.CodigoCronograma='tst';
        dataST.codigoArchivoSoporte='tst';
        dataST.FechaInicio=(Datetime)JSON.deserialize('"2022-12-01T00:00:00.000Z"', Datetime.class);
        dataST.FechaFin=(Datetime)JSON.deserialize('"2022-12-01T04:00:00.000Z"', Datetime.class);
        dataST.TotalAsistentes=1;
        
        
        // Crear Usuario (perfil de consultor) y ServiceResource (campo: documento igual a la cedula)
        Id consultorId = [SELECT Id FROM Profile WHERE Name = 'Consultor Unidad Prevención' LIMIT 1].Id;

        User testUser = new User();
        testUser.Username = 'emailtest009@test.com';
        testUser.FirstName = 'First';
        testUser.LastName = 'Last';
        testUser.Alias = 'Alias';
        testUser.Email = 'emailtes0009t@test.com';
        testUser.TimeZoneSidKey = 'America/Mexico_City';
        testUser.LocaleSidKey = 'en_US';
        testUser.EmailEncodingKey = 'ISO-8859-1';
        testUser.ProfileId = consultorId;
        testUser.LanguageLocaleKey = 'en_US';
        insert testUser;
        
        User testUser2 = new User();
        testUser2.Username = 'emailtest010@test.com';
        testUser2.FirstName = 'First2';
        testUser2.LastName = 'Last2';
        testUser2.Alias = 'Alias';
        testUser2.Email = 'emailtes0010t@test.com';
        testUser2.TimeZoneSidKey = 'America/Mexico_City';
        testUser2.LocaleSidKey = 'en_US';
        testUser2.EmailEncodingKey = 'ISO-8859-1';
        testUser2.ProfileId = consultorId;
        testUser2.LanguageLocaleKey = 'en_US';
        insert testUser2;
        
        OperatingHours oph = new OperatingHours();
        oph.Name = 'oppHoursTest';
        insert oph;
        
        ServiceTerritory st = new ServiceTerritory();
        st.Name = 'Colombia';
        st.IsActive = true;
        st.OperatingHoursId = oph.Id;
        insert st;
       
        ServiceResource sr = new ServiceResource();
        sr.Name = 'TestService';
        sr.IsActive = true;
        sr.RelatedRecordId = testUser.Id;
        sr.XFLS_document__c = data.cedulaConsultor;
        insert sr;
        
        ServiceResource sr2 = new ServiceResource();
        sr2.Name = 'TestService2';
        sr2.IsActive = true;
        sr2.RelatedRecordId = testUser2.Id;
        sr2.XFLS_document__c = '4321';
        insert sr2;
        
        ServiceTerritoryMember stm = new ServiceTerritoryMember();
        stm.ServiceResourceId = sr.Id;
        stm.ServiceTerritoryId = st.Id;
        stm.OperatingHoursId = oph.Id;
        stm.EffectiveStartDate = dataST.FechaInicio - 10;
        insert stm;

        ServiceTerritoryMember stm2 = new ServiceTerritoryMember();
        stm2.ServiceResourceId = sr2.Id;
        stm2.ServiceTerritoryId = st.Id;
        stm2.OperatingHoursId = oph.Id;
        stm2.EffectiveStartDate = dataST.FechaInicio - 10;
        insert stm2;

        Test.startTest();
        ServicioWorkOrder.doGet();
        ServicioWorkOrder.doPost(cuenta, data, dataOS, dataST);

        WorkOrder wo=[SELECT Id, Status, XFLS_CedulaConsultor__c FROM WorkOrder LIMIT 1];//momento 1
        
        WorkOrderLineItem woli=[SELECT Id, Status FROM WorkOrderLineItem LIMIT 1]; //momento 2
        woli.Status = 'Aceptada';
        Update woli;

        ServiceAppointment serviceApp= new ServiceAppointment();
        serviceApp.XFLS_Codigo__c=dataST.codigoArchivoSoporte;
        serviceApp.XFLS_Descripcion__c=dataST.estadoSoporte;
        serviceApp.XFLS_VieneDeIntegracion__c = true;
        serviceApp.Status = 'Programado';
        String fechaInicioSA = String.valueOfGmt(dataST.FechaInicio);
        serviceApp.SchedStartTime=Datetime.newInstanceGmt(Date.valueOf(fechaInicioSA), Time.newInstance(0, 0, 0, 0));
        serviceApp.EarliestStartTime = Datetime.newInstanceGmt(Date.valueOf(fechaInicioSA), Time.newInstance(0, 0, 0, 0));     
        serviceApp.DueDate = Datetime.newInstanceGmt(Date.valueOf(fechaInicioSA), Time.newInstance(0, 0, 0, 0)); 
        //serviceApp.SchedEndTime=dataST.FechaFin;
        String fechaFinSA = dataST.FechaFin.format('yyyy-MM-dd');
        serviceApp.SchedEndTime=Datetime.newInstanceGmt(Date.valueOf(fechaInicioSA), Time.newInstance(0, 0, 0, 0));
        serviceApp.XFLS_Observaciones__c=dataST.Observaciones;
        serviceApp.XFLS_CodigoEstado__c=dataST.CodigoEstado;
        serviceApp.XFLS_ObservacionesProveedor__c=dataST.ObservacionesProveedor;
        serviceApp.XFLS_TotalDeAsistentes__c=dataST.TotalAsistentes;
        serviceApp.XFLS_CodigoDeSesion__c= Decimal.valueOf(dataOS.CodigoActividad) + 00000001;
        serviceApp.XFLS_Contacto__c = data.Contacto;
        serviceApp.XFLS_CiudadEjecucion__c = data.CiudadesDesarrollo; 
        List<ServiceAppointment> saExist = new List<ServiceAppointment>();
        saExist = [Select Id From ServiceAppointment Where XFLS_CodigoDeSesion__c =: serviceApp.XFLS_CodigoDeSesion__c];
        if(saExist.size()>0){
            
        }else{
        	serviceApp.parentRecordId=woli.Id;
        }
        System.debug('serviceApp '+serviceApp);

        
        //añadir registro a la lista
        listaOS.add(serviceApp);
        // DML statement

        Schema.SObjectField codigoSesion = ServiceAppointment.Fields.XFLS_CodigoDeSesion__c;
        Database.UpsertResult[] srListaOS = Database.upsert(listaOS, codigoSesion, false);
        // Iterate through each returned result
        List<CS_Log__c> logList=new List<CS_Log__c> (); 

        for (Database.UpsertResult srOS : srListaOS) {
            if (srOS.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                System.debug('Se logró la inserción correcta.  ID de Orden de servicio: ' + srOS.getId());
            }
            else {
                // Operation failed, so get all errors       
                for(Database.Error err : srOS.getErrors()) {System.debug('Ocurrieron los siguientes errores.');   System.debug(err.getStatusCode() + ': ' + err.getMessage());System.debug('Los campos que se afectaron por el error: ' + err.getFields());
                }
                CS_Log__c log=new CS_Log__c(); log.CS_ShortDescription__c='Error Service Appointment';log.CS_Funcion__c='Cargar Service Appointment';
                log.CS_ExceptionStackTrace__c='ServicioWorkOrder';log.CS_RequestMethod__c='POST';log.CS_RequestEndPoint__c='/services/apexrest/servicio-workorder';
                logList.add(log); System.debug('Mandar mensaje de error');}
        }
        if(logList.size()>0){
        	insert logList;
        }

        ServiceAppointment sa=[SELECT Id, Status FROM ServiceAppointment LIMIT 1]; // momento 3
        //momento 4 es cuando pasa la sa a programada 
        
        //probando momento 5 agregar adjunto a la sa
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Document';
        cv.PathOnClient = 'TestDocument.snote';
        cv.VersionData = Blob.valueOf('Test Content');
        cv.IsMajorVersion = true;
        Insert cv;
        System.debug(cv.Id);
        
        ContentDocumentLink cdl=new ContentDocumentLink();
        cdl.ShareType = 'V';
        cdl.ContentDocumentId= [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
        System.debug(cdl.ContentDocumentId);
        cdl.LinkedEntityID=sa.Id;
        Insert cdl;
        
        
        ContentDocumentLink cdl2 =new ContentDocumentLink();
        ContentVersion cv2 = new ContentVersion();
        cv2.Title = 'SA-testDoc';
        cv2.PathOnClient = 'TestDocument.snote';
        cv2.VersionData = Blob.valueOf('Test Content');
        cv2.IsMajorVersion = true;
        Insert cv2;
        System.debug(cv2.Id);
        
        cdl2.ShareType = 'V';
        cdl2.ContentDocumentId= [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv2.Id].ContentDocumentId;
        System.debug(cdl2.ContentDocumentId);
        cdl2.LinkedEntityID=sa.Id;
        Insert cdl2;

        ServiceReport report = new ServiceReport();
        report.DocumentBody = Blob.valueOf('Test Content') ; 
        report.DocumentContentType ='application/pdf';
        report.DocumentName='Test';
        report.ParentId = sa.Id; 
        insert report;

        FSL.GlobalAPIS.addStatusTransition('Programado', 'En curso');
        FSL.GlobalAPIS.addStatusTransition('En curso', 'Ejecutada');
        FSL.GlobalAPIS.addStatusTransition('Ejecutada', 'Enviada');

        sa.Status='En curso';
        sa.ActualStartTime = system.now();
        Update sa;
        
        //momento 3
        sa.Status='Ejecutada';
        sa.ActualStartTime = system.now();
        sa.ActualEndTime = system.now() + 10;
        sa.XFLS_NumeroAsistentes__c = 1;
        sa.XFLS_NumeroAsistentes__c = 5;
        sa.XFLS_FechaRadicacion__c = System.now();
        sa.XFLS_Observaciones__c = 'TestTexto'; 
        Update sa;

        //probando momento 4, 6 y 8
        //momento 6 es que la sa pase a ejecutada y momento 8 ocurre al mismo tiempo y envía el historico de soportes relacionados
        sa.Status='Enviada';
        Update sa;

        //momento 7, cuando la os woli, pasa a estatus completada
        woli.Status='Completada';
        Update woli;
        
        // Probar que se actualice los campos del consultor en la orden
        wo.XFLS_CedulaConsultor__c = sr2.XFLS_document__c;
        update wo;
        
        // Se vuelve a asignar el Consultor original
        wo.XFLS_Consultor__c = sr.Id;
        update wo;
            
        Test.stopTest();
		
    }
}