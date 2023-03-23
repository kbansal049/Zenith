@isTest
public class AccountTriggerHelperTest {
        
    
        @isTest static void testCustomerSuccessSENames()
    {
        OnOffSwitch__c zcs1= new OnOffSwitch__c();
        zcs1.name='updateCSMfieldonAccount';
        zcs1.Deactivate_Component__c=false;
        insert zcs1;
        
        DealRegTestDataFactory.createPatchTeamsAndGeoLeaderMappings();
        TestDatafactory_Zscaler.gettriggerswitchrecords(true);
        String terrId = DealRegTestDataFactory.mapPatchTeams.get('EMEA|General Business').Id;
        Patch__c patch = new Patch__c(PatchName__c='acme', Active__c=true,PatchTeam__c=terrId);
        insert patch;
        
        system.debug('ttttttttttt' + terrId);
        Account acc = TestDatafactory_Zscaler.insertAccount('Test Account1', null, 'Customer', null, patch.Id, null);
        
        Date closeDate = system.today() + 5;
        Opportunity opp = TestDatafactory_Zscaler.insertOpportunity('Test Opp1', false, acc.Id, Label.Stage_4_Economic_Buyer_Signoff, closeDate , null, null, null, null,null, null, null, null, null, null, true);
        
        Product2 prod = TestDatafactory_Zscaler.constructProduct('Product2', 'ZCES-SUP-PREM', 'Products', 'Standalone', true, false, false);
        insert prod;
        
        Contract_Detail__c cdtl = TestDatafactory_Zscaler.insertContractDetail('test contract', acc.Id, prod.Id, system.today(),system.today() + 10, 10, 100, null, null, 100, null, false, false);       
        cdtl.Is_Bundle_SKU__c = true;
        cdtl.Zscaler_Product_Family__c = 'ZIA';
        cdtl.Contract_Detail_Status__c = 'Active';        
        update cdtl;
        
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User userOne = new User(LastName = 'User Account',
                                FirstName='Test',
                                Alias = 'tUAcc',
                                Email = 'test.test@test.com',
                                Username = 'test.testAccount@test.com',
                                ProfileId = profileId.id,
                                TimeZoneSidKey = 'GMT',
                                LanguageLocaleKey = 'en_US',
                                EmailEncodingKey = 'UTF-8',
                                LocaleSidKey = 'en_US'
                               );
        insert userOne;
        
        TriggerUtility.realignPatchReset();
        TriggerUtility.CustomerSuccessUpdatemethodsetfalse();
        TriggerUtility.updateSENameFromAccountReset();
        
        Test.StartTest();
        acc.Current_ARR__c = 24000;
        acc.DAS_Stage__c = 'stage_d2_design_completed';
        acc.X10_ZPA_Traffic_attained_date__c = system.today() - 1;
        acc.X10_Traffic_attained_date__c = system.today() - 1;
        acc.X25_ZPA_Traffic_attained_date__c = system.today() - 1;
        acc.Date_when_traffic_consumed_is_25__c = system.today() - 1;
        acc.Type = 'Customer';
        acc.Phone='4334344444';
        acc.Customer_Next_Steps__c = 'test';
        acc.CS_Business_Alignment__c=userOne.Id;
        update acc;
        Test.StopTest();  
        Account acct = [select Customer_Support_Segment__c from Account limit 1];
        //system.assert(acct.Customer_Support_Segment__c == 'Bronze');      
    }
    
    @isTest static void testProspectTypeUpdate()
    {
        OnOffSwitch__c zcs1= new OnOffSwitch__c();
        zcs1.name='updateCSMfieldonAccount';
        zcs1.Deactivate_Component__c=false;
        insert zcs1;
        
        TestDatafactory_Zscaler.gettriggerswitchrecords(true);
        
        Account acc = TestDatafactory_Zscaler.insertAccount('Test Account1', null, 'Customer', null, null, null);
        Test.StartTest();
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User userOne = new User(LastName = 'User Account',
                                FirstName='Test',
                                Alias = 'tUAcc',
                                Email = 'test.test@test.com',
                                Username = 'test.testAccount@test.com',
                                ProfileId = profileId.id,
                                TimeZoneSidKey = 'GMT',
                                LanguageLocaleKey = 'en_US',
                                EmailEncodingKey = 'UTF-8',
                                LocaleSidKey = 'en_US'
                               );
        insert userOne;
        
        Date closeDate = system.today() + 5;        
        Opportunity opp = TestDatafactory_Zscaler.insertOpportunity('Test Opp1', false, acc.Id, label.Stage_6_Closed_Won, closeDate, null, null, null, null,null, null, null, null, null, null, true);
        
        Opportunity opp1 = TestDatafactory_Zscaler.insertOpportunity('Test Opp1', false, acc.Id, Label.Stage_4_Economic_Buyer_Signoff, closeDate , null, null, null, null,null, null, null, null, null, null, true);        
        
        TriggerUtility.realignPatchReset();
        TriggerUtility.prospectTypeUpdReset();
        
        
        Event evt = TestDatafactory_Zscaler.insertEvent(system.today() - 1, system.Today() + 5, acc.Id); 
        evt.Type = System.Label.Other_Regular_Meeting;
        evt.peopleai__MeetingStatus__c = 'Scheduled';
        update evt;
        
        acc.Type = 'Prospect';
        acc.CS_Business_Alignment__c=userOne.Id;
        update acc;
        Test.StopTest();
        
        Account acct = [select Prospect_Type__c from Account limit 1];
        //system.assert(TriggerUtility.isProspectUpdateExecuted() == true);   
    }
    
    
    
    @isTest static void testOwnerChange()
    {
        TestDatafactory_Zscaler.gettriggerswitchrecords(true);
        
        OnOffSwitch__c zcs1= new OnOffSwitch__c();
        zcs1.name='updateCSMfieldonAccount';
        zcs1.Deactivate_Component__c=false;
        insert zcs1;
        
        Account acc = TestDatafactory_Zscaler.insertAccount('Test Account1', null, 'Customer', null, null, null);
        
        User usr = TestDatafactory_Zscaler.insertAdminUser('xyz@xyz.com', 'test1', 'test', 'ttest1', 'xyz@xyz.com.test', 'GMT', 'en_US', 'UTF-8', 'en_US');
        
        Contact con = TestDatafactory_Zscaler.insertContact('Test Account1', acc.Id, null);
        
        TriggerUtility.realignPatchReset();
        TriggerUtility.prospectTypeUpdReset();
        
        Test.StartTest();
        acc.ownerId = usr.Id;
        update acc;
        acc.Customer_Sentiment__c='No Engagement';
        update acc;
        acc.type='Ex-Customer';
        acc.Customer_Sentiment__c='Lost';
        update acc;
        
        
        
        Test.StopTest();
        Account acct = [select ownerId from Account limit 1];
        
        system.assert(acct.ownerId == usr.Id); 
        
        
    }
    
    @isTest static void testActivitytoTerr()
    {
        OnOffSwitch__c zcs1= new OnOffSwitch__c();
        zcs1.name='updateSalesTeamBlankifSTnotchng';
        zcs1.Deactivate_Component__c=false;
        insert zcs1;
        
        DealRegTestDataFactory.createPatchTeamsAndGeoLeaderMappings();
        TestDatafactory_Zscaler.gettriggerswitchrecords(true);
                
        String terrId = DealRegTestDataFactory.mapPatchTeams.get('EMEA|General Business').Id;
        String terr1Id = DealRegTestDataFactory.mapPatchTeams.get('APAC|All').Id;
        
        List<PatchTeamMember__c> lstPatchTeamMembersToInsert = new List<PatchTeamMember__c>();
        lstPatchTeamMembersToInsert.add(new PatchTeamMember__c(PatchTeam__c = terrId,Role__c = 'Customer Advocate',User__c = UserInfo.getUserId()));
        lstPatchTeamMembersToInsert.add(new PatchTeamMember__c(PatchTeam__c = terrId,
                                                               Role__c = 'Sales Engineer',User__c = UserInfo.getUserId()));
        lstPatchTeamMembersToInsert.add(new PatchTeamMember__c(PatchTeam__c = terrId,
                                                               Role__c = 'ZPA Manager',User__c = UserInfo.getUserId()));
        lstPatchTeamMembersToInsert.add(new PatchTeamMember__c(PatchTeam__c = terrId,Role__c = 'ZPA SE',User__c = UserInfo.getUserId()));
        lstPatchTeamMembersToInsert.add(new PatchTeamMember__c(PatchTeam__c = terrId,Role__c = 'Lead Development',User__c = UserInfo.getUserId()));
        lstPatchTeamMembersToInsert.add(new PatchTeamMember__c(PatchTeam__c = terr1Id,Role__c = 'Lead Development',User__c = UserInfo.getUserId()));
        insert lstPatchTeamMembersToInsert;
        
        List<Patch__c> patchList = new List<Patch__c> ();
        Patch__c patch = new Patch__c(PatchName__c='acme', Active__c=true,PatchTeam__c=terrId);
        patch = new Patch__c(PatchName__c='APAC', Active__c=true,PatchTeam__c=terr1Id);
        patchList.add(patch);
        insert patchList;
        
        
        Account acc = TestDatafactory_Zscaler.insertAccount('Test Account1', null, 'Customer', null, patch.Id, 25);
        Account acc1 = TestDatafactory_Zscaler.insertAccount('Test Account2', null, 'Customer', null,null, 25);
        TriggerUtility.realignPatchReset();
        
        Task tsk = TestDatafactory_Zscaler.insertTask('test1', 'New', 'Normal', acc.Id);
        Event evt = TestDatafactory_Zscaler.insertEvent(system.today(), system.Today() + 5, acc.Id);
        
        Test.StartTest(); 
        List<Account> acclist = new List<Account>();
        acc.Name = 'Test Account';
        acclist.add(acc);
        acc1.Name = 'Test Account3';
        acclist.add(acc1);
        TriggerUtility.AcctoActivityTerritoryReset();
        update acclist;        
        Test.StopTest();
        
        Task tsk1 = [select Sales_Territory__c from Task limit 1];
        acc = [select Sales_Territory__r.Name from Account limit 1];
        //system.assert(tsk1.Sales_Territory__c == acc.Sales_Territory__r.Name);   
                
        acc.Sales_Territory__c = NULL;
        UPDATE acc;
    }
    
