@isTest
public class BookMeetingSchedulerControllerTest {
    @testSetup static void setup() {
        //User
        User sysUser = TestDatafactory_Zscaler.insertAdminUser('puser000@amamama.com', 'Admin', 'System', 'alias', 'puser000@amamama.com' + System.currentTimeMillis(), 
                        'America/Los_Angeles', 'en_US', 'UTF-8', 'en_US');
        //Account
        String accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('End_User_Customer_DS_Reviewed').getRecordTypeId();
        Account accObj = TestDatafactory_Zscaler.insertAccount('Test Account', null, 'Customer', accRecordTypeId, null, 300);

        //Case
        String caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Support').getRecordTypeId();
        Case cs = TestDatafactory_Zscaler.insertCase('New', 'Test Subject', 'Test Commment',accObj.Id , null, null, caseRecordTypeId);
        cs.Product_New__c = 'ZIA';
        cs.Case_Type__c = 'Problem';
        cs.Internal_Escalation__c = true;
        cs.Priority = 'Urgent (P1)';
        Update cs;

        //User Skill
        User us = new User();
        us.Id = UserInfo.getUserid();
        us.Skills__c = 'CS';

        Update us;

        //Service Resource
        ServiceResource resource = TestDatafactory_Zscaler.insertServiceResource('Agent x', sysUser.Id, 1, 5, 0, 0, 0, 'Frontline');
        resource.IsActive = true;
        Update resource;

        //Support Meeting
        DateTime schedStartTime = System.now().addDays(1);
        DateTime schedEndTime = schedStartTime.addMinutes(60);
        DateTime dueDate = System.now().addDays(1);
        DateTime earliestStartTime = System.now();

        ServiceAppointment meeting = TestDatafactory_Zscaler.insertServiceAppointment(cs.Id,schedStartTime,schedEndTime,dueDate,earliestStartTime);    

        //AssignedResource
        TestDatafactory_Zscaler.insertAssignedResource(meeting.Id, resource.Id);

        //Resource Absence
        DateTime startTime = System.now();
        DateTime endTime = System.now().addDays(2);
        TestDatafactory_Zscaler.insertResourceAbsence(resource.Id,startTime,endTime,'Vacation');

        DateTime startTime2 = System.now().addDays(4);
        DateTime endTime2 = System.now().addDays(7);
        TestDatafactory_Zscaler.insertResourceAbsence(resource.Id,startTime2,endTime2,'Vacation');
    }

    @isTest
    static void testBookMeeting(){
        Case cs = [SELECT Id, AccountId,Internal_Escalation__c,priority,Case_Type__c,case_source__c,Case_Category__c,Case_Support_Type__c,Customer_Segment__c ,Product_New__c
                    FROM Case LIMIT 1];
        List<ResourceAbsence> absenceList = [SELECT Id,Start,End,Type,ResourceId FROM ResourceAbsence];
        
        Test.startTest();
            BookMeetingSchedulerController.getDetails(cs.Id);
            BookMeetingSchedulerController.setSlackTemplate(absenceList);
        Test.stopTest();
    }

    @isTest
    static void testBookMeeting2(){
        Case cs = [SELECT Id, AccountId,Internal_Escalation__c,priority,Case_Type__c,case_source__c,Case_Category__c,Case_Support_Type__c,Customer_Segment__c ,Product_New__c
                    FROM Case LIMIT 1];
        List<ResourceAbsence> absenceList = [SELECT Id,Start,End,Type,ResourceId FROM ResourceAbsence where start >: System.now()];
        
        Test.startTest();
            BookMeetingSchedulerController.getDetails(cs.Id);
            BookMeetingSchedulerController.setSlackTemplate(absenceList);
        Test.stopTest();
    }

    @isTest
    static void testBookMeetingException(){
        List<ResourceAbsence> absenceList = [SELECT Id, Start, End, Type FROM ResourceAbsence];
        
        Test.startTest();
            BookMeetingSchedulerController.getDetails('testException');
            BookMeetingSchedulerController.setSupportType(null);
            BookMeetingSchedulerController.setSlackTemplate(absenceList);
        Test.stopTest();
    }
}