@isTest
public class CreateAccExtension_Test{
    
    @testSetup  static void setupdata(){
        
        Skip_Triggers__c skipTriggers = new Skip_Triggers__c();
        skipTriggers.Skip_Account_Triggers__c = true;
        skipTriggers.Skip_Opportunity_Triggers__c = true;
        skipTriggers.Name = 'SkipTriggers';
        insert skipTriggers;
        
        TriggerHandler.bypass('AccountTriggerHandler');
    }
    
    
    static testmethod void test1(){
        
        Account acct = new Account();
        acct.name = 'Test Account';
        acct.Type = 'Customer';
        insert acct;
        
        CreateAccExtension cae= new CreateAccExtension();
        database.executebatch(cae,2);
    }
    
}