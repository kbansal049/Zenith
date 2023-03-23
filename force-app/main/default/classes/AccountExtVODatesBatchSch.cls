global class AccountExtVODatesBatchSch implements Schedulable
{
    global AccountExtVODatesBatchSch()
    {
    }
    
    global void execute(SchedulableContext SC)
    {
        Integer batchSize = Integer.valueOf(Label.AccountVoDatesBatchSize);
        AccountExtVODatesBatch batch;
        batch = new AccountExtVODatesBatch(); //moved query to batch class
        if(!Test.isRunningTest()){
            Database.executeBatch(batch,batchSize);
        }
     }
 }