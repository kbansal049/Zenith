@isTest
public class AccountExtVODatesBatchTest{
    
    static testmethod void test1(){
		triggerhandler.bypass('AccountTriggerHandler');
        Account account = new Account(Name = 'Test Account', type = 'Customer');
        //account.Needs_to_be_Migrated__c = true;
        insert account;
        Product2 prod = TestDatafactory_Zscaler.constructProduct('Product2', 'ZCES-SUP-PREM', 'Products', 'Standalone', true, false, false);
        insert prod;
        Contract_Detail__c cdtl = TestDatafactory_Zscaler.insertContractDetail('test contract', account.Id, prod.Id, system.today(),system.today() + 10, 10, 100, null, null, 100, null, false, false);
        cdtl.Contract_Detail_Status__c = 'Active';
        update cdtl;
        triggerhandler.clearBypass('AccountTriggerHandler');

        Id meRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal Opportunity').getRecordTypeId();
        opportunity opp = new opportunity(RecordtypeId = meRecordTypeId, Name = 'Test opportunity', AccountId = account.Id, StageName = '6 - Closed Won', SE_name__c = UserInfo.getUserId(), NextStep = 'Test 1',
                            CloseDate = system.Today()+30, Primary_Quote_Exception__c = true, Validation_Stage__c = '6 - Technical Win', Validation_Plan__c = 'Test', AD_Forecast_Category__c='Pipeline',AD_Forecast_Category_Lock__c=true, Next_Steps__c  = 'fdsjsdk', Pricebook2ID=Test.getStandardPricebookId(), contract_end_date_new__c = date.today().adddays(65));
        insert opp;
        
        User usr = [SELECT Id FROM User WHERE Username = 'dummytestdummy@zscaler.com' LIMIT 1];
        
        OpportunitySplit oppSplit = new OpportunitySplit();
        oppSplit.OpportunityId = opp.Id;
        oppSplit.Split_Type__c = 'Upsell';
        oppSplit.SplitOwnerId = usr.Id;
        oppSplit.SplitPercentage = 50; 
        insert oppSplit;
        
        AccountExtVODatesBatch batch;
        batch = new AccountExtVODatesBatch();
        Database.executeBatch(batch,1);
        
    }
    
    static testmethod void test2(){
        triggerhandler.bypass('AccountTriggerHandler');
        TriggerHandler.bypass('OpportunityTriggerHandler');
        Account account = new Account(Name = 'Test Account', type = 'Customer');
        insert account;
        Product2 prod = TestDatafactory_Zscaler.constructProduct('Product2', 'ZCES-SUP-PREM', 'Products', 'Standalone', true, false, false);
        insert prod;
        Contract_Detail__c cdtl = TestDatafactory_Zscaler.insertContractDetail('test contract', account.Id, prod.Id, system.today(),system.today() + 10, 10, 100, null, null, 100, null, false, false);
        cdtl.Contract_Detail_Status__c = 'Active';
        update cdtl;
        triggerhandler.clearBypass('AccountTriggerHandler');
        
        Id meRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Upsell Opportunity').getRecordTypeId();
        Id meRecordTypeId2 = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal Opportunity').getRecordTypeId();
        opportunity opp = new opportunity(RecordtypeId = meRecordTypeId, Name = 'Test opportunity', AccountId = account.Id, StageName = '6 - Closed Won', SE_name__c = UserInfo.getUserId(), NextStep = 'Test 1',
                            CloseDate = system.Today()+30, Primary_Quote_Exception__c = true, Type = 'Existing Customer (Add On)', Validation_Stage__c = '6 - Technical Win', Validation_Plan__c = 'Test', AD_Forecast_Category__c='Pipeline',AD_Forecast_Category_Lock__c=true, Next_Steps__c  = 'fdsjsdk', Pricebook2ID=Test.getStandardPricebookId(), contract_end_date_new__c = date.today().adddays(65));
        insert opp;
        
        opportunity opp1 = new opportunity(RecordtypeId = meRecordTypeId2, Name = 'Test opportunity', AccountId = account.Id, StageName = '6 - Closed Won', SE_name__c = UserInfo.getUserId(), NextStep = 'Test 1',
                            CloseDate = system.Today()+31, Primary_Quote_Exception__c = true, Type = 'Existing Customer (Renewal)', Validation_Stage__c = '6 - Technical Win', Validation_Plan__c = 'Test', AD_Forecast_Category__c='Pipeline',AD_Forecast_Category_Lock__c=true, Next_Steps__c  = 'fdsjsdk', Pricebook2ID=Test.getStandardPricebookId(), contract_end_date_new__c = date.today().adddays(65));
        insert opp1;
        
        User usr = [SELECT Id FROM User WHERE Username = 'dummytestdummy@zscaler.com' LIMIT 1];
        
        OpportunitySplit oppSplit = new OpportunitySplit();
        oppSplit.OpportunityId = opp1.Id;
        oppSplit.Split_Type__c = 'Upsell';
        oppSplit.SplitOwnerId = usr.Id;
        oppSplit.SplitPercentage = 50; 
        insert oppSplit;
        
        Test.startTest();
        AccountExtVODatesBatch batch;
        batch = new AccountExtVODatesBatch();
        Database.executeBatch(batch,1);
        Test.stopTest(); 
    }
    
    static testmethod void test3(){  
        Test.startTest();   
        AccountExtVODatesBatchSch sche = new AccountExtVODatesBatchSch();   
        String sch ='0 0 0 * * ?';  
        System.schedule('Notification Test', sch,sche); 
        Test.stopTest();    
    }
    
    @testSetup
    static void setupTest(){
        
        User me = [SELECT Username, Email, Alias, CommunityNickname, TimeZoneSidKey, LocaleSidKey, EmailEncodingKey, LanguageLocaleKey, ViewForecastAs__c, ForecastEnabled__c, ForecastLevel__c FROM User WHERE Id = :UserInfo.getUserId()];
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        UserRole r = [SELECT Id FROM UserRole WHERE Name = 'CEO' LIMIT 1];
        
        User usr = new User(FirstName='Test', Lastname='Dummy', ForecastLevel__c = 'Level 23', UserRoleId = r.Id, Level__c = 'Exec',
            ProfileId = p.Id, Username = 'dummytestdummy@zscaler.com', Email = me.Email, Alias = 'dumt', CommunityNickname = 'dumt',
            TimeZoneSidKey = me.TimeZoneSidKey, LocaleSidKey = me.LocaleSidKey, EmailEncodingKey = me.EmailEncodingKey,
            LanguageLocaleKey = me.LanguageLocaleKey, ForecastEnabled__c = true);
        insert usr;
        
    }

}