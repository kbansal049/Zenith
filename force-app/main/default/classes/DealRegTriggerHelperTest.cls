/*****************************************************************************************
Name: DealRegTriggerHelperTest
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
Test class for AssociatedOpportunityDealRegsExt
==========================================================================================
==========================================================================================
History
-------
VERSION        AUTHOR                  DATE              DETAIL
1.0            Kunal Raj            4-OCT-2016    Initial Development
******************************************************************************************/


@isTest(SeeAllData=false)
public class DealRegTriggerHelperTest{
    public static Map<String, Account> mapAccounts;

    static testMethod void testDealRegTriggerHelper(){
        TriggerUtility.prospectTypeUpdExecuted();
        triggerUtility.contactPatchManagerExecuted();
        triggerUtility.accTerritoryPatchExecuted();
        triggerUtility.oppPatchManagerAfterInsertExecuted();
        triggerUtility.oppPatchManagerAfterUpdateExecuted();
    //Added By Swathi:CR1058 start
        TriggerUtility.isDRPendingNBMConvertedExecuted();
        TriggerUtility.isDRCopyPriorStatusonExpExtensionExecuted();
        TriggerUtility.isDRPriorStatusCaptureExecuted();
        TriggerUtility.isDRRemovalfromOppExecuted();
        //Added By Swathi:CR1058 End
        RecordType rt = [SELECT Id FROM RecordType where Name='Partner' and SobjectType='Account'];
        list<Account> accInsertList = new list<Account>();
        Account acc = new account();
        Acc.Name = 'Test Data';
        acc.Domain__c = 'abc.com';
        acc.Partner_Type__c = 'Partner-Reseller';
        acc.Sales_Engineer__c = UserInfo.getUserId();
        acc.SummitDistribution__c=true;
        acc.Type='Partner';
        accInsertList.add(acc);

        Account acc1 = new account();
        Acc1.Name = 'Test partner';
        acc1.Domain__c = 'partner5.com';
        acc1.Partner_Type__c = 'Partner-Reseller';
        acc1.Sales_Engineer__c = UserInfo.getUserId();
        acc1.Ultimate_Parent_Account__c = acc.Id;//Varun
        acc1.type='Technology Partner';
        acc1.Partner_Level__c = 'Tier 1: Strategic';
        //acc1.SummitDistribution__c=true;
        acc1.RecordTypeId =rt.Id;
        accInsertList.add(acc1);
		
        Account acc2 = new account();
        Acc2.Name = 'Test partner';
        acc2.Domain__c = 'partner.com';
        acc2.Partner_Type__c = 'Partner-Distributor';
        acc2.Sales_Engineer__c = UserInfo.getUserId();
        acc2.SummitDistribution__c=true;
        acc2.Program_Type__c ='Distribution';
        acc2.Type='Partner';
        acc2.RecordTypeId =rt.Id;
        accInsertList.add(acc2);
        insert accInsertList;
        System.debug('Total Number of SOQL Queries allowed in this apex code context: ' +  Limits.getQueries());
        acc2.Ultimate_Parent_Account__c = acc1.Id;
        update acc2;
        List<Partner_Incentive__c> piList = new List<Partner_Incentive__c>();
        piList.add((SB_TestCPQDataUtility.createPartnerIncentive(1,accInsertList[2].Id,true,system.today(),system.today(),'Traditional','MSP'))[0]);
        piList.add((SB_TestCPQDataUtility.createPartnerIncentive(1,accInsertList[2].Id,true,system.today()+365,system.today()-30,'Summit - Discount','MSP'))[1]);
        piList[1].Default__c=true;
        piList[1].Partner_Role__c='Reseller';
        piList[1].Transacting_Entity__c=accInsertList[2].Id;
        piList[1].Transacting_Location__c='China';
        piList[0].Partner_Role__c='Distributor';
        insert piList;
        
        System.debug('Total Number of SOQL Queries allowed in this apex code context: ' +  Limits.getQueries());
        Campaign camp = new Campaign();
        camp.Name = 'Deal Registration';
        camp.EndDate = system.today() + 30;
        camp.IsActive = true;
        insert camp;
        ZscalerSetting__c zs = new ZscalerSetting__c();
        zs.Name = 'DealRegCampaign';
        zs.Value__c = ''+camp.Id;
        insert zs;
        System.debug('Total Number of SOQL Queries allowed in this apex code context: ' +  Limits.getQueries());
        ZscalerSetting__c zs1 = new ZscalerSetting__c();
        zs1.Name = 'DealRegCaseReviewOwnerId';
        zs1.Value__c = ''+userInfo.getuserId();
        insert zs1;
        System.debug('Total Number of SOQL Queries allowed in this apex code context: ' +  Limits.getQueries());
        Contact con = new Contact();
        con.firstName = 'Jhon';
        con.LastName = 'Smith';
        con.email = 'jhon@abcd.com';
        con.AccountId = acc2.Id;
        insert con;
    
    //Added By Swathi:CR#1058 Start
    	PatchTeam__c pct = new PatchTeam__c(Territory_Type__c = 'Enterprise',name = 'Sales Enterprise');
        PatchTeam__c pct2 = new PatchTeam__c(Territory_Type__c = 'Enterprise',name = 'Sales Enterprise');
        insert pct;
        insert pct2;
        
        List<Focus_Partner__c> focusPartner = New List<Focus_Partner__c>();
        Focus_Partner__c focusMem = new Focus_Partner__c(Comments__c='Test',RAM__c = userinfo.getUserId(),Partner_Account__c = acc2.Id,Sales_Territory__c=pct.Id);
		Focus_Partner__c focusMem1 = new Focus_Partner__c(Comments__c='Test',RAM__c = userinfo.getUserId(),Partner_Account__c = acc.Id,Sales_Territory__c=pct.Id);
        focusPartner.add(focusMem);focusPartner.add(focusMem1);
        insert focusPartner;
        
        List<PatchTeamMember__c> patchTeam = new List<PatchTeamMember__c>();
        PatchTeamMember__c member = new PatchTeamMember__c(PatchTeam__c=pct.Id, Role__c='Account Manager', User__c=UserInfo.getUserId());
        PatchTeamMember__c member1 = new PatchTeamMember__c(PatchTeam__c=pct.Id, Role__c='Area Director', User__c=UserInfo.getUserId());
        PatchTeamMember__c member2 = new PatchTeamMember__c(PatchTeam__c=pct.Id, Role__c='Channel Manager', User__c=UserInfo.getUserId());
        PatchTeamMember__c member3 = new PatchTeamMember__c(PatchTeam__c=pct.Id, Role__c='Channel Manager 2', User__c=UserInfo.getUserId());
        PatchTeamMember__c member4 = new PatchTeamMember__c(PatchTeam__c=pct.Id, Role__c='Channel Manager 3', User__c=UserInfo.getUserId());
        PatchTeamMember__c member5 = new PatchTeamMember__c(PatchTeam__c=pct.Id, Role__c='Channel Manager 4', User__c=UserInfo.getUserId());
        PatchTeamMember__c member6 = new PatchTeamMember__c(PatchTeam__c=pct.Id, Role__c='Geo VP', User__c=UserInfo.getUserId());
        PatchTeamMember__c member7 = new PatchTeamMember__c(PatchTeam__c=pct.Id, Role__c='Regional VP', User__c=UserInfo.getUserId());
        PatchTeamMember__c member8 = new PatchTeamMember__c(PatchTeam__c=pct.Id, Role__c='Tech Partner Sales Manager', User__c=UserInfo.getUserId());
        PatchTeamMember__c member9 = new PatchTeamMember__c(PatchTeam__c=pct.Id, Role__c='Tech Partner Solution Architect', User__c=UserInfo.getUserId());
        patchTeam.add(member);
        patchTeam.add(member1);
        patchTeam.add(member2);
        patchTeam.add(member3);
        patchTeam.add(member4);
        patchTeam.add(member5);
        patchTeam.add(member6);
        patchTeam.add(member7);
        patchTeam.add(member8);
        patchTeam.add(member9);
        insert patchTeam;
        
        List<Triggers_Switch__c> trlst = new List<Triggers_Switch__c>();
        Triggers_Switch__c tr1 = new Triggers_Switch__c(name = 'Execute_DR_Pending_NBM_To_Converted', Execute__c = true);
        Triggers_Switch__c tr2 = new Triggers_Switch__c(name = 'Execute_DR_Revert_Status_Exp_Extension', Execute__c = true);
        Triggers_Switch__c tr3 = new Triggers_Switch__c(name = 'Execute_DR_Capture_Prior_Status', Execute__c = true);
        Triggers_Switch__c tr4 = new Triggers_Switch__c(name = 'Execute_DR_Removal_from_Opp', Execute__c = true);
        trlst.add(tr1);trlst.add(tr2);trlst.add(tr3);trlst.add(tr4);
        insert trlst;
        //Added By Swathi:CR#1058 End
    
        System.debug('Total Number of SOQL Queries allowed in this apex code context: ' +  Limits.getQueries());
        test.startTest();
        Lead le = new Lead();
        le.Company = 'test Company';
        le.FirstName = 'Test';
        le.LastName = 'Name';
        le.Email = 'test@abc.com';
    le.Territory__c = pct.id; //Added By Swathi:CR#1058
        insert le;
        System.debug('Total Number of SOQL Queries allowed in this apex code context: ' +  Limits.getQueries());
        
        
        list<Deal_Reg__c> dealRegInsertList = new list<Deal_Reg__c>();

        Deal_Reg__c deal = new Deal_Reg__c();
        deal.End_Customer_Contact_Name__c = 'Test';
        deal.End_Customer_Contact_Last_Name__c= 'Test';
        deal.End_Customer_Country__c = 'US';
        deal.End_Customer_Domain__c = 'abc.com';
        deal.End_Customer_Email__c  = 'Test@abc.com';
        deal.End_Customer_Name__c = 'ABC Inc';
        deal.End_Customer_Phone__c = '123456789';
        deal.End_Customer_State__c = 'US';
        deal.DS_Review_Status__c = 'Pending Review';
        deal.Estimated_Amount__c = 1234567;
        deal.Expected_Close_Date__c = system.today() + 30;
        deal.Market_Segment__c = 'SMB';
        deal.Number_of_Users__c = 1234567;
        deal.Partner_Company_Name__c = 'Test partner';
        //deal.Partner_Contact_Email__c = 'Test@partner.com';
        deal.Partner_Contact_Name__c = 'Test';
        deal.Partner_Contact_Last_Name__c  = 'Partner';
        deal.Partner_Country__c  = 'US';
        deal.Partner_Domain__c  = 'partner.com';
        deal.Source__c = 'Deal Reg';
        deal.Status__c = 'Submitted';
        deal.Partner_Account__c = acc1.Id;
        deal.Partner_Contact__c = con.Id;
        dealRegInsertList.add(deal);

        Deal_Reg__c deal1 = new Deal_Reg__c();
        deal1.End_Customer_Contact_Name__c = 'Test';
        deal1.End_Customer_Contact_Last_Name__c= 'Test';
        deal1.End_Customer_Country__c = 'US';
        deal1.End_Customer_Domain__c = 'abcd.com';
        deal1.End_Customer_Email__c  = 'jhon@abcd.com';
        deal1.End_Customer_Name__c = 'ABC Inc';
        deal1.End_Customer_Phone__c = '123456789';
        deal1.End_Customer_State__c = 'US';
        deal1.DS_Review_Status__c = 'Pending Review';
        deal1.Estimated_Amount__c = 1234567;
        deal1.Expected_Close_Date__c = system.today() + 30;
        deal1.Market_Segment__c = 'SMB';
        deal1.Number_of_Users__c = 1234567;
        deal1.Partner_Company_Name__c = 'Test partner';
        deal1.Partner_Contact_Email__c = 'Test@partner.com';
        deal1.Partner_Contact_Name__c = 'Test';
        deal1.Partner_Contact_Last_Name__c  = 'Partner';
        deal1.Partner_Country__c  = 'US';
        deal1.Partner_Domain__c  = 'partner.com';
        deal1.Source__c = 'Deal Reg';
        deal1.Status__c = 'Submitted';
        deal1.Lead__c = le.id;
        deal1.Contact__c = con.id;
        dealRegInsertList.add(deal1);

        Deal_Reg__c deal2 = new Deal_Reg__c();
        deal2.End_Customer_Contact_Name__c = 'Test';
        deal2.End_Customer_Contact_Last_Name__c= 'Test';
        deal2.End_Customer_Country__c = 'China';
        deal2.End_Customer_Domain__c = 'abcd.com';
        deal2.End_Customer_Email__c  = 'Test@abcde.com';
        deal2.End_Customer_Name__c = 'ABC Inc';
        deal2.End_Customer_Phone__c = '123456789';
        deal2.End_Customer_State__c = 'China';
        deal2.DS_Review_Status__c = 'Pending Review';
        deal2.Estimated_Amount__c = 1234567;
        deal2.Expected_Close_Date__c = system.today() + 30;
        deal2.Market_Segment__c = 'SMB';
        deal2.Number_of_Users__c = 1234567;
        deal2.Partner_Account__c = acc1.Id;
        deal2.Partner_Company_Name__c = 'Test partner';
        deal2.Partner_Contact_Email__c = 'Test@partner.com';
        deal2.Partner_Contact_Name__c = 'Test';
        deal2.Partner_Contact_Last_Name__c  = 'Partner';
        deal2.Partner_Country__c  = 'China';
        deal2.Partner_Domain__c  = 'partner.com';
        deal2.Source__c = 'Deal Reg';
        deal2.Status__c = 'Submitted';
        dealRegInsertList.add(deal2);

        Deal_Reg__c deal3 = new Deal_Reg__c();
        deal3.End_Customer_Contact_Name__c = 'Test3';
        deal3.End_Customer_Contact_Last_Name__c= 'Test3';
        deal3.End_Customer_Country__c = 'China';
        deal3.End_Customer_Domain__c = 'abc.com';
        deal3.End_Customer_Email__c  = 'Test@abc.com';
        deal3.End_Customer_Name__c = 'ABC Inc';
        deal3.End_Customer_Phone__c = '123456785';
        deal3.End_Customer_State__c = 'China';
        deal3.DS_Review_Status__c = 'Pending Review';
        deal3.Estimated_Amount__c = 1234567;
        deal3.Expected_Close_Date__c = system.today() + 30;
        deal3.Market_Segment__c = 'SMB';
        deal3.Number_of_Users__c = 1234567;
        deal3.Partner_Company_Name__c = 'Test partner';
        deal3.Partner_Contact_Email__c = 'Test@partner.com';
        deal3.Partner_Contact_Name__c = 'Test';
        deal3.Partner_Contact_Last_Name__c  = 'Partner';
        deal3.Partner_Country__c  = 'China';
        deal3.Partner_Domain__c  = 'partner.com';
        deal3.Source__c = 'Deal Reg';
        deal3.Partner_Account__c = acc2.Id;
        deal3.Status__c = 'Submitted';
        deal3.Partner_Contact__c=con.Id;
        dealRegInsertList.add(deal3);
        
        insert dealRegInsertList;
        
        TriggerUtility.DRRemovalfromOppReset();
        deal3.Status__c = 'Pending Expiration';
        deal3.Partner_Account__c = acc1.Id;
        update deal3;
        System.debug('Update deal3 ' +  deal3.Status__c);
        test.stopTest();
        System.debug('Total Number of SOQL Queries allowed in this apex code context: ' +  Limits.getQueries());
		List<Opportunity> oppList = new List<Opportunity>();
        
        Opportunity opp = new Opportunity();
        Opp.Name = 'Test Opp';
        Opp.CloseDate = system.Today() + 30;
        Opp.AccountId = acc.Id;
        Opp.Amount = 123456;
        opp.StageName = label.Stage_1_Alignment /*'1 - Qualified and Budgeted'*/;
        opp.Deal_Reg__c = deal.Id;
        Opp.Associated_Deal_Registrations__c = deal.Name;
        
        Opportunity opp2 = new Opportunity();
        opp2.Name = 'Test Opp 2';
        opp2.CloseDate = system.Today() + 30;
        opp2.AccountId = acc.Id;
        opp2.Amount = 123456;
        opp2.StageName = label.Stage_1_Alignment /*'1 - Qualified and Budgeted'*/;
        opp2.Deal_Reg__c = deal3.Id;
        opp2.Associated_Deal_Registrations__c = deal.Name;
        
        Opportunity opp3 = new Opportunity();
        opp3.Name = 'Test Opp 3';
        opp3.CloseDate = system.Today() + 30;
        opp3.AccountId = acc.Id;
        opp3.Amount = 123456;
        opp3.StageName = label.Stage_1_Alignment /*'1 - Qualified and Budgeted'*/;
        opp3.Deal_Reg_Teaming_Reseller__c = deal3.Id;
        opp3.Associated_Deal_Registrations__c = deal.Name;
        
        Opportunity opp4 = new Opportunity();
        opp4.Name = 'Test Opp';
        opp4.CloseDate = system.Today() + 30;
        opp4.AccountId = acc.Id;
        opp4.Amount = 123456;
        opp4.StageName = label.Stage_1_Alignment /*'1 - Qualified and Budgeted'*/;
        //opp4.Deal_Reg_Teaming_Tech_Partner__c = deal3.Id;
        opp4.Associated_Deal_Registrations__c = deal.Name;
        oppList.add(opp);
        oppList.add(opp2);
        oppList.add(opp3);
        oppList.add(opp4);
        TriggerHandler.bypass('OpportunityTriggerHandler');
        insert oppList;
        TriggerHandler.clearBypass('OpportunityTriggerHandler');
        System.debug('Total Number of SOQL Queries allowed in this apex code context: ' +  Limits.getQueries());
        //deal1.Status__c = 'Approved';
        update deal;
        update deal3;
        System.debug('Total Number of SOQL Queries allowed in this apex code context: ' +  Limits.getQueries());
        
        deal.Sales_Territory__c =pct2.Id;
        deal1.Sales_Territory__c =pct2.Id;
        deal2.Sales_Territory__c =pct2.Id;
        deal3.Sales_Territory__c =pct2.Id;
        update dealRegInsertList;
        deal.Sales_Territory__c =pct.Id;
        deal1.Sales_Territory__c =pct.Id;
        deal2.Sales_Territory__c =pct.Id;
        deal3.Sales_Territory__c =pct.Id;
        update dealRegInsertList;
    }
    
