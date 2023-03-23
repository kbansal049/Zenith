global class AccountRollupEnrolledUserBatchScheduler implements Schedulable
{
    global void execute(SchedulableContext SC) 
    {

        String query = 'SELECT Id FROM Account WHERE First_ZPA_Contract_Date__c != null and Type =\'Customer\'';
        AccountRollUpEnrolledUserBatch rollup = new AccountRollUpEnrolledUserBatch(query);
        
        Database.executeBatch(rollup,1);

    }

   
}