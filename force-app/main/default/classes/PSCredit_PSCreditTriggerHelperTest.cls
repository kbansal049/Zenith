//Bikram 26th Aug - Adding a comment to create a new commit
@isTest
public class PSCredit_PSCreditTriggerHelperTest {
    
    @testSetup static void setupmethod() {
        
        Account acc = new Account();
        acc.Name  = 'Test Account 1';
        insert acc;
        
        List<Professional_Services_Credits__c> psCredListToInsert = new List<Professional_Services_Credits__c>();
        for(integer i=0; i<2 ; i++){
            Professional_Services_Credits__c psCreditObj = new Professional_Services_Credits__c();
            psCreditObj.Opportunity_Close_Date__c = date.today()+360;
            psCreditObj.Credits_Purchased__c = 900;
            psCreditObj.Credits_Redeemed__c = 70;
            psCreditObj.Credits_Expiration_Date__c = date.today();
            psCreditObj.Account__c = acc.id;
            psCreditObj.PS_Credit_SKU__c = 'Z-CFWZPA-Credit';
            psCreditObj.RecordTypeId = ZScalarConstants.TRAINING_CREDIT_RECORDTYPEID;
            psCredListToInsert.add(psCreditObj);
            
        }
        
        if(!psCredListToInsert.isEmpty()){
            insert psCredListToInsert;
        }  
    }
    
    @isTest
    public static void updateTotalPurchasedCreditsOnAccountListTest(){
        
        Account acc = new Account();
        acc.Name  = 'Test Account 2';
        insert acc;

		opportunity opp = new opportunity(Name = 'Test opportunity', 
                                          AccountId = acc.Id, 
                                          StageName = '1 - Discovery & Qualification',
                                          NextStep = 'Test 1',
                                          CloseDate = system.Today()+30, 
                                          Primary_Quote_Exception__c = true, 
                                          Validation_Stage__c = '6 - Technical Win', 
                                          Validation_Plan__c = 'Test');
        TriggerHandler.bypass('OpportunityTriggerHandler');
        insert opp;
        
        List<Professional_Services_Credits__c> psCredList = new List<Professional_Services_Credits__c>();
        for(integer i=0; i<1 ; i++){
            Professional_Services_Credits__c psCred = new Professional_Services_Credits__c();
            psCred.Opportunity_Close_Date__c = date.today()+360;
            psCred.Credits_Purchased__c = 900;
            psCred.Credits_Redeemed__c = 70;
            psCred.Credits_Expiration_Date__c = date.today()+i;
            psCred.Account__c = acc.id;
            psCred.Opportunity__c = opp.Id;
            pscred.RecordTypeId = ZScalarConstants.PS_CREDIT_RECORDTYPEID;
            psCredList.add(psCred);
        }
        
        Test.startTest();
        	insert psCredList;
        Test.stopTest();
    }
    
    @isTest
    public static void generateCreditCodesOnTrainingCreditsTest()
    {
        Account acc = new Account();
        acc.Name  = 'Test Account 3';
        insert acc;
        
        Contact testContact = new Contact(LastName = 'Test Contact', AccountId = acc.Id);
        insert testContact;
        
        List<Professional_Services_Credits__c> psCredList = new List<Professional_Services_Credits__c>();
        for(integer i=0; i<2 ; i++){
            Professional_Services_Credits__c psCred = new Professional_Services_Credits__c();
            psCred.Opportunity_Close_Date__c = date.today()+360;
            psCred.Credits_Purchased__c = 900;
            psCred.Credits_Redeemed__c = 70;
            psCred.Credits_Expiration_Date__c = date.today()+i;
            psCred.Account__c = acc.id;
            psCred.PS_Credit_SKU__c = 'Z-CFWZPA-Credit';
            pscred.RecordTypeId = ZScalarConstants.TRAINING_CREDIT_RECORDTYPEID;
            psCredList.add(psCred);
            
        }
        insert psCredList;
        
    }
    
