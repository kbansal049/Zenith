public class UpdateTouchesHandler {

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────┐
    * This Method was refactored as part of JIRA ID IBA-6394 : to update touches information on contacts 
                                                               from the associated Tasks and Events.
    * ──────────────────────────────────────────────────────────────────────────────────────────────
    * @Method   NAME : updateTouchesTaskEvent .
    * @param    NAME : List<Id> contact_ids .
    * @return   TYPE : void .
    * ─────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public void updateTouchesTaskEvent(List<Id> contact_ids){

        Map<Id, Contact> contactIdToContactMap = new Map<Id, Contact> ([SELECT Id, Last_Opened_Date__c FROM Contact WHERE Id IN :contact_ids]);
        UpdateTouchesHandlerWrapper wrapper = prepareTouchesOnTasks(contactIdToContactMap);
        wrapper = prepareTouchesOnEvents(contactIdToContactMap, wrapper);

        List<Contact> contactListToUpdate = new List<Contact>();
        for (Id contactId : wrapper.contactIdsSet) {
            Contact contactToUpdate = new Contact(Id = contactId);
            if (wrapper.contactIdToTouchesSinceLastOpenCountMap.containsKey(contactId)) {
                contactToUpdate.Touches_Since_Last_Open__c = wrapper.contactIdToTouchesSinceLastOpenCountMap.get(contactId);
            }
            if (wrapper.contactIdToOpenTasksCountMap.containsKey(contactId)) {
                contactToUpdate.Open_Activities__c = wrapper.contactIdToOpenTasksCountMap.get(contactId);
            }
            contactToUpdate.Activities__c = wrapper.contactIdToTotalTasksCountMap.get(contactId);

            contactListToUpdate.add(contactToUpdate);
        }

        if (!contactListToUpdate.isEmpty()) {
            TriggerUtility2.updateTouchesSinceLastOpenExecuted();
            Triggerhandler.bypass('ContactTriggerHandler');
            update contactListToUpdate;
            TriggerHandler.clearBypass('ContactTriggerHandler');
        }
    }
	
    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────┐
    * This Method was added as part of JIRA ID IBA-6394 : to prepare touches information of contacts 
                                                          from associated Tasks.
    * ──────────────────────────────────────────────────────────────────────────────────────────────
    * @Method   NAME : prepareTouchesOnTasks .
    * @param    NAME : Set<Id> contact_ids .
    * @return   TYPE : UpdateTouchesHandlerWrapper : contains the touches information in maps and set .
    * ─────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    @testVisible
	private UpdateTouchesHandlerWrapper prepareTouchesOnTasks(Map<Id, Contact> contactIdToContactMap) {

        UpdateTouchesHandlerWrapper wrapper = new UpdateTouchesHandlerWrapper();
        if (contactIdToContactMap != null) {
            List<Task> tasksList = [SELECT Id, ActivityDate, Status, WhoId FROM Task
                                    WHERE WhoId IN :contactIdToContactMap.keySet() 
                                    ORDER BY LastModifiedDate DESC];

            for (Task currentTask : tasksList) {
                if (contactIdToContactMap.containsKey(currentTask.WhoId) && contactIdToContactMap.get(currentTask.WhoId).Last_Opened_Date__c != null) {
                    if (!wrapper.contactIdToIsLatestTaskCompletedMap.containsKey(currentTask.WhoId)) {
                        Boolean isLatestTaskCompleted = (currentTask.Status == L2O_Constants.TaskObject.TASK_STATUS_COMPLETED);
                        wrapper.contactIdToIsLatestTaskCompletedMap.put(currentTask.WhoId, isLatestTaskCompleted);
                    }
                    if (wrapper.contactIdToIsLatestTaskCompletedMap.get(currentTask.WhoId) && currentTask.Status == L2O_Constants.TaskObject.TASK_STATUS_COMPLETED && 
                        currentTask.ActivityDate >= contactIdToContactMap.get(currentTask.WhoId).Last_Opened_Date__c) {
                        
                        if (!wrapper.contactIdToTouchesSinceLastOpenCountMap.containsKey(currentTask.WhoId)) {
                            wrapper.contactIdToTouchesSinceLastOpenCountMap.put(currentTask.WhoId, 0);
                        }
                        wrapper.contactIdToTouchesSinceLastOpenCountMap.put(currentTask.WhoId, 
                            wrapper.contactIdToTouchesSinceLastOpenCountMap.get(currentTask.WhoId) + 1);
                    }
                    if (currentTask.Status != L2O_Constants.TaskObject.TASK_STATUS_COMPLETED) {
                        if (!wrapper.contactIdToOpenTasksCountMap.containsKey(currentTask.WhoId)) {
                            wrapper.contactIdToOpenTasksCountMap.put(currentTask.WhoId, 0);
                        }
                        wrapper.contactIdToOpenTasksCountMap.put(currentTask.WhoId, wrapper.contactIdToOpenTasksCountMap.get(currentTask.WhoId) + 1);
                    }
                    if (!wrapper.contactIdToTotalTasksCountMap.containsKey(currentTask.WhoId)) {
                        wrapper.contactIdToTotalTasksCountMap.put(currentTask.WhoId, 0);
                    }
                    wrapper.contactIdToTotalTasksCountMap.put(currentTask.WhoId, wrapper.contactIdToTotalTasksCountMap.get(currentTask.WhoId) + 1);
                    wrapper.contactIdsSet.add(currentTask.WhoId);
                }
            }
        }
        return wrapper;
	}

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────┐
    * This Method was added as part of JIRA ID IBA-6394 : to prepare touches information of contacts 
                                                          from associated Events.
    * ──────────────────────────────────────────────────────────────────────────────────────────────
    * @Method   NAME : prepareTouchesOnEvents .
    * @param    NAME : Set<Id> contact_ids .
    * @param    NAME : UpdateTouchesHandlerWrapper wrapper  : contains the touches information from tasks .
    * @return   TYPE : UpdateTouchesHandlerWrapper          : contains the touches information in maps and set .
    * ─────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    @testVisible
    private UpdateTouchesHandlerWrapper prepareTouchesOnEvents(Map<Id, Contact> contactIdToContactMap, UpdateTouchesHandlerWrapper wrapper) {
        
        if (contactIdToContactMap != null && wrapper != null) {
            DateTime currentTime = System.now();
            List<Event> eventsList = [SELECT Id, ActivityDate, StartDateTime, EndDate, EndDateTime, WhoId FROM Event 
                                      WHERE WhoId IN :contactIdToContactMap.keySet()];
    
            for (Event currentEvent : eventsList) {
                if (contactIdToContactMap.containsKey(currentEvent.WhoId) && contactIdToContactMap.get(currentEvent.WhoId).Last_Opened_Date__c != null) {
                    if (wrapper.contactIdToIsLatestTaskCompletedMap.containsKey(currentEvent.WhoId) && wrapper.contactIdToIsLatestTaskCompletedMap.get(currentEvent.WhoId) && 
                        currentEvent.EndDateTime <= currentTime && currentEvent.ActivityDate >= contactIdToContactMap.get(currentEvent.WhoId).Last_Opened_Date__c) {
                        
                        if (!wrapper.contactIdToTouchesSinceLastOpenCountMap.containsKey(currentEvent.WhoId)) {
                            wrapper.contactIdToTouchesSinceLastOpenCountMap.put(currentEvent.WhoId, 0);
                        }
                        wrapper.contactIdToTouchesSinceLastOpenCountMap.put(currentEvent.WhoId, 
                            wrapper.contactIdToTouchesSinceLastOpenCountMap.get(currentEvent.WhoId) + 1);
        
                        wrapper.contactIdsSet.add(currentEvent.WhoId);
                    }
                }
            }
        }
        return wrapper;
    }

    public class UpdateTouchesHandlerWrapper {
        public Map<Id, Integer> contactIdToTouchesSinceLastOpenCountMap = new Map<Id, Integer>();
        public Map<Id, Integer> contactIdToOpenTasksCountMap = new Map<Id, Integer>();
        public Map<Id, Integer> contactIdToTotalTasksCountMap = new Map<Id, Integer>();
        public Map<Id, Boolean> contactIdToIsLatestTaskCompletedMap = new Map<Id, Boolean>();

        public Set<Id> contactIdsSet = new Set<Id>();
    }
}