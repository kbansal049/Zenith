/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* EventTriggerHandler
* @description    This is the Event Trigger handler class called synchronously from EventMasterTrigger.
*				  All the methods needs to be called synchronously from the Event Trigger
* 				  should be called from here in the before/after insert/update methods.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Zscaler
* @modifiedBy     
* @maintainedBy   Zscaler
* @version        1.0
* @created        2022-03-15
* @modified       
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* vX.X            Developer Name
* YYYY-MM-DD      Explanation of the change.  Multiple lines can be used to explain the change, but
*                 each line should be indented till left aligned with the previous description text.
*
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
**/
public class EventTriggerHandler extends TriggerHandler {
    static String updateRelatedToFieldStr = 'Execute_UpdateRelatedToField';
    static String updateCheckboxStr = 'updateCheckbox';
    static String executeEventTriggerStr = 'Execute_Event_Trigger';
    static String executeMeetingTechTeamingPartnerStr = 'Execute_Meeting_Tech_Teaming_Partner';
    static String executeUpdateTargetCustomerNumberStr = 'Execute_UpdateTargetCustomerNumber';
    static String updateAccountQBRDateStr = 'updateAccountQBRDate';

    public override void beforeInsert() {
        List<Event> newEventList = (List<Event>) Trigger.new;

        //EventTrigger Trigger START
        Boolean skipTrigger = isSkipTrigger();
        Map<String, Triggers_Switch__c> tsmap = Triggers_Switch__c.getAll();
        //EventTrigger Trigger END

        //EventCreateRole Trigger START
        String currentUserRoleId = UserInfo.getUserRoleId();
        String roleName = '';
        if(currentUserRoleId != null)  {
            roleName = [SELECT Name FROM UserRole WHERE Id = :currentUserRoleId].Name;
        }
        //EventCreateRole Trigger END

        for(Event currentEvent : newEventList)  {
            //EventCreateRole Trigger START
            currentEvent.Role_of_Creator_When_Created1__c  = roleName;

            //Criteria Name : Event: Update the Event Owner when its created by LDR START
            if (roleName.contains('LDR')) {
                currentEvent.OwnerId = UserInfo.getUserId();
            }
            //Criteria Name : Event: Update the Event Owner when its created by LDR END
            //EventCreateRole Trigger END

            //Flow Name : Activity Type Event - V1 START
            if (String.isNotBlank(currentEvent.Type)) {
                currentEvent.Activity_Type__c = currentEvent.Type;
            }
            //Flow Name : Activity Type Event - V1 END

            //Process Name : Event: Update the Event Owner when its created by LDR
        }

        //EventTrigger Trigger START
        if(!skiptrigger 
            && !TriggerUtility.isSkipEventTriggerExecuted() 
            && tsmap != null 
            && !tsmap.isEmpty() 
            && tsmap.containsKey(executeEventTriggerStr) 
            && tsmap.get(executeEventTriggerStr) != null 
            && tsmap.get(executeEventTriggerStr).Execute__c) {

            //CR# 670
            if(tsmap.containsKey(executeMeetingTechTeamingPartnerStr) 
                && tsmap.get(executeMeetingTechTeamingPartnerStr) != null 
                && tsmap.get(executeMeetingTechTeamingPartnerStr).Execute__c 
                && !TriggerUtility.isCreateOpportunityPartnerFromEventExecuted()) {
                
                EventTriggerhelper.shouldCreateTechTeamingPartner(newEventList);
            }

            //CR# 2914 - Added by Ritesh Kumar - start
            if(tsmap.containsKey(updateRelatedToFieldStr) 
                && tsmap.get(updateRelatedToFieldStr) != null 
                && tsmap.get(updateRelatedToFieldStr).Execute__c 
                && !TriggerUtility.isupdateRelatedToFieldExecuted()) {
                EventTriggerhelper.updateRelatedToField(newEventList, null);
            }
            
            if(tsmap.containsKey(executeUpdateTargetCustomerNumberStr) 
                && tsmap.get(executeUpdateTargetCustomerNumberStr) != null 
                && tsmap.get(executeUpdateTargetCustomerNumberStr).Execute__c 
                && !TriggerUtility.isupdateTargetCustomerNumberExecuted()) {
                EventTriggerhelper.updateTargetCustomerNumber(newEventList, null);
            }
            //CR# 2914 - Added by Ritesh Kumar - End

            //CR# 349 - Parth Doshi - Start
            if(tsmap.containsKey(updateCheckboxStr) 
                && tsmap.get(updateCheckboxStr) != null 
                && tsmap.get(updateCheckboxStr).Execute__c 
                && !TriggerUtility.isupdateEventComplete()){
                EventTriggerhelper.updateCheckbox(newEventList);
            }
            //CR# 349 - Parth Doshi - End
        }
        //EventTrigger Trigger END
    }

