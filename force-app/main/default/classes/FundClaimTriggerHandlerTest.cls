@isTest
private class FundClaimTriggerHandlerTest {
    
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
        
        Campaign campaignRecord = new Campaign();
        campaignRecord.name='ZPA Interactive';
        campaignRecord.Department__c = '5000-Corporate Marketing';
        campaignRecord.Geo__c = 'GLOBAL';
        campaignRecord.StartDate = Date.today();
        campaignRecord.EndDate = Date.today()+30;
        campaignRecord.Fiscal_Year__c = 'All Time';
        campaignRecord.Type = 'Default';
        campaignRecord.Campaign_Type__c = 'Assets';
        campaignRecord.Recommended_Outreach_Sequence__c ='Testing';
        
        insert campaignRecord;
        
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
        
        PartnerFundRequest fundRequest = new PartnerFundRequest(Title = 'FundRequest001',
                                                                Activity = 'Digital Advertising-LinkedIn',
                                                                ChannelPartnerId = partnerAccount.Id,
                                                                AllocationId = fundAllocation.Id,
                                                                CoOp_Status__c = 'Pre-Approved',
                                                                Status = 'APPROVED',
                                                                RequestedAmount = 100.99,
                                                                Zinfi_Co_op_Id__c = 'ZINFI-Id-XYZ001',
                                                                Product__c = 'Zero Trust Exchange (ZTX)',
                                                                Lead_Follow_Up__c = 'Zscaler Lead Nurturing',
                                                                Target_Audience__c = 'End Customer',
                                                                PO_Number__c = 'POMNOP098765',
                                                                CampaignId = campaignRecord.Id,
                                                                Amount_Approved__c = 100);
        
        
        insert fundRequest;
		
		PartnerFundClaim fundClaim = new PartnerFundClaim(Title = 'FundClaim001',
                                                        RequestId = fundRequest.Id,
                                                        Claim_Status__c = 'Pending Submission',
                                                        Claim_Amount__c = 20.99,
                                                        Zinfi_Claim_Id__c = 'ZINFI-Id-XYZ001');
        insert fundClaim;        
    }
    
    @isTest 
    static void fundClaimTriggerHandlerTestPositive() {
        PartnerFundClaim fundClaim = [SELECT Id, Amount_Approved__c,Claim_Status__c
                                      FROM PartnerFundClaim
                                      WHERE Title = 'FundClaim001' 
                                      LIMIT 1];
        
        Test.startTest();
        	fundClaim.Amount_Approved__c = 11.99;
        	update fundClaim;
        Test.stopTest();

        PartnerFundClaim checkCreatedFundClaim = [SELECT Id, Amount_Approved__c FROM PartnerFundClaim LIMIT 1];
        System.assertEquals(checkCreatedFundClaim.Amount_Approved__c,11.99);
    }

}