    @isTest static void testCustomerSuccessUpd2()
    {
        OnOffSwitch__c zcs1= new OnOffSwitch__c();
        zcs1.name='updateCSMfieldonAccount';
        zcs1.Deactivate_Component__c=false;
        insert zcs1;
        
        TestDatafactory_Zscaler.gettriggerswitchrecords(true);
        
        Account acc = TestDatafactory_Zscaler.insertAccount('Test Account1', null, 'Customer', null, null, null);
        
        Date closeDate = system.today() + 5;
        Opportunity opp = TestDatafactory_Zscaler.insertOpportunity('Test Opp1', false, acc.Id, Label.Stage_4_Economic_Buyer_Signoff, closeDate , null, null, null, null,null, null, null, null, null, null, true);
        
        Product2 prod = TestDatafactory_Zscaler.constructProduct('Product2', 'ZIA-BUS-BUNDLE', 'Products', 'Standalone', true, false, false);
        insert prod;
        prod.Zscaler_Product_Family__c = 'ZIA';
        update prod;
        
        TriggerUtility.realignPatchReset();
        TriggerUtility.CustomerSuccessUpdatemethodsetfalse();
        
        Contract_Detail__c cdtl = TestDatafactory_Zscaler.insertContractDetail('test contract', acc.Id, prod.Id, system.today(),system.today() + 10, 10, 100, null, null, 100, null, false, false);       
        cdtl.Product_SKU__c = 'ZIA-BUS-BUNDLE';
        cdtl.Is_Bundle_SKU__c = true;
        cdtl.Zscaler_Product_Family__c = 'ZIA';
        cdtl.Contract_Detail_Status__c = 'Active';        
        
        update cdtl;
        
        Test.StartTest();
        acc.Date_when_traffic_consumed_is_25__c = system.today();       
        acc.First_ZPA_Contract_Date__c = system.today();
        acc.Last_QBR_Date__c = system.today();
        TriggerUtility.CustomerSuccessUpdatemethodsetfalse();        
        update acc;
        Test.StopTest();        
        
    }
    
    @isTest static void testDateRange()
    {
        TestDatafactory_Zscaler.gettriggerswitchrecords(true);
        
        Account acc = TestDatafactory_Zscaler.insertAccount('Test Account1', null, 'Customer', null, null, null);
        acc.Legal_Certification_Date__c = system.today() - 1;
        acc.Legal_Questionaire_Date__c = system.today() - 1;
        acc.Arch_workshop_next_steps__c = 'test';
        
        List<Account> NewAccountList = new List<Account>();
        NewAccountList.add(acc);
        
        Account accClone = acc.clone();
        accClone.Id = acc.Id;
        accClone.Legal_Certification_Date__c = system.today();
        accClone.Legal_Questionaire_Date__c  = system.today();
        accClone.Arch_workshop_next_steps__c = 'test1';
        
        Map<Id, Account> accountOldMap = new Map<Id, Account>();
        accountOldMap.put(accClone.Id, accClone);
          
        
        Test.StartTest();
        AccountTriggerHelper.UpdateDateRange(NewAccountList, accountOldMap);
        
        AccountTriggerHelper.UpdateDateRange(NewAccountList);
        
        AccountTriggerHelper.updateArchitectureNextStepsHistory(accountOldMap, NewAccountList);
        AccountTriggerHelper.updateEntitlement(NewAccountList,accountOldMap);
        
        
        //Moved the code to async
        //AccountTriggerHelper.changeRelatedContactsOwner(NewAccountList,accountOldMap);
        
        Test.StopTest();
    }
    
    @isTest static void testAccountExtMarketSegment()
    {
        TestDatafactory_Zscaler.gettriggerswitchrecords(true);
        
        Account acc = TestDatafactory_Zscaler.insertAccount('Test Account1', null, 'Customer', null, null, null);
        Account_Extension__c accExt = TestDatafactory_Zscaler.insertAccountExtension(acc.Id);
        accExt.Customer_Success_Engagement__c='';
        //acc.No_of_Employees_Users__c='40000+';
        //acc.NumberOfEmployees=22;
        List<Account> NewAccountList = new List<Account>();
        NewAccountList.add(acc);
        TriggerUtility.accountExtensionHistoryExecuted = false;
        acc.Architecture_Workshop_Link__c = 'test';
        //acc.NumberOfEmployees=22;
        acc.Prospect_Type__c = 'Pipeline';
        acc.No_of_Employees_Users__c='0 - 99';
        update acc;
        
        Account accClone = acc.clone();
        accClone.Id = acc.Id;
        accClone.Architecture_Workshop_Link__c = 'test1';        
        accClone.NumberOfEmployees=20001;
        acc.No_of_Employees_Users__c='20000 - 39999';
        Map<Id, Account> accountOldMap = new Map<Id, Account>();
        accountOldMap.put(accClone.Id, accClone);
        
        Test.StartTest();        
        AccountTriggerHelper.createAccountExtensionHistory(accountOldMap, NewAccountList, true);
        //AccountTriggerHelper.SendEmailtoCSM(NewAccountList,accountOldMap);
        Market_Segmentation_Setting__c ms = new Market_Segmentation_Setting__c();
        ms.Name = '1';
        ms.End_Range__c = 1000000;
        ms.Is_EMEA_Region__c = false;
        ms.Market_Segmentation__c = 'Commercial';
        ms.Start_Range__c = 1;
        
        insert ms;
        
        Account_Extension_History__c accountHistory = new Account_Extension_History__c();
        accountHistory.Account__c = acc.Id;
        insert accountHistory;
        
        
        AccountTriggerHelper.UpdateMarketSegment(NewAccountList, accountOldMap, true, true);
        //AccountTriggerHelper.UpdateCSMAccountExtenssionMethod(NewAccountList, accountOldMap);
        Test.StopTest();        
        
    }
    
    @isTest static void testAccountExtMarket()
    {
        TestDatafactory_Zscaler.gettriggerswitchrecords(true);
        
        Account acc = TestDatafactory_Zscaler.insertAccount('Test Account1', null, 'Customer', null, null, null);
        Account_Extension__c accExt = TestDatafactory_Zscaler.insertAccountExtension(acc.Id);
        List<Account> NewAccountList = new List<Account>();
        NewAccountList.add(acc);
        TriggerUtility.accountExtensionHistoryExecuted = false;
        acc.Architecture_Workshop_Link__c = 'test';
        acc.NumberOfEmployees=22;
        acc.Prospect_Type__c = 'Pipeline';
        acc.No_of_Employees_Users__c='0 - 99';
        update acc;
        
        Account accClone = acc.clone();
        accClone.Id = acc.Id;
        accClone.Architecture_Workshop_Link__c = 'test1';        
        accClone.NumberOfEmployees=20001;
        acc.No_of_Employees_Users__c='20000 - 39999';
        Map<Id, Account> accountOldMap = new Map<Id, Account>();
        accountOldMap.put(accClone.Id, accClone);
        
        Test.StartTest();
        Market_Segmentation_Setting__c ms = new Market_Segmentation_Setting__c();
        ms.Name = '1';
        ms.End_Range__c = 1000000;
        ms.Is_EMEA_Region__c = false;
        ms.Market_Segmentation__c = 'Commercial';
        ms.Start_Range__c = 1;
        insert ms;
        AccountTriggerHelper.UpdateMarketSegment(NewAccountList, accountOldMap, true, true);
        Test.StopTest();
    }
    
    
    @isTest 
    static void test1()
    {
        PatchTeam__c territory =  new PatchTeam__c();
        territory.Theater__c = 'International';
        territory.Region__c = 'SEUR';
        territory.Area__c = 'EMEA';
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
        account.Type = 'Customer'; 
        account.Sales_Territory__c = territory.id;
        account.Prospect_Type__c = 'Pipeline';
        account.No_of_Employees_Users__c='40000+';    
        insert account;
        
        Account_Extension__c accExt = TestDatafactory_Zscaler.insertAccountExtension(account.Id);
        TriggerUtility.UpdateCSMAccountExtenssionMethodsetfalse();
        TriggerUtility.UpdateAccountExtensionmethodsetfalse();
        accExt.Customer_Success_Engagement__c='';
        update accExt;
        
        TriggerUtility.UpdateCSMAccountExtenssionMethodsetfalse();
        account.NumberOfEmployees=400000;
        account.No_of_Employees_Users__c='40000+';
        update account;
        TriggerUtility.UpdateCSMAccountExtenssionMethodsetfalse();
        
    }
    
    @isTest 
    static void test2()
    {
        OnOffSwitch__c ofs = new OnOffSwitch__c();
        ofs.Name = 'updateSalesTeamBlankifSTnotchng';
        ofs.Deactivate_Component__c = false;
        insert ofs;
        
        Account account = new Account(Name = 'Test Account');
        account.CSM_Name_New__c = UserInfo.getUserId();
        account.type = 'Customer'; 
        insert account;
        
        List<Account> accs = new List<Account>();
        accs.add(account);
        AccountTriggerHelper.getAccSalesTeam(accs,null);
    }
    
