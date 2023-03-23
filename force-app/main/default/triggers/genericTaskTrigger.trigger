/*****************************************************************************************
Name: genericTaskTrigger
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
1. Generic trigger to manage all the business logic.
==========================================================================================
==========================================================================================
History
-------
VERSION        AUTHOR                  DATE              DETAIL              
1.0            Kunal Raj            21-Sep-2015    Initial Development
******************************************************************************************/ 


trigger genericTaskTrigger on Task (after insert, after update, before insert, before update) {
    // Added as a part of CR# 584 : Gurjinder :Start
    if(trigger.isInsert && trigger.isBefore){
        TaskTriggerHelper.BeforeInsertTask(trigger.new);
    }
    if(trigger.isUpdate && trigger.isBefore){
        TaskTriggerHelper.BeforeUpdateTask(trigger.new, Trigger.old);
    }
    // Added as a part of CR# 584 : Gurjinder :End

    if(trigger.isInsert && trigger.isAfter){
        if(!TriggerUtility.isCampMemActivityExecuted())
           captureActivityOnLead.getActivityDetail(trigger.newMap);
        /*if(!TriggerUtility.isActivityleadterritoryinsertExecuted()){
            captureActivityOnLead.assignleadterritory(trigger.new, trigger.Oldmap, trigger.isInsert, trigger.isUpdate);
        }*/
        TaskTriggerHelper.Afterinsert(trigger.Newmap); //Added By Swathi: CR#1416
    }
    /*if(trigger.isAfter && trigger.isUpdate){
        if(!TriggerUtility.isActivityleadterritoryupdateExecuted()){
            captureActivityOnLead.assignleadterritory(trigger.new, trigger.Oldmap, trigger.isInsert, trigger.isUpdate);
        }
    }*/
    
    //Added By Swathi: CR#1416 - Start
    if(trigger.isAfter && trigger.isUpdate){
        TaskTriggerHelper.AfterUpdateTask(trigger.Newmap,trigger.Oldmap);
    }
    //Added By Swathi: CR#1416 - End
}