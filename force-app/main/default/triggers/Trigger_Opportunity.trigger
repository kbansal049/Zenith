trigger Trigger_Opportunity on Opportunity (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    
    if(trigger.isBefore){
        if(trigger.isInsert){
            Trigger_Opportunity_Handler.beforeInsertHandler(trigger.new, trigger.newMap, trigger.old, trigger.oldMap);
        }
        else if(trigger.isUpdate){
            Trigger_Opportunity_Handler.beforeUpdateHandler(trigger.new, trigger.newMap, trigger.old, trigger.oldMap);
        }
        else if(trigger.isDelete){
            Trigger_Opportunity_Handler.beforeDeleteHandler(trigger.old, trigger.oldMap);
        }
    }else{
        if(trigger.isInsert){
            Trigger_Opportunity_Handler.afterInsertHandler(trigger.new, trigger.newMap, trigger.old, trigger.oldMap);
        }
        else if(trigger.isUpdate){
            Trigger_Opportunity_Handler.afterUpdateHandler(trigger.new, trigger.newMap, trigger.old, trigger.oldMap);               
        }
        else if(trigger.isDelete){
            Trigger_Opportunity_Handler.afterDeleteHandler(trigger.new, trigger.old, trigger.oldMap);
        }
        else if(trigger.isUnDelete){
            Trigger_Opportunity_Handler.afterUnDeleteHandler(trigger.new, trigger.newMap);
        }
    } 
    
}