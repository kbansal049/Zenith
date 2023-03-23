global class AccountCustomerScorecardUpdateBatch implements Database.Batchable<sObject>, Database.Stateful{
    ZscalerBatchFramework zb = new ZscalerBatchFramework('AccountCustomerScorecardUpdateBatch');

    
    private string query; 
    
    global AccountCustomerScorecardUpdateBatch(String query){
        this.query = query;
        //'select Id,Customer_Scorecard__c,(select id,Name from Customer_Score_Card__r) from account'
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        this.zb.callStart();
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC,List<Account> scope){
        this.zb.callExecute(scope[0]?.Id, scope.size());
        
        List<Account> accountsToUpdate = new List<Account>();
        for(Account acc:scope){
            if(!acc.Customer_Score_Card__r.isempty())
                acc.Customer_Scorecard__c = acc.Customer_Score_Card__r[0].Id;
                accountsToUpdate.add(acc);
        }
       
        Database.update(accountsToUpdate);

    }
    
    global void finish(Database.BatchableContext BC){
        this.zb.callFinish(BC);
        
    }
}