    @isTest 
    static void test3()
    {
        PatchTeam__c territory =  new PatchTeam__c();
        territory.Theater__c = 'International';
        territory.Region__c = 'SEUR';
        territory.Area__c = 'EMEA';
        insert territory;
        
        List<PatchTeamMember__c> ptms = new List<PatchTeamMember__c>();
        
        PatchTeamMember__c ptm = new PatchTeamMember__c();
        ptm.PatchTeam__c = territory.Id;
        ptm.Role__c = 'Account Manager';
        ptm.User__c = UserInfo.getUserId();
        ptms.add(ptm);
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
        Account_Extension__c accExt = TestDatafactory_Zscaler.insertAccountExtension(account.Id);
        accExt.Customer_Success_Engagement__c='';
        update accExt;
        
    }
    
    @isTest static void testProspectType()
    {Test.StartTest();
        OnOffSwitch__c zcs1= new OnOffSwitch__c();
        zcs1.name='updateCSMfieldonAccount';
        zcs1.Deactivate_Component__c=false;
        insert zcs1;
     	
     	TriggerHandler.bypass('AccountTriggerHandler');
     	TriggerHandler.bypass('OpportunityTriggerHandler');
        
        TestDatafactory_Zscaler.gettriggerswitchrecords(true);
        
        Account acc = TestDatafactory_Zscaler.insertAccount('Test Account1', null, 'Customer', null, null, null);
        
        Date closeDate = system.today() + 5;        
        Opportunity opp = TestDatafactory_Zscaler.insertOpportunity('Test Opp1', false, acc.Id, label.Stage_6_Closed_Won, closeDate, null, null, null, null,null, null, null, null, null, null, true);
        Date closeDate1 = system.today() + 35;
        Opportunity opp1 = TestDatafactory_Zscaler.insertOpportunity('Test Opp1', false, acc.Id, Label.Stage_4_Economic_Buyer_Signoff, closeDate1 , null, null, null, null,null, null, null, null, null, null, true);        
        
        TriggerHandler.clearBypass('AccountTriggerHandler');
     	TriggerHandler.clearBypass('OpportunityTriggerHandler');
        
        TriggerUtility.realignPatchReset();
        TriggerUtility.prospectTypeUpdReset();
        
        Event evt = TestDatafactory_Zscaler.insertEvent(system.today() - 1, system.Today() + 5, acc.Id); 
        evt.Type = System.Label.Other_Regular_Meeting;
        evt.peopleai__MeetingStatus__c = 'Scheduled';
        update evt;
        acc.Support_Type__c = 'Premium Support';
        acc.Type = 'Prospect';
        //acc.Support_Type__c = 'Premium Plus Support';
        acc.Type = 'Customer';
        update acc;
        Test.StopTest();
    }
    
    @IsTest
    static void updatePartnerDiscountTest()
    {
        Test.startTest();

        List<Account> newAccountList = new List<Account>();
        Account account = new Account(Name = 'Test Account');
        account.CSM_Name_New__c = UserInfo.getUserId();
        account.type = 'Partner'; 
        account.Program_Type__c = 'Reseller';
        account.Model_Type_Partner__c = 'Traditional'; 
        account.Partner_Tier__c = 'Alpine';
        account.Avg_estimated_users_L31D__c  = 100;
        account.ZPA_Enrolled_Users_L31D__c = 100; 
        insert account;
        Account account2 = new Account(Name = 'Test Account');
        account2.CSM_Name_New__c = UserInfo.getUserId();
        account2.type = 'Customer'; 
        account2.Model_Type_Partner__c = 'Traditional'; 
        account2.Partner_Tier__c = 'Alpine';
        account2.Avg_estimated_users_L31D__c  = 100;
        account2.ZPA_Enrolled_Users_L31D__c = 100; 
        insert account2;
        newAccountList.add(account);
        newAccountList.add(account2);
        Account_Extension__c accExt = TestDatafactory_Zscaler.insertAccountExtension(account2.Id);
        accExt.Customer_Success_Engagement__c='';
        update accExt;
        List<Account> accs = new List<Account>();
        Product2 prod = TestDatafactory_Zscaler.constructProduct('Product2', 'ZCES-SUP-PREM', 'Products', 'Standalone', true, false, false);
        insert prod;
        
        accs.add(account);
        //update accs;
        //AccountTriggerHelper.updatePartnerDiscounts(accs,null);
        //AccountTriggerHelper.updatePartnerTierMargins(accs);
        TriggerUtility.UpdateCSMAccountExtenssionMethodsetfalse();
        update account2;
        Test.stopTest();
    }
    
    @isTest
    static void updateSkipTAMReassignmentOnChildCasesTest()
    {
        User usr = TestDatafactory_Zscaler.insertAdminUser('xyz@xyz.com', 'test1', 'test', 'ttest1', 'xyz@xyz.com.test', 'GMT', 'en_US', 'UTF-8', 'en_US');
        Account account = TestDatafactory_Zscaler.insertAccount('Test Account', 'test@test.com', 'Customer',null, null, 5);
        account.TAM_Name_New__c=usr.id;
        account.CSM_Name_New__c=usr.id;
        account.Skip_TAM_Reassignments__c = true;
        account.Type = 'Customer';
        account.DS_Review_Status__c='';
        update account;
        Contact cont = TestDatafactory_Zscaler.insertContact('Test Contact', account.Id, null);
        Id caseSupportRT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Support').getRecordTypeId();
        TriggerUtility.SkipCaseTriggerExecuted();
        Case  cs = TestDatafactory_Zscaler.insertCase('status', 'subject',  'description',  account.Id, null, account.Id, caseSupportRT);   
        Case caseTest = [select id, is_TAm_Account__c, TAM_Reassignment__c, Case_Type__c,Status from Case where Id=:cs.Id limit 1];
        caseTest.TAM_Reassignment__c=false;
        caseTest.Case_Type__c='Problem';            
        update caseTest;
        System.debug('CaseTest-->'+ caseTest);
        System.debug('Case Details 1-->'+caseTest.Case_Type__c+caseTest.Status);
        System.debug('Case Details 2-->'+caseTest.Is_TAM_Account__c+caseTest.TAM_Reassignment__c);
        Skip_Triggers_User_Based__c skp = new Skip_Triggers_User_Based__c();
        skp.SetupOwnerId = UserInfo.getUserId();
        skp.Object_s_to_skip__c = 'Account';
        insert skp;
        Account account2 = TestDatafactory_Zscaler.insertAccount('Test Account', 'test@test.com', 'Customer','01270000000EAFsAAO', null, 5);
        system.debug(account2);
        account2.Type='Customer';
        account2.CSM_Name_New__c=usr.id;
        TriggerUtility.SkipAccTriggerExecuted();
        update account2; 
        Account_Extension__c accExt = TestDatafactory_Zscaler.insertAccountExtension(account2.Id);
        accExt.Customer_Success_Engagement__c ='';
        update accExt;

        List<Account> acclist=new List<Account>();
        acclist.add(account2);
        //AccountTriggerHelper.UpdateCSMAccountExtenssionMethod(acclist,null);
        TriggerUtility.SkipAccTriggerReset(); 
        acclist.add(account);
        //AccountTriggerHelper.updateSkipTAMReassignmentOnChildCases(null,acclist);
    }
    
