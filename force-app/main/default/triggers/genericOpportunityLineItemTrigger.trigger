trigger genericOpportunityLineItemTrigger on OpportunityLineItem (before insert, after insert, before update, after update, before delete, after delete, after undelete) {
   
   
    if(Trigger.isAfter){
        OpportunityLineTriggerHandler.triggerEventHandler(trigger.new,trigger.oldmap);
    }    
    //To avoid Prospect type update on line item deletion, basically on quote finalization
    if(trigger.isdelete){
        TriggerUtility.prospectTypeUpdExecuted();
        TriggerUtility.SkipAccTriggerExecuted();
        TriggerUtility.TechpartnerupdateExecuted();
    }
}