public class AccountSyncToJIRABatch  implements Database.Batchable<sObject>, Database.Stateful {
    ZscalerBatchFramework zb = new ZscalerBatchFramework('AccountSyncToJIRABatch');

    String batchSoql;
   
    public AccountSyncToJIRABatch(){}
    
    public AccountSyncToJIRABatch(String soql){
        batchSoql = soql;
    }
   
    public Database.QueryLocator start(Database.BatchableContext bc) {
        this.zb.callStart();
        batchSoql = batchSoql == null ? 'Select id,Sync_To_JIRA__c from Account_Extension__c where Sync_To_JIRA__c = \'Sync to JIRA Failed\'' : batchSoql;
        return Database.getQueryLocator(batchSoql);
    }
    
    public void execute(Database.BatchableContext bc, List<Account_Extension__c> scope){
        this.zb.callExecute(scope[0]?.Id, scope.size());
        List<Account_Extension__c> aeUpdateList = new List<Account_Extension__c>();
        for (Account_Extension__c ae : scope) {
            if(ae.Sync_To_JIRA__c == 'Sync to JIRA Failed'){
                ae.Sync_To_JIRA__c = 'Sync SFDC Account to JIRA';
                aeUpdateList.add(ae);
            }
        }
        
        update aeUpdateList;
    }
    
    public void finish(Database.BatchableContext bc){
        this.zb.callFinish(bc);
       
    }  
}