    @isTest static void testAccountExtenson() {
        
        OnOffSwitch__c zcs2= new OnOffSwitch__c();
        zcs2.name='updateAccountExtension';
        zcs2.Deactivate_Component__c=false;
        insert zcs2;
        
        List<PatchTeam__c> territoryList = new List<PatchTeam__c> ();
        
        PatchTeam__c territory =  new PatchTeam__c();
        territory.Theater__c = 'International';
        territory.Region__c = 'SEUR';
        territory.Area__c = 'EMEA';
        territory.Territory_Type__c='Major';
        territoryList.add(territory);
        
        territory =  new PatchTeam__c();
        territory.Theater__c = 'EMEA';
        territory.Region__c = 'NEUR';
        territory.Area__c = 'Benelux';
        territory.Territory_Type__c='Enterprise';
        territoryList.add(territory);
        
        //TriggerUtility.realignPatch();
        
        INSERT territoryList;
        
        TriggerUtility.realignPatchReset();
        
        
        
        TestDatafactory_Zscaler.gettriggerswitchrecords(true);
        
        Account acc = TestDatafactory_Zscaler.insertAccount('Test Account1', null, 'Customer', null, null, null);        
        Account accParent = TestDatafactory_Zscaler.insertAccount('Test Account Parent1', null, 'Customer', null, null, null);                
        acc.Ultimate_Parent_Account__c = accParent.Id;
        
        update acc;
        
        Contact cont = TestDatafactory_Zscaler.insertContact('Test Contact', accParent.Id, null);
        Account_Extension__c accExt = TestDatafactory_Zscaler.insertAccountExtension(acc.Id);
        accExt.Customer_Success_Engagement__c = Null;
        update accExt;
        TriggerUtility.UpdateAccountExtensionmethodsetfalse();
        
        User usr = TestDatafactory_Zscaler.insertAdminUser('xyz@xyz.com', 'test1', 'test', 'ttest1', 'xyz@xyz.com.test', 'GMT', 'en_US', 'UTF-8', 'en_US');
        User usr1 = TestDatafactory_Zscaler.insertAdminUser('xyz1@xyz.com', 'test2', 'test2', 'ttest2', 'xyz1@xyz.com.test', 'GMT', 'en_US', 'UTF-8', 'en_US');
        Test.StartTest();
        acc.Summarize_the_Value_to_the_Customer__c = 'test';
        acc.CS_Management_Notes__c = 'test';
        acc.Customer_Next_Steps__c = 'test';
        acc.Architecture_Workshop_Link__c = 'test';
        acc.Arch_workshop_next_steps__c = 'test';
        acc.ZSR_Link__c = 'test';
        acc.HeadOfIT__c = cont.Id;
        acc.HeadOfSecurity__c = cont.Id;
        acc.HeadOfNetworking__c = cont.Id;
        acc.Head_of_Architecture__c = cont.Id;
        acc.Prospect_Type__c = 'Pipeline';
        acc.type='Customer';
        //added by swathi: CR1116 start
        acc.accountBuyingStage6sense_ZIA__c = 'Purchase'; 
        acc.accountBuyingStage6sense_ZPA__c = 'Purchase';
        //acc.Customer_Success_Engagement__c = '';
        //added by swathi: CR1116 end
        update acc;
        
        TriggerUtility.UpdateAccountExtensionmethodsetfalse();
        
        acc.HeadOfIT__c = null;
        acc.HeadOfSecurity__c = null;
        acc.HeadOfNetworking__c = null;
        acc.Head_of_Architecture__c = null;
        //added by swathi: CR1116 start
        acc.accountBuyingStage6sense_ZIA__c = 'Decision';
        acc.accountBuyingStage6sense_ZPA__c = 'Decision';
        acc.Account_Manager__c=usr.id;
        //added by swathi: CR1116 End
        update acc;    
        acc.Account_Manager__c=usr1.id;
        acc.type='Ex-Customer';
        acc.Date_when_traffic_consumed_is_25__c = system.today();
        acc.Design_Completed_Date__c = system.today();
        acc.Deployment_Phase_Risk__c = 'Design Complete Over Due';
        update acc;
        acc.Kick_Off_Call_Date__c = system.today();
        acc.Deployment_Phase_Risk__c = 'Kick Off Over Due';
        acc.Success_Stage__c='0 - Not Started';
        acc.Sales_Territory__c = territoryList.get(0).Id;
        update acc;
        
        acc.Type='Partner';
        acc.Program_Type__c = 'Reseller';
        acc.Billing_Frequency__c='';
        acc.Payment_Terms__c='';
        acc.Success_Stage__c='4 - Transformation in Progress (25%+ Deployed)';
        acc.DS_Review_Status__c='Complete';
        acc.Sales_Territory__c = territoryList.get(1).Id;
        update acc;
        delete cont;
        acc.DS_Review_Status__c='Complete';
        update acc;
        
        Test.StopTest();
        Account_Extension__c accex = [select CS_Management_Notes__c,Customer_Success_Engagement__c from Account_Extension__c limit 1];
        //system.assert(accex.CS_Management_Notes__c == 'test');      
    }
    
    
    @isTest static void testFedAccs()
    {
        OnOffSwitch__c zcs1= new OnOffSwitch__c();
        zcs1.name='updateCSMfieldonAccount';
        zcs1.Deactivate_Component__c=false;
        insert zcs1;
        
        TestDatafactory_Zscaler.gettriggerswitchrecords(true);
        
        Account acc = new Account();
        acc.Name = 'Test account';
        acc.Type= 'Prospect';
        acc.Is_Federal_Account_Sync__c = TRUE;
        acc.DS_Review_Status__c = 'Complete';

        insert acc;
        
        Contract_Detail__c con = new Contract_Detail__c();
        con.Account_Name__c = acc.Id;        
        con.Start_Date__c = Date.today();
        con.Product_SKU__c = 'ZIA-TRANS-EDITION';
        con.Is_Bundle_SKU__c  = TRUE;
        INSERT con;
        
        acc.Name = acc.Name + ' updated';
        UPDATE acc;
        
        Date closeDate = System.today() + 5;        
        Opportunity opp = TestDatafactory_Zscaler.insertOpportunity('Test Opp1', false, acc.Id, label.Stage_6_Closed_Won, closeDate, null, null, null, null,null, null, null, null, null, null, true);
        
       // Opportunity opp1 = TestDatafactory_Zscaler.insertOpportunity('Test Opp1', false, acc.Id, Label.Stage_4_Economic_Buyer_Signoff, closeDate , null, null, null, null,null, null, null, null, null, null, true);        
        
        TriggerUtility.realignPatchReset();
        TriggerUtility.prospectTypeUpdReset();
        
        Test.StartTest();
        
        
        acc.Type = 'Prospect';
        update acc;
        Test.StopTest();  
    }
    
    @isTest static void updateAccountExtensionCheckBox(){
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.Type= 'Prospect';
        insert acc;
        Test.startTest();
        Account_Extension__c accExtension = new Account_Extension__c();
        accExtension.Account__c = acc.Id;
        Test.stopTest();
        //acc.Avg_Estimated_Users_L31D_Vs_Purchase__c = '26';
        //acc.ZPA_Enrolled_users_L31D_Vs_Purchase__c = 26;
        
    }
    @isTest static void UpdateCSMAccountExtension(){
        Account acct = new Account();
        acct.Name ='Test Account';
        acct.Type ='Customer';
        acct.CSM_Name_New__c = UserInfo.getUserId();
        insert acct;
        Set<Id> accIdSet = new Set<Id>();
        accIdSet.add(acct.Id);
        
        test.startTest();
        Account_Extension__c accExt = new Account_Extension__c ();
        accExt.Account__c = acct.Id;
        accExt.Override_CS_Engagement__c = false;
        AccountTriggerHelper.UpdateCSMAccountExtenssionMethod(accIdSet);
        AccountTriggerHelper.UpdateCSMAccountExtenssionMethodAsync(accIdSet);
        test.stopTest();
        
        
    }
    
    @isTest static void updateProspectTypeOnAccount(){
        
        PatchTeam__c salestert  = new PatchTeam__c();
        salestert.District__c = 'District 1';
        salestert.Theater__c = 'AMER';
        salestert.Region__c = 'Central';
        salestert.Territory__c = 'SF Bay Area 1';
        salestert.Name = 'Sales Team';
        insert salestert;
        
        PatchTeam__c salestert1  = new PatchTeam__c();
        salestert1.District__c = 'District 1';
        salestert1.Theater__c = 'AMERICAS';
        salestert1.Region__c = 'US West';
        salestert1.Territory__c = 'US South West';
        salestert1.Name = 'Sales Team';
        insert salestert1;
        
        PatchTeamMember__c SalesTeamMem6 = new PatchTeamMember__c();
        SalesTeamMem6.Role__c = 'ZPA Manager';
        SalesTeamMem6.PatchTeam__c = salestert.Id;
        SalesTeamMem6.User__c = userinfo.GetuserId();
        insert SalesTeamMem6 ;
        
        PatchTeamMember__c SalesTeamMem7 = new PatchTeamMember__c();
        SalesTeamMem7.Role__c = 'ZPA SE';
        SalesTeamMem7.PatchTeam__c = salestert1.Id;
        SalesTeamMem7.User__c = userinfo.GetuserId();
        insert SalesTeamMem7 ;
        
        Patch__c patch  = new Patch__c();
        patch.Active__c = true;
        patch.PatchTeam__c = salestert.Id ;
        patch.PatchName__c = 'Test Patch';
        insert patch;
        
        
        Patch__c patch1  = new Patch__c();
        patch1.Active__c = true;
        patch1.PatchTeam__c = salestert1.Id ;
        patch1.PatchName__c = 'Test Patch';
        insert patch1;
        
        Account acct = new Account();
        acct.Name = 'Test Account';
        insert acct;
          
        test.startTest();
        List<Account> accList = new List<Account>();
        accList.add(acct);
        Opportunity opp = new Opportunity();
        opp.AccountId = acct.Id;
        AccountTriggerHelper ath = new AccountTriggerHelper();
        ath.updateProspectTypeOnAccount(accList);
        
        test.stopTest();
        
    }
    
