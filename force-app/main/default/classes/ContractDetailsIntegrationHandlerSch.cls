/*
 * @description       : 
 * Modifications Log 
 * Ver   Date         Author        Modification
 * 1.0   12-06-2021   Mayank B.    Initial Version
*/

global class ContractDetailsIntegrationHandlerSch implements Schedulable{
    global void execute(SchedulableContext SC) 
    { 
        ContractDetailsIntegrationHandlerBatch rollup = new ContractDetailsIntegrationHandlerBatch();   
        Integer batchSize = Test.isRunningTest() ? 200 : 1;
        Database.executeBatch(rollup,batchSize);
    }
}