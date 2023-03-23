// Added by Abhijit for CR851
trigger genericCXOAdvisorRequestTrigger on CXO_Advisor_Request__c (before Insert, After Insert, Before Update, After Update, Before delete, After delete) {
    Map<String, Triggers_Switch__c> tsmap = Triggers_Switch__c.getAll();
    Boolean skiptrigger = false;
    Skip_Triggers_User_Based__c usertoskip = Skip_Triggers_User_Based__c.getInstance(Userinfo.getUserId());
    SObjectType triggerType = trigger.isDelete ? trigger.old.getSObjectType() : trigger.new.getSObjectType();
    String objname = triggerType.getDescribe().getName();
    
    if(objname != null && usertoskip.Id != null && usertoskip.Object_s_to_skip__c != null && usertoskip.Object_s_to_skip__c.split(';') != null && !usertoskip.Object_s_to_skip__c.split(';').isEmpty() && usertoskip.Object_s_to_skip__c.split(';').contains(objname)){
        skiptrigger = true;
    }
    
    if(!skiptrigger && !TriggerUtility.isSkipCXOAdvisorRequestTriggerExecuted() && tsmap != null && !tsmap.isEmpty() && tsmap.containsKey('Execute_CXOAdvisorRequest_Trigger') && tsmap.get('Execute_CXOAdvisorRequest_Trigger') != null && tsmap.get('Execute_CXOAdvisorRequest_Trigger').Execute__c){
        if(trigger.isAfter){
            if(trigger.isInsert && (!TriggerUtility.isCXOAdvisorRequestAfterInsertExecuted() || !TriggerUtility.ispopulateCXOAdvisorExecuted())){
                CXOAdvisorRequestTriggerHandler.afterInsert(trigger.New);
            }
            
            if(trigger.isUpdate && (!TriggerUtility.isCXOAdvisorRequestAfterUpdateExecuted() || !TriggerUtility.ispopulateCXOAdvisorExecuted())){
                CXOAdvisorRequestTriggerHandler.afterUpdate(trigger.New, trigger.oldMap);
            }
        }
    }
    // Added by Ayush Kangar as part of CR# 3856 - Start
    if(trigger.isBefore){
        if((trigger.isInsert ||trigger.isUpdate) && !TriggerUtility.ispopulateTeamAdvisorExecuted()){
            CXOAdvisorRequestTriggerHandler.beforeInsertAndUpdate(trigger.New);
        }
        if(trigger.isUpdate){
            CXOAdvisorRequestTriggerHandler.beforeUpdate(trigger.New,trigger.oldMap);
        }
        // Added by Ayush Kangar as part of CR# 4587 - Start
        if(trigger.isInsert){
            CXOAdvisorRequestTriggerHandler.beforeInsert(trigger.New);
        }
        // Added by Ayush Kangar as part of CR# 4587 - End
    } 
    // Added by Ayush Kangar as part of CR# 3856 - End
}