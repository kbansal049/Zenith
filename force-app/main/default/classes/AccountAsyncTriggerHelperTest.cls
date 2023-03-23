@IsTest 
private class AccountAsyncTriggerHelperTest {
    
    @TestSetup 
    private static void createTestData() {
        
        User usr = TestDatafactory_Zscaler.insertAdminUser('xyz@xyz.com', 'test1', 'test', 'ttest1', 'xyz@xyz.com.test', 'GMT', 'en_US', 'UTF-8', 'en_US');
        
        PatchTeam__c salestert  = new PatchTeam__c();
        salestert.District__c = 'AMERICAS';
        salestert.Theater__c = 'Americas';
        salestert.Region__c = 'AMERICAS';
        salestert.Territory__c = 'SF Bay Area 1';
        salestert.Name = 'Sales Team';
        salestert.Sales_Territory_Year__c = 'Current';
        insert salestert;      
        
        Patch__c patch  = new Patch__c();
        patch.Active__c = true;
        patch.PatchTeam__c = salestert.Id ;
        patch.PatchName__c = 'Test Patch';
        insert patch;
                
        PatchTeam__c salestert1  = new PatchTeam__c();
        salestert1.District__c = 'France';
        salestert1.Theater__c = 'EMEA';
        salestert1.Region__c = 'EMEA';
        salestert1.Territory__c = 'France';
        salestert1.Name = 'Sales Team France';
        insert salestert1;
        
        Patch__c patch1  = new Patch__c();
        patch1.Active__c = true;
        patch1.PatchTeam__c = salestert1.Id ;
        patch1.PatchName__c = 'Test Patch1';
        insert patch1;
        
        User usr2 = TestDatafactory_Zscaler.insertAdminUser('xyz2@xyz.com', 'test2', 'test2', 'ttest2', 'xyz2@xyz.com.test2', 'GMT', 'en_US', 'UTF-8', 'en_US');
        
        
        
    }
    
    @isTest
    private static void accountInsertAsyncTest() {
        //Reference 
        //https://developer.salesforce.com/docs/atlas.en-us.change_data_capture.meta/change_data_capture/cdc_trigger_testing.htm
        Test.enableChangeDataCapture();
        
        Account acc = new Account(Name = 'Test Account',
                                  Type='Prospect',
                                  BillingCountry = '',
                                  BillingState = '',
                                  BillingPostalCode = '',
                                  Domain__c = '',
                                  Industry = '',
                                  Market_Segment__c = '');
        insert acc;
        System.debug('acc FROM accountInsertAsyncTest INSERT : ' + acc);
        Test.getEventBus().deliver();
        Account newAccountRecord = [SELECT Id,Name,Type,BillingCountry,BillingState,BillingPostalCode,
                                    Domain__c,Industry,Market_Segment__c
                                    FROM Account 
                                    WHERE Name = 'Test Account'];
        newAccountRecord.Name = 'Test Account UPDATED';
        newAccountRecord.Type = 'Customer';
        newAccountRecord.BillingCountry = 'BillingCountry';
        newAccountRecord.BillingState = 'BillingState';
        newAccountRecord.BillingPostalCode = '101010';
        newAccountRecord.Domain__c = 'domain';
        newAccountRecord.Industry = 'Other';
        newAccountRecord.Market_Segment__c = 'Enterprise';
        Test.startTest();
        update newAccountRecord;
        Test.stopTest();
        System.debug('newAccountRecord FROM accountInsertAsyncTest UPDATE : ' + newAccountRecord);
        //Test.getEventBus().deliver();        
    }
    
    @isTest
    private static void accountUpdateTypeAsyncTest() {
        //Reference 
        //https://developer.salesforce.com/docs/atlas.en-us.change_data_capture.meta/change_data_capture/cdc_trigger_testing.htm
        Test.enableChangeDataCapture();
        
        Account acc = new Account(Name = 'Test Account',
                                  Type='Prospect',
                                  BillingCountry = '',
                                  BillingState = '',
                                  BillingPostalCode = '',
                                  Domain__c = '',
                                  Industry = '',
                                  Market_Segment__c = '');
        insert acc;
        System.debug('acc FROM accountInsertAsyncTest INSERT : ' + acc);
        Test.getEventBus().deliver();
        Account newAccountRecord = [SELECT Id,Name,Type,BillingCountry,BillingState,BillingPostalCode,
                                    Domain__c,Industry,Market_Segment__c
                                    FROM Account 
                                    WHERE Name = 'Test Account'];
        newAccountRecord.Name = 'Test Account';
        newAccountRecord.Type = 'Customer';
        newAccountRecord.BillingCountry = 'BillingCountry';
        newAccountRecord.BillingState = 'BillingState';
        newAccountRecord.BillingPostalCode = '101010';
        newAccountRecord.Domain__c = 'domain';
        newAccountRecord.Industry = 'Other';
        newAccountRecord.Market_Segment__c = 'Enterprise';
        Test.startTest();
        update newAccountRecord;
        Test.stopTest();
        System.debug('newAccountRecord FROM accountInsertAsyncTest UPDATE : ' + newAccountRecord);
        //Test.getEventBus().deliver();        
    }
    
