public class CaseIntegrationHandler {
    
    public static ID testContactID;
    public static ID testAccountID;
    
    public void MainEntry(System.TriggerOperation triggerEvent, Boolean IsExecuting,
                          List<SObject> newlist, Map<ID, SObject> newMap,
                          List<SObject> oldList, Map<ID,SObject> oldMap)
    {
        System.debug('----Inside CaseIntegrationHandler MainEntry---');
        List<Case_Integration__c> lstNew = (List<Case_Integration__c>)newlist;
        List<Case_Integration__c> lstOld = (List<Case_Integration__c>)oldList;
        Map<ID, Case_Integration__c> mapNew = (Map<ID,Case_Integration__c>)newMap;
        Map<ID, Case_Integration__c> mapOld = (Map<ID,Case_Integration__c>)oldMap;
        
        // Add entries to the dispatcher static variable if they need to be updated or do direct DML
        
        System.debug('CaseIntegrationHandler MainEntry. triggerEvent: ' + triggerEvent);
        
        switch on triggerEvent {    
            
            when BEFORE_INSERT {
                System.debug('Case_Integration__c ---- > BEFORE_INSERT');
                callComplaintLogic(lstNew);
            }
            
            when BEFORE_UPDATE {
                System.debug('Case_Integration__c ---- > BEFORE_UPDATE');
                callComplaintLogic(lstNew);
            }
            
            when AFTER_INSERT {
                System.debug('Case_Integration__c ---- > AFTER_INSERT');
                upsertCaseRecords(mapNew, null);
                
            }
            when AFTER_UPDATE {
                System.debug('Case_Integration__c ---- > AFTER_UPDATE');   
                upsertCaseRecords(mapNew, mapOld);
                
            }            
            when else {
                System.debug('Not expecting Trigger Event: ' + triggerEvent);
            }
        }
    }
    
    
    public void callComplaintLogic(List<Case_Integration__c> newCIList){
        System.debug('---callComplaintLogic---called');
        
        List<String> originatedIncidents = new List<String>();
        List<Case_Integration__c> complaintCIList = new  List<Case_Integration__c> ();
        for(Case_Integration__c ci : newCIList){
            if(ci.Incident_Type__c != null && ci.Incident_Type__c == 'Complaint' && ci.Originated_From_Incident__c != null
               && ci.External_ID__c != null){
                complaintCIList.add(ci);
                originatedIncidents.add(ci.Originated_From_Incident__c);
            }
        }
        
        System.debug('--originatedIncidents--'+originatedIncidents);
        
        MAP<String, Case_Integration__c> parentCIMAP = new  MAP<String, Case_Integration__c>();
        if(originatedIncidents.size()>0){
            for(Case_Integration__c prCI : [Select ID,External_ID__c,Case__c from Case_Integration__c 
                                            where External_ID__c in : originatedIncidents and 
                                            Originated_From_Incident__c = null and //Not a Compalint
                                            Parent_Incident__c = null and  //Not a Child Incident
                                            Ticket_Status__c !=  'Closed'] 
               )
            {
                parentCIMAP.put(prCI.External_ID__c, prCI);
            }
        }
        
        System.debug('--parentCIMAP--'+parentCIMAP);
        for(Case_Integration__c comCI : complaintCIList){
            if(parentCIMAP.containskey(comCI.Originated_From_Incident__c) &&  comCI.External_ID__c != null){
                comCI.case__c = parentCIMAP.get(comCI.Originated_From_Incident__c).Case__c;
                //comCI.Parent_Incident__c = parentCIMAP.get(comCI.Originated_From_Incident__c).Id;
                comCI.Case_Integration__c = parentCIMAP.get(comCI.Originated_From_Incident__c).Id;
            }
        }
        
    }
    
    
    public void upsertCaseRecords(Map<Id,Case_Integration__c> newCIMap,Map<Id,Case_Integration__c> oldCIMap){
        Map<Id,Case> caseMAP = new Map<Id,Case>();
        Set<Id> caseIDSet = new Set<Id>();
        
        List<Id> csIntChild = new List<Id>();
        
        List<String> masterTicketSet = new List<String>();
        
        List<Case_Integration__c> complaintList = new List<Case_Integration__c>();
        List<Case_Integration__c> feedItemRecs = new List<Case_Integration__c>();
        
        List<Case_Integration__c> caseIntList = new List<Case_Integration__c>();
        List<Case_Integration__c> webFormCasesList = new List<Case_Integration__c>();
        List<String> listOfReceiverEmail = new List<String>();
        List<String> orgIdList = new List<String>();
        Map<Id, Contact> mapOfCaseIntAndContact = new Map<Id, Contact>();
        for(Case_Integration__c ciRec : newCIMap.values()){
            //IF Origin == Siemens
            if(ciRec.Case_Origin__c == 'Siemens'){
                if(ciRec.External_ID__c != null){
                    caseIntList.add(ciRec);
                }
                if(ciRec.Case__c != null){
                    caseIDSet.add(ciRec.Case__c);
                }
                if(ciRec.Parent_Incident__c != null){
                    masterTicketSet.add(ciRec.Parent_Incident__c);
                }
            }
            else{
                if(oldCIMap==null || (ciRec.Case_Creation_Status__c != oldCIMap.get(ciRec.Id).Case_Creation_Status__c && ciRec.Case_Creation_Status__c=='Initiated')){
                    webFormCasesList.add(ciRec);
                    if(ciRec.Receiver_Email__c!=null){
                        listOfReceiverEmail.add(ciRec.Receiver_Email__c);
                    }
                    if(ciRec.Assignment_Group__c!=null){
                        orgIdList.add(ciRec.Assignment_Group__c);
                    }
                }
            }
        } 
        
        System.debug('---masterTicketSet---'+masterTicketSet);
        
        MAP<String,Case> incidentCaseMAP = new MAP<String,Case>();
        for(Case cs : [Select id,caseNumber,status,External_Reference__c,Defcon_Level__c,OwnerID,Escalation_Stage__c  from Case where External_Reference__c != null and Id in :caseIDSet]){
            incidentCaseMAP.put(cs.External_Reference__c,cs);
        }
        
        System.debug('---incidentCaseMAP---'+incidentCaseMAP);
        
        MAP<String,Case> masterIncidentCaseMAP = new MAP<String,Case>();
        if(masterTicketSet.size()>0){
            id conID = Test.isRunningTest() ? testContactID :  System.Label.SiemensDummyContcatID;
            for(Case cs : [Select id,caseNumber,status,External_Reference__c from Case where Origin = 'API' and
                           ContactId = :conID and 
                           External_Reference__c in :masterTicketSet and Status != 'Closed'  order by createddate])
            {
                masterIncidentCaseMAP.put(cs.External_Reference__c,cs);
            }
        }
        
        System.debug('---masterIncidentCaseMAP---'+masterIncidentCaseMAP);
        
        // have only one method - merge to below
        if(caseIntList.size()>0){
            
            List<Generic_Field_Mapping__mdt> metaDataList = GenericFieldMappingController.getMappingFromMetaData('Case_Integartion__c','Case');
            System.debug('---metaDataList---'+metaDataList);
            if(metaDataList != null && metaDataList.size()>0){
                
                for(Case_Integration__c csInt  : caseIntList){
                    
                    System.debug('---csInt External_ID__c---'+csInt.External_ID__c);
                    System.debug('---csInt Parent_Incident__c---'+csInt.Parent_Incident__c);
                    
                    Case_Integration__c csIntOld = oldCIMap != null && oldCIMap.containskey(csInt.Id) ? oldCIMap.get(csInt.Id) : null;
                    
                    if(csInt.Incident_Type__c == 'Incident'){
                        case csOld = incidentCaseMAP.containskey(csInt.External_ID__c) ? incidentCaseMAP.get(csInt.External_ID__c) : null;
                        case cs = new Case();
                        cs.External_Reference__c = csint.External_ID__c;
                        if(oldCIMap == null){
                            cs = prepareCaseRecordFromIntegaration(csInt, cs, metaDataList, 'Siemens');
                            System.debug('Case Record--'+cs.id);
                        }else{
                            cs.id = csInt.Case__c;
                            cs = prepareCaseRecordFromIntegaration(csInt, cs, metaDataList, 'Siemens');
                        }
                        cs.ParentId = csInt.Parent_Incident__c != null &&  masterIncidentCaseMAP.containskey(csInt.Parent_Incident__c) ? masterIncidentCaseMAP.get(csInt.Parent_Incident__c).id : null;
                        SiemensSpecificFieldPopulation(csInt,csIntOld, cs, csOld);
                        caseMAP.put(csInt.id, cs);
                        
                        
                        //Create Feed Item
                        feedItemRecs.add(csInt);
                        
                    }else if(csInt.Incident_Type__c == 'Complaint'){
                        if(csInt.Ticket_Status__c != 'Resolved' && csInt.Ticket_Status__c != 'Closed'){
                            complaintList.add(csInt);
                        }
                        //Create Feed Item
                        feedItemRecs.add(csInt);
                    }
                    
                    //If Ticket gets Closed, Clsoe all related child Case Integration.
                    if(csIntOld != null && (csIntOld.Ticket_Status__c != csInt.Ticket_Status__c || (csInt.Updated_Fields__c!=null && csInt.Updated_Fields__c.contains('Ticket_Status__c'))) && csInt.Ticket_Status__c == 'Closed'){
                        csIntChild.add(csInt.id);
                    }
                }        
            }
        }
        
        if(!webFormCasesList.isEmpty()){
            List<Generic_Field_Mapping__mdt> metaDataListAll = GenericFieldMappingController.getMappingFromMetaData('Case_Integartion__c','Case');
            List<Generic_Field_Mapping__mdt> metaDataList = new List<Generic_Field_Mapping__mdt>();
            Id caseSupportRT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Support').getRecordTypeId();
            Map<String, Contact> mapOfEmailAndContact = new Map<String, Contact>();
            Map<String, Zscaler_Cloud_ID__c> mapOfOrgIdAndRecord = new Map<String, Zscaler_Cloud_ID__c>();
            for(Contact con : [select id, Email, AccountId from Contact where Email IN:listOfReceiverEmail]){
                mapOfEmailAndContact.put(con.Email, con);
            }
            if(!orgIdList.isEmpty()){
                for(Zscaler_Cloud_ID__c cloudId : [SELECT Id, Name,Org_Name__c,Account__c FROM Zscaler_Cloud_ID__c WHERE Name = : orgIdList]){
                    mapOfOrgIdAndRecord.put(cloudId.Name.toLowerCase(), cloudId);
                }
            }
            for(Case_Integration__c csInt : webFormCasesList){
                if(csInt.Case__c == null){
                    Case cs = new Case();
                    cs = prepareCaseRecordFromIntegaration(csInt, cs, metaDataListAll, 'Web Forms');
                    cs.Status = 'New';
                    cs.RecordTypeId = caseSupportRT;
                    cs.Data_Access_Authorization_Provided__c = true;
                    if(mapOfOrgIdAndRecord.containsKey(csInt.Assignment_Group__c.toLowerCase()) && mapOfOrgIdAndRecord.get(csInt.Assignment_Group__c)!=null){
                        cs.AccountId = mapOfOrgIdAndRecord.get(csInt.Assignment_Group__c).Account__c;
                    }
                    if(mapOfEmailAndContact.containsKey(csInt.Receiver_Email__c) && mapOfEmailAndContact.get(csInt.Receiver_Email__c)!=null){
                        cs.ContactId = mapOfEmailAndContact.get(csInt.Receiver_Email__c).Id;
                        cs.AccountId = mapOfEmailAndContact.get(csInt.Receiver_Email__c).AccountId;
                    }
                    if(cs.ContactId == null && cs.AccountId!=null && csInt.Receiver_Email__c !=null){
                        Contact con  = new Contact();
                        con.Email = csInt.Receiver_Email__c;
                        con.AccountId = cs.AccountId;
                        con.FirstName = csInt.Created_By_First_Name__c;
                        con.LastName = csInt.Created_By_Last_Name__c;
                        mapOfCaseIntAndContact.put(csInt.Id, con);
                    }
                    caseMAP.put(csInt.id, cs);
                }
            }
        }
        System.debug('--caseMAP--'+caseMAP);
        if(caseMAP.size()>0){
            if(mapOfCaseIntAndContact.size() > 0){
                TriggerHandler.clearBypass('ContactTriggerHandler');
                insert mapOfCaseIntAndContact.values();
                for(Id csIntId : mapOfCaseIntAndContact.keySet()){
                    if(mapOfCaseIntAndContact.get(csIntId)!=null && mapOfCaseIntAndContact.get(csIntId).Id!=null){
                        caseMAP.get(csIntId).ContactId = mapOfCaseIntAndContact.get(csIntId).Id;
                    }
                }
            }
            TriggerHandler.bypass('ContactTriggerHandler');
            TriggerUtility.contactOwnerShipExecuted();
            TriggerUtility.contaskFieldUpdateExecuted();
            
            TriggerUtility.executeCaseAfterUpdateCaseIntegartionSetTrue();
            try{
                upsert caseMAP.values();
            }
            catch(Exception e){
                system.debug('Case Upsert failed');
            }
            
            System.debug('--caseMAP--'+caseMAP);
            
            List<Case_Integration__c> ciRecordsWithCaseIDs = new List<Case_Integration__c>();
            for(Id ciId : caseMAP.keySet()){
                if(caseMAP.get(ciId) != null && caseMAP.get(ciId).Id != null && 
                   newCIMap.get(ciId).Case__c !=  caseMAP.get(ciId).Id)
                {
                    ciRecordsWithCaseIDs.add(new Case_Integration__c(Id=ciId, Case__c= caseMAP.get(ciId).Id, Case_Creation_Status__c='Success'));
                }
                else if(caseMAP.get(ciId) != null && caseMAP.get(ciId).Id == null && newCIMap.get(ciId).Case__c==null){
                    //Added By Anup - IBA-5947 - Start
                    Integer retryCounter = 0;
                    if(newCIMap.get(ciId).Retry_Counter__c != null){
                        retryCounter = Integer.valueOf(newCIMap.get(ciId).Retry_Counter__c);
                    }
                    retryCounter += 1;
                    //Added By Anup - IBA-5947 - End
                    ciRecordsWithCaseIDs.add(new Case_Integration__c(Id=ciId, Case_Creation_Status__c='Failure', Retry_Counter__c=retryCounter));
                }
            }
            System.debug('--ciRecordsWithCaseIDs--'+ciRecordsWithCaseIDs);
            
            if(!ciRecordsWithCaseIDs.isEmpty()){
                TriggerUtility.caseIntegartionExecutedSetTrue();
                TriggerUtility.caseCaseIntegartionPatchSetTrue();
                update ciRecordsWithCaseIDs;
                TriggerUtility.caseCaseIntegartionPatchSetFalse();
            }
        }
        
        
        System.debug('--complaintList--'+complaintList);
        //Escalate the case
        //if(oldCIMap == null && complaintList.size()>0){
        if(complaintList.size()>0){
            escalateTheCase(incidentCaseMAP, complaintList);
        }

        //create FeedItem entry on Case
        if(feedItemRecs.size()>0){
            createCaseFeedItemEntry(feedItemRecs,newCIMap,oldCIMap);
        }
        
        
        System.debug('--csIntChild--'+csIntChild);
        if(csIntChild.size()>0){
            System.enqueueJob(new SiemensIncidentCloseChildCase(csIntChild)); 
        }
    }
    
    
    public void callSiemensPatch(Map<Id,Case_Integration__c> newCIMap,Map<Id,Case_Integration__c> oldCIMap){
        System.debug('---callSiemensPatch---called');
        if(oldCIMAP == null){
            //Call Queue
            System.debug('---afterInsert--call-enqueueJob');
            
            Map<Id,Case_Integration__c> newPatchMap =new Map<Id,Case_Integration__c>();            
            for(Case_Integration__c ci : newCIMap.values()){
                if(
                    (
                        //If master incident
                        (ci.Parent_Incident__c == null || String.isBlank(ci.Parent_Incident__c))
                        && 
                        (ci.is_First_Time_Patch__c == false)
                    )
                    && ci.Ticket_Status__c != 'Closed' 
                    && ci.Integration_Status__c == 'Not Started'
                ){
                    newPatchMap.put(ci.id, ci);  
                }
            }  
            if(newPatchMap.size()>0){
                System.enqueueJob(new SiemensIncidentPatchQueue(newPatchMap)); 
            }            
        }else{
            System.debug('---afterUpdate--call-enqueueJob');
            List<String> systemFields = new List<String>{'lastmodifieddate','systemmodstamp','Integration_Status__c','Integration_Error__c'};
            Map<Id,Case_Integration__c> newPatchMap =new Map<Id,Case_Integration__c>();
           
            for(Case_Integration__c ci : newCIMap.values()){
                System.debug('---ci--'+ci);
                System.debug('---ci.Integration_Status__c--'+ci.Integration_Status__c);
                Case_Integration__c ciOld = oldCIMap.get(ci.id);
                if(
                    (           
                        (
                            //If master incident and User is not boomi
                            (ci.Parent_Incident__c == null || String.isBlank(ci.Parent_Incident__c))
                            && 
                            ((userinfo.getUserId() != '0054u0000075JtcAAE' && userinfo.getUserId()!='0050g000005nUT1AAM') || ci.is_First_Time_Patch__c == false)
                        )
                    )
                    && ci.Ticket_Status__c != 'Closed' 
                    && ci.Integration_Status__c == 'Not Started'
                ){
                    for (String str : Schema.SObjectType.Case_Integration__c.fields.getMap().keyset()) {
                        if((ci.get(str) != ciOld.get(str)) || (ci.Updated_Fields__c!=null && ci.Updated_Fields__c.contains(str))){
                            if(!systemFields.contains(str)){
                                newPatchMap.put(ci.id, ci);
                                break;
                            }
                        }
                    }
                }
            }
            System.debug('---newPatchMap--'+newPatchMap);
            if(newPatchMap.size()>0){
                System.enqueueJob(new SiemensIncidentPatchQueue(newPatchMap)); 
            }
        }
    }
    
    
    @testVisible
    private void createCaseFeedItemEntry(List<Case_Integration__c> childRecs,MAP<ID,Case_Integration__c> newMAP, MAP<ID,Case_Integration__c> oldMAP){
        System.debug('--createCaseFeedItemEntry Called--'); 
        System.debug('--childRecs--'+childRecs);        
        System.debug('--newMAP--'+newMAP); 
        System.debug('--oldMAP--'+oldMAP);
  
        childRecs = [Select id,case__c, Updated_Fields__c from Case_Integration__c where id in :childRecs];
        
        List<FeedItem> fiList = new List<FeedItem>();
        for(Case_Integration__c ci : childRecs){
            System.debug('--Case--'+ ci.Case__c);
            if(ci.Case__c != null){
                Case_Integration__c ciNew = newMAP.get(ci.id);
                System.debug('--ciNew--'+ciNew);
                
                //Is Update
                if(oldMAP != null){
                    Case_Integration__c ciold = oldMAP.get(ci.id);
                    
                    //If Case__c gets modified
                    if((ci.case__c != ciold.case__c) || (ci.Updated_Fields__c!=null && ci.Updated_Fields__c.contains('Case__c'))){
                        if(ciNew.Internal_Work_Notes__c != null){
                            fiList.add(createFeedItemRecord(ci.Case__c,ciNew.Internal_Work_Notes__c));
                        }
                        if(ciNew.Customer_Communication__c != null){
                            fiList.add(createFeedItemRecord(ci.Case__c,ciNew.Customer_Communication__c));
                        }
                        if(ciNew.Detailed_Solution_Description__c != null){
                            fiList.add(createFeedItemRecord(ci.Case__c,ciNew.Detailed_Solution_Description__c));
                        }
                        if(ciNew.Data_Points__c != null){
                            fiList.add(createFeedItemRecord(ci.Case__c,ciNew.Data_Points__c));
                        }
                    }else{
                        system.debug('Inside Condition of Create Feed Anup-->'+ciNew.Updated_Fields__c);

                        if(ciNew.Internal_Work_Notes__c != null &&  (ciNew.Internal_Work_Notes__c != ciold.Internal_Work_Notes__c || (ciNew.Updated_Fields__c!=null && ciNew.Updated_Fields__c.contains('Internal_Work_Notes__c')))){
                            fiList.add(createFeedItemRecord(ci.Case__c,ciNew.Internal_Work_Notes__c));
                        }
                        if(ciNew.Customer_Communication__c != null &&  (ciNew.Customer_Communication__c != ciold.Customer_Communication__c || (ciNew.Updated_Fields__c!=null && ciNew.Updated_Fields__c.contains('Customer_Communication__c')))){
                            fiList.add(createFeedItemRecord(ci.Case__c,ciNew.Customer_Communication__c));
                        }
                        if(ciNew.Detailed_Solution_Description__c != null &&  (ciNew.Detailed_Solution_Description__c != ciold.Detailed_Solution_Description__c || (ciNew.Updated_Fields__c!=null && ciNew.Updated_Fields__c.contains('Detailed_Solution_Description__c')))){
                            fiList.add(createFeedItemRecord(ci.Case__c,ciNew.Detailed_Solution_Description__c));
                        }
                        if(ciNew.Data_Points__c != null &&  (ciNew.Data_Points__c != ciold.Data_Points__c || (ciNew.Updated_Fields__c!=null && ciNew.Updated_Fields__c.contains('Data_Points__c')))){
                            fiList.add(createFeedItemRecord(ci.Case__c,ciNew.Data_Points__c));
                        }
                    }
                }
                //Is Insert
                else{
                    if(ciNew.Internal_Work_Notes__c != null){
                        fiList.add(createFeedItemRecord(ci.Case__c,ciNew.Internal_Work_Notes__c));
                    }
                    if(ciNew.Customer_Communication__c != null){
                        fiList.add(createFeedItemRecord(ci.Case__c,ciNew.Customer_Communication__c));
                    }
                    if(ciNew.Detailed_Solution_Description__c != null){
                        fiList.add(createFeedItemRecord(ci.Case__c,ciNew.Detailed_Solution_Description__c));
                    }
                    if(ciNew.Data_Points__c != null){
                        System.debug('Create Feed Item Called--'+ciNew.Data_Points__c);
                        fiList.add(createFeedItemRecord(ci.Case__c,ciNew.Data_Points__c));
                    }
                }
            }
        }
        System.debug('----fiList----'+fiList);
        TriggerUtility.CaseBeforeInsertExecuted();
        TriggerUtility.CaseAfterInsertExecuted();
        TriggerUtility.skipCaseEscalationExecuted();
        TriggerUtility.UpdateTAMemailExecuted();
        TriggerUtility.UpdateSEonCaseExecuted();
        TriggerUtility.CaseAfterUpdateExecuted();
        TriggerUtility.SkipFeedItemTriggerExecuted();
        TriggerUtility.SkipCaseCommentTriggerExecuted();
        Database.insert(fiList,false);
        
    }
    
    
    private FeedItem createFeedItemRecord(Id parentId, String dec){
        FeedItem cc = new FeedItem();
        cc.parentId = parentId;
        //cc.Body = 'Siemens:'+'\n'+dec;
        cc.Body = 'Siemens:'+'\n'+ (dec != null ? dec.left(9000) : null);
        cc.Visibility = 'AllUsers';
        cc.IsRichText = false;
        return cc;
    }
    
    
    @testVisible    
    private void escalateTheCase(MAP<String,Case> incidentCaseMAP, List<Case_Integration__c> complaintList){
        System.debug('--escalateTheCase--called--');
        List<Case> updateDefConAndEscalatioNReason = new List<Case>();
        
        Set<ID> caseOwnerIDSet = new Set<ID>();
        for(Case cs  : incidentCaseMAP.values()){
            if(cs.ownerID != null){
                caseOwnerIDSet.add(cs.OwnerId);
            }
        }
        
        MAP<ID,ID> caseOwnerIDMAP = new MAP<ID,ID>();
        for(User caseOwner :  [Select Id, Name, ManagerId from User where Id in : caseOwnerIDSet and ManagerId != null]){
            caseOwnerIDMAP.put(caseOwner.ID,caseOwner.ManagerId);
        }
        
        
        for(Case_Integration__c csInt  : complaintList){
            
            if(csInt.Case__c != null && incidentCaseMAP.containskey(csInt.Originated_From_Incident__c)){
                
                case csOld = incidentCaseMAP.get(csInt.Originated_From_Incident__c);
                
                System.debug('---csOld---'+csOld);
                
                String defLevel = csOld.Defcon_Level__c;
                String ownerID = csOld.OwnerID;
                String ownerManagerID = caseOwnerIDMAP.containskey(ownerID) ? caseOwnerIDMAP.get(ownerID) : null;
                
                //String resultDef =  (defLevel == null ? '3' : ( defLevel == '3' ?  '3' : defLevel));
                String resultDef =  '3'; //(defLevel == null ? '3' : ( defLevel ));
                System.debug('---defLevel---'+defLevel);
                System.debug('---resultDef---'+resultDef);
                
                String csIntStatus = '';
                
                if(csOld != null && csOld.Escalation_Stage__c == 'Work in progress' && csInt.Ticket_Status__c == 'Open'){
                    csIntStatus = 'Work in progress';
                }else{
                    csIntStatus = csInt.Assignment_Group__c == System.Label.Siemens_Assignment_Group ? 'Closed' : 'Open';   
                }
                
                updateDefConAndEscalatioNReason.add(new Case(Id= csInt.Case__c, Escalation_Stage__c = csIntStatus,
                                                             Escalation_Start_Time__c = System.now(),
                                                             Defcon_Level__c = resultDef, 
                                                             IsEscalated__c  = true,
                                                             IsEscalated= true,
                                                             Escalation_Reason__c =  csInt.Internal_Work_Notes__c,
                                                             Escalated_By__c = UserInfo.getUserId(),
                                                             Escalation_Owner__c = ownerManagerID,
                                                             Escalation_on_behalf_of_Customer__c = true
                                                            )
                                                   );
            }
        }
        System.debug('--updateDefConAndEscalatioNReason--'+updateDefConAndEscalatioNReason);  
        update updateDefConAndEscalatioNReason;
    }
    
