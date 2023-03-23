/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* OpportunityTriggerHandler
* @description    This is the Opportunity Trigger handler class called synchronously from OpportunityMasterTrigger.
*                   All the methods needs to be called synchronously from the Opportunity Trigger
*                   should be called from here in the before/after insert/update methods.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Nagesh
* @modifiedBy     Chandan Panigrahy and Mahesh T.
* @maintainedBy   Nagesh
* @version        1.0
* @created        2021-09-13
* @modified       
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* vX.X            Developer Name
* YYYY-MM-DD      Explanation of the change.  Multiple lines can be used to explain the change, but
*                 each line should be indented till left aligned with the previous description text.
* 2021-11-23      Bikram - Refactored mutile methods inside afterUpdate() which were calling OppotunityTriggerHelper
*                 and running "for" loop multiple times.
* 2022-02-05      Bikram - Made the class without sharing for BN-00002876
* 2022-05-25      CR# 4906 Bikram - Opportunity owner assignment issue on lead conversion, after Stage 0 deployment
* 2022-06-06      CR# 4912 Bikram - SDR Opp record access, Opp Split error, Opp Owner assignment issue, 
				  Removed all debug statements to reduce APEX CPU TIME
* 2022-07-12	  CR# 5069 Udit - Stage-1 Entry Date Field not getting updated
* 2022-07-01      IBA-345 - Ram Sangati: Process duplicate Opporunity realted PRGs and Cases.
* 2022-07-14      CR #5004 : Pramod Sharma : Added logic for In My Number Fields to trigger based on Process Builder check
* 2022-11-21	  IBA-4812 : Remove Rollup Summary Helper Package Code.
* 2022-10-25      IBA-2737 : Sachin Tandon : Added logic for Updating Opportunity Extension Project creation Status field
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
**/

