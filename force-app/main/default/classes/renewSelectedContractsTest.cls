@isTest
private class renewSelectedContractsTest {
      
    @testSetup static void setup() {
        List<Account> testAccts = new List<Account>();        
        testAccts.add(new Account(Name = 'TestAcct1'));
        insert testAccts; 
        Test.startTest();
        Opportunity opp = new Opportunity();
        Opp.Name = 'Test Opp1';
        Opp.CloseDate = system.Today() + 10;
        Opp.AccountId = testAccts[0].Id;
        Opp.Amount = 123456;
        Opp.Type = 'Existing Customer (Renewal)';
        Opp.Forecast_Category__c = 'Best Case';
        Opp.Stagename = '4 - Impact Validation';
        Opp.Custom_Renewal__c = false;
        insert Opp;
        Test.stopTest();
    }
    
    private static testmethod void Test1(){
        List<Account> testAccts = [Select Id from Account];
        Opportunity Opp = [Select Id from Opportunity limit 1];
        List<Contract> conList = new List<Contract>();
        Contract contract1 = new Contract(
        AccountId = testAccts[0].Id,  
        SBQQ__RenewalOpportunity__c =null,
        Status ='Draft',
        SBQQ__opportunity__c = Opp.Id,
        SBQQ__RenewalQuoted__c=false,
        SBQQ__RenewalForecast__c =True,
        StartDate = Date.today(),
        EndDate = Date.today().addDays(10)); 
        conList.add(contract1);
        
        Contract contract2 = new Contract(
        AccountId = testAccts[0].Id,  
        ContractTerm = 12,
        SBQQ__RenewalOpportunity__c =null,
        Status ='Draft',
        SBQQ__opportunity__c = Opp.Id,
        SBQQ__RenewalQuoted__c=false,
        SBQQ__RenewalForecast__c =False,
        StartDate = Date.today(),
        EndDate = Date.today().addDays(10));
        conList.add(contract2);
        SBQQ.TriggerControl.disable();
        insert conList;  
        SBQQ.TriggerControl.enable();
        
        string query = 'Select id,SBQQ__RenewalOpportunity__c, SBQQ__RenewalForecast__c, SBQQ__RenewalQuoted__c,createdby.name,createddate,EndDate,StartDate,ContractTerm from contract LIMIT 2';
        
        Test.StartTest();
        renewSelectedContracts sh1 = new renewSelectedContracts(query);      
        Database.executeBatch(sh1);
        
        Test.stopTest();
        
    }

}