    private case prepareCaseRecordFromIntegaration(Case_Integration__c caseInt,  Case csObj, List<Generic_Field_Mapping__mdt> metaDataList, String origin){
        sObject csInt = caseInt; 
        if(csObj == null)
            csObj = new Case();
        
        List<Generic_Field_Mapping__mdt> siemnsMapping = new  List<Generic_Field_Mapping__mdt>();
        for(Generic_Field_Mapping__mdt mdt : metaDataList){
            if(mdt.Origin__c != null && mdt.Origin__c == origin){
                siemnsMapping.add(mdt);
            }
        }
        System.debug('---siemnsMapping---'+siemnsMapping);
        
        csObj = (Case)GenericFieldMappingController.prepareRecordFromGenericFieldMapping(csInt, csObj, siemnsMapping); 
        
        return csObj;
    }
    
    
    private void SiemensSpecificFieldPopulation(Case_Integration__c csInt,Case_Integration__c csInstOld,Case cs, Case csOld){
        cs.ContactId = Test.isRunningTest() ? testContactID :  System.Label.SiemensDummyContcatID;
        cs.AccountId = Test.isRunningTest() ? testAccountID :  System.Label.Siemens_Account_ID;//added by Swathi CR#2236
        
        if(System.label.ZPA_Sub_Categories.containsIgnoreCase(csInt.SubCategory_ID__c)){
            cs.Product_New__c = 'ZPA';
        }else if(System.label.ZIA_Sub_Categories.containsIgnoreCase(csInt.SubCategory_ID__c)){
            cs.Product_New__c = 'ZIA';
        }else{
            cs.Product_New__c = 'ZPA';
        }
       
        
        cs.zscaler_org_id__c = System.Label.SiemensIncidentZscalerOrgID;
        cs.Origin = 'API';
        cs.case_source__c = 'Integration';
        
        System.debug('----csInt---'+csInt);
        System.debug('----csInstOld---'+csInstOld);
        System.debug('----cs---'+cs);
        System.debug('----csOld---'+csOld);
        
        
        
        //IF the assignment group is not for Zscaler then set the Status as Pending Customer
        if(csInt.Ticket_Status__c != 'Closed' && csInt.Ticket_Status__c != 'Resolved' && csInt.Assignment_Group__c != System.label.Zscaler_Assignment_Group 
           && csInt.Assignment_Group__c != System.label.Siemens_Assignment_Group && csInt.Assignment_Group__c != System.label.ZIA_Assignment_Group_Siemens)
        {
            cs.status= 'Pending Customer';
        }
        
        
        //IF Child Tikcet
        if(csInt.Parent_Incident__c != null || String.isNotBlank(csInt.Parent_Incident__c)){
            if(csInt.Ticket_Status__c != 'Closed' && csInt.Ticket_Status__c != 'Resolved'){
                cs.status= 'Pending Customer';
            }
        }
        
        //IF Parent Ticket
        else{
            //Priority : 1
            //IF assignment group is zzzFITS, Don't update the Case ticket Status if It was pending customer Erlier
            if((csInt.Assignment_Group__c == System.label.Siemens_Assignment_Group || csInt.Assignment_Group__c == System.label.ZIA_Assignment_Group_Siemens) &&
               csOld != null && cs != null &&
               csOld.Status == 'Pending Customer' &&
               csInt != null && csInt.Ticket_Status__c == 'Open' &&
               csInstOld != null && csInstOld.Ticket_Status__c == 'Open'
              )
            {
                cs.status= 'Pending Customer';
            }
            
            //Priority : 2
            //customer Note added
            if((csInt.Assignment_Group__c == System.label.Zscaler_Assignment_Group || csInt.Assignment_Group__c == System.label.ZIA_Assignment_Group_Siemens)
               && 
               csOld != null && csOld.Status == 'Pending Customer' &&
               csInstOld != null && 
               (csInstOld.Internal_Work_Notes__c != csInt.Internal_Work_Notes__c ||
                csInstOld.Customer_Communication__c != csInt.Customer_Communication__c || 
                (csInt.Updated_Fields__c!=null && (csInt.Updated_Fields__c.containsIgnoreCase('Internal_Work_Notes__c') || csInt.Updated_Fields__c.containsIgnoreCase('Customer_Communication__c')))
               ) 
              )
            {
                cs.status= 'Customer Note Added';
            }
            
            
            if((csInt.Assignment_Group__c == System.label.Zscaler_Assignment_Group ||  csInt.Assignment_Group__c == System.label.ZIA_Assignment_Group_Siemens)
               && 
               csOld != null &&  csInt.Ticket_Status__c == 'Open')
            {
                switch on csOld.Status {
                    when 'Researching' {
                        cs.status= 'Researching';
                    }
                    when 'Escalated to Engineering' {
                        cs.status= 'Escalated to Engineering';
                    }
                    when 'Customer Callback Scheduled' {
                        cs.status= 'Customer Callback Scheduled';
                    }
                    when 'Awaiting Fix' {
                        cs.status= 'Awaiting Fix';
                    }  
                }
            }
        }
        System.debug('----cs--final---'+cs);
    }
    
    
    
