/*****************************************************************************************
Name: OpportunitySplitTriggerHelperTest
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
1. Test class for OpportunitySplitTriggerHelper class.
==========================================================================================
==========================================================================================
History
-------
VERSION        AUTHOR                  DATE              DETAIL              
1.0            Kunal Raj               21-Oct-2015       Initial Development
1.0            Harish Gowda N          14-04-2022        CR:4137 : Related test class changes.
******************************************************************************************/ 

@isTest(SeeAllData=false)
private class OpportunitySplitTriggerHelperTest {
    static testmethod void testInsert() {
        
        List<user> users = [select id,Department from user where IsActive = true AND Profile.Name = 'System Administrator' Limit 2];
        users[0].Department = '0';
        update users[0];
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        opportunity opp = new opportunity(Name = 'Test opportunity',Type = 'Existing Customer (Renewal)', AccountId = acc.Id, StageName = Label.Stage_1_Alignment /*'1 - Qualified and Budgeted'*/, CloseDate = system.Today()+30);
        insert opp;
        
        test.startTest();
        OpportunitySplit  oppSplit = new OpportunitySplit(OpportunityId = opp.Id,Split_Type__c = 'Renewal', SplitPercentage = 10, SplitOwnerId = users[0].id, Channel_Rep__c = users[0].id, SE__c = users[0].id);
        oppSplit.Override_SE__c = true;
        insert oppSplit;
        oppSplit.SE__c = users[1].id;
        oppSplit.Channel_Rep__c = users[1].id;
        update oppSplit;
        test.stopTest();
    }
    
    static testmethod void test1() {
        
        PatchTeam__c pt= new PatchTeam__c();
        pt.Sales_Territory_Year__c = 'Current';
        
        insert pt;
        
        PatchTeamMember__c ptm= new PatchTeamMember__c();
        ptm.User__c = UserInfo.getUserId();
        ptm.PatchTeam__c = pt.Id;
        ptm.Role__c = ' Account Manager';
        insert ptm;
        
        List<user> users = [select id from user where IsActive = true AND Profile.Name = 'System Administrator' ];
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        
        Id oppRecordTypeId = Schema.SObjectType.opportunity.getRecordTypeInfosByName().get('Renewal Opportunity').getRecordTypeId();
        opportunity opp = new opportunity(Name = 'Test opportunity', AccountId = acc.Id, StageName = Label.Stage_1_Alignment , CloseDate = system.Today()+30);
        opp.Type = 'Existing Customer (Renewal)';
        opp.Has_Multiple_Upsell_Split_Lines__c = false;
        opp.recordTypeId = oppRecordTypeId;
        
        insert opp;
        test.startTest();
        OpportunitySplit  oppSplit = new OpportunitySplit(OpportunityId = opp.Id, SplitPercentage = 10, SplitOwnerId = users[0].id);
        oppSplit.Split_Type__c = 'Upsell';
        
        insert oppSplit;
        test.stopTest();
    }
    
    static testmethod void test2() {
        List<user> users = [select id from user where IsActive = true AND Profile.Name = 'System Administrator' ];

        PatchTeam__c salestert  = new PatchTeam__c();
        salestert.District__c = 'AMERICAS';
        salestert.Theater__c = 'Americas';
        salestert.Region__c = 'AMERICAS';
        salestert.Territory__c = 'SF Bay Area 1';
        salestert.Name = 'Sales Team';
        salestert.Sales_Territory_Year__c = 'Current';
        insert salestert;
        PatchTeamMember__c SalesTeamMem1 = new PatchTeamMember__c();
        SalesTeamMem1.Role__c = 'Account Manager';
        SalesTeamMem1.PatchTeam__c = salestert.Id;
        SalesTeamMem1.User__c = users[0].Id;
        insert SalesTeamMem1 ;
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        opportunity opp = new opportunity(Name = 'Test opportunity', Number_Of_Upsell_Split_Lines__c = 2 , Split__c = true , Type = 'Existing Customer (Renewal)', AccountId = acc.Id, StageName = Label.Stage_1_Alignment /*'1 - Qualified and Budgeted'*/, CloseDate = system.Today()+30);
        insert opp;
        
        test.startTest();
        OpportunitySplit  oppSplit = new OpportunitySplit(OpportunityId = opp.Id, SplitPercentage = 10,Split_Type__c = 'Upsell',Owner_Sales_Territory__c = salestert.id , SplitOwnerId = users[0].id);
        oppSplit.Override_SE__c = false;
        insert oppSplit;
        
        delete oppSplit;
        
        test.stopTest();
    }
    
