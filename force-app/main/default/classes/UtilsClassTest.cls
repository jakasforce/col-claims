@isTest
public class UtilsClassTest {
    @isTest
    static void testRedistributeLeads() {
        // Buscar una cola válida (puedes ajustar el criterio de búsqueda según tus necesidades)
        Group queue = [SELECT Id FROM Group WHERE Type = 'Queue'  AND Id IN (SELECT QueueId FROM QueueSobject WHERE SobjectType = 'Lead') LIMIT 1];
        
        if (queue != null) {
            // Crea algunos leads ficticios y asigna la cola como propietaria
            Lead lead1 = new Lead(
                Firstname = 'lead',
                LastName = 'Lead1',
                Company = 'lead Lead1',
                Email = 'prueba1@gmail.com',
                Numero_de_documento__c = '987541245',
                Tipo_de_documento__c = '3',
                Phone = '6012345671',
                OwnerId = queue.Id
            );
            
            Lead lead2 = new Lead(
                Firstname = 'lead',
                LastName = 'Lead2',
                Company = 'lead Lead2',
                Email = 'prueba2@gmail.com',
                Numero_de_documento__c = '987541246',
                Tipo_de_documento__c = '3',
                Phone = '6012345672',
                OwnerId = queue.Id
            );
            
            Lead lead3 = new Lead(
                Firstname = 'lead',
                LastName = 'Lead3',
                Company = 'lead Lead3',
                Email = 'prueba3@gmail.com',
                Numero_de_documento__c = '987541247',
                Tipo_de_documento__c = '3',
                Phone = '6012345673',
                OwnerId = queue.Id
            );
            
            Test.startTest();
            insert new List<Lead>{lead1, lead2, lead3};
                Test.stopTest();
        } else {
            System.debug('No se encontró una cola de tipo "Queue". Asegúrate de que haya una cola válida en tu org.');
        }
    }
    
    @isTest
    static void testDistributeLeads() {
        Profile pf = [SELECT Id FROM Profile WHERE Name LIKE '%Admin%' LIMIT 1];
        List<Lead> testLeads = new List<Lead>();
        for (Integer i = 0; i < 3; i++) {
            testLeads.add(new Lead(
                FirstName = 'Lead',
                LastName = 'Test' + i,
                Company = 'Lead Test' + i,
                Email = 'test' + i + '@example.com',
                Phone = '601234567' + i,
                Numero_de_documento__c = '98754124' + i,
                Tipo_de_documento__c = '3'
            ));
        }
        insert testLeads;
        
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'testuser@example.com',
            Username = 'testusercrmcolmena@example.com',
            Alias = 'TUser',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId = pf.Id
        );
        insert testUser;
        
        User testUser2 = new User(
            FirstName = 'Test',
            LastName = 'User2',
            Email = 'testuser2@example.com',
            Username = 'testusercrmcolmena2@example.com',
            Alias = 'TUser',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId = pf.Id
        );
        insert testUser2;
        
        List<Id> leadIds = new List<Id>();
        for (Lead lead : testLeads) {
            lead.OwnerId = testUser.Id;
            leadIds.add(lead.Id);
        }
        update testLeads;
        
        Test.startTest();
        UtilsClass.distribuir(testLeads, new List<Id>{testUser.Id,testUser2.Id});
        Test.stopTest();
    }

}