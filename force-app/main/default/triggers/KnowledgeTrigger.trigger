/**
 * Name : KnowledgeTrigger
 * Description : Trigger on Knowledge, includes functionalities like : Populating User Lookups on KB, Setting the Validation Status 
 * Test Class : KnowledgeTriggerHandlerTest
 * 
 */

trigger KnowledgeTrigger on KB__kav (before update, before insert) {
    Map<String, Triggers_Switch__c> tsmap = Triggers_Switch__c.getAll();
    Boolean skiptrigger = false;
    
    Skip_Triggers_User_Based__c usertoskip = Skip_Triggers_User_Based__c.getInstance(Userinfo.getUserId());
    SObjectType triggerType = trigger.isDelete ? trigger.old.getSObjectType() : trigger.new.getSObjectType();
    
    String objname = triggerType.getDescribe().getName();
    if(objname != null && usertoskip.Id != null && usertoskip.Object_s_to_skip__c != null && usertoskip.Object_s_to_skip__c.split(';') != null && !usertoskip.Object_s_to_skip__c.split(';').isEmpty() && usertoskip.Object_s_to_skip__c.split(';').contains(objname)){
        skiptrigger = true;
    }
   
    if(!skiptrigger && tsmap != null && !tsmap.isEmpty() && tsmap.containsKey('KnowledgeTrigger') && tsmap.get('KnowledgeTrigger') != null && tsmap.get('KnowledgeTrigger').Execute__c) {
        if(trigger.isBefore && trigger.isInsert){
            KnowledgeTriggerHandler.beforeInsert(Trigger.new);
        }
    
        if(trigger.isBefore && trigger.isUpdate){
            KnowledgeTriggerHandler.beforeUpdate(Trigger.new, trigger.OldMap);
        }
    }
}