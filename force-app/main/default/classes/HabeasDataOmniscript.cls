global with sharing class HabeasDataOmniscript implements omnistudio.VlocityOpenInterface {
    global Boolean invokeMethod(String methodName, Map<String, Object> inputMap, Map<String, Object> outMap, Map<String, Object> options) {
        Boolean result = true;

        try {
            if (methodName.equals('saveInformationHabeasData')) {
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
                
                saveInformationHabeasData(dataRequest);
            }
        } catch (Exception e) {
            result = false;
        }

        return result;
    }

    public static void saveInformationHabeasData(WS_HabeasDataWrapper.RequestWSWrapper dataRequest) {
        System.debug('Entro saveInformationHabeasData()...');
        WSClientController cctest = new WSClientController();
        dataRequest = cctest.ValidacionIdentidad(dataRequest);

        WSHabeasDataController controller = new WSHabeasDataController();
        System.debug(controller.controllerHD(dataRequest));
    }
}