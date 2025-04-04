/*
* ===================================================================================
* @className        CS_GetUser_Test
* @description      Test of the classes  CS_GetUser and CS_QueubleUserACK.
* @author           JP
* @version          V0.1 
* @dateCreated      2022-11
* ===================================================================================*/ 
@isTest
class CS_GetUser_Test {
	@isTest
    static void getUserTest(){ 
        Test.setMock(HttpCalloutMock.class, new mockNewCP());
        CS_SmartSupervisionConstants__c cons= new CS_SmartSupervisionConstants__c();
        cons.CS_GetComplainsEndpoint__c='http://endpoint.com';
        cons.CS_GetFileEndpoint__c='http://endpoint.com';
        cons.CS_SmartSupervisionUsername__c='username';
        insert cons;
        Account cuent1= new account(
            FirstName = 'Juan',
            LastName = 'Prueba',
            CS_TipoIdentificacionCP__pc = '2',
            CS_NumeroIdentificacionCP__pc = '15256878965',
            Phone = '3194568899'
			            
        );
        insert cuent1; 
        id idQuejaSuper = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('CS_Queja_Superintendencia').getRecordTypeId();
        case c1 = new case(
            accountid = cuent1.id,
            CS_CodigoEntidad__c = 3,
            CS_EstadoQuejaReclamo__c = '1',
            recordtypeid = idQuejaSuper
        );
        insert c1;
        list<Case> casosEnc = [SELECT
							Id,
							CS_SuperintendenciaName__c,
							CS_SuperintendenciaFechaNacimiento__c,
							CS_SuperintendenciaEmail__c,
							CS_SuperintendenciaPhone__c,
							CS_SuperintendenciaRazonSocial__c,
							CS_SuperintendenciaAddress__c,
							CS_SuperintendenciaDepartamento__c,
                        	CS_SuperintendenciaMunicipio__c,
                        	CS_CodigoEntidad__c,
                        	Account.CS_NumeroIdentificacionCP__pc
						FROM Case
						WHERE
							CS_EstadoQuejaReclamo__c != '4'
                        	AND CS_CodigoEntidad__c = 3
                        	AND recordtypeid =: idQuejaSuper
							AND Account.CS_NumeroIdentificacionCP__pc = '15256878965'
						WITH SECURITY_ENFORCED];
        system.debug('lista cas' + casosEnc);
         test.startTest();
         CS_GetUser.getUserFuture('3');
         test.stopTest();
        //System.assertNotEquals(null, newAcc, 'No se creo la personAccount');        
    }
    
    private class mockNewCP implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            if(req.getEndpoint()=='callout:SmartSupervision/login/'){
                HttpResponse response = new HttpResponse();
                response.setHeader('Content-Type', 'application/json');
                response.setBody('{"refresh":"refresh1234", "access":"access456"}');
                response.setStatusCode(200);
                response.setStatus('Success');
                return response;               
            }else{
                HttpResponse response = new HttpResponse();
                response.setHeader('Content-Type', 'application/json');
                CS_WrapperSmartSupervision.GetUsersResponseType res= new CS_WrapperSmartSupervision.GetUsersResponseType();
                res.count=1;
                res.pages=1;
                res.current_page=1;
                res.next='next';
                res.previous='previous';
                CS_WrapperSmartSupervision.GetUserResponseType com= new CS_WrapperSmartSupervision.GetUserResponseType();
                List<CS_WrapperSmartSupervision.GetUserResponseType> lstcom= new List<CS_WrapperSmartSupervision.GetUserResponseType>();
                com.numero_id_CF='15256878965';
                com.tipo_id_CF='1';
                com.nombre='Juan';
                com.apellido='Prueba';
                com.fecha_nacimiento='1997-05-26';
                com.correo='prueba@prueba.com';
                com.telefono='6478888';
                com.razon_social=null;
                com.direccion='Direccion Prueba';
                com.departamento_cod='11';
                com.municipio_cod='11001';
                lstcom.add(com);
                res.results=lstcom;
                response.setBody(JSON.serialize(res));
                response.setStatusCode(200);
                response.setStatus('Success');
                return response;   
            } 
        }
	}
    
}