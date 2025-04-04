@istest
public class ServiceAppointmentTriggerHandlerTest {

    @istest
    public static void serviceAppointmentTestCreate(){
        test.startTest();
        
        
         WorkOrder woTest = new WorkOrder();

        woTest.XFLS_FechaPublicacionOS__c = Datetime.newInstance(2022, 5, 31);
        woTest.XFLS_FechaAprobacionOS__c = Datetime.newInstance(2022, 5, 31);
        woTest.XFLS_CodigoOS__c = '1';
        woTest.XFLS_CodigoEstadoOS__c = '1';
        woTest.XFLS_CodigoEmpresa__c = '1';
        woTest.XFLS_Contrato__c = '1';
        woTest.XFLS_CodigoDIS__c = '1';
        woTest.XFLS_DIS__c = '1';
        woTest.XFLS_NOmbreDISAtendedor__c = 'Jose';
        woTest.XFLS_Actividad__c = '1';
        woTest.XFLS_CodigoDeActividadTecnica__c = '1';
        woTest.XFLS_TipoDeActividad__c = 'Test';
        woTest.XFLS_CodigoGrupo__c = '1';
        woTest.XFLS_CodigoSubGrupo__c = '1';
        woTest.XFLS_DescSubGrupo__c = 'Sub Grupo Test';
        woTest.XFLS_DescripcionGrupo__c = 'Grupo Test';
        woTest.XFLS_Cantidad__c = 1;
        woTest.Status = 'Nueva';
        woTest.XFLS_Observaciones__c = 'Ninguna';
       woTest.XFLS_VieneDeIntegracion__c = true;
     
        insert woTest;
        WorkOrderLineItem woliTest = new WorkOrderLineItem();
        woliTest.WorkOrderId = woTest.Id;
        woliTest.XFLS_CodigoOS__c = '1';
        
        woliTest.XFLS_CodigoDeActividadTecnicaSAP__c = '1';
        //woliTest.XFLS_RealizadoPor__c = 'JOS';
        woliTest.XFLS_CodigoAutorizacion__c = '1';
        woliTest.Status = 'Aceptada';
        woliTest.XFLS_FechaRadicacion__c = System.today();
        woliTest.XFLS_FechaAutorizacion__c = System.today();
           woliTest.XFLS_FechaInicio__c =System.today().addDays(1);
             
           woliTest.StartDate =System.today().addDays(1);
   woliTest.EndDate =System.today().addDays(5);
        woliTest.XFLS_CodEdoAuto__c = '1';
        woliTest.XFLS_EstadoAuto__c = '1';
        woliTest.XFLS_FechaProcesadaInt__c = System.today();
        woliTest.XFLS_ProcesadaInterfaz__c = 1;
        woliTest.XFLS_CodigoInterfaz__c = '1';
        woliTest.XFLS_CodigoUserAutoriza__c = '1';
        
        woliTest.XFLS_HorasProgramadas__c = 4;
        woliTest.Duration =30;
     woliTest.XFLS_TiempoEjecutado__c =1;
        woliTest.XFLS_HorasSuspendidas__c = 4;
         woliTest.XFLS_MotivoRechazo__c = 'prueba';
        insert woliTest;
        string idWoliTest = woliTest.Id;
        system.debug('woliTestwoliTest'+woliTest.Id);
        system.debug('woliTestwoliTest'+idWoliTest);
      
        ServiceAppointment newSA = new ServiceAppointment();
        
        newSA.ParentRecordId = woliTest.Id;
        newSA.XFLS_EsContigenciaCOVID19__c = '1';
        newSA.XFLS_Soportes__c = 1;
        newSA.XFLS_NecesidadesAdministrativas__c = 1;
        newSA.DueDate = System.today().addDays(5);
        newSA.EarliestStartTime = System.today().addDays(1);
        
                newSA.SchedStartTime =System.today().addDays(2);
        newSA.SchedEndTime =System.today().addDays(3);
        newSA.XFLS_TotalDeAsistentes__c = 1;
              
      
        //Campos para servicio Radicar Sesion Ejecutada
        newSA.Status = 'Reprogramar';
        newSA.XFLS_CodigoDeSesion__c = 1;
        newSA.XFLS_CodigoEstadoPed__c = '1';
        newSA.ParentRecordId__c = '1';
       newSA.XFLS_SinFecha__c = true;
       newSA.XFLS_MotReprogramacion__c = 'prueba motivo';
newSA.XFLS_NumeroAsistentes__c =5;
newSA.XFLS_Observaciones__c ='test';
newSA.ActualStartTime=Datetime.newInstance(2022, 5, 31);
newSA.ActualEndTime=Datetime.newInstance(2022, 5, 31);
        insert newSA;
        newSA.XFLS_MotReprogramacion__c = 'prueba motivo1';
        update newSA;
        XFLS_Soporte_Sesion__c Soporte_Sesion = new XFLS_Soporte_Sesion__c();
        Soporte_Sesion.XFLS_SesionDeTrabajo__c = newSA.id;
        insert Soporte_Sesion;
        List <Id> IdsSesWork = new  List <Id>();
        IdsSesWork.add(newSA.id);
        
       XFLS_ServiceAppointmentTriggerHandler.enviarhistorico(IdsSesWork);
       XFLS_ServiceAppointmentTriggerHandler.radicarOrdenesDeTrabajo(IdsSesWork);
        XFLS_ServiceAppointmentTriggerHandler.radicaSesionesEjecutadas(IdsSesWork);
        
        test.stopTest();
    }@istest
    public static void serviceAppointmentTestCreateEnviada(){
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
        ServiceResource sr = new ServiceResource();
        sr.Name = 'TestService';
        sr.IsActive = true;
        sr.RelatedRecordId = testUser.Id;
        sr.XFLS_document__c = '12345';
        sr.XFLS_Email__c = 'emailtes00019t@test.com';
        insert sr;
        OperatingHours oph = new OperatingHours();
        oph.Name = 'oppHoursTest';
        insert oph;
        ServiceTerritory st = new ServiceTerritory();
        st.Name = 'Colombia';
        st.IsActive = true;
        st.OperatingHoursId = oph.Id;
        insert st;
        ServiceTerritoryMember stm = new ServiceTerritoryMember();
        stm.ServiceResourceId = sr.Id;
        stm.ServiceTerritoryId = st.Id;
        stm.OperatingHoursId = oph.Id;
        stm.EffectiveStartDate =((Datetime)JSON.deserialize('"2022-12-01T00:00:00.000Z"', Datetime.class))- 10;
        insert stm;
        
        
        
         WorkOrder woTest = new WorkOrder();

        woTest.XFLS_FechaPublicacionOS__c = Datetime.newInstance(2023, 6, 30);
        woTest.XFLS_FechaAprobacionOS__c = Datetime.newInstance(2023,7, 10);
        woTest.XFLS_CodigoOS__c = '1';
        woTest.XFLS_CodigoEstadoOS__c = '1';
        woTest.XFLS_CodigoEmpresa__c = '1';
        woTest.XFLS_Contrato__c = '1';
        woTest.XFLS_CodigoDIS__c = '1';
        woTest.XFLS_DIS__c = '1';
        woTest.XFLS_NOmbreDISAtendedor__c = 'Jose';
        woTest.XFLS_Actividad__c = '1';
        woTest.XFLS_CodigoDeActividadTecnica__c = '1';
        woTest.XFLS_TipoDeActividad__c = 'Test';
        woTest.XFLS_CodigoGrupo__c = '1';
        woTest.XFLS_CodigoSubGrupo__c = '1';
        woTest.XFLS_DescSubGrupo__c = 'Sub Grupo Test';
        woTest.XFLS_DescripcionGrupo__c = 'Grupo Test';
        woTest.XFLS_Cantidad__c = 1;
        woTest.Status = 'Nueva';
        woTest.XFLS_Observaciones__c = 'Ninguna';
      woTest.XFLS_Consultor__c = sr.id;
          woTest.XFLS_VieneDeIntegracion__c = true;
        insert woTest;
       
        WorkOrderLineItem woliTest = new WorkOrderLineItem();
        woliTest.WorkOrderId = woTest.Id;
        woliTest.XFLS_CodigoOS__c = '1';
        
        woliTest.XFLS_CodigoDeActividadTecnicaSAP__c = '1';
        //woliTest.XFLS_RealizadoPor__c = 'JOS';
        woliTest.XFLS_CodigoAutorizacion__c = '1';
        woliTest.Status = 'Aceptada';
        woliTest.XFLS_FechaRadicacion__c = System.today();
        woliTest.XFLS_FechaAutorizacion__c = System.today();
           woliTest.XFLS_FechaInicio__c =System.today().addDays(1);
           woliTest.StartDate =System.today().addDays(1);
         woliTest.XFLS_FechaFin__c = System.today().addDays(1);
   woliTest.EndDate =System.today().addDays(5);
        woliTest.XFLS_CodEdoAuto__c = '1';
        woliTest.XFLS_EstadoAuto__c = '1';
        woliTest.XFLS_FechaProcesadaInt__c = System.today();
        woliTest.XFLS_ProcesadaInterfaz__c = 1;
        woliTest.XFLS_CodigoInterfaz__c = '1';
        woliTest.XFLS_CodigoUserAutoriza__c = '1';
        woliTest.XFLS_HorasProgramadas__c = 4;
        woliTest.Duration =30;
     woliTest.XFLS_TiempoEjecutado__c =1;
        woliTest.XFLS_HorasSuspendidas__c = 4;
         woliTest.XFLS_MotivoRechazo__c = 'prueba';
        insert woliTest;
        string idWoliTest = woliTest.Id;
        system.debug('woliTestwoliTest'+woliTest.Id);
        system.debug('woliTestwoliTest'+idWoliTest);
      
        ServiceAppointment newSA = new ServiceAppointment();
        
        newSA.ParentRecordId = woliTest.Id;
        newSA.XFLS_EsContigenciaCOVID19__c = '1';
        newSA.XFLS_Soportes__c = 1;
        newSA.XFLS_NecesidadesAdministrativas__c = 1;
        newSA.DueDate = System.today().addDays(5);
        newSA.EarliestStartTime = System.today().addDays(1);
        
                newSA.SchedStartTime =System.today().addDays(2);
        newSA.SchedEndTime =System.today().addDays(3);
        newSA.XFLS_TotalDeAsistentes__c = 1;
              
      
        //Campos para servicio Radicar Sesion Ejecutada
        newSA.Status = 'Ejecutada';
        newSA.XFLS_CodigoDeSesion__c = 1;
        newSA.XFLS_CodigoEstadoPed__c = '1';
        newSA.ParentRecordId__c = '1';
       newSA.XFLS_SinFecha__c = true;
       newSA.XFLS_MotReprogramacion__c = 'prueba motivo';
newSA.XFLS_NumeroAsistentes__c =5;
newSA.XFLS_Observaciones__c ='test';
newSA.ActualStartTime=Datetime.newInstance(2022, 5, 31);
newSA.ActualEndTime=Datetime.newInstance(2022, 5, 31);
        insert newSA;
    }
    

