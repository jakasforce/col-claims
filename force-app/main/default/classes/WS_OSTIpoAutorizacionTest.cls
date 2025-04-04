@isTest
public class WS_OSTIpoAutorizacionTest {
    @testSetup
    static void setupTestData() {
        List<RecordType> personalAccountRecordType = [SELECT Id, Name, DeveloperName FROM RecordType WHERE DeveloperName  = 'PersonAccount' Limit 1];
        
        EngagementChannelType engagementChannelTest = new EngagementChannelType(
            Name = 'Mary',
            channelReceivesPQRs__c = true
        );
        insert engagementChannelTest;
        
        Account acc = new Account(
            RecordTypeId = personalAccountRecordType[0].Id,
            CS_TipoIdentificacionCP__pc = '1',
            CS_NumeroIdentificacionCP__pc = '1000350348',
            FirstName = 'Gabriel',
            LastName = 'Velandia',
            PersonEmail = 'Gabosvel2003@gmail.com',
            PersonMobilePhone = '3013926584',
            CS_Empresa_Colmena__c = '1',
            CC_Tipo_de_Cuenta__c = 'Cuenta Prospecto',
            CS_ContactChannels__c = 'Mensaje de texto'	
        );
        insert acc;
    }

    @isTest
    static void testCallCreateClient() {
        // Crear datos simulados
        Map<String, Object> request = new Map<String, Object>{
            'FirstName' => 'John',
            'SecondName' => 'Doe',
            'LastName' => 'Smith',
            'SecondLastName' => 'Johnson',
            'identityType' => 'Passport',
            'identityNumber' => '1234567890',
            'email' => 'john.doe@example.com',
            'numberPhone' => '1234567890',
            'AttentionChannel' => 'Email',
            'Companies' => new List<Map<String, Object>>{
                new Map<String, Object>{
                    'name' => 'Company1',
                    'essentialFunctionalities' => true,
                    'law2300' => true,
                    'notessentialFunctionalities' => new List<String>{'FNE1', 'FNE2'},
                    'MedicalHistory' => false
                },
                new Map<String, Object>{
                    'name' => 'Company2',
                    'essentialFunctionalities' => false,
                    'law2300' => false,
                    'notessentialFunctionalities' => new List<String>{'FNE1'},
                    'MedicalHistory' => true
                }
            }
        };

        Map<String, Object> input = new Map<String, Object>{
            'Request' => request
        };
        Map<String, Object> output = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();

        Map<String, Object> args = new Map<String, Object>{
            'input' => input,
            'output' => output,
            'options' => options
        };

        WS_OSTIpoAutorizacion instance = new WS_OSTIpoAutorizacion();

        Test.startTest();
        Object result = instance.call('createClient', args);
        Test.stopTest();
    }

    @isTest
    static void testCallHomologateJson() {
        // Crear datos de entrada simulados
        Map<String, Object> datosCuenta = new Map<String, Object>{
            'FirstName' => 'Camilo',
            'MiddleName' => 'Test',
            'LastName' => 'Merchan',
            'SecondLastName' => 'Test',
            'IdentityType' => '1',
            'IdentityNumber' => '1010137364',
            'Email' => 'edwincamilomartinezmerchan63@gmail.com',
            'numberPhone' => '123456789',
            'ColmenaCapitalizadora' => new Map<String, Object>{
                'essentialFunctionalitiesCapitalizadora' => true,
                'notessentialFunctionalitiesCapitalizadora' => 'FNE1;FNE2',
                'law2300Capitalizadora' => true
            },
            'ColmenaSegurosGenerales' => new Map<String, Object>{
                'essentialFunctionalitiesGenerales' => true,
                'notessentialFunctionalitiesGenerales' => 'FNE1',
                'law2300Generales' => true
            },
            'ColmenaSegurosVida' => new Map<String, Object>{
                'essentialFunctionalitiesVida' => true,
                'notessentialFunctionalitiesVida' => 'FNE1',
                'law2300Vida' => true,
                'clinicHistoryVida' => false
            },
            'ColmenaSegurosARL' => new Map<String, Object>{
                'essentialFunctionalitiesARL' => true,
                'notessentialFunctionalitiesARL' => 'FNE1',
                'law2300ARL' => true,
                'clinicHistoryARL' => true
            }
        };

        Map<String, Object> requestMap = new Map<String, Object>{
            'DatosCuenta' => datosCuenta
        };

        Map<String, Object> input = new Map<String, Object>{
            'Request' => requestMap,
            'IsAccount' => true
        };

        Map<String, Object> output = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();

        Map<String, Object> args = new Map<String, Object>{
            'input' => input,
            'output' => output,
            'options' => options
        };

        WS_OSTIpoAutorizacion instance = new WS_OSTIpoAutorizacion();

        Test.startTest();
        Object result = instance.call('homologateJson', args);
        Test.stopTest();

    }

