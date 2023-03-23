@isTest
public class CAPRequestRaiseForCAPCallBatchTest {
    @TestSetup
    static void setupTestData(){
        Id accountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('End_User_Customer_DS_Reviewed').getRecordTypeId();
        Account acct = GCSTestDataFactory.createAccount(GCSCommonConstants.TEST_ACCOUNT_NAME, GCSCommonConstants.ACCOUNT_TYPE_CUSTOMER, accountRecordTypeId);
        insert acct;
        
        CAP_Request__c cap = GCSTestDataFactory.createCAPRequests(acct.Id, 'In Progress','Level 3',false);
        cap.Last_Current_Status_Update__c = System.Today().addDays(-10);
        insert cap;
    }

    @IsTest
    Static void testCAPRequestRaiseForCAPCallBatch(){
        Test.StartTest();            
            Id jobId= Database.executeBatch(new CAPRequestRaiseForCAPCallBatch());
            AsyncApexJob job = [SELECT Id, Status FROM AsyncApexJob WHERE Id = :jobId LIMIT 1];
            System.assert(job.Status != null, GCSCommonConstants.APEX_TEST_PASS);
        Test.StopTest();
    }
}