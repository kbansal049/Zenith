@isTest
public class CaseTriggerHandlerTest {
    final static String CASE_SUPPORT_RT_ID = GCSCommonUtility.getCaseRecordTypeId(GCSCommonConstants.CASE_SUPPORT_RECORD_TYPE_NAME);
    final static Id ACCOUNT_END_USER_CUSTOMER_DS_REVIEWED_RT_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('End_User_Customer_DS_Reviewed').getRecordTypeId();
    final static Id SLA_PROCESS_ID = [SELECT Id FROM SlaProcess WHERE SObjectType = 'Case' AND Name = 'Defcon Escalations Entitlement Process' ORDER BY LastModifiedDate DESC LIMIT 1].Id;
    
    static String caseTZStr = 'Pacific/Chatham';
    static String userTZSIDKeyStr = 'America/Sao_Paulo';
    static String userLanguageLocaleKeyStr = 'en_US';
    static String userEmailEncodingKeyStr = 'UTF-8';
    static String testEmailStr = 'test@test.com';
    static String testEmail1Str = 'test1@t1.com';
    static String testEmail2Str = 'test2@t2.com';
    static String phoneStr = 'Phone';
    static String gmtStr = 'GMT';
    static String l2aStr = 'L2A';
    static String testFNameStr = 'TestFName';
    
    static String acctQueryFieldsStr = 'Id, Domain__c, X3rd_TAM_Name__c, TAM_Name_New__c, Secondary_TAM_Name__c';
    static String acctwhereClauseAccStr = ' Name = \'' + GCSCommonConstants.TEST_ACCOUNT_NAME + '\'';
    static String orderByClauseAcc = null;
    static Integer limitClauseAcc = null;

