/*****************************************************************************************************
* Nombre de la clase de apex   :   CS_TestMakeData
* Versión                      :   1.0
* Fecha de creación            :   09/05/2022
* Función                      :   Crear registros para las clases de prueba
*                          
* --------------------------------------------------------------------------------------------------
* Desarrollador                          Fecha                      Descripción
*  
* Carlos Uriel Bolívar Aguilar         09/05/2022                  Versión original
****************************************************************************************************** */

@isTest
public with sharing class CS_TestMakeData {
    public static ContentVersion crearContentVersion(Boolean create) {
        
        ContentVersion content = new ContentVersion(); 
        content.Title='Header_Picture1'; 
        content.PathOnClient='/' + content.Title + '.jpg'; 
        Blob bodyBlob = Blob.valueOf('Unit Test ContentVersion Body'); 
        content.VersionData=bodyBlob; 
        content.origin = 'H';
        
        if(create){
            insert content;
        }
        
        return content;
    }
    
    public static ContentDocumentLink crearContentDocumentLink(Boolean create, String linkEntity, String contentId){
        ContentDocumentLink contentlink = new ContentDocumentLink();
        contentlink.LinkedEntityId = linkEntity;
        contentlink.ContentDocumentId= [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: contentId].ContentDocumentId;
        contentlink.ShareType = 'I';
        contentlink.Visibility = 'AllUsers'; 
        if(create){
            insert contentlink;
        }
        
        return contentlink;
    }
    
    public static Case crearcase(Boolean create){
        Case oneCase = new Case();
        oneCase.Type = 'Problem';
        oneCase.Origin = '2';
        oneCase.Status = 'Nuevo';
        oneCase.CS_Pais__c = '484';
        oneCase.CS_ProductoM2__c = '124';
        oneCase.CS_ProductoColmenaM2__c = 'Accidentes Personales';
        oneCase.CS_Subtipo__c = '2';
        oneCase.CS_PasosCompletados__c = true;
        if(create){
            insert oneCase;
        }       
        return oneCase;
    }

    public static Case createCase(Boolean create, String entity){
        Case oneCase = new Case();
        oneCase.Type = 'Problem';
        oneCase.Origin = '2';
        oneCase.Status = 'Nuevo';
        oneCase.CS_Pais__c = '484';
        if(entity == '3'){
            oneCase.CS_ProductoM2__c = '198';
            oneCase.CS_ProductoColmenaM2__c = null;
        }else if(entity == '2'){
            oneCase.CS_ProductoM2__c = '124';
            oneCase.CS_ProductoColmenaM2__c = 'Accidentes Personales';
        }else{
            oneCase.CS_ProductoM2__c = '132';
        }
        oneCase.CS_Subtipo__c = entity;
        oneCase.CS_PasosCompletados__c = true;
        if(create){
            insert oneCase;
        }       
        return oneCase;
    }
    
    public static Account createPersonAccount(){
        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        Account cuentaP = new Account(
            Firstname = 'test',
        	LastName = 'test',
            CS_TipoIdentificacionCP__pc = '1',
            CS_NumeroIdentificacionCP__pc = '123456789',
            CS_Empresa_Colmena__c = '1',  
            PersonEmail = 'test@test.com',
            Phone = '3300343345',
            CS_Sexo__pc = '1',             
            RecordTypeId = devRecordTypeId 
        ); 
        return cuentaP;
    }

    public static Account createJuridicaAccount(){
        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CS_Juridico').getRecordTypeId();
        Account cuentaJ = new Account(
        	Firstname = 'test',
            CS_TipoIdentificacionCP__pc = '1',
            CS_NumeroIdentificacionCP__pc = '123456789',
            CS_Empresa_Colmena__c = '1', 
            Phone = '3300343345',
            RecordTypeId = devRecordTypeId 
            );         
        return cuentaJ;
    }

    /*public static Contact createContact(){
        Contact con = new Contact(
            LastName = 'test',
            Email = 'test@test.com'             
            );         
        return con;
    }*/   
    
}