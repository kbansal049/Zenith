@istest
public class OrderTrackerRestResourceTest {
    
    
    @testSetup static void setup()
    {
        Customers__c customers = new Customers__c();
        customers.Name='test custom setting';
        customers.Latest_Number__c=0;
        insert customers;
        
        Order_tracker__c testordertracker = new Order_Tracker__c(Thread_ID__c='179a2b96dag3b6fc',Email_Subject__c='test class email subject', Status__c='PO Pending for QR', Region__c='EMEA', 
                                                                 Order_Type__c='New', End_User__c='Test class end user',PO__c='Q-1234');
        insert testordertracker;
        
    }
    public static testMethod void  Test1(){
        String JSONMsg='{\"Thread_ID__c\":\"179a2b96daf3b6fc\",\"Message_Id__c\":\"<CAOVTAbBqFaqo4kz3KiLdSZDRworj_DHHNJfnD+EYFKJFjHQ@mail.gmail.com>\",\"From__c\":\"viplava.rao@zscaler.com\",\"To__c\":\"ltauro@zscaler.com\",\"CC__c\":\"\",\"BCC__c\":\"\",\"Email_Subject__c\":\"0342Sunb\",\"Proposal_for_initiating_QC__c\":\"Q-00195255\",\"Order_Type__c\":\"New\",\"Attachments\":[{\"Body\":\"JVBERi0xLjMKJdLIKMxLWMdv+SgQhWmsKyQ=\",\"ContentType\":\"imagepdf\",\"Name\":\"po1.pdf\"}],\"Body__c\":\"c2RzZg==\"}';
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = 'https://zscaler--apttus.my.salesforce.com/services/apexrest/OrderTracker'; 
        req.httpMethod = 'Post';
        req.addHeader('Content-Type', 'application/json'); 
        req.requestBody = Blob.valueof(JSONMsg);
        RestContext.request = req;
        RestContext.response = res; 
        Test.startTest();
        OrderTrackerRestResource.createOrderTrackerAndMailChain();
        Test.stopTest();  
    }
    public static testMethod void  Test2(){
        String JSONMsg='{\"Thread_ID__c\":\"179a2b96dag3b6fc\",\"Message_Id__c\":\"<CAOVTAbBqFaqo4kz3KiLdSZDRworj_DHHNJfnD+EYFKJFjHQ@mail.gmail.com>\",\"From__c\":\"viplava.rao@zscaler.com\",\"To__c\":\"ltauro@zscaler.com\",\"CC__c\":\"\",\"BCC__c\":\"\",\"Email_Subject__c\":\"0342Sunb\",\"Proposal_for_initiating_QC__c\":\"Q-00195255\",\"Order_Type__c\":\"New\",\"Attachments\":[{\"Body\":\"JVBERi0xLjMKJdLIKMxLWMdv+SgQhWmsKyQ=\",\"ContentType\":\"imagepdf\",\"Name\":\"po1.pdf\"}],\"Body__c\":\"c2RzZg==\"}';
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = 'https://zscaler--apttus.my.salesforce.com/services/apexrest/OrderTracker'; 
        req.httpMethod = 'Post';
        req.addHeader('Content-Type', 'application/json'); 
        req.requestBody = Blob.valueof(JSONMsg);
        RestContext.request = req;
        RestContext.response = res; 
        Test.startTest();
        OrderTrackerRestResource.createOrderTrackerAndMailChain();
        Test.stopTest();  
    }
    public static testMethod void  Test3(){
        Order_tracker__c testordertracker =[Select Id,Thread_ID__c from order_tracker__c limit 1 ];
        String JSONMsg='{\"Thread_ID__c\":\"' + testordertracker.Thread_ID__c +'\",\"Message_Id__c\":\"<CAOVTAbBqFaqo4kz3KiLdSZDRworj_DHH-=_NJfnD+EYFKJFjHQ@mail.gmail.com>\",\"From__c\":\"viplava.rao@zscaler.com\",\"To__c\":\"ltauro@zscaler.com\",\"CC__c\":\"\",\"BOT_Auto_QC_Done__c\":\"Yes\",\"Email_Subject__c\":\"0342Sunb\",\"Proposal_for_initiating_QC__c\":\"Q-00195255\",\"Order_Type__c\":\"New\",\"Attachments\":[{\"Body\":\"JVBERi0xLjMKJdLIKMxLWMdv+SgQhWmsKyQ=\",\"ContentType\":\"imagepdf\",\"Name\":\"po1.pdf\"}]}';
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = 'https://zscaler--apttus.my.salesforce.com/services/apexrest/OrderTracker'; 
        req.httpMethod = 'Put';
        req.addHeader('Content-Type', 'application/json'); 
        req.requestBody = Blob.valueof(JSONMsg);
        RestContext.request = req;
        RestContext.response = res; 
        Test.startTest();
        OrderTrackerRestResource.updateOrderTrackerAndMailChain();
        Test.stopTest();  
    }
    
    
}