/**
 * DeleteUserPresenceBatch
 * Added by : Ankit Bhatnagar
 * Description : Batch that deletes the User Presence Records older than 3/6 months (Months Specified in DeleteUserPresenceInterval_in_Months CustomLabel)
 */
public class DeleteUserPresenceBatch implements Database.Batchable<sObject>,Database.Stateful {
    
    ZscalerBatchFramework zscalerBatchFrameWorkObj = new ZscalerBatchFramework('DeleteUserPresenceBatch');

    
    public DeleteUserPresenceBatch() {}

    public Database.QueryLocator start(Database.BatchableContext context){
        this.zscalerBatchFrameWorkObj.callStart();
        
        Integer limitMonths = 0 - Integer.valueOf(System.Label.DeleteUserPresenceInterval_in_Months);
        Date limitDate = System.today().addMonths(limitMonths);
        return Database.getQueryLocator([SELECT id FROM UserServicePresence WHERE CreatedDate <:limitDate]);
    }

    public void execute(Database.BatchableContext context, List<UserServicePresence> scope){
        this.zscalerBatchFrameWorkObj.callExecute(scope[0]?.Id, scope.size());
        
        if(!scope.isEmpty()) {
            Database.delete(scope);
        }
    }

    public void finish(Database.BatchableContext bc){
        // execute any post-processing operations
       this.zscalerBatchFrameWorkObj.callFinish(bc);
    }
}