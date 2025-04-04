/********************************************************************
Apex Class Name	:	XFLS_WorkOrderTrigger_Test
Version			:	1.0
Created Date	:	30/05/2022
Function 		: 	

Modification Log
*--------------------------------------------------------------------
* Developer		     	Date			   	Description
* -------------------------------------------------------------------
* José Quevedo   	 30/05/2022	        Original Version
*********************************************************************/

@istest
public class XFLS_WorkOrderTrigger_Test {
    
    @testsetup
    public static void setup(){
        Contact objCont = new Contact();
        objCont.FirstName = 'Jose';
        objCont.LastName = 'Quevedo';
        //objCont.AccountId = '0015200000tYuJCAA0';
        objCont.Phone = '999999999';
        objCont.Email = 'tester56@test.com';
   		
        insert objCont;
    }
    
    @istest
    public static void workOrderTest(){
        List <WorkOrder> lstWO = new List <WorkOrder>();
        
        Contact objCont = [SELECT Id FROM Contact WHERE lastName = 'Quevedo' LIMIT 1];
        
        
        WorkOrder woTest1 = new WorkOrder();
        woTest1.XFLS_FechaPublicacionOS__c = Datetime.newInstance(2022, 5, 31);
        woTest1.XFLS_FechaAprobacionOS__c = Datetime.newInstance(2022, 5, 31);
        woTest1.XFLS_CodigoOS__c = '1';
        woTest1.XFLS_CodigoEstadoOS__c = '1';
        woTest1.XFLS_CodigoEmpresa__c = '1';
        woTest1.XFLS_Contrato__c = '1';
        woTest1.XFLS_CodigoDIS__c = '1';
        woTest1.XFLS_DIS__c = '1';
        woTest1.XFLS_NOmbreDISAtendedor__c = 'Jose';
        woTest1.Status = 'Aceptada';
        woTest1.ContactId = objCont.Id;
        woTest1.XFLS_CedulaConsultor__c = '1110515651';
        woTest1.XFLS_Consultor__c = '0Hn8F000000L2MLSA0';

        lstWO.add(woTest1);
        
        Test.startTest();
        //insert lstWO;
        Test.stopTest();  
        
    }

}