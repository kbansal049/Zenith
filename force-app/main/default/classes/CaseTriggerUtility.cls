/**
* @description       : 
* @author            : ChangeMeIn@UserSettingsUnder.SFDoc
* @group             : 
* @last modified on  : 12-20-2022
* @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class CaseTriggerUtility{
    public static Id caseSupportRT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Support').getRecordTypeId();
    public static Id exp_projRT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Experience_Project').getRecordTypeId();
    
    public static void beforeInsert(List<Case> newList){
        Map<String, Triggers_Switch__c> tsmap = Triggers_Switch__c.getAll();
        convertIntegrationCasestoSupport(newList);
        assignStatusStartDate(newList);
        if(tsmap.containsKey('Execute_UpdateNOCSubject') && tsmap.get('Execute_UpdateNOCSubject') != null && tsmap.get('Execute_UpdateNOCSubject').Execute__c){
            updateNOCSubject(newList,null);
        }
        
        //Added by Chetan CR#2268 Start
        if(tsmap.containsKey('Execute_CreateContactUnderAccount') && tsmap.get('Execute_CreateContactUnderAccount') != null && tsmap.get('Execute_CreateContactUnderAccount').Execute__c){
            createContactUnderAccount(newList);
        }
        //Added by Chetan CR#2268 End
        
        assignAccountforSupportCase(newList);
        assignCustomerScoreParameters(newList);
        if(tsmap.containsKey('Execute_Case_SkillAssignment') && tsmap.get('Execute_Case_SkillAssignment') != null && tsmap.get('Execute_Case_SkillAssignment').Execute__c && !TriggerUtility.isCaseSkillAssignmentExecuted()){
            //assignCasesbySkill(newList);
            assignCasesbySkill_TamRouting(newList);
        }
        if(tsmap.containsKey('Execute_Case_Entitlement_Assignment') && tsmap.get('Execute_Case_Entitlement_Assignment') != null && tsmap.get('Execute_Case_Entitlement_Assignment').Execute__c && !TriggerUtility.isCaseEntitlementAssigned()){
            assignEntitlementtoCase(newList);
        }
        if(tsmap.containsKey('updateExtentison') && tsmap.get('updateExtentison') != null && tsmap.get('updateExtentison').Execute__c && !TriggerUtility.isUpdateCaseAccountExtension()){       
            updateExtentison(newList,null);
        }
        if(tsmap.containsKey('ExecuteUpdateTAMemail') && tsmap.get('ExecuteUpdateTAMemail') != null && tsmap.get('ExecuteUpdateTAMemail').Execute__c && !TriggerUtility.isUpdateTAMemailExecuted()){
            UpdateTAMemail(newList);
        }
        
        // Added by Gurjinder : CR# 125 :Start
        if(tsmap.containsKey('ExecuteUpdateSEonCase') && tsmap.get('ExecuteUpdateSEonCase') != null && tsmap.get('ExecuteUpdateSEonCase').Execute__c && !TriggerUtility.isUpdateSEonCaseExecuted()){
            UpdateSEonCase(newList);
        }
        // Added by Gurjinder : CR# 125 :End
        
        // Added by Chetan : CR# 2842 :Start
        if(tsmap.containsKey('Execute_UpdateCustomerSupportAlias') && tsmap.get('Execute_UpdateCustomerSupportAlias') != null && tsmap.get('Execute_UpdateCustomerSupportAlias').Execute__c){
            updateCustomerSupportAlias(newList);
        }
        // Added by Chetan : CR# 2842 :End
        
        //Added by Viral : CR# 251
        if(tsmap.containsKey('ExecuteUpdateOriginalTAMdetails') && tsmap.get('ExecuteUpdateOriginalTAMdetails') != null && tsmap.get('ExecuteUpdateOriginalTAMdetails').Execute__c && !TriggerUtility.isUpdateOriginalTAMexecuted()){
            fillTAMDetails(newList);
        }
        
        /*if(tsmap.containsKey('updateExtentison') && tsmap.get('updateExtentison') != null && tsmap.get('updateExtentison').Execute__c && !TriggerUtility.isUpdateCaseAccountExtension()){       
updateExtentison(newList,null);
}*/
        
        if(tsmap.containsKey('Execute_Case_Close_with_Action_Plan') && tsmap.get('Execute_Case_Close_with_Action_Plan') != null && tsmap.get('Execute_Case_Close_with_Action_Plan').Execute__c && !TriggerUtility.isCaseCloseCompleteActionPlanExecuted()){   
            CheckActionPlanIsCloseForCase(newList,null);
        }
        
        //Added by Swathi : CR# 1008 Start
        if(tsmap.containsKey('ExecuteUpdateCSMonCase') && tsmap.get('ExecuteUpdateCSMonCase') != null && tsmap.get('ExecuteUpdateCSMonCase').Execute__c && !TriggerUtility.isUpdateCSMonCaseExecuted()){
            UpdateCSMonCase(newList);
        }
        //Added by Swathi : CR# 1008 End
        
        //Added By Anup : TAM Reassignment - Start
        if(tsmap.containsKey('Execute_TAM_Reassignment') && tsmap.get('Execute_TAM_Reassignment') != null && tsmap.get('Execute_TAM_Reassignment').Execute__c){
            checkTAMReassignment(newList, null);
        }
        //Added By Anup : TAM Reassignment - End
        
        //Added by Anup : CR#1702 - Start
        if(tsmap.containsKey('Execute_CollaboratorEmailList') && tsmap.get('Execute_CollaboratorEmailList') != null && tsmap.get('Execute_CollaboratorEmailList').Execute__c){
            validateAndUpdateCustomerCCList(newList, null);
        }
        //Added by Anup : CR#1702 - End
        
        // Added by Ankit Bhatagar : C# 2750 Start  
        if(tsmap.containsKey('Execute_setRequestType') && tsmap.get('Execute_setRequestType') != null && tsmap.get('Execute_setRequestType').Execute__c){
            setRequestType(newList);
        }
        // Added by Ankit Bhatagar : C# 2750 End  
        
        // Added by Ankit : CR# 2958 Start
        if(tsmap.containsKey('Execute_addDefaultProdOnSFDCCases') && tsmap.get('Execute_addDefaultProdOnSFDCCases') != null && tsmap.get('Execute_addDefaultProdOnSFDCCases').Execute__c){
            addDefaultProductOnSFDCSupportCases(newList);
        }
        // Added by Ankit : CR# 2958 End
        
        //Added by Ankit - Defcon Project - start
        setNextUpdateDue(newList,null);
        setDefaultTemplateFields(newList,null);
        addEntitlementToDefconCases(newList);
        //Added by Ankit - Defcon Project - Ends
        TriggerUtility.CaseBeforeInsertExecuted();
    }
    
    public static void afterInsert(List<Case> newList){
        Map<String, Triggers_Switch__c> tsmap = Triggers_Switch__c.getAll();
        // CR# 180 : Abhishek : Short term fixes for CC List : Start
        if(tsmap.containsKey('Execute_CC_toCaseTeam') && tsmap.get('Execute_CC_toCaseTeam') != null && tsmap.get('Execute_CC_toCaseTeam').Execute__c && !TriggerUtility.isCaseCCtoTeamExecuted()){
            cctoCaseTeamafterInsert(newList);
        }
        // CR# 180 : Abhishek : Short term fixes for CC List : End
        
        if(tsmap.containsKey('Execute_TAM_Assignment') && tsmap.get('Execute_TAM_Assignment') != null && tsmap.get('Execute_TAM_Assignment').Execute__c && !TriggerUtility.isTAMAgentWorkExecuted()){
            createAgentWorkforTAM(newList);
        }
        if(tsmap.containsKey('Execute_Case_Description_to_Comment') && tsmap.get('Execute_Case_Description_to_Comment') != null && tsmap.get('Execute_Case_Description_to_Comment').Execute__c && !TriggerUtility.isCaseDesctoCommentExecuted()){
            makeCaseDescriptiontoComment(newList);
        }
        
        if(tsmap.containsKey('Execute_Case_TAM_Notes_History') && tsmap.get('Execute_Case_TAM_Notes_History') != null && tsmap.get('Execute_Case_TAM_Notes_History').Execute__c && !TriggerUtility.isCaseTAMNotesHistoryExecuted()){
            createTAMNotesHistory(newList, null);
        }
        
        if(tsmap.containsKey('UpdateAccountDataTime') && tsmap.get('UpdateAccountDataTime') != null && tsmap.get('UpdateAccountDataTime').Execute__c && !TriggerUtility.isUpdateAccountDataTime()){
            TriggerUtility.stopUpdateAccountDataTime();
            updateTAMWeeklyDateTime(newList,null);
            
        }
        //Added by Swathi : CR1408 start
        if(tsmap.containsKey('Executed_CustomerScroceCard') && tsmap.get('Executed_CustomerScroceCard') != null && tsmap.get('Executed_CustomerScroceCard').Execute__c && !TriggerUtility2.isUpdateCustomerScroceCardValueExecuted()){
            UpdateCustomerScroceCard(newList, null);
        }
        //Added by Swathi : CR1408 End
        
        //Added by Ankit Bhatnagar : TAM Routing implementation Start
        updateDailyQuota(newList, null);
        //Added by Ankit Bhatnagar : TAM Routing implementation End
        
        TriggerUtility.CaseAfterInsertExecuted();
    }
    
    public static void beforeUpdate(List<Case> newList, Map<Id, case> oldmap){
        Map<String, Triggers_Switch__c> tsmap = Triggers_Switch__c.getAll();
        //Added by Anup : CR#2195 - Start
        if(tsmap.containsKey('Execute_Partner_Support_Validation') && tsmap.get('Execute_Partner_Support_Validation') != null && tsmap.get('Execute_Partner_Support_Validation').Execute__c){
            validateExcludePartnerCaseAssignment(newList, oldmap);
        }
        //Added by Anup : CR#2195 - End
        
        if(tsmap.containsKey('Execute_UpdateNOCSubject') && tsmap.get('Execute_UpdateNOCSubject') != null && tsmap.get('Execute_UpdateNOCSubject').Execute__c){
            updateNOCSubject(newList,oldmap);
        } 
        changeAccountofSupportCase(newList, oldmap);
        system.debug('beforeUpdateExecuteddddd');
        if(tsmap.containsKey('Execute_Case_Escalation') && tsmap.get('Execute_Case_Escalation') != null && tsmap.get('Execute_Case_Escalation').Execute__c && !TriggerUtility.isskipCaseEscalationExecuted()){
            system.debug('escalateCaseExecutedddd');    
            escalateCase(newList, oldmap);
        }
        assignNewStartDateforStatus(newList, oldmap);
        assignCustomerScoreParameters(newList); 
        UpdatePriorOwnerofCase(newList, oldmap);
        
        if(tsmap.containsKey('ExecuteUpdateTAMemail') && tsmap.get('ExecuteUpdateTAMemail') != null && tsmap.get('ExecuteUpdateTAMemail').Execute__c && !TriggerUtility.isUpdateTAMemailExecuted()){
            UpdateTAMemail(newList);
        }
        
        // Added by Gurjinder : CR# 125 :Start
        if(tsmap.containsKey('ExecuteUpdateSEonCase') && tsmap.get('ExecuteUpdateSEonCase') != null && tsmap.get('ExecuteUpdateSEonCase').Execute__c && !TriggerUtility.isUpdateSEonCaseExecuted()){
            UpdateSEonCase(newList);
        }
        if(tsmap.containsKey('updateExtentison') && tsmap.get('updateExtentison') != null && tsmap.get('updateExtentison').Execute__c && !TriggerUtility.isUpdateCaseAccountExtension()){       
            updateExtentison(newList,oldmap);
        }
        // Added by Gurjinder : CR# 125 :End
        
        //Added by Anup : CR# 686  : Start
        if(tsmap != null && !tsmap.isEmpty() && tsmap.containsKey('Execute_AgentWork_Trigger') && tsmap.get('Execute_AgentWork_Trigger') != null && tsmap.get('Execute_AgentWork_Trigger').Execute__c && !TriggerUtility.isManualCaseAssignExecuted()){
            UpdateManualRoutingOfCase(newList, oldMap);
        }
        //Added by Anup : CR# 686  : End
        
        if(tsmap.containsKey('Execute_Case_Close_with_Action_Plan') && tsmap.get('Execute_Case_Close_with_Action_Plan') != null && tsmap.get('Execute_Case_Close_with_Action_Plan').Execute__c && !TriggerUtility.isCaseCloseCompleteActionPlanExecuted()){   
            CheckActionPlanIsCloseForCase(newList,oldMap);
        }     
        //Added by Swathi : CR# 1008 Start
        if(tsmap.containsKey('ExecuteUpdateCSMonCase') && tsmap.get('ExecuteUpdateCSMonCase') != null && tsmap.get('ExecuteUpdateCSMonCase').Execute__c && !TriggerUtility.isUpdateCSMonCaseExecuted()){
            UpdateCSMonCase(newList);
        }
        //Added by Swathi : CR# 1008 End
        
        //Added By Anup : TAM Reassignment - Start
        if(tsmap.containsKey('Execute_TAM_Reassignment') && tsmap.get('Execute_TAM_Reassignment') != null && tsmap.get('Execute_TAM_Reassignment').Execute__c && !TriggerUtility.isTAMReassignmentExecuted()){
            checkTAMReassignment(newList, oldMap);
        }
        /* Commented by Chetan IBA-3691 if(tsmap.containsKey('Execute_Assign_TAM_As_Owner') && tsmap.get('Execute_Assign_TAM_As_Owner') != null && tsmap.get('Execute_Assign_TAM_As_Owner').Execute__c && !TriggerUtility.isAssignTAMOwnerExecuted()){
            assignTamAsOwner(newList, oldMap);
        }*/
        //Added By Anup : TAM Reassignment - End
        
        //Added by Anup : CR#1702 - Start
        if(tsmap.containsKey('Execute_CollaboratorEmailList') && tsmap.get('Execute_CollaboratorEmailList') != null && tsmap.get('Execute_CollaboratorEmailList').Execute__c){
            validateAndUpdateCustomerCCList(newList, oldMap);
        }
        //Added by Anup : CR#1702 - End
        
        //CR#3298 TTC TTR Project Added by Chetan-Start
        if(tsmap.containsKey('Execute_UpdateResolutionState') && tsmap.get('Execute_UpdateResolutionState') != null && tsmap.get('Execute_UpdateResolutionState').Execute__c){
            updateResolutionState(newList, oldMap);
        }
        //CR#3298 TTC TTR Project Added by Chetan-End   
        
        //Added by Anup - Omni Overhaul - Start
        updatePrioritySupportOfCase(newList, oldmap);
        //Added by Anup - Omni Overhaul - End
        
        //CR#4095 Added by Chetan-Start  
        if(tsmap.containsKey('Execute_UpdatePendingCustomerTimestamp') && tsmap.get('Execute_UpdatePendingCustomerTimestamp') != null && tsmap.get('Execute_UpdatePendingCustomerTimestamp').Execute__c){
            updatePendingCustomerTimestamp(newList, oldMap);
        } 
        //CR#4095 Added by Chetan-End 
        
        //Handoff-Automation - Anup - Start
        caseHandoffAssignment(newList, oldMap);
        //Handoff-Automation - Anup - End
        
        //IBA-2679 - Change starts here 
        //Ram S Added for Slack notification flows (DO NOT REMOVE)
        Set<Id> priorUserIdSet = new Set<Id>();
        for(Case cs : (List<Case>)Trigger.new) {
            Case oldCS = (Case)Trigger.oldMap.get(cs.Id);
            if(cs.OwnerId != oldCS.OwnerId){
                cs.Prior_Owner_Id__c = oldCS.OwnerId;
                
                //(In flow the merge field '$Record.Owner.Name' is returning null. 
                //So we store prior owner name value in below mentioend field)
                if(cs.Prior_Owner_Id__c.contains(System.Label.Support_Queue_Id)){
                    cs.Prior_Owner_Name__c = 'Support Queue';
                }else if(cs.Prior_Owner_Id__c.contains(System.Label.ZPA_Support_Queue_Id)){
                    cs.Prior_Owner_Name__c = 'ZPA Support Queue';
                }else if(cs.Prior_Owner_Id__c.contains(System.Label.ZPC_Support_Queue)){
                    cs.Prior_Owner_Name__c = 'ZPC Support Queue';
                }else if(cs.Prior_Owner_Id__c.contains(System.Label.ZWS_Queue_Id)){
                    cs.Prior_Owner_Name__c = 'ZWS Support Queue';
                }else if(cs.Prior_Owner_Id__c.contains(System.Label.Defcon_Escalation_Queue)){
                    cs.Prior_Owner_Name__c = 'Defcon Escalation Queue';
                }else{
                    priorUserIdSet.add(oldCS.OwnerId);
                }
            }
            
            //IBA-3745 - Change starts here 
            //Ram S added for existing TAM slack integration flow re-write.
            if(cs.Case_Record_Type_Name__c == 'Support' && cs.FRT_Violation_Warning__c == true && oldCS.FRT_Violation_Warning__c == false){
                cs.Prior_FRT_Violation_Warning_Msg__c = 'FRT SLA Violated';
            }

            if(cs.Case_Record_Type_Name__c == 'Escalation' && cs.Defcon_Level__c != oldCS.Defcon_Level__c){
            	cs.Prior_Defcon_Level__c = oldCS.Defcon_Level__c;
            }
            //IBA-3745 - Change ends here
        }
        if(!priorUserIdSet.isEmpty()){
            Map<Id, User> activePriorOwnerssMap = new Map<Id, User>([SELECT Id, Name FROM User WHERE Id IN :priorUserIdSet AND isActive = true ORDER BY Name DESC]);
            for(Case cs : (List<Case>)Trigger.new) {
                User priorOwnerUser = activePriorOwnerssMap.get(((Case)Trigger.oldMap.get(cs.Id)).OwnerId);
                cs.Prior_Owner_Name__c = priorOwnerUser != null ? priorOwnerUser.Name : '';
            }
        }
        //IBA-2679 - Change ends here
        
        //Defcon Changes - Start
        reopenDefconCase(newList,oldMap);
        setNextUpdateDue(newList,oldMap);
        setDefaultTemplateFields(newList,oldMap);
        
        //Added by Ankit - Defcon Project - start
        setAutoEscSLACumulativeTime(newList,oldMap);
        resetMilestonesOnDefconUpdate(newList,oldMap);
        //Added by Ankit - Defcon Project - End
        
        //Added By Bhagyalaxmi - 4069- Start
        validateDefconOwner(newList,oldMap);
        //Added By Bhagyalaxmi - 4069- End

        //added by Bhagyalaxmi - IBA-5356
        UpdateParentFieldsOnDefcon(newList,oldMap);
        //Added By Bhagyalaxmi - IBA-5356- End
        //Defcon Changes - End
        
        TriggerUtility.CaseBeforeUpdateExecuted();
    }
    
    public static void afterUpdate(List<Case> newList, Map<Id, case> oldmap){
        Map<String, Triggers_Switch__c> tsmap = Triggers_Switch__c.getAll();
        
        // CR# 180 : Abhishek : Short term fixes for CC List : Start
        if(tsmap.containsKey('Execute_CC_toCaseTeam') && tsmap.get('Execute_CC_toCaseTeam') != null && tsmap.get('Execute_CC_toCaseTeam').Execute__c && !TriggerUtility.isCaseCCtoTeamExecuted()){
            cctoCaseTeamafterUpdate(newList, oldmap);
        }
        // CR# 180 : Abhishek : Short term fixes for CC List : End
        
        if(tsmap.containsKey('Execute_SendEscalationEmail') && tsmap.get('Execute_SendEscalationEmail') != null && tsmap.get('Execute_SendEscalationEmail').Execute__c){
            sendEscalationEmail(newList,oldMap);
        }
        if(tsmap.containsKey('Execute_Escalation_Notes_Creation') && tsmap.get('Execute_Escalation_Notes_Creation') != null && tsmap.get('Execute_Escalation_Notes_Creation').Execute__c && !TriggerUtility.isCaseEscalationNotesExecuted()){
            escalationNotesCreation(newList, oldmap);
        }
        if(tsmap.containsKey('Execute_Escalation_History_Creation') && tsmap.get('Execute_Escalation_History_Creation') != null && tsmap.get('Execute_Escalation_History_Creation').Execute__c && !TriggerUtility.isCaseEscalationHistoryExecuted()){
            escalationHistoryCreation(newList, oldmap);
        }
        
        if(tsmap.containsKey('Execute_Case_Status_History') && tsmap.get('Execute_Case_Status_History') != null && tsmap.get('Execute_Case_Status_History').Execute__c && !TriggerUtility.isCaseStatusHistoryExecuted()){
            caseStatusChangeManagement(newList, oldmap);
        }
        
        if(tsmap.containsKey('Execute_Manual_SLA') && tsmap.get('Execute_Manual_SLA') != null && tsmap.get('Execute_Manual_SLA').Execute__c && !TriggerUtility.isManualSLAExecuted()){
            manualSLAChange(newList, oldmap);
        }
        
        if(tsmap.containsKey('Execute_Get_Feedback') && tsmap.get('Execute_Get_Feedback') != null && tsmap.get('Execute_Get_Feedback').Execute__c && !TriggerUtility.isGetFeedbackExecuted()){
            getFeedbackSurveyCreation(newList, oldmap);
        }
        if(tsmap.containsKey('CloseMilestonesonCaseClose') && tsmap.get('CloseMilestonesonCaseClose') != null && tsmap.get('CloseMilestonesonCaseClose').Execute__c && !TriggerUtility.isCloseMilestonesonCaseCloseExecuted()){
            closeMilestonesonCaseClosure(newList, oldmap);
        }
        
        //Added by Gurjinder for update details on Master Case:Start
        if(tsmap.containsKey('UpdateDetailsonMasterCase') && tsmap.get('UpdateDetailsonMasterCase') != null && tsmap.get('UpdateDetailsonMasterCase').Execute__c && !TriggerUtility.isUpdateDetailsonMasterCaseExecuted()){
            UpdateDetailsonMasterCase(newList, oldmap);
        }
        //Added by Gurjinder for update details on Master Case:End
        
        if(tsmap.containsKey('UpdateAccountDataTime') && tsmap.get('UpdateAccountDataTime') != null && tsmap.get('UpdateAccountDataTime').Execute__c && !TriggerUtility.isUpdateAccountDataTime()){
            TriggerUtility.stopUpdateAccountDataTime();
            updateTAMWeeklyDateTime(newList,oldmap);
        }
        
        //Added by Anup : CR1022 - Start
        if(tsmap.containsKey('Execute_Sync_CaseBA_With_CR') && tsmap.get('Execute_Sync_CaseBA_With_CR') != null && tsmap.get('Execute_Sync_CaseBA_With_CR').Execute__c && !TriggerUtility.isSyncBAOnCrExecuted()){
            SyncBusinessAnalystWithCR(newList,oldMap);
        }
        //Added by Anup : CR1022 - End
        
        if(tsmap.containsKey('Execute_Case_TAM_Notes_History') && tsmap.get('Execute_Case_TAM_Notes_History') != null && tsmap.get('Execute_Case_TAM_Notes_History').Execute__c && !TriggerUtility.isCaseTAMNotesHistoryExecuted()){
            createTAMNotesHistory(newList, null);
        }
        
        //Viral : To sync back updates to Case Integration record
        if(tsmap.containsKey('Execute_Case_Integration_Updation') && tsmap.get('Execute_Case_Integration_Updation') != null &&
           tsmap.get('Execute_Case_Integration_Updation').Execute__c && !TriggerUtility.isExecuteCaseAfterUpdateCaseIntegartionExecuted())
        {
            TriggerUtility.executeCaseAfterUpdateCaseIntegartionSetTrue();
            updateCaseIntegration(newList,oldmap);
        }
        
        //Added by Swathi : CR1408 start
        if(tsmap.containsKey('Executed_CustomerScroceCard') && tsmap.get('Executed_CustomerScroceCard') != null && tsmap.get('Executed_CustomerScroceCard').Execute__c && !TriggerUtility2.isUpdateCustomerScroceCardValueExecuted()){
            UpdateCustomerScroceCard(newList, oldmap);
        }
        //Added by Swathi : CR1408 End
        
        //Added by Anup : CR#502 - Start
        if(tsmap.containsKey('Execute_TAM_Owner_OOO_Mail') && tsmap.get('Execute_TAM_Owner_OOO_Mail') != null && tsmap.get('Execute_TAM_Owner_OOO_Mail').Execute__c){
            sendEmailToTamManagerForOOO(newList, OldMap);
        }
        //Added by Anup : CR#502 - End
        sendDefconStatusChangeEmail(newList,OldMap);
        //CR#2495 Added by Chetan - Start
        /*if(tsmap.containsKey('Execute_SendEmailForCancelledMeeting') && tsmap.get('Execute_SendEmailForCancelledMeeting') != null && tsmap.get('Execute_SendEmailForCancelledMeeting').Execute__c){
sendEmailForCancelledMeeting(newList, OldMap);
}*/
        //CR#2495 Added by Chetan - End
        
        //Added by Anup - Omni Overhaul
        
        updateDailyQuota(newList, oldmap);
        
        //Added by Ankit - CR# 3883 - Start
        /*sendEmailOnMeetingNotesUpdate(newList, oldMap);*/
        //Added by Ankit - CR# 3883 - End
        
        //Added by Bhagyalaxmi - IBA-4060-Start
        closeDefconOnCaseClosure(newList, oldmap);
        //Added by Bhagyalaxmi - IBA-4060-End
        
        //Added by Ankit - Defcon Project - start
        toggleAutoEscSLAOnDefcon(newList, oldmap);
        completeDefconMilestones(newList, oldMap);
        //Added by Ankit - Defcon Project - End
        
        //Added by Chetan: IBA-686
        if(tsmap.containsKey('Execute_CaseRecordHistoryTracking') && tsmap.get('Execute_CaseRecordHistoryTracking') != null && tsmap.get('Execute_CaseRecordHistoryTracking').Execute__c){
            insertCaseRecordHistoryTracking((List<Case>)Trigger.new,(Map<Id,Case>)Trigger.oldMap);
        }
        //Added by Chetan: IBA-686
        TriggerUtility.CaseAfterUpdateExecuted();
    }
    
    //Added by Anup : CR#2195 - Start
    public static void validateExcludePartnerCaseAssignment(List<Case> newList, map<Id, Case> oldMap){
        List<Id> listOfOwnerId = new List<Id>();
        Set<Id> setOfCaseId = new Set<Id>();
        for(Case cs : newList){
            if((cs.RecordTypeId == caseSupportRT && cs.Exclude_Partner_Support__c && oldMap.get(cs.Id).OwnerId == Label.Handoff_Queue_ID && String.valueOf(cs.OwnerId).startswith('005') && cs.OwnerId != oldMap.get(cs.Id).OwnerId) || Test.isRunningTest()){
                listOfOwnerId.add(cs.OwnerId);
                setOfCaseId.add(cs.Id);
            } 
        }
        if(!listOfOwnerId.isEmpty()){
            String partnerProfileIds = Label.Partner_Engineer_Profile_Ids;
            List<Id> listOfProfileId = partnerProfileIds.split(',');
            List<Id> listOfPE = new List<Id>();
            for(User usr : [select id from User where id IN:listOfOwnerId and profileId IN:listOfProfileId]){
                listOfPE.add(usr.Id);
            }
            for(Case cs : newList){
                if(setOfCaseId.contains(cs.Id) && listOfPE.contains(cs.OwnerId)){
                    cs.addError(Label.Excluded_Partner_Validation_Message);
                }
            }
        }
    }
    //Added by Anup : CR#2195 - End
    
    //Added by Anup : CR#1702 - Start
    public static void validateAndUpdateCustomerCCList(List<Case> newList, Map<Id, Case> oldMap){
        Set<String> setOfEmailId = new Set<String>();
        for(Case cs: newList){
            if(cs.RecordTypeId == caseSupportRT && (oldMap==null || (cs.Internal_cc_List__c != oldmap.get(cs.Id).Internal_cc_List__c || cs.Customer_CC_List__c != oldmap.get(cs.Id).Customer_CC_List__c))){
                setOfEmailId = new Set<String>();
                if((oldMap==null || (oldMap!=null && cs.Customer_CC_List__c != oldmap.get(cs.Id).Customer_CC_List__c)) && !String.isBlank(cs.Customer_CC_List__c)){
                    String ccListCheck = cs.Customer_CC_List__c.removeEnd(';');
                    if(!((ccListCheck.countMatches('@') == ccListCheck.countMatches(';')) || (ccListCheck.countMatches('@') == ccListCheck.countMatches(';')+1))){
                        cs.addError('Please seperate the emails by semi-colon in Customer CC List');
                    }
                    String ccList='';
                    list<String> listOfEmail = cs.Customer_CC_List__c.split(';');
                    for(String email: listOfEmail){
                        if(!String.isBlank(email) && !setOfEmailId.contains(email)){
                            ccList += email.trim() + ';';
                            setOfEmailId.add(email);
                        }
                    }
                    cs.Customer_CC_List__c = ccList;
                }
                /*if(cs.Customer_CC_List__c !=null && cs.Account_Support_Email__c!=null ) 
{
cs.Customer_CC_List__c +=cs.Account_Support_Email__c + ';';                 
}
else if(cs.Account_Support_Email__c !=null)
{
cs.Customer_CC_List__c =cs.Account_Support_Email__c + ';';                             
}
System.debug(cs.Customer_CC_List__c); */
                
                if(oldMap !=null && (cs.Internal_cc_List__c != oldmap.get(cs.Id).Internal_cc_List__c) && !String.isBlank(cs.Internal_CC_List__c)){
                    String internalListCheck = cs.Internal_cc_List__c.removeEnd(';');
                    if(!((internalListCheck.countMatches('@') == internalListCheck.countMatches(';')) || (internalListCheck.countMatches('@') == internalListCheck.countMatches(';')+1))){
                        cs.addError('Please seperate the emails by semi-colon in Internal CC List');
                    }
                    String internalList='';
                    list<String> listOfEmail2 = cs.Internal_CC_List__c.split(';');
                    for(String email: listOfEmail2){
                        if(!String.isBlank(email) && !setOfEmailId.contains(email)){
                            internalList += email.trim() + ';';
                            setOfEmailId.add(email);
                        }
                    }
                    cs.Internal_CC_List__c = internalList;
                }
                
            }
        }
    }
    //Added by Anup : CR#1702 - End
    
    //Added by Anup : CR#502 - Start
    public static void sendEmailToTamManagerForOOO(List<Case> newList, Map<Id, Case> oldMap){
        List<Id> listOfCaseId = new List<Id>();
        List<Id> listOfUserId = new List<Id>();
        for(Case cs: newList){
            //Changed by Ankit : CR# 2686 - START 
            if((cs.Case_Type__c == 'Problem' ||  cs.Case_Type__c == 'Question') && cs.Status != oldMap.get(cs.Id).Status && cs.Status == 'Customer Note Added'){
                //if(cs.Is_TAM_Account__c && cs.Is_Current_Owner_TAM__c && cs.Status != oldMap.get(cs.Id).Status && cs.Status == 'Customer Note Added'){
                //Changed by Ankit : CR# 2686 - END
                listOfCaseId.add(cs.Id);
                listOfUserId.add(cs.ownerId);
            }
        }
        if(!listOfCaseId.isEmpty() || Test.isRunningTest()){
            Map<Id, List<String>> mapOfUserAndEmails = new Map<Id, List<String>>();
            for(User usr: [select id, Email, Manager.Email from User where Out_Of_office__c=true and Returning_date__c >: System.today()]){
                mapOfUserAndEmails.put(usr.Id, new List<String>{usr.Email, usr.Manager.Email});
            }
            if(!mapOfUserAndEmails.isEmpty()){
                List<Messaging.SingleEmailMessage> mailLst = new List<Messaging.SingleEmailMessage>();
                EmailTemplate emailTemplate = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where DeveloperName = 'Custom_Comment_To_TAM_Managers'];
                Messaging.SingleEmailMessage mail =  new Messaging.SingleEmailMessage();
                mail.setTemplateId(emailTemplate.Id);
                mail.settargetObjectId([select id from Contact limit 1].Id);
                mail.setTreatTargetObjectAsRecipient(false);
                OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'support@zscaler.com'];
                if(owea.size() > 0){
                    mail.setOrgWideEmailAddressId(owea.get(0).Id);  
                }
                for(Case cs: newList){
                    if(listOfCaseId.contains(cs.Id)){
                        if(mapOfUserAndEmails.containsKey(cs.OwnerId) && mapOfUserAndEmails.get(cs.OwnerId) != null){
                            List<String> listOfAddress = mapOfUserAndEmails.get(cs.OwnerId);
                            mail.setWhatId(cs.Id);
                            if(listOfAddress[1] != null){
                                mail.setToAddresses(new List<String>{listOfAddress[1]});  
                                mail.setCcAddresses(new List<String>{listOfAddress[0]});
                                mailLst.add(mail);
                            }
                        }
                    }
                }  
                if(!mailLst.isEmpty() && !Test.isRunningTest()){
                    try{
                        Messaging.sendEmail(mailLst); 
                    }catch(Exception ex){
                        system.debug('Error While sending Email to TAM manager');
                    }
                }
            }
        }
    }    
    //Added by Anup : CR#502 - End
    
    //Added by Anup : TAM Reassignment - Start
    public static void checkTAMReassignment(List<Case> newList, Map<Id, Case> oldMap){
        List<Case> caseForTAMassignment = new List<Case>();
        //Added By Anup-CR#1465 - Start
        List<Id> listOfAccountId = new List<Id>();
        Set<Id> setOfAccountId = new Set<Id>();
        //Anup - Product Exclusions for TAM Reassignment - Start
        List<String> productsToExclude = new List<String>();
        if(String.isNotBlank(Label.TAM_Assignment_Exclusion_Products)){
            productsToExclude = Label.TAM_Reassignment_Excluded_Products.trim().split(';');
        }
        //Anup - Product Exclusions for TAM Reassignment - End
        Map<Id, Set<Id>> mapOfAccountAndTAM = new Map<Id, Set<Id>>();
        //if(oldMap == null){
        for(Case currCase: newList){
            if(currCase.RecordTypeId == caseSupportRT /*&& currCase.is_TAM_account__c*/ && currCase.Priority != 'Low (P4)' && currCase.Priority != 'Urgent (P1)' && (currCase.Case_Type__c=='Problem' || currCase.Case_Type__c=='Question') && !productsToExclude.contains(currCase.Product_New__c)){
                listOfAccountId.add(currCase.AccountId);
            }
        }
        if(!listOfAccountId.isEmpty()){
            for(Account acc: [select id, Skip_TAM_Reassignments__c, TAM_Name_New__c, Secondary_TAM_Name__c, X3rd_TAM_Name__c from Account where Id in:listOfAccountId /*and Skip_TAM_Reassignments__c = true*/]){
                if(acc.Skip_TAM_Reassignments__c){
                    setOfAccountId.add(acc.Id);
                }
                Set<Id> setOfTAMIds = new Set<Id>();
                if(acc.TAM_Name_New__c != null){
                    setOfTAMIds.add(acc.TAM_Name_New__c);
                }
                if(acc.Secondary_TAM_Name__c != null){
                    setOfTAMIds.add(acc.Secondary_TAM_Name__c);
                }
                if(acc.X3rd_TAM_Name__c != null){
                    setOfTAMIds.add(acc.X3rd_TAM_Name__c);
                }
                if(!setOfTAMIds.isEmpty()){
                    mapOfAccountAndTAM.put(acc.Id, setOfTAMIds);
                }
            }
        }  
        //}
        //Added By Anup-CR#1465 - End
        for(Case currentCase : newList){
            Set<Id> setOfPresentTAMs = new Set<Id>();
            if(mapOfAccountAndTAM.containsKey(currentCase.AccountId)){
                setOfPresentTAMs = mapOfAccountAndTAM.get(currentCase.AccountId);
            }
            if((currentCase.RecordTypeId == caseSupportRT) && currentCase.Next_TAM_Date__c == null /*&& ((oldMap!=null && currentCase.OwnerId != oldMap.get(currentCase.Id).OwnerId) || oldMap==null)*/ && currentCase.is_Tam_Account__c /*&& !currentCase.Is_Current_Owner_TAM__c*/ && currentCase.Priority != 'Low (P4)' && currentCase.Priority != 'Urgent (P1)' && (currentCase.Case_Type__c=='Problem' || currentCase.Case_Type__c=='Question') && !productsToExclude.contains(currentCase.Product_New__c)){
                Integer daysAdded = 1;
                Integer numberOfDays = 0;
                DateTime nextTamDate;
                if(oldMap!=null){
                    nextTamDate = currentCase.CreatedDate;    
                }else{
                    nextTamDate = System.now();    
                }
                system.debug('Priority :'+currentcase.Priority);
                
                if(currentcase.Priority == 'High (P2)'){
                    numberOfDays = 3;
                }
                if(currentcase.Priority == 'Medium (P3)'){
                    numberOfDays = 7;
                }
                system.debug('numberOfDays :'+numberOfDays);
                while(daysAdded <= numberOfDays){
                    nextTamDate = nextTamDate.addDays(1);
                    daysAdded += 1;
                }
                String day = nextTamDate.format('E');
                if(day == 'Sat'){
                    nextTamDate = nextTamDate.addDays(2);
                    nextTamDate = DateTime.newInstance(nextTamDate.year(), nextTamDate.month(), nextTamDate.day());
                }
                else if(day == 'Sun'){
                    nextTamDate = nextTamDate.addDays(1);
                    nextTamDate = DateTime.newInstance(nextTamDate.year(), nextTamDate.month(), nextTamDate.day());
                }
                currentCase.Next_TAM_Date__c = nextTamDate;
                //currentCase.TAM_Assignment__c = 'Assigned To Support';
            }/*else{
if(currentCase.TAM_Assignment__c != 'Not TAM Account' && !currentCase.Is_TAM_Account__c){
currentCase.TAM_Assignment__c = 'Not TAM Account';
currentCase.Next_TAM_Date__c = null;
}
else if(currentCase.TAM_Assignment__c != 'Pending TAM Assignment' && currentCase.TAM_Assignment__c != 'Assigned To Support' && currentCase.Is_TAM_Account__c && !currentCase.Is_Current_Owner_TAM__c){
currentCase.TAM_Assignment__c = 'Assigned To Support';
}
else if(currentCase.TAM_Assignment__c != 'Pending TAM Assignment' && currentCase.TAM_Assignment__c != 'Assigned To Support' && currentCase.Is_TAM_Account__c && currentCase.Is_Current_Owner_TAM__c){
currentCase.TAM_Assignment__c = 'Assigned To TAM';
}
}*/
            if(setOfPresentTAMs!= null && !setOfPresentTAMs.isEmpty() && setOfPresentTAMs.contains(currentCase.OwnerId)){
                currentCase.TAM_Assignment__c = 'Assigned To TAM';
            }
            else if(setOfPresentTAMs.isEmpty()){
                currentCase.TAM_Assignment__c = 'Not TAM Account';
            }
            else{
                if(currentCase.TAM_Assignment__c != 'Pending TAM Assignment'){
                    currentCase.TAM_Assignment__c = 'Assigned To Support';
                }
            }
            /*//Added by Chetan : CR#2468 -Start
if(currentCase.Is_Current_Owner_TAM__c && currentCase.Is_TAM_Account__c)
{
currentCase.TAM_Assignment__c = 'Assigned To TAM';
}
//Added by Chetan : CR#2468 -End*/
            //Added By Anup-CR#1465 - Start
            if(!setOfAccountId.isEmpty() && setOfAccountId.contains(currentCase.AccountId)){
                currentCase.TAM_Reassignment__c = true; 
            }
            //Added By Anup-CR#1465 - End
        }
        TriggerUtility.TAMReassignmentExecuted();
    }
    
   /*  Commented by Chetan IBA-3691 Start 
    public static void assignTamAsOwner(List<Case> newList, Map<Id, Case> oldMap){
        List<String> listOfStatus = new List<String>{'New', 'Reopen', 'Researching', 'Pending Customer', 'Customer Note Added', 'Escalated to Engineering'};
            List<Id> listOfCaseToProcess = new List<Id>(); 
        Map<Id, Id> mapOfCaseAndTAM = new Map<Id, Id>();
        //Anup - Product Exclusions for TAM Reassignment - Start
        List<String> productsToExclude = new List<String>();
        if(String.isNotBlank(Label.TAM_Assignment_Exclusion_Products)){
            productsToExclude = Label.TAM_Reassignment_Excluded_Products.trim().split(';');
        }
        //Anup - Product Exclusions for TAM Reassignment - End
        for(Case currentCase : newList){
            system.debug('currentCase --- '+currentCase.TAM_Assignment__c + '----->'+oldMap.get(currentCase.Id).TAM_Assignment__c);
            if((currentCase.TAM_Assignment__c != oldMap.get(currentCase.Id).TAM_Assignment__c && currentCase.TAM_Assignment__c == 'Pending TAM Assignment' && listOfStatus.contains(currentCase.Status) && !currentCase.TAM_Reassignment__c && !productsToExclude.contains(currentCase.Product_New__c)) || Test.isRunningTest()){
                listOfCaseToProcess.add(currentCase.Id);
            }
        }
        if(!listOfCaseToProcess.isEmpty()){
            Map<String, Timezone_Region_Mapping__c> timeRegionMap = Timezone_Region_Mapping__c.getAll();
            for(Case currentCase : [select id, OwnerId, Preferred_Contact_Time_Zone__c, AccountId, Account.TAM_Name_New__c, Account.Secondary_TAM_Name__c, Account.X3rd_TAM_Name__c, Account.TAM_Name_New__r.TimeZoneSidKey, Account.Secondary_TAM_Name__r.TimeZoneSidKey, Account.X3rd_TAM_Name__r.TimeZoneSidKey, Account.TAM_Name_New__r.Out_Of_Office__c, Account.Secondary_TAM_Name__r.Out_Of_Office__c, Account.X3rd_TAM_Name__r.Out_Of_Office__c, Account.TAM_Name_New__r.Returning_Date__c, Account.Secondary_TAM_Name__r.Returning_Date__c,  Account.X3rd_TAM_Name__r.Returning_Date__c from Case where Id in:listOfCaseToProcess]){
                if(currentCase.AccountId !=null && currentCase.Account.TAM_Name_New__c!=null && !currentCase.Account.TAM_Name_New__r.Out_Of_Office__c){
                    if(currentCase.Preferred_Contact_Time_Zone__c==null || (timeRegionMap.containsKey(currentCase.Preferred_Contact_Time_Zone__c) && timeRegionMap.containsKey(currentCase.Account.TAM_Name_New__r.TimeZoneSidKey) && (timeRegionMap.get(currentCase.Preferred_Contact_Time_Zone__c).Region__c == timeRegionMap.get(currentCase.Account.TAM_Name_New__r.TimeZoneSidKey).Region__c))){
                        if(!currentCase.Account.TAM_Name_New__r.Out_Of_Office__c){
                            if(currentCase.Account.TAM_Name_New__r.Returning_Date__c == null || (currentCase.Account.TAM_Name_New__r.Returning_Date__c != null && Date.Today().daysBetween(currentCase.Account.TAM_Name_New__r.Returning_Date__c) >= 1)){
                                mapOfCaseAndTAM.put(currentCase.Id, currentCase.Account.TAM_Name_New__c);
                                continue;
                            }
                        }
                    }
                }
                if(currentCase.AccountId !=null && currentCase.Account.Secondary_TAM_Name__c!=null && !currentCase.Account.Secondary_TAM_Name__r.Out_Of_Office__c){
                    if(currentCase.Preferred_Contact_Time_Zone__c==null || (timeRegionMap.containsKey(currentCase.Preferred_Contact_Time_Zone__c) && timeRegionMap.containsKey(currentCase.Account.Secondary_TAM_Name__r.TimeZoneSidKey) && (timeRegionMap.get(currentCase.Preferred_Contact_Time_Zone__c).Region__c == timeRegionMap.get(currentCase.Account.Secondary_TAM_Name__r.TimeZoneSidKey).Region__c))){
                        if(!currentCase.Account.Secondary_TAM_Name__r.Out_Of_Office__c){
                            if(currentCase.Account.Secondary_TAM_Name__r.Returning_Date__c == null || (currentCase.Account.Secondary_TAM_Name__r.Returning_Date__c != null && currentCase.Account.Secondary_TAM_Name__r.Returning_Date__c.daysBetween(Date.Today()) >= 1)){
                                mapOfCaseAndTAM.put(currentCase.Id, currentCase.Account.Secondary_TAM_Name__c);
                                continue;
                            }
                        }
                    }
                }
                if(currentCase.AccountId !=null && currentCase.Account.X3rd_TAM_Name__c!=null && !currentCase.Account.X3rd_TAM_Name__r.Out_Of_Office__c){
                    if(currentCase.Preferred_Contact_Time_Zone__c==null || (timeRegionMap.containsKey(currentCase.Preferred_Contact_Time_Zone__c) && timeRegionMap.containsKey(currentCase.Account.X3rd_TAM_Name__r.TimeZoneSidKey) && (timeRegionMap.get(currentCase.Preferred_Contact_Time_Zone__c).Region__c == timeRegionMap.get(currentCase.Account.X3rd_TAM_Name__r.TimeZoneSidKey).Region__c))){
                        if(!currentCase.Account.X3rd_TAM_Name__r.Out_Of_Office__c){
                            if(currentCase.Account.X3rd_TAM_Name__r.Returning_Date__c == null || (currentCase.Account.X3rd_TAM_Name__r.Returning_Date__c != null && currentCase.Account.X3rd_TAM_Name__r.Returning_Date__c.daysBetween(Date.Today()) >= 1)){
                                mapOfCaseAndTAM.put(currentCase.Id, currentCase.Account.X3rd_TAM_Name__c);
                                continue;
                            }
                        }
                    }
                }
            }
            for(Case cs : newList){
                if(mapOfCaseAndTAM.containsKey(cs.Id) && mapOfCaseAndTAM.get(cs.Id)!=null){
                    //Added by Anup: CR#2052 - Start
                    if(String.valueOf(cs.Ownerid).startsWith('005') ){
                        cs.Prior_Owner__c = cs.OwnerId;
                    }
                    cs.Case_Owner_Assigned_Date__c = System.now();
                    //Added by Anup: CR#2052 - End
                    cs.OwnerId = mapOfCaseAndTAM.get(cs.Id); 
                    //Added by Chetan : CR#2468 -Start
                    cs.Case_TAM_Assignment__c='Reassignment';
                    //Added by Chetan : CR#2468 -End
                    cs.TAM_Assignment__c = 'Assigned To TAM';
                }
                else if(!mapOfCaseAndTAM.containsKey(cs.Id) && listOfCaseToProcess.contains(cs.Id)){
                    cs.TAM_Assignment__c = 'Assigned To Support';
                    Decimal currentCount = cs.No_of_TAM_Reassignment_Attempts__c;
                    cs.No_of_TAM_Reassignment_Attempts__c = currentCount + 1;
                    if(cs.No_Of_TAM_Reassignment_Attempts__c < 2){
                        DateTime nextTamDate = cs.Next_TAM_Date__c != null ? cs.Next_TAM_Date__c : System.now();
                        String addingHours = Label.TAM_Reassignment_Reschedule_Hours;
                        if(!String.isBlank(addingHours) && addingHours.isNumeric()){
                            Integer addHours = Integer.valueOf(addingHours);
                            cs.Next_TAM_Date__c = nextTamDate.addHours(addHours);
                        }else{
                            cs.Next_TAM_Date__c = nextTamDate.addHours(12);    
                        }  
                    }else{
                        cs.TAM_Reassignment__c = true;
                    }
                    
                }
            }
        }
        TriggerUtility.AssignTAMOwnerExecuted();
    }
    //Added by Anup : TAM Reassignment - End Commented by Chetan IBA-3691 */
    
    //Added by Anup : CR1022 - Start
    public static void SyncBusinessAnalystWithCR(List<Case> newList, Map<Id, Case> oldmap){
        Id caseSalesOpsRT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Sales').getRecordTypeId();
        List<Id> listOfCase = new List<Id>();
        Map<Id,Id> mapOfCaseAndBSA = new Map<Id,Id>();
        for(Case cs : newList){
            if(cs.RecordTypeId == caseSalesOpsRT && cs.Business_Analyst__c != null && cs.Business_Analyst__c != oldMap.get(cs.Id).Business_Analyst__c){
                mapOfCaseAndBSA.put(cs.Id, cs.Business_Analyst__c);
            }
        }
        if(!mapOfCaseAndBSA.isEmpty()){
            List<Tracker_Change_request__c> listOfCRToUpdate = new List<Tracker_Change_request__c>();
            for(Tracker_Change_request__c cr : [select id, Business_Analyst__c, Case__c from Tracker_Change_Request__c where Case__c IN:mapOfCaseAndBSA.keySet() AND Stage__c not in ('Archived', 'Released') AND Parent_Request__c=null]){
                if(mapOfCaseAndBSA.get(cr.Case__c)!=null && cr.Business_Analyst__c != mapOfCaseAndBSA.get(cr.Case__c)){
                    cr.Business_analyst__c = mapOfCaseAndBSA.get(cr.Case__c);
                    listOfCRToUpdate.add(cr);
                }
            }
            if(!listOfCRToUpdate.isEmpty()){
                //Commented by Tirth
                //                TriggerUtility.SyncBAOnCaseExecuted();
                update listOfCRToUpdate;
            }
        }
        //Commented by Tirth
        //        TriggerUtility.SyncBAOnCrExecuted();
    }
    //Added by Anup : CR1022 - End
    
    //Added by Anup : CR# 686  : Start
    public static void UpdateManualRoutingOfCase(List<Case> newList, Map<Id, Case> oldmap){
        system.debug('Inside UpdateManualRoutingOfCase');
        //Id queueId = [select QueueId from QueueSObject where Queue.Name='Support Queue'].QueueId;
        for(Case cs:newList){
            String oldOwnerId = String.valueOf(oldMap.get(cs.id).OwnerId);
            if(cs.RecordTypeId == caseSupportRT && cs.Ownerid != oldmap.get(cs.id).Ownerid && oldOwnerId.containsIgnoreCase(Label.Support_Queue_Id) && cs.Original_Case_Assigned_Date_Time__c==null){
                cs.Original_Case_Assigned_Date_Time__c=System.Now();
            }
        }
        TriggerUtility.ManualCaseAssignExecuted();
    }   
    //Added by Anup : CR# 686  : End
    
    //Siemens -- 1139
    public static void updateCaseIntegration(List<Case> newList, Map<Id, Case> oldmap){
        List<Case> siemensCases = new  List<Case>();
        for(Case cs:newList){
            if(cs.External_Reference__c != null && cs.origin =='API'){
                siemensCases.add(cs);
            }
        }
        if(siemensCases.size()>0){
            List<Generic_Field_Mapping__mdt> metaDataList = GenericFieldMappingController.getMappingFromMetaData('Case','Case_Integration__c');
            System.debug('---metaDataList---'+metaDataList);
            Set<String> siemensFields = new Set<String>();
            for(Generic_Field_Mapping__mdt mdt : metaDataList){
                if(mdt.Source_Field_API_Name__c != null && mdt.Origin__c == 'Siemens'){
                    siemensFields.add(mdt.Source_Field_API_Name__c);
                }
            }
            List<Case> updatedCases = new List<Case>();
            for(Case cs : siemensCases){
                case csOld = oldmap.get(cs.id);
                for (String field : siemensFields) {
                    if (cs.get(field) !=  csOld.get(field)) {
                        updatedCases.add(cs);
                        break;
                    }
                }
            }
            System.debug('--updatedCases--'+updatedCases);
            
            MAP<ID,ID> caseIdCaseIntegartionIDMap = new MAP<ID,ID>();
            MAP<ID,List<ID>> caseIdCaseIntComplaintIDMap = new MAP<ID,List<ID>>();
            for(Case_Integration__c cst : [Select id,name,Case__c,Incident_Type__c,createddate from Case_Integration__c  
                                           where case__c in : updatedCases and case__c != null  order by createddate])
            {
                if(cst.Incident_Type__c == 'Incident'){
                    caseIdCaseIntegartionIDMap.put(cst.case__c,cst.id);
                }else if(cst.Incident_Type__c == 'Complaint'){
                    List<ID> complaintIds = caseIdCaseIntComplaintIDMap.containskey(cst.case__c) ? caseIdCaseIntComplaintIDMap.get(cst.case__c)  : new List<ID>();
                    complaintIds.add(cst.id);
                    caseIdCaseIntComplaintIDMap.put(cst.case__c,complaintIds);
                }
            }
            
            
            System.debug('--caseIdCaseIntegartionIDMap--'+caseIdCaseIntegartionIDMap);
            System.debug('--caseIdCaseIntComplaintIDMap--'+caseIdCaseIntComplaintIDMap);
            
            MAP<ID,case> caseMessageMap= new MAP<ID,Case>([Select id,casenumber,(Select id, FromName,RelatedToId, 
                                                                                 Incoming,TextBody,MessageDate from emailmessages where 
                                                                                 Incoming = false 
                                                                                 order by MessageDate Desc limit 1) 
                                                           from case where id in :caseIdCaseIntegartionIDMap.keyset()]);
            
            List<Case_Integration__c> caseIntegartionRecordUpdate = new List<Case_Integration__c>();
            for(case cs : updatedCases){
                if(caseIdCaseIntegartionIDMap.containskey(cs.id) && 
                   caseIdCaseIntegartionIDMap.get(cs.id) != null && 
                   ((cs.AccountID == System.label.Siemens_Account_ID) || Test.isRunningTest()) &&
                   (cs.status == 'Closed' || cs.status == 'Pending Customer' ||
                    cs.status == 'Researching' || cs.status == 'Escalated to Engineering' ||
                    cs.status == 'Awaiting Fix' || cs.status == 'Customer Callback Scheduled'))
                {
                    
                    Case_Integration__c csInst = new Case_Integration__c();
                    csInst.id = caseIdCaseIntegartionIDMap.get(cs.id);
                    csInst = prepareCaseIntegartionRecordFromCaseSiemens(cs,csInst,  metaDataList);
                    if(caseMessageMap.containskey(cs.id) && caseMessageMap.get(cs.id).emailmessages != null){
                        
                        for(EmailMessage em : caseMessageMap.get(cs.id).emailmessages){
                            
                            String timeStamp = em.MessageDate.formatGMT('yyyy-MM-dd HH:mm:ss');
                            String siemensMessage = 'Zscaler :'+timeStamp +'-'+em.FromName + ' : ' +em.TextBody.stripHtmlTags();
                            if(cs.status == 'Closed'){
                                csInst.Detailed_Solution_Description__c = siemensMessage;
                                csInst.is_Detailed_Solution_Description_Changed__c = true;
                                csInst.Assignment_Group__c = cs.Product_New__c == 'ZIA' ? System.label.ZIA_Assignment_Group_Siemens : System.label.Siemens_Assignment_Group;
                                csInst.Patch_Source__c = 'Resolved';
                                //Added by Anup - CR#4177 - Start
                                if(cs.Product_New__c == 'ZIA'){
                                    csInst.Ticket_Status__c = 'Open';
                                    csInst.Internal_Work_Notes__c = siemensMessage;
                                    csInst.IS_Work_Notes_Changed__c = true;
                                }
                                csInst.Resolution_Code__c = 'Solved permanently';
                                //Added by Anup - CR#4177 - End
                                if(caseIdCaseIntComplaintIDMap.containskey(cs.id)){
                                    List<Id> complaintIDs = caseIdCaseIntComplaintIDMap.get(cs.id);
                                    caseIntegartionRecordUpdate.addALL(CaseIntegrationHandler.prepareCaseComplaintRecordsSiemens(complaintIDs,csInst.Patch_Source__c,siemensMessage));
                                }
                                
                            }else if(cs.status == 'Pending Customer'){
                                csInst.Internal_Work_Notes__c = siemensMessage;
                                csInst.IS_Work_Notes_Changed__c = true;
                                csInst.Assignment_Group__c = cs.Product_New__c == 'ZIA' ? System.label.ZIA_Assignment_Group_Siemens : System.label.Siemens_Assignment_Group;
                                csInst.Patch_Source__c = 'Reassign';
                                
                                if(caseIdCaseIntComplaintIDMap.containskey(cs.id)){
                                    List<Id> complaintIDs = caseIdCaseIntComplaintIDMap.get(cs.id);
                                    caseIntegartionRecordUpdate.addALL(CaseIntegrationHandler.prepareCaseComplaintRecordsSiemens(complaintIDs,csInst.Patch_Source__c,siemensMessage));
                                }
                                
                                //Added by: Ankit Bhatnagar - IBA-1622 Starts
                                if(em.TextBody.containsIgnoreCase(System.Label.Siemens_Customer_Communication_Keyword)) {
                                    csInst.Customer_Communication__c = siemensMessage;
                                    csInst.Is_Customer_Communications_Changed__c = true;
                                    csInst.Assignment_Group__c = System.Label.Zscaler_Assignment_Group;
                                }
                                //Added by: Ankit Bhatnagar - IBA-1622 ends
                                
                            }else if(cs.status == 'Researching' || cs.status == 'Escalated to Engineering' ||
                                     cs.status == 'Awaiting Fix' || cs.status == 'Customer Callback Scheduled')
                            {
                                csInst.Internal_Work_Notes__c = siemensMessage;
                                csInst.IS_Work_Notes_Changed__c = true;
                                csInst.Ticket_Status__c = 'Open';
                                csInst.Patch_Source__c = 'Worknotes';
                            }
                        }
                    }
                    csInst.Status_Code__c = '0';
                    csInst.Integration_Status__c = 'Not Started';
                    System.debug('--csInst--'+csInst);
                    caseIntegartionRecordUpdate.add(csInst);
                }
            }
            System.debug('--caseIntegartionRecordUpdate--'+caseIntegartionRecordUpdate);
            if(caseIntegartionRecordUpdate.size()>0){
                TriggerUtility.caseIntegartionExecutedSetTrue();
                update caseIntegartionRecordUpdate;
            }
        }
    }
    
    
    
    
    private static Case_Integration__c prepareCaseIntegartionRecordFromCaseSiemens(Case csObj, Case_Integration__c caseInt,
                                                                                   List<Generic_Field_Mapping__mdt> metaDataList)
    {
        List<Generic_Field_Mapping__mdt> siemnsMapping = new  List<Generic_Field_Mapping__mdt>();
        for(Generic_Field_Mapping__mdt mdt : metaDataList){
            if(mdt.Origin__c != null && mdt.Origin__c == 'Siemens'){
                siemnsMapping.add(mdt);
            }
        }
        System.debug('---siemnsMapping---'+siemnsMapping);                                                        
        return (Case_Integration__c)GenericFieldMappingController.prepareRecordFromGenericFieldMapping(csObj,caseInt,siemnsMapping);
    }
    
    public static void UpdatePriorOwnerofCase(List<Case> newList, Map<Id, Case> oldmap){
        Integer threshold = Integer.valueOf(Label.Case_Reassignment_Threshold);
        Map<Id,Case> mapOfCaseAndCaseDetail = new Map<Id, Case>();
        for(Case cs:newList){
            if(cs.RecordTypeId == caseSupportRT && cs.Ownerid != oldmap.get(cs.id).Ownerid){
                if(oldmap.get(cs.id).Ownerid != null && string.valueOf(oldmap.get(cs.id).Ownerid).startsWith('005') ){
                    cs.Prior_Owner__c=oldmap.get(cs.id).Ownerid;
                }
                cs.Case_Owner_Assigned_Date__c = System.now();
                
                //Case Handoff Project - Anup - Start
                if(cs.OwnerId!=null && String.valueOf(cs.OwnerId).startsWith('005') && !String.valueOf(oldmap.get(cs.id).Ownerid).startsWith('005') && cs.Original_Case_Assigned_Date_Time__c!=null){
                    Integer counter = 0;
                    if(cs.Reassignment_Counter__c==null){
                        counter = 0;
                    }
                    else{
                        counter = Integer.valueOf(cs.Reassignment_Counter__c);
                    }
                    counter += 1;
                    cs.Reassignment_Counter__c = counter;
                    //IBA-1334 - Adding condition to not send email for P1 cases
                    if((counter>=threshold) && cs.Priority != 'Urgent (P1)'){
                        mapOfCaseAndCaseDetail.put(cs.Id, cs);
                    }
                }
                //Case Handoff Project - Anup - End
            }
        }
        if(mapOfCaseAndCaseDetail != null && !mapOfCaseAndCaseDetail.isEmpty()){
            sendReassignmentThresholdEmail(mapOfCaseAndCaseDetail);
        }
    }
    
    public static void changeAccountofSupportCase(List<Case> newList, Map<Id, Case> oldmap){
        // Added by Gurjinder:Start
        List<Case> Caselist= new List<Case>();
        for(Case cs:newList){
            if(cs.RecordTypeId == caseSupportRT && cs.AccountId!=oldmap.get(cs.id).AccountId){
                Caselist.add(cs);
            }
        }
        if(!Caselist.isempty()){
            assignAccountforSupportCase(Caselist);  
        }
        // Added by Gurjinder:End
    }
    
    //Added by Gurjinder for update details on Master Case
    public static void UpdateDetailsonMasterCase(List<Case> newList, map<Id, case> oldmap){
        system.debug('inside UpdateDetailsonMasterCase method');
        List<Id> Caseidlist = new List<Id>();
        for(Case cs: newList){
            if(cs.Master_Case__c!=null && cs.Master_Case__c!=oldmap.get(cs.Id).Master_Case__c){
                Caseidlist.add(cs.Master_Case__c);
            }else if(cs.Master_Case__c==null && oldmap.get(cs.Id).Master_Case__c!=null){
                Caseidlist.add(oldmap.get(cs.Id).Master_Case__c);
            }
        }
        system.debug('Caseidlist   '+Caseidlist);
        if(Caseidlist.size()>0){
            UpdateMasterCaseKeyfields Qjob= new UpdateMasterCaseKeyfields(Caseidlist);
            System.enqueueJob(Qjob);
        }
        TriggerUtility.UpdateDetailsonMasterCaseExecuted();
    }
    
    public static void closeMilestonesonCaseClosure(List<Case> newList, map<Id, case> oldmap){
        Set<Id> caseIds = new Set<Id>();
        for(Case cs: newList){
            if(cs.RecordTypeId == caseSupportRT && cs.IsClosed && cs.IsClosed != oldmap.get(cs.Id).IsClosed){
                caseIds.add(cs.Id);
            }
        }
        TriggerUtility.CaseBeforeUpdateExecuted();
        TriggerUtility.CaseAfterUpdateExecuted();
        if(!caseIds.isEmpty()){
            MilestoneUtils.completeMilestone(caseIds, 'First Response', System.now());
            MilestoneUtils.completeMilestone(caseIds, 'Subsequent', System.now());
        }
        TriggerUtility.CloseMilestonesonCaseCloseExecuted();
    }
    
    public static void getFeedbackSurveyCreation(List<Case> newList, map<Id, case> oldmap){
        List<Survey__c> ticketList = new List<Survey__c>();
        //Added By Anup : CR#959 - Start
        List<String> domainsToExclude = new List<String>();
        domainsToExclude = fetchDomainsToExclude();
        //Added By Anup : CR#959 - End
        
        //Added By Anup : CR987 - Start
        List<Id> listOfuserId = new List<Id>();
        
        for(Case cs : newList){
            if(cs.RecordTypeId == caseSupportRT && cs.IsClosed && (cs.Case_Type__c == 'Problem' || cs.Case_Type__c == 'Question') && cs.IsClosed != oldmap.get(cs.Id).IsClosed){
                listOfuserId.add(cs.Case_Owner_Manager__c);
                listOfuserId.add(cs.OwnerId);
            }
        }
        Map<Id, User> mapOfUserDetails = new Map<Id, User>();
        if(!listOfuserId.isEmpty()){
            mapOfUserDetails = new Map<Id,user>([select id,managerId from user where id IN: listOfuserId]);
        }
        //Added By Anup : CR987 - Start
        
        for(Case cs: newList){
            if(cs.RecordTypeId == caseSupportRT && cs.IsClosed && (cs.Case_Type__c == 'Problem' || cs.Case_Type__c == 'Question') && cs.IsClosed != oldmap.get(cs.Id).IsClosed){
                ticketList.add(createSurvey(cs,domainsToExclude,mapOfUserDetails)); //Anup : Adding mapOfUserDetails parameter for CR987
            }
        }
        insert ticketList;
        TriggerUtility.GetFeedbackExecuted();
    }
    
    public static Survey__c createSurvey(Case ticket, List<String> listOfDomainsToExclude,Map<Id, User> mapOfUserDetails)
    {
        Id csatRTId = Schema.SObjectType.Survey__c.getRecordTypeInfosByDeveloperName().get('CSAT_Survey').getRecordTypeId();
        //Id dasRTId = Schema.SObjectType.Survey__c.getRecordTypeInfosByDeveloperName().get('DAS_Survey').getRecordTypeId();
        Survey__c ticketFeedback = new Survey__c();
        ticketFeedback.RecordTypeId = csatRTId;
        ticketFeedback.Case__c = ticket.Id;
        if(ticket.AccountId != null)
        {
            ticketFeedback.Account__c = ticket.AccountId;
        }
        if(ticket.ContactId != null)
        {
            ticketFeedback.Contact__c = ticket.ContactId;
        }
        ticketFeedback.Zendesk_Area__c = ticket.Case_Category__c;
        ticketFeedback.Zendesk_Sub_Area__c = ticket.Case_Sub_Category__c;
        String currEmail = ''; //Added By Anup : CR#959
        if(isSandbox())
        {
            ticketFeedback.Contact_Email__c = Label.surveySandboxEmail;
            currEmail = Label.surveySandboxEmail;  //Added By Anup : CR#959
        }
        else
        {
            ticketFeedback.Contact_Email__c = ticket.ContactEmail; 
            currEmail = ticket.ContactEmail; //Added By Anup : CR#959
        }
        //Added By Anup : CR#959 - Start
        if(checkEmailDomainsExclude(currEmail, listOfDomainsToExclude)){
            ticketFeedback.Contact_Email_Includes_Public_Domain__c = true;
            ticketFeedback.Survey_Status__c = 'Survey not Sent due to Public Domain';
        }
        //Added By Anup : CR#959 - End
        ticketFeedback.Contact_Name__c = ticket.Contact_Name__c;
        ticketFeedback.Ticket_Assignee__c = ticket.OwnerId;
        //ticketFeedback.Type__c = ticket.Integration_Type__c;
        //ticketFeedback.Ticket_Status__c = ticket.Integration_Status__c;
        ticketFeedback.Case_Owner_Manager__c = ticket.Case_Owner_Manager__c;
        //Added by Anup : CR987 - Start
        if(!mapOfUserDetails.isEmpty()){
            if(mapOfUserDetails.containsKey(ticket.Case_Owner_Manager__c) && mapOfUserDetails.get(ticket.Case_Owner_manager__c)!= null){
                ticketFeedback.Case_Owner_Manager_s_Manager__c = mapOfUserDetails.get(ticket.Case_Owner_manager__c).ManagerId;
            }
            if(mapOfUserDetails.containsKey(ticket.OwnerId)){
                ticketFeedback.Parent_Case_Owner__c = ticket.OwnerId;
            }
        }
        if(ticket.Account_Extension__c != null){
            ticketFeedback.Account_Extension__c = ticket.Account_Extension__c;
        }
        //Added by Anup : CR987 - End
        return ticketFeedback;
    }
    
    public static void convertIntegrationCasestoSupport(List<Case> newList){
        for(Case cs: newList){
            if(cs.case_source__c == 'Integration'){
                cs.RecordTypeId = caseSupportRT;
                // added by Swathi: CR#779 start
                if(cs.Case_Type__c == Null || cs.Case_Type__c == ''){
                    cs.Case_Type__c = 'Problem';
                }
                // added by Swathi: CR#779 end
            }
        }
    }
    
    public static void assignAccountforSupportCase(List<Case> newList){
        for(Case cs: newList){
            if(cs.RecordTypeId == caseSupportRT){
                cs.Account_of_Support_Case__c = cs.AccountId;
            }
        }
    }
    
    public static void escalateCase(List<Case> newList, map<Id, case> oldmap){
        Set<Id> accids = new Set<Id>();
        Set<Id> caseOwnerasAccTAMs = new Set<Id>();
        Set<Id> caseOwners = new Set<Id>();
        List<Case> supportcases = new List<Case>();
        Map<String, Primary_Secondary_Escalation_Support_Map__c> psesupportmap = Primary_Secondary_Escalation_Support_Map__c.getAll();
        //Added by Anup - Handoff Project - Start
        Map<String, Timezone_Region_Mapping__c> tacTimeRegionMap = Timezone_Region_Mapping__c.getAll();
        //Added by Anup - Handoff Project - End
        for(Case cs: newList){
            if(cs.RecordTypeId == caseSupportRT && cs.HandOff_Cases__c && cs.HandOff_Cases__c != oldmap.get(cs.Id).HandOff_Cases__c){
                supportcases.add(cs);
                caseOwners.add(cs.OwnerId);
                system.debug(caseOwners);
                accids.add(cs.AccountId);
            }
        }
        Map<Id, String> useridtolevelmap = new Map<Id, String>();
        for(User us: [Select Id, Skills__c from user where id in :caseOwners and Skills__c != null]){
            useridtolevelmap.put(us.Id, us.Skills__c);
        }
        
        //Added by Anup - CR#2195 - Start
        Set<Id> accountIdExcludedPartner = new Set<Id>();
        for(Account acc: [Select id, Exclude_Partner_Support__c from Account where Id in :accids]){
            accountIdExcludedPartner.add(acc.Id);
        }
        
        
        List<String> nonZpaProducts = new List<String>();
        if(String.isNotBlank(Label.Non_ZPA_Products)){
            nonZpaProducts = Label.Non_ZPA_Products.trim().split(',');
        }
        List<QueueSObject> queues = new List<QueueSObject>([SELECT id,QueueId FROM QueueSObject WHERE sObjectType = 'Case' AND Queue.DeveloperName='ZPA_Product_Queue']);
        String ZPAQueueId = !queues.isEmpty()?queues.get(0).queueId:'';
        
        //Added by Anup - CR#2195 - End
        for(case cs: supportcases){
            //Added by Ankit - CR# 4069 Start
            
            if(cs.Case_Type__c == 'Problem' || cs.Case_Type__c == 'Question') {
                
                //On Weekdays: Set Product Type on the basis of Case's Product
                if(cs.Product_New__c == 'ZPA') {
                    cs.Product_Type__c = 'ZPA';
                }
                else if(nonZpaProducts.contains(cs.Product_New__c)) {
                    cs.Product_Type__c = 'Non ZPA';
                }   
            }
            //}
            /*else {
cs.Product_Type__c = '';
}*/ 
            //Added by Ankit - CR# 4069 End
            cs.Priority_Support__c = 'Backline'; //Added by Anup - Omni Overhaul
            cs.Primary_Support__c = '';
            //cs.Secondary_Support__c = '';
            cs.Escalation_Support__c ='';
            //Added by Anup - Handoff Project - Start
            if(cs.Preferred_Contact_Time_Zone__c!= null && tacTimeRegionMap.containsKey(cs.Preferred_Contact_Time_Zone__c) && tacTimeRegionMap.get(cs.Preferred_Contact_Time_Zone__c)!=null && tacTimeRegionMap.get(cs.Preferred_Contact_Time_Zone__c).TAC_Region__c!=null){
                String tacRegion = tacTimeRegionMap.get(cs.Preferred_Contact_Time_Zone__c).TAC_Region__c;
                cs.Region_Support__c = tacRegion;
            }
            //Added by Anup - Handoff Project - End
            if(cs.Product_New__c == 'ZPA')
                cs.OwnerID = ZPAQueueId;
            else
                cs.OwnerId = Label.Support_Queue_Id;
            cs.Handed_Off_Case__c = false; //IBA-1316
            cs.Work_Item_Progress__c = 'In-Progress'; //IBA-2400 - Anup
        }
        TriggerUtility.skipCaseEscalationExecuted();
    }
    
    public static void assignStatusStartDate(List<Case> cslst){
        for(Case cs: cslst){
            if(cs.status != null && cs.recordtypeId == caseSupportRT){
                cs.Status_Start_Date__c = System.now();
                cs.Work_Item_Progress__c = 'In-Progress'; //IBA-2400 - Anup
            }
        }
    }
    
    public static void escalationHistoryCreation(List<Case> newList, map<Id, case> oldmap){
        List<Case> supportcases = new List<Case>();
        List<Case> casestoupdate = new List<Case>();
        Map<Id, Case_Escalation_History__c> mapcasetoescalation = new Map<Id, Case_Escalation_History__c>();
        for(Case cs: newList){
            //if(cs.RecordTypeId == caseSupportRT && cs.Escalation_Stage__c == 'Closed' && cs.Escalation_Stage__c != oldmap.get(cs.Id).Escalation_Stage__c){
            if(cs.RecordTypeId == caseSupportRT && cs.IsClosed && cs.IsClosed != oldmap.get(cs.Id).IsClosed){
                supportcases.add(cs);
            }
        }
        List<Case_Escalation_History__c> cehlst = new List<Case_Escalation_History__c>();
        List<Case_Notes_History__c> cnhlst = new List<Case_Notes_History__c>();
        for(Case cs: supportcases){
            case cstoupdate = new case(Id = cs.Id);
            
            Id ownerID = cs.OwnerId;
            
            Case_Escalation_History__c ceh = new Case_Escalation_History__c(Case__c = cs.Id);
            for (FieldSetMember fm: Schema.SObjectType.Case.fieldSets.getMap().get('Escalation_History_Creation').getFields()) {
                ceh.put(fm.getFieldPath(), cs.get(fm.getFieldPath()));
                //cstoupdate.put(fm.getFieldPath(), null);
            }
            if(cs.OwnerId.getSObjectType().getDescribe().getName() == 'User'){
                ceh.Case_Owner__c = cs.OwnerId;
            }
            ceh.Escalation_End_time__c = system.now();
            ceh.Escalation_Resolved_By__c = UserInfo.getUserId();
            cehlst.add(ceh);
            //cstoupdate.isEscalated = false;
            //cstoupdate.Escalation_on_behalf_of_Customer__c = false;
            cstoupdate.Escalation_End_time__c = system.now();
            cstoupdate.Escalation_Resolved_By__c = UserInfo.getUserId();
            casestoupdate.add(cstoupdate);
            if(!mapcasetoescalation.containskey(cs.Id)){
                mapcasetoescalation.put(cs.Id, ceh);
            }
        }
        insert cehlst;
        TriggerUtility.CaseBeforeUpdateExecuted();
        TriggerUtility.CaseAfterUpdateExecuted();
        update casestoupdate;
        
        for(Case_Notes_History__c cnh: [Select Id, Case__c, Case_Escalation_History__c from Case_Notes_History__c where Case__c in :mapcasetoescalation.keyset() and Case_Escalation_History__c = null]){
            if(cnh.Case__c != null && mapcasetoescalation.containsKey(cnh.Case__c) && mapcasetoescalation.get(cnh.Case__c) != null && mapcasetoescalation.get(cnh.Case__c).Id != null){
                cnh.Case_Escalation_History__c = mapcasetoescalation.get(cnh.Case__c).Id;
                cnhlst.add(cnh);
            }
        }
        update cnhlst;
        TriggerUtility.CaseEscalationHistoryExecuted();
    }
    
    public static void escalationNotesCreation(List<Case> newList, map<Id, case> oldmap){
        List<Case> supportcases = new List<Case>();
        List<Case> casestoupdate = new List<Case>();
        for(Case cs: newList){
            if(cs.RecordTypeId == caseSupportRT && cs.Escalation_Resolution_Notes__c != oldmap.get(cs.Id).Escalation_Resolution_Notes__c){
                supportcases.add(cs);
            }
        }
        List<Case_Notes_History__c> cnhlst = new List<Case_Notes_History__c>();
        for(Case cs: supportcases){
            case cstoupdate = new case(Id = cs.Id);
            Case_Notes_History__c cnh = new Case_Notes_History__c(Escalation_Stage__c = cs.Escalation_Stage__c, Escalation_Notes__c = cs.Escalation_Resolution_Notes__c, Case__c = cs.Id, Notes_Added_at__c = system.now(), Notes_Added_By__c=userinfo.getUserId(), Customer_Temperature__c = cs.Customer_Temperature__c,Escalation__c = cs.Escalation_Reason_New_n__c ); //Added By Anup- CR#1648 - Replacing Escalation_Reason_New__c with Escalation_Reason_New_n__c
            cnhlst.add(cnh);
            /*cstoupdate.Escalation_Resolution_Notes__c = null;
cstoupdate.Customer_Temperature__c = null;
cstoupdate.Escalation_Stage__c = null;
casestoupdate.add(cstoupdate);*/
        }
        insert cnhlst;
        TriggerUtility.CaseBeforeUpdateExecuted();
        TriggerUtility.CaseAfterUpdateExecuted();
        //update casestoupdate;
        TriggerUtility.CaseEscalationNotesExecuted();
    }
    
    public static void assignEntitlementtoCase(List<Case> newList){
        Map<Id, Case> csmap = new Map<Id, Case>();
        for(Case cs: newList){
            if(cs.RecordTypeId == caseSupportRT){
                csmap.put(cs.AccountId, cs);
            }
        }
        for(Entitlement ent: [Select Id, AccountId from Entitlement where accountid in :csmap.keySet() and EndDate = null and Status = 'Active']){
            if(ent.AccountId != null){
                csmap.get(ent.AccountId).EntitlementId = ent.Id;
            }
        }
        TriggerUtility.CaseEntitlementAssigned();
    }
    
    public static void caseStatusChangeManagement(List<Case> newList, map<Id, case> oldmap){
        Map<Id, Case> csmap = new Map<Id, Case>();
        Set<Id> caseIds = new Set<Id>();
        List<case> cstoupdate = new List<Case>();
        Map<String, Case_Status_and_SLA_Map__c> cssmap = Case_Status_and_SLA_Map__c.getAll();
        Set<Id> caseIdForStatusManage = new Set<Id>();
        for(Case cs: newList){
            if(cs.RecordTypeId == caseSupportRT && cs.Status != oldmap.get(cs.Id).Status){
                csmap.put(cs.AccountId, cs);
            }
            //IBA-2400 - Anup - Start
            if(cs.RecordTypeId == caseSupportRT && cs.Work_Item_Progress__c != oldMap.get(cs.Id).Work_Item_Progress__c && cs.Work_Item_Progress__c == 'Completed'){
                caseIdForStatusManage.add(cs.Id);
            }
            //IBA-2400 - Anup - End
        }
        List<Case_Stage_History__c> cshlst = new List<Case_Stage_History__c>();
        for(Case cs: csmap.values()){
            Case_Stage_History__c csh = new Case_Stage_History__c(Case__c = cs.Id);
            csh.Start_Date__c = oldmap.get(cs.Id).Status_Start_Date__c;
            csh.End_Date__c = System.now();
            csh.Modified_By__c = UserInfo.getUserId();
            csh.Case_Status__c = oldmap.get(cs.Id).Status;
            if(cs.SRT_Violated_Time__c >= csh.Start_Date__c  && cs.SRT_Violated_Time__c <= csh.End_Date__c){
                csh.Subsequent_Response_Breached__c = cs.Subsequent_Response_Breached__c;
                csh.SRT_Violated_Time__c = cs.SRT_Violated_Time__c;
            }
            if(cs.First_Response_Violated_Time__c >= csh.Start_Date__c  && cs.First_Response_Violated_Time__c <= csh.End_Date__c){
                csh.First_Response_Time_Violated__c = cs.First_Response_Time_Violated__c;
                csh.First_Response_Violated_Time__c = cs.First_Response_Violated_Time__c;
            }
            cshlst.add(csh);
            
            if(cs.Status == 'Closed'){
                csh = new Case_Stage_History__c(Case__c = cs.Id);
                csh.Start_Date__c = System.now();
                csh.End_Date__c = System.now();
                csh.Modified_By__c = UserInfo.getUserId();
                csh.Case_Status__c = cs.Status;
                cshlst.add(csh);
            }
            
            if(oldmap.get(cs.Id).Status != null && cssmap.containskey(oldmap.get(cs.Id).Status) && cssmap.get(oldmap.get(cs.Id).Status).SLA_Type__c == 'SRT'){
                caseIds.add(cs.Id);
            }
        }
        TriggerUtility.CaseBeforeUpdateExecuted();
        TriggerUtility.CaseAfterUpdateExecuted();
        insert cshlst;
        
        if(!caseIds.isEmpty()){
            MilestoneUtils.completeMilestone(caseIds, 'Subsequent', System.now());
        }
        //IBA-2400 - Anup - Start
        if(!caseIdForStatusManage.isEmpty()){
            MilestoneUtils.completeMilestone(caseIdForStatusManage, 'Ticket Assignment Timer', System.now());
        }
        //IBA-2400 - Anup - End
        TriggerUtility.CaseStatusHistoryExecuted();
    }
    public static void makeCaseDescriptiontoComment(List<Case> newList){
        Map<Id, Case> csmap = new Map<Id, Case>();
        Set<Id> caseIds = new Set<Id>();
        List<case> cstoupdate = new List<Case>();
        for(Case cs: newList){
            if((cs.RecordTypeId == caseSupportRT || cs.RecordTypeId == exp_projRT) && cs.Description != null){
                csmap.put(cs.Id, cs);
            }
        }
        List<FeedItem> cclst = new List<FeedItem>();
        for(Case cs: csmap.values()){
            FeedItem cc = new FeedItem(parentId = cs.Id);
            cc.Body = cs.Description;
            cc.Visibility = 'AllUsers';
            cc.IsRichText = true;
            cclst.add(cc);
        }
        
        TriggerUtility.CaseBeforeInsertExecuted();
        TriggerUtility.CaseAfterInsertExecuted();
        //TriggerUtility.CaseBeforeUpdateExecuted();
        TriggerUtility.skipCaseEscalationExecuted();
        TriggerUtility.UpdateTAMemailExecuted();
        TriggerUtility.UpdateSEonCaseExecuted();
        TriggerUtility.CaseAfterUpdateExecuted();
        TriggerUtility.SkipFeedItemTriggerExecuted();
        TriggerUtility.SkipCaseCommentTriggerExecuted();
        insert cclst;
        
        TriggerUtility.CaseDesctoCommentExecuted();
    }
    public static void createAgentWorkforTAM(List<Case> newList){
        Map<Id, Case> csmap = new Map<Id, Case>();
        Set<Id> caseIds = new Set<Id>();
        List<case> cstoupdate = new List<Case>();
        for(Case cs: newList){
            if(cs.RecordTypeId == caseSupportRT && cs.Case_Owner_is_TAM__c == true){
                csmap.put(cs.Id, cs);
            }
        }
        List<AgentWork> awlst = new List<AgentWork>();
        for(Case cs: csmap.values()){
            AgentWork work = new AgentWork();
            work.ServiceChannelId = Label.Case_Service_Channel_Id;
            work.WorkItemId = cs.Id;
            work.CapacityWeight = 1;
            work.UserId = cs.OwnerId;
            awlst.add(work);
        }
        if(!awlst.isEmpty()){
            try{
                insert awlst;
            }catch(Exception ex){
                
            }
        }
        TriggerUtility.TAMAgentWorkExecuted();
    }
    public static void assignNewStartDateforStatus(List<Case> newList, map<Id, case> oldmap){
        for(Case cs: newList){
            if(cs.RecordTypeId == caseSupportRT && cs.Status != oldmap.get(cs.Id).Status){
                cs.Status_Start_Date__c = system.now();
                cs.Manual_SLA_Timestamp__c = null;
            }
        }
    }
    public static void manualSLAChange(List<Case> newList, map<Id, case> oldmap){
        Map<Id, Case> csmap = new Map<Id, Case>();
        List<CaseMilestone> cmlst = new List<CaseMilestone>();
        for(Case cs: newList){
            if(cs.RecordTypeId == caseSupportRT && cs.Manual_SLA_Timestamp__c != oldmap.get(cs.Id).Manual_SLA_Timestamp__c){
                csmap.put(cs.Id, cs);
            }
        }
        for(CaseMilestone cm: [select Id, completionDate, Startdate, TargetDate, CaseId
                               from CaseMilestone cm
                               where caseId in :csmap.keyset() and cm.MilestoneType.Name='Subsequent' 
                               and completionDate = null]){
                                   Long diffinms = (cm.TargetDate.getTime() - cm.StartDate.getTime());
                                   Long diffinsec = diffinms/1000;
                                   Integer diffinmin = -1 * Integer.valueOf(diffinsec/60);
                                   cm.StartDate = csmap.containsKey(cm.CaseId) && csmap.get(cm.CaseId) != null && csmap.get(cm.CaseId).Manual_SLA_Timestamp__c != null && diffinmin != null? csmap.get(cm.CaseId).Manual_SLA_Timestamp__c.addminutes(diffinmin): cm.StartDate;
                                   cmlst.add(cm);
                               }
        TriggerUtility.CaseBeforeUpdateExecuted();
        TriggerUtility.CaseAfterUpdateExecuted();
        update cmlst;
        TriggerUtility.ManualSLAExecuted();
        
    }
    public static void assignCustomerScoreParameters(List<Case> newList){
        Map<Id, Case> csmap = new Map<Id, Case>();
        Map<String, Case_Priority_Score__c> cpsmap = Case_Priority_Score__c.getAll();
        Map<String, DEFCON_Case_Score__c> dccmap = DEFCON_Case_Score__c.getAll();
        for(Case cs: newList){
            if(cs.RecordTypeId == caseSupportRT){
                csmap.put(cs.Id, cs);
            }
        }
        for(Case cs: csmap.values()){
            if(cs.Priority != null){
                cs.Case_Priority_Score__c = cpsmap.containsKey(cs.Priority) ? cpsmap.get(cs.Priority).Score__c : cs.Case_Priority_Score__c;
            }
            if(cs.Defcon_Level__c != null){
                cs.DEFCON_Score__c = dccmap.containsKey(cs.Defcon_Level__c) ? dccmap.get(cs.Defcon_Level__c).Score__c : cs.DEFCON_Score__c;
            }
        }
        
    }
    
    public static Boolean isSandbox(){
        Boolean flag = true;
        
        Organization org = [Select IsSandbox,InstanceName from Organization];
        
        flag = org.IsSandbox;
        return flag;
    }
    public static void UpdateTAMemail(List<Case> Caselist){
        system.debug('inside UpdateTAMemail method');
        List<Id> listOfAccountExtensionId = new List<Id>();
        Map<Id, String> mapOfAccExtAndEmail = new Map<Id, String>();
        for(Case cs:Caselist){
            cs.X3rd_TAM_Email__c=cs.X3_TAM_Email__c;
            cs.Primary_TAM_Email__c=cs.Primary_TAM_Emailformula__c;
            cs.Secondary_TAM_Email__c=cs.Secondary_TAM_EmailFormula__c;
            //Added by Anup : CR#1701 - Start
            if(cs.Account_Extension__c != null){
                listOfAccountExtensionId.add(cs.Account_Extension__c);
            }
            //Added by Anup : CR#1701 - End
        }
        //Added by Anup : CR#1701 - Start
        if(!listOfAccountExtensionId.isEmpty()){
            for(Account_Extension__c accExt : [select id, X4th_TAM_Name__c, X4th_TAM_Name__r.Email from Account_Extension__c where Id IN:listOfAccountExtensionId and X4th_TAM_Name__c !=null]){
                if(!mapOfAccExtAndEmail.containsKey(accExt.Id) && accExt.X4th_TAM_Name__r.Email !=null){
                    mapOfAccExtAndEmail.put(accExt.Id, accExt.X4th_TAM_Name__r.Email);
                }
            }
            if(!mapOfAccExtAndEmail.isEmpty()){
                for(Case cs:CaseList){
                    if(mapOfAccExtAndEmail.containsKey(cs.Account_Extension__c)){
                        cs.X4th_TAM_Email__c = mapOfAccExtAndEmail.get(cs.Account_Extension__c);
                    }
                }  
            }
            
        }
        //Added by Anup : CR#1701 - End
        //TriggerUtility.UpdateTAMemailExecuted();
    }
    
    // Added by Gurjinder : CR# 125 :Start
    public static void UpdateSEonCase(List<Case> Caselist){
        system.debug('inside UpdateSEonCase method');
        for(Case cs:Caselist){
            system.debug('case before SE update'+cs);
            cs.Sales_Engineer__c=cs.Account_SE_id__c;
            system.debug('case after SE update'+cs);
        }
        TriggerUtility.UpdateSEonCaseExecuted();
    }
    // Added by Gurjinder : CR# 125 :End
    
    // CR# 180 : Abhishek : Short term fixes for CC List : Start
    public static void cctoCaseTeamafterUpdate(List<Case> newlist, Map<Id, Case> oldmap){
        List<Case> cslst = new List<Case>();
        for(Case cs: newlist){
            if(cs.RecordTypeId == caseSupportRT && (cs.Internal_cc_List__c != oldmap.get(cs.Id).Internal_cc_List__c || cs.Customer_CC_List__c != oldmap.get(cs.Id).Customer_CC_List__c)){
                cslst.add(cs);
            }
        }
        createCaseTeam(cslst);
    }
    
    public static void cctoCaseTeamafterInsert(List<Case> newlist){
        List<Case> cslst = new List<Case>();
        for(Case cs: newlist){
            if(cs.RecordTypeId == caseSupportRT && (cs.Internal_cc_List__c != null || cs.Customer_CC_List__c != null)){
                cslst.add(cs);
            }
        }
        createCaseTeam(cslst);
    }
    
    //CR# 251 replicate Original TAM information into Case during creation
    public static void fillTAMDetails(List<Case> caseLists){
        Set<Id> AccountId = new Set<Id>();
        for(Case c: caseLists){
            AccountId.add(c.AccountId);
        }
        MAP<ID,Account> accMap = new MAP<ID,Account>([Select id,name,TAM_Name_New__c,Secondary_TAM_Name__c,X3rd_TAM_Name__c from account where id in :AccountId]);
        for(Case c: caseLists){
            if(accMap.containskey(c.accountid) && accMap.get(c.accountid) != null ){
                account acc = accMap.get(c.accountid);
                c.Original_Primary_TAM__c = acc.TAM_Name_New__c;
                c.Original_Secondary_TAM__c = acc.Secondary_TAM_Name__c;
                c.Original_Third_TAM__c = acc.X3rd_TAM_Name__c;
            }
        }
        TriggerUtility.UpdateOriginalTAMexecuted();
    }
    
    //Added by Swathi: CR1008 Start
    public static void UpdateCSMonCase(List<Case> caseLists){
        Set<Id> AccountId = new Set<Id>();
        for(Case c: caseLists){
            AccountId.add(c.AccountId);
        }
        MAP<ID,Account> accMap = new MAP<ID,Account>([Select id,name,CSM_Name_New__r.Email from account where id in :AccountId]);
        for(Case c: caseLists){
            if(accMap.containskey(c.accountid) && accMap.get(c.accountid) != null ){
                account acc = accMap.get(c.accountid);
                c.CSM_Email__c = acc.CSM_Name_New__r.Email;
            }
        }
        TriggerUtility.UpdateCSMonCaseExecuted();
    }
    //Added by Swathi: CR1008 End
    
    public static void createCaseTeam(List<Case> cslst){
        Map<Id, Set<Id>> mapCstoCaseTeamMemberId = new Map<Id, Set<Id>>();
        if(!cslst.isEmpty()){
            Map<String, Id> teamroletoIdmap = new Map<String, Id>();
            for(CaseTeamRole ctr: [SELECT Id,Name FROM CaseTeamRole WHERE Name in ('Customer', 'Internal Agent')]){
                teamroletoIdmap.put(ctr.Name, ctr.Id);
            }
            for(CaseTeamMember csteam : [Select Id, parentId, MemberId from CaseTeamMember where ParentId in :cslst]){
                if(!mapCstoCaseTeamMemberId.isEmpty()){
                    Set<Id> memberIds = mapCstoCaseTeamMemberId.get(csteam.parentId);
                    memberIds.add(csteam.MemberId);
                    mapCstoCaseTeamMemberId.put(csteam.parentId, memberIds);
                }else{
                    mapCstoCaseTeamMemberId.put(csteam.parentId, new Set<Id>{csteam.MemberId});
                }
            }
            
            Map<Id, Set<String>> mapCasetoInternal = new Map<Id, Set<String>>();
            Map<Id, Set<String>> mapCasetoExternal = new Map<Id, Set<String>>();
            Set<String> internalEmails = new Set<String>();
            Set<String> externalEmails = new Set<String>();
            //Added by Anup - CR# 4578 - Start
            Set<String> setOfDomain = new Set<String>();  
            Map<String, ID> setOfDomainAndAccount = new Map<String, ID>();
            //Added by Anup - CR# 4578 - End  
            for(Case cs: cslst){
                Set<String> intsetofcase = new Set<String>();
                Set<String> extsetofcase = new Set<String>();
                if(cs.Internal_CC_List__c != null){
                    for(String s: cs.Internal_CC_List__c.split(';')){
                        if(s != '' && s!= null){
                            internalEmails.add(s.trim().toLowerCase());
                            intsetofcase.add(s.trim().toLowerCase());
                        }
                    }
                }
                if(cs.Customer_CC_List__c != null){
                    for(String s: cs.Customer_CC_List__c.split(';')){
                        if(s != '' && s!= null){
                            externalEmails.add(s.trim().toLowerCase());
                            extsetofcase.add(s.trim().toLowerCase());
                            List<String> splittedEmail = s.split('@');
                            if(splittedEmail.size() >=2){
                                setOfDomain.add(splittedEmail[1]);
                            }
                        }
                    }
                }
                mapCasetoInternal.put(cs.Id, intsetofcase);
                mapCasetoExternal.put(cs.Id, extsetofcase);
            }
            
            Map<String, Id> mapEmailtoId = new Map<String, Id>();
            if(!internalEmails.isEmpty()){
                List<Id> teamemails = new List<Id>();
                for(Set<Id> s: mapCstoCaseTeamMemberId.values()){
                    list<Id> strlst = new list<Id>(s);
                    teamemails.addAll(strlst);
                }
                for(User us: [Select Id, email from User where email in :internalEmails and isActive = true and Profile.Name not in ('Zscaler Partner Community User','Customer Community User Profile')]){
                    if(!mapEmailtoId.containskey(us.email) || (teamemails != null && !teamemails.isEmpty() && teamemails.contains(us.Id))){
                        mapEmailtoId.put(us.email, us.Id);
                    }
                }
            }
            if(!externalEmails.isEmpty()){
                List<Id> teamemails = new List<Id>();
                for(Set<Id> s: mapCstoCaseTeamMemberId.values()){
                    list<Id> strlst = new list<Id>(s);
                    teamemails.addAll(strlst);
                }
                for(Contact con: [Select Id, email from Contact where email in :externalEmails]){
                    if(!mapEmailtoId.containskey(con.email) || (teamemails != null && !teamemails.isEmpty() && teamemails.contains(con.Id))){
                        mapEmailtoId.put(con.email, con.Id);
                    }
                }
            }
            //Added by Anup - CR# 4578 - Start
            if(!setOfDomain.isEmpty()){
                for(Account acc : [select id, Domain__c, Additional_Organization_Domains__c from Account where Domain__c IN:setOfDomain and Domain__c!=null]){
                    setOfDomainAndAccount.put(acc.Domain__c, acc.Id);
                    if(!String.isBlank(acc.Additional_Organization_Domains__c)){
                        for(String adddomain: acc.Additional_Organization_Domains__c.split(',')){
                            String accdomain = adddomain.trim().remove('https://www.').remove('http://www.').remove('https://').remove('http://');
                            if(!String.isBlank(accdomain)){
                                setOfDomainAndAccount.put(accdomain, acc.Id);    
                            }
                        }
                    }
                }
            }
            //Added by Anup - CR# 4578 - End
            List<CaseTeamMember> ctmlst = new List<CaseTeamMember>();
            Map<String, Contact> conEmailtoContact =  new Map<String, Contact>();
            Map<String, CaseTeamMember> conEmailtoCTM =  new Map<String, CaseTeamMember>();
            for(Id csid : mapCasetoInternal.keySet()){
                Set<Id> existingCaseTeamIds = mapCstoCaseTeamMemberId.containsKey(csid) ? mapCstoCaseTeamMemberId.get(csId) : new Set<Id>();
                for(String s: mapCasetoInternal.get(csid)){
                    if(s != '' && s != null && mapEmailtoId.containsKey(s.toLowerCase())){
                        String userId = mapEmailtoId.get(s.toLowerCase());
                        if(!existingCaseTeamIds.contains(userId)){
                            CaseTeamMember ctm = new CaseTeamMember();
                            ctm.MemberId = userId;
                            ctm.ParentId = csid;
                            ctm.TeamRoleId = teamroletoIdmap.containsKey('Internal Agent') ? teamroletoIdmap.get('Internal Agent') : null;
                            ctmlst.add(ctm);
                        }
                    }
                }
            }
            for(Id csid : mapCasetoExternal.keySet()){
                Set<Id> existingCaseTeamIds = mapCstoCaseTeamMemberId.containsKey(csid) ? mapCstoCaseTeamMemberId.get(csId) : new Set<Id>();
                for(String s: mapCasetoExternal.get(csid)){
                    if(s != '' && s != null){
                        if(mapEmailtoId.containsKey(s.toLowerCase())){
                            String conId = mapEmailtoId.get(s.toLowerCase());
                            if(!existingCaseTeamIds.contains(conId)){
                                CaseTeamMember ctm = new CaseTeamMember();
                                ctm.MemberId = conId;
                                ctm.ParentId = csid;
                                ctm.TeamRoleId = teamroletoIdmap.containsKey('Customer') ? teamroletoIdmap.get('Customer') : null;
                                ctmlst.add(ctm);
                            }
                        }else{
                            //Added by Anup - CR# 4578 - Start
                            List<String> splittedEmail1 = s.split('@');
                            String accountIdToPatch = label.Account_of_CC_Contact;
                            if(!splittedEmail1.isEmpty() && splittedEmail1.size() >=2 && !setOfDomainAndAccount.isEmpty() && setOfDomainAndAccount.containsKey(splittedEmail1[1]) && setOfDomainAndAccount.get(splittedEmail1[1])!=null){
                                accountIdToPatch = setOfDomainAndAccount.get(splittedEmail1[1]);
                            }
                            //Added by Anup - CR# 4578 - End
                            conEmailtoContact.put(s, new contact(email=s, lastname=s, accountid=accountIdToPatch,Contact_Type__c='Support'));
                            CaseTeamMember ctm = new CaseTeamMember();
                            ctm.ParentId = csid;
                            ctm.TeamRoleId = teamroletoIdmap.containsKey('Customer') ? teamroletoIdmap.get('Customer') : null;
                            conEmailtoCTM.put(s, ctm);
                        }
                    }
                }
            }
            if(!conEmailtoContact.isEmpty()){
                ContactTriggerHelper.skipTrigger = true;
                TriggerUtility.realignPatch();
                database.insert(conEmailtoContact.values(), false);
            }
            if(!conEmailtoCTM.isEmpty()){
                for(String s: conEmailtoCTM.keyset()){
                    if(s != null && s != '' && conEmailtoCTM.get(s) != null && conEmailtoContact.containsKey(s)){
                        conEmailtoCTM.get(s).MemberId = conEmailtoContact.get(s).Id;
                    }
                }
                ctmlst.addAll(conEmailtoCTM.values());
            }
            if(!ctmlst.isEmpty()){
                Database.insert(ctmlst, false);
            }
        }
    }
    // CR# 180 : Abhishek : Short term fixes for CC List : Start
    public static void updateTAMWeeklyDateTime(List<Case> lstCases,Map<Id,Case> mapOldCases)  {
        Set<String> setAcountId = new Set<String> ();
        Id typeId = System.Label.CaseRT_Weekly_Meeting ; //[select Id,Name from RecordType where sObjectType='Case' AND DeveloperName = 'Weekly_Meeting'].Id;
        Map<Id,DateTIme> mapCloseDateTime = new Map<Id,DateTime>();
        for (Case  c: lstCases){
            //System.debug(mapOldCases.get(c.Id).closedDate);
            if((c.AccountId != null && c.recordTypeID == typeId && c.closedDate != null && (mapOldCases == null || mapOldCases.get(c.Id).closedDate == null)) || Test.isRunningTest()){
                System.debug('I am in');
                setAcountId.add(c.AccountId);  
                mapCloseDateTime.put(c.AccountId,C.ClosedDate);
            }     
        }
        
        if(setAcountId.size() > 0){
            List<Account_Extension__c> lstaccEx = [select id, name,Account__c, TAM_Weekly_DateTime__c from Account_Extension__c where Account__c in :setAcountId];
            for(Account_Extension__c ae : lstaccEx)  {
                // Added IF Condition by Rajesh : CR# 1229 : Start
                if(ae.TAM_Weekly_DateTime__c < mapCloseDateTime.get(ae.Account__c)){
                    ae.TAM_Weekly_DateTime__c = mapCloseDateTime.get(ae.Account__c);
                }
                // Added IF Condition by Rajesh : CR# 1229 : End
            }
            if(lstaccEx.size() > 0)  {
                update lstaccEx;  
            }
        }
    }
    
    public static void updateExtentison(List<Case> lstCases, Map<Id,Case> mapOldEmails)  {
        Map<Id, Id> extMap = new Map<Id, Id>();
        List<String> extIdSet = new List<String>();
        for(Case c : lstCases){
            if(mapOldEmails == null || (mapOldEmails.get(c.Id).AccountId != c.AccountId))  {
                extIdSet.add(c.AccountId);
            }
        }
        
        if(extIdSet.size() > 0)  {
            List<Account_Extension__c> accExList = new List<Account_Extension__c>();
            for(Account_Extension__c ae :  [select Id, Account__c from Account_Extension__c where Account__c IN :extIdSet])  {
                extMap.put(ae.Account__c, ae.id);
                
            }
            
            for(Case cs : lstCases){
                if(mapOldEmails == null || (mapOldEmails.get(cs.Id).AccountId != cs.AccountId))  {
                    cs.Account_Extension__c = extMap.get(cs.accountId);
                }    
            }
        }    
    }
    
    //Added By Anup : CR#959 - Start
    public static List<String> fetchDomainsToExclude(){
        Map<String, Email_Domains_to_Exclude__c> emailDomainMaps = Email_Domains_to_Exclude__c.getAll();
        List<String> domainsToExcludeData = new List<String>(emailDomainMaps.keySet());
        Internal_Domains_Exclusion__c internalDomainsToExclude = Internal_Domains_Exclusion__c.getOrgDefaults();
        if(internalDomainsToExclude.Domains__c != null && internalDomainsToExclude.Domains__c != ''){
            String domains = internalDomainsToExclude.Domains__c;
            List<String> listOfDomains = domains.split(',');
            domainsToExcludeData.addAll(listOfDomains);
        }
        return domainsToExcludeData;
    }
    
    public static boolean checkEmailDomainsExclude(String currEmail, List<String> listOfDomainsToExclude) {  
        String domain='';
        if(!String.isBlank(currEmail)){
            List<String> splittedEmail = currEmail.split('@');
            domain = splittedEmail[1];
        }
        
        if(!listOfDomainsToExclude.isEmpty() && !String.isBlank(domain)){
            if(listOfDomainsToExclude.contains(domain)){
                return true;
            }else{
                return false;            
            }
        }else{
            return false;
        }
    }
    //Added By Anup : CR#959 - End
    
    public static void createTAMNotesHistory(List<Case> newList, map<Id, Case> oldmap){
        List<TAM_Meeting_History__c> tamhistlst = new List<TAM_Meeting_History__c>();
        for(Case ap: newList){
            for (FieldSetMember fm: Schema.SObjectType.Case.fieldSets.getMap().get('Case_TAM_Meeting_History_Set').getFields()) {
                TAM_Meeting_History__c tamhist = new TAM_Meeting_History__c(Case__c = ap.Id);
                tamhist.Old_Value__c = oldmap != null && oldmap.get(ap.Id) != null ? String.valueOf(oldmap.get(ap.Id).get(fm.getFieldPath())) : null;
                tamhist.New_Value__c = String.valueOf(ap.get(fm.getFieldPath()));
                tamhist.Field_Modified__c = fm.getLabel();
                tamhist.Field_Modified_API__c = fm.getFieldPath();
                tamhist.Modified_at__c = system.now();
                tamhist.Modified_By__c = UserInfo.getUserId();
                if(tamhist.Old_Value__c != tamhist.New_Value__c){
                    tamhistlst.add(tamhist);
                }
            }
        }
        insert tamhistlst;
        TriggerUtility.CaseTAMNotesHistoryExecuted();
    }
    //CR# DSAT Closed Loop Process
    public static void CheckActionPlanIsCloseForCase(List<Case> lstCases, Map<Id,Case> mapOldEmails){
        Set<Id> caseIdList = new Set<Id>();
        for(Case caseObj : lstCases){
            if(((mapOldEmails == null) || (mapOldEmails != null && caseObj.Status != mapOldEmails.get(caseObj.id).Status)) && (caseObj.Status == 'Closed' || caseObj.Status == 'Closed - Resolved' || caseObj.Status == 'Closed - No Action' || caseObj.Status == 'Closed - Duplicate')){
                
                caseIdList.add(caseObj.Id);
            }
        }
        List<Action_Plan__c> ActionPlanList = [select Id,Case__c from Action_Plan__c where Case__c IN : caseIdList AND (Status__c != 'Completed' and Status__c != 'Closed' and Status__c != 'Cancelled' ) and Case__r.recordType.Developername = 'DSAT_Ticket' ];
        if(ActionPlanList.size() > 0){
            for(Case caseobj : lstCases){
                caseObj.addError(Label.Message_Case_Close_Action_Plan_NotCompleted);
                
            }
        }
        TriggerUtility.caseCloseCompleteActionPlanSetTrue();
    }
    
    //Added by Swathi : CR1408 start
    public static void UpdateCustomerScroceCard(List<Case> newList, Map<Id, Case> oldmap){
        System.debug('UpdateCustomerScroceCard '+newList);
        Set<ID> newCaselist = new Set<ID>();
        for(Case cs:newList){
            if((oldmap == null) || (oldmap != null && (cs.Priority != oldmap.get(cs.id).Priority || cs.Escalated__c != oldmap.get(cs.id).Escalated__c))){
                newCaselist.add(cs.AccountID);
            }
        }
        system.debug('newCaselist '+newCaselist);
        List<Customer_Score_Card__c> customerCard = new List<Customer_Score_Card__c>();
        Decimal CountofopenP1sc=0;
        Decimal CountofopenP2sc=0;
        Decimal CountofopenP3P4sc=0;
        Decimal CountofopenDefcon=0;
        Datetime mostRecent;
        Boolean Trackvalue = False;
        if(!newCaselist.isEmpty()){
            for(Case cs:[Select id,Account_Name__c,Priority,Status,IsEscalated,CreatedDate FROM Case WHERE AccountID In:newCaselist and (Case_Type__c = 'Problem' OR Case_Type__c = 'Question' OR Case_Type__c = 'Categorisation') and Status != 'Closed' ORDER BY CreatedDate]){
                if(cs.Priority == 'Urgent (P1)'){
                    CountofopenP1sc = CountofopenP1sc+1;
                }
                if(cs.Priority == 'High (P2)'){
                    CountofopenP2sc = CountofopenP2sc+1;
                }
                if((cs.Priority == 'Medium (P3)' || cs.Priority == 'Low (P4)')){
                    CountofopenP3P4sc = CountofopenP3P4sc+1;
                }
                if(cs.IsEscalated == True){
                    CountofopenDefcon = CountofopenDefcon+1;
                }
                if(mostRecent==null || cs.CreatedDate < mostRecent) {
                    mostRecent = cs.CreatedDate;
                }
                //mostRecent = cs.CreatedDate.format('yyyy-MM-dd');
            }
            
            System.debug('CountofopenP1sc '+CountofopenP1sc);
            for(Customer_Score_Card__c csm : [Select Count_of_open_P1s__c,Count_of_open_P2s__c,Count_of_open_Defcon_tickets__c,Count_of_open_P3_P4s__c,DateoflastExecmeeting__c from Customer_Score_Card__c where Account__c In:newCaselist]){
                if(CountofopenP1sc != csm.Count_of_open_P1s__c){
                    csm.Count_of_open_P1s__c=CountofopenP1sc;
                    Trackvalue = True;
                }
                if(CountofopenP2sc != csm.Count_of_open_P2s__c){
                    csm.Count_of_open_P2s__c=CountofopenP2sc;
                    Trackvalue = True;
                }
                if(CountofopenP3P4sc != csm.Count_of_open_P3_P4s__c){
                    csm.Count_of_open_P3_P4s__c=CountofopenP3P4sc;
                    Trackvalue = True;
                }
                if(CountofopenDefcon != csm.Count_of_open_Defcon_tickets__c){
                    csm.Count_of_open_Defcon_tickets__c=CountofopenDefcon;
                    Trackvalue = True;
                }
                if(mostRecent != csm.DateoflastExecmeeting__c){
                    csm.DateoflastExecmeeting__c=mostRecent;
                    Trackvalue = True;
                }
                if(Trackvalue){         
                    customerCard.add(csm);
                }
            }
            system.debug('customerCard '+customerCard);
            if(!customerCard.isEmpty()){
                update(customerCard);
            }
        }
        TriggerUtility2.UpdateCustomerScroceCardValueExecuted();
    } 
    //Added by Swathi : CR1408 end
    //Added by Chetan : CR2268 start
    public static void createContactUnderAccount(list<Case>newList)
    {
        map<string,Case> mapDomainCase=new map<string,Case>();
        list<Case> newCaseList=new list<Case>();
        Set<String> setOfDomainPresent = new Set<String>();
        
        
        for(Case cs:newList)
        {
            if (cs.ContactId==null && cs.Origin=='Sitereview' && cs.Case_Type__c=='Categorization' && cs.Priority=='Low (P4)')
            {
                newCaseList.add(cs);
                String caseDomain='';     
                List<String> splittedEmail = cs.Case_Created_By_Email__c.split('@');
                caseDomain = splittedEmail[1];
                mapDomainCase.put(caseDomain,cs);
            }
        }
        if(!mapDomainCase.isEmpty())
        {
            for (Account Acc:[select Name,Domain__c from Account where Domain__c in :mapDomainCase.keyset()])
            {
                setOfDomainPresent.add(acc.Domain__c);                                       
                Case currentCase = mapDomainCase.get(Acc.Domain__c); 
                currentCase.AccountId = Acc.Id;
            }   
            for(String domain : mapDomainCase.keyset())
            {
                if(!setOfDomainPresent.contains(domain))
                {
                    Case currentCase = mapDomainCase.get(domain);
                    if (!Test.isRunningTest())
                    {
                        currentCase.AccountId = Label.Sitereview_default;
                    }
                }
            }     
        }       
    }
    
    //Added by Chetan : CR2268 end        
    
    /**
* Added by : Ankit Bhatnagar
* CR #     : 2750
* Start
*/
    public static void setRequestType (list<Case>newList){
        if(!newList.isEmpty()) {
            //Query Custom metadata Type - Request Type Config
            Map<String, Case_Request_Type_Configurations__mdt> rtConfigMap = new Map<String, Case_Request_Type_Configurations__mdt>();
            
            for (Case_Request_Type_Configurations__mdt rtConfig : [ SELECT MasterLabel, DeveloperName, Current_URL_Category__c ,Suggested_URL_Category__c 
                                                                   FROM Case_Request_Type_Configurations__mdt]) {
                                                                       rtConfigMap.put(rtConfig.MasterLabel, rtConfig);
                                                                   }
            
            for(Case c : newList) {
                //Case is created from Site Review Integration
                if(c.origin == 'Sitereview' && c.case_Type__c=='Categorization' && c.priority=='Low (P4)')  {
                    //Added by Chetan CR 3113 Start
                    setURLFromDescription(c);
                    //Added by Chetan CR 3113 Start
                    //Suggested_Category__c
                    //Current_Category__c
                    Set<String> caseCurrCatSet = new Set<String>();
                    Set<String> caseSuggCatSet = new Set<String>();
                    
                    if(String.isNotBlank(c.Current_Category__c)) {
                        if(c.Current_Category__c.split(',').size() > 0) {
                            caseCurrCatSet = new Set<String>(c.Current_Category__c.split(','));
                        }
                    }
                    if(String.isNotBlank(c.Suggested_Category__c)) {
                        if(c.Suggested_Category__c.split(',').size() > 0) {
                            caseSuggCatSet = new Set<String>(c.Suggested_Category__c.split(','));
                        }
                    }
                    
                    Set<String> urlCat_CurrCatSet = new Set<String>();
                    Set<String> urlCat_SuggCatSet = new Set<String>();
                    Set<String> urlReCat_CurrCatSet = new Set<String>();
                    Set<String> urlReCat_SuggCatSet = new Set<String>();
                    Set<String> secRevAddBlock_CurrCatSet = new Set<String>();
                    Set<String> secRevAddBlock_SuggCatSet = new Set<String>();
                    Set<String> secRevLiftBlock_CurrCatSet = new Set<String>();
                    Set<String> secRevLiftBlock_SuggCatSet = new Set<String>();
                    
                    if(rtConfigMap.containsKey('URL Categorization')) {
                        if(String.isNotBlank(rtConfigMap.get('URL Categorization').current_URL_Category__c)) {
                            urlCat_CurrCatSet = new Set<String>(rtConfigMap.get('URL Categorization').current_URL_Category__c.split(','));
                        }
                        if(String.isNotBlank(rtConfigMap.get('URL Categorization').suggested_URL_Category__c)) {
                            urlCat_SuggCatSet = new Set<String>(rtConfigMap.get('URL Categorization').suggested_URL_Category__c.split(','));
                        }
                    }
                    if(rtConfigMap.containsKey('URL Re-categorization')) {
                        if(String.isNotBlank(rtConfigMap.get('URL Re-categorization').current_URL_Category__c)) {
                            urlReCat_CurrCatSet = new Set<String>(rtConfigMap.get('URL Re-categorization').current_URL_Category__c.split(','));
                        }
                        if(String.isNotBlank(rtConfigMap.get('URL Re-categorization').suggested_URL_Category__c)) {
                            urlReCat_SuggCatSet = new Set<String>(rtConfigMap.get('URL Re-categorization').suggested_URL_Category__c.split(','));
                        }
                    }
                    if(rtConfigMap.containsKey('Security Review Add Block')) {
                        if(String.isNotBlank(rtConfigMap.get('Security Review Add Block').current_URL_Category__c)) {
                            secRevAddBlock_CurrCatSet = new Set<String>(rtConfigMap.get('Security Review Add Block').current_URL_Category__c.split(','));
                        }
                        if(String.isNotBlank(rtConfigMap.get('Security Review Add Block').suggested_URL_Category__c)) {
                            secRevAddBlock_SuggCatSet = new Set<String>(rtConfigMap.get('Security Review Add Block').suggested_URL_Category__c.split(','));
                        }
                    }
                    if(rtConfigMap.containsKey('Security Review Lift Block')) {
                        if(String.isNotBlank(rtConfigMap.get('Security Review Lift Block').current_URL_Category__c)) {
                            secRevLiftBlock_CurrCatSet = new Set<String>(rtConfigMap.get('Security Review Lift Block').current_URL_Category__c.split(','));
                        }
                        if(String.isNotBlank(rtConfigMap.get('Security Review Lift Block').suggested_URL_Category__c)) {
                            secRevLiftBlock_SuggCatSet = new Set<String>(rtConfigMap.get('Security Review Lift Block').suggested_URL_Category__c.split(','));
                        }
                    }
                    
                    Boolean urlCat_CurrCondition = false;
                    Boolean urlCat_SuggCondition = false;
                    Boolean urlReCat_CurrCondition = false;
                    Boolean urlReCat_SuggCondition = false;
                    Boolean secRevAddBlock_CurrCondition = false;
                    Boolean secRevAddBlock_SuggCondition = false;
                    Boolean secRevLiftBlock_CurrCondition = false;
                    Boolean secRevLiftBlock_SuggCondition = false;
                    
                    //Loop over Case Current Categories
                    if(!caseCurrCatSet.isEmpty()) {
                        for(String currCat : caseCurrCatSet) {
                            if(!urlCat_CurrCatSet.isEmpty() && urlCat_CurrCatSet.contains(currCat)) {
                                urlCat_CurrCondition = true;
                            }
                            if(!urlReCat_CurrCatSet.isEmpty() && !urlReCat_CurrCatSet.contains(currCat)) {
                                urlReCat_CurrCondition = true;
                            }
                            if(!secRevAddBlock_CurrCatSet.isEmpty() && secRevAddBlock_CurrCatSet.contains(currCat)) {
                                secRevAddBlock_CurrCondition = true;
                            }
                            if(!secRevLiftBlock_CurrCatSet.isEmpty() && secRevLiftBlock_CurrCatSet.contains(currCat)) {
                                secRevLiftBlock_CurrCondition = true;
                            }
                        }
                    }
                    
                    //Loop over Case Suggested Categories
                    if(!caseSuggCatSet.isEmpty()) {
                        for(String suggCat : caseSuggCatSet) {
                            if(!urlCat_SuggCatSet.isEmpty() && !urlCat_SuggCatSet.contains(suggCat)) {
                                urlCat_SuggCondition = true;
                            }
                            if(!urlReCat_SuggCatSet.isEmpty() && !urlReCat_SuggCatSet.contains(suggCat)) {
                                urlReCat_SuggCondition = true;
                            }
                            if(!secRevAddBlock_SuggCatSet.isEmpty() && secRevAddBlock_SuggCatSet.contains(suggCat)) {
                                secRevAddBlock_SuggCondition = true;
                            }
                            if(!secRevLiftBlock_SuggCatSet.isEmpty() && !secRevLiftBlock_SuggCatSet.contains(suggCat)) {
                                secRevLiftBlock_SuggCondition = true;
                            }
                        }
                    }
                    
                    if(urlCat_CurrCondition && urlCat_SuggCondition)
                        c.Request_Type__c = 'URL Categorization';
                    if(urlReCat_CurrCondition && urlReCat_SuggCondition) 
                        c.Request_Type__c = 'URL Re-categorization';
                    if(secRevAddBlock_CurrCondition && secRevAddBlock_SuggCondition) 
                        c.Request_Type__c = 'Security Review Add Block';
                    if(secRevLiftBlock_CurrCondition && secRevLiftBlock_SuggCondition) 
                        c.Request_Type__c = 'Security Review Lift Block';
                }
            }
        }
    }
    
    /**
* Added by : Ankit Bhatnagar
* CR #     : 2750
* End
*/
    /*//CR #2495 Added by Chetan-Start
public static void sendEmailForCancelledMeeting(List<Case> newList, Map<Id, Case> oldMap){
List<Id> listOfCaseId = new List<Id>();
List<Id> listOfUserId = new List<Id>();
for(Case cs: newList){
if(cs.Chili_Piper_Meeting_Status__c  != oldMap.get(cs.Id).Chili_Piper_Meeting_Status__c  && cs.Chili_Piper_Meeting_Status__c== 'Cancelled (If CP Meeting is cancelled)'){
listOfCaseId.add(cs.Id);
listOfUserId.add(cs.ownerId);
System.debug('List of Case-->'+listOfCaseId);
System.debug('List of User-->'+listOfUserId);


}
}
if((!listOfCaseId.isEmpty() && !listOfUserId.isEmpty()) || Test.isRunningTest()){
Map<Id, List<String>> mapOfUserAndEmails = new Map<Id, List<String>>();
for(User usr: [select id, Email, Manager.Email from User where Id in :listOfUserId]){
mapOfUserAndEmails.put(usr.Id, new List<String>{usr.Email, usr.Manager.Email});
}
if(!mapOfUserAndEmails.isEmpty()){
List<Messaging.SingleEmailMessage> mailLst = new List<Messaging.SingleEmailMessage>();
EmailTemplate emailTemplate = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where DeveloperName ='Email_for_cancelled_meeting'];
Messaging.SingleEmailMessage mail =  new Messaging.SingleEmailMessage();
mail.setTemplateId(emailTemplate.Id);
mail.settargetObjectId([select id from Contact limit 1].Id);
mail.setTreatTargetObjectAsRecipient(false);
OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'support@zscaler.com'];
if(owea.size() > 0){
mail.setOrgWideEmailAddressId(owea.get(0).Id);  
}
for(Case cs: newList){
if(listOfCaseId.contains(cs.Id)){
if(mapOfUserAndEmails.containsKey(cs.OwnerId) && mapOfUserAndEmails.get(cs.OwnerId) != null){
List<String> listOfAddress = mapOfUserAndEmails.get(cs.OwnerId);
mail.setWhatId(cs.Id);
if(listOfAddress[0] != null){
mail.setToAddresses(new List<String>{listOfAddress[0]});  
mail.setCcAddresses(new List<String>{listOfAddress[1]});
mailLst.add(mail);
}
}
}
}  
if(!mailLst.isEmpty() && !Test.isRunningTest()){
try{
Messaging.sendEmail(mailLst); 
}catch(Exception ex){
system.debug(ex);
system.debug('Error While sending Email.');
}
}
}
}
}
//CR #2495 Added by Chetan-End*/
    /**
* Added by : Chetan
* CR #     : 3113
* Start
*/
    public static void setURLFromDescription (Case c){
        if(String.isNotBlank(c.Description) && c.Description.contains('URL :')) {
            String descriptionExtract = !c.description.split(',').isEmpty()?(c.description.split(',').get(0)).replaceAll('URL :', '').trim():'';
            c.Sitereview_Case_URL__c = descriptionExtract;
        }
    }
    /**
* Added by : Chetan
* CR #     : 3113
* End
*/
    
    /**
* TAM Routing Implementation
* Added by : Ankit Bhatnagar
*/
    public static void assignCasesbySkill_TamRouting(List<Case> newList){
        Set<Id> accids = new Set<Id>();
        List<Case> supportcases = new List<Case>();
        Map<String, Primary_Secondary_Escalation_Support_Map__c> psesupportmap = Primary_Secondary_Escalation_Support_Map__c.getAll();
        Set<String> setOfRegionSupport = new Set<String>();
        for(String csData : psesupportmap.keySet()){
            if(psesupportmap.get(csData)!= null && psesupportmap.get(csData).Region_Support__c != null){
                setOfRegionSupport.add(csData);
            }
        }
        Map<String, Timezone_Region_Mapping__c> timeRegionMap = Timezone_Region_Mapping__c.getAll();
        for(Case cs: newList){
            if(cs.case_source__c == 'Integration'){
                cs.RecordTypeId = caseSupportRT;
            }
            if(cs.RecordTypeId == caseSupportRT){
                supportcases.add(cs);
                accids.add(cs.AccountId);
            }
        }
        Map<Id, Account> accmap = new Map<Id, Account>();
        set<Id> tamIds = new Set<Id>();
        Set<Id> prioritizedCaseRoutingAccountsSet = new Set<Id>();
        
        Map<Id, Service_Agent_Information__c> userServiceAgentMap = new Map<Id, Service_Agent_Information__c>();
        for(Account acc: [Select Id, Type, TAM_Name_New__c, Name, Secondary_TAM_Name__c, X3rd_TAM_Name__c, Customer_Support_Segment__c, Support_Type__c, Prospect_Type__c, Exclude_Partner_Support__c, Language_Support__c, District__c, CAP_Level__c,(SELECT Id,CAP_Level__c, Prioritized_Case_Routing__c,Status__c FROM CAP_Requests__r WHERE Status__c !='Closed' Order By LastModifiedDate desc LIMIT 1) from Account where Id in :accids]){
            if(acc.TAM_Name_New__c != null){
                tamIds.add(acc.TAM_Name_New__c);
            }
            if(acc.Secondary_TAM_Name__c != null){
                tamIds.add(acc.Secondary_TAM_Name__c);
            }
            if(acc.X3rd_TAM_Name__c != null){
                tamIds.add(acc.X3rd_TAM_Name__c);
            }
            accmap.put(acc.Id, acc);
        }
        if(!tamIds.isEmpty()) {
            for(Service_Agent_Information__c sai : [SELECT id,daily_quota__c, weekly_Quota__c, backlog__c, out_of_office__c, returning_Date__c, User__c, Timezone__c FROM Service_Agent_Information__c WHERE User__c IN :tamIds]) {
                userServiceAgentMap.put(sai.user__c, sai);
            }
        }
        //Added By Ankit - CR# 4245 - Start
        for(Account a : accMap.values()) {
            if(String.isNotBlank(a.CAP_Level__c) && !a.CAP_Requests__r.isEmpty()) {
                if(a.CAP_Requests__r.get(0).Prioritized_Case_Routing__c) {
                    prioritizedCaseRoutingAccountsSet.add(a.Id);
                }
            }    
        }
        //Added By Ankit - CR# 4245 - End
        
        Boolean tamrouting = false;
        Boolean internalagentcreation = false;
        Boolean cspmCase = false;
        Boolean zpaCase = false;
        //Priyanka - 10/05/2021 - CR:2247
        Boolean zwsCase = false;
        //CR#2550 Start-Chetan
        Boolean sitereviewCase=false;
        //CR#2550 End-Chetan
        //Added by Anup - CR#3033 - Start
        Boolean zscalerDeceptionCase = false;
        //Added by Anup - CR#3033 - Start
        //Added by Anup - CR#4228 - Start
        Boolean cloudConnectorCase = false;
        //Added by Anup - CR#4228 - End
        //Added by Chetan - IBA#872 - Start
        Boolean zpcCase=false;
        //Added by Chetan - IBA#872 - Start
        List<String> nonZpaProducts = new List<String>();
        if(String.isNotBlank(Label.Non_ZPA_Products)){
            nonZpaProducts = Label.Non_ZPA_Products.trim().split(',');
        }
        List<String> productsExcludeTAMReassignment = new List<String>();
        if(String.isNotBlank(Label.TAM_Assignment_Exclusion_Products)){
            productsExcludeTAMReassignment = Label.TAM_Assignment_Exclusion_Products.trim().split(',');
        }
        
        List<QueueSObject> queues = new List<QueueSObject>([SELECT id,QueueId FROM QueueSObject WHERE sObjectType = 'Case' AND Queue.DeveloperName='ZPA_Product_Queue']);
        String ZPAQueueId = !queues.isEmpty()?queues.get(0).queueId:'';
        //Added by Anup - Handoff Project - Start
        Map<String, Timezone_Region_Mapping__c> tacTimeRegionMap = Timezone_Region_Mapping__c.getAll();
        //Added by Anup - Handoff Project - End
        for(Case cs: supportcases){
            //Added by Ankit Bhatnagar - CR# 3558 Start
            List<String> tamUnassignedReasons = new List<String>();
            //Added by Ankit Bhatnagar - CR# 3558 End
            /**
* NEW ADDITION - TAM ROUTING STARTS 
*/
            if(cs.priority == 'High (P2)' || cs.priority == 'Medium (P3)') {
                if(cs.Case_Type__c == 'Problem' || cs.Case_Type__c == 'Question') {
                    //TAM Assignment will be skipped if product exists in TAM_Assignment_Exclusion_Products Custom Label
                    if(!productsExcludeTAMReassignment.contains(cs.Product_New__c)) {
                        //Check Case Channel
                        if(cs.origin == 'Public Form' || cs.origin == 'Support Portal' || cs.origin == 'Chatbot Portal' || cs.origin == 'Partner Portal' || cs.origin == 'API' || cs.origin == 'Public Form - POST Request') {
                            //Check if TAM Acc
                            if(cs.Is_TAM_Account__c && String.isNotBlank(cs.accountId)) {
                                Boolean isWeekend = false;
                                String zoneOfCase = '';
                                //Update in CR#3534 - Added by Ankit Bhatnagar -Start
                                /*if(String.isNotBlank(cs.Preferred_Contact_Time_Zone__c)) {
//isWeekend = checkIfWeekend(cs.Preferred_Contact_Time_Zone__c);
//Get Region as per Pref Contact Time Zone
zoneOfCase = timeRegionMap.containsKey(cs.Preferred_Contact_Time_Zone__c)?timeRegionMap.get(cs.Preferred_Contact_Time_Zone__c).Region__c:'';
}*/
                                //Update in CR#3534 - Added by Ankit Bhatnagar -End
                                
                                if(!isWeekend) {
                                    //is Not Weekend
                                    if(!accmap.isEmpty() && accMap.containsKey(cs.AccountId)) {
                                        String tam1 = accMap.get(cs.AccountId).TAM_Name_New__c;
                                        String tam2 = accMap.get(cs.AccountId).Secondary_TAM_Name__c;
                                        String tam3 = accMap.get(cs.AccountId).X3rd_TAM_Name__c;
                                        
                                        if(String.isNotBlank(tam1) && !userServiceAgentMap.isEmpty() && userServiceAgentMap.containsKey(tam1)) {
                                            if(!timeRegionMap.isEmpty() && timeRegionMap.containsKey(userServiceAgentMap.get(tam1).Timezone__c)) {
                                                //Update in CR#3534 - Added by Ankit Bhatnagar -Start
                                                /*if(String.isBlank(cs.Preferred_Contact_Time_Zone__c)) {
//Get Region as per TAMTime Zone
zoneOfCase = timeRegionMap.containsKey(userServiceAgentMap.get(tam1).timezone__c)?timeRegionMap.get(userServiceAgentMap.get(tam1).timezone__c).Region__c:'';
}*/
                                                //Get Region as per TAMTime Zone
                                                zoneOfCase = timeRegionMap.containsKey(userServiceAgentMap.get(tam1).timezone__c)?timeRegionMap.get(userServiceAgentMap.get(tam1).timezone__c).Region__c:'';
                                                //Update in CR#3534 - Added by Ankit Bhatnagar -End
                                                isWeekend = checkIfWeekend(userServiceAgentMap.get(tam1).timezone__c);
                                                
                                                if((timeRegionMap.get(userServiceAgentMap.get(tam1).Timezone__c).Region__c == zoneOfCase) && !isWeekend) {
                                                    //Timezone of Case matches TZ of Primary TAM
                                                    if(!userServiceAgentMap.get(tam1).out_of_office__c || (userServiceAgentMap.get(tam1).out_of_office__c && userServiceAgentMap.get(tam1).returning_Date__c <= Date.today())) {
                                                        //TAM is not out of Office OR TAM has returned after being Out of Office
                                                        if(userServiceAgentMap.get(tam1).daily_quota__c > 0 || (userServiceAgentMap.get(tam1).daily_quota__c == 0 && userServiceAgentMap.get(tam1).backlog__c > 0)) {
                                                            cs.ownerId = tam1;
                                                            cs.Case_Owner_is_TAM__c=true;
                                                            cs.Case_TAM_Assignment__c = 'Auto Assignment';
                                                            //Ram S Added for Slack_TAM_Case_Owner_New flow fix - starts here
                                                            cs.Prior_Owner_Id__c = 'Auto_Assignment';
                                                            cs.Prior_Owner_Name__c = 'Customer (OR) Integration User';
                                                            //Ram S Added for Slack_TAM_Case_Owner_New flow fix - ends here
                                                            Service_Agent_Information__c saInfo = userServiceAgentMap.get(tam1);
                                                            if(userServiceAgentMap.get(tam1).daily_quota__c > 0 ) {
                                                                saInfo.daily_quota__c -= 1;
                                                            }
                                                            else if (userServiceAgentMap.get(tam1).daily_quota__c == 0 && userServiceAgentMap.get(tam1).backlog__c > 0){
                                                                saInfo.backlog__c -= 1;
                                                            }
                                                            if(saInfo.weekly_quota__c > 0)
                                                                saInfo.weekly_quota__c -= 1;    
                                                            userServiceAgentMap.put(tam1, saInfo);
                                                            tamrouting = true;
                                                            continue;
                                                        }
                                                        //Added by Ankit Bhatnagar - CR# 3558 Start
                                                        //Quota Exhausted Condition Starts
                                                        else {
                                                            if(!tamUnassignedReasons.contains('Quota Exhausted')) {
                                                                tamUnassignedReasons.add('Quota Exhausted');
                                                            }
                                                        }
                                                        //Quota Exhausted Condition Ends
                                                    }
                                                    //TAM out of office Condition Starts
                                                    else {
                                                        if(!tamUnassignedReasons.contains('TAM Out of Office')) {
                                                            tamUnassignedReasons.add('TAM Out of Office');
                                                        }
                                                    }
                                                    //TAM out of office Condition Ends
                                                }
                                                //Non Working Hours Condition Starts
                                                else {
                                                    if(!tamUnassignedReasons.contains('Non Working Hours')) {
                                                        tamUnassignedReasons.add('Non Working Hours');
                                                    }
                                                }
                                                //Non Working Hours Condition Ends
                                                //Added by Ankit Bhatnagar - CR# 3558 End 
                                            }
                                        }
                                        if(String.isNotBlank(tam2) && !userServiceAgentMap.isEmpty() && userServiceAgentMap.containsKey(tam2)) {
                                            if(!timeRegionMap.isEmpty() && timeRegionMap.containsKey(userServiceAgentMap.get(tam2).Timezone__c)) {
                                                //Update in CR#3534 - Added by Ankit Bhatnagar -Start
                                                /*if(String.isBlank(cs.Preferred_Contact_Time_Zone__c)) {
//Get Region as per TAMTime Zone
zoneOfCase = timeRegionMap.containsKey(userServiceAgentMap.get(tam2).timezone__c)?timeRegionMap.get(userServiceAgentMap.get(tam2).timezone__c).Region__c:'';
}*/
                                                //Get Region as per TAMTime Zone
                                                zoneOfCase = timeRegionMap.containsKey(userServiceAgentMap.get(tam2).timezone__c)?timeRegionMap.get(userServiceAgentMap.get(tam2).timezone__c).Region__c:'';
                                                //Update in CR#3534 - Added by Ankit Bhatnagar -End
                                                isWeekend = checkIfWeekend(userServiceAgentMap.get(tam2).timezone__c);
                                                if((timeRegionMap.get(userServiceAgentMap.get(tam2).Timezone__c).Region__c == zoneOfCase) && !isWeekend) {
                                                    //Timezone of Case matches TZ of Secondary TAM
                                                    if(!userServiceAgentMap.get(tam2).out_of_office__c || (userServiceAgentMap.get(tam2).out_of_office__c && userServiceAgentMap.get(tam2).returning_Date__c <= Date.today())) {
                                                        //TAM is not out of Office OR TAM has returned after being Out of Office
                                                        if(userServiceAgentMap.get(tam2).daily_quota__c > 0 || (userServiceAgentMap.get(tam2).daily_quota__c == 0 && userServiceAgentMap.get(tam2).backlog__c > 0)) {
                                                            cs.ownerId = tam2;
                                                            cs.Case_Owner_is_TAM__c=true;
                                                            cs.Case_TAM_Assignment__c = 'Auto Assignment';
                                                            //Ram S Added for Slack_TAM_Case_Owner_New flow fix - starts here
                                                            cs.Prior_Owner_Id__c = 'Auto_Assignment';
                                                            cs.Prior_Owner_Name__c = 'Customer (OR) Integration User';
                                                            //Ram S Added for Slack_TAM_Case_Owner_New flow fix - ends here
                                                            Service_Agent_Information__c saInfo = userServiceAgentMap.get(tam2);
                                                            if(userServiceAgentMap.get(tam2).daily_quota__c > 0 ) {
                                                                saInfo.daily_quota__c -= 1;
                                                            }
                                                            else if (userServiceAgentMap.get(tam2).daily_quota__c == 0 && userServiceAgentMap.get(tam2).backlog__c > 0){
                                                                saInfo.backlog__c -= 1;
                                                            }
                                                            if(saInfo.weekly_quota__c > 0)
                                                                saInfo.weekly_quota__c -= 1;
                                                            userServiceAgentMap.put(tam2, saInfo);
                                                            tamrouting = true;
                                                            continue;
                                                        }
                                                        //Added by Ankit Bhatnagar - CR# 3558 Start
                                                        //Quota Exhausted Condition Starts
                                                        else {
                                                            if(!tamUnassignedReasons.contains('Quota Exhausted')) {
                                                                tamUnassignedReasons.add('Quota Exhausted');
                                                            }    
                                                        }
                                                        //Quota Exhausted Condition Ends
                                                    }
                                                    //TAM out of office Condition Starts
                                                    else {
                                                        if(!tamUnassignedReasons.contains('TAM Out of Office')) {
                                                            tamUnassignedReasons.add('TAM Out of Office');
                                                        }
                                                    }
                                                    //TAM out of office Condition Ends
                                                } 
                                                //Non Working Hours Condition Starts
                                                else {
                                                    if(!tamUnassignedReasons.contains('Non Working Hours')) {
                                                        tamUnassignedReasons.add('Non Working Hours');
                                                    }
                                                }
                                                //Non Working Hours Condition Ends
                                                //Added by Ankit Bhatnagar - CR# 3558 End
                                            }
                                        }
                                        if(String.isNotBlank(tam3) && !userServiceAgentMap.isEmpty() && userServiceAgentMap.containsKey(tam3)) {
                                            if(!timeRegionMap.isEmpty() && timeRegionMap.containsKey(userServiceAgentMap.get(tam3).Timezone__c)) {
                                                //Update in CR#3534 - Added by Ankit Bhatnagar -Start
                                                /*if(String.isBlank(cs.Preferred_Contact_Time_Zone__c)) {
//Get Region as per TAMTime Zone
zoneOfCase = timeRegionMap.containsKey(userServiceAgentMap.get(tam3).timezone__c)?timeRegionMap.get(userServiceAgentMap.get(tam3).timezone__c).Region__c:'';
}*/
                                                //Get Region as per TAMTime Zone
                                                zoneOfCase = timeRegionMap.containsKey(userServiceAgentMap.get(tam3).timezone__c)?timeRegionMap.get(userServiceAgentMap.get(tam3).timezone__c).Region__c:'';
                                                //Update in CR#3534 - Added by Ankit Bhatnagar -End
                                                isWeekend = checkIfWeekend(userServiceAgentMap.get(tam3).timezone__c);
                                                if((timeRegionMap.get(userServiceAgentMap.get(tam3).Timezone__c).Region__c == zoneOfCase) && !isWeekend ) {
                                                    //Timezone of Case matches TZ of Third TAM
                                                    if(!userServiceAgentMap.get(tam3).out_of_office__c || (userServiceAgentMap.get(tam3).out_of_office__c && userServiceAgentMap.get(tam3).returning_Date__c <= Date.today())) {
                                                        //TAM is not out of Office OR TAM has returned after being Out of Office
                                                        if(userServiceAgentMap.get(tam3).daily_quota__c > 0 || (userServiceAgentMap.get(tam3).daily_quota__c == 0 && userServiceAgentMap.get(tam3).backlog__c > 0)) {
                                                            cs.ownerId = tam3;
                                                            cs.Case_Owner_is_TAM__c=true;
                                                            cs.Case_TAM_Assignment__c = 'Auto Assignment';
                                                            //Ram S Added for Slack_TAM_Case_Owner_New flow fix - starts here
                                                            cs.Prior_Owner_Id__c = 'Auto_Assignment';
                                                            cs.Prior_Owner_Name__c = 'Customer (OR) Integration User';
                                                            //Ram S Added for Slack_TAM_Case_Owner_New flow fix - ends here
                                                            Service_Agent_Information__c saInfo = userServiceAgentMap.get(tam3);
                                                            if(userServiceAgentMap.get(tam3).daily_quota__c > 0 ) {
                                                                saInfo.daily_quota__c -= 1;
                                                            }
                                                            else if (userServiceAgentMap.get(tam3).daily_quota__c == 0 && userServiceAgentMap.get(tam3).backlog__c > 0){
                                                                saInfo.backlog__c -= 1;
                                                            }
                                                            if(saInfo.weekly_quota__c > 0)
                                                                saInfo.weekly_quota__c -= 1;
                                                            userServiceAgentMap.put(tam3, saInfo);
                                                            tamrouting = true;
                                                            continue;
                                                        }
                                                        //Added by Ankit Bhatnagar - CR# 3558 Start
                                                        //Quota Exhausted Condition Starts
                                                        else {
                                                            if(!tamUnassignedReasons.contains('Quota Exhausted')){
                                                                tamUnassignedReasons.add('Quota Exhausted');
                                                            }
                                                        }
                                                        //Quota Exhausted Condition Ends
                                                    }
                                                    //TAM Out of office condition starts
                                                    else {
                                                        if(!tamUnassignedReasons.contains('TAM Out of Office')){
                                                            tamUnassignedReasons.add('TAM Out of Office');
                                                        }
                                                    }
                                                    //TAM Out of office condition ends
                                                } 
                                                //Non working hours condition starts
                                                else {
                                                    if(!tamUnassignedReasons.contains('Non Working Hours')) {
                                                        tamUnassignedReasons.add('Non Working Hours');
                                                    }   
                                                }
                                                //Non working hours condition ends
                                                //Added by Ankit Bhatnagar - CR# 3558 End
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    } 
                }
                //Added by Ankit - CR# 3743 - Start
                else if(cs.Case_Type__c == 'Categorization' || cs.Case_Type__c == 'Provisioning') {
                    if(!tamUnassignedReasons.contains('Case Type - Provisioning/Categorization')){
                        tamUnassignedReasons.add('Case Type - Provisioning/Categorization');
                    }
                }
                //Added by Ankit - CR# 3743 - End
            }
            //Added by Ankit - CR# 3743 - Start
            else if(cs.priority == 'Urgent (P1)' || cs.priority == 'Low (P4)') {
                if(!tamUnassignedReasons.contains('Case Priority - P1/P4')){
                    tamUnassignedReasons.add('Case Priority - P1/P4');
                }
            }
            //Added by Ankit - CR# 3743 - End
            /**
* NEW ADDITION - TAM ROUTING ENDS 
*/
            
            //Added by Ankit Bhatnagar - CR# 3558 Start
            if(!tamUnassignedReasons.isEmpty()) {
                //Set TAM Unasssigned Reasons on a Case
                cs.TAM_Unassigned_Reason__c = String.join(tamUnassignedReasons,';');
            }
            //Added by Ankit Bhatnagar - CR# 3558 End
            
            if(cs.Case_Type__c == 'Problem' || cs.Case_Type__c == 'Question') {
                //Added by Ankit - CR# 4069 Start
                //if(!checkIfWeekend_ZPA('America/Los_Angeles')) {
                //On Weekdays: Set Product Type on the basis of Case's Product
                if(cs.Product_New__c == 'ZPA') {
                    cs.Product_Type__c = 'ZPA';
                }
                else if(nonZpaProducts.contains(cs.Product_New__c)) {
                    cs.Product_Type__c = 'Non ZPA';
                } 
                //} 
                //Added by Ankit - CR# 4069 End
                //adding the case to ZPA Product Queue if Case's Product is ZPA
                if(cs.Product_New__c == 'ZPA') {
                    if(String.isNotBlank(ZPAQueueId)) {
                        zpaCase = true;
                    }
                }
                //Added by Anup - Omni Overhaul - Start
                Case_Quota_Management__c orgDefaults = Case_Quota_Management__c.getOrgDefaults();
                Boolean isWeekendCaseRouting = AgentWorkAssignedCompCtrl.checkIfWeekend(orgDefaults);
                if(!isWeekendCaseRouting){
                    if(cs.Priority == 'Urgent (P1)'){
                        cs.Priority_Support__c = 'P1';
                    }else{
                        cs.Priority_Support__c = 'P2-P4';
                    }
                    //cs.Overflow_Support__c= 'No Overflow';//Commented as part of IBA-5471
                }
                //Added by Anup - Omni Overhaul - End
            }
            //adding ZCSPM product to CSPM Queue as per CR#1159 by Swathi
            if(cs.Product_New__c == 'CSPM' || cs.Product_New__c == 'ZCSPM'){
                cs.OwnerId = Label.CSPM_Queue_Id;
                cspmCase = true;
            }
            //Priyanka - 10/05/2021 - CR:2247
            else if(cs.Product_New__c == 'ZWS'){
                cs.OwnerId = Label.ZWS_Queue_Id; 
                zwsCase =  true;
            }
            else if(cs.Product_New__c == 'Zscaler Deception'){
                cs.OwnerId = Label.Zscaler_Deception_Queue_Id;
                zscalerDeceptionCase = true;
            }
            else if(cs.Product_New__c == 'Cloud Connector'){
                //IBA-3165 - Start
                if(cs.Case_Type__c == 'Provisioning'){
                    cloudConnectorCase = false;
                    cs.Primary_Support__c = psesupportmap != null && psesupportmap.containsKey('CS') ? psesupportmap.get('CS').Primary_Support__c : '';
                    cs.Secondary_Support__c = psesupportmap != null && psesupportmap.containsKey('CS') ? psesupportmap.get('CS').Secondary_Support__c : '';
                    cs.Escalation_Support__c = psesupportmap != null && psesupportmap.containsKey('CS') ? psesupportmap.get('CS').Escalation_Support__c : '';
                    cs.Product_Type__c = '';
                    cs.Priority_Support__c = '';
                    //cs.Overflow_Support__c = '';//Commented as part of IBA-5471
                }else{
                    cs.OwnerId = Label.Cloud_Connector_Queue_Id;
                    cloudConnectorCase = true;
                }
                //IBA-3165 - End
            }
            //CR#2550 Start-Chetan
            //Added by Chetan - IBA#872 - Start
            else if(cs.Product_New__c == 'ZPC'){
                cs.OwnerId = Label.ZPC_Support_Queue;
                zpcCase = true;
            }
            //Added by Chetan - IBA#872 - Start
            
            else if(cs.Case_Type__c == 'Categorization' && cs.Origin=='Sitereview' && cs.zscaler_org_id__c=='no cloud - site review'){
                cs.OwnerId = Label.Sitereview_Queue_ID;
                sitereviewCase=true;
            }
            //CR#2550 End-Chetan
            else if(cs.case_source__c == 'Integration' && cs.AccountId == null){
                cs.Primary_Support__c = psesupportmap != null && psesupportmap.containsKey('CS') ? psesupportmap.get('CS').Primary_Support__c : '';
                cs.Secondary_Support__c = psesupportmap != null && psesupportmap.containsKey('CS') ? psesupportmap.get('CS').Secondary_Support__c : '';
                cs.Escalation_Support__c = psesupportmap != null && psesupportmap.containsKey('CS') ? psesupportmap.get('CS').Escalation_Support__c : '';
                cs.Product_Type__c = '';
                cs.Priority_Support__c = '';
                //cs.Overflow_Support__c = '';//Commented as part of IBA-5471
            }else if(cs.Case_Type__c == 'Provisioning' || cs.Case_Type__c == 'Categorization' || cs.Case_Category__c == 'Provisioning Request'){
                cs.Primary_Support__c = psesupportmap != null && psesupportmap.containsKey('CS') ? psesupportmap.get('CS').Primary_Support__c : '';
                cs.Secondary_Support__c = psesupportmap != null && psesupportmap.containsKey('CS') ? psesupportmap.get('CS').Secondary_Support__c : '';
                cs.Escalation_Support__c = psesupportmap != null && psesupportmap.containsKey('CS') ? psesupportmap.get('CS').Escalation_Support__c : '';
            }else if(cs.AccountId != null && accmap != null && accmap.containsKey(cs.AccountId) && accmap.get(cs.AccountId) != null && accmap.get(cs.AccountId).Type == 'Partner'){
                cs.Primary_Support__c = psesupportmap != null && psesupportmap.containsKey('Premium Plus') ? psesupportmap.get('Premium Plus').Primary_Support__c : '';
                //cs.Secondary_Support__c = psesupportmap != null && psesupportmap.containsKey('Premium Plus') ? psesupportmap.get('Premium Plus').Secondary_Support__c : '';
                //cs.Escalation_Support__c = psesupportmap != null && psesupportmap.containsKey('Premium Plus') ? psesupportmap.get('Premium Plus').Escalation_Support__c : '';
            }
            //Priyanka: CR-2234 - Added cs.Owner_Service_Level__c != 'CS' in the below else if
            else if(cs.Owner_Service_Level__c != null && cs.Owner_Service_Level__c != 'Support Leads' && cs.Owner_Service_Level__c != 'Support Managers' && cs.Owner_Service_Level__c != 'CS'){
                internalagentcreation = true;
                cs.Origin = 'Internal Agent';
                cs.Case_Owner_Assigned_Date__c = System.Now();
            }
            //Added By Ankit - CR# 4245 - Start
            else if(cs.AccountId != null && prioritizedCaseRoutingAccountsSet.contains(cs.AccountId) && (cs.priority == 'High (P2)' || cs.priority == 'Urgent (P1)') && (cs.Case_Type__c == 'Problem' || cs.Case_Type__c == 'Question')){
                cs.Primary_Support__c = '';
                cs.Secondary_Support__c = '';
                cs.Escalation_Support__c = '';
                cs.Priority_Support__c = 'Backline';
                //cs.Overflow_Support__c = 'No Overflow'; //Commented as part of IBA-5471
                cs.Case_Escalation_Reason__c = Label.Case_Escalation_Reason_CAP_Prioritize_Case_Routing;
            }
            //Added By Ankit - CR# 4245 - End
            else if(cs.AccountId != null && accmap != null && accmap.containsKey(cs.AccountId) && accmap.get(cs.AccountId) != null){
                String segmentForCase = accmap.get(cs.AccountId).Customer_Support_Segment__c;
                String premiumPlusTypes = Label.Premium_Plus_Support_Types;
                List<String> premiumPlusTypesList =  premiumPlusTypes.split(';');
                //Added by Ankit - IBA-2997 - Starts
                String premiumPlusProducts = Label.Prem_Plus_P1_Routing_Products;
                List<String> premiumPlusProductsList =  premiumPlusProducts.split(',');
                /*if(cs.Priority == 'Urgent (P1)' && cs.Product_New__c == 'ZIA' && (cs.Case_Type__c == 'Problem' || cs.Case_Type__c == 'Question')){
segmentForCase = 'Platinum';
}*/
                if(!premiumPlusProductsList.isEmpty() && premiumPlusProductsList.contains(cs.Product_New__c) && cs.Priority == 'Urgent (P1)' && (cs.Case_Type__c == 'Problem' || cs.Case_Type__c == 'Question')){
                    segmentForCase = 'Platinum';
                }
                //Added by Ankit - IBA-2997 - Ends
                else if(String.isBlank(segmentForCase) || accmap.get(cs.AccountId).Prospect_Type__c == 'POC'){
                    segmentForCase = 'Platinum';
                }
                else if(premiumPlusTypesList!=null && accmap.get(cs.AccountId).Support_Type__c!=null && premiumPlusTypesList.contains(accmap.get(cs.AccountId).Support_Type__c)){
                    segmentForCase = 'Platinum';
                }
                cs.Primary_Support__c = psesupportmap != null && psesupportmap.containsKey(segmentForCase) ? psesupportmap.get(segmentForCase).Primary_Support__c : '';
                if(accmap.get(cs.AccountId).Exclude_Partner_Support__c){
                    cs.Escalation_Support__c = psesupportmap != null && psesupportmap.containsKey(segmentForCase) ? psesupportmap.get(segmentForCase).Escalation_Support__c : '';
                }
            }
            else{
                cs.Primary_Support__c = psesupportmap != null && psesupportmap.containsKey('CS') ? psesupportmap.get('CS').Primary_Support__c : '';
                cs.Secondary_Support__c = psesupportmap != null && psesupportmap.containsKey('CS') ? psesupportmap.get('CS').Secondary_Support__c : '';
                cs.Escalation_Support__c = psesupportmap != null && psesupportmap.containsKey('CS') ? psesupportmap.get('CS').Escalation_Support__c : '';
                cs.Product_Type__c = '';
                cs.Priority_Support__c = '';
                //cs.Overflow_Support__c = '';//Commented as part of IBA-5471
            }
            
            //Added by Anup - Japan & SLED Routing - Start
            if(cs.Primary_Support__c != 'CS'){
                if(cs.AccountId != null && accmap != null && accmap.containsKey(cs.AccountId) && accmap.get(cs.AccountId) != null && accmap.get(cs.AccountId).District__c!=null){
                    String accountRegion = accmap.get(cs.AccountId).District__c;
                    for(String region : setOfRegionSupport){
                        if(accountRegion.containsIgnoreCase(region)){
                            cs.Language_Support__c = psesupportmap != null && psesupportmap.containsKey(region) ? psesupportmap.get(region).Region_Support__c : '';
                        }
                    }
                    if(!accountRegion.containsIgnoreCase('Japan')){
                        cs.Secondary_Support__c = psesupportmap != null && psesupportmap.containsKey('All Regions') ? psesupportmap.get('All Regions').Secondary_Support__c : '';
                    }
                }else{
                    cs.Secondary_Support__c = psesupportmap != null && psesupportmap.containsKey('All Regions') ? psesupportmap.get('All Regions').Secondary_Support__c : '';
                }
            }
            //Added by Anup - Japan & SLED Routing - End
            
            if(cs.Preferred_Contact_Time_Zone__c!= null && tacTimeRegionMap.containsKey(cs.Preferred_Contact_Time_Zone__c) && tacTimeRegionMap.get(cs.Preferred_Contact_Time_Zone__c)!=null && tacTimeRegionMap.get(cs.Preferred_Contact_Time_Zone__c).TAC_Region__c!=null){
                String tacRegion = tacTimeRegionMap.get(cs.Preferred_Contact_Time_Zone__c).TAC_Region__c;
                cs.Region_Support__c = tacRegion;
            }
            //Priyanka - 10/05/2021 - CR:2247 - Included zwsCase
            //CR#2550-Chetan-Added sitereviewCase
            if(!tamrouting && !internalagentcreation && !cspmCase && !zwsCase && !sitereviewCase && !zscalerDeceptionCase && !zpaCase && !cloudConnectorCase && !zpcCase){
                cs.OwnerId = Label.Support_Queue_Id;
            }
            else if(!tamrouting && !internalagentcreation && !cspmCase && !zwsCase && !sitereviewCase && !zscalerDeceptionCase && zpaCase && !cloudConnectorCase && !zpcCase) {
                cs.ownerId = ZPAQueueId;
            }
        }
        TriggerUtility.CaseSkillAssignmentExecuted();
    }
    
    public static Boolean checkIfWeekend(String prefTimeZone) {
        //Check for Weekend
        Timezone casePrefTimezone = Timezone.getTimeZone(prefTimeZone);
        DateTime currentTimePrefTimeZone = Datetime.now().addSeconds((casePrefTimezone.getOffset(Datetime.now())/1000));
        
        //String dayOfWeek_currentTimePrefTimeZone = currentTimePrefTimeZone.format('E');
        Integer hourNow = currentTimePrefTimeZone.hourGmt();
        
        String formattedTime = System.now().format('EEE, yyyy-MM-dd HH:mm:ss',prefTimeZone);
        String dayOfWeek_currentTimePrefTimeZone = formattedTime.split(',').get(0);   
        
        Integer hrDayStart = Integer.valueOf(Label.CaseTAMRouting_HourDayStart);
        Integer hrDayEnd = Integer.valueOf(Label.CaseTAMRouting_HourDayEnd);
        //Integer minNow = currentTimePrefTimeZone.minuteGmt();
        
        /*System.debug('## currentTimePrefTimeZone :' + currentTimePrefTimeZone );
System.debug('## dayOfWeek_currentTimePrefTimeZone :' + dayOfWeek_currentTimePrefTimeZone );
System.debug('## hourNow :' + hourNow );*/
        
        Boolean isWeekend = false;
        if(dayOfWeek_currentTimePrefTimeZone =='Sun' || dayOfWeek_currentTimePrefTimeZone == 'Sat') {
            isWeekend = true;
        }
        else if(dayOfWeek_currentTimePrefTimeZone == 'Fri') {
            if(hourNow >= hrDayEnd || hourNow < hrDayStart) {
                isWeekend = true;
            }
            else {
                isWeekend = false;
            }
        }
        else if(dayOfWeek_currentTimePrefTimeZone == 'Mon') {
            if(hourNow < hrDayStart || hourNow >= hrDayEnd) {
                isWeekend = true;    
            }
            else {
                isWeekend = false;
            }
        }
        else {
            if(hourNow >= hrDayEnd || hourNow < hrDayStart) {
                //Agents will be done for the day after 5 on weekdays, if a case comes after 4pm, we'll treat it as a Case on Weekend.
                isWeekend = true;    
            }
            else {
                isWeekend = false;
            }
        }
        return isWeekend;
    }
    //Commenting temporarily by Anup
    /*public static void updateDailyQuota(List<Case> newList) {
Map<Id, Service_Agent_Information__c> serviceAgentMap = new Map<Id, Service_Agent_Information__c>();
List<Case> tamCases = new List<Case>();
for(Case cs : newList) {
if(cs.case_Owner_is_TAM__c && String.isNotBlank(cs.Case_TAM_Assignment__c) && cs.Case_TAM_Assignment__c == 'Auto Assignment') {
serviceAgentMap.put(cs.OwnerId, null);
tamCases.add(cs);
}
}
if(!serviceAgentMap.isEmpty()) {
for(Service_Agent_Information__c sai : [SELECT id,daily_quota__c, weekly_Quota__c, backlog__c, out_of_office__c, returning_Date__c,
User__c, Timezone__c
FROM Service_Agent_Information__c WHERE User__c IN :serviceAgentMap.keySet()]) {
serviceAgentMap.put(sai.user__c, sai);
}
for(Case c : tamCases) {
if(serviceAgentMap.containsKey(c.ownerId)) {
Service_Agent_Information__c sai = serviceAgentMap.get(c.OwnerId);
if(sai.daily_quota__c > 0)
sai.daily_quota__c -= 1;
else if (sai.daily_quota__c == 0 && sai.backlog__c > 0) 
sai.backlog__c -= 1;
if(sai.weekly_quota__c > 0)
sai.weekly_quota__c -= 1;
serviceAgentMap.put(c.ownerId, sai);
}
}
update serviceAgentMap.values();
}
}*/
    
    public static void updateDailyQuota(List<Case> newList, Map<Id, Case> oldMap){
        Map<Id, Service_Agent_Information__c> serviceAgentMap = new Map<Id, Service_Agent_Information__c>();
        List<Case> tamCases = new List<Case>();
        List<Id> supportRouted = new List<Id>();
        List<Id> handOffCases = new List<Id>();
        List<Case> ownerUpdatedCases = new List<Case>();
        List<Service_Agent_Information__c> serviceInfoToUpdate = new List<Service_Agent_Information__c>();
        for(Case cs : newList) {
            if(oldMap == null && cs.case_Owner_is_TAM__c && String.isNotBlank(cs.Case_TAM_Assignment__c) && cs.Case_TAM_Assignment__c == 'Auto Assignment') {
                serviceAgentMap.put(cs.OwnerId, null);
                tamCases.add(cs);
            }
            if(oldMap!=null && (cs.Case_Type__c == 'Problem' || cs.Case_Type__c == 'Question') && cs.OwnerId != oldMap.get(cs.Id).OwnerId && !cs.case_Owner_is_TAM__c){
                if(!String.valueOf(cs.OwnerId).startsWith('00G')){
                    serviceAgentMap.put(cs.OwnerId, null);
                }
                ownerUpdatedCases.add(cs);
                if(!String.valueOf(oldMap.get(cs.Id).OwnerId).startsWith('00G')){
                    handOffCases.add(cs.Id);
                    serviceAgentMap.put(oldMap.get(cs.Id).OwnerId, null);
                }
            }
        }
        if(!serviceAgentMap.isEmpty()) {
            for(Service_Agent_Information__c sai : [SELECT id,daily_quota__c, weekly_Quota__c, backlog__c, out_of_office__c, returning_Date__c,
                                                    User__c, Timezone__c, Type__c, Overflow_Cases__c, Overflow_Cases_Weekly__c
                                                    FROM Service_Agent_Information__c WHERE User__c IN :serviceAgentMap.keySet()]) {
                                                        serviceAgentMap.put(sai.user__c, sai);
                                                    }
            System.debug('Service Agent Map '+ serviceAgentMap);
            for(Case c : tamCases) {
                if(serviceAgentMap.containsKey(c.ownerId)) {
                    Service_Agent_Information__c sai = serviceAgentMap.get(c.OwnerId);
                    if(sai.daily_quota__c > 0)
                        sai.daily_quota__c -= 1;
                    else if (sai.daily_quota__c == 0 && sai.backlog__c > 0) 
                        sai.backlog__c -= 1;
                    if(sai.weekly_quota__c > 0)
                        sai.weekly_quota__c -= 1;
                    serviceAgentMap.put(c.ownerId, sai);
                }
            }
            
            for(Case c : ownerUpdatedCases){
                if(serviceAgentMap.containsKey(c.OwnerId) && serviceAgentMap.get(c.OwnerId)!=null){
                    Service_Agent_Information__c sai = serviceAgentMap.get(c.OwnerId);
                    if(sai.Type__c != 'TAM'){
                        if(sai.daily_quota__c > 0)
                            sai.daily_quota__c -= 1;
                        else if (sai.daily_quota__c == 0 && sai.backlog__c > 0) 
                            sai.backlog__c -= 1;
                        else if(sai.daily_Quota__c == 0 && sai.backlog__c == 0){
                            sai.Overflow_Cases__c += 1;
                            sai.Overflow_Cases_Weekly__c +=1;
                        }
                        if(sai.weekly_quota__c > 0)
                            sai.weekly_quota__c -= 1;
                        serviceAgentMap.put(c.ownerId, sai);
                    }
                }
                if(handOffCases.contains(c.Id)){
                    if(serviceAgentMap.containsKey(oldMap.get(c.Id).OwnerId) && serviceAgentMap.get(oldMap.get(c.Id).OwnerId)!=null){
                        Service_Agent_Information__c sai = serviceAgentMap.get(oldMap.get(c.Id).OwnerId);
                        if(sai.Type__c != 'TAM'){
                            if(sai.Overflow_Cases__c > 0 && sai.Overflow_Cases_Weekly__c > 0){
                                sai.Overflow_Cases__c -= 1;
                                sai.Overflow_Cases_Weekly__c -= 1;
                            }else{
                                sai.daily_quota__c += 1;
                                sai.Weekly_Quota__c +=1;
                            }
                            serviceAgentMap.put(oldMap.get(c.Id).OwnerId, sai);
                        }
                    }
                }
            }
            
            for(Service_Agent_Information__c sr : serviceAgentMap.values()){
                if(sr!=null){
                    serviceInfoToUpdate.add(sr);
                }
            }
            if(!serviceInfoToUpdate.isEmpty()){
                update serviceInfoToUpdate;
            }
            //update serviceAgentMap.values();
            
        }
    }
    
    //CR# 3298 TTR TTC Project Added by Chetan-Start
    public static void updateResolutionState(List<Case> newList, map<Id, Case> oldMap)
    {
        for(Case cs:newList)
        {
            if(cs.Resolution_State__c!=null && cs.Resolution_State__c!=oldmap.get(cs.Id).Resolution_State__c && oldmap.get(cs.Id).Resolution_State__c=='Not Resolved' && (cs.Resolution_State__c=='Resolved'||cs.Resolution_State__c=='Workaround Provided'))
            {
                cs.Date_and_Time_of_Resolution__c=System.now();
            }
            if(cs.Resolution_State__c!=null && cs.Resolution_State__c!=oldmap.get(cs.Id).Resolution_State__c && cs.Resolution_State__c=='Not Resolved' && (oldmap.get(cs.Id).Resolution_State__c=='Resolved'||oldmap.get(cs.Id).Resolution_State__c=='Workaround Provided'))
            {
                cs.Date_and_Time_of_Resolution__c=null;
            }
        }
    }
    //CR# 3298 TTR TTC Project Added by Chetan-End
    
    /*public static Boolean checkIfWeekend_ZPA(String tz) {
Timezone casePrefTimezone = Timezone.getTimeZone(tz);
DateTime currentTimePrefTimeZone = Datetime.now().addSeconds((casePrefTimezone.getOffset(Datetime.now())/1000));

Integer hourNow = currentTimePrefTimeZone.hourGmt();
String formattedTime = System.now().format('EEE, yyyy-MM-dd HH:mm:ss',tz);
String dayOfWeek_currentTimePrefTimeZone = formattedTime.split(',').get(0);   
Integer hrDayEnd = Integer.valueOf(Label.CaseProductRouting_HourDayEnd);
Boolean isWeekend = false;

if(dayOfWeek_currentTimePrefTimeZone == 'Fri' && hourNow >= hrDayEnd) {
isWeekend = true;
}
else if(dayOfWeek_currentTimePrefTimeZone == 'Sat') {
isWeekend = true;
}
else if(dayOfWeek_currentTimePrefTimeZone == 'Sun' && hourNow < hrDayEnd) {
isWeekend = true;
}
else {
isWeekend = false;
}
return isWeekend;
}*/
    // CR# 2842 Added by Chetan-Start
    public static void updateCustomerSupportAlias(List<Case> Caselist){
        system.debug('inside updateCustomerSupportAlias method');
        for(Case cs:Caselist){
            if((cs.RecordTypeId == caseSupportRT && cs.Customer_Support_Email_Formula__c!=null && (cs.Case_Type__c=='Problem' || cs.Case_Type__c=='Question')) || Test.isRunningTest())
            {
                cs.Account_Support_Email__c=cs.Customer_Support_Email_Formula__c;
            }
            system.debug('case after Account Support Email update'+cs);
        }
    }
    // CR# 2842 Added by Chetan-End
    
    // CR# 2958 added by Ankit - Start
    public static void addDefaultProductOnSFDCSupportCases(List<Case> newList) {
        Id sfdcSupportCaseRT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Sales').getRecordTypeId();
        for(Case c: newList) {
            if(c.RecordTypeId == sfdcSupportCaseRT) {
                c.Product_New__c = 'ZIA';
            }
        }
    }
    // CR# 2958 added by Ankit - End
    
    //Added by Anup - Omni Overhaul - Start
    public static void updatePrioritySupportOfCase(List<Case> newList, Map<Id, Case> oldMap){
        Boolean accountChange = false;
        List<Id> listOfAccountId = new List<Id>();
        List<String> nonZpaProducts = new List<String>();
        if(String.isNotBlank(Label.Non_ZPA_Products)){
            nonZpaProducts = Label.Non_ZPA_Products.trim().split(',');
        }
        Map<String, Primary_Secondary_Escalation_Support_Map__c> psesupportmap = Primary_Secondary_Escalation_Support_Map__c.getAll();
        Set<String> setOfRegionSupport = new Set<String>();
        for(String csData : psesupportmap.keySet()){
            if(psesupportmap.get(csData)!= null && psesupportmap.get(csData).Region_Support__c != null){
                setOfRegionSupport.add(csData);
            }
        }
        for(Case cs : newList){
            if(cs.RecordTypeId == caseSupportRT){
                if(cs.Case_Type__c == 'Problem' || cs.Case_Type__c == 'Question'){
                    if((oldMap.containsKey(cs.Id) && oldMap.get(cs.Id)!=null && ((oldMap.get(cs.Id).Priority!=cs.Priority) || (oldMap.get(cs.Id).AccountId!=cs.AccountId) || ((oldMap.get(cs.Id).Case_Type__c!=cs.Case_Type__c) && (oldMap.get(cs.Id).Case_Type__c=='Categorization' || oldMap.get(cs.Id).Case_Type__c=='Provisioning')))) || Test.isRunningTest()){
                        if(cs.Priority_Support__c != 'Backline'){
                            if (cs.Priority == 'Urgent (P1)') {
                                cs.Priority_Support__c = 'P1';
                            }else{
                                cs.Priority_Support__c = 'P2-P4';
                            }
                            //cs.Overflow_Support__c= 'No Overflow';//Commented as part of IBA-5471
                        }
                    }
                    if((oldMap.containsKey(cs.Id) && oldMap.get(cs.Id)!=null && ((oldMap.get(cs.Id).Product_New__c!=cs.Product_New__c) || (oldMap.get(cs.Id).AccountId!=cs.AccountId) || ((oldMap.get(cs.Id).Case_Type__c!=cs.Case_Type__c) && (oldMap.get(cs.Id).Case_Type__c=='Categorization' || oldMap.get(cs.Id).Case_Type__c=='Provisioning')))) || Test.isRunningTest()){
                        if(cs.Product_New__c == 'ZPA') {
                            cs.Product_Type__c = 'ZPA';
                        }
                        else if(nonZpaProducts.contains(cs.Product_New__c)) {
                            cs.Product_Type__c = 'Non ZPA';
                        }
                        //cs.Overflow_Support__c= 'No Overflow';//Commented as part of IBA-5471
                    }
                    if((oldMap.containsKey(cs.Id) && oldMap.get(cs.Id)!=null && ((oldMap.get(cs.Id).AccountId!=cs.AccountId) || ((oldMap.get(cs.Id).Case_Type__c!=cs.Case_Type__c) && (oldMap.get(cs.Id).Case_Type__c=='Categorization' || oldMap.get(cs.Id).Case_Type__c=='Provisioning')))) || Test.isRunningTest()){
                        accountChange = true;
                        listOfAccountId.add(cs.AccountId);
                        //cs.Overflow_Support__c= 'No Overflow';//Commented as part of IBA-5471
                    }
                }else if(cs.Case_Type__c == 'Provisioning' || cs.Case_Type__c == 'Categorization'){
                    if((oldMap.containsKey(cs.Id) && oldMap.get(cs.Id)!=null && oldMap.get(cs.Id).Case_Type__c!=cs.Case_Type__c && oldMap.get(cs.Id).Case_Type__c!='Categorization' && oldMap.get(cs.Id).Case_Type__c!='Provisioning') || Test.isRunningTest()){
                        cs.Primary_Support__c = psesupportmap != null && psesupportmap.containsKey('CS') ? psesupportmap.get('CS').Primary_Support__c : '';
                        cs.Secondary_Support__c = psesupportmap != null && psesupportmap.containsKey('CS') ? psesupportmap.get('CS').Secondary_Support__c : '';
                        cs.Escalation_Support__c = psesupportmap != null && psesupportmap.containsKey('CS') ? psesupportmap.get('CS').Escalation_Support__c : '';
                        cs.Priority_Support__c = '';
                        cs.Product_Type__c = '';
                        //cs.Overflow_Support__c= '';//Commented as part of IBA-5471
                        cs.Language_Support__c = '';
                    }
                }
            }
            
        }
        
        if(!listOfAccountId.isEmpty()){
            Map<Id, Account> accmap = new Map<Id, Account>();
            for(Account acc: [Select Id, Customer_Support_Segment__c, Prospect_Type__c, Exclude_Partner_Support__c, Support_Type__c, District__c from Account where Id in :listOfAccountId]){
                accmap.put(acc.Id, acc);
            }
            for(Case cs: newList){
                if(cs.Priority_Support__c != 'Backline'){
                    if(cs.AccountId != null && accmap != null && accmap.containsKey(cs.AccountId) && accmap.get(cs.AccountId) != null){
                        String segmentForCase = accmap.get(cs.AccountId).Customer_Support_Segment__c;
                        String premiumPlusTypes = Label.Premium_Plus_Support_Types;
                        List<String> premiumPlusTypesList =  premiumPlusTypes.split(';');
                        //Added by Ankit - IBA-2997 - Starts
                        String premiumPlusProducts = Label.Prem_Plus_P1_Routing_Products;
                        List<String> premiumPlusProductsList =  premiumPlusProducts.split(',');
                        /*if(cs.Priority == 'Urgent (P1)' && cs.Product_New__c == 'ZIA' && (cs.Case_Type__c == 'Problem' || cs.Case_Type__c == 'Question')){
segmentForCase = 'Platinum';
}*/
                        if(!premiumPlusProductsList.isEmpty() && premiumPlusProductsList.contains(cs.Product_New__c) && cs.Priority == 'Urgent (P1)' && (cs.Case_Type__c == 'Problem' || cs.Case_Type__c == 'Question')){
                            segmentForCase = 'Platinum';
                        }
                        //Added by Ankit - IBA-2997 - Ends
                        else if(String.isBlank(segmentForCase) || accmap.get(cs.AccountId).Prospect_Type__c == 'POC'){
                            segmentForCase = 'Platinum';
                        }
                        else if(premiumPlusTypesList!=null && accmap.get(cs.AccountId).Support_Type__c!=null && premiumPlusTypesList.contains(accmap.get(cs.AccountId).Support_Type__c)){
                            segmentForCase = 'Platinum';
                        }
                        cs.Primary_Support__c = psesupportmap != null && psesupportmap.containsKey(segmentForCase) ? psesupportmap.get(segmentForCase).Primary_Support__c : '';
                        if(accmap.get(cs.AccountId).Exclude_Partner_Support__c){
                            cs.Escalation_Support__c = psesupportmap != null && psesupportmap.containsKey(segmentForCase) ? psesupportmap.get(segmentForCase).Escalation_Support__c : '';
                        }
                    }
                    else{
                        cs.Primary_Support__c = psesupportmap != null && psesupportmap.containsKey('CS') ? psesupportmap.get('CS').Primary_Support__c : '';
                        cs.Secondary_Support__c = psesupportmap != null && psesupportmap.containsKey('CS') ? psesupportmap.get('CS').Secondary_Support__c : '';
                        cs.Escalation_Support__c = psesupportmap != null && psesupportmap.containsKey('CS') ? psesupportmap.get('CS').Escalation_Support__c : '';
                        cs.Priority_Support__c = '';
                        cs.Product_Type__c = '';
                        //cs.Overflow_Support__c = '';//Commented as part of IBA-5471
                    }
                }
                
                
                //Added by Anup - Japan & SLED Routing - Start
                if(cs.Primary_Support__c != 'CS'){
                    cs.Language_Support__c = '';
                    if(cs.AccountId != null && accmap != null && accmap.containsKey(cs.AccountId) && accmap.get(cs.AccountId) != null && accmap.get(cs.AccountId).District__c!=null){
                        String accountRegion = accmap.get(cs.AccountId).District__c;
                        for(String region : setOfRegionSupport){
                            if(accountRegion.containsIgnoreCase(region)){
                                cs.Language_Support__c = psesupportmap != null && psesupportmap.containsKey(region) ? psesupportmap.get(region).Region_Support__c : '';
                            }
                        }
                        if(!accountRegion.containsIgnoreCase('Japan')){
                            cs.Secondary_Support__c = psesupportmap != null && psesupportmap.containsKey('All Regions') ? psesupportmap.get('All Regions').Secondary_Support__c : '';
                        }
                    }else{
                        cs.Secondary_Support__c = psesupportmap != null && psesupportmap.containsKey('All Regions') ? psesupportmap.get('All Regions').Secondary_Support__c : '';
                    }
                }
                //Added by Anup - Japan & SLED Routing - End
            }
        }
    }
    //Added by Anup - Omni Overhaul - End
    
    //CR# 4095 Added by Chetan-Start
    public static void updatePendingCustomerTimestamp(List<Case> newList, map<Id, Case> oldMap)
    {
        List<String> nonZpaProducts = new List<String>();
        List<Id> listOfAccountId = new List<Id>();
        if(String.isNotBlank(Label.Non_ZPA_Products)){
            nonZpaProducts = Label.Non_ZPA_Products.trim().split(',');
        }
        System.debug('update Pending Customer called');
        Map<String, Primary_Secondary_Escalation_Support_Map__c> psesupportmap = Primary_Secondary_Escalation_Support_Map__c.getAll();
        //Added by Anup - Handoff Project - Start
        Map<String, Timezone_Region_Mapping__c> tacTimeRegionMap = Timezone_Region_Mapping__c.getAll();
        //Added by Anup - Handoff Project - End
        Set<String> setOfRegionSupport = new Set<String>();
        for(String csData : psesupportmap.keySet()){
            if(psesupportmap.get(csData)!= null && psesupportmap.get(csData).Region_Support__c != null){
                setOfRegionSupport.add(csData);
            }
        }
        for(Case cs:newList)
        {
            //CR#4095 Logic - Start
            if(cs.RecordTypeId == caseSupportRT && cs.Status!=null && cs.Status!=oldmap.get(cs.Id).Status && cs.Status=='Pending Customer' && (cs.Case_Type__c=='Problem' || cs.Case_Type__c=='Question'))
            {
                cs.Pending_Customer_Timestamp__c=System.now();
            }
            else if(cs.RecordTypeId == caseSupportRT && cs.Status!=null && cs.Status!=oldmap.get(cs.Id).Status && cs.Status!='Pending Customer' && (cs.Case_Type__c=='Problem' || cs.Case_Type__c=='Question'))
            {
                cs.Pending_Customer_Timestamp__c=null;
            }
            //CR#4095 Logic - End
            if(cs.RecordTypeId == caseSupportRT && cs.Warm_Handoff__c && cs.Warm_Handoff__c != oldmap.get(cs.Id).Warm_Handoff__c){
                cs.Work_Item_Progress__c = 'In-Progress';//IBA-2400 - Anup
                if(cs.Case_Type__c == 'Provisioning' || cs.Case_Type__c == 'Categorization'){
                    cs.Primary_Support__c = 'CS';
                    cs.Secondary_Support__c = '';
                    cs.Escalation_Support__c = '';
                    cs.Priority_Support__c = '';
                    cs.Product_Type__c = '';
                    //cs.Overflow_Support__c= '';//Commented as part of IBA-5471
                }
                else{
                    if(cs.Product_New__c == 'ZPA') {
                        cs.Product_Type__c = 'ZPA';
                    }
                    else if(nonZpaProducts.contains(cs.Product_New__c)) {
                        cs.Product_Type__c = 'Non ZPA';
                    }
                    Case_Quota_Management__c orgDefaults = Case_Quota_Management__c.getOrgDefaults();
                    Boolean isWeekendCaseRouting = AgentWorkAssignedCompCtrl.checkIfWeekend(orgDefaults);
                    system.debug('isWeekendCaseRouting --->'+isWeekendCaseRouting);
                    if(cs.Priority_Support__c != 'Backline'){
                        if(!isWeekendCaseRouting){
                            if(cs.Priority == 'Urgent (P1)'){
                                cs.Priority_Support__c = 'P1';
                            }else{
                                cs.Priority_Support__c = 'P2-P4';
                            }
                            //cs.Overflow_Support__c= 'No Overflow';//Commented as part of IBA-5471
                        }else{
                            cs.Priority_Support__c = '';
                            //cs.Overflow_Support__c='';//Commented as part of IBA-5471
                        }
                    }
                    if(cs.AccountId != null){
                        listOfAccountId.add(cs.AccountId);
                    }
                }
            }
        }
        Map<Id, Account> accmap = new Map<Id, Account>();
        if(!listOfAccountId.isEmpty()){
            for(Account acc: [Select Id, Customer_Support_Segment__c, Prospect_Type__c, Exclude_Partner_Support__c, Support_Type__c, District__c from Account where Id in :listOfAccountId]){
                accmap.put(acc.Id, acc);
            }
        }
        for(Case cs: newList){
            if(cs.RecordTypeId == caseSupportRT && cs.Warm_Handoff__c && cs.Warm_Handoff__c != oldmap.get(cs.Id).Warm_Handoff__c){
                if(cs.Priority_Support__c != 'Backline'){
                    if(cs.AccountId != null && accmap != null && accmap.containsKey(cs.AccountId) && accmap.get(cs.AccountId) != null){
                        String segmentForCase = accmap.get(cs.AccountId).Customer_Support_Segment__c;
                        String premiumPlusTypes = Label.Premium_Plus_Support_Types;
                        List<String> premiumPlusTypesList =  premiumPlusTypes.split(';');
                        //Added by Ankit - IBA-2997 - Starts
                        String premiumPlusProducts = Label.Prem_Plus_P1_Routing_Products;
                        List<String> premiumPlusProductsList =  premiumPlusProducts.split(',');
                        /*if(cs.Priority == 'Urgent (P1)' && cs.Product_New__c == 'ZIA' && (cs.Case_Type__c == 'Problem' || cs.Case_Type__c == 'Question')){
segmentForCase = 'Platinum';
}*/
                        if(!premiumPlusProductsList.isEmpty() && premiumPlusProductsList.contains(cs.Product_New__c) && cs.Priority == 'Urgent (P1)' && (cs.Case_Type__c == 'Problem' || cs.Case_Type__c == 'Question')){
                            segmentForCase = 'Platinum';
                        }
                        //Added by Ankit - IBA-2997 - Ends
                        else if(String.isBlank(segmentForCase) || accmap.get(cs.AccountId).Prospect_Type__c == 'POC'){
                            segmentForCase = 'Platinum';
                        }
                        else if(premiumPlusTypesList!=null && accmap.get(cs.AccountId).Support_Type__c!=null && premiumPlusTypesList.contains(accmap.get(cs.AccountId).Support_Type__c)){
                            segmentForCase = 'Platinum';
                        }
                        cs.Primary_Support__c = psesupportmap != null && psesupportmap.containsKey(segmentForCase) ? psesupportmap.get(segmentForCase).Primary_Support__c : '';
                        if(accmap.get(cs.AccountId).Exclude_Partner_Support__c){
                            cs.Escalation_Support__c = psesupportmap != null && psesupportmap.containsKey(segmentForCase) ? psesupportmap.get(segmentForCase).Escalation_Support__c : '';
                        }
                    }
                    else{
                        cs.Primary_Support__c = psesupportmap != null && psesupportmap.containsKey('CS') ? psesupportmap.get('CS').Primary_Support__c : '';
                        cs.Secondary_Support__c = psesupportmap != null && psesupportmap.containsKey('CS') ? psesupportmap.get('CS').Secondary_Support__c : '';
                        cs.Escalation_Support__c = psesupportmap != null && psesupportmap.containsKey('CS') ? psesupportmap.get('CS').Escalation_Support__c : '';
                        cs.Product_Type__c = '';
                        cs.Priority_Support__c = '';
                        //cs.Overflow_Support__c = '';//Commented as part of IBA-5471
                    }
                }
                
                //Added by Anup - Japan & SLED Routing - Start
                if(cs.Primary_Support__c != 'CS'){
                    cs.Language_Support__c = '';
                    if(cs.AccountId != null && accmap != null && accmap.containsKey(cs.AccountId) && accmap.get(cs.AccountId) != null && accmap.get(cs.AccountId).District__c!=null){
                        String accountRegion = accmap.get(cs.AccountId).District__c;
                        for(String region : setOfRegionSupport){
                            if(accountRegion.containsIgnoreCase(region)){
                                cs.Language_Support__c = psesupportmap != null && psesupportmap.containsKey(region) ? psesupportmap.get(region).Region_Support__c : '';
                            }
                        }
                        if(!accountRegion.containsIgnoreCase('Japan')){
                            cs.Secondary_Support__c = psesupportmap != null && psesupportmap.containsKey('All Regions') ? psesupportmap.get('All Regions').Secondary_Support__c : '';
                        }
                    }else{
                        cs.Secondary_Support__c = psesupportmap != null && psesupportmap.containsKey('All Regions') ? psesupportmap.get('All Regions').Secondary_Support__c : '';
                    }
                }else{
                    cs.Language_Support__c = '';
                    cs.Secondary_Support__c = '';
                }
                //Added by Anup - Japan & SLED Routing - End
                
                //Added by Anup - Handoff Project - Start
                if(cs.Preferred_Contact_Time_Zone__c!= null && tacTimeRegionMap.containsKey(cs.Preferred_Contact_Time_Zone__c) && tacTimeRegionMap.get(cs.Preferred_Contact_Time_Zone__c)!=null && tacTimeRegionMap.get(cs.Preferred_Contact_Time_Zone__c).TAC_Region__c!=null){
                    String tacRegion = tacTimeRegionMap.get(cs.Preferred_Contact_Time_Zone__c).TAC_Region__c;
                    cs.Region_Support__c = tacRegion;
                }
                //Added by Anup - Handoff Project - End
            }
        }
        
    }
    //CR# 4095 Added by Chetan-End
    
    public static void caseHandoffAssignment(List<Case> newList, map<Id, Case> oldMap){
        List<Id> listOfCaseToProcess = new List<Id>();
        List<Id> listOfUserId = new List<Id>();
        List<Service_Agent_Information__c> listOfSAI = new List<Service_Agent_Information__c>();
        List<Id> caseOwnerQueueOrOOO = new List<Id>();
        List<Id> listOfOwnerId = new List<Id>();
        Set<Id> setOfActiveUserId = new Set<Id>();
        List<FeedItem> feedItemList = new List<FeedItem>();
        List<String> productsToExclude = new List<String>();
        if(String.isNotBlank(Label.TAM_Reassignment_Excluded_Products)){
            productsToExclude = Label.TAM_Reassignment_Excluded_Products.trim().split(';');
        }
        //Skills Calculation Logic - Start
        Map<String, Primary_Secondary_Escalation_Support_Map__c> psesupportmap = Primary_Secondary_Escalation_Support_Map__c.getAll();
        List<String> nonZpaProducts = new List<String>();
        List<Id> listOfAccountId = new List<Id>();
        if(String.isNotBlank(Label.Non_ZPA_Products)){
            nonZpaProducts = Label.Non_ZPA_Products.trim().split(',');
        }
        Map<String, Timezone_Region_Mapping__c> tacTimeRegionMap = Timezone_Region_Mapping__c.getAll();
        Set<String> setOfRegionSupport = new Set<String>();
        for(String csData : psesupportmap.keySet()){
            if(psesupportmap.get(csData)!= null && psesupportmap.get(csData).Region_Support__c != null){
                setOfRegionSupport.add(csData);
            }
        }
        //Skills Calculation Logic - End
        for(Case cs : newList){
            Boolean caseSelected = false;
            if(cs.RecordTypeId == caseSupportRT && !cs.TAM_Reassignment__c && !productsToExclude.contains(cs.Product_New__c)){
                //IBA-1315 : Commenting SLA Breached logic and removing P2 from CNA condition
                /*if(cs.SLA_Breached_Threshold__c != oldMap.get(cs.Id).SLA_Breached_Threshold__c && cs.SLA_Breached_Threshold__c){
listOfCaseToProcess.add(cs.Id);
caseSelected = true;
cs.Automated_Trigger_Reason__c = 'Subsequent SLA breached by 75%';
cs.SLA_Breached_Threshold__c = false;
}*/
                if(cs.Status != oldMap.get(cs.Id).Status && cs.Status == 'Customer Note Added' && (cs.Priority =='Urgent (P1)'/* || cs.Priority == 'High (P2)'*/)){
                    listOfCaseToProcess.add(cs.Id);
                    caseSelected = true;
                    cs.Automated_Trigger_Reason__c = 'Customer Note Added for a P1 Case';
                }
                else if(cs.Defcon_Level__c != oldMap.get(cs.Id).Defcon_Level__c && cs.Defcon_Level__c!=null && cs.Defcon_Level__c!='5'){                    
                    listOfCaseToProcess.add(cs.Id);
                    caseSelected = true;
                    cs.Automated_Trigger_Reason__c = 'DEFCON Escalation occurred on case';                    
                }
                else if(cs.Case_Owner_Not_Available__c && cs.Status != oldMap.get(cs.Id).Status && cs.Status == 'Customer Note Added'){
                    listOfCaseToProcess.add(cs.Id);
                    caseSelected = true;
                    cs.Automated_Trigger_Reason__c = 'Customer note added & Case owner is OOO/Inactive';
                }
                if(caseSelected){
                    if(String.valueOf(cs.OwnerId).startsWithIgnoreCase(Label.Cold_Transfer_Queue_Id) || cs.Case_Owner_Not_Available__c){
                        caseOwnerQueueOrOOO.add(cs.Id);                                            
                    }
                    else{
                        if(!String.valueOf(cs.OwnerId).startsWithIgnoreCase('00G')){
                            listOfOwnerId.add(cs.OwnerId);
                        }
                    }
                    FeedItem caseFeed = new FeedItem(parentId = cs.Id);
                    caseFeed.Body = 'Automated Trigger Reason : ' + cs.Automated_Trigger_Reason__c;
                    caseFeed.Visibility = 'InternalUsers';
                    caseFeed.IsRichText = true;
                    feedItemList.add(caseFeed);
                    //Skills Calculation Logic - Start
                    if(cs.AccountId != null){
                        listOfAccountId.add(cs.AccountId);
                    }
                    //Skills Calculation Logic - End
                }
            }
        }
        if(!listOfCaseToProcess.isEmpty()){
            
            List<Service_Agent_Information__c> saiList = new List<Service_Agent_Information__c>();
            Map<Id, String> mapOfUserAndEmail = new Map<Id, String>();
            Map<Id, String> mapOfUserAndManagerEmail = new Map<Id, String>();
            String ziaPremiumDutyManagerEmail='';
            String ziaPremiumPlusDutyManagerEmail = '';
            String zpaDutyManager = '';
            String backupDutyManagerEmail = '';
            String ziaPremiumPlusBackupDutyManagerEmail = '';
            String ziaPremiumBackupDutyManagerEmail = '';
            String zpaBackupDutyManagerEmail = '';
            if(!listOfOwnerId.isEmpty()){
                /*for(User usr: [select id, Email, ManagerId, Manager.Email from User where Id IN:listOfOwnerId]){
mapOfUserAndEmail.put(usr.Id, usr.Email);
if(usr.ManagerId!=null){
mapOfUserAndManagerEmail.put(usr.Id, usr.manager.Email);
}
}*/
                Map<String,String> daysOfWeek = new Map<String,String>{'Mon'=>'Monday','Tue'=>'Tuesday','Wed'=>'Wednesday','Thu'=>'Thursday','Fri'=>'Friday','Sat'=>'Saturday','Sun'=>'Sunday'};
                    Timezone pstTz = Timezone.getTimeZone('America/Los_Angeles');
                DateTime currentTimePst = Datetime.now().addSeconds((pstTz.getOffset(Datetime.now())/1000));
                DateTime currentTimePstWithTwoHours = Datetime.now().addSeconds((pstTz.getOffset(Datetime.now())/1000)).addHours(2);
                Integer hourNowPst = currentTimePst.hourGmt();
                Time timeNowPst = currentTimePst.timeGMT();
                Time timeTwoHoursLater = currentTimePstWithTwoHours.timeGmt();
                String formattedTime = System.now().format('EEE, yyyy-MM-dd HH:mm:ss','America/Los_Angeles');
                String dayOfWeek_currentTimePst = formattedTime.split(',').get(0); 
                Set<Id> setOfOutShiftUsers = new Set<Id>();
                for(Engineer_Schedule__c es : [select id, Start_Time__c, End_Time__c, Day__c, Duty_Manager__c, Duty_Manager__r.Email,Backup_Duty_Manager__c, Backup_Duty_Manager__r.Email, Product__c, Segment__c, Service_Agent_Information__r.User__c, Type__c, Service_Agent_Information__r.Timezone__c, Service_Agent_Information__r.Shift_Off_Days__c from Engineer_Schedule__c where ( Service_Agent_Information__r.User__c IN:listOfOwnerId) OR Type__c='Duty Manager']){
                    if(es.Type__c == 'Duty Manager' && timeNowPst>=es.start_time__c && timeNowPst <=es.End_Time__c){
                        if(es.Product__c == 'ZPA'){
                            zpaDutyManager = es.Duty_Manager__r.Email;
                            if(es.Backup_Duty_Manager__c!=null && es.Backup_Duty_Manager__r.Email !=null){
                                zpaBackupDutyManagerEmail = es.Backup_Duty_Manager__r.Email;
                            }
                        }
                        else{
                            if(es.Segment__c == 'Premium Plus'){
                                ziaPremiumPlusDutyManagerEmail = es.Duty_Manager__r.Email;
                                if(es.Backup_Duty_Manager__c!=null && es.Backup_Duty_Manager__r.Email !=null){
                                    ziaPremiumPlusBackupDutyManagerEmail = es.Backup_Duty_Manager__r.Email;
                                }
                            }
                            else{
                                ziaPremiumDutyManagerEmail = es.Duty_Manager__r.Email;
                                if(es.Backup_Duty_Manager__c!=null && es.Backup_Duty_Manager__r.Email !=null){
                                    ziaPremiumBackupDutyManagerEmail = es.Backup_Duty_Manager__r.Email;
                                }
                            }
                            
                        }
                    }
                    else{
                        if(!setOfActiveUserId.contains(es.Service_Agent_Information__r.User__c)){
                            Boolean isShiftOff = false;
                            Timezone casePrefTimezoneTAC = Timezone.getTimeZone(es.Service_Agent_Information__r.Timezone__c);
                            DateTime currentTimePrefTimeZoneTAC = Datetime.now().addSeconds((casePrefTimezoneTAC.getOffset(Datetime.now())/1000));
                            Integer hourNowTAC = currentTimePrefTimeZoneTAC.hourGmt();
                            String formattedTimeTAC = System.now().format('EEE, yyyy-MM-dd HH:mm:ss',es.Service_Agent_Information__r.Timezone__c);
                            String dayOfWeek_currentTimePrefTimeZoneTAC = formattedTimeTAC.split(',').get(0);   
                            Integer hrDayStartTAC = Integer.valueOf(Label.SupportTAC_HourDayStart);
                            Integer hrDayEndTAC = Integer.valueOf(Label.SupportTAC_HourDayEnd);
                            
                            if(es.Service_Agent_Information__r.Shift_Off_Days__c!= null){
                                String currentDay = daysOfWeek.get(dayOfWeek_currentTimePrefTimeZoneTAC);
                                if(es.Service_Agent_Information__r.Shift_Off_Days__c.contains(currentDay)){
                                    isShiftOff = true;
                                    setOfOutShiftUsers.add(es.Service_Agent_Information__r.User__c);
                                }
                            }
                            if(!isShiftOff){
                                if(hourNowTAC >= hrDayStartTAC && hourNowTAC < hrDayEndTAC){
                                    setOfActiveUserId.add(es.Service_Agent_Information__r.User__c);
                                }
                            }
                            /*if((timeNowPst>=es.start_time__c && timeNowPst <=es.End_Time__c) || (timeTwoHoursLater>=es.start_time__c && timeTwoHoursLater <=es.End_Time__c)){
setOfActiveUserId.add(es.Service_Agent_Information__r.User__c);
}*/
                            system.debug('setOfActiveUserId-->'+setOfActiveUserId);
                        }
                    }
                }
                
                for(User usr: [select id, Email, ManagerId, Manager.Email, TimeZoneSidKey from User where Id IN:listOfOwnerId]){
                    mapOfUserAndEmail.put(usr.Id, usr.Email);
                    if(usr.ManagerId!=null){
                        mapOfUserAndManagerEmail.put(usr.Id, usr.manager.Email);
                    }
                    if(!setOfActiveUserId.contains(usr.Id) && !setOfOutShiftUsers.contains(usr.Id)){
                        Timezone casePrefTimezoneTAC = Timezone.getTimeZone(usr.TimeZoneSidKey);
                        DateTime currentTimePrefTimeZoneTAC = Datetime.now().addSeconds((casePrefTimezoneTAC.getOffset(Datetime.now())/1000));
                        Integer hourNowTAC = currentTimePrefTimeZoneTAC.hourGmt();
                        String formattedTimeTAC = System.now().format('EEE, yyyy-MM-dd HH:mm:ss',usr.TimeZoneSidKey);
                        String dayOfWeek_currentTimePrefTimeZoneTAC = formattedTimeTAC.split(',').get(0);   
                        Integer hrDayStartTAC = Integer.valueOf(Label.SupportTAC_HourDayStart);
                        Integer hrDayEndTAC = Integer.valueOf(Label.SupportTAC_HourDayEnd);
                        if(hourNowTAC >= hrDayStartTAC && hourNowTAC < hrDayEndTAC){
                            setOfActiveUserId.add(usr.Id);
                        }
                    }
                }
                system.debug('Active User-->'+setOfActiveUserId);
            }
            List<QueueSObject> queues = new List<QueueSObject>([SELECT id,QueueId FROM QueueSObject WHERE sObjectType = 'Case' AND Queue.DeveloperName='ZPA_Product_Queue']);
            String ZPAQueueId = !queues.isEmpty()?queues.get(0).queueId:'';
            List<Messaging.SingleEmailMessage> notifyMailList = new List<Messaging.SingleEmailMessage>();
            EmailTemplate emailTemplate = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where DeveloperName = 'Automated_Trigger_Case_Notifiication'];
            Messaging.SingleEmailMessage mail =  new Messaging.SingleEmailMessage();
            //mail.setTemplateId(emailTemplate.Id);
            mail.settargetObjectId([select id from Contact limit 1].Id);
            mail.setTreatTargetObjectAsRecipient(false);
            OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'support@zscaler.com'];
            if(owea.size() > 0){
                mail.setOrgWideEmailAddressId(owea.get(0).Id);  
            }
            
            //Skills Calculation Logic - Start
            Map<Id, Account> accmap = new Map<Id, Account>();
            if(!listOfAccountId.isEmpty()){
                for(Account acc: [Select Id, Customer_Support_Segment__c, Prospect_Type__c, Exclude_Partner_Support__c, Support_Type__c, District__c from Account where Id in :listOfAccountId]){
                    accmap.put(acc.Id, acc);
                }
            }
            //Skills Calculation Logic - End
            for(Case cs : newList){
                system.debug('setOfActiveUserId Inner--> '+setOfActiveUserId);
                system.debug('caseOwnerQueueOrOOO-->'+caseOwnerQueueOrOOO);
                Boolean executeOmniAssignment = false;
                if(!String.valueOf(cs.OwnerId).startsWithIgnoreCase(Label.Support_Queue_Id) && !String.valueOf(cs.OwnerId).startsWithIgnoreCase(ZPAQueueId)){
                    system.debug('Inside Another Main Condi');
                    if(!caseOwnerQueueOrOOO.isEmpty() && caseOwnerQueueOrOOO.contains(cs.Id)){
                        //Execute Logic for Moving case to Omni Channel
                        executeOmniAssignment = true;
                    }
                    else{
                        if(!setOfActiveUserId.isEmpty() && setOfActiveUserId.contains(cs.OwnerId)){
                            system.debug('Inside Email Considtion');
                            //Execute logic for Email Triggering
                            List<String> listOfAddress = new List<String>();
                            if(mapOfUserAndEmail.containsKey(cs.OwnerId) && mapOfUserAndEmail.get(cs.OwnerId) != null){
                                listOfAddress.add(mapOfUserAndEmail.get(cs.OwnerId));
                            }
                            //Anup - Commenting code for not adding Duty Managers in the email - 07/12/2022
                            if(cs.Product_New__c == 'ZPA' && !String.isBlank(zpaDutyManager)){
                                //listOfAddress.add(zpaDutyManager);
                                if(!String.isBlank(zpaBackupDutyManagerEmail)){
                                    //listOfAddress.add(zpaBackupDutyManagerEmail);
                                }
                            }
                            else{
                                String segmentForCase = cs.Customer_Segment__c;
                                if(String.isBlank(segmentForCase)){
                                    segmentForCase = 'Platinum';
                                }
                                String customerSegment = psesupportmap != null && psesupportmap.containsKey(segmentForCase) ? psesupportmap.get(segmentForCase).Primary_Support__c : '';
                                if(customerSegment == 'Premium Plus' && !String.isBlank(ziaPremiumPlusDutyManagerEmail)){
                                    //listOfAddress.add(ziaPremiumPlusDutyManagerEmail);
                                    if(!String.isBlank(ziaPremiumPlusBackupDutyManagerEmail)){
                                        //listOfAddress.add(ziaPremiumPlusBackupDutyManagerEmail);
                                    }
                                }
                                else if(customerSegment == 'Premium' && !String.isBlank(ziaPremiumDutyManagerEmail)){
                                    //listOfAddress.add(ziaPremiumDutyManagerEmail);
                                    if(!String.isBlank(ziaPremiumBackupDutyManagerEmail)){
                                        //listOfAddress.add(ziaPremiumBackupDutyManagerEmail);
                                    }
                                }
                                if(cs.Priority_Support__c == 'Backline' && mapOfUserAndManagerEmail.containsKey(cs.OwnerId)){
                                    listOfAddress.add(mapOfUserAndManagerEmail.get(cs.OwnerId));
                                }
                            }
                            
                            if(!listOfAddress.isEmpty()){
                                system.debug('listOfAddress--->'+listOfAddress);
                                mail.setToAddresses(listOfAddress);
                                String htmlBody = emailTemplate.HtmlValue;
                                htmlBody = htmlBody.replace('[AUTOMATED_REASON]', cs.Automated_Trigger_Reason__c);
                                htmlBody = htmlBody.replace('[Case_Number]', cs.CaseNumber);
                                //IBA-1335 - Start
                                if(cs.Automated_Trigger_Reason__c == 'DEFCON Escalation occurred on case'){
                                    htmlBody = htmlBody.replace('[DEFCON_INFORMATION]', 'Defcon Level : '+cs.Defcon_Level__c);
                                }
                                else{
                                    htmlBody = htmlBody.replace('[DEFCON_INFORMATION]', '');
                                }
                                //IBA-1335 - End
                                htmlBody = htmlBody.replace(']]>','');
                                mail.setHtmlBody(htmlBody);
                                String emailSubject = emailTemplate.Subject;
                                emailSubject = emailSubject.replace('[AUTOMATED_REASON]', cs.Automated_Trigger_Reason__c);
                                emailSubject = emailSubject.replace('[Case_Number]', cs.CaseNumber);
                                mail.setSubject(emailSubject);
                                mail.setWhatId(cs.Id);
                                notifyMailList.add(mail);
                            }
                        }
                        else{
                            //Execute Logic for Moving case to Omni Channel
                            executeOmniAssignment = true;
                        }
                    }
                }
                
                if(executeOmniAssignment){
                    //Skills Calculation Logic - Start
                    if(cs.Case_Type__c == 'Provisioning' || cs.Case_Type__c == 'Categorization'){
                        cs.Primary_Support__c = 'CS';
                        cs.Secondary_Support__c = '';
                        cs.Escalation_Support__c = '';
                        cs.Priority_Support__c = '';
                        cs.Product_Type__c = '';
                        //cs.Overflow_Support__c= '';//Commented as part of IBA-5471
                    }
                    else{
                        if(cs.Product_New__c == 'ZPA') {
                            cs.Product_Type__c = 'ZPA';
                        }
                        else if(nonZpaProducts.contains(cs.Product_New__c)) {
                            cs.Product_Type__c = 'Non ZPA';
                        }
                        Case_Quota_Management__c orgDefaults = Case_Quota_Management__c.getOrgDefaults();
                        Boolean isWeekendCaseRouting = AgentWorkAssignedCompCtrl.checkIfWeekend(orgDefaults);
                        system.debug('isWeekendCaseRouting --->'+isWeekendCaseRouting);
                        if(cs.Priority_Support__c != 'Backline'){
                            if(!isWeekendCaseRouting){
                                if(cs.Priority == 'Urgent (P1)'){
                                    cs.Priority_Support__c = 'P1';
                                }else{
                                    cs.Priority_Support__c = 'P2-P4';
                                }
                                //cs.Overflow_Support__c= 'No Overflow';//Commented as part of IBA-5471
                            }else{
                                cs.Priority_Support__c = '';
                                //cs.Overflow_Support__c='';//Commented as part of IBA-5471
                            }
                        }
                    }
                    if(cs.Priority_Support__c != 'Backline' && cs.Primary_Support__c != 'CS'){
                        if(cs.AccountId != null && accmap != null && accmap.containsKey(cs.AccountId) && accmap.get(cs.AccountId) != null){
                            String segmentForCase = accmap.get(cs.AccountId).Customer_Support_Segment__c;
                            String premiumPlusTypes = Label.Premium_Plus_Support_Types;
                            List<String> premiumPlusTypesList =  premiumPlusTypes.split(';');
                            //Added by Ankit - IBA-2997 - Starts
                            String premiumPlusProducts = Label.Prem_Plus_P1_Routing_Products;
                            List<String> premiumPlusProductsList =  premiumPlusProducts.split(',');
                            /*if(cs.Priority == 'Urgent (P1)' && cs.Product_New__c == 'ZIA' && (cs.Case_Type__c == 'Problem' || cs.Case_Type__c == 'Question')){
segmentForCase = 'Platinum';
}*/
                            if(!premiumPlusProductsList.isEmpty() && premiumPlusProductsList.contains(cs.Product_New__c) && cs.Priority == 'Urgent (P1)' && (cs.Case_Type__c == 'Problem' || cs.Case_Type__c == 'Question')){
                                segmentForCase = 'Platinum';
                            }
                            //Added by Ankit - IBA-2997 - Ends
                            else if(String.isBlank(segmentForCase) || accmap.get(cs.AccountId).Prospect_Type__c == 'POC'){
                                segmentForCase = 'Platinum';
                            }
                            else if(premiumPlusTypesList!=null && accmap.get(cs.AccountId).Support_Type__c!=null && premiumPlusTypesList.contains(accmap.get(cs.AccountId).Support_Type__c)){
                                segmentForCase = 'Platinum';
                            }
                            cs.Primary_Support__c = psesupportmap != null && psesupportmap.containsKey(segmentForCase) ? psesupportmap.get(segmentForCase).Primary_Support__c : '';
                            if(accmap.get(cs.AccountId).Exclude_Partner_Support__c){
                                cs.Escalation_Support__c = psesupportmap != null && psesupportmap.containsKey(segmentForCase) ? psesupportmap.get(segmentForCase).Escalation_Support__c : '';
                            }
                        }
                        else{
                            cs.Primary_Support__c = psesupportmap != null && psesupportmap.containsKey('CS') ? psesupportmap.get('CS').Primary_Support__c : '';
                            cs.Secondary_Support__c = psesupportmap != null && psesupportmap.containsKey('CS') ? psesupportmap.get('CS').Secondary_Support__c : '';
                            cs.Escalation_Support__c = psesupportmap != null && psesupportmap.containsKey('CS') ? psesupportmap.get('CS').Escalation_Support__c : '';
                            cs.Product_Type__c = '';
                            cs.Priority_Support__c = '';
                            //cs.Overflow_Support__c = '';//Commented as part of IBA-5471
                        }
                    }
                    if(cs.Primary_Support__c != 'CS'){
                        cs.Language_Support__c = '';
                        if(cs.AccountId != null && accmap != null && accmap.containsKey(cs.AccountId) && accmap.get(cs.AccountId) != null && accmap.get(cs.AccountId).District__c!=null){
                            String accountRegion = accmap.get(cs.AccountId).District__c;
                            for(String region : setOfRegionSupport){
                                if(accountRegion.containsIgnoreCase(region)){
                                    cs.Language_Support__c = psesupportmap != null && psesupportmap.containsKey(region) ? psesupportmap.get(region).Region_Support__c : '';
                                }
                            }
                            if(!accountRegion.containsIgnoreCase('Japan')){
                                cs.Secondary_Support__c = psesupportmap != null && psesupportmap.containsKey('All Regions') ? psesupportmap.get('All Regions').Secondary_Support__c : '';
                            }
                        }else{
                            cs.Secondary_Support__c = psesupportmap != null && psesupportmap.containsKey('All Regions') ? psesupportmap.get('All Regions').Secondary_Support__c : '';
                        }
                    }else{
                        cs.Language_Support__c = '';
                        cs.Secondary_Support__c = '';
                    }
                    if(cs.Preferred_Contact_Time_Zone__c!= null && tacTimeRegionMap.containsKey(cs.Preferred_Contact_Time_Zone__c) && tacTimeRegionMap.get(cs.Preferred_Contact_Time_Zone__c)!=null && tacTimeRegionMap.get(cs.Preferred_Contact_Time_Zone__c).TAC_Region__c!=null){
                        String tacRegion = tacTimeRegionMap.get(cs.Preferred_Contact_Time_Zone__c).TAC_Region__c;
                        cs.Region_Support__c = tacRegion;
                    }
                    //Skills Calculation Logic - Start
                    cs.Warm_Handoff__c = true;
                    //IBA-1367 - Start
                    if(String.valueOf(cs.Ownerid).startsWith('005') ){
                        cs.Prior_Owner__c = cs.OwnerId;
                    }
                    //IBA-1367 - End
                    if(cs.Product_New__c == 'ZPA'){
                        cs.OwnerId = ZPAQueueId;
                    }
                    else{
                        cs.OwnerId = Label.Support_Queue_Id;
                    }
                    //IBA-1265 - Start
                    Integer counter = 0;
                    if(cs.Automated_Trigger_Counter__c==null){
                        counter = 0;
                    }
                    else{
                        counter = Integer.valueOf(cs.Automated_Trigger_Counter__c) ;
                    }
                    counter += 1;
                    cs.Automated_Trigger_Counter__c = counter;
                    //IBA-1265 - End
                    //IBA-1316 - Start
                    cs.Handed_Off_Case__c = true; 
                    cs.Queue_Priority__c = '6';
                    //IBA-1316 - End
                }
            }
            
            if(!notifyMailList.isEmpty() && !Test.isRunningTest()){
                try{
                    TriggerUtility.EmailMessageAfterInsertExecuted();
                    Messaging.sendEmail(notifyMailList); 
                }catch(Exception ex){
                    system.debug('Error While sending Email to Duty manager');
                }
            }
            
            if(!feedItemList.isEmpty()){
                TriggerUtility.SkipFeedItemTriggerExecuted();
                TriggerUtility.SkipCaseCommentTriggerExecuted();
                insert feedItemList;
            }
        }
    }
    
    public static void sendReassignmentThresholdEmail(Map<Id, Case> mapOfCaseAndCaseDetail){
        String ziaPremiumDutyManagerEmail='';
        String ziaPremiumPlusDutyManagerEmail = '';
        String zpaDutyManager = '';
        String backupDutyManagerEmail = '';
        String ziaPremiumPlusBackupDutyManagerEmail = '';
        String ziaPremiumBackupDutyManagerEmail = '';
        String zpaBackupDutyManagerEmail = '';
        Map<String,String> daysOfWeek = new Map<String,String>{'Mon'=>'Monday','Tue'=>'Tuesday','Wed'=>'Wednesday','Thu'=>'Thursday','Fri'=>'Friday','Sat'=>'Saturday','Sun'=>'Sunday'};
            Timezone pstTz = Timezone.getTimeZone('America/Los_Angeles');
        DateTime currentTimePst = Datetime.now().addSeconds((pstTz.getOffset(Datetime.now())/1000));
        Integer hourNowPst = currentTimePst.hourGmt();
        Time timeNowPst = currentTimePst.timeGMT();
        String formattedTime = System.now().format('EEE, yyyy-MM-dd HH:mm:ss','America/Los_Angeles');
        String dayOfWeek_currentTimePst = formattedTime.split(',').get(0); 
        for(Engineer_Schedule__c es : [select id, Start_Time__c, End_Time__c, Day__c, Duty_Manager__c, Duty_Manager__r.Email, Backup_Duty_Manager__c, Backup_Duty_Manager__r.Email, Product__c, Segment__c, Service_Agent_Information__r.User__c, Type__c from Engineer_Schedule__c where Type__c='Duty Manager']){
            if(es.Type__c == 'Duty Manager' && timeNowPst>=es.start_time__c && timeNowPst <=es.End_Time__c){
                if(es.Product__c == 'ZPA'){
                    zpaDutyManager = es.Duty_Manager__r.Email;
                    if(es.Backup_Duty_Manager__c!=null && es.Backup_Duty_Manager__r.Email !=null){
                        zpaBackupDutyManagerEmail = es.Backup_Duty_Manager__r.Email;
                    }
                }
                else{
                    if(es.Segment__c == 'Premium Plus'){
                        ziaPremiumPlusDutyManagerEmail = es.Duty_Manager__r.Email;
                        if(es.Backup_Duty_Manager__c!=null && es.Backup_Duty_Manager__r.Email !=null){
                            ziaPremiumPlusBackupDutyManagerEmail = es.Backup_Duty_Manager__r.Email;
                        }
                    }
                    else{
                        ziaPremiumDutyManagerEmail = es.Duty_Manager__r.Email;
                        if(es.Backup_Duty_Manager__c!=null && es.Backup_Duty_Manager__r.Email !=null){
                            ziaPremiumBackupDutyManagerEmail = es.Backup_Duty_Manager__r.Email;
                        }
                    }
                }
            }
        }
        List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
        EmailTemplate emailTemplate = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where DeveloperName = 'Case_Reassignment_Counter_Surpass_Threshold'];
        Messaging.SingleEmailMessage mail =  new Messaging.SingleEmailMessage();
        mail.setTemplateId(emailTemplate.Id);
        mail.settargetObjectId([select id from Contact limit 1].Id);
        mail.setTreatTargetObjectAsRecipient(false);
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'support@zscaler.com'];
        if(owea.size() > 0){
            mail.setOrgWideEmailAddressId(owea.get(0).Id);  
        }
        Map<String, Primary_Secondary_Escalation_Support_Map__c> psesupportmap = Primary_Secondary_Escalation_Support_Map__c.getAll();
        for(Id caseId : mapOfCaseAndCaseDetail.keySet()){
            Case cs = mapOfCaseAndCaseDetail.get(caseId);
            List<String> listOfAddress = new List<String>();
            if(cs.Product_New__c == 'ZPA' && !String.isBlank(zpaDutyManager)){
                listOfAddress.add(zpaDutyManager);
                if(!String.isBlank(zpaBackupDutyManagerEmail)){
                    listOfAddress.add(zpaBackupDutyManagerEmail);
                }
            }
            else{
                String segmentForCase = cs.Customer_Segment__c;
                if(String.isBlank(segmentForCase)){
                    segmentForCase = 'Platinum';
                }
                String customerSegment = psesupportmap != null && psesupportmap.containsKey(segmentForCase) ? psesupportmap.get(segmentForCase).Primary_Support__c : '';
                if(customerSegment == 'Premium Plus' && !String.isBlank(ziaPremiumPlusDutyManagerEmail)){
                    listOfAddress.add(ziaPremiumPlusDutyManagerEmail);
                    if(!String.isBlank(ziaPremiumPlusBackupDutyManagerEmail)){
                        listOfAddress.add(ziaPremiumPlusBackupDutyManagerEmail);
                    }
                }
                else if(customerSegment == 'Premium' && !String.isBlank(ziaPremiumDutyManagerEmail)){
                    listOfAddress.add(ziaPremiumDutyManagerEmail);
                    if(!String.isBlank(ziaPremiumBackupDutyManagerEmail)){
                        listOfAddress.add(ziaPremiumBackupDutyManagerEmail);
                    }
                }
            }
            if(!listOfAddress.isEmpty()){
                system.debug('This is new Anup-->'+listOfAddress);
                mail.setToAddresses(listOfAddress);
                mail.setWhatId(cs.Id);
                mailList.add(mail);
            }
        }
        
        if(!mailList.isEmpty() && !Test.isRunningTest()){
            try{
                TriggerUtility.EmailMessageAfterInsertExecuted();
                Messaging.sendEmail(mailList); 
            }catch(Exception ex){
                system.debug('Error While sending Email to Duty Manager');
            }
        }
    } 
    //Added by Chetan IBA-1613 --Start
    public static void updateNOCSubject(List<Case> caseList,Map<Id,Case> caseMap){
        String ZNOCEmail = System.Label.ZNOC_Email;
        List<String> ZNOCEmailList= new List<String>();
        if(String.isNotBlank(ZNOCEmail)) {
            ZNOCEmailList = ZNOCEmail.split(',');
        }
        for(Case cs:caseList){
            if(((cs.Requestor_s_Email__c !=null && caseMap==null ) || (caseMap!=null && cs.Case_Created_By_Email__c !=caseMap.get(cs.Id).Case_Created_By_Email__c)) && ZNOCEmailList.contains(cs.Case_Created_By_Email__c) && !cs.Subject.startsWithIgnoreCase(label.ZNOC) && cs.RecordTypeId == caseSupportRT)
                cs.Subject= label.ZNOC+' '+ cs.Subject;
        }
    }
    //Added by Chetan IBA-1613 --End
    //Added by Chetan IBA-1749 --Start
    public static void sendEscalationEmail(List<Case> newList, Map<Id, Case> oldMap){
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        EmailTemplate template = [select id,HtmlValue,subject from EmailTemplate where DeveloperName = 'Customer_escalation_email'];
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'support@zscaler.com'];
        Id contactId=[select id from Contact limit 1].Id;
        Set<Id> accIds = new Set<Id>();
        Set<Id> caseIds = new Set<Id>();
        Map<id, String> accMap = new Map<id, String>();
        List<String> ccEmails = new List<String>();  
        for(Case cs: newList){
            if(cs.IsEscalated != oldMap.get(cs.Id).IsEscalated && cs.IsEscalated == True){
                accIds.add(cs.AccountId);
                caseIds.add(cs.Id);
            }
        }
        if(!accIds.isEmpty()){
            for(Account acc:[select id,Case_Escalation_Notification_Recipients__c from account where id in:accIds]){
                accMap.put(acc.id,acc.Case_Escalation_Notification_Recipients__c); 
            }
        }
        if(!caseIds.isEmpty()){
            for (Case cs : [select id,AccountId,Owner.Email from Case where id in:caseIds]) {
                String sendTo;
                ccEmails = new List<String>();
                if(cs.Owner.Email!=null){
                    ccEmails.add(cs.Owner.Email);
                }  
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                if(accMap!=null && accMap.containsKey(cs.AccountId) && accMap.get(cs.AccountId)!=null){
                    sendTo =accMap.get(cs.AccountId);
                }
                List<String> sendToList = new List<String>();
                if(String.isNotBlank(sendTo)) {
                    sendToList = sendTo.split(';');
                }
                if(!sendToList.isEmpty()){
                    mail.setToAddresses(sendToList);
                    mail.setCcAddresses(ccEmails);
                    if(owea.size() > 0){
                        mail.setOrgWideEmailAddressId(owea.get(0).Id);  
                    }
                    mail.setSaveAsActivity(false);
                    mail.setTargetObjectId(contactId);
                    mail.setTreatTargetObjectAsRecipient(false);
                    mail.setTemplateId(template.Id);
                    mail.setWhatId(cs.Id);    
                    mails.add(mail);
                }
            }
        }   
        Messaging.sendEmail(mails);
    }
    //Added by Chetan IBA-1749 --End
    //Added by Chetan IBA-686 -- Start
    public static void insertCaseRecordHistoryTracking(List<Case> caseList, Map<Id,Case> oldCaseMap) {
        List<Schema.FieldSetMember> fieldSetMemberList =  FieldSetQuery.readFieldSet('History_Tracking_Fields','Case');
        List<String> fieldsToTrack = new List<String>();
        Map<String,String> fieldsAPIVsLabel = new Map<String,String>();
        List<Record_History_Tracking__c> recordHistoryTrackingList = new List<Record_History_Tracking__c>();
        Id caseRecordType = Schema.SObjectType.Record_History_Tracking__c.getRecordTypeInfosByDeveloperName().get('Case').getRecordTypeId();
        try{
            if(!fieldSetMemberList.isEmpty()){
                for(Schema.FieldSetMember fieldSetMemberObj : fieldSetMemberList){
                    fieldsToTrack.add(fieldSetMemberObj.getFieldPath()); 
                    fieldsAPIVsLabel.put(fieldSetMemberObj.getFieldPath(),fieldSetMemberObj.getLabel());
                }
                for(Case cs : caseList){
                    for(String eachFieldToTrack : fieldsToTrack){
                        if(oldCaseMap.get(cs.Id).get(eachFieldToTrack) != cs.get(eachFieldToTrack)){
                            Record_History_Tracking__c newTrack = new Record_History_Tracking__c();
                            newTrack.Case__c = cs.Id;
                            newTrack.recordTypeId = caseRecordType;
                            newTrack.New_Value__c = String.valueOf(cs.get(eachFieldToTrack));
                            newTrack.old_Value__c = String.valueOf(oldCaseMap.get(cs.Id).get(eachFieldToTrack));
                            newTrack.Field_Name__c = eachFieldToTrack;
                            newTrack.Field_Label__c = fieldsAPIVsLabel.get(eachFieldToTrack);
                            recordHistoryTrackingList.add(newTrack);
                        }
                    }
                }
                if(!recordHistoryTrackingList.isEmpty()){
                    Database.Insert(recordHistoryTrackingList);
                }
            }
        }
        catch(Exception e){
            system.debug('### Exception occured in History Insertion operation.'+e);
        }
    }
    //Added by Chetan IBA-686 -- End
    
    //Defcon Escalation Code Starts
    
    //Added by Chetan - Start
    public static void sendDefconStatusChangeEmail(List<Case> newList, Map<Id, Case> oldMap){
        Id defconRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Escalation').getRecordTypeId();
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        EmailTemplate template = [select id,HtmlValue,subject from EmailTemplate where DeveloperName = 'Defcon_Current_Status_Next_Plan_Of_Action_Update_Email_Template_1669778137290'];
        Id contactId=[select id from Contact limit 1].Id;
        Set<Id> defconCaseIds = new Set<Id>();
        Map<String, String> parentCaseMap = new Map<String, String>();
        Map<String, Case> finalCaseMap = new Map<String, Case>();
        Map<String, Case> defconCaseMap = new Map<String, Case>();
        List<Id> profileIds = new List<Id>();
        for(Profile pr:[Select id,Name from Profile where Name IN ('Zscaler Partner Community User','Customer Community User Profile')]){
            profileIds.add(pr.id);
        }
        for(Case cs: newList){
            if((cs.Current_Status_Next_Plan_Of_Action__c != oldMap.get(cs.Id).Current_Status_Next_Plan_Of_Action__c) && cs.RecordTypeId==defconRecordTypeId){
                defconCaseIds.add(cs.Id);
            }
        }
        if(!defconCaseIds.isEmpty()){
            for (Case cs : [select id,ParentId,Escalated_By__r.ProfileId,Escalated_By__r.Email from Case where Id in:defconCaseIds]) {
                defconCaseMap.put(cs.Id,cs);
                parentCaseMap.put(cs.Id, cs.ParentId);
            }
        }
        if(!parentCaseMap.isEmpty()) {
            for(Case c : [SELECT id,Internal_CC_List__c,Owner.Email FROM Case WHERE Id IN : parentCaseMap.values()]) {
                finalCaseMap.put(c.Id, c);
            }
            for(Case cs : [select id,ParentId from Case where Id in:defconCaseIds]) {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                if(!profileIds.contains(defconCaseMap.get(cs.Id).Escalated_By__r.ProfileId) && defconCaseMap.get(cs.Id).Escalated_By__r.ProfileId!=null){
                    if(finalCaseMap.containsKey(cs.ParentId)) {
                        String ccList;
                        List<String> sendToList = new List<String>();
                        if(finalCaseMap.get(cs.ParentId).Internal_CC_List__c!=null){
                            ccList = finalCaseMap.get(cs.ParentId).Internal_CC_List__c; 
                        }
                        if(String.isNotBlank(ccList)) {
                            sendToList = ccList.split(';');
                        }
                        if(defconCaseMap.get(cs.Id).Escalated_By__r.Email!=null){
                            sendToList.add(defconCaseMap.get(cs.Id).Escalated_By__r.Email);
                        }
                        if(finalCaseMap.get(cs.ParentId).Owner.Email!=null){
                            sendToList.add(finalCaseMap.get(cs.ParentId).Owner.Email);
                        }
                        if(!sendToList.isEmpty()){
                            mail.setToAddresses(sendToList);
                            mail.setSaveAsActivity(false);
                            mail.setTargetObjectId(contactId);
                            mail.setTreatTargetObjectAsRecipient(false);
                            mail.setTemplateId(template.Id);
                            mail.setWhatId(cs.Id);    
                            mails.add(mail);
                        } 
                    }            
                }  
            }
        }
        if(!mails.isEmpty()){
            Messaging.sendEmail(mails);
        }
    }
    //Added by Chetan - End
    // Added by Chetan - IBA-3524 - Start, 
    //Updated logic by Bhagyalaxmi for IBA-5356
    public static void setNextUpdateDue(List<Case> caseList,Map<Id,Case> caseOldMap) {
        try {
            Id defconRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Escalation').getRecordTypeId();
            Map<String, Decimal> followUpSLAConfigMap = new Map<String, Decimal>();
            DateTime currentNextUpdateDue;
            long seconds;
            long millseconds;
            Integer min;
            Integer hour;
            Integer day;
            
            for(Defcon_Follow_Up_SLA_Configurations__mdt meta : [SELECT id, defcon_Level__c, minutes__c FROM Defcon_Follow_Up_SLA_Configurations__mdt]) {
                followUpSLAConfigMap.put(meta.defcon_Level__c, meta.minutes__c);
            }
            
            for(Case cs: caseList){
                if(cs.RecordTypeId==defconRecordTypeId){
                    if(caseOldMap == null){                   
                        if(followUpSLAConfigMap.containsKey(cs.Defcon_Level__c)) {
                            cs.Next_Update_Due__c = System.now().addMinutes(Integer.valueOf(followUpSLAConfigMap.get(cs.Defcon_Level__c)));
                        }
                    }
                    if(caseOldMap!=null && (cs.Defcon_Level__c != caseOldMap.get(cs.Id).Defcon_Level__c)) {
                        currentNextUpdateDue = cs.Next_Update_Due__c;                          
                        if(currentNextUpdateDue!=null){
                            seconds =  currentNextUpdateDue.getTime() - System.now().getTime();
                        	millseconds = seconds/1000;
                        	min = Integer.valueof(millseconds/60);
                        	hour = min/60;
                        	day = hour/24;
                            
                            if(hour<=48){
                                cs.Next_Update_Due__c = System.now().addDays(2);
                                cs.Defcon_Automation_Reason__c = addDefonAutomationReason('Defcon Level Changed',cs.Defcon_Automation_Reason__c);	                                
                            }  
                        }else if(currentNextUpdateDue==null){                            
                            cs.Defcon_Automation_Reason__c = addDefonAutomationReason('Defcon Owner Changed',cs.Defcon_Automation_Reason__c);
                            cs.Next_Update_Due__c = System.now().addDays(2); 
                        }                                                                                                                   
                        cs.Status = 'Needs Follow Up';
                    }
                
                    //Added by Bhagya for 4066 Start
                    else if(caseOldMap!=null && caseOldMap.get(cs.Id)!=null && (cs.OwnerId != caseOldMap.get(cs.Id).OwnerId) ){                        
                        currentNextUpdateDue = cs.Next_Update_Due__c;                              
                        if(currentNextUpdateDue!=null){
                            seconds =  currentNextUpdateDue.getTime() - System.now().getTime();                                               
                        	millseconds = seconds/1000;
                        	min = Integer.valueof(millseconds/60);
                        	hour = min/60;
                        	day = hour/24;
                            
                            if(hour<=48 ) {                                
                                cs.Defcon_Automation_Reason__c = addDefonAutomationReason('Defcon Owner Changed',cs.Defcon_Automation_Reason__c);
                                cs.Next_Update_Due__c = System.now().addDays(2);                            
                        	}
                        }else if(currentNextUpdateDue==null){                           
                            cs.Defcon_Automation_Reason__c = addDefonAutomationReason('Defcon Owner Changed',cs.Defcon_Automation_Reason__c);
                            cs.Next_Update_Due__c = System.now().addDays(2); 
                        }                                                                                                     
                        if(cs.Status != 'Needs Follow Up'){
                            cs.Status = 'Needs Follow Up';
                        }
                    }
                    //Added by Bhagya for 4066 End
                }
            }
        }
        catch(Exception e) {
            ZscalerErrorLogsUtility.insertlogs('CaseTriggerUtility', 'setNextUpdateDue', 'Apex', UserInfo.getUserId(), 'Service cloud', e.getStackTraceString(), e.getMessage(), e.getTypeName());
        }
    }
    // Added by Chetan - IBA-3524 - End
    
    //Added by Ankit - Defcon Project - Start
    
    //Add Defcon Entitlement on Escalation Cases on insertion
    public static void addEntitlementToDefconCases(List<Case> cases) {
        try {
            String entitlementId =  [Select Id, Name from Entitlement WHERE Name = 'Defcon Escalation Entitlement (DO NOT DELETE)' AND EndDate = null and Status = 'Active'].Id;
            Id escalationRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Escalation').getRecordTypeId();
            //Set owner of the Defcon Record as Queue
            String defconQueueId = '';
            for(QueueSObject queue : [SELECT Id, QueueId, Queue.DeveloperName, SobjectType FROM QueueSobject WHERE Queue.DeveloperName = 'Defcon_Escalation_Queue']) {
                defconQueueId = queue.QueueId;
            }
            Map<String, String> ownerManagerMap = new Map<String, String>(); 
            for(Case c: cases) {
                if(c.RecordTypeId == escalationRecordTypeId) {
                    c.EntitlementId = entitlementId;
                    if(c.Defcon_Level__c != '5') {
                        c.OwnerId = defconQueueId;
                    }
                    else {
                        ownerManagerMap.put(c.escalated_By__c,'');
                    }
                }
            }
            if(!ownerManagerMap.isEmpty()) {
                for(User u : [SELECT id, ManagerId FROM User WHERE Id IN :ownerManagerMap.keySet() AND ManagerId != '']) {
                    ownerManagerMap.put(u.id,u.ManagerId);
                }
            }
            for(Case c: cases) {
                if(c.RecordTypeId == escalationRecordTypeId && c.Defcon_Level__c == '5' && ownerManagerMap.containsKey(c.Escalated_By__c) && String.isNotBlank(ownerManagerMap.get(c.Escalated_By__c))) {
                    c.OwnerId = ownerManagerMap.get(c.escalated_By__c);
                }
            }
        }
        catch(Exception e) {
            ZscalerErrorLogsUtility.insertLogs('CaseTriggerUtility', 'addEntitlementToDefconCases', 'Apex', UserInfo.getUserId(), 'Service cloud', e.getStackTraceString(), e.getMessage(), e.getTypeName());
        }
    }
    
    //Called on before update : if Escalation Case's Defcon Level is updated, reset the milestones and Esc level
    public static void resetMilestonesOnDefconUpdate(List<Case> cases, Map<Id, Case> oldCases) {
        try {
            Id escalationRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Escalation').getRecordTypeId();
            List<String> casesMilestonesReset = new List<String>();
            List<String> followUpCasesMilestonesReset = new List<String>();
            List<String> responseCasesMilestonesReset = new List<String>();
            
            for(Case c : cases) {
                if(c.recordTypeId == escalationRecordTypeId && (c.defcon_Level__c != oldCases.get(c.id).defcon_Level__c)) {
                    c.Auto_Esc_SLA_Level_0_Cumulative_Time__c = 0;
                    c.Auto_Esc_SLA_Level_1_Cumulative_Time__c = 0;
                    c.Auto_Esc_SLA_Level_2_Cumulative_Time__c = 0;
                    c.Escalation_Level__c = 'Level 0';
                    c.Auto_Esc_SLA_Violated__c = '';
                    c.Defcon_Automation_Reason__c = removeDefonAutomationReason('Auto Esc Lev 0 Violated',c.Defcon_Automation_Reason__c);
                    c.Defcon_Automation_Reason__c = removeDefonAutomationReason('Auto Esc Lev 1 Violated',c.Defcon_Automation_Reason__c);
                    c.Defcon_Automation_Reason__c = removeDefonAutomationReason('Auto Esc Lev 2 Violated',c.Defcon_Automation_Reason__c);
                    c.Defcon_Automation_Reason__c = removeDefonAutomationReason('Defcon assigned to Manager',c.Defcon_Automation_Reason__c);
                    casesMilestonesReset.add(c.Id);
                    
                }
                if(c.recordTypeId == escalationRecordTypeId && c.status != oldCases.get(c.id).status && c.status == 'Resolved') {
                    casesMilestonesReset.add(c.Id);
                }
                if(c.recordTypeId == escalationRecordTypeId && c.Follow_Up_SLA_Violated__c  != oldCases.get(c.id).Follow_Up_SLA_Violated__c  && c.Follow_Up_SLA_Violated__c ) {
                    followUpCasesMilestonesReset.add(c.Id);
                    c.Is_Follow_Up_SLA_Violated__c = true;	    //Ram Sangati - Added for IBA-3803 change (DO NOT DELETE).
                    c.Defcon_Automation_Reason__c = addDefonAutomationReason('Follow Up SLA Violated',c.Defcon_Automation_Reason__c);
                    c.status = 'SLA Violated'; // Moved From after Update
                    c.Follow_Up_SLA_Violated__c = true;
                }
                if(c.recordTypeId == escalationRecordTypeId && c.Response_SLA_Violated__c != oldCases.get(c.id).Response_SLA_Violated__c && c.Response_SLA_Violated__c) {
                    responseCasesMilestonesReset.add(c.Id);
                    c.Defcon_Automation_Reason__c = addDefonAutomationReason('Ownership SLA Violated',c.Defcon_Automation_Reason__c);
                    c.status = 'SLA Violated'; // Moved From after Update
                    c.Response_SLA_Violated__c = true;
                }
                if(c.recordTypeId == escalationRecordTypeId && c.Next_update_Due__c != oldCases.get(c.id).Next_update_Due__c) {
                    c.Follow_Up_SLA_Violated__c = false;
                }
            }
            List<CaseMilestone> milestonesToComplete = new List<CaseMilestone>();
            
            for(CaseMilestone cm : [SELECT Id,MilestoneType.Name, startDate, caseId,targetDate, completionDate FROM
                                    CaseMilestone WHERE 
                                    caseId in :casesMilestonesReset  AND completionDate = null]) {
                                        cm.completionDate = System.now();
                                        milestonesToComplete.add(cm);
                                    }
            if(!followUpCasesMilestonesReset.isEmpty() || !responseCasesMilestonesReset.isEmpty()) {
                for(CaseMilestone cm : [SELECT Id,MilestoneType.Name, startDate, caseId,targetDate, completionDate FROM
                                        CaseMilestone WHERE 
                                        ((caseId in :followUpCasesMilestonesReset AND MilestoneType.Name='Follow Up SLA') OR
                                         (caseId in :responseCasesMilestonesReset AND MilestoneType.Name='Ownership SLA')) 
                                        AND completionDate = null]) {
                                            cm.completionDate = cm.targetDate.addSeconds(1);
                                            milestonesToComplete.add(cm);
                                        }
            }
            if(!milestonesToComplete.isEmpty()) {
                update milestonesToComplete;
            }
        }
        catch(Exception e) {
            ZscalerErrorLogsUtility.insertlogs('CaseTriggerUtility', 'resetMilestonesOnDefconUpdate', 'Apex', UserInfo.getUserId(), 'Service cloud', e.getStackTraceString(), e.getMessage(), e.getTypeName());
        }
    }
    
    //Called on before update : if Escalation Case's Status changes to Auto Esc SLA Violated, Set the Cumulative Time Fields 
    public static void setAutoEscSLACumulativeTime(List<Case> cases, Map<Id, Case> oldCases) {
        try {
            Id escalationRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Escalation').getRecordTypeId();
            Map<String, Case> defconMap = new Map<String, Case>(cases);
            Map<String, String> ownerManagerMap = new Map<String, String>(); 
            Map<String, List<String>> autoEscOwnerChangeConfig = new Map<String, List<String>>{
                '1' => new List<String>{'Level 1', 'Level 2'},
                    '2' => new List<String>{'Level 1', 'Level 2'},
                        '3' => new List<String>{'Level 2'},
                            '4' => new List<String>{'Level 2'}
            };
                
                for(Case c : cases) {
                    if(c.RecordTypeId == escalationRecordTypeId && String.valueOf(c.ownerId).startsWith('005')) {
                        ownerManagerMap.put(c.ownerId, '');
                        
                    }
                }
            Map<Id,User> userMap = new Map<Id,User>([SELECT id,Level__c,name,profile.name,IsActive,Manager.Name FROM User WHERE Manager.Name = :Label.SVP_Global_Customer_Services AND IsActive =true]);        
            List<String> gcsProfileList = System.label.Defcon_GCS_Profile_List.split(',');
            //List<String> gcsProfileList = new List<String>{'GCS Leadership Team','Customer Support - Leads - Managers','Core Sales - CSM','Core Sales - SE','Customer Community User Profile','Customer Community Admin Profile','System Administrator','Zscaler Partner Community User','TAM (Licensed)','Customer Support - External','Customer Support - Internal'};
                
                if(!ownerManagerMap.isEmpty()) {
                    for(User u : [SELECT id,managerId,manager.Level__c, manager.profile.Name,level__c FROM user WHERE Id IN : ownerManagerMap.keySet() AND managerId != '']) {
                        if(u.manager.Level__c =='EXEC' || u.manager.Level__c =='RVP' || u.manager.Level__c =='Sr.RVP' || !gcsProfileList.contains(u.manager.profile.name)){
                            ownerManagerMap.put(u.id, '');
                        }
                        else if(u.manager.Level__c == 'Director' && !userMap.containsKey(u.managerId)){
                            ownerManagerMap.put(u.id, '');
                        }
                        else if(u.manager.Level__c == 'VP' && !gcsProfileList.contains(u.manager.profile.name)){
                            ownerManagerMap.put(u.id, '');
                        }
                        else {
                            ownerManagerMap.put(u.id, u.managerId);
                        }
                    }
                }
            
            for(CaseMilestone cm : [SELECT Id, CaseId, TargetDate, startDate, IsCompleted, IsViolated, MilestoneTypeId, MilestoneType.Name FROM CaseMilestone WHERE (caseId in :defconMap.keySet() AND (MilestoneType.Name = 'Auto Esc SLA' OR MilestoneType.Name = 'Follow Up SLA' OR MilestoneType.Name = 'Ownership SLA')) AND completionDate = null]){
                Case c = defconMap.get(cm.caseId);
                Case cOld = oldCases.get(cm.caseId);
                
                
                if(c.recordTypeId == escalationRecordTypeId && (c.Auto_Esc_SLA_Violated__c != cOld.Auto_Esc_SLA_Violated__c && String.isNotBlank(c.Auto_Esc_SLA_Violated__c)) && cm.MilestoneType.Name == 'Auto Esc SLA') {
                    c.Is_Auto_Esc_SLA_Violated__c = true;		//Ram Sangati - Added for IBA-3804 change (DO NOT DELETE).
                    c.status = 'SLA Violated';
                    if(c.Escalation_Level__c != cOld.Escalation_Level__c && autoEscOwnerChangeConfig.containsKey(c.defcon_level__c) && autoEscOwnerChangeConfig.get(c.defcon_level__c).contains(c.Escalation_Level__c)) {
                        if(String.valueOf(c.ownerId).startsWith('005') && ownerManagerMap.containsKey(c.ownerId) && String.isNotBlank(ownerManagerMap.get(c.ownerId))) {
                            
                            c.Defcon_Automation_Reason__c = addDefonAutomationReason('Defcon assigned to Manager',c.Defcon_Automation_Reason__c);
                            c.OwnerId = ownerManagerMap.get(c.ownerId);
                        }
                    }
                    Long dt1Long = cm.startDate.getTime();
                    Long dt2Long = DateTime.now().getTime();
                    Long milliseconds = dt2Long - dt1Long;
                    Long seconds = milliseconds / 1000;
                    Long minutes = seconds / 60;
                    
                    if(c.Escalation_Level__c != cOld.Escalation_Level__c) {
                        if(c.Escalation_Level__c == 'Level 1') {
                            c.Auto_Esc_SLA_Violated__c = 'Level 0';
                            c.Auto_Esc_SLA_Level_0_Cumulative_Time__c += seconds;
                            c.of_hops_in_Esc_Level__c += 1;
                            c.Defcon_Automation_Reason__c = addDefonAutomationReason('Auto Esc Lev 0 Violated',c.Defcon_Automation_Reason__c);
                        }
                        else if(c.Escalation_Level__c == 'Level 2') {
                            c.Auto_Esc_SLA_Level_1_Cumulative_Time__c += seconds;
                            c.Auto_Esc_SLA_Violated__c = 'Level 1';
                            c.of_hops_in_Esc_Level__c += 1;
                            c.Defcon_Automation_Reason__c = addDefonAutomationReason('Auto Esc Lev 1 Violated',c.Defcon_Automation_Reason__c);
                        }
                    }
                    else {
                        if(c.Escalation_Level__c == 'Level 2') {
                            c.Auto_Esc_SLA_Level_2_Cumulative_Time__c += seconds;
                            c.Auto_Esc_SLA_Violated__c = 'Level 2';
                            c.Defcon_Automation_Reason__c = addDefonAutomationReason('Auto Esc Lev 2 Violated',c.Defcon_Automation_Reason__c);
                        }
                    }
                }
            }
            for(Case c : cases) {
                if(c.ownerId != oldCases.get(c.id).OwnerId && c.recordTypeId == escalationRecordTypeId) {
                    if(c.Escalation_Level__c == 'Level 0' && !c.Defcon_Automation_Reason__c.containsIgnoreCase('Auto Esc Lev 0 Violated')) {
                        c.Auto_Esc_SLA_Level_0_Cumulative_Time__c = 0;
                    }
                    else if(c.Escalation_Level__c == 'Level 1' && !c.Defcon_Automation_Reason__c.containsIgnoreCase('Auto Esc Lev 1 Violated')) {
                        c.Auto_Esc_SLA_Level_1_Cumulative_Time__c = 0;
                    }
                    else if(c.Escalation_Level__c == 'Level 2' && !c.Defcon_Automation_Reason__c.containsIgnoreCase('Auto Esc Lev 2 Violated')) {
                        c.Auto_Esc_SLA_Level_2_Cumulative_Time__c = 0;
                    }
                }
            }
        }
        catch(Exception e) {
            ZscalerErrorLogsUtility.insertlogs('CaseTriggerUtility', 'setAutoEscSLACumulativeTime', 'Apex', UserInfo.getUserId(), 'Service cloud', e.getStackTraceString(), e.getMessage(), e.getTypeName());
        }
    }
    
    //Called on after update : Complete milestones when Escalation Case is updated
    public static void completeDefconMilestones(List<Case> cases, Map<Id, Case> oldCases) {
        try {
            Id escalationRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Escalation').getRecordTypeId();
            Set<String> completeMilestoneSet = new Set<String>();
            Set<String> respCaseIds = new Set<String>();
            Set<String> autoEscCaseIds = new Set<String>();
            Set<String> followUpEscCaseIds = new Set<String>();
            
            Map<String, Case> caseMap = new Map<String, Case>(cases);
            String defconQueueId = '';
            for(QueueSObject queue : [SELECT Id, QueueId, Queue.DeveloperName, SobjectType FROM QueueSobject WHERE Queue.DeveloperName = 'Defcon_Escalation_Queue']) {
                defconQueueId = queue.QueueId;
            }
            for(Case c : cases) {
                if(c.RecordTypeId == escalationRecordTypeId) {
                    if(oldCases.containsKey(c.id) && c.ownerId != oldCases.get(c.id).ownerId) {
                        completeMilestoneSet.add(c.Id);
                        if(String.valueOf(c.ownerId).startsWith('005') && oldCases.get(c.id).ownerId == defconQueueId) {
                            respCaseIds.add(c.id);
                        }
                        //Complete Auto Esc ML when owner is changed
                        autoEscCaseIds.add(c.id);
                        
                    }
                    if(oldCases.containsKey(c.id) && c.Escalation_Level__c != oldCases.get(c.id).Escalation_Level__c) {
                        autoEscCaseIds.add(c.id);
                        
                    }
                    //NEW CODE 
                    if(String.isNotBlank(c.Defcon_Automation_Reason__c)) {
                        if((String.isBlank(oldCases.get(c.id).Defcon_Automation_Reason__c) || !oldCases.get(c.id).Defcon_Automation_Reason__c.contains('Ownership SLA Violated')) && c.Defcon_Automation_Reason__c.contains('Ownership SLA Violated')) {
                            respCaseIds.add(c.id);
                        }
                        if((String.isBlank(oldCases.get(c.id).Defcon_Automation_Reason__c) || !oldCases.get(c.id).Defcon_Automation_Reason__c.contains('Follow Up SLA Violated')) && c.Defcon_Automation_Reason__c.contains('Follow Up SLA Violated')) {
                            followUpEscCaseIds.add(c.id);
                        }
                        if((String.isBlank(oldCases.get(c.id).Defcon_Automation_Reason__c) || !oldCases.get(c.id).Defcon_Automation_Reason__c.contains('Auto Esc Lev 0 Violated')) && c.Defcon_Automation_Reason__c.contains('Auto Esc Lev 0 Violated')) {
                            autoEscCaseIds.add(c.id);
                        }
                        if((String.isBlank(oldCases.get(c.id).Defcon_Automation_Reason__c) || !oldCases.get(c.id).Defcon_Automation_Reason__c.contains('Auto Esc Lev 1 Violated')) && c.Defcon_Automation_Reason__c.contains('Auto Esc Lev 1 Violated')) {
                            autoEscCaseIds.add(c.id);
                        }
                        if((String.isBlank(oldCases.get(c.id).Defcon_Automation_Reason__c) || !oldCases.get(c.id).Defcon_Automation_Reason__c.contains('Auto Esc Lev 2 Violated')) && c.Defcon_Automation_Reason__c.contains('Auto Esc Lev 2 Violated')) {
                            autoEscCaseIds.add(c.id);
                        }
                    }
                }
            }  
            if(!respCaseIds.isEmpty() || !autoEscCaseIds.isEmpty() || !followUpEscCaseIds.isEmpty()) {
                List<CaseMilestone> caseMilestones = new List<CaseMilestone>();
                
                for(CaseMilestone cm : [SELECT Id,MilestoneType.Name, startDate, caseId,targetDate, completionDate FROM CaseMilestone WHERE (caseId in :respCaseIds OR caseId IN : followUpEscCaseIds OR caseId IN : autoEscCaseIds) AND completionDate = null]){
                    if(cm.MilestoneType.Name == 'Ownership SLA' && respCaseIds.contains(cm.caseId)) {
                        if(completeMilestoneSet.contains(cm.caseId)) {
                            cm.completionDate = System.now();
                        }
                        else {
                            cm.completionDate = cm.targetDate.addSeconds(1);
                        }
                        caseMilestones.add(cm);
                    }
                    if(cm.MilestoneType.Name == 'Auto Esc SLA' && autoEscCaseIds.contains(cm.caseId)) {
                        if(completeMilestoneSet.contains(cm.caseId)) {
                            cm.completionDate = System.now();
                        }
                        else {
                            cm.completionDate = cm.targetDate.addSeconds(1);
                        }
                        caseMilestones.add(cm);
                    }
                    if(cm.MilestoneType.Name == 'Follow up SLA' && followUpEscCaseIds.contains(cm.caseId)) {
                        cm.completionDate = cm.targetDate.addSeconds(1);
                        caseMilestones.add(cm);
                    }
                }
                if(!caseMilestones.isEmpty()){
                    update caseMilestones;   
                }
            }    
        } 
        catch(Exception e) {
            ZscalerErrorLogsUtility.insertlogs('CaseTriggerUtility', 'completeDefconMilestones', 'Apex', UserInfo.getUserId(), 'Service cloud', e.getStackTraceString(), e.getMessage(), e.getTypeName());
        }   
    } 
    
    //Called on after update : Pause and Resume Milestones when Parent Case is Updated
    public static void toggleAutoEscSLAOnDefcon(List<Case> casesNew, Map<Id, Case> caseOldMap) {
        try {
            List<string> pauseAutoEscStatuses = new List<string>{'Pending Fix Verification','Customer Callback Scheduled', 'Customer Follow Up Scheduled', 'Awaiting Fix', 'Escalated to Engineering','Closed','Closed - Duplicate','Pending Customer'};               	                 
                Id escalationRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Escalation').getRecordTypeId();
            Id supportRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Support').getRecordTypeId();
            List<String> caseIdsPauseSLA = new List<String>(); 
            List<String> caseIdsResumeSLA = new List<String>(); 
            for(Case c: casesNew) {
                if(c.status != caseOldMap.get(c.id).status && c.recordTypeId == supportRecordTypeId) {
                    if(pauseAutoEscStatuses.contains(c.Status)) {
                        caseIdsPauseSLA.add(c.Id);
                    }
                    else {
                        caseIdsResumeSLA.add(c.Id);
                    }
                }
            }
            
            Map<String, Case> escalationCases = new Map<String, Case>();
            Map<String, Case> escalationCasesResumeSLA = new Map<String, Case>();
            for(Case c : [SELECT id,parentId,Escalation_Level__c,Auto_Esc_SLA_Level_0_Cumulative_Time__c,Auto_Esc_SLA_Level_1_Cumulative_Time__c,Auto_Esc_SLA_Level_2_Cumulative_Time__c
                          FROM Case 
                          WHERE recordTypeId =: escalationRecordTypeId AND (parentId IN :caseIdsPauseSLA OR parentId IN :caseIdsResumeSLA)]) {
                              if(caseIdsPauseSLA.contains(c.parentId)) {
                                  escalationCases.put(c.Id, c);
                              }
                              else if(caseIdsResumeSLA.contains(c.parentId)) {
                                  escalationCasesResumeSLA.put(c.Id, c);
                              }
                          }
            if(!escalationCasesResumeSLA.isEmpty()) {
                update escalationCasesResumeSLA.values();
            }
            if(!escalationCases.isEmpty()) {
                completeAutoEscDefconMilestones(escalationCases);
            }
        }
        catch(Exception e) {
            ZscalerErrorLogsUtility.insertlogs('CaseTriggerUtility', 'toggleAutoEscSLAOnDefcon', 'Apex', UserInfo.getUserId(), 'Service cloud', e.getStackTraceString(), e.getMessage(), e.getTypeName());
        }
    }
    
    //Called from toggleAutoEscSLAOnDefcon: Complete Auto Esc Milestones and Set Cumulative Time
    public static void completeAutoEscDefconMilestones(Map<String, Case> cases) {
        try {
            if(!cases.isEmpty()) {
                List<CaseMilestone> caseMilestones = new List<CaseMilestone>();
                for(CaseMilestone cm : [SELECT Id, startDate, caseId,targetDate, completionDate,MilestoneType.Name FROM CaseMilestone WHERE ( caseId IN : cases.keySet()) AND completionDate = null]){
                    if(cm.MilestoneType.Name == 'Auto Esc SLA' && cases.containsKey(cm.caseId)) {
                        cm.completionDate = System.now();
                        caseMilestones.add(cm);
                        Long dt1Long = cm.startDate.getTime();
                        Long dt2Long = DateTime.now().getTime();
                        Long milliseconds = dt2Long - dt1Long;
                        Long seconds = milliseconds / 1000;
                        Long minutes = seconds / 60;
                        if(cases.get(cm.caseId).Escalation_Level__c == 'Level 0') {
                            cases.get(cm.caseId).Auto_Esc_SLA_Level_0_Cumulative_Time__c += seconds;
                        }
                        else if(cases.get(cm.caseId).Escalation_Level__c == 'Level 1') {
                            cases.get(cm.caseId).Auto_Esc_SLA_Level_1_Cumulative_Time__c += seconds;
                        }
                        else if(cases.get(cm.caseId).Escalation_Level__c == 'Level 2') {
                            cases.get(cm.caseId).Auto_Esc_SLA_Level_2_Cumulative_Time__c += seconds;
                        }
                    }
                }
                if(!caseMilestones.isEmpty()){
                    update caseMilestones;   
                    update cases.values(); 
                }
            }    
        } 
        catch(Exception e) {
            ZscalerErrorLogsUtility.insertlogs('CaseTriggerUtility', 'completeAutoEscDefconMilestones', 'Apex', UserInfo.getUserId(), 'Service cloud', e.getStackTraceString(), e.getMessage(), e.getTypeName());
        }  
    } 
    //Added by Ankit - Defcon Project - Ends
    
    
    //Added by Bhagyalaxmi - IBA-4060 - Start
    public static void closeDefconOnCaseClosure(List<Case> newList,Map<Id,Case> oldMap) {
        try {
            Set<Id> caseIdSet = new Set<Id>();               
            List<Case> listDefconsToClose = new List<Case>(); 
            List<string> listClosedStatus = new List<string>{'Closed - Resolved','Closed - No Action','Closed - No Response','Closed - Duplicate','Closed'};               	                 
                Id escRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Escalation').getRecordTypeId();
            
            //Check if Case status was changed and case was closed
            for(Case caseObj : newList){
                if(caseObj.Status != oldMap.get(caseObj.Id).Status && listClosedStatus.contains(caseObj.Status)){
                    caseIdSet.add(caseObj.Id);                
                }
            } 
            
            //Retrive Escalations related to cases
            for(Case escRecord : [SELECT Id, ParentId,RecordTypeId,Status,Root_Cause_for_DEFCON__c  FROM Case WHERE RecordTypeId=:escRecordTypeId AND ParentId IN:caseIdSet ]){
                if(escRecord.Root_Cause_for_DEFCON__c != null){
                    escRecord.Status = 'Resolved';
                    escRecord.Escalation_Resolved_By__c = UserInfo.getUserId();
                    listDefconsToClose.add(escRecord);
                }   
            }
            
            //Update Escalation Cases
            if(!listDefconsToClose.isEmpty()){
                Update listDefconsToClose;
            }
        }
        catch(Exception e) {
            ZscalerErrorLogsUtility.insertlogs('CaseTriggerUtility', 'closeDefconOnCaseClosure', 'Apex', UserInfo.getUserId(), 'Service cloud', e.getStackTraceString(), e.getMessage(), e.getTypeName());
        }        
    }
    //Added by Bhagyalaxmi - IBA-4060 - End
    
    //Added by Bhagyalaxmi - IBA-4069 - Start Runs Before Update
    public static void validateDefconOwner(List<Case> newList,Map<Id,Case> oldMap) {
        try {
            Map<Id,List<Case>> mapCaseToOwner = new Map<Id,List<Case>>();
            Id escRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Escalation').getRecordTypeId();
            List<String> gcsProfileList = System.label.Defcon_GCS_Profile_List.split(',');
            //List<String> gcsProfileList = new List<String>{'GCS Leadership Team','Customer Support - Leads - Managers','Core Sales - CSM','Core Sales - SE','Customer Community User Profile','Customer Community Admin Profile','System Administrator','Zscaler Partner Community User','TAM (Licensed)','Customer Support - External','Customer Support - Internal'};
                Map<Id,User> userMap = new Map<Id,User>([SELECT id,Level__c,name,profile.name,IsActive,Manager.Name FROM User WHERE Manager.Name = :Label.SVP_Global_Customer_Services AND IsActive =true]);        
            for(Case csObj : newList){
                if(csObj.RecordTypeId==escRecordTypeId && csObj.OwnerId !=oldMap.get(csObj.Id).OwnerId && String.valueOf(csObj.OwnerId).startsWith('005') ){                
                    if(!mapCaseToOwner.containsKey(csObj.OwnerId)) {
                        mapCaseToOwner.put(csObj.OwnerId, new List<Case>());
                    }
                    mapCaseToOwner.get(csObj.OwnerId).add(csObj);                   
                }
            }
            
            List<User> userList = [SELECT id,Level__c,name,profile.name,IsActive FROM User WHERE IsActive =true AND Id IN:mapCaseToOwner.keyset()];
            for(User ownerObj : userList){
                if(mapCaseToOwner.containsKey(ownerObj.id) && !mapCaseToOwner.get(ownerObj.id).isEmpty()) {
                    for(Case c: mapCaseToOwner.get(ownerObj.id)) {
                        if(ownerObj.Level__c =='EXEC' || ownerObj.Level__c =='RVP' || ownerObj.Level__c =='Sr.RVP' || !gcsProfileList.contains(ownerObj.profile.name)){
                            c.addError('This defcon cannot be assigned to '+ownerObj.Name);
                        }else if(ownerObj.Level__c == 'Director' && !gcsProfileList.contains(ownerObj.profile.name) /*!userMap.containsKey(ownerObj.Id)*/){
                            c.addError('This defcon cannot be assigned to '+ownerObj.Name);
                        }else if(ownerObj.Level__c == 'VP' && !gcsProfileList.contains(ownerObj.profile.name)){
                            c.addError('This defcon cannot be assigned to '+ownerObj.Name);
                        }
                    }
                }
            }
        }
        catch(Exception e) {
            ZscalerErrorLogsUtility.insertlogs('CaseTriggerUtility', 'validateDefconOwner', 'Apex', UserInfo.getUserId(), 'Service cloud', e.getStackTraceString(), e.getMessage(), e.getTypeName());
        }
    } 
    //Added by Bhagyalaxmi - IBA-4069 - End Runs Before Update
    
    // Added by Chetan - IBA-4394 - Start
    public static void setDefaultTemplateFields(List<Case> caseList,Map<Id,Case> caseOldMap) {
        try {
            Id defconRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Escalation').getRecordTypeId();
            for(Case cs: caseList){
                if(cs.RecordTypeId==defconRecordTypeId){
                    if(caseOldMap==null){
                        cs.Current_Status_Next_Plan_Of_Action__c = 'Current Status:\n Next Plan Of Action:\n Exec Summary:\n Next Steps:';
                    }
                    else if(caseOldMap!=null && caseOldMap.get(cs.Id)!=null && (cs.Current_Status_Next_Plan_Of_Action__c != caseOldMap.get(cs.Id).Current_Status_Next_Plan_Of_Action__c)) { 
                        if(cs.Current_Status_Next_Plan_Of_Action__c==null){
                            cs.Current_Status_Next_Plan_Of_Action__c='';
                        }
                        if(cs.Current_Status_Next_Plan_Of_Action__c.contains('\n') && cs.Current_Status_Next_Plan_Of_Action__c.contains('Last Update')){
                            Integer i=0;
                            List<String> summaryList = cs.Current_Status_Next_Plan_Of_Action__c.split('\n');
                            for(string substr : summaryList){                                                
                                if(substr.contains('Last Update')){
                                    List<String> strList = substr.split(':',2);
                                    String str = strList[1].replace(strList[1],String.valueOf(cs.LastModifiedDate));
                                    strList[1] = str;                           
                                    substr = String.join(strList,':');     
                                    summaryList[i] =   substr;                 
                                }
                                i++;
                            }                    
                            cs.Current_Status_Next_Plan_Of_Action__c = String.join(summaryList,'\n');
                        }else if(!cs.Current_Status_Next_Plan_Of_Action__c.contains('Last Update')){
                            cs.Current_Status_Next_Plan_Of_Action__c = cs.Current_Status_Next_Plan_Of_Action__c +'\n Last Update: '+ String.valueOf(cs.LastModifiedDate);
                        }
                    }                
                }
            }
        }
        catch(Exception e) {
            ZscalerErrorLogsUtility.insertlogs('CaseTriggerUtility', 'setDefaultTemplateFields', 'Apex', UserInfo.getUserId(), 'Service cloud', e.getStackTraceString(), e.getMessage(), e.getTypeName());
        }
    }
    // Added by Chetan - IBA-4394 - End
    
    public static String addDefonAutomationReason(String newVal, String existingVal) {
        String returnValue = ''; 
        if(String.isNotBlank(existingVal)) {
            List<String> valuesList = new List<String>();
            valuesList = existingVal.split(';');
            valuesList.add(newVal);
            Set<String> valuesSet = new Set<String>(valuesList);
            returnValue = String.join(new List<String>(valuesSet), ';');
        }
        else {
            returnValue = newVal+';';
        }
        return returnValue;
    }
    
    public static String removeDefonAutomationReason(String removeVal, String existingVal) {
        String returnValue = ''; 
        if(String.isNotBlank(existingVal)) {
            List<String> valuesList = new List<String>();
            valuesList = existingVal.split(';');
            Set<String> valuesSet = new Set<String>(valuesList);
            valuesSet.remove(removeVal);
            returnValue = String.join(new List<String>(valuesSet), ';');
        }
        else {
            returnValue = '';
        }
        return returnValue;
    }
    
    public static void reopenDefconCase(List<Case> casesNew, Map<Id, Case> caseOldMap) {
        try {
        Id escalationRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Escalation').getRecordTypeId();
        Id supportRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Support').getRecordTypeId();
        Set<String> supportCases = new Set<String>();
        Map<Id,Case> parentCaseMap = new Map<Id,Case>();
        for(Case c: casesNew) {
            if(c.recordTypeId == supportRecordTypeId && c.status != caseOldMap.get(c.id).status && caseOldMap.get(c.id).status.containsIgnoreCase('Closed') && !c.status.containsIgnoreCase('Closed')) {
               // c.IsEscalated =  true;
                supportCases.add(c.Id);
                parentCaseMap.put(c.Id,c);
            }
        }
        List<Case> defcons = new List<Case>();
        for(Case c : [SELECT id,parentId,Parent.IsEscalated,Escalation_Level__c,status FROM Case WHERE recordTypeId =: escalationRecordTypeId AND parentId IN :supportCases]) {
           
            parentCaseMap.get(c.parentId).IsEscalated = true;

            c.status = 'Re-Open';
            c.Escalation_Resolved_By__c = null;
            defcons.add(c);
        }
        if(!defcons.isEmpty()) {
            update defcons;
        }
    	}
        catch(Exception e) {
            ZscalerErrorLogsUtility.insertlogs('CaseTriggerUtility', 'reopenDefconCase', 'Apex', UserInfo.getUserId(), 'Service cloud', e.getStackTraceString(), e.getMessage(), e.getTypeName());
        }
    }
    // Added By Bhagyalaxmi for (Defcon Hypercare) IBA-5356 
    public static void UpdateParentFieldsOnDefcon(List<Case> casesNew, Map<Id, Case> caseOldMap) {       
        try {
            Map<Id,Case> mapSupportCase = new Map<Id,Case>();
            List<Case> escToUpdate = new List<Case>();

            Id caseEscalationRT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Escalation').getRecordTypeId();
            for(Case cs : casesNew){
                if(cs.RecordTypeId == caseSupportRT && ((cs.OwnerId != caseOldMap.get(cs.Id).OwnerId) || (cs.Product_New__c != caseOldMap.get(cs.Id).Product_New__c) || (cs.Priority != caseOldMap.get(cs.Id).Priority) ||  (cs.Customer_Temperature__c != caseOldMap.get(cs.Id).Customer_Temperature__c) ||(cs.AccountId != caseOldMap.get(cs.Id).AccountId) || (cs.ContactId != caseOldMap.get(cs.Id).ContactId) )){                    
                    mapSupportCase.put(cs.Id,cs);
                }
            }

            if(mapSupportCase != null){
                for(Case escRecord : [SELECT Id,ParentId,Parent.OwnerId,AccountId,ContactId,RecordTypeId,Product_New__c FROM Case WHERE ParentId IN: (mapSupportCase.keyset()) AND RecordTypeId=:caseEscalationRT ]){                    
                    escRecord.Product_New__c = mapSupportCase.get(escRecord.ParentId).Product_New__c;
                    escRecord.AccountId = mapSupportCase.get(escRecord.ParentId).AccountId;
                    escRecord.ContactId = mapSupportCase.get(escRecord.ParentId).ContactId;
                    escRecord.Priority = mapSupportCase.get(escRecord.ParentId).Priority;
                    escRecord.Customer_Temperature__c = mapSupportCase.get(escRecord.ParentId).Customer_Temperature__c;
                                        
                    escToUpdate.add(escRecord);
                }
            }

            if(!escToUpdate.isEmpty()){
                Update escToUpdate;
            }
        }Catch(Exception e){
            ZscalerErrorLogsUtility.insertlogs('CaseTriggerUtility', 'UpdateParentFieldsOnDefcon', 'Apex', UserInfo.getUserId(), 'Service cloud', e.getStackTraceString(), e.getMessage(), e.getTypeName());
        }
    }
    /* Code added for Defcon Hypercare IBA-5356 End */
    //Defcon Escalation Code Ends
}