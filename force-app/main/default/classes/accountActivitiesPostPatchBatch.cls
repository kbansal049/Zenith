public class accountActivitiesPostPatchBatch implements Database.Batchable<SObject>,Database.Stateful {
    ZscalerBatchFramework zb = new ZscalerBatchFramework('accountActivitiesPostPatchBatch');
    private List<Id> recordIds;
    
    public accountActivitiesPostPatchBatch(List<Id> patchIds){
        this.recordIds = patchIds;
    }
    
    public Database.QueryLocator start(Database.BatchableContext context) {
        this.zb.callStart();
        if(recordIds != null && !recordIds.isEmpty()){
            return Database.getQueryLocator('Select Id from Account Where Patch__c IN: recordIds');
        }
        else{
            return Database.getQueryLocator('Select Id from Account');
        }
    }
    
    public void execute(Database.BatchableContext context, Account[] accounts) {
        this.zb.callExecute(accounts[0]?.Id, accounts.size());
            
        List<Event> eventlst = [Select Id, WhoId, WhatId, Account.Sales_Territory__r.Name, Account.Sales_Territory__r.Area__c, Account.Sales_Territory__r.Theater__c, Account.Territory_Type__c, Sales_Territory__c, Territory_Area__c, Territory_Geo__c, Territory_Type__c from Event where AccountId in :accounts and IsChild=false and isrecurrence = false AND EndDateTime >= :System.now()];
        for(Event eventRec : eventlst){
            eventRec.Sales_Territory__c = eventRec.Account.Sales_Territory__r.Name;
            eventRec.Territory_Area__c = eventRec.Account.Sales_Territory__r.Area__c;
            eventRec.Territory_Geo__c = eventRec.Account.Sales_Territory__r.Theater__c;
            eventRec.Territory_Type__c = eventRec.Account.Territory_Type__c;
        }
        TriggerUtility.AcctoActivityTerritoryExecuted();
        //IBA-5765 - Added TriggerHandler.byPass
        TriggerHandler.byPass('LeadTriggerHandler');
        TriggerHandler.byPass('AccountTriggerHandler');
        TriggerHandler.byPass('OpportunityTriggerHandler');
        TriggerHandler.byPass('ContactTriggerHandler');
        TriggerHandler.byPass('TaskTriggerHandler');
        TriggerHandler.byPass('EventTriggerHandler');
        update eventlst;
        TriggerHandler.clearBypass('LeadTriggerHandler');
        TriggerHandler.clearBypass('AccountTriggerHandler');
        TriggerHandler.clearBypass('OpportunityTriggerHandler');
        TriggerHandler.clearBypass('ContactTriggerHandler');
        TriggerHandler.clearBypass('TaskTriggerHandler');
        TriggerHandler.clearBypass('EventTriggerHandler');
    }
    
    public void finish(Database.BatchableContext context) {
        this.zb.callFinish(context);
        if(!test.isRunningTest()){
            Database.executeBatch(new oppTeamQuoteAndProdConfigShareBatch(), 10);
        }
    }
}