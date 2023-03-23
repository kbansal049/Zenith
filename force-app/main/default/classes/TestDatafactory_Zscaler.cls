@isTest
public class TestDatafactory_Zscaler{
	static final String ClosedStage = 'Closed';
	static final String DASSKUCodes = 'Z-DAS-0;Z-DAS-1';
	static final String ZIABusBundle = 'ZIA-BUS-BUNDLE';
	static final String L2A = 'L2A';

    public static List<Triggers_Switch__c> gettriggerswitchrecords(Boolean execute){
        List<Triggers_Switch__c> trlst = new List<Triggers_Switch__c>();
        trlst.add(new Triggers_Switch__c(name = 'Execute_DR_Reject_Approval', Execute__c = execute));
        trlst.add(new Triggers_Switch__c(name = 'Execute_DR_Final_Review_Submission', Execute__c = execute));
        trlst.add(new Triggers_Switch__c(name = 'Execute_Cosell_Trigger', Execute__c = execute));
        trlst.add(new Triggers_Switch__c(name = 'Execute_Cosell_Status_LastModified', Execute__c = execute));
        trlst.add(new Triggers_Switch__c(name = 'CloseMilestonesonCaseClose', Execute__c = execute));
        trlst.add(new Triggers_Switch__c(name = 'Close_Case_FRT', Execute__c = execute));
        trlst.add(new Triggers_Switch__c(name = 'Execute_Account_Trigger', Execute__c = execute));
        trlst.add(new Triggers_Switch__c(name = 'Execute_CaseComment_Trigger', Execute__c = execute));
        trlst.add(new Triggers_Switch__c(name = 'Execute_Case_Description_to_Comment', Execute__c = execute));
        trlst.add(new Triggers_Switch__c(name = 'Execute_Case_Entitlement_Assignment', Execute__c = execute));
        trlst.add(new Triggers_Switch__c(name = 'Execute_Case_Escalation', Execute__c = execute));
        trlst.add(new Triggers_Switch__c(name = 'Execute_Case_SkillAssignment', Execute__c = execute));
        trlst.add(new Triggers_Switch__c(name = 'Execute_Case_Status_History', Execute__c = execute));
        trlst.add(new Triggers_Switch__c(name = 'Execute_Case_Trigger', Execute__c = execute));
        trlst.add(new Triggers_Switch__c(name = 'Execute_Contact_Trigger', Execute__c = execute));
        trlst.add(new Triggers_Switch__c(name = 'Execute_ContentDocumentLink_Trigger', Execute__c = execute));
        trlst.add(new Triggers_Switch__c(name = 'Execute_CustomerNoteAdded', Execute__c = execute));
        trlst.add(new Triggers_Switch__c(name = 'Execute_EmailMessageCDL_to_CaseCDL', Execute__c = execute));
        trlst.add(new Triggers_Switch__c(name = 'Execute_EmailMessage_CaseComment', Execute__c = execute));
        trlst.add(new Triggers_Switch__c(name = 'Execute_EmailMessage_Trigger', Execute__c = execute));
        trlst.add(new Triggers_Switch__c(name = 'Execute_Escalation_History_Creation', Execute__c = execute));
        trlst.add(new Triggers_Switch__c(name = 'Execute_Escalation_Notes_Creation', Execute__c = execute));
        trlst.add(new Triggers_Switch__c(name = 'Execute_FeedComment_Trigger', Execute__c = execute));
        trlst.add(new Triggers_Switch__c(name = 'Execute_FeedItem_Internal', Execute__c = execute));
        trlst.add(new Triggers_Switch__c(name = 'Execute_FeedItem_Trigger', Execute__c = execute));
        trlst.add(new Triggers_Switch__c(name = 'Execute_FRT_CustomerNoteAdded', Execute__c = execute));
        trlst.add(new Triggers_Switch__c(name = 'Execute_Get_Feedback', Execute__c = execute));
        trlst.add(new Triggers_Switch__c(name = 'Execute_Manual_SLA', Execute__c = execute));
        trlst.add(new Triggers_Switch__c(name = 'Execute_User_Skill_Assignment', Execute__c = execute));
        trlst.add(new Triggers_Switch__c(name = 'Execute_User_Trigger', Execute__c = execute));
        trlst.add(new Triggers_Switch__c(name = 'OpportunityForecastCategoryAutomation', Execute__c = execute));
        trlst.add(new Triggers_Switch__c(name = 'OppSplitForecastCategoryAutomation', Execute__c = execute));
        trlst.add(new Triggers_Switch__c(name = 'UpdateDetailsonMasterCase', Execute__c = execute));
        trlst.add(new Triggers_Switch__c(name = 'Update_GAM_NAM', Execute__c = execute));
        trlst.add(new Triggers_Switch__c(name = 'Execute_Event_Trigger', Execute__c = execute));
        trlst.add(new Triggers_Switch__c(name = 'updateAccountQBRDate', Execute__c = execute));
        trlst.add(new Triggers_Switch__c(name = 'updateCheckbox', Execute__c = execute));
        trlst.add(new Triggers_Switch__c(name = 'Execute_Attachment_Trigger', Execute__c = execute));
        trlst.add(new Triggers_Switch__c(name = 'Execute_Att_Opp_PO', Execute__c = execute));
        trlst.add(new Triggers_Switch__c(name = 'Execute_TAM_Assignment', Execute__c = execute));
        trlst.add(new Triggers_Switch__c(name = 'ExecuteUpdateTAMemail', Execute__c = execute));
        trlst.add(new Triggers_Switch__c(name = 'Execute_Send_Email_Closed_CommentAdded', Execute__c = execute));
        trlst.add(new Triggers_Switch__c(name = 'ExecuteUpdateSEonCase', Execute__c = execute));
        trlst.add(new Triggers_Switch__c(name = 'Execute_CC_toCaseTeam', Execute__c = execute));
        trlst.add(new Triggers_Switch__c(name = 'Execute_Sync_CaseBA_With_CR', Execute__c = execute));
        trlst.add(new Triggers_Switch__c(name = 'Execute_Case_TAM_Notes_History', Execute__c = execute));
        trlst.add(new Triggers_Switch__c(name = 'ExecuteUpdateOriginalTAMdetails', Execute__c = execute));
        trlst.add(new Triggers_Switch__c(name = 'UpdateAccountDataTime', Execute__c = execute));
        trlst.add(new Triggers_Switch__c(name = 'updateExtentison', Execute__c = execute));
        trlst.add(new Triggers_Switch__c(name = 'Executed_CustomerScroceCard', Execute__c = execute));
        trlst.add(new Triggers_Switch__c(name = 'Execute_TAM_Owner_OOO_Mail', Execute__c = execute));
        trlst.add(new Triggers_Switch__c(name = 'Execute_CollaboratorEmailList', Execute__c = execute));
        trlst.add(new Triggers_Switch__c(name = 'Execute_Partner_Support_Validation', Execute__c = execute));
        trlst.add(new Triggers_Switch__c(name = 'Execute_CreateContactUnderAccount', Execute__c = execute));
        trlst.add(new Triggers_Switch__c(name = 'Execute_setRequestType', Execute__c = execute));
        trlst.add(new Triggers_Switch__c(name = 'ExecuteUpdateCSMonCase', Execute__c = execute));
        trlst.add(new Triggers_Switch__c(name = 'Execute_Case_Close_with_Action_Plan', Execute__c = execute));
        trlst.add(new Triggers_Switch__c(name = 'Execute_Case_Integration_Updation', Execute__c = execute));
        trlst.add(new Triggers_Switch__c(name = 'Execute_TAM_Reassignment', Execute__c = execute));
        trlst.add(new Triggers_Switch__c(name = 'Execute_Assign_TAM_As_Owner', Execute__c = execute));
        trlst.add(new Triggers_Switch__c(name = 'Execute_UpdateResolutionState', Execute__c = execute));
        trlst.add(new Triggers_Switch__c(name = 'Execute_UpdateCustomerSupportAlias', Execute__c = execute));
        trlst.add(new Triggers_Switch__c(name = 'Execute_UpdatePendingCustomerTimestamp', Execute__c = execute));
        trlst.add(new Triggers_Switch__c(name = 'Execute_addDefaultProdOnSFDCCases', Execute__c = execute));
        trlst.add(new Triggers_Switch__c(name = 'Execute_AgentWork_Trigger', Execute__c = execute));
        //trlst.add(new Triggers_Switch__c(name = 'Execute_UpdateNOCSubject', Execute__c = execute));
        trlst.add(new Triggers_Switch__c(name = 'Execute_CaseRecordHistoryTracking', Execute__c = true));

        return trlst;
    }
    public static List<Stage_ForecastCategory_Mapping__c> getstageforecastcategorymap(){
        List<Stage_ForecastCategory_Mapping__c > sfmlst = new List<Stage_ForecastCategory_Mapping__c >();
        /*Stage_ForecastCategory_Mapping__c sfm0 = new Stage_ForecastCategory_Mapping__c(name='Stg0', StageName__c = '0 - Initial Prospecting', Forecast_Category__c = 'Pipeline');
        sfmlst.add(sfm0);*/
        Stage_ForecastCategory_Mapping__c sfm = new Stage_ForecastCategory_Mapping__c(name='Stg1', StageName__c = Label.Stage_1_Alignment /*'1 - Qualified and Budgeted'*/, Forecast_Category__c = 'Pipeline');
        sfmlst.add(sfm);
        Stage_ForecastCategory_Mapping__c sfm1 = new Stage_ForecastCategory_Mapping__c(name='Stg2', StageName__c = label.Stage_2_Qualified_Budgeted /*'2 - Technical Validation'*/, Forecast_Category__c = 'Pipeline');
        sfmlst.add(sfm1);
        Stage_ForecastCategory_Mapping__c sfm2 = new Stage_ForecastCategory_Mapping__c(name='Stg3', StageName__c = label.Stage_4_Economic_Buyer_Signoff /*'7 - Negotiation & Review'*/, Forecast_Category__c = 'Pipeline');
        sfmlst.add(sfm2);
        //Stage_ForecastCategory_Mapping__c sfm3 = new Stage_ForecastCategory_Mapping__c(name='Stg4', StageName__c = label.Stage_4_Economic_Buyer_Signoff /*'8 - Expecting Order'*/, Forecast_Category__c = 'Commit');
        //sfmlst.add(sfm3);
        //Stage_ForecastCategory_Mapping__c sfm4 = new Stage_ForecastCategory_Mapping__c(name='Stg5', StageName__c = '10 - Closed Won', Forecast_Category__c = ClosedStage);
        //sfmlst.add(sfm4);
        Stage_ForecastCategory_Mapping__c sfm5 = new Stage_ForecastCategory_Mapping__c(name='Stg6', StageName__c = label.Stage_5_Contracts_Complete /*'10b - PO recd, pending finance approval'*/, Forecast_Category__c = ClosedStage);
        sfmlst.add(sfm5);
        sfmlst.add(new Stage_ForecastCategory_Mapping__c(name='Stg5A', StageName__c = label.Stage_5A_Opportunity /*'10b - PO recd, pending finance approval'*/, Forecast_Category__c = ClosedStage));
        sfmlst.add(new Stage_ForecastCategory_Mapping__c(name='Stg5B', StageName__c = label.Stage_5B_Opportunity /*'10b - PO recd, pending finance approval'*/, Forecast_Category__c = ClosedStage));
        sfmlst.add(new Stage_ForecastCategory_Mapping__c(name='Stg5C', StageName__c = label.Stage_5C_Opportunity /*'10b - PO recd, pending finance approval'*/, Forecast_Category__c = ClosedStage));
        Stage_ForecastCategory_Mapping__c sfm6 = new Stage_ForecastCategory_Mapping__c(name='Stg7', StageName__c = label.Stage_7_Closed_Lost /*'11 - Closed Lost'*/, Forecast_Category__c = 'Omitted');
        sfmlst.add(sfm6);
        /*Stage_ForecastCategory_Mapping__c sfm7= new Stage_ForecastCategory_Mapping__c(name='Stg8', StageName__c = '12 - Closed With No Decision', Forecast_Category__c = 'Omitted');
        sfmlst.add(sfm7);
        Stage_ForecastCategory_Mapping__c sfm8= new Stage_ForecastCategory_Mapping__c(name='Stg9', StageName__c = '14 - Closed: Delete Duplicate', Forecast_Category__c = 'Omitted');
        sfmlst.add(sfm8);*/
        Stage_ForecastCategory_Mapping__c sfm9 = new Stage_ForecastCategory_Mapping__c(name='Stg10', StageName__c = label.Stage_6_Closed_Won /*'13 - Closed & Approved By Finance'*/, Forecast_Category__c = ClosedStage);
        sfmlst.add(sfm9);
        return sfmlst;
    }
    
