@isTest
public class createOverageOpportunityControllerTest {
   @isTest
    static void testmethod1(){
	        TriggerHandler.bypass('AccountTriggerHandler');
            Account testAccount = new Account();
            testAccount.Name = 'Test Account';
            INSERT testAccount;
    		
    		testAccount.Account_Overage__c = 'Create Opportunity';
    		update testAccount;
    
    		opportunity opp = new opportunity(Name = 'Test opportunity', AccountId = testAccount.Id, StageName = '1 - Discovery & Qualification', CloseDate = system.Today()+30);
    		insert opp;
        	
	        createOverageOpportunityController.updateAccForOverage(new List<Id>{testAccount.Id});
        
    }
    		
}