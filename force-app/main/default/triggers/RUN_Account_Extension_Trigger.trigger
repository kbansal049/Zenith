trigger RUN_Account_Extension_Trigger on Account_Extension__c (after delete, after insert, after undelete, after update, before delete, before insert,before update) {
    Map<String, Triggers_Switch__c> tsmap = Triggers_Switch__c.getAll();
    Boolean skiptrigger = false;
    Skip_Triggers_User_Based__c usertoskip = Skip_Triggers_User_Based__c.getInstance(Userinfo.getUserId());
    SObjectType triggerType = trigger.isDelete ? trigger.old.getSObjectType() : trigger.new.getSObjectType();
    String objname = triggerType.getDescribe().getName();
    if(objname != null && usertoskip.Id != null && usertoskip.Object_s_to_skip__c != null && usertoskip.Object_s_to_skip__c.split(';') != null && !usertoskip.Object_s_to_skip__c.split(';').isEmpty() && usertoskip.Object_s_to_skip__c.split(';').contains(objname)){
        skiptrigger = true;
    }
    
    if(!skiptrigger && !TriggerUtility.getAccountExtensionmethod() && tsmap != null && !tsmap.isEmpty() && tsmap.containsKey('Service_Owner_Change_Trigger') && tsmap.get('Service_Owner_Change_Trigger') != null && tsmap.get('Service_Owner_Change_Trigger').Execute__c){
        
        if(trigger.isAfter && trigger.isInsert){
            AccountExtensionTriggerHelper.afterInsert(trigger.new);
            
        }
        if(trigger.isAfter && trigger.isupdate){
            AccountExtensionTriggerHelper.afterUpdate(trigger.newMap, trigger.oldMap);
        }
    }
    if(trigger.isAfter && trigger.isInsert){
        if(!skiptrigger && tsmap != null && !tsmap.isEmpty() && tsmap.containsKey('Executed_AccountExtRelated_Acc') && tsmap.get('Executed_AccountExtRelated_Acc') != null && tsmap.get('Executed_AccountExtRelated_Acc').Execute__c && !TriggerUtility2.isupdateAccExtRelatedAccExecuted()){
            AccountExtensionTriggerHelper.AccountFieldUpdate(trigger.newMap,Null);
        }
    }
    //Added by Swathi : CR1142 Start
    if(trigger.isAfter && trigger.isupdate){
        if(!skiptrigger && tsmap != null && !tsmap.isEmpty() && tsmap.containsKey('Execute_AccountOwnerChange_Alert') && tsmap.get('Execute_AccountOwnerChange_Alert') != null && tsmap.get('Execute_AccountOwnerChange_Alert').Execute__c && !TriggerUtility.isAccountOwnerChangeAlertExecuted()){
            AccountExtensionTriggerHelper.SendEmailtoCSM(trigger.newMap, trigger.oldMap);
        }
        if(!skiptrigger && tsmap != null && !tsmap.isEmpty() && tsmap.containsKey('Executed_AccountExtRelated_Acc') && tsmap.get('Executed_AccountExtRelated_Acc') != null && tsmap.get('Executed_AccountExtRelated_Acc').Execute__c && !TriggerUtility2.isupdateAccExtRelatedAccExecuted()){
            AccountExtensionTriggerHelper.AccountFieldUpdate(trigger.newMap, trigger.oldMap);
        }
        if(!skiptrigger){
            //Added by Mahesh T:CR#4705
            AccountExtensionTriggerHelper.createAccountTeamMember(trigger.new,trigger.oldMap); 
        }
    }
    //Added by Swathi : CR1142 End
}