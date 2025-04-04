/********************************************************************************************************************************************************************************************
Apex Class Name	:	CS_CrearCasoController
Version			:	1.0
Created Date	:	23/03/2023 by Jorge Martínez (jorge.martinez-miranda@viseo.com / martinezmiranda.jorge@gmail.com)
Test Class      :   CS_CrearCasoController_Test
Function 		:   Clase Controladora para el LWC cs_CrearCaso

Modification Log:
*--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*    Developer                    Date                    Description                    Changes
*--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*    Jorge Martinez               23/03/2023              Original Version               Nuevo método getInsurancePolicy y getClaim
*    Jorge Martinez               24/03/2023              Original Version               Nuevo método getContacts
*    Jorge Martinez               04/04/2023              Original Version               Nuevo método getTituloCapitalizacion
*--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*********************************************************************************************************************************************************************************************/

public without sharing class CS_CrearCasoController {

    /*
     * @method getInsurancePolicy() 
     * @description Obtiene la información de la póliza de seguro
     * @param  { id } - Id de la póliza
     * @return { List<InsurancePolicy> } - retorna la lista con la póliza de seguro, objeto "InsurancePolicy"
     */
    @AuraEnabled(cacheable=true)
    public static List<InsurancePolicy> getInsurancePolicy(String id){
        return [SELECT Id, Name, RecordType.DeveloperName, NameInsured.Name, NameInsuredId, NameInsured.IsPersonAccount, NameInsured.PersonContact.Name, NameInsured.PersonContactId,
                ProductId, Product.CS_Producto_M2__c, Product.CS_Producto_Colmena_M2__c, Product.Family, CS_NumeroContrato__c, CS_Estrategia__c, RenewalChannel
                FROM InsurancePolicy 
                WHERE Id =: Id
               ];
    }

    /*
     * @method getClaim() 
     * @description Obtiene la información del reclamo
     * @param  { id } - Id del reclamo
     * @return { List<Claim> } - retorna la lista con el reclamo, objeto "Claim"
     */
    @AuraEnabled(cacheable=true)
    public static List<Claim> getClaim(String id){
        return [SELECT Id, Name, RecordType.Name, Account.Name, AccountId, Account.IsPersonAccount, Account.PersonContact.Name, Account.PersonContactId, RecordType.DeveloperName,
                PolicyNumber.RenewalChannel, PolicyNumber.CS_Estrategia__c, PolicyNumber.Product.CS_Producto_M2__c, PolicyNumber.Product.CS_Producto_Colmena_M2__c, PolicyNumberId, 
                PolicyNumber.ProductId, PolicyNumber.Product.Family
                FROM Claim 
                WHERE Id =: Id
               ];
    }

    /*
     * @method getTituloCapitalizacion() 
     * @description Obtiene la información del título de capitalización
     * @param  { id } - Id del título de capitalización
     * @return { List<CS_Titulo_de_Capitalizacion__c> } - retorna la lista con el titulo de capitalización, objeto "CS_Titulo_de_Capitalizacion__c"
     */
    @AuraEnabled(cacheable=true)
    public static List<CS_Titulo_de_Capitalizacion__c> getTituloCapitalizacion(String id){
        return [SELECT Id, Name, CS_Cuenta__c, CS_Cuenta__r.Name, CS_Cuenta__r.IsPersonAccount, CS_Cuenta__r.PersonContact.Name, CS_Cuenta__r.PersonContactId,
                CS_Producto__c, CS_Producto__r.CS_Producto_M2__c, CS_Producto__r.CS_Producto_Colmena_M2__c, CS_Producto__r.Family, CS_Estrategia__c, CS_Canal_de_venta__c
                FROM CS_Titulo_de_Capitalizacion__c 
                WHERE Id =: Id
               ];
    }

    /*
     * @method getContacts() 
     * @description Obtiene los contactos de una cuenta
     * @param  { id } - Id de cuenta
     * @return { List<AccountContactRelation> } - retorna la lista con relación de los contactos de una cuenta, objeto "AccountContactRelation"
     */
    @AuraEnabled(cacheable=true)
    public static List<AccountContactRelation> getContacts(String id){
        return [SELECT Id, AccountId, ContactId, Contact.Name
                FROM AccountContactRelation 
                WHERE AccountId =: Id and IsActive = true
                ORDER BY Contact.Name
               ];
    }

}