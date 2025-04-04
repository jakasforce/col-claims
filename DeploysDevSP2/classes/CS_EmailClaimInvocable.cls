/**
 * @description       : 
 * @author            : diego.jacanamijoy@gmail.com
 * @group             : 
 * @last modified on  : 05/03/2024
 * @last modified by  : diego.jacanamijoy@vass.com
**/
public class CS_EmailClaimInvocable {
    public class request 
    {
        @InvocableVariable(label='Records' description='A Single Sobject record')
        public list<sObject> records;
        
  	}

    public class response 
    {
  		@InvocableVariable(label='A string value returned' description='A result for an action executed ' )
  		public string stringValue;         
        @InvocableVariable(label='Records' description='A Single Sobject record')
        public list<sObject> records;
        
  	}
    
     @InvocableMethod
  	public static list<response> execute (list<request> requests)
    {
        response res = new response();
        String Documents = '';
        list<Claim> newClaim = (list<Claim>)requests[0].records;
        
        List<ClaimCoverage> ClaimCoverageList = new list<ClaimCoverage>([Select id, InsurancePolicyCoverage.CategoryGroupType from ClaimCoverage where ClaimId=:newClaim[0].Id limit 1]);
		
        if(ClaimCoverageList.size()>0){
            
            List <ContentDocumentLink> CDlist = [SELECT ContentDocumentId, LinkedEntityId, ContentDocument.LatestPublishedVersion.VersionData, ContentDocument.LatestPublishedVersion.DocumentCode_fileupload__c FROM ContentDocumentLink where LinkedEntityId =: newClaim[0].Id];
            
            List<DocumentsByCoverage__mdt> DocByCovList = new list<DocumentsByCoverage__mdt>([Select CoverageType__r.CoverageCode__c, DocumentSetting__r.DocumentDescription__c, DocumentSetting__r.DocumentCode__c from DocumentsByCoverage__mdt where CoverageType__r.CoverageCode__c =:Decimal.valueOf(ClaimCoverageList[0].InsurancePolicyCoverage.CategoryGroupType)]);
                
            if(DocByCovList.size()>0){
                
                if(CDlist.size()>0){
                    
                    Map<String,String> DocMap = new Map<String,String>();
                    for(ContentDocumentLink cdl:CDlist){
                        DocMap.put(cdl.ContentDocument.LatestPublishedVersion.DocumentCode_fileupload__c,cdl.ContentDocument.LatestPublishedVersion.DocumentCode_fileupload__c);
                    }
                    List<String> DocFaltantesList = new List<String>();
                    for(DocumentsByCoverage__mdt Doc:DocByCovList){
                        if(!DocMap.containsKey(String.valueOf( Integer.valueOf(Doc.DocumentSetting__r.DocumentCode__c)))){
                            DocFaltantesList.add(Doc.DocumentSetting__r.DocumentDescription__c);
                        }
                    }
                    if(DocFaltantesList.size()>0){
                        
                        Documents='<p>Documentos Faltantes:</p>';
                        Documents+='<ul>';
                        for(Integer i = 0; i < DocFaltantesList.size(); i++){
                            Documents+='<li>';
                            Documents+= DocFaltantesList[i];
                            Documents+='</li>';
                        }
                        Documents+='</ul>';
                        
                    }
                    
                }else{
                    if(DocByCovList.size()>0){
                        Documents='<p>Documentos Faltantes:</p>';
                        Documents+='<ul>';
                        for(DocumentsByCoverage__mdt Doc:DocByCovList){
                            Documents+='<li>';
                            Documents+= Doc.DocumentSetting__r.DocumentDescription__c;
                            Documents+='</li>';
                        }
                        Documents+='</ul>';
                    }
                }
                if(Documents!='' || newClaim[0].CS_DocumentosFaltantes__c <> ''){
                    Claim NClaim= new Claim();
                    NClaim.Id = newClaim[0].Id;
                    NClaim.CS_DocumentosFaltantes__c	=Documents;
                    update NClaim;
                }                
            }
             
        }
        res.stringValue =newClaim[0].Id;
        res.records =newClaim ; 
		        
        return new list<response>{res};
    
    }
}