    @isTest static void updateSENamesInOpportunity(){
        
        User adminUser =  SB_TestCPQDataUtility.createUsers(1, 'system', 'Administrator1' , 'System Administrator')[0];
        insert adminUser;
       
        Test.startTest();
        
        List<Account> accList = new List<Account>();
        
        Account acc = new Account();
        acc.Name ='Test Account';
        acc.Sales_Engineer__c = System.UserInfo.getUserId();
        accList.add(acc);
        
        Account acc1 = new Account();
        acc1.Name ='Test Account1';
        acc1.Sales_Engineer__c = NULL;
        
        accList.add(acc1);
        
        INSERT accList;
        
        Account accUpdate = new Account ();
        accUpdate.Id = accList.get(0).Id;
        accUpdate.Sales_Engineer__c = adminUser.Id;
        
        Map<Id, Account> accountOldMap = new Map<Id, Account>();
        accountOldMap.put(accList.get(0).Id, accUpdate);
        
        accUpdate = new Account ();
        accUpdate.Id = accList.get(1).Id;
        accUpdate.Sales_Engineer__c = adminUser.Id;
        
        accountOldMap.put(accList.get(1).Id, accUpdate);
        
        List<Opportunity> oppList = new List<Opportunity> ();
        Opportunity opp = new Opportunity();
        opp.Name ='Test opportunity';
        opp.AccountId = accList.get(0).Id;
        opp.StageName = '4 - Impact Validation';
        opp.CloseDate = System.Date.today() + 365;
        oppList.add(opp);
        
        opp = new Opportunity();
        opp.Name ='Test opportunity';
        opp.AccountId = accList.get(1).Id;
        opp.StageName = '4 - Impact Validation';
        opp.CloseDate = System.Date.today() + 365;        
        oppList.add(opp);
        
        
        INSERT oppList;
        
        AccountTriggerHelper.updateSENamesInOpportunity(accList, accountOldMap);
        Test.stopTest();
    }
    
   
    
    
    @IsTest
    static void testTerritoryUpdate() {
        
        ZscalerSetting__c zs = new ZscalerSetting__c();
        zs.Name = 'DSReviewCaseOwnerId';
        zs.Value__c = ''+userInfo.Getuserid();
        insert zs;
        
        List<OnOffSwitch__c> switchList = new List<OnOffSwitch__c> ();
        OnOffSwitch__c zcs1= new OnOffSwitch__c();
        zcs1.name='updateSalesTeamBlankifSTnotchng';
        zcs1.Deactivate_Component__c=false;
        switchList.add(zcs1);
        
        INSERT switchList;
        
        
        
        //TriggerUtility.accSalesTeamExecuted();
        
        PatchTeam__c salestert  = new PatchTeam__c();
        salestert.District__c = 'District 1';
        salestert.Theater__c = 'AMER';
        salestert.Region__c = 'Central';
        salestert.Territory__c = 'SF Bay Area 1';
        salestert.Name = 'Sales Team';
        insert salestert;
        
        PatchTeam__c salestert1  = new PatchTeam__c();
        salestert1.District__c = 'District 1';
        salestert1.Theater__c = 'AMERICAS';
        salestert1.Region__c = 'US West';
        salestert1.Territory__c = 'US South West';
        salestert1.Name = 'Sales Team';
        insert salestert1;
        
        List<PatchTeamMember__c> patchTeamMemberList = new List<PatchTeamMember__c> ();
        
        PatchTeamMember__c SalesTeamMem2 = new PatchTeamMember__c();
        SalesTeamMem2.Role__c = 'ZPA Manager';
        SalesTeamMem2.PatchTeam__c = salestert.Id;
        SalesTeamMem2.User__c = UserInfo.getUserId();
        
        patchTeamMemberList.add(SalesTeamMem2);
        
        PatchTeamMember__c SalesTeamMem3 = new PatchTeamMember__c();
        SalesTeamMem3.Role__c = 'ZPA SE';
        SalesTeamMem3.PatchTeam__c = salestert1.Id;
        SalesTeamMem3.User__c = UserInfo.getUserId();
        patchTeamMemberList.add(SalesTeamMem3);
        
        PatchTeamMember__c SalesTeamMem4 = new PatchTeamMember__c();
        SalesTeamMem4.Role__c = 'Customer Advocate';
        SalesTeamMem4.PatchTeam__c = salestert1.Id;
        SalesTeamMem4.User__c = UserInfo.getUserId();
        patchTeamMemberList.add(SalesTeamMem4);
        
        PatchTeamMember__c SalesTeamMem5 = new PatchTeamMember__c();
        SalesTeamMem5.Role__c = 'Channel Manager';
        SalesTeamMem5.PatchTeam__c = salestert1.Id;
        SalesTeamMem5.User__c = UserInfo.getUserId();
        patchTeamMemberList.add(SalesTeamMem5);
        
        PatchTeamMember__c SalesTeamMem6 = new PatchTeamMember__c();
        SalesTeamMem6.Role__c = 'Account Manager';
        SalesTeamMem6.PatchTeam__c = salestert.Id;
        SalesTeamMem6.User__c = UserInfo.getUserId();
        patchTeamMemberList.add(SalesTeamMem6);
        
        PatchTeamMember__c SalesTeamMem7 = new PatchTeamMember__c();
        SalesTeamMem7.Role__c = 'Area Director';
        SalesTeamMem7.PatchTeam__c = salestert1.Id;
        SalesTeamMem7.User__c = UserInfo.getUserId();
        patchTeamMemberList.add(SalesTeamMem7);
        
        INSERT patchTeamMemberList;
        
        Patch__c patch  = new Patch__c();
        patch.Active__c = true;
        patch.PatchTeam__c = salestert.Id ;
        patch.PatchName__c = 'Test Patch';
        insert patch;
        
        
        Patch__c patch1  = new Patch__c();
        patch1.Active__c = true;
        patch1.PatchTeam__c = salestert1.Id ;
        patch1.PatchName__c = 'Test Patch';
        insert patch1;
                
        
        List<Account> accList = new List<Account> ();
        Account acc = new account();
        Acc.Name = 'Test Data';
        acc.Patch__c = patch.Id;
        acc.Sales_Territory__c = salestert1.Id;
        
        accList.add(acc);
        
        
        Account acc1 = new account();
        Acc1.Name = 'Test Data';
        acc1.Patch__c = patch.Id;
        acc1.Sales_Territory__c = NULL;
        
        
        insert accList;
        
        Account accClone = new account();
        accClone.Id = accList.get(0).Id;
        accClone.Sales_Territory__c = salestert.Id;
        
        Map<Id, Account> accOldMap = new Map<Id, Account> ();
        accOldMap.put(accList.get(0).Id, accClone);
        
        
        Contact con = new Contact();
        con.LastName = 'test lastname';
        con.AccountId = accList.get(0).Id;
        INSERT con;
        
        Task t = new Task(Subject='Donni',Status='New',Priority='Normal',CallType='Outbound');
        t.WhatId = accList.get(0).Id;
        t.WhoId = con.Id;
        
        INSERT t;

        Event evt = TestDatafactory_Zscaler.insertEvent(system.today(), System.Today() + 5, accList.get(0).Id);

        
        AccountTriggerHelper.updateTerritoryonActivities(accList, accOldMap);
        
    }
    
    
    
    @IsTest
    static void testTerritoryUpdate1() {
        
        ZscalerSetting__c zs = new ZscalerSetting__c();
        zs.Name = 'DSReviewCaseOwnerId';
        zs.Value__c = ''+userInfo.Getuserid();
        insert zs;
        
        List<OnOffSwitch__c> switchList = new List<OnOffSwitch__c> ();
        OnOffSwitch__c zcs1= new OnOffSwitch__c();
        zcs1.name='updateSalesTeamBlankifSTnotchng';
        zcs1.Deactivate_Component__c=false;
        switchList.add(zcs1);
        
        INSERT switchList;
        
        
        
        //TriggerUtility.accSalesTeamExecuted();
        
        System.debug('-=- !TriggerUtility.isPatchRealigning() -=- '+!TriggerUtility.isPatchRealigning());
        PatchTeam__c salestert  = new PatchTeam__c();
        salestert.District__c = 'District 1';
        salestert.Theater__c = 'AMER';
        salestert.Region__c = 'Central';
        salestert.Territory__c = 'SF Bay Area 1';
        salestert.Name = 'Sales Team';
        insert salestert;
        
        PatchTeam__c salestert1  = new PatchTeam__c();
        salestert1.District__c = 'District 1';
        salestert1.Theater__c = 'AMERICAS';
        salestert1.Region__c = 'US West';
        salestert1.Territory__c = 'US South West';
        salestert1.Name = 'Sales Team';
        insert salestert1;
        
        List<PatchTeamMember__c> patchTeamMemberList = new List<PatchTeamMember__c> ();
        
        PatchTeamMember__c SalesTeamMem2 = new PatchTeamMember__c();
        SalesTeamMem2.Role__c = 'ZPA Manager';
        SalesTeamMem2.PatchTeam__c = salestert.Id;
        SalesTeamMem2.User__c = UserInfo.getUserId();
        
        patchTeamMemberList.add(SalesTeamMem2);
        
        PatchTeamMember__c SalesTeamMem3 = new PatchTeamMember__c();
        SalesTeamMem3.Role__c = 'ZPA SE';
        SalesTeamMem3.PatchTeam__c = salestert1.Id;
        SalesTeamMem3.User__c = UserInfo.getUserId();
        patchTeamMemberList.add(SalesTeamMem3);
        
        PatchTeamMember__c SalesTeamMem4 = new PatchTeamMember__c();
        SalesTeamMem4.Role__c = 'Customer Advocate';
        SalesTeamMem4.PatchTeam__c = salestert1.Id;
        SalesTeamMem4.User__c = UserInfo.getUserId();
        patchTeamMemberList.add(SalesTeamMem4);
        
        PatchTeamMember__c SalesTeamMem5 = new PatchTeamMember__c();
        SalesTeamMem5.Role__c = 'Channel Manager';
        SalesTeamMem5.PatchTeam__c = salestert1.Id;
        SalesTeamMem5.User__c = UserInfo.getUserId();
        patchTeamMemberList.add(SalesTeamMem5);
        
        PatchTeamMember__c SalesTeamMem6 = new PatchTeamMember__c();
        SalesTeamMem6.Role__c = 'Account Manager';
        SalesTeamMem6.PatchTeam__c = salestert.Id;
        SalesTeamMem6.User__c = UserInfo.getUserId();
        patchTeamMemberList.add(SalesTeamMem6);
        
        PatchTeamMember__c SalesTeamMem7 = new PatchTeamMember__c();
        SalesTeamMem7.Role__c = 'Area Director';
        SalesTeamMem7.PatchTeam__c = salestert1.Id;
        SalesTeamMem7.User__c = UserInfo.getUserId();
        patchTeamMemberList.add(SalesTeamMem7);
        
        INSERT patchTeamMemberList;
        
        Patch__c patch  = new Patch__c();
        patch.Active__c = true;
        patch.PatchTeam__c = salestert.Id ;
        patch.PatchName__c = 'Test Patch';
        insert patch;
        
        
        Patch__c patch1  = new Patch__c();
        patch1.Active__c = true;
        patch1.PatchTeam__c = salestert1.Id ;
        patch1.PatchName__c = 'Test Patch';
        insert patch1;
        
        
        //TriggerUtility.realignPatchReset();  
        List<Account> accList = new List<Account> ();
        Account acc = new account();
        Acc.Name = 'Test Data';
        acc.Patch__c = patch.Id;
        acc.Sales_Territory__c = NULL;
        
        accList.add(acc);
        
        Account acc1 = new account();
        Acc1.Name = 'Test Data1';
        
        
        accList.add(acc1);
        
        insert accList;
        

        System.debug('-=- !TriggerUtility.isPatchRealigning() -=- '+!TriggerUtility.isPatchRealigning());
        
        //TriggerUtility.realignPatchReset();  

        //TriggerUtility.realignPatch();
        System.debug('-=- !TriggerUtility.isPatchRealigning() -=- '+!TriggerUtility.isPatchRealigning());

        //acc.Patch__c = patch1.Id;
        acc.Sales_Territory__c = NULL;
        update acc;
        
        
    }
    
