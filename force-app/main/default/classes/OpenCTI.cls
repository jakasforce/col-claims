public class OpenCTI {
    
    Map<String, String> getParameters = new Map<String, String>();
    String sfdcIframeOrigin{get;set;}
    String UUI{get;set;}
    List<String> lstUUI{get;set;}
    String AccountId{get;set;}
    String ANI{get; set;}
    String UCID{get; set;}
    String DNIS{get; set;}
    String QUEUE{get; set;}
    String IVRCallKey{get; set;}
    String IVRDocument{get; set;}
    String IVRDocumentType{get; set;}
    String TaskId{get; set;}
    String CreateDate{get; set;}
    public String actUrl{get; set;}
    public String UrlRedirect{get; set;}
    String contactId{get; set;}
    Boolean nuevaPag{get; set;}
    
    public OpenCTI() {
        CS_Log__c log = new CS_Log__c(CS_Funcion__c = 'IVRCall', CS_ResponseBody__c = 'Ingreso al Contructor');
        //insert log;
        getParameters = apexpages.currentpage().getparameters();
        sfdcIframeOrigin = getParameters.get('sfdcIframeOrigin');
        ANI = getParameters.get('ANI');
        UCID = getParameters.get('UCID');
        DNIS = getParameters.get('DNIS');
        UUI = getParameters.get('UUI');
        QUEUE = getParameters.get('QUEUE');
        system.debug(UUI);
        try {
            lstUUI = UUI.split(',');
            IVRDocumentType = lstUUI[0];
            IVRDocument = lstUUI[1];
            nuevaPag = true;
            AccountId = lstUUI[4];
            IVRCallKey = lstUUI[5];
            CreateDate = lstUUI[6];//2024-05-16T14:18:16.000+0000   2024/05/09 17:44:30
            CreateDate = CreateDate.replace('/','-');
            CreateDate = CreateDate.replace(' ','T');
            CreateDate += '.000+0000';
            if (AccountID.indexOf('!')>0) {
                List<String> lstacc = AccountID.split('!');
                AccountID = lstacc[0];
                nuevaPag = false;
            } 
        } catch (Exception e) {
            System.debug(e);
            IVRDocumentType = '';
            IVRDocument = '';
            AccountId = '';
        }
        System.debug(sfdcIframeOrigin);
        System.debug(lstUUI);
        System.debug(AccountId);
        System.debug(getParameters);
        System.debug(apexpages.currentpage().getUrl());       
    }

    public PageReference loadData(){
        System.debug('Ingreso a LoadData');
        createTask();
        return null;
    }
    
    public String getContactId(String phoneNumber) {
        Integer i = 0;
        i = Database.countQuery('SELECT count() FROM Contact WHERE Phone = : phoneNumber');
        if (i > 0) {
            List<Contact> contactList = Database.query('SELECT Id FROM Contact WHERE Phone = : phoneNumber');
            return contactList[0].Id ;
        }
        else {
            return '';
        }
    }
    
    public String getDocumentType(String docType) {
        String documentType = '';
        switch on docType {
            when '1' {		// when block 1
                documentType='Cédula de Ciudadanía';
            }	
            when '2' {		// when block 2
                documentType='Cédula de Extranjería';
            }
            when '3' {		// when block 3
                documentType='Número de Identificación Tributaria (NIT)';
            }
            when else {		  // default block, optional
                documentType='Otro';
            }
	    }
        return documentType;
    }

    public Task createTask(){
        System.debug('Ingreso a CreateTask');
        Task task = new Task();
        try {
/*            contactId = getContactId(ANI);
            if (contactId != '') {
                task.WhoId = contactId ;
            }
*/            
            task.Subject = 'Llamada';
            if (AccountID != '0') {
                task.whatId = AccountID;
            }
            task.RecordTypeId = '012Nt000000ZnnRIAS'; //UAT
//            task.RecordTypeId = '012Ou0000008I9RIAU'; // PRODUCCION
            task.caller__c = ANI;
            task.IVRMainCallID__c = IVRCallKey;            
            task.IVRCallCreationDate__c = CreateDate;
            task.IVRCallKey__c = UCID;
//            task.AgentID__c = DNIS;      
//            task.AgentID__c = QUEUE;
            task.ComdataGroupExtension__c = QUEUE;
            task.AtentoGroupExtension__c = DNIS;
            task.IVRDocumentNumber__c = IVRDocument;
            task.Modulo__c = 'Capitalizadora';
            IVRDocumentType = getDocumentType(IVRDocumentType);
            task.IVRDocumentType__c = IVRDocumentType;
            task.UUICode__c = UUI;
            task.HandCalls__c = 'Ingresó por IVR';
            task.Tipo_de_llamada__c = 'Entrante';
            task.ActivityDate = Date.today();
            System.debug(task);
            Insert task;
            TaskId = task.Id;
        } catch (Exception e) {
           System.debug(e);
        }
        actUrl = URL.getOrgDomainURL().toExternalForm();
        UrlRedirect = actUrl + '/lightning/r/Task/' + TaskId + '/view/';
        System.debug(UrlRedirect);
        return task;
    }
   
    public PageReference redirect(){
        
        actUrl = URL.getOrgDomainURL().toExternalForm();
        UrlRedirect = actUrl + '/lightning/r/Task/' + TaskId + '/view/';
        //String UrlRedirect = sfdcIframeOrigin + '/lightning/r/Task/' + TaskId + '/view/';
        //String UrlRedirect = sfdcIframeOrigin + '/lightning/r/Account/' + AccountID + '/view/';
        
        System.debug('Otra URL' + actUrl);
        System.debug('URL nueva');
        System.debug(UrlRedirect);

        PageReference pg = new PageReference(UrlRedirect);
        pg.setRedirect(true);
        return pg;

    }
}