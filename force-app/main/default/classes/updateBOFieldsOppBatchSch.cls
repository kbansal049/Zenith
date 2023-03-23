global class updateBOFieldsOppBatchSch implements Schedulable
{
    global updateBOFieldsOppBatchSch()
    {
    }
    
    global void execute(SchedulableContext SC)
    {
        Integer batchSize = Integer.valueOf(Label.OppBOBatchSize);
        updateBOFieldsOpp bch = new updateBOFieldsOpp('SELECT Id FROM Account Where Type =\''+L2O_Constants.AccountType.ACCOUNT_TYPE_CUSTOMER + '\'' + ' OR Type =' + '\''+L2O_Constants.AccountType.ACCOUNT_TYPE_PROSPECT +'\'');
        if(!Test.isRunningTest()){
            Database.executeBatch(bch,batchSize);
        }
     }
 }