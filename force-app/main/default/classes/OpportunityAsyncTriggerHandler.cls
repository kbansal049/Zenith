/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* OpportunityAsyncTriggerHandler
* @description    This is the Opportunity Trigger handler called asynchronously.
*					Here we are collecting the filtered data and calling the OpportunityAsyncTriggerController.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Chandan Panigrahy
* @modifiedBy     Chandan Panigrahy
* @maintainedBy   Chandan Panigrahy
* @version        1.0
* @created        2021-09-13
* @modified       
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* vX.X            Developer Name
* YYYY-MM-DD      Explanation of the change.  Multiple lines can be used to explain the change, but
*                 each line should be indented till left aligned with the previous description text.
*
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
**/

public class OpportunityAsyncTriggerHandler extends TriggerHandler {
    public override void afterInsert() {
        
        Map<Id, OpportunityChangeEvent> newOppChangeEvtMap = new Map<Id, OpportunityChangeEvent>();
        
        for (OpportunityChangeEvent oppChangeEvt : (List<OpportunityChangeEvent>) Trigger.new) {
            String recId = String.valueOf(oppChangeEvt.get('Id'));
            if(!ManageRecursive.processedOpportunityIds.contains(recId)) {
                newOppChangeEvtMap.put(recId, oppChangeEvt);
                
                ManageRecursive.processedOpportunityIds.add(recId);
            }
        }
        
        OpportunityAsyncTriggerController instance = OpportunityAsyncTriggerController.getInstance();
        instance.setNewOppList(Trigger.new);
        instance.process();
        
        
    }
}