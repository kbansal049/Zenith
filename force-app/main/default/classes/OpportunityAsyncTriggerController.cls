/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* OpportunityAsyncTriggerController
* @description    This is the Opportunity Trigger controller class called asynchronously from OpportunityAsyncTriggerHandler.
*                   All the methods needs to be called asynchronously from the Opportunity Trigger
*                   should be called from here.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Chandan Panigrahy
* @modifiedBy     Chandan Panigrahy
* @maintainedBy   Chandan Panigrahy
* @version        1.0
* @created        2021-09-13
* @modified       
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* vX.X            Developer Name
* YYYY-MM-DD      Explanation of the change.  Multiple lines can be used to explain the change, but
*                 each line should be indented till left aligned with the previous description text.
* 2021-11-22      Modified Opportunity query to fetch related field line 50-59 CR# 3684
* 2021-11-23      Bikram - Modified the process() to handle multiple records (batch size > 1)
* 2022-06-16      CR# 4912 - Bikram, Add Creator of Opportunity as a Opp team Member
* 2022-09-20      CR# 5246 - Viral, Updating Account so that Prospect Type Trigger will fire
* 2023-02-23      IBA-7353 - Harish Gowda N, Remove field References from L2O classes .
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
**/

public class OpportunityAsyncTriggerController {
    private static OpportunityAsyncTriggerController instance;
    public static OpportunityAsyncTriggerController getInstance() {
        if (instance == NULL) {
            instance = new OpportunityAsyncTriggerController();
        }
        
        return instance;
    }
    
    
    private List<OpportunityChangeEvent> newOppList;
    public void setNewOppList(List<OpportunityChangeEvent> newOppList) {
        this.newOppList = newOppList;
    }
    
    private Map<Id, Opportunity> newOppMap;
    private void setNewOppMap(Map<Id, Opportunity> newOppMap) {
        this.newOppMap = newOppMap;    
    }
    
    private void retrieveOpporunities(List<String> opportunityIdSet) {
        
        Map<Id, Opportunity> newOppMap = new Map<Id, Opportunity> (
            [
                SELECT
                Id,OwnerId,StageName,AccountId,Type,Contract_End_Date_New__c,Sub_Stage__c,
                Validation_Stage__c,Technical_Validation_Start_Date__c,Validation_End_Date__c,
                Validation_Plan__c,Competitor__c,Other_Competitors__c,          // removed Customer_use_CASB_or_considers__c, CASB_Vendor__c as part of CR#4967
                Validation_Report__c,Next_Steps__c,POV_Scope_Approved__c,POV_Playback_Approved__c,
                Technology_Champion_Notes__c,Technical_Validation_Manager_Notes__c,
                Primary_Reseller_Partner__c,
                Channel_Sentiment__c,Partner_Margin_Adjustment__c,Secondary_Partner__c,CreatedById,
                ImpartnerPRM__PartnerAccount__c,Secondary_Partner_Role__c,Partner_Close_Date__c,
                Partner_Comments__c,Primary_Partner_Program__c,Deal_Reg__c,Deal_Reg_Teaming_Reseller__c,
                Validated_Solution_Tech_Partner__c,Deal_Reg_Partner_Teaming_Reseller__c,
                Deal_Reg_Margin__c,ImpartnerPRM__PartnerContact__c,Partner_Type__c,TriggerPatchAssignment__c
                FROM
                Opportunity
                WHERE 
                Id IN :opportunityIdSet
            ]
        );
        
        setNewOppMap(newOppMap);
    }
    
