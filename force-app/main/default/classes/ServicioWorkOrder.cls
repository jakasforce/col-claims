/********************************************************************
Apex Class Name :   ServicioWorkOrder
Version         :   1.0
Created Date    :   08/07/2022
Function        :   Integración que expone el servicio #11 
Test Class      :   

Modification Log
*--------------------------------------------------------------------
* Developer             Date                Description
* ------------------------------------------------------------------
* Lizeth Ramos    06/07/2022         Versión original
* 
*********************************************************************/
@RestResource(urlMapping='/servicio-workorder')
global with sharing class ServicioWorkOrder {

    public static final string DUPLICATE_EXTERNAL_ID = 'DUPLICATE_EXTERNAL_ID';
    public static final string DEV_RECORDTYPE_CUENTA_JURIDICA = 'CS_Juridico';

    @HttpGet
    global static String doGet() {
        RestRequest req= RestContext.request;
        //RequestWrapper bodyRequest=(RequestWrapper)JSON.deserialize(req.requestBody.toString(), RequestWrapper.class);
        return 'se invocó get';
    }

    @HttpPost
    global static void doPost(XFLS_WrapperSendaGCP2.CuentaWO cuenta, XFLS_WrapperSendaGCP2.OrdenDeTrabajo data, XFLS_WrapperSendaGCP2.OrdenDeServicio dataOS, XFLS_WrapperSendaGCP2.SesionDeTrabajo dataST){
        
        Account objCuenta=new Account();
        Contract objContract=new Contract();
        WorkOrder objWorkOrder=new WorkOrder();
        WorkOrderLineItem objWOLI= new WorkOrderLineItem();
        ServiceAppointment objSA=new ServiceAppointment();

        //creación de listas para añadir los registros recibidos
        List<Account> listaAcct=new List<Account>();
        List<Contract> listaContract=new List<Contract>();
        List<WorkOrder> listaWO=new List<WorkOrder> ();
        List<WorkOrderLineItem> listaWOLI=new List<WorkOrderLineItem> ();
        List<ServiceAppointment> listaOS=new List<ServiceAppointment> ();
               
        Id RecordTypeIdAcct = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(DEV_RECORDTYPE_CUENTA_JURIDICA).getRecordTypeId();
        objCuenta.RecordTypeId=RecordTypeIdAcct;
        objCuenta.CS_NumeroIdentificacion__c=cuenta.codigoEmpresaAcct;
        objCuenta.Name=cuenta.Name;
        listaAcct.add(objCuenta);

        // DML statement
        Schema.SObjectField account = Account.Fields.CS_NumeroIdentificacion__c;
        Database.UpsertResult[] srListaAcct = Database.upsert(listaAcct, account, false);

        List<CS_Log__c> logListAcct=new List<CS_Log__c> ();
        for (Database.UpsertResult srAcct : srListaAcct) {
            if (srAcct.isSuccess()) {
                System.debug('Se logró la inserción correcta.  ID de Account: ' + srAcct.getId());
            }
            else {
                // Variable para guardar el StatusCode del error      
                System.StatusCode errorStatusCodeCuenta;

                CS_Log__c logAcct=new CS_Log__c(); 
                logAcct.CS_ShortDescription__c='Error Cuenta'; 
                logAcct.CS_Funcion__c='Cargar Cuenta';
                logAcct.CS_RequestMethod__c='POST';
                logAcct.CS_RequestEndPoint__c='/services/apexrest/servicio-workorder'; 
                for(Database.Error err : srAcct.getErrors()) { 
                    errorStatusCodeCuenta = err.getStatusCode(); 
                    logAcct.CS_ExceptionStackTrace__c='(ServicioWorkOrder) '+err.getStatusCode() + ': ' + err.getMessage();
                }
                
                // Inicio - implementación 27-02-2023
                // Dada la existencia de cuentas duplicadas en producción, se ajusta servicio para que en caso de error al insertar
                // cuentas se valide su motivo y si es por duplicados se consulte en SF y se asocie cualquiera de las existentes 
                // en la Actividad a ser cargada  

                // Se valida si el fallo fue por cuentas duplicadas existentes
                if (DUPLICATE_EXTERNAL_ID.equals(errorStatusCodeCuenta.name())) {
                    // Se obtiene una de las cuentas duplicadas existentes 
                    Account accountOld = [ SELECT Id FROM Account WHERE CS_NumeroIdentificacion__c =: cuenta.codigoEmpresaAcct ORDER BY createdDate DESC LIMIT 1];
                    objCuenta.Id = accountOld.Id;
                    Database.SaveResult[] updateResult = Database.update(new List<Account>{objCuenta}, false);
                    for (Database.SaveResult r : updateResult){
                        if (!r.isSuccess()){
                            CS_Log__c logAcct2=new CS_Log__c(); logAcct2.CS_ShortDescription__c='Error Cuenta'; logAcct2.CS_Funcion__c='Cargar Cuenta';
                            for(Database.Error err : r.getErrors()) { logAcct2.CS_ExceptionStackTrace__c='(ServicioWorkOrder) '+err.getStatusCode() + ': ' + err.getMessage();}
                            logAcct2.CS_RequestMethod__c='POST';logAcct2.CS_RequestEndPoint__c='/services/apexrest/servicio-workorder'; logListAcct.add(logAcct2);System.debug('No se pudo actualizar la cuenta existente');
                        }
                    }
                }else {
                    // Cuando el error es por una causa diferente a duplicidad en las cuentas se debe guardar el log inicial
                    logListAcct.add(logAcct);
                }
                // Fin - implementación 27-02-2023
            }
        }

        objContract.Name = cuenta.RTAcct;
        objContract.Status = 'Draft';
        objContract.StartDate = Date.newInstance(2020, 01, 01);
        objContract.ContractTerm = 1000;
        objContract.AccountId = objCuenta.Id;
        objContract.XFLS_ContractIdSenda__c = cuenta.RTAcct;
        listaContract.add(objContract);
        Schema.SObjectField contract = Contract.Fields.XFLS_ContractIdSenda__c;
        Database.UpsertResult[] srListContract = Database.upsert(listaContract, contract, false);
        // Iterate through each returned result
        for (Database.UpsertResult srContract : srListContract) {
            if (srContract.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                System.debug('Se logró la inserción correcta.  ID de Contrato: ' + srContract.getId());
            }
            else {
                // Operation failed, so get all errors       
                CS_Log__c logAcct=new CS_Log__c(); logAcct.CS_ShortDescription__c='Error Contrato';logAcct.CS_Funcion__c='Cargar Contrato';
                for(Database.Error err : srContract.getErrors()) {logAcct.CS_ExceptionStackTrace__c='(ServicioWorkOrder) '+err.getStatusCode() + ': ' + err.getMessage();} 
                logAcct.CS_RequestMethod__c='POST'; logAcct.CS_RequestEndPoint__c='/services/apexrest/servicio-workorder'; logListAcct.add(logAcct);System.debug('Mandar mensaje de error no se insertó contrato');}
            }

        insert logListAcct;
        
        //objWorkOrder.XFLS_CodigoEmpresa__c=data.Codigoempresa;
        objWorkOrder.XFLS_CodigoEmpresa__c=cuenta.codigoEmpresaAcct;
        objWorkOrder.AccountId = objCuenta.Id;
        objWorkOrder.XFLS_Contrato__c = cuenta.RTAcct;
        objWorkOrder.XFLS_AnoCronograma__c=data.AnoCronograma;
        objWorkOrder.XFLS_TipoPrevencion__c=data.TipoPrevencion;
        objWorkOrder.XFLS_DescripcionUnidad__c=data.DescripcionUnidad;
        objWorkOrder.XFLS_TarifaTecho__c=data.TarifaTecho;
        objWorkOrder.XFLS_NombreCiudad__c=data.NombreCiudad;
        objWorkOrder.XFLS_NOmbreDISAtendedor__c=data.Responsable;
        objWorkOrder.XFLS_Proyecto__c=data.Proyecto;
        objWorkOrder.XFLS_CodigoEstadoAsignacionProveedor__C=data.CodigoEstadoAsignacionProveedor;
        objWorkOrder.XFLS_DescripcionEstado__c=data.DescripcionEstado;
        objWorkOrder.XFLS_NitProveedor__c=data.NitProveedor;
        objWorkOrder.XFLS_CodigoDisRemision__c=data.CodigoDisRemision;
        objWorkOrder.XFLS_NombreDisRemision__c=data.NombreDisRemision;
        objWorkOrder.XFLS_SucursalDisRemision__c=data.SucursalDisRemision;
        objWorkOrder.XFLS_CentroDeCosto__c=data.CentroDeCosto;
        objWorkOrder.XFLS_Actividad__c=dataOS.CodigoActividad;
        objWorkOrder.XFLS_NombreActividad__c =data.Actividad;
        objWorkOrder.XFLS_TipoDeActividad__c =data.Actividad;
        objWorkOrder.XFLS_ActividadTecnica__c = data.Actividad;
        objWorkOrder.XFLS_CodigoDeActividadTecnica__c = dataOS.CodigoActividad;
        objWorkOrder.XFLS_Negocio__c=data.Negocio;
        objWorkOrder.XFLS_CiudadesDesarrollo__c=data.CiudadesDesarrollo;
        objWorkOrder.XFLS_CantidadEntregada__c=data.CantidadEntregada;
        objWorkOrder.XFLS_CodigoContacto__c=data.CodigoContacto;
        objWorkOrder.XFLS_Contacto__c=data.Contacto;
        objWorkOrder.XFLS_CiudadContacto__c=data.CiudadContacto;
        System.debug('data.TelefonoFax ' +data.TelefonoFax);
        objWorkOrder.XFLS_TelefonoFax__c=data.TelefonoFax;
        System.debug('data.TelefonoFax2 ' +data.TelefonoFax);

        System.debug('objWorkOrder.XFLS_TelefonoFax__c ' +objWorkOrder.XFLS_TelefonoFax__c);
        objWorkOrder.XFLS_DireccionPrincipal__c	=data.direccionprincipal;
        //objWorkOrder.XFLS_FechaPedido__c=data.FechaPedido;
        String fechaPedido = data.FechaPedido.format('yyyy-MM-dd');
        objWorkOrder.XFLS_FechaPedido__c=Date.valueOf(fechaPedido);        
     	objWorkOrder.XFLS_VieneDeIntegracion__c = true;
        
        objWorkOrder.XFLS_NombreProveedor__c=data.NombreProveedor;
        objWorkOrder.XFLS_ResaltarActividad__c=data.ResaltarActividad;
        objWorkOrder.XFLS_CodigoSucursalProveedor__c=data.CodigoSucursalProveedor;
        objWorkOrder.XFLS_NumeroInvitados__c=data.NumeroInvitados;
        objWorkOrder.XFLS_EnviadaACoordinadorAIS__c=data.EnviadaACoordinadorAIS;
        objWorkOrder.XFLS_TarifaVenta__c=data.TarifaVenta;
        objWorkOrder.XFLS_FechaInicioMod__c=data.FechaInicioMod;
        objWorkOrder.XFLS_FechaFinMod__c=data.FechaFinMod;
        objWorkOrder.XFLS_numeroSapSolicitadas__c=data.numeroSapSolicitadas;
        objWorkOrder.XFLS_CodigoPadreActividad__c=data.CodigoPadreActividad;
        objWorkOrder.XFLS_codigoCreador__c=data.codigoCreador;
        //objWorkOrder.XFLS_Fecha_FechaInicio__c=data.Fecha_FechaInicio;
        String fechaInicio = String.valueOfGmt(data.Fecha_FechaInicio);
        objWorkOrder.XFLS_Fecha_FechaInicio__c=Datetime.newInstanceGmt(Date.valueOf(fechaInicio), Time.newInstance(5, 0, 0, 0));
        objWorkOrder.StartDate = Datetime.newInstanceGmt(Date.valueOf(fechaInicio), Time.newInstance(5, 0, 0, 0));
        //objWorkOrder.XFLS_Fecha_FechaFin__c=data.Fecha_FechaFin;
        String fechaFin = String.valueOfGmt(data.Fecha_FechaFin);
        objWorkOrder.XFLS_Fecha_FechaFin__c=Datetime.newInstanceGmt(Date.valueOf(fechaFin), Time.newInstance(5, 0, 0, 0)); 
        objWorkOrder.EndDate = Datetime.newInstanceGmt(Date.valueOf(fechaFin), Time.newInstance(5, 0, 0, 0));
        objWorkOrder.XFLS_ProyectoColmena__c=data.ProyectoColmena;
        objWorkOrder.XFLS_EstadoContratacion__c=data.EstadoContratacion;
        objWorkOrder.XFLS_EstadoGestionContratacion__c=data.EstadoGestionContratacion;
        objWorkOrder.XFLS_CodigoProveedor_TipoProveedor__c=data.CodigoProveedor_TipoProveedor;
        objWorkOrder.XFLS_codigotipomanejoPresupuesto__c=data.codigotipomanejoPresupuesto;
        objWorkOrder.XFLS_Actividad_RealizadaPorSubTipoId__c=data.Actividad_RealizadaPorSubTipoId;
        
        //traer valores requeridos de WOLI
        objWorkOrder.XFLS_CodigoEstadoOS__c	 =dataST.CodigoEstado;
        
        //traer valores de account?
        objWorkOrder.XFLS_CodigoEmpresa__c=cuenta.codigoEmpresaAcct;
        objWorkOrder.XFLS_CedulaConsultor__c = data.cedulaConsultor;
        
        objWorkOrder.XFLS_CodigoGrupo__c=dataOS.CodigoGrupo;
        objWorkOrder.XFLS_DescripcionGrupo__c=dataOS.DescripcionGrupo;
        objWorkOrder.XFLS_CodigoSubGrupo__c=dataOS.CodigoSubGrupo;
        objWorkOrder.XFLS_DescSubGrupo__c=dataOS.DescripcionSubGrupo;
        objWorkOrder.XFLS_Cantidad__c=dataOS.Cantidad;
        objWorkOrder.Duration=dataOS.Cantidad;
        objWorkOrder.XFLS_CodigoCronograma__c=dataST.CodigoCronograma;
        objWorkOrder.XFLS_CodigoTipoDeActividad__c=dataOS.CodigoTipoActividad;
        objWorkOrder.XFLS_NombreLinea__c=dataOS.NombreLinea;
        objWorkOrder.XFLS_ObservacionesProveedor__c=dataST.ObservacionesProveedor;
        objWorkOrder.XFLS_Observaciones__c=dataST.Observaciones;
        //añadir registro a la lista
        listaWO.add(objWorkOrder);
        // DML statement
		System.debug('objWorkOrder '+objWorkOrder);
        List<CS_Log__c> logListWO=new List<CS_Log__c> (); 

        Schema.SObjectField actividad = WorkOrder.Fields.XFLS_Actividad__c;
        Database.UpsertResult[] srListaWO = Database.upsert(listaWO, actividad, false);
        // Iterate through each returned result
        for (Database.UpsertResult sr : srListaWO) {
            if (sr.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                System.debug('Se logró la inserción correcta.  ID de Workorder: ' + sr.getId());
            }
            else {
                // Operation failed, so get all errors     
                CS_Log__c logWO=new CS_Log__c();
                for(Database.Error err : sr.getErrors()) {logWO.CS_ExceptionStackTrace__c='(ServicioWorkOrder) '+err.getStatusCode() + ': ' + err.getMessage();}
                logWO.CS_ShortDescription__c='Error Orden de Actividad';logWO.CS_Funcion__c='Cargar Actividad';logWO.CS_RequestMethod__c='POST';logWO.CS_RequestEndPoint__c='/services/apexrest/servicio-workorder';
                logListWO.add(logWO); System.debug('Mandar mensaje de error');}
        }
        if(logListWO.size()>0){
        	insert logListWO;
        }
        
        
  
        
          
        WorkOrderLineItem woli= new WorkOrderLineItem();
        woli.WorkOrderId=objWorkOrder.Id;
        woli.XFLS_RealizadoPor__c=dataOS.RealizadaPor;
        woli.XFLS_VieneDeIntegraciOn__c = true;
        woli.XFLS_CodigoEstadoOS__c = dataST.CodigoEstado;
        woli.XFLS_FechaPublicacionOS__c = System.now();
        woli.XFLS_FechaAprobacionOS__c = System.now();
        woli.XFLS_NecesidadesAdministrativas__c = '1';
        woli.XFLS_Tarifa__c = data.TarifaTecho;
        woli.Duration = Decimal.valueOf(dataOS.Cantidad);
        woli.XFLS_FechaInicio__c = Datetime.newInstanceGmt(Date.valueOf(fechaInicio), Time.newInstance(5, 0, 0, 0));
        woli.XFLS_FechaFin__c = Datetime.newInstanceGmt(Date.valueOf(fechaFin), Time.newInstance(5, 0, 0, 0));
        woli.StartDate = Datetime.newInstanceGmt(Date.valueOf(fechaInicio), Time.newInstance(5, 0, 0, 0));
        woli.EndDate = Datetime.newInstanceGmt(Date.valueOf(fechaFin), Time.newInstance(5, 0, 0, 0));
        woli.XFLS_NombreContacto__c = data.Contacto;
        
        String CodigoOS= String.valueOf(dataOS.CodigoActividad) + '00000001';
		woli.XFLS_CodigoOS__c = CodigoOS;
		System.debug('woli '+woli);
        //upsert woli;

        //añadir registro a la lista
        listaWOLI.add(woli);
        // DML statement

        List<CS_Log__c> logListWOLI=new List<CS_Log__c> (); 

       Schema.SObjectField CodigoOS1 = WorkOrderLineItem.Fields.XFLS_CodigoOS__c;
        Database.UpsertResult[] srListaWOLI = Database.upsert(listaWOLI, CodigoOS1, false);
        // Iterate through each returned result
        for (Database.UpsertResult sr : srListaWOLI) {
            if (sr.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                System.debug('Se logró la inserción correcta.  ID de WorkorderLineItem: ' + sr.getId());
            }
            else {
                // Operation failed, so get all errors 
                CS_Log__c logWOLI=new CS_Log__c(); for(Database.Error err : sr.getErrors()) {logWOLI.CS_ExceptionStackTrace__c='(ServicioWorkOrder) '+err.getStatusCode() + ': ' + err.getMessage();}
                logWOLI.CS_ShortDescription__c='Error WOLI';logWOLI.CS_Funcion__c='Cargar WOLI'; logWOLI.CS_RequestMethod__c='POST';logWOLI.CS_RequestEndPoint__c='/services/apexrest/servicio-workorder';
                logListWOLI.add(logWOLI);System.debug('Mandar mensaje de error');}
        }
        if(logListWOLI.size()>0){
       		insert logListWOLI;
        }
        
        // ServiceAppointment serviceApp= new ServiceAppointment();
        // serviceApp.XFLS_Codigo__c=dataST.codigoArchivoSoporte;
        // serviceApp.XFLS_Descripcion__c=dataST.estadoSoporte;
        // serviceApp.XFLS_VieneDeIntegracion__c = true;
        // serviceApp.Status = 'Programado';
        // //serviceApp.SchedStartTime=dataST.FechaInicio;
        // String fechaInicioSA = dataST.FechaInicio.format('YYYY-MM-DD HH:MM:SS');
        // serviceApp.SchedStartTime=Date.valueOf(fechaInicioSA);
		// serviceApp.EarliestStartTime = Date.valueOf(fechaInicioSA);     
        // serviceApp.DueDate = Date.valueOf(fechaInicioSA);      
        // //serviceApp.SchedEndTime=dataST.FechaFin;
        // String fechaFinSA = dataST.FechaFin.format('YYYY-MM-DD HH:MM:SS');
        // serviceApp.SchedEndTime=Date.valueOf(fechaInicioSA);
        // serviceApp.XFLS_Observaciones__c=dataST.Observaciones;
        // serviceApp.XFLS_CodigoEstado__c=dataST.CodigoEstado;
        // serviceApp.XFLS_ObservacionesProveedor__c=dataST.ObservacionesProveedor;
        // serviceApp.XFLS_TotalDeAsistentes__c=dataST.TotalAsistentes;
        // serviceApp.XFLS_CodigoDeSesion__c= Decimal.valueOf(dataOS.CodigoActividad) + 00000001;
        // serviceApp.XFLS_Contacto__c = data.Contacto;
        // serviceApp.XFLS_CiudadEjecucion__c = data.CiudadesDesarrollo; 
        // List<ServiceAppointment> saExist = new List<ServiceAppointment>();
        // saExist = [Select Id From ServiceAppointment Where XFLS_CodigoDeSesion__c =: serviceApp.XFLS_CodigoDeSesion__c];
        // if(saExist.size()>0){
            
        // }else{
        // 	serviceApp.parentRecordId=woli.Id;
        // }
        // System.debug('serviceApp '+serviceApp);

        
        // //añadir registro a la lista
        // listaOS.add(serviceApp);
        // // DML statement

        // Schema.SObjectField codigoSesion = ServiceAppointment.Fields.XFLS_CodigoDeSesion__c;
        // Database.UpsertResult[] srListaOS = Database.upsert(listaOS, codigoSesion, false);
        // // Iterate through each returned result
        // List<CS_Log__c> logList=new List<CS_Log__c> (); 

        // for (Database.UpsertResult sr : srListaOS) {
        //     if (sr.isSuccess()) {
        //         // Operation was successful, so get the ID of the record that was processed
        //         System.debug('Se logró la inserción correcta.  ID de Orden de servicio: ' + sr.getId());
        //     }
        //     else {
        //         // Operation failed, so get all errors       
        //         for(Database.Error err : sr.getErrors()) {System.debug('Ocurrieron los siguientes errores.');   System.debug(err.getStatusCode() + ': ' + err.getMessage());System.debug('Los campos que se afectaron por el error: ' + err.getFields());
        //         }
        //         CS_Log__c log=new CS_Log__c(); log.CS_ShortDescription__c='Error Service Appointment';log.CS_Funcion__c='Cargar Service Appointment';
        //         log.CS_ExceptionStackTrace__c='ServicioWorkOrder';log.CS_RequestMethod__c='POST';log.CS_RequestEndPoint__c='/services/apexrest/servicio-workorder';
        //         logList.add(log); System.debug('Mandar mensaje de error');}
        // }
        // if(logList.size()>0){
        // 	insert logList;
        // }
        RestResponse res = RestContext.response;
        XFLS_WrapperSendaGCP.responseServicioWorkOrder responseBodySWO = new XFLS_WrapperSendaGCP.responseServicioWorkOrder();
        if(objWorkOrder.Id != null){
            responseBodySWO.actividadId = objWorkOrder.Id;
            responseBodySWO.mensaje = 'Actividad insertada con éxito';
            if(woli.Id != null){
                responseBodySWO.ordenDeServicioId = woli.Id;
                            responseBodySWO.mensaje = 'Actividad y Orden de Servicio insertadas con éxito';
                // if(serviceApp.Id != null){
                //     responseBodySWO.mensaje = 'Actividad, Orden de Servicio y Sesión de Trabajo insertadas con éxito';
                //     responseBodySWO.sesionDeTrabajoId = serviceApp.Id;
                // }else{
                //     responseBodySWO.sesionDeTrabajoId = '';
                // }
            }else{responseBodySWO.ordenDeServicioId = '';responseBodySWO.sesionDeTrabajoId = '';
            }
            if(!Test.isRunningTest()){res.addHeader('Content-Type', 'application/json');res.responseBody = Blob.valueOf(JSON.serialize(responseBodySWO));res.statusCode = 200;
            }
        }
        else{responseBodySWO.actividadId = '';responseBodySWO.ordenDeServicioId = '';responseBodySWO.sesionDeTrabajoId = '';responseBodySWO.mensaje = 'Actividad no Insertada';
            if(!Test.isRunningTest()){res.addHeader('Content-Type', 'text/plain'); res.responseBody = Blob.valueOf(JSON.serialize(responseBodySWO));res.statusCode = 400;
            }    
        }
        //return objWorkOrder;
        
    }
}