    @AuraEnabled
    public static void callComplaintPatchForSiemens(String recId){
        
        System.debug('--callComplaintPatchForSiemens called--');
        System.debug('--callComplaintPatchForSiemens recId--'+recId);
        
        Case  caseRec = [Select Id,Escalation_Stage__c,Escalation_Resolution_Notes__c, Origin,zscaler_org_id__c,Defcon_Level__c,isEscalated,External_Reference__c, OwnerId from case where id  = :recId];
        MAP<ID,Case_Integration__c> caseIntMAp = new   MAP<ID,Case_Integration__c>();
        
        //check if Case is for Siemnes Integartion Case
        if(caseRec.Origin == 'API' && 
           caseRec.zscaler_org_id__c == System.Label.SiemensIncidentZscalerOrgID &&
           caseRec.External_Reference__c != null &&
           caseRec.Escalation_Resolution_Notes__c != null)
        {
            String timeStamp = System.now().formatGMT('yyyy-MM-dd HH:mm:ss');
            
            MAP<Id, Case_Integration__c> complaintRecords = new MAP<Id, Case_Integration__c>();
            for(Case_Integration__c ci  : [Select ID,Patch_Source__c,Name,External_ID__c from Case_Integration__c 
                                           where Originated_From_Incident__c = :caseRec.External_Reference__c AND Case__c = :recId  ])
            {
                
                ci.Internal_Work_Notes__c = 'Zscaler :'+timeStamp +'-'+caseRec.Escalation_Resolution_Notes__c.stripHtmlTags();
                ci.IS_Work_Notes_Changed__c = true;
                ci.Patch_Source__c = '';
                if(caseRec.Escalation_Stage__c == 'Open' || caseRec.Escalation_Stage__c == 'Work in progress'){   
                   System.debug('--Assingment Group Should not be changed');
                }else if(caseRec.Escalation_Stage__c == 'Closed'){
                   ci.Assignment_Group__c = System.Label.Siemens_Assignment_Group; 
                }
                caseIntMAp.put(ci.id, ci);
            }
        }
        System.debug('--caseIntMAp--'+caseIntMAp);
        if(caseIntMAp.size()>0){
            TriggerUtility.caseIntegartionExecutedSetTrue();
            TriggerUtility.caseCaseIntegartionPatchSetTrue();
            CaseIntegrationHandler.executeFieldUpdateCheckSetTrue();
            update caseIntMAp.values();
            System.enqueueJob(new SiemensIncidentPatchQueue(caseIntMAp)); 
        }
    }
    
    
    
