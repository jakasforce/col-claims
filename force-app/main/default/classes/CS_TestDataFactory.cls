/***************************************************************************************************************************
 * Nombre de la Clase Apex : CS_TestDataFactory
 * Versión                 : 1.0
 * Fecha de Creación       : 08/09/2022
 * Funcionalidad           : Generación de datos para pruebas
 *--------------------------------------------------------------------------------------------------------------------------
 *                                              HISTORIAL DE MODIFICACIONES:
 *--------------------------------------------------------------------------------------------------------------------------
 * Desarrollador         Fecha           Descripción
 *--------------------------------------------------------------------------------------------------------------------------
 * Angel Cabezas         08/09/2022      Creación
 * Jorge Martinez        10/04/2023      Nuevos métodos: createProduct, createInsurancePolicy, createClaim, 
 *                                                       createTituloCapitalizacion, createContact
 * 
 * ///TODO: Nombre desarrollador        //TODO: Fecha de creación dd/mm/aaaa      Creación
 *--------------------------------------------------------------------------------------------------------------------------
 **************************************************************************************************************************/
@isTest
public class CS_TestDataFactory {
	public static Case createCase(Boolean doInsert) {

        Product2 newProduct = new Product2(
            Name = 'TestName',
            IsActive = true, 
            ProductCode = 'PC',
            Description = 'Desc',
            Family = '31'
        );

		Case newCase = new Case(CS_Departamento__c = '05', CS_Municipio__c = '05002', CS_ProductoM1__c = '125', CS_ProductoM2__c = '121', CS_Subtipo__c = '2');
		
        if (doInsert) {
            insert newProduct;
            newCase.ProductId = newProduct.Id;
			insert newCase;
		}
		return newCase;
	}

	public static Case createCase(Map<Schema.SObjectField, Object> customFieldsMap, Boolean doInsert) {
		Case newCase = createCase(false);
		for (Schema.SObjectField fieldDescription : customFieldsMap.keySet()) {
			newCase.put(fieldDescription, customFieldsMap.get(fieldDescription));
		}
		if (doInsert) {
			insert newCase;
		}
		return newCase;
	}
    
    public static Account createPersonAccount(Boolean doInsert) {
        Id personAccountRecordTypeId =  Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        Account newPersonAccount = new Account(RecordTypeId=personAccountRecordTypeId,
                                               PersonMobilePhone='55555',
                                               PersonEmail='email@test.com',
                                               FirstName='Nombre',
                                               LastName='Apellido',
                                               Phone='55555'
                                               );
        if (doInsert) {
            insert newPersonAccount;
        }
        return newPersonAccount;
    }

    public static Account createPersonAccount(Map<Schema.SObjectField, Object> customFieldsMap, Boolean doInsert) {
     Account newPersonAccount = createPersonAccount(false);
        for (Schema.SObjectField fieldDescription : customFieldsMap.keySet()) {
            newPersonAccount.put(fieldDescription, customFieldsMap.get(fieldDescription));
        }
        if (doInsert) {
            insert newPersonAccount;
        }
        return newPersonAccount;
    }
 public static Account createAccount(Boolean doInsert) {
        Id AccountRecordTypeId =  Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CS_Juridico').getRecordTypeId();
        Account newAccount = new Account(RecordTypeId=AccountRecordTypeId,
                                         Name='Cuenta Juridico');
        if (doInsert) {
            insert newAccount;
        }
        return newAccount;
    }

    public static Account createAccount(Map<Schema.SObjectField, Object> customFieldsMap, Boolean doInsert) {
     Account newAccount = createAccount(false);
        for (Schema.SObjectField fieldDescription : customFieldsMap.keySet()) {
            newAccount.put(fieldDescription, customFieldsMap.get(fieldDescription));
        }
        if (doInsert) {
            insert newAccount;
        }
        return newAccount;
    }

    public static Product2 createProduct(Map<Schema.SObjectField, Object> customFieldsMap, Boolean doInsert){
        Product2 newProduct2 = new Product2();       
        for (Schema.SObjectField fieldDescription : customFieldsMap.keySet()) {
            newProduct2.put(fieldDescription, customFieldsMap.get(fieldDescription));
        }
        if (doInsert) {
            insert newProduct2;
        }
        return newProduct2;
    }

    public static InsurancePolicy createInsurancePolicy(Map<Schema.SObjectField, Object> customFieldsMap, Boolean doInsert){    
        InsurancePolicy newInsurancePolicy = new InsurancePolicy();
        for (Schema.SObjectField fieldDescription : customFieldsMap.keySet()) {
            newInsurancePolicy.put(fieldDescription, customFieldsMap.get(fieldDescription));
        }
        if (doInsert) {
            insert newInsurancePolicy;
        }
        return newInsurancePolicy;
    }

    public static Claim createClaim(Map<Schema.SObjectField, Object> customFieldsMap, Boolean doInsert){    
        Claim newClaim = new Claim();
        for (Schema.SObjectField fieldDescription : customFieldsMap.keySet()) {
            newClaim.put(fieldDescription, customFieldsMap.get(fieldDescription));
        }
        if (doInsert) {
            insert newClaim;
        }
        return newClaim;
    }

    public static CS_Titulo_de_Capitalizacion__c createTituloCapitalizacion(Map<Schema.SObjectField, Object> customFieldsMap, Boolean doInsert){    
        CS_Titulo_de_Capitalizacion__c newTituloCapitalizacion = new CS_Titulo_de_Capitalizacion__c();
        for (Schema.SObjectField fieldDescription : customFieldsMap.keySet()) {
            newTituloCapitalizacion.put(fieldDescription, customFieldsMap.get(fieldDescription));
        }
        if (doInsert) {
            insert newTituloCapitalizacion;
        }
        return newTituloCapitalizacion;
    }

    public static Contact createContact(Map<Schema.SObjectField, Object> customFieldsMap, Boolean doInsert){    
        Contact newContact = new Contact();
        for (Schema.SObjectField fieldDescription : customFieldsMap.keySet()) {
            newContact.put(fieldDescription, customFieldsMap.get(fieldDescription));
        }
        if (doInsert) {
            insert newContact;
        }
        return newContact;
    }

}