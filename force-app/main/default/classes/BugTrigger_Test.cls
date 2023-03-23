@IsTest
public class BugTrigger_Test {
    
    @isTest
    static void createUserStryFromBugs(){
        
        List<Triggers_Switch__c> trlst = new List<Triggers_Switch__c>();
        trlst.add(new Triggers_Switch__c(name = 'Execute_CR_Bug_Update', Execute__c = true));
        trlst.add(new Triggers_Switch__c(name = 'Execute_CreateUserStoryfromCR', Execute__c = true));
        insert trlst;
        Id caseSalesRT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Sales').getRecordTypeId();
        Case cs = new Case(Subject='abcd', Priority='Urgent (P1)', RecordTypeId=caseSalesRT, Description='abcdDes', Case_type__c = 'Problem');
        insert cs;
        
        
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User user1 = new User(LastName = 'test',
                              FirstName='test',
                              Alias = 'alias',
                              Email = 'testCR@testCR.com',
                              Username = 'userNameCR@testCR.com',
                              ProfileId = profileId.id,
                              TimeZoneSidKey = 'America/Los_Angeles',
                              EmailEncodingKey = 'UTF-8',
                              LanguageLocaleKey = 'en_US',
                              LocaleSidKey = 'en_US'
                             );
        insert user1;
        copado__Org__c cUser = new copado__Org__c();
        cUser.OwnerId =user1.id;
        insert cUser;
        
        Tracker_Change_Request__c cr = new Tracker_Change_Request__c();
        cr.Assignee__c = UserInfo.getUserId();
        cr.Stage__c = 'Backlog';
        cr.Type__c = 'Issue/Bug';
        cr.Priority__c = 'Critical';
        cr.Business_Analyst__c = UserInfo.getUserId();
        cr.Summary__c = cs.Subject;
        cr.Description__c = cs.Description;
        cr.Case__c = cs.Id;
        
        cr.Business_Analyst__c = user1.id;
        Test.startTest();
        insert cr;
        
        
        Tracker_Release__c  rl = new Tracker_Release__c ();
        rl.name = 'test';
        rl.Release_Date__c  = system.today();
        insert rl;
        
        cr.Stage__c = 'Development';
        cr.Status__c = 'In Dev';
        cr.Developer__c = user1.Id;
        cr.QA__c = user1.Id;
        cr.Release__c = rl.Id;
        cr.Dev_Estimated_Efforts__c = 10;
        update cr;
        
        Bug__c newBug = new bug__c();
        newBug.Assignee__c = user1.Id;
        newBug.Change_Request__c = cr.id;
        newBug.Status__c = 'Work In Progress';
        newBug.Type__c = 'Bug';
        newBug.Environment__c = 'QA';
        insert newBug;
        newBug.Environment__c = 'UAT';
        update newBug;
        
        Test.stopTest();
    }
}