    @testvisible
    public static List<Case_Integration__c> prepareCaseComplaintRecordsSiemens(List<ID> caseIntID, String patchSource, String worknotes)
    {
        List<Case_Integration__c> caseIntComplaintList = new List<Case_Integration__c>();
        for(Id caseInt : caseIntID){
            if(patchSource == 'Resolved' || patchSource == 'Reassign'){
                Case_Integration__c ci = new Case_Integration__c();
                ci.id = caseInt;
                ci.Internal_Work_Notes__c = worknotes;
                ci.IS_Work_Notes_Changed__c = true;
                //ci.Patch_Source__c = 'Worknotes';
                ci.Assignment_Group__c = System.Label.Siemens_Assignment_Group; 
                caseIntComplaintList.add(ci);
            }
        }
        
        return caseIntComplaintList;
    }


    public static void getUpdatedFields(Map<Id, Case_Integration__c> newMap, Map<Id, Case_Integration__c> oldMap){
        List<String> systemFields = new List<String>{'lastmodifieddate','systemmodstamp','Integration_Status__c','Integration_Error__c', 'Case_Creation_Status__c'};
        List<String> changedFields = new list<String> ();
        MAP<string, SObjectField> fieldMap = new MAP<string, SObjectField>();
        fieldMap = schema.getGlobalDescribe().get('Case_Integration__c').getDescribe().fields.getMap();
        for(Id recId : newMap.keySet()){
            changedFields = new List<String>();
            SObject o1 = Trigger.oldMap.get(recId);
            SObject o2 = Trigger.newMap.get(recId);
            for (Schema.sObjectField field : fieldMap.values()) {
                String fieldapiName = field.getDescribe().getName();
                if(!systemFields.contains(fieldapiName)){
                    Object v1 = o1.get(field);
                    Object v2 = o2.get(field);
                    if (didFieldChange(v1, v2)) {
                        changedFields.add(fieldapiName);
                    }
                }
            }
            if(!changedFields.isEmpty()){
                String changedFieldsString = String.join(changedFields, ';');
                newMap.get(recId).Updated_Fields__c = changedFieldsString;
            }
        }
        
    }