    @isTest
    private static void accountUpdateBillingCountryAsyncTest() {
        //Reference 
        //https://developer.salesforce.com/docs/atlas.en-us.change_data_capture.meta/change_data_capture/cdc_trigger_testing.htm
        Test.enableChangeDataCapture();
        
        Account acc = new Account(Name = 'Test Account',
                                  Type='Prospect',
                                  BillingCountry = '',
                                  BillingState = '',
                                  BillingPostalCode = '',
                                  Domain__c = '',
                                  Industry = '',
                                  Market_Segment__c = '');
        insert acc;
        System.debug('acc FROM accountInsertAsyncTest INSERT : ' + acc);
        Test.getEventBus().deliver();
        Account newAccountRecord = [SELECT Id,Name,Type,BillingCountry,BillingState,BillingPostalCode,
                                    Domain__c,Industry,Market_Segment__c
                                    FROM Account 
                                    WHERE Name = 'Test Account'];
        newAccountRecord.Name = 'Test Account';
        newAccountRecord.Type = 'Prospect';
        newAccountRecord.BillingCountry = 'BillingCountry';
        newAccountRecord.BillingState = 'BillingState';
        newAccountRecord.BillingPostalCode = '101010';
        newAccountRecord.Domain__c = 'domain';
        newAccountRecord.Industry = 'Other';
        newAccountRecord.Market_Segment__c = 'Enterprise';
        Test.startTest();
        update newAccountRecord;
        Test.stopTest();
        System.debug('newAccountRecord FROM accountInsertAsyncTest UPDATE : ' + newAccountRecord);
        //Test.getEventBus().deliver();        
    }
    
    @isTest
    private static void accountUpdateBillingStateAsyncTest() {
        //Reference 
        //https://developer.salesforce.com/docs/atlas.en-us.change_data_capture.meta/change_data_capture/cdc_trigger_testing.htm
        Test.enableChangeDataCapture();
        
        Account acc = new Account(Name = 'Test Account',
                                  Type='Prospect',
                                  BillingCountry = '',
                                  BillingState = '',
                                  BillingPostalCode = '',
                                  Domain__c = '',
                                  Industry = '',
                                  Market_Segment__c = '');
        insert acc;
        System.debug('acc FROM accountInsertAsyncTest INSERT : ' + acc);
        Test.getEventBus().deliver();
        Account newAccountRecord = [SELECT Id,Name,Type,BillingCountry,BillingState,BillingPostalCode,
                                    Domain__c,Industry,Market_Segment__c
                                    FROM Account 
                                    WHERE Name = 'Test Account'];
        newAccountRecord.Name = 'Test Account';
        newAccountRecord.Type = 'Prospect';
        newAccountRecord.BillingCountry = 'BillingCountry';
        newAccountRecord.BillingState = 'BillingState';
        newAccountRecord.BillingPostalCode = '101010';
        newAccountRecord.Domain__c = 'domain';
        newAccountRecord.Industry = 'Other';
        newAccountRecord.Market_Segment__c = 'Enterprise';
        Test.startTest();
        update newAccountRecord;
        Test.stopTest();
        System.debug('newAccountRecord FROM accountInsertAsyncTest UPDATE : ' + newAccountRecord);
        //Test.getEventBus().deliver();        
    }
    
    @isTest
    private static void accountUpdateIndustryAsyncTest() {
        //Reference 
        //https://developer.salesforce.com/docs/atlas.en-us.change_data_capture.meta/change_data_capture/cdc_trigger_testing.htm
        Test.enableChangeDataCapture();
        
        Account acc = new Account(Name = 'Test Account',
                                  Type='Prospect',
                                  BillingCountry = '',
                                  BillingState = '',
                                  BillingPostalCode = '',
                                  Domain__c = '',
                                  Industry = '',
                                  Market_Segment__c = '');
        insert acc;
        System.debug('acc FROM accountInsertAsyncTest INSERT : ' + acc);
        Test.getEventBus().deliver();
        Account newAccountRecord = [SELECT Id,Name,Type,BillingCountry,BillingState,BillingPostalCode,
                                    Domain__c,Industry,Market_Segment__c
                                    FROM Account 
                                    WHERE Name = 'Test Account'];
        newAccountRecord.Industry = 'Other';
        Test.startTest();
        update newAccountRecord;
        Test.stopTest();
        System.debug('newAccountRecord FROM accountInsertAsyncTest UPDATE : ' + newAccountRecord);
        //Test.getEventBus().deliver();        
    }
    
    @isTest
    private static void accountUpdateMarketSegmentAsyncTest() {
        //Reference 
        //https://developer.salesforce.com/docs/atlas.en-us.change_data_capture.meta/change_data_capture/cdc_trigger_testing.htm
        Test.enableChangeDataCapture();
        
        Account acc = new Account(Name = 'Test Account',
                                  Type='Prospect',
                                  BillingCountry = '',
                                  BillingState = '',
                                  BillingPostalCode = '',
                                  Domain__c = '',
                                  Industry = '',
                                  Market_Segment__c = '');
        insert acc;
        System.debug('acc FROM accountInsertAsyncTest INSERT : ' + acc);
        Test.getEventBus().deliver();
        Account newAccountRecord = [SELECT Id,Name,Type,BillingCountry,BillingState,BillingPostalCode,
                                    Domain__c,Industry,Market_Segment__c
                                    FROM Account 
                                    WHERE Name = 'Test Account'];
        newAccountRecord.Market_Segment__c = 'Enterprise';
        Test.startTest();
        update newAccountRecord;
        Test.stopTest();
        System.debug('newAccountRecord FROM accountInsertAsyncTest UPDATE : ' + newAccountRecord);
        //Test.getEventBus().deliver();        
    }
    
    @isTest 
    private static void accountOwnerChangeTest(){
        
        Test.enableChangeDataCapture();
        
        
        TestDatafactory_Zscaler.gettriggerswitchrecords(true);
        
        OnOffSwitch__c zcs1= new OnOffSwitch__c();
        zcs1.name='updateCSMfieldonAccount';
        zcs1.Deactivate_Component__c=false;
        insert zcs1;
        
        Patch__c patch = [SELECT Id FROM Patch__c WHERE PatchName__c = 'Test Patch'];
        PatchTeam__c salestert = [SELECT Id FROM PatchTeam__c WHERE Name = 'Sales Team'];
        User usr = [SELECT Id FROM User WHERE username = 'xyz@xyz.com.test'];
        
        Account acc = new Account();
        acc.Name='AMERICAS';
        acc.Type ='Prospect';
        acc.Sales_Territory__c = salestert.Id;
        acc.Patch__c = patch.Id;
        acc.ownerId = usr.Id;
        insert acc;
        Test.getEventBus().deliver();
        Contact con = TestDatafactory_Zscaler.insertContact('AMERICAS Contact', acc.Id, null);
        Account acc1 = [SELECT Id,OwnerId FROM Account WHERE Name = 'AMERICAS'];
        User usr1 = [SELECT Id FROM User WHERE username = 'xyz2@xyz.com.test2'];
               
        
        TriggerUtility.realignPatchReset();
        TriggerUtility.prospectTypeUpdReset();
        
        acc.ownerId = usr1.Id;
        update acc;
        Test.getEventBus().deliver();
    }
    
    @isTest 
    private static void accountPatchChangeTest(){
        
        Test.enableChangeDataCapture();
        
        TestDatafactory_Zscaler.gettriggerswitchrecords(true);
        
        OnOffSwitch__c zcs1= new OnOffSwitch__c();
        zcs1.name='updateCSMfieldonAccount';
        zcs1.Deactivate_Component__c=false;
        insert zcs1;
        
        Patch__c patch = [SELECT Id FROM Patch__c WHERE PatchName__c = 'Test Patch'];
        PatchTeam__c salestert = [SELECT Id FROM PatchTeam__c WHERE Name = 'Sales Team'];
        User usr = [SELECT Id FROM User WHERE username = 'xyz@xyz.com.test'];
        
        Account acc = new Account();
        acc.Name='AMERICAS';
        acc.Type ='Prospect';
        acc.Sales_Territory__c = salestert.Id;
        acc.Patch__c = patch.Id;
        acc.ownerId = usr.Id;
        insert acc;
        Test.getEventBus().deliver();
        
        Contact con = TestDatafactory_Zscaler.insertContact('AMERICAS Contact', acc.Id, null);
        
        Account acc1 = [SELECT Id,Patch__c FROM Account WHERE Name = 'AMERICAS'];
        Patch__c patch1 = [SELECT Id FROM Patch__c WHERE PatchName__c = 'Test Patch1'];        
        
        acc1.Patch__c = patch1.Id;
        update acc1;             
        Test.getEventBus().deliver();         
        
    }

    @isTest
    static void testUpdateProductionOrgCheckboxOnZscalerCloudId() {
        Account acc = TestDatafactory_Zscaler.insertAccount('Test Account1', null, 'Customer', null, null, null);
        
        Product2 prod = TestDatafactory_Zscaler.constructProduct('Product2', 'ZIA-BUS-BUNDLE', 'Products', 'Standalone', true, false, false);
        insert prod;
        
        prod.Zscaler_Product_Family__c = 'ZIA';
        update prod;
        
        Contract_Detail__c cdtl = TestDatafactory_Zscaler.insertContractDetail('test contract', acc.Id, prod.Id, system.today(),system.today() + 10, 10, 100, null, null, 100, null, false, false);       
        cdtl.Product_SKU__c = 'ZIA-BUS-BUNDLE';
        cdtl.Is_Bundle_SKU__c = true;
        cdtl.Zscaler_Product_Family__c = 'ZIA';
        cdtl.Contract_Detail_Status__c = 'Active';        
        
        update cdtl;

        Zscaler_Cloud_ID__c ci = new Zscaler_Cloud_ID__c(Account__c = acc.id, Cloud_Type__c = 'ZIA');
        insert ci;

        Test.startTest();
            AccountAsyncTriggerHelper.updateProductionOrgCheckboxOnZscalerCloudId(new List<Account> {acc});
        Test.stopTest();
    }
}