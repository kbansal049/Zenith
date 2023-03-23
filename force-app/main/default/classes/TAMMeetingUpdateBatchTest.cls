@isTest
public class TAMMeetingUpdateBatchTest{
    
    static testmethod void test1(){
        
        Account account = new Account(Name = 'Test Account');
        insert account;
        
        Account_Extension__c accExt = new Account_Extension__c();
        accExt.Account__c = account.Id;
        insert accExt;
        
        Meeting__c meet = new Meeting__c();
        meet.Customer_Name__c = account.Id;
        meet.Date_of_meeting__c = Date.Today() + 1;
        meet.Status__c = 'Completed'; 
        meet.Executive_Summary__c = 'Test';
        insert meet;
        
        Test.StartTest();
        Database.executeBatch(new TAMMeetingUpdateBatch('select Id, Account__c, TAM_Weekly_DateTime__c from Account_Extension__c'));
        Test.StopTest();
    }
    
}