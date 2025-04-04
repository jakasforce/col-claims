@isTest
public class ConsultIvrAPI_tst {
    @isTest
    static void cuentaPersonal() {

    Id personAccountRecordTypeId =  Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId(); 
    Account personal1 = new Account(RecordTypeId=personAccountRecordTypeId,
                                    PersonMobilePhone='123456',
                                    PersonEmail='emailconsulta@test.com',
                                    FirstName='Nombre',
                                    LastName='Apellido',
                                    Phone='3114343434',
                                    CS_NumeroIdentificacionCP__pc	= '111222333876',
                                    CS_TipoIdentificacionCP__pc		= '1'
                                    );

    INSERT personal1;

    String tipoIdentificacion = '1';
	String numeroIdentificacion = '111222333876';

    String endpoint = '/services/apexrest/consultivr/info';

    RestRequest request = new RestRequest();
    request.requestURI = endpoint;
    request.httpMethod = 'GET';
    request.addParameter('documentType', tipoIdentificacion);
	request.addParameter('documentNumber', numeroIdentificacion);
    RestContext.request = request;
    RestContext.response = new RestResponse();

    Test.startTest();
    ConsultIvrAPI.info();
    Test.stopTest();

        
    RestResponse response = RestContext.response;
        
    String jsonResponse = response.responseBody.toString();
    System.debug('@@@response'+jsonResponse);
    }
    @isTest
    static void cuentaJuridica() {

        Id AccountRecordTypeId =  Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CS_Juridico').getRecordTypeId();
        Account juridico1 = new Account(RecordTypeId=AccountRecordTypeId,
                                                   Phone='9998999',
                                                   Name='NombreTres',
                                                   CS_NumeroIdentificacion__c	= '11157575737',
                                                   CS_TipoIdentificacion__c		= '3'
                                                   );

        INSERT juridico1;

        String tipoIdentificacion = '3';
	    String numeroIdentificacion = '11157575737';

        String endpoint = '/services/apexrest/consultivr/info';

        RestRequest request = new RestRequest();
        request.requestURI = endpoint;
        request.httpMethod = 'GET';
        request.addParameter('documentType', tipoIdentificacion);
	    request.addParameter('documentNumber', numeroIdentificacion);
        RestContext.request = request;
        RestContext.response = new RestResponse();

        Test.startTest();
        ConsultIvrAPI.info();
        Test.stopTest();


        RestResponse response = RestContext.response;
        
        String jsonResponse = response.responseBody.toString();
        System.debug('@@@response'+jsonResponse);
    }
    @isTest
    static void cuentaNull() {

        String tipoIdentificacion = '';
	    String numeroIdentificacion = '';

        String endpoint = '/services/apexrest/consultivr/info';

        RestRequest request = new RestRequest();
        request.requestURI = endpoint;
        request.httpMethod = 'GET';
        request.addParameter('documentType', tipoIdentificacion);
	    request.addParameter('documentNumber', numeroIdentificacion);
        RestContext.request = request;
        RestContext.response = new RestResponse();

        Test.startTest();
        ConsultIvrAPI.info();
        Test.stopTest();


        RestResponse response = RestContext.response;

        String jsonResponse = response.responseBody.toString();
        System.debug('@@@response'+jsonResponse);
    }

    @isTest
    static void cuentaNoExiste() {

        String tipoIdentificacion = '3';
	    String numeroIdentificacion = '122212121212121212';

        String endpoint = '/services/apexrest/consultivr/info';

        RestRequest request = new RestRequest();
        request.requestURI = endpoint;
        request.httpMethod = 'GET';
        request.addParameter('documentType', tipoIdentificacion);
	    request.addParameter('documentNumber', numeroIdentificacion);
        RestContext.request = request;
        RestContext.response = new RestResponse();

        Test.startTest();
        ConsultIvrAPI.info();
        Test.stopTest();


        RestResponse response = RestContext.response;

        String jsonResponse = response.responseBody.toString();
        System.debug('@@@response'+jsonResponse);
    }

    @isTest
    static void participante() {

    Id personAccountRecordTypeId =  Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId(); 
    Account personal1 = new Account(RecordTypeId=personAccountRecordTypeId,
                                               PersonMobilePhone='123456',
                                               PersonEmail='emailconsulta@test.com',
                                               FirstName='Nombre',
                                               LastName='Apellido',
                                               Phone='3114343434',
                                               CS_NumeroIdentificacionCP__pc	= '111222333888',
                                               CS_TipoIdentificacionCP__pc		= '1'
                                               );

    INSERT personal1;
        
    Id AccountRecordTypeId =  Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CS_Juridico').getRecordTypeId();
        Account juridico1 = new Account(RecordTypeId=AccountRecordTypeId,
                                                   Phone='9998999',
                                                   Name='NombreTres',
                                                   CS_NumeroIdentificacion__c	= '11157575711',
                                                   CS_TipoIdentificacion__c		= '3'
                                                   );

    INSERT juridico1;
    
    Id claimAt = Schema.SObjectType.Claim.getRecordTypeInfosByDeveloperName().get('CS_AT').getRecordTypeId();
    Claim reclamo = new Claim(RecordTypeId=claimAt,name='12378998',AccountId=personal1.Id);
    INSERT reclamo;
        
    Id claimCS = Schema.SObjectType.Claim.getRecordTypeInfosByDeveloperName().get('CS_Siniestro').getRecordTypeId();
    Claim reclamo2 = new Claim(RecordTypeId=claimCS,name='12378998',AccountId=juridico1.Id);
    INSERT reclamo2;

    Id poliz = Schema.SObjectType.InsurancePolicy.getRecordTypeInfosByDeveloperName().get('CS_Contrato_ARL').getRecordTypeId();
    InsurancePolicy poliza = new InsurancePolicy(RecordTypeId=poliz,Name='1232423423',NameInsuredId=juridico1.Id); 
    INSERT poliza; 

    InsurancePolicy poliza2 = new InsurancePolicy(RecordTypeId=poliz,Name='1232423424',NameInsuredId=personal1.Id); 
    INSERT poliza2;

    InsurancePolicyParticipant participant = new InsurancePolicyParticipant(Role='Empleador',InsurancePolicyId=poliza.Id,PrimaryParticipantAccountId=personal1.Id);
    INSERT participant;
	
    String tipoIdentificacion = '1';
	String numeroIdentificacion = '111222333888';

    String endpoint = '/services/apexrest/consultivr/info';

    RestRequest request = new RestRequest();
    request.requestURI = endpoint;
    request.httpMethod = 'GET';
    request.addParameter('documentType', tipoIdentificacion);
	request.addParameter('documentNumber', numeroIdentificacion);
    RestContext.request = request;
    RestContext.response = new RestResponse();

    Test.startTest();
    
    ConsultIvrAPI.info();
    Test.stopTest();

        
    RestResponse response = RestContext.response;
        
    String jsonResponse = response.responseBody.toString();
    }
}