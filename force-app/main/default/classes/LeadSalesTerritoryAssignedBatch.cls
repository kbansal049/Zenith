global class LeadSalesTerritoryAssignedBatch implements Database.Batchable<sObject>, Database.Stateful{
    ZscalerBatchFramework zscalerBatchFrameWorkObj = new ZscalerBatchFramework('LeadSalesTerritoryAssignedBatch');
    public Set<Id> recIds = new Set<Id>();
    global LeadSalesTerritoryAssignedBatch() {
        
    }
    global LeadSalesTerritoryAssignedBatch(Set<Id> ids){
        recIds = ids ;
    } 
    global Database.QueryLocator start(Database.BatchableContext BC){
        this.zscalerBatchFrameWorkObj.callStart();
        String query = 'SELECT Id,TriggerPatchAssignment__c,Territory__c From Lead  '+ (recIds.isEmpty() ? ' WHERE Owner.Name=\'Marketo Admin\' AND Territory__c=NULL ' : ' WHERE ID IN:recIds') ;
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc, List<Lead> scope){
        this.zscalerBatchFrameWorkObj.callExecute(scope[0]?.Id, scope.size());
       
        for(Lead l: scope){ 
            l.TriggerPatchAssignment__c = true;
        }
        //updated by Akash 1: CR# 5023 start
        try{
            Database.update (scope,false);
        }
        catch(Exception ex){
            ZscalerErrorLogsUtility.insertlogsForAsync('LeadSalesTerritoryAssignedBatch', 'execute', 'Async Apex',userInfo.getUserId(),'Sales cloud', ex.getStackTraceString(), ex.getMessage(), ex.getTypeName());
        }
        //updated by Akash 1: CR# 5023 end
       
    }
    
    global void finish(Database.BatchableContext BC){
        this.zscalerBatchFrameWorkObj.callFinish(BC);
        LeadOwnerChangeBatch b = new LeadOwnerChangeBatch(new Set<Id>());
        Database.executeBatch(b);
    }
    
}