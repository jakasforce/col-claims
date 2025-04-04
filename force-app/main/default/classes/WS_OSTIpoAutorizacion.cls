global with sharing class WS_OSTIpoAutorizacion implements Callable {
    public Object call(String action, Map<String, Object> args) {
        System.debug('Entering call method');
        Map<String, Object> input = (Map<String, Object>) args.get('input');
        Map<String, Object> output = (Map<String, Object>) args.get('output');
        Map<String, Object> options = (Map<String, Object>) args.get('options');
        return invokeMethod(action, input, output, options);
    }

    global Boolean invokeMethod(String methodName, Map<String, Object> inputMap, Map<String, Object> outMap, Map<String, Object> options) {
        System.debug('Entering invokeMethod: ' + methodName);
        Boolean result = true;
        try {
            if (methodName.equals('createClient')) {
                createClient(inputMap, outMap, options);
            } else if (methodName.equals('homologateJson')) {
                homologateJson(inputMap, outMap, options);
            } else if (methodName.equals('saveInformationHabeasData')) {
                saveInformationHabeasDataFromOmniscript(inputMap);
            } else {
                result = false;
            }
        } catch(Exception e) {
            System.debug('Exception in invokeMethod: ' + e.getMessage());
            System.debug('LineNumber: ' + e.getLineNumber());
            System.debug('StackTrace: ' + e.getStackTraceString());
            System.debug('TypeName: ' + e.getTypeName());
            result = false;
        }
        return result;
    }

    public static void saveInformationHabeasDataFromOmniscript(Map<String, Object> inputMap) {
        System.debug('InputMap : ' + inputMap);
        WS_HabeasDataWrapper.RequestWSWrapper dataRequest = new WS_HabeasDataWrapper.RequestWSWrapper();
        dataRequest.FirstName = (String) inputMap.get('FirstName');
        dataRequest.SecondName = (String) inputMap.get('SecondName');
        dataRequest.LastName = (String) inputMap.get('LastName');
        dataRequest.SecondLastName = (String) inputMap.get('SecondLastName');
        dataRequest.identityType = (String) inputMap.get('identityType');
        dataRequest.identityNumber = (String) String.valueOf(inputMap.get('identityNumber'));
        dataRequest.email = (String) inputMap.get('email');
        dataRequest.numberPhone = (String) inputMap.get('numberPhone');
        dataRequest.AttentionChannel = (String) inputMap.get('AttentionChannel');

        WS_HabeasDataWrapper.CompaniesWrapper compani = new WS_HabeasDataWrapper.CompaniesWrapper();
        compani.name = (String) inputMap.get('companieName');
        compani.essentialFunctionalities = (Boolean) inputMap.get('essentialFunctionalities');
        compani.law2300 = null;
        compani.MedicalHistory = null;
        String fne1 = (String) inputMap.get('FNE1');
        String fne2 = (String) inputMap.get('FNE2');
        String fne3 = (String) inputMap.get('FNE3');
        List<String> notEssentialFunctionalities = new List<String>();

        if (fne1 == 'Yes') {
            notEssentialFunctionalities.add('FNE1');
        }
        if (fne2 == 'Yes') {
            notEssentialFunctionalities.add('FNE2');
        }
        if (fne3 == 'Yes') {
            notEssentialFunctionalities.add('FNE3');
        }
        compani.notEssentialFunctionalities = notEssentialFunctionalities;

        List<WS_HabeasDataWrapper.CompaniesWrapper> listCompanies = new List<WS_HabeasDataWrapper.CompaniesWrapper>();
        listCompanies.add(compani);
        dataRequest.companies = listCompanies;

        WSClientController cctest = new WSClientController();
        System.debug('ValidacionIdentidad()...');
        dataRequest = cctest.ValidacionIdentidad(dataRequest);
        
        WSHabeasDataController controller = new WSHabeasDataController();
        System.debug('controllerHD()...');
        System.debug(controller.controllerHD(dataRequest));
    }
    
    public static void createClient(Map<String, Object> inputMap, Map<String, Object> outMap, Map<String, Object> options) {
        System.debug('Entering createClient method');
        WS_HabeasDataWrapper.RequestWSWrapper requestParams = new WS_HabeasDataWrapper.RequestWSWrapper();
        
        System.debug('inputMap: ' + JSON.serializePretty(inputMap));
        System.debug('outMap: ' + outMap);
        System.debug('options: ' + options);
        
        Map<String, Object> request = (Map<String, Object>) inputMap.get('Request');
        
        // Agregar requestParams
        requestParams.FirstName = (String) request.get('FirstName');
        requestParams.SecondName = (String) request.get('SecondName');
        requestParams.LastName = (String) request.get('LastName');
        requestParams.SecondLastName = (String) request.get('SecondLastName');
        requestParams.identityType = (String) request.get('identityType');
        requestParams.identityNumber = (String) request.get('identityNumber');
        requestParams.email = (String) request.get('email');
        requestParams.numberPhone = (String) request.get('numberPhone');
        requestParams.AttentionChannel = (String) request.get('AttentionChannel');
        
        List<Map<String, Object>> companies = (List<Map<String, Object>>) request.get('Companies');
        
        List<WS_HabeasDataWrapper.CompaniesWrapper> requestCompanies = new List<WS_HabeasDataWrapper.CompaniesWrapper>();
        
        for (Map<String, Object> companyMap : companies) {
            WS_HabeasDataWrapper.CompaniesWrapper company = new WS_HabeasDataWrapper.CompaniesWrapper();
            company.name = (String) companyMap.get('name');
            company.essentialFunctionalities = (Boolean) companyMap.get('essentialFunctionalities');
            company.law2300 = (Boolean) companyMap.get('law2300');
            
            List<String> notessentialFunctionalities = new List<String>();
            if (companyMap.get('notessentialFunctionalities') != null) {
                notessentialFunctionalities = (List<String>) companyMap.get('notessentialFunctionalities');
            }
            company.notEssentialFunctionalities = notessentialFunctionalities;
            
            if (companyMap.containsKey('MedicalHistory')) {
                company.MedicalHistory = (Boolean) companyMap.get('MedicalHistory');
            }
            
            requestCompanies.add(company);
        }
        
        requestParams.companies = requestCompanies;
        
        System.debug('Request Parameters: ' + JSON.serializePretty(requestParams));
        
        WSClientController wsClientController = new WSClientController();
        WS_HabeasDataWrapper.RequestWSWrapper responseClientController = wsClientController.ValidacionIdentidad(requestParams);
        
        if (responseClientController.IdClient != null) {
            outMap.put('Exito', true);
            outMap.put('ClientId', responseClientController.IdClient);
            System.debug('IdClient: ' + responseClientController.IdClient);
            System.debug('ClientController: ' + responseClientController.ClientController);
            
            WSHabeasDataController habeasDataManager = new WSHabeasDataController();
            WS_HabeasDataWrapper.ResponseWSWrapper response = new WS_HabeasDataWrapper.ResponseWSWrapper();
            response = habeasDataManager.controllerHD(responseClientController);
        } else {
            outMap.put('Exito', false);
        }
        
        System.debug('Final outMap: ' + JSON.serializePretty(outMap));
    }
    
    public static void homologateJson(Map<String, Object> inputMap, Map<String, Object> outMap, Map<String, Object> options) {
        System.debug('Entering homologateJson method');
        System.debug('Original inputMap: ' + JSON.serializePretty(inputMap));
        
        Map<String, Object> requestMap = (Map<String, Object>) inputMap.get('Request');
        if (requestMap == null) {
            System.debug('Request map null');
            return;
        }
        
        Map<String, Object> datosCuenta = (Map<String, Object>) requestMap.get('DatosCuenta');
        if (datosCuenta == null) {
            System.debug('DatosCuenta map null');
            return;
        }
        
        Boolean isAccount = (Boolean) inputMap.get('IsAccount');
        Boolean isLead = (Boolean) inputMap.get('IsLead');
        
        System.debug('Value of IsAccount: ' + isAccount);
        System.debug('Value of IsLead: ' + isLead);
        
        // Crear mapa homologado
        Map<String, Object> homologatedMap = new Map<String, Object>();
        
        if (isAccount) {
            homologatedMap.put('FirstName', (String) datosCuenta.get('FirstName'));
            homologatedMap.put('SecondName', (String) datosCuenta.get('MiddleName'));
            homologatedMap.put('LastName', (String) datosCuenta.get('LastName'));
            homologatedMap.put('SecondLastName', (String) datosCuenta.get('SecondLastName'));
            homologatedMap.put('identityType', (String) datosCuenta.get('IdentityType'));
            homologatedMap.put('identityNumber', (String) datosCuenta.get('IdentityNumber'));
            homologatedMap.put('email', (String) datosCuenta.get('Email'));
            homologatedMap.put('numberPhone', (String) datosCuenta.get('numberPhone'));
        } else if (isLead) {
            homologatedMap.put('FirstName', (String) datosCuenta.get('FirstNameLead'));
            homologatedMap.put('LastName', (String) datosCuenta.get('LastNameLead'));
            homologatedMap.put('identityType', (String) datosCuenta.get('IdentityTypeLead'));
            homologatedMap.put('identityNumber', (String) datosCuenta.get('IdentityNumberLead'));
            homologatedMap.put('email', (String) datosCuenta.get('EmailLead'));
            homologatedMap.put('numberPhone', (String) datosCuenta.get('numberPhoneLead'));
        }
        
        homologatedMap.put('AttentionChannel', 'Mary');
        
        List<Map<String, Object>> companies = new List<Map<String, Object>>();
        
        if (datosCuenta.containsKey('ColmenaCapitalizadora')) {
            Map<String, Object> colmenaCapitalizadora = (Map<String, Object>) datosCuenta.get('ColmenaCapitalizadora');
            Map<String, Object> companyMap = new Map<String, Object>();
            companyMap.put('name', 'Colmena Capitalizadora');
            companyMap.put('essentialFunctionalities', colmenaCapitalizadora.get('essentialFunctionalitiesCapitalizadora'));
            companyMap.put('notessentialFunctionalities', colmenaCapitalizadora.containsKey('notessentialFunctionalitiesCapitalizadora') ? ((String) colmenaCapitalizadora.get('notessentialFunctionalitiesCapitalizadora')).split(';') : new List<String>());
            companyMap.put('law2300', colmenaCapitalizadora.get('law2300Capitalizadora'));
            companyMap.put('MedicalHistory', false); 
            companies.add(companyMap);
        }
        
        if (datosCuenta.containsKey('ColmenaSegurosGenerales')) {
            Map<String, Object> colmenaSegurosGenerales = (Map<String, Object>) datosCuenta.get('ColmenaSegurosGenerales');
            Map<String, Object> companyMap = new Map<String, Object>();
            companyMap.put('name', 'Colmena Seguros Generales');
            companyMap.put('essentialFunctionalities', colmenaSegurosGenerales.get('essentialFunctionalitiesGenerales'));
            String notessentialFunctionalitiesGenerales = (String) colmenaSegurosGenerales.get('notessentialFunctionalitiesGenerales');
            companyMap.put('notessentialFunctionalities', notessentialFunctionalitiesGenerales != null ? notessentialFunctionalitiesGenerales.split(';') : new List<String>());
            companyMap.put('law2300', colmenaSegurosGenerales.get('law2300Generales'));
            companyMap.put('MedicalHistory', colmenaSegurosGenerales.containsKey('clinicHistoryGenerales') ? colmenaSegurosGenerales.get('clinicHistoryGenerales') : false);
            companies.add(companyMap);
        }
        
        if (datosCuenta.containsKey('ColmenaSegurosVida')) {
            Map<String, Object> colmenaSegurosVida = (Map<String, Object>) datosCuenta.get('ColmenaSegurosVida');
            Map<String, Object> companyMap = new Map<String, Object>();
            companyMap.put('name', 'Colmena Seguros Vida');
            companyMap.put('essentialFunctionalities', colmenaSegurosVida.get('essentialFunctionalitiesVida'));
            String notessentialFunctionalitiesVida = (String) colmenaSegurosVida.get('notessentialFunctionalitiesVida');
            companyMap.put('notessentialFunctionalities', notessentialFunctionalitiesVida != null ? notessentialFunctionalitiesVida.split(';') : new List<String>());
            companyMap.put('law2300', colmenaSegurosVida.get('law2300Vida'));
            companyMap.put('MedicalHistory', colmenaSegurosVida.containsKey('clinicHistoryVida') ? colmenaSegurosVida.get('clinicHistoryVida') : false);
            companies.add(companyMap);
        }
        
        if (datosCuenta.containsKey('ColmenaSegurosARL')) {
            Map<String, Object> colmenaSegurosARL = (Map<String, Object>) datosCuenta.get('ColmenaSegurosARL');
            Map<String, Object> companyMap = new Map<String, Object>();
            companyMap.put('name', 'Colmena Seguros ARL');
            companyMap.put('essentialFunctionalities', colmenaSegurosARL.get('essentialFunctionalitiesARL'));
            String notessentialFunctionalitiesARL = (String) colmenaSegurosARL.get('notessentialFunctionalitiesARL');
            companyMap.put('notessentialFunctionalities', notessentialFunctionalitiesARL != null ? notessentialFunctionalitiesARL.split(';') : new List<String>());
            companyMap.put('law2300', colmenaSegurosARL.get('law2300ARL'));
            companyMap.put('MedicalHistory', colmenaSegurosARL.containsKey('clinicHistoryARL') ? colmenaSegurosARL.get('clinicHistoryARL') : false);
            companies.add(companyMap);
        }
        
        homologatedMap.put('Companies', companies);
        
        System.debug('Homologated Map: ' + JSON.serializePretty(homologatedMap));
        
        inputMap.put('Request', homologatedMap);
        createClient(inputMap, outMap, options);
    }
}