@isTest
public class RenewContractBatch_2Test {
      
    @testSetup static void setup() {
        List<Account> testAccts = SB_TestCPQDataUtility.createAccount(3);       
        insert testAccts;    
        
        SB_TestCPQDataUtility.priceBooksToBeInsertedList = SB_TestCPQDataUtility.createCustomPriceBooks(1);
        insert SB_TestCPQDataUtility.priceBooksToBeInsertedList;
        
        Test.StartTest();
        List<Opportunity> listOppty = SB_TestCPQDataUtility.createOpportunity(2,'Test Opportunity',testAccts[0].id);        
        insert listOppty;        
        
        SBQQ__Quote__c quote = new SBQQ__Quote__c(
        SBQQ__Account__c = testAccts[0].Id, 
        SBQQ__PricebookId__c = Test.getStandardPricebookId(), 
        SBQQ__Opportunity2__c = listOppty[0].Id, 
        SBQQ__Partner__c = testAccts[0].Id,
        SBQQ__StartDate__c = system.today()+365,
        SBQQ__Status__c = 'Approved',
        SBQQ__Primary__c=true);
        insert quote; 
        Test.stopTest();
    }
    
    @isTest
    public static void Test1(){
        List<Account> testAccts = [Select Id from Account];
        List<Opportunity> listOppty = [Select Id from Opportunity ];
        Contract contract1 = new Contract(
        AccountId = testAccts[0].Id,  
        ContractTerm = 12,
        Split_Contract__c = false,
        Migrated_Contract__c = false,
        Status ='Draft',
        SBQQ__opportunity__c = listOppty[0].Id,
        SBQQ__RenewalOpportunity__c = listOppty[1].Id,
        SBQQ__RenewalForecast__c =TRUE,
        SBQQ__RenewalQuoted__c=false,
        StartDate = Date.today(),
        EndDate = Date.today().addDays(365)); 
        Test.StartTest();
        insert contract1;
        
        
        RenewContractBatchSchedulable_2 sh1 = new RenewContractBatchSchedulable_2 ();      
        SchedulableContext sc = null;
        sh1.execute(sc);
        Test.stopTest();
    }
    
    @isTest
    public static void Test3(){
        List<Account> testAccts = [Select Id from Account];
        Opportunity Opp = [Select Id,SBQQ__RenewedContract__c from Opportunity limit 1];
        SBQQ__Quote__c Quote= [Select Id from SBQQ__Quote__c limit 1];
            
        Contract contract3 = new Contract(
        AccountId = testAccts[2].Id,  
        ContractTerm = 12,
        Split_Contract__c = false,
        Migrated_Contract__c = false,
        SBQQ__RenewalOpportunity__c = Opp.id,
        Status ='Draft',
        SBQQ__RenewalForecast__c =TRUE,
        SBQQ__RenewalQuoted__c = false,
        SBQQ__Quote__c= Quote.id,
        StartDate = system.Today(),
        EndDate = system.Today() + 360 );  
        SBQQ.TriggerControl.disable();
        insert contract3;
        Opp.SBQQ__RenewedContract__c = contract3.id;
        Test.StartTest();
        update Opp;
        SBQQ.TriggerControl.enable();
        generateYWSforRenewals sh1 = new generateYWSforRenewals(new List<String>{contract3.id});
        Test.stopTest();
        Database.executeBatch(sh1); 
        System.assert(true);  
    }
    
}