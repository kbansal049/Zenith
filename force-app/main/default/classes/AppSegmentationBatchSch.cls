global class AppSegmentationBatchSch implements Schedulable
{
    
    global AppSegmentationBatchSch()
    {
    }
    
    global void execute(SchedulableContext SC)
    {
        if(!Test.isRunningTest()){
            Database.executeBatch(new AppSegmentationBatch('SELECT Id  FROM ACCOUNT WHERE Type =\''+ L2O_Constants.AccountType.ACCOUNT_TYPE_CUSTOMER + '\''),1);
        }
     }
 }