    @isTest 
    private static void updateCSBusinessAlignmentOnAccTeamMemberTest(){
        
        Test.enableChangeDataCapture();
        
        TestDatafactory_Zscaler.gettriggerswitchrecords(true);
        
        OnOffSwitch__c zcs1= new OnOffSwitch__c();
        zcs1.name='updateCSMfieldonAccount';
        zcs1.Deactivate_Component__c=false;
        insert zcs1;
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User userOne = new User(LastName = 'User Account',
                                FirstName='Test',
                                Alias = 'tUAcc',
                                Email = 'test.test@test.com',
                                Username = 'test.testAccount@test.com',
                                ProfileId = profileId.id,
                                TimeZoneSidKey = 'GMT',
                                LanguageLocaleKey = 'en_US',
                                EmailEncodingKey = 'UTF-8',
                                LocaleSidKey = 'en_US'
                               );
        insert userOne;
        User userTwo = new User(LastName = 'User Account',
                                FirstName='Test',
                                Alias = 'tUAcc',
                                Email = 'test.test@test.com',
                                Username = 'test.testAccount2@test.com',
                                ProfileId = profileId.id,
                                TimeZoneSidKey = 'GMT',
                                LanguageLocaleKey = 'en_US',
                                EmailEncodingKey = 'UTF-8',
                                LocaleSidKey = 'en_US'
                               );
        insert userTwo;
        
        //Patch__c patch = [SELECT Id FROM Patch__c WHERE PatchName__c = 'Test Patch'];
        //PatchTeam__c salestert = [SELECT Id FROM PatchTeam__c WHERE Name = 'Sales Team'];
        List<User> usr = [SELECT Id FROM User limit 10];
        
        Account acc = new Account();
        acc.Name='AMERICAS';
        acc.Type ='Prospect';
        //acc.Sales_Territory__c = salestert.Id;
       // acc.Patch__c = patch.Id;
        acc.ownerId = userTwo.Id;
        insert acc;
        
        Account acc2 = new Account();
        acc2.Name='AMERICAS';
        acc2.Type ='Prospect';
        //acc2.Sales_Territory__c = salestert.Id;
        //acc2.Patch__c = patch.Id;
        acc2.ownerId = userTwo.Id;
        insert acc2;
        Test.getEventBus().deliver();
        
        AccountTeamMember atm = new AccountTeamMember();
        atm.accountid=acc.Id;
        atm.teamMemberRole='Customer Success Manager';
        atm.UserId=userTwo.Id;
        atm.AccountAccessLevel='Edit';
        atm.OpportunityAccessLevel = 'Edit';
        atm.CaseAccessLevel='Edit';
        atm.ContactAccessLevel='Edit';
        insert atm;
        
        Contact con = TestDatafactory_Zscaler.insertContact('AMERICAS Contact', acc.Id, null);
        //TriggerUtility.realignPatchReset();
        //Account acc1 = [SELECT Id,Patch__c,CS_Business_Alignment__c,CSM_Name_2__c FROM Account WHERE Name = 'AMERICAS'];
        //Patch__c patch1 = [SELECT Id FROM Patch__c WHERE PatchName__c = 'Test Patch1'];       
        //acc.Patch__c = patch1.Id;
        acc.CS_Business_Alignment__c =usr[0].ID;
        acc.CSM_Name_2__c=usr[1].Id;
        //acc2.Patch__c = patch1.Id;
        acc2.CS_Business_Alignment__c =usr[0].ID;
        acc2.CSM_Name_2__c=usr[1].Id;
        TriggerUtility.realignPatchReset();
        update acc;
        update acc2;
        Test.getEventBus().deliver();         
        
    }
    
    @isTest 
    private static void updateCSBusinessAlignmentWithZeroAccTeamMembersTest(){
        
        Test.enableChangeDataCapture();
        
        TestDatafactory_Zscaler.gettriggerswitchrecords(true);
        
        OnOffSwitch__c zcs1= new OnOffSwitch__c();
        zcs1.name='updateCSMfieldonAccount';
        zcs1.Deactivate_Component__c=false;
        insert zcs1;
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User userOne = new User(LastName = 'User Account',
                                FirstName='Test',
                                Alias = 'tUAcc',
                                Email = 'test.test@test.com',
                                Username = 'test.testAccount@test.com',
                                ProfileId = profileId.id,
                                TimeZoneSidKey = 'GMT',
                                LanguageLocaleKey = 'en_US',
                                EmailEncodingKey = 'UTF-8',
                                LocaleSidKey = 'en_US'
                               );
        insert userOne;
        User userTwo = new User(LastName = 'User Account',
                                FirstName='Test',
                                Alias = 'tUAcc',
                                Email = 'test.test@test.com',
                                Username = 'test.testAccount2@test.com',
                                ProfileId = profileId.id,
                                TimeZoneSidKey = 'GMT',
                                LanguageLocaleKey = 'en_US',
                                EmailEncodingKey = 'UTF-8',
                                LocaleSidKey = 'en_US'
                               );
        insert userTwo;
        
        //Patch__c patch = [SELECT Id FROM Patch__c WHERE PatchName__c = 'Test Patch'];
        //PatchTeam__c salestert = [SELECT Id FROM PatchTeam__c WHERE Name = 'Sales Team'];
        List<User> usr = [SELECT Id FROM User limit 10];
        
        Account acc = new Account();
        acc.Name='AMERICAS';
        acc.Type ='Prospect';
        //acc.Sales_Territory__c = salestert.Id;
        //acc.Patch__c = patch.Id;
        acc.ownerId = userTwo.Id;
        insert acc;
        Test.getEventBus().deliver();
        
        
        Contact con = TestDatafactory_Zscaler.insertContact('AMERICAS Contact', acc.Id, null);
       // Patch__c patch1 = [SELECT Id FROM Patch__c WHERE PatchName__c = 'Test Patch1'];       
        //acc.Patch__c = patch1.Id;
        acc.CS_Business_Alignment__c =usr[0].ID;
        acc.CSM_Name_2__c=usr[1].Id;
        //TriggerUtility.realignPatchReset();
        update acc;
        //Test.getEventBus().deliver();         
        
    }
    
    @isTest
    static void testUpdateFedAccountCustomerType() {
        DealRegTestDataFactory.createPatchTeamsAndGeoLeaderMappings();
        TestDatafactory_Zscaler.gettriggerswitchrecords(true);
        String terrId = DealRegTestDataFactory.mapPatchTeams.get('EMEA|General Business').Id;
        Patch__c patch = new Patch__c(PatchName__c='acme', Active__c=true,PatchTeam__c=terrId);
        insert patch;
        
        Account acc = TestDatafactory_Zscaler.insertAccount('Test Account1', null, 'Customer', null, patch.Id, null);
        
        Product2 prod = TestDatafactory_Zscaler.constructProduct('Product2', 'ZCES-SUP-PREM', 'Products', 'Standalone', true, false, false);
        insert prod;
        
        Contract_Detail__c cdtl = TestDatafactory_Zscaler.insertContractDetail('test contract', acc.Id, prod.Id, system.today(),system.today() + 10, 10, 100, null, null, 100, null, false, false);       
        cdtl.Contract_Detail_Status__c = 'Active';
        update cdtl;

        acc = [SELECT Id, Active_Contracts__c, Type FROM Account WHERE Id = :acc.Id LIMIT 1];
        Test.startTest();
            AccountTriggerHelper.updateFedAccountCustomerType(new List<Account> {acc});
        Test.stopTest();
    }

    @isTest
    static void testUpdateCSMAccountExtenssionMethodAccountRenewableACVAbove50000() {
        DealRegTestDataFactory.createPatchTeamsAndGeoLeaderMappings();
        TestDatafactory_Zscaler.gettriggerswitchrecords(true);
        String terrId = DealRegTestDataFactory.mapPatchTeams.get('EMEA|General Business').Id;
        Patch__c patch = new Patch__c(PatchName__c='acme', Active__c=true,PatchTeam__c=terrId);
        insert patch;
        
        Account acc = TestDatafactory_Zscaler.insertAccount('Test Account1', null, 'Customer', null, patch.Id, null);
        
        Product2 prod = TestDatafactory_Zscaler.constructProduct('Product2', 'ZCES-SUP-PREM', 'Products', 'Standalone', true, false, false);
        insert prod;
        
        Contract_Detail__c cdtl = TestDatafactory_Zscaler.insertContractDetail('test contract', acc.Id, prod.Id, system.today(),system.today() + 10, 10, 100, null, null, 100, null, false, false);
        cdtl.MRR_USD__c = 4500;       
        cdtl.Contract_Detail_Status__c = 'Active';
        update cdtl;

        Account_Extension__c accExt = TestDatafactory_Zscaler.insertAccountExtension(acc.Id);

        Test.startTest();
            AccountTriggerHelper.UpdateCSMAccountExtenssionMethod(new Set<Id> {acc.Id});
        Test.stopTest();
    }

