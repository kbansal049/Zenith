/**
 * Name : CAPRequestCmpCtrlTest
 * Description : Test Class of CAPRequestCmpCtrl
 */

@isTest
public class CAPRequestCmpCtrlTest {
    
    @testSetup
    static void setup() {
        List<CAP_Request__c> capRequestList = new List<CAP_Request__c>();
        Account acc = new Account(Name='Test Account');
        insert acc;
        capRequestList.add(new CAP_Request__c(Account__c = acc.id));
        insert capRequestList;
    }

    @isTest
    static void getCapRequestStatus_test() {
        CAP_Request__c cap = [SELECT id,Name,account__c FROM CAP_Request__c LIMIT 1];
        CAPRequestCmpCtrl.getCapRequestStatus(cap.id);
    }

    @isTest
    static void getCapRequestAccountDetails_test(){
        CAP_Request__c cap = [SELECT id,Name,account__c FROM CAP_Request__c LIMIT 1];
        CAPRequestCmpCtrl.getCapRequestAccountDetails(cap.account__c);
    }

    @isTest
    static void getDailyNotesData_test(){
        CAP_Request__c cap = [SELECT id,Name,account__c,next_steps__c,current_Status__c FROM CAP_Request__c LIMIT 1];
        cap.next_steps__c = 'Test Next Steps';
        cap.current_Status__c = 'Test Current Status';
        update cap;
        CAPRequestCmpCtrl.getDailyNotesData(cap.id);
    }

    @isTest
    static void getPageLayoutFields_test(){
        CAP_Request__c cap = [SELECT id,Name,account__c,next_steps__c,current_Status__c FROM CAP_Request__c LIMIT 1];
        CAPRequestCmpCtrl.getPageLayoutFields('New',cap.id);
        CAPRequestCmpCtrl.getPageLayoutFields('New','');
    }

    @isTest
    static void getStatusPicklistValue_test(){
        CAPRequestCmpCtrl.getStatusPicklistValue();
    }

    @isTest
    static void approvalProcess_test(){
        CAP_Request__c cap = [SELECT id,Name,account__c,next_steps__c,current_Status__c FROM CAP_Request__c LIMIT 1];
        CAPRequestCmpCtrl.submitForApproval(cap.id,'');
        System.assert([SELECT id,status__c FROM CAP_Request__c WHERE id =: cap.id].status__c == 'Submitted', 'Status must be submitted after submit for approval');
        CAPRequestCmpCtrl.handleCAPApproval(cap.id,'Approve','Test');
        System.assert([SELECT id,status__c FROM CAP_Request__c WHERE id =: cap.id].status__c == 'Planning', 'Status must be Planning after approval');
    }

    @isTest
    static void CAPSetStatus_test(){
        CAP_Request__c cap = [SELECT id,Name,account__c,next_steps__c,current_Status__c FROM CAP_Request__c LIMIT 1];
        CAPRequestCmpCtrl.CAPSetStatus(cap.id, 'Closed');
        System.assert([SELECT id,status__c FROM CAP_Request__c WHERE id =: cap.id].status__c == 'Closed', 'Status must be Clsoed');
    }
    
    @isTest
    static void setApprovalFlag_test(){
        CAP_Request__c cap = [SELECT id,Name,account__c,next_steps__c,current_Status__c FROM CAP_Request__c LIMIT 1];
        CAPRequestCmpCtrl.setApprovalFlag(cap.id);
    }
    
    @isTest
    static void checkIfUserCanApprove_test(){
        CAP_Request__c cap = [SELECT id,Name,account__c,next_steps__c,current_Status__c FROM CAP_Request__c LIMIT 1];
        CAPRequestCmpCtrl.checkIfUserCanApprove(UserInfo.getUserId(),cap.id);
    }

    /*@isTest
    static void checkIfUserCanSubmit_test(){
        CAPRequestCmpCtrl.checkIfUserCanSubmit(UserInfo.getUserId());
    }*/
    @isTest
    static void handleCAPRejection_test(){
        List<CAP_Request__c> cap = new List<CAP_Request__c>([SELECT id,Name,account__c,next_steps__c,current_Status__c FROM CAP_Request__c LIMIT 1]);
        CAPRequestCmpCtrl.handleCAPRejection(new List<String>{cap.get(0).id});  
    }
}