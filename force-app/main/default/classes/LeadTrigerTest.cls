@isTest
public class LeadTrigerTest {
    @isTest
    static void insertar(){
        Lead lead1 = new Lead(Firstname='lead',LastName='Lead1', Company='lead Lead1', email='prueba1@gmail.com', Numero_de_documento__c='987541245',Tipo_de_documento__c='3',Phone='6012345678');
        Test.startTest();
        insert lead1;
        Test.stopTest();
    }
    @isTest
    static void actualizar(){
        Lead lead1 = new Lead(Firstname='lead',LastName='Lead1', Company='lead Lead1', email='prueba1@gmail.com', Numero_de_documento__c='987541277',Tipo_de_documento__c='3',Phone='6012345678');
        insert lead1;
        Lead lead2 = [Select id,Firstname from lead limit 1];
        lead2.FirstName = 'nombre cambiado';
        lead2.Company 	= 'nombre cambiado Lead1';
        Test.startTest();
        update lead2;
        Test.stopTest();
    }
    @isTest
    static void eliminar(){
        Lead lead1 = new Lead(Firstname='lead',LastName='Lead1', Company='lead Lead1', email='prueba1@gmail.com', Numero_de_documento__c='987541288',Tipo_de_documento__c='3',Phone='6012345678');
        insert lead1;
        Lead lead3 = [Select id,Firstname from lead limit 1];
        Test.startTest();
        delete lead3;
        Test.stopTest();
    }
}