    public static List<SKUs_Referred_in_Renewal_Upsell_NS_Calc__c> skusNSInteg(){
        List<SKUs_Referred_in_Renewal_Upsell_NS_Calc__c> trlst = new List<SKUs_Referred_in_Renewal_Upsell_NS_Calc__c>();
        SKUs_Referred_in_Renewal_Upsell_NS_Calc__c tr1 = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c(name = 'Credit_SKUs', SKU_Codes__c = 'Z-Credit;ZCR-Buyback');
        SKUs_Referred_in_Renewal_Upsell_NS_Calc__c tr2 = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c(name = 'One_Time_SKUs', SKU_Codes__c = DASSKUCodes);
        SKUs_Referred_in_Renewal_Upsell_NS_Calc__c tr3 = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c(name = 'DAS_SKUs', SKU_Codes__c = DASSKUCodes);
        SKUs_Referred_in_Renewal_Upsell_NS_Calc__c tr4 = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c(name = 'One_Time_SKU', SKU_Codes__c = DASSKUCodes);
        SKUs_Referred_in_Renewal_Upsell_NS_Calc__c tr5 = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c(name = 'One_Time_SKU1', SKU_Codes__c = DASSKUCodes);
        SKUs_Referred_in_Renewal_Upsell_NS_Calc__c tr6 = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c(name = 'FED_DAS_SKUs', SKU_Codes__c = DASSKUCodes);
        SKUs_Referred_in_Renewal_Upsell_NS_Calc__c tr7 = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c(name='ZPA_Contract_Date', SKU_Codes__c = 'ZPA-BBA;ZPA-BUS;ZPA-ENT;ZPA-PRO;ZPA-PRO-LU;ZPA-BUS-LU;ZS-WFA-BUS-EDITION');
        SKUs_Referred_in_Renewal_Upsell_NS_Calc__c tr8 = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c(name='ZIA_Contract_Date', SKU_Codes__c = 'ZSC-SIP;ZIA-PRO-BUNDLE;ZIA-BUS-BUNDLE;ZIA-TRANS-BUNDLE;ZCES-SUP-PREM;ZIA-ELA-BUNDLE;ZIA-PRO-BUNDLE-LU;ZIA-BUS-BUNDLE-LU;ZIA-TRANS-BUNDLE-LU;ZIA-ELA-BUNDLE-LU;ZSC-SIP-LOC;ZIA-SIP;ZS-WFA-BUS-EDITION');
        SKUs_Referred_in_Renewal_Upsell_NS_Calc__c tr9 = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c(name='ZIA_Contract_Date1', SKU_Codes__c = 'ZS-WFA-BUS-EDITION');
        SKUs_Referred_in_Renewal_Upsell_NS_Calc__c tr10 = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c(name='ZPA_Deployment_SKUs', SKU_Codes__c = 'ZCES-PRO-SVC;ZCES-DAS-PKG0;ZCES-DAS-PKG1;ZCES-DAS-PKG2;ZCES-DAS-PKG3;ZCES-DAS-PKG6;ZCES-EDU-CREDIT;ZCES-EDU-LABCREDIT');
        SKUs_Referred_in_Renewal_Upsell_NS_Calc__c tr11 = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c(name='Uplift_SKUs', SKU_Codes__c = 'ZCR-UPY4;ZCR-UPY5');
        SKUs_Referred_in_Renewal_Upsell_NS_Calc__c tr12 = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c(name='SKUs_to_SKIP_ACV', SKU_Codes__c = 'ZCR-BuyBack;Z-ZPA-BuyBack;Z-CFWCSB-PROMO;Z-CFWZPA-Credit;Z-CREDIT;ZCR-UPY4;ZCR-UPY5');
        SKUs_Referred_in_Renewal_Upsell_NS_Calc__c tr13 = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c(name='Recurring_SKU', SKU_Codes__c = 'ZCES-SUP-PREM;ZCES-SUP-PREM-SP;ZCES-SUP-TAMT');
        trlst.add(tr1);
        trlst.add(tr2);
        trlst.add(tr3);
        trlst.add(tr4);
        trlst.add(tr5);
        trlst.add(tr6);
        trlst.add(tr7);
        trlst.add(tr8);
        trlst.add(tr9);
        trlst.add(tr10);
        trlst.add(tr11);
        trlst.add(tr12);
        trlst.add(tr13);
        return trlst;
    }
    public static List<Like_to_Like_Asset_Mapping_for_ZSUITE__c> liketolike(){
        List<Like_to_Like_Asset_Mapping_for_ZSUITE__c> trlst = new List<Like_to_Like_Asset_Mapping_for_ZSUITE__c>();
        Like_to_Like_Asset_Mapping_for_ZSUITE__c tr1 = new Like_to_Like_Asset_Mapping_for_ZSUITE__c(name = '1', Asset_SKU_Codes__c = 'ZSC-SIP;ZSUITE-WEBBUS;Z-LOGFEED;ZMAN-WEB-BAND',Asset_SKU_Qty_codes__c = 'ZSUITE-WEBBUS',Proposal_Line_Item_Quantity_SKU_Codes__c=ZIABusBundle,Proposal_Line_Item_SKU_Codes__c=ZIABusBundle);
        Like_to_Like_Asset_Mapping_for_ZSUITE__c tr2 = new Like_to_Like_Asset_Mapping_for_ZSUITE__c(name = '2', Asset_SKU_Codes__c = 'ZSC-SIP;ZSUITE-WEBBUS',Asset_SKU_Qty_codes__c = 'ZSUITE-WEBBUS',Proposal_Line_Item_Quantity_SKU_Codes__c=ZIABusBundle,Proposal_Line_Item_SKU_Codes__c=ZIABusBundle);
        trlst.add(tr1);
        trlst.add(tr2);
        return trlst;
    }
    public static List<Service_Team_to_Skill_Map__c> getserviceteamtoskill(){
        List<Service_Team_to_Skill_Map__c> trlst = new List<Service_Team_to_Skill_Map__c>();
        trlst.add(new Service_Team_to_Skill_Map__c(name = 'Centracomm', Skill__c = 'Cetercomm'));
        trlst.add(new Service_Team_to_Skill_Map__c(name = 'L2', Skill__c = 'L2;L2Escalated;L2AEscalated;L3Escalated;L2_Placeholder'));
        trlst.add(new Service_Team_to_Skill_Map__c(name = 'Frontline', Skill__c = 'P1;P2_P4;No_Overflow'));
        trlst.add(new Service_Team_to_Skill_Map__c(name = 'Backline', Skill__c = 'Backline;No_Overflow'));
        return trlst;
    }
    public static List<Primary_Secondary_Escalation_Support_Map__c> getprimsecescmap(){
        List<Primary_Secondary_Escalation_Support_Map__c> trlst = new List<Primary_Secondary_Escalation_Support_Map__c>();
        trlst.add(new Primary_Secondary_Escalation_Support_Map__c(name = 'Centracomm', Escalation_Support__c = '', Primary_Support__c='Centracomm', Secondary_Support__c=''));
        trlst.add(new Primary_Secondary_Escalation_Support_Map__c(name = 'CS', Escalation_Support__c = '', Primary_Support__c='CS', Secondary_Support__c=''));
        trlst.add(new Primary_Secondary_Escalation_Support_Map__c(name = 'L1', Escalation_Support__c = '', Primary_Support__c='L1', Secondary_Support__c=''));
        trlst.add(new Primary_Secondary_Escalation_Support_Map__c(name = 'L1Escalation', Escalation_Support__c = 'L3Escalated', Primary_Support__c='L2Escalated', Secondary_Support__c='L2AEscalated'));
        trlst.add(new Primary_Secondary_Escalation_Support_Map__c(name = 'L2', Escalation_Support__c = '', Primary_Support__c='L2', Secondary_Support__c='L2-Placeholder'));
        trlst.add(new Primary_Secondary_Escalation_Support_Map__c(name = L2A, Escalation_Support__c = '', Primary_Support__c=L2A, Secondary_Support__c='L2'));
        trlst.add(new Primary_Secondary_Escalation_Support_Map__c(name = 'L2AEscalation', Escalation_Support__c = '', Primary_Support__c='L3Escalated', Secondary_Support__c='L3'));
        trlst.add(new Primary_Secondary_Escalation_Support_Map__c(name = 'L2Escalation', Escalation_Support__c = 'L3Escalated', Primary_Support__c='L2AEscalated', Secondary_Support__c=L2A));
        trlst.add(new Primary_Secondary_Escalation_Support_Map__c(name = 'L3', Escalation_Support__c = '', Primary_Support__c='L3', Secondary_Support__c=L2A));
        return trlst;
    }
    public static List<Case_Priority_Score__c> getpriorityscore(){
        List<Case_Priority_Score__c> trlst = new List<Case_Priority_Score__c>();
        trlst.add(new Case_Priority_Score__c(name = 'High (P2)', Score__c = 25));
        trlst.add(new Case_Priority_Score__c(name = 'Low (P4)', Score__c = 25));
        trlst.add(new Case_Priority_Score__c(name = 'Medium (P3)', Score__c = 25));
        trlst.add(new Case_Priority_Score__c(name = 'Urgent (P1)', Score__c = 25));
        return trlst;
    }
    public static List<DEFCON_Case_Score__c> getdefconcasescore(){
        List<DEFCON_Case_Score__c> trlst = new List<DEFCON_Case_Score__c>();
        trlst.add(new DEFCON_Case_Score__c(name = '1', Score__c = 25));
        trlst.add(new DEFCON_Case_Score__c(name = '2', Score__c = 25));
        trlst.add(new DEFCON_Case_Score__c(name = '3', Score__c = 25));
        trlst.add(new DEFCON_Case_Score__c(name = '4', Score__c = 25));
        trlst.add(new DEFCON_Case_Score__c(name = '5', Score__c = 25));
        return trlst;
    }
    public static List<DefaultData__c> getDefaultData(){
        List<DefaultData__c> trlst = new List<DefaultData__c>();
		Account acc = new Account(Name = 'Test account');
		insert acc;
        trlst.add(new DefaultData__c(name = 'PRCaseCreationDefault', Account_Id__c = acc.Id, Category__c='Provisioning Request',Priority__c='Medium (P3)',Product__c='ZIA', Stage_Status__c='New',Type__c='Provisioning'));
        trlst.add(new DefaultData__c(name = 'SurveyCaseDefaults', Account_Id__c = acc.Id, Category__c='DSAT',Priority__c='Medium (P3)',Product__c='', Stage_Status__c='New',Type__c=''));
        return trlst;
    }
    
