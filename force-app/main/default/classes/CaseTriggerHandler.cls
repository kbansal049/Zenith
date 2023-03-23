/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* CaseTriggerHandler
* @description    
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Ankit Bhatnagar
* @modifiedBy     
* @maintainedBy   Zscaler
* @version        1.0
* @created        2022-12-21
* @modified       
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* vX.X            Ankit Bhatnagar
* 2023-01-11     
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
**/

public class CaseTriggerHandler extends TriggerHandler {
    
    List<Case> newCaseList;
    Map<Id, Case> newCaseMap;
    List<Case> oldCaseList;
    Map<Id, Case> oldCaseMap;
    
    //String literals that used more than 5 times
    String updateNOCSubjectStr = 'Execute_UpdateNOCSubject';
    String updateExtentisonStr = 'updateExtentison';
    String executeUpdateTAMemailStr = 'ExecuteUpdateTAMemail';
    String executeUpdateSEonCaseStr = 'ExecuteUpdateSEonCase';
    String executeCaseCloseWithActionPlanStr = 'Execute_Case_Close_with_Action_Plan';
    String executeUpdateCSMonCaseStr = 'ExecuteUpdateCSMonCase';
    String executeTAMReassignmentStr = 'Execute_TAM_Reassignment';
    String executeCollaboratorEmailListStr = 'Execute_CollaboratorEmailList';
    String updateAccountDataTimeStr = 'UpdateAccountDataTime';
    String executeCCtoCaseTeamStr = 'Execute_CC_toCaseTeam';
    String executeCaseTAMNotesHistoryStr = 'Execute_Case_TAM_Notes_History';
    String executedCustomerScroceCardStr = 'Executed_CustomerScroceCard';
    
    /**
     * This is CaseTriggerHandler constructor
     * @return   return description
     */
    public CaseTriggerHandler() {
        newCaseList = (List<Case>)Trigger.new;
        newCaseMap = (Map<Id, Case>) Trigger.newMap;
        oldCaseList = (List<Case>)Trigger.old;
        oldCaseMap = (Map<Id, Case>) Trigger.oldMap;
    }
    
