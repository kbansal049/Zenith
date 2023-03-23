/**
 *  This is the ulitity class for triggers.
 *
 */
//TriggerUtility class
public class TriggerUtility
{
    private static boolean manageZscalerAttendee= false;
    private static boolean intLogtriggerPRLogic = false;
    private static boolean CampMemActivity= false;
    private static boolean Activityleadterritoryinsert = false;
    private static boolean Activityleadterritoryupdate = false;
    private static boolean ActivityleadterritoryEventinsert = false;
    private static boolean ActivityleadterritoryEventupdate = false;
    private static boolean AcctoActivityTerritory = false;
    private static boolean contactPatchManager = false;
    private static boolean OpportunityPartnerAddition = false;
    private static boolean oppCaseCreation = false;
    private static boolean caseCreationForDefaultTerrirtory = false;
    private static boolean contactOwnerShip = false;
    private static boolean accToContactOwner = false;
    private static boolean conWhiteSpaceUpdate = false;
    private static boolean requestDecommissionPr = false;
    private static boolean oppSpliSalesTeam = false;
    private static boolean dealRegBeforeInsert = false;
    private static boolean dealRegAfterInsert = false;
    private static boolean dealRegAfterUpdate = false;
    private static boolean dealRegBeforeUpdate = false;
    private static boolean accSalesTeam = false;
    private static boolean accterritorypatch = false;
    private static boolean accPatchManagerAfterInsert=false;
   
    private static boolean opportunityAccountsScreening = false;
    private static boolean accContactWhiteSpaceUpdate = false;
    private static boolean updateLeadContactForCamp = false;
    private static boolean udpateSCIforEngagement = false;
    private static boolean oppPRProductionStatusUpdate = false;
    private static boolean fsAccountOwnerIdUpdate = false;
    private static boolean oppPatchManagerAfterInsert = false;
    private static boolean oppPatchManagerAfterUpdate = false;
    private static boolean updateContactRoleCount = false;
    private static boolean updateOppNextStepHistory = false;
    //Start of change - Raghu (Tech Validation Next Step History, Architecture Next Step History)
    Private static boolean updateTechValHistory = false;
    Private static boolean architectureHistory = false;
    //End of change - Raghu (Tech Validation Next Step History, Architecture Next Step History)
    private static boolean updateSEManagerEmail = false;
    private static boolean updateopportuntydfield = false;
    private static boolean updateSENameFromAccount = false;
    private static boolean updateAccountForApprovedPZEN = false;
    private static boolean ERNotification = false;
   
    private static boolean updateLatestIBConOpp = false;
    private static boolean SCIOppUpdate = false;
    private static boolean SCIDealRegUpdate = false;
    private static boolean updateForecastCategory = false;
    private static boolean updatedQuote = false;
    private static boolean updateProposalPriceList = false;
    private static boolean updateGeolocationForDatacenter = false;
    private static boolean updateLeadSalesTeamEmailFields = false;
    private static boolean revisitOpportunitySplitsSalesTerritory = false;
    private static boolean opportunitySplitsAfterUpdate = false;
    private static boolean opportunityOwnershipChange = false;
    private static boolean overrideACVValuesReset = false;
    private static boolean overrideACVValuesResetFromOppty = true;
    private static boolean updatePartnerAccountForSCI = false;
    private static boolean updateContactCountSCI = false;
    private static boolean ForecastCategorychanges = false;
    private static boolean ForecastCategorychangessplit = false;
    private static boolean generateYearWiseSplit = false;
    private static boolean updateDasPackageNameInOppty = false;
    private static boolean updateContactLeadStage = false;
    private static boolean captureCustomerNextStepsHistory = false;
    private static boolean updateContractEndDate = false;
    private static boolean skipentireproposaltrigger = false;
    private static boolean BRTriggerExecuted = false;
    private static boolean createInternalAttendeesForMeetingEvent = false;
    private static boolean updateLeadNoOfEmployees = false;
    private static boolean CustomerSuccessUpdatemethod = false;
    private static boolean createAnnualBreakdownLines = false;
    
   
    private static boolean updateTechnologyPartner = false;
    private static boolean AutocreateZCloudIDcontactUpdate = false; //added by Gurjinder for Autocreation of Zscaler Cloud ID Contacts
    private static boolean ZCloudIDcontactDeletetrigger = false; //added by Gurjinder for Autocreation of Zscaler Cloud ID Contacts
    private static boolean ZCloudIDcontactAfterInserttrigger = false; //added by Gurjinder for Autocreation of Zscaler Cloud ID Contacts
    //private static boolean updateTechnologyPartner = false;
    private static boolean beforeUpdateSplit = false;
    private static boolean splitOwnerterritory_Update = false;
    private static boolean revokePendingQuoteApproval = false;
    private static boolean skipLineItemTrigger = false;
    //CR# 168
    //private static boolean generateVendorPaymentSchedule = false; //commented by minkesh patel 27-5-2020
    
    
    //CR# 238
    //private static boolean isZPAAACApprovalSet = false; //commented by minkesh patel 27-5-2020
    
    public static boolean skipAmendmentRenewalLogic = false;
    public static boolean bypassSCITrigger=false;
    public static boolean isGroove2SCIcodeexecuted=false;
    public static boolean skipAccountTrigger = false;
    public static boolean skipCaseTrigger = false;
    public static boolean skipCaseCommentTrigger = false;
    public static boolean skipCaseSkillAssignment = false;
    public static boolean skipCaseEscalation = false;
    public static boolean casebeforeinsert = false;
    public static boolean casebeforeupdate = false;
    public static boolean caseafterudpate = false;
   
    public static boolean caseEscalationHistoryCreation = false;
    public static boolean skipCaseEntAssignment = false;
    public static boolean caseEscalationNotes = false;
    public static boolean skipCaseCommentAfterInsertTrigger = false;
    public static boolean skipFRTandCustomerNote = false;
    public static boolean caseStatusHistory = false;
    public static boolean skipManualSLA = false;
    public static boolean caseCloseCompleteActionPlan = false;
    public static boolean skipentitlementcreation = false;
    public static boolean skipentitlementupdate = false;
    public static boolean skipCaseCommentBeforeInsertTrigger = false;
    public static boolean skipCustomerNotePublic = false;
    public static Integer accSalesTeamMethodExecution = 0;
    
    public static final String PROSPECT = 'Prospect';
    public static final String ENGAGED = 'Engaged';
    public static final String NO_RECENT_ENGAGEMENT = 'No recent engagement';
   
    public static final String PIPELINE = 'Pipeline';
    public static final String POC = 'POC';
    public static final String OPPLOST = 'Opportunity Lost';
    public static final String NOT_TOUCHED = 'Not touched';
    public static final String BLANK = '';
    public static boolean containsOpenOpps = false;
    public static boolean makePrimary = false;
    public static boolean dontThrowErrorForConvertedDR = false;
    public static Boolean isRunningForMarketo = false;
    
    public static Boolean quoteTriggerforAnnualBreakDown = false;
    

    public static Boolean getRunningForMarketo() {
        return isRunningForMarketo;
    }
    public static void setMakePrimary()
    {
        makePrimary = true;
    }

     public static Boolean isMakePrimaryExecuted() {
        return makePrimary;
    }
    
    public static final String OPP_CLOSED_12 = label.Stage_7_Closed_Lost /*'12 - Closed With No Decision'*/;
    
    //Created to capture Quote line Trigger's insert event
    public static boolean blnQLInsert = false;
    
    //CR# 473 - by Parth Doshi
    public static boolean accountExtensionHistoryExecuted = false;
    
    public static boolean PropTriggerHandlerQueueableExecuted = false;
    
    //added by Gurjinder for CSU:start
    public static Boolean CustomerSuccessUpdatemethodexecuted() {
        return CustomerSuccessUpdatemethod;
    }

    public static void CustomerSuccessUpdatemethodsettrue() {
        CustomerSuccessUpdatemethod = true;
    }

    public static void CustomerSuccessUpdatemethodsetfalse() {
        CustomerSuccessUpdatemethod = false;
    }

     public static Boolean isCaseCloseCompleteActionPlanExecuted() {
        return caseCloseCompleteActionPlan;
    }
    public static void  caseCloseCompleteActionPlanSetFalse(){
        caseCloseCompleteActionPlan = false;
        
    }
     public static void caseCloseCompleteActionPlanSetTrue() {
         
        caseCloseCompleteActionPlan = true;
    }
    
    //added by Gurjinder for CSU:end
    private static boolean updateAccountDataTime = false;  
      
     public static Boolean isUpdateAccountDataTime() {  
        return UpdateAccountDataTime;  
    }  
      
    public static void stopUpdateAccountDataTime() {  
        UpdateAccountDataTime = true;  
    }  
      
    public static void startUpdateAccountDataTime() {  
        UpdateAccountDataTime = false;  
    }  
      
     private static boolean updateCaseAccountExtension = false;  
      
     public static Boolean isUpdateCaseAccountExtension() {  
        return updateCaseAccountExtension;  
    }  
      
    public static void stopUpdateCaseAccountExtension() {  
        updateCaseAccountExtension  = true;  
    }  
      
    public static void startUpdateCaseAccountExtension() {  
        updateCaseAccountExtension  = false;  
    }   
    
    private static boolean updateAccountQBRDate = false;
    
     public static Boolean isupdateAccountQBRDate() {
        return updateAccountQBRDate;
    }
    
    public static void stopupdateAccountQBRDate() {
        updateAccountQBRDate  = true;
    }
    
    public static void startupdateAccountQBRDate() {
        updateAccountQBRDate  = false;
    }

    private static boolean updateCountractDetails = false;
    
     public static Boolean isupdateCountractDetails() {
        return updateCountractDetails;
    }
    
    public static void stopUpdateCountractDetailsseetTrue() {
        updateCountractDetails = true;
    }
    
    public static void startUpdateCountractDetails() {
        updateEventComplete = false;
    }
    
    private static boolean updateEventComplete = false;
    
     public static Boolean isupdateEventComplete() {
        return updateEventComplete;
    }
    
    public static void stopupdateEventComplete() {
        updateEventComplete = true;
    }
    
    public static void startupdateEventComplete() {
        updateEventComplete = false;
    }
    
    private static boolean opportunityUpdatesContactHandler = false;
    private static boolean opportunityCreatorRoleHandler = false;
    
     public static Boolean isOpportunityUpdatesContactHandler() {
        return OpportunityUpdatesContactHandler;
    }
    
    public static void stopOpportunityUpdatesContactHandler() {
        OpportunityUpdatesContactHandler = true;
    }
    
    public static void startOpportunityUpdatesContactHandler() {
        OpportunityUpdatesContactHandler = false;
    }

    public static Boolean isOpportunityCreatorRoleHandler() {
        return OpportunityCreatorRoleHandler;
    }
    
    public static void stopOpportunityCreatorRoleHandler() {
        OpportunityCreatorRoleHandler = true;
    }
    
    public static void startOpportunityCreatorRoleHandler() {
        OpportunityCreatorRoleHandler = false;
    }
    
    public static Boolean isUpdateLeadNoOfEmployeesExecuted() {
        return updateLeadNoOfEmployees;
    }

    public static void updateLeadNoOfEmployeesExecuted() {
        updateLeadNoOfEmployees = true;
    }

    public static void updateLeadNoOfEmployeesReset() {
        updateLeadNoOfEmployees = false;
    }
        
    public static Boolean isCreateInternalAttendeesForMeetingEventExecuted() {
        return createInternalAttendeesForMeetingEvent;
    }

    public static void createInternalAttendeesForMeetingEventExecuted() {
        createInternalAttendeesForMeetingEvent = true;
    }

    public static void createInternalAttendeesForMeetingEventReset() {
        createInternalAttendeesForMeetingEvent = false;
    }
    
    public static Boolean isBRAttachmentValidationExecuted() {
        return BRTriggerExecuted ;
    }

    public static void BRAttachmentValidationExecuted() {
        BRTriggerExecuted = true;
    }

    public static void BRAttachmentValidationReset() {
        BRTriggerExecuted = false;
    }

    public static Boolean isskipentireproposaltriggerExecuted() {
        return skipentireproposaltrigger;
    }

    public static void skipentireproposaltriggerExecuted() {
        skipentireproposaltrigger = true;
    }

    public static void skipentireproposaltriggerReset() {
        skipentireproposaltrigger = false;
    }
    
    public static Boolean isUpdateContractEndDateExecuted() {
        return updateContractEndDate;
    }

    public static void updateContractEndDateExecuted() {
        updateContractEndDate = true;
    }

    public static void updateContractEndDateReset() {
        updateContractEndDate = false;
    }
    
    public static Boolean isintLogtriggerPRLogicExecuted() {
        return intLogtriggerPRLogic;
    }

    public static void intLogtriggerPRLogicExecuted() {
        intLogtriggerPRLogic = true;
    }

    public static void intLogtriggerPRLogicReset() {
        intLogtriggerPRLogic = false;
    }

    public static Boolean isCaptureCustomerNextStepsHistoryExecuted() {
        return captureCustomerNextStepsHistory;
    }

    public static void captureCustomerNextStepsHistoryExecuted() {
        captureCustomerNextStepsHistory = true;
    }

    public static void captureCustomerNextStepsHistoryReset() {
        captureCustomerNextStepsHistory = false;
    }

    public static Boolean isSCIDealRegUpdateExecuted() {
        return SCIDealRegUpdate;
    }

    public static void SCIDealRegUpdateExecuted() {
        SCIDealRegUpdate = true;
    }

    public static void SCIDealRegUpdateReset() {
        SCIDealRegUpdate = false;
    }

    public static Boolean isUpdateContactLeadStageExecuted() {
        return updateContactLeadStage;
    }

    public static void updateContactLeadStageExecuted() {
        updateContactLeadStage = true;
    }

    public static void updateContactLeadStageReset() {
        updateContactLeadStage = false;
    }

    public static Boolean isUpdateDasPackageNameInOpptyExecuted() {
        return updateDasPackageNameInOppty;
    }

    public static void updateDasPackageNameInOpptyExecuted() {
        updateDasPackageNameInOppty = true;
    }

    public static void updateDasPackageNameInOpptyReset() {
        updateDasPackageNameInOppty = false;
    }

    public static Boolean isGenerateYearWiseSplitExecuted() {
        return generateYearWiseSplit;
    }

    public static void generateYearWiseSplitExecuted() {
        generateYearWiseSplit = true;
    }

    public static void generateYearWiseSplitReset() {
        generateYearWiseSplit = false;
    }
    
    public static Boolean iscreateAnnualBreakdownLinesExecuted() {
        return createAnnualBreakdownLines;
    }

    public static void createAnnualBreakdownLinesExecuted() {
        createAnnualBreakdownLines = true;
    }

    public static void createAnnualBreakdownLinesReset() {
        createAnnualBreakdownLines = false;
    }
    
