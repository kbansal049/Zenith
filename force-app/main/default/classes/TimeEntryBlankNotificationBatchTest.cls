@isTest
public class TimeEntryBlankNotificationBatchTest {
    @isTest
    public static void testMethod1(){
        Account account = TestDatafactory_Zscaler.insertAccount('Test Account', 'vdua@zscaler.com', 'test', null, null, 5);
        Contact contact = TestDatafactory_Zscaler.insertContact('Test', account.Id, account.Id);
        
        inspire1__Project__c testProject = new inspire1__Project__c();
        testProject.Name = 'Test';
        testProject.inspire1__Account__c = account.Id;
        insert testProject;
        
        inspire1__Project_Tasks__c IPT = new inspire1__Project_Tasks__c();
        IPT.Name = 'Testing Task';
        IPT.inspire1__Time_Tracking_Only__c = False;
        IPT.inspire1__Start_Date__c = System.today(); 
        IPT.inspire1__Project__c = testProject.Id;
        insert IPT;
        
        inspire1__Time_Entry__c timeEntry = new inspire1__Time_Entry__c();
        timeEntry.inspire1__Tracked_Project_Tasks__c = IPT.Id;
        timeEntry.inspire1__Contact__c = contact.Id;
        timeEntry.inspire1__Efforts__c = 8.0;
        timeEntry.inspire1__Date__c = System.today();
        insert timeEntry;
        
        Test.startTest();
        TimeEntryBlankNotificationSch sche = new TimeEntryBlankNotificationSch(); 
        sche.execute(null);
        Test.stopTest();
    }
}