    public override void beforeUpdate() {
        List<Event> newEventList = (List<Event>) Trigger.new;
        Map<Id, Event> oldEventMap = (Map<Id, Event>) Trigger.oldMap;
        Boolean skipTrigger = isSkipTrigger();
        Map<String, Triggers_Switch__c> tsmap = Triggers_Switch__c.getAll();

        for (Event currentEvent : newEventList) {
            Event oldEvent = oldEventMap.get(currentEvent.Id);

            //Flow Name : Activity Type Event - V1 START
            if (currentEvent.Type != oldEvent.Type && String.isNotBlank(currentEvent.Type)) {
                currentEvent.Activity_Type__c = currentEvent.Type;
            }
            //Flow Name : Activity Type Event - V1 END
        }

        if(!skiptrigger 
            && !TriggerUtility.isSkipEventTriggerExecuted() 
            && tsmap != null 
            && !tsmap.isEmpty() 
            && tsmap.containsKey(executeEventTriggerStr) 
            && tsmap.get(executeEventTriggerStr) != null 
            && tsmap.get(executeEventTriggerStr).Execute__c) {
            //CR# 670
            if(tsmap.containsKey(executeMeetingTechTeamingPartnerStr) 
                && tsmap.get(executeMeetingTechTeamingPartnerStr) != null 
                && tsmap.get(executeMeetingTechTeamingPartnerStr).Execute__c 
                && !TriggerUtility.isCreateOpportunityPartnerFromEventExecuted()) {
                EventTriggerhelper.shouldCreateTechTeamingPartner(newEventList);
            }

            //CR# 2914 - Added by Ritesh Kumar - start
            if(tsmap.containsKey(updateRelatedToFieldStr) 
                && tsmap.get(updateRelatedToFieldStr) != null 
                && tsmap.get(updateRelatedToFieldStr).Execute__c 
                && !TriggerUtility.isupdateRelatedToFieldExecuted()) {
                EventTriggerhelper.updateRelatedToField(newEventList, oldEventMap);
            }
            
            if(tsmap.containsKey(executeUpdateTargetCustomerNumberStr) 
                && tsmap.get(executeUpdateTargetCustomerNumberStr) != null 
                && tsmap.get(executeUpdateTargetCustomerNumberStr).Execute__c 
                && !TriggerUtility.isupdateTargetCustomerNumberExecuted()) {
                EventTriggerhelper.updateTargetCustomerNumber(newEventList, oldEventMap);
            }
            //CR# 2914 - Added by Ritesh Kumar - End

            //CR# 349 - Parth Doshi - Start
            if(tsmap.containsKey(updateCheckboxStr) 
                && tsmap.get(updateCheckboxStr) != null 
                && tsmap.get(updateCheckboxStr).Execute__c 
                && !TriggerUtility.isupdateEventComplete()){
                EventTriggerhelper.updateCheckbox(newEventList);
            }
            //CR# 349 - Parth Doshi - End
        }
    }

    public override void afterInsert() {
        List<Event> newEventList = (List<Event>) Trigger.new;
        
        //EventTrigger Trigger START
        Boolean skipTrigger = isSkipTrigger();
        Map<String, Triggers_Switch__c> tsmap = Triggers_Switch__c.getAll();
        //EventTrigger Trigger END

        //Process Name : Auto update Lead & contact based upon event type START
        EventTriggerHelper.updateLeadAndContact(newEventList);
        //Process Name : Auto update Lead & contact based upon event type END

        //UpdateTouchesOnContactOnEventInsertUpdate Trigger START
        updateTouchesOnContactOnEventInsertUpdate(newEventList);
        //UpdateTouchesOnContactOnEventInsertUpdate Trigger END

        //EventTrigger Trigger START
        if(!skiptrigger 
            && !TriggerUtility.isSkipEventTriggerExecuted() 
            && tsmap != null 
            && !tsmap.isEmpty() 
            && tsmap.containsKey(executeEventTriggerStr) 
            && tsmap.get(executeEventTriggerStr) != null 
            && tsmap.get(executeEventTriggerStr).Execute__c) {

            if(!TriggerUtility.isGroove2SCIcodeexecuted){
                EventTriggerhelper.AutocreateSCI(newEventList, null, Trigger.isInsert, Trigger.isUpdate);
            }

            //CR# 349 - Parth Doshi - Start
            EventTriggerhelper.setCountOfSCIs(newEventList);

            if(tsmap.containsKey(updateAccountQBRDateStr) 
                && tsmap.get(updateAccountQBRDateStr) != null 
                && tsmap.get(updateAccountQBRDateStr).Execute__c 
                && !TriggerUtility.isupdateAccountQBRDate()){
    	        EventTriggerhelper.updateAccountQBRDate(newEventList);
        	}
            //CR# 349 - Parth Doshi - End

            //Added by Abhishek: Sales Teaming: Start
            if (!TriggerUtility.isEventAfterInsertExecuted()) {
                EventTriggerhelper.afterInsert(newEventList);
            }
            //Added by Abhishek: Sales Teaming: End
        }
        //EventTrigger Trigger END

        //Added by Anup - Scheduler Project
        EventTriggerhelper.createEventRelationRecords(newEventList);
        //Added by Anup - Scheduler Project
    }