    @isTest
    static void testUpdateCSMAccountExtenssionMethodAccountRenewableACVBelow50000() {
        DealRegTestDataFactory.createPatchTeamsAndGeoLeaderMappings();
        TestDatafactory_Zscaler.gettriggerswitchrecords(true);
        
        String terrId = DealRegTestDataFactory.mapPatchTeams.get('EMEA|General Business').Id;
        Patch__c patch = new Patch__c(PatchName__c='acme', Active__c=true,PatchTeam__c=terrId);
        insert patch;
        
        Account acc = TestDatafactory_Zscaler.insertAccount('Test Account1', null, 'Customer', null, patch.Id, null);
        
        Product2 prod = TestDatafactory_Zscaler.constructProduct('Product2', 'ZCES-SUP-PREM', 'Products', 'Standalone', true, false, false);
        insert prod;
        
        Contract_Detail__c cdtl = TestDatafactory_Zscaler.insertContractDetail('test contract', acc.Id, prod.Id, system.today(),system.today() + 10, 10, 100, null, null, 100, null, false, false);       
        cdtl.MRR_USD__c = 4000;
        cdtl.Contract_Detail_Status__c = 'Active';
        update cdtl;

        Account_Extension__c accExt = TestDatafactory_Zscaler.insertAccountExtension(acc.Id);

        Test.startTest();
            AccountTriggerHelper.UpdateCSMAccountExtenssionMethod(new Set<Id> {acc.Id});
        Test.stopTest();
    }

    @isTest
    static void testUpdateCSMAccountExtenssionMethodAsyncAccountRenewableACVAbove50000() {
        DealRegTestDataFactory.createPatchTeamsAndGeoLeaderMappings();
        TestDatafactory_Zscaler.gettriggerswitchrecords(true);
        
        String terrId = DealRegTestDataFactory.mapPatchTeams.get('EMEA|General Business').Id;
        Patch__c patch = new Patch__c(PatchName__c='acme', Active__c=true,PatchTeam__c=terrId);
        insert patch;
        
        Account acc = TestDatafactory_Zscaler.insertAccount('Test Account1', null, 'Customer', null, patch.Id, null);
        
        Product2 prod = TestDatafactory_Zscaler.constructProduct('Product2', 'ZCES-SUP-PREM', 'Products', 'Standalone', true, false, false);
        insert prod;
        
        Contract_Detail__c cdtl = TestDatafactory_Zscaler.insertContractDetail('test contract', acc.Id, prod.Id, system.today(),system.today() + 10, 10, 100, null, null, 100, null, false, false);       
        cdtl.MRR_USD__c = 4500;
        cdtl.Contract_Detail_Status__c = 'Active';
        update cdtl;

        Account_Extension__c accExt = TestDatafactory_Zscaler.insertAccountExtension(acc.Id);

        Test.startTest();
            AccountTriggerHelper.UpdateCSMAccountExtenssionMethodAsync(new Set<Id> {acc.Id});
        Test.stopTest();
    }

    @isTest
    static void testUpdateCSMAccountExtenssionMethodAsyncAccountRenewableACVBelow50000() {
        DealRegTestDataFactory.createPatchTeamsAndGeoLeaderMappings();
        TestDatafactory_Zscaler.gettriggerswitchrecords(true);
        
        String terrId = DealRegTestDataFactory.mapPatchTeams.get('EMEA|General Business').Id;
        Patch__c patch = new Patch__c(PatchName__c='acme', Active__c=true,PatchTeam__c=terrId);
        insert patch;
        
        Account acc = TestDatafactory_Zscaler.insertAccount('Test Account1', null, 'Customer', null, patch.Id, null);
        
        Product2 prod = TestDatafactory_Zscaler.constructProduct('Product2', 'ZCES-SUP-PREM', 'Products', 'Standalone', true, false, false);
        insert prod;
        
        Contract_Detail__c cdtl = TestDatafactory_Zscaler.insertContractDetail('test contract', acc.Id, prod.Id, system.today(),system.today() + 10, 10, 100, null, null, 100, null, false, false);       
        cdtl.MRR_USD__c = 4000;
        cdtl.Contract_Detail_Status__c = 'Active';
        update cdtl;

        Account_Extension__c accExt = TestDatafactory_Zscaler.insertAccountExtension(acc.Id);

        Test.startTest();
            AccountTriggerHelper.UpdateCSMAccountExtenssionMethodAsync(new Set<Id> {acc.Id});
        Test.stopTest();
    }

    @isTest
    static void testUpdateSENamesInOpportunity() {
        PatchTeam__c territory =  new PatchTeam__c();
        territory.Theater__c = 'International';
        territory.Region__c = 'SEUR';
        territory.Area__c = 'EMEA';
        insert territory;
        
        Account account = new Account(Name = 'Test Account');
        account.CSM_Name_New__c = UserInfo.getUserId();
        account.Type = 'Customer'; 
        account.Sales_Territory__c = territory.id;
        account.Prospect_Type__c = 'Pipeline';
        account.No_of_Employees_Users__c='40000+';    
        insert account;

        Account oldAccount = new Account(Id = account.Id);

        Date closeDate = system.today() + 5;
        Opportunity opp = TestDatafactory_Zscaler.insertOpportunity('Test Opp1', false, account.Id, Label.Stage_4_Economic_Buyer_Signoff, closeDate , null, null, null, null,null, null, null, null, null, null, true);

        Test.startTest();
            AccountTriggerHelper.updateSENamesInOpportunity(new List<Account> {account}, new Map<Id, Account> {oldAccount.Id => oldAccount});
        Test.stopTest();
        
    }

    @isTest
    static void testUpdateCustomerSupportStageCurrentARRGT1000000()
    {
        Account account = TestDatafactory_Zscaler.insertAccount('Test Account', 'test@test.com', 'Customer','01270000000EAFsAAO', null, 5);
        account.Override_Customer_Support_Segment__c=false;
        account.Type='Customer';
        account.Current_ARR__c=2000000;
        
        Test.startTest();
            new AccountTriggerHelper().updateCustomerSupportStage(new List<Account> {account});
        Test.stopTest();
    }

    @isTest
    static void testUpdateCustomerSupportStageCurrentARRGT300000()
    {
        Account account = TestDatafactory_Zscaler.insertAccount('Test Account', 'test@test.com', 'Customer','01270000000EAFsAAO', null, 5);
        account.Override_Customer_Support_Segment__c=false;
        account.Type='Customer';
        account.Current_ARR__c=500000;
        
        Test.startTest();
            new AccountTriggerHelper().updateCustomerSupportStage(new List<Account> {account});
        Test.stopTest();
    }
    
    @isTest
    static void testUpdateCustomerSupportStageCurrentARRGT100000()
    {
        Account account = TestDatafactory_Zscaler.insertAccount('Test Account', 'test@test.com', 'Customer','01270000000EAFsAAO', null, 5);
        account.Override_Customer_Support_Segment__c=false;
        account.Type='Customer';
        account.Current_ARR__c=200000;
        
        Test.startTest();
            new AccountTriggerHelper().updateCustomerSupportStage(new List<Account> {account});
        Test.stopTest();
    }

    @isTest
    static void testUpdateCustomerSupportStageCurrentARRGT25000()
    {
        Account account = TestDatafactory_Zscaler.insertAccount('Test Account', 'test@test.com', 'Customer','01270000000EAFsAAO', null, 5);
        account.Override_Customer_Support_Segment__c=false;
        account.Type='Customer';
        account.Current_ARR__c=50000;
        
        Test.startTest();
            new AccountTriggerHelper().updateCustomerSupportStage(new List<Account> {account});
        Test.stopTest();
    }

    @isTest
    static void testAccountWorkflowOptimizationmethod() {
        Account testAccount = (Account) JSON.deserialize('{ "Avg_Estimated_Users_L31D_Vs_Purchase__c" : 100, "ZPA_Enrolled_users_L31D_Vs_Purchase__c" : 100, "Active_Contracts__c" : 0, "Contracts__c" : 0, "Premium_Support_ACV__c" : 100, "Active_Users_L30D_Vs_Purchased_Users__c" : 100}', Account.class);
        testAccount.DS_Review_Status__c = 'Complete';
        testAccount.Type = 'Customer';
        testAccount.Support_Type_Exception__c = false;
        testAccount.Name = 'Test Customer Account'; //Added Name to resolve test class error in production
		Insert testAccount;
        
        Map<Id,Account> accMap = new Map<Id,Account>();
        accMap.put(testAccount.Id, testAccount);
        Test.startTest();
            AccountTriggerHelper.AccountWorkflowOptimizationmethod(new List<Account> {testAccount},accMap , false, false);
        Test.stopTest();
    }

    @isTest
    static void testUpdateEntitlementProspect() {
        Account account = TestDatafactory_Zscaler.insertAccount('Test Account', 'test@test.com', 'Prospect','01270000000EAFsAAO', null, 5);
        account.Support_Type__c = 'Premium Support';
        update account;

        Account oldAccount = new Account(Id = account.Id);

        Test.startTest();
            AccountTriggerHelper.updateEntitlement(new List<Account> {account}, new Map<Id, Account> {oldAccount.Id => oldAccount});
        Test.stopTest();
    }

