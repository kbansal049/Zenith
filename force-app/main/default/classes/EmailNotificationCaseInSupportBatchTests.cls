@IsTest
public class EmailNotificationCaseInSupportBatchTests {
    final static String CASE_SUPPORT_RT_ID = GCSCommonUtility.getCaseRecordTypeId(GCSCommonConstants.CASE_SUPPORT_RECORD_TYPE_NAME);
    final static Id ACCOUNT_END_USER_CUSTOMER_DS_REVIEWED_RT_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('End_User_Customer_DS_Reviewed').getRecordTypeId();
    
    @TestSetup
    static void setupTestData(){
        Id supportQueueId = GCSCommonUtility.getCaseQueueId('Support_Queue');
        String phoneStr = 'Phone';

        User ur = GCSTestDataFactory.createUser(GCSCommonConstants.TEST_USER_EMAIL,GCSCommonConstants.TEST_CONTACT_LAST_NAME, GCSCommonConstants.TEST_CONTACT_FIRST_NAME, 'ttest12', '2xyz@xyz.com.test',GCSCommonConstants.AMERICA_LA_TIME_ZONE,GCSCommonConstants.LANGUAGE_ENCODING_AS_EN_US,GCSCommonConstants.EMAIL_ENCODING_AS_UTF_8,GCSCommonConstants.LANGUAGE_ENCODING_AS_EN_US);
        insert ur;
        
        Account acct = GCSTestDataFactory.createAccount(GCSCommonConstants.TEST_ACCOUNT_NAME,GCSCommonConstants.ACCOUNT_TYPE_CUSTOMER, ACCOUNT_END_USER_CUSTOMER_DS_REVIEWED_RT_ID);
        insert acct;
        
        Contact con = GCSTestDataFactory.createContact(GCSCommonConstants.TEST_CONTACT_LAST_NAME, GCSCommonConstants.TEST_CONTACT_FIRST_NAME, acct.Id, GCSCommonConstants.TEST_USER_EMAIL);
        insert con;

        Case cs = GCSTestDataFactory.createCase(GCSCommonConstants.TEST_SUPPORT_CASE_SUBJECT, GCSCommonConstants.CASE_PRODUCT_ZPA, GCSCommonConstants.CASE_STATUS_NEW,GCSCommonConstants.CASE_PRIORITY_MEDIUM,GCSCommonConstants.CASE_ORIGIN_API,GCSCommonConstants.CASE_TYPE_PROVISIONING,GCSCommonConstants.ASIA_KOLKATA_TIME_ZONE, phoneStr,CASE_SUPPORT_RT_ID,ur.Id,con.Id);
        cs.OwnerId = supportQueueId;
        cs.Case_Assign_to_Support_Queue__c = datetime.now();
        insert cs;
    }
    
    @isTest
    static void testEmailNotificationCaseInSupportBatch(){
        String queryFields = 'id,subject,case_source__c,Case_Type__c,RecordTypeId,Case_Assign_to_Support_Queue__c';
        String whereClause = null;
        String orderByClause = null;
        Integer limitClause = null;

        List<Case> csList = CaseSelector.getCases(queryFields, whereClause, orderByClause, limitClause);
        System.assert(csList != null, GCSCommonConstants.APEX_TEST_PASS);

        csList.get(0).Case_Assign_to_Support_Queue__c = datetime.now().addMinutes(-30);
        update csList;

        Test.startTest();
        	EmailNotificationCaseInSupportBatch m = new EmailNotificationCaseInSupportBatch();
            Id jobId = Database.executeBatch(m);
            AsyncApexJob job = [SELECT Id, Status FROM AsyncApexJob WHERE Id = :jobId LIMIT 1];
            System.assert(job.Status != null, GCSCommonConstants.APEX_TEST_PASS);
        Test.stopTest();
    }
}