    // Start Modified by Abhijit for CR840
    public static User insertStandardUser(String email, String lastName, String firstName, string alias, string userName, string timeZoneSidKey, string languageLocaleKey, string emailEncodingKey, string localeSidKey){
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User userMgr = new User(LastName = lastname,
                           FirstName=Firstname,
                           Alias = alias,
                           Email = email,
                           Username = userName,
                           ProfileId = profileId.id,
                           TimeZoneSidKey = timeZoneSidKey,
                           LanguageLocaleKey = languageLocaleKey,
                           EmailEncodingKey = EmailEncodingKey,
                           LocaleSidKey = localeSidKey
                           );
        insert userMgr;
        
        return userMgr;
    }    

    public static User insertAdminUser(String email, String lastName, String firstName, string alias, string userName, string timeZoneSidKey, string languageLocaleKey, string emailEncodingKey, string localeSidKey){
        Profile adminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        System.debug('adminProfile** : '+adminProfile);
        User userMgr = new User(LastName = lastname,
                            FirstName=Firstname,
                            Alias = alias,
                            Email = email,
                            Username = userName,
                            ProfileId = adminProfile.Id,
                            TimeZoneSidKey = timeZoneSidKey,
                            LanguageLocaleKey = languageLocaleKey,
                            EmailEncodingKey = EmailEncodingKey,
                            LocaleSidKey = localeSidKey
                           );
                           System.debug('userMgr** : '+userMgr);
        insert userMgr;
       
        return userMgr;
    }    
    
