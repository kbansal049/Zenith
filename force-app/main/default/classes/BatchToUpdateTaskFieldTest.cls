@istest
public class BatchToUpdateTaskFieldTest {
    @testSetup 
    static void setup() {
        Contact con = new Contact(FirstName = 'Robin',LastName = 'Koehler');
        insert con;

        Lead lead=new Lead(LastName='Doe',FirstName='John',Company='Test',Status='Inquiry');
        insert lead;
        
        Contact con1 = new Contact(FirstName = 'Robin',LastName = 'Koehler',Qualifying_SDR__c=UserInfo.getUserId());
        insert con1;

        Lead lead1=new Lead(LastName='Doe',FirstName='John',Company='Test',Status='Inquiry',Qualifying_SDR__c=UserInfo.getUserId());
        insert lead1;
        
        List<Task> tasks = new List<Task>();
        tasks.add(new Task(
        ActivityDate = Date.today().addDays(7),
        Subject='call',
        WhoId = con.Id,
        OwnerId = UserInfo.getUserId(),
        SDR_Qualified__c = True,
        Status='In Progress',
        Type='Discovery')
        );

        tasks.add(new Task(
        ActivityDate = Date.today().addDays(7),
        Subject='call',
        WhoId = lead.Id,
        OwnerId = UserInfo.getUserId(),
        SDR_Qualified__c = True,
        Status='In Progress',
        Type='Discovery')
        );
        tasks.add(new Task(
        ActivityDate = Date.today().addDays(7),
        Subject='call',
        WhoId = con1.Id,
        OwnerId = UserInfo.getUserId(),
        SDR_Qualified__c = False,
        Status='In Progress',
        Type='Discovery')
        );

        tasks.add(new Task(
        ActivityDate = Date.today().addDays(7),
        Subject='call',
        WhoId = lead1.Id,
        OwnerId = UserInfo.getUserId(),
        SDR_Qualified__c = False,
        Status='In Progress',
        Type='Discovery')
        );
        Test.startTest();
        insert tasks;
        tasks[0].SDR_Qualified__c = True;
        tasks[1].SDR_Qualified__c = True;
        Update tasks;
        Test.stopTest();
    }
    
     @isTest static void testMethod1() {
        BatchToUpdateTaskField b = new BatchToUpdateTaskField ();
		Database.executeBatch(b,5);
        
    }
    @isTest static void testMethod2() {
        BatchToUpdateTaskField2 b = new BatchToUpdateTaskField2 ();
		Database.executeBatch(b,5);
        
    }
    @isTest static void testMethod3() {
        BatchToUpdateTaskField3 b = new BatchToUpdateTaskField3 ();
		Database.executeBatch(b,5);
        
    }
    @isTest static void testMethod4() {
        BatchToUpdateTaskField4 b = new BatchToUpdateTaskField4 ();
		Database.executeBatch(b,5);
        
    }
}