    /*public static testmethod void testsplitdealregtest(){
        TriggerUtility.prospectTypeUpdExecuted();
        triggerUtility.contactPatchManagerExecuted();
        triggerUtility.accTerritoryPatchExecuted();
        triggerUtility.oppPatchManagerAfterInsertExecuted();
        triggerUtility.oppPatchManagerAfterUpdateExecuted();
        Campaign camp = new Campaign();
        camp.Name = 'Deal Registration';
        camp.EndDate = system.today() + 30;
        camp.IsActive = true;
        insert camp;
        ZscalerSetting__c zs = new ZscalerSetting__c();
        zs.Name = 'DealRegCampaign';
        zs.Value__c = ''+camp.Id;
        insert zs;
        System.debug('Total Number of SOQL Queries allowed in this apex code context: ' +  Limits.getQueries());
        ZscalerSetting__c zs1 = new ZscalerSetting__c();
        zs1.Name = 'DealRegCaseReviewOwnerId';
        zs1.Value__c = ''+userInfo.getuserId();
        insert zs1;
        
        List<Lead> ldlst = new List<lead>();
        Lead le = new Lead();
        le.Company = 'test Company';
        le.FirstName = 'Test';
        le.LastName = 'Name';
        le.Email = 'test@abc.com';
        le.ZPA_Interactive_Lead__c = true;
        ldlst.add(le);
        
        Lead le1 = new Lead();
        le1.Company = 'test Company';
        le1.FirstName = 'Test';
        le1.LastName = 'Name';
        le1.Email = 'test@abc.com';
        ldlst.add(le1);
        insert ldlst;
        //le1.ZPA_Interactive_Lead__c = true;
        le1.Lead_Development__c = [Select Id from User where isactive = true limit 1].Id;
        update le1;
        
        test.starttest();
        Deal_Reg__c deal = new Deal_Reg__c();
        deal.End_Customer_Contact_Name__c = 'Test';
        deal.End_Customer_Contact_Last_Name__c= 'Test';
        deal.End_Customer_Country__c = 'US';
        deal.End_Customer_Domain__c = 'abc.com';
        deal.End_Customer_Email__c  = 'Test@abc.com';
        deal.End_Customer_Name__c = 'ABC Inc';
        deal.End_Customer_Phone__c = '123456789';
        deal.End_Customer_State__c = 'US';
        deal.DS_Review_Status__c = 'Pending Review';
        deal.Estimated_Amount__c = 1234567;
        deal.Expected_Close_Date__c = system.today() + 30;
        deal.Market_Segment__c = 'SMB';
        deal.Number_of_Users__c = 1234567;
        deal.Partner_Company_Name__c = 'Test partner';
        deal.Partner_Contact_Email__c = 'Test@partner.com';
        deal.Partner_Contact_Name__c = 'Test';
        deal.Partner_Contact_Last_Name__c  = 'Partner';
        deal.Partner_Country__c  = 'US';
        deal.Partner_Domain__c  = 'partner.com';
        deal.Source__c = 'Deal Reg';
        deal.Status__c = 'Submitted';
        insert deal;
        
        map<String, Deal_Reg__c> dealRegMap = new map<string, Deal_Reg__c>();
        dealRegMap.put(deal.End_Customer_Email__c, deal);
        DealRegTriggerHelper.createLeadForDealReg(dealRegMap);
        System.debug('Total Number of SOQL Queries allowed in this apex code context: ' +  Limits.getQueries());
        test.stoptest();
    
    }*/
    static testMethod void dealRegAutoUpdateScenario(){
        TriggerUtility.prospectTypeUpdExecuted();
        triggerUtility.contactPatchManagerExecuted();
        triggerUtility.accTerritoryPatchExecuted();
        triggerUtility.oppPatchManagerAfterInsertExecuted();
        triggerUtility.oppPatchManagerAfterUpdateExecuted();
        DealRegTestDataFactory.createPatchTeamsAndGeoLeaderMappings();
        DealRegTestDataFactory.createAccountAndContact('TestCust1', 'testcust1.com', DealRegTestDataFactory.mapPatchTeams.get('EMEA|General Business').Id, 'Enterprise', 1);
		Account acc = TestDatafactory_Zscaler.insertAccount('Test Account1', null, 'Partner', null, null, null);
        
        PatchTeam__c amerPatchTeam1 = new PatchTeam__c();
        amerPatchTeam1.Area__c = 'AMERICAS';
        amerPatchTeam1.Region__c = 'AMERICAS';
        amerPatchTeam1.Territory_Type__c = 'Commercial';
        amerPatchTeam1.Theater__c = 'International';
        insert amerPatchTeam1;
        Focus_Partner__c focusMem = new Focus_Partner__c(Comments__c='Test',RAM__c = userinfo.getUserId(),Partner_Account__c = acc.Id,Sales_Territory__c=amerPatchTeam1.Id);
        insert focusMem;
        
        Deal_Reg__c dealReg = DealRegTestDataFactory.createDealReg('vprakash@zscaler.com', 'IT Authorities', 'TestCust1', 'testcust1.com', 'India', DealRegTestDataFactory.mapPatchTeams.get('EMEA|General Business'), 'SMB');
		System.debug('>>>>dealReg ' + dealReg);
        Deal_Reg__c dealReg2 = DealRegTestDataFactory.createDealReg('vprakash@zscaler.com', 'IT Authorities', 'TestCust1', 'testcust1.com', 'India', DealRegTestDataFactory.mapPatchTeams.get('EMEA|General Business'), 'SMB');
        System.debug('>>>>dealReg2 ' + dealReg2);
        Test.startTest();
        dealReg.Sales_Territory__c = DealRegTestDataFactory.mapPatchTeams.get('EMEA|General Business').Id;
        dealReg.Market_Segment__c = 'SMB';
        dealReg.DS_Review_Status__c = 'Complete';
        dealReg.Partner_Account__c = acc.Id;
        //dealReg.Territory_Type__c = 'Commercial';
        update dealReg;
        dealReg2.Market_Segment__c = 'SMB';
        dealReg2.DS_Review_Status__c = 'Complete';
        dealReg2.Status__c = 'Converted';
        dealReg2.Partner_Account__c = acc.Id;
        dealReg2.Sales_Territory__c = amerPatchTeam1.Id;
        System.debug('>>>> ' + dealReg2);
        TriggerUtility.dealRegAfterUpdateReset();
        update dealReg2;
        System.debug('>>>> ' + dealReg2);
        System.debug('>>>> ' + dealReg.Name);
        Test.stopTest();
    }