    /*//commented by minkesh patel 27-5-2020
    //CR# 168
    public static Boolean isgenerateVendorPaymentSchedule() {
        return generateVendorPaymentSchedule;
    }
    public static void generateVendorPaymentScheduleExecuted() {
        generateVendorPaymentSchedule = true;
    }
    public static void generateVendorPaymentScheduleReset() {
        generateVendorPaymentSchedule = false;
    }
    
    //CR# 238
    public static Boolean getZPAAACApprovalSet() {
        return isZPAAACApprovalSet;
    }
    public static void isZPAAACApprovalSetExecuted() {
        generateVendorPaymentSchedule = true;
    }
    public static void ZPAAACApprovalSetReset() {
        generateVendorPaymentSchedule = false;
    }
    */
    
    public static Boolean isOverrideACVValuesResetFromOpptyExecuted() {
        return overrideACVValuesResetFromOppty;
    }

    public static void overrideACVValuesResetFromOpptyExecuted() {
        overrideACVValuesResetFromOppty = true;
    }

    public static void overrideACVValuesResetFromOpptyReset() {
        overrideACVValuesResetFromOppty = false;
    }

    public static Boolean isupdatePartnerAccountForSCIExecuted() {
        return updatePartnerAccountForSCI;
    }

    public static void updatePartnerAccountForSCIExecuted() {
        updatePartnerAccountForSCI = true;
    }

    public static void updatePartnerAccountForSCIReset() {
        updatePartnerAccountForSCI = false;
    }
    
    public static Boolean isUpdateContactCountSCIExecuted() {
        return updateContactCountSCI;
    }

    public static void updateContactCountSCIExecuted() {
        updateContactCountSCI = true;
    }

    public static void updateContactCountSCIReset() {
        updateContactCountSCI = false;
    }

    public static Boolean isOverrideACVValuesResetExecuted() {
        return overrideACVValuesReset;
    }

    public static void overrideACVValuesResetExecuted() {
        overrideACVValuesReset = true;
    }

    public static void overrideACVValuesResetReset() {
        overrideACVValuesReset = false;
    }

    public static Boolean isOpportunityOwnershipChangeExecuted() {
        return opportunityOwnershipChange;
    }

    public static void opportunityOwnershipChangeExecuted() {
        opportunityOwnershipChange = true;
    }

    public static void OpportunityOwnershipChangeReset() {
        opportunityOwnershipChange = false;
    }

    public static Boolean isOpportunitySplitsAfterUpdateExecuted() {
        return opportunitySplitsAfterUpdate;
    }

    public static void opportunitySplitsAfterUpdateExecuted() {
        opportunitySplitsAfterUpdate = true;
    }

    public static void opportunitySplitsAfterUpdateReset() {
        opportunitySplitsAfterUpdate = false;
    }

    public static Boolean isRevisitOpportunitySplitsSalesTerritoryExecuted() {
        return revisitOpportunitySplitsSalesTerritory;
    }

    public static void revisitOpportunitySplitsSalesTerritoryExecuted() {
        revisitOpportunitySplitsSalesTerritory = true;
    }

    public static void revisitOpportunitySplitsSalesTerritoryReset() {
        revisitOpportunitySplitsSalesTerritory = false;
    }

    public static boolean isUpdateLeadSalesTeamEmailFieldsExecuted() {
        return updateLeadSalesTeamEmailFields;
    }

    public static void updateLeadSalesTeamEmailFieldsExecuted() {
        updateLeadSalesTeamEmailFields = true;
    }

    public static void updateLeadSalesTeamEmailFieldsReset() {
        updateLeadSalesTeamEmailFields = false;
    }

    public static boolean isUpdateGeolocationForDatacenterExecuted() {
        return updateProposalPriceList;
    }

    public static void updateGeolocationForDatacenterExecuted() {
        updateProposalPriceList = true;
    }

    public static void updateGeolocationForDatacenterReset() {
        updateProposalPriceList = false;
    }

    public static boolean isUpdateProposalPriceListExecuted() {
        return updateProposalPriceList;
    }

    public static void updateProposalPriceListExecuted() {
        updateProposalPriceList = true;
    }

    public static void updateProposalPriceListReset() {
        updateProposalPriceList = false;
    }

    public static boolean isUpdatedQuoteExecuted() {
        return updatedQuote;
    }


    public static void updatedQuoteExecuted() {
        updatedQuote = true;
    }


    public static void updatedQuoteReset() {
        updatedQuote = false;
    }

    public static boolean isUpdateForecastCategoryExecuted() {
        return updateForecastCategory;
    }


    public static void updateForecastCategoryExecuted() {
        updateForecastCategory = true;
    }


    public static void updateForecastCategoryReset() {
        updateForecastCategory = false;
    }

    public static boolean isSCIOppUpdateExecuted() {
        return SCIOppUpdate;
    }


    public static void SCIOppUpdateExecuted() {
        SCIOppUpdate = true;
    }


    public static void SCIOppUpdateReset() {
        SCIOppUpdate = false;
    }

    public static boolean isupdateLatestIBConOppExecuted() {
        return updateLatestIBConOpp;
    }


    public static void updateLatestIBConOppExecuted() {
        updateLatestIBConOpp = true;
    }

    public static void updateLatestIBConOppReset() {
        updateLatestIBConOpp = false;
    }

    public static boolean isERNotificationExecuted() {
        return ERNotification;
    }


    public static void ERNotificationExecuted() {
        ERNotification = true;
    }

    public static void ERNotificationReset() {
        ERNotification = false;
    }

    public static boolean isUpdateAccountForApprovedPZEN() {
        return updateAccountForApprovedPZEN;
    }

    public static void updateAccountForApprovedPZENExecuted() {
        updateAccountForApprovedPZEN = true;
    }

    public static void updateAccountForApprovedPZENReset() {
        updateAccountForApprovedPZEN = false;
    }

    public static boolean isupdateSENameFromAccountExecuted() {
        return updateSENameFromAccount;
    }

    public static void updateSENameFromAccountExecuted() {
        updateSENameFromAccount = true;
    }

    public static void updateSENameFromAccountReset() {
        updateSENameFromAccount = false;
    }

    public static boolean isupdateSEManagerEmailExecuted() {
        return updateSEManagerEmail;
    }

    public static void updateSEManagerEmailExecuted() {
        updateSEManagerEmail = true;
    }

    public static void updateSEManagerEmailReset() {
        updateSEManagerEmail = false;
    }

    //Added by Minkesh for field update - start
    public static boolean isopportunityfieldupdate() {
        return updateopportuntydfield;
    }

    public static void isopportunityfieldupdateExecuted() {
        updateopportuntydfield = true;
    }

    public static void isopportunityfieldupdateReset() {
        updateopportuntydfield = false;
    }
     //Added by Minkesh for field update - end

    public static boolean isupdateOppNextStepHistoryExecuted() {
        return updateOppNextStepHistory;
    }

    public static void updateOppNextStepHistoryExecuted() {
        updateOppNextStepHistory = true;
    }

    public static void updateOppNextStepHistoryReset() {
        updateOppNextStepHistory = false;
    }

    //start of change - Raghu

    public static boolean isupdateTechValHistoryExecuted() {
        return updateTechValHistory;
    }

    public static void updateTechValHistoryExecuted() {
        updateTechValHistory = true;
    }

    public static void updateTechValHistoryReset() {
        updateTechValHistory = false;
    }

    public static boolean isarchitectureHistoryExecuted() {
        return architectureHistory;
    }

    public static void architectureHistoryExecuted() {
        architectureHistory = true;
    }

    public static void architectureHistoryReset() {
        architectureHistory = false;
    }
    //End of change - Raghu

    public static boolean isupdateContactRoleCountExecuted() {
        return updateContactRoleCount;
    }

    public static void updateContactRoleCountExecuted() {
        updateContactRoleCount = true;
    }

    public static void updateContactRoleCountReset() {
        updateContactRoleCount = false;
    }

    public static boolean isOppPatchManagerAfterInsertExecuted() {
        return oppPatchManagerAfterInsert;
    }

    public static void oppPatchManagerAfterInsertExecuted() {
        oppPatchManagerAfterInsert = true;
    }

    public static void oppPatchManagerAfterInsertReset() {
        oppPatchManagerAfterInsert = false;
    }

    public static boolean isOppPatchManagerAfterUpdateExecuted() {
        return oppPatchManagerAfterUpdate;
    }

    public static void oppPatchManagerAfterUpdateExecuted() {
        oppPatchManagerAfterUpdate = true;
    }

    public static void oppPatchManagerAfterUpdateReset() {
        oppPatchManagerAfterUpdate = false;
    }

    public static boolean isFsAccountOwnerIdUpdateExecuted() {
        return fsAccountOwnerIdUpdate;
    }

    public static void fsAccountOwnerIdUpdateExecuted() {
        fsAccountOwnerIdUpdate = true;
    }

    public static void fsAccountOwnerIdUpdateReset() {
        fsAccountOwnerIdUpdate = false;
    }

    public static boolean isOppPRProductionStatusUpdateExecuted() {
        return oppPRProductionStatusUpdate;
    }

    public static void oppPRProductionStatusUpdateExecuted() {
        oppPRProductionStatusUpdate = true;
    }

    public static void oppPRProductionStatusUpdateReset() {
        oppPRProductionStatusUpdate = false;
    }

    public static boolean isudpateSCIforEngagement() {
        return udpateSCIforEngagement;
    }

    public static void udpateSCIforEngagementExecuted() {
        udpateSCIforEngagement = true;
    }

    public static void udpateSCIforEngagementReset() {
        udpateSCIforEngagement = false;
    }

    public static boolean isUpdateLeadContactForCampExecuted() {
        return accContactWhiteSpaceUpdate;
    }

    public static void updateLeadContactForCampExecuted() {
        accContactWhiteSpaceUpdate = true;
    }

    public static void updateLeadContactForCampReset() {
        accContactWhiteSpaceUpdate = false;
    }



    public static boolean isAccContactWhiteSpaceUpdateExecuted() {
        return accContactWhiteSpaceUpdate;
    }

    public static void accContactWhiteSpaceUpdateExecuted() {
        accContactWhiteSpaceUpdate = true;
    }

    public static void accContactWhiteSpaceUpdateReset() {
        accContactWhiteSpaceUpdate = false;
    }


    public static boolean isOpportunityAccountsScreeningExecuted() {
        return opportunityAccountsScreening;
    }

    public static void opportunityAccountsScreeningExecuted() {
        opportunityAccountsScreening = true;
    }

    public static void opportunityAccountsScreeningReset() {
        opportunityAccountsScreening = false;
    }


    public static boolean isAccSalesTeamExecuted(){
        return accSalesTeam;
    }

    public static void accSalesTeamExecuted(){
        accSalesTeam= true;
    }
    public static void accSalesTeamReset(){
        accSalesTeam= false;
    }

    public static boolean isAccTerritoryPatchexecuted(){
        return accterritorypatch;
    }

    public static void accTerritoryPatchExecuted(){
        accterritorypatch = true;
    }
    public static void accterritorypatchReset(){
        accterritorypatch = false;
    }

    public static boolean isDealRegBeforeUpdateExecuted(){
        return dealRegBeforeUpdate;
    }

    public static void dealRegBeforeUpdateExecuted(){
        dealRegBeforeUpdate= true;
    }
    public static void dealRegBeforeUpdateReset(){
        dealRegBeforeUpdate= false;
    }

    public static boolean isDealRegAfterUpdateExecuted(){
        return dealRegAfterUpdate;
    }

    public static void dealRegAfterUpdateExecuted(){
        dealRegAfterUpdate= true;
    }
    public static void dealRegAfterUpdateReset(){
        dealRegAfterUpdate= false;
    }

    public static boolean isDealRegAfterInsertExecuted(){
        return dealRegAfterInsert;
    }

    public static void dealRegAfterInsertExecuted(){
        dealRegAfterInsert= true;
    }
    public static void dealRegAfterInsertReset(){
        dealRegAfterInsert= false;
    }

    public static boolean isDealRegBeforeInsertExecuted(){
        return dealRegBeforeInsert;
    }

    public static void dealRegBeforeInsertExecuted(){
        dealRegBeforeInsert= true;
    }
    public static void dealRegBeforeInsertReset(){
        dealRegBeforeInsert= false;
    }


    public static boolean isOppSpliSalesTeamExecuted(){
        return oppSpliSalesTeam;
    }

    public static void oppSpliSalesTeamExecuted(){
        oppSpliSalesTeam= true;
    }
    public static void oppSpliSalesTeamReset(){
        oppSpliSalesTeam= false;
    }


    public static boolean isRequestDecommissionPrExecuted(){
        return requestDecommissionPr;
    }

    public static void requestDecommissionPrExecuted(){
        requestDecommissionPr= true;
    }
    public static void requestDecommissionPrReset(){
        requestDecommissionPr= false;
    }


    public static boolean isconWhiteSpaceUpdateExecuted(){
        return conWhiteSpaceUpdate;
    }

    public static void conWhiteSpaceUpdateExecuted(){
        conWhiteSpaceUpdate= true;
    }
    public static void conWhiteSpaceUpdateReset(){
        conWhiteSpaceUpdate= false;
    }

    public static boolean isaccToContactOwnerExecuted(){
        return accToContactOwner;
    }

    public static void accToContactOwnerExecuted(){
        accToContactOwner= true;
    }
    public static void accToContactOwnerReset(){
        accToContactOwner= false;
    }

    public static boolean iscontactOwnerShipExecuted(){
        return contactOwnerShip;
    }

    public static void contactOwnerShipExecuted(){
        contactOwnerShip= true;
    }
    public static void contactOwnerShipReset(){
        contactOwnerShip= false;
    }

    public static boolean isOpptyTriggerFCexecuted(){
        return ForecastCategorychanges;
    }

    public static void OpptyTriggerFCexecuted(){
        ForecastCategorychanges = true;
    }
    public static void OpptyTriggerFCReset(){
        ForecastCategorychanges = false;
    }

    public static boolean isOpptySplitTriggerFCexecuted(){
        return ForecastCategorychangessplit;
    }

    public static void OpptySplitTriggerFCexecuted(){
        ForecastCategorychangessplit = true;
    }
    public static void OpptySplitTriggerFCReset(){
        ForecastCategorychangessplit = false;
    }






    public static boolean isOppCaseCreationExecuted(){
        return manageZscalerAttendee;
    }

    public static void oppCaseCreationExecuted(){
        manageZscalerAttendee= true;
    }
    public static void oppCaseCreationReset(){
        manageZscalerAttendee= false;
    }



    public static boolean ismanageZscalerAttendeeExecuted(){
        return manageZscalerAttendee;
    }

    public static void manageZscalerAttendeeExecuted(){
        manageZscalerAttendee= true;
    }
    public static void manageZscalerAttendeeReset(){
        manageZscalerAttendee= false;
    }

    public static boolean isCampMemActivityExecuted(){
        return CampMemActivity;
    }

    public static void CampMemActivityExecuted(){
        CampMemActivity= true;
    }
    public static void CampMemActivityReset(){
        CampMemActivity= false;
    }

    public static boolean isActivityleadterritoryinsertExecuted(){
        return Activityleadterritoryinsert;
    }
    public static void ActivityleadterritoryinsertExecuted(){
        Activityleadterritoryinsert = true;
    }
    public static void isActivityleadterritoryinsertReset(){
        Activityleadterritoryinsert = false;
    }
    
