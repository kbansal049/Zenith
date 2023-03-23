public class TaskTriggerHelper{
    // Added as a part of CR# 584 : Gurjinder :Start
    public static void BeforeInsertTask(List<Task> Tasklist){
        for(Task tsk:Tasklist){
            if(tsk.Type==null || tsk.Type==''){
                tsk.Type='Call';            
            }
        }

        //Added By Anup : CR#832 - Start
        Map<String, Triggers_Switch__c> tsmap = Triggers_Switch__c.getAll();
        if(tsmap != null && !tsmap.isEmpty() && tsmap.containsKey('Execute_Task_CampaignMostRecent') && tsmap.get('Execute_Task_CampaignMostRecent') != null && tsmap.get('Execute_Task_CampaignMostRecent').Execute__c && !TriggerUtility.isPopulateCampaignMostRecentOnTaskExecuted()){
            populateCampaignMostRecentOnActivity(Tasklist);
        }
        //Added By Anup : CR#832 - End
    }
    
    //CR# 4090 added parameter oldTaskList
    public static void BeforeUpdateTask(List<Task> Tasklist, List<Task> oldTaskList){
        Map<Id, Task> oldTaskMap = new Map<Id, Task>(oldTaskList);
        inspire1__InspirePlannerConfig__c inspirePlannerConfigCustomSetting = inspire1__InspirePlannerConfig__c.getInstance();
        for(Task tsk:Tasklist){
            //CR# 4090 START
            Task oldTask = oldTaskMap.get(tsk.Id);
            //CR# 4090 END
            if(tsk.Type==null || tsk.Type==''){ 
                tsk.Type='Call';
            }
            //CR# 4090 START
            //Workflow Name : Populate Task Actual Costs
            if ((tsk.inspire1__Planned_Effort__c != oldTask.inspire1__Planned_Effort__c || 
                tsk.inspire1__Hourly_Rate__c != oldTask.inspire1__Hourly_Rate__c ||
                tsk.inspire1__Actual_Effort__c != oldTask.inspire1__Actual_Effort__c) && 
                inspirePlannerConfigCustomSetting.inspire1__Use_Effort_to_Calculate_Cost__c == true &&
                (String.isNotBlank(tsk.inspire1__Inspire_Task__c) || !''.equalsIgnoreCase(tsk.inspire1__Schedule_As__c))) {

                tsk.inspire1__Actual_Cost__c = tsk.inspire1__Actual_Cost__c * tsk.inspire1__Hourly_Rate__c;
            }
            //CR# 4090 END
        }
        
    } 
        // Added as a part of CR# 584 : Gurjinder :End
    //Added By Swathi: CR#1416 - Start
    public static void Afterinsert(map<id, Task> newActivityMap ){
        Map<String, Triggers_Switch__c> tsmap = Triggers_Switch__c.getAll();
        if(tsmap != null && !tsmap.isEmpty() && tsmap.containsKey(L2O_Constants.LeadObject.TRIGGER_SWITCH_EXECUTE_CONTACT_LEAD_RELATED_TASK) && tsmap.get(L2O_Constants.LeadObject.TRIGGER_SWITCH_EXECUTE_CONTACT_LEAD_RELATED_TASK) != null && tsmap.get(L2O_Constants.LeadObject.TRIGGER_SWITCH_EXECUTE_CONTACT_LEAD_RELATED_TASK).Execute__c && !TriggerUtility2.isupdateTaskRelatedContOrLeadExecuted()){
            UpdateTaskafterupdate(newActivityMap,Null);
        }   
        //Start CR#4571: Karthik
        if(tsmap != null && !tsmap.isEmpty() && tsmap.containsKey('Execute_Task_PopulateSDR') && tsmap.get('Execute_Task_PopulateSDR') != null && tsmap.get('Execute_Task_PopulateSDR').Execute__c && !populateSDROnTaskExecuted){
            List<Task> discoveryTasks = new List<Task>();
            for(Task tsk: newActivityMap.values()){
                if(tsk.Type == System.Label.Task_Type_Discovery_Meeting){
                	discoveryTasks.add(tsk);
            	}
            }
            populateSDROnContactLead(discoveryTasks);
        }
         //End CR#4571: Karthik
   
    } 
     
    public static void AfterUpdateTask(map<id, Task> newActivityMap, map<id, Task> OldMap){
        Map<String, Triggers_Switch__c> tsmap = Triggers_Switch__c.getAll();
        if(tsmap != null && !tsmap.isEmpty() && tsmap.containsKey(L2O_Constants.LeadObject.TRIGGER_SWITCH_EXECUTE_CONTACT_LEAD_RELATED_TASK) && tsmap.get(L2O_Constants.LeadObject.TRIGGER_SWITCH_EXECUTE_CONTACT_LEAD_RELATED_TASK) != null && tsmap.get(L2O_Constants.LeadObject.TRIGGER_SWITCH_EXECUTE_CONTACT_LEAD_RELATED_TASK).Execute__c && !TriggerUtility2.isupdateTaskRelatedContOrLeadExecuted()){
            UpdateTaskafterupdate(newActivityMap,OldMap);
        }
    } 
    //Added By Swathi: CR#1416 - End
    
    //Added By Anup : CR#832-Start
    public static void populateCampaignMostRecentOnActivity(List<Task> newTaskList){
        Map<Id, List<Task>> leadIdTaskMap = new Map<Id, List<Task>>();
        map<Id, List<Task>> contactIdTaskMap = new Map<Id, List<Task>>();
        Map<Id,Id> mapOfLeadContactAndCampaign = new Map<Id,Id>();
        for(Task t : newTaskList){
            if(t.WhoId != null){
                Schema.SObjectType token = t.WhoId.getSObjectType();
                String objName  = token.getDescribe().getName();
                if(objName == 'Lead'){
                    if(!leadIdTaskMap.containsKey(t.WhoId)){
                        leadIdTaskMap.put(t.WhoId, new List<Task>());
                    }
                    leadIdTaskMap.get(t.WhoId).add(t);
                }   
                if(objName == 'Contact'){   
                    if(!contactIdTaskMap.containsKey(t.WhoId)){
                        contactIdTaskMap.put(t.WhoId, new List<Task>());
                    }
                    contactIdTaskMap.get(t.WhoId).add(t);
                }
            }
        }
        if(!leadIdTaskMap.isEmpty()){
            for(Lead currLead : [select id, Most_Recent_Campaign2__c, Most_Recent_Campaign2__r.Id, Qualifying_SDR__c from Lead where Id IN:leadIdTaskMap.keyset()]){
                mapOfLeadContactAndCampaign.put(currLead.id, currLead.Most_Recent_Campaign2__r.Id);
            }
        }

        if(!contactIdTaskMap.isEmpty()){
            for(Contact currContact : [select id, Most_Recent_Campaign__c, Most_Recent_Campaign__r.Id, Qualifying_SDR__c from Contact where Id IN:contactIdTaskMap.keyset()]){
                mapOfLeadContactAndCampaign.put(currContact.id, currContact.Most_Recent_Campaign__r.Id);
            }
        }
        
        for(Task currTask : newTaskList){
            if(mapOfLeadContactAndCampaign.containsKey(currTask.WhoId) && mapOfLeadContactAndCampaign.get(currTask.WhoId) != null){
                system.debug('adding Most Recent Campaign :'+mapOfLeadContactAndCampaign.get(currTask.WhoId));
                currTask.Campaign__c = mapOfLeadContactAndCampaign.get(currTask.WhoId);
            }
        }

        TriggerUtility.PopulateCampaignMostRecentOnTaskExecuted();
    }
    //Added By Anup : CR#832-End
    
    
    //Added By Swathi: CR#1127/CR#1416 - Start
    public static void UpdateTaskafterupdate(map<id, Task> newActivityMap,map<id, Task> oldMap ){
        if(!newActivityMap.isEmpty() && !system.isFuture() && !system.isBatch() && !system.isQueueable() && !test.isRunningTest()){
            Set<Id> taskIds = new Set<Id>();
            for(Task t : newActivityMap.values()){
                if(t.WhoId != null){
                    taskIds.add(t.Id);
                }
            }
            System.enqueuejob(new UpdateTaskSDRFieldsbasedOnLeadAndCont(taskIds));
        }
        TriggerUtility2.updateTaskRelatedContOrLeadExecuted();
        
    }
     //Added By Swathi: CR#1127/CR#1416 - End

    //CR# 4443 START
    //Flow Name : AutoUpdate Lead and Contact based on task - V2 START
    public static void processLeads(Map<Id, List<Task>> leadIdToListOfTasksMap) {
        if (!leadIdToListOfTasksMap.isEmpty()) {
            List<Lead> leadList = [SELECT Id, Status, Qualified_Date__c, Qualifying_SDR__c, Funnel_Stage_Date__c, Funnel_Stage__c 
                FROM Lead WHERE Id IN :leadIdToListOfTasksMap.keySet()];
            List<Lead> leadsToUpdateList = new List<Lead>();
            for (Lead currentLead : leadList) {
                Boolean leadUpdated = false;
                for (Task associatedTask : leadIdToListOfTasksMap.get(currentLead.Id)) {
                    if (String.isNotBlank(associatedTask.Role_of_Creator_When_Created1__c) && associatedTask.Role_of_Creator_When_Created1__c.contains('SDR') && associatedTask.WhatId == null && 
                        (currentLead.Qualified_Date__c == null || currentLead.Qualifying_SDR__c == null)) {

                        currentLead.Qualified_Date__c = Date.today();
                        currentLead.Qualifying_SDR__c = associatedTask.CreatedById;
                        leadUpdated = true;
                    } 
                    if (!L2O_Constants.TaskObject.TASK_STATUS_COMPLETED.equalsIgnoreCase(associatedTask.Status) && !L2O_Constants.LeadObject.LEAD_STATUS_ACTIVELY_ENGAGED.equalsIgnoreCase(currentLead.Status)) {
                        currentLead.Status = L2O_Constants.LeadObject.LEAD_STATUS_MEETING_SCHEDULED;
                        currentLead.Funnel_Stage_Date__c = Date.today();
                        currentLead.Funnel_Stage__c = 'Discovery Meeting Scheduled';
                        leadUpdated = true;
                    } else if (L2O_Constants.TaskObject.TASK_STATUS_COMPLETED.equalsIgnoreCase(associatedTask.Status) && !L2O_Constants.LeadObject.LEAD_STATUS_ACTIVELY_ENGAGED.equalsIgnoreCase(currentLead.Status)) {
                        currentLead.Status = L2O_Constants.LeadObject.LEAD_STATUS_MEETING_SCHEDULED;
                        currentLead.Funnel_Stage_Date__c = Date.today();
                        currentLead.Funnel_Stage__c = 'Discovery Meeting Completed';
                        leadUpdated = true;
                    }
                }
                if (leadUpdated) {
                    leadsToUpdateList.add(currentLead);
                }
            }
            if (!leadsToUpdateList.isEmpty()) {
                update leadsToUpdateList;
            }
        }
    }

    public static void processContacts(Map<Id, List<Task>> contactIdToListOfTasksMap) {
        if (!contactIdToListOfTasksMap.isEmpty()) {
            List<Contact> contactList = [SELECT Id, Qualified_Date__c, Qualifying_SDR__c, Contact_Lead_Status__c, Funnel_Stage_Date__c, Funnel_Stage__c FROM Contact WHERE Id IN :contactIdToListOfTasksMap.keySet()];
            List<Contact> contactsToUpdateList = new List<Contact>();
            for (Contact currentContact : contactList) {
                Boolean contactUpdated = false;
                for (Task associatedTask : contactIdToListOfTasksMap.get(currentContact.Id)) {
                    if (String.isNotBlank(associatedTask.Role_of_Creator_When_Created1__c) && associatedTask.Role_of_Creator_When_Created1__c.contains('SDR') && associatedTask.WhatId == null && 
                        (currentContact.Qualified_Date__c == null || currentContact.Qualifying_SDR__c == null)) {

                        currentContact.Qualified_Date__c = Date.today();
                        currentContact.Qualifying_SDR__c = associatedTask.CreatedById;
                        contactUpdated = true;
                    }
                    if (L2O_Constants.TaskObject.TASK_STATUS_COMPLETED.equalsIgnoreCase(associatedTask.Status) && !L2O_Constants.LeadObject.LEAD_STATUS_ACTIVELY_ENGAGED.equalsIgnoreCase(currentContact.Contact_Lead_Status__c) && 
                        !'Actively Engaged (System Use)'.equalsIgnoreCase(currentContact.Contact_Lead_Status__c) && !'Processing (System Use)'.equalsIgnoreCase(currentContact.Contact_Lead_Status__c)) {
                        currentContact.Contact_Lead_Status__c = L2O_Constants.LeadObject.LEAD_STATUS_MEETING_SCHEDULED;
                        currentContact.Funnel_Stage_Date__c = Date.today();
                        currentContact.Funnel_Stage__c = 'Discovery Meeting Completed';
                        contactUpdated = true;
                    } else if (!L2O_Constants.TaskObject.TASK_STATUS_COMPLETED.equalsIgnoreCase(associatedTask.Status) && !L2O_Constants.LeadObject.LEAD_STATUS_ACTIVELY_ENGAGED.equalsIgnoreCase(currentContact.Contact_Lead_Status__c) && 
                        !'Actively Engaged (System Use)'.equalsIgnoreCase(currentContact.Contact_Lead_Status__c) && !'Processing (System Use)'.equalsIgnoreCase(currentContact.Contact_Lead_Status__c)) {
                        currentContact.Contact_Lead_Status__c = L2O_Constants.LeadObject.LEAD_STATUS_MEETING_SCHEDULED;
                        currentContact.Funnel_Stage_Date__c = Date.today();
                        currentContact.Funnel_Stage__c = 'Discovery Meeting Scheduled';
                        contactUpdated = true;
                    }
                }
                if (contactUpdated) {
                    contactsToUpdateList.add(currentContact);
                }
            }
            if (!contactsToUpdateList.isEmpty()) {
                update contactsToUpdateList;
            }
        }
    }
    //Flow Name : AutoUpdate Lead and Contact based on task - V2 END
    //CR# 4443 END

    //Start CR# 4571: Karthik
    private static boolean populateSDROnTaskExecuted= false; 
     
    public static void populateSDROnContactLead(List<Task> newTaskList){
        Map<Id,Id> leadIdTaskMap = new Map<Id,Id>();
        Map<Id, Id> contactIdTaskMap = new Map<Id,Id>();
        for(Task t : newTaskList){
            if(t.WhoId != null){
                Schema.SObjectType token = t.WhoId.getSObjectType();
                String objName  = token.getDescribe().getName();
                if(objName == 'Lead'){
                    
                    leadIdTaskMap.put(t.WhoId,t.OwnerId);
                }   
                else if(objName == 'Contact'){   
                    
                    contactIdTaskMap.put(t.WhoId,t.OwnerId);
                }
            }
        }
        if(!leadIdTaskMap.isEmpty()){
            List<Lead> leadsToUpdate = new List<Lead>();
            for(Lead currLead : [select id, Qualifying_SDR__c , Qualified_Date__c  from Lead where Id IN:leadIdTaskMap.keyset()]){
                if(leadIdTaskMap.containsKey(currLead.Id) && (String.isBlank(currLead.Qualifying_SDR__c) || currLead.Qualified_Date__c == null || currLead.Qualifying_SDR__c != leadIdTaskMap.get(currLead.Id) || currLead.Qualified_Date__c != system.today() )){
                    currLead.Qualifying_SDR__c = leadIdTaskMap.get(currLead.Id);
                    currLead.Qualified_Date__c = system.today();
                    leadsToUpdate.add(currLead);
                }
            }
                    
            if(!leadsToUpdate.isEmpty()){
                update leadsToUpdate;     
            }
        }

        if(!contactIdTaskMap.isEmpty()){
            List<Contact> consToUpdate = new List<Contact>();
            for(Contact currContact : [select id, Qualifying_SDR__c , Qualified_Date__c  from Contact where Id IN:contactIdTaskMap.keyset()]){
                if(contactIdTaskMap.containsKey(currContact.Id) && (String.isBlank(currContact.Qualifying_SDR__c) || currContact.Qualified_Date__c == null || currContact.Qualifying_SDR__c != contactIdTaskMap.get(currContact.Id) || currContact.Qualified_Date__c != system.today() )){
                    currContact.Qualifying_SDR__c = contactIdTaskMap.get(currContact.Id);
                    currContact.Qualified_Date__c = system.today();
                    consToUpdate.add(currContact);
                }
            }
            if(!consToUpdate.isEmpty()){
                update consToUpdate;     
            }
        }
        
        populateSDROnTaskExecuted = true;
    }
        
    //End CR# 4571: Karthik

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────┐
    * This Method was added as part of JIRA ID IBA-6527 : to populate territory fields on task from
                                                          the associated Lead/Contact.
    * ──────────────────────────────────────────────────────────────────────────────────────────────
    * @method   NAME : populateTerritoryFields .
    * @param    NAME : List<Task> newTaskList .
    * @return   TYPE : void .
    * ─────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static void populateTerritoryFields(List<Task> newTasksList) {
        if (newTasksList != null) {
            Set<Id> leadIdsSet = new Set<Id>();
            Set<Id> contactIdsSet = new Set<Id>();
            List<Task> filteredTasksList = new List<Task>();

            for (Task currentTask : newTasksList) {
                if (currentTask.WhoId != null) {
                    if (String.valueOf(currentTask.WhoId).startsWith(ZScalarConstants.LEAD_ID_PREFIX)) {
                        leadIdsSet.add(currentTask.WhoId);
                    } else if (String.valueOf(currentTask.WhoId).startsWith(ZScalarConstants.CONTACT_ID_PREFIX)) {
                        contactIdsSet.add(currentTask.WhoId);
                    }
                    filteredTasksList.add(currentTask);
                }
            }

            Map<Id, Lead> leadIdToLeadMap = getLeadsByIds(leadIdsSet);
            Map<Id, Contact> contactIdToContactMap = getContactsByIds(contactIdsSet);

            for (Task currentTask : filteredTasksList) {
                if (leadIdToLeadMap.containsKey(currentTask.WhoId) && leadIdToLeadMap.get(currentTask.WhoId).Territory__c != null) {
                    currentTask.Sales_Territory__c = leadIdToLeadMap.get(currentTask.WhoId).Territory__r.Name;
                    currentTask.Territory_Area__c = leadIdToLeadMap.get(currentTask.WhoId).Territory__r.Area__c;
                    currentTask.Territory_Geo__c = leadIdToLeadMap.get(currentTask.WhoId).Territory__r.Theater__c;
                    currentTask.Territory_Type__c = leadIdToLeadMap.get(currentTask.WhoId).Territory__r.Territory_Type__c;
                } else if (contactIdToContactMap.containsKey(currentTask.WhoId) && contactIdToContactMap.get(currentTask.WhoId).Territory__c != null) {
                    currentTask.Sales_Territory__c = contactIdToContactMap.get(currentTask.WhoId).Territory__r.Name;
                    currentTask.Territory_Area__c = contactIdToContactMap.get(currentTask.WhoId).Territory__r.Area__c;
                    currentTask.Territory_Geo__c = contactIdToContactMap.get(currentTask.WhoId).Territory__r.Theater__c;
                    currentTask.Territory_Type__c = contactIdToContactMap.get(currentTask.WhoId).Territory__r.Territory_Type__c;
                }
            }
        }
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────┐
    * This Method was added as part of JIRA ID IBA-6527 : to get the Lead records based on the ids.
    * ──────────────────────────────────────────────────────────────────────────────────────────────
    * @method   NAME : getLeadsByIds .
    * @param    NAME : Set<Id> leadIdsSet .
    * @return   TYPE : Map<Id, Lead> leadIdToLeadMap.
    * ─────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static Map<Id, Lead> getLeadsByIds(Set<Id> leadIdsSet) {
        if (leadIdsSet == null || leadIdsSet.isEmpty()) {
            return new Map<Id, Lead>();
        }
        Map<Id, Lead> leadIdToLeadMap = new Map<Id, Lead> ([SELECT Id, Territory__c, Territory__r.Name, Territory__r.Area__c, Territory__r.Theater__c, Territory__r.Territory_Type__c 
                                                            FROM Lead WHERE Id IN :leadIdsSet]);
        return leadIdToLeadMap;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────┐
    * This Method was added as part of JIRA ID IBA-6527 : to get the Contact records based on the ids.
    * ──────────────────────────────────────────────────────────────────────────────────────────────
    * @method   NAME : getContactsByIds .
    * @param    NAME : Set<Id> contactIdsSet .
    * @return   TYPE : Map<Id, Contact> contactIdToContactMap.
    * ─────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static Map<Id, Contact> getContactsByIds(Set<Id> contactIdsSet) {
        if (contactIdsSet == null || contactIdsSet.isEmpty()) {
            return new Map<Id, Contact>();
        }
        Map<Id, Contact> contactIdToContactMap = new Map<Id, Contact> ([SELECT Id, Territory__c, Territory__r.Name, Territory__r.Area__c, Territory__r.Theater__c, Territory__r.Territory_Type__c 
                                                                        FROM Contact WHERE Id IN :contactIdsSet]);
        return contactIdToContactMap;
    }
}