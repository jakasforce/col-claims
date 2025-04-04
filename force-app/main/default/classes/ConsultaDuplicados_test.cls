@isTest
public class ConsultaDuplicados_test {
    
    @isTest
	public static void crearCuentaPersonal() {
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
        
    	Account personal2 = new Account(RecordTypeId=personAccountRecordTypeId,
                                               PersonMobilePhone='55554',
                                               PersonEmail='emailconsulta2@test.com',
                                               FirstName='NombreDos',
                                               LastName='ApellidoDos',
                                               Phone='55555',
                                               CS_NumeroIdentificacionCP__pc	= '11157575738',
                                               CS_TipoIdentificacionCP__pc		= '1'
                                               );
        INSERT personal1; 
        INSERT personal2;
        
        Test.startTest();
        	ConsultaDuplicados.inicioDuplicados('CuentasPersonales');
        Test.stopTest();
        
    }
    
    @isTest
    public static void crearCuentaJuridico() {
        Id AccountRecordTypeId =  Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CS_Juridico').getRecordTypeId();
    	Account juridico1 = new Account(RecordTypeId=AccountRecordTypeId,
                                               //PersonMobilePhone='55554',
                                               //PersonEmail='juridicoconsulta1@test.com',
                                               Phone='9998999',
                                               Name='NombreTres',
                                               CS_NumeroIdentificacion__c	= '11157575737',
                                               CS_TipoIdentificacion__c		= '3'
                                               );
    
    	Account juridico2 = new Account(RecordTypeId=AccountRecordTypeId,
                                               //PersonMobilePhone='55554',
                                               //PersonEmail='juridicoconsulta2@test.com',
                                               Phone='9998899',
                                               Name='NombreCuatro',
                                               CS_NumeroIdentificacion__c	= '11157575736',
                                               CS_TipoIdentificacion__c		= '3'
                                               );
        INSERT juridico1; 
        INSERT juridico2;
        
        Test.startTest();
        	ConsultaDuplicados.inicioDuplicados('CuentasJuridicas');
        Test.stopTest();
    }
}