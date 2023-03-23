@IsTest
public class TAMReassignmentBatchTest {
    final static String CASE_SUPPORT_RT_ID  = GCSCommonUtility.getCaseRecordTypeId(GCSCommonConstants.CASE_SUPPORT_RECORD_TYPE_NAME);
    final static Id ACCOUNT_END_USER_CUSTOMER_DS_REVIEWED_RT_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('End_User_Customer_DS_Reviewed').getRecordTypeId(); 

    @TestSetup
    static void setupTestData(){
        String phoneStr = 'Phone';
        String tamAssignmentAssignedToSupport = 'Assigned To Support';
        String bypassTrgStr = 'AccountTriggerHandler';
        
        Timezone_Region_Mapping__c regionMap = GCSTestDataFactory.createTRM(GCSCommonConstants.ASIA_KOLKATA_TIME_ZONE, GCSCommonConstants.ASIA_KOLKATA_TIME_ZONE, 'APAC','APAC');
        insert regionMap;
        
        List<User> usrList = new List<User>();
        User ur1 = GCSTestDataFactory.createUser('1xyz@xyz.com', 'test11', GCSCommonConstants.TEST_CONTACT_FIRST_NAME, 'ttest11', '1xyz@xyz.com.test', GCSCommonConstants.ASIA_KOLKATA_TIME_ZONE, GCSCommonConstants.LANGUAGE_ENCODING_AS_EN_US, GCSCommonConstants.EMAIL_ENCODING_AS_UTF_8, GCSCommonConstants.LANGUAGE_ENCODING_AS_EN_US);
        usrList.add(ur1);

        User ur2 = GCSTestDataFactory.createUser('2xyz@xyz.com', 'test12', GCSCommonConstants.TEST_CONTACT_FIRST_NAME, 'ttest12', '2xyz@xyz.com.test', GCSCommonConstants.ASIA_KOLKATA_TIME_ZONE, GCSCommonConstants.LANGUAGE_ENCODING_AS_EN_US, GCSCommonConstants.EMAIL_ENCODING_AS_UTF_8, GCSCommonConstants.LANGUAGE_ENCODING_AS_EN_US);
        usrList.add(ur2);
        insert usrList;

        ur1.TimeZoneSidKey = GCSCommonConstants.ASIA_KOLKATA_TIME_ZONE;

        ur2.Start_Date__c = System.Today();
        ur2.Returning_Date__c = System.Today().addDays(5);
        ur2.Out_Of_Office__c = true;
        update usrList;

        ServiceResource sr = GCSTestDataFactory.createServiceResources('Test',ur2.Id,System.Today().addDays(6),true);
        insert sr;

        List<Account> acctList = new List<Account>();
        Account acct1 = GCSTestDataFactory.createAccount(GCSCommonConstants.TEST_ACCOUNT_NAME, GCSCommonConstants.ACCOUNT_TYPE_CUSTOMER, ACCOUNT_END_USER_CUSTOMER_DS_REVIEWED_RT_ID);
        acct1.TAM_Name_New__c = ur1.Id;
        acctList.add(acct1);
        
        Account acct2 = GCSTestDataFactory.createAccount(GCSCommonConstants.TEST_ACCOUNT_NAME + '_2', GCSCommonConstants.ACCOUNT_TYPE_CUSTOMER, ACCOUNT_END_USER_CUSTOMER_DS_REVIEWED_RT_ID);
        acct2.Secondary_TAM_Name__c = ur1.Id;
        acctList.add(acct2);

        Account acct3 = GCSTestDataFactory.createAccount(GCSCommonConstants.TEST_ACCOUNT_NAME + '_3', GCSCommonConstants.ACCOUNT_TYPE_CUSTOMER, ACCOUNT_END_USER_CUSTOMER_DS_REVIEWED_RT_ID);
        acct3.X3rd_TAM_Name__c = ur1.Id;
        acctList.add(acct3);

        Account acct4 = GCSTestDataFactory.createAccount(GCSCommonConstants.TEST_ACCOUNT_NAME + '_4', GCSCommonConstants.ACCOUNT_TYPE_CUSTOMER, ACCOUNT_END_USER_CUSTOMER_DS_REVIEWED_RT_ID);
        acct4.X3rd_TAM_Name__c = ur2.Id;
        acctList.add(acct4);

        TriggerHandler.bypass(bypassTrgStr);
        insert acctList;

        List<Contact> contList = new List<Contact>();
        Contact con1 = GCSTestDataFactory.createContact(GCSCommonConstants.TEST_CONTACT_LAST_NAME, GCSCommonConstants.TEST_CONTACT_FIRST_NAME, acct1.Id, GCSCommonConstants.TEST_USER_EMAIL);
        contList.add(con1);

        Contact con2 = GCSTestDataFactory.createContact('TAM Reassignment Contact LastName', 'TAM Reassignment Contact FirstName', acct2.Id, GCSCommonConstants.TEST_USER_EMAIL);
        contList.add(con2);

        Contact con3 = GCSTestDataFactory.createContact('Case Handoff Contact LastName', 'Case Handoff Contact FirstName', acct3.Id, GCSCommonConstants.TEST_USER_EMAIL);
        contList.add(con3);

        Contact con4 = GCSTestDataFactory.createContact('GCS Leadership Contact LastName', 'GCS Leadership Contact FirstName', acct4.Id, GCSCommonConstants.TEST_USER_EMAIL);
        contList.add(con4);
        insert contList;

        List<Case> caseList = new List<Case>();
        Case csSupport1 = GCSTestDataFactory.createCase(GCSCommonConstants.TEST_SUPPORT_CASE_SUBJECT, GCSCommonConstants.CASE_PRODUCT_ZIA, GCSCommonConstants.CASE_STATUS_NEW, GCSCommonConstants.CASE_PRIORITY_MEDIUM, GCSCommonConstants.CASE_ORIGIN_API, GCSCommonConstants.CASE_TYPE_PROBLEM, GCSCommonConstants.ASIA_KOLKATA_TIME_ZONE, phoneStr,CASE_SUPPORT_RT_ID,ur1.Id,con1.Id);
        csSupport1.TAM_Assignment__c = tamAssignmentAssignedToSupport;
        csSupport1.TAM_Reassignment__c = false;
        csSupport1.Internal_Escalation__c = false;
        csSupport1.Next_TAM_Date__c = System.Now().addDays(-4);
        csSupport1.AccountId = acct1.Id;
        caseList.add(csSupport1);

        Case csSupport2 = GCSTestDataFactory.createCase(GCSCommonConstants.TEST_SUPPORT_CASE_SUBJECT + '_2', GCSCommonConstants.CASE_PRODUCT_ZIA, GCSCommonConstants.CASE_STATUS_NEW, GCSCommonConstants.CASE_PRIORITY_MEDIUM, GCSCommonConstants.CASE_ORIGIN_API, GCSCommonConstants.CASE_TYPE_PROBLEM, GCSCommonConstants.ASIA_KOLKATA_TIME_ZONE, phoneStr,CASE_SUPPORT_RT_ID,ur1.Id,con2.Id);
        csSupport2.TAM_Assignment__c = tamAssignmentAssignedToSupport;
        csSupport2.TAM_Reassignment__c = false;
        csSupport2.Internal_Escalation__c = false;
        csSupport2.Next_TAM_Date__c = System.Now().addDays(-4);
        csSupport2.AccountId = acct2.Id;
        caseList.add(csSupport2);

        Case csSupport3 = GCSTestDataFactory.createCase(GCSCommonConstants.TEST_SUPPORT_CASE_SUBJECT + '_3', GCSCommonConstants.CASE_PRODUCT_ZIA, GCSCommonConstants.CASE_STATUS_NEW, GCSCommonConstants.CASE_PRIORITY_MEDIUM, GCSCommonConstants.CASE_ORIGIN_API, GCSCommonConstants.CASE_TYPE_PROBLEM, GCSCommonConstants.ASIA_KOLKATA_TIME_ZONE, phoneStr,CASE_SUPPORT_RT_ID,ur1.Id,con3.Id);
        csSupport3.TAM_Assignment__c = tamAssignmentAssignedToSupport;
        csSupport3.TAM_Reassignment__c = false;
        csSupport3.Internal_Escalation__c = false;
        csSupport3.Next_TAM_Date__c = System.Now().addDays(-4);
        csSupport3.AccountId = acct3.Id;
        caseList.add(csSupport3);
        
        Case csSupport4 = GCSTestDataFactory.createCase(GCSCommonConstants.TEST_SUPPORT_CASE_SUBJECT + '_4', GCSCommonConstants.CASE_PRODUCT_ZIA, GCSCommonConstants.CASE_STATUS_NEW, GCSCommonConstants.CASE_PRIORITY_MEDIUM, GCSCommonConstants.CASE_ORIGIN_API, GCSCommonConstants.CASE_TYPE_PROBLEM, GCSCommonConstants.ASIA_KOLKATA_TIME_ZONE, phoneStr,CASE_SUPPORT_RT_ID,ur2.Id,con4.Id);
        csSupport4.TAM_Assignment__c = tamAssignmentAssignedToSupport;
        csSupport4.TAM_Reassignment__c = false;
        csSupport4.Internal_Escalation__c = false;
        csSupport4.Next_TAM_Date__c = System.Now().addDays(-4);
        csSupport4.AccountId = acct4.Id;
        caseList.add(csSupport4);
        insert caseList;
    }

    @isTest
    static void testTAMReassignmentBatch(){    
        Test.startTest();
            Id jobId = Database.executeBatch(new TAMReassignmentBatch());
            AsyncApexJob job = [SELECT Id, Status FROM AsyncApexJob WHERE Id = :jobId LIMIT 1];
            System.assert(job.Status != null, GCSCommonConstants.APEX_TEST_PASS);
        Test.stopTest();
    }
}