    public void process() {
        
        try {
            
            List<String> opportunityIdList = new List<String>();
            
            for (OpportunityChangeEvent oppChangeEvt : newOppList) {            
                EventBus.ChangeEventHeader header = oppChangeEvt.ChangeEventHeader;
                opportunityIdList.addAll(header.getRecordIds());//for batch size more than 1            
            }
            
            retrieveOpporunities(opportunityIdList);
            
            System.debug('-=- newOppMap -=- '+newOppMap);
            
            Set<Id> oppIdSet = new Set<Id> ();
            Set<Id> accIdSet = new Set<Id> ();
            Set<Id> relatedAccIdSetFromInsert = new Set<Id> ();
            List<Opportunity> oppToCreateTeamList = new List<Opportunity>();
            List<Opportunity> closedWonOppList = new List<Opportunity>();
            List<Opportunity> oppIdWithStageList = new List<Opportunity>();
            List<Opportunity> oppCustomerRenewalList = new List<Opportunity>();
            
            List<Opportunity> closedLostOppList = new List<Opportunity>();
            
            Map<String, Triggers_Switch__c> tsmap = Triggers_Switch__c.getAll();
            
            //CR# 3382 US-0001402 START - Bikram 25th Oct 2021
            List<Id> stageChangedOppIdsSet = new List<Id>();
            //CR# 3382 US-0001402 END - Bikram 25th Oct 2021
            
            //CR# 3382 US-0001415 START - Bikram 27th Oct 2021
            List<Opportunity> closedLostDeleteDuplicateOppList = new List<Opportunity>();
            //CR# 3382 US-0001415 END - Bikram 27th Oct 2021
            
            for (OpportunityChangeEvent oppChangeEvt : newOppList) {
                
                EventBus.ChangeEventHeader header = oppChangeEvt.ChangeEventHeader;
                System.debug('Received change event for ' +
                             header.entityName +
                             ' for the ' + header.changeType + ' operation. -=- '+header);
                
                List<String> updatedFieldList = new List<String>();
                Boolean isAccountIdUpdated = FALSE;
                
                
                if (header.changetype == 'UPDATE') {
                    
                    for(String recordId : header.getRecordIds()){//process each record in a bulk operation, batch size more than 1
                        
                        updatedFieldList = header.changedFields;                    
                        Id oppId = recordId;
                        
                        for(String fieldStr : updatedFieldList){
                            System.debug('OpportunityAsyncTriggerController.process() updatedFieldList fieldStr : ' + fieldStr);
                        }
                        
                        if(updatedFieldList.contains('AccountId') || updatedFieldList.contains('TriggerPatchAssignment__c')) oppIdSet.add(oppId);
                        
                        if (updatedFieldList.contains('OwnerId')) {
                            /*Opportunity oppToCreateTeam = new Opportunity(Id = oppId);
oppToCreateTeam.OwnerId = String.valueOf(oppChangeEvt.get('OwnerId'));*/
                            
                            Opportunity oppToCreateTeam = newOppMap.get(oppId);
                            
                            oppToCreateTeamList.add(oppToCreateTeam);
                            
                            oppIdSet.add(oppId);
                        }
                        
                        if (updatedFieldList.contains('StageName')) {
                            
                            String oppStage = newOppMap.get(oppId).StageName;
                            
                            if (oppStage.equalsIgnoreCase(System.Label.Stage_6_Closed_Won)) {
                                
                                Opportunity oppToCreateTeam = newOppMap.get(oppId);
                                
                                closedWonOppList.add(oppToCreateTeam);
                            }
                            
                            Set<String> stageNameSet = new Set<String> { System.Label.Stage_4_Economic_Buyer_Signoff, System.Label.Stage_5_Contracts_Complete, System.Label.Stage_5A_Opportunity, System.Label.Stage_5B_Opportunity, System.Label.Stage_5C_Opportunity, System.Label.Stage_6_Closed_Won };
                                
                                Opportunity oppWithStage = newOppMap.get(oppId);
                            
                            oppIdWithStageList.add(oppWithStage);
                            
                            //CR# 3382 US-0001402 START - Bikram 25th Oct 2021, If Stage isChanged, add it to stageChangedOppIdsSet
                            stageChangedOppIdsSet.add(oppId);
                            //CR# 3382 US-0001402 END - Bikram 25th Oct 2021
                        }
                        
                        if (updatedFieldList.contains('StageName') || updatedFieldList.contains('Type') || updatedFieldList.contains('Contract_End_Date_New__c')) {
                            
                            System.debug('-=-= updatedFieldList -=- '+updatedFieldList);
                            
                            /*renewal code*/
                            Opportunity oppWithStage = newOppMap.get(oppId);
                            
                            System.debug('-=- oppWithStage -=- '+oppWithStage);
                            
                            if (oppWithStage.StageName.equalsIgnoreCase('4 - Impact Validation')  && 
                                oppWithStage.Type.equalsIgnoreCase('Existing Customer (Renewal)') && 
                                oppWithStage.Contract_End_Date_New__c != NULL   ) {
                                    
                                    oppCustomerRenewalList.add(oppWithStage);
                                }
                            
                        }
                        
                        //CR# 3382 US-0001415 START - Bikram 27th Oct 2021, If Stage & SubStage isChanged
                        if (updatedFieldList.contains('StageName') && updatedFieldList.contains('Sub_Stage__c')) {
                            
                            if(newOppMap.get(oppId).StageName == '7 - Closed Lost' &&  newOppMap.get(oppId).Sub_Stage__c == System.label.SubStage_Closed_Delete_Duplicate){
                                closedLostDeleteDuplicateOppList.add(newOppMap.get(oppId));
                            }
                        }
                        //CR# 3382 US-0001415 END - Bikram 27th Oct 2021
                        //
                        
                        //CR# 5246
                         if (updatedFieldList.contains('Validation_Stage__c')) {
                            accIdSet.add(newOppMap.get(oppId).AccountID);
                        }
                    }
                } 
                else if (header.changetype == 'CREATE') {
                    
                    for(String recordId : header.getRecordIds()){//process each record in a bulk operation, batch size more than 1              
                        Id oppId = recordId;
                        
                        Opportunity newOpportunity = newOppMap.get(oppId);
                        String relatedAccId = String.valueOf(newOpportunity.get('AccountId'));
                        
                        System.debug('-=-=- oppId -=- '+oppId);
                        
                        if (String.isNotBlank(relatedAccId)) {
                            oppIdSet.add(oppId);
                            relatedAccIdSetFromInsert.add(relatedAccId);
                        }
                        
                        
                        if (newOpportunity.StageName.equalsIgnoreCase(System.Label.Stage_5C_Opportunity)) {
                            Opportunity oppWithStage = new Opportunity(Id = newOpportunity.Id, StageName = newOpportunity.StageName);
                            
                            System.debug('-=-=- oppWithStage -=- '+oppWithStage);
                            
                            oppIdWithStageList.add(oppWithStage);
                        }
                        
                        /* Renewal code*/
                        
                        
                        Opportunity oppWithStage = newOppMap.get(oppId);
                        
                        if (oppWithStage.StageName.equalsIgnoreCase('4 - Impact Validation')  && 
                            oppWithStage.Type.equalsIgnoreCase('Existing Customer (Renewal)') && 
                            oppWithStage.Contract_End_Date_New__c != NULL   ) {
                                
                                oppCustomerRenewalList.add(oppWithStage);
                            }
                    }
                }
                
            }
            
            
            /** 
*  Calling the patch handler async way Start 
*/
            
            List<Id> oppIdList = new List<Id> ();
            oppIdList.addAll(oppIdSet);
            
            Zscaler_Error_Logs__c logObj1 = new Zscaler_Error_Logs__c(
                Class_Name__c = 'OpportunityAsyncTriggerController',
                Method_Name__c = 'OpportunityAsyncTriggerController before',
                Error_in__c = 'Apex',
                User__c  = UserInfo.getUserId(),
                Biz_Area__c  = 'Sales Cloud',
                Stack_Trace_String__c = 'oppIdList, '+JSON.serialize(oppIdList)
            );
            insert logObj1;
            
            if (!oppIdList.isEmpty()) {
                system.debug('OpportunityAsyncTriggerController oppIdList : ' + oppIdList);
                PatchRuleHelper.assignSalesTeamMembers(oppIdList, 'Opportunity'); 
                //CR# 4912 START - Bikram, Add Creator of Opportunity as a Opp team Member
                List<OpportunityTeamMember>  oppTeamMemberListForInsert  = new List<OpportunityTeamMember>();           
                Map<Id,OpportunityTeamMember> userIdOppTeamRecMap = new Map<Id,OpportunityTeamMember>(); 
                for(OpportunityTeamMember oppTeamRec : [SELECT Id, UserId 
                                                        FROM 
                                                        OpportunityTeamMember 
                                                        WHERE 
                                                        OpportunityId IN: oppIdList])
                {
                    userIdOppTeamRecMap.put(oppTeamRec.UserId,oppTeamRec);
                }
                
                for(Opportunity oppRec : newOppMap.values()){
                    if(!userIdOppTeamRecMap.containsKey(oppRec.CreatedById)){
                        OpportunityTeamMember oppTeamMember  = new OpportunityTeamMember();
                        oppTeamMember.OpportunityId  = oppRec.Id;
                        oppTeamMember.TeamMemberRole  = 'Out of Territory';
                        oppTeamMember.OpportunityAccessLevel  = 'Edit';
                        oppTeamMember.UserId = oppRec.CreatedById;
                        oppTeamMemberListForInsert.add(oppTeamMember); 
                    }                
                }
                if(!oppTeamMemberListForInsert.isEmpty()){
                    insert oppTeamMemberListForInsert;
                }
                //CR# 4912 END - Bikram, Add Creator of Opportunity as a Opp team Member
            }
            
            /* Calling the patch handler async way End */
            
            /* Calling the AmberRoad Enhancement async way Start */
            if (!relatedAccIdSetFromInsert.isEmpty()) {
                AmberRoadEnhancementHandler amberRoadEnhanceInstance = AmberRoadEnhancementHandler.getInstance();
                amberRoadEnhanceInstance.setRelatedAccIdList(relatedAccIdSetFromInsert);
                amberRoadEnhanceInstance.process();
            }
            /* Calling the AmberRoad Enhancement async way End */
            
            /* Calling create opportunity team code async way Start
* merged the code from LinkOpportunityToPatch trigger
*/
            if (!oppToCreateTeamList.isEmpty()) {
                OppotunityTriggerHelper.createOpportunityTeam(oppToCreateTeamList);
            }
            /* Calling create opportunity team code async way End
* merged the code from LinkOpportunityToPatch trigger
*/
            
            /* Calling create cases for closed won opportunities async way Start
* merged the code from LinkOpportunityToPatch trigger
*/
            
            if(!closedWonOppList.isEmpty() && !TriggerUtility.isOppCaseCreationExecuted()){
                CaseCreationForAccountAndOpportunity.opportunityCaseCreation(closedWonOppList);
                TriggerUtility.oppCaseCreationExecuted();
            }
            
            /* Calling create cases for closed won opportunities async way End
* merged the code from LinkOpportunityToPatch trigger
*/
            
            /* Updating Provisioning Request:Status to Production async way Start
* merged the code from LinkOpportunityToPatch trigger
*/
            
            if (!closedWonOppList.isEmpty() && !TriggerUtility.isOppPRProductionStatusUpdateExecuted()) {
                OppotunityTriggerHelper.updatePRStatusToProduction(closedWonOppList);
                TriggerUtility.oppPRProductionStatusUpdateExecuted();
            }
            
            /* Updating Provisioning Request:Status to Production async way End
* merged the code from LinkOpportunityToPatch trigger
*/
            
            
            
            /*  Calling CustomerRenewal Async way */
            if(!oppCustomerRenewalList.isEmpty()) {
                
                CustomerRenewalReminderHandler custRenReminderInstance = CustomerRenewalReminderHandler.getInstance();
                custRenReminderInstance.setNewOpportunityList(oppCustomerRenewalList);
                custRenReminderInstance.handle();
            }
            
            
            /* Calling Opportunity closed lost email helper */
            
            /*System.debug('-=-= closedLostOppList -=- '+closedLostOppList);
if(!closedLostOppList.isEmpty()) {
OpportunityClosedLostSendEmailHelper instance = OpportunityClosedLostSendEmailHelper.getInstance();
instance.setOppList(closedLostOppList);
instance.process();
}*/
            
            //CR# 3382 US-0001402 START - Bikram 25th Oct 2021, call updateContactRoles Logic.
            if(!stageChangedOppIdsSet.isEmpty()) {            
                if(tsmap.containsKey('OpportunityUpdatesContactHandler') && 
                   tsmap.get('OpportunityUpdatesContactHandler') != null && 
                   tsmap.get('OpportunityUpdatesContactHandler').Execute__c && 
                   !TriggerUtility.isOpportunityUpdatesContactHandler()){                
                       OpportunityUpdatesContactHandler.updateContactRoles(stageChangedOppIdsSet);
                   }
            }
            //CR# 3382 US-0001402 END - Bikram 25th Oct 2021
            
            //CR# 3382 US-0001415 START - Bikram 27th Oct 2021
            if(!closedLostDeleteDuplicateOppList.isEmpty()) {
                if(!TriggerUtility.isUpdateRelatedOppExecuted() && 
                   tsmap != null && !tsmap.isEmpty() && 
                   tsmap.containsKey('Execute_UpdateRelatedOpportunity') && 
                   tsmap.get('Execute_UpdateRelatedOpportunity') != null && 
                   tsmap.get('Execute_UpdateRelatedOpportunity').Execute__c){
                       OppotunityTriggerHelper.updateRelatedOpportunityFields(closedLostDeleteDuplicateOppList);    
                   }
            }        
            //CR# 3382 US-0001415 END - Bikram 27th Oct 2021
            
            
            //CR# 5246
            if(!accIdSet.isEmpty()){
                List<Account> accList = [Select Id from Account where id in :accIdSet];
                update accList;
            }
        } catch (Exception ex) {
            Zscaler_Error_Logs__c logObj1 = new Zscaler_Error_Logs__c(
                Class_Name__c = 'OpportunityAsyncTriggerController',
                Method_Name__c = 'process catch exception',
                Error_in__c = 'Apex',
                User__c  = UserInfo.getUserId(),
                Biz_Area__c  = 'Sales Cloud',
                Stack_Trace_String__c = 'Error, getStackTraceString >> '+ex.getStackTraceString()+'\n\ngetMessage >> '+ex.getMessage()
            );
            insert logObj1;
        }
    }
}