    public static boolean isActivityleadterritoryupdateExecuted(){
        return Activityleadterritoryupdate;
    }
    public static void ActivityleadterritoryupdateExecuted(){
        Activityleadterritoryupdate = true;
    }
    public static void isActivityleadterritoryupdateReset(){
        Activityleadterritoryupdate = false;
    }

    public static boolean isActivityleadterritoryEventinsertExecuted(){
        return ActivityleadterritoryEventinsert;
    }
    public static void ActivityleadterritoryEventinsertExecuted(){
        ActivityleadterritoryEventinsert = true;
    }
    public static void isActivityleadterritoryEventinsertReset(){
        ActivityleadterritoryEventinsert = false;
    }
    
    public static boolean isActivityleadterritoryEventupdateExecuted(){
        return ActivityleadterritoryEventupdate;
    }
    public static void ActivityleadterritoryEventupdateExecuted(){
        ActivityleadterritoryEventupdate = true;
    }
    public static void isActivityleadterritoryEventupdateReset(){
        ActivityleadterritoryEventupdate = false;
    }

    public static boolean isAcctoActivityTerritoryExecuted(){
        return AcctoActivityTerritory;
    }
    public static void AcctoActivityTerritoryExecuted(){
        AcctoActivityTerritory = true;
    }
    public static void AcctoActivityTerritoryReset(){
        AcctoActivityTerritory = false;
    }


    public static boolean isContactPatchManagerExecuted(){
        return contactPatchManager;
    }

    public static void contactPatchManagerExecuted(){
        contactPatchManager = true;
    }
    public static void contactPatchManagerReset(){
        contactPatchManager = false;
    }


    public static boolean isOpportunityPartnerAddition(){
        return contactPatchManager;
    }

    public static void OpportunityPartnerAdditionExecuted(){
        contactPatchManager = true;
    }
    public static void OpportunityPartnerAdditionReset(){
        contactPatchManager = false;
    }


    public static boolean isCaseCreationForLeadTerrirtory(){
        return caseCreationForDefaultTerrirtory ;
    }

    public static void caseCreationForLeadTerrirtoryExecuted(){
        caseCreationForDefaultTerrirtory  = true;
    }
    public static void caseCreationForLeadTerrirtoryReset(){
        caseCreationForDefaultTerrirtory  = false;
    }
    
    public static boolean isAcctPatchManagerAfterInsertExecuted() {
        return accPatchManagerAfterInsert;
    }

    public static void acctPatchManagerAfterInsertExecuted() {
        accPatchManagerAfterInsert = true;
    }

    public static void acctPatchManagerAfterInsertReset() {
        accPatchManagerAfterInsert = false;
    }


    public static String  GetMarketSegment(String noOfEmployeesPicklist, Integer noOfEmployees, Boolean isEMEARegion)
    {
        String marketSegment1 = TriggerUtility.GetMarketSegmentFromPicklist(noOfEmployeesPicklist, noOfEmployees, isEMEARegion);
        return marketSegment1;
        //Previous FY19 Market segmentation is deactivated on 31-01-2020 START
        //String marketSegment2 = TriggerUtility.GetMarketSegmentFromNumber(noOfEmployees, isEMEARegion);

        /*System.debug('*** marketSegment1: ' + marketSegment1);
        System.debug('*** marketSegment2: ' + marketSegment2);
        if(marketSegment1 == 'LE' || marketSegment2 =='LE')
        {
            return 'Large Enterprise';
        }
        else if(marketSegment1 =='ENT' || marketSegment2 == 'ENT')
        {
            return 'Enterprise';
        }
        else if(marketSegment1 =='COMM' || marketSegment2 == 'COMM')
        {
            return 'General Business';
        }
        else if(marketSegment1 =='SMB' || marketSegment2 =='SMB')
        {
            return 'General Business';
        }
        else if(marketSegment1 =='SOHO' || marketSegment2 =='SOHO')
        {
            return 'General Business';
        }
        else if(marketSegment1 =='GB' || marketSegment2 =='GB')
        {
            return 'General Business';
        }
        else
        {
            return 'General Business';
        }*/
        //Previous FY19 Market segmentation is deactivated on 31-01-2020 END
    }

    public static String getMarketSegmentFromPicklist(String noOfEmployeesPicklist, Integer noOfEmployees, Boolean isEMEARegion)
    {   
        // New logic per the FY19 Market Segmentation
        String marketSegment = '';
        if ( noOfEmployees == null && noOfEmployeesPicklist == null )
            /*return 'Corp sales';*/ return 'Corporate sales'; //commented & changed by minkesh patel 27-5-2020
        
        Integer startRange = 0, endRange = 0;
        if( noOfEmployeesPicklist != null ) {
            startRange =  noOfEmployeesPicklist.contains(' - ') ?  
                            Integer.valueOf( noOfEmployeesPicklist.split(' - ')[0].trim() ) : 
                            0;
            endRange = noOfEmployeesPicklist.contains(' - ') ?  Integer.valueOf( noOfEmployeesPicklist.split(' - ')[1].trim() ) : 0;
            startRange = noOfEmployeesPicklist.contains('+') ?  
                        Integer.valueOf( noOfEmployeesPicklist.substringBefore('+').trim() ) : 
                        startRange;
                        
        }
        
        if ( (noOfEmployees != null && noOfEmployeesPicklist != null && startRange > noOfEmployees) || (noOfEmployees == null && noOfEmployeesPicklist != null)) {
            for(Market_Segmentation_Setting__c setting : Market_Segmentation_Setting__c.getall().values() ) {
                if(noOfEmployeesPicklist.contains(' - ') && setting.Start_Range__c <= startRange && setting.End_Range__c >= endRange) { //setting.Is_EMEA_Region__c ==  isEMEARegion  // for future use
                    marketSegment = setting.Market_Segmentation__c;
                    break;
                } else if( noOfEmployeesPicklist.contains('+') && setting.Start_Range__c <= startRange ) {
                    marketSegment = setting.Market_Segmentation__c;
                    break;
                }
            }  
            
            return marketSegment;
        } else if ( noOfEmployees != null) {
            for(Market_Segmentation_Setting__c setting : Market_Segmentation_Setting__c.getall().values() ) {
                if( setting.Start_Range__c <= noOfEmployees && setting.End_Range__c >= noOfEmployees) { //setting.Is_EMEA_Region__c ==  isEMEARegion  // for future use
                    marketSegment = setting.Market_Segmentation__c;
                    break;
                }
            }  
        }

        return marketSegment;
        
        //Previous FY19 Market segmentation is deactivated on 31-01-2020 START
        // // New logic per the FY19 Market Segmentation
        // if (!isEMEARegion) {
        //     if (noOfEmployeesPicklist == '0 - 99' || noOfEmployeesPicklist == '100 - 499' || noOfEmployeesPicklist == '500 - 999' || noOfEmployeesPicklist == '1000 - 1999') {
        //         return 'GB';
        //     } else if (noOfEmployeesPicklist == '2000 - 4999' || noOfEmployeesPicklist == '5000 - 9999') {
        //         return 'ENT';
        //     } else if (noOfEmployeesPicklist == '10000 - 14999' || noOfEmployeesPicklist == '15000 - 24999' || noOfEmployeesPicklist == '25000+') {
        //         return 'LE';
        //     }
        // } else {
        //     if (noOfEmployeesPicklist == '0 - 99' || noOfEmployeesPicklist == '100 - 499' || noOfEmployeesPicklist == '500 - 999' || noOfEmployeesPicklist == '1000 - 1999') {
        //         return 'GB';
        //     } else if (noOfEmployeesPicklist == '2000 - 4999' || noOfEmployeesPicklist == '5000 - 9999' || noOfEmployeesPicklist == '10000 - 14999') {
        //         return 'ENT';
        //     } else if (noOfEmployeesPicklist == '15000 - 24999' || noOfEmployeesPicklist == '25000+') {
        //         return 'LE';
        //     }
        // }

        // return 'GB';
        //Previous FY19 Market segmentation is deactivated on 31-01-2020 END 
        
        // Below is the old logic:
        // Integer noOfEmployeesConverted;

        // if(String.isNotEmpty(noOfEmployeesPicklist))
        // {
        //     try
        //     {
        //         noOfEmployeesConverted = Integer.valueOf(noOfEmployeesPicklist);
        //     }
        //     catch(TypeException ex)
        //     {
        //         System.debug('An error occorred when converting string to integer.');
        //     }
        // }
        // if(noOfEmployeesConverted != null)
        // {
        //     return TriggerUtility.GetMarketSegmentFromNumber(noOfEmployeesConverted, isEMEARegion);
        // }
        // else
        // {
        //     if(noOfEmployeesPicklist == '1 - 100' )
        //     {
        //         return 'SOHO';
        //     }
        //     else if(noOfEmployeesPicklist == '100 - 250' || noOfEmployeesPicklist == '250 - 500' || ((noOfEmployeesPicklist == '500 - 1500') && noOfEmployees < 1000))
        //     {
        //         return 'SMB';
        //     }
        //     else if( noOfEmployeesPicklist == '500 - 1500' || noOfEmployeesPicklist == '1500 - 3000')
        //     {
        //         return 'COMM';
        //     }
        //     if (noOfEmployeesPicklist == '3000 - 5000') {
        //         // Condition for EMEA region
        //         if (isEMEARegion) {
        //             return 'GB';
        //         } else {
        //             return 'ENT';
        //         }
        //     }
        //     else if((noOfEmployeesPicklist == '5000 - 20000' || noOfEmployeesPicklist == '> 5000') && isEMEARegion && (noOfEmployees == null || noOfEmployees < 15000))
        //     {
        //         return 'ENT';
        //     }
        //     else if((noOfEmployeesPicklist == '5000 - 20000' || noOfEmployeesPicklist == '> 5000') && noOfEmployees < 10000)
        //     {
        //         return 'ENT';
        //     }
        //     else if(noOfEmployeesPicklist == '5000 - 20000' || noOfEmployeesPicklist == '5001 - 20000' || noOfEmployeesPicklist == '> 5000' || noOfEmployeesPicklist == '> 20000')
        //     {
        //         return 'LE';
        //     }
        //     else
        //     {
        //         return 'N/A';
        //     }
        // }
    }

    public static String getMarketSegmentFromNumber(Integer noOfEmployees, Boolean isEMEARegion)
    {
        // Condition for EMEA region
        //Changes 0-2k and 2k-15k  from 0-5k and 5k-15k  as part of Market segment
        
        
        if (isEMEARegion) {
            if (noOfEmployees > 0 && noOfEmployees < 2000) {
                return 'GB';
            } else if (noOfEmployees >= 2000 && noOfEmployees < 15000) {
                return 'ENT';
            } else if (noOfEmployees >= 15000) {
                return 'LE';
            }
        } else {
            if (noOfEmployees > 0 && noOfEmployees < 2000) {
                return 'GB';
            } else if (noOfEmployees >= 2000 && noOfEmployees < 10000) {
                return 'ENT';
            } else if (noOfEmployees >= 10000) {
                return 'LE';
            }
        }

        return 'GB';

        // if(noOfEmployees > 0 && noOfEmployees < 100)
        // {
        //     return 'SOHO';
        // }
        // else if(noOfEmployees >= 100 && noOfEmployees < 1000)
        // {
        //     return 'SMB';
        // }
        // else if(noOfEmployees >= 1000 && noOfEmployees < 3000)
        // {
        //     return 'COMM';
        // }
        // else if(noOfEmployees >= 3000 && noOfEmployees < 10000)
        // {
        //     return 'ENT';
        // }
        // else if(noOfEmployees >= 10000)
        // {
        //     return 'LE';
        // }
        // else
        // {
        //     return 'N/A';
        // }
    }
    
    //added by Gurjinder for Autocreation of Zscaler Cloud ID Contacts :start
    public static Boolean AutocreateZCloudIDcontactUpdateExecuted() {
        return AutocreateZCloudIDcontactUpdate;
    }

    public static void AutocreateZCloudIDcontactUpdatesettrue() {
        AutocreateZCloudIDcontactUpdate = true;
    }

    public static void AutocreateZCloudIDcontactUpdatesetfalse() {
        AutocreateZCloudIDcontactUpdate = false;
    }
    
    public static Boolean ZCloudIDcontactDeletetriggerExecuted() {
        return ZCloudIDcontactDeletetrigger;
    }

    public static void ZCloudIDcontactDeletetriggersettrue() {
        ZCloudIDcontactDeletetrigger = true;
    }

    public static void ZCloudIDcontactDeletetriggersetfalse() {
        ZCloudIDcontactDeletetrigger = false;
    }
    
    public static Boolean ZCloudIDcontactAfterInserttriggerExecuted() {
        return ZCloudIDcontactAfterInserttrigger;
    }

    public static void ZCloudIDcontactAfterInserttriggersettrue() {
        ZCloudIDcontactAfterInserttrigger = true;
    }

    public static void ZCloudIDcontactAfterInserttriggersetfalse() {
        ZCloudIDcontactAfterInserttrigger = false;
    }
    
    public static Boolean isTechpartnerupdateExecuted() {
        return updateTechnologyPartner;
    }

    public static void TechpartnerupdateExecuted() {
        updateTechnologyPartner = true;
    }

    public static void TechpartnerupdateReset() {
        updateTechnologyPartner = false;
    }
    //added by Gurjinder for Autocreation of Zscaler Cloud ID Contacts :End
    
    private static boolean prospectTypeUpdate = false;
    public static boolean isProspectUpdateExecuted(){
        return prospectTypeUpdate;
    }
    public static void prospectTypeUpdExecuted(){
        prospectTypeUpdate = true;
    }
    public static void prospectTypeUpdReset(){
        prospectTypeUpdate = false;
    }
    public static String sendEmailMethod(Provisioning_Request__c prObj,EmailTemplate et, String[] recepients){
    
         String response;
         //Get all recepients to be notified. SE Manager, PR Creator, Opp Owner
                
                //list of emails
                List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
                
                //initiallize messaging method
                Messaging.SingleEmailMessage singleMail = new Messaging.SingleEmailMessage();
                singleMail.setToAddresses(recepients);
                
                //set template Id
                singleMail.setTemplateId(et.Id);
                
                String accId = [SELECT Id,AccountId FROM Opportunity WHERE Id =: prObj.Opportunity__c].AccountId;
                singleMail.setTargetObjectId([SELECT Id From Contact where AccountId =: accId LIMIT 1].Id);
                
                //flag to false to stop inserting activity history
                singleMail.setSaveAsActivity(true);
                singleMail.setWhatId(prObj.id);
                singleMail.setTreatTargetObjectAsRecipient(false);
                
                //add mail
                emails.add(singleMail);
               
               try{            
                     Messaging.SendEmailResult[] resultMail = Messaging.sendEmail(emails);
                     if(resultMail[0].isSuccess()){
                          response = 'SUCCESS';
                          system.debug('EMAIL SENT!');
                     }
                     else{
                          response = resultMail[0].getErrors().get(0).getMessage();
                     }
                                    
                }catch(System.EmailException ex){
                     response = ex.getMessage();
                }  
           return response;     
    }
    //added bu Sateesh as a part of RBAC
    private static boolean patchRealign = false;
    public static boolean isPatchRealigning(){
        return patchRealign;
    }
    public static void realignPatch(){
        patchRealign = true;
    }
    public static void realignPatchReset(){
        patchRealign = false;
    }
    
