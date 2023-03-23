@isTest
public class UpdateCompetitorContentBatchTest {
	@testSetup
    static void setup(){
        List<Partner_Incentive__c> piList = new List<Partner_Incentive__c>();
        // Create common test accounts
        List<Account> testAccts = new List<Account>();        
        testAccts.add(new Account(Name = 'TestAcct1'));
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
        Opp.Competitor__c = 'Akamai'+ ';'+ 'Netskope' + ';' + 'Palo Alto Networks';
        insert Opp;
        
        Opp.Competitor_Content_Technical__c = '';
        update Opp;
    }
    
    static testMethod void testMethod1(){
       Test.startTest();
       UpdateCompetitorContentBatch acc = new UpdateCompetitorContentBatch();        
       Database.executeBatch(acc,40);
        
    }
}