    /**
     * This method gets executed when Before Insert trigger event fired
     */
    public override void beforeInsert() {
        if(!TriggerUtility.isCaseBeforeInsertExecuted()){
            Map<String, Triggers_Switch__c> tsmap = Triggers_Switch__c.getAll();
            
            CaseTriggerHelper.convertIntegrationCasestoSupport(newCaseList);
            CaseTriggerHelper.assignStatusStartDate(newCaseList);
            
            if(tsmap.containsKey(updateNOCSubjectStr) 
                && tsmap.get(updateNOCSubjectStr) != null 
                && tsmap.get(updateNOCSubjectStr).Execute__c){
                CaseTriggerHelper.updateNOCSubject(newCaseList, null);
            }
            
            //Added by Chetan CR#2268 Start
            if(tsmap.containsKey('Execute_CreateContactUnderAccount') 
                && tsmap.get('Execute_CreateContactUnderAccount') != null
                && tsmap.get('Execute_CreateContactUnderAccount').Execute__c){
                CaseTriggerHelper.createContactUnderAccount(newCaseList);
            }
            //Added by Chetan CR#2268 End
            
            CaseTriggerHelper.assignAccountforSupportCase(newCaseList);
            CaseTriggerHelper.assignCustomerScoreParameters(newCaseList);
            if(tsmap.containsKey('Execute_Case_SkillAssignment') 
                && tsmap.get('Execute_Case_SkillAssignment') != null
                && tsmap.get('Execute_Case_SkillAssignment').Execute__c 
                && !TriggerUtility.isCaseSkillAssignmentExecuted()){
                CaseTriggerHelper.assignCasesbySkill_TamRouting(newCaseList);
            }
            if(tsmap.containsKey('Execute_Case_Entitlement_Assignment') 
                && tsmap.get('Execute_Case_Entitlement_Assignment') != null 
                && tsmap.get('Execute_Case_Entitlement_Assignment').Execute__c 
                && !TriggerUtility.isCaseEntitlementAssigned()){
                CaseTriggerHelper.assignEntitlementtoCase(newCaseList);
            }
            
            if(tsmap.containsKey(updateExtentisonStr) 
                && tsmap.get(updateExtentisonStr) != null 
                && tsmap.get(updateExtentisonStr).Execute__c 
                && !TriggerUtility.isUpdateCaseAccountExtension()){       
                CaseTriggerHelper.updateExtentison(newCaseList, null);
            }
            
            if(tsmap.containsKey(executeUpdateTAMemailStr) 
                && tsmap.get(executeUpdateTAMemailStr) != null 
                && tsmap.get(executeUpdateTAMemailStr).Execute__c 
                && !TriggerUtility.isUpdateTAMemailExecuted()){
                CaseTriggerHelper.updateTAMemail(newCaseList);
            }
            
            // Added by Gurjinder : CR# 125 :Start
            if(tsmap.containsKey(executeUpdateSEonCaseStr) 
                && tsmap.get(executeUpdateSEonCaseStr) != null 
                && tsmap.get(executeUpdateSEonCaseStr).Execute__c 
                && !TriggerUtility.isUpdateSEonCaseExecuted()){
                CaseTriggerHelper.updateSEonCase(newCaseList);
            }
            // Added by Gurjinder : CR# 125 :End
            
            // Added by Chetan : CR# 2842 :Start
            if(tsmap.containsKey('Execute_UpdateCustomerSupportAlias') 
                && tsmap.get('Execute_UpdateCustomerSupportAlias') != null 
                && tsmap.get('Execute_UpdateCustomerSupportAlias').Execute__c){
                CaseTriggerHelper.updateCustomerSupportAlias(newCaseList);
            }
            // Added by Chetan : CR# 2842 :End
            
            //Added by Viral : CR# 251
            if(tsmap.containsKey('ExecuteUpdateOriginalTAMdetails') 
                && tsmap.get('ExecuteUpdateOriginalTAMdetails') != null 
                && tsmap.get('ExecuteUpdateOriginalTAMdetails').Execute__c 
                && !TriggerUtility.isUpdateOriginalTAMexecuted()){
                CaseTriggerHelper.fillTAMDetails(newCaseList);
            }
            if(tsmap.containsKey(executeCaseCloseWithActionPlanStr) 
                && tsmap.get(executeCaseCloseWithActionPlanStr) != null 
                && tsmap.get(executeCaseCloseWithActionPlanStr).Execute__c 
                && !TriggerUtility.isCaseCloseCompleteActionPlanExecuted()){   
                CaseTriggerHelper.checkActionPlanIsCloseForCase(newCaseList, null);
            }
            
            //Added by Swathi : CR# 1008 Start
            if(tsmap.containsKey(executeUpdateCSMonCaseStr) 
                && tsmap.get(executeUpdateCSMonCaseStr) != null 
                && tsmap.get(executeUpdateCSMonCaseStr).Execute__c 
                && !TriggerUtility.isUpdateCSMonCaseExecuted()){
                CaseTriggerHelper.updateCSMOnCase(newCaseList);
            }
            //Added by Swathi : CR# 1008 End
            
            //Added By Anup : TAM Reassignment - Start
            if(tsmap.containsKey(executeTAMReassignmentStr) 
                && tsmap.get(executeTAMReassignmentStr) != null 
                && tsmap.get(executeTAMReassignmentStr).Execute__c){
                CaseTriggerHelper.checkTAMReassignment(newCaseList, null);
            }
            //Added By Anup : TAM Reassignment - End
            
            //Added by Anup : CR#1702 - Start
            if(tsmap.containsKey(executeCollaboratorEmailListStr) 
                && tsmap.get(executeCollaboratorEmailListStr) != null 
                && tsmap.get(executeCollaboratorEmailListStr).Execute__c){
                CaseTriggerHelper.validateAndUpdateCustomerCCList(newCaseList, null);
            }
            //Added by Anup : CR#1702 - End
            
            // Added by Ankit Bhatagar : C# 2750 Start
            if(tsmap.containsKey('Execute_setRequestType') 
                && tsmap.get('Execute_setRequestType') != null 
                && tsmap.get('Execute_setRequestType').Execute__c){
                CaseTriggerHelper.setRequestType(newCaseList);
            }
            // Added by Ankit Bhatagar : C# 2750 End
            
            // Added by Ankit : CR# 2958 Start
            if(tsmap.containsKey('Execute_addDefaultProdOnSFDCCases') 
                && tsmap.get('Execute_addDefaultProdOnSFDCCases') != null 
                && tsmap.get('Execute_addDefaultProdOnSFDCCases').Execute__c){
                CaseTriggerHelper.addDefaultProductOnSFDCSupportCases(newCaseList);
            }
            // Added by Ankit : CR# 2958 End
            
            //Added by Ankit - Defcon Project - start
            List<Case> defconCaseList = GCSCommonUtility.getDefconCases(newCaseList);
            if(!defconCaseList.isEmpty()) {
                CaseTriggerHelper.setDefconNextUpdateDue(defconCaseList, null);
                CaseTriggerHelper.setDefaultNextPlanOfActionTemplateFields(defconCaseList, null);
                CaseTriggerHelper.addEntitlementToDefconCases(defconCaseList);
            }
            //Added by Ankit - Defcon Project - Ends
        }
    }
    
