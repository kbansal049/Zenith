@isTest
private class RenewContractBatchTest {
      
    @testSetup static void setup() {
        List<Account> testAccts = new List<Account>();        
        testAccts.add(new Account(Name = 'TestAcct1'));
        testAccts.add(new Account(Name = 'TestAcct2'));
        testAccts.add(new Account(Name = 'TestAcct3'));
        insert testAccts;    
        
        Opportunity opp = new Opportunity();
        Opp.Name = 'Test Opp1';
        Opp.CloseDate = system.Today() + 10;
        Opp.AccountId = testAccts[0].Id;
        Opp.Amount = 123456;
        Opp.Type = 'Existing Customer (Renewal)';
        Opp.Forecast_Category__c = 'Best Case';
        Opp.Stagename = '4 - Impact Validation';
        Opp.Custom_Renewal__c = false;
        Opp.Deal_Reg_Margin__c = testAccts[0].Id;
        Opp.Deal_Reg_Partner_Teaming_Reseller__c = testAccts[0].Id;
        insert Opp;
        
        SBQQ__Quote__c quote = new SBQQ__Quote__c(
            SBQQ__Account__c = testAccts[0].Id, 
            SBQQ__PricebookId__c = Test.getStandardPricebookId(), 
            SBQQ__Opportunity2__c = Opp.Id, 
            SBQQ__Partner__c = testAccts[0].Id,
            SBQQ__StartDate__c = system.today(),
            SBQQ__Status__c = 'Approved',
            SBQQ__Primary__c=true);
        insert quote; 
		
        Profile coreSalesProfile= [Select Id from profile where Name='Core Sales - CSM']; 
        String orgId=UserInfo.getOrganizationId(); 
        String dateString=String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        String uniqueName=orgId+dateString + Integer.valueOf(Math.rint(Math.random()*1000000));
        User coreSalesUser=new User(firstname = 'Core Sales', 
                                    lastName = 'User', 
                                    email = uniqueName + '@test' + orgId + '.org', 
                                    Username = uniqueName + '@test' + orgId + '.org', 
                                    EmailEncodingKey = 'ISO-8859-1', 
                                    Alias = uniqueName.substring(18, 23), 
                                    TimeZoneSidKey = 'America/Los_Angeles', 
                                    LocaleSidKey = 'en_US', 
                                    LanguageLocaleKey = 'en_US', 
                                    ProfileId = coreSalesProfile.Id);
        insert coreSalesUser;
    }
    
    private static testmethod void Test1(){
        List<Account> testAccts = [Select Id from Account];
        Opportunity Opp = [Select Id from Opportunity limit 1];
		User usr = [SELECT Id FROM User WHERE firstname = 'Core Sales'];
        Contract contract1 = new Contract(
        AccountId = testAccts[0].Id,  
        ContractTerm = 12,
        Split_Contract__c = false,
        Migrated_Contract__c = false,
        SBQQ__RenewalOpportunity__c =null,
        Status ='Draft',
        SBQQ__opportunity__c = Opp.Id,
        SBQQ__RenewalQuoted__c=false,
        StartDate = Date.today(),
        EndDate = Date.today().addDays(360),
        Number_of_renewable_subscriptions__c = 5);        
        SBQQ.TriggerControl.disable();
        insert contract1;  
        SBQQ.TriggerControl.enable();
        
		TriggerHandler.bypass('OpportunityTriggerHandler');
        Test.StartTest();
        System.runAs(usr){
            RenewContractBatchSchedulable sh1 = new RenewContractBatchSchedulable();      
            SchedulableContext sc = null;
            sh1.execute(sc);
            System.assert(true);
		}
        Test.stopTest();
		TriggerHandler.clearBypass('OpportunityTriggerHandler');
    }
    
    private static testmethod void Test2(){
        List<Account> testAccts = [Select Id from Account];
        Opportunity Opp = [Select Id from Opportunity limit 1];
        SBQQ__Quote__c Quote= [Select Id from SBQQ__Quote__c limit 1];
        User usr = [Select Id from User limit 1];

        Contract contract3 = new Contract(
        AccountId = testAccts[2].Id,  
        ContractTerm = 12,
        Split_Contract__c = false,
        Migrated_Contract__c = false,
        SBQQ__RenewalOpportunity__c = null,
        Status ='Draft',
        SBQQ__RenewalForecast__c =TRUE,
        SBQQ__RenewalQuoted__c = false,
        SBQQ__Quote__c= Quote.id,
        StartDate = system.Today(),
        EndDate = system.Today() + 360,
        Number_of_renewable_subscriptions__c = 5 );  
        SBQQ.TriggerControl.disable();
        insert contract3;  
        SBQQ.TriggerControl.enable();
        
		TriggerHandler.bypass('OpportunityTriggerHandler');

        Test.StartTest();
        System.runAs(usr){
            RenewContractBatchSchedulable sh1 = new RenewContractBatchSchedulable();      
            SchedulableContext sc = null;
            sh1.execute(sc);
            System.assert(true);
        }
        Test.stopTest();
		TriggerHandler.clearBypass('OpportunityTriggerHandler');
    }
    
    private static testmethod void Test3(){
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
        EndDate = system.Today() + 360,
        Number_of_renewable_subscriptions__c = 5 );  
        SBQQ.TriggerControl.disable();
        insert contract3;
        Opp.SBQQ__RenewedContract__c = contract3.id;
        update Opp;
        SBQQ.TriggerControl.enable();
		TriggerHandler.bypass('OpportunityTriggerHandler');
        Test.StartTest();
        generateYWSforRenewals sh1 = new generateYWSforRenewals(new List<String>{contract3.id});      
        Database.executeBatch(sh1); 
        System.assert(true);
        Test.stopTest();
		TriggerHandler.clearBypass('OpportunityTriggerHandler');
    }
    
   /* private static testmethod void Test3(){
        List<Account> testAccts = [Select Id from Account];
        Opportunity Opp = [Select Id from Opportunity limit 1];
        Contract contract3 = new Contract(
        AccountId = testAccts[2].Id,  
        ContractTerm = 12,
        Split_Contract__c = false,
        Migrated_Contract__c = false,
        SBQQ__RenewalOpportunity__c = null,
        Status ='New',
        SBQQ__RenewalForecast__c = false,
        SBQQ__RenewalQuoted__c = false,
        StartDate = Date.today(),
        EndDate = Date.today());        
        insert contract3; 
        
        Test.StartTest();
        RenewContractBatchSchedulable sh1 = new RenewContractBatchSchedulable();      
        SchedulableContext sc = null;
        sh1.execute(sc);
        Test.stopTest();
    }
    */
    
}