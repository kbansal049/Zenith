//Added by Abhijit for CR549
global class UpdateContactPortalUserBatch implements Database.Batchable<sObject>, Database.Stateful {
    ZscalerBatchFramework zb = new ZscalerBatchFramework('UpdateContactPortalUserBatch');
    Boolean runCheckPortalUser = false;
    Boolean runUnCheckPortalUser = false;   
    String batchSoql;
    public List<String> errorlst = new List<String>();
    public List<String> successlst = new List<String>();  
    public string batchjobname = 'Contact Portal User Job';       

    public UpdateContactPortalUserBatch(String soql, String str){
        if(str == 'checkportaluser'){
            runCheckPortalUser = true;
        }else if(str == 'uncheckportaluser'){
            runUnCheckPortalUser = true;
        }
        batchSoql = soql;

    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        this.zb.callStart();
        return Database.getQueryLocator(batchSoql);
    }
    
    global void execute(Database.BatchableContext bc, List<Contact> scope){
        this.zb.callExecute(scope[0]?.Id, scope.size());
        TriggerHandler.bypass('ContactTriggerHandler');     
        system.debug('aaaaa - - ' + runCheckPortalUser + ' -  ' + runUnCheckPortalUser);
        for(Contact contactUser:scope){
            if(runCheckPortalUser){
                contactUser.Portal_User__c = true;                   
            }else if(runUnCheckPortalUser){
                contactUser.Portal_User__c = false;                   
            }
        }
        system.debug('bbbbb - - ' + scope);
        
       Database.SaveResult[] srList = database.update(scope, false);
        for (Database.SaveResult sr : srList) {
            if (sr.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
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
        this.zb.callFinish(BC);
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