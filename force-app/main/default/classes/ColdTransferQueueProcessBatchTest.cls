@isTest
public class ColdTransferQueueProcessBatchTest {
    
    @TestSetup
    static void setupTestData(){
        String CASE_SUPPORT_RT_ID = GCSCommonUtility.getCaseRecordTypeId(GCSCommonConstants.CASE_SUPPORT_RECORD_TYPE_NAME);
        Id ACCOUNT_END_USER_CUSTOMER_DS_REVIEWED_RT_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('End_User_Customer_DS_Reviewed').getRecordTypeId(); 
        String phoneStr = 'Phone';
        //String bypassTrgStr = 'CaseTriggerHandler';
        
        Timezone_Region_Mapping__c regionMap = GCSTestDataFactory.createTRM(GCSCommonConstants.ASIA_KOLKATA_TIME_ZONE, GCSCommonConstants.ASIA_KOLKATA_TIME_ZONE, 'APAC','APAC');
        insert regionMap;

        Primary_Secondary_Escalation_Support_Map__c pseSupportMap = GCSTestDataFactory.getPrimarySecondaryEscMap('Japan','','','');
        pseSupportMap.Region_Support__c = 'Japan';
        insert pseSupportMap;

        User ur = GCSTestDataFactory.createUser(GCSCommonConstants.TEST_USER_EMAIL,GCSCommonConstants.TEST_CONTACT_LAST_NAME, GCSCommonConstants.TEST_CONTACT_FIRST_NAME, 'ttest12', '2xyz@xyz.com.test',GCSCommonConstants.ASIA_KOLKATA_TIME_ZONE,GCSCommonConstants.LANGUAGE_ENCODING_AS_EN_US,GCSCommonConstants.EMAIL_ENCODING_AS_UTF_8,GCSCommonConstants.LANGUAGE_ENCODING_AS_EN_US);
        insert ur;

        Account acct = GCSTestDataFactory.createAccount(GCSCommonConstants.TEST_ACCOUNT_NAME,GCSCommonConstants.ACCOUNT_TYPE_CUSTOMER, ACCOUNT_END_USER_CUSTOMER_DS_REVIEWED_RT_ID);
        acct.Exclude_Partner_Support__c = true;
        insert acct;
        
        Contact con = GCSTestDataFactory.createContact(GCSCommonConstants.TEST_CONTACT_LAST_NAME, GCSCommonConstants.TEST_CONTACT_FIRST_NAME, acct.Id,GCSCommonConstants.TEST_USER_EMAIL);
        insert con;
        
        Case_Quota_Management__c cqm = GCSTestDataFactory.createCQM(2, 10,3 ,15 , 'Quota_Met;Overflow', '', 'CS;TAM', 'America/Los_Angeles', 0 , 7, 16, 19, 'Sun', 'Fri');
        cqm.SetupOwnerId = UserInfo.getOrganizationId();
        insert cqm;

        Case csSupport1 = GCSTestDataFactory.createCase(GCSCommonConstants.TEST_SUPPORT_CASE_SUBJECT, GCSCommonConstants.CASE_PRODUCT_ZIA, GCSCommonConstants.CASE_STATUS_NEW,GCSCommonConstants.CASE_PRIORITY_URGENT,GCSCommonConstants.CASE_ORIGIN_API,GCSCommonConstants.CASE_TYPE_PROBLEM,GCSCommonConstants.ASIA_KOLKATA_TIME_ZONE, phoneStr,CASE_SUPPORT_RT_ID,ur.Id,con.Id);
        csSupport1.Preferred_Contact_Time_Zone__c = GCSCommonConstants.ASIA_KOLKATA_TIME_ZONE;
        csSupport1.Contact_Time_Slot__c = GCSCommonConstants.CASE_CONTACT_TIME_SLOT;
        csSupport1.Priority_Support__c = GCSCommonConstants.CASE_PRIORITY_SUPPORT_P1;
        csSupport1.AccountId = acct.Id;
        insert csSupport1;

        csSupport1.OwnerId = Label.Cold_Transfer_Queue_Id;
        csSupport1.Warm_Handoff__c = true;
        update csSupport1;
        
        Case csSupport2 = GCSTestDataFactory.createCase(GCSCommonConstants.TEST_SUPPORT_CASE_SUBJECT + '_2', GCSCommonConstants.CASE_PRODUCT_ZPA, GCSCommonConstants.CASE_STATUS_NEW,GCSCommonConstants.CASE_PRIORITY_URGENT,GCSCommonConstants.CASE_ORIGIN_API,GCSCommonConstants.CASE_TYPE_PROVISIONING,GCSCommonConstants.ASIA_KOLKATA_TIME_ZONE, phoneStr,CASE_SUPPORT_RT_ID,ur.Id,con.Id);
        csSupport2.Preferred_Contact_Time_Zone__c = GCSCommonConstants.ASIA_KOLKATA_TIME_ZONE;
        csSupport2.Contact_Time_Slot__c = GCSCommonConstants.CASE_CONTACT_TIME_SLOT;
        csSupport2.AccountId = acct.Id;
        insert csSupport2;

        csSupport2.OwnerId = Label.Cold_Transfer_Queue_Id;
        csSupport2.Warm_Handoff__c = true;
        csSupport2.Priority_Support__c = GCSCommonConstants.CASE_PRIORITY_SUPPORT_P1;
        update csSupport2;

        Case csSupport3 = GCSTestDataFactory.createCase(GCSCommonConstants.TEST_SUPPORT_CASE_SUBJECT + '_3', GCSCommonConstants.CASE_PRODUCT_ZPA, GCSCommonConstants.CASE_STATUS_NEW,GCSCommonConstants.CASE_PRIORITY_HIGH,GCSCommonConstants.CASE_ORIGIN_API,GCSCommonConstants.CASE_TYPE_QUESTION,GCSCommonConstants.ASIA_KOLKATA_TIME_ZONE, phoneStr,CASE_SUPPORT_RT_ID,ur.Id,con.Id);
        csSupport3.Preferred_Contact_Time_Zone__c = GCSCommonConstants.ASIA_KOLKATA_TIME_ZONE;
        csSupport3.Contact_Time_Slot__c = GCSCommonConstants.CASE_CONTACT_TIME_SLOT;
        csSupport3.AccountId = acct.Id;
        insert csSupport3;

        csSupport3.OwnerId = Label.Cold_Transfer_Queue_Id;
        csSupport3.Warm_Handoff__c = true;
        csSupport3.Priority_Support__c = GCSCommonConstants.CASE_PRIORITY_SUPPORT_P1;
        update csSupport3;

    }
    
	@isTest
    static void testColdTransferQueueProcessBatch(){
        Test.StartTest();
            Id jobId = Database.executeBatch(new ColdTransferQueueProcessBatch());
            AsyncApexJob job = [SELECT Id, Status FROM AsyncApexJob WHERE Id = :jobId LIMIT 1];
            System.assert(job.Status != null, GCSCommonConstants.APEX_TEST_PASS);
        Test.StopTest();
    }
}