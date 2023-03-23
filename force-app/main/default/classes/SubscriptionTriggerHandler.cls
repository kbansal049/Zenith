/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 07-12-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class SubscriptionTriggerHandler extends TriggerHandler{
    
    public override void beforeInsert() { 
        SubscriptionTriggerHelper.blnIsInsertEvent = true;
        SubscriptionTriggerHelper.setRequiredByLookup((List<SBQQ__Subscription__c>)Trigger.new);
        
      //  SubscriptionTriggerHelper.setPhantomToSplitCheck(Trigger.new);
    }
    
    public override void beforeUpdate(){
        system.debug('handler@@');
        SubscriptionTriggerHelper.setRequiredByLookup(Trigger.new);
      //  SubscriptionTriggerHelper.setPhantomToSplitCheck(Trigger.new);
    }
    
    
    public override void afterInsert(){
        SubscriptionTriggerHelper.updateParentContract(Trigger.new, (Map<Id,SBQQ__Subscription__c>) Trigger.oldMap); 
        SubscriptionTriggerHelper.updateZPAEndDate(Trigger.new,NULL,TRUE);
        SubscriptionTriggerHelper.updateZIAEndDate(Trigger.new,NULL,TRUE);
        SubscriptionTriggerHelper.updateNoOfSubscriptions(Trigger.new,NULL,TRUE);
        //SubscriptionTriggerHelper.updatePlatformSKUOnPhantom(Trigger.new,(Map<Id,SBQQ__Subscription__c>)Trigger.newMap);
    }
      
    public override void afterUpdate(){
        SubscriptionTriggerHelper.updateParentContract(Trigger.new, (Map<Id,SBQQ__Subscription__c>)Trigger.oldMap);
       // if(SubscriptionTriggerHelper.blnIsInsertEvent){
            SubscriptionTriggerHelper.updatePlatformSKUOnPhantom(Trigger.new,(Map<Id,SBQQ__Subscription__c>)Trigger.newMap);       
        //}
        SubscriptionTriggerHelper.updateZPAEndDate(Trigger.new,(Map<Id,SBQQ__Subscription__c>)Trigger.oldMap,FALSE);
        SubscriptionTriggerHelper.updateZIAEndDate(Trigger.new,(Map<Id,SBQQ__Subscription__c>)Trigger.oldMap,FALSE);
        SubscriptionTriggerHelper.updateNoOfSubscriptions(Trigger.new,(Map<Id,SBQQ__Subscription__c>)Trigger.oldMap,FALSE);
    }
   
    
}