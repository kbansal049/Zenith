global class ContactCloseFieldUpdateBatch implements Database.Batchable<sObject>,Schedulable,Database.Stateful {
    ZscalerBatchFramework zb = new ZscalerBatchFramework('ContactCloseFieldUpdateBatch');
	global Database.QueryLocator start(Database.BatchableContext bc) {
        this.zb.callStart();
        
        String query;
        
        if(Test.isRunningTest()){
            query ='Select id,Contact_Lead_Status__c,Involved_in_Active_Oppty__c,Remarks__c FROM Contact where Contact_Lead_Status__c =\'Actively Engaged\' LIMIT 10';
        }else{
            query ='Select id,Contact_Lead_Status__c,Involved_in_Active_Oppty__c,Remarks__c FROM Contact where Days_since_last_activity__c > 60 and Contact_Lead_Status__c =\'Actively Engaged\' and Involved_in_Active_Oppty__c  = false';
        }
        
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc, List<Contact> records){
        this.zb.callExecute(records[0]?.Id, records.size());
        for(Contact con: records){
            con.Contact_Lead_Status__c = 'Recycled to Marketing';
            con.Remarks__c = 'Replied: Not Interested';
            
            //Added Funnel_Stage_Date__c and Funnel_Stage__c to avoid impact of contact trigger bypass
            con.Funnel_Stage_Date__c = NULL;
            con.Funnel_Stage__c = 'Inactive';
        }
        try{
            triggerUtility.afterUpdateRelatedContactExecuted();
            TriggerHandler.bypass('genericContactTrigger');
            update records;
            TriggerHandler.clearBypass('genericContactTrigger');
            triggerUtility.afterUpdateRelatedContactExecutedReset();
        }catch(Exception e){
            //updated by Akash 1: CR# 5023 start
            ZscalerErrorLogsUtility.insertlogsForAsync('ContactCloseFieldUpdateBatch', 'execute', 'Async Apex',userInfo.getUserId(),'Sales cloud', e.getStackTraceString(), e.getMessage(), e.getTypeName());
            //updated by Akash 1: CR# 5023 end
        }
    }    
    
    global void finish(Database.BatchableContext bc){
        
        this.zb.callFinish(bc);
        
    }  
    global void execute(SchedulableContext sc) {
        ContactCloseFieldUpdateBatch b = new ContactCloseFieldUpdateBatch(); 
        database.executebatch(b,100);
    }
}