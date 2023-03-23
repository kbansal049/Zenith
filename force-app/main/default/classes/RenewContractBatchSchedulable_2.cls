/************************************************************************************************************************************
 * Name: RenewContractBatchSchedulable_2 
 * Description: Scheduable for RenewContractBatch_2
************************************************************************************************************************************/ 
global class RenewContractBatchSchedulable_2 implements Schedulable {
    
    global void execute(SchedulableContext ctx) {
        RenewContractBatch_2 batchObject = new RenewContractBatch_2();
        Id batchId = Database.executeBatch(batchObject, 1);
    }
    
}