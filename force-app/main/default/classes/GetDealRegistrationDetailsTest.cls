@isTest
public class GetDealRegistrationDetailsTest {
    
    
    @testSetup
    static void testData(){
        
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
        
        ZscalerSetting__c zs1 = new ZscalerSetting__c();
        zs1.Name = 'DealRegCaseReviewOwnerId';
        zs1.Value__c = ''+userInfo.getuserId();
        insert zs1;
        
        Skip_Triggers__c skipTriggers = new Skip_Triggers__c();
        skipTriggers.Skip_Account_Triggers__c = true;
        skipTriggers.Skip_Opportunity_Triggers__c = true;
        skipTriggers.Name = 'SkipTriggers';
        insert skipTriggers;
        
        Account acc = new Account();
        acc.Name ='Test Account';
        acc.Type ='Partner';
        acc.BillingCountry = 'France';
        insert acc;
        
        Account acc1 = new Account();
        acc1.Name ='Test Account1';
        acc1.Type ='Partner';
        acc1.BillingCountry = 'France';
        acc1.parentid = acc.id;
        acc1.Ultimate_Parent_Account__c = acc.id;
        insert acc1;
        
        Account acc2 = new Account();
        acc2.Name ='Test Account2';
        acc2.Type ='Partner';
        acc2.BillingCountry = 'France';
        acc2.parentid = acc.id;
        acc2.Ultimate_Parent_Account__c = acc.id;
        insert acc2;  
        
        Account acc21 = new Account();
        acc21.Name ='Test Account21';
        acc21.Type ='Partner';
        acc21.BillingCountry = 'France';
        acc21.Ultimate_Parent_Account__c = acc.id;
        insert acc21; 
        
        Account acc22 = new Account();
        acc22.Name ='Test Account22';
        acc22.Type ='Partner';
        acc22.BillingCountry = 'France';
        acc22.Ultimate_Parent_Account__c = acc.id;
        insert acc22;
        
        
        
        Lead le = new Lead();
        le.Company = 'test Company';
        le.FirstName = 'Test';
        le.LastName = 'Name';
        le.Email = 'test@abc.com';
        insert le;
        
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
        dealRegInsertList.add(deal1);
        
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
        
        Opportunity opp = new Opportunity();
        Opp.Name = 'Test Opp';
        Opp.CloseDate = system.Today() + 30;
        Opp.AccountId = acc.Id;
        Opp.Amount = 123456;
        opp.StageName = label.Stage_1_Alignment;
        opp.Deal_Reg__c = deal.Id;
        Opp.Associated_Deal_Registrations__c = deal.Name;
        insert Opp;
        
        
        Opportunity opp1 = new Opportunity();
        opp1.Name = 'Test Opp1';
        opp1.CloseDate = system.Today() + 30;
        opp1.AccountId = acc1.Id;
        opp1.Amount = 123456;
        opp1.StageName = label.Stage_1_Alignment;
        opp1.Deal_Reg__c = deal2.Id;
        opp1.Associated_Deal_Registrations__c = deal2.Name;
        insert opp1;
        
    }
    
    
    static testMethod void myUnitTest() {
        RestRequest req = new RestRequest(); 
        req.addHeader('httpMethod', 'GET');
        req.requestUri = '/services/apexrest/GetDealRegistrationDetails';       
        RestContext.request = req; 
        
        RestResponse res = new RestResponse();
        RestContext.response= res;
        
        Test.startTest();
        GetDealRegistrationDetails.getRegisteredDeals();
		//GetDealRegistrationDetails.booster();
        Test.stopTest();
    }
    
    static testMethod void myUnitTest1() {
        
        Account acc = [Select id from account where name = 'Test Account' limit 1];
        
        RestRequest req = new RestRequest(); 
        
        req.addHeader('httpMethod', 'GET');
        req.requestUri = '/services/apexrest/GetDealRegistrationDetails'; 
        RestContext.request = req; 
        RestContext.request.params.put('partner_acc_id', acc.id);
        RestContext.request.params.put('partneremail', 'Test@partner.com');
        RestContext.request.params.put('partnerrole', 'Manager');
        RestContext.request.params.put('pagenumber', '1');
        RestContext.request.params.put('limit', '10');
        
        
        RestResponse res = new RestResponse();
        RestContext.response= res;
        
        Test.startTest();
        GetDealRegistrationDetails.getRegisteredDeals();
		//GetDealRegistrationDetails.booster();
        Test.stopTest();
    }
    
    @isTest
    static void testGetDealRegistrationDetails(){
                Account acc = [Select id from account where name = 'Test Account' limit 1];
        
        RestRequest req = new RestRequest(); 
        
        Account acc1 = new Account(name = 'test Account');
        insert acc1;
        acc.Ultimate_Parent_Account__c = acc1.Id;
        update acc;
        
        req.addHeader('httpMethod', 'GET');
        req.requestUri = '/services/apexrest/GetDealRegistrationDetails'; 
        RestContext.request = req; 
        RestContext.request.params.put('partner_acc_id', acc.id);
        RestContext.request.params.put('partneremail', 'Test@partner.com');
        RestContext.request.params.put('partnerrole', 'Manager');
        RestContext.request.params.put('pagenumber', '1');
        RestContext.request.params.put('limit', '10');
        
        
        RestResponse res = new RestResponse();
        RestContext.response= res;
        
        Test.startTest();
        GetDealRegistrationDetails.getRegisteredDeals();
		//GetDealRegistrationDetails.booster();
		Test.stopTest();
    }
    
    
}