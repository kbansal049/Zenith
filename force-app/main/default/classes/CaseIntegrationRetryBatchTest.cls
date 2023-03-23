@isTest
public class CaseIntegrationRetryBatchTest {
    @isTest 
    public static void Test(){
        Case_Integration__c ci=new Case_Integration__c();
        ci.Case_Creation_Status__c='Failure';
        ci.Retry_Counter__c = 2;
        ci.Incident_Type__c=  'Categorization';
        ci.Assignment_Group__c = 'no cloud - site review';
        ci.Case_Origin__c = 'Sitereview';
        ci.Category_ID__c = 'test';
        ci.SubCategory_ID__c = 'ZIA';
        ci.SubSubCategory_ID__c = 'test';
        ci.Short_Description__c = 'Test Subject';
        ci.Detailed_Description__c = 'Test Description';
        ci.Severity__c = 'Low (P4)';
        insert ci;
        Test.startTest();
        CaseIntegrationRetryBatch.createCsvAttachmentAndSendEmail(new List<Case_Integration__c>{ci});
        Database.executeBatch(new CaseIntegrationRetryBatch(), 1);
        Test.stopTest();
    }
}