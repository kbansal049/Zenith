@isTest
public class ContactCloseFieldUpdateBatchTest {
    
    @testSetup static void setup() {
       	
        Account acc = new Account(Name = 'Test Account', TAM_Email__c = 'abc@abc.com', Type='Prospect');
        insert acc;
        
        
		Contact con2 = new Contact();
        con2.FirstName = 'Test2';
        con2.LastName = 'Test2';
        con2.Contact_Lead_Status__c = 'Actively Engaged';
        con2.Involved_in_Active_Oppty__c = true;
        con2.AccountId = acc.Id;
        con2.Remarks__c = 'Replied: Not Interested';
       
      
        
        Contact con3 = new Contact();
        con3.FirstName = 'Test3';
        con3.LastName = 'Test3';
        con3.Contact_Lead_Status__c = 'Actively Engaged';
        con3.Involved_in_Active_Oppty__c = false;
        con3.AccountId = acc.Id;
        
        
        insert new List<Contact>{con2, con3};
    
       	Contact con4 = new Contact();
        con4.FirstName = 'Test4';
        con4.LastName = 'Test4';
        con4.Contact_Lead_Status__c = 'Actively Engaged';
        con4.Involved_in_Active_Oppty__c = true;
        con4.AccountId = acc.Id;
        con4.Remarks__c = 'Replied: Not Interested';
       
      
        
        Contact con5= new Contact();
        con5.FirstName = 'Test5';
        con5.LastName = 'Test5';
        con5.Contact_Lead_Status__c = 'Actively Engaged';
        con5.Involved_in_Active_Oppty__c = false;
        con5.AccountId = acc.Id;
        
        insert new List<Contact>{con4, con5};
        	
     }
    @isTest static void opportunityBatch(){
        Test.startTest();
        String CRON_EXP = '0 0 0 15 3 ? *';
        ContactCloseFieldUpdateBatch ob =new ContactCloseFieldUpdateBatch();
        String jobId = System.schedule('ScheduleApexClassTest',  CRON_EXP, new ContactCloseFieldUpdateBatch());
        Database.executeBatch(ob);
       	Test.stopTest();
    }  

}