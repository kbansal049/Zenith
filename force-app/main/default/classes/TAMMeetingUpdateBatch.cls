public class TAMMeetingUpdateBatch implements Database.Batchable<sObject>, Database.Stateful{
    ZscalerBatchFramework zb = new ZscalerBatchFramework('TAMMeetingUpdateBatch');
    public string query; 
    
    public TAMMeetingUpdateBatch(String query){
        this.query = query;
        /*'select Id, Account__c, TAM_Weekly_DateTime__c from Account_Extension__c'*/
    }
    
    public Database.QueryLocator start(Database.BatchableContext context){
        this.zb.callStart();
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext context, List<Account_Extension__c> scope){
        this.zb.callExecute(scope[0]?.Id, scope.size());
        Map<Id,Account_Extension__c> lstAccExt = new Map<Id,Account_Extension__c>();
        Set<Id> acctIds = new Set<Id>();
        Map<Id,Id> accVsAccExt = new Map<Id,Id>();
        
        for(Account_Extension__c ex: scope){
            acctIds.add(ex.Account__c);
            lstAccExt.put(ex.Id, ex);
            accVsAccExt.put(ex.Account__c, ex.Id);
        }
        
        List<AggregateResult> maxMeeting = [SELECT Customer_Name__c, Max(Date_of_meeting__c) 
                                                        FROM Meeting__c 
                                                        WHERE Status__c = 'Completed' AND Customer_Name__c IN: acctIds
                                                        GROUP BY Customer_Name__c];
                                                        
        List<Account_Extension__c> lstToUpdate = new List<Account_Extension__c>();
        
        for(AggregateResult result : maxMeeting){
            Id accountId = String.valueOf(result.get('Customer_Name__c'));
            DateTime maxDate = DateTime.valueOf(result.get('expr0'));
            if(maxDate != null){
                if(accVsAccExt.containsKey(accountId) && (maxDate > lstAccExt.get(accVsAccExt.get(accountId)).TAM_Weekly_DateTime__c || lstAccExt.get(accVsAccExt.get(accountId)).TAM_Weekly_DateTime__c == null)){
                    Account_Extension__c accExtToUpdate = lstAccExt.get(accVsAccExt.get(accountId)); 
                    accExtToUpdate.TAM_Weekly_DateTime__c = maxDate;
                    lstToUpdate.add(accExtToUpdate);
                }
            }
        }
        if(lstToUpdate.size() > 0 && !lstToUpdate.IsEmpty()){
            update lstToUpdate;
        }
    }
    
    public void finish(Database.BatchableContext context){
        this.zb.callFinish(context);
    }

}