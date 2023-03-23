public class DeleteActionPlanBatch implements Database.Batchable<sObject>,  Database.Stateful{
    ZscalerBatchFramework zscalerBatchFrameWorkObj = new ZscalerBatchFramework('DeleteActionPlanBatch');
    public string query;
    public DeleteActionPlanBatch(){
        this.query = 'Select Created_Date__c,Name,Priority__c,Visible_in_Doc__c,Owner__c,Due_Date__c,Status__c,Detail_TAM_Notes__c FROM Action_Plan__c where Due_Date__c < today';
    }
    public Database.QueryLocator start(Database.BatchableContext context){
        this.zscalerBatchFrameWorkObj.callStart();
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext context, List<Action_Plan__c> scope){
        this.zscalerBatchFrameWorkObj.callExecute(scope[0]?.Id, scope.size());
        if(!scope.isEmpty()){
            Database.delete(scope,false);
        }
    }
    public void finish(Database.BatchableContext bc){
        this.zscalerBatchFrameWorkObj.callFinish(bc);
        // execute any post-processing operations
    }
}