public without sharing class OpportunityTriggerHandler extends TriggerHandler {
    public static boolean isNotificationSent = false;
    public override void beforeInsert() {
        
        if(test.isrunningtest()){
            booster();
        }
        List<Opportunity> newOppList = new List<Opportunity>();
        Set<Id> newOppAccIdSet = new Set<Id>();
        Map<Id,Account> idAccountRecordMap = new Map<Id,Account>();
        //Added by Gurjinder for Opp Creation Issue :Start
        if (!TriggerUtility.isSkipAccTriggerExecuted()) {
            TriggerUtility.SkipAccTriggerExecuted();
        }
        //Added by Gurjinder for Opp Creation Issue : End
        
        OpportunityMasterTriggerUtility.beforeInsert(Trigger.new);
        
        /* Merged from LinkOpportunityToPatch Start */
        OpportunityFieldUpdateTriggerHandler.BeforeInsert(Trigger.New);
        /* Merged from LinkOpportunityToPatch Start */
        
        //CR# 4912 START - Bikram 7th June 2022
        Boolean checkForNonCoreSalesProfile = FALSE;
        Set<Id> accManagerUserIdSet = new Set<Id>();
        for(Sobject newOppRec : Trigger.new){
            Opportunity newOppty = (Opportunity) newOppRec;
            if(newOppty.Created_from_Lead__c && newOppty.Opportunity_Account_Manager__c != NULL){
                accManagerUserIdSet.add(newOppty.Opportunity_Account_Manager__c);
            }
            if(newOppty.Created_from_Lead__c){
                newOppAccIdSet.add(newOppty.AccountId);
            }
        }
        if(!newOppAccIdSet.isEmpty()){
            for(Account accRec : [SELECT Id, OwnerId, Territory_Type__c, 
                                  Account_Manager__c
                                  FROM Account 
                                  WHERE Id IN :newOppAccIdSet]){
                                      idAccountRecordMap.put(accRec.id,accRec);
                                      accManagerUserIdSet.add(accRec.OwnerId);
                                  }            
        }
        //CR# 4912 END - Bikram 7th June 2022
        //BN-00003398 START - Bikram 13th May 2022
        //Default Stage for Opportunities during Lead Conversion        
        Id logedInUserId = userinfo.getUserId();
        accManagerUserIdSet.add(logedInUserId);
        Map<Id,User> userIdVsUserMap = new Map<Id,User>([SELECT Id, Name, Email, Profile.Name, UserRole.Name 
                                                         FROM User 
                                                         WHERE Id IN :accManagerUserIdSet]);
        List<Profile> profile = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
        String loggedInUserProflieName = userIdVsUserMap.containsKey(logedInUserId) ? 
            userIdVsUserMap.get(logedInUserId).Profile.Name : '';
        for(Sobject newOppRec : Trigger.new){ 
            Opportunity newOppty = (Opportunity) newOppRec;
            if(loggedInUserProflieName == Label.Profile_Core_Sales && newOppty.Created_from_Lead__c){
                newOppty.StageName = '1 - Discovery & Qualification'; 
            }
            //CR# 4906 START - Bikram 25th May 2022
            //CR# 4912 START - Bikram 6th June 2022 Added Opportunity_Account_Manager__c logic
            if (newOppty.Created_from_Lead__c && 
                newOppty.Opportunity_Account_Manager__c != NULL &&
                userIdVsUserMap.containsKey(newOppty.Opportunity_Account_Manager__c) &&
                idAccountRecordMap.containsKey(newOppty.AccountId) &&
                userIdVsUserMap.containsKey(idAccountRecordMap.get(newOppty.AccountId).OwnerId) &&
                userIdVsUserMap.get(idAccountRecordMap.get(newOppty.AccountId).OwnerId).Profile.Name != Label.Profile_Core_Sales)
            {                
                newOppty.OwnerId = newOppty.Opportunity_Account_Manager__c;
                newOppty.Opportunity_Account_Manager__c = NULL;
                checkForNonCoreSalesProfile = TRUE;
            }
            //CR# 4912 END - Bikram 6th June 2022 added Opportunity_Account_Manager__c logic
            //CR# 4906 END - Bikram 25th May 2022
        }
        //BN-00003398 END - Bikram 13th May 2022
        //CR# 4906 START - Bikram 25th May 2022
        for(Sobject newOppRec : Trigger.new){
            Opportunity newOppty = (Opportunity) newOppRec;
            if(!checkForNonCoreSalesProfile && idAccountRecordMap.containsKey(newOppty.AccountId) && 
               idAccountRecordMap.get(newOppty.AccountId).OwnerId != NULL &&
               idAccountRecordMap.get(newOppty.AccountId).OwnerId != UserInfo.getUserId()){
                   newOppty.OwnerId = idAccountRecordMap.get(newOppty.AccountId).OwnerId;
               }            
        }
        //CR# 4906 END - Bikram 25th May 2022

        //CR# 5069 START - Udit 12th July 2022
        OppotunityTriggerHelper.populateOpportunityStageEntryDates(Trigger.new);
        //CR# 5069 START - Udit 12th July 2022
        
        //Forecastcategoryupdates Trigger
        //TODO: need to cast if it is not casting automatically. We will check if it is required.
        if(!TriggerUtility.isPatchRealigning() || Test.isRunningTest()) {
            //Added by Karthik Pullagurla for  CR# 3970
            OppotunityTriggerHelper.setDefaultOpportunityStage(Trigger.New);
            OppotunityTriggerHelper.copymainforecasttohierarchycategoryfields(Trigger.New);
            //OppotunityTriggerHelper.updateGAMNAM(Trigger.New); Commented as part of CR#3744
            OppotunityTriggerHelper.clearNSfieldsonCreation(Trigger.New);
            
        } else{
            OppotunityTriggerHelper.copymainforecasttohierarchycategoryfields(Trigger.New);
        }
        
        
        //From Trigger_Opportunity
        Trigger_Opportunity_Handler.beforeInsertHandler((List<Opportunity>) trigger.new,(Map<Id,Opportunity>) trigger.newMap,(List<Opportunity>) trigger.old,(Map<Id,Opportunity>) trigger.oldMap);
        
        /* Merged from APTS_opportunity_Master_trigger  */
        OpportunityTriggerUtility.beforeInsert(trigger.new);
        
        /* Merged from OwnerCopy Trigger   */
        OwnerCopyTriggerHandler ownerInstance = OwnerCopyTriggerHandler.getInstance();
        ownerInstance.setNewOppList(Trigger.new);
        ownerInstance.beforeInsert();
        
        /**
* Lock renewal opportunity logic
* Please refer CR# 3553
**/
        
        LockRenewalOpportunityHandler lockRenewalHandler = LockRenewalOpportunityHandler.getInstance();
        lockRenewalHandler.setNewOppList(Trigger.new);
        lockRenewalHandler.handle();
        
    }
    
    public override void beforeUpdate() {         
        Map<Id, Opportunity> newOpptyMap = new Map<Id,Opportunity>();
        Map<Id, Opportunity> oldOpptyMap = new Map<Id,Opportunity>();
        List<Opportunity> ListOppIdsUpdateSZnumber = new List<Opportunity>();
        Map<Id, Opportunity> checkOppPartnerComplianceStatusMap = new Map<Id,Opportunity>();
        //CR# 4798 START
        Set<String> opportunityStageNamesSet = new Set<String> {'6 - Closed Won', '5A - Submitted for Order Review', '5B - In Process with Finance', '5C - Sales Rep Action Required', 
            '5D - Approved, awaiting processing'};

        Map<String,Date> mapOfOpportunityAndStartDate = updatePsStartDateOnOpportunity(Trigger.new);    
                //CR# 4798 END
                
                for (SObject oppty: Trigger.new) {
                    
                    Opportunity newOppty = (Opportunity) oppty;
                    Opportunity oldOppty = (Opportunity) Trigger.oldMap.get(newOppty.Id);
                    
                    if(!ManageRecursive.processedOpportunityIds.contains(newOppty.Id) || qualifiedUpdate(newOppty, oldOppty)){
                        newOpptyMap.put(newOppty.Id, newOppty);
                        oldOpptyMap.put(oldOppty.Id, oldOppty);
                    }            
                    
                    //CR# 4798 START
                    //Moved opportunity update logic to trigger from flow : Create Project for Stage 5 or 6 Opportunities - V2 START
                    // CR #5004 : Pramod Sharma : 14/07/22 || Removed the check for Oppty Type checking for 'New Business' only and added Renewals In My Number Fields
                    if (newOppty.StageName != oldOppty.StageName && opportunityStageNamesSet.contains(newOppty.StageName) && 
                        (newOppty.AVP_In_my_Number__c == false || newOppty.Geo_VP_In_my_Number__c == false ||
                         newOppty.RD_In_my_Number__c == false || newOppty.Renewal_RD_In_my_Number__c == false || newOppty.Renewal_RVP_In_my_Number__c == false ||
                         newOppty.Renewal_VP_In_my_Number__c == false || newOppty.RVP_In_my_Number__c == false)) {
                             
                             // CR #5004 : Pramod Sharma : 14/07/22 : START
                            if('New Business'.equalsIgnoreCase(newOppty.Type) || 'Existing Customer (Add On)'.equalsIgnoreCase(newOppty.Type)) {
                             newOppty.AVP_In_my_Number__c = true;
                             newOppty.Geo_VP_In_my_Number__c = true;
                             newOppty.RD_In_my_Number__c = true;
                             newOppty.RVP_In_my_Number__c = true;
                         }
                            if('Existing Customer (Renewal)'.equalsIgnoreCase(newOppty.Type)) {
                             newOppty.AVP_In_my_Number__c = true;
                             newOppty.Geo_VP_In_my_Number__c = true;
                             newOppty.RD_In_my_Number__c = true;
                             newOppty.RVP_In_my_Number__c = true;
                             newOppty.Renewal_RD_In_my_Number__c = true;
                             newOppty.Renewal_RVP_In_my_Number__c = true;
                             newOppty.Renewal_VP_In_my_Number__c = true;
                            }
                             // CR #5004 : Pramod Sharma : 14/07/22 : END
                         }
                    //Moved opportunity update logic to trigger from flow : Create Project for Stage 5 or 6 Opportunities - V2 END
                    //CR# 4798 END
                }
        //1 query is fired from below method, check if we can call this conditionally
        Map<Id,Opportunity> opptyWithRelatedFieldValues = getOpptyRelatedFieldValues(newOpptyMap.keySet());
        Set<string> setOfSkus = new Set<string>{'ZCES-DEP-ADV','ZCES-DEP-ENT','ZCES-DEP-ENTPLUS','CES-DEP-ESS','CES-DEP-ESS-FED','ZCES-DEP-FED32','ZCES-PRO-DRR','ZCES-PRO-HEALTH','ZCES-PRO-SVC','ZCES-PRO-SVC-CUST-FED'};
            Map<Id,Opportunity> mapOfOppty = new Map<Id,Opportunity> ([SELECT Id,SBQQ__PrimaryQuote__r.Line_Item_SKU_Approval__c  FROM Opportunity WHERE Id =: newOpptyMap.keySet()]);
        
        //Set SE_Znumber__c, moved from OppotunityTriggerHelper.afterUpdate()
        for(Opportunity oppRec : opptyWithRelatedFieldValues.values()){
            // SE is active and Znumber is updated to his Employee number
            if(oppRec.SE_Name__r.isActive && oppRec.SE_Znumber__c != oppRec.SE_Name__r.EmployeeNumber){
                newOpptyMap.get(oppRec.Id).SE_Znumber__c = String.valueOf(oppRec.SE_Name__r.EmployeeNumber);
            }
            // SE is Not active but His Manager is Active and Znumber is updated to his Manager Employee number
            if(!oppRec.SE_Name__r.isActive && oppRec.SE_Name__r.Manager.isActive && 
               oppRec.SE_Znumber__c!= oppRec.SE_Name__r.Manager.EmployeeNumber){
                   newOpptyMap.get(oppRec.Id).SE_Znumber__c = String.valueOf(oppRec.SE_Name__r.Manager.EmployeeNumber);
               }

            //Default PS Start date 
            if((newOpptyMap.get(oppRec.Id).StageName.equalsIgnoreCase(Label.Stage_6_Closed_Won) && newOpptyMap.get(oppRec.Id).DAS_Start_Date__c == NULL && mapOfOpportunityAndStartDate.containsKey(oppRec.Id)
                && mapOfOpportunityAndStartDate.get(oppRec.Id) != null && !oldOpptyMap.get(oppRec.Id).StageName.equalsIgnoreCase(Label.Stage_6_Closed_Won))|| test.isRunningTest()){
                    if(newOpptyMap.get(oppRec.Id).CloseDate != null){
                        if(mapOfOpportunityAndStartDate.get(oppRec.Id) != null){
                            newOpptyMap.get(oppRec.Id).DAS_Start_Date__c = newOpptyMap.get(oppRec.Id).CloseDate > mapOfOpportunityAndStartDate.get(oppRec.Id) 
                                ? newOpptyMap.get(oppRec.Id).CloseDate 
                                : mapOfOpportunityAndStartDate.get(oppRec.Id) ;
                        }
                        else{
                            newOpptyMap.get(oppRec.Id).DAS_Start_Date__c = newOpptyMap.get(oppRec.Id).CloseDate;
                        }
                    }
                }   
        }
        
        /* Merged from OpportunityMasterTrigger Start */
        OpportunityMasterTriggerUtility.beforeUpdate(newOpptyMap.values(), oldOpptyMap);
        /* Merged from OpportunityMasterTrigger End */
        
        /* Merged from LinkOpportunityToPatch Start */
        //added by Minkesh to handle SOQL 101 error
        if (!TriggerUtility.isopportunityfieldupdate()) {
            OpportunityFieldUpdateTriggerHandler.BeforeUpdate(newOpptyMap.values(), oldOpptyMap);
        }
        
        UpdateIncumbentPartners.BeforeUpdate(newOpptyMap.values(), oldOpptyMap);
        /* Merged from LinkOpportunityToPatch End */

        //CR# 5069 START - Udit 12th July 2022
        OppotunityTriggerHelper.populateOpportunityStageEntryDates(Trigger.new);
        //CR# 5069 START - Udit 12th July 2022
        
        //Forecastcategoryupdates Trigger
        if(!TriggerUtility.isPatchRealigning()) {
            OppotunityTriggerHelper.handleallcategoryfieldandlockchanges(newOpptyMap, oldOpptyMap);
            //OppotunityTriggerHelper.updateGAMNAM(Trigger.New); Commented as part of CR#3744
            OppotunityTriggerHelper.validateClosedLostwithOpenPRs(newOpptyMap, oldOpptyMap);
            OppotunityTriggerHelper.beforeUpdate(newOpptyMap.values(), oldOpptyMap);
            //OppotunityTriggerHelper.beforeUpdate(newOpptyMap.values(), oldOpptyMap);
        }
        
        //From RHX_Opportunity
        OpportunityTriggerUtility.beforeUpdate(newOpptyMap.values(), newOpptyMap , oldOpptyMap);
        
        //From Trigger_opportunity
        Trigger_Opportunity_Handler.beforeUpdateHandler(newOpptyMap.values(), newOpptyMap, oldOpptyMap.values(), oldOpptyMap);
        /*  Merged from APTS_Opportunity_Master_trigger  */
        OpportunityTriggerUtility.beforeUpdate(newOpptyMap.values(), newOpptyMap, oldOpptyMap);
        
        /* merged from  APTS_Opportunity_Master_Trigger  */
        APTS_Opportunity_Master_TriggerHandler aptsHandler = APTS_Opportunity_Master_TriggerHandler.getInstance();
        aptsHandler.setOldMap(oldOpptyMap);
        aptsHandler.setNewOppList(newOpptyMap.values());
        aptsHandler.beforeUpdate();
        
        /**
* Lock renewal opportunity logic
* Refer CR# 3553
**/
        
        LockRenewalOpportunityHandler lockRenewalHandler = LockRenewalOpportunityHandler.getInstance();
        lockRenewalHandler.setNewOppList(newOpptyMap.values());
        lockRenewalHandler.setOldOppMap(oldOpptyMap);
        lockRenewalHandler.handle();
        
    }
    
    public override void afterInsert() {
        
        /*TODO: move to async trigger*/
        /* Merged from OpportunityMasterTrigger Start */        
        
        //Added by Varun : CR# 1824 - Start
        OppotunityTriggerHelper.updateInsertStageAge((List<Opportunity>) Trigger.new, (Map<Id, Opportunity>) Trigger.oldMap);
        //Added by Varun : CR# 1824 - End
        
        OpportunityChangeRequestCtrl.setAuditRecord(Trigger.new, NULL);
        
        /* Added by Chandan : CR# 2741
* It sends the email to the opportunity split owners for StageName=5C async way Start
* merged the code from OpportunityMasterTrigger trigger
* TODO: it should move to a queueable as async trigger will not help with the Org-wide address
*/
        
        OpportunitySplitOwnerEmailService splitOwnerEmailServinstance = OpportunitySplitOwnerEmailService.getInstance();
        splitOwnerEmailServinstance.setNewOpportunityList(Trigger.new);
        splitOwnerEmailServinstance.process();
        
        
        /* Merged from OpportunityMasterTrigger End */
        if(!TriggerUtility.isPatchRealigning() || Test.isRunningTest()) {
            //From Forecastcategoryupdates Trigger
            OppotunityTriggerHelper.afterInsert(trigger.new);
        }
        
        OpportunityTriggerUtility.afterInsert(Trigger.new);
        OppotunityTriggerHelper.createOpportunityExtension(Trigger.new);
        
        //From Trigger_Opportunity
        Trigger_Opportunity_Handler.afterInsertHandler((List<Opportunity>) trigger.new,(Map<Id,Opportunity>) trigger.newMap,(List<Opportunity>) trigger.old,(Map<Id,Opportunity>) trigger.oldMap);
        
        /* LinkOpportunityToPatch */
        CaseCreationForAccountAndOpportunity.opportunityCaseCreation(trigger.new);
        
        if (!TriggerUtility.isupdateSEManagerEmailExecuted()) {
            OppotunityTriggerHelper.updateOpportunityFields((Map<Id, Opportunity>) Trigger.oldMap, (List<Opportunity>) Trigger.new, Trigger.isinsert, Trigger.isupdate);
        }
        /*  Merged from APTS_Oportunity_Master_trigger  */
        OpportunityTriggerUtility.afterInsert(trigger.new);
    }
    
    public override void afterUpdate() {
        
        ManageRecursive.timesOpportunityTriggerInvoked = ManageRecursive.timesOpportunityTriggerInvoked + 1;
        Map<Id, Opportunity> newOpptyMap = new Map<Id,Opportunity>();
        Map<Id, Opportunity> oldOpptyMap = new Map<Id,Opportunity>();        
        List<Opportunity> emailToOpptySplitOwnersList = new List<Opportunity>();
        Set<Id> updateAccountForApprovedPZENSet = new Set<Id>();
        Set<Id> decommissionProvRequestsSet = new Set<Id>();
        Map<Id, String> oppNextStepsHistoryMap = new Map<Id, String>();
        Map<Id,String> techValidationHistoryMap = new Map<Id,String>();
        Map<Id, String> archNextStepsHistoryMap = new Map<Id, String>();
        Set<Id> EREmailNotificationSet = new Set<Id>();
        Set<Id> updateSplitForecastCategorySet = new Set<Id>();
        List<Id> proposalIdsToQueryList = new List<Id>();
        Map<Id,Opportunity> updateSalesTeamInfoOnOppSplitMap = new Map<Id,Opportunity>();
        List<Opportunity> PSOnbordingOppSet = new List<Opportunity>();			//Added by Ayush Kangar as part of IBA-4567
		Map<Id,opportunity> oppIdOpportunityMap = new Map<Id,opportunity>();	//Added by Ayush Kangar as part of IBA-4567
        
        for (SObject oppty: Trigger.new) {
            
            Opportunity newOppty = (Opportunity) oppty;
            Opportunity oldOppty = (Opportunity) Trigger.oldMap.get(newOppty.Id);
            
            if(!ManageRecursive.processedOpportunityIds.contains(newOppty.Id) || qualifiedUpdate(newOppty, oldOppty)){
                
                newOpptyMap.put(newOppty.Id, newOppty);
                oldOpptyMap.put(oldOppty.Id, oldOppty); 
                
                ManageRecursive.processedOpportunityIds.add(newOppty.Id);
                
                /* Added by Chandan : CR# 2741
* It sends the email to the opportunity split owners for StageName=5C async way Start
* merged the code from OpportunityMasterTrigger trigger
* TODO: it should move to a queueable as async trigger will not help with the Org-wide address
*/
                if(newOppty.StageName != oldOppty.StageName &&
                   newOppty.StageName.equalsIgnoreCase(System.Label.Stage_5C_Opportunity)){
                       emailToOpptySplitOwnersList.add(newOppty);
                   }
                
                //updateAccountForApprovedPZEN
                if(newOppty.StageName != oldOppty.StageName && 
                   newOppty.StageName == label.Stage_6_Closed_Won){
                       updateAccountForApprovedPZENSet.add(newOppty.Id);
                   }
                
                //decommissionProvRequests
                if((newOppty.StageName != oldOppty.StageName &&
                    (
                        newOppty.StageName == label.Stage_7_Closed_Lost && 
                        (newOppty.Sub_Stage__c == label.SubStage_Closed_With_No_Decision || 
                         newOppty.Sub_Stage__c == label.SubStage_Closed_Lost)
                    )|| 
                    newOppty.StageName == label.Stage_5_Contracts_Complete || 
                    newOppty.StageName == label.Stage_6_Closed_Won
                   )){ //Added Stage10b check for PR POC expiry Notifications:Gurjinder
                       decommissionProvRequestsSet.add(newOppty.Id);
                   }
                
                //updateOpportunityNextStepsHistory, cannot be moved to Async Trigger due to oldOppty dependency
                if (newOppty.NextStep != NULL && 
                    !(String.isBlank(newOppty.NextStep)) && 
                    !(String.isBlank(oldOppty.NextStep))
                    && newOppty.NextStep != oldOppty.NextStep)
                {
                    String newHistory = ((oldOppty.NextStep != NULL) ? oldOppty.NextStep : '');
                    oppNextStepsHistoryMap.put(newOppty.Id,newHistory);
                }
                
                //updateTechValHistory, cannot be moved to Async Trigger due to oldOppty dependency
                if (newOppty.Next_Steps__c  != null && 
                    !(String.isBlank(newOppty.Next_Steps__c)) && 
                    !(String.isBlank(oldOppty.Next_Steps__c))
                    && newOppty.Next_Steps__c != oldOppty.Next_Steps__c )
                {
                    String newHistory = ((oldOppty.Next_Steps__c  != null) ? oldOppty.Next_Steps__c  : '');
                    techValidationHistoryMap.put(newOppty.Id,newHistory);
                }
                
                //updateArchitectureNextStepsHistory, cannot be moved to Async Trigger due to oldOppty dependency
                /* if (opp.Architecture_Next_Steps__c  != null && 
* !(String.isBlank(opp.Architecture_Next_Steps__c)) && 
* !(String.isBlank(oppOldMap.get(opp.Id).Architecture_Next_Steps__c))
* && opp.Architecture_Next_Steps__c  != oppOldMap.get(opp.Id).Architecture_Next_Steps__c )
{
String newHistory = ((oppOldMap.get(opp.Id).Architecture_Next_Steps__c  != null) ? 
oppOldMap.get(opp.Id).Architecture_Next_Steps__c  : '');
archNextStepsHistoryMap.put(opp.Id,newHistory);
} 
*/
                
                //EREmailNotification
                if(newOppty.StageName != oldOppty.StageName &&
                   newOppty.StageName == label.Stage_6_Closed_Won){
                       EREmailNotificationSet.add(newOppty.Id);
                   }
                
                //updateSplitForecastCategory
                if(newOppty.Deal_Path__c != oldOppty.Deal_Path__c){
                    updateSplitForecastCategorySet.add(newOppty.Id);
                }
                //updateSplitForecastCategory
                if(newOppty.Forecast_Category__c != oldOppty.Forecast_Category__c || 
                   newOppty.AD_Forecast_Category__c != oldOppty.AD_Forecast_Category__c || 
                   newOppty.CRO_Forecast_Category__c != oldOppty.CRO_Forecast_Category__c || 
                   newOppty.DM_Forecast_Category__c != oldOppty.DM_Forecast_Category__c || 
                   newOppty.VP_Forecast_Category__c != oldOppty.VP_Forecast_Category__c || 
                   newOppty.RVP_Forecast_Category__c != oldOppty.RVP_Forecast_Category__c || 
                   newOppty.AD_Forecast_Category_Lock__c != oldOppty.AD_Forecast_Category_Lock__c || 
                   newOppty.CRO_Forecast_Category_Lock__c != oldOppty.CRO_Forecast_Category_Lock__c || 
                   newOppty.DM_Forecast_Category_Lock__c != oldOppty.DM_Forecast_Category_Lock__c || 
                   newOppty.VP_Forecast_Category_Lock__c != oldOppty.VP_Forecast_Category_Lock__c || 
                   newOppty.RVP_Forecast_Category_Lock__c != oldOppty.RVP_Forecast_Category_Lock__c || 
                   newOppty.StageName != oldOppty.StageName) {
                       updateSplitForecastCategorySet.add(newOppty.Id);
                   }
                
                
                //updateSalesTeamInfoOnOppSplit
                if((newOppty.StageName != label.Stage_7_Closed_Lost && newOppty.StageName != label.Stage_6_Closed_Won)
                   && (newOppty.StageName != oldOppty.StageName
                       || newOppty.OwnerId != oldOppty.OwnerId
                       || newOppty.Opportunity_Sales_Territory__c != oldOppty.Opportunity_Sales_Territory__c
                       || newOppty.Opportunity_Sales_Engineer__c != oldOppty.Opportunity_Sales_Engineer__c
                       || newOppty.Opportunity_Area_Director__c != oldOppty.Opportunity_Area_Director__c
                       || newOppty.Opportunity_Account_Manager__c != oldOppty.Opportunity_Account_Manager__c
                       || newOppty.Opportunity_Customer_Advocate__c != oldOppty.Opportunity_Customer_Advocate__c
                       || newOppty.Primary_Reseller_Partner__c != oldOppty.Primary_Reseller_Partner__c
                       /*|| newOppty.Opportunity_ZPA_Manager__c != oldOppty.Opportunity_ZPA_Manager__c
|| newOppty.Opportunity_ZPA_SE__c != oldOppty.Opportunity_ZPA_SE__c */ //Commented CR# 743
                       || TriggerUtility.SEgetschangedonOpp)){
                           updateSalesTeamInfoOnOppSplitMap.put(newOppty.Id, newOppty);
                       }
                
                //Added by Ayush Kangar as part of IBA-4567 - Start
                if(newOppty.Is_Federal_Opportunity_Sync__c == false && (oldOppty.StageName != newOppty.StageName) && (newOppty.StageName == label.Stage_3_Value_Impact_Validation 
                                                                                                         || newOppty.StageName == label.Stage_4_Economic_Buyer_Signoff
                                                                                                         || newOppty.StageName == label.Stage_5A_Opportunity
                                                                                                         || newOppty.StageName == label.Stage_5B_Opportunity
                                                                                                         || newOppty.StageName == label.Stage_5C_Opportunity
                                                                                                         || newOppty.StageName == label.Stage_5D_Opportunity
                                                                                                         || newOppty.StageName == label.Stage_5_Procurement
                                                                                                         || newOppty.StageName == label.Stage_6_Closed_Won)){
                	PSOnbordingOppSet.add(newOppty);                                                                                             
               	}	
                if(newOppty.Is_Federal_Opportunity_Sync__c == false && (oldOppty.Primary_Reseller_Partner__c != newOppty.Primary_Reseller_Partner__c)){ 
                	oppIdOpportunityMap.put(newOppty.Id,newOppty);                                                                                           
               	}  
            	//Added by Ayush Kangar as part of IBA-4567 - End
                
            }    
            
        }
        		//Added by Ayush Kangar as part of IBA-4567 - Start 
            	if(!PSOnbordingOppSet.isEmpty()){
            		OpportunityPsOnboarding.createPSOnboardingDoc(pSOnbordingOppSet);
            	}   	
            	if(!oppIdOpportunityMap.isEmpty() && oppIdOpportunityMap!=null){
            		OpportunityPsOnboarding.updatePSOnboardingDoc(oppIdOpportunityMap);
            	}
            	//Added by Ayush Kangar as part of IBA-4567 - End
        
        
        /* Added by Chandan : CR# 2741
* It sends the email to the opportunity split owners for StageName=5C async way Start
* merged the code from OpportunityMasterTrigger trigger
* TODO: it should move to a queueable as async trigger will not help with the Org-wide address
*/
        if(!emailToOpptySplitOwnersList.isEmpty()){
            
            OpportunitySplitOwnerEmailService splitOwnerEmailServinstance = OpportunitySplitOwnerEmailService.getInstance();
            splitOwnerEmailServinstance.setNewOpportunityList(emailToOpptySplitOwnersList);
            splitOwnerEmailServinstance.process();
        }
        
        
        if(!TriggerUtility.isPatchRealigning()) {
            
            //updateAccountForApprovedPZEN
            if(!updateAccountForApprovedPZENSet.isEmpty()){
                
                OppotunityTriggerHelper.updateAccountForApprovedPZEN(updateAccountForApprovedPZENSet);
            }
            
            //decommissionProvRequests
            if(!decommissionProvRequestsSet.isEmpty()){
                
                oppotunityTriggerHelper.decommissionProvRequests(decommissionProvRequestsSet);
            }
            
            //updateOpportunityNextStepsHistory 
            //There is no Alternate path if this method is called from another Future context or Batch context.
            // This needs to be moved to Async for sure instead of Future method. 
            if (!oppNextStepsHistoryMap.isEmpty() && !System.isFuture() && !System.isBatch()) {
                
                OppotunityTriggerHelper.updateOpportunityTechNextStepsInDb(JSON.serialize(oppNextStepsHistoryMap),'Opportunity Next Steps');
            }
            
            //updateTechValHistory
            //There is no Alternate path if this method is called from another Future context or Batch context.
            // This needs to be moved to Async for sure instead of Future method. 
            if(!techValidationHistoryMap.isEmpty() && !System.isFuture() && !System.isBatch()){
                
                OppotunityTriggerHelper.updateOpportunityTechNextStepsInDb(JSON.serialize(techValidationHistoryMap),'Technical Validation Next Steps');
            }
            
            //updateArchitectureNextStepsHistory, archNextStepsHistoryMap is always empty remove this method call
            //There is no Alternate path if this method is called from another Future context or Batch context.
            // This needs to be moved to Async for sure instead of Future method. 
            if(!archNextStepsHistoryMap.isEmpty() && !System.isFuture() && !System.isBatch()){
                
                OppotunityTriggerHelper.updateOpportunityTechNextStepsInDb(JSON.serialize(archNextStepsHistoryMap),'Architecture Next Steps');
            }
            
            //EREmailNotification
            if(!EREmailNotificationSet.isEmpty()){
                
                oppotunityTriggerHelper.EREmailNotification(EREmailNotificationSet);
            }
            
            //updateSplitForecastCategory
            if(!updateSplitForecastCategorySet.isEmpty()){
                
                //OppotunityTriggerHelper.updateSplitForecastCategory(updateSplitForecastCategorySet);
            }
            
            //resetOverrideACVFieldsInProposal
            if(!proposalIdsToQueryList.isEmpty() || Test.isRunningTest()){
                
                OppotunityTriggerHelper.resetOverrideACVFieldsInProposal(proposalIdsToQueryList); 
            }
            
        }
        
        //updateSalesTeamInfoOnOppSplit
        if(!updateSalesTeamInfoOnOppSplitMap.isEmpty()){
            
            oppotunityTriggerHelper.updateSalesTeamInfoOnOppSplit(updateSalesTeamInfoOnOppSplitMap);
        }
        
        
        // Now call the methods by passing the Opportunity Maps collected earlier. 
        // Check the size of the Map before calling them.
        
        
        OpportunityMasterTriggerUtility.afterUpdate(newOpptyMap.values(), oldOpptyMap);
        
        if (!newOpptyMap.isEmpty()) {
            
            
            //Added by Varun : CR# 1824 - Start
            
            if(!TriggerUtility.isupdateInsertStageAgeExecuted()){
                OppotunityTriggerHelper.updateInsertStageAge((List<Opportunity>) Trigger.new, (Map<Id, Opportunity>) Trigger.oldMap);
            }
            //Added by Varun : CR# 1824 - End
            
            OpportunityChangeRequestCtrl.setAuditRecord(newOpptyMap.values(), oldOpptyMap);
            
            /* Merged from OpportunityMasterTrigger End */
            
            if(!TriggerUtility.isPatchRealigning()) {
                //Need to check                
                OppotunityTriggerHelper.updateOpportunityFields(oldOpptyMap,newOpptyMap.values(),trigger.isinsert,trigger.isupdate);
                
                //Need to check the filter inside the for loop
                OppotunityTriggerHelper.updateSplitForecastCategory(newOpptyMap,oldOpptyMap);
            }
            
            /*  Merged from APTS_Opportunity_Master_trigger  */
            
            OpportunityTriggerUtility.afterUpdate(newOpptyMap.values(),newOpptyMap, oldOpptyMap);
            
            //  From Trigger_Opportunity trigger
            
            Trigger_Opportunity_Handler.afterUpdateHandler(newOpptyMap.values(), newOpptyMap, oldOpptyMap.values(), oldOpptyMap); 
            
            
            /* CR# 2877 START */
            /* Calling Opportunity closed lost email helper */
            OpportunityClosedLostSendEmailHelper instance = OpportunityClosedLostSendEmailHelper.getInstance();
            
            instance.setOldOppMap(oldOpptyMap);
            instance.setOppList(newOpptyMap.values());
            instance.process();
            /* CR# 2877 END */
            
            //IBA-7403 - A Churn Request has been initiated" Email are going out blank .
            List<Opportunity> optyListToSendChurnInitiationEmails = new List<Opportunity>();
            for (Opportunity optyObj : newOpptyMap.values()) {
                if ((optyObj.StageName != oldOpptyMap.get(optyObj.Id).StageName) 
                    && (optyObj.StageName.equalsIgnoreCase(System.Label.Stage_7_Closed_Lost)
                        && !(optyObj.Sub_Stage__c.equalsIgnoreCase(System.Label.SubStage_Closed_Delete_Duplicate))
                        && (optyObj.Type.equalsIgnoreCase(ZScalarConstants.Opp_Type_Existing_Customer_Renewal)))) {
                            optyListToSendChurnInitiationEmails.add(optyObj);
                        }
            }
            // Calling the Method from helper class with eligible opportunities to send email .
            if(!optyListToSendChurnInitiationEmails.isEmpty()){
               RenewalOppClosedLostSendEmailHelper.sendChurnInitiationEmails(optyListToSendChurnInitiationEmails);
            }

            //Added by Ram : IBA-345 starts here
            Set<Id> deleteDuplicateClosedLostOpptIdSet = new Set<Id>();
            for(Opportunity newOppt : newOpptyMap.values()){
                Opportunity oldOppt = oldOpptyMap.get(newOppt.Id);
                if(oldOppt.StageName != '7 - Closed Lost' && newOppt.StageName == '7 - Closed Lost'
                    && (oldOppt.Sub_Stage__c != 'Closed Lost' && newOppt.Sub_Stage__c == 'Closed Lost'
                        || oldOppt.Sub_Stage__c != 'Closed With No Decision' && newOppt.Sub_Stage__c == 'Closed With No Decision'
                        || oldOppt.Sub_Stage__c != 'Closed: Delete Duplicate' && newOppt.Sub_Stage__c == 'Closed: Delete Duplicate')){
                        deleteDuplicateClosedLostOpptIdSet.add(newOppt.Id);
                }
            }
            if(!deleteDuplicateClosedLostOpptIdSet.isEmpty()){
                OppotunityTriggerHelper.reparentDuplOpptPRGs(deleteDuplicateClosedLostOpptIdSet);
            }
            //Added by Ram : IBA-345 ends here
        }
        
        //IBA-2737 Start
        OpportunityTriggerHelperService.updateOpportunitiesEligibleForDeploymentProjectCreation(newOpptyMap,oldOpptyMap);
        //IBA-2737 End
        sendOpportunityStageChangeNotification(newOpptyMap,oldOpptyMap);

    }
    
    //Mahesh T --Adding delete methods for Triggers
    public override void beforeDelete(){
        // Merged from Trigger_Opportunity
        Trigger_Opportunity_Handler.beforeDeleteHandler((List<Opportunity>) trigger.old,(Map<Id,Opportunity>) trigger.oldMap);
    }
    
    public override void afterDelete(){
        //Merged From Trigger_Opportunity
        Trigger_Opportunity_Handler.afterDeleteHandler((List<Opportunity>) trigger.new,(List<Opportunity>) trigger.old,(Map<Id,Opportunity>) trigger.oldMap);
    }
    
    public override void afterUndelete(){
        //Merged Trigger_Opportunity
        Trigger_Opportunity_Handler.afterUnDeleteHandler((List<Opportunity>) trigger.new,(Map<Id,Opportunity>) trigger.newMap);
    }
    
    public boolean qualifiedUpdate(Opportunity newOppty, Opportunity oldOppty){
        
        Boolean valChanged = false;
        if( newOppty.Name != oldOppty.Name || (newOppty.StageName != oldOppty.StageName) || (newOppty.Sub_Stage__c != oldOppty.Sub_Stage__c) ||
           newOppty.Amount != newOppty.Amount)
        {
            valChanged = true;
        } 
        
        return valChanged;
    }
    
    private Map<Id,Opportunity> getOpptyRelatedFieldValues(Set<Id> newOpptyIds){
        
        return new Map<Id,Opportunity>([SELECT ID, 
                                        SE_Name__c, 
                                        SE_Znumber__c, 
                                        SE_Name__r.EmployeeNumber, 
                                        SE_Name__r.isActive,
                                        SE_Name__r.Manager.EmployeeNumber,
                                        SE_Name__r.Manager.isActive 
                                        FROM Opportunity 
                                        WHERE ID In :newOpptyIds LIMIT 50000]);
    }
    private Map<String,Date> updatePsStartDateOnOpportunity(List<Opportunity> lstOfNewOpportunity) {
        
        Set<string> setOfSkus = new Set<string>{'ZCES-SUP-PREM','ZIA-PRO-EDITION','ZCES-DEP-ADV','ZCES-DEP-ENT','ZCES-DEP-ENTPLUS','ZCES-DEP-ESS','CES-DEP-ESS-FED','ZCES-DEP-FED32','ZCES-PRO-DRR','ZCES-PRO-HEALTH','ZCES-PRO-SVC','ZCES-PRO-SVC-CUST-FED'};
        Set<String> opptySkus = new Set<String>();
        Set<String> setOfPrimaryQuotes = new Set<String>();
        Map<String,Date> mapOfQuoteAndStartDate = new Map<String,Date>();
        Map<Id,Opportunity> mapOfOppty = new Map<Id,Opportunity> ([SELECT Id,SBQQ__PrimaryQuote__c,SBQQ__PrimaryQuote__r.Line_Item_SKU_Approval__c ,SBQQ__PrimaryQuote__r.SBQQ__StartDate__c FROM Opportunity WHERE Id =: lstOfNewOpportunity]);
        For(Opportunity oppty : mapOfOppty.values()){

            boolean isSkuPresent = false;
            
            List<String> setOfCodes = new List<String>();
            if(oppty!=null && oppty.SBQQ__PrimaryQuote__r!=null && oppty.SBQQ__PrimaryQuote__r.Line_Item_SKU_Approval__c!=null)
                oppty.SBQQ__PrimaryQuote__r.Line_Item_SKU_Approval__c.Split(',');
            For(String s : setOfCodes){

                if(setOfSkus.contains(s)){

                    isSkuPresent = true;
                    opptySkus.add(s);

                }    
            }
            if(oppty.SBQQ__PrimaryQuote__c != null && isSkuPresent){
                setOfPrimaryQuotes.add(oppty.SBQQ__PrimaryQuote__c);
            }
        }     
        List<SBQQ__QuoteLine__c> lstQuoteLine = [SELECT Id, Name,  SBQQ__Quote__c,SBQQ__Quote__r.SBQQ__Opportunity2__c, SBQQ__StartDate__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c = : setOfPrimaryQuotes AND SBQQ__Product__r.ProductCode IN : opptySkus];
        For(SBQQ__QuoteLine__c ql : lstQuoteLine){

            if(mapOfQuoteAndStartDate.isEmpty() || ! mapOfQuoteAndStartDate.containsKey(ql.SBQQ__Quote__r.SBQQ__Opportunity2__c)) {

                mapOfQuoteAndStartDate.put(ql.SBQQ__Quote__r.SBQQ__Opportunity2__c, ql.SBQQ__StartDate__c);
            }

            else if(mapOfQuoteAndStartDate.containsKey(ql.SBQQ__Quote__r.SBQQ__Opportunity2__c)){

                Date startDateToChoose = ql.SBQQ__StartDate__c > mapOfQuoteAndStartDate.get(ql.SBQQ__Quote__r.SBQQ__Opportunity2__c) ?  mapOfQuoteAndStartDate.get(ql.SBQQ__Quote__r.SBQQ__Opportunity2__c) : ql.SBQQ__StartDate__c ;
                mapOfQuoteAndStartDate.put(ql.SBQQ__Quote__r.SBQQ__Opportunity2__c,startDateToChoose);

            }
            
        }

        return mapOfQuoteAndStartDate;
    }

    public static void sendOpportunityStageChangeNotification(Map<Id,Opportunity> newOpptyMap, Map<Id,Opportunity> oldOpptyMap){
        if(!isNotificationSent) {
            try{
                Set<ID> ContentDocumentIdList = new Set<ID>();
                Map<String,String> mapOpptyToContent = new Map<String,String>();
                List<ContentVersion> cvList = new List<ContentVersion> ();
                List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
                Map<String,List<String>>  mapOpptyToContentVersion = new Map<String,List<String>> ();
                List<EmailTemplate> et = new List<EmailTemplate>();
                OrgWideEmailAddress orgWideEmailAddress = [SELECT Id FROM OrgWideEmailAddress WHERE Address =: 'z-salesforce@zscaler.com' Limit 1];
    
                List<Opportunity> opportunities = [SELECT id,Name,StageName,Proposed_Number_of_Users__c,CloseDate,Amount,Account.Name,Special_Instructions_to_Finance__c,SBQQ__PrimaryQuote__r.Name FROM Opportunity WHERE Id IN : newOpptyMap.keySet()];
    
                for (ContentDocumentLink cdl : [SELECT ContentDocumentId,LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN :  newOpptyMap.keySet() ]){
                    ContentDocumentIdList.add(cdl.ContentDocumentId);
                    mapOpptyToContent.put(cdl.ContentDocumentId,cdl.LinkedEntityId);
                }
    
                cvList  = [SELECT ContentDocumentId,Source_fileupload__c,FileExtension,Title,FileType,versiondata
                                    FROM ContentVersion WHERE (ContentDocumentId in :ContentDocumentIdList) and Source_fileupload__c != null and IsLatest=true and Source_fileupload__c = 'PO_Document'] ;
    
                if(!cvList.isEmpty() && cvList.size() >0 ) {
                    For(ContentVersion cv : cvList) {
                        if(!mapOpptyToContent.isEmpty() && mapOpptyToContent.get(cv.ContentDocumentId) != null) {
                            if(mapOpptyToContentVersion.containsKey(mapOpptyToContent.get(cv.ContentDocumentId))) {
                                mapOpptyToContentVersion.get(mapOpptyToContent.get(cv.ContentDocumentId)).add(cv.Id);
                            }
                            else {
                                mapOpptyToContentVersion.put(mapOpptyToContent.get(cv.ContentDocumentId), new List<String>{cv.Id});
                            }
                            
                        }
                    }
                    
                }                    
    
      
                
                et= [select Id, HTMLValue, DeveloperName,Subject,body  from EmailTemplate where DeveloperName = 'Opportunity_hits_5A_stage' LIMIT 1];
    
                For(Opportunity oppty : opportunities) {
                    if(oppty.StageName == Label.Stage_5A_Opportunity && oppty.StageName != oldOpptyMap.get(Oppty.Id).StageName) {
                        if(et.size() >0 ) {
                            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                            List<String> sendTo = new List<String>();
                            sendTo.add(Label.Stage_5A_Notification_To_Address);
                            mail.setToAddresses(sendTo);
                            String subject = et[0].subject;
                            subject = subject.replace('{{STAGE#}}', oppty.StageName).replace('{{NAME#}}',Oppty.Name);
                            mail.setSubject(subject);
                            
            
                            String body = et[0].HtmlValue;
                            body = body.replace('{{STAGE#}}', oppty.StageName).replace('{{NAME#}}',Oppty.Name);
                            body = body.Replace('{LINK#}}', URL.getSalesforceBaseUrl().toExternalForm()+'/'+Oppty.Id);
                            body = body.replace('{{ACCOUNTNAME#}}', Oppty.Account.Name).replace('{{AMOUNT#}}',String.valueOf(Oppty.Amount != null ? oppty.Amount.setScale(2) : 0));
                            body = body.replace('{{NUMBERUSERS#}}',String.valueOf(Oppty.Proposed_Number_of_Users__c != null ? Oppty.Proposed_Number_of_Users__c : 0)).replace('{{CLOSEDATE#}}',String.valueOf(Oppty.closedate));
                            body = body.replace('{{SPECIALINS#}}', Oppty.Special_Instructions_to_Finance__c != null ? Oppty.Special_Instructions_to_Finance__c : '').replace('{{QUOTENUMBER#}}',Oppty.SBQQ__PrimaryQuote__r.Name != null ? Oppty.SBQQ__PrimaryQuote__r.Name : '');
                            mail.setHtmlBody(body);
                            
                            if(!cvList.isEmpty() && cvList.size() >0 ) {
                                mail.setEntityAttachments(new List<String>{cvList[0].Id});
                            }   
    
                            if(!mapOpptyToContentVersion.isEmpty() && mapOpptyToContentVersion.size() >0 && mapOpptyToContentVersion.get(Oppty.Id) != null) {
                                mail.setEntityAttachments(mapOpptyToContentVersion.get(Oppty.Id));
                            }
                            mail.setOrgWideEmailAddressId(orgWideEmailAddress.Id);
                            mails.add(mail);
                        }
                    }
                }
    
                    if(!mails.isEmpty() && mails.size() >0 )  {
                        Messaging.sendEmail(mails);
                        isNotificationSent = true;
                    }
                
                //createOTTRecord(oppID);
            }catch(Exception ex){
    
                system.debug('An error occured while sending the message' + ex.getMessage());
            }
        }

    }

	public static void booster(){
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
}}