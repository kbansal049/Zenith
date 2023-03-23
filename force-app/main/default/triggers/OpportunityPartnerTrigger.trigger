/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 12-17-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
trigger OpportunityPartnerTrigger on Opportunity_Partner__c (before insert,before update,after insert,before delete,after delete, after update) {
    System.debug('-=-- Inside my trigger -=- ');
    boolean skipTrigger = false;
    
    
    
    Skip_Triggers_User_Based__c usertoskip = Skip_Triggers_User_Based__c.getInstance(Userinfo.getUserId());
    SObjectType triggerType = trigger.isDelete ? trigger.old.getSObjectType() : trigger.new.getSObjectType();
    String objname = triggerType.getDescribe().getName();
    if(objname != null && usertoskip.Id != null && usertoskip.Object_s_to_skip__c != null && usertoskip.Object_s_to_skip__c.split(';') != null && !usertoskip.Object_s_to_skip__c.split(';').isEmpty() && usertoskip.Object_s_to_skip__c.split(';').contains(objname)){
        skiptrigger = true;
    }
    
    if(!skipTrigger){
        /*if(Trigger.IsAfter && Trigger.IsInsert){
            OpportunityPartnerTriggerHandler.onAfterInsert(Trigger.new);
        }*/
        if(Trigger.Isbefore && Trigger.IsInsert){
            if(!TriggerUtility2.issetOppPartnerTechPartnerExecuted()){
            	//OpportunityPartnerTriggerHandler.onBeforeInsert(Trigger.new);
            }
        }
        if(Trigger.IsAfter && Trigger.IsInsert){
            if(!TriggerUtility2.issetOppPartnerTechPartnerExecuted()){
            	OpportunityPartnerTriggerHandler.onAfterInsert(Trigger.new);
            }
        }
        
        if(Trigger.Isbefore && Trigger.IsUpdate){
            //OpportunityPartnerTriggerHandler.onBeforeUpdate(Trigger.new, Trigger.oldMap);
        }
        if(Trigger.IsAfter && Trigger.IsUpdate){
            OpportunityPartnerTriggerHandler.onAfterUpdate(Trigger.new, Trigger.oldMap);
        }
        /*if(Trigger.IsAfter && Trigger.IsDelete){
            OpportunityPartnerTriggerHandler.onBeforeDelete(Trigger.old);
        }*/
        
        if(Trigger.IsAfter && Trigger.IsDelete){
            if(!TriggerUtility2.issetOppRelTechPartnerExecuted()){
            	OpportunityPartnerTriggerHandler.onBeforeDelete(Trigger.old);
            }
        }
        if(Trigger.isBefore && Trigger.IsDelete){
            	OpportunityPartnerTriggerHandler.deleteDistributor(Trigger.old);
        }
        
        if((Trigger.IsAfter && Trigger.IsUpdate)) {
            System.debug('-=-- Inside my trigger -=- 2');
            
            OpportunityPartnerTriggerHandler instance = OpportunityPartnerTriggerHandler.getInstance();
            instance.onAfterUpdate();
        }
    }
    
    
    
}