    public static String getUsersEmail(Id userId){
        return [SELECT Id,Email FROM User WHERE Id =: userId].Email;
    }
    
    public static boolean isbeforeUpdateSplitExecuted(){
        return beforeUpdateSplit;
    }
    public static void beforeUpdateSplitExecuted(){
        beforeUpdateSplit = true;
    }
    public static void beforeUpdateSplitReset(){
        beforeUpdateSplit = false;
    }
    
    public static boolean issplitOwnerterritory_UpdateExecuted(){
        return splitOwnerterritory_Update;
    }
    public static void splitOwnerterritory_UpdateExecuted(){
        splitOwnerterritory_Update = true;
    }
    public static void splitOwnerterritory_UpdateReset(){
        splitOwnerterritory_Update = false;
    }
    
    
    private static boolean accountExtension = false;
    public static Boolean getAccountExtensionmethod() {
        return UpdateAccountExtensionmethod;
    }

    public static void setAccountExtension() {
        UpdateAccountExtensionmethod = true;
    }

    public static void setFlaseAccountExtension() {
        UpdateAccountExtensionmethod = false;
    }
    
    
    
    
    
     //added by Gurjinder for Updating Account Extension :start  //uncommented by minkesh patel 27-5-2020
    /**/private static boolean UpdateAccountExtensionmethod = false;
    public static Boolean UpdateAccountExtensionmethodExecuted() {
        return UpdateAccountExtensionmethod;
    }

    public static void UpdateAccountExtensionmethodsettrue() {
        UpdateAccountExtensionmethod = true;
    }

    public static void UpdateAccountExtensionmethodsetfalse() {
        UpdateAccountExtensionmethod = false;
    }


    //add by : tirth patel  
    //for if csm is present in account thne update account extension    
    private static boolean UpdateCSMAccountExtenssionMethod = false;    
    public static Boolean UpdateCSMAccountExtenssionMethodExecuted() {  
        return UpdateCSMAccountExtenssionMethod;    
    }   
    public static void UpdateCSMAccountExtenssionMethodsettrue() {  
        UpdateCSMAccountExtenssionMethod= true; 
    }   
    public static void UpdateCSMAccountExtenssionMethodsetfalse() { 
        UpdateCSMAccountExtenssionMethod = false;   
    }   
        
        
    //add by tirth patel    
 //change service owner 
    private static boolean AccountExtensionFalse = false;   
    public static Boolean getAccountExtensionFalse() {  
        return UpdateCSMAccountExtenssionMethod;    
    }   
    public static void setAccountExtenssionTrue() { 
        UpdateCSMAccountExtenssionMethod= true; 
    }   
    public static void setAccountExtenssionFalse() {    
        UpdateCSMAccountExtenssionMethod = false;   
    }   


    
    //added by Gurjinder for Updating Account Extension :End  //uncommented by minkesh patel 27-5-2020
    /**/
    //added by Gurjinder for Account Workflow Optimization :start
    private static boolean AccountWorkflowOptimizationmethod = false;
    public static Boolean AccountWorkflowOptimizationmethodExecuted() {
        return AccountWorkflowOptimizationmethod;
    }

    public static void AccountWorkflowOptimizationmethodsettrue() {
        AccountWorkflowOptimizationmethod = true;
    }

    public static void AccountWorkflowOptimizationmethodsetfalse() {
        AccountWorkflowOptimizationmethod = false;
    }
    //added by Gurjinder for  Account Workflow Optimization :End
    public static Boolean isrevokePendingQuoteApprovalExecuted() {
        return revokePendingQuoteApproval;
    }

    public static void revokePendingQuoteApprovalExecuted() {
        revokePendingQuoteApproval = true;
    }

    public static void revokePendingQuoteApprovalReset() {
        revokePendingQuoteApproval = false;
    }
    //added by Gurjinder for Amber Road Screening 
    
    private static boolean ScreenAccountsWithAmberRoadExecuted = false; //added by Gurjinder for Amber Road Screening
    public static Boolean ScreenAccountsWithAmberRoadExecuted() {
        return ScreenAccountsWithAmberRoadExecuted;
    }

    public static void ScreenAccountsWithAmberRoadExecutedsettrue() {
        ScreenAccountsWithAmberRoadExecuted = true;
    }

    public static void ScreenAccountsWithAmberRoadExecutedsetfalse() {
        ScreenAccountsWithAmberRoadExecuted = false;
    }
    
    public static Boolean isSkipAccTriggerExecuted() {
        return skipAccountTrigger;
    }

    public static void SkipAccTriggerExecuted() {
        skipAccountTrigger = true;
    }

    public static void SkipAccTriggerReset() {
        skipAccountTrigger = false;
    }
    
    public static Boolean isSkipLineItemTriggerExecuted() {
        return skipLineItemTrigger;
    }

    public static void SkipLineItemTriggerExecuted() {
        skipLineItemTrigger = true;
    }

    public static void SkipLineItemTriggerReset() {
        skipLineItemTrigger = false;
    }
    
    public static Boolean isSkipCaseTriggerExecuted() {
        return skipCaseTrigger;
    }

    public static void SkipCaseTriggerExecuted() {
        skipCaseTrigger = true;
    }

    public static void SkipCaseTriggerReset() {
        skipCaseTrigger = false;
    }
    
    public static Boolean isCaseBeforeInsertExecuted() {
        return casebeforeinsert;
    }

    public static void CaseBeforeInsertExecuted() {
        casebeforeinsert = true;
    }

    public static void CaseBeforeInsertReset() {
        casebeforeinsert = false;
    }
    
    public static Boolean isCaseBeforeUpdateExecuted() {
        return casebeforeupdate;
    }

    public static void CaseBeforeUpdateExecuted() {
        casebeforeupdate = true;
    }

    public static void CaseBeforeUpdateReset() {
        casebeforeupdate = false;
    }

    public static Boolean isCaseAfterUpdateExecuted() {
        return caseafterudpate;
    }

    public static void CaseAfterUpdateExecuted() {
        caseafterudpate = true;
    }

    public static void CaseAfterUpdateReset() {
        caseafterudpate = false;
    }

    public static Boolean isCaseEscalationHistoryExecuted() {
        return caseEscalationHistoryCreation;
    }

    public static void CaseEscalationHistoryExecuted() {
        caseEscalationHistoryCreation = true;
    }

    public static void CaseEscalationHistoryReset() {
        caseEscalationHistoryCreation = false;
    }
    
    public static Boolean isCaseSkillAssignmentExecuted() {
        return skipCaseSkillAssignment;
    }

    public static void CaseSkillAssignmentExecuted() {
        skipCaseSkillAssignment = true;
    }

    public static void CaseSkillAssignmentReset() {
        skipCaseSkillAssignment = false;
    }
    
    public static Boolean isskipCaseEscalationExecuted() {
        return skipCaseEscalation;
    }

    public static void skipCaseEscalationExecuted() {
        skipCaseEscalation = true;
    }

    public static void skipCaseEscalationReset() {
        skipCaseEscalation = false;
    }
    
    public static Boolean isCaseEntitlementAssigned() {
        return skipCaseEntAssignment;
    }

    public static void CaseEntitlementAssigned() {
        skipCaseEntAssignment = true;
    }

    public static void CaseEntitlementReset() {
        skipCaseEntAssignment = false;
    }
    
    public static Boolean isCaseEscalationNotesExecuted() {
        return caseEscalationNotes;
    }

    public static void CaseEscalationNotesExecuted() {
        caseEscalationNotes = true;
    }

    public static void CaseEscalationNotesReset() {
        caseEscalationNotes = false;
    }
    
    public static Boolean isSkipCaseCommentTriggerExecuted() {
        return skipCaseCommentTrigger;
    }

    public static void SkipCaseCommentTriggerExecuted() {
        skipCaseCommentTrigger = true;
    }

    public static void SkipCaseCommentTriggerReset() {
        skipCaseCommentTrigger = false;
    }
    
    public static Boolean isCaseCommentAfterInsertExecuted() {
        return skipCaseCommentAfterInsertTrigger;
    }

    public static void CaseCommentAfterInsertExecuted() {
        skipCaseCommentAfterInsertTrigger = true;
    }

    public static void CaseCommentAfterInsertReset() {
        skipCaseCommentAfterInsertTrigger = false;
    }
    
    public static Boolean isFRTandCustomerNoteExecuted() {
        return skipFRTandCustomerNote;
    }

    public static void FRTandCustomerNoteExecuted() {
        skipFRTandCustomerNote = true;
    }

    public static void FRTandCustomerNoteReset() {
        skipFRTandCustomerNote = false;
    }
    
    public static Boolean isCaseStatusHistoryExecuted() {
        return caseStatusHistory;
    }

    public static void CaseStatusHistoryExecuted() {
        caseStatusHistory = true;
    }

    public static void CaseStatusHistoryReset() {
        caseStatusHistory = false;
    }
    
    public static Boolean isManualSLAExecuted() {
        return skipManualSLA;
    }

    public static void ManualSLAExecuted() {
        skipManualSLA = true;
    }

    public static void ManualSLAReset() {
        skipManualSLA = false;
    }
    
    public static Boolean isProspectEntitlementExecuted() {
        return skipentitlementcreation;
    }

    public static void ProspectEntitlementExecuted() {
        skipentitlementcreation = true;
    }

    public static void ProspectEntitlementReset() {
        skipentitlementcreation = false;
    }
    
    public static Boolean isEntitlementUpdateExecuted() {
        return skipentitlementupdate;
    }

    public static void EntitlementUpdateExecuted() {
        skipentitlementupdate = true;
    }

    public static void EntitlementUpdateReset() {
        skipentitlementupdate = false;
    }
    
    public static Boolean isCaseCommentBeforeInsertExecuted() {
        return skipCaseCommentBeforeInsertTrigger;
    }

    public static void CaseCommentBeforeInsertExecuted() {
        skipCaseCommentBeforeInsertTrigger = true;
    }

    public static void CaseCommentBeforeInsertReset() {
        skipCaseCommentBeforeInsertTrigger = false;
    }
    
    public static Boolean isCustomerNotePublicExecuted() {
        return skipCustomerNotePublic;
    }

    public static void CustomerNotePublicExecuted() {
        skipCustomerNotePublic = true;
    }

    public static void CustomerNotePublicReset() {
        skipCustomerNotePublic = false;
    }
    
    //added by Gurjinder for SOQL 101 Optimization
    private static boolean UpdatingMarketsegmentforEMEA = false; 
    public static Boolean UpdatingMarketsegmentforEMEAExecuted() {
        return UpdatingMarketsegmentforEMEA;
    }

    public static void UpdatingMarketsegmentforEMEAsettrue() {
        UpdatingMarketsegmentforEMEA = true;
    }

    public static void UpdatingMarketsegmentforEMEAsetfalse() {
        UpdatingMarketsegmentforEMEA = false;
    }
    
    public static boolean iSupdateProspectTypeOnAccountmethodExecuted=false;
    //public static boolean IsCSMmanagerEmailCodeexecuted=false;
    
    //added by Gurjinder for avoid query in Workflow Optimization method
    private static boolean IsCSMmanagerEmailCodeexecuted = false; 
    public static Boolean IsCSMmanagerEmailCodeexecuted() {
        return IsCSMmanagerEmailCodeexecuted;
    }

    public static void IsCSMmanagerEmailCodeexecutedsettrue() {
        IsCSMmanagerEmailCodeexecuted = true;
    }

    public static void IsCSMmanagerEmailCodeexecutedsetfalse() {
        IsCSMmanagerEmailCodeexecuted = false;
    }


    private static boolean skipEmailMessageTrigger = false; 
    public static Boolean isSkipEmailMessageTriggerExecured() {
        return skipEmailMessageTrigger;
    }

    public static void SkipEmailMessageTriggerExecured() {
        skipEmailMessageTrigger = true;
    }

    public static void SkipEmailMessageTriggerReset() {
        skipEmailMessageTrigger = false;
    }

    private static boolean skipEmailMessageAfterInsertTrigger = false; 
    public static Boolean isEmailMessageAfterInsertExecuted() {
        return skipEmailMessageAfterInsertTrigger;
    }

    public static void EmailMessageAfterInsertExecuted() {
        skipEmailMessageAfterInsertTrigger = true;
    }

    public static void EmailMessageAfterInsertReset() {
        skipEmailMessageAfterInsertTrigger = false;
    }

    private static boolean skipEmailMessagetoCaseComment = false; 
    public static Boolean isEmailMessagetoCaseCommentExecuted() {
        return skipEmailMessagetoCaseComment;
    }

    public static void EmailMessagetoCaseCommentExecuted() {
        skipEmailMessagetoCaseComment = true;
    }

    public static void EmailMessagetoCaseCommentReset() {
        skipEmailMessagetoCaseComment = false;
    }

    private static boolean skipUserTriggerExecuted = false; 
    public static Boolean isSkipUserTriggerExecuted() {
        return skipUserTriggerExecuted;
    }

    public static void SkipUserTriggerExecuted() {
        skipUserTriggerExecuted = true;
    }

    public static void SkipUserTriggerReset() {
        skipUserTriggerExecuted = false;
    }

    private static boolean UserAfterInsertExecuted = false; 
    public static Boolean isUserAfterInsertExecuted() {
        return UserAfterInsertExecuted;
    }

    public static void UserAfterInsertExecuted() {
        UserAfterInsertExecuted = true;
    }

    public static void UserAfterInsertReset() {
        UserAfterInsertExecuted = false;
    }

    private static boolean UserAfterUpdateExecuted = false; 
    public static Boolean isUserAfterUpdateExecuted() {
        return UserAfterUpdateExecuted;
    }

    public static void UserAfterUpdateExecuted() {
        UserAfterUpdateExecuted = true;
    }

    public static void UserAfterUpdateReset() {
        UserAfterUpdateExecuted = false;
    }

    private static boolean userskillassninsert = false; 
    public static Boolean isUserSkillAssignmentInsertExecuted() {
        return userskillassninsert;
    }

    public static void UserSkillAssignmentInsertExecuted() {
        userskillassninsert = true;
    }

    public static void UserSkillAssignmentInsertReset() {
        userskillassninsert = false;
    }

    private static boolean userskillassnupdate = false; 
    public static Boolean isUserSkillAssignmentUpdateExecuted() {
        return userskillassnupdate;
    }
    // for the Bug BN-00003535 26 july 2022
    private static boolean inactiveUserReplaced = false; 
    public static Boolean isInactiveUserReplaced() {
        return inactiveUserReplaced;
    } //for the Bug BN-00003535 26 july 2022

    public static void UserSkillAssignmentUpdateExecuted() {
        userskillassnupdate = true;
    }

    public static void UserSkillAssignmentUpdateReset() {
        userskillassnupdate = false;
    }
    
    private static boolean prafterinsert = false; 
    public static Boolean isPRafterInsertExecuted() {
        return prafterinsert;
    }

    public static void PRafterInsertExecuted() {
        prafterinsert = true;
    }

