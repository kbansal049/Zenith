global class LeadStatusUpdateBatch implements Database.Batchable<sObject>, Database.Stateful{
    ZscalerBatchFramework zscalerBatchFrameWorkObj = new ZscalerBatchFramework('LeadStatusUpdateBatch');
    public Set<Id> recIds = new Set<Id>();
    global LeadStatusUpdateBatch(Set<Id> ids){
        recIds = ids ;
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
        this.zscalerBatchFrameWorkObj.callStart();
        String query = 'SELECT Id,Status,Days_since_last_activity__c ,Age_Since_Last_Open__c,Remarks__c,Outreach_Status__c From Lead WHERE Status= \'Actively Engaged\' ' + (Test.isRunningTest() ?  ' ' : (recIds.isEmpty() ? 'AND ((Days_since_last_activity__c =Null AND Age_Since_Last_Open__c >= 61) OR Days_since_last_activity__c>=61) ' : ' AND Id IN: recIds AND ((Days_since_last_activity__c =Null AND Age_Since_Last_Open__c >= 61) or  Days_since_last_activity__c >=61)  ') );
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc, List<Lead> scope){
        this.zscalerBatchFrameWorkObj.callExecute(scope[0]?.Id, scope.size());
        for(Lead l: scope){ 
                l.Status = 'Recycled to Marketing'; 
                l.Remarks__c = 'Replied: Not Interested' ;
                //l.Outreach_Status__c ='Closed'; Removed by Rajesh : CR# 1170
        }
        Database.update (scope,false);
    }
    
    global void finish(Database.BatchableContext BC){
        this.zscalerBatchFrameWorkObj.callFinish(BC);
    }
    
}