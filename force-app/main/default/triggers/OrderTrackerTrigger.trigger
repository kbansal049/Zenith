trigger OrderTrackerTrigger on Order_Tracker__c (before insert,before update, after update) 
{
    if(OrderTrackerHelper.bypassOrderTrackerTrigger)
        return;
    
	if(trigger.isBefore){
       
        if(trigger.isInsert){
            OrderTrackerHelper.getOppAndProposalFieldsForInsert(trigger.new);
        }else if(trigger.isUpdate){
            OrderTrackerHelper.getOppAndProposalFieldsForUpdate(trigger.new,trigger.oldMap);
        }
        OrderTrackerHelper.fillPODetailLookUpBasedOnthePO(trigger.new);
    }else if(trigger.isAfter){
        if(trigger.isUpdate){
            OrderTrackerHelper.updatePoDetailOrderTrackerStatusChange(trigger.new,trigger.oldMap);
        }
    }
}