    public static Boolean didFieldChange(Object v1, Object v2) {
        if (v1 == null && v2 == null) {
            return false;
        }
        if (v1 != v2) {
            return true;
        }
        return false;
    }

    public static void associateAllCaseIntFilesWithCase(List<Case_Integration__c> newList, Map<Id, Case_Integration__c> oldMap){
        Map<Id, Id> mapOfIntAndCaseId = new Map<Id, Id>();
        List<Id> caseOfCaseIntId = new List<Id>();
        for(Case_Integration__c csInt : newList){
            if(csInt.Case__c !=null && csInt.Case__c != oldMap.get(csInt.Id).Case__c){
                mapOfIntAndCaseId.put(csInt.Id, csInt.Case__c);
            }
        }

        if(mapOfIntAndCaseId.size() > 0){
            List<ContentDocumentLink> cdlToInsert = new List<ContentDocumentLink>();
            for(ContentDocumentLink cdl: [select id, LinkedEntityId, ContentDocumentId, Visibility from ContentDocumentLink where LinkedEntityId IN:mapOfIntAndCaseId.keySet()]){
                ContentDocumentLink newcdl = new ContentDocumentLink();
                newcdl.Visibility = 'AllUsers';
                newcdl.ShareType = 'V';
                newcdl.LinkedEntityId = mapOfIntAndCaseId.get(cdl.LinkedEntityId);
                newcdl.ContentDocumentId = cdl.ContentDocumentId;
                cdlToInsert.add(newcdl);
            }
            if(!cdlToInsert.isEmpty()){
                TriggerUtility.CDLAfterInsertExecuted();
                insert cdlToInsert;
            }
        }
    }

    private static boolean executeFieldUpdateCheck = false;
    public static Boolean isexecuteFieldUpdateCheckExecuted() {
        return executeFieldUpdateCheck;
    }
    public static void executeFieldUpdateCheckSetTrue() {
        executeFieldUpdateCheck = true;
    }
    public static void executeFieldUpdateCheckSetFalse() {
        executeFieldUpdateCheck = false;
    } 

    private static boolean executeFilesAssociationToCase = false;
    public static Boolean isExecuteFilesAssociationToCaseExecuted() {
        return executeFilesAssociationToCase;
    }
    public static void executeFilesAssociationToCaseSetTrue() {
        executeFilesAssociationToCase = true;
    }
    public static void executeFilesAssociationToCaseSetFalse() {
        executeFilesAssociationToCase = false;
    } 
    
}
//no change comment