    static testmethod void test3() {
        insert TestDatafactory_Zscaler.gettriggerswitchrecords(true);
        insert TestDatafactory_Zscaler.getstageforecastcategorymap();
        List<user> users = [select id from user where IsActive = true AND Profile.Name = 'System Administrator' ];
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
        
        PatchTeamMember__c SalesTeamMem1 = new PatchTeamMember__c();
        SalesTeamMem1.Role__c = 'Account Manager';
        SalesTeamMem1.PatchTeam__c = salestert.Id;
        SalesTeamMem1.User__c = users[0].Id;
        insert SalesTeamMem1 ;
        
        PatchTeam__c pct2 = new PatchTeam__c(Territory_Type__c = 'Enterprise',name = 'Sales Enterprise');
        insert pct2;
        PatchTeamMember__c SalesTeamMem2 = new PatchTeamMember__c();
        SalesTeamMem2.Role__c = 'Channel Manager';
        SalesTeamMem2.PatchTeam__c = pct2.Id;
        SalesTeamMem2.User__c = users[1].Id;
        insert SalesTeamMem2 ;
        
        triggerhandler.bypass('AccountTriggerHandler');
        Account acc = new Account(Name = 'Test Account', Patch__c = patch.Id, Sales_Territory__c=salestert.Id,Type='Partner');
        TriggerUtility.accSalesTeamExecuted();
        insert acc;
        
        List<Focus_Partner__c> focusPartner = New List<Focus_Partner__c>();
        Focus_Partner__c focusMem = new Focus_Partner__c(RAM__c = userinfo.getUserId(),Partner_Account__c = acc.Id,Sales_Territory__c=salestert.Id);
        focusPartner.add(focusMem);
        insert focusPartner;
        
        opportunity opp = new opportunity(Name = 'Test opportunity', AccountId = acc.Id, StageName =label.Stage_1_Alignment , SE_name__c = UserInfo.getUserId(), NextStep = 'Test 1',Primary_Reseller_Partner__c = acc.Id,
                                          CloseDate = system.Today()+30, Primary_Quote_Exception__c = true, Validation_Stage__c = '6 - Technical Win', Validation_Plan__c = 'Test', AD_Forecast_Category__c='Pipeline',AD_Forecast_Category_Lock__c=true, Next_Steps__c  = 'fdsjsdk');
        insert opp;
        List<OpportunitySplit> OSList = new List<OpportunitySplit>();
        OpportunitySplit  oppSplit = new OpportunitySplit(OpportunityId = opp.Id, SplitPercentage = 10, SplitOwnerId = users[0].id,Channel_Rep__c = users[0].id,SE__c = users[0].id);
        OpportunitySplit  oppSplit1 = new OpportunitySplit(OpportunityId = opp.Id, SplitPercentage = 10, SplitOwnerId = users[1].id,Channel_Rep__c = users[1].id,SE__c = users[1].id);

        oppSplit.Override_SE__c = true;
        OSList.add(oppSplit);
        OSList.add(oppSplit1);
        insert OSList;
		triggerhandler.clearBypass('AccountTriggerHandler');

		test.startTest();

        Map<Id, OpportunitySplit> oldSplit = new Map<Id, OpportunitySplit>();
        oldSplit.put(OSList[0].id, OSList[0]);
        List<OpportunitySplit> OSListupdate = new List<OpportunitySplit>();
        oppSplit.SE__c = users[1].id;
        oppSplit.Channel_Rep__c = users[10].id;
        OSListupdate.add(oppSplit);
        update OSListupdate;
        
        OpportunitySplitTriggerHelper.populateOwnerSalesTerritoryAndRAM(OSListupdate, oldSplit, false, true, true);
            OpportunitySplitTriggerHelper.createOpportunityTeamforSplit(OSListupdate,oldSplit);

		test.stopTest();
    }
    