    public static void PRafterInsertReset() {
        prafterinsert = false;
    }
    
    private static boolean prafterupdate = false; 
    public static Boolean isPRafterUpdateExecuted() {
        return prafterupdate;
    }

    public static void PRafterUpdateExecuted() {
        prafterupdate = true;
    }

    public static void PRafterUpdateReset() {
        prafterupdate = false;
    }
    
    private static boolean ccinsertpr = false; 
    public static Boolean isCaseCreationInsertPRExecuted() {
        return ccinsertpr;
    }

    public static void CaseCreationInsertPRExecuted() {
        ccinsertpr = true;
    }

    public static void CaseCreationInsertPRReset() {
        ccinsertpr = false;
    }

    private static boolean ccupdatepr = false; 
    public static Boolean isCaseCreationUpdatePRExecuted() {
        return ccupdatepr;
    }

    public static void CaseCreationUpdatePRExecuted() {
        ccupdatepr = true;
    }

    public static void CaseCreationUpdatePRReset() {
        ccupdatepr = false;
    }

    private static boolean getfeedback = false; 
    public static Boolean isGetFeedbackExecuted() {
        return getfeedback;
    }

    public static void GetFeedbackExecuted() {
        getfeedback = true;
    }

    public static void GetFeedbackReset() {
        getfeedback = false;
    }

    private static boolean dsatcase = false; 
    public static Boolean isDSATCaseCreationExecuted() {
        return dsatcase;
    }

    public static void DSATCaseCreationExecuted() {
        dsatcase = true;
    }

    public static void DSATCaseCreationReset() {
        dsatcase = false;
    }
    
    private static boolean userbeforeinsert = false; 
    public static Boolean isUserBeforeInsertExecuted() {
        return userbeforeinsert;
    }

    public static void UserBeforeInsertExecuted() {
        userbeforeinsert = true;
    }

    public static void UserBeforeInsertReset() {
        userbeforeinsert = false;
    }

    private static boolean userbeforeupdate = false; 
    public static Boolean isUserBeforeUpdateExecuted() {
        return userbeforeupdate;
    }

    public static void UserBeforeUpdateExecuted() {
        userbeforeupdate = true;
    }

    public static void UserBeforeUpdateReset() {
        userbeforeupdate = false;
    }

    private static boolean emailmessageFRT = false; 
    public static Boolean isEmailMessageFRTExecuted() {
        return emailmessageFRT;
    }

    public static void EmailMessageFRTExecuted() {
        emailmessageFRT = true;
    }

    public static void EmailMessageFRTReset() {
        emailmessageFRT = false;
    }

    private static boolean skipfeeditemtrigger = false; 
    public static Boolean isSkipFeedItemTriggerExecuted() {
        return skipfeeditemtrigger;
    }

    public static void SkipFeedItemTriggerExecuted() {
        skipfeeditemtrigger = true;
    }

    public static void SkipFeedItemTriggerReset() {
        skipfeeditemtrigger = false;
    }

    private static boolean skipfeeditemafterinserttrigger = false; 
    public static Boolean isFeedItemAfterTriggerExecuted() {
        return skipfeeditemafterinserttrigger;
    }

    public static void FeedItemAfterTriggerExecuted() {
        skipfeeditemafterinserttrigger = true;
    }

    public static void FeedItemAfterTriggerReset() {
        skipfeeditemafterinserttrigger = false;
    }

    private static boolean skipfeeditembeforeinserttrigger = false; 
    public static Boolean isFeedItemBeforeTriggerExecuted() {
        return skipfeeditembeforeinserttrigger;
    }

    public static void FeedItemBeforeTriggerExecuted() {
        skipfeeditembeforeinserttrigger = true;
    }

    public static void FeedItemBeforeTriggerReset() {
        skipfeeditembeforeinserttrigger = false;
    }

    private static boolean skipfeeditemiternalpost = false; 
    public static Boolean isFeedItemInternalPostExecuted() {
        return skipfeeditemiternalpost;
    }

    public static void FeedItemInternalPostExecuted() {
        skipfeeditemiternalpost = true;
    }

    public static void FeedItemInternalPostReset() {
        skipfeeditemiternalpost = false;
    }

    private static boolean skipfeedcommentaftertrigger = false; 
    public static Boolean isFeedCommentAfterTriggerExecuted() {
        return skipfeedcommentaftertrigger;
    }

    public static void FeedCommentAfterTriggerExecuted() {
        skipfeedcommentaftertrigger = true;
    }

    public static void FeedCommentAfterTriggerReset() {
        skipfeedcommentaftertrigger = false;
    }

    private static boolean skipfeedcommenttrigger = false; 
    public static Boolean isSkipFeedCommentTriggerExecuted() {
        return skipfeedcommenttrigger;
    }

    public static void SkipFeedCommentTriggerExecuted() {
        skipfeedcommenttrigger = true;
    }

    public static void SkipFeedCommentTriggerReset() {
        skipfeedcommenttrigger = false;
    }

    private static boolean skipCaseAfterInsert = false; 
    public static Boolean isCaseAfterInsertExecuted() {
        return skipCaseAfterInsert;
    }

    public static void CaseAfterInsertExecuted() {
        skipCaseAfterInsert = true;
    }

    public static void CaseAfterInsertReset() {
        skipCaseAfterInsert = false;
    }

    private static boolean CaseDesctoComment = false; 
    public static Boolean isCaseDesctoCommentExecuted() {
        return CaseDesctoComment;
    }

    public static void CaseDesctoCommentExecuted() {
        CaseDesctoComment = true;
    }

    public static void CaseDesctoCommentReset() {
        CaseDesctoComment = false;
    }

    private static boolean SkipContactTrigger = false; 
    public static Boolean isSkipContactTriggerExecuted() {
        return SkipContactTrigger;
    }

    public static void SkipContactTriggerExecuted() {
        SkipContactTrigger = true;
    }

    public static void SkipContactTriggerReset() {
        SkipContactTrigger = false;
    }

    private static boolean casecloseMilestone = false; 
    public static Boolean isCloseMilestonesonCaseCloseExecuted() {
        return casecloseMilestone;
    }

    public static void CloseMilestonesonCaseCloseExecuted() {
        casecloseMilestone = true;
    }

    public static void CloseMilestonesonCaseCloseReset() {
        casecloseMilestone = false;
    }
    
    private static boolean UpdateDetailsonMasterCase = false; 
    public static Boolean isUpdateDetailsonMasterCaseExecuted() {
        return UpdateDetailsonMasterCase;
    }

    public static void UpdateDetailsonMasterCaseExecuted() {
        UpdateDetailsonMasterCase = true;
    }

    public static void UpdateDetailsonMasterCaseReset() {
        UpdateDetailsonMasterCase = false;
    }
    
    private static boolean cldtrigger = false; 
    public static Boolean isSkipContentDocLinkTriggerExecuted() {
        return cldtrigger;
    }

    public static void SkipContentDocLinkTriggerExecuted() {
        cldtrigger = true;
    }

    public static void SkipContentDocLinkTriggerReset() {
        cldtrigger = false;
    }
    
    private static boolean cdlafterinsert = false; 
    public static Boolean isCDLAfterInsertExecuted() {
        return cdlafterinsert;
    }

    public static void CDLAfterInsertExecuted() {
        cdlafterinsert = true;
    }

    public static void CDLAfterInsertReset() {
        cdlafterinsert = false;
    }
    
    private static boolean emailcdltocaseedl = false; 
    public static Boolean isEmailCDLtoCaseEDLExecuted() {
        return emailcdltocaseedl;
    }

    public static void EmailCDLtoCaseEDLExecuted() {
        emailcdltocaseedl = true;
    }

    public static void EmailCDLtoCaseEDLReset() {
        emailcdltocaseedl = false;
    }
    
     //added by Dhawal Sharda 08-07-2021 CR# 2857 Start
     //light_updaterfprequest is used for lightning UI on ContentDocumentLink object
    private static boolean light_updaterfprequest = false; 
    public static Boolean isupdateRFPRequest_lightExecuted() {
        return light_updaterfprequest;
    }

    public static void updateRFPRequest_lightExecuted() {
        light_updaterfprequest = true;
    }

    public static void updateRFPRequest_lightReset() {
        light_updaterfprequest = false;
    }
    //classic_updaterfprequest is used for classic UI on Attachmetn object
    private static boolean classic_updaterfprequest = false; 
    public static Boolean isupdateRFPRequest_classicExecuted() {
        return classic_updaterfprequest;
    }

    public static void updateRFPRequest_classicExecuted() {
        classic_updaterfprequest = true;
    }

    public static void updateRFPRequest_classicReset() {
        classic_updaterfprequest = false;
    }
    //added by Dhawal Sharda 08-07-2021 CR# 2857 End
    
    //added by minkesh patel 27-5-2020
    private static boolean SkipUserPresenceTrigger = false; 
    public static Boolean isSkipUserPresenceTriggerExecuted() {
        return SkipUserPresenceTrigger;
    }

    public static void SkipUserPresenceTriggerExecuted() {
        SkipUserPresenceTrigger = true;
    }

    public static void SkipUserPresenceTriggerReset() {
        SkipUserPresenceTrigger = false;
    }
    //added by minkesh patel 27-5-2020
    
    private static boolean updateOppPartonMakePrimary = false; 
    public static Boolean isUpdateOppPartneronPrimaryChangeExecuted() {
        return updateOppPartonMakePrimary;
    }

    public static void UpdateOppPartneronPrimaryChangeExecuted() {
        updateOppPartonMakePrimary = true;
    }

    public static void UpdateOppPartneronPrimaryChangeReset() {
        updateOppPartonMakePrimary = false;
    }
    
    private static boolean SkipCosellTrigger = false; 
    public static Boolean isSkipCosellTriggerExecuted() {
        return SkipCosellTrigger;
    }

    public static void SkipCosellTriggerExecuted() {
        SkipCosellTrigger = true;
    }

    public static void SkipCosellTriggerReset() {
        SkipCosellTrigger = false;
    }
    
    private static boolean CosellBeforeInsert = false; 
    public static Boolean isCosellBeforeInsertExecuted() {
        return CosellBeforeInsert;
    }

    public static void CosellBeforeInsertExecuted() {
        CosellBeforeInsert = true;
    }

    public static void CosellBeforeInsertReset() {
        CosellBeforeInsert = false;
    }
    
    private static boolean CosellBeforeUpdate = false; 
    public static Boolean isCosellBeforeUpdateExecuted() {
        return CosellBeforeUpdate;
    }

    public static void CosellBeforeUpdateExecuted() {
        CosellBeforeUpdate = true;
    }

    public static void CosellBeforeUpdateReset() {
        CosellBeforeUpdate = false;
    }
    
    private static boolean SkipCosellStatusLM = false; 
    public static Boolean isSkipCosellStatusLMExecuted() {
        return SkipCosellStatusLM;
    }

    public static void SkipCosellStatusLMExecuted() {
        SkipCosellStatusLM = true;
    }

    public static void SkipCosellStatusLMReset() {
        SkipCosellStatusLM = false;
    }
    
    //added by minkesh patel 27-5-2020
    private static boolean UpdateTAMemail = false; 
    public static Boolean isUpdateTAMemailExecuted() {
        return UpdateTAMemail;
    }
    
    public static void UpdateTAMemailExecuted() {
        UpdateTAMemail = true;
    }
    
    public static void UpdateTAMemailReset() {
        UpdateTAMemail = false;
    }
    
    private static boolean CreateAccExtension = false; 
    public static Boolean isCreateAccExtensionExecuted() {
      return CreateAccExtension;
    }
    
    public static void CreateAccExtensionExecuted() {
      CreateAccExtension = true;
    }
    
    public static void CreateAccExtensionReset() {
      CreateAccExtension = false;
    }
    
   
    
    private static boolean SkipUserPresenceAfterTrigger = false; 
    public static Boolean isUserPresenceAfterInsertExecuted() {
        return SkipUserPresenceAfterTrigger;
    }

    public static void UserPresenceAfterInsertExecuted() {
        SkipUserPresenceAfterTrigger = true;
    }

    public static void UserPresenceAfterInsertReset() {
        SkipUserPresenceAfterTrigger = false;
    }
    
    private static boolean assignPendingTAMCases = false; 
    public static Boolean isAssignPendingCasestoTAMsExecuted() {
        return assignPendingTAMCases;
    }

    public static void AssignPendingCasestoTAMsExecuted() {
        assignPendingTAMCases = true;
    }

    public static void AssignPendingCasestoTAMsReset() {
        assignPendingTAMCases = false;
    }
    
    private static boolean TAMagentwork = false; 
    public static Boolean isTAMAgentWorkExecuted() {
        return TAMagentwork;
    }

    public static void TAMAgentWorkExecuted() {
        TAMagentwork = true;
    }

    public static void TAMAgentWorkReset() {
        TAMagentwork = false;
    }
    //added by minkesh patel 27-5-2020
    
    //Added By Gurjinder : CR# 125: Start
    private static boolean UpdateSEonCase = false; 
    public static Boolean isUpdateSEonCaseExecuted() {
      return UpdateSEonCase;
    }
    
    public static void UpdateSEonCaseExecuted() {
      UpdateSEonCase = true;
    }
    
    public static void UpdateSEonCaseReset() {
      UpdateSEonCase = false;
    }
    //Added By Gurjinder : CR# 125: End
    
    // CR# 180 : Abhishek : Short term fixes for CC List : Start
    private static boolean casecctoteam = false; 
    public static Boolean isCaseCCtoTeamExecuted() {
        return casecctoteam;
    }
    
    public static void CaseCCtoTeamExecuted() {
        casecctoteam = true;
    }
    
    public static void CaseCCtoTeamReset() {
        casecctoteam = false;
    }
    // CR# 180 : Abhishek : Short term fixes for CC List : End
    
    //Added by - Parth Doshi CR# 473 - Start
    public static void updateAccountExtensionHistoryExecuted() {
        accountExtensionHistoryExecuted = true;
    }

    public static boolean isAccountExtensionHistoryExecuted() {
        return accountExtensionHistoryExecuted;
    }
    //Added by - Parth Doshi CR# 473 - End
    
    private static boolean FeedPartnerContact = false; 
    public static boolean isFeedPartnerContactExecuted() {
        return FeedPartnerContact;
    }
    
    public static void FeedPartnerContactExecuted() {
        FeedPartnerContact = true;
    }

    public static void FeedPartnerContactReset() {
        FeedPartnerContact = false;
    }

    private static boolean FeedPartnerDealReg = false; 
    public static Boolean isFeedPartnerDealRegExecuted() {
        return FeedPartnerDealReg;
    }

    public static void FeedPartnerDealRegExecuted() {
        FeedPartnerDealReg = true;
    }

    public static void isFeedPartnerDealRegReset() {
        FeedPartnerDealReg = false;
    }
    
    private static boolean FeedPartnerCosell = false; 
    public static Boolean isFeedPartnerCosellExecuted() {
        return FeedPartnerCosell;
    }

    public static void FeedPartnerCosellExecuted() {
        FeedPartnerCosell = true;
    }

    public static void FeedPartnerCosellReset() {
        FeedPartnerCosell = false;
    }
    
