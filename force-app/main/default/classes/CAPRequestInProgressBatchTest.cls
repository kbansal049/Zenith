@isTest
public class CAPRequestInProgressBatchTest {
    @TestSetup
    static void setupTestData(){
        Id accountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('End_User_Customer_DS_Reviewed').getRecordTypeId();
        Account acct = GCSTestDataFactory.createAccount(GCSCommonConstants.TEST_ACCOUNT_NAME, GCSCommonConstants.ACCOUNT_TYPE_CUSTOMER, accountRecordTypeId);
        insert acct;

        Contact con = GCSTestDataFactory.createContact(GCSCommonConstants.TEST_CONTACT_LAST_NAME, GCSCommonConstants.TEST_CONTACT_FIRST_NAME, acct.Id, GCSCommonConstants.TEST_USER_EMAIL);
        insert con;

        List<CAP_Request__c> capRequestList = new List<CAP_Request__c>();
        CAP_Request__c cap1 = GCSTestDataFactory.createCAPRequests(acct.Id, 'In Progress','Level 3',false);
        cap1.Customer_Main_POC_for_Communication__c = con.Id;
        cap1.CAP_Manager__c = UserInfo.getUserId();
        cap1.In_Progress_Updates_Missed__c = false;
        cap1.Next_In_Progress_Update__c = System.Today().addDays(-7);
        capRequestList.add(cap1);

        CAP_Request__c cap2 = GCSTestDataFactory.createCAPRequests(acct.Id, 'In Progress','Level 3',false);
        cap2.Customer_Main_POC_for_Communication__c = con.Id;
        cap2.CAP_Manager__c = UserInfo.getUserId();
        cap2.In_Progress_Updates_Missed__c = false;
        cap2.Next_In_Progress_Update__c = System.Today().addDays(-7);
        cap2.Progress_Update_Frequency__c = 'Weekly';
        capRequestList.add(cap2);
        insert capRequestList;
    }

    @isTest
    static void testCAPRequestInProgressBatch(){
        Test.StartTest();
            Id jobId = Database.executeBatch(new CAPRequestInProgressBatch());
            AsyncApexJob job = [SELECT Id, Status FROM AsyncApexJob WHERE Id = :jobId LIMIT 1];
            System.assert(job.Status != null, GCSCommonConstants.APEX_TEST_PASS);
        Test.StopTest();
    }
}