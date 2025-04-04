/***************************************************************************************************************************
 * Nombre de la Clase Apex : CS_ClaimUtilsInvocable
 * Versión                 : 1.0
 * Fecha de Creación       : 19/07/2024
 * Funcionalidad           : Busqueda de usuario o cola a asignar.
 * Clase Test			   : CS_ClaimUtilsInvocable_Test
 *--------------------------------------------------------------------------------------------------------------------------
 **************************************************************************************************************************/
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
        String idOwner;
        if (requests[0].action ==1){
            LIST<Group> grupo = [Select id,(Select id, Group.DeveloperName,UserOrGroupId from GroupMembers) FROM group where DeveloperName=:requests[0].stringFormat];
            list<GroupMember> gmList = new list<GroupMember>();
            if(grupo[0].GroupMembers.size()>0){
                for(GroupMember gMember: grupo[0].GroupMembers){
                    gmList.add(gMember);
                }
            }
            set<Id> IdsMember = new set<Id>();
            List<User> userAssign = new List<User>();
            list<Sobject > newObject = (list<Sobject >)requests[0].records;
            if(gmList.size()>0){
                for(GroupMember gm:gmList){
                    IdsMember.add(gm.UserOrGroupId);
                }
                userAssign = [Select id,Fecha_Ultima_Asignacion__c  from user where id in:IdsMember and isActive =true order by Fecha_Ultima_Asignacion__c  asc limit 1];
                if(userAssign.size()>0){
                    for (Sobject obj : newObject)
                    {
                        obj.put('ownerid',userAssign[0].Id);  
                        idOwner = userAssign[0].Id;
                        
                    }
                    update newObject; 
                    userAssign[0].Fecha_Ultima_Asignacion__c  = system.now();
                    update userAssign;
                }
            }
            else{
                for (Sobject obj : newObject)
                {
                    obj.put('ownerid',grupo[0].id);
                    idOwner = grupo[0].id;
                }                
                update newObject;
            }
            res.stringValue =idOwner;
            res.records =newObject;   
        }
        
        return new list<response>{res};
    }

}