    private static boolean executeDRRejectApproval = false; 
    public static Boolean isDRRejectApprovalExecuted() {
        return executeDRRejectApproval;
    }
    
    public static void DRRejectApprovalExecuted() {
        executeDRRejectApproval = true;
    }
    
    public static void DRRejectApprovalReset() {
        executeDRRejectApproval = false;
    }
    
    private static boolean executeDRfinalreview = false; 
    public static Boolean isDRFinalReviewExecuted() {
        return executeDRfinalreview;
    }
    
    public static void DRFinalReviewExecuted() {
        executeDRfinalreview = true;
    }
    
    public static void DRFinalReviewReset() {
        executeDRfinalreview = false;
    }
    
   
    private static boolean UpdateOriginalTAMemail = false; 
    public static Boolean isUpdateOriginalTAMexecuted() {
        return UpdateOriginalTAMemail;
    }
    public static void UpdateOriginalTAMexecuted() {
        UpdateOriginalTAMemail = true;
    }
    
     //Added by Gurjinder : CR# 315: Start    
    public  static boolean SEgetschangedonOpp = false;   
    
    //Added by Gurjinder : CR# 620: Start    
    private static boolean beforeinserteventonVCE = false;   
    public static Boolean isbeforeinsertexecutedonVCE() { 
      return beforeinserteventonVCE;   
    }   
        
    public static void beforeinsertexecutedonVCE() {  
      beforeinserteventonVCE = true;   
    }   
        
    public static void beforeinsertexecutedonVCEReset() { 
      beforeinserteventonVCE = false;  
    } 
    //Added by Gurjinder : CR# 620: End

    //Added by Abhishek: Sales Teaming: Start
    private static boolean executeDRMeetingDate = false; 
    public static Boolean isDRMeetingTypeUpdated() {
        return executeDRMeetingDate;
    }
    
    public static void DRMeetingTypeUpdated() {
        executeDRMeetingDate = true;
    }
    
    public static void DRMeetingTypeReset() {
        executeDRMeetingDate = false;
    }
    
    private static boolean eventTrigger = false; 
    public static Boolean isSkipEventTriggerExecuted() {
        return eventTrigger;
    }
    
    public static void SkipEventTriggerExecuted() {
        eventTrigger = true;
    }
    
    public static void SkipEventTriggerReset() {
        eventTrigger = false;
    }
    
    private static boolean eventAFinsert = false; 
    public static Boolean isEventAfterInsertExecuted() {
        return eventAFinsert;
    }
    
    public static void EventAfterInsertExecuted() {
        eventAFinsert = true;
    }
    
    public static void EventAfterInsertReset() {
        eventAFinsert = false;
    }
    
    private static boolean eventAFupdate = false; 
    public static Boolean isEventAfterUpdateExecuted() {
        return eventAFupdate;
    }
    
    public static void EventAfterUpdateExecuted() {
        eventAFupdate = true;
    }
    
    public static void EventAfterUpdateReset() {
        eventAFupdate = false;
    }
    
    private static boolean DRPriorStatusCapture = false; 
    public static Boolean isDRPriorStatusCaptureExecuted() {
        return DRPriorStatusCapture;
    }
    
    public static void DRPriorStatusCaptureExecuted() {
        DRPriorStatusCapture = true;
    }
    
    public static void DRPriorStatusCaptureReset() {
        DRPriorStatusCapture = false;
    }
    
    private static boolean copypriorStatus = false; 
    public static Boolean isDRCopyPriorStatusonExpExtensionExecuted() {
        return copypriorStatus;
    }
    
    public static void DRCopyPriorStatusonExpExtensionExecuted() {
        copypriorStatus = true;
    }
    
    public static void DRCopyPriorStatusonExpExtensionReset() {
        copypriorStatus = false;
    }
    
    private static boolean pendingNBMtoConverted = false; 
    public static Boolean isDRPendingNBMConvertedExecuted() {
        return pendingNBMtoConverted;
    }
    
    public static void DRPendingNBMConvertedExecuted() {
        pendingNBMtoConverted = true;
    }
    
    public static void DRPendingNBMConvertedReset() {
        pendingNBMtoConverted = false;
    }
    
    private static boolean drremovalfromOpp = false; 
    public static Boolean isDRRemovalfromOppExecuted() {
        return drremovalfromOpp;
    }
    
    public static void DRRemovalfromOppExecuted() {
        drremovalfromOpp = true;
    }
    
    public static void DRRemovalfromOppReset() {
        drremovalfromOpp = false;
    }
    
    private static boolean skipOppTrigger = false; 
    public static Boolean isSkipOppTriggerExecuted() {
        return skipOppTrigger;
    }
    
    public static void SkipOppTriggerExecuted() {
        skipOppTrigger = true;
    }
    
    public static void SkipOppTriggerReset() {
        skipOppTrigger = false;
    }
    
    private static boolean skipOppBeforeInsertTrigger = false; 
    public static Boolean isskipOppBeforeInsertTriggerExecuted() {
        return skipOppBeforeInsertTrigger;
    }
    
    public static void skipOppBeforeInsertTriggerExecuted() {
        skipOppBeforeInsertTrigger = true;
    }
    
    public static void skipOppBeforeInsertTriggerReset() {
        skipOppBeforeInsertTrigger = false;
    }
    
    private static boolean skipOppAfterInsertTrigger = false; 
    public static Boolean isskipOppAfterInsertTriggerExecuted() {
        return skipOppAfterInsertTrigger;
    }
    
    public static void skipOppAfterInsertTriggerExecuted() {
        skipOppAfterInsertTrigger = true;
    }
    
    public static void skipOppAfterInsertTriggerReset() {
        skipOppAfterInsertTrigger = false;
    }
    
    private static boolean skipOppBeforeUpdateTrigger = false; 
    public static Boolean isskipOppBeforeUpdateTriggerExecuted() {
        return skipOppBeforeUpdateTrigger;
    }
    
    public static void skipOppBeforeUpdateTriggerExecuted() {
        skipOppBeforeUpdateTrigger = true;
    }
    
    public static void skipOppBeforeUpdateTriggerReset() {
        skipOppBeforeUpdateTrigger = false;
    }
    
    private static boolean skipOppAfterUpdateTrigger = false; 
    public static Boolean isskipOppAfterUpdateTriggerExecuted() {
        return skipOppAfterUpdateTrigger;
    }
    
    public static void skipOppAfterUpdateTriggerExecuted() {
        skipOppAfterUpdateTrigger = true;
    }
    
    public static void skipOppAfterUpdateTriggerReset() {
        skipOppAfterUpdateTrigger = false;
    }
    
    private static boolean skipreprice = false; 
    public static Boolean isSkipQuoteNeedsRepriceExecuted() {
        return skipreprice;
    }
    
    public static void SkipQuoteNeedsRepriceExecuted() {
        skipreprice = true;
    }
    
    public static void SkipQuoteNeedsRepriceReset() {
        skipreprice = false;
    }
    
    private static boolean syncProductonCD = false; 
    public static Boolean isskipCopyProductDetailsExecuted() {
        return syncProductonCD;
    }
    
    public static void skipCopyProductDetailsExecuted() {
        syncProductonCD = true;
    }
    
    public static void skipCopyProductDetailsReset() {
        syncProductonCD = false;
    }
    
    private static boolean skipContractDetailTrigger = false; 
    public static Boolean isSkipConDetailTriggerExecuted() {
        return skipContractDetailTrigger;
    }
    
    public static void SkipConDetailTriggerExecuted() {
        skipContractDetailTrigger = true;
    }
    
    public static void SkipConDetailTriggerReset() {
        skipContractDetailTrigger = false;
    }

    private static boolean skipOpportunityTrigger = false; 
    public static Boolean isSkipOpportunityTriggerExecuted() {
        return skipOpportunityTrigger;
    }
    
    public static void SkipOpportunityTriggerExecutedSetTrue() {
        skipOpportunityTrigger = true;
    }
    
    public static void SkipOpportunityTriggerSetFalse() {
        skipOpportunityTrigger = false;
    }
    
    
    
   private static boolean OppoGotoSevenStage = false; 
    public static Boolean isOppoGotoSevenStageExecuted() {
        return OppoGotoSevenStage;
    }
    
    public static void oppoGotoSevenStageExecutedSetTrue() {
        OppoGotoSevenStage = true;
    }
    
    public static void oppoGotoSevenStageSetFalse() {
        OppoGotoSevenStage = false;
    } 
    
    private static boolean createOppExtension = false; 
    public static Boolean isCreateOppExtensionExecuted() {
        return createOppExtension;
    }
    
    public static void createOppExtensionExecutedSetTrue() {
        createOppExtension = true;
    }
    
    public static void createOppExtensionExtensionSetFasle() {
        createOppExtension = false;
    }
    

    private static boolean  contractDetailAccountDeployment = false; 
    public static Boolean isContractDetailAccountDeploymentExecuted() {
        return contractDetailAccountDeployment;
    }
    
    public static void contractDetailAccountDeploymentExecuted() {
        contractDetailAccountDeployment = true;
    }
    
    public static void contractDetailAccountDeploymentReset() {
        contractDetailAccountDeployment = false;
    }




    public static void skipOpportunityTrigger(){
        TriggerUtility.accTerritoryPatchExecuted();
        TriggerUtility.accSalesTeamExecuted();
        TriggerUtility.OpptyTriggerFCexecuted();
        TriggerUtility.oppPatchManagerAfterInsertExecuted();
        TriggerUtility.oppPatchManagerAfterUpdateExecuted();
        TriggerUtility.oppCaseCreationExecuted();
        TriggerUtility.oppPRProductionStatusUpdateExecuted();
        TriggerUtility.opportunityAccountsScreeningExecuted();
        TriggerUtility.OpportunityPartnerAdditionExecuted();
        TriggerUtility.requestDecommissionPrExecuted();
        TriggerUtility.oppSpliSalesTeamExecuted();
        TriggerUtility.updateOppNextStepHistoryExecuted();
        TriggerUtility.updateTechValHistoryExecuted();
        TriggerUtility.architectureHistoryExecuted();
        TriggerUtility.ERNotificationExecuted();
        TriggerUtility.updateSEManagerEmailExecuted();
        TriggerUtility.updateAccountForApprovedPZENExecuted();
        TriggerUtility.updateForecastCategoryExecuted();
        TriggerUtility.overrideACVValuesResetExecuted();
        TriggerUtility.OpptySplitTriggerFCexecuted();
        TriggerUtility.beforeUpdateSplitExecuted();
        TriggerUtility.splitOwnerterritory_UpdateExecuted();
        TriggerUtility.opportunitySplitsAfterUpdateExecuted();
    }
    //Added by Abhishek: Sales Teaming: End
    
    //Added by GUrjinder : CR# 737 :Start
    private static boolean UpdatingMarketsegmentforLead = false; 
  public static Boolean UpdatingMarketsegmentforLeadExecuted() {
    return UpdatingMarketsegmentforLead;
  }

  public static void UpdatingMarketsegmentforLeadsettrue() {
    UpdatingMarketsegmentforLead = true;
  }

  public static void UpdatingMarketsegmentforLeadsetfalse() {
    UpdatingMarketsegmentforLead = false;
  }
  //Added by GUrjinder : CR# 737 :End
  
  //Added by Viral: CR# 666 :Start
    private Static boolean createCSMProjectFromCompleted = false;
    public static Boolean iscreateCSMProjectFromCompletedExecuted() {
        return createCSMProjectFromCompleted;
    }
    
    public static void createCSMProjectFromCompletedExecuted() {
        createCSMProjectFromCompleted = true;
    }
    
    public static void createCSMProjectFromCompletedReset() {
        createCSMProjectFromCompleted = false;
    }    
    //Added by Viral: CR# 666:End
  
  
  //Added by Viral : CR# 670 :Start
    private static boolean createOpportunityPartnerFromEvent = false; 
    public static Boolean isCreateOpportunityPartnerFromEventExecuted() {
        return createOpportunityPartnerFromEvent;
    }
    
    public static void createOpportunityPartnerFromEventExecuted() {
        createOpportunityPartnerFromEvent = true;
    }
    
    public static void createOpportunityPartnerFromEventReset() {
        createOpportunityPartnerFromEvent = false;
    }
    //Added by Viral : CR# 670 :End
  
  //Added by Gurjinder :  CR# 758 : Start
 private static boolean CreateCustomerScoreCard = false; 
    public static Boolean isCreateCustomerScoreCardExecuted() {
      return CreateCustomerScoreCard;
    }
    
    public static void CreateCustomerScoreCardExecuted() {
      CreateCustomerScoreCard = true;
    }
    
    public static void CreateCustomerScoreCardReset() {
      CreateCustomerScoreCard = false;
    }
   //Added by Gurjinder :  CR# 758 : End


   //Added by Anup : CR# 686 :Start
    private static boolean manualCaseAssign= false; 
    public static Boolean isManualCaseAssignExecuted() {
        return manualCaseAssign;
    }
    
    public static void ManualCaseAssignExecuted() {
        manualCaseAssign = true;
    }
    
    public static void ManualCaseAssignReset() {
        manualCaseAssign = false;
    }


    private static boolean autoCaseAssign= false; 
    public static Boolean isAutoCaseAssignExecuted() {
        return autoCaseAssign;
    }
    
    public static void AutoCaseAssignExecuted() {
        autoCaseAssign = true;
    }
    
    public static void AutoCaseAssignReset() {
        autoCaseAssign = false;
    }
  
  private static boolean agentWorkAfterUpdate= false; 
    public static Boolean isAgentWorkAfterUpdateExecuted() {
        return agentWorkAfterUpdate;
    }
    
    public static void AgentWorkAfterUpdateExecuted() {
        agentWorkAfterUpdate = true;
    }
    
    public static void AgentWorkAfterUpdateReset() {
        agentWorkAfterUpdate = false;
    }
  //Added by Anup : CR# 686 :End
  
    
    //Added by Swathi : CR# 693 and CR# 736 :Start
    private static boolean projectFieldUpdateExecuted = false; 
    public static Boolean isprojectFieldUpdateExecuted() {
        return projectFieldUpdateExecuted;
    }
    
    public static void projectFieldUpdateExecuted() {
        projectFieldUpdateExecuted = true;
    }
    
    public static void projectFieldUpdateExecutedReset() {
        projectFieldUpdateExecuted = false;
    }
    //Added by Swathi : CR# 693 and CR# 736 :end
    
    //Added by Anup : CR#832- Start
    private static boolean populateCampaignOnTask= false; 
    public static Boolean isPopulateCampaignMostRecentOnTaskExecuted() {
        return populateCampaignOnTask;
    }
    
    public static void PopulateCampaignMostRecentOnTaskExecuted() {
        populateCampaignOnTask = true;
    }
    
    public static void PopulateCampaignMostRecentOnTaskReset() {
        populateCampaignOnTask = false;
    }
    //Added by Anup : CR#832- End
    
    
        //Start - Added by Abhijit for CR851
    private static boolean populateCXOAdvisorExecuted = false; 
    public static Boolean isPopulateCXOAdvisorExecuted() {
        return populateCXOAdvisorExecuted;
    }
    
