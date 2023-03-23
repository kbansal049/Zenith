/************************************************************************************************************************************
 * Name: RenewContractBatchSchedulable 
 * Description: Scheduable for RenewContractBatch
************************************************************************************************************************************/ 
global class RenewContractBatchSchedulable implements Schedulable {
    
    global void execute(SchedulableContext ctx) {
        RenewContractBatch batchObject = new RenewContractBatch();
        Id batchId = Database.executeBatch(batchObject, 1);
    }
    
}