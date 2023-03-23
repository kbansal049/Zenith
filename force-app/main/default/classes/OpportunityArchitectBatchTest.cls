@isTest
public class OpportunityArchitectBatchTest {
    
     @testSetup
    static void data(){
        Account account = new Account(Name = 'Test Account', Solution_Architect__c = UserInfo.getUserId());
        insert account;
         
       
         
        opportunity opp = new opportunity( Name = 'Test opportunity', AccountId = account.Id, StageName = '1 - Discovery & Qualification',
                                          CloseDate = system.Today()+30,
                                          contract_end_date_new__c = date.today().adddays(65)
                                         );
        insert opp;
    }
   static testMethod void run(){
        
         Account a = [Select Id,Name,Solution_Architect__c from Account limit 1];
         List<Account> accList =  new List<Account>();
         accList.add(a);
         OpportunityArchitectBatch.getOppAccMap(accList);
      
       OpportunityArchitectBatch b = new OpportunityArchitectBatch();
       Database.executeBatch(b);
       
    }
}