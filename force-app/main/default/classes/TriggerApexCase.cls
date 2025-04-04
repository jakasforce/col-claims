public class TriggerApexCase {

    @InvocableMethod (label='Create or Update in Senda Case'
                      description='Create or Update Cases of salesforce in senda'
    )
    public static void createOrUpdateCaseSenda(List<String> idString){
        sendCaseSenda.createOrUpdateCaseSenda(idString[0]);  
	}
}