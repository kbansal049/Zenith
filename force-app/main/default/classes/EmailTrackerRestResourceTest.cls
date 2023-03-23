@isTest
public class EmailTrackerRestResourceTest {
    @testSetup static void setup(){ 
       Email_tracker__c testemailtracker = new Email_Tracker__c(Thread_Id__c='179a2b96dag3b6fc',Email_Subject__c='test class email subject', Status__c='Completed', Email_Category__c='Decommissioning',Priority__c='Low');
       insert testemailtracker;
    }
    public static testMethod void  Test1(){
        String JSONMsg='{\"Thread_ID__c\":\"179a2b96daf3b5fc\",\"Message_Id__c\":\"<CAOVTAbBqFaqo4kz3KiLdSZDRworj_DHH-=_NJfnD+EYFKJFjHQ@mail.gmail.com>\",\"From__c\":\"viplava.rao@zscaler.com\",\"To__c\":\"ltauro@zscaler.com\",\"CC__c\":\"\",\"BCC__c\":\"\",\"Email_Subject__c\":\"PO-44000079962030342Sunbelt Rentals, Inc.\",\"Attachments\":[{\"Body\":\"JVBERi0xLj\",\"ContentType\":\"imagepdf\",\"Name\":\"PO-44000079962030342.pdf\"}],\"Body__c\":\"c2RzZg==\"}';
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = 'https://zscaler--apttus.my.salesforce.com/services/apexrest/EmailTracker'; 
        req.httpMethod = 'Post';
        req.addHeader('Content-Type', 'application/json'); 
        req.requestBody = Blob.valueof(JSONMsg);
        RestContext.request = req;
        RestContext.response = res; 
        Test.startTest();
        EmailTrackerRestResource.createEmailTrackerAndMailChain();
        EmailTrackerRestResource.parseEmailbody(JSONMsg);
        Test.stopTest();  
    }
     public static testMethod void  Test2(){
        String JSONMsg='{\"Thread_ID__c\":\"179a2b96dag3b6fc\",\"Message_Id__c\":\"<CAOVTAbBqFaqo4kz3KiLdSZDRworj_DHH-=_NJfnD+EYFKJFjHQ@mail.gmail.com>\",\"From__c\":\"viplava.rao@zscaler.com\",\"To__c\":\"ltauro@zscaler.com\",\"CC__c\":\"\",\"BCC__c\":\"\",\"Email_Subject__c\":\"PO-44000079962030342Sunbelt Rentals, Inc.\",\"Attachments\":[{\"Body\":\"JVBERi0xLj\",\"ContentType\":\"imagepdf\",\"Name\":\"PO-44000079962030342.pdf\"}],\"Body__c\":\"c2RzZg==e\"}';
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = 'https://zscaler--apttus.my.salesforce.com/services/apexrest/EmailTracker'; 
        req.httpMethod = 'Post';
        req.addHeader('Content-Type', 'application/json'); 
        req.requestBody = Blob.valueof(JSONMsg);
        RestContext.request = req;
        RestContext.response = res; 
        Test.startTest();
             EmailTrackerRestResource.createEmailTrackerAndMailChain();
        Test.stopTest();  
    }
}