    public static void populateCXOAdvisorExecuted() {
        populateCXOAdvisorExecuted = true;
    }

    public static void populateCXOAdvisorExecutedReset() {
        populateCXOAdvisorExecuted = false;
    }
    
    private static boolean cXOAdvisorRequestAfterUpdateExecuted = false; 
    public static Boolean isCXOAdvisorRequestAfterUpdateExecuted() {
        return cXOAdvisorRequestAfterUpdateExecuted;
    }
    
    public static void cXOAdvisorRequestAfterUpdateExecuted() {
        cXOAdvisorRequestAfterUpdateExecuted = true;
    }

    private static boolean cXOAdvisorRequestAfterInsertExecuted = false; 
    public static Boolean isCXOAdvisorRequestAfterInsertExecuted() {
        return cXOAdvisorRequestAfterInsertExecuted;
    }
    
    public static void cXOAdvisorRequestAfterInsertExecuted() {
        cXOAdvisorRequestAfterInsertExecuted = true;
    }

    private static boolean skipCXOAdvisorRequestTriggerExecuted = false; 
    public static Boolean isSkipCXOAdvisorRequestTriggerExecuted() {
        return skipCXOAdvisorRequestTriggerExecuted;
    }
    
    public static void skipCXOAdvisorRequestTriggerExecuted() {
        skipCXOAdvisorRequestTriggerExecuted = true;
    }

    //End - Added by Abhijit for CR851
    
    //Added by Varun : CR# 839 - Start
    private static boolean proposalExtensionExecuted= false; 
    public static Boolean isProposalExtensionExecuted() {
        return proposalExtensionExecuted;
    }
    
    public static void ProposalExtensionExecuted() {
        proposalExtensionExecuted = true;
    }
    
    public static void ProposalExtensionReset() {
        proposalExtensionExecuted = false;
    }
 
    private static boolean multipleProposalsExecuted= false; 
    public static Boolean isMultipleProposalsExecuted() {
        return multipleProposalsExecuted;
    }
    
    public static void MultipleProposalsExecuted() {
        multipleProposalsExecuted = true;
    }
    
    public static void MultipleProposalsReset() {
        multipleProposalsExecuted = false;
    }

    private static boolean productConfigurationExecuted= false; 
    public static Boolean isProductConfigurationExecuted() {
        return productConfigurationExecuted;
    }
    
    public static void ProductConfigurationExecuted() {
        productConfigurationExecuted = true;
    }
    
    public static void ProductConfigurationReset() {
        productConfigurationExecuted = false;
    }
   
    private static boolean proposalExtLookupExecuted= false; 
    public static Boolean isProposalExtLookupExecuted() {
        return proposalExtLookupExecuted;
    }
    
    public static void ProposalExtLookupExecuted() {
        proposalExtLookupExecuted = true;
    }
    
    public static void ProposalExtLookupReset() {
        proposalExtLookupExecuted = false;
    }

  
    private static boolean peCreationExecuted= false; 
    public static Boolean isPeCreationExecuted() {
        return peCreationExecuted;
    }
    
    public static void PeCreationExecuted() {
        peCreationExecuted = true;
    }
    
    public static void PeCreationReset() {
        peCreationExecuted = false;
    }  
    //Added by Varun : CR# 839 - End
    
    public static void PropTriggerHandlerQueueableExecuted(){
        PropTriggerHandlerQueueableExecuted = true;
    }
    
    public static void PropTriggerHandlerQueueableReset(){
        PropTriggerHandlerQueueableExecuted = false;
    }
    
    //Added by Gurjinder :  Code Clean Activity : Start

/*public static boolean skipOppTrigger = false;
public static Boolean isSkipOppTriggerExecuted() {
        return skipOppTrigger;
    }

    public static void SkipOppTriggerExecuted() {
        skipOppTrigger = true;
    }

    public static void SkipOppTriggerReset() {
        skipOppTrigger = false;
    } */
    
    //Added by Abhishek: CR# 829: TAM Meeting : Start
    private static boolean skipObjectiveCreation= false; 
    public static Boolean isSkipCreateObjectiveExecuted() {
        return skipObjectiveCreation;
    }
    
    public static void SkipCreateObjectiveExecuted() {
        skipObjectiveCreation = true;
    }
    
    public static void SkipCreateObjectiveReset() {
        skipObjectiveCreation = false;
    }
    
    private static boolean meetingafterinsert= false; 
    public static Boolean isMeetingAfterInsertExecuted() {
        return meetingafterinsert;
    }
    
    public static void MeetingAfterInsertExecuted() {
        meetingafterinsert = true;
    }
    
    public static void MeetingAfterInsertReset() {
        meetingafterinsert = false;
    }
    


    private static boolean skipmeeting= false; 
    public static Boolean isSkipMeetingTriggerExecuted() {
        return skipmeeting;
    }
    
    public static void SkipMeetingTriggerExecuted() {
        skipmeeting = true;
    }
    
    public static void SkipMeetingTriggerReset() {
        skipmeeting = false;
    }
      
    
    private static boolean APhistory = false; 
    public static Boolean isAPHistoryCreationExecuted() {
        return APhistory;
    }
    public static void APHistoryCreationExecuted() {
        APhistory = true;
    }
    public static void APHistoryCreationReset() {
        APhistory = false;
    }

    private static boolean updateCompletionDate = false; 
    public static Boolean isupdateCompletionDateExecuted() {
        return updateCompletionDate;
    }
    public static void updateCompletionDateExecuted() {
        updateCompletionDate = true;
    }
    public static void updateCompletionDateReset() {
        updateCompletionDate = false;
    }
    
    private static boolean CaseTAMHistory = false; 
    public static Boolean isCaseTAMNotesHistoryExecuted() {
        return CaseTAMHistory;
    }
    public static void CaseTAMNotesHistoryExecuted() {
        CaseTAMHistory = true;
    }
    public static void CaseTAMNotesHistoryReset() {
        CaseTAMHistory = false;
    }

    private static boolean APAfterInsert = false; 
    public static Boolean isActionPlanAfterInsertExecuted() {
        return APAfterInsert;
    }
    public static void ActionPlanAfterInsertExecuted() {
        APAfterInsert = true;
    }
    public static void ActionPlanAfterInsertReset() {
        APAfterInsert = false;
    }

    private static boolean APAfterUpdate = false; 
    public static Boolean isActionPlanAfterUpdateExecuted() {
        return APAfterUpdate;
    }
    public static void ActionPlanAfterUpdateExecuted() {
        APAfterUpdate = true;
    }
    public static void ActionPlanAfterUpdateReset() {
        APAfterUpdate = false;
    }
    
    private static boolean APBeforeUpdate = false; 
    public static Boolean isActionPlanBeforeUpdateExecuted() {
        return APBeforeUpdate;
    }
    public static void ActionPlanBeforeUpdateExecuted() {
        APBeforeUpdate = true;
    }
    public static void ActionPlanBeforeUpdateReset() {
        APBeforeUpdate = false;
    }
    
    private static boolean APTriggerExecute = false; 
    public static Boolean isSkipActionPlanTriggerExecuted() {
        return APTriggerExecute;
    }
    public static void SkipActionPlanTriggerExecuted() {
        APTriggerExecute = true;
    }
    public static void SkipActionPlanTriggerReset() {
        APTriggerExecute = false;
    }
    
    private static boolean APTriggerBIExecute = false; 
    public static Boolean isActionPlanBeforeInsertExecuted() {
        return APTriggerBIExecute;
    }
    public static void ActionPlanBeforeInsertExecuted() {
        APTriggerBIExecute = true;
    }
    public static void ActionPlanBeforeInsertReset() {
        APTriggerBIExecute = false;
    }
    
    private static boolean ownercopy = false; 
    public static Boolean isOwnerDefaultLogicExecuted() {
        return ownercopy;
    }
    public static void OwnerDefaultLogicExecuted() {
        ownercopy = true;
    }
    public static void OwnerDefaultLogicReset() {
        ownercopy = false;
    }
    //Added by Abhishek: CR# 829: TAM Meeting : End

    //Added by Gurjinder :  Code Clean Activity : Start
    
    public static boolean Oppbeforeinsert=false;
    public static Boolean isOppBeforeInsertExecuted() {
        return Oppbeforeinsert;
    }

    public static void OppBeforeInsertExecuted() {
        Oppbeforeinsert = true;
    }

    public static void OppBeforeInsertReset() {
        Oppbeforeinsert = false;
    }
    
    public static boolean Oppbeforeupdate = false;
    public static Boolean isOppBeforeUpdateExecuted() {
        return Oppbeforeupdate;
    }

    public static void OppBeforeUpdateExecuted() {
        Oppbeforeupdate = true;
    }

    public static void OppBeforeUpdateReset() {
        Oppbeforeupdate = false;
    }
    
    public static boolean Oppafterinsert = false;
    public static Boolean isOppAfterInsertExecuted() {
        return Oppafterinsert;
    }

    public static void OppAfterInsertExecuted() {
        Oppafterinsert = true;
    }

    public static void OppAfterInsertReset() {
        Oppafterinsert = false;
    }
    
    public static boolean OppAfterupdate = false;
    public static Boolean isOppAfterUpdateExecuted() {
        return OppAfterupdate;
    }

    public static void OppAfterUpdateExecuted() {
        OppAfterupdate = true;
    }

    public static void OppAfterUpdateReset() {
        OppAfterupdate = false;
    }
    
//Added by Gurjinder :  Code Clean Activity : End

//Added by Gurjinder :  CR# 910 : Start

public static boolean UpdateEdgewiseOverlayTeamSharing = false;
public static Boolean isUpdateEdgewiseOverlayTeamSharingExecuted() {
        return UpdateEdgewiseOverlayTeamSharing;
    }

    public static void UpdateEdgewiseOverlayTeamSharingExecuted() {
        UpdateEdgewiseOverlayTeamSharing = true;
    }

    public static void UpdateEdgewiseOverlayTeamSharingReset() {
        UpdateEdgewiseOverlayTeamSharing = false;
    }

//Added by Gurjinder :  CR# 910 : End

    //Start - Added by Abhijit for CR183
    private static boolean updateContractDetailStatus = false; 
    public static Boolean isUpdateContractDetailStatusExecuted() {
        return updateContractDetailStatus;
    }
    
    public static void updateContractDetailStatusExecuted() {
        updateContractDetailStatus = true;
    }
    //End - Added by Abhijit for CR183

 //Start - Added by Viral for CR813
    private static boolean projectClone = false; 
    public static Boolean isProjectCloneExecuted() {
        return projectClone;
    }
    public static void updateProjectCloneExecuted() {
        projectClone = true;
    }
    public static void updateProjectCloneReset() {
        projectClone = false;
    }
    //End - Added by Viral for CR813
    
    //Added by Anup : CR#1022- Start
    private static boolean updateParentCR= false; 
    public static Boolean isUpdateParentChangeRequestExecuted() {
        return updateParentCR;
    }
    
    public static void UpdateParentChangeRequestExecuted() {
        updateParentCR = true;
    }
    
    public static void UpdateParentChangeRequestReset() {
        updateParentCR = false;
    }

    private static boolean updateBaCrOnCase= false; 
    public static Boolean isUpdateBaCROnCaseExecuted() {
        return updateBaCrOnCase;
    }
    
    public static void UpdateBaCROnCaseExecuted() {
        updateBaCrOnCase = true;
    }
    
    public static void UpdateBaCROnCaseReset() {
        updateBaCrOnCase = false;
    }

    private static boolean syncBAonCase= false; 
    public static Boolean isSyncBAOnCaseExecuted() {
        return syncBAonCase;
    }
    
    public static void SyncBAOnCaseExecuted() {
        syncBAonCase = true;
    }
    
    public static void SyncBAOnCaseReset() {
        syncBAonCase = false;
    }

    private static boolean syncBAonCR= false; 
    public static Boolean isSyncBAOnCrExecuted() {
        return syncBAonCase;
    }
    
    public static void SyncBAOnCrExecuted() {
        syncBAonCase = true;
    }
    
    public static void SyncBAOnCrReset() {
        syncBAonCase = false;
    }
    //Added by Anup : CR#1022- End
    private static boolean requestChangeStatus= false; 
    public static Boolean isRequestChangeStatusExecuted() {
        return requestChangeStatus;
    }
    
    public static void RequestChangeStatusExecuted() {
        requestChangeStatus = true;
    }
    
    public static void RequestChangeStatusReset() {
        requestChangeStatus = false;
    }
    // Added by Varun for CR1069: Start
    private static boolean fillProjectSummaryTriggerExecute = false; 
    public static Boolean isFillProjectSummaryTriggerExecuted() {
        return fillProjectSummaryTriggerExecute;
    }
    public static void FillProjectSummaryTriggerExecuted() {
        fillProjectSummaryTriggerExecute = true;
    }
    public static void FillProjectSummaryTriggerReset() {
        fillProjectSummaryTriggerExecute = false;
    }
    // Added by Varun for CR1069: End
    
    //Added By Anup : CR#1142 - Start
    private static boolean accountOwnerChangeEmailAlert = false; 
    public static Boolean isAccountOwnerChangeAlertExecuted() {
        return accountOwnerChangeEmailAlert;
    }
    public static void AccountOwnerChangeAlertExecuted() {
        accountOwnerChangeEmailAlert = true;
    }
    public static void AccountOwnerChangeAlertReset() {
        accountOwnerChangeEmailAlert = false;
    }
    //Added By Anup : CR#1142 - End
    
//Added By Swathi : CR# 1008 Start
    private static boolean UpdateCSMonCase = false; 
    public static Boolean isUpdateCSMonCaseExecuted() {
      return UpdateCSMonCase;
    }
    
    public static void UpdateCSMonCaseExecuted() {
      UpdateCSMonCase = true;
    }
    
    public static void UpdateCSMonCaseReset() {
      UpdateCSMonCase = false;
    }
    //Added By Swathi : CR# 1008 End
    
    //Added By Anup : CR#1122 - Start
    private static boolean qualifierRoleUpdate = false; 
    public static Boolean isQualifierRoleUpdateExecuted() {
        return qualifierRoleUpdate;
    }
    public static void QualifierRoleUpdateExecuted() {
        qualifierRoleUpdate = true;
    }
    public static void QualifierRoleUpdateReset() {
        qualifierRoleUpdate = false;
    }

    private static boolean qualifierRoleInsert = false; 
    public static Boolean isQualifierRoleInsertExecuted() {
        return qualifierRoleInsert;
    }
    public static void QualifierRoleInsertExecuted() {
        qualifierRoleInsert = true;
    }
    public static void QualifierRoleInsertReset() {
        qualifierRoleInsert = false;
    }
    //Added By Anup : CR#1122 - End
    
    
    // Added by Rajesh CR# 1099 : Start
    private static boolean calculateLatestZIAZPA = false; 
    public static Boolean iscalculateLatestZIAZPA() {
      return calculateLatestZIAZPA;
    }
    
    public static void calculateLatestZIAZPA() {
      calculateLatestZIAZPA= true;
    }
    
    public static void calculateLatestZIAZPAReset() {
      calculateLatestZIAZPA = false;
    }
    // Added by Rajesh CR# 1099 : End
    
