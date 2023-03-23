@isTest
private class customLookUpClassTest {
    
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
        
        Partner_Incentive__c pi1 = new Partner_Incentive__c();
        pi1.Account__c = testAccts[3].id;
        pi1.Active__c = true;
        Pi1.Partner_Program__c ='Summit - Federal';
        insert pi1;
    }

    private static testMethod void test() { 
        Test.startTest();
        customLookUpClass.fetchLookUpValues('TestAcctIncentive','Account','Reseller',true,'');
        Test.stopTest();
    }
    private static testMethod void test1() { 
        Test.startTest();
        customLookUpClass.fetchLookUpValues('TestDeal','Deal_Reg__c','',false,'');
        customLookUpClass.fetchLookUpValues('Test','Account','Tech Partner',true,'');
        customLookUpClass.fetchLookUpValues('FedReseller','Account','FederalReseller',false,'');
        customLookUpClass.fetchLookUpValues('FedReseller','Account','FederalReseller',True,'');
        customLookUpClass.fetchLookUpValues('Test','Account','Distributor',false,'Federal Distributor');
        customLookUpClass.fetchLookUpValues('Test','Account','Distributor',false,'SLED');
        Test.stopTest();
    }
}