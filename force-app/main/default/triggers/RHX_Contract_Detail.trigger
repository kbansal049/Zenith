trigger RHX_Contract_Detail on Contract_Detail__c(after delete, after insert, after undelete, after update, before delete, before insert,before update) {
    Map<String, Triggers_Switch__c> tsmap = Triggers_Switch__c.getAll();
    Boolean skiptrigger = false;
    Skip_Triggers_User_Based__c usertoskip = Skip_Triggers_User_Based__c.getInstance(Userinfo.getUserId());
    SObjectType triggerType = trigger.isDelete ? trigger.old.getSObjectType() : trigger.new.getSObjectType();
    String objname = triggerType.getDescribe().getName();
    if(objname != null && usertoskip.Id != null && usertoskip.Object_s_to_skip__c != null && usertoskip.Object_s_to_skip__c.split(';') != null && !usertoskip.Object_s_to_skip__c.split(';').isEmpty() && usertoskip.Object_s_to_skip__c.split(';').contains(objname)){
        skiptrigger = true;
    }

    if(!skiptrigger && !TriggerUtility.isSkipConDetailTriggerExecuted() && tsmap != null && !tsmap.isEmpty() && tsmap.containsKey('Execute_Contract_Detail_Trigger') && tsmap.get('Execute_Contract_Detail_Trigger') != null && tsmap.get('Execute_Contract_Detail_Trigger').Execute__c){
        if(trigger.isBefore && trigger.isInsert){
            ContractDetailTriggerHelper.beforeInsert(trigger.new);
            //ContractDetailTriggerHelper.UpdateIncumbentPartneronAccount(trigger.new);
            //ContractDetailTriggerHelper.updateFirstZPAContractDateonAccount(trigger.new);
        }

        if(trigger.isAfter && trigger.isInsert){
            
            ContractDetailTriggerHelper.afterInsert(trigger.new);
            //ContractDetailTriggerHelper.UpdateIncumbentPartneronAccount(trigger.new);
            //ContractDetailTriggerHelper.updateFirstZPAContractDateonAccount(trigger.new);
        }

        if(trigger.isBefore && trigger.isupdate){
            ContractDetailTriggerHelper.beforeUpdate(trigger.new, trigger.newMap, trigger.oldMap);
            //ContractDetailTriggerHelper.updateFirstZPAContractDateonAccount(trigger.new);
        }
        //due to CR#402 added by minkesh patel 22-05-2020 start
        if(trigger.isAfter && trigger.isupdate){
            ContractDetailTriggerHelper.afterUpdate(trigger.new, trigger.newMap, trigger.oldMap);
            //ContractDetailTriggerHelper.updateFirstZPAContractDateonAccount(trigger.new);
        }
        if(trigger.isDelete && trigger.isBefore){
            ContractDetailTriggerHelper.beforeDelete(trigger.old, trigger.oldMap);
            //ContractDetailTriggerHelper.updateFirstZPAContractDateonAccount(trigger.old);
        }
        if(trigger.isDelete && trigger.isAfter){
             ContractDetailTriggerHelper.afterDelete(trigger.old, trigger.oldMap);
        }
    }
    //due to CR#402 added by minkesh patel 22-05-2020 end
}