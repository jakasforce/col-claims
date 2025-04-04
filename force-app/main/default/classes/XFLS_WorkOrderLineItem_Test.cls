/********************************************************************
Apex Class Name	:	XFLS_WorkOrderLineItem_Test
Version			:	1.0
Created Date	:	01/06/2022
Function 		: 	

Modification Log
*--------------------------------------------------------------------
* Developer		     	Date			   	Description
* -------------------------------------------------------------------
* José Quevedo   	 01/06/2022	        Original Version
*********************************************************************/
@istest
public class XFLS_WorkOrderLineItem_Test {
    
	   
    @testsetup
    public static void setup(){        
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
        woTest.Status = 'Nueva';
        
        insert woTest;
    }
    
    
    @istest
    public static void workOrderLineItemTest(){        
        List <WorkOrderLineItem> lstWOLI = new List <WorkOrderLineItem>();
        
        WorkOrder woTest = [SELECT Id, XFLS_NOmbreDISAtendedor__c, Status FROM WorkOrder WHERE XFLS_NOmbreDISAtendedor__c = 'Jose' AND Status = 'Nueva'];
        
        
        WorkOrderLineItem woliTest = new WorkOrderLineItem();
        woliTest.WorkOrderId = woTest.Id;
        woliTest.XFLS_CodigoOS__c = '1';
        //woliTest.XFLS_CodigoDeActividad__c = '1';
        //woliTest.XFLS_CodigoDeActividadTecnica__c = '1';
        woliTest.XFLS_CodigoDeActividadTecnicaSAP__c = '1';
        //woliTest.XFLS_TipoDeActividad__c = 'Test';
        //woliTest.XFLS_CodigoGrupo__c = '1';
        //woliTest.XFLS_CodigoSubGrupo__c = '1';
        //woliTest.XFLS_DescSubGrupo__c = 'Sub Grupo Test';
        //woliTest.XFLS_DescripcionGrupo__c = 'Grupo Test';
        woliTest.XFLS_CodigoAutorizacion__c = '1';
        //woliTest.XFLS_Cantidad__c = 1;
        woliTest.Status = 'Aceptada';
        woliTest.XFLS_FechaRadicacion__c = System.today();
        woliTest.XFLS_FechaAutorizacion__c = System.today();
        woliTest.XFLS_CodEdoAuto__c = '1';
        woliTest.XFLS_EstadoAuto__c = '1';
        //woliTest.XFLS_Observaciones__c = 'Ninguna';
        woliTest.XFLS_FechaProcesadaInt__c = System.today();
        woliTest.XFLS_ProcesadaInterfaz__c = 1;
        woliTest.XFLS_CodigoInterfaz__c = '1';
        woliTest.XFLS_CodigoUserAutoriza__c = '1';
        
        Test.startTest();
        insert woliTest;
        
		WorkOrderLineItem woliUpdate = [SELECT Id, Status FROM WorkOrderLineItem WHERE Status = 'Aceptada' LIMIT 1];
		woliUpdate.Status = 'Completada';
        update woliUpdate;
        Test.stopTest();       
    }
	
}