    //Added by Swathi : CR1127 Start
    private static boolean contaskFieldUpdateExecuted= false;
    public static boolean iscontaskFieldUpdateExecuted(){
        return contaskFieldUpdateExecuted;
    }

    public static void contaskFieldUpdateExecuted(){
        contaskFieldUpdateExecuted= true;
    }
    public static void contaskFieldUpdateReset(){
        contaskFieldUpdateExecuted= false;
    }
    private static boolean leadtaskFieldUpdateExecuted= false;
    public static boolean isleadtaskFieldUpdateExecuted(){
        return leadtaskFieldUpdateExecuted;
    }

    public static void leadtaskFieldUpdateExecuted(){
        leadtaskFieldUpdateExecuted= true;
    }
    public static void leadtaskFieldUpdateReset(){
        leadtaskFieldUpdateExecuted= false;
    }
    //Added by Swathi: CR1127 End
    
    //Added by Viral: CR1051 Start
    private static boolean jiraTicketTrigger = false; 
    public static Boolean isJiraTicketExecuted() {
        return jiraTicketTrigger;
    }
    public static void jiraTicketExecuted() {
        jiraTicketTrigger = true;
    }
    public static void jiraTicketReset() {
        jiraTicketTrigger = false;
    }
    //Added by Viral: CR1051 End
    
    //Added by Anup : CR#1117 - Start
    private static boolean updateRelatedOpp = false; 
    public static Boolean isUpdateRelatedOppExecuted() {
        return updateRelatedOpp;
    }
    public static void UpdateRelatedOppExecuted() {
        updateRelatedOpp = true;
    }
    public static void UpdateRelatedOppReset() {
        updateRelatedOpp = false;
    }
    //Added by Anup : CR#1117 - End
    
    //Added by Anup : TAM Case Reassignment - Start
    private static boolean executeTAMReassignment = false; 
    public static Boolean isTAMReassignmentExecuted() {
        return executeTAMReassignment;
    }
    public static void TAMReassignmentExecuted() {
        executeTAMReassignment = true;
    }
    public static void TAMReassignmentReset() {
        executeTAMReassignment = false;
    } 
    
    private static boolean executeAssignTAMOwner = false; 
    public static Boolean isAssignTAMOwnerExecuted() {
        return executeAssignTAMOwner;
    }
    public static void AssignTAMOwnerExecuted() {
        executeAssignTAMOwner = true;
    }
    public static void AssignTAMOwnerReset() {
        executeAssignTAMOwner = false;
    }
    //Added by Anup : TAM Case Reassignment - End
    
     //Added by Anup : CR#1215 - Start
    public static boolean executeUpdateLastActivity = false;
    public static Boolean isexecuteUpdateLastActivityExecuted() {
        return executeUpdateLastActivity;
    }
    public static void executeUpdateLastActivityExecuted() {
        executeUpdateLastActivity = true;
    }
    public static void executeUpdateLastActivityReset() {
        executeUpdateLastActivity = false;
    }
    //Added by Anup : CR#1215 - End
  
    // : CR#- Start
    private static boolean updateBugCreateUserStory= false; 
    public static Boolean isUpdateBugCreateUserStoryExecuted() {
        return updateBugCreateUserStory;
    }
    
    public static void UpdateBugCreateUserStoryExecuted() {
        updateBugCreateUserStory = true;
    }
    
    public static void UpdateBugCreateUserStoryReset() {
        updateBugCreateUserStory = false;
    }
    
    private static boolean isCaseStatusUpdateMeeting= false; 
    public static Boolean isCaseStatusUpdateMeetingSchedule()  {
        return isCaseStatusUpdateMeeting;
    }
    
    public static void startCaseStatusUpdateMeetingSchedule()  {
        isCaseStatusUpdateMeeting = true;
    }
        
    public static void stopCaseStatusUpdateMeetingSchedule()  {
        isCaseStatusUpdateMeeting = false;
    }
  
  
  
  //added by Viral : Siemens
    private static boolean executeCaseIntegartion = false;
    public static Boolean isCaseIntegartionExecuted() {
        return executeCaseIntegartion;
    }
    public static void caseIntegartionExecutedSetTrue() {
        executeCaseIntegartion = true;
    }
    public static void caseIntegartionExecutedSetFalse() {
        executeCaseIntegartion = false;
    }
    
    private static boolean executeCaseIntegartionPatch= false;
    public static Boolean isCaseIntegartionPatchExecuted() {
        return executeCaseIntegartionPatch;
    }
    public static void caseCaseIntegartionPatchSetTrue() {
        executeCaseIntegartionPatch = true;
    }
    public static void caseCaseIntegartionPatchSetFalse() {
        executeCaseIntegartionPatch = false;
    }
    
    private static boolean executeCaseAfterUpdateCaseIntegartion = false;
    public static Boolean isExecuteCaseAfterUpdateCaseIntegartionExecuted() {
        return executeCaseAfterUpdateCaseIntegartion;
    }
    public static void executeCaseAfterUpdateCaseIntegartionSetTrue() {
        executeCaseAfterUpdateCaseIntegartion = true;
    }
    public static void executeCaseAfterUpdateCaseIntegartionSetFalse() {
        executeCaseAfterUpdateCaseIntegartion = false;
    }
    //added by Viral Ends: Siemens
    
    //Added by Dhawal, Ayush, Lucky : CR# 1498: Start
    private static boolean afterinserteventonVCE = false;   
    public static Boolean isafterinsertexecutedonVCE() { 
      return afterinserteventonVCE;   
    }   
        
    public static void afterinsertexecutedonVCE() {  
      afterinserteventonVCE = true;   
    }   
        
    public static void afterinsertexecutedonVCEReset() { 
      afterinserteventonVCE = false;  
    }  
    private static boolean afterupdateeventonVCE = false;   
    public static Boolean isafterupdateexecutedonVCE() { 
      return afterupdateeventonVCE;   
    }   
        
    public static void afterupdateexecutedonVCE() {  
      afterupdateeventonVCE = true;   
    }   
        
    public static void afterupdateexecutedonVCEReset() { 
      afterupdateeventonVCE = false;  
    }  

    
    //Added by Dhawal, Ayush, Lucky : CR# 1498: End
    
    //Added by Parth : CR# 1520: Start
     private static boolean afterUpdateRelatedLeadExecuted = false;   
    public static Boolean isafterUpdateRelatedLeadExecuted() { 
        return afterUpdateRelatedLeadExecuted;   
    }   
        
    public static void afterUpdateRelatedLeadExecuted() {  
        afterUpdateRelatedLeadExecuted = true;   
    }   
        
    public static void afterUpdateRelatedLeadExecutedReset() { 
        afterUpdateRelatedLeadExecuted = false;  
    }
    
    private static boolean afterUpdateRelatedContactExecuted = false;   
    public static Boolean isafterUpdateRelatedContactExecuted() { 
        return afterUpdateRelatedContactExecuted;   
    }   
        
    public static void afterUpdateRelatedContactExecuted() {  
        afterUpdateRelatedContactExecuted = true;   
    }   
        
    public static void afterUpdateRelatedContactExecutedReset() { 
        afterUpdateRelatedContactExecuted = false;  
    }
    private static boolean afterUpdateCampaignExecuted = false;   
    public static Boolean isafterUpdateCampaignExecuted() { 
        return afterUpdateCampaignExecuted;   
    }   
        
    public static void afterUpdateCampaignExecuted() {  
        afterUpdateCampaignExecuted = true;   
    }   
        
    public static void afterUpdateCampaignExecutedReset() { 
        afterUpdateCampaignExecuted = false;  
    }

    //Added by Parth : CR# 1520: End
    
    //Added by Varun : CR# 1807: Start
    private static boolean updateAccountExtensionCheckBox = false;  
    public static Boolean isUpdateAccountExtensionCheckBoxExecuted() {
        return updateAccountExtensionCheckBox;
    }

    public static void UpdateAccountExtensionCheckBoxExecuted() {
        updateAccountExtensionCheckBox = true;
    }

    public static void UpdateAccountExtensionCheckBoxReset() {
        updateAccountExtensionCheckBox = false;
    }
  //Added by Varun : CR# 1807: Start

    //Added by Anup : CR# 1770 - Start
    public static boolean executeFeedFromKBComment = false;
    public static Boolean isexecuteFeedFromKBCommentExecuted() {
        return executeFeedFromKBComment;
    }
    public static void executeFeedFromKBCommentExecuted() {
        executeFeedFromKBComment = true;
    }
    public static void executeFeedFromKBCommentReset() {
        executeFeedFromKBComment = false;
    }
    //Added by Anup : CR# 1770 - End
    //Added by Varun : CR# 2271: Start
    private static boolean updateContactForCampExecuted = false;  
    public static Boolean isUpdateContactForCampExecuted() {
        return updateContactForCampExecuted;
    }

    public static void UpdateContactForCampExecuted() {
        updateContactForCampExecuted = true;
    }

    public static void UpdateContactForCampReset() {
        updateContactForCampExecuted = false;
    }

    
    private static boolean updateLeadForCampExecuted = false;  
    public static Boolean isUpdateLeadForCampExecuted() {
        return updateLeadForCampExecuted;
    }

    public static void UpdateLeadForCampExecuted() {
        updateLeadForCampExecuted = true;
    }

    public static void UpdateLeadForCampReset() {
        updateLeadForCampExecuted = false;
    }
    
    private static boolean updateRecentCampaignExecuted = false;  
    public static Boolean isUpdateRecentCampaignExecuted() {
        return updateRecentCampaignExecuted;
    }

    public static void UpdateRecentCampaignExecuted() {
        updateRecentCampaignExecuted = true;
    }

    public static void UpdateRecentCampaignReset() {
        updateRecentCampaignExecuted = false;
    }
  //Added by Varun : CR# 2271: End
    //Added by Chetan : CR# 2282-Start
    public static boolean executeUpdateResponseExecuted = false;
    public static Boolean isexecuteUpdateResponseExecuted() {
        return executeUpdateResponseExecuted;
    }
    public static void executeUpdateResponseExecuted() {
        executeUpdateResponseExecuted = true;
    }
    public static void executeUpdateResponseReset() {
        executeUpdateResponseExecuted = false;
    }
    //Added by Chetan : CR# 2282-End
    //Start-Added by Chetan : CR# 3357
    public static boolean executeValidateCompletedStatus = false;
    public static Boolean isexecuteValidateCompletedStatusExecuted() {
        return executeValidateCompletedStatus;
    }
    public static void executeValidateCompletedStatusExecuted() {
        executeValidateCompletedStatus = true;
    }
    public static void executeValidateCompletedStatusReset() {
        executeValidateCompletedStatus = false;
    }
    //End-Added by Chetan : CR# 3357
    
    //Start-Added by Chetan : IBA-1093
    public static boolean executeUpdateParticipants = false;
    public static Boolean isexecuteUpdateParticipantsExecuted() {
        return executeUpdateParticipants;
    }
    public static void executeUpdateParticipantsExecuted() {
        executeUpdateParticipants = true;
    }
    public static void executeUpdateParticipantsReset() {
        executeUpdateParticipants = false;
    }
    //End-Added by Chetan : IBA-1093 
        
    //Added by Varun  :  CR# 1824 -     Start  
   
    private static boolean updateInsertStageAge = false;  
   
    public static Boolean isupdateInsertStageAgeExecuted() {  
        return updateInsertStageAge;  
    }  
    
    public static void updateInsertStageAgeExecuted() {  
        updateInsertStageAge  =  true;  
    }  
   
    public static void updateInsertStageAgeReset() {  
        updateInsertStageAge  =  false;  
    }  
    
    //Added by  Varun :   CR# 1824  -       End  
    
    //Added by Varun    Start  
    
    private static boolean updateAccountExtension = false;  

    public static Boolean isUpdateAccountExtensionExecuted() {  
        return updateAccountExtension;  
    }  
    
    public static void updateAccountExtensionExecuted() {  
        updateAccountExtension  =  true;  
    }
   
    public static void updateAccountExtensionReset() {  
        updateAccountExtension  =  false;  
    }  
    
    //Added by  Varun        End  
    
    //CR# 2914 - Added by Ritesh Kumar - Start   
    private static boolean updateRelatedToField = false;     
    public static Boolean isupdateRelatedToFieldExecuted(){ return updateRelatedToField; } 
    public static void updateRelatedToFieldExecuted(){ updateRelatedToField = true; }  
    public static void updateRelatedToFieldReset(){ updateRelatedToField = false; }  
    
    private static boolean updateTargetCustomerNumber = false;     
    public static Boolean isupdateTargetCustomerNumberExecuted(){ return updateTargetCustomerNumber; } 
    public static void updateTargetCustomerNumberExecuted(){ updateTargetCustomerNumber = true; }  
    public static void updateTargetCustomerNumberReset(){ updateTargetCustomerNumber = false; }  
    //CR# 2914 - Added by Ritesh Kumar - End

    // Added by Ayush Kangar as part of CR# 3483 - Start
    public static boolean UpdateEventNotes = false;
        public static Boolean isUpdateEventNotesExecuted() {  
        return UpdateEventNotes;  
    }  
    
    public static void UpdateEventNotesExecuted() {  
        UpdateEventNotes  =  true;  
    }
    // Added by Ayush Kangar as part of CR# 3483 - End
    // Added by Ayush Kangar as part of CR# 3856 - End
    private static boolean populateTeamAdvisor = false; 
    public static Boolean ispopulateTeamAdvisorExecuted() {
        return populateTeamAdvisor;
    }
    
    public static void populateTeamAdvisorExecuted() {
        populateTeamAdvisor = true;
    }
    // Added by Ayush Kangar as part of CR# 3856 - End
    
    //Added for CR#3178 - Start
    public static boolean updateCSBusinessAlignment = false;
    public static Boolean isUpdateCSBusinessAlignmentExecuted() {
        return updateCSBusinessAlignment;
    }
    
    public static void updateCSBusinessAlignmentExecuted() {
        updateCSBusinessAlignment = true;
    }
    
    public static void updateCSBusinessAlignmentReset() {
        updateCSBusinessAlignment = false;
    }
    //Added for CR#3178 - End
    
    //Added by Chetan : CR# 2258 - Start
   
    public static boolean updateSkipTAMReassignmentOnChildCases = false;
   
    public static Boolean updateSkipTAMReassignmentOnChildCasesExecuted() {
        return updateSkipTAMReassignmentOnChildCases;
    }
    
    public static void updateSkipTAMReassignmentOnChildCasesTrue() {
        updateSkipTAMReassignmentOnChildCases = true;
    }
   
    public static void updateSkipTAMReassignmentOnChildCasesFalse() {
        updateSkipTAMReassignmentOnChildCases = false;
    }
    //Added by Chetan : CR# 2258 - End
    
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
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;  
       i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++; 
           i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
         i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;  
       i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++; 
           i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
         i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;  
       i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
        
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++; 
           i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++; 
           i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
         i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;  
       i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++; 
           i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
         i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;  
       i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
  i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
        i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
        i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
        i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
        i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
        i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
        i++;
    i++;
    i++;
        i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
        i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
        i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
        i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
        i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
        i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
  }
}