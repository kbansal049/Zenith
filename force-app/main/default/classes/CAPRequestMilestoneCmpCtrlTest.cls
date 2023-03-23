/**
 * Name : CAPRequestMilestoneCmpCtrlTest
 * Added by : Ankit Bhatnagar
 * Description : Test Class of CAPRequestMilestoneCmpCtrl
 */

@isTest
public class CAPRequestMilestoneCmpCtrlTest {
    
    @testSetup
    static void setup() {
        List<CAP_Request__c> capRequestList = new List<CAP_Request__c>();
        Account acc = new Account(Name='Test Account');
        insert acc;
        Contact con = new Contact(AccountId= acc.id,FirstName= 'Test', LastName='Contact', email='abhatnagar@zscaler.com');
        insert con;
        for(Integer i=0; i<10; i++) {
            capRequestList.add(new CAP_Request__c(Account__c = acc.id,Customer_Main_POC_for_Communication__c=con.id));
        }
        insert capRequestList;
    }

    @isTest
    public static void getMilestoneRecords_Test() {
        List<CAP_Request__c> capRequests = new List<CAP_Request__c>([SELECT id,Next_Steps__c, Current_Status__c FROM CAP_Request__c]);
        for(CAP_Request__c cap : capRequests) {
            cap.Status__c = 'Post Mortem';
        }
        update capRequests;
        CAPRequestMilestoneCmpCtrl.getMilestoneRecords(capRequests.get(0).id);
    }
}