    public static Opportunity insertOpportunity(string name, boolean primaryQuoteException, String accountId, string stageName, Date closeDate, string recordTypeId, string  nextStep, string opportunitySalesEngineer, string sEZnumber,
                                                string primaryReasonForLoss, string validationStage, Date technicalValidationStartDate, string subStage, string SEName, string validationPlan, boolean realignPatchReset){
        opportunity opp = new opportunity();
        opp.Name = name;
        opp.Primary_Quote_Exception__c  = primaryQuoteException;
        opp.AccountId = accountId;
        opp.StageName = stageName;
        opp.CloseDate = closeDate;
        if(recordTypeId != null){
            opp.RecordTypeId = recordTypeId;        
        }
        opp.Primary_Reason_For_Loss__c = primaryReasonForLoss;
        opp.Validation_Stage__c = validationStage;
        opp.Technical_Validation_Start_Date__c = technicalValidationStartDate;
        opp.Sub_Stage__c = subStage;
        opp.SE_name__c = SEName;
        opp.Validation_Plan__c = validationPlan;
        opp.NextStep =  nextStep;
        opp.Opportunity_Sales_Engineer__c =  opportunitySalesEngineer;
        opp.SE_Znumber__c =  sEZnumber;                
        
        if(realignPatchReset){
            TriggerUtility.realignPatchReset();        
        }

        insert opp;
        return opp;
    
    }    
    
