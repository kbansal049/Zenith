@istest
public class Cosell_Activity_Trigger_Test {
    @testSetup
    static void testData(){
        
        TriggerUtility.prospectTypeUpdExecuted();
        triggerUtility.contactPatchManagerExecuted();
        triggerUtility.accTerritoryPatchExecuted();
        triggerUtility.oppPatchManagerAfterInsertExecuted();
        triggerUtility.oppPatchManagerAfterUpdateExecuted();
        
        Skip_Triggers__c skipTriggers = new Skip_Triggers__c();
        skipTriggers.Skip_Account_Triggers__c = true;
        skipTriggers.Skip_Opportunity_Triggers__c = true;
        skipTriggers.Name = 'SkipTriggers';
        insert skipTriggers;
        
        Account acc = new Account();
        acc.Name ='Test Account';
        acc.Type ='Partner';
        acc.BillingCountry = 'France';
        insert acc;

        Contact con = new contact(lastname = 'abhi', email ='testemail123@tzscaler.com');
        insert con;

        
    }
    @IsTest
    static void test1(){
        
        insert TestDatafactory_Zscaler.gettriggerswitchrecords(true);
        
        Contact con = [Select Id, AccountID from contact limit 1];
        Cosell_Activities__c rec = new Cosell_Activities__c();
        rec.partner__c = con.AccountId;
        rec.partner_contact__c = con.Id;
        rec.status__c = Label.Cosell_Invited;
        insert rec;
        Test.startTest();
        rec.status__c = Label.Cosell_Accepted;
        update rec;
        Test.stopTest();
        
    }
}