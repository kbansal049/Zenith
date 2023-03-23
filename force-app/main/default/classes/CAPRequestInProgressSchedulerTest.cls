@isTest
public class CAPRequestInProgressSchedulerTest {
    
    @testSetup static void setup(){
        List<CAP_Request__c> capRequestList = new List<CAP_Request__c>();
        Account acc = new Account(Name='Test Account');
        insert acc;
        Contact con = new Contact(AccountId= acc.id,FirstName= 'Test', LastName='Contact', email='abhatnagar@zscaler.com');
        insert con;
        for(Integer i=0; i<10; i++) {
            capRequestList.add(new CAP_Request__c(Account__c = acc.id,Customer_Main_POC_for_Communication__c=con.id, CAP_Manager__c = UserInfo.getUserId()));
        }
        insert capRequestList;
    }

    @isTest
    static void test(){
        List<CAP_Request__c> capRequests = new List<CAP_Request__c>([SELECT id,Next_Steps__c, Current_Status__c FROM CAP_Request__c]);
        for(CAP_Request__c cap : capRequests) {
            cap.Status__c = 'In Progress';
        }
        update capRequests;
        CAPRequestInProgressScheduler sch = new CAPRequestInProgressScheduler();
        SchedulableContext sc = null;
        sch.execute(sc);
    }
}