    static testMethod void dealRegApprovalSubmissionScenario() {
        TriggerUtility.prospectTypeUpdExecuted();
        triggerUtility.contactPatchManagerExecuted();
        triggerUtility.accTerritoryPatchExecuted();
        triggerUtility.oppPatchManagerAfterInsertExecuted();
        triggerUtility.oppPatchManagerAfterUpdateExecuted();
        DealRegTestDataFactory.createPatchTeamsAndGeoLeaderMappings();
        DealRegTestDataFactory.createAccountAndContact('TestCust1', 'testcust1.com', DealRegTestDataFactory.mapPatchTeams.get('EMEA|Enterprise').Id, 'Enterprise', 1);
		PatchTeam__c amerPatchTeam1 = new PatchTeam__c();
        amerPatchTeam1.Area__c = 'AMERICAS';
        amerPatchTeam1.Region__c = 'AMERICAS';
        amerPatchTeam1.Territory_Type__c = 'Commercial';
        amerPatchTeam1.Theater__c = 'International';
        insert amerPatchTeam1;
        
        Deal_Reg__c dealReg = DealRegTestDataFactory.createDealReg('vprakash@zscaler.com', 'IT Authorities', 'TestCust1', 'testcust1.com', 'India', DealRegTestDataFactory.mapPatchTeams.get('EMEA|General Business'), 'SMB');

        Test.startTest();
        dealReg.Sales_Territory__c = DealRegTestDataFactory.mapPatchTeams.get('EMEA|Enterprise').Id;
        dealReg.Market_Segment__c = 'Enterprise';
        dealReg.DS_Review_Status__c = 'Complete';
        update dealReg;
        dealReg.Sales_Territory__c = amerPatchTeam1.Id;
        TriggerUtility.dealRegAfterUpdateReset();
        update dealReg;
        System.debug('>>>> ' + dealReg);
        System.debug('>>>> ' + dealReg.Name);
        //DealRegTriggerHelper.booster();
        Test.stopTest();
    }

