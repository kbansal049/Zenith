@isTest
public class TamMeetingCompletedUpdateBatchTest {
	@isTest 
    public static void testBatch()
    {
        Account account = new Account(Name = 'Test Account');
        insert account;
        
        Meeting__c meet = new Meeting__c();
        meet.Customer_Name__c = account.Id;
        meet.Date_of_meeting__c = System.now();
        meet.Status__c = 'Scheduled'; 
        meet.Executive_Summary__c = 'Test';
        meet.Name = 'Meeting';
        insert meet;
        
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Meeting - Test Account.pdf';
        cv.PathOnClient = 'Meeting - Test Account.pdf';
        cv.VersionData = Blob.valueOf('Test Content');
        cv.IsMajorVersion = true;
        Insert cv;
        
        List<ContentVersion> conDoc = [select id, ContentDocumentId from ContentVersion where id=:cv.Id limit 1];
        ContentDocumentLink conDocLink = new ContentDocumentLink();
        conDocLink.LinkedEntityId = meet.Id;
        conDocLink.ContentDocumentId = conDoc[0].ContentDocumentId;
        insert conDocLink; 
        
        Test.startTest();
        TamMeetingUpdateHandler.updateTAMMeetingStatus();
        Test.stopTest();
    }
}