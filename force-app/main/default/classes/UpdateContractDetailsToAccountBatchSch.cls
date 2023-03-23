/*
 * @description       : 
 * Modifications Log 
 * Ver   Date         Author        Modification
 * 1.0   11-15-2021   Bharath R.    Initial Version
*/

global class UpdateContractDetailsToAccountBatchSch implements Schedulable{
    global void execute(SchedulableContext SC) 
    { 
        UpdateContractDetailsToAccountBatch rollup = new UpdateContractDetailsToAccountBatch();   
        Integer batchSize = Test.isRunningTest() ? 200 : 1;
        Database.executeBatch(rollup,batchSize);
    }
}