    @isTest
    static void testUpdateEntitlementPremiumSupport() {
        DealRegTestDataFactory.createPatchTeamsAndGeoLeaderMappings();
        TestDatafactory_Zscaler.gettriggerswitchrecords(true);
        String terrId = DealRegTestDataFactory.mapPatchTeams.get('EMEA|General Business').Id;
        Patch__c patch = new Patch__c(PatchName__c='acme', Active__c=true,PatchTeam__c=terrId);
        insert patch;
        
        Account acc = TestDatafactory_Zscaler.insertAccount('Test Account1', null, 'Customer', null, patch.Id, null);
        acc.Support_Type__c = 'Premium Support';
        update acc;
        
        Product2 prod = TestDatafactory_Zscaler.constructProduct('Product2', 'ZCES-SUP-PREM', 'Products', 'Standalone', true, false, false);
        insert prod;
        
        Contract_Detail__c cdtl = TestDatafactory_Zscaler.insertContractDetail('test contract', acc.Id, prod.Id, system.today(),system.today() + 10, 10, 100, null, null, 100, null, false, false);       
        cdtl.Contract_Detail_Status__c = 'Active';
        update cdtl;

        acc = [SELECT Id, Support_Type__c, Type FROM Account WHERE Id = :acc.Id LIMIT 1];
        Account oldAccount = new Account(Id = acc.Id);
        
        Test.startTest();
        AccountTriggerHelper.updateEntitlement(new List<Account> {acc}, new Map<Id, Account> {oldAccount.Id => oldAccount});
        Test.stopTest();
    }

    @isTest
    static void testUpdateFedAccountCustomerTypePremiumPlusSupport() {
        DealRegTestDataFactory.createPatchTeamsAndGeoLeaderMappings();
        TestDatafactory_Zscaler.gettriggerswitchrecords(true);
        String terrId = DealRegTestDataFactory.mapPatchTeams.get('EMEA|General Business').Id;
        Patch__c patch = new Patch__c(PatchName__c='acme', Active__c=true,PatchTeam__c=terrId);
        insert patch;
        
        Account acc = TestDatafactory_Zscaler.insertAccount('Test Account1', null, 'Customer', null, patch.Id, null);
        //acc.Support_Type__c = 'Premium Plus Support';
        update acc;
        
        Product2 prod = TestDatafactory_Zscaler.constructProduct('Product2', 'ZCES-SUP-PREM', 'Products', 'Standalone', true, false, false);
        insert prod;
        
        Contract_Detail__c cdtl = TestDatafactory_Zscaler.insertContractDetail('test contract', acc.Id, prod.Id, system.today(),system.today() + 10, 10, 100, null, null, 100, null, false, false);       
        cdtl.Contract_Detail_Status__c = 'Active';
        update cdtl;

        acc = [SELECT Id, Support_Type__c, Type FROM Account WHERE Id = :acc.Id LIMIT 1];
        Account oldAccount = new Account(Id = acc.Id);
        
        Test.startTest();
        AccountTriggerHelper.updateEntitlement(new List<Account> {acc}, new Map<Id, Account> {oldAccount.Id => oldAccount});
        Test.stopTest();
    }

    @isTest
    static void testAAUCreateAccountTeamMember() {
        Account testAccount1 = new Account(Name = 'Test Account 1');
        insert testAccount1;

        testAccount1.OwnerId = UserInfo.getUserId();
        update testAccount1;

        Account testAccount2 = new Account(Name = 'Test Account 2');
        insert testAccount2;

        testAccount2.Id = testAccount1.Id;

        testAccount1 = [SELECT Id, OwnerId, CreatedDate, LastModifiedDate FROM Account WHERE Id = :testAccount1.Id LIMIT 1];
        Test.startTest();
            AccountTriggerHelper.AAUCreateAccountTeamMember(new List<Account> {testAccount1}, new Map<Id, Account> {testAccount2.Id => testAccount2});
        Test.stopTest();
    }

    @isTest
    static void testCreateAccountExtensionHistory() {
        Account acc = TestDatafactory_Zscaler.insertAccount('Test Account1', null, 'Prospect', null, null, null);
        acc.CS_Management_Notes__c = 'Test Note';
        update acc;
    }
    //Added Ayush Kangar as part of IBA-2489 - Start
    @isTest
    static void createOverageOpportunityTest() {
        Account acc = TestDatafactory_Zscaler.insertAccount('Test Account1', null, 'Prospect', null, null, null);
         Product2 prod = TestDatafactory_Zscaler.constructProduct('Product2', 'ZCES-SUP-PREM', 'Products', 'Standalone', true, false, false);
        insert prod;
        Contract_Detail__c cdtl = TestDatafactory_Zscaler.insertContractDetail('test contract', acc.Id, prod.Id, system.today(),system.today() + 10, 10, 100, null, null, 100, null, false, false);       
        cdtl.Is_Bundle_SKU__c = true;
        cdtl.Zscaler_Product_Family__c = 'ZIA';
        cdtl.Contract_Detail_Status__c = 'Active';        
        update cdtl;
        acc.Account_Overage__c = 'Create Opportunity';
        acc.Proposed_Number_of_Users__c = 100;
        acc.True_Forward_opportunity_Notes__c = 'test';
        update acc;
    }
     //Added Ayush Kangar as part of IBA-2489 - End
     
    @isTest 
    static void testUpdateAuthenticatedConsumptionFieldsOnAccountExtension() {
        Account testAccountRecord = new Account();
        testAccountRecord.name = 'Test Account';
        testAccountRecord.Type = 'Customer';
        testAccountRecord.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Partner').getRecordTypeId();
        testAccountRecord.DS_Review_Status__c = 'Complete';
        testAccountRecord.Total_Transactions__c = 0;
        testAccountRecord.Total_Bandwidth__c = 0;
        testAccountRecord.Total_Policy_Blocks__c = 0;
        testAccountRecord.Total_Botnet_Calls__c = 0;
        testAccountRecord.Total_Malware__c = 0;
        testAccountRecord.Total_Phishing_Attacks__c = 0;
        testAccountRecord.Total_Security_Blocks__c = 0;
        insert testAccountRecord;
        
        Customer_Score_Card__c card = new Customer_Score_Card__c();
        card.Account__c = testAccountRecord.Id;
        Insert card;

        testAccountRecord.Customer_ScoreCard__c = card.Id;
        Update testAccountRecord;
        
        Contract_Detail__c testContractDetail = TestDatafactory_Zscaler.insertContractDetail('test contract', testAccountRecord.Id, null, system.today(),system.today() + 10, 1, 1000, 'TEST1234', 1000, 100, null, false, false);       
        testContractDetail.Is_Bundle_SKU__c = true;
        testContractDetail.Zscaler_Product_Family__c = 'ZIA';
        testContractDetail.Contract_Detail_Status__c = 'Active';    
        update testContractDetail;

        Account testAccountRecordFetched = [SELECT Id, Customer_ScoreCard__c FROM Account WHERE Id = :testAccountRecord.Id];

        Customer_Score_Card__c associatedCustomerScoreCard = new Customer_Score_Card__c(
            Id = testAccountRecordFetched.Customer_ScoreCard__c,
            Total_Bytes_90D__c = 160000000
        );

        Test.startTest();
            update associatedCustomerScoreCard;
        Test.stopTest();
    }

    @isTest 
    static void testUpdateAuthenticatedConsumptionFieldsOnAccountExtensionInvocableMethod() {
        Account testAccountRecord = new Account();
        testAccountRecord.name = 'Test Account';
        testAccountRecord.Type = 'Customer';
        testAccountRecord.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Partner').getRecordTypeId();
        testAccountRecord.DS_Review_Status__c = 'Complete';
        testAccountRecord.Total_Transactions__c = 0;
        testAccountRecord.Total_Bandwidth__c = 0;
        testAccountRecord.Total_Policy_Blocks__c = 0;
        testAccountRecord.Total_Botnet_Calls__c = 0;
        testAccountRecord.Total_Malware__c = 0;
        testAccountRecord.Total_Phishing_Attacks__c = 0;
        testAccountRecord.Total_Security_Blocks__c = 0;        
        insert testAccountRecord;

        Customer_Score_Card__c card = new Customer_Score_Card__c();
        card.Account__c = testAccountRecord.Id;
        Insert card;

        testAccountRecord.Customer_ScoreCard__c = card.Id;
        Update testAccountRecord;
        
        Contract_Detail__c testContractDetail = TestDatafactory_Zscaler.insertContractDetail('test contract', testAccountRecord.Id, null, system.today(),system.today() + 10, 1, 1000, 'TEST1234', 1000, 100, null, false, false);       
        testContractDetail.Is_Bundle_SKU__c = true;
        testContractDetail.Zscaler_Product_Family__c = 'ZIA';
        testContractDetail.Contract_Detail_Status__c = 'Active';    
        update testContractDetail;

        Account testAccountRecordFetched = [SELECT Id, Customer_ScoreCard__c FROM Account WHERE Id = :testAccountRecord.Id];

        Customer_Score_Card__c associatedCustomerScoreCard = new Customer_Score_Card__c(
            Id = testAccountRecordFetched.Customer_ScoreCard__c,
            Total_Bytes_90D__c = 160000000
        );

        Test.startTest();
            update associatedCustomerScoreCard;

            List<List<Account>> listOfAccountList = new List<List<Account>>();
            listOfAccountList.add(new List<Account> {testAccountRecord});

            AccountTriggerHelper.updateAuthenticatedConsumptionFieldsOnAccountExtensionInvocableMethod(listOfAccountList);
        Test.stopTest();
    }
     
}