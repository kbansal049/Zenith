/*****************************************************************************************
Name: ContactPatchManagerTest
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
1. Test Class for ContactPatchManager Class.
1. Test Class for CaseCreationForAccountAndOpportunity Class.
1. Test Class for AccountSalesTerritoryAndContactPatch Class.
==========================================================================================
==========================================================================================
History
-------
VERSION        AUTHOR                  DATE              DETAIL
1.0            Kunal Raj            13-Nov-2015    Initial Development
******************************************************************************************/
@isTest(SeeAllData=false)
private class ContactPatchManagerTest{
    @isTest(SeeAllData=false)
     static void testContactPatch(){
         test.startTest();
         ZscalerSetting__c zs = new ZscalerSetting__c();
         zs.Name = 'DSReviewCaseOwnerId';
         zs.Value__c = ''+userInfo.Getuserid();
         insert zs;
         TriggerUtility.accSalesTeamExecuted();
         PatchTeam__c salestert  = new PatchTeam__c();
         salestert.District__c = 'District 1';
         salestert.Theater__c = 'AMER';
         salestert.Region__c = 'Central';
         salestert.Territory__c = 'SF Bay Area 1';
         salestert.Name = 'Sales Team';
         insert salestert;



         PatchTeamMember__c SalesTeamMem1 = new PatchTeamMember__c();
         SalesTeamMem1.Role__c = 'Account Manager';
         SalesTeamMem1.PatchTeam__c = salestert.Id;
         SalesTeamMem1.User__c = userinfo.GetuserId();
         insert SalesTeamMem1 ;


         PatchTeamMember__c SalesTeamMem2 = new PatchTeamMember__c();
         SalesTeamMem2.Role__c = 'Channel Manager';
         SalesTeamMem2.PatchTeam__c = salestert.Id;
         SalesTeamMem2.User__c = userinfo.GetuserId();
         insert SalesTeamMem2 ;


         PatchTeamMember__c SalesTeamMem3 = new PatchTeamMember__c();
         SalesTeamMem3.Role__c = 'Customer Advocate';
         SalesTeamMem3.PatchTeam__c = salestert.Id;
         SalesTeamMem3.User__c = userinfo.GetuserId();
         insert SalesTeamMem3 ;


         PatchTeamMember__c SalesTeamMem4 = new PatchTeamMember__c();
         SalesTeamMem4.Role__c = 'Lead Development';
         SalesTeamMem4.PatchTeam__c = salestert.Id;
         SalesTeamMem4.User__c = userinfo.GetuserId();
         insert SalesTeamMem4 ;


         PatchTeamMember__c SalesTeamMem5 = new PatchTeamMember__c();
         SalesTeamMem5.Role__c = 'Sales Engineer';
         SalesTeamMem5.PatchTeam__c = salestert.Id;
         SalesTeamMem5.User__c = userinfo.GetuserId();
         insert SalesTeamMem5 ;

         PatchTeamMember__c SalesTeamMem6 = new PatchTeamMember__c();
         SalesTeamMem6.Role__c = 'ZPA Manager';
         SalesTeamMem6.PatchTeam__c = salestert.Id;
         SalesTeamMem6.User__c = userinfo.GetuserId();
         insert SalesTeamMem6 ;

         PatchTeamMember__c SalesTeamMem7 = new PatchTeamMember__c();
         SalesTeamMem7.Role__c = 'ZPA SE';
         SalesTeamMem7.PatchTeam__c = salestert.Id;
         SalesTeamMem7.User__c = userinfo.GetuserId();
         insert SalesTeamMem7 ;

         Patch__c patch  = new Patch__c();
         patch.Active__c = true;
         patch.PatchTeam__c = salestert.Id ;
         patch.PatchName__c = 'Test Patch';
         insert patch;

         Account acc = new account();
         Acc.Name = 'Test Data';
         acc.Patch__c = patch.Id;
         insert acc;

         Contact con = new Contact();
         con.FirstName = 'Test';
         con.LastName = 'Test';
         con.AccountId = acc.id;
         insert con;

         TriggerUtility.contactPatchManagerReset();

         acc.Patch__c = patch.Id;
         update acc;

         con.AccountId = acc.id;
         update con;

         acc.Patch__c = null;
         acc.DS_Review_Status__c = null;
         update acc;

         Opportunity opp = new Opportunity();
         opp.Name = 'test Opp';
         opp.AccountId = acc.Id;
         Opp.StageName = label.Stage_1_Alignment /*'01 - Prospect'*/;
         opp.CloseDate = system.today();
         insert opp;
         test.stopTest();
     }
     
