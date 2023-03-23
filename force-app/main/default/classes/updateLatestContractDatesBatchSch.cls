global class updateLatestContractDatesBatchSch implements Schedulable
{
    global updateLatestContractDatesBatchSch()
    {
    }
    
    global void execute(SchedulableContext SC)
    {
        Integer batchSize = Integer.valueOf(Label.Contract_Dates);
        if(!Test.isRunningTest()){
            Database.executeBatch(new updateLatestContractDatesBatch('SELECT Id  FROM ACCOUNT WHERE Type = \'Customer\''),batchSize);
        }
     }
 }