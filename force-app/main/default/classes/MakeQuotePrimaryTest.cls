@isTest
public class MakeQuotePrimaryTest {
    @TestSetup
    static void setupData(){
        List<Account> accountList = SB_TestCPQDataUtility.createAccount(1);
        insert accountList;
        
        PriceBook2 customPb = (SB_TestCPQDataUtility.createCustomPriceBooks(1))[0];
        insert customPb;

        Opportunity opportunityRecord = SB_TestCPQDataUtility.createOpportunity(1, 'tes Opp 001', accountList[0].Id)[0];
        insert opportunityRecord;
        
        String quoteNewBusiness = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByDeveloperName().get('New_Business').getRecordTypeId();
        List<SBQQ__Quote__c> quoteList = SB_TestCPQDataUtility.createQuote(2, opportunityRecord.Id, opportunityRecord.AccountId, opportunityRecord.Primary_Reseller_Partner__c,opportunityRecord.Primary_Reseller_Partner__c,quoteNewBusiness);
        
        SBQQ.TriggerControl.disable();
        insert quoteList[0];
        insert quoteList[1];
        SBQQ.TriggerControl.enable();
    }

    @IsTest
    static void testMakePrimary(){
        List<SBQQ__Quote__c> quoteList = [SELECT Id, SBQQ__Primary__c, SBQQ__Opportunity2__c FROM SBQQ__Quote__c LIMIT 1];
        Test.startTest();
            MakeQuotePrimary.makePrimary(quoteList);
        Test.stopTest();
        
    }
}