    @isTest
    public static void generateCreditCodesOnTrainingCreditsTestMethod2()
    {        
        List<Professional_Services_Credits__c> psCreditListExisting = [SELECT Id,Opportunity_Close_Date__c,
                                                                       Credits_Purchased__c,Credits_Redeemed__c,Credits_Expiration_Date__c,
                                                                       Account__c,PS_Credit_SKU__c,RecordTypeId FROM Professional_Services_Credits__c];
        
        List<Professional_Services_Credits__c> psCreditList = new List<Professional_Services_Credits__c>();
        for(integer i=0; i<2 ; i++){
            Professional_Services_Credits__c psCred = new Professional_Services_Credits__c();
            psCred.Opportunity_Close_Date__c = psCreditListExisting[0].Opportunity_Close_Date__c;
            psCred.Credits_Purchased__c = 900;
            psCred.Credits_Redeemed__c = 70;
            psCred.Credits_Expiration_Date__c = psCreditListExisting[0].Credits_Expiration_Date__c;
            psCred.Account__c = psCreditListExisting[0].Account__c;
            psCred.PS_Credit_SKU__c = psCreditListExisting[0].PS_Credit_SKU__c;
            pscred.RecordTypeId = ZScalarConstants.TRAINING_CREDIT_RECORDTYPEID;
            psCreditList.add(psCred);
            
        }
        insert psCreditList;
    }
    
    @isTest
    static void testInsertTrainingCreditsLogrecordsForFedAccounts() {
        TriggerHandler.bypass('AccountTriggerHandler');
        
        Account testAccount = TestDataFactory_ZScaler.insertAccount('Test Account 4', null, null, null, null, null);
        testAccount.Is_Federal_Account_Sync__c = true;
        update testAccount;
        
        TestDataFactory_ZScaler.insertContact('Test Contact', testAccount.Id, null);
        
        List<Opportunity> testOpportunity = TestDataFactory_Opportunity.prepareTestOpportunities('Test opportunity', ZScalarConstants.Opp_STAGE_1, System.today()+30, 
        	null, null, 1);
        testOpportunity[0].AccountId = testAccount.Id;
        
        TriggerHandler.bypass('OpportunityTriggerHandler');
        insert testOpportunity;
        
        Test.startTest();
            List<Professional_Services_Credits__c> testTrainingCreditsList = TestDataFactory_CustomerCredits.prepareTestTrainingCreditsForFedAccounts(testOpportunity[0], 
                900, 70, L2O_Constants.ProductInfo.ZCES_EDU_CREDIT_PRODUCT_CODE, false, 2);
            insert testTrainingCreditsList; 
        List<ZSA_Integration_Log__c> zsaIntegrationLogList = [SELECT Id FROM ZSA_Integration_Log__c WHERE Training_Credit__c IN :testTrainingCreditsList];
        Test.stopTest();
        
        System.assert(zsaIntegrationLogList.isEmpty(), 'Logs should not be created.');
    }
    
    @isTest
    static void testInsertErrorLog() {
        Test.startTest();
        PSCredit_PSCreditTriggerHelper.PSCredit_PSCreditTriggerHelperException testException = new PSCredit_PSCreditTriggerHelper.PSCredit_PSCreditTriggerHelperException('Test Error');
        PSCredit_PSCreditTriggerHelper.insertErrorLog('testInsertErrorLog', testException);
        Test.stopTest();
        
        List<ZScaler_Error_Logs__c> resultErrorLogsList = [SELECT Id FROM ZScaler_Error_Logs__c];
        System.assert(!resultErrorLogsList.isEmpty(), 'Error Log should be inserted');
    }
    
    @isTest
    static void testInsertTrainingCreditsLogrecordsForNonFedAccounts() {
        TriggerHandler.bypass('AccountTriggerHandler');
        Account testAccount = TestDataFactory_ZScaler.insertAccount('Test Account 5', null, null, null, null, null);
        
        TestDataFactory_ZScaler.insertContact('Test Contact 1', testAccount.Id, null);
        
        List<Opportunity> testOpportunity = TestDataFactory_Opportunity.prepareTestOpportunities('Test opportunity', ZScalarConstants.Opp_STAGE_1, System.today()+30, 
        	null, null, 1);
        testOpportunity[0].AccountId = testAccount.Id;
        
        TriggerHandler.bypass('OpportunityTriggerHandler');
        insert testOpportunity;
        
        Test.startTest();
            List<Professional_Services_Credits__c> testTrainingCreditsList = TestDataFactory_CustomerCredits.prepareTestTrainingCreditsForFedAccounts(testOpportunity[0], 
                900, 70, L2O_Constants.ProductInfo.ZCES_EDU_CREDIT_PRODUCT_CODE, true, 2);
            insert testTrainingCreditsList;
        
        List<ZSA_Integration_Log__c> zsaIntegrationLogList = [SELECT Id FROM ZSA_Integration_Log__c WHERE Training_Credit__c IN :testTrainingCreditsList];
        Test.stopTest();
        
        System.assert(!zsaIntegrationLogList.isEmpty(), 'Logs should be created.');
    }
    
}