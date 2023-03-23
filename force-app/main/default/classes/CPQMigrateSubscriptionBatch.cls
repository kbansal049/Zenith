global class CPQMigrateSubscriptionBatch implements Database.Batchable<sObject>, Database.Stateful{
    ZscalerBatchFramework zb = new ZscalerBatchFramework('CPQMigrateSubscriptionBatch');
    global static Set<Id> accountId = new Set<Id>();
    global String query;
    
    global CPQMigrateSubscriptionBatch(string squery){
        query = squery;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        this.zb.callStart();
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Contract_Detail__c> scope){
        this.zb.callExecute(scope[0]?.Id, scope.size());
        Set<Id> cdIds = new Set<Id>();
        Map<Id,Id> subscriptionMap = new Map<Id,Id>();
        List<Contract_Detail__c> updateList = new List<Contract_Detail__c>();
        for(Contract_Detail__c cd : scope){
            cdIds.add(cd.Id);
        }
        List<SBQQ__Subscription__c> subList =  [SELECT Id,Contract_Detail__c FROM SBQQ__Subscription__c WHERE Contract_Detail__c IN : cdIds];
        for(SBQQ__Subscription__c sb : subList){
            if(sb.Contract_Detail__c != NULL){
                subscriptionMap.put(sb.Contract_Detail__c,sb.Id);    
            } 
        }
        for(Contract_Detail__c cd : scope){
            if(subscriptionMap.containsKey(cd.Id)){
                cd.Subscription__c = subscriptionMap.get(cd.Id);
                updateList.add(cd);
            }
        }
        if(!updateList.isEmpty() && updateList != NULL){
            update updateList;    
        }
    }
    global void finish(Database.BatchableContext BC){
        this.zb.callFinish(BC);
        String query = 'Select id from sbqq__subscription__c where SBQQ__Bundle__c = TRUE AND SBQQ__contract__r.Migrated_contract__c = TRUE AND sbqq__quoteline__c = NULL AND No_of_Platform_SKUS__c = NULL';
        if(Test.isRunningTest()){
            query = 'Select id from sbqq__subscription__c';    
        }
        cpqPlatformsubscriptionBatch rs = new cpqPlatformsubscriptionBatch(query);
        Database.executeBatch(rs, 500);
    }     
}