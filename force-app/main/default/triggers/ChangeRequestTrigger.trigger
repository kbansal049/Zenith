trigger ChangeRequestTrigger on Tracker_Change_Request__c (before insert, before update, after insert, after update) {
    Boolean skiptrigger = false;
    Skip_Triggers_User_Based__c usertoskip = Skip_Triggers_User_Based__c.getInstance(Userinfo.getUserId());
    SObjectType triggerType = trigger.isDelete ? trigger.old.getSObjectType() : trigger.new.getSObjectType();
    String objname = triggerType.getDescribe().getName();
    if(objname != null && usertoskip.Id != null && usertoskip.Object_s_to_skip__c != null && usertoskip.Object_s_to_skip__c.split(';') != null && !usertoskip.Object_s_to_skip__c.split(';').isEmpty() && usertoskip.Object_s_to_skip__c.split(';').contains(objname)){
        skiptrigger = true;
    }
    if(!skiptrigger){
        if(Trigger.isInsert){
            if(Trigger.isBefore){
                ChangeRequestTriggerHandler.beforeInsert(Trigger.New);
            }
            if(Trigger.isAfter){
                ChangeRequestTriggerHandler.afterInsert(Trigger.New);
            }
        }
        if(Trigger.isUpdate){
            if(Trigger.isAfter){
              	ChangeRequestTriggerHandler.afterUpdate(Trigger.new, Trigger.OldMap);
            }
            
        }
    }
    
}