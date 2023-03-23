//Added by Varun for CR 995
global class CustomerScorecardBatchSch implements Schedulable {

    global CustomerScorecardBatchSch() {}

    global void execute(SchedulableContext SC)    
    {
        Database.executeBatch(new CleanCustomerScorecardBatch('Select Id FROM Customer_Score_Card__c'), 200);
    }
}