    public static Account insertAccount(string name, string tamEmail, string type, string recordTypeId, string patch, integer numberOfEmployees){
        Account acc = new Account();
        acc.Name = name;
        acc.TAM_Email__c = tamEmail;
        acc.Type= type;
        acc.NumberOfEmployees = numberOfEmployees;
        if(recordTypeId != null){
            acc.RecordTypeId = recordTypeId;        
        }
        acc.Patch__c = patch;

        insert acc;
        
        return acc;
    }    

    public static Contact insertContact(string lastName, string accountId, string partnerDealRegAccountName){
        Contact con = new Contact();
        con.LastName = lastName;
        con.accountId = accountId;
        con.Partner_Deal_Reg_Account_Name__c= partnerDealRegAccountName;

        insert con;
        
        return con;
    }  
    
    public static Task insertTask(string subject, string status, string priority, string whatId){
       Task ta = new Task();
       ta.Subject=subject;
       ta.Status=status;
       ta.Priority=priority;
       ta.whatId = whatid;
       insert ta;
        
        return ta;
    }    
    
    public static Event insertEvent(Date startdate, Date endDate, string whatId){
        Event ev = new Event();
        ev.WhatID  = whatId;
        ev.StartDateTime=startdate;
        ev.EndDateTime=endDate;

        insert ev;
        
        return ev;
    }    