    @isTest
    static void testInvokeMethodCreateClient() {
        // Crear datos simulados
        Map<String, Object> inputMap = new Map<String, Object>();
        Map<String, Object> outMap = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();

        WS_OSTIpoAutorizacion instance = new WS_OSTIpoAutorizacion();

        Test.startTest();
        Boolean result = instance.invokeMethod('createClient', inputMap, outMap, options);
        Test.stopTest();

    }

    @isTest
    static void testInvokeMethodHomologateJson() {
        Map<String, Object> datosCuenta = new Map<String, Object>{
            'FirstName' => 'Camilo',
            'MiddleName' => 'Test',
            'LastName' => 'Merchan',
            'SecondLastName' => 'Test',
            'IdentityType' => '1',
            'IdentityNumber' => '1010137364',
            'Email' => 'edwincamilomartinezmerchan63@gmail.com',
            'numberPhone' => '123456789',
            'ColmenaCapitalizadora' => new Map<String, Object>{
                'essentialFunctionalitiesCapitalizadora' => true,
                'notessentialFunctionalitiesCapitalizadora' => 'FNE1;FNE2',
                'law2300Capitalizadora' => true
            },
            'ColmenaSegurosGenerales' => new Map<String, Object>{
                'essentialFunctionalitiesGenerales' => true,
                'notessentialFunctionalitiesGenerales' => 'FNE1',
                'law2300Generales' => true
            },
            'ColmenaSegurosVida' => new Map<String, Object>{
                'essentialFunctionalitiesVida' => true,
                'notessentialFunctionalitiesVida' => 'FNE1',
                'law2300Vida' => true,
                'clinicHistoryVida' => false
            },
            'ColmenaSegurosARL' => new Map<String, Object>{
                'essentialFunctionalitiesARL' => true,
                'notessentialFunctionalitiesARL' => 'FNE1',
                'law2300ARL' => true,
                'clinicHistoryARL' => true
            }
        };

        Map<String, Object> requestMap = new Map<String, Object>{
            'DatosCuenta' => datosCuenta
        };

        Map<String, Object> inputMap = new Map<String, Object>{
            'Request' => requestMap,
            'IsAccount' => true
        };

        Map<String, Object> outMap = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();

        WS_OSTIpoAutorizacion instance = new WS_OSTIpoAutorizacion();

        Test.startTest();
        Boolean result = instance.invokeMethod('homologateJson', inputMap, outMap, options);
        Test.stopTest();

    }

    @isTest
    static void testInvokeMethodInvalid() {
        Map<String, Object> inputMap = new Map<String, Object>();
        Map<String, Object> outMap = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();
        
        WS_OSTIpoAutorizacion instance = new WS_OSTIpoAutorizacion();
        
        Test.startTest();
        Boolean result = instance.invokeMethod('invalidMethod', inputMap, outMap, options);
        Test.stopTest();
        
    }
    
    @isTest
    static void testSaveInformationHabeasDataFromOmniscript() {
        String jsonString = '{"AttentionChannel":"Mary","AuthorizeDataProcessing":{"AuthorizeDataProcessingCheckbox":true,"AuthorizeTermsAndConditions":true,"RadioGoodsProducts":"Yes","RadioGoodsProducts2":"Yes","RadioTastesHabitsInterests":"Yes"},"FNE1":"Yes","FNE2":"Yes","FNE3":"Yes","FirstName":"Test","LastName":"Test","PersonData":{"addresshome":"Test","documentNumber":"23494390","documentType":"1","email":"test@oc.vasscompany.com","firstName":"Test","lastName":"Test","phoneNumber":"3145601769","relationType":"Cónyuge","secondLastName":"Test","secondName":"Test"},"SecondLastName":"Test","SecondName":"Test"}';
		Map<String, Object> dataMap = (Map<String, Object>) JSON.deserializeUntyped(jsonString);
            
        Test.startTest();
        	WS_OSTIpoAutorizacion.saveInformationHabeasDataFromOmniscript(dataMap);
        Test.stopTest();
    }

}