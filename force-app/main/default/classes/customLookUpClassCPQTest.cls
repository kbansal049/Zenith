@isTest
private class customLookUpClassCPQTest {
    
    @testSetup static void setup() {
        // Create common test accounts
        List<Account> testAccts = new List<Account>();        
        testAccts.add(new Account(Name = 'TestAcct', Type='Technology Partner'));
        testAccts.add(new Account(Name = 'TestAcctIncentive', Type = 'Partner'));
        testAccts.add(new Account(Name = 'TestAcct', Type = 'Partner'));
        testAccts.add(new Account(Name = 'FedReseller', Type = 'Partner'/*, Model_Type_Partner__c = 'Summit - Federal'*/));
        insert testAccts;    
        Partner_Incentive__c pi = new Partner_Incentive__c();
        pi.Account__c = testAccts[1].id;
        pi.Active__c = true;
        insert pi;
    }

    private static testMethod void test() { 
        Test.startTest();
        customLookUpClassCPQ.fetchLookUpValues('TestAcctIncentive','Account','Reseller',true);
        Test.stopTest();
    }
    private static testMethod void test1() { 
        Test.startTest();
        customLookUpClassCPQ.fetchLookUpValues('TestDeal','Deal_Reg__c','',false);
        customLookUpClassCPQ.fetchLookUpValues('Test','Account','Tech Partner',true);
        customLookUpClassCPQ.fetchLookUpValues('FedReseller','Account','FederalReseller',false);
        Test.stopTest();
    }
}