   /*  static testMethod void dealRegGEOEscalationScenario() {
        TriggerUtility.prospectTypeUpdExecuted();
        triggerUtility.contactPatchManagerExecuted();
        triggerUtility.accTerritoryPatchExecuted();
        triggerUtility.oppPatchManagerAfterInsertExecuted();
        triggerUtility.oppPatchManagerAfterUpdateExecuted();

        list<Account> accInsertList = new list<Account>();
        Account acc = new account();
        Acc.Name = 'Test Data';
        acc.Domain__c = 'abc.com';
        acc.Partner_Type__c = 'Partner-Reseller';
        acc.Sales_Engineer__c = UserInfo.getUserId();
        accInsertList.add(acc);

        Account acc1 = new account();
        Acc1.Name = 'Test partner parent';
        acc1.Domain__c = 'partner.com';
        acc1.Partner_Type__c = 'Partner-Reseller';
        acc1.Sales_Engineer__c = UserInfo.getUserId();
        accInsertList.add(acc1);

        Account acc2 = new account();
        Acc2.Name = 'Test partner';
        acc2.Domain__c = 'partner.com';
        acc2.Partner_Type__c = 'Partner-Reseller';
        acc2.Sales_Engineer__c = UserInfo.getUserId();
        accInsertList.add(acc2);
        insert accInsertList;

        acc2.Ultimate_Parent_Account__c = acc1.Id;
        update acc2;

        mapAccounts = new Map<String, Account>();
        mapAccounts.put(acc.Name, acc);
        mapAccounts.put(acc1.Name, acc1);
        mapAccounts.put(acc2.Name, acc2);

        DealRegTestDataFactory.createPatchTeamsAndGeoLeaderMappings();
        DealRegTestDataFactory.createAccountAndContact('TestCust1', 'testcust1.com', DealRegTestDataFactory.mapPatchTeams.get('EMEA|Enterprise').Id, 'Enterprise', 1);

        Deal_Reg__c dealReg = DealRegTestDataFactory.createDealReg('vprakash@zscaler.com', 'IT Authorities', 'TestCust1', 'testcust1.com', 'India', DealRegTestDataFactory.mapPatchTeams.get('EMEA|General Business'), 'SMB');

        dealReg.Sales_Territory__c = DealRegTestDataFactory.mapPatchTeams.get('EMEA|Enterprise').Id;
        dealReg.Market_Segment__c = 'Enterprise';
        dealReg.DS_Review_Status__c = 'Complete';
        dealReg.Partner_Account__c = mapAccounts.get('Test partner parent').Id;
        update dealReg;

        Test.startTest();
        dealReg.Escalated_To_GEO_Leader__c = true;
        update dealReg;
        System.debug('>>>> ' + dealReg);
        System.debug('>>>> ' + dealReg.Name);
        Test.stopTest();
    }  */

