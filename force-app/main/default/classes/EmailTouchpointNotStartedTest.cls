@IsTest
public class EmailTouchpointNotStartedTest {
    @IsTest
    static void test(){
        User usr = TestDatafactory_Zscaler.insertAdminUser('2xyz@xyz.com', 'test12', 'test', 'ttest12', '2xyz@xyz.com.test', 'GMT', 'en_US', 'UTF-8', 'en_US');
        Account acct = new Account();
        acct.name = 'Test Account';
        acct.Type = 'Customer';
        acct.RecordTypeId = '01270000000EAFsAAO';
        acct.TAM_Name_New__c = usr.id;
        insert acct;
        inspire1__Project__c project=new inspire1__Project__c();
        project.Name='Test Project';
        project.inspire1__Project_Status__c='In Progress';
        project.inspire1__Account__c=acct.id;
        insert project;
        inspire1__Project_Tasks__c task=new inspire1__Project_Tasks__c();
        task.inspire1__StartDate__c=system.today().addDays(-1);
        System.debug('Start Date-->'+ task.inspire1__StartDate__c);
        System.debug('Project Status' + project.inspire1__Project_Status__c);
        System.debug('System Date-->'+ System.today());
        task.inspire1__Project__c=project.Id;
        task.Name='PSC-TAM1 Test task';
        task.inspire1__Status__c='Not Started';
        insert task;
        Test.startTest();
        EmailTouchpointNotStarted.callEmailTouchpointNotStartedBatch();
        Test.stopTest();
    }
}