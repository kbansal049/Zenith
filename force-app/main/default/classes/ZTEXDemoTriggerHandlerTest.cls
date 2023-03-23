@isTest
public class ZTEXDemoTriggerHandlerTest {
    
    @isTest
    static void testInsertFlow(){
        
        ZTEX_Demo_Env__c zde = new ZTEX_Demo_Env__c();
        zde.Request_Date__c = System.today();
        zde.Requestor_Email__c = 'abc@pqr.com';
        zde.Request_Status__c = 'Requested';
        zde.User_Name__c = Userinfo.getUserId();
        
        Test.startTest();
        insert zde;
        Test.stopTest();
    }
    
    @isTest
    static void testUpdateFlow(){
        
        ZTEX_Demo_Env__c zde = new ZTEX_Demo_Env__c();
        zde.Request_Date__c = System.today();
        zde.Requestor_Email__c = 'abc@pqr.com';
        zde.Request_Status__c = null;
        zde.User_Name__c = Userinfo.getUserId();
        insert zde;
        
        Test.startTest();
        zde.Request_Status__c = 'Requested';
        update zde;
        Test.stopTest();
    }
    
}