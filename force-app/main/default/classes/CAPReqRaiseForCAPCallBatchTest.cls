@IsTest
public with sharing class CAPReqRaiseForCAPCallBatchTest {
    @TestSetup
    static void makeTestData(){
        List<CAP_Request__c> capRequestList = new List<CAP_Request__c>();
        Account acc = new Account(Name='Test Account');
        insert acc;
        capRequestList.add(new CAP_Request__c(Account__c = acc.id));
        insert capRequestList;

        capRequestList[0].Last_Current_Status_Update__c = DateTime.now().addDays(-8);
        capRequestList[0].Raise_for_CAP_Call__c = False;
        Update capRequestList;
    }

    @IsTest
    Static void testRaiseForCallBatch(){
        Test.StartTest();            
            Database.executeBatch(new CAPRequestRaiseForCAPCallBatch());
			CAPRequestRaiseForCAPCallBatch.logError('test');
        Test.StopTest();
    }
}