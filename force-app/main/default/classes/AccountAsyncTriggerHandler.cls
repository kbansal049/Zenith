/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* AccountAsyncTriggerHandler
* @description    This is the Account Trigger handler called asynchronously.
*				  Here we are collecting the filtered data and calling the AccountAsyncTriggerHelper.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Zscaler
* @modifiedBy     
* @maintainedBy   Zscaler
* @version        1.0
* @created        2021-11-09
* @modified       
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* vX.X            Developer Name
* YYYY-MM-DD      Explanation of the change.  Multiple lines can be used to explain the change, but
*                 each line should be indented till left aligned with the previous description text.
*
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
**/
public class AccountAsyncTriggerHandler extends TriggerHandler {
    
    public override void afterInsert() {
        Map<Id, AccountChangeEvent> newAccountChangeEvtMap = new Map<Id, AccountChangeEvent>();
        
        for (AccountChangeEvent accChangeEvt : (List<AccountChangeEvent>) Trigger.new) {
            String recId = String.valueOf(accChangeEvt.get('Id'));
            if(!ManageRecursive.processedAccountIds.contains(recId)) {
                newAccountChangeEvtMap.put(recId, accChangeEvt);
                
                ManageRecursive.processedAccountIds.add(recId);
            }
        }
        
        AccountAsyncTriggerHelper instance = AccountAsyncTriggerHelper.getInstance();
        instance.setNewAccountList((List<AccountChangeEvent>)Trigger.new);
        instance.process();
    }

}