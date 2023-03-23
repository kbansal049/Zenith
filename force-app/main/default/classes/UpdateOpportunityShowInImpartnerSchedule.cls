global class UpdateOpportunityShowInImpartnerSchedule implements Schedulable{
    global void execute(SchedulableContext ctx){
        string batchSize = ZscalerSetting__c.getValues('UpdateOpportunityShowInImpartnerSize').Value__c;
        UpdateOpportunityShowInImpartnerBatch currentBatchJob = new UpdateOpportunityShowInImpartnerBatch();
        Database.executeBatch(currentBatchJob, ((batchSize != null && batchSize.isNumeric()) ? Integer.valueOf(batchSize) : 5));
    }
}