    /**
     * This method gets executed when Before Update trigger event fired
     */
    public override void beforeUpdate() {
        if(!TriggerUtility.isCaseBeforeUpdateExecuted()){
            Map<String, Triggers_Switch__c> tsmap = Triggers_Switch__c.getAll();
            
            //Added by Anup : CR#2195 - Start
            if(tsmap.containsKey('Execute_Partner_Support_Validation') 
                && tsmap.get('Execute_Partner_Support_Validation') != null 
                && tsmap.get('Execute_Partner_Support_Validation').Execute__c){
                CaseTriggerHelper.validateExcludePartnerCaseAssignment(newCaseList, oldCaseMap);
            }
            //Added by Anup : CR#2195 - End
            if(tsmap.containsKey(updateNOCSubjectStr) 
                && tsmap.get(updateNOCSubjectStr) != null 
                && tsmap.get(updateNOCSubjectStr).Execute__c){
                CaseTriggerHelper.updateNOCSubject(newCaseList, oldCaseMap);
            }
            CaseTriggerHelper.changeAccountofSupportCase((List<Case>)Trigger.new, (Map<Id,Case>)Trigger.oldMap); 
            
            if(tsmap.containsKey('Execute_Case_Escalation') 
                && tsmap.get('Execute_Case_Escalation') != null 
                && tsmap.get('Execute_Case_Escalation').Execute__c 
                && !TriggerUtility.isskipCaseEscalationExecuted()){
                CaseTriggerHelper.escalateCase(newCaseList, oldCaseMap);
            }
            CaseTriggerHelper.assignNewStartDateforStatus((List<Case>)Trigger.new, (Map<Id,Case>)Trigger.oldMap);
            CaseTriggerHelper.assignCustomerScoreParameters(newCaseList);
            CaseTriggerHelper.updatePriorOwnerofCase(newCaseList, oldCaseMap);
            
            if(tsmap.containsKey(executeUpdateTAMemailStr) 
                && tsmap.get(executeUpdateTAMemailStr) != null 
                && tsmap.get(executeUpdateTAMemailStr).Execute__c 
                && !TriggerUtility.isUpdateTAMemailExecuted()){
                CaseTriggerHelper.updateTAMemail(newCaseList);
            }
            
            // Added by Gurjinder : CR# 125 :Start
            if(tsmap.containsKey(executeUpdateSEonCaseStr) 
                && tsmap.get(executeUpdateSEonCaseStr) != null 
                && tsmap.get(executeUpdateSEonCaseStr).Execute__c 
                && !TriggerUtility.isUpdateSEonCaseExecuted()){
                CaseTriggerHelper.updateSEonCase(newCaseList);
            }
            if(tsmap.containsKey(updateExtentisonStr) 
                && tsmap.get(updateExtentisonStr) != null 
                && tsmap.get(updateExtentisonStr).Execute__c 
                && !TriggerUtility.isUpdateCaseAccountExtension()){
                CaseTriggerHelper.updateExtentison(newCaseList, oldCaseMap);
            }
            // Added by Gurjinder : CR# 125 :End
            
            //Added by Anup : CR# 686  : Start
            if(tsmap != null && !tsmap.isEmpty() 
                && tsmap.containsKey('Execute_AgentWork_Trigger')
                && tsmap.get('Execute_AgentWork_Trigger') != null 
                && tsmap.get('Execute_AgentWork_Trigger').Execute__c 
                && !TriggerUtility.isManualCaseAssignExecuted()){
                CaseTriggerHelper.updateManualRoutingOfCase(newCaseList, oldCaseMap);
            }
            //Added by Anup : CR# 686  : End
            
            if(tsmap.containsKey(executeCaseCloseWithActionPlanStr) 
                && tsmap.get(executeCaseCloseWithActionPlanStr) != null 
                && tsmap.get(executeCaseCloseWithActionPlanStr).Execute__c 
                && !TriggerUtility.isCaseCloseCompleteActionPlanExecuted()){   
                CaseTriggerHelper.checkActionPlanIsCloseForCase(newCaseList, oldCaseMap);
            }
            
            //Added by Swathi : CR# 1008 Start
            if(tsmap.containsKey(executeUpdateCSMonCaseStr) 
                && tsmap.get(executeUpdateCSMonCaseStr) != null 
                && tsmap.get(executeUpdateCSMonCaseStr).Execute__c 
                && !TriggerUtility.isUpdateCSMonCaseExecuted()){
                CaseTriggerHelper.updateCSMonCase(newCaseList);
            }
            //Added by Swathi : CR# 1008 End
            
            //Added By Anup : TAM Reassignment - Start
            if(tsmap.containsKey(executeTAMReassignmentStr) 
                && tsmap.get(executeTAMReassignmentStr) != null 
                && tsmap.get(executeTAMReassignmentStr).Execute__c 
                && !TriggerUtility.isTAMReassignmentExecuted()){
                CaseTriggerHelper.checkTAMReassignment(newCaseList, oldCaseMap);
            }
            //Added By Anup : TAM Reassignment - End
            
            //Added by Anup : CR#1702 - Start
            if(tsmap.containsKey(executeCollaboratorEmailListStr) 
                && tsmap.get(executeCollaboratorEmailListStr) != null 
                && tsmap.get(executeCollaboratorEmailListStr).Execute__c){
                CaseTriggerHelper.validateAndUpdateCustomerCCList(newCaseList, oldCaseMap);
            }
            //Added by Anup : CR#1702 - End
            
            //CR#3298 TTC TTR Project Added by Chetan-Start
            if(tsmap.containsKey('Execute_UpdateResolutionState') 
                && tsmap.get('Execute_UpdateResolutionState') != null 
                && tsmap.get('Execute_UpdateResolutionState').Execute__c){
                CaseTriggerHelper.updateResolutionState(newCaseList, oldCaseMap);
            }
            //CR#3298 TTC TTR Project Added by Chetan-End
            
            //Added by Anup - Omni Overhaul - Start
            CaseTriggerHelper.updatePrioritySupportOfCase(newCaseList, oldCaseMap);
            //Added by Anup - Omni Overhaul - End
            
            //CR#4095 Added by Chetan-Start  
            if(tsmap.containsKey('Execute_UpdatePendingCustomerTimestamp') 
                && tsmap.get('Execute_UpdatePendingCustomerTimestamp') != null 
                && tsmap.get('Execute_UpdatePendingCustomerTimestamp').Execute__c){
                CaseTriggerHelper.updatePendingCustomerTimestamp(newCaseList, oldCaseMap);
            } 
            //CR#4095 Added by Chetan-End
            
            //Handoff-Automation - Anup - Start
            CaseTriggerHelper.caseHandoffAssignment(newCaseList, oldCaseMap);
            //Handoff-Automation - Anup - End
            
            //IBA-2679 - Change starts here 
            CaseTriggerHelper.setPriorOwner(newCaseList, oldCaseMap);
            
            //Defcon Changes - Start
                CaseTriggerHelper.reopenDefconCase(newCaseList, oldCaseMap);
                CaseTriggerHelper.setDefconNextUpdateDue(newCaseList, oldCaseMap);
                CaseTriggerHelper.setDefaultNextPlanOfActionTemplateFields(newCaseList, oldCaseMap);
                
                //Added by Ankit - Defcon Project - start
                CaseTriggerHelper.setAutoEscSLACumulativeTime(newCaseList, oldCaseMap);
                CaseTriggerHelper.resetMilestonesOnDefconUpdate(newCaseList, oldCaseMap);
                //Added by Ankit - Defcon Project - End
                
                //Added By Bhagyalaxmi - 4069- Start
                CaseTriggerHelper.validateDefconOwnerBeforeDefconOwnershipChange(newCaseList, oldCaseMap);
                //Added By Bhagyalaxmi - 4069- End
            //Defcon Changes - End

            //Added by Ankit - IBA-7948 starts
            CaseTriggerHelper.caseOwnerOOOValidation(newCaseList, oldCaseMap);
            //Added by Ankit - IBA-7948 ends

            TriggerUtility.CaseBeforeUpdateExecuted();
        } 
    }
    
