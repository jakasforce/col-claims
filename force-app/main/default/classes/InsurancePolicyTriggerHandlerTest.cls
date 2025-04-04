/********************************************************************
Apex Class Name	:	InsurancePolicyTriggerHandlerTest
Version			:	1.0
Created Date	:	25/09/2022
Coverage        :   85%

Modification Log
*--------------------------------------------------------------------
* Developer		     	Date			   	Description
* -------------------------------------------------------------------
* Alejandro Giraldo  	 25/09/2022	       			Original Version
*********************************************************************/
@isTest
public class InsurancePolicyTriggerHandlerTest {

      @isTest
    static void insertInsurancePolicy(){
                         Id devRecordTypeIdAcc = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();

        Account    objCon1 = new account(SHIPPINGCOUNTRY = '170',CS_NUMEROIDENTIFICACIONCP__PC = '1098741907',CS_SEXO__PC = '2',SUFFIX = 'beltran',SHIPPINGCITY = '11001',
                                         CS_TRATAMIENTODATOS__C = false,RECORDTYPEID =devRecordTypeIdAcc ,FIRSTNAME = 'mario',SHIPPINGSTATE = '11',PHONE = '7573927',PERSONEMAIL = 'notiene@correo.com',
                                         CS_CLIENTEACTIVO__C = true,CS_TIPOIDENTIFICACIONCP__PC = '1',MIDDLENAME = 'alberto', LASTNAME = 'perez',PERSONMOBILEPHONE = '0'
            
             
            );
        insert objCon1;

                  Id policyId = Schema.SObjectType.InsurancePolicy.getRecordTypeInfosByDeveloperName().get('CS_Seguro_de_vida').getRecordTypeId();
 Map<Schema.SObjectField, Object> mapProduct2 = new Map<Schema.SObjectField, Object>();
        mapProduct2.put(Product2.Name, 'Desempleo');
        mapProduct2.put(Product2.Family, '24');
        mapProduct2.put(Product2.CS_Producto_M2__c, '121');
        mapProduct2.put(Product2.CS_Producto_Colmena_M2__c, 'Desempleo Individual');
        mapProduct2.put(Product2.CS_Estrategia_M2__c, '14');
        Product2 prod = CS_TestDataFactory.createProduct(mapProduct2, true);
        
         InsurancePolicy    objCon = new InsurancePolicy(
              UniversalPolicyNumber = '50249-1856',CS_ProductoVT__c = '30249',
             CS_NumeroPolizaVisualTime__c = '30249',PolicyType = 'PC',
             RecordTypeId = policyId ,Status = 'Activo',PremiumFrequency='Mensual',
             CS_asesorVenta__c = '22810844',CS_sucursalVenta__c = '3004',CS_medioRecaudo__c = 'Tarjeta de credito',
             RenewalChannel = 'Corredores',CS_Intermediario__c = '901565242',SourceSystem = 'VT',
             CS_RazonSocial__c = 'SOLUCIONES TERCERIZADAS S.A.S.',Name = '30249-1856',
             ProductId =Prod.id, NameInsuredId = objCon1.id
             
            );
        insert objCon;
        Id devRecordTypeId = Schema.SObjectType.InsurancePolicyParticipant.getRecordTypeInfosByDeveloperName().get('CS_Asegurado').getRecordTypeId();

 
         InsurancePolicyParticipant     objConP = new InsurancePolicyParticipant (RecordTypeId	=devRecordTypeId,
         InsurancePolicyId = objCon.id,Role	= 'Otros',IsMinorBeneficiary = false,IsActiveParticipant = true,PrimaryParticipantAccountId = objCon1.id
            );
        insert objConP;
        Test.startTest();
        
       
        Test.stopTest();
        
    }
      @isTest
    static void UpdateInsurancePolicy(){
                                 Id devRecordTypeIdAcc = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
 Map<Schema.SObjectField, Object> mapProduct2 = new Map<Schema.SObjectField, Object>();
        mapProduct2.put(Product2.Name, 'Desempleo');
        mapProduct2.put(Product2.Family, '24');
        mapProduct2.put(Product2.CS_Producto_M2__c, '121');
        mapProduct2.put(Product2.CS_Producto_Colmena_M2__c, 'Desempleo Individual');
        mapProduct2.put(Product2.CS_Estrategia_M2__c, '14');
        Product2 prod = CS_TestDataFactory.createProduct(mapProduct2, true);
        Account    objCon1 = new account(SHIPPINGCOUNTRY = '170',CS_NUMEROIDENTIFICACIONCP__PC = '1098741907',CS_SEXO__PC = '2',SUFFIX = 'beltran',SHIPPINGCITY = '11001',
                                         CS_TRATAMIENTODATOS__C = false,RECORDTYPEID = devRecordTypeIdAcc,FIRSTNAME = 'mario',SHIPPINGSTATE = '11',PHONE = '7573927',PERSONEMAIL = 'notiene@correo.com',
                                         CS_CLIENTEACTIVO__C = true,CS_TIPOIDENTIFICACIONCP__PC = '1',MIDDLENAME = 'alberto', LASTNAME = 'perez',PERSONMOBILEPHONE = '0'
            
             
            );
        insert objCon1;
                Id devRecordTypeIdIn = Schema.SObjectType.InsurancePolicy.getRecordTypeInfosByDeveloperName().get('CS_Seguro_de_vida').getRecordTypeId();
                Id devRecordTypeIdIn2 = Schema.SObjectType.InsurancePolicy.getRecordTypeInfosByDeveloperName().get('CS_Contrato_ARL').getRecordTypeId();

         InsurancePolicy    objCon = new InsurancePolicy(
              UniversalPolicyNumber = '50249-1856',CS_ProductoVT__c = '30249',
             CS_NumeroPolizaVisualTime__c = '30249',PolicyType = 'PC',
             RecordTypeId = devRecordTypeIdIn,PremiumFrequency='Mensual',Status = 'Ingresado',
             CS_asesorVenta__c = '22810844',CS_sucursalVenta__c = '3004',CS_medioRecaudo__c = 'Tarjeta de credito',
             RenewalChannel = 'Corredores',CS_Intermediario__c = '901565242',SourceSystem = 'VT',
             CS_RazonSocial__c = 'SOLUCIONES TERCERIZADAS S.A.S.',Name = '30249-1856',
             ProductId =Prod.id, NameInsuredId = objCon1.id
             
            );
        InsurancePolicy    objCon3 = new InsurancePolicy(
              UniversalPolicyNumber = '40249-1856',CS_ProductoVT__c = '30249',
             CS_NumeroPolizaVisualTime__c = '30249',PolicyType = 'PC',
             RecordTypeId = devRecordTypeIdIn2,PremiumFrequency='Mensual',Status = 'Ingresado',
             CS_asesorVenta__c = '22810844',CS_sucursalVenta__c = '3004',
             RenewalChannel = 'Corredores',CS_Intermediario__c = '901565242',SourceSystem = 'VT',
             CS_RazonSocial__c = 'SOLUCIONES TERCERIZADAS S.A.S.',Name = '30249-1856',
             ProductId =Prod.id, NameInsuredId = objCon1.id
             
            );
         Account    objCon2 = new account(SHIPPINGCOUNTRY = '170',CS_NUMEROIDENTIFICACIONCP__PC = '1098741904',CS_SEXO__PC = '2',SUFFIX = 'beltra',SHIPPINGCITY = '11001',
                                         CS_TRATAMIENTODATOS__C = false,RECORDTYPEID =devRecordTypeIdAcc,FIRSTNAME = 'marioU',SHIPPINGSTATE = '11',PHONE = '7573957',PERSONEMAIL = 'notiene@correo.com',
                                         CS_CLIENTEACTIVO__C = true,CS_TIPOIDENTIFICACIONCP__PC = '1',MIDDLENAME = 'albero', LASTNAME = 'erez',PERSONMOBILEPHONE = '0'
            
             
            );
        insert objCon2;
        insert objCon3;
        insert objCon;
        objCon.NameInsuredId = objCon2.id;
        Id devRecordTypeId = Schema.SObjectType.InsurancePolicyParticipant.getRecordTypeInfosByDeveloperName().get('CS_Asegurado').getRecordTypeId();

        Id devRecordTypeId2 = Schema.SObjectType.InsurancePolicyParticipant.getRecordTypeInfosByDeveloperName().get('CS_Trabajador').getRecordTypeId();
         InsurancePolicyParticipant     objConP = new InsurancePolicyParticipant (RecordTypeId	=devRecordTypeId,
         InsurancePolicyId = objCon.id,Role	= 'Otros',IsMinorBeneficiary = false,IsActiveParticipant = true,PrimaryParticipantAccountId = objCon2.id
            );
         InsurancePolicyParticipant     objConP2 = new InsurancePolicyParticipant (RecordTypeId	=devRecordTypeId2,
         InsurancePolicyId = objCon.id,Role	= 'Otros',IsMinorBeneficiary = false,IsActiveParticipant = true,PrimaryParticipantAccountId = objCon1.id
            );
        insert objConP;
        insert objConP2;
        update objCon;
    }

}