    public static Account insertAccountForextension(string name, string type, string recordTypeId, string summarizetheValuetotheCustomer, string csManagementNotes , string customerNextSteps, string architectureWorkshopLink, string archworkshopnextsteps, string zsrLink){
        Account acc = new Account();
        acc.Name = name;
        acc.Type= type;
        if(recordTypeId != null){
            acc.RecordTypeId = recordTypeId;        
        }
        acc.Summarize_the_Value_to_the_Customer__c = summarizetheValuetotheCustomer;
        acc.CS_Management_Notes__c = csManagementNotes;
        acc.Customer_Next_Steps__c = customerNextSteps;
        acc.Architecture_Workshop_Link__c = architectureWorkshopLink;
        acc.Arch_workshop_next_steps__c = archworkshopnextsteps;
        acc.ZSR_Link__c = zsrLink;

        insert acc;
        
        return acc;
    }    

    public static Account_Extension__c insertAccountExtension(string accountId){
    
        Account_Extension__c accExt = new Account_Extension__c();    
        accExt.Account__c = accountId;

        insert accExt;
        
        return accExt;
    }    

    public static Case insertCase(string status, string subject, string description, string accountId, string accountofSupportCase, string legacyAccount, string recordTypeId){
        //Id prRecordTypeId = Schema.getGlobalDescribe().get(status).SObjectType.getRecordTypeInfosByName().get(status).getRecordTypeId();        
        Case c = new Case();
        c.Status = status;
        c.Subject = subject;
        c.Description = description;
        c.AccountId = accountId;
        c.Account_of_Support_Case__c = accountofSupportCase;
        c.Legacy_Account__c = legacyAccount;
        if(recordTypeId != null){
           c.RecordTypeId = recordTypeId;        
        }
        
        insert c;
        return c;
    } 
    
