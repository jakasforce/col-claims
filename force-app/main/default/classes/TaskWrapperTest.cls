@IsTest(SeeAllData = True)
private class TaskWrapperTest {

    // Test method to verify the behavior of the constructor
    @isTest
    static void testTaskWrapperTest() {
        
        /////////////////////////// Creando Case Inicio
        
        //location
        Schema.Location location = new Schema.Location(Name = 'casa' , LocationType = 'Sitio');
        insert location;
        
        Schema.Location locationQuery = [Select Id, Name, LocationType
                     from Location where Name = 'casa' and LocationType = 'Sitio'][0];
        
        System.debug('Location: ' + locationQuery.Id);
        
		//Account personal
		/*
		Account account = new Account(
        							RecordTypeId= Schema.sObjectType.Account.getRecordTypeInfosByName().get('Persona').getRecordTypeId(),
        							CS_TipoIdentificacion__c = '1',
            						//CS_TipoIdentificacionCP__pc = '1'
        							CS_NumeroIdentificacion__c = '1022428537',
            						//CS_NumeroIdentificacionCP__pc = '1022428537',
        							Salutation = 'Mr.',
        							FirstName = 'JuanD',
        							LastName = 'LastName',
        							PersonEmail = 'das@asa.co',
        							Phone = '3016949560',
        							CC_Ciudad__c = locationQuery.Id,
        							CS_Sexo__pc = '2',
        							CS_Profesion__pc = 'Ing');
        
        insert account;
        
        Account accountQuery = [Select Id
                     from Account where CS_NumeroIdentificacionCP__pc = '1022428537' and CS_TipoIdentificacion__c = '1'][0];
		*/
        
        Account account = new Account(
        							CS_TipoIdentificacionCP__pc = '1',
            						CS_NumeroIdentificacionCP__pc = '10224285377',
        							//Salutation = 'Mr.',
        							FirstName = 'JuanD',
            						Middlename = 'MARIA',
        							LastName = 'LastName',
            						suffix = 'VILLADA',
        							//CC_Fecha_de_nacimiento__c = date.parse('2/25/1960'),
        							CS_IndicadorTratamientoDatos__pc = 'SI',
        							ShippingCity = '1318c000000qRKFAA2',
        							ShippingStreet = 'ALDEA KR 56 63 A 79',
        							PersonEmail = 'aipena6@misena.edu.co',
        							PHONE = '3016949560',
        							et4ae5__Mobile_Country_Code__pc = 'CO',
        							PersonMobilePhone = '3016949560',
        							AccountSource = '2',
        							//CC_Sub_Origen__c = '16',
        							CC_Producto_de_interes__c = '1',
        							//OwnerId = '0058H000004nnfoQAA',
        							CC_Tipo_de_Cuenta__c = 'Cuenta Cliente',
        							//RecordTypeId = '0128c000001z5tYAAQ',
        							CS_Origen_del_Registro__c = 'Visual Time',
        							CS_ClienteActivo__c = True);
        							//Fecha_Ingreso_Journey__c = date.parse('1/1/2018'));
		
        insert account;
        
        Account accountQuery = [Select Id
                     from Account where CS_NumeroIdentificacionCP__pc = '10224285377' and CS_TipoIdentificacionCP__pc = '1'][0];
        
        System.debug('accountQuery: ' + accountQuery.Id);
        		//Account Empresa
		Account accountEnterprise = new Account(
        							//RecordTypeId= Schema.sObjectType.Account.getRecordTypeInfosByName().get('Empresa').getRecordTypeId(),
        							Name = 'JuanD',
        							Phone = '1234133',
        							CC_Ciudad__c = location.Id);
		
        insert accountEnterprise;
        
        Account accountEnterpriseQuery = [Select Id
                     from Account where Phone = '1234133' and Name = 'JuanD'][0];
       
        System.debug('accountEnterpriseQuery: ' + accountEnterpriseQuery.Id);
        
        //Contact
        //
        
        Contact contact = new Contact(
            							Salutation = 'Mr.',
                                            FirstName = 'Juan',
                                            LastName = 'Holguin',
                                            AccountId = accountEnterpriseQuery.id,
                                            Email = 'das@asa.co',
                                            CS_Sexo__c = '2');
        
        insert contact;
        
        Contact contactQuery = [Select Id
                     from Contact where FirstName = 'Juan' and LastName = 'Holguin' and Email = 'das@asa.co'][0];
        
        System.debug('contactQuery: ' + contactQuery.Id);

	    //Case    
        Case caseValidation = new Case(
            							AccountId = accountQuery.id,
            							ContactId = contactQuery.id,
            							CS_Pais__c = '170',
            							CS_Departamento__c = '11',
            							CS_Municipio__c = '11001',
            							//CS_MacroMotivo__c = 'Interna - Incidencia RL',
            							//CS_Submotivo__c = 'Error linea efectiva',
            							RecordTypeId = Schema.sObjectType.Case.getRecordTypeInfosByName().get('Incidente').getRecordTypeId(),
            							Status = 'Escalado',
            							//CS_FechaTentativaDeCierre__c = date.parse('1/25/2024'),
            							CS_Semaforotexto__c = '', 
        								Description = 'the body of email',
        								Subject = 'the Email Subject123',
        								SuppliedEmail = 'foo@bar.com',
        								Origin = 'Internet');
        								//CS_Subtipo__c = '2',
        								//CS_ProductoM2__c = '132');
        // When inserts the Case
        INSERT caseValidation;
        
        
        
        Case caso = [Select Id, CaseNumber, RecordType.Name, Description, CS_MacroMotivo__c, 
                    	CS_Submotivo__c, Status, CS_FechaTentativaDeCierre__c, CS_Semaforotexto__c From Case 
                     where Subject = 'the Email Subject123' and Status = 'Escalado'];
        
        
        ///////////////////////// Creando Case Fin
        //
    	
       // Sample data
       string subject = 'Llamada Prueba';
       string status = 'Abierto';
       string description = 'Lorem Ipsum es simplemente';
       Task testTask = new Task(
           WhatId = caso.Id,
           subject = subject,         
           Description = description, 
           OwnerId = '0058c000009ZKtjAAG',
           Status = status, 
           ActivityDate = Date.today().addDays(7),
           //RecordTypeId = '0128c000001z636AAA'
           RecordTypeId = Schema.sObjectType.Task.getRecordTypeInfosByName().get('Tareas').getRecordTypeId()
       );
       insert testTask;
       Task tarea = [Select Id, WhatId, subject,
                      Description, ActivityDate, OwnerId, Owner.Name, Status, CreatedDate, RecordType.name
                     From Task where subject = :subject][0];
        
        //call Method
       TaskWrapper taskWrapper = new TaskWrapper(tarea);

        // Test
        System.assertEquals(description, tarea.Description, 'Las descripciones coinciden');
        System.assertEquals(subject, tarea.subject);
        
		system.debug('Fin');
        
       
    }
}