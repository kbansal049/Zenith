global class BatchToUpdateTaskField implements Database.Batchable<sObject>, Database.Stateful
{
    ZscalerBatchFramework zb = new ZscalerBatchFramework('BatchToUpdateTaskField');
    public List<String> errorlst = new List<String>();
    public List<String> successlst = new List<String>();
    public string batchjobname = 'Job to update Task Field based on contact object';
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        this.zb.callStart();
        //query on Task
        String query = 'SELECT Id, SDR_Qualified__c FROM Task WHERE SDR_Qualified__c = true and WhoId IN (SELECT Id FROM Lead where Qualifying_SDR__c = Null Or (Qualifying_SDR__c != Null And Qualification_Status__c!=Null) ) and WhoCount<=1 and Type in (\'Discovery\',\'Discovery Meeting\',\'NBM (New Business Meeting)\')';
		
        return Database.getQueryLocator(query);
    }
   
    global void execute(Database.BatchableContext BC, List<Task> scope)
    {
        this.zb.callExecute(scope[0]?.Id, scope.size());
         for(Task a : scope) 
         {
             a.SDR_Qualified__c = false;            
         }
        TriggerUtility2.updateTaskRelatedContOrLeadExecuted();
        TriggerUtility2.updateTouchesSinceLastOpenExecuted();
        TriggerUtility.campMemActivityExecuted();
        TriggerUtility.ActivityleadterritoryinsertExecuted();
        TriggerUtility.ActivityleadterritoryupdateExecuted();
        TriggerUtility.ActivityleadterritoryEventinsertExecuted();
        TriggerUtility.ActivityleadterritoryEventupdateExecuted();
        TriggerUtility.PopulateCampaignMostRecentOnTaskExecuted();
        CampaignTriggerHelper.setTriggerUtilityFlags();
        update scope;
        
    }   
    global void finish(Database.BatchableContext BC)
    {
        this.zb.callFinish(BC);
    }
}