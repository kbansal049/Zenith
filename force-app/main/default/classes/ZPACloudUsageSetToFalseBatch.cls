global class ZPACloudUsageSetToFalseBatch implements Database.Batchable<sObject>,  Database.Stateful{
    
    ZscalerBatchFramework zb = new ZscalerBatchFramework('ZPACloudUsageSetToFalseBatch');
    
    global Database.QueryLocator start(Database.BatchableContext context){
        this.zb.callStart();
        
        return Database.getQueryLocator([Select Id, Last_6_Months__c, ZPA_End_Date__c, Last_31_Days__c, Last_90_Days__c
                                         from Cloud_Usage__c WHERE Cloud_Usage_Type__c = 'ZPA'
                                         AND ZPA_End_Date__c != null AND ZPA_End_Date__c != LAST_N_DAYS:30 AND 
                                         Last_6_Months__c = TRUE]);
    }
    
    global void execute(Database.BatchableContext context, List<sObject> cloudUsageList){
        
        this.zb.callExecute('Cloud_Usage__c', cloudUsageList.size());
        
        try{
            
            list<Cloud_Usage__c> cloudUsageUpdateList = new list<Cloud_Usage__c>();
            map<id, Cloud_Usage__c> cloudUsageUpdateMap = new map<id, Cloud_Usage__c>();
            for(Cloud_Usage__c cloudUsage : (list<Cloud_Usage__c>)cloudUsageList){
                Cloud_Usage__c tempCloudUsage = new Cloud_Usage__c();
                tempCloudUsage = cloudUsage;
                tempCloudUsage.Last_31_Days__c = false;
                if(tempCloudUsage.ZPA_End_Date__c.addDays(180) < system.today()){
                    tempCloudUsage.Last_6_Months__c = false;
                }
                if(tempCloudUsage.ZPA_End_Date__c.addDays(90) < system.today()){
                    tempCloudUsage.Last_90_Days__c = false;
                }
                cloudUsageUpdateList.add(tempCloudUsage);
            }
            TriggerUtility.CustomerSuccessUpdatemethodsettrue();
            database.update(cloudUsageUpdateList, false);
        }
        catch(Exception ex){
            ZscalerErrorLogsUtility.insertlogsForAsync('ZPACloudUsageSetToFalseBatch', 'execute', 'Async Apex',userInfo.getUserId(),'Sales cloud', ex.getStackTraceString(), ex.getMessage(), ex.getTypeName());
        }
    }
    
    global void finish(Database.BatchableContext bc){
        this.zb.callFinish(bc);
    }
}