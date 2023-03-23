trigger OpportunityContactRoleTrigger on OpportunityContactRole (after insert, after update, before delete, after delete) {
	Boolean skiptrigger = false;
    Skip_Triggers_User_Based__c usertoskip = Skip_Triggers_User_Based__c.getInstance(Userinfo.getUserId());
    SObjectType triggerType = trigger.isDelete ? trigger.old.getSObjectType() : trigger.new.getSObjectType();
    String objname = triggerType.getDescribe().getName();
    if(objname != null && usertoskip.Id != null && usertoskip.Object_s_to_skip__c != null && usertoskip.Object_s_to_skip__c.split(';') != null && !usertoskip.Object_s_to_skip__c.split(';').isEmpty() && usertoskip.Object_s_to_skip__c.split(';').contains(objname)){
        skiptrigger = true;
    }
    
    if(!skiptrigger)  {
    OpportunityContactRoleTriggerHelper contactRoleTriggerHelper = new OpportunityContactRoleTriggerHelper();
    
    if(trigger.isInsert && trigger.isAfter){
        contactRoleTriggerHelper.afterInsert(trigger.new);
        OppContactRolesTrgHelper.process(trigger.new);
    }
    
    if(trigger.isupdate && trigger.isAfter){
        system.debug('### recordIds' + trigger.new);
        system.debug('### trigger size' + trigger.new.size());
        contactRoleTriggerHelper.afterUpdate(trigger.new);
    }
    
    if(trigger.isdelete && trigger.isBefore){
        contactRoleTriggerHelper.beforeDelete(trigger.old);
        // contactRoleTriggerHelper.AfterDelete(trigger.old);
    }
    
    if(trigger.isdelete && trigger.isAfter){
        contactRoleTriggerHelper.AfterDelete(trigger.old);
    }
    }
}