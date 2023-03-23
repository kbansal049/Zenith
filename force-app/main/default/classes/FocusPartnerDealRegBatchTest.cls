/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 08-17-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/

@isTest
public class FocusPartnerDealRegBatchTest {
    @isTest
    static void testFocusPartnerDealRegBatch(){
        RecordType rt = [SELECT Id FROM RecordType WHERE Name = 'Partner' AND SobjectType = 'Account'];
        List<Account> accInsertList = new List<Account>();
        
        Account acc = new account();
        Acc.Name = 'Test Data';
        acc.Domain__c = 'abc.com';
        acc.Partner_Type__c = 'Partner-Reseller';
        acc.Program_Type__c = 'Reseller';
        acc.Sales_Engineer__c = UserInfo.getUserId();
        acc.SummitDistribution__c = true;
        acc.Type = 'Partner';
        accInsertList.add(acc);
        
        Account acc1 = new account();
        Acc1.Name = 'Test partner';
        acc1.Domain__c = 'partner5.com';
        acc1.Partner_Type__c = 'Partner-Reseller';
        acc1.Sales_Engineer__c = UserInfo.getUserId();
        acc1.Ultimate_Parent_Account__c = acc.Id;
        acc1.type = 'Technology Partner';
        acc1.Partner_Level__c = 'Tier 1: Strategic';
        acc1.SummitDistribution__c = true;
        acc1.RecordTypeId = rt.Id;
        acc1.Ultimate_Parent_Account__c = acc.Id;
        accInsertList.add(acc1);
        
        Account acc2 = new account();
        Acc2.Name = 'Test partner';
        acc2.Domain__c = 'partner.com';
        acc2.Partner_Type__c = 'Partner-Distributor';
        acc2.Sales_Engineer__c = UserInfo.getUserId();
        acc2.SummitDistribution__c = true;
        acc2.Program_Type__c = 'Distribution';
        acc2.Type = 'Partner';
        acc2.RecordTypeId = rt.Id;
        accInsertList.add(acc2);
        acc2.Ultimate_Parent_Account__c = acc1.Id;
        insert accInsertList;
        
        Campaign camp = new Campaign();
        camp.Name = 'Deal Registration';
        camp.EndDate = System.today() + 30;
        camp.IsActive = true;
        insert camp;

        ZscalerSetting__c zs = new ZscalerSetting__c();
        zs.Name = 'DealRegCampaign';
        zs.Value__c = String.valueOf(camp.Id);
        insert zs;

        System.debug('Total Number of SOQL Queries allowed in this apex code context: ' +  Limits.getQueries());
        ZscalerSetting__c zs1 = new ZscalerSetting__c();
        zs1.Name = 'DealRegCaseReviewOwnerId';
        zs1.Value__c = String.valueOf(userInfo.getuserId());
        insert zs1;

        System.debug('Total Number of SOQL Queries allowed in this apex code context: ' +  Limits.getQueries());
        Contact con = new Contact();
        con.firstName = 'Jhon';
        con.LastName = 'Smith';
        con.email = 'jhon@abcd.com';
        con.AccountId = acc2.Id;
        insert con;
        
        PatchTeam__c pct = new PatchTeam__c(Territory_Type__c = 'Enterprise', Name = 'Sales Enterprise - 1');
        insert pct;
        
        List<Focus_Partner__c> focusPartnerLst = New List<Focus_Partner__c>();
        Focus_Partner__c fp = new Focus_Partner__c(Comments__c = 'Test FP - 1', RAM__c = userinfo.getUserId(), Partner_Account__c = acc2.Id, Sales_Territory__c = pct.Id);
        Focus_Partner__c fp1 = new Focus_Partner__c(Comments__c = 'Test FP - 2', RAM__c = userinfo.getUserId(), Partner_Account__c = acc.Id, Sales_Territory__c = pct.Id);
        focusPartnerLst.add(fp);
        focusPartnerLst.add(fp1);
        insert focusPartnerLst;
        
        List<PatchTeamMember__c> patchTeam = new List<PatchTeamMember__c>();
        PatchTeamMember__c member = new PatchTeamMember__c(PatchTeam__c = pct.Id, Role__c = 'Account Manager', User__c = UserInfo.getUserId());
        PatchTeamMember__c member1 = new PatchTeamMember__c(PatchTeam__c = pct.Id, Role__c = 'Area Director', User__c = UserInfo.getUserId());
        PatchTeamMember__c member2 = new PatchTeamMember__c(PatchTeam__c = pct.Id, Role__c = 'Channel Manager', User__c = UserInfo.getUserId());
        PatchTeamMember__c member3 = new PatchTeamMember__c(PatchTeam__c = pct.Id, Role__c = 'Channel Manager 2', User__c = UserInfo.getUserId());
        PatchTeamMember__c member4 = new PatchTeamMember__c(PatchTeam__c = pct.Id, Role__c = 'Channel Manager 3', User__c = UserInfo.getUserId());
        PatchTeamMember__c member5 = new PatchTeamMember__c(PatchTeam__c = pct.Id, Role__c = 'Channel Manager 4', User__c = UserInfo.getUserId());
        PatchTeamMember__c member6 = new PatchTeamMember__c(PatchTeam__c = pct.Id, Role__c = 'Geo VP', User__c = UserInfo.getUserId());
        PatchTeamMember__c member7 = new PatchTeamMember__c(PatchTeam__c = pct.Id, Role__c = 'Regional VP', User__c = UserInfo.getUserId());
        PatchTeamMember__c member8 = new PatchTeamMember__c(PatchTeam__c = pct.Id, Role__c = 'Tech Partner Sales Manager', User__c = UserInfo.getUserId());
        PatchTeamMember__c member9 = new PatchTeamMember__c(PatchTeam__c = pct.Id, Role__c = 'Tech Partner Solution Architect', User__c = UserInfo.getUserId());
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
        
        List<Deal_Reg__c> tobeInsertDealRegList = new List<Deal_Reg__c>();
        
        Deal_Reg__c deal = new Deal_Reg__c();
        deal.End_Customer_Contact_Name__c = 'Test';
        deal.End_Customer_Contact_Last_Name__c = 'Test';
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
        //deal.Lead__c = le.id;
        //deal.Contact__c = con.id;
        deal.Partner_Account__c = acc1.Id;
        deal.Partner_Contact__c = con.Id;
        tobeInsertDealRegList.add(deal);
        
        Deal_Reg__c deal1 = new Deal_Reg__c();
        deal1.End_Customer_Contact_Name__c = 'Test';
        deal1.End_Customer_Contact_Last_Name__c = 'Test';
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
        //deal1.Lead__c = le.id;
        //deal1.Contact__c = con.id;
        deal1.Partner_Account__c = acc.Id;
        deal1.Partner_Contact__c = con.id;
        tobeInsertDealRegList.add(deal1);
        
        Deal_Reg__c deal2 = new Deal_Reg__c();
        deal2.End_Customer_Contact_Name__c = 'Test';
        deal2.End_Customer_Contact_Last_Name__c = 'Test';
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
        tobeInsertDealRegList.add(deal2);
        
        Deal_Reg__c deal3 = new Deal_Reg__c();
        deal3.End_Customer_Contact_Name__c = 'Test3';
        deal3.End_Customer_Contact_Last_Name__c = 'Test3';
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
        deal3.Status__c = 'Pending Expiration';
        deal3.Partner_Contact__c = con.Id;
        tobeInsertDealRegList.add(deal3);
        insert tobeInsertDealRegList;

        deal.Sales_Territory__c = pct.Id;
        deal1.Sales_Territory__c = pct.Id;
        deal2.Sales_Territory__c = pct.Id;
        deal3.Sales_Territory__c = pct.Id;
        update tobeInsertDealRegList;
        
        Test.startTest();
            Database.executeBatch(new FocusPartnerDealRegBatch('SELECT Id, Name, Partner_Type__c, Partner_Account__c, Sales_Territory__c,Channel_Manager__c, Partner_Account__r.Ultimate_Parent_Account__c FROM Deal_Reg__c WHERE Status__c NOT IN (\'Converted\', \'Expired\')'));
        Test.stopTest();

        List<Deal_Reg__c> updatedDealRegList = [SELECT Id, Name, Partner_Type__c, Partner_Account__c, Sales_Territory__c, Channel_Manager__c, Partner_Account__r.Ultimate_Parent_Account__c FROM Deal_Reg__c WHERE Status__c NOT IN ('Converted', 'Expired') AND Channel_Manager__c = :fp.RAM__c LIMIT 1];
        System.assertEquals(1, updatedDealRegList.size(), 'Pass');
    }
}