// Created by Harish for CR 1141
global class AccountTotalUniqueClientUsersBatch implements Database.Batchable<sObject>, Database.Stateful {
    ZscalerBatchFramework zb = new ZscalerBatchFramework('AccountTotalUniqueClientUsersBatch');
    @TestVisible
    private Set<Id> recIds;
      
    global AccountTotalUniqueClientUsersBatch(Set<Id> ids){
         recIds = ids ;   
    }
    global Database.QueryLocator start(Database.BatchableContext bc) {
        this.zb.callStart();
        return Database.getQueryLocator(
            'SELECT Id, ZApp_Registered_Devices__c FROM Account ' + (recIds.isEmpty() ? ' WHERE type in (\'Customer\', \'Ex-Customer\') ' : ' WHERE ID IN:recIds')
        );
    }
    
    global void execute(Database.BatchableContext bc, List<Account> scope){
        this.zb.callExecute(scope[0]?.Id, scope.size());
        Map<Id,List< Zscaler_Cloud_ID__c >> accZsciListMap = getLatestAuthUserCount(scope); 
        
        for(Account acc : scope){
            Decimal cnt = 0.00;
            for(Zscaler_Cloud_ID__c zci : (!accZsciListMap.isEMpty() && accZsciListMap.containsKey(acc.Id)) ? accZsciListMap.get(acc.Id) : new List<Zscaler_Cloud_ID__c>()){  
                for(BWC_Data__c bwc : zci.BWC_Data__r.isEMpty() ? new List<BWC_Data__c>() : zci.BWC_Data__r){
                    cnt = cnt + (bwc.Total_Unique_Users__c!=NULL ? bwc.Total_Unique_Users__c : 0.00);
                }
            }
            acc.ZApp_Registered_Devices__c = cnt ;
        }
        TriggerHandler.bypass('AccountTriggerHnadler');
        Database.update(scope,false);
                    
    }    

    global void finish(Database.BatchableContext bc){
        this.zb.callFinish(bc);
        
    } 
    
    @TestVisible
    private static Map<Id,List< Zscaler_Cloud_ID__c >> getLatestAuthUserCount(List<Account> accs){
        Map<Id,List< Zscaler_Cloud_ID__c >> accLatestAuthUserCntMap = new Map<Id,List< Zscaler_Cloud_ID__c >>();
        
        for(Zscaler_Cloud_ID__c zsci : [SELECT id,Account__c,(SELECT id, Total_Unique_Users__c,Cloud_ID__c 
                                        FROM BWC_Data__r WHERE is_Current_Month__c=TRUE AND Type__c='ZIA' AND Total_Unique_Users__c!=null)
                                        FROM Zscaler_Cloud_ID__c 
                                        WHERE Cloud_Type__c ='ZIA'
                                        AND Account__c IN : accs
                                        ])
        {
            if(!accLatestAuthUserCntMap.containsKey(zsci.Account__c))
                accLatestAuthUserCntMap.put(zsci.Account__c,new List<Zscaler_Cloud_ID__c>());
                
            List<Zscaler_Cloud_ID__c> cloudIds = accLatestAuthUserCntMap.get(zsci.Account__c);
            cloudIds.add(zsci);
            accLatestAuthUserCntMap.put(zsci.Account__c,cloudIds);  
                                        
        }
        return accLatestAuthUserCntMap;
    }
}