    @istest
    public static void serviceAppointmentTestAccountWorkOrder(){
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
        ServiceResource sr = new ServiceResource();
        sr.Name = 'TestService';
        sr.IsActive = true;
        sr.RelatedRecordId = testUser.Id;
        sr.XFLS_document__c = '12345';
        sr.XFLS_Email__c = 'emailtes00019t@test.com';
        insert sr;
        OperatingHours oph = new OperatingHours();
        oph.Name = 'oppHoursTest';
        insert oph;
        ServiceTerritory st = new ServiceTerritory();
        st.Name = 'Colombia';
        st.IsActive = true;
        st.OperatingHoursId = oph.Id;
        insert st;
        ServiceTerritoryMember stm = new ServiceTerritoryMember();
        stm.ServiceResourceId = sr.Id;
        stm.ServiceTerritoryId = st.Id;
        stm.OperatingHoursId = oph.Id;
        stm.EffectiveStartDate =((Datetime)JSON.deserialize('"2022-12-01T00:00:00.000Z"', Datetime.class))- 10;
        insert stm;
        
        	Id personAccountRecordTypeId =  Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId(); 
    	Account personal1 = new Account(RecordTypeId=personAccountRecordTypeId,
                                               PersonMobilePhone='55555',
                                               PersonEmail='emailconsulta@test.com',
                                               FirstName='Nombre',
                                               LastName='Apellido',
                                               Phone='55555',
                                               CS_NumeroIdentificacionCP__pc	= '11157575739',
                                               CS_TipoIdentificacionCP__pc		= '1'
                                               );
         INSERT personal1; 
        
         WorkOrder woTest = new WorkOrder();

        woTest.XFLS_FechaPublicacionOS__c = Datetime.newInstance(2022, 5, 31);
        woTest.XFLS_FechaAprobacionOS__c = Datetime.newInstance(2022, 5, 31);
        woTest.XFLS_CodigoOS__c = '1';
        woTest.XFLS_CodigoEstadoOS__c = '1';
        woTest.XFLS_CodigoEmpresa__c = '1';
        woTest.XFLS_Contrato__c = '1';
        woTest.XFLS_CodigoDIS__c = '1';
        woTest.XFLS_DIS__c = '1';
        woTest.XFLS_NOmbreDISAtendedor__c = 'Jose';
        woTest.XFLS_Actividad__c = '1';
        woTest.XFLS_CodigoDeActividadTecnica__c = '1';
        woTest.XFLS_TipoDeActividad__c = 'Test';
        woTest.XFLS_CodigoGrupo__c = '1';
        woTest.XFLS_CodigoSubGrupo__c = '1';
        woTest.XFLS_DescSubGrupo__c = 'Sub Grupo Test';
        woTest.XFLS_DescripcionGrupo__c = 'Grupo Test';
        woTest.XFLS_Cantidad__c = 1;
        woTest.Status = 'Nueva';
        woTest.XFLS_Observaciones__c = 'Ninguna';
      woTest.XFLS_Consultor__c = sr.id;
        woTest.AccountId = personal1.id ;
         woTest.XFLS_VieneDeIntegracion__c = true;
        insert woTest;
        WorkOrderLineItem woliTest = new WorkOrderLineItem();
        woliTest.WorkOrderId = woTest.Id;
        woliTest.XFLS_CodigoOS__c = '1';
        
        woliTest.XFLS_CodigoDeActividadTecnicaSAP__c = '1';
        //woliTest.XFLS_RealizadoPor__c = 'JOS';
        woliTest.XFLS_CodigoAutorizacion__c = '1';
        woliTest.Status = 'Aceptada';
        woliTest.XFLS_FechaRadicacion__c = System.today();
        woliTest.XFLS_FechaAutorizacion__c = System.today();
           woliTest.XFLS_FechaInicio__c =System.today().addDays(1);
           woliTest.StartDate =System.today().addDays(1);
         woliTest.XFLS_FechaFin__c = System.today().addDays(1);
   woliTest.EndDate =System.today().addDays(5);
        woliTest.XFLS_CodEdoAuto__c = '1';
        woliTest.XFLS_EstadoAuto__c = '1';
        woliTest.XFLS_FechaProcesadaInt__c = System.today();
        woliTest.XFLS_ProcesadaInterfaz__c = 1;
        woliTest.XFLS_CodigoInterfaz__c = '1';
        woliTest.XFLS_CodigoUserAutoriza__c = '1';
        woliTest.XFLS_HorasProgramadas__c = 4;
        woliTest.Duration =30;
     woliTest.XFLS_TiempoEjecutado__c =1;
        woliTest.XFLS_HorasSuspendidas__c = 4;
         woliTest.XFLS_MotivoRechazo__c = 'prueba';
        
        insert woliTest;
        string idWoliTest = woliTest.Id;
        system.debug('woliTestwoliTest'+woliTest.Id);
        system.debug('woliTestwoliTest'+idWoliTest);
      
        ServiceAppointment newSA = new ServiceAppointment();
        
        newSA.ParentRecordId = woliTest.Id;
        newSA.XFLS_EsContigenciaCOVID19__c = '1';
        newSA.XFLS_Soportes__c = 1;
        newSA.XFLS_NecesidadesAdministrativas__c = 1;
        newSA.DueDate = System.today().addDays(5);
        newSA.EarliestStartTime = System.today().addDays(1);
        
                newSA.SchedStartTime =System.today().addDays(2);
        newSA.SchedEndTime =System.today().addDays(3);
        newSA.XFLS_TotalDeAsistentes__c = 1;
              
      
        //Campos para servicio Radicar Sesion Ejecutada
        newSA.Status = 'Ejecutada';
        newSA.XFLS_CodigoDeSesion__c = 1;
        newSA.XFLS_CodigoEstadoPed__c = '1';
        newSA.ParentRecordId__c = '1';
       newSA.XFLS_SinFecha__c = true;
       newSA.XFLS_MotReprogramacion__c = 'prueba motivo';
newSA.XFLS_NumeroAsistentes__c =5;
newSA.XFLS_Observaciones__c ='test';
newSA.ActualStartTime=Datetime.newInstance(2022, 5, 31);
newSA.ActualEndTime=Datetime.newInstance(2022, 5, 31);
        insert newSA;
        
    }
     @istest
    public static void serviceAppointmentTestStatusWorkOrder(){
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
        ServiceResource sr = new ServiceResource();
        sr.Name = 'TestService';
        sr.IsActive = true;
        sr.RelatedRecordId = testUser.Id;
        sr.XFLS_document__c = '12345';
        sr.XFLS_Email__c = 'emailtes00019t@test.com';
        insert sr;
        OperatingHours oph = new OperatingHours();
        oph.Name = 'oppHoursTest';
        insert oph;
        ServiceTerritory st = new ServiceTerritory();
        st.Name = 'Colombia';
        st.IsActive = true;
        st.OperatingHoursId = oph.Id;
        insert st;
        ServiceTerritoryMember stm = new ServiceTerritoryMember();
        stm.ServiceResourceId = sr.Id;
        stm.ServiceTerritoryId = st.Id;
        stm.OperatingHoursId = oph.Id;
        stm.EffectiveStartDate =((Datetime)JSON.deserialize('"2022-12-01T00:00:00.000Z"', Datetime.class))- 10;
        insert stm;
        
        	Id personAccountRecordTypeId =  Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId(); 
    	Account personal1 = new Account(RecordTypeId=personAccountRecordTypeId,
                                               PersonMobilePhone='55555',
                                               PersonEmail='emailconsulta@test.com',
                                               FirstName='Nombre',
                                               LastName='Apellido',
                                               Phone='55555',
                                               CS_NumeroIdentificacionCP__pc	= '11157575739',
                                               CS_TipoIdentificacionCP__pc		= '1'
                                               );
         INSERT personal1; 
        
         WorkOrder woTest = new WorkOrder();

        woTest.XFLS_FechaPublicacionOS__c = Datetime.newInstance(2022, 5, 31);
        woTest.XFLS_FechaAprobacionOS__c = Datetime.newInstance(2022, 5, 31);
        woTest.XFLS_CodigoOS__c = '1';
        woTest.XFLS_CodigoEstadoOS__c = '1';
        woTest.XFLS_CodigoEmpresa__c = '1';
        woTest.XFLS_Contrato__c = '1';
        woTest.XFLS_CodigoDIS__c = '1';
        woTest.XFLS_DIS__c = '1';
        woTest.XFLS_NOmbreDISAtendedor__c = 'Jose';
        woTest.XFLS_Actividad__c = '1';
        woTest.XFLS_CodigoDeActividadTecnica__c = '1';
        woTest.XFLS_TipoDeActividad__c = 'Test';
        woTest.XFLS_CodigoGrupo__c = '1';
        woTest.XFLS_CodigoSubGrupo__c = '1';
        woTest.XFLS_DescSubGrupo__c = 'Sub Grupo Test';
        woTest.XFLS_DescripcionGrupo__c = 'Grupo Test';
        woTest.XFLS_Cantidad__c = 1;
        woTest.Status = 'Suspendido';
        woTest.XFLS_Observaciones__c = 'Ninguna';
      woTest.XFLS_Consultor__c = sr.id;
        woTest.AccountId = personal1.id ;
         woTest.XFLS_VieneDeIntegracion__c = true;
        insert woTest;
        
        WorkOrderLineItem woliTest = new WorkOrderLineItem();
        woliTest.WorkOrderId = woTest.Id;
        woliTest.XFLS_CodigoOS__c = '1';
         woliTest.Status = 'Suspendido' ; 
         woliTest.XFLS_TipoSuspension__c = 'Parcial';
        woliTest.XFLS_CodigoDeActividadTecnicaSAP__c = '1';
        //woliTest.XFLS_RealizadoPor__c = 'JOS';
        woliTest.XFLS_CodigoAutorizacion__c = '1';
       
        woliTest.XFLS_FechaRadicacion__c = System.today();
        woliTest.XFLS_FechaAutorizacion__c = System.today();
           woliTest.XFLS_FechaInicio__c =System.today().addDays(1);
           woliTest.StartDate =System.today().addDays(1);
         woliTest.XFLS_FechaFin__c = System.today().addDays(1);
   woliTest.EndDate =System.today().addDays(5);
        woliTest.XFLS_CodEdoAuto__c = '1';
        woliTest.XFLS_EstadoAuto__c = '1';
        woliTest.XFLS_FechaProcesadaInt__c = System.today();
        woliTest.XFLS_ProcesadaInterfaz__c = 1;
        woliTest.XFLS_CodigoInterfaz__c = '1';
        woliTest.XFLS_CodigoUserAutoriza__c = '1';
        woliTest.XFLS_EliminarOS__c = true;
        woliTest.XFLS_HorasProgramadas__c = 4;
        woliTest.Duration =30;
     woliTest.XFLS_TiempoEjecutado__c =1;
        woliTest.XFLS_HorasSuspendidas__c = 4;
         woliTest.XFLS_MotivoRechazo__c = 'prueba';
        insert woliTest;
        string idWoliTest = woliTest.Id;
  
        ServiceAppointment newSA = new ServiceAppointment();
        
        newSA.ParentRecordId =woliTest.id;
        newSA.XFLS_EsContigenciaCOVID19__c = '1';
        newSA.XFLS_Soportes__c = 1;
        newSA.XFLS_NecesidadesAdministrativas__c = 1;
        newSA.DueDate = System.today().addDays(5);
        newSA.EarliestStartTime = System.today().addDays(1);
        
                newSA.SchedStartTime =System.today().addDays(2);
        newSA.SchedEndTime =System.today().addDays(3);
        newSA.XFLS_TotalDeAsistentes__c = 1;
              
      
        //Campos para servicio Radicar Sesion Ejecutada
       newSA.Status = 'Reprogramar';
        newSA.XFLS_CodigoDeSesion__c = 1;
        newSA.XFLS_CodigoEstadoPed__c = '1';
        newSA.ParentRecordId__c = '1';
       newSA.XFLS_SinFecha__c = true;
       newSA.XFLS_MotReprogramacion__c = 'prueba motivo';
newSA.ActualDuration = 1500;
       newSA.XFLS_NumeroAsistentes__c =5;
newSA.XFLS_Observaciones__c ='test';
newSA.ActualStartTime=Datetime.newInstance(2022, 5, 31);
newSA.ActualEndTime=Datetime.newInstance(2022, 5, 31);
        insert newSA;
        
    } @istest
    public static void serviceAppointmentTestUpdateWorkOrder(){
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
        ServiceResource sr = new ServiceResource();
        sr.Name = 'TestService';
        sr.IsActive = true;
        sr.RelatedRecordId = testUser.Id;
        sr.XFLS_document__c = '12345';
        sr.XFLS_Email__c = 'emailtes00019t@test.com';
        insert sr;
        OperatingHours oph = new OperatingHours();
        oph.Name = 'oppHoursTest';
        insert oph;
        ServiceTerritory st = new ServiceTerritory();
        st.Name = 'Colombia';
        st.IsActive = true;
        st.OperatingHoursId = oph.Id;
        insert st;
        ServiceTerritoryMember stm = new ServiceTerritoryMember();
        stm.ServiceResourceId = sr.Id;
        stm.ServiceTerritoryId = st.Id;
        stm.OperatingHoursId = oph.Id;
        stm.EffectiveStartDate =((Datetime)JSON.deserialize('"2022-12-01T00:00:00.000Z"', Datetime.class))- 10;
        insert stm;
        
        	Id personAccountRecordTypeId =  Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId(); 
    	Account personal1 = new Account(RecordTypeId=personAccountRecordTypeId,
                                               PersonMobilePhone='55555',
                                               PersonEmail='emailconsulta@test.com',
                                               FirstName='Nombre',
                                               LastName='Apellido',
                                               Phone='55555',
                                               CS_NumeroIdentificacionCP__pc	= '11157575739',
                                               CS_TipoIdentificacionCP__pc		= '1'
                                               );
         INSERT personal1; 
        
         WorkOrder woTest = new WorkOrder();

        woTest.XFLS_FechaPublicacionOS__c = Datetime.newInstance(2022, 5, 31);
        woTest.XFLS_FechaAprobacionOS__c = Datetime.newInstance(2022, 5, 31);
        woTest.XFLS_CodigoOS__c = '1';
        woTest.XFLS_CodigoEstadoOS__c = '1';
        woTest.XFLS_CodigoEmpresa__c = '1';
        woTest.XFLS_Contrato__c = '1';
        woTest.XFLS_CodigoDIS__c = '1';
        woTest.XFLS_DIS__c = '1';
        woTest.XFLS_NOmbreDISAtendedor__c = 'Jose';
        woTest.XFLS_Actividad__c = '1';
        woTest.XFLS_CodigoDeActividadTecnica__c = '1';
        woTest.XFLS_TipoDeActividad__c = 'Test';
        woTest.XFLS_CodigoGrupo__c = '1';
        woTest.XFLS_CodigoSubGrupo__c = '1';
        woTest.XFLS_DescSubGrupo__c = 'Sub Grupo Test';
        woTest.XFLS_DescripcionGrupo__c = 'Grupo Test';
        woTest.XFLS_Cantidad__c = 1;
        woTest.Status = 'Suspendido';
        woTest.XFLS_Observaciones__c = 'Ninguna';
      woTest.XFLS_Consultor__c = sr.id;
        woTest.AccountId = personal1.id ;
         woTest.XFLS_VieneDeIntegracion__c = true;
        insert woTest;
        
        WorkOrderLineItem woliTest = new WorkOrderLineItem();
        woliTest.WorkOrderId = woTest.Id;
        woliTest.XFLS_CodigoOS__c = '1';
         woliTest.Status = 'Aceptada' ; 
         
        woliTest.XFLS_CodigoDeActividadTecnicaSAP__c = '1';
        //woliTest.XFLS_RealizadoPor__c = 'JOS';
        woliTest.XFLS_CodigoAutorizacion__c = '1';
       
        woliTest.XFLS_FechaRadicacion__c = System.today();
        woliTest.XFLS_FechaAutorizacion__c = System.today();
           woliTest.XFLS_FechaInicio__c =System.today().addDays(1);
           woliTest.StartDate =System.today().addDays(1);
         woliTest.XFLS_FechaFin__c = System.today().addDays(1);
   woliTest.EndDate =System.today().addDays(5);
        woliTest.XFLS_CodEdoAuto__c = '1';
        woliTest.XFLS_EstadoAuto__c = '1';
        woliTest.XFLS_FechaProcesadaInt__c = System.today();
        woliTest.XFLS_ProcesadaInterfaz__c = 1;
        woliTest.XFLS_CodigoInterfaz__c = '1';
        woliTest.XFLS_CodigoUserAutoriza__c = '1';
       
        woliTest.XFLS_HorasProgramadas__c = 4;
        woliTest.Duration =30;
     woliTest.XFLS_TiempoEjecutado__c =1;
        woliTest.XFLS_HorasSuspendidas__c = 4;
         woliTest.XFLS_MotivoRechazo__c = 'prueba';
        insert woliTest;
        woliTest.status = 'Completada';
         woliTest.XFLS_TiempoEjecutado__c =30;
        update woliTest;
            
    }
   
}