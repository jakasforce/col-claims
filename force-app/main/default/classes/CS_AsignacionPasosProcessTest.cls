@isTest
public class CS_AsignacionPasosProcessTest {
    
    /*@isTest
	static void tesTProcesoAsignacion() {
        CS_ProcesoAtencion__c proceso = new CS_ProcesoAtencion__c();
        proceso.CS_Subtipo__c = '2';
        proceso.CS_Submotivo__c = 'Reclamo comunicaciones';
        proceso.CS_MacroMotivo__c = 'Servicio';
        proceso.CS_TiempoGlobalAtencion__c = 15;
		insert proceso;
        CS_PasosAtencion__c paso = new CS_PasosAtencion__c();
        paso.Name = 'Paso 1 Test';
        paso.CS_Tiempoatencion__c = 5;
        paso.CS_ProcesoAtencion__c = proceso.Id;
        insert paso;
        CS_PasosAtencion__c paso2 = new CS_PasosAtencion__c();
        paso2.Name = 'Paso 2 Test';
        paso2.CS_Tiempoatencion__c = 5;
        paso2.CS_ProcesoAtencion__c = proceso.Id;
        insert paso2;
        CS_PasosAtencion__c paso3 = new CS_PasosAtencion__c();
        paso3.Name = 'Paso 3 Test';
        paso3.CS_Tiempoatencion__c = 5;
        paso3.CS_ProcesoAtencion__c = proceso.Id;
        insert paso3;
        Case oneCase = new Case();
        oneCase.Type = 'Problem';
        oneCase.Origin = '2';
        oneCase.Status = 'Nuevo';
        oneCase.CS_Pais__c = '484';
        oneCase.CS_ProductoM2__c = '124';
        oneCase.CS_ProductoColmenaM2__c = 'Accidentes Personales';
        oneCase.CS_Subtipo__c = '2';
        oneCase.CS_PasosCompletados__c = true;
        oneCase.CS_MacroMotivo__c = 'Servicio';
        oneCase.CS_Submotivo__c = 'Reclamo comunicaciones';
        Test.startTest();
        insert oneCase;
        CS_AsginacionPasosAtencion__c asignacion = [Select Id,CS_Estado__c From CS_AsginacionPasosAtencion__c LIMIT 1];
        asignacion.CS_Estado__c = 'Completado';
        update asignacion;
        Test.stopTest();
    }*/
    /*
     *@autor: Diego Caneda Se creo el método para la cobertura de la clase CS_AsignacionPasosHandlerTrigger para eliminar los counters
	 * y obtner la cobertura correcta para la clase.
     */
    @isTest
    static void casePasosAtencion(){
        Id recordTypeCaseId =Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CS_Incidente').getRecordTypeId();
        Id recordTypeCuentaId =Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CS_Juridico').getRecordTypeId();
        
        Account cuenta = new Account(
            Name = 'cuenta',
            RecordTypeId = recordTypeCuentaId
        );
        insert cuenta;
        
        CS_ProcesoAtencion__c pa2= new CS_ProcesoAtencion__c();
        pa2.CS_MacroMotivo__c='Interna - Incidencia SV';
        pa2.CS_Submotivo__c='Error linea efectiva';
        pa2.CS_Subtipo__c='2';
        pa2.CS_Tipo_de_caso__c = 'CS_Incidente';
        insert pa2;
        CS_PasosAtencion__c paAt2= new CS_PasosAtencion__c();
        paAt2.CS_ProcesoAtencion__c=pa2.Id; 
        paAt2.Name='Paso 1';
        paAt2.CS_Tiempoatencion__c=8;
    	insert paAt2;
        CS_PasosAtencion__c paAt3= new CS_PasosAtencion__c();
        paAt3.CS_ProcesoAtencion__c=pa2.Id; 
        paAt3.Name='Paso 2';
        paAt3.CS_Tiempoatencion__c=8;
    	insert paAt3;
        CS_PasosAtencion__c paAt4= new CS_PasosAtencion__c();
        paAt4.CS_ProcesoAtencion__c=pa2.Id; 
        paAt4.Name='Paso 2';
        paAt4.CS_Tiempoatencion__c=8;
    	insert paAt4;
        
        Case casop = new Case(
            RecordTypeId = recordTypeCaseId,
            AccountId = cuenta.Id,
            CS_Subtipo__c = '2',
            CS_Pais__c = '170',
            Status = 'Nuevo',
            CS_Canal__c = '6',
            CS_Departamento__c = '91',
            CS_Municipio__c = '91263',
            CS_ProductoM2__c = '121',
            CS_MacroMotivo__c = 'Interna - Incidencia SV',
            CS_Submotivo__c = 'Error linea efectiva',
            CS_FechaTentativaDeCierre__c = Date.today().addDays(10)
        );
        Test.startTest();
        insert casop;
		CS_AsginacionPasosAtencion__c paso2= new CS_AsginacionPasosAtencion__c();
        paso2.CS_CasoRelacionado__c=casop.Id;
        paso2.CS_Tiempo_de_AtencionN__c=8;
        paso2.CS_Estado__c='Iniciado';
        paso2.CS_AsignacionFlujoSecundario__c=false;
        paso2.CS_ProcesoAtencion__c = pa2.Id;
        paso2.CS_PasoAtencionId__c = paAt2.Id;
        insert paso2;
        CS_AsginacionPasosAtencion__c asignacion = [Select Id,CS_Estado__c From CS_AsginacionPasosAtencion__c WHERE CS_CasoRelacionado__c=:casop.Id LIMIT 1];
        System.debug('asignacion: ' + asignacion);
        asignacion.CS_Estado__c = 'Completado';
        update asignacion;        
        Test.stopTest();
    }
    public static testMethod void testschedule() {
        CS_ProcesoAtencion__c proceso = new CS_ProcesoAtencion__c();
        proceso.CS_Subtipo__c = '2';
        proceso.CS_Submotivo__c = 'Reclamo comunicaciones';
        proceso.CS_MacroMotivo__c = 'Servicio';
        proceso.CS_TiempoGlobalAtencion__c = 3;
		insert proceso;
        CS_PasosAtencion__c paso = new CS_PasosAtencion__c();
        paso.Name = 'Paso 1 Test';
        paso.CS_Tiempoatencion__c = 1;
        paso.CS_ProcesoAtencion__c = proceso.Id;
        insert paso;
        CS_PasosAtencion__c paso2 = new CS_PasosAtencion__c();
        paso2.Name = 'Paso 2 Test';
        paso2.CS_Tiempoatencion__c = 1;
        paso2.CS_ProcesoAtencion__c = proceso.Id;
        insert paso2;
        CS_PasosAtencion__c paso3 = new CS_PasosAtencion__c();
        paso3.Name = 'Paso 3 Test';
        paso3.CS_Tiempoatencion__c = 1;
        paso3.CS_ProcesoAtencion__c = proceso.Id;
        //insert paso3;
        Case oneCase = new Case();
        oneCase.Type = 'Problem';
        oneCase.Origin = '2';
        oneCase.Status = 'Nuevo';
        oneCase.CS_Pais__c = '484';
        oneCase.CS_ProductoM2__c = '124';
            oneCase.CS_ProductoColmenaM2__c = 'Accidentes Personales';
        oneCase.CS_Subtipo__c = '2';
        oneCase.CS_PasosCompletados__c = true;
        oneCase.CS_MacroMotivo__c = 'Servicio';
        oneCase.CS_Submotivo__c = 'Reclamo comunicaciones';
        insert oneCase;
       paso.CS_Tiempoatencion__c = 0;
        update paso;
		Test.StartTest();
        CS_PasoAtrasadoSchedule sh1 = new CS_PasoAtrasadoSchedule();
		String sch = '0 0 23 * * ?'; 
        system.schedule('Test Territory Check', sch, sh1); 
        Test.stopTest();
    }

}