public class FileConfigMulesoft {

    public String client_id;
    public String client_secret;
    public String grant_type;
    public String urlMulesoft;
    
    public FileConfigMulesoft(String nameProperties){
        file_config_mulesoft__c config = file_config_mulesoft__c.getValues(nameProperties);
        this.client_id = (String) config.get('client_id__c');
        this.client_secret = (String) config.get('client_secret__c');
    	this.grant_type = (String) config.get('grant_type__c');
    	this.urlMulesoft = (String) config.get('url_mulesoft__c');
    }
}