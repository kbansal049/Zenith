/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* TaskTriggerHandler
* @description    This is the Task Trigger handler class called synchronously from TaskMasterTrigger.
*				  All the methods needs to be called synchronously from the Task Trigger
* 				  should be called from here in the before/after insert/update methods.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Zscaler
* @modifiedBy     
* @maintainedBy   Zscaler
* @version        1.0
* @created        2022-03-14
* @modified       
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* vX.X            Developer Name
* YYYY-MM-DD      Explanation of the change.  Multiple lines can be used to explain the change, but
*                 each line should be indented till left aligned with the previous description text.
*
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
**/
public class TaskTriggerHandler extends TriggerHandler {

    public override void beforeInsert() {
        List<Task> newTaskList = (List<Task>)Trigger.New;

        //TaskCreatorRole Trigger START
        String currentUserRoleId = UserInfo.getUserRoleId();
        String roleName = '';
        if (currentUserRoleId != null) {
            roleName = [SELECT Name FROM UserRole WHERE Id = :currentUserRoleId].Name;
        }
        for(Task currentTask : newTaskList)  {
            currentTask.Role_of_Creator_When_Created1__c = roleName;

            //Flow Name : Activity Type - V1 - START
            if (String.isNotBlank(currentTask.Type)) {
                currentTask.Activity_Type__c = currentTask.Type;
            }
            //Flow Name : Activity Type - V1 - END

            //Workflow Name : Task Type Disovery Meeting
            if ('Kronologic - Meeting Accepted'.equalsIgnoreCase(currentTask.Subject)) {
                currentTask.Type = 'Discovery Meeting';
            }
        }
        //TaskCreatorRole Trigger END

        //GenericTaskTrigger Trigger START
        TaskTriggerHelper.BeforeInsertTask(newTaskList);
        //GenericTaskTrigger Trigger END

        // IBA-6527 START
        TaskTriggerHelper.populateTerritoryFields(newTaskList);
        // IBA-6527 END
    }

    public override void beforeUpdate() {
        List<Task> newTaskList = (List<Task>) Trigger.New;
        Map<Id, Task> oldTaskMap = (Map<Id, Task>) Trigger.oldMap;

        for (Task currentTask : newTaskList) {
            Task oldTask = oldTaskMap.get(currentTask.Id);

            //Flow Name : Activity Type - V1 - START
            if (currentTask.Type != oldTask.Type && String.isNotBlank(currentTask.Type)) {
                currentTask.Activity_Type__c = currentTask.Type;
            }
            //Flow Name : Activity Type - V1 - END
        }

        //GenericTaskTrigger Trigger START
        TaskTriggerHelper.BeforeUpdateTask(newTaskList, oldTaskMap.values());
        //GenericTaskTrigger Trigger END
    }

    public override void beforeDelete() {

    }

    public override void afterInsert() {
        List<Task> newTaskList = (List<Task>)Trigger.New;
        Map<Id, Task> newTaskMap = new Map<Id, Task>(newTaskList);
        List<Id> contactIdList = new List<Id>();
        Set<Id> allIdSet = new Set<Id>();
        for (Task currentTask : newTaskList) {

            //UpdateTouchesOnContactOnTaskInsertUpdate Trigger Logic START
            //if the whoid is a contact and the status is completed
            if(currentTask.WhoId != null && String.Valueof(currentTask.WhoId).substring(0,3) == '003'){
                contactIdList.add(currentTask.WhoId);       
            }

            //UpdateTouchesOnContactOnTaskInsertUpdate Trigger Logic END

            //APTS_UpdateProposalStage Trigger START
            if(currentTask.WhatId != null && currentTask.Subject == 'Cloned from Proposal') {
                allIdSet.add(currentTask.WhatId);
            }
            //APTS_UpdateProposalStage Trigger END
        }

        //UpdateTouchesOnContactOnTaskInsertUpdate Trigger Logic START
        if(!contactIdList.isEmpty()){
            UpdateTouchesHandler up = new UpdateTouchesHandler();
            up.updateTouchesTaskEvent(contactIdList);
        }
        //UpdateTouchesOnContactOnTaskInsertUpdate Trigger Logic END

        //GenericTaskTrigger Trigger START
        if(!TriggerUtility.isCampMemActivityExecuted())
           CaptureActivityOnLead.getActivityDetail(newTaskMap);
        
        TaskTriggerHelper.Afterinsert(newTaskMap); //Added By Swathi: CR#1416
        //GenericTaskTrigger Trigger END

    }

