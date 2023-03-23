@isTest
private class GetConvertedOpportunitiesTest {
    @TestSetup
    static void setdata(){
        
        TriggerHandler.bypass('AccountTriggerHandler');
        TriggerHandler.bypass('OpportunityTriggerHandler');
        
        TriggerUtility.prospectTypeUpdExecuted();
        triggerUtility.contactPatchManagerExecuted();
        triggerUtility.accTerritoryPatchExecuted();
        triggerUtility.oppPatchManagerAfterInsertExecuted();
        triggerUtility.oppPatchManagerAfterUpdateExecuted();
        
        Account acc = new account();
        Acc.Name = 'Test Data';
        acc.Domain__c = 'abc.com';
        insert acc;
        Account acc1 = new account();
        Acc1.Name = 'Test partner';
        acc1.Domain__c = 'partner.com';
        insert acc1;
        Campaign camp = new Campaign();
        camp.Name = 'Deal Registration';
        camp.EndDate = system.today() + 30;
        camp.IsActive = true;
        insert camp;
        ZscalerSetting__c zs = new ZscalerSetting__c();
        zs.Name = 'DealRegCampaign';
        zs.Value__c = ''+camp.Id;
        insert zs;
        
        ZscalerSetting__c zs1 = new ZscalerSetting__c();
        zs1.Name = 'DealRegCaseReviewOwnerId';
        zs1.Value__c = ''+userInfo.getuserId();
        insert zs1;
        
        Lead le = new Lead();
        le.Company = 'test Company';
        le.FirstName = 'Test';
        le.LastName = 'Name';
        le.Email = 'test@abc.com';
        insert le;
        
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
        
        Opportunity opp = new Opportunity();
        Opp.Name = 'Test Opp';
        Opp.CloseDate = system.Today() + 30;
        Opp.AccountId = acc.Id;
        Opp.Amount = 123456;
        opp.StageName = label.Stage_1_Alignment /*'1 - Qualified and Budgeted'*/;
        opp.Deal_Reg__c = deal.Id;
        insert Opp;
    }
    
    static testmethod void getopptest(){
        Deal_Reg__c dr = [Select id, Name, Channel_Manager__r.Name, Channel_Manager__r.Email, Technology_Alliance_Manager__r.Email, Technology_Alliance_Manager__r.Name, Partner_Account__c,Partner_Company_Name__c, Distributor__r.Name, Account_Manager__r.Name, Account__r.Name,Deal_Reg_Type__c from Deal_Reg__c where Status__c = 'Submitted'];
        
        GetConvertedOpportunities ctrl = new GetConvertedOpportunities();
        System.debug('dr'+dr.id);
        
        ctrl.dealRegId = dr.Id;
        System.debug('Opp'+ctrl.opp);
        System.debug('DR'+ctrl.DR);
        System.debug('drid'+dr.id);
    }
    
}