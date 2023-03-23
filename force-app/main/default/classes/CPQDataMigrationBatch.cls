global class CPQDataMigrationBatch implements Database.Batchable<sObject>{
    ZscalerBatchFramework zb = new ZscalerBatchFramework('CPQDataMigrationBatch');
    global static Set<Id> accountId = new Set<Id>();
    global final String query;
    
    global CPQDataMigrationBatch(string squery){
        query = squery;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){  
		this.zb.callStart(); 
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Account> scope){ 
		this.zb.callExecute(scope[0]?.Id, scope.size());
        Id AccId = scope[0].Id;
        if(AccId != NULL || String.valueof(AccId) != ''){
            string msg = MigrateToCPQController.convertToContract(AccId);
            Account acc = new Account(Id = AccId);
            acc.migration_error__c = msg;
            if(msg == 'Contract Detail records have been migrated successfully.'){
                acc.Is_Migrated__c = true;
            }
            else{
                acc.Is_Migrated__c = false;    
            }
            update acc; 
        }
    }
    global void finish(Database.BatchableContext BC){  
        this.zb.callFinish(bc);
        String query = 'SELECT ID,Subscription__c FROM Contract_Detail__c WHERE Subscription__c = NULL AND Contract_detail_Status__c IN (\'Active\',\'Pending Renewal\') AND Ignore_Migration__c = FALSE';
        CPQMigrateSubscriptionBatch cp = new CPQMigrateSubscriptionBatch(query);
        Database.executeBatch(cp, 10);
    } 
    
}