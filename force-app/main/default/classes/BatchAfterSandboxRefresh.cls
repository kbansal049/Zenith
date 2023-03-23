global class BatchAfterSandboxRefresh implements Database.Batchable<sObject>, Database.stateful{
    ZscalerBatchFramework zb = new ZscalerBatchFramework('BatchAfterSandboxRefresh');

    global string query;

    global Database.Querylocator start(Database.Batchablecontext BC){
        this.zb.callStart();
         return Database.getQueryLocator(query);
    }

    global void execute(Database.Batchablecontext BC, list<sObject> scope){
        this.zb.callExecute(scope[0]?.Id, scope.size());
        if(!test.isRunningTest()){
            Database.delete(scope, false);
            DataBase.emptyRecycleBin(scope);
        }
    }
    
    global void finish(Database.Batchablecontext BC){
        this.zb.callFinish(BC);
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String ToAddress = 'ldogra@zscaler.com';
        
        mail.setToAddresses(new String[] {ToAddress});
        mail.setSenderDisplayName('CopadoIntAdmin@zscaler.com');
        mail.setSubject('Sandbox Refresh Batch Completed for Org Id: ' + UserInfo.getOrganizationId());
        mail.setPlainTextBody('Sandbox Refresh Batch Completed');
        
        IF(!Test.isRunningTest())Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }   
}