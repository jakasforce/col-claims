/***************************************************************************************************************************
 * Nombre de la Clase Apex : CS_ClaimUtilsInvocable_Test
 * Versión                 : 1.0
 * Fecha de Creación       : 19/07/2024
 * Funcionalidad           : Generación de datos para pruebas para clase CS_ClaimUtilsInvocable
 *--------------------------------------------------------------------------------------------------------------------------
 **************************************************************************************************************************/
@isTest
public class CS_ClaimUtilsInvocable_Test {
    @isTest
	static void queueWithUser(){
        Group testGroup = new Group(Name='test group', type='Queue');
        insert testGroup;
        System.runAs(new User(Id=UserInfo.getUserId()))
        {
            QueuesObject testQueue = new QueueSObject(QueueID = testGroup.id, SObjectType = 'Case');
            insert testQueue;
            groupMember gp = new groupMember(groupId = testGroup.Id,UserOrGroupId =UserInfo.getUserId() );
        	insert gp;
        }
        
        Id CasoRecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByName().get('Gestión de Operaciones').getRecordTypeId();
        Case caso = new case(status = 'Abierto', Priority = 'Medio', Subject = 'Prueba',Description = 'Prueba test',RecordTypeId = CasoRecordTypeId);
        insert caso;
        list<Case> lstCaso = new list<Case>();
        lstCaso.add(caso);
        CS_ClaimUtilsInvocable.request req = new CS_ClaimUtilsInvocable.request();
        List<CS_ClaimUtilsInvocable.request> ListReq = new List<CS_ClaimUtilsInvocable.request>();
        List<CS_ClaimUtilsInvocable.response> ListResp = new List<CS_ClaimUtilsInvocable.response>();
        req.records = lstCaso;
        req.stringFormat = 'test_group';
        req.action = 1;
        ListReq.add(req);
        test.startTest();
        ListResp = CS_ClaimUtilsInvocable.execute(ListReq);
        System.assert(!String.isBlank(string.valueof(ListResp[0].stringValue)),'Ejecución realizada adecuadamente');
        test.stopTest();
        
    }
    @isTest
	static void queueWithoutUser(){
        Group testGroup = new Group(Name='test group', type='Queue');
        insert testGroup;
        System.runAs(new User(Id=UserInfo.getUserId()))
        {
            QueuesObject testQueue = new QueueSObject(QueueID = testGroup.id, SObjectType = 'Case');
            insert testQueue;
        }
       
        Id CasoRecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByName().get('Gestión de Operaciones').getRecordTypeId();
        Case caso = new case(status = 'Abierto', Priority = 'Medio', Subject = 'Prueba',Description = 'Prueba test',RecordTypeId = CasoRecordTypeId);
        insert caso;
        list<Case> lstCaso = new list<Case>();
        lstCaso.add(caso);
        CS_ClaimUtilsInvocable.request req = new CS_ClaimUtilsInvocable.request();
        List<CS_ClaimUtilsInvocable.request> ListReq = new List<CS_ClaimUtilsInvocable.request>();
        List<CS_ClaimUtilsInvocable.response> ListResp = new List<CS_ClaimUtilsInvocable.response>();
        req.records = lstCaso;
        req.stringFormat = 'test_group';
        req.action = 1;
        ListReq.add(req);
        test.startTest();
        
        ListResp = CS_ClaimUtilsInvocable.execute(ListReq);
        System.assert(!String.isBlank(string.valueof(ListResp[0].stringValue)),'Ejecución realizada adecuadamente');
        test.stopTest();
        
    }

}