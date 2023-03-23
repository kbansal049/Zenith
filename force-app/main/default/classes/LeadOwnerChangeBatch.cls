global class LeadOwnerChangeBatch implements Database.Batchable<sObject>, Database.Stateful{
    ZscalerBatchFramework zscalerBatchFrameWorkObj = new ZscalerBatchFramework('LeadOwnerChangeBatch');
    public Set<Id> recIds = new Set<Id>();
    global LeadOwnerChangeBatch(Set<Id> ids){
        recIds = ids ;
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
        this.zscalerBatchFrameWorkObj.callStart();
        String query = 'SELECT Id,Lead_Development__c,OwnerId From Lead  '+ (recIds.isEmpty() ? ' WHERE Owner.Name=\'Marketo Admin\' AND Lead_Development__c!=NULL ' : ' WHERE ID IN:recIds') ;
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc, List<Lead> scope){
        this.zscalerBatchFrameWorkObj.callExecute(scope[0]?.Id, scope.size());
        for(Lead l: scope){ 
            l.ownerId = l.Lead_Development__c;
        }
        TriggerHandler.bypass('LeadTriggerHandler');
        Database.update (scope,false);
        TriggerHandler.clearBypass('LeadTriggerHandler');
    }
    
    global void finish(Database.BatchableContext BC){
        this.zscalerBatchFrameWorkObj.callFinish(BC);
    }
    
}