    static testMethod void dealRegAutoRejectionScenario() {
        TriggerUtility.prospectTypeUpdExecuted();
        triggerUtility.contactPatchManagerExecuted();
        triggerUtility.accTerritoryPatchExecuted();
        triggerUtility.oppPatchManagerAfterInsertExecuted();
        triggerUtility.oppPatchManagerAfterUpdateExecuted();
        DealRegTestDataFactory.createPatchTeamsAndGeoLeaderMappings();
        DealRegTestDataFactory.createAccountAndContact('TestCust1', 'testcust1.com', DealRegTestDataFactory.mapPatchTeams.get('EMEA|Enterprise').Id, 'Enterprise', 1);

        Deal_Reg__c dealReg = DealRegTestDataFactory.createDealReg('vprakash@zscaler.com', 'IT Authorities', 'TestCust1', 'testcust1.com', 'India', DealRegTestDataFactory.mapPatchTeams.get('EMEA|General Business'), 'SMB');

        dealReg.Sales_Territory__c = DealRegTestDataFactory.mapPatchTeams.get('EMEA|Enterprise').Id;
        dealReg.Market_Segment__c = 'Enterprise';
        dealReg.DS_Review_Status__c = 'Complete';
        dealReg.Approval_Status__c = 'Channel Manager Rejected';
        dealReg.Channel_Manager__c = DealRegTestDataFactory.geoLeader.Id;
        update dealReg;
        dealReg.Sales_Territory__c = DealRegTestDataFactory.mapPatchTeams.get('EMEA|General Business').Id;	
        Test.startTest();
        dealReg.Escalated_To_GEO_Leader__c = true;
        update dealReg;
        
        System.debug('>>>> ' + dealReg);
        System.debug('>>>> ' + dealReg.Name);
        Test.stopTest();
    }

    static testMethod void dealRegNoPartnerAccountFoundScenario() {
        TriggerUtility.prospectTypeUpdExecuted();
        triggerUtility.contactPatchManagerExecuted();
        triggerUtility.accTerritoryPatchExecuted();
        triggerUtility.oppPatchManagerAfterInsertExecuted();
        triggerUtility.oppPatchManagerAfterUpdateExecuted();
        DealRegTestDataFactory.createPatchTeamsAndGeoLeaderMappings();
        DealRegTestDataFactory.createAccountAndContact('TestCust1', 'testcust1.com', DealRegTestDataFactory.mapPatchTeams.get('EMEA|Enterprise').Id, 'Enterprise', 1);

        Deal_Reg__c dealReg = DealRegTestDataFactory.createDealReg('vprakash@zscaler.com', 'IT Authorities', 'TestCust1', 'testcust1.com', 'India', DealRegTestDataFactory.mapPatchTeams.get('EMEA|General Business'), 'SMB');
		dealReg.Deal_Reg_Type__c='Teaming';
        dealReg.Sales_Territory__c = DealRegTestDataFactory.mapPatchTeams.get('EMEA|Enterprise').Id;
        dealReg.Market_Segment__c = 'Enterprise';
        dealReg.Channel_Manager__c = DealRegTestDataFactory.geoLeader.Id;
        dealReg.Channel_Manager_2__c = DealRegTestDataFactory.geoLeader.Id;
        dealReg.Channel_Manager_3__c = DealRegTestDataFactory.geoLeader.Id;
        dealReg.Channel_Manager_4__c = DealRegTestDataFactory.geoLeader.Id;
        dealReg.Channel_Manager_5__c = DealRegTestDataFactory.geoLeader.Id;
        dealReg.Partner_Account_Owner__c = DealRegTestDataFactory.geoLeader.Id;
        update dealReg;

        Test.startTest();
        TriggerUtility.dealRegAfterUpdateReset();
        dealReg.Partner_Account__c = null;
        dealReg.DS_Review_Status__c = 'Complete';
        dealReg.Deal_Reg_Type__c='Sourced';
        update dealReg;
        System.debug('>>>> ' + dealReg);
        System.debug('>>>> ' + dealReg.Name);
        Test.stopTest();
    }
    
    static testMethod void dealRegPendingFinalReviewscenario() {
        TriggerUtility.prospectTypeUpdExecuted();
        triggerUtility.contactPatchManagerExecuted();
        triggerUtility.accTerritoryPatchExecuted();
        triggerUtility.oppPatchManagerAfterInsertExecuted();
        triggerUtility.oppPatchManagerAfterUpdateExecuted();
        DealRegTestDataFactory.createPatchTeamsAndGeoLeaderMappings();
        DealRegTestDataFactory.createAccountAndContact('TestCust1', 'testcust1.com', DealRegTestDataFactory.mapPatchTeams.get('EMEA|Enterprise').Id, 'Enterprise', 1);

        Deal_Reg__c dealReg = DealRegTestDataFactory.createDealReg('vprakash@zscaler.com', 'IT Authorities', 'TestCust1', 'testcust1.com', 'India', DealRegTestDataFactory.mapPatchTeams.get('EMEA|General Business'), 'SMB');

        dealReg.Sales_Territory__c = DealRegTestDataFactory.mapPatchTeams.get('EMEA|Enterprise').Id;
        dealReg.Market_Segment__c = 'Enterprise';
        dealReg.Channel_Manager__c = DealRegTestDataFactory.geoLeader.Id;
        dealReg.Area_Director__c = userinfo.getuserid();
        dealReg.DS_Review_Status__c = 'Complete';
        update dealReg;
        
        insert TestDatafactory_Zscaler.gettriggerswitchrecords(true);
        Test.startTest();
        dealReg.Status__c= Label.DR_Pending_Final_Review;
        update dealReg;
        System.debug('>>>> ' + dealReg);
        System.debug('>>>> ' + dealReg.Name);
        Test.stopTest();
    }
    
    static testMethod void dealRegRejectedscenario() {
        TriggerUtility.prospectTypeUpdExecuted();
        triggerUtility.contactPatchManagerExecuted();
        triggerUtility.accTerritoryPatchExecuted();
        triggerUtility.oppPatchManagerAfterInsertExecuted();
        triggerUtility.oppPatchManagerAfterUpdateExecuted();
        insert TestDatafactory_Zscaler.gettriggerswitchrecords(true);
        DealRegTestDataFactory.createPatchTeamsAndGeoLeaderMappings();
        DealRegTestDataFactory.createAccountAndContact('TestCust1', 'testcust1.com', DealRegTestDataFactory.mapPatchTeams.get('EMEA|Enterprise').Id, 'Enterprise', 1);

        Deal_Reg__c dealReg = DealRegTestDataFactory.createDealReg('vprakash@zscaler.com', 'IT Authorities', 'TestCust1', 'testcust1.com', 'India', DealRegTestDataFactory.mapPatchTeams.get('EMEA|General Business'), 'SMB');

        dealReg.Sales_Territory__c = DealRegTestDataFactory.mapPatchTeams.get('EMEA|Enterprise').Id;
        dealReg.Market_Segment__c = 'Enterprise';
        dealReg.Channel_Manager__c = DealRegTestDataFactory.geoLeader.Id;
        dealReg.DS_Review_Status__c = 'Complete';
        dealReg.Area_Director__c = userinfo.getuserid();
        update dealReg;
        dealReg.Sales_Territory__c = DealRegTestDataFactory.mapPatchTeams.get('EMEA|Enterprise').Id;
        dealReg.Status__c= Label.DR_Pending_Final_Review;
        update dealReg;

        Test.startTest();
        dealReg.Rejection_Reason__c = 'Rejected over Email';
        dealReg.Status__c= Label.DR_Rejected;
        update dealReg;
        System.debug('>>>> ' + dealReg);
        System.debug('>>>> ' + dealReg.Name);
        Test.stopTest();
    }
  
