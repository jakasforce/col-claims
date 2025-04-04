global class CaseTaskWrapper {
        //public string msg;
        public String Id;
        public String CaseNumber;
    	public String NumberATEL;
        public String RecordTypeName;
        public String Description;
        public String CS_MacroReason;
        public String CS_SubReason;
        public String Status;
        public String CS_TentativeClosingDate;
        public String CS_TrafficLightString;
    	public String RecordTypeClaimName;
    	public Date salesforceFilingDate;
    	public List<TaskWrapper> taskWrapper;
    
    public CaseTaskWrapper(Case c, Claim claim) {
            if (c != null) {
                this.Id = c.Id;
                this.CaseNumber = !String.isBlank(c.CaseNumber) ? c.CaseNumber : '';
                this.RecordTypeName = c.RecordType.Name;
                this.Description = !String.isBlank(c.Description) ? c.Description : '';
                this.CS_MacroReason = !String.isBlank(c.CS_MacroMotivo__c) ? c.CS_MacroMotivo__c : '';
                this.CS_SubReason = !String.isBlank(c.CS_Submotivo__c) ? c.CS_Submotivo__c : '';
                this.Status = c.Status;
                this.CS_TentativeClosingDate = !String.isBlank(String.valueOf(c.CS_FechaTentativaDeCierre__c)) ? String.valueOf(c.CS_FechaTentativaDeCierre__c.year())+ '-' + String.valueOf(c.CS_FechaTentativaDeCierre__c.month()).leftPad(2, '0') + '-' + String.valueOf(c.CS_FechaTentativaDeCierre__c.day()).leftPad(2, '0') : '';
                this.CS_TrafficLightString = !String.isBlank(c.CS_Semaforotexto__c) ? c.CS_Semaforotexto__c : '';
                this.NumberATEL = claim.Name;
                this.RecordTypeClaimName = claim.RecordType.Name;
                this.salesforceFilingDate = c.CS_Fecha_de_radicacion_en_la_Compania__c;
            }
        }

}