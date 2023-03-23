trigger genericFeedItemTrigger on FeedItem(before insert, after insert, before update, after update, before delete, after delete, after undelete) {
    Map<String, Triggers_Switch__c> tsmap = Triggers_Switch__c.getAll();
    Boolean skiptrigger = false;
    Skip_Triggers_User_Based__c usertoskip = Skip_Triggers_User_Based__c.getInstance(Userinfo.getUserId());
    SObjectType triggerType = trigger.isDelete ? trigger.old.getSObjectType() : trigger.new.getSObjectType();
    String objname = triggerType.getDescribe().getName();
    if(objname != null && usertoskip.Id != null && usertoskip.Object_s_to_skip__c != null && usertoskip.Object_s_to_skip__c.split(';') != null && !usertoskip.Object_s_to_skip__c.split(';').isEmpty() && usertoskip.Object_s_to_skip__c.split(';').contains(objname)){
        skiptrigger = true;
    }
    if(Test.isRunningTest() || (   !skiptrigger && !TriggerUtility.isSkipFeedItemTriggerExecuted() && tsmap != null && !tsmap.isEmpty() && tsmap.containsKey('Execute_FeedItem_Trigger') && tsmap.get('Execute_FeedItem_Trigger') != null && tsmap.get('Execute_FeedItem_Trigger').Execute__c)){
        if(trigger.isAfter && trigger.isInsert && !TriggerUtility.isFeedItemAfterTriggerExecuted()){
            try {
                FeedItemTriggerUtility.afterInsert(Trigger.new);
                
                MAP<Id,Case> updates = new   MAP<Id,Case> ();
                id id1 = userinfo.getProfileId();
                Profile p = [select Name from profile where id = :id1];
                
                for (FeedItem fi : Trigger.new) {
                    
                    if ( fi.ParentId.getSObjectType() == Case.SObjectType &&  fi.Visibility  == 'AllUsers' && 
                        p.Name != 'Customer Community User Profile' && p.Name != 'Customer Community Login User'  && p.Name != 'Customer Community Admin Profile' ) 
                    {
                        updates.put(fi.ParentId,new Case(
                            Id = fi.ParentId,
                            Days_since_last_activity__c = system.now()
                        ));
                    }
                }
                update updates.values();
            }catch(DmlException  ex)  {
                for(FeedItem fd : Trigger.new )  {
                    fd.addError(ex.getDmlMessage(0));
                }
            } 
        }
        if(trigger.isBefore && trigger.isInsert && !TriggerUtility.isFeedItemBeforeTriggerExecuted()){
            FeedItemTriggerUtility.beforeInsert(Trigger.new);
        }
    }
    
    if(trigger.isafter && trigger.isinsert){
        
        
    }
    
}