/*****************************************************************************************************************************
 * Apex Class Name	:	CS_CaseTriggerHandler_test
 * Version			:	1.0
 * Created Date	    :	20/09/2022
 * Function 		: 	Prueba el funcionamiento de la clase CS_CaseTriggerHandler
 * Test Class		:	???
 *----------------------------------------------------------------------------------------------------------------------------
 *                                                MODIFICATION LOG
 *----------------------------------------------------------------------------------------------------------------------------
 * Developer		     	Date			   	Description
 * ---------------------------------------------------------------------------------------------------------------------------
 * Fernanda Villafaña           20/09/2022          Original Version
 * Diego Caneda					09/03/2023			Modificación para cobertura y eliminación de counters.
 *****************************************************************************************************************************/
@isTest 
public class CS_CaseTriggerHandler_test {
    @testSetup
    static void setup(){
        account ACC= CS_TestDataFactory.createPersonAccount(true);
        Entitlement ent = new Entitlement(Name='ans consulta', AccountId=ACC.Id, 
        StartDate=Date.valueof(System.now().addDays(-2)), EndDate=Date.valueof(System.now().addYears(2)));
        insert ent;
        Map<Schema.SObjectField, Object> mapCase= new Map<Schema.SObjectField, Object>();
        mapCase.put(Case.CS_Subtipo__c, '2');
        mapCase.put(Case.CS_MacroMotivo__c, 'Defensor del consumidor SV');
        mapCase.put(Case.CS_Submotivo__c, 'Novedades');
        mapCase.put(Case.Status, 'Nuevo');
        mapCase.put(Case.CS_FechaTentativaDeCierre__c, date.Today());
        Case caso= CS_TestDataFactory.createCase(mapCase, true);
        CS_ProcesoAtencion__c pa= new CS_ProcesoAtencion__c();
        pa.CS_MacroMotivo__c='Defensor del consumidor SV';
        pa.CS_Submotivo__c='Novedades';
        pa.CS_Subtipo__c='2';
        insert pa;
        CS_PasosAtencion__c paAt= new CS_PasosAtencion__c();
        paAt.CS_ProcesoAtencion__c=pa.Id; 
        paAt.Name='111111';
        paAt.CS_Tiempoatencion__c=3;
    	insert paAt;

    }
    @isTest
    static void caseConAsignacion(){
        Case caso=[SELECT Id FROM Case LIMIT 1];    
        CS_AsginacionPasosAtencion__c paso= new CS_AsginacionPasosAtencion__c();
        paso.CS_CasoRelacionado__c=Caso.Id;
        paso.CS_Tiempo_de_AtencionN__c=1;
        paso.CS_Estado__c='Iniciado';
        paso.CS_AsignacionFlujoSecundario__c=false;
        insert paso;
        update caso;
        List <CS_AsginacionPasosAtencion__c> lst= [SELECT ID FROM CS_AsginacionPasosAtencion__c WHERE CS_CasoRelacionado__c=:caso.Id];
        System.debug('lst con asignación: ' + lst);
        System.assertEquals(1, lst.size(), 'Se asignaron pasos de atención a pesar de que el caso ya tenía previamente');
        
    }
    @isTest
    Static void caseSinAsignacion(){
        List<Case> listCaseTest = [Select Id,RecordType.DeveloperName,CS_Subtipo__c,CS_MacroMotivo__c,CS_Submotivo__c, Status, CS_FechaTentativaDeCierre__c FROM Case];
        system.debug('listCaseTest: ' + listCaseTest);
        Case caso=[SELECT Id, CS_Subtipo__c,CS_MacroMotivo__c,CS_Submotivo__c, Status, CS_FechaTentativaDeCierre__c FROM Case LIMIT 1]; 
        update caso;
		List <CS_AsginacionPasosAtencion__c> lst= [SELECT ID FROM CS_AsginacionPasosAtencion__c WHERE CS_CasoRelacionado__c=:caso.Id];
        System.debug('lst sin asignación: ' + lst);
        System.assertEquals(0, lst.size(), 'No se asignaron los pasos de atención');
    }
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
         insert casop;

		CS_AsginacionPasosAtencion__c paso2= new CS_AsginacionPasosAtencion__c();
        paso2.CS_CasoRelacionado__c=casop.Id;
        paso2.CS_Tiempo_de_AtencionN__c=8;
        paso2.CS_Estado__c='Iniciado';
        paso2.CS_AsignacionFlujoSecundario__c=false;
        paso2.CS_ProcesoAtencion__c = pa2.Id;
        paso2.CS_PasoAtencionId__c = paAt2.Id;
        insert paso2;
        
        List <CS_AsginacionPasosAtencion__c> lst= [SELECT Id,CS_ProcesoAtencion__c,CS_PasoAtencionId__c FROM CS_AsginacionPasosAtencion__c WHERE CS_CasoRelacionado__c=:casop.Id];
        System.debug('lst pasos: ' + lst);
        
    }
}