  //Added by Swathi: CR#1058 Starts
    static testMethod void dealRegRejectedscenario2() {
        TriggerUtility.prospectTypeUpdExecuted();
        triggerUtility.contactPatchManagerExecuted();
        triggerUtility.accTerritoryPatchExecuted();
        triggerUtility.oppPatchManagerAfterInsertExecuted();
        triggerUtility.oppPatchManagerAfterUpdateExecuted();
        insert TestDatafactory_Zscaler.gettriggerswitchrecords(true);
        DealRegTestDataFactory.createPatchTeamsAndGeoLeaderMappings();
        DealRegTestDataFactory.createAccountAndContact('TestCust1', 'testcust1.com', DealRegTestDataFactory.mapPatchTeams.get('EMEA|Enterprise').Id, 'Enterprise', 1);
		Account acc = TestDatafactory_Zscaler.insertAccount('Test Account1', null, 'Customer', null, null, null);
        Deal_Reg__c dealReg = DealRegTestDataFactory.createDealReg('vprakash@zscaler.com', 'IT Authorities', 'TestCust1', 'testcust1.com', 'India', DealRegTestDataFactory.mapPatchTeams.get('EMEA|General Business'), 'SMB');
        
        Account acc1 = new account();
        Acc1.Name = 'Test partner';
        acc1.Domain__c = 'partner.com';
        acc1.Partner_Type__c = 'Partner-Reseller';
        acc1.Sales_Engineer__c = UserInfo.getUserId();
        acc1.Ultimate_Parent_Account__c = acc.Id;
        insert acc1;
        
        Test.startTest();
        dealReg.Sales_Territory__c = DealRegTestDataFactory.mapPatchTeams.get('EMEA|Enterprise').Id;
        dealReg.Market_Segment__c = 'Enterprise';
        dealReg.Channel_Manager__c = DealRegTestDataFactory.geoLeader.Id;
        dealReg.DS_Review_Status__c = 'Complete';
        dealReg.Area_Director__c = userinfo.getuserid();
        dealReg.Partner_Account__c = acc1.id;
        update dealReg;
        
        dealReg.Rejection_Reason__c = 'Rejected over Email';
        dealReg.Status__c= Label.DR_Pending_Final_Review;
        update dealReg;
        
        dealReg.Status__c= Label.DR_Rejected;
        update dealReg;
        
        System.debug('----' + dealReg);
        System.debug('----' + dealReg.Name);
        Test.stopTest();
    }
    //Added by Swathi: CR#1058 End
    
    static testMethod void dealRegTriggerTest() {
        TriggerUtility.prospectTypeUpdExecuted();
        triggerUtility.contactPatchManagerExecuted();
        triggerUtility.accTerritoryPatchExecuted();
        triggerUtility.oppPatchManagerAfterInsertExecuted();
        triggerUtility.oppPatchManagerAfterUpdateExecuted();
        triggerUtility.DRRemovalfromOppReset();        
        Triggers_Switch__c tr4 = new Triggers_Switch__c(name = 'Execute_DR_Removal_from_Opp', Execute__c = true);
        insert TestDatafactory_Zscaler.gettriggerswitchrecords(true);
        DealRegTestDataFactory.createPatchTeamsAndGeoLeaderMappings();
        DealRegTestDataFactory.createAccountAndContact('TestCust1', 'testcust1.com', DealRegTestDataFactory.mapPatchTeams.get('EMEA|Enterprise').Id, 'Enterprise', 1);
		Account acc = TestDatafactory_Zscaler.insertAccount('Test Account1', null, 'Customer', null, null, null);
        Account acc1 = new account();
        Acc1.Name = 'Test partner';
        acc1.Domain__c = 'partner11.com';
        acc1.Partner_Type__c = 'Partner-Reseller';
        acc1.Sales_Engineer__c = UserInfo.getUserId();
        acc1.Ultimate_Parent_Account__c = acc.Id;
        insert acc1;
        list<Deal_Reg__c> dealRegInsertList = new list<Deal_Reg__c>();
        Deal_Reg__c deal2 = new Deal_Reg__c();
        deal2.End_Customer_Contact_Name__c = 'Test';
        deal2.End_Customer_Contact_Last_Name__c= 'Test';
        deal2.End_Customer_Country__c = 'US';
        deal2.End_Customer_Domain__c = 'abcd.com';
        deal2.End_Customer_Email__c  = 'Test@abcde.com';
        deal2.End_Customer_Name__c = 'ABC Inc';
        deal2.End_Customer_Phone__c = '123456789';
        deal2.End_Customer_State__c = 'US';
        deal2.DS_Review_Status__c = 'Pending Review';
        deal2.Estimated_Amount__c = 1234567;
        deal2.Expected_Close_Date__c = system.today() + 30;
        deal2.Market_Segment__c = 'SMB';
        deal2.Number_of_Users__c = 1234567;
        deal2.Partner_Account__c = acc1.Id;
        deal2.Partner_Company_Name__c = 'Test partner';
        deal2.Partner_Contact_Email__c = 'Test@partner.com';
        deal2.Partner_Contact_Name__c = 'Test';
        deal2.Partner_Contact_Last_Name__c  = 'Partner';
        deal2.Partner_Country__c  = 'US';
        deal2.Partner_Domain__c  = 'partner.com';
        deal2.Source__c = 'Deal Reg';
        deal2.Status__c = 'Submitted';
        dealRegInsertList.add(deal2);

        insert dealRegInsertList;
        Deal_Reg__c dealReg = DealRegTestDataFactory.createDealReg('vprakash@zscaler.com', 'IT Authorities', 'TestCust1', 'testcust1.com', 'India', DealRegTestDataFactory.mapPatchTeams.get('EMEA|General Business'), 'SMB');
		
        
        Test.startTest();
        Map<Id, Deal_Reg__c> oldMap = new Map<Id, Deal_Reg__c>();
        oldMap.put(dealReg.Id, dealReg);
        dealReg.Status__c = 'Pending Expiration';
        System.debug('Pending Expiration'+dealReg.Status__c);
        TriggerUtility.DRRemovalfromOppReset();
       // update dealReg;
        List<Deal_Reg__c> listDealReg = new List<Deal_Reg__c>();
        listDealReg.add(dealReg);
        System.debug('listDealReg'+listDealReg);
        System.debug('oldMap'+oldMap);
        //DealRegTriggerHelper.removeDRfromOpp(oldMap,listDealReg);
        DealRegTriggerHelper.RejectDRinApproval(oldMap,listDealReg);
        DealRegTriggerHelper.submitDRforFinalReview(oldMap,listDealReg);
        Test.stopTest();
    }
    
