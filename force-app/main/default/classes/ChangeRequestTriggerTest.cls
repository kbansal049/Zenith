@isTest
public class ChangeRequestTriggerTest {
    
    
    
    public static testMethod void testChangeRequest(){
        List<Triggers_Switch__c> trlst = new List<Triggers_Switch__c>();
        trlst.add(new Triggers_Switch__c(name = 'Execute_Parent_CR_Update', Execute__c = true));
        trlst.add(new Triggers_Switch__c(name = 'Execute_BA_CR_Update_On_Case', Execute__c = true));
        trlst.add(new Triggers_Switch__c(name = 'Execute_Sync_BA_From_CR_To_Case', Execute__c = true));
        trlst.add(new Triggers_Switch__c(name = 'Execute_CreateUserStoryfromCR', Execute__c = true));
        //Added for CR History purpose
        trlst.add(new Triggers_Switch__c(name = 'Execute_requestChangeStatus', Execute__c = true));
        
        insert trlst;
        copado__Org__c org = new copado__Org__c();
        org.Name = 'SBDEV12';
        insert org;
        Id caseSalesRT = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Sales Operations Helpdesk').getRecordTypeId();
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
                              LocaleSidKey = 'en_US',
                              Developer_Sandbox_Name__c=org.Id
                             );
        insert user1;
        
        
        Tracker_Change_Request__c cr = new Tracker_Change_Request__c();
        cr.Assignee__c = UserInfo.getUserId();
        cr.Stage__c = 'Backlog';
        cr.Type__c = 'Issue/Bug';
        cr.Priority__c = 'Normal';
        cr.Business_Analyst__c = UserInfo.getUserId();
        cr.Summary__c = cs.Subject;
        cr.Description__c = cs.Description;
        cr.Case__c = cs.Id;
        insert cr;
        Test.startTest();
        cs.Change_Request__c = cr.id;
        cs.Business_Analyst__c = user1.Id;
        update cs;
        
        cr.Business_Analyst__c = user1.id;
        TriggerUtility.SyncBAOnCaseReset();
        update cr;
        
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
        cr.Dev_Estimated_Efforts__c = 12;
        cr.Actual_Dev_Efforts__c = 11;
        cr.Business_Analyst__c = user1.id;
        cr.Deployment_Component_Provided__c=true;
        cr.stage__c = 'Ready for Release';
        update cr;	
        

        //Covering controller for Create_CR_Component component
        String result = Create_CR_Component_Controller.checkIfCrExists(String.valueOf(cs.Id));
        String result2 = Create_CR_Component_Controller.checkIfCrExists(String.valueOf(''));
        TriggerUtility2.booster();
        Test.stopTest();
    }
    
    public static testMethod void test(){
        
        Id caseSalesRT = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Sales Operations Helpdesk').getRecordTypeId();
        Case cs = new Case(Subject='abcd', Priority='Urgent (P1)', RecordTypeId=caseSalesRT, Description='abcdDes', Case_type__c = 'Problem');
        insert cs;
        Triggers_Switch__c tc = new Triggers_Switch__c();
        tc.name = 'Execute_requestChangeStatus';
        tc.Execute__c = true;
        insert tc;
        
        Tracker_Change_Request__c cr = new Tracker_Change_Request__c();
        cr.Assignee__c = UserInfo.getUserId();
        cr.Stage__c = 'Backlog';
        cr.Type__c = 'Issue/Bug';
        cr.Priority__c = 'Normal';
        cr.Status__c = 'Cancelled';
        cr.Business_Analyst__c = UserInfo.getUserId();
        cr.Summary__c = cs.Subject;
        cr.Description__c = cs.Description;
        cr.Case__c = cs.Id;
        insert cr;
        
        Audit_Logs__c ac = new Audit_Logs__c();
        ac.Name = 'test';
        ac.Start_Date__c = Date.today();
        ac.Change_Request__c = cr.Id;
        insert ac;
        
        Test.startTest();
        cr.Status__c = 'Work In Progress';
        update cr;
        
        
    }
    public static testMethod void createCRTest(){
        
        Triggers_Switch__c tc=  new Triggers_Switch__c(name = 'Execute_CreateUserStoryfromCR', Execute__c = true);
        insert tc;
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        
        copado__Org__c org = new copado__Org__c();
        org.Name = 'SBDEV12';
        insert org;
        User user1 = new User(LastName = 'test',
                              FirstName='test',
                              Alias = 'alias',
                              Email = 'testCR@testCR.com',
                              Username = 'userNameCR@testCR.com',
                              ProfileId = profileId.id,
                              TimeZoneSidKey = 'America/Los_Angeles',
                              EmailEncodingKey = 'UTF-8',
                              LanguageLocaleKey = 'en_US',
                              LocaleSidKey = 'en_US',
                              Developer_Sandbox_Name__c=org.Id
                             );
        insert user1;
        Id caseSalesRT = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Sales Operations Helpdesk').getRecordTypeId();
        Case cs = new Case(Subject='abcd', Priority='Urgent (P1)', RecordTypeId=caseSalesRT, Description='abcdDes', Case_type__c = 'Problem');
        insert cs;
        
        Tracker_Release__c  rl = new Tracker_Release__c ();
        rl.name = 'test';
        rl.Release_Date__c  = system.today();
        insert rl;
        
        
        Tracker_Change_Request__c cr = new Tracker_Change_Request__c();
        cr.Assignee__c = UserInfo.getUserId();
        cr.Type__c = 'Issue/Bug';
        cr.Priority__c = 'Normal';
        cr.Business_Analyst__c = UserInfo.getUserId();
        cr.Summary__c = cs.Subject;
        cr.Description__c = cs.Description;
        cr.Case__c = cs.Id;
        cr.Stage__c = 'Development';
        cr.Status__c = 'In Dev';
        cr.Developer__c = user1.Id;
        cr.QA__c = user1.Id;
        cr.Release__c = rl.Id;
        cr.Dev_Estimated_Efforts__c = 10;
        insert cr;
        copado__User_Story__c cc = new copado__User_Story__c();
        cc.Change_Request__c = cr.id;
        insert cc;
        cr.Stage__c = 'Ready for Release';
        cr.Copado_User_Story__c = cc.id;
        cr.Actual_Dev_Efforts__c=10;
        cr.Deployment_Component_Provided__c=true;
        update cr;
        
        Tracker_Change_Request__c cr1 = new Tracker_Change_Request__c();
        cr1.Assignee__c = UserInfo.getUserId();
        cr1.Type__c = 'Issue/Bug';
        cr1.Priority__c = 'Normal';
        cr1.Business_Analyst__c = UserInfo.getUserId();
        cr1.Summary__c = cs.Subject;
        cr1.Description__c = cs.Description;
        cr1.Case__c = cs.Id;
        cr1.Stage__c = 'Development';
        cr1.Status__c = 'In Dev';
        cr1.Developer__c = user1.Id;
        cr1.QA__c = user1.Id;
        cr1.Release__c = rl.Id;
        cr1.Dev_Estimated_Efforts__c = 10;
        cr1.Copado_User_Story__c = cc.id;
        cr1.Actual_Dev_Efforts__c=10;
        cr1.Deployment_Component_Provided__c=true;
        insert cr1;
        
    }
}