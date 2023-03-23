@isTest
public class MADTriggerHelperTest {
	@isTest
    static void enagagementTypeTest() {
        TriggerHandler.bypass('AccountTriggerHandler');
        Account acc = TestDatafactory_Zscaler.insertAccount('Test Account', 'test@test.com', 'Customer',null, null, 5);
        TriggerHandler.clearBypass('AccountTriggerHandler');
        Set<Id> accIdSet = new Set<Id>();
        accIdSet.add(acc.Id);
        Date closeDate = system.today() + 5;
        TriggerHandler.bypass('OpportunityTriggerHandler');
        Opportunity opp = TestDatafactory_Zscaler.insertOpportunity('Test Opp1', false, acc.Id, Label.Stage_4_Economic_Buyer_Signoff, closeDate , null, null, null, null,null, null, null, null, null, null, true);
        Opportunity oppToChange = TestDatafactory_Zscaler.insertOpportunity('Test Opp1', false, acc.Id, Label.Stage_4_Economic_Buyer_Signoff, closeDate , null, null, null, null,null, null, null, null, null, null, true);
        TriggerHandler.clearBypass('OpportunityTriggerHandler');
        List<M_A_D_Details__c> madList = new List<M_A_D_Details__c>();
        M_A_D_Details__c madObj1 = new M_A_D_Details__c();
        
        madObj1.Sales_Effort__c = 'Sales Leading';
        madObj1.Source__c = 'MADS / ADV / GSI';
        madObj1.Firm_Type__c = 'Private Equity Firm';
        madObj1.Opportunity__c = opp.Id;
        madObj1.Transaction_Perspective__c = 'Investor';
        madObj1.Engaged_with_M_A_Partner__c = 'No';
        madObj1.Source__c = 'ZS - Other';
        madObj1.Sales_Effort__c = 'MADS leading';
       // madObj1.Region__c = 'NA';
        madObj1.Transaction_Approach__c = 'Integration';
     
        insert madObj1;

        madObj1.Source__c = 'Sales / SDR / CSM';
        
        update madObj1;
        
        madObj1.Sales_Effort__c = 'MADS Leading';
        madObj1.Source__c = 'MADS / ADV / GSI';
        
        update madObj1;
        
        madObj1.Source__c = 'Sales / SDR / CSM';
        
        update madObj1;
        
        madObj1.Sales_Effort__c = 'Joint effort';
        madObj1.Source__c = 'MADS / ADV / GSI';
        
        update madObj1;
        
        madObj1.Source__c = 'Sales / SDR / CSM';
        
        update madObj1;
        
        madObj1.Sales_Effort__c = 'External Influence';
        madObj1.Source__c = 'MADS / ADV / GSI';
        
        update madObj1;
        
        madObj1.Source__c = 'Sales / SDR / CSM';
        
        update madObj1;
        
        Test.startTest();
        madObj1.Opportunity__c = oppToChange.Id;
        update madObj1;
        MADTriggerHelper.getRelatedAccDetails(accIdSet);
        Test.stopTest();
        
        
    }
    
    @isTest
    private static void setAccountLookupTest(){
        
    }
}