    /**
     * This method gets executed when After Insert trigger event fired
     */
    public override void afterInsert() {
        if(!TriggerUtility.isCaseAfterInsertExecuted()){
            Map<String, Triggers_Switch__c> tsmap = Triggers_Switch__c.getAll();
            
            // CR# 180 : Abhishek : Short term fixes for CC List : Start
            if(tsmap.containsKey(executeCCtoCaseTeamStr) 
                && tsmap.get(executeCCtoCaseTeamStr) != null 
                && tsmap.get(executeCCtoCaseTeamStr).Execute__c
                && !TriggerUtility.isCaseCCtoTeamExecuted()){
                CaseTriggerHelper.cctoCaseTeamafterInsert(newCaseList);
            }
            // CR# 180 : Abhishek : Short term fixes for CC List : End
            
            if(tsmap.containsKey('Execute_Case_Description_to_Comment') 
                && tsmap.get('Execute_Case_Description_to_Comment') != null 
                && tsmap.get('Execute_Case_Description_to_Comment').Execute__c 
                && !TriggerUtility.isCaseDesctoCommentExecuted()){
                CaseTriggerHelper.makeCaseDescriptiontoComment(newCaseList);
            }
            
            if(tsmap.containsKey(executeCaseTAMNotesHistoryStr) 
                && tsmap.get(executeCaseTAMNotesHistoryStr) != null 
                && tsmap.get(executeCaseTAMNotesHistoryStr).Execute__c 
                && !TriggerUtility.isCaseTAMNotesHistoryExecuted()){
                CaseTriggerHelper.createTAMNotesHistory(newCaseList, null);
            }
            
            if(tsmap.containsKey(updateAccountDataTimeStr) 
                && tsmap.get(updateAccountDataTimeStr) != null 
                && tsmap.get(updateAccountDataTimeStr).Execute__c 
                && !TriggerUtility.isUpdateAccountDataTime()){
                TriggerUtility.stopUpdateAccountDataTime();
                CaseTriggerHelper.updateTAMWeeklyDateTime(newCaseList, null);
            }
            
            //Added by Swathi : CR1408 start
            if(tsmap.containsKey(executedCustomerScroceCardStr) 
                && tsmap.get(executedCustomerScroceCardStr) != null 
                && tsmap.get(executedCustomerScroceCardStr).Execute__c 
                && !TriggerUtility2.isUpdateCustomerScroceCardValueExecuted()){
                CaseTriggerHelper.updateCustomerScroceCard(newCaseList, null);
            }
            //Added by Swathi : CR1408 End
            
            //Added by Ankit Bhatnagar : TAM Routing implementation Start
            CaseTriggerHelper.updateDailyQuota(newCaseList, null);
            //Added by Ankit Bhatnagar : TAM Routing implementation End
        }
    }
    
