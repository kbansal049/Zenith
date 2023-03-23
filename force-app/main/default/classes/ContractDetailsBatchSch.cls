global class ContractDetailsBatchSch implements Schedulable{
    global void execute(SchedulableContext SC) { 
        string query = null;
        contractDetailsBatch contractDetailBatch = new contractDetailsBatch(query);   
        Integer batchSize = Test.isRunningTest() ? 200 : 50;
        Database.executeBatch(contractDetailBatch,batchSize);
    }
}