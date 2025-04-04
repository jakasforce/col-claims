public class CS_ClaimUtilsInvocable {
    public class request 
    {
  		@InvocableVariable(label='Datetime Value' description='This value will be used by the action selected')
  		public datetime datetimeValue;         
        @InvocableVariable(label='String Format' description='This will be used to format the output')
  		public string stringFormat;         
        @InvocableVariable(label='1=Run Claim Assigment Rule' description='Action to be executed')
        public integer action;
        @InvocableVariable(label='Records' description='A Single Sobject record')
        public list<sObject> records;
        
  	}
    
    public class response 
    {
  		@InvocableVariable(label='A string value returned' description='A result for an action executed ' )
  		public Id stringValue;         
        @InvocableVariable(label='Records' description='A Single Sobject record')
        public list<sObject> records;
  	} 
    
    @InvocableMethod
  	public static list <response> execute (list<request> requests)
    {
        response res = new response();
        if (requests[0].action ==1){
            list<GroupMember> gmList = new list<GroupMember>();
            gmList =[Select id, Group.DeveloperName,UserOrGroupId from GroupMember where Group.DeveloperName=:requests[0].stringFormat];
            set<Id> IdsMember = new set<Id>();
            List<User> userAssign = new List<User>();
            list<Claim > newClaims = (list<Claim >)requests[0].records;
            if(gmList.size()>0){
                for(GroupMember gm:gmList){
                    IdsMember.add(gm.UserOrGroupId);
                }
                userAssign = [Select id,Fecha_Ultima_Asignacion__c  from user where id in:IdsMember and isActive =true order by Fecha_Ultima_Asignacion__c  asc limit 1];
                if(userAssign.size()>0){
                    for (Claim c : newClaims)
                    {
                        c.OwnerID=userAssign[0].Id;    
                    }
                    
                    update newClaims;
                    
                    userAssign[0].Fecha_Ultima_Asignacion__c  = system.now();
                    update userAssign;
                }
            }
            
            res.stringValue =newClaims[0].OwnerID;
            res.records =newClaims ;   
        }
        
        return new list<response>{res};
    }

}