    static testMethod void testDealRegTriggerHelper1(){
        TriggerUtility.prospectTypeUpdExecuted();
        triggerUtility.contactPatchManagerExecuted();
        triggerUtility.accTerritoryPatchExecuted();
        triggerUtility.oppPatchManagerAfterInsertExecuted();
        triggerUtility.oppPatchManagerAfterUpdateExecuted();
    //Added By Swathi:CR1058 start
        TriggerUtility.isDRPendingNBMConvertedExecuted();
        TriggerUtility.isDRCopyPriorStatusonExpExtensionExecuted();
        TriggerUtility.isDRPriorStatusCaptureExecuted();
        TriggerUtility.isDRRemovalfromOppExecuted();
        //Added By Swathi:CR1058 End
    
        list<Account> accInsertList = new list<Account>();
        Account acc = new account();
        Acc.Name = 'Test Data';
        acc.Domain__c = 'abc.com';
        acc.Partner_Type__c = 'Partner-Reseller';
        acc.Sales_Engineer__c = UserInfo.getUserId();
        acc.SummitDistribution__c=true;
        acc.Type='Partner';
        accInsertList.add(acc);

        Account acc1 = new account();
        Acc1.Name = 'Test partner';
        acc1.Domain__c = 'partner5.com';
        acc1.Partner_Type__c = 'Partner-Reseller';
        acc1.Sales_Engineer__c = UserInfo.getUserId();
        acc1.Ultimate_Parent_Account__c = acc.Id;//Varun
        acc1.Type='Partner';
        //acc1.SummitDistribution__c=true;
        accInsertList.add(acc1);
		RecordType rt = [SELECT Id FROM RecordType where Name='Partner' and SobjectType='Account'];
        Account acc2 = new account();
        Acc2.Name = 'Test partner';
        acc2.Domain__c = 'partner.com';
        acc2.Partner_Type__c = 'Partner-Distributor';
        acc2.Sales_Engineer__c = UserInfo.getUserId();
        acc2.SummitDistribution__c=true;
        acc2.Program_Type__c ='Distribution';
        acc2.Type='Partner';
        acc2.RecordTypeId =rt.Id;
        accInsertList.add(acc2);
        insert accInsertList;
        System.debug('Total Number of SOQL Queries allowed in this apex code context: ' +  Limits.getQueries());
        acc2.Ultimate_Parent_Account__c = acc1.Id;
        update acc2;
        List<Partner_Incentive__c> piList = new List<Partner_Incentive__c>();
        piList.add((SB_TestCPQDataUtility.createPartnerIncentive(1,accInsertList[2].Id,true,system.today(),system.today(),'Traditional','MSP'))[0]);
        piList.add((SB_TestCPQDataUtility.createPartnerIncentive(1,accInsertList[2].Id,true,system.today()+365,system.today()-30,'Summit - Discount','MSP'))[1]);
        piList[1].Default__c=true;
        piList[1].Partner_Role__c='Reseller';
        piList[1].Transacting_Entity__c=accInsertList[2].Id;
        piList[1].Transacting_Location__c='China';
        piList[0].Partner_Role__c='Distributor';
        insert piList;
        
        System.debug('Total Number of SOQL Queries allowed in this apex code context: ' +  Limits.getQueries());
        Campaign camp = new Campaign();
        camp.Name = 'Deal Registration';
        camp.EndDate = system.today() + 30;
        camp.IsActive = true;
        insert camp;
        ZscalerSetting__c zs = new ZscalerSetting__c();
        zs.Name = 'DealRegCampaign';
        zs.Value__c = ''+camp.Id;
        insert zs;
        System.debug('Total Number of SOQL Queries allowed in this apex code context: ' +  Limits.getQueries());
        ZscalerSetting__c zs1 = new ZscalerSetting__c();
        zs1.Name = 'DealRegCaseReviewOwnerId';
        zs1.Value__c = ''+userInfo.getuserId();
        insert zs1;
        System.debug('Total Number of SOQL Queries allowed in this apex code context: ' +  Limits.getQueries());
        Contact con = new Contact();
        con.firstName = 'Jhon';
        con.LastName = 'Smith';
        con.email = 'jhon@abcd.com';
        con.AccountId = acc2.Id;
        insert con;
    
    //Added By Swathi:CR#1058 Start
    	PatchTeam__c pct = new PatchTeam__c(Territory_Type__c = 'Enterprise',name = 'Sales Enterprise');
        PatchTeam__c pct2 = new PatchTeam__c(Territory_Type__c = 'Enterprise',name = 'Sales Enterprise');
        insert pct;
        insert pct2;
        List<Focus_Partner__c> focusPartner = New List<Focus_Partner__c>();
        Focus_Partner__c focusMem = new Focus_Partner__c(Comments__c='Test',RAM__c = userinfo.getUserId(),Partner_Account__c = acc2.Id,Sales_Territory__c=pct.Id);
		Focus_Partner__c focusMem1 = new Focus_Partner__c(Comments__c='Test',RAM__c = userinfo.getUserId(),Partner_Account__c = acc.Id,Sales_Territory__c=pct.Id);
        focusPartner.add(focusMem);focusPartner.add(focusMem1);
        insert focusPartner;
        List<PatchTeamMember__c> patchTeam = new List<PatchTeamMember__c>();
        PatchTeamMember__c member = new PatchTeamMember__c(PatchTeam__c=pct.Id, Role__c='Account Manager', User__c=UserInfo.getUserId());
        PatchTeamMember__c member1 = new PatchTeamMember__c(PatchTeam__c=pct.Id, Role__c='Area Director', User__c=UserInfo.getUserId());
        PatchTeamMember__c member2 = new PatchTeamMember__c(PatchTeam__c=pct.Id, Role__c='Channel Manager', User__c=UserInfo.getUserId());
        PatchTeamMember__c member3 = new PatchTeamMember__c(PatchTeam__c=pct.Id, Role__c='Channel Manager 2', User__c=UserInfo.getUserId());
        PatchTeamMember__c member4 = new PatchTeamMember__c(PatchTeam__c=pct.Id, Role__c='Channel Manager 3', User__c=UserInfo.getUserId());
        PatchTeamMember__c member5 = new PatchTeamMember__c(PatchTeam__c=pct.Id, Role__c='Channel Manager 4', User__c=UserInfo.getUserId());
        PatchTeamMember__c member6 = new PatchTeamMember__c(PatchTeam__c=pct.Id, Role__c='Geo VP', User__c=UserInfo.getUserId());
        PatchTeamMember__c member7 = new PatchTeamMember__c(PatchTeam__c=pct.Id, Role__c='Regional VP', User__c=UserInfo.getUserId());
        PatchTeamMember__c member8 = new PatchTeamMember__c(PatchTeam__c=pct.Id, Role__c='Tech Partner Sales Manager', User__c=UserInfo.getUserId());
        PatchTeamMember__c member9 = new PatchTeamMember__c(PatchTeam__c=pct.Id, Role__c='Tech Partner Solution Architect', User__c=UserInfo.getUserId());
        patchTeam.add(member);
        patchTeam.add(member1);
        patchTeam.add(member2);
        patchTeam.add(member3);
        patchTeam.add(member4);
        patchTeam.add(member5);
        patchTeam.add(member6);
        patchTeam.add(member7);
        patchTeam.add(member8);
        patchTeam.add(member9);
        insert patchTeam;
        
        List<Triggers_Switch__c> trlst = new List<Triggers_Switch__c>();
        Triggers_Switch__c tr1 = new Triggers_Switch__c(name = 'Execute_DR_Pending_NBM_To_Converted', Execute__c = true);
        Triggers_Switch__c tr2 = new Triggers_Switch__c(name = 'Execute_DR_Revert_Status_Exp_Extension', Execute__c = true);
        Triggers_Switch__c tr3 = new Triggers_Switch__c(name = 'Execute_DR_Capture_Prior_Status', Execute__c = true);
        Triggers_Switch__c tr4 = new Triggers_Switch__c(name = 'Execute_DR_Removal_from_Opp', Execute__c = true);
        trlst.add(tr1);trlst.add(tr2);trlst.add(tr3);trlst.add(tr4);
        insert trlst;
        //Added By Swathi:CR#1058 End
    
        System.debug('Total Number of SOQL Queries allowed in this apex code context: ' +  Limits.getQueries());
        test.startTest();
        Lead le = new Lead();
        le.Company = 'test Company';
        le.FirstName = 'Test';
        le.LastName = 'Name';
        le.Email = 'test@abc.com';
    le.Territory__c = pct.id; //Added By Swathi:CR#1058
        insert le;
        System.debug('Total Number of SOQL Queries allowed in this apex code context: ' +  Limits.getQueries());
        
        
        list<Deal_Reg__c> dealRegInsertList = new list<Deal_Reg__c>();

        Deal_Reg__c deal = new Deal_Reg__c();
        deal.End_Customer_Contact_Name__c = 'Test';
        deal.End_Customer_Contact_Last_Name__c= 'Test';
        deal.End_Customer_Country__c = 'US';
        deal.End_Customer_Domain__c = 'abc.com';
        deal.End_Customer_Email__c  = 'Test@abc.com';
        deal.End_Customer_Name__c = 'ABC Inc';
        deal.End_Customer_Phone__c = '123456789';
        deal.End_Customer_State__c = 'US';
        deal.DS_Review_Status__c = 'Pending Review';
        deal.Estimated_Amount__c = 1234567;
        deal.Expected_Close_Date__c = system.today() + 30;
        deal.Market_Segment__c = 'SMB';
        deal.Number_of_Users__c = 1234567;
        deal.Partner_Company_Name__c = 'Test partner';
        deal.Partner_Contact_Email__c = 'Test@partner.com';
        deal.Partner_Contact_Name__c = 'Test';
        deal.Partner_Contact_Last_Name__c  = 'Partner';
        deal.Partner_Country__c  = 'US';
        deal.Partner_Domain__c  = 'partner.com';
        deal.Source__c = 'Deal Reg';
        deal.Status__c = 'Submitted';
        deal.Partner_Account__c=accInsertList[1].Id;
        dealRegInsertList.add(deal);

        Deal_Reg__c deal1 = new Deal_Reg__c();
        deal1.End_Customer_Contact_Name__c = 'Test';
        deal1.End_Customer_Contact_Last_Name__c= 'Test';
        deal1.End_Customer_Country__c = 'US';
        deal1.End_Customer_Domain__c = 'abcd.com';
        deal1.End_Customer_Email__c  = 'jhon@abcd.com';
        deal1.End_Customer_Name__c = 'ABC Inc';
        deal1.End_Customer_Phone__c = '123456789';
        deal1.End_Customer_State__c = 'US';
        deal1.DS_Review_Status__c = 'Pending Review';
        deal1.Estimated_Amount__c = 1234567;
        deal1.Expected_Close_Date__c = system.today() + 30;
        deal1.Market_Segment__c = 'SMB';
        deal1.Number_of_Users__c = 1234567;
        deal1.Partner_Company_Name__c = 'Test partner';
        deal1.Partner_Contact_Email__c = 'Test@partner.com';
        deal1.Partner_Contact_Name__c = 'Test';
        deal1.Partner_Contact_Last_Name__c  = 'Partner';
        deal1.Partner_Country__c  = 'US';
        deal1.Partner_Domain__c  = 'partner.com';
        deal1.Source__c = 'Deal Reg';
        deal1.Status__c = 'Submitted';
        deal1.Lead__c = le.id;
        deal1.Contact__c = con.id;
        deal1.Partner_Account__c = accInsertList[1].Id;
        dealRegInsertList.add(deal1);

        Deal_Reg__c deal2 = new Deal_Reg__c();
        deal2.End_Customer_Contact_Name__c = 'Test';
        deal2.End_Customer_Contact_Last_Name__c= 'Test';
        deal2.End_Customer_Country__c = 'China';
        deal2.End_Customer_Domain__c = 'abcd.com';
        deal2.End_Customer_Email__c  = 'Test@abcde.com';
        deal2.End_Customer_Name__c = 'ABC Inc';
        deal2.End_Customer_Phone__c = '123456789';
        deal2.End_Customer_State__c = 'China';
        deal2.DS_Review_Status__c = 'Pending Review';
        deal2.Estimated_Amount__c = 1234567;
        deal2.Expected_Close_Date__c = system.today() + 30;
        deal2.Market_Segment__c = 'SMB';
        deal2.Number_of_Users__c = 1234567;
        deal2.Partner_Account__c = acc1.Id;
        deal2.Partner_Company_Name__c = 'Test partner';
        deal2.Partner_Contact_Email__c = 'Test@partner.com';
        deal2.Partner_Contact_Name__c = 'Test';
        deal2.Partner_Contact_Last_Name__c  = 'Partner';
        deal2.Partner_Country__c  = 'China';
        deal2.Partner_Domain__c  = 'partner.com';
        deal2.Source__c = 'Deal Reg';
        deal2.Status__c = 'Submitted';
        dealRegInsertList.add(deal2);

        Deal_Reg__c deal3 = new Deal_Reg__c();
        deal3.End_Customer_Contact_Name__c = 'Test3';
        deal3.End_Customer_Contact_Last_Name__c= 'Test3';
        deal3.End_Customer_Country__c = 'China';
        deal3.End_Customer_Domain__c = 'abc.com';
        deal3.End_Customer_Email__c  = 'Test@abc.com';
        deal3.End_Customer_Name__c = 'ABC Inc';
        deal3.End_Customer_Phone__c = '123456785';
        deal3.End_Customer_State__c = 'China';
        deal3.DS_Review_Status__c = 'Pending Review';
        deal3.Estimated_Amount__c = 1234567;
        deal3.Expected_Close_Date__c = system.today() + 30;
        deal3.Market_Segment__c = 'SMB';
        deal3.Number_of_Users__c = 1234567;
        deal3.Partner_Company_Name__c = 'Test partner';
        deal3.Partner_Contact_Email__c = 'Test@partner.com';
        deal3.Partner_Contact_Name__c = 'Test';
        deal3.Partner_Contact_Last_Name__c  = 'Partner';
        deal3.Partner_Country__c  = 'China';
        deal3.Partner_Domain__c  = 'partner.com';
        deal3.Source__c = 'Deal Reg';
        deal3.Partner_Account__c = acc2.Id;
        deal3.Status__c = 'Submitted';
        dealRegInsertList.add(deal3);
        
        insert dealRegInsertList;
        
        TriggerUtility.DRRemovalfromOppReset();
        deal3.Status__c = 'Pending Expiration';
        deal3.Partner_Account__c = acc1.Id;
        update deal3;
        System.debug('Update deal3 ' +  deal3.Status__c);
        test.stopTest();
        System.debug('Total Number of SOQL Queries allowed in this apex code context: ' +  Limits.getQueries());
		List<Opportunity> oppList = new List<Opportunity>();
        
        Opportunity opp = new Opportunity();
        Opp.Name = 'Test Opp';
        Opp.CloseDate = system.Today() + 30;
        Opp.AccountId = acc.Id;
        Opp.Amount = 123456;
        opp.StageName = label.Stage_1_Alignment /*'1 - Qualified and Budgeted'*/;
        opp.Deal_Reg__c = deal.Id;
        Opp.Associated_Deal_Registrations__c = deal.Name;
        
        Opportunity opp2 = new Opportunity();
        opp2.Name = 'Test Opp 2';
        opp2.CloseDate = system.Today() + 30;
        opp2.AccountId = acc.Id;
        opp2.Amount = 123456;
        opp2.StageName = label.Stage_1_Alignment /*'1 - Qualified and Budgeted'*/;
        opp2.Deal_Reg__c = deal3.Id;
        opp2.Associated_Deal_Registrations__c = deal.Name;
        
        Opportunity opp3 = new Opportunity();
        opp3.Name = 'Test Opp 3';
        opp3.CloseDate = system.Today() + 30;
        opp3.AccountId = acc.Id;
        opp3.Amount = 123456;
        opp3.StageName = label.Stage_1_Alignment /*'1 - Qualified and Budgeted'*/;
        opp3.Deal_Reg_Teaming_Reseller__c = deal3.Id;
        opp3.Associated_Deal_Registrations__c = deal.Name;
        
        Opportunity opp4 = new Opportunity();
        opp4.Name = 'Test Opp';
        opp4.CloseDate = system.Today() + 30;
        opp4.AccountId = acc.Id;
        opp4.Amount = 123456;
        opp4.StageName = label.Stage_1_Alignment /*'1 - Qualified and Budgeted'*/;
        //opp4.Deal_Reg_Teaming_Tech_Partner__c = deal3.Id;
        opp4.Associated_Deal_Registrations__c = deal.Name;
        oppList.add(opp);
        oppList.add(opp2);
        oppList.add(opp3);
        oppList.add(opp4);
        insert oppList;
        System.debug('Total Number of SOQL Queries allowed in this apex code context: ' +  Limits.getQueries());
        //deal1.Status__c = 'Approved';
        update deal;
        update deal3;
        System.debug('Total Number of SOQL Queries allowed in this apex code context: ' +  Limits.getQueries());
    }
}