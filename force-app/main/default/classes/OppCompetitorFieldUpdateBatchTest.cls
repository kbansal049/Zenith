@IsTest
private class OppCompetitorFieldUpdateBatchTest {
	@IsTest static void testBatch(){
        
        Skip_Triggers__c skipTriggers = new Skip_Triggers__c();
        skipTriggers.Skip_Account_Triggers__c = true;
        skipTriggers.Skip_Opportunity_Triggers__c = true;
        skipTriggers.Name = 'SkipTriggers';
        insert skipTriggers;
        
        Account acc = new Account();
        acc.Name = 'Test account';
        acc.Domain__c = 'test.com';
        INSERT acc;
        
        Contact con = new contact(lastname = 'abhi', email ='testemail123@tzscaler.com', accountid=acc.Id);
        insert con;
        
        opportunity opp1 = new opportunity(Name = 'Test opportunity', Primary_Quote_Exception__c  = TRUE, AccountId = acc.Id, StageName = label.Stage_1_Alignment, CloseDate = system.Today()+30,
                                         Competitors__c='No Vendor', Competitor__c = 'Palo Alto Networks', ZPA_Competitor__c='No Vendor');
        opportunity opp2 = new opportunity(Name = 'Test opportunity 2', Primary_Quote_Exception__c  = TRUE, AccountId = acc.Id, StageName = label.Stage_1_Alignment, CloseDate = system.Today()+30,
                                         Competitors__c='No Vendor', Competitor__c = 'Palo Alto Networks 123', ZPA_Competitor__c='No Vendor');
        opportunity opp3 = new opportunity(Name = 'Test opportunity 3', Primary_Quote_Exception__c  = TRUE, AccountId = acc.Id, StageName = label.Stage_1_Alignment, CloseDate = system.Today()+30,
                                         Competitors__c='No Vendor', Competitor__c = 'Other', Other_Competitors__c = 'Test Competitors', ZPA_Competitor__c='No Vendor');
        opportunity opp4 = new opportunity(Name = 'Test opportunity 4', Primary_Quote_Exception__c  = TRUE, AccountId = acc.Id, StageName = label.Stage_1_Alignment, CloseDate = system.Today()+30,
                                         Competitors__c='No Vendor', Competitor__c = 'Palo Alto Networks;Netskope', ZPA_Competitor__c='No Vendor');
        List<Opportunity> oppsToInsertList = new List<Opportunity> {opp1, opp2, opp3, opp4};
        INSERT oppsToInsertList;
        
        System.Test.startTest();
    	String query = 'SELECT Id, Competitor__c, Primary_Competitor__c, Other_Primary_competitor__c, Secondary_Competitors__c, Other_Secondary_competitor__c, Other_Competitors__c FROM Opportunity WHERE Competitor__c != null';
        Database.executeBatch(new OppCompetitorFieldUpdateBatchController(query));
        System.Test.stopTest();
    }
    
    @isTest
    static void testPrepareLogsForAsync() {
        OppCompetitorFieldUpdateBatchController batchInstance = new OppCompetitorFieldUpdateBatchController('');
        
        List<Zscaler_Error_Logs__c> zscalerErrorLogsList = new List<Zscaler_Error_Logs__c>();
        zscalerErrorLogsList.add(batchInstance.prepareLogsForAsync('execute', UserInfo.getUserId(), 'Stack Trace Not Available', 'Test Error', 'Type Not available'));
        zscalerErrorLogsList.add(batchInstance.prepareLogsForAsync('execute', UserInfo.getUserId(), 'Stack Trace Not Available', 'Test Error', 'Type Not available'));
        
        Test.startTest();
        	insert zscalerErrorLogsList;
        Test.stopTest();
        
    }
}