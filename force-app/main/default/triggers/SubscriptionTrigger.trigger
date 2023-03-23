/********************************************************************
** Trigger Name: SubscriptionTrigger 
**
** Purpose: This handles various custom functionalities to gets invoked while creating 
            subscription records.
********************************************************************/
TRIGGER SubscriptionTrigger on SBQQ__Subscription__c (before insert, before update, after insert, after update) {
    new SubscriptionTriggerHandler().run();
   /* if(trigger.isBefore){
        if(trigger.isInsert){
            SubscriptionTriggerHandler.beforeInsertHandler(trigger.new, trigger.newMap, trigger.old, trigger.oldMap);
        }
        else if(trigger.isUpdate){
            SubscriptionTriggerHandler.beforeUpdateHandler(trigger.new, trigger.newMap, trigger.old, trigger.oldMap);
        }
    }else{
        if(trigger.isInsert){
            SubscriptionTriggerHandler.afterInsertHandler(trigger.new, trigger.newMap, trigger.old, trigger.oldMap);
        }
        else if(trigger.isUpdate){
            SubscriptionTriggerHandler.afterUpdateHandler(trigger.new, trigger.newMap, trigger.old, trigger.oldMap);               
        }
    }*/ 
    
}