    public override void afterUpdate() {
        List<Event> newEventList = (List<Event>) Trigger.new;
        Map<Id, Event> oldEventMap = (Map<Id, Event>) Trigger.oldMap;
        
        //Process Name : Auto update Lead & contact based upon event type START
        EventTriggerHelper.updateLeadAndContactForUpdate(newEventList, oldEventMap);
        //Process Name : Auto update Lead & contact based upon event type END

        //EventTrigger Trigger START
        Boolean skipTrigger = isSkipTrigger();
        Map<String, Triggers_Switch__c> tsmap = Triggers_Switch__c.getAll();
        //EventTrigger Trigger END

        //UpdateTouchesOnContactOnEventInsertUpdate Trigger START
        updateTouchesOnContactOnEventInsertUpdate(newEventList);
        //UpdateTouchesOnContactOnEventInsertUpdate Trigger END

        if(!skiptrigger 
            && !TriggerUtility.isSkipEventTriggerExecuted() 
            && tsmap != null 
            && !tsmap.isEmpty() 
            && tsmap.containsKey(executeEventTriggerStr) 
            && tsmap.get(executeEventTriggerStr) != null 
            && tsmap.get(executeEventTriggerStr).Execute__c) {
            if(!TriggerUtility.isGroove2SCIcodeexecuted){
                EventTriggerhelper.AutocreateSCI(newEventList, oldEventMap, Trigger.isInsert, Trigger.isUpdate);
            }

            //CR# 349 - Parth Doshi - Start
            EventTriggerhelper.setCountOfSCIs(newEventList);
            //CR# 349 - Parth Doshi - End

            //Added by Abhishek: Sales Teaming: Start
            if (!TriggerUtility.isEventAfterUpdateExecuted()) {
                EventTriggerhelper.afterUpdate(newEventList, oldEventMap);
            }
            //Added by Abhishek: Sales Teaming: End
        }
    }

    public override void afterDelete() {
        List<Event> oldEventList = (List<Event>) Trigger.old;
        
        //EventTrigger Trigger START
        Boolean skipTrigger = isSkipTrigger();
        Map<String, Triggers_Switch__c> tsmap = Triggers_Switch__c.getAll();
        //EventTrigger Trigger END

        if(!skiptrigger 
            && !TriggerUtility.isSkipEventTriggerExecuted() 
            && tsmap != null 
            && !tsmap.isEmpty() 
            && tsmap.containsKey(executeEventTriggerStr) 
            && tsmap.get(executeEventTriggerStr) != null 
            && tsmap.get(executeEventTriggerStr).Execute__c) {
            EventTriggerhelper.setCountOfSCIs(oldEventList);
        }
    }

    @testVisible
    private void updateTouchesOnContactOnEventInsertUpdate(List<Event> eventList) {
        Set<Id> contactIdSet = new Set<Id>();
        for(Event currentEvent : eventList){
            //if the whoid is a contact and the status is completed
            if(currentEvent.WhoId != null 
                && String.Valueof(currentEvent.WhoId).substring(0,3) == '003'){
                contactIdSet.add(currentEvent.WhoId);
            }
        }

        if(!contactIdSet.isEmpty()){
            List<Id> contactIdList = new List<Id>(contactIdSet);
            UpdateTouchesHandler up = new UpdateTouchesHandler();
            up.updateTouchesTaskEvent(contactIdList);
        }
    }

    @testVisible
    private Boolean isSkipTrigger() {
        //Added by Abhishek: Sales Teaming: Start
        Boolean skipTrigger = false;
        Skip_Triggers_User_Based__c userToSkip = Skip_Triggers_User_Based__c.getInstance(Userinfo.getUserId());
        SObjectType triggerType = trigger.isDelete ? trigger.old.getSObjectType() : trigger.new.getSObjectType();
        String objname = triggerType.getDescribe().getName();
        if(objname != null 
            && userToSkip.Id != null 
            && userToSkip.Object_s_to_skip__c != null 
            && userToSkip.Object_s_to_skip__c.split(';') != null 
            && !userToSkip.Object_s_to_skip__c.split(';').isEmpty() 
            && userToSkip.Object_s_to_skip__c.split(';').contains(objname)){
            skipTrigger = true;
        }
        return skipTrigger;
        //Added by Abhishek: Sales Teaming: End
    }
}