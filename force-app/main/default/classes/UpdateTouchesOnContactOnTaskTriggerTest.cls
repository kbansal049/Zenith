@isTest
public class UpdateTouchesOnContactOnTaskTriggerTest {

     @isTest static void myTest() {
        // code_block
        // 
        Contact cnt = new Contact();
        cnt.firstName = 'test1';
        cnt.LastName = 'test2';
        cnt.email = 'test@test.com';                       
        insert cnt;
        
        Task t = new Task();
        t.whoId = cnt.Id;
        t.Subject='Donni';
        t.Status='Completed';
        t.Priority='Normal';
        
        insert t;    
         
        Event event = new Event(
            OwnerId = UserInfo.getUserId(),
            StartDateTime = Date.today().addDays(2),
            EndDateTime = Date.today().addDays(3),
            Subject = 'Go Live',
            whoId = cnt.Id
        );
         
        insert event ;   
        UpdateContactTouchesBatch batch= new UpdateContactTouchesBatch();
        database.executebatch(batch);
    }
    
    @isTest static void testContactRollUp() {
        // code_block
        // 
        Contact cnt = new Contact();
        cnt.firstName = 'test1';
        cnt.LastName = 'test2';
        cnt.email = 'test@test.com';                       
        insert cnt;
        
        Task t = new Task();
        t.whoId = cnt.Id;
        t.Subject='Donni';
        t.Status='New';
        t.Priority='Normal';
        
        insert t;    
           
        //UpdateContactTouchesBatch batch= new UpdateContactTouchesBatch();
        //database.executebatch(batch);
        //
        Task t1 = new Task();
        t1.whoId = cnt.Id;
        t1.Subject='Donni 1';
        t1.Status='New';
        t1.Priority='Normal';
        insert t1;
         
        Test.startTest();
        t1.Status='Completed';
        update t1; 
        Test.stopTest();
         
         Contact con = [SELECT Id, Activities__c, Open_Activities__c FROM Contact LIMIT 1];
         System.assertEquals(con.Activities__c, 2);
         System.assertEquals(con.Open_Activities__c, 1);
         
    }
}