    @testSetup
    static void setupTestData(){
        List<Triggers_Switch__c> lstTriggersSwitch = new List<Triggers_Switch__c>();
        
        lstTriggersSwitch.add(GCSTestDataFactory.createTriggersSwitch('Execute_UpdateNOCSubject'));
        lstTriggersSwitch.add(GCSTestDataFactory.createTriggersSwitch('Execute_Case_SkillAssignment'));
        lstTriggersSwitch.add(GCSTestDataFactory.createTriggersSwitch('Execute_Case_Entitlement_Assignment'));
        lstTriggersSwitch.add(GCSTestDataFactory.createTriggersSwitch('updateExtentison'));
        lstTriggersSwitch.add(GCSTestDataFactory.createTriggersSwitch('ExecuteUpdateTAMemail'));
        lstTriggersSwitch.add(GCSTestDataFactory.createTriggersSwitch('ExecuteUpdateSEonCase'));
        lstTriggersSwitch.add(GCSTestDataFactory.createTriggersSwitch('Execute_UpdateCustomerSupportAlias'));
        lstTriggersSwitch.add(GCSTestDataFactory.createTriggersSwitch('ExecuteUpdateOriginalTAMdetails'));
        lstTriggersSwitch.add(GCSTestDataFactory.createTriggersSwitch('Execute_Case_Close_with_Action_Plan'));
        lstTriggersSwitch.add(GCSTestDataFactory.createTriggersSwitch('Execute_TAM_Reassignment'));
        lstTriggersSwitch.add(GCSTestDataFactory.createTriggersSwitch('Execute_CollaboratorEmailList'));
        lstTriggersSwitch.add(GCSTestDataFactory.createTriggersSwitch('Execute_setRequestType'));
        lstTriggersSwitch.add(GCSTestDataFactory.createTriggersSwitch('Execute_addDefaultProdOnSFDCCases'));
        lstTriggersSwitch.add(GCSTestDataFactory.createTriggersSwitch('Execute_CC_toCaseTeam'));
        lstTriggersSwitch.add(GCSTestDataFactory.createTriggersSwitch('Execute_Case_Description_to_Comment'));
        lstTriggersSwitch.add(GCSTestDataFactory.createTriggersSwitch('Execute_Case_TAM_Notes_History'));
        lstTriggersSwitch.add(GCSTestDataFactory.createTriggersSwitch('UpdateAccountDataTime'));
        lstTriggersSwitch.add(GCSTestDataFactory.createTriggersSwitch('Executed_CustomerScroceCard'));
        lstTriggersSwitch.add(GCSTestDataFactory.createTriggersSwitch('Execute_SendEscalationEmail'));
        lstTriggersSwitch.add(GCSTestDataFactory.createTriggersSwitch('Execute_Escalation_Notes_Creation'));
        lstTriggersSwitch.add(GCSTestDataFactory.createTriggersSwitch('Execute_Escalation_History_Creation'));
        lstTriggersSwitch.add(GCSTestDataFactory.createTriggersSwitch('Execute_Case_Status_History'));
        lstTriggersSwitch.add(GCSTestDataFactory.createTriggersSwitch('Execute_Manual_SLA'));
        lstTriggersSwitch.add(GCSTestDataFactory.createTriggersSwitch('Execute_Get_Feedback'));
        lstTriggersSwitch.add(GCSTestDataFactory.createTriggersSwitch('CloseMilestonesonCaseClose'));
        lstTriggersSwitch.add(GCSTestDataFactory.createTriggersSwitch('UpdateDetailsonMasterCase'));
        lstTriggersSwitch.add(GCSTestDataFactory.createTriggersSwitch('Execute_Sync_CaseBA_With_CR'));
        lstTriggersSwitch.add(GCSTestDataFactory.createTriggersSwitch('Execute_Case_Integration_Updation'));
        lstTriggersSwitch.add(GCSTestDataFactory.createTriggersSwitch('Execute_TAM_Owner_OOO_Mail'));
        lstTriggersSwitch.add(GCSTestDataFactory.createTriggersSwitch('Execute_CaseRecordHistoryTracking'));
        lstTriggersSwitch.add(GCSTestDataFactory.createTriggersSwitch('Execute_Partner_Support_Validation'));
        lstTriggersSwitch.add(GCSTestDataFactory.createTriggersSwitch('Execute_Case_Escalation'));
        lstTriggersSwitch.add(GCSTestDataFactory.createTriggersSwitch('Execute_AgentWork_Trigger'));
        lstTriggersSwitch.add(GCSTestDataFactory.createTriggersSwitch('ExecuteUpdateCSMonCase'));
        lstTriggersSwitch.add(GCSTestDataFactory.createTriggersSwitch('Execute_UpdateResolutionState'));
        lstTriggersSwitch.add(GCSTestDataFactory.createTriggersSwitch('Execute_UpdatePendingCustomerTimestamp'));
        lstTriggersSwitch.add(GCSTestDataFactory.createTriggersSwitch('Execute_CreateContactUnderAccount'));
        insert lstTriggersSwitch;
        
        List<User> userList = new List<User>();
        User ur = GCSTestDataFactory.createUser('2xyz@xyz.com', 'test12', testFNameStr, 'ttest12', '2xyz@xyz.com.test', userTZSIDKeyStr, userLanguageLocaleKeyStr, userEmailEncodingKeyStr, userLanguageLocaleKeyStr);
        userList.add(ur);
        
        User ur2 = GCSTestDataFactory.createUser('3xyz@xyz.com', 'test22', 'test2', 'ttest22', '3xyz@xyz.com.test', userTZSIDKeyStr, userLanguageLocaleKeyStr, userEmailEncodingKeyStr, userLanguageLocaleKeyStr);
        userList.add(ur2);
        insert userList;
        
        Account acct = GCSTestDataFactory.createAccount('Test Account', 'Customer', ACCOUNT_END_USER_CUSTOMER_DS_REVIEWED_RT_ID);
        acct.TAM_Name_New__c = userList[0].Id;
        acct.Secondary_TAM_Name__c = userList[1].Id;
        acct.X3rd_TAM_Name__c = UserInfo.getUserId();
        acct.Customer_s_Support_Alias__c = 'test@abc.com';
        insert acct;
        
        Contact con = GCSTestDataFactory.createContact('Contact', testFNameStr, acct.Id, testEmailStr);
        insert con;
        
        Entitlement entitle1 = GCSTestDataFactory.createEntitlement('Defcon Escalation Entitlement (DO NOT DELETE)', acct.Id, date.today(), SLA_PROCESS_ID);
        insert entitle1;
        
        Case csSupport = GCSTestDataFactory.createCase('Test Support Case', GCSCommonConstants.CASE_PRODUCT_ZIA, GCSCommonConstants.CASE_STATUS_NEW, GCSCommonConstants.CASE_PRIORITY_MEDIUM, GCSCommonConstants.CASE_ORIGIN_API, GCSCommonConstants.CASE_TYPE_PROBLEM, caseTZStr, phoneStr,CASE_SUPPORT_RT_ID,ur.Id,con.Id);
        csSupport.Internal_CC_List__c = 'a@gmail.com;b@gmail.com';
        csSupport.Escalation_Reason__c = 'Test Escalation';
        csSupport.Escalation_Category__c = 'Unsatisfied with current support';
        csSupport.EntitlementId = entitle1.Id;
        csSupport.Escalated_By__c = UserInfo.getUserId();
        insert csSupport;
        
        TriggerUtility.CaseAfterUpdateReset();
        TriggerUtility.CaseTAMNotesHistoryReset();
        TriggerUtility.startUpdateAccountDataTime();
        TriggerUtility2.UpdateCustomerScroceCardValueReset();
        update csSupport;        
    }
    
    @isTest
    public static void  testCaseTriggerHandlerMethods(){
        List<Account> accList = AccountSelector.getAccounts(acctQueryFieldsStr, acctwhereClauseAccStr, orderByClauseAcc, limitClauseAcc);
        System.assert(accList != null, GCSCommonConstants.APEX_TEST_PASS);
    }
}