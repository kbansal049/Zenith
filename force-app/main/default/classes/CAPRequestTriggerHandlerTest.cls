/**
 * Name : CAPRequestTriggerHandlerTest
 * Description : Test Class of CAPRequestTrigger and CAPRequestTriggerHandler
 */

@isTest
public class CAPRequestTriggerHandlerTest {
    
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
    public static void insertCAPRequestInteractions_Test() {
        List<CAP_Request__c> capRequests = new List<CAP_Request__c>([SELECT id,Next_Steps__c, Current_Status__c FROM CAP_Request__c]);
        for(CAP_Request__c cap : capRequests) {
            cap.Current_Status__c = 'Test';
            cap.send_Customer_email_Update__c = true;
            cap.Raise_for_CAP_Call__c = true;
        }
        update capRequests;
        List<CAP_Request_Interaction__c> capInteractions = new List<CAP_Request_Interaction__c>([SELECT id FROM CAP_Request_Interaction__c]);
        //System.assert(capInteractions.size() == 10, 'CAP Interactions were not inserted successfully');
        CapRequestTriggerHandler.isErrorRaiseForCAPCall();
    }
    
    @isTest
    public static void capNotifications_Test() {
        List<CAP_Request__c> capRequests = new List<CAP_Request__c>([SELECT id,Next_Steps__c,status__c,resolution_Summary__c, Current_Status__c FROM CAP_Request__c Limit 1]);
        for(CAP_Request__c cap : capRequests) {
            cap.status__c = 'In Progress';
            cap.CAP_Level__c = 'Level 2';
            cap.Higher_CAP_Level_Reason__c = 'Test';
        }
        update capRequests;
        for(CAP_Request__c cap : capRequests) {
            cap.Resolution_Summary__c = 'Test';
            cap.CAP_Level__c = 'Level 2';
            cap.Higher_CAP_Level_Reason__c = 'Test';
        }
        update capRequests;   
    }
    
    @isTest
    public static void capNotifications_cap1_Test() {
        List<CAP_Request__c> capRequests = new List<CAP_Request__c>([SELECT id,Next_Steps__c,status__c,resolution_Summary__c, Current_Status__c FROM CAP_Request__c Limit 1]);
        for(CAP_Request__c cap : capRequests) {
            cap.status__c = 'In Progress';
            cap.CAP_Level__c = 'Level 1';
            cap.Higher_CAP_Level_Reason__c = 'Test';
        }
        update capRequests;
        for(CAP_Request__c cap : capRequests) {
            cap.Resolution_Summary__c = 'Test';
            cap.CAP_Level__c = 'Level 1';
            cap.Higher_CAP_Level_Reason__c = 'Test';
        }
        update capRequests;
    }
    
    @isTest
    public static void capNotifications_cap3_Test() {
        List<CAP_Request__c> capRequests = new List<CAP_Request__c>([SELECT id,Next_Steps__c,status__c,resolution_Summary__c, Current_Status__c FROM CAP_Request__c Limit 1]);
        for(CAP_Request__c cap : capRequests) {
            cap.status__c = 'In Progress';
            cap.CAP_Level__c = 'Level 3';
            cap.current_Status__c ='Test3';
        }
        update capRequests;
        for(CAP_Request__c cap : capRequests) {
            cap.Resolution_Summary__c = 'Test';
            cap.CAP_Level__c = 'Level 3';
            cap.current_Status__c ='Test2';
            cap.Status__c = 'Submitted';
        }
        update capRequests;  
        
        for(CAP_Request__c cap : capRequests) {
            cap.Resolution_Summary__c = 'Test';
            cap.CAP_Level__c = 'Level 1';
            cap.current_Status__c ='Test2';
            cap.Higher_CAP_Level_Reason__c = 'Test';
        }
        update capRequests;  

        for(CAP_Request__c cap : capRequests) {
            cap.Resolution_Summary__c = 'Test';
            cap.CAP_Level__c = 'Level 2';
            cap.current_Status__c ='Test2';
            cap.Higher_CAP_Level_Reason__c = 'Test';
        }
        update capRequests;  
    }

    @isTest
    public static void capReqUpdateTest() {
        List<CAP_Request__c> capRequests = new List<CAP_Request__c>([SELECT id,Next_Steps__c,Exec_Summary__c, Current_Status__c,Additional_Technical_Details__c,Next_In_Progress_Update__c FROM CAP_Request__c]);
        for(CAP_Request__c cap : capRequests) {
            cap.Next_Steps__c = 'Test';
            cap.send_Customer_email_Update__c = true;
            cap.Raise_for_CAP_Call__c = true;
            cap.Additional_Technical_Details__c = 'Test';
            cap.Exec_Summary__c = 'Test Summary';
            cap.Next_In_Progress_Update__c = System.now().addDays(2);
        }
        update capRequests;
    }

    @isTest
    public static void capNotifications2_Test() {
        List<CAP_Request__c> capRequests = new List<CAP_Request__c>([SELECT id,Next_Steps__c,status__c,resolution_Summary__c, Current_Status__c FROM CAP_Request__c Limit 1]);
        for(CAP_Request__c cap : capRequests) {
            cap.status__c = 'In Progress';
            cap.CAP_Level__c = 'Level 2';
            cap.Higher_CAP_Level_Reason__c = 'Test';
           // cap.next_Steps__c = 'test';
        }
        update capRequests;

        for(CAP_Request__c cap : capRequests) {
            //cap.status__c = 'In Progress';
            cap.CAP_Level__c = 'Level 1';
            cap.Higher_CAP_Level_Reason__c = 'Test';
            cap.next_Steps__c = 'test';
        }
        update capRequests;
        
    }
}