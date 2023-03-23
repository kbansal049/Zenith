trigger genericKnowledgeTrigger on KB__kav (before insert, before update){
    
    Map<String, Triggers_Switch__c> tsmap = Triggers_Switch__c.getAll();
    Boolean skiptrigger = false;
    Skip_Triggers_User_Based__c usertoskip = Skip_Triggers_User_Based__c.getInstance(Userinfo.getUserId());
    SObjectType triggerType = trigger.isDelete ? trigger.old.getSObjectType() : trigger.new.getSObjectType();
    String objname = triggerType.getDescribe().getName();
    if(objname != null && usertoskip.Id != null && usertoskip.Object_s_to_skip__c != null && usertoskip.Object_s_to_skip__c.split(';') != null && !usertoskip.Object_s_to_skip__c.split(';').isEmpty() && usertoskip.Object_s_to_skip__c.split(';').contains(objname)){
        skiptrigger = true;
    }
    if(!skiptrigger && tsmap != null && !tsmap.isEmpty() && tsmap.containsKey('Execute_Kb_Trigger') && tsmap.get('Execute_Kb_Trigger') != null && tsmap.get('Execute_Kb_Trigger').Execute__c){
        if(trigger.isInsert){
            knowledgeHandler.beforeInsert(trigger.new);
        }
        else if(trigger.isUpdate){
            knowledgeHandler.beforeUpdate(trigger.new,trigger.newmap,trigger.oldmap);
        }
    }
    
}