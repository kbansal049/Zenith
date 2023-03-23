@isTest
public class Trigger_Opportunity_HelperTest {

    @testSetup static void setup() {
        List<Partner_Incentive__c> piList = new List<Partner_Incentive__c>();
        // Create common test accounts
        List<Account> testAccts = new List<Account>();        
        testAccts.add(new Account(Name = 'TestAcct1'));
        testAccts.add(new Account(Name = 'TestAcct2'));
        testAccts.add(new Account(Name = 'TestAcct3'));
        insert testAccts;    
        
        Opportunity opp = new Opportunity();
        Opp.Name = 'Test Opp1';
        Opp.CloseDate = system.Today() + 30;
        Opp.AccountId = testAccts[0].Id;
        Opp.Amount = 123456;
        Opp.Type = 'Existing Customer (Renewal)';
        Opp.Forecast_Category__c = 'Best Case';
        Opp.Stagename = '4 - Impact Validation';
        Opp.Custom_Renewal__c = false;
        Opp.Deal_Reg_Margin__c = testAccts[0].Id;
        Opp.Deal_Reg_Partner_Teaming_Reseller__c = testAccts[0].Id;
        insert Opp;
        
        Opportunity_Partner__c oppPartner = new Opportunity_Partner__c();
        oppPartner.Partner_Type__c = 'Reseller';
        oppPartner.Opportunity__c = Opp.Id;
        oppPartner.Account__c =testAccts[0].Id;
        insert oppPartner;

        Contract contract1 = new Contract(
        AccountId = testAccts[0].Id,  
        ContractTerm = 12,
        SBQQ__opportunity__c = Opp.Id,
        StartDate = Date.today(),
        EndDate = Date.today());        
        insert contract1;
         
        piList.add((SB_TestCPQDataUtility.createPartnerIncentive(1,testAccts[0].Id,true,system.today(),system.today(),'Traditional','MSP'))[0]);
        piList.add((SB_TestCPQDataUtility.createPartnerIncentive(1,testAccts[0].Id,true,system.today()+365,system.today()-30,'Summit - Discount','MSP'))[1]);
        piList[1].Default__c=true;
        piList[1].Partner_Role__c='Distributor';
        piList[0].Partner_Role__c='Distributor';
        insert piList;
        
        SBQQ__Quote__c quote = new SBQQ__Quote__c(
            SBQQ__Account__c = testAccts[0].Id, 
            SBQQ__PricebookId__c = Test.getStandardPricebookId(), 
            SBQQ__Opportunity2__c = Opp.Id, 
            SBQQ__Partner__c = testAccts[0].Id,
            SBQQ__StartDate__c = system.today(),
            SBQQ__Status__c = 'Approved',
            Partner_Incentive__c = piList[1].Id,
            Partner_Program__c = Label.Partner_Program_Summit_Discount,
            SBQQ__Primary__c=true);
        insert quote; 
    }
    
    private static testmethod void Test1(){
        List<Account> lstacc = [Select Id, Name from Account]; 
        Opportunity Opp = [Select Id,Deal_Reg_Partner_Teaming_Reseller__c,Deal_Reg_Margin__c from Opportunity limit 1];
        Test.startTest();
        Opp.Deal_Reg_Partner_Teaming_Reseller__c = lstacc[1].Id;
        Opp.Deal_Reg_Margin__c = lstacc[1].Id;
        Update Opp;
        System.assertNotEquals(null,Opp);
        Test.stopTest();
    }
    
     private static testmethod void Test2(){
        List<Account> testAccts = [Select Id, Name from Account];    
        Test.startTest(); 
        Contract contract = new Contract(
        AccountId = testAccts[0].Id,  
        ContractTerm = 12,
        StartDate = Date.today(),
        EndDate = Date.today());        
        insert contract; 
         
        Opportunity Opp1 = new Opportunity();
        Opp1.Name = 'Test Opp21';
        Opp1.CloseDate = system.Today() + 30;
        Opp1.AccountId = testAccts[0].Id;
        Opp1.Amount = 123456;
        Opp1.Type = 'Existing Customer (Renewal)';
        Opp1.Forecast_Category__c = 'Best Case';
        Opp1.Stagename = '4 - Impact Validation';
        Opp1.Custom_Renewal__c = true;
        Opp1.SBQQ__RenewedContract__c = contract.Id;
        insert Opp1;   
       
        Opportunity_Partner__c oppPartner1 = new Opportunity_Partner__c();
        oppPartner1.Partner_Type__c = 'Reseller';
        oppPartner1.Opportunity__c = Opp1.Id;
        oppPartner1.Account__c = testAccts[1].Id;
        //oppList.add(Opp1);
        insert oppPartner1;

        contract.SBQQ__opportunity__c = Opp1.Id;
        update contract;
        
        Trigger_Opportunity_Helper.mapRenewedContract= new Map<Id,Contract>([SELECT Id,EndDate,SBQQ__Opportunity__c,SBQQ__Opportunity__r.Amount,SBQQ__Opportunity__r.Name,Partner__c,Partner_Program__c,AccountId,Account.Customer_Advocate__c,Account.OwnerId,Partner__r.Ultimate_Parent_Account__c,Account.Sales_Territory__c,Account.Sales_Territory__r.Customer_Advocate__c FROM Contract]);
        Trigger_Opportunity_Helper.createOpportunityPartnerRecords(new List<Opportunity> {Opp1});
        delete Opp1;
        List<Opportunity> lstOpp=[SELECT id,IsDeleted from Opportunity WHERE IsDeleted = true ALL rows];
		undelete lstOpp;
        System.assertNotEquals(null,lstOpp);
        Test.stopTest();
     }
    
    //Added by Arsh - CR# 4631
    private static testmethod void TestsetCompetitorContext(){
        List<Account> lstacc = [Select Id, Name from Account]; 
        Opportunity Opp = [Select Id,Primary_Competitor__c,
                           Deal_Reg_Partner_Teaming_Reseller__c,Deal_Reg_Margin__c,
                           Competitor__c,Competitor_Content_Technical__c,
                           Link_to_Competitor_s_Content__c from Opportunity limit 1];
        Test.startTest();
        Opp.Competitor__c = 'Akamai'+ ';'+ 'Netskope' + ';' + 'Palo Alto Networks';
        Opp.Primary_Competitor__c = 'Palo Alto Networks';
        Update Opp;
        Test.stopTest();
    }
    
}