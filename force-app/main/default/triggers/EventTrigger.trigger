trigger EventTrigger on Event (before insert, after insert, before update, after update, before delete, after delete) {
    /*if(trigger.isAfter && trigger.isInsert){
        if(!TriggerUtility.isActivityleadterritoryEventinsertExecuted()){
            captureActivityOnLead.assignleadterritoryEvent(trigger.new, trigger.Oldmap, trigger.isInsert, trigger.isUpdate);
        }
    }
    if(trigger.isAfter && trigger.isUpdate){
        if(!TriggerUtility.isActivityleadterritoryEventupdateExecuted()){
            captureActivityOnLead.assignleadterritoryEvent(trigger.new, trigger.Oldmap, trigger.isInsert, trigger.isUpdate);
        }
    }*/
    //Added by Abhishek: Sales Teaming: Start 
    Map<String, Triggers_Switch__c> tsmap = Triggers_Switch__c.getAll();
    Boolean skiptrigger = false;
    Skip_Triggers_User_Based__c usertoskip = Skip_Triggers_User_Based__c.getInstance(Userinfo.getUserId());
    SObjectType triggerType = trigger.isDelete ? trigger.old.getSObjectType() : trigger.new.getSObjectType();
    String objname = triggerType.getDescribe().getName();
    if(objname != null && usertoskip.Id != null && usertoskip.Object_s_to_skip__c != null && usertoskip.Object_s_to_skip__c.split(';') != null && !usertoskip.Object_s_to_skip__c.split(';').isEmpty() && usertoskip.Object_s_to_skip__c.split(';').contains(objname)){
        skiptrigger = true;
    }
    //Added by Abhishek: Sales Teaming: End
    
    if(!skiptrigger && !TriggerUtility.isSkipEventTriggerExecuted() && tsmap != null && !tsmap.isEmpty() &&
        tsmap.containsKey('Execute_Event_Trigger') && tsmap.get('Execute_Event_Trigger') != null && 
        tsmap.get('Execute_Event_Trigger').Execute__c)
    {
        if(trigger.isBefore && trigger.isUpdate){
            if(!TriggerUtility.isGroove2SCIcodeexecuted){
                system.debug('before calling EventTriggerhelper.BeforeUpdateEventMethod in before update event');
                EventTriggerhelper.BeforeUpdateEventMethod(trigger.new, trigger.Oldmap);
            }
        }
        
        if(trigger.isBefore && (trigger.isInsert || trigger.isUpdate)){
            //CR# 670
            if(tsmap != null && !tsmap.isEmpty() && tsmap.containsKey('Execute_Meeting_Tech_Teaming_Partner') && 
            tsmap.get('Execute_Meeting_Tech_Teaming_Partner') != null && tsmap.get('Execute_Meeting_Tech_Teaming_Partner').Execute__c &&
            !TriggerUtility.isCreateOpportunityPartnerFromEventExecuted())
            {
                EventTriggerhelper.shouldCreateTechTeamingPartner(trigger.new);
            }
            
            //CR# 2914 - Added by Ritesh Kumar - start
            if(tsmap != null && !tsmap.isEmpty() && tsmap.containsKey('Execute_UpdateRelatedToField') && tsmap.get('Execute_UpdateRelatedToField') != null 
            && tsmap.get('Execute_UpdateRelatedToField').Execute__c && !TriggerUtility.isupdateRelatedToFieldExecuted())
            {
                if(Trigger.isInsert){ EventTriggerhelper.updateRelatedToField(Trigger.new, null); }
                if(Trigger.isUpdate){ EventTriggerhelper.updateRelatedToField(Trigger.new, Trigger.oldMap); }
            }
            
            if(tsmap != null && !tsmap.isEmpty() && tsmap.containsKey('Execute_UpdateTargetCustomerNumber') && tsmap.get('Execute_UpdateTargetCustomerNumber') != null 
            && tsmap.get('Execute_UpdateTargetCustomerNumber').Execute__c && !TriggerUtility.isupdateTargetCustomerNumberExecuted())
            {                
                if(Trigger.isInsert){ EventTriggerhelper.updateTargetCustomerNumber(Trigger.new, null); }
                if(Trigger.isUpdate){ EventTriggerhelper.updateTargetCustomerNumber(Trigger.new, Trigger.oldMap); }             
            }
            //CR# 2914 - Added by Ritesh Kumar - End
        }
        
        
        if(trigger.isAfter && (trigger.isInsert || trigger.isUpdate)){
            if(!TriggerUtility.isGroove2SCIcodeexecuted){
                system.debug('before calling EventTriggerhelper.AutocreateSCI ');
                EventTriggerhelper.AutocreateSCI(trigger.new, trigger.Oldmap, trigger.isInsert, trigger.isUpdate);
            }
        }
        
        //CR# 349 - Parth Doshi - Start
        if(trigger.isAfter && (trigger.isInsert || trigger.isUpdate || trigger.isDelete)){
            if(trigger.isDelete){
                EventTriggerhelper.setCountOfSCIs(trigger.old);
            }else{
                EventTriggerhelper.setCountOfSCIs(trigger.new);
            }
        }
        Map<String, Triggers_Switch__c> tsmap = Triggers_Switch__c.getAll();
        if(trigger.isAfter && trigger.isInsert ){

        
            if(tsmap != null && !tsmap.isEmpty() && tsmap.containsKey('updateAccountQBRDate') && tsmap.get('updateAccountQBRDate') != null && tsmap.get('updateAccountQBRDate').Execute__c && !TriggerUtility.isupdateAccountQBRDate()){
                EventTriggerhelper.updateAccountQBRDate(Trigger.New);
            }  
        } 
        
        if(trigger.isBefore && (trigger.isInsert || trigger.isUpdate)){
            if(tsmap != null && !tsmap.isEmpty() && tsmap.containsKey('updateCheckbox') && tsmap.get('updateCheckbox') != null && tsmap.get('updateCheckbox').Execute__c && !TriggerUtility.isupdateEventComplete()){
                EventTriggerhelper.updateCheckbox(trigger.new);
            }   
        }
        //CR# 349 - Parth Doshi - End
        
        //Added by Abhishek: Sales Teaming: Start
        if(trigger.isAfter && trigger.isInsert && !TriggerUtility.isEventAfterInsertExecuted()){
            EventTriggerhelper.afterInsert(trigger.new);
        }

        if(trigger.isAfter && trigger.isUpdate && !TriggerUtility.isEventAfterUpdateExecuted()){
            EventTriggerhelper.afterUpdate(trigger.new, trigger.oldMap);
        }
        //Added by Abhishek: Sales Teaming: End
        //CR# 562 - Commented by Parth Doshi
        /*if(trigger.isBefore && trigger.isDelete){
            //if(!TriggerUtility.isActivityleadterritoryEventinsertExecuted()){
                system.debug('before calling EventTriggerhelper.AutocreateSCI ');
                EventTriggerhelper.DeleteSCI(trigger.old,trigger.OldMap);
            //}
        }*/
    }
}