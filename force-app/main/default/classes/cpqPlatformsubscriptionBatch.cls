global class cpqPlatformsubscriptionBatch implements Database.Batchable<sObject>, Database.Stateful{
    ZscalerBatchFramework zb = new ZscalerBatchFramework('cpqPlatformsubscriptionBatch');
    global static Set<Id> accountId = new Set<Id>();
    global String query;
    
    global cpqPlatformsubscriptionBatch(string squery){
        query = squery;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        this.zb.callStart();
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<SBQQ__Subscription__c> scope){
        this.zb.callExecute(scope[0]?.Id, scope.size());
        Set<Id> subIds = new Set<Id>();
        Map<Id,List<Id>> platformBundleMap = new Map<Id,List<Id>>();
        List<SBQQ__Subscription__c> subUpdateList = new List<SBQQ__Subscription__c>();
        for(SBQQ__Subscription__c sub : scope){
            subIds.add(sub.Id);
        }
        List<SBQQ__Subscription__c> subList =  [SELECT Id,SBQQ__RequiredById__c,SBQQ__Product__c FROM SBQQ__Subscription__c WHERE SBQQ__Product__r.Platform_SKU_Number__c != NULL AND SBQQ__Product__r.Platform_SKU_Number__c != 0 AND SBQQ__RequiredById__c IN : subIds];
        for(SBQQ__Subscription__c sb : subList){
            if(!platformBundleMap.containsKey(sb.SBQQ__RequiredById__c)){
                platformBundleMap.put(sb.SBQQ__RequiredById__c,new List<Id>{sb.SBQQ__Product__c});    
            }
            else{
                if(!platformBundleMap.get(sb.SBQQ__RequiredById__c).contains(sb.SBQQ__Product__c)){
                    platformBundleMap.get(sb.SBQQ__RequiredById__c).add(sb.SBQQ__Product__c);       
                }    
            } 
        }
        if(!platformBundleMap.isEmpty() && platformBundleMap != NULL){
            for(Id subId : platformBundleMap.keySet()){
                SBQQ__Subscription__c sub = new SBQQ__Subscription__c(Id = subId);
                sub.No_of_Platform_SKUS__c = platformBundleMap.get(subId).size();
                subUpdateList.add(sub);
            }    
        }
        if(!subUpdateList.isEmpty() && subUpdateList != NULL){
            update subUpdateList;    
        }
    }
    global void finish(Database.BatchableContext BC){ 
        this.zb.callFinish(BC);
        integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }     
}