    public static Provisioning_Request__c insertProvisioningRequest(string oppId, string recordTypeId, string accountId, string sendInitialL, string se, string status){
        Provisioning_Request__c pr = new Provisioning_Request__c();
        pr.Opportunity__c = oppId;
        if(recordTypeId != null){
           pr.RecordTypeId = recordTypeId;        
        }
        pr.Account__c = accountId;
        pr.Send_Initial_l__c = sendInitialL;
        pr.SE__c = se;
        pr.Provisioning_Status__c = status;

        insert pr;
        
        return pr;
    }

    public static Equipment_Request__c insertEquipmentRequest(string approvalStatus, string recordTypeId, string oppId, boolean localizedContent){
        Equipment_Request__c er = new Equipment_Request__c();
        er.Approval_Status__c = approvalStatus;
        if(recordTypeId != null){
           er.RecordTypeId = recordTypeId;
        }
        er.Opportunity__c = oppId;
        er.Localized_content__c = localizedContent;
        insert er;
        
        return er;
    }
       
   public static Product2 constructProduct(String ProductName, String pcode, String pfamily, String sConfigType, boolean isActive, boolean hasAttributes, boolean hasOptions) {
       Product2 productSO = new Product2();
       productSO.Name = ProductName;
       productSO.Family = pfamily;
       productSO.ProductCode = pcode;
       productSO.IsActive = isActive;
       
       return productSO;
   }    
   
   public static OpportunityLineItem constructOppLineItem(String oppId, String pId){
        OpportunityLineItem lineItem1 = new OpportunityLineItem();
        lineItem1.OpportunityId = oppId;
        lineItem1.Product2Id = pId;
        
        return lineItem1;
      }

  public static Contract_Detail__c insertContractDetail(string name, string accountId, string productId, Date startDate, Date endDate, Decimal quantity, Decimal amountUsd, string contractNo, decimal mRRUSD, decimal listPrice, decimal discount, boolean needstoBeMigratedAssetLine, boolean doNotAggregate){
       Contract_Detail__c contractDetail = new Contract_Detail__c();
       contractDetail.Name = name;
       contractDetail.Account_Name__c = accountId;
       contractDetail.Product_Name__c = productId;
       contractDetail.Start_Date__c = startDate;
       contractDetail.End_Date__c = endDate;
       contractDetail.Quantity__c = quantity;
       contractDetail.Amount_USD__c = amountUsd;
       contractDetail.Contract_No__c = contractNo;
       contractDetail.MRR_USD__c = mRRUSD;
       contractDetail.List_Price__c = listPrice;
       contractDetail.Discount__c = discount;
       contractDetail.Needs_to_Be_Migrated_to_Asset_Line__c = needstoBeMigratedAssetLine;
       contractDetail.Do_Not_Aggregate__c = doNotAggregate;
       
       insert contractDetail;
       
       return contractDetail;
  }  
  
  public static Order insertOrder(string accountId, string name, Date orderDate, string nSSalesOrderNumber, Date effectiveDate, Date endDate, string status, string location){
       Order o = new Order();
       o.name = name;
       o.AccountId = accountId;
       o.Order_Date__c = orderDate;
       o.NS_Sales_Order_Number__c = nSSalesOrderNumber;
       o.EffectiveDate = effectiveDate;
       o.EndDate=endDate;
       o.Status = status;
       o.Location__c = location;
       
       insert o;
       
       return o;
  
  }        
              
    // End Modified by Abhijit for CR840 
    