    public override void afterUpdate() {
        List<Task> newTaskList = (List<Task>) Trigger.New;
        Map<Id, Task> newTaskMap = new Map<Id, Task>(newTaskList);
        Map<Id, Task> oldTaskMap = (Map<Id, Task>) Trigger.oldMap;
        List<Id> contactIdList = new List<Id>();

        for (Task currentTask : newTaskList) {

            //UpdateTouchesOnContactOnTaskInsertUpdate Trigger Logic START
            //if the whoid is a contact and the status has changed to completed
            if(currentTask.WhoId != null && String.Valueof(currentTask.WhoId).substring(0,3) == '003' && 
                currentTask.Status != oldTaskMap.get(currentTask.id).Status && currentTask.Status == 'Completed'){
                
                contactIdList.add(currentTask.WhoId);       
            } 
            //UpdateTouchesOnContactOnTaskInsertUpdate Trigger Logic END

            // Commenting the flow code as this flow runs asynchronously
            //Flow Name : AutoUpdate Lead and Contact based on task - V2 START
            // if ('Discovery Meeting'.equalsIgnoreCase(currentTask.Type) && currentTask.whoId != null && (currentTask.Type != oldTask.Type || currentTask.Status != oldTask.Status || currentTask.whoId != oldTask.WhoId ||
            //     currentTask.whatId != oldTask.WhatId || currentTask.Role_of_Creator_When_Created1__c != oldTask.Role_of_Creator_When_Created1__c)) {

            //     if (String.valueOf(currentTask.WhoId).startsWith(LEAD_ID_PREFIX)) {
            //         if (leadIdToListOfTasksMap.containsKey(currentTask.whoId)) {
            //             leadIdToListOfTasksMap.get(currentTask.whoId).add(currentTask);
            //         } else {
            //             leadIdToListOfTasksMap.put(currentTask.whoId, new List<Task> {currentTask});
            //         }
            //     } else if (String.valueOf(currentTask.WhoId).startsWith(CONTACT_ID_PREFIX)) {
            //         if (contactIdToListOfTasksMap.containsKey(currentTask.whoId)) {
            //             contactIdToListOfTasksMap.get(currentTask.whoId).add(currentTask);
            //         } else {
            //             contactIdToListOfTasksMap.put(currentTask.whoId, new List<Task> {currentTask});
            //         }
            //     }
            // }
            //Flow Name : AutoUpdate Lead and Contact based on task - V2 END
        }

        //Flow Name : AutoUpdate Lead and Contact based on task - V2 START
        // TaskTriggerHelper.processLeads(leadIdToListOfTasksMap);
        // TaskTriggerHelper.processContacts(contactIdToListOfTasksMap);
        //Flow Name : AutoUpdate Lead and Contact based on task - V2 END

        //UpdateTouchesOnContactOnTaskInsertUpdate Trigger Logic START
        if(!contactIdList.isEmpty()){
            UpdateTouchesHandler up = new UpdateTouchesHandler();
            up.updateTouchesTaskEvent(contactIdList);
        }
        
        //UpdateTouchesOnContactOnTaskInsertUpdate Trigger Logic END

        //GenericTaskTrigger Trigger START
        TaskTriggerHelper.afterUpdateTask(newTaskMap, oldTaskMap);
        //GenericTaskTrigger Trigger END
    }

    public override void afterDelete() {
        List<Task> deletedTaskList = (List<Task>) Trigger.Old;
    	List<Id> contactIdList = new List<Id>();
        for (Task currentTask : deletedTaskList) {
            //UpdateTouchesOnContactOnTaskInsertUpdate Trigger Logic START
            //if the whoid is a contact and the status has changed to completed
            if(currentTask.WhoId != null && String.Valueof(currentTask.WhoId).substring(0,3) == '003'){
                contactIdList.add(currentTask.WhoId);       
            } 
        }
        if(!contactIdList.isEmpty()){
            UpdateTouchesHandler up = new UpdateTouchesHandler();
            up.updateTouchesTaskEvent(contactIdList);
        }
        
    }

    public override void afterUndelete() {
        
    }
}