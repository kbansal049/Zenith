trigger genericMeetingTrigger on Meeting__c (before insert, after insert, before update, after update, before delete, after delete, after undelete) {
    Map<String, Triggers_Switch__c> tsmap = Triggers_Switch__c.getAll();
    Boolean skiptrigger = false;
    Skip_Triggers_User_Based__c usertoskip = Skip_Triggers_User_Based__c.getInstance(Userinfo.getUserId());
    SObjectType triggerType = trigger.isDelete ? trigger.old.getSObjectType() : trigger.new.getSObjectType();
    String objname = triggerType.getDescribe().getName();
    if(objname != null && usertoskip.Id != null && usertoskip.Object_s_to_skip__c != null && usertoskip.Object_s_to_skip__c.split(';') != null && !usertoskip.Object_s_to_skip__c.split(';').isEmpty() && usertoskip.Object_s_to_skip__c.split(';').contains(objname)){
        skiptrigger = true;
    }
    if(!skiptrigger && !TriggerUtility.isSkipMeetingTriggerExecuted() && tsmap != null && !tsmap.isEmpty() && tsmap.containsKey('Execute_Meeting_Trigger') && tsmap.get('Execute_Meeting_Trigger') != null && tsmap.get('Execute_Meeting_Trigger').Execute__c){
        if(trigger.isAfter && trigger.isInsert && !TriggerUtility.isMeetingAfterInsertExecuted()){
            MeetingTriggerHandler.afterInsert(Trigger.new);
        }
        if(trigger.isBefore && trigger.isInsert && !TriggerUtility.isexecuteUpdateParticipantsExecuted()){
            MeetingTriggerHandler.beforeInsert(Trigger.new);
        } 
        //Added by Rajesh : CR#1229 - Start
        if(trigger.isAfter && (trigger.isInsert ||trigger.isUpdate) && !TriggerUtility2.isupdateTAMMetingDateExecuted()){
            MeetingTriggerHandler.updateMeetingDateAccExt(Trigger.new);
        }
        //Added by Rajesh : CR#1229 - End		 
    }
       //Added by Chetan : CR# 3357-Start
        if(trigger.isBefore && trigger.isUpdate && !TriggerUtility.isexecuteValidateCompletedStatusExecuted()){
            MeetingTriggerHandler.beforeUpdate(Trigger.new,Trigger.oldMap);
        }
        //Added by Chetan : CR# 3357-Start
    
}