trigger genericAttachmentTrigger on Attachment (before insert, after insert, before update, after update, before delete, after delete, after undelete) {
    Map<String, Triggers_Switch__c> tsmap = Triggers_Switch__c.getAll();
    Boolean skiptrigger = false;
    Skip_Triggers_User_Based__c usertoskip = Skip_Triggers_User_Based__c.getInstance(Userinfo.getUserId());
    SObjectType triggerType = trigger.isDelete ? trigger.old.getSObjectType() : trigger.new.getSObjectType();
    String objname = triggerType.getDescribe().getName();
    if(objname != null && usertoskip.Id != null && (usertoskip.Skip_all_triggers__c || usertoskip.Object_s_to_skip__c != null && usertoskip.Object_s_to_skip__c.split(';') != null && !usertoskip.Object_s_to_skip__c.split(';').isEmpty() && usertoskip.Object_s_to_skip__c.split(';').contains(objname))){
        skiptrigger = true;
    }
    
    if(!skiptrigger && !TriggerUtility2.isSkipAttachmentTriggerExecuted() && tsmap != null && !tsmap.isEmpty() && tsmap.containsKey('Execute_Attachment_Trigger') && tsmap.get('Execute_Attachment_Trigger') != null && tsmap.get('Execute_Attachment_Trigger').Execute__c){
        if(trigger.isAfter && trigger.isInsert && !TriggerUtility2.isAttachmentAfterInsertExecuted()){
            AttachmentTriggerHelper.afterInsert(Trigger.new);
        }
        if(trigger.isAfter && trigger.isInsert && !TriggerUtility2.isAttachmentAfterUpdateExecuted()){
            AttachmentTriggerHelper.afterupdate(Trigger.new, trigger.oldmap);
        }
    }
}