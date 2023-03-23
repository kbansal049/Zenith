@isTest
private class FundRequestTriggerHandlerTest {
    
    @TestSetup
    static void createTestData() {
        
        Account partnerAccount = new Account(Name = 'PartnerAccount001',
                                             Type = 'Partner');
        insert partnerAccount;
        
		partnerAccount = [SELECT Id, isPartner, Name 
                          FROM Account 
                          WHERE Name = 'PartnerAccount001' 
                          LIMIT 1];
        partnerAccount.IsPartner = TRUE;
        update partnerAccount;
        
        PartnerMarketingBudget budget = new PartnerMarketingBudget();
        budget.Title = partnerAccount.Name + ' Marketing Budget';
        budget.ChannelPartnerId = partnerAccount.Id;
        budget.Amount = 99999999999.99;
        budget.Type = 'Marketing Funds';
        
        insert budget;
        
        PartnerFundAllocation fundAllocation = new PartnerFundAllocation();
        fundAllocation.Title = partnerAccount.Name + ' Fund Allocation';
        fundAllocation.ChannelPartnerId = partnerAccount.Id;
        fundAllocation.Amount = budget.Amount;
        fundAllocation.BudgetId = budget.Id;
        
        insert fundAllocation;
    }
    
    @isTest 
    static void fundRequestTriggerHandlerTestPositive() {
        Account partnerAccount = [SELECT Id, isPartner, Name 
                                  FROM Account 
                                  WHERE Name = 'PartnerAccount001' 
                                  LIMIT 1];
        PartnerFundRequest fundRequest = new PartnerFundRequest(Title = 'FundRequest001',
                                                        Activity = 'Digital Advertising-LinkedIn',
                                                        ChannelPartnerId = partnerAccount.Id,
                                                        CoOp_Status__c = 'Pending Submission',
                                                        RequestedAmount = 100.99,
                                                        Zinfi_Co_op_Id__c = 'ZINFI-Id-XYZ001',
                                                        Product__c = 'Zero Trust Exchange (ZTX)',
                                                        Lead_Follow_Up__c = 'Zscaler Lead Nurturing',
                                                        Target_Audience__c = 'End Customer');

        Test.startTest();
        	insert fundRequest;
        Test.stopTest();

        PartnerFundRequest check = [SELECT Id, Title FROM PartnerFundRequest LIMIT 1];
        System.assertEquals(check.Title,'FundRequest001');
    }

}