    // Create Products of default ZPA Product Family
    public static Product2 createProduct(String PRoductName, String pcode, String pfamily, String sConfigType, String zscalerProductFamily) {
        Product2 productSO = new Product2();
        productSO.Name = ProductName;
        productSO.Family = pfamily;
        productSO.ProductCode = pcode;
        productSO.IsActive = true;
        productSO.APTS_Buyback_Eligible__c = true;
        productSO.Zscaler_Product_Family__c = zscalerProductFamily;
        productSO.APTS_DisableManualAdjustments__c = false;
        return productSO;
    }

     //Added by Ayush Kangar as part of IBA-4567 - Start	
     public static PS_Questionnaire__c insertPSQuestionnaireforPSOnboarding(string accountid, string opportunityId){	
        Id PsOnboardingRecordTypeId = Schema.SObjectType.PS_Questionnaire__c.getRecordTypeInfosByDeveloperName().get(Label.PS_Onboarding).getRecordTypeId();     	
        PS_Questionnaire__c psq=new PS_Questionnaire__c();	
        	psq.Account__c=accountId;	
        	psq.opportunity__c =opportunityId;	
        	psq.recordtypeId = PsOnboardingRecordTypeId;	
        	psq.Customer_s_Preferred_Start_Date__c = Date.today();	
        	psq.Is_this_a_paid_pilot__c = 'No';	
        	insert psq;	
        	
        return psq;	
    }
        
    // Added by Swathi for CR840
    public static List<Product2> getProduct2(){
        List<Product2> trlst = new List<Product2>();
        trlst.add(new Product2(Name = 'Test Support Product', Product_Line__c = 'Support', ProductCode = 'ABCD',IsActive = true));
        trlst.add(new Product2(Name = 'Test Support Product', Product_Line__c = 'Support', ProductCode = 'ZCR-BuyBack',IsActive = true));
        return trlst;
    }

    public static ServiceResource insertServiceResource(String name, String userId, Integer dailyQuota, Integer weeklyQuota, Integer backlog, Integer ofCases, Integer ofCasesWeekly,String type){
        ServiceResource sr = new ServiceResource();
        sr.name = name;
        sr.RelatedRecordId=userId;
        sr.daily_Quota__c = dailyQuota;
        sr.weekly_quota__c = weeklyQuota; 
        sr.backlog__c = backlog;
        sr.Overflow_Cases__c = ofCases;
        sr.Overflow_Cases_Weekly__c = ofCasesWeekly; 
        sr.Type__c = Type;
  
        insert sr;
        return sr;
    }

    public static Shift insertShift(String srId, String priority, String day, Datetime startDt, Datetime endDt, String slot){
        Shift sf = new Shift();
        sf.ServiceResourceId = srId;
        sf.Shift_Type__c = priority;
        sf.Day__c = day;	
		sf.StartTime = startDt;
        sf.EndTime = endDt;
		sf.TimeSlotType = slot;

        insert sf;
        return sf;
    }

	public static Shift insertShift(String srId, String priority, String day, Datetime startDt, Datetime endDt, String slot, String serviceTerritory,String typ){
        Shift sf = new Shift();
        sf.ServiceResourceId = srId;
        sf.Shift_Type__c = priority;
        sf.Day__c = day;	
		sf.StartTime = startDt;
        sf.EndTime = endDt;
		sf.TimeSlotType = slot;
		sf.ServiceTerritoryId = serviceTerritory;
		sf.Type = typ;
		
        if(typ == 'Recurring'){
            DateTime after30days = Datetime.now().addDays(30);
            String dateAfter30days = after30days.format('yyyyMMdd');
			String rp = 'RRULE:FREQ=WEEKLY;INTERVAL=1;BYDAY=MO,TU,WE,TH,FR;UNTIL=' + dateAfter30days + 'T000000Z';
            sf.RecurrencePattern = rp;
        }
        insert sf;
        return sf;
    }

    public static ResourceAbsence insertResourceAbsence(String resourceId,DateTime startTime, DateTime endTime, String type){
        ResourceAbsence absence = new ResourceAbsence();
        absence.Start = startTime;
        absence.End = endTime;
        absence.ResourceId = resourceId;
        absence.Type = type;

        Insert absence;

        return absence;
    }

    public static ServiceAppointment insertServiceAppointment(String parentId,DateTime schedStartTime, DateTime schedEndTime,DateTime dueDate,DateTime earliestStartTime){
        ServiceAppointment meeting = new ServiceAppointment();
        meeting.ParentRecordId = parentId;
        meeting.SchedStartTime = schedStartTime;
        meeting.SchedEndTime = schedEndTime;
        meeting.DueDate = dueDate;
        meeting.EarliestStartTime = earliestStartTime;

        insert meeting;

        return meeting;
    }

    public static AssignedResource insertAssignedResource(string appointmentId, string resourceId){
        AssignedResource aresource = new AssignedResource();
        aresource.ServiceAppointmentId = appointmentId;
        aresource.ServiceResourceId = resourceId;

        insert aresource;

        return aresource;
    }

}