    static testmethod void test4() {
        insert TestDatafactory_Zscaler.gettriggerswitchrecords(true);
        insert TestDatafactory_Zscaler.getstageforecastcategorymap();
        
        List<user> users = [select id from user where IsActive = true AND Profile.Name = 'System Administrator' ];
        users[0].Department = 'IT';
        update users[0];
        
        ZscalerSetting__c sttng = new ZscalerSetting__c();
        sttng.Name = 'CustomerAdvocacyDepartmentName';
        sttng.Value__c = 'IT';
        
        insert sttng;
        
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
        
        PatchTeamMember__c SalesTeamMem1 = new PatchTeamMember__c();
        SalesTeamMem1.Role__c = 'Account Manager';
        SalesTeamMem1.PatchTeam__c = salestert.Id;
        SalesTeamMem1.User__c = users[0].id;
        insert SalesTeamMem1 ;
        
        Account acc = new Account(Name = 'Test Account', Patch__c = patch.Id, Sales_Territory__c=salestert.Id,Type='Prospect');
        TriggerUtility.accSalesTeamExecuted();
        insert acc;
        
        opportunity opp = new opportunity(Name = 'Test opportunity', AccountId = acc.Id, StageName =label.Stage_1_Alignment , SE_name__c = UserInfo.getUserId(), NextStep = 'Test 1',
                                          CloseDate = system.Today()+30, Primary_Quote_Exception__c = true, Validation_Stage__c = '6 - Technical Win', Validation_Plan__c = 'Test', AD_Forecast_Category__c='Pipeline',AD_Forecast_Category_Lock__c=true, Next_Steps__c  = 'fdsjsdk');
        insert opp;

		test.startTest();
        OpportunitySplit  oppSplit = new OpportunitySplit(OpportunityId = opp.Id, SplitPercentage = 10, SplitOwnerId = users[0].id);
        oppSplit.Override_SE__c = false;
        insert oppSplit;
		test.stopTest();
    }
    
    static testmethod void test5() {
        
        PatchTeam__c pt= new PatchTeam__c();
        pt.Sales_Territory_Year__c = 'Current';
        
        insert pt;
        
        PatchTeamMember__c ptm= new PatchTeamMember__c();
        ptm.User__c = UserInfo.getUserId();
        ptm.PatchTeam__c = pt.Id;
        ptm.Role__c = ' Account Manager';
        insert ptm;
        
        List<user> users = [select id from user where IsActive = true AND Profile.Name = 'System Administrator' ];
        Account acc = new Account(Name = 'Test Account 23');
        insert acc;
        
        Id oppRecordTypeId = Schema.SObjectType.opportunity.getRecordTypeInfosByName().get('Renewal Opportunity').getRecordTypeId();
        opportunity opp = new opportunity(Name = 'Test opportunity', AccountId = acc.Id, StageName = Label.Stage_1_Alignment , CloseDate = system.Today()+30);
        opp.Type = 'Existing Customer (Renewal)';
        opp.Has_Multiple_Upsell_Split_Lines__c = false;
        opp.recordTypeId = oppRecordTypeId;
        
        insert opp;
        test.startTest();
        OpportunitySplit  oppSplit = new OpportunitySplit(OpportunityId = opp.Id, SplitPercentage = 10, SplitOwnerId = users[0].id);
        oppSplit.Split_Type__c = 'Upsell';
        
        insert oppSplit;
        
        System.runas(users[1]) {
            OpportunitySplit  oppSplitNew = new OpportunitySplit(OpportunityId = opp.Id, SplitPercentage = 10, SplitOwnerId = users[1].id);
            oppSplitNew.Split_Type__c = 'Upsell';
            insert oppSplitNew;
        }
        test.stopTest();
    }
    
    static testmethod void test6() {
        
        PatchTeam__c pt= new PatchTeam__c();
        pt.Sales_Territory_Year__c = 'Current';
        insert pt;
        
        PatchTeamMember__c ptm= new PatchTeamMember__c();
        ptm.User__c = UserInfo.getUserId();
        ptm.PatchTeam__c = pt.Id;
        ptm.Role__c = ' Account Manager';
        insert ptm;
        
        List<user> users = [select id from user where IsActive = true AND Profile.Name = 'System Administrator' ];
        Account acc = new Account(Name = 'Test Account 23');
        insert acc;
       
       User partnerProgramPMUser = new User(ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,Alias = 'alias',
                                TimeZoneSidKey = 'America/Los_Angeles',EmailEncodingKey = 'UTF-8',LanguageLocaleKey = 'en_US',LocaleSidKey = 'en_US',
                                LastName = 'Partner Program PM',Email = 'max@bupa.com',Username = 'max@bupa.com');
       insert partnerProgramPMUser ;
        
        Id oppRecordTypeId = Schema.SObjectType.opportunity.getRecordTypeInfosByName().get('Renewal Opportunity').getRecordTypeId();
        opportunity opp = new opportunity(Name = 'Test opportunity', AccountId = acc.Id, StageName = Label.Stage_1_Alignment , CloseDate = system.Today()+30);
        opp.Type = 'Existing Customer (Renewal)';
        opp.Has_Multiple_Upsell_Split_Lines__c = false;
        opp.recordTypeId = oppRecordTypeId;
        
        insert opp;
        test.startTest();
        OpportunitySplit  oppSplit = new OpportunitySplit(OpportunityId = opp.Id, SplitPercentage = 10, SplitOwnerId = partnerProgramPMUser.id);
        oppSplit.Split_Type__c = 'Renewal';
        
        insert oppSplit;
        
        test.stopTest();
    }
    
}