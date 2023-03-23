global class OpportunityNOTRABatch implements Database.Batchable<sObject>, Database.Stateful,  Schedulable {
    
    ZscalerBatchFramework zscalerBatchFrameWorkObj = new ZscalerBatchFramework('OpportunityNOTRABatch');
    
    //OpportunityNOTRABatch be = new OpportunityNOTRABatch();
    //database.executeBatch(be,200);
    
    global void execute(SchedulableContext SC) {
         OpportunityNOTRABatch be = new OpportunityNOTRABatch();
    	database.executeBatch(be,200);
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        this.zscalerBatchFrameWorkObj.callStart();
        String query = 'SELECT  type,Contract_End_Date_New__c, CRO_Forecast_Category__c, NOTRA__c, Id,NAME,CloseDate,Renewal_VP_In_my_Number__c,StageName,Prior_Early__c FROM Opportunity where CloseDate !=null';
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Opportunity> scope){
        this.zscalerBatchFrameWorkObj.callExecute(scope[0]?.Id, scope.size());
        Map <Id, Opportunity> newOpportunitiesMap = new Map<Id, Opportunity>(
            (List<Opportunity>)scope
        );
        //List<Opportunity> newOpportunitiesMap = (List<Opportunity>)scope;
        System.debug('---------->'+newOpportunitiesMap);
        List<Opportunity> oppToUpdate = OpportunityNOTRABatchHandler.beforeUpdate(newOpportunitiesMap);
        update oppToUpdate;
    }
    
    global void finish(Database.BatchableContext BC) {
        this.zscalerBatchFrameWorkObj.callFinish(BC);
        System.debug('Succesfull');
    }
    
}