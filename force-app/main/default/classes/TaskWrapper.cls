public class TaskWrapper {
    
    //public String msg;
    public String id;
    public String Related; //Whatid
    public String recordTypeName;
    public String Subject; //Subject;
    public String Comment; //Description
    public String DueDate; //Fecha de vencimiento
    public String Assigned; //OwnerId.Account.name
    public String AssignedId;  //OwnerId
    public String Status; //Status
    public String CreateDate; // CreateDate
    
    public TaskWrapper(Task t) {
    	if (t != null) {
               this.Id               = t.id;
               this.Related      = t.WhatId;
               this.recordTypeName   = t.RecordType.name;
               this.Subject           = !String.isBlank(t.Subject) ? t.Subject : '';
               this.Comment       = !String.isBlank(t.Description) ? t.Description : '';
               this.DueDate = !String.isBlank(String.valueOf(t.ActivityDate)) ? String.valueOf(t.ActivityDate.year())+ '-' + String.valueOf(t.ActivityDate.month()).leftPad(2, '0') + '-' + String.valueOf(t.ActivityDate.day()).leftPad(2, '0') : '';
               this.AssignedId         = t.OwnerId;
          	   this.Assigned =	t.Owner.Name;
               this.Status           = t.Status;
               this.CreateDate    = !String.isBlank(String.valueOf(t.CreatedDate)) ? t.CreatedDate.format('yyyy-MM-dd') : '';
        }
    }
}