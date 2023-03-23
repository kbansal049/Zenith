@isTest
public class getMailChainDataTest {
    
    @testSetup static void setup()
    {
        Customers__c customers = new Customers__c();
        customers.Name='test custom setting';
        customers.Latest_Number__c=0;
        insert customers;
        Order_tracker__c testordertracker = new Order_Tracker__c(Email_Subject__c='test class email subject', Status__c='PO Pending for QR', Region__c='EMEA', 
                                                                 Order_Type__c='New', End_User__c='Test class end user');
        insert testordertracker;
        
        Email_tracker__c testemailtracker = new Email_Tracker__c(Email_Subject__c='test class email subject', Status__c='Completed', Email_Category__c='Decommissioning',Priority__c='Low');
        insert testemailtracker;
        Mail_Chain__c testmailchain1 = new Mail_chain__c(Email_Subject__c='test class email subject',to__c='test@gmail.com',cc__c='test@gmail.com',order_tracker__c = testordertracker.id);
        insert testmailchain1;
        Mail_Chain__c testmailchain2 = new Mail_chain__c(Email_Subject__c='test class email subject',to__c='test@gmail.com',cc__c='test@gmail.com',email_tracker__c = testemailtracker.id);
        insert testmailchain2;
    	List<ContentVersion> conVersionList = new List<ContentVersion>();
        ContentVersion contentVersionFile1 = new ContentVersion();
        contentVersionFile1.ContentLocation = 'S';
        contentVersionFile1.FirstPublishLocationId=testmailchain1.Id;
        contentVersionFile1.PathOnClient =  'po1.pdf'; 
        contentVersionFile1.Title = 'po1.pdf'; 
        contentVersionFile1.VersionData = Blob.valueOf('JVBERi0xLjMKJdLIKMxLWMdv+SgQhWmsKyQ=');
        conVersionList.add(contentVersionFile1); 
        ContentVersion contentVersionFile2 = new ContentVersion();
        contentVersionFile2.ContentLocation = 'S';
        contentVersionFile2.FirstPublishLocationId=testmailchain2.Id;
        contentVersionFile2.PathOnClient =  'po1.pdf'; 
        contentVersionFile2.Title = 'po1.pdf'; 
        contentVersionFile2.VersionData = Blob.valueOf('JVBERi0xLjMKJdLIKMxLWMdv+SgQhWmsKyQ=');
        conVersionList.add(contentVersionFile2); 
        insert conVersionList;
        
    }
    @isTest 
    static void method1() 
    {
        Order_tracker__c testordertracker = [select id from Order_tracker__c limit 1];
        Email_tracker__c testemailtracker = [select id from Email_tracker__c limit 1];
        Mail_Chain__c testmailchain1 = [select id from mail_chain__c where Order_tracker__c =:testordertracker.id]; 
        Mail_Chain__c testmailchain2 =[select id from mail_chain__c where Email_tracker__c =:testemailtracker.id];
        
        test.startTest();
        getMailChainData.getMainChainTableData(testordertracker.Id,'orderTracker');
        getMailChainData.getMainChainTableData(testemailtracker.Id,'emailTracker');
        getMailChainData.convertTracker('orderTracker', testordertracker.Id);
        String isSuccess = getMailChainData.convertToOrderTracker('emailTracker', testemailtracker.Id,'Test','');
        system.assertEquals('true', isSuccess);
        test.stopTest();
    }
}