     // Added by Rajesh CR# 1058 : Start
    @isTest
    static void testDealRegCaseCreation(){
        list<Deal_Reg__c> newDealRegList = new list<Deal_Reg__c>();
        ZscalerSetting__c zs = new ZscalerSetting__c();
        zs.Name = 'DealRegCaseReviewOwnerId';
        zs.Value__c = ''+userInfo.Getuserid();
        insert zs;
        
        newDealRegList.add(new Deal_Reg__c(X48_Hours_Passed__c=true));
        
        CaseCreationForAccountAndOpportunity.dealRegCaseCreation(newDealRegList);
        
    }
    
    @isTest
    static void testopportunitySplitsCaseCreation(){
        Test.StartTest();
        
        Account acc = TestDatafactory_Zscaler.insertAccount('Test Account1', null, 'Customer', null, null, null);
        update acc;
        
        Date closeDate = system.today() + 365;
        Id meRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal Opportunity').getRecordTypeId();
        Opportunity opp = TestDatafactory_Zscaler.insertOpportunity('Test Opp1', false, acc.Id, Label.Stage_4_Economic_Buyer_Signoff, closeDate , meRecordTypeId, null, null, null,null, null, null, null, null, null, true);
        
        Case  cs = TestDatafactory_Zscaler.insertCase('status', 'subject',  'description',  acc.Id, null, acc.Id, null);
        cs.Subject = 'New Opportunity Split entry created : '+ opp.Name;
        cs.Opportunity_Name__c  = opp.Id;
        
        update cs;
        
        // Method parameters
        Set<Id> lstMultiTerritoryOpportunitySplits = new Set<Id>();
        Set<Id> lstOtbOpportunityIds = new Set<Id>();
        Set<Id> lstRenewalOpptysWithUpsellSplits = new Set<Id>();
        Set<Id> splitsWithBlankZPAFields = new Set<Id>();
        
        lstMultiTerritoryOpportunitySplits.add(opp.Id);
        lstOtbOpportunityIds.add(opp.Id);
        lstRenewalOpptysWithUpsellSplits.add(opp.Id);
        splitsWithBlankZPAFields.add(opp.Id);
        
        
        CaseCreationForAccountAndOpportunity.opportunitySplitsCaseCreation(lstMultiTerritoryOpportunitySplits, lstOtbOpportunityIds, lstRenewalOpptysWithUpsellSplits, splitsWithBlankZPAFields);
        Test.StopTest(); 
    }
    
    @isTest
    static void testopportunitySplitsCaseCreatio2(){
        Test.StartTest();
        
        Account acc = TestDatafactory_Zscaler.insertAccount('Test Account1', null, 'Customer', null, null, null);
        update acc;
        
        Date closeDate = system.today() + 365;
        Id meRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal Opportunity').getRecordTypeId();
        Opportunity opp = TestDatafactory_Zscaler.insertOpportunity('Test Opp1', false, acc.Id, Label.Stage_4_Economic_Buyer_Signoff, closeDate , meRecordTypeId, null, null, null,null, null, null, null, null, null, true);
       
        // Method parameters
        Set<Id> lstMultiTerritoryOpportunitySplits = new Set<Id>();
        Set<Id> lstOtbOpportunityIds = new Set<Id>();
        Set<Id> lstRenewalOpptysWithUpsellSplits = new Set<Id>();
        Set<Id> splitsWithBlankZPAFields = new Set<Id>();
        
        lstMultiTerritoryOpportunitySplits.add(opp.Id);
        lstOtbOpportunityIds.add(opp.Id);
        lstRenewalOpptysWithUpsellSplits.add(opp.Id);
        splitsWithBlankZPAFields.add(opp.Id);
        
        
        CaseCreationForAccountAndOpportunity.opportunitySplitsCaseCreation(lstMultiTerritoryOpportunitySplits, lstOtbOpportunityIds, lstRenewalOpptysWithUpsellSplits, splitsWithBlankZPAFields);
        Test.StopTest(); 
    }
    
    
    @isTest static void testoverrideACVValuesRCC()
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
    
    @isTest
    static void testoverrideACVValuesResetCC(){
        Test.StartTest();
        
        Account acc = TestDatafactory_Zscaler.insertAccount('Test Account1', null, 'Customer', null, null, null);
        update acc;
        
        Date closeDate = system.today() + 365;
        Id meRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal Opportunity').getRecordTypeId();
        Opportunity opp = TestDatafactory_Zscaler.insertOpportunity('Test Opp1', false, acc.Id, Label.Stage_4_Economic_Buyer_Signoff, closeDate , meRecordTypeId, null, null, null,null, null, null, null, null, null, true);
    
        List<Id> resetOverrideACVOpptyIds = new List<Id>();
        resetOverrideACVOpptyIds.add(opp.Id);
        
        CaseCreationForAccountAndOpportunity.overrideACVValuesResetCaseCreation(resetOverrideACVOpptyIds, true);
    }
    // Added by Rajesh CR# 1058 : End
}