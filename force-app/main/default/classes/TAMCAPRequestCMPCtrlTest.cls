/**
 * Name : TAMCAPRequestCMPCtrlTest
 * Description : Test Class of TAMCAPRequestCMPCtrl
 */

@isTest
public class TAMCAPRequestCMPCtrlTest {

    @isTest 
    static void test_Method() {
        List<CAP_Request__c> capRequestList = new List<CAP_Request__c>();
        Account acc = new Account(Name='Test Account');
        insert acc;
        capRequestList.add(new CAP_Request__c(Account__c = acc.id));
        insert capRequestList;
        TAMCAPRequestCMPCtrl cons = new TAMCAPRequestCMPCtrl();
        TAMCAPRequestCmpCtrl.getCAPRequestData(acc.id);
    }
}