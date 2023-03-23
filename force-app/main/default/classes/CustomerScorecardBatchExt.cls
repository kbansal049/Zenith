//Added by Varun, Rajesh for CR 995
global class CustomerScorecardBatchExt implements 
Database.Batchable<sObject>, Database.Stateful {
	ZscalerBatchFramework zb = new ZscalerBatchFramework('CustomerScorecardBatchExt');    
    global Integer recordsProcessed = 0;
    public List<String> errorlst = new List<String>();
    public List<String> successlst = new List<String>();  
    public string batchjobname = 'Customer Socercard Batch Job - CustomerScorecardBatchExt';
    public List<Customer_Score_Card__c> lstCustomer;
    
    public CustomerScorecardBatchExt(List<Customer_Score_Card__c> lstCustomer){
        this.lstCustomer = lstCustomer;
    }
    
    global List<Customer_Score_Card__c> start(Database.BatchableContext bc) {
        this.zb.callStart();
        return this.lstCustomer;
    }
    
    global void execute(Database.BatchableContext bc, List<Customer_Score_Card__c> scope){
        this.zb.callExecute(scope[0]?.Id, scope.size());
        Database.UpsertResult[] srList = Database.upsert(scope,false) ;
        for (Database.UpsertResult sr : srList) {
            if (sr.isSuccess()) {
                successlst.add(sr.getId());
            }
            else {
                for(Database.Error err : sr.getErrors()) {
                    errorlst.add(sr.getId() + ' - ' + err.getMessage());
                }
            }
        } 
    }

    
    global void finish(Database.BatchableContext bc){
        this.zb.callFinish(bc);
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'sfdcsupport@zscaler.com'];
        list<Messaging.SingleEmailMessage> messageList = new list<Messaging.SingleEmailMessage>();
        if(!errorlst.isEmpty()){
            Messaging.SingleEmailMessage mail1 = new Messaging.SingleEmailMessage();
            mail1.setToAddresses(new String[] {Label.BSYS_ALERT});
            if ( owea.size() > 0 ) {
                mail1.setOrgWideEmailAddressId(owea[0].Id);
            }else{
                mail1.setsenderDisplayName('Sales Ops System Admin');
            }
            mail1.setSubject(batchjobname + ' Batch Failure result');
            String msgbody = 'Below are the Ids of ' + errorlst.size() + ' records that have failed: \n';
            for(String s: errorlst){
                msgbody += s + '\n';
            }
            mail1.setPlainTextBody(msgbody);
            messageList.add(mail1);
        }
        if(!successlst.isEmpty()){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new String[] {Label.BSYS_INFO});
            if ( owea.size() > 0 ) {
                mail.setOrgWideEmailAddressId(owea[0].Id);
            }else{
                mail.setsenderDisplayName('Sales Ops System Admin');
            }
            mail.setSubject(batchjobname + ' Batch Success result ');
            mail.setPlainTextBody(batchjobname + ' Batch has been executed Successfully and processed '+ successlst.size() + ' records.');
            messageList.add(mail);
        }
        Messaging.sendEmail(messageList);
    }
}