trigger TaskTrackerTrigger on Task_Tracker__c (before insert,before update) {
    
    Boolean skiptrigger = false;
    Skip_Triggers_User_Based__c usertoskip = Skip_Triggers_User_Based__c.getInstance(Userinfo.getUserId());
    
    //User Base Skip Logic
    SObjectType triggerType = trigger.isDelete ? trigger.old.getSObjectType() : trigger.new.getSObjectType();
    String objname = triggerType.getDescribe().getName();
    if(usertoskip != null && objname != null &&  usertoskip.Object_s_to_skip__c != null && 
       usertoskip.Object_s_to_skip__c.split(';') != null &&
       usertoskip.Object_s_to_skip__c.split(';').contains(objname))
    {
        skiptrigger = true;
    }
    
    
    //Trigger Switch Base Skip Logic
    Map<String, Triggers_Switch__c> tsmap = Triggers_Switch__c.getAll();
    if(!skiptrigger &&  tsmap != null && !tsmap.isEmpty() &&
       tsmap.containsKey('Execute_TaskTrackerTrigger') && tsmap.get('Execute_TaskTrackerTrigger') != null &&
       tsmap.get('Execute_TaskTrackerTrigger').Execute__c)
    {
        
        
        if(trigger.isBefore)
        {
            if(trigger.isInsert)
            {
                TaskTrackerHelper.updateScheduleDateOnInsert(trigger.new);
            }
            else if(trigger.isUpdate)
            {
                TaskTrackerHelper.updateScheduleDateOnUpdate(trigger.new,trigger.oldMap);
            }
        }
    }
}