    /**
     * This method gets executed when After Update trigger event fired
     */
    public override void afterUpdate() {
        if(!TriggerUtility.isCaseAfterUpdateExecuted()){
            Map<String, Triggers_Switch__c> tsmap = Triggers_Switch__c.getAll();
            
            // CR# 180 : Abhishek : Short term fixes for CC List : Start
            if(tsmap.containsKey(executeCCtoCaseTeamStr)
                && tsmap.get(executeCCtoCaseTeamStr) != null 
                && tsmap.get(executeCCtoCaseTeamStr).Execute__c 
                && !TriggerUtility.isCaseCCtoTeamExecuted()){
                CaseTriggerHelper.cctoCaseTeamafterUpdate(newCaseList, oldCaseMap);
            }
            // CR# 180 : Abhishek : Short term fixes for CC List : End
            
            if(tsmap.containsKey('Execute_SendEscalationEmail') 
                && tsmap.get('Execute_SendEscalationEmail') != null 
                && tsmap.get('Execute_SendEscalationEmail').Execute__c){
                CaseTriggerHelper.sendEscalationEmail(newCaseList, oldCaseMap);
            }
            
            if(tsmap.containsKey('Execute_Escalation_Notes_Creation') 
                && tsmap.get('Execute_Escalation_Notes_Creation') != null 
                && tsmap.get('Execute_Escalation_Notes_Creation').Execute__c 
                && !TriggerUtility.isCaseEscalationNotesExecuted()){
                CaseTriggerHelper.escalationNotesCreation(newCaseList, oldCaseMap);
            }
            
            if(tsmap.containsKey('Execute_Escalation_History_Creation') 
                && tsmap.get('Execute_Escalation_History_Creation') != null 
                && tsmap.get('Execute_Escalation_History_Creation').Execute__c 
                && !TriggerUtility.isCaseEscalationHistoryExecuted()){
                CaseTriggerHelper.escalationHistoryCreation(newCaseList, oldCaseMap);
            }
            
            if(tsmap.containsKey('Execute_Case_Status_History') 
                && tsmap.get('Execute_Case_Status_History') != null 
                && tsmap.get('Execute_Case_Status_History').Execute__c 
                && !TriggerUtility.isCaseStatusHistoryExecuted()){
                CaseTriggerHelper.caseStatusChangeManagement(newCaseList, oldCaseMap);
            }
            
            if(tsmap.containsKey('Execute_Manual_SLA') 
                && tsmap.get('Execute_Manual_SLA') != null 
                && tsmap.get('Execute_Manual_SLA').Execute__c 
                && !TriggerUtility.isManualSLAExecuted()){
                CaseTriggerHelper.manualSLAChange(newCaseList, oldCaseMap);
            }
            
            if(tsmap.containsKey('Execute_Get_Feedback') 
                && tsmap.get('Execute_Get_Feedback') != null 
                && tsmap.get('Execute_Get_Feedback').Execute__c 
                && !TriggerUtility.isGetFeedbackExecuted()){
                CaseTriggerHelper.getFeedbackSurveyCreation(newCaseList, oldCaseMap);
            }
            if(tsmap.containsKey('CloseMilestonesonCaseClose') 
                && tsmap.get('CloseMilestonesonCaseClose') != null 
                && tsmap.get('CloseMilestonesonCaseClose').Execute__c 
                && !TriggerUtility.isCloseMilestonesonCaseCloseExecuted()){
                CaseTriggerHelper.closeMilestonesonCaseClosure(newCaseList, oldCaseMap);
            }
            
            //Added by Gurjinder for update details on Master Case:Start
            if(tsmap.containsKey('UpdateDetailsonMasterCase') 
                && tsmap.get('UpdateDetailsonMasterCase') != null 
                && tsmap.get('UpdateDetailsonMasterCase').Execute__c 
                && !TriggerUtility.isUpdateDetailsonMasterCaseExecuted()){
                CaseTriggerHelper.updateDetailsOnMasterCase(newCaseList, oldCaseMap);
            }
            //Added by Gurjinder for update details on Master Case:End
            
            if(tsmap.containsKey(updateAccountDataTimeStr) 
                && tsmap.get(updateAccountDataTimeStr) != null 
                && tsmap.get(updateAccountDataTimeStr).Execute__c 
                && !TriggerUtility.isUpdateAccountDataTime()){
                TriggerUtility.stopUpdateAccountDataTime();
                CaseTriggerHelper.updateTAMWeeklyDateTime(newCaseList, oldCaseMap);
            }
            
            //Added by Anup : CR1022 - Start
            if(tsmap.containsKey('Execute_Sync_CaseBA_With_CR') 
                && tsmap.get('Execute_Sync_CaseBA_With_CR') != null 
                && tsmap.get('Execute_Sync_CaseBA_With_CR').Execute__c 
                && !TriggerUtility.isSyncBAOnCrExecuted()){
                CaseTriggerHelper.syncBusinessAnalystWithCR(newCaseList, oldCaseMap);
            }
            //Added by Anup : CR1022 - End
            
            if(tsmap.containsKey(executeCaseTAMNotesHistoryStr) 
                && tsmap.get(executeCaseTAMNotesHistoryStr) != null 
                && tsmap.get(executeCaseTAMNotesHistoryStr).Execute__c 
                && !TriggerUtility.isCaseTAMNotesHistoryExecuted()){
                CaseTriggerHelper.createTAMNotesHistory(newCaseList, null);
            }
            
            //Viral : To sync back updates to Case Integration record
            if(tsmap.containsKey('Execute_Case_Integration_Updation') 
                && tsmap.get('Execute_Case_Integration_Updation') != null 
                && tsmap.get('Execute_Case_Integration_Updation').Execute__c 
                && !TriggerUtility.isExecuteCaseAfterUpdateCaseIntegartionExecuted()) {
                TriggerUtility.executeCaseAfterUpdateCaseIntegartionSetTrue();
                CaseTriggerHelper.updateCaseIntegration(newCaseList, oldCaseMap);
            }
            
            //Added by Swathi : CR1408 start
            if(tsmap.containsKey(executedCustomerScroceCardStr) 
                && tsmap.get(executedCustomerScroceCardStr) != null 
                && tsmap.get(executedCustomerScroceCardStr).Execute__c 
                && !TriggerUtility2.isUpdateCustomerScroceCardValueExecuted()){
                CaseTriggerHelper.updateCustomerScroceCard(newCaseList, oldCaseMap);
            }
            //Added by Swathi : CR1408 End
            
            //Added by Anup : CR#502 - Start
            if(tsmap.containsKey('Execute_TAM_Owner_OOO_Mail') 
                && tsmap.get('Execute_TAM_Owner_OOO_Mail') != null 
                && tsmap.get('Execute_TAM_Owner_OOO_Mail').Execute__c){
                CaseTriggerHelper.sendEmailToTamManagerForOOO(newCaseList, oldCaseMap);
            }
            //Added by Anup : CR#502 - End

            //Added by Anup - Omni Overhaul
            CaseTriggerHelper.updateDailyQuota(newCaseList, oldCaseMap);
            
	        //Defcon Changes - Start
                //Added by Chetan - Start
                CaseTriggerHelper.sendDefconNextPlanOfActionChangeEmail(newCaseList, oldCaseMap);
                //Added by Chetan - End

                //Added by Bhagyalaxmi - IBA-4060-Start
                CaseTriggerHelper.updateDefconStatusAsResolvedUponParentCaseIsClosed(newCaseList, oldCaseMap);
                //Added by Bhagyalaxmi - IBA-4060-End
                
                //Added by Ankit - Defcon Project - start
                CaseTriggerHelper.toggleAutoEscSLAOnDefcon(newCaseList, oldCaseMap);
                CaseTriggerHelper.completeDefconMilestones(newCaseList, oldCaseMap);
                //Added by Ankit - Defcon Project - End
                
                //added by Bhagyalaxmi - IBA-5356
                CaseTriggerHelper.updateParentFieldsOnDefcon(newCaseList, oldCaseMap);
                //Added By Bhagyalaxmi - IBA-5356- End
	        //Defcon Changes - End
            
            //Added by Chetan: IBA-686
            if(tsmap.containsKey('Execute_CaseRecordHistoryTracking') 
                && tsmap.get('Execute_CaseRecordHistoryTracking') != null 
                && tsmap.get('Execute_CaseRecordHistoryTracking').Execute__c){
                CaseTriggerHelper.insertCaseRecordHistoryTracking(newCaseList, oldCaseMap);
            }
            //Added by Chetan: IBA-686
            
            TriggerUtility.CaseAfterUpdateExecuted();
        }
    }
}