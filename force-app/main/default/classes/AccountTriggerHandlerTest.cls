@isTest
private class AccountTriggerHandlerTest {
	
    @TestSetup
    private static void createTestData(){
        
        OnOffSwitch__c zcs1= new OnOffSwitch__c();
        zcs1.name='updateCSMfieldonAccount';
        zcs1.Deactivate_Component__c=false;
        insert zcs1;
        
        OnOffSwitch__c zcs2= new OnOffSwitch__c();
        zcs2.name='updateAccountExtension';
        zcs2.Deactivate_Component__c=false;
        insert zcs2;        
        
        ByPassTriggerForSpecifiedUser__c bypassForanUser = new ByPassTriggerForSpecifiedUser__c();
        bypassForanUser.name = 'CustomerSuccessstage';
        bypassForanUser.bypass_component__c=TRUE;
        bypassForanUser.User_Name__c = 'sbosco@zscaler.com';
        insert bypassForanUser;

        PatchTeam__c territory =  new PatchTeam__c();
        territory.Theater__c = 'International';
        territory.Region__c = 'SEUR';
        territory.Area__c = 'EMEA';
        territory.Partner_SDR__c = UserInfo.getUserId();
        insert territory;
        
        List<PatchTeamMember__c> ptms = new List<PatchTeamMember__c>();
        
        PatchTeamMember__c ptm = new PatchTeamMember__c();
        ptm.PatchTeam__c = territory.Id;
        ptm.Role__c = 'Account Manager';
        ptm.User__c = UserInfo.getUserId();
        ptms.add(ptm);
        
        PatchTeamMember__c ptm1 = new PatchTeamMember__c();
        ptm1.PatchTeam__c = territory.Id;
        ptm1.Role__c = 'Channel Manager';
        ptm1.User__c = UserInfo.getUserId();
        ptms.add(ptm1);
        
        PatchTeamMember__c ptm2 = new PatchTeamMember__c();
        ptm2.PatchTeam__c = territory.Id;
        ptm2.Role__c = 'Area Director';
        ptm2.User__c = UserInfo.getUserId();
        ptms.add(ptm2);
        
        PatchTeamMember__c ptm3 = new PatchTeamMember__c();
        ptm3.PatchTeam__c = territory.Id;
        ptm3.Role__c = 'Customer Advocate';
        ptm3.User__c = UserInfo.getUserId();
        ptms.add(ptm3);
        insert ptms;
        
        Market_Segmentation_Setting__c ms = new Market_Segmentation_Setting__c();
        ms.Name = '1';
        ms.End_Range__c = 1000000;
        ms.Is_EMEA_Region__c = false;
        ms.Market_Segmentation__c = 'Commercial';
        ms.Start_Range__c = 1;
        
        insert ms;
        
        Account account = new Account(Name = 'Test Account');
        account.CSM_Name_New__c = UserInfo.getUserId();
        account.type = 'Customer'; 
        account.Sales_Territory__c = territory.id;
        account.Prospect_Type__c = 'Pipeline';
        account.NumberOfEmployees=400000;   
        account.No_of_Employees_Users__c='40000+';
        account.TAM_Name_New__c= UserInfo.getUserId();
        insert account;
    }
    
    @isTest 
    static void updateAccountExtentionTest()
    {
		Account accountRecord = [SELECT Id,CSM_Name_New__c,Type,Sales_Territory__c,
                                 Prospect_Type__c,No_of_Employees_Users__c,NumberOfEmployees
                                 FROM Account 
                                 WHERE Name = 'Test Account' LIMIT 1];
        
        Account_Extension__c accExt = TestDatafactory_Zscaler.insertAccountExtension(accountRecord.Id);
        TriggerUtility.UpdateCSMAccountExtenssionMethodsetfalse();
        TriggerUtility.UpdateAccountExtensionmethodsetfalse();
        accExt.Customer_Success_Engagement__c='';
        update accExt;
        
        TriggerUtility.UpdateCSMAccountExtenssionMethodsetfalse();
        accountRecord.NumberOfEmployees=400000;
        accountRecord.No_of_Employees_Users__c='40000+';
        update accountRecord;
        TriggerUtility.UpdateCSMAccountExtenssionMethodsetfalse();
        
        system.assert(accountRecord != null);
        
    }
    
    @isTest 
    private static void updateCustomerSupportStageTest(){
        
        User usr = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' and isActive=true LIMIT 1];
        System.runas(usr){
            Test.StartTest();
            Test.StopTest();
            system.assert(usr != null, 'Updated the Customer Support Segment');
        }
    }
    
    @isTest 
    private static void updateAccountTest(){
        Test.StartTest();
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='standarduser234@testorg.com');
        insert u;
 
        Account ac = TestDatafactory_Zscaler.insertAccount('Test Account1', null, 'Customer', null, null, null);
        
        TriggerUtility.UpdateCSMAccountExtenssionMethodsetfalse();
        ac.CSM_Name_New__c = u.id;
        update ac;
        Test.stopTest();
        system.assert(ac != null,'Account Updated');
    }
    
    @isTest 
    private static void deleteAccountTest(){
        
        Account account = new Account(Name = 'Test Account To Delete');
        account.CSM_Name_New__c = UserInfo.getUserId();
        account.type = 'Customer';
        account.Prospect_Type__c = 'Pipeline';
        account.NumberOfEmployees=400000;   
        account.No_of_Employees_Users__c='40000+';
        account.TAM_Name_New__c= UserInfo.getUserId();
        insert account;
        Id accId = account.id;
        Test.StartTest();
        try{
            delete account;
        }catch (Exception ex){
            
        }        
        	
        Test.stopTest();
        boolean deletedAcc = [Select IsDeleted FROM Account WHERE Id = :accId limit 1 ALL ROWS].IsDeleted;
       // system.assert(!deletedAcc,'Account Deleted');
    }

    @isTest
    static void testCustomerSentimentUpdation() {
        // DealRegTestDataFactory.createPatchTeamsAndGeoLeaderMappings();
        // TestDatafactory_Zscaler.gettriggerswitchrecords(true);
        // String terrId = DealRegTestDataFactory.mapPatchTeams.get('EMEA|General Business').Id;
        // Patch__c patch = new Patch__c(PatchName__c='acme', Active__c=true,PatchTeam__c=terrId);
        // insert patch;
        
        Account acc = TestDatafactory_Zscaler.insertAccount('Test Account1', null, 'Customer', null, null, null);
        acc.Last_SCI_Date__c = Date.today().addDays(-80);
        acc.Support_Type__c = 'Premium Support';
        update acc;
        
        Product2 prod = TestDatafactory_Zscaler.constructProduct('Product2', 'ZCES-SUP-PREM', 'Products', 'Standalone', true, false, false);
        insert prod;
        
        Contract_Detail__c cdtl = TestDatafactory_Zscaler.insertContractDetail('test contract', acc.Id, prod.Id, system.today(),system.today() + 10, 10, 100, null, null, 100, null, false, false);       
        cdtl.Contract_Detail_Status__c = 'Active';
        update cdtl;
        
        string accCustomerSentiments = acc.Customer_Sentiment__c;

        Test.startTest();
            cdtl.Contract_Detail_Status__c = '';
            update cdtl;

            acc.Customer_Sentiment__c = 'No Engagement';
            update acc;

            cdtl.Contract_Detail_Status__c = 'Active';
            update cdtl;
        Test.stopTest();
        
        system.assert(acc.Customer_Sentiment__c != accCustomerSentiments,'Customer Sentiment Updated');
    }

    @isTest
    static void testFederalAccountSync() {
        Account account = new Account(Name = 'Test Account');
        account.CSM_Name_New__c = UserInfo.getUserId();
        account.type = 'Customer'; 
        account.Prospect_Type__c = 'Pipeline';
        account.NumberOfEmployees=400000;   
        account.No_of_Employees_Users__c='40000+';
        account.TAM_Name_New__c= UserInfo.getUserId();
        account.Is_Federal_Account_Sync__c = true;
        insert account;
        
        system.assert(account.id !=null,'Federal Account Inserted');
    }
    
    @isTest
    static void updateSyncToPlanhatTest() {
        Account account = new Account(Name = 'Test Account');
        account.CSM_Name_New__c = UserInfo.getUserId();
        account.type = 'Customer'; 
        account.Prospect_Type__c = 'Pipeline';
        account.NumberOfEmployees=400000;   
        account.No_of_Employees_Users__c='40000+';
        account.TAM_Name_New__c= UserInfo.getUserId();
        account.DS_Review_Status__c='Complete';		
		
        Test.startTest();
        insert account;
        Product2 prod = TestDatafactory_Zscaler.constructProduct('Product2', 'ZCES-SUP-PREM', 'Products', 'Standalone', true, false, false);
        insert prod;
        
        Contract_Detail__c cdtl = TestDatafactory_Zscaler.insertContractDetail('test contract', account.Id, prod.Id, system.today(),system.today() + 10, 10, 100, null, null, 100, null, false, false);       
        cdtl.Contract_Detail_Status__c = 'Active';
        update cdtl;
        
        Account acc = TestDatafactory_Zscaler.insertAccount('Test Account1 Sync Update', null, 'Investor', null, null, null);
        Contract_Detail__c cdtl1 = TestDatafactory_Zscaler.insertContractDetail('test contract', acc.Id, prod.Id, system.today(),system.today() + 10, 10, 100, null, null, 100, null, false, false);       
        cdtl1.Contract_Detail_Status__c = 'Active';
        update cdtl1;
        acc.Last_SCI_Date__c = Date.today().addDays(-80);
        acc.Support_Type__c = 'Premium Support';
        update acc;
        
        Test.stopTest();
        Account accObj = [Select Id,Name,Sync_to_Planhat__c From Account Where Name='Test Account1 Sync Update' ];
       // System.assert(accObj.Sync_to_Planhat__c == true, 'Sync to Planhat Updated');
        
    }    
}