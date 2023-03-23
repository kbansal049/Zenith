trigger OpportunityMasterTrigger on Opportunity (before insert, before update, after insert, after update, before delete, after delete, after undelete) {
    
    new OpportunityTriggerHandler().run();
    
    /*Map<String, Triggers_Switch__c> tsmap = Triggers_Switch__c.getAll();
    Boolean skiptrigger = false;
    Skip_Triggers_User_Based__c usertoskip = Skip_Triggers_User_Based__c.getInstance(Userinfo.getUserId());
    system.debug('usertoskip '+usertoskip);
    SObjectType triggerType = trigger.isDelete ? trigger.old.getSObjectType() : trigger.new.getSObjectType();
    system.debug('triggerType '+triggerType);
    String objname = triggerType.getDescribe().getName();
    system.debug('objname '+objname);
    if(objname != null && usertoskip.Id != null && usertoskip.Object_s_to_skip__c != null && usertoskip.Object_s_to_skip__c.split(';') != null && !usertoskip.Object_s_to_skip__c.split(';').isEmpty() && usertoskip.Object_s_to_skip__c.split(';').contains(objname)){
        skiptrigger = true;
    }
    system.debug('skiptrigger '+skiptrigger);
    
	//Added by Gurjinder for Opp Creation Issue :Start
	if(trigger.Isbefore && trigger.isInsert && !TriggerUtility.isSkipAccTriggerExecuted()){ 
		TriggerUtility.SkipAccTriggerExecuted();
	}
	//Added by Gurjinder for Opp Creation Issue : End

    if(!skiptrigger && !TriggerUtility.isSkipOppTriggerExecuted() && tsmap != null && !tsmap.isEmpty() && tsmap.containsKey('Execute_Opp_Trigger') && tsmap.get('Execute_Opp_Trigger') != null && tsmap.get('Execute_Opp_Trigger').Execute__c){
        system.debug('inside conditions');
        if(trigger.isBefore && trigger.isinsert && !TriggerUtility2.isOppBeforeInsertExecuted()){
            OpportunityMasterTriggerUtility.beforeInsert(Trigger.new);
        }
        if(trigger.isBefore && trigger.isUpdate && !TriggerUtility2.isOppBeforeUpdateExecuted()){
            System.debug('-Trigger.new-'+Trigger.new);
            System.debug('-trigger.OldMap-'+trigger.OldMap);
            OpportunityMasterTriggerUtility.beforeUpdate(Trigger.new, trigger.OldMap);
        }
        if(trigger.isAfter && trigger.isInsert && !TriggerUtility2.isOppAfterInsertExecuted()){
            system.debug('inside after insert condition');
            OpportunityMasterTriggerUtility.afterInsert(Trigger.new);
            //Added by Chandan : CR#2742
            CustomerRenewalReminderHandler custRenReminderInstance = CustomerRenewalReminderHandler.getInstance();
            custRenReminderInstance.handle();
        
            //Added by Chandan : CR# 2741
            if (!OpportunitySplitOwnerEmailService.sendOpportunitySplitOwnerEmails) {
                OpportunitySplitOwnerEmailService splitOwnerEmailServinstance = OpportunitySplitOwnerEmailService.getInstance();
                splitOwnerEmailServinstance.process();
            }
        }
        
        if(trigger.isAfter && trigger.isUpdate && !TriggerUtility2.isOppAfterUpdateExecuted()){
            system.debug('inside after update condition');
            OpportunityMasterTriggerUtility.afterUpdate(Trigger.new, trigger.OldMap);
            //Added by Chandan : CR#2742
            CustomerRenewalReminderHandler custRenReminderInstance = CustomerRenewalReminderHandler.getInstance();
            custRenReminderInstance.handle();
            
            //Added by Chandan : CR# 2741
            if (!OpportunitySplitOwnerEmailService.sendOpportunitySplitOwnerEmails) {
                OpportunitySplitOwnerEmailService splitOwnerEmailServinstance = OpportunitySplitOwnerEmailService.getInstance();
                splitOwnerEmailServinstance.process();
            }
            
            
        }
        if(trigger.isAfter && Trigger.isInsert && !TriggerUtility2.isOppAfterInsertExecuted() )  {
            OpportunityChangeRequestCtrl.setAuditRecord(Trigger.New,null);
        }
        if(trigger.isAfter && Trigger.isUpdate && !TriggerUtility2.isOppAfterUpdateExecuted() )  {
            OpportunityChangeRequestCtrl.setAuditRecord(Trigger.New,Trigger.OldMap);
        }
        
        //Added by Varun : CR# 1824 - Start
        if(Trigger.isAfter && (Trigger.isUpdate || Trigger.isInsert)){
            if(!TriggerUtility.isupdateInsertStageAgeExecuted()){
                OppotunityTriggerHelper.updateInsertStageAge(Trigger.new, Trigger.oldMap);
            }
        }
        //Added by Varun : CR# 1824 - End
        
        
        
    }
    if(test.isrunningtest()){
    integer i=0;
    i++;
    i++;
    i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
    i++;
    i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
    i++;
    i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
    i++;
    i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
    i++;
    i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
    }
*/
    
}