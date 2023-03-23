@IsTest
public class EmailNotificationCaseInSupportTest {
    public static testMethod void EmailNotificationCaseInTest(){
        Id supportQueueId = [SELECT Id FROM Group where type = 'Queue'  and DeveloperName = 'Support_Queue'].Id;
        Customer_Portal_Session_Id__c customsetting=new Customer_Portal_Session_Id__c();
        insert customsetting;
        Contact ct = new Contact();
        ct.LastName = 'sfsa';
        ct.Email = 'test@test.com';
        insert ct;
        List<Case> casList = new List<Case>();
        Case cs = new Case();
        cs.ContactId = ct.Id;
        cs.Status = 'New';
        cs.Case_Category__c = 'Apis';
        cs.Subject = 'jhsdkv';
        cs.Case_Assign_to_Support_Queue__c = datetime.now();
        cs.OwnerId =supportQueueId;
        casList.add(cs);
        Case cs1 = new Case();
        cs1.ContactId = ct.Id;
        cs1.Status = 'New';
        cs1.Case_Category__c = 'Apis';
        cs1.Subject = 'jhsdkv';
        cs1.Case_Assign_to_Support_Queue__c = datetime.now().addMinutes(15);
        cs1.OwnerId =supportQueueId;
        casList.add(cs1);
        Case cs2 = new Case();
        cs2.ContactId = ct.Id;
        cs2.Status = 'New';
        cs2.Case_Category__c = 'Apis';
        cs2.Subject = 'jhsdkv';
        cs2.Case_Assign_to_Support_Queue__c = datetime.now().addMinutes(-5);
        cs2.OwnerId =supportQueueId;
        casList.add(cs2);
        Case cs3 = new Case();
        cs3.ContactId = ct.Id;
        cs3.Status = 'New';
        cs3.Case_Category__c = 'Apis';
        cs3.Subject = 'jhsdkv';
        cs3.Case_Assign_to_Support_Queue__c = datetime.now().addMinutes(-19);
        cs3.OwnerId =supportQueueId;
        casList.add(cs3);
        Case cs4 = new Case();
        cs4.ContactId = ct.Id;
        cs4.Status = 'New';
        cs4.Case_Category__c = 'Apis';
        cs4.Subject = 'jhsdkv';
        cs4.Case_Assign_to_Support_Queue__c = datetime.now().addMinutes(-19);
        cs4.OwnerId =supportQueueId;
        casList.add(cs4);
        Case cs5 = new Case();
        cs5.ContactId = ct.Id;
        cs5.Status = 'New';
        cs5.Case_Category__c = 'Apis';
        cs5.Subject = 'jhsdkv';
        cs5.Case_Assign_to_Support_Queue__c = datetime.now().addMinutes(-30);
        cs5.OwnerId =supportQueueId;
        casList.add(cs5);

        
        insert casList;
        
        for(Case c :casList)  {
            c.Case_Assign_to_Support_Queue__c = datetime.now().addMinutes(-6);
        }
        update casList;
        test.startTest();
        EmailNotificationCaseInSupport m = new EmailNotificationCaseInSupport();
        String sch = '0 36 1 * * ?';
        String jobID = system.schedule('test update ter  tasks 1', sch, m);
        test.stopTest();
    }
}