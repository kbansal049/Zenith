public class EventTriggerhelper{
    static final String APEX_CLASS_NAME = 'EventTriggerhelper';

    static String executeEventCustomerScroceCardStr = 'Execute_EventCustomerScroceCard';
    static String caseStatusToMeettingScheduleStr = 'Case_Status_To_Meetting_Schedule';
    static String meetingScheduledStr = 'Meeting Scheduled';
    static String pgDiscoveryCallStr = 'PG - Discovery Call';
    static String pgNewBusinessMeetingStr = 'PG - New Business Meeting';
    static String completedStr = 'Completed';

    //Added by Abhishek: Sales Teaming: Start
    public static void afterInsert(List<Event> newEventlst){
        Map<String, Triggers_Switch__c> tsmap = Triggers_Switch__c.getAll();
        
        if(tsmap != null 
            && !tsmap.isEmpty() 
            && tsmap.containsKey('updateAccountQBRDate') 
            && tsmap.get('updateAccountQBRDate') != null 
            && tsmap.get('updateAccountQBRDate').Execute__c 
            && !TriggerUtility.isupdateAccountQBRDate()){
            updateAccountQBRDate(newEventlst);
        } 

        //Added by Swathi : CR1408 start
        if(tsmap != null 
            && !tsmap.isEmpty() 
            && tsmap.containsKey(completedStr) 
            && tsmap.get(completedStr) != null 
            && tsmap.get(completedStr).Execute__c 
            && !TriggerUtility2.isUpdateEventCustomerScroceCardExecuted()){
            updateEventCustomerScroceCard(newEventlst,null);
        }
        //Added by Swathi : CR1408 End

        if(tsmap != null 
        && !tsmap.isEmpty() 
        && tsmap.containsKey(caseStatusToMeettingScheduleStr) 
        && tsmap.get(caseStatusToMeettingScheduleStr) != null 
        && tsmap.get(caseStatusToMeettingScheduleStr).Execute__c 
        && (!TriggerUtility.isCaseStatusUpdateMeetingSchedule() 
            || Test.isRunningTest())){
            Map<Id, Event> oldEventmap = new Map<Id, Event> ();
            updateCaseStutusToMeetingShceduled(newEventlst,oldEventmap);        
        }
    }
    
    public static void afterUpdate(List<Event> newEventlst, Map<Id, Event> oldEventmap){
        Map<String, Triggers_Switch__c> tsmap = Triggers_Switch__c.getAll();
        //Added by Swathi : CR1408 start
        if(tsmap != null 
            && !tsmap.isEmpty() 
            && tsmap.containsKey(completedStr) 
            && tsmap.get(completedStr) != null 
            && tsmap.get(completedStr).Execute__c 
            && !TriggerUtility2.isUpdateEventCustomerScroceCardExecuted()){
            updateEventCustomerScroceCard(newEventlst,oldEventmap);
        }
        //Added by Swathi : CR1408 end
        if(tsmap != null 
            && !tsmap.isEmpty() 
            && tsmap.containsKey(caseStatusToMeettingScheduleStr) 
            && tsmap.get(caseStatusToMeettingScheduleStr) != null 
            && tsmap.get(caseStatusToMeettingScheduleStr).Execute__c 
            && (!TriggerUtility.isCaseStatusUpdateMeetingSchedule() 
                || Test.isRunningTest())){
            updateCaseStutusToMeetingShceduled(newEventlst,oldEventmap);
        }
    }

    //Added by Abhishek: Sales Teaming: End
    Public static void AutocreateSCI(List<Event> newEventlst, Map<Id, Event> oldEventmap, Boolean isInsert, Boolean isUpdate){
        
    }
    
    
    public static void DeleteSCI(List<Event> newEventlst,Map<Id, Event> oldEventmap){
        Set<id> eventIdSet = new Set<id>();
        for(Event evnt : newEventlst){
            eventIdSet.add(evnt.id);
        }
        
        delete [SELECT Id FROM Significant_Customer_Interaction__c WHERE Meeting_ID__c IN :eventIdSet];
    }
    
    //CR# 349 - by Parth Doshi - Start
    public static void setCountOfSCIs(List<Event> newEventlst){
        set<Id> accIds = new set<Id>();
        for(Event evnt: newEventlst){
            if(evnt.accountId != null 
                && findObjectAPIName(evnt.accountId) == 'Account'){
                accIds.add(evnt.accountId);
            }
        }
        if(!accIds.isEmpty()){
            Map<Id,Account> mapOfIdVsAccount = new Map<Id,Account>([SELECT Id, Count_of_SCIs__c FROM Account WHERE Id IN :accIds]);
            if(!mapOfIdVsAccount.isEmpty()){
                List<Event> pastEvents = new List<Event>();
                pastEvents = [SELECT Id, StartDateTime, accountId 
                                FROM Event 
                                WHERE accountId IN :mapOfIdVsAccount.keySet() 
                                AND StartDateTime < :System.now() 
                                AND peopleai__MeetingStatus__c != 'Canceled'];
                if(!pastEvents.isEmpty()){
                    Map<Id,Integer> mapOfAccIdVsCount = new Map<Id,Integer>();
                    for(Event evnt : pastEvents){
                        Integer count = 0;
                        if(mapOfAccIdVsCount.get(evnt.accountId) != null){
                            count = mapOfAccIdVsCount.get(evnt.accountId);
                        }
                        count += 1;
                        mapOfAccIdVsCount.put(evnt.accountId,count);
                    }

                    // Now Update Account's Count_of_SCIs__c field
                    for(Id accId : mapOfIdVsAccount.keySet()){
                        if(mapOfAccIdVsCount.get(accId) != null){
                            Account acc = mapOfIdVsAccount.get(accId);
                            acc.Count_of_SCIs__c = mapOfAccIdVsCount.get(accId);
                            mapOfIdVsAccount.put(acc.Id,acc);
                        }
                    }

                    // Update Account
                    update mapOfIdVsAccount.values();
                }
            }
        }
    }
    
    public static string findObjectAPIName(String recordId){
        if(recordId == null){return null;}
        Id recId = (Id) recordId;
        String objectAPIName = recId.getSObjectType().getDescribe().getName();
        return objectAPIName;
    }
    
    
    public static void updateAccountQBRDate(List<Event> lstEvents)  {
        Map<String,Event> eventMap = new map<String,Event>();
        
        for(Event ob:lstEvents){
            if(String.isNotEmpty(ob.Type) 
                && String.isNotEmpty(ob.WhatId) 
                && (ob.Type.equals(System.Label.Post_Sale_Operational_Review) 
                    || ob.Type.equals(System.Label.Post_Sale_Executive_Review)) 
                && String.valueOf(ob.WhatId).startsWithIgnoreCase('001')){        
                eventMap.put(ob.WhatId, ob);                    
            }
        }
        List<Account> acclst = [SELECT Id, Next_QBR_Date__c FROM Account WHERE Id IN :eventMap.keySet()];
        if(!acclst.isEmpty()) {
            for(Account accob:acclst){
                Event obevent = eventMap.get(accob.id);
                accob.Next_QBR_Date__c=Date.valueOf(obevent.StartDateTime);
            }
            update acclst;
        }
    }
    
    public static void updateCheckbox(List<Event> lst)  {
        for(Event e : lst)  {
            if(e.peopleai__MeetingStatus__c != null && e.peopleai__MeetingStatus__c == completedStr)  {
                e.Is_Event_Completed__c  = true;
            }else  {
                e.Is_Event_Completed__c  = false;
            }
        }
    }
    //CR# 349 - by Parth Doshi - End
    
    //CR# 670
    public static void shouldCreateTechTeamingPartner(List<Event> newEventlst){
        List<Event> validEvents = new List<Event>();
        
        for(Event ev: newEventlst){
            if(Trigger.isUpdate){
                if(ev.type != null 
                    && ev.peopleai__MeetingStatus__c == completedStr 
                    && (ev.Technology_Partner_Associated__c == 'Not Associated' 
                        || ev.Technology_Partner_Associated__c == 'Not Applicable' 
                        || ev.Technology_Partner_Associated__c == null)){
                    validEvents.add(ev);
                }
            }else if(Trigger.isInsert){
                if(ev.type != null 
                    && ev.peopleai__MeetingStatus__c == completedStr){
                    validEvents.add(ev);
                }
            }
        }
        
        if(!validEvents.isEmpty()){
            //get all valid Domains for Tech partner
            List<String> validDomains = FillValidDomainsList(); 
            
            //update the Technology_Partner_Associated__c picklist value
            for(Event ev: validEvents){
                if(ev.Opportunity__c != null){
                    ev.Technology_Partner_Associated__c = checkforTheValidPeopleAIParticipants(validDomains,ev.peopleai__Participants__c) ? 'Needs to be Associated' : 'No Partner Found';
                }else{
                    ev.Technology_Partner_Associated__c = 'Not Applicable';
                }
            }
        }
        TriggerUtility.createOpportunityPartnerFromEventExecuted();
    }
    
    
    public static List<String> FillValidDomainsList(){
        List<String> validDomains = new List<String>();
        for(Event_Tech_Partner_Automation__mdt etp : [SELECT Valid_Domains__c FROM Event_Tech_Partner_Automation__mdt]){
            if(etp.Valid_Domains__c != null){
                for(String dom : etp.Valid_Domains__c.Split(',')){
                    if(dom != null && String.isNotEmpty(dom)){
                        validDomains.add(dom.trim());
                    }
                }
            }
        }
        
        return validDomains;
    }
    
    
    //CR# 670 Validate tech Partners Email is there in participants or not
    public Static Boolean checkforTheValidPeopleAIParticipants(List<String> validDomains,String participants){
        Boolean retVal = false;
        
        if(participants == null 
            || String.isEmpty(participants) 
            || validDomains == null 
            || validDomains.isEmpty()){
            return retVal;
        }
        
        for(String participantEmail : participants.split(',')){
            for(String dom : validDomains){
                String domCheck = '@' + dom;
                if(participantEmail.containsIgnoreCase(domCheck)){
                    return true;
                }
            }
        }
        return retVal;
    }   

    //Added by Swathi : CR1408 start
    public static void updateEventCustomerScroceCard(List<Event> lstEvents,Map<Id, Event> oldEventmap)  {

        Map<String,List<Event>> eventMap=new map<String,List<Event>>(); 
        List<Customer_Score_Card__c> csmlstToUpdate = new List<Customer_Score_Card__c>();
        List<Event> eventList = new List<Event>();
        for(Event ob:lstEvents){
            if((oldEventmap == null 
                    && String.isNotEmpty(ob.AccountId) 
                    && ob.peopleai__MeetingStatus__c == completedStr) 
                || (oldEventmap != null 
                    && String.isNotEmpty(ob.AccountId) 
                    && ob.peopleai__MeetingStatus__c == completedStr 
                    && (oldEventmap.get(ob.id).peopleai__MeetingStatus__c != ob.peopleai__MeetingStatus__c 
                        || ob.peopleai__Participants__c!=oldEventmap.get(ob.Id).peopleai__Participants__c))){        
                eventList.add(ob);                    
            }
            if(!eventList.isEmpty()){
                eventMap.put(ob.AccountId, eventList);
            }
        }
        List<Customer_Score_Card__c> CSMlst = [SELECT Id, Account__r.Id, DateTimeoflastExecMeeting__c, Account__r.HeadOfIT__r.email, 
                                                Account__r.Head_of_Architecture__r.email, Account__r.HeadOfNetworking__r.email, 
                                                Account__r.HeadOfSecurity__r.email 
                                                FROM Customer_Score_Card__c 
                                                WHERE Account__c IN : eventMap.keySet()];
        if(!CSMlst.isEmpty() && !eventMap.isEmpty()){
            for(Customer_Score_Card__c accob:CSMlst){
                for(Event ob_event : eventMap.get(accob.Account__r.id)){
                    if(ob_event.peopleai__Participants__c != null){
                        if((accob.Account__r.HeadOfIT__c != null 
                                && ob_event.peopleai__Participants__c.contains(accob.Account__r.HeadOfIT__r.email)) 
                            || (accob.Account__r.Head_of_Architecture__c != null 
                                && ob_event.peopleai__Participants__c.contains(accob.Account__r.Head_of_Architecture__r.email)) 
                            || (accob.Account__r.HeadOfNetworking__c != null 
                                && ob_event.peopleai__Participants__c.contains(accob.Account__r.HeadOfNetworking__r.email)) 
                            || (accob.Account__r.HeadOfSecurity__c != null 
                                && ob_event.peopleai__Participants__c.contains(accob.Account__r.HeadOfSecurity__r.email))){
                            accob.DateTimeoflastExecMeeting__c=ob_event.StartDateTime;  
                            csmlstToUpdate.add(accob);
                        }
                    }
                }
            }
            if(!csmlstToUpdate.isEmpty()){
                update csmlstToUpdate;
            }
        }
        TriggerUtility2.UpdateEventCustomerScroceCardExecuted();
    }
    //Added by Swathi : CR1408 End

    //CR# 1415 PB to Trigger Update CaseStatus to meeting Scheduled
    public Static void updateCaseStutusToMeetingShceduled(List<Event> eventList, Map<Id, Event> oldEventmap){
        Set<String> chiliStatusSet = new Set<String>();
        Chili_Piper_Status__mdt[] chiliPiperStatuses = [SELECT MasterLabel, QualifiedApiName FROM Chili_Piper_Status__mdt];
        
        for (Chili_Piper_Status__mdt chiliPiperStatus : chiliPiperStatuses) {
            chiliStatusSet.add(chiliPiperStatus.MasterLabel);
        }
        
        Set<id> caseIdsFromEvents = new Set<id>();
        Map<id,boolean> caseIdsForEventsCancel = new Map<id,boolean>();
        for(Event event : eventList){
            if(String.isNotBlank(event.WhatId) 
                && String.valueOf(event.WhatId).startsWithIgnoreCase('500') 
                && String.isNotBlank(event.Meeting_Type_CP__c) 
                && chiliStatusSet.contains(event.Meeting_Type_CP__c) 
                && (Trigger.isInsert || event.Canceled_CP__c != oldEventmap.get(event.Id).Canceled_CP__c)){
                caseIdsForEventsCancel.put(event.WhatId,event.Canceled_CP__c);
            }
            if(String.isNotBlank(event.WhatId) 
                && String.valueOf(event.WhatId).startsWithIgnoreCase('500') 
                && String.isNotBlank(event.Meeting_Type_CP__c) && chiliStatusSet.contains(event.Meeting_Type_CP__c) 
                && (Trigger.isInsert 
                    || (!chiliStatusSet.contains(oldEventmap.get(event.Id).Meeting_Type_CP__c) 
                        && event.Meeting_Type_CP__c != oldEventmap.get(event.Id).Meeting_Type_CP__c))){
                caseIdsFromEvents.add(event.WhatId);
            }
        }

        //GCS Support - 30min
        if(!caseIdsFromEvents.isEmpty()){
            List<Case> caseList = [SELECT Id, status FROM Case WHERE Id In :caseIdsFromEvents];
            List<FeedItem> lstFeeditems = new List<FeedItem>();
            if(!caseList.isEmpty()){
                for(Case caseObj : caseList){
                    if(caseIdsForEventsCancel.keyset().contains(caseObj.id) 
                        && !caseIdsForEventsCancel.get(caseObj.id)){
                        caseObj.Chili_Piper_Meeting_Status__c = 'Scheduled';  
                        FeedItem post = new FeedItem();
                        post.ParentId = caseObj.Id;
                        post.Body = 'Customer Meeting Scheduled';
                        post.Visibility = 'InternalUsers';
                        lstFeeditems.add(post);
                    }
                }
                update caseList;
            }
            if(!lstFeeditems.isEmpty()){
                insert lstFeeditems;
            }
        }
        
        //event.cancel_cp__c update
        if(!caseIdsForEventsCancel.isEmpty()){
            List<Case> caseList = [SELECT Id, Status FROM Case WHERE Id In :caseIdsForEventsCancel.keyset()];
            if(!caseList.isEmpty()){
                for(Case caseObj : caseList){
                    caseObj.Chili_Piper_Meeting_Status__c = caseIdsForEventsCancel.get(caseObj.id) ? 'Cancelled (If CP Meeting is cancelled)':'Scheduled';
                }
                update caseList;
            }
        }
        TriggerUtility.startCaseStatusUpdateMeetingSchedule();
    }

    //CR# 2914 - Added by Ritesh Kumar - start
    public static void updateRelatedToField(List<Event> eventList,Map<Id,Event> eventOldMap) {
        Set<String> domainSet = new Set<String>();
        Map<String,Event> domaintoEventMap = new Map<String,Event>();
        for(Event eventRecord : eventList){
            //RelatedTo field is updated if meeting type equals Channel - opportunity or channel - Interlock
            if(eventRecord.Type == 'Channel - Opportunity' 
                || eventRecord.Type == 'Channel - Interlock'){
                if(eventRecord.WhatId != null 
                    && eventOldMap != null 
                    && eventRecord.WhatId != eventOldMap?.get(eventRecord.Id)?.WhatId){ 
                    eventRecord.Related_To_Override__c = true;
                } //Should not overwrite once manually updated by RSM/RAM            
                else if(String.isNotBlank(eventRecord.peopleai__Participants__c) 
                    && (eventRecord.WhatId == null || !eventRecord.Related_To_Override__c)){
                    List<String> emails = eventRecord.peopleai__Participants__c.removeEndIgnoreCase(' More in People.ai...').split(','); //Remove end of the field
                    for(String email : emails){
                        String domain = email.trim().substringAfter('@');
                        if(!domain.containsIgnoreCase('zscaler')){ //System should not consider all zscaler domain
                            domainSet.add(domain);
                            domaintoEventMap.put(domain, eventRecord);
                        }
                    }
                }
            }
        }

        if(!domainSet.isEmpty()){            
            //SOSL to find domain matches in accounts
            List<Account> accountList = new List<Account>();
            if(domainSet.size() == 1){
                String findStr = (new List<string>(domainSet))[0];
                findStr = findStr.contains('-') ? findStr.replace('-', '\\-') : findStr; //Reserved characters, if specified in a text search, must be escaped
                //CR# 3795 START - Bikram 8th Dec 2021
                //To avoid System.SearchException: search term must be longer than one character:
                List<List<SObject>> soslResults = new List<List<SObject>>();
                if(findStr.length() > 1){
                    soslResults = [FIND :findStr IN ALL FIELDS 
                                   RETURNING Account(ID, Ultimate_Parent_Account__c, Name, Additional_Organization_Domains__c, Domain__c, Type 
                                                     WHERE Additional_Organization_Domains__c != null or Domain__c != null)];
                }

                //CR# 3795 END - Bikram 8th Dec 2021
                if(!soslResults.isEmpty()){
                    accountList = (List<Account>) soslResults[0];
                }                
            } 
            //In case of multiple domains of participants, consider only accounts with Type as Partner.
            else {
                String tempStr = domainSet.toString();
                tempStr = tempStr.replace(', ', ' OR '); //Combine domain using OR into String
                tempStr = tempStr.contains('-') ? tempStr.replace('-','\\-') : tempStr; //Reserved characters, if specified in a text search, must be escaped
                
                //CR# 3795 START - Bikram 8th Dec 2021
                //To avoid System.SearchException: search term must be longer than one character:
                List<List<SObject>> soslResults = new List<List<SObject>>();
                if(tempStr.length() > 1){
                    soslResults = [ FIND :tempStr IN ALL FIELDS 
                                   RETURNING Account(ID, Ultimate_Parent_Account__c, Name, Additional_Organization_Domains__c, Domain__c, Type  
                                                     WHERE Type = 'Partner' AND (Additional_Organization_Domains__c != null or Domain__c != null))];
                }
                //CR# 3795 END - Bikram 8th Dec 2021
                if(!soslResults.isEmpty()){
                    accountList = (List<Account>) soslResults[0];
                }
            }
    
            Map<String, Id> domainToAccountMap = new Map<String, Id>();
            Map<Id, Account> accountMap = new Map<Id, Account>();
            for (Account accRecord : accountList) {
                String domainStr = '';
                domainStr = String.valueOf(accRecord.Domain__c != null ? accRecord.Domain__c : '');
                domainStr = domainStr + ',' + String.valueOf(accRecord.Additional_Organization_Domains__c != null ? accRecord.Additional_Organization_Domains__c : '');
                domainStr = domainStr.removeStart(',');
                domainStr = domainStr.remove('@');
                for (String domain : domainStr.split(',')) {
                    if(domainSet.contains(domain)){
                        accountMap.put(accRecord.Id, accRecord);
                        if(domainToAccountMap.containsKey(domain)){ 
                            if(accountMap.get(domainToAccountMap.get(domain)).Type != 'Partner'){ domainToAccountMap.put(domain.trim(), accRecord.Id); }
                        }else{
                            domainToAccountMap.put(domain.trim(), accRecord.Id);
                        }                        
                    }
                }
            }
    
            //List<Event> listName = new List<Event>();
            for (String domain : domaintoEventMap.keySet()) {
                if(domainToAccountMap.containsKey(domain)){
                    Account acc = accountMap.get(domainToAccountMap.get(domain));
                    Event event = domaintoEventMap.get(domain);
                    //If it's a child account then mark and update with it's ultimate parent account only.
                    event.WhatId = acc.Ultimate_Parent_Account__c != null ? acc.Ultimate_Parent_Account__c : acc.Id;
                    event.Related_To_Override__c = false;
                }
            }        
        }
        TriggerUtility.updateRelatedToFieldExecuted();
    }

    public static void updateTargetCustomerNumber(List<Event> eventList, Map<Id,Event> eventOldMap) {
        Set<Id> whatIdSet = new Set<Id>();
        Set<Id> customerNameSet = new Set<Id>();
        for(Event eventRecord : eventList){
            if((eventRecord.Target_Customer__c == null 
                    && eventRecord.WhatId != null 
                    && eventRecord.Customer_Name__c != null) 
                || (eventRecord.WhatId != eventOldMap?.get(eventRecord.Id)?.WhatId) 
                || (eventRecord.Customer_Name__c != eventOldMap?.get(eventRecord.Id)?.Customer_Name__c)){
                whatIdSet.add(eventRecord.WhatId); 
                customerNameSet.add(eventRecord.Customer_Name__c);
            }
        }

        if(!whatIdSet.isEmpty() && !customerNameSet.isEmpty()){
            Map<String, Target_Customer__c> targetCustomerMap = new Map<String, Target_Customer__c>();
    
            for(Target_Customer__c targetCustomer : [SELECT Id, Partner__c, Customer__c 
                                                        FROM Target_Customer__c 
                                                        WHERE Partner__c IN :whatIdSet 
                                                            OR Customer__c IN :customerNameSet]){
                String tempString = String.valueOf(targetCustomer.Partner__c) + String.valueOf(targetCustomer.Customer__c);
                targetCustomerMap.put(tempString, targetCustomer);
            }
    
            for(Event eventRecord : eventList){
                String tempString = String.valueOf(eventRecord.WhatId) + String.valueOf(eventRecord.Customer_Name__c);
                if(targetCustomerMap.containsKey(tempString)){
                    eventRecord.Target_Customer__c = targetCustomerMap.get(tempString).Id;
                }
            }                                                
        }
        TriggerUtility.updateTargetCustomerNumberExecuted();           
    }
    //CR# 2914 - Added by Ritesh Kumar - End

    //CR# 4443 START
    //Process Name : Auto update Lead & contact based upon event type START
    public static void updateLeadAndContact(List<Event> eventList) {
        Map<Id, List<Event>> leadIdToListOfEventsMap = new Map<Id, List<Event>>();
        Map<Id, List<Event>> contactIdToListOfEventsMap = new Map<Id, List<Event>>();

        final String CONTACT_PREFIX = Schema.SObjectType.Contact.getKeyPrefix();
        final String LEAD_PREFIX = Schema.SObjectType.Lead.getKeyPrefix();

        for (Event currentEvent : eventList) {
            Boolean addLeadOrContactToMap = false;
            //Criteria Name : action type is NBM
            if (currentEvent.WhoId != null 
                && 'NBM (New Business Meeting)'.equalsIgnoreCase(currentEvent.Type)) {
                addLeadOrContactToMap = true;
            }

            //Combined the following Criteria
            //  Criteria Name : BM Scheduled : Lead
            //  Criteria Name : BM Scheduled : Contact
            else if (currentEvent.whoId != null 
                && !completedStr.equalsIgnoreCase(currentEvent.peopleai__MeetingStatus__c) 
                && pgNewBusinessMeetingStr.equalsIgnoreCase(currentEvent.Type)) {
                addLeadOrContactToMap = true;
            }

            //Combined the following Criteria
            //  Criteria Name : BM Completed : Lead
            //  Criteria Name : BM Completed : Contact
            else if (currentEvent.whoId != null 
                && completedStr.equalsIgnoreCase(currentEvent.peopleai__MeetingStatus__c) 
                && pgNewBusinessMeetingStr.equalsIgnoreCase(currentEvent.Type)) {
                addLeadOrContactToMap = true;
            }

            //Combined the following Criteria
            //  Criteria Name : Discovery Meeting Scheduled : Lead  
            //  Criteria Name : Discovery Meeting Scheduled : Contact
            else if (currentEvent.whoId != null 
                && !completedStr.equalsIgnoreCase(currentEvent.peopleai__MeetingStatus__c) 
                && pgDiscoveryCallStr.equalsIgnoreCase(currentEvent.Type)) {
                addLeadOrContactToMap = true;
            }

            //Combined the following Criteria
            //  Criteria Name : Discovery Meeting Completed : Lead
            //  Criteria Name : Discovery Meeting Completed : Contact
            else if (currentEvent.whoId != null 
                && completedStr.equalsIgnoreCase(currentEvent.peopleai__MeetingStatus__c) 
                && pgDiscoveryCallStr.equalsIgnoreCase(currentEvent.Type)) {
                addLeadOrContactToMap = true;
            }

            if (addLeadOrContactToMap) {
                if (String.valueOf(currentEvent.WhoId).startsWith(CONTACT_PREFIX)) {
                    if (contactIdToListOfEventsMap.containsKey(currentEvent.whoId)) {
                        contactIdToListOfEventsMap.get(currentEvent.whoId);
                    } else {
                        contactIdToListOfEventsMap.put(currentEvent.whoId, new List<Event> {currentEvent});
                    }
                } else if (String.valueOf(currentEvent.WhoId).startsWith(LEAD_PREFIX)) {
                    if (leadIdToListOfEventsMap.containsKey(currentEvent.whoId)) {
                        leadIdToListOfEventsMap.get(currentEvent.whoId).add(currentEvent);
                    } else {
                        leadIdToListOfEventsMap.put(currentEvent.whoId, new List<Event> {currentEvent});
                    }
                }
            }
        }

        processAssociatedLeads(leadIdToListOfEventsMap);
        processAssociatedContacts(contactIdToListOfEventsMap);
    }

    public static void updateLeadAndContactForUpdate(List<Event> eventList, Map<Id, Event> oldEventMap) {
        Map<Id, List<Event>> leadIdToListOfEventsMap = new Map<Id, List<Event>>();
        Map<Id, List<Event>> contactIdToListOfEventsMap = new Map<Id, List<Event>>();

        final String CONTACT_PREFIX = Schema.SObjectType.Contact.getKeyPrefix();
        final String LEAD_PREFIX = Schema.SObjectType.Lead.getKeyPrefix();

        for (Event currentEvent : eventList) {

            Boolean addLeadOrContactToMap = false;
            Event oldEvent = oldEventMap.get(currentEvent.Id);

            //Combined the following Criteria
            //  Criteria Name : BM Scheduled : Lead
            //  Criteria Name : BM Scheduled : Contact
            if ((currentEvent.whoId != oldEvent.whoId 
                    || currentEvent.peopleai__MeetingStatus__c != oldEvent.peopleai__MeetingStatus__c 
                    || currentEvent.Type != oldEvent.Type) 
                && currentEvent.whoId != null 
                && !completedStr.equalsIgnoreCase(currentEvent.peopleai__MeetingStatus__c) 
                && pgNewBusinessMeetingStr.equalsIgnoreCase(currentEvent.Type)) {
                addLeadOrContactToMap = true;
            }

            //Combined the following Criteria
            //  Criteria Name : BM Completed : Lead
            //  Criteria Name : BM Completed : Contact
            else if ((currentEvent.whoId != oldEvent.whoId 
                    || currentEvent.peopleai__MeetingStatus__c != oldEvent.peopleai__MeetingStatus__c 
                    || currentEvent.Type != oldEvent.Type) 
                && currentEvent.whoId != null 
                && completedStr.equalsIgnoreCase(currentEvent.peopleai__MeetingStatus__c) && 
                pgNewBusinessMeetingStr.equalsIgnoreCase(currentEvent.Type)) {
                addLeadOrContactToMap = true;
            }

            //Combined the following Criteria
            //  Criteria Name : Discovery Meeting Scheduled : Lead  
            //  Criteria Name : Discovery Meeting Scheduled : Contact
            else if ((currentEvent.whoId != oldEvent.whoId 
                    || currentEvent.peopleai__MeetingStatus__c != oldEvent.peopleai__MeetingStatus__c 
                    || currentEvent.Type != oldEvent.Type) 
                && currentEvent.whoId != null 
                && !completedStr.equalsIgnoreCase(currentEvent.peopleai__MeetingStatus__c) 
                && pgDiscoveryCallStr.equalsIgnoreCase(currentEvent.Type)) {
                addLeadOrContactToMap = true;
            }

            //Combined the following Criteria
            //  Criteria Name : Discovery Meeting Completed : Lead
            //  Criteria Name : Discovery Meeting Completed : Contact
            else if ((currentEvent.whoId != oldEvent.whoId 
                    || currentEvent.peopleai__MeetingStatus__c != oldEvent.peopleai__MeetingStatus__c 
                    || currentEvent.Type != oldEvent.Type) 
                && currentEvent.whoId != null 
                && completedStr.equalsIgnoreCase(currentEvent.peopleai__MeetingStatus__c) 
                && pgDiscoveryCallStr.equalsIgnoreCase(currentEvent.Type)) {
                addLeadOrContactToMap = true;
            }

            if (addLeadOrContactToMap) {
                if (String.valueOf(currentEvent.WhoId).startsWith(CONTACT_PREFIX)) {
                    if (contactIdToListOfEventsMap.containsKey(currentEvent.whoId)) {
                        contactIdToListOfEventsMap.get(currentEvent.whoId);
                    } else {
                        contactIdToListOfEventsMap.put(currentEvent.whoId, new List<Event> {currentEvent});
                    }
                } else if (String.valueOf(currentEvent.WhoId).startsWith(LEAD_PREFIX)) {
                    if (leadIdToListOfEventsMap.containsKey(currentEvent.whoId)) {
                        leadIdToListOfEventsMap.get(currentEvent.whoId).add(currentEvent);
                    } else {
                        leadIdToListOfEventsMap.put(currentEvent.whoId, new List<Event> {currentEvent});
                    }
                }
            }
        }

        processAssociatedLeads(leadIdToListOfEventsMap);
        processAssociatedContacts(contactIdToListOfEventsMap);
    }

    @TestVisible
    private static void processAssociatedLeads(Map<Id, List<Event>> leadIdToListOfEventsMap) {
        if (!leadIdToListOfEventsMap.isEmpty()) {
            List<Lead> leadList = [SELECT Id, Status, Task_and_Event_Activity__c, Funnel_Stage_Date__c, Funnel_Stage__c 
                                    FROM Lead 
                                    WHERE Id IN :leadIdToListOfEventsMap.keySet()];
            List<Lead> leadsToUpdateList = new List<Lead>();
            for (Lead currentLead : leadList) {
                Boolean leadUpdated = false;
                for (Event associatedEvent : leadIdToListOfEventsMap.get(currentLead.Id)) {
                    if ('NBM (New Business Meeting)'.equalsIgnoreCase(associatedEvent.Type)) {
                        currentLead.Task_and_Event_Activity__c = 'NBM';
                        leadUpdated = true;
                    } else if (!'Actively Engaged'.equalsIgnoreCase(currentLead.Status)) {
                        if (!completedStr.equalsIgnoreCase(associatedEvent.peopleai__MeetingStatus__c) && 
                            pgNewBusinessMeetingStr.equalsIgnoreCase(associatedEvent.Type)) {
                            currentLead.Funnel_Stage_Date__c = Date.today();
                            currentLead.Funnel_Stage__c = 'New Business Meeting Scheduled';
                            currentLead.Status = meetingScheduledStr;
                            leadUpdated = true;
                        } else if (completedStr.equalsIgnoreCase(associatedEvent.peopleai__MeetingStatus__c) && 
                            pgNewBusinessMeetingStr.equalsIgnoreCase(associatedEvent.Type)) {
                            currentLead.Funnel_Stage_Date__c = Date.today();
                            currentLead.Funnel_Stage__c = 'New Business Meeting Completed';
                            currentLead.Status = meetingScheduledStr;
                            leadUpdated = true;
                        } else if (!completedStr.equalsIgnoreCase(associatedEvent.peopleai__MeetingStatus__c) && 
                            pgDiscoveryCallStr.equalsIgnoreCase(associatedEvent.Type)) {
                            currentLead.Funnel_Stage_Date__c = Date.today();
                            currentLead.Funnel_Stage__c = 'Discovery Meeting Scheduled';
                            currentLead.Status = meetingScheduledStr;
                            leadUpdated = true;
                        } else if (completedStr.equalsIgnoreCase(associatedEvent.peopleai__MeetingStatus__c) && 
                            pgDiscoveryCallStr.equalsIgnoreCase(associatedEvent.Type)) {
                            currentLead.Funnel_Stage_Date__c = Date.today();
                            currentLead.Funnel_Stage__c = 'Discovery Meeting Completed';
                            currentLead.Status = meetingScheduledStr;
                            leadUpdated = true;
                        }
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

    @TestVisible
    private static void processAssociatedContacts(Map<Id, List<Event>> contactIdToListOfEventsMap) {
        if (!contactIdToListOfEventsMap.isEmpty()) {
            List<Contact> contactList = [SELECT Id, Task_and_Event_Activity__c, Contact_Lead_Status__c, Funnel_Stage_Date__c, Funnel_Stage__c 
                                            FROM Contact 
                                            WHERE Id IN :contactIdToListOfEventsMap.keySet()];
            List<Contact> contactsToUpdateList = new List<Contact>();
            for (Contact currentContact : contactList) {
                Boolean contactUpdated = false;
                for (Event associatedEvent : contactIdToListOfEventsMap.get(currentContact.Id)) {
                    if ('NBM (New Business Meeting)'.equalsIgnoreCase(associatedEvent.Type)) {
                        currentContact.Task_and_Event_Activity__c = 'NBM';
                        contactUpdated = true;
                    } else if (!'Actively Engaged'.equalsIgnoreCase(currentContact.Contact_Lead_Status__c) 
                        && !'Actively Engaged (System Use)'.equalsIgnoreCase(currentContact.Contact_Lead_Status__c) 
                        && !'Processing (System Use)'.equalsIgnoreCase(currentContact.Contact_Lead_Status__c)) {
                        if (!completedStr.equalsIgnoreCase(associatedEvent.peopleai__MeetingStatus__c) 
                            && pgNewBusinessMeetingStr.equalsIgnoreCase(associatedEvent.Type)) {
                            currentContact.Contact_Lead_Status__c = meetingScheduledStr;
                            currentContact.Funnel_Stage_Date__c = Date.today();
                            currentContact.Funnel_Stage__c = 'New Business Meeting Scheduled';
                            contactUpdated = true;
                        } else if (completedStr.equalsIgnoreCase(associatedEvent.peopleai__MeetingStatus__c) 
                            && pgNewBusinessMeetingStr.equalsIgnoreCase(associatedEvent.Type)) {
                            currentContact.Contact_Lead_Status__c = meetingScheduledStr;
                            currentContact.Funnel_Stage_Date__c = Date.today();
                            currentContact.Funnel_Stage__c = 'New Business Meeting Completed';
                            contactUpdated = true;
                        } else if (!completedStr.equalsIgnoreCase(associatedEvent.peopleai__MeetingStatus__c) 
                            && pgDiscoveryCallStr.equalsIgnoreCase(associatedEvent.Type)) {
                            currentContact.Contact_Lead_Status__c = meetingScheduledStr;
                            currentContact.Funnel_Stage_Date__c = Date.today();
                            currentContact.Funnel_Stage__c = 'Discovery Meeting Scheduled';
                            contactUpdated = true;
                        } else if (completedStr.equalsIgnoreCase(associatedEvent.peopleai__MeetingStatus__c) 
                            && pgDiscoveryCallStr.equalsIgnoreCase(associatedEvent.Type)) {
                            currentContact.Contact_Lead_Status__c = meetingScheduledStr;
                            currentContact.Funnel_Stage_Date__c = Date.today();
                            currentContact.Funnel_Stage__c = 'Discovery Meeting Completed';
                            contactUpdated = true;
                        }
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
    //Process Name : Auto update Lead & contact based upon event type END
    //CR# 4443 END

    //Added By Anup - Salesforce Scheduler Project - Start
    public static void createEventRelationRecords(List<Event> newList){
        final String METHOD_NAME = 'createEventRelationRecords';
        try{
            Map<Id, Id> mapOfMeetingAndEventId = new Map<Id, Id>();
            for(Event evn : newList){
                if(evn.ServiceAppointmentId !=null || Test.isRunningTest()){
                    mapOfMeetingAndEventId.put(evn.ServiceAppointmentId, evn.Id);
                }
            }
            if(!mapOfMeetingAndEventId.isEmpty()){
                Map<String, EventRelation> mapOfEmailAndEventRelation = new Map<String, EventRelation>();
                Map<Id, Set<String>> mapOfEventAndExternalEmails = new Map<Id, Set<String>>();
                List<String> listOfContactEmail = new List<String>();
                List<String> listOfUserEmail = new List<String>();
                Set<String> setOfDomain = new Set<String>();
                for(ServiceAppointment sa : [SELECT Id, Additional_Participants__c, OwnerId, Owner.Email, ContactId, Contact.Email 
                                                FROM ServiceAppointment 
                                                WHERE Id IN :mapOfMeetingAndEventId.keySet()]){
                    if(sa.Additional_Participants__c!=null){
                        String emailString = sa.Additional_Participants__c.removeStart('[');
                        emailString = emailString.removeEnd(']');
                        if(!String.isBlank(emailString)){
                            for(String email : emailString.split(',')){
                                if(email.containsIgnoreCase(GCSCommonConstants.ZSCALER_DOMAIN)){
                                    listOfUserEmail.add(email);
                                }
                                else{
                                    listOfContactEmail.add(email);
                                    String eventId = mapOfMeetingAndEventId.get(sa.Id);
                                    if(!mapOfEventAndExternalEmails.containsKey(eventId)){
                                        mapOfEventAndExternalEmails.put(eventId, new Set<String>());
                                    }
                                    mapOfEventAndExternalEmails.get(eventId).add(email);
                                    List<String> splittedEmail = email.split(GCSCommonConstants.AT_THE_RATE_STRING);
                                    if(splittedEmail.size() >= GCSCommonConstants.INTEGER_2){
                                        setOfDomain.add(splittedEmail[GCSCommonConstants.INTEGER_1]);
                                    }
                                }
                                mapOfEmailAndEventRelation.put(email, new EventRelation(EventId = mapOfMeetingAndEventId.get(sa.Id), isParent = false, isInvitee = true));
                            }
                        }
                        /*if(sa.ContactId != null && Contact.Email != null){
                            mapOfEmailAndEventRelation.put(sa.Contact.Email, new EventRelation(EventId = mapOfMeetingAndEventId.get(sa.Id), RelationId = sa.ContactId, isParent = true, isInvitee = true));
                        }*/
                    }
                }
                if(!listOfUserEmail.isEmpty()){
                    for(User usr : [SELECT Id, Email FROM User WHERE Email IN :listOfUserEmail]){
                        if(mapOfEmailAndEventRelation.containsKey(usr.Email)){
                            mapOfEmailAndEventRelation.get(usr.Email).RelationId = usr.Id;
                        }
                    }
                }
                if(!listOfContactEmail.isEmpty()){
                    Map<String, ID> setOfDomainAndAccount = new Map<String, ID>();
                    Map<String, Id> mapOfEmailAndContactId = new Map<String, Id>();
                    for(Contact con : [SELECT Id, Email FROM Contact WHERE Email IN :listOfContactEmail]){
                        if(mapOfEmailAndEventRelation.containsKey(con.Email)){
                            mapOfEmailAndEventRelation.get(con.Email).RelationId = con.Id;
                        }
                        mapOfEmailAndContactId.put(con.Email, con.Id);
                    }

                    if(!setOfDomain.isEmpty()){
                        String queryFields = 'Id, Domain__c, Additional_Organization_Domains__c';
                        String whereClause = 'Domain__c IN ' + GCSCommonUtility.getFormattedString(new List<String>(), setOfDomain) + ' AND Domain__c != null';
                        String orderByClause = GCSCommonConstants.EMPTY_STRING;
                        Integer limitClause = null;
                        for(Account acc : AccountSelector.getAccounts(queryFields, whereClause, orderByClause, limitClause)){
                            setOfDomainAndAccount.put(acc.Domain__c, acc.Id);
                            if(String.isNotBlank(acc.Additional_Organization_Domains__c)){
                                for(String adddomain : acc.Additional_Organization_Domains__c.split(GCSCommonConstants.COMMA_STRING)){
                                    String accdomain = adddomain.trim().remove('https://www.').remove('http://www.').remove('https://').remove('http://');
                                    if(String.isNotBlank(accdomain)){
                                        setOfDomainAndAccount.put(accdomain, acc.Id);
                                    }
                                }
                            }
                        }
                    }

                    if(!mapOfEventAndExternalEmails.isEmpty()){
                        Map<String, Contact> conEmailtoContact = new Map<String, Contact>();
                        for(Id eventId : mapOfEventAndExternalEmails.keySet()){
                            for(String conEmail : mapOfEventAndExternalEmails.get(eventId)){
                                if(!mapOfEmailAndContactId.containsKey(conEmail)){
                                    List<String> splittedEmail1 = conEmail.split(GCSCommonConstants.AT_THE_RATE_STRING);
                                    String accountIdToPatch = label.Account_of_CC_Contact;
                                    if(!splittedEmail1.isEmpty() 
                                        && splittedEmail1.size() >= GCSCommonConstants.INTEGER_2 
                                        && !setOfDomainAndAccount.isEmpty() 
                                        && setOfDomainAndAccount.containsKey(splittedEmail1[GCSCommonConstants.INTEGER_1]) 
                                        && setOfDomainAndAccount.get(splittedEmail1[GCSCommonConstants.INTEGER_1]) != null){
                                        accountIdToPatch = setOfDomainAndAccount.get(splittedEmail1[GCSCommonConstants.INTEGER_1]);
                                    }
                                    conEmailtoContact.put(conEmail, new contact(email = conEmail, lastname = conEmail, accountid = accountIdToPatch, Contact_Type__c = 'Support'));
                                }
                            }
                        }

                        if(!conEmailtoContact.isEmpty()){
                            TriggerHandler.bypass('ContactTriggerHandler');
                            TriggerUtility.realignPatch();
                            List<Database.SaveResult> srList = Database.insert(conEmailtoContact.values(), false);
                            GCSCommonUtility.logDBInsertOrUpdateError(srList, APEX_CLASS_NAME, METHOD_NAME, GCSCommonConstants.EMPTY_STRING);
        
                            if(!mapOfEmailAndEventRelation.isEmpty()){
                                for(String conEmail : mapOfEmailAndEventRelation.keyset()){
                                    if(String.isNotBlank(conEmail)
                                        && conEmailtoContact.containsKey(conEmail)){
                                        mapOfEmailAndEventRelation.get(conEmail).RelationId = conEmailtoContact.get(conEmail).Id;
                                    }
                                }
                            }
                        }
                    }
                }
                if(!mapOfEmailAndEventRelation.isEmpty()){
                    List<Database.SaveResult> srList1 = Database.insert(mapOfEmailAndEventRelation.values(), false);
                    GCSCommonUtility.logDBInsertOrUpdateError(srList1, APEX_CLASS_NAME, METHOD_NAME, GCSCommonConstants.EMPTY_STRING);
                }
            }
        }
        catch(Exception e) {
            GCSCommonUtility.insertZscalerErrorLog(APEX_CLASS_NAME, METHOD_NAME, 
                GCSCommonConstants.EMPTY_STRING, e.getStackTraceString(), String.valueOf(e), e.getTypeName());
        }
        
    }
    //Added By Anup - Salesforce Scheduler Project - End
}