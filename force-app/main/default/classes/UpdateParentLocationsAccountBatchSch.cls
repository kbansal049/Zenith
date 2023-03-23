//Added by Abhijit for CR1001
global class UpdateParentLocationsAccountBatchSch implements Schedulable{

    global UpdateParentLocationsAccountBatchSch() {}

    global void execute(SchedulableContext SC)    
    {
        Database.executeBatch(new UpdateParentLocationsAccountBatch('select id from Account'), 100);
    }
}