/*****************************************************************************************
Name: DealRegConversionControllerTest
Copyright © Zscaler
Purpose:

Test class for DealRegConversionController
History

VERSION        AUTHOR                  DATE              DETAIL
1.0            Kunal Raj            4-OCT-2016          Initial Development
2.0            Swathi               2/28/2022           CR#3744 - ProfessionalService Partner
3.0            Ram S                8/15/2022           Refactored the associaed APEX class to resolve too many SOQL : 101 error
******************************************************************************************/ 

@isTest
private class DealRegConversionControllerTest{
    @TestSetup
    static void createtestData(){
        Skip_Triggers__c skipTriggers = new Skip_Triggers__c();
        skipTriggers.Skip_Account_Triggers__c = true;
        skipTriggers.Skip_Opportunity_Triggers__c = true;
        skipTriggers.Name = 'SkipTriggers';
        insert skipTriggers;
        
        Skip_Triggers_User_Based__c sk = new Skip_Triggers_User_Based__c();
        sk.SetupOwnerId = userInfo.getUserId();
        sk.Object_s_to_skip__c = 'Deal_Reg__c';
        insert sk;
        
        TriggerUtility.dealRegAfterUpdateExecuted();
        TriggerUtility.dealRegAfterInsertExecuted();
        TriggerUtility.dealRegBeforeInsertExecuted();
        TriggerUtility.contactPatchManagerExecuted();
        TriggerUtility.conWhiteSpaceUpdateExecuted();
        TriggerUtility.accToContactOwnerExecuted();
        TriggerUtility.contactOwnerShipExecuted();
        TriggerUtility.oppCaseCreationExecuted();
        TriggerUtility.requestDecommissionPrExecuted();
        TriggerUtility.oppSpliSalesTeamExecuted();
        TriggerUtility.caseCreationForLeadTerrirtoryExecuted();
        TriggerUtility.prospectTypeUpdExecuted();
        
        Id partnerAccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner').getRecordTypeId();

        list<Account> accInsertList = new list<Account>();
        Account acc = new account();
        Acc.Name = 'Test Data';
        acc.Domain__c = 'abc.com';
        acc.Program_Type__c = 'Distribution';
        acc.recordTypeId = partnerAccRecordTypeId;
        acc.SummitDistribution__c = True;
        acc.Service_Authorizations__c = 'Support Services Authorized';
        acc.Type = 'Partner';
        acc.Partner_Type__c ='Partner-Distributor';
        accInsertList.add(acc);
        
        Account acc1 = new account();
        Acc1.Name = 'Test partner';
        acc1.Domain__c = 'partner.com';
        acc1.Is_Federal_Account_Sync__c = TRUE;
        acc1.SummitDistribution__c = True;
        acc1.Program_Type__c = 'Reseller';
        acc1.recordTypeId = partnerAccRecordTypeId;
        acc1.Service_Authorizations__c = 'Support Services Authorized';
        accInsertList.add(acc1);
        
        insert accInsertList;

        Campaign camp = new Campaign();
        camp.Name = 'DealRegistration';
        camp.EndDate = System.today() + 30;
        camp.IsActive = true;
        insert camp;
        
        List<Partner_Incentive__c> piList = new List<Partner_Incentive__c>();
        piList.add((SB_TestCPQDataUtility.createPartnerIncentive(1,accInsertList[1].Id,true,System.today()+60,System.today()-30,'Traditional','MSP'))[0]);
        piList.add((SB_TestCPQDataUtility.createPartnerIncentive(1,accInsertList[1].Id,true,System.today(),System.today(),'Summit - Federal','MSP'))[1]);
        piList[1].Default__c=true;
        piList[1].Active__c=true;
        insert piList;
        
        Contact con = new Contact();
        con.firstName = 'Jhon';
        con.LastName = 'Smith';
        con.email = 'jhon@abcd.com';
        con.AccountId = accInsertList[0].Id;
        insert con;
        
        Lead le = new Lead();
        le.Company = 'Test Company';
        le.FirstName = 'Test';
        le.LastName = 'Name';
        le.Email = 'test1234@abc.com';
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
        deal.Expected_Close_Date__c = System.today() + 30;
        deal.Market_Segment__c = 'SMB';
        deal.Number_of_Users__c = 1234567;
        deal.Partner_Company_Name__c = 'Test partner';
        deal.Partner_Contact_Email__c = 'Test@partner.com';
        deal.Partner_Contact_Name__c = 'Test';
        deal.Partner_Contact_Last_Name__c  = 'Partner';
        deal.Partner_Country__c  = 'US';
        deal.Partner_Domain__c  = 'partner.com';
        deal.Partner_Account__c = accInsertList[0].Id;
        deal.Source__c = 'Deal Reg';
        deal.Status__c = 'Submitted';
        deal.AW_Partner_Intent__c = 'Interested';
        deal.POV_Partner_Intent__c = 'Interested';
        deal.AW_POV_Partner_Intent__c = 'Interested';
        deal.Delivery_Intent__c = 'Interested';
        deal.Distributor__c = acc.Id;
        insert deal;
        
        deal.OwnerId = userInfo.getuserId();
        deal.Account_Type__c ='Customer';
        update deal;
        System.debug('PArtnerType'+deal.Partner_Type__c);
        
        Deal_Reg__c deal1 = new Deal_Reg__c();
        deal1.End_Customer_Contact_Name__c = 'Test';
        deal1.End_Customer_Contact_Last_Name__c= 'Test';
        deal1.End_Customer_Country__c = 'US';
        deal1.End_Customer_Domain__c = 'abcd.com';
        deal1.End_Customer_Email__c  = 'Test@abcd.com';
        deal1.End_Customer_Name__c = 'ABC Inc';
        deal1.End_Customer_Phone__c = '123456789';
        deal1.End_Customer_State__c = 'US';
        deal1.DS_Review_Status__c = 'Pending Review';
        deal1.Estimated_Amount__c = 1234567;
        deal1.Expected_Close_Date__c = System.today() + 30;
        deal1.Market_Segment__c = 'SMB';
        deal1.Number_of_Users__c = 1234567;
        deal1.Partner_Company_Name__c = 'Test partner';
        deal1.Partner_Contact_Email__c = 'Test@partner.com';
        deal1.Partner_Contact_Name__c = 'Test';
        deal1.Partner_Contact_Last_Name__c  = 'Partner';
        deal1.Partner_Country__c  = 'US';
        deal1.Partner_Domain__c  = 'partner.com';
        deal1.Partner_Account__c = acc.Id;
        deal1.Source__c = 'Deal Reg';
        deal1.Status__c = 'Submitted';
        deal1.Account_Manager__c = userInfo.getuserId();
        deal1.AW_Partner_Intent__c = 'Interested';
        deal1.POV_Partner_Intent__c = 'Interested';
        deal1.Delivery_Intent__c = 'Interested';
        insert deal1;
        
        deal1.OwnerId = userInfo.getuserId();
        deal.Deal_Reg_Type__c = Label.Deal_Reg_Type_Teaming;
        deal.Account_Type__c ='Customer';
        
        update deal1;
    }
    
    /*@isTest
    static void testDealRegConversionControllerHelper(){
        Account acc = [SELECT Id FROM Account WHERE Name = 'Test partner'];
        Account accData = [SELECT Id FROM Account WHERE Name = 'Test Data'];
        Campaign camp = [SELECT Id FROM Campaign WHERE Name = 'DealRegistration'];
        Lead le = [SELECT Id FROM Lead WHERE Company = 'Test Company'];
        Contact con = [SELECT Id FROM Contact WHERE LastName = 'Smith'];
        Partner_Incentive__c partnerIncentive = [SELECT Id FROM Partner_Incentive__c WHERE Partner_Program__c = 'Summit - Federal'];
        Deal_Reg__c deal = [SELECT ID, Name, Partner_Category__c FROM Deal_Reg__c WHERE End_Customer_Email__c = 'Test@abc.com'];

        TriggerUtility.dealRegAfterUpdateExecuted();
        TriggerUtility.dealRegAfterInsertExecuted();
        TriggerUtility.dealRegBeforeInsertExecuted();
        TriggerUtility.contactPatchManagerExecuted();
        TriggerUtility.conWhiteSpaceUpdateExecuted();
        TriggerUtility.accToContactOwnerExecuted();
        TriggerUtility.contactOwnerShipExecuted();
        TriggerUtility.oppCaseCreationExecuted();
        TriggerUtility.requestDecommissionPrExecuted();
        TriggerUtility.oppSpliSalesTeamExecuted();
        TriggerUtility.caseCreationForLeadTerrirtoryExecuted();
        TriggerUtility.prospectTypeUpdExecuted();
        
        ZscalerSetting__c zs = new ZscalerSetting__c();
        zs.Name = 'DealRegCampaign';
        zs.Value__c = ''+camp.Id;
        insert zs;
        
        ZscalerSetting__c zs1 = new ZscalerSetting__c();
        zs1.Name = 'DealRegCaseReviewOwnerId';
        zs1.Value__c = ''+userInfo.getuserId();
        insert zs1;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opp';
        opp.CloseDate = System.today() + 30;
        opp.AccountId = accData.Id;
        opp.Amount = 123456;
        opp.StageName = Label.Stage_1_Alignment;
        opp.Deal_Reg__c = deal.Id;
        opp.Associated_Deal_Registrations__c = deal.Name;
        TriggerHandler.bypass('OpportunityTriggerHandler');
        insert Opp;
        
        Opportunity_Partner__c oppPartner = new Opportunity_Partner__c(Is_Primary__c = TRUE, Opportunity__c = opp.Id, Partner_Type__c = 'Reseller', Account__c = acc.Id);
        INSERT oppPartner;
        Opportunity_Partner__c oppPartner1 = new Opportunity_Partner__c(Is_Primary__c = true,Opportunity__c = opp.Id,Partner_Type__c = 'Deal Reg',Account__c = acc.Id);
        insert oppPartner1;
        
        Opportunity_Partner__c oppPartner2 = new Opportunity_Partner__c(Is_Primary__c = true,Opportunity__c = opp.Id,Partner_Type__c = 'Architecture Workshop',Account__c = acc.Id);
        insert oppPartner2;
        
        String quoteNewBusiness = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByDeveloperName().get('New_Business').getRecordTypeId();
        SBQQ__Quote__c quoteRec = (SB_TestCPQDataUtility.createQuote(1, opp.Id, accData.Id, acc.id, acc.id,quoteNewBusiness))[0];
        insert quoteRec;
        TriggerHandler.bypass('OpportunityTriggerHandler');
        Test.startTest();
            PageReference pageRef = Page.DealRegConversion;
            Test.setCurrentPage(pageRef);
            pageRef.getParameters().put('id', String.valueOf(deal.Id));

            DealRegConversionController.dealRegId = deal.id;
            DealRegConversionController.dealReg = deal;
            DealRegConversionController.convertDealReg(deal.id);
            DealRegConversionController.getOppPartner(acc.id, opp.id, 'Distributor', null, null);
            DealRegConversionController.updateDealStatustoConverted(deal.id);
        	TriggerHandler.bypass('OpportunityTriggerHandler');
            DealRegConversionController.createOpportunityPartner(acc.Id, opp.id, deal.id);
            DealRegConversionController.contactConversion();
        TriggerHandler.clearBypass('OpportunityTriggerHandler');
        Test.stopTest();
    }
    
    @isTest
    static void testOpportunityConversionWithAcc(){
        Account acc = [SELECT Id FROM Account WHERE Name = 'Test Data'];
        Campaign camp = [SELECT Id FROM Campaign WHERE Name = 'DealRegistration'];
        Lead le = [SELECT Id FROM Lead WHERE Company = 'Test Company'];
        Contact con = [SELECT Id FROM Contact WHERE LastName = 'Smith'];
        Partner_Incentive__c partnerIncentive = [SELECT Id FROM Partner_Incentive__c WHERE Partner_Program__c = 'Summit - Federal'];
		Deal_Reg__c deal = [SELECT ID, Name, Partner_Category__c,End_Customer_Contact_Name__c,
		 End_Customer_Contact_Last_Name__c,End_Customer_Country__c,End_Customer_Domain__c,End_Customer_Email__c,
		 End_Customer_Name__c,End_Customer_Phone__c,End_Customer_State__c,DS_Review_Status__c,Estimated_Amount__c,
		 Expected_Close_Date__c,Market_Segment__c,Number_of_Users__c,Partner_Company_Name__c,Partner_Contact_Email__c,
		 Partner_Contact_Name__c,Partner_Contact_Last_Name__c,Partner_Country__c,Partner_Domain__c,Partner_Account__c,Source__c,Status__c,
		 Account_Manager__c,AW_Partner_Intent__c,POV_Partner_Intent__c,Delivery_Intent__c,Account_Type__c FROM Deal_Reg__c WHERE End_Customer_Email__c = 'Test@abc.com'];

        
        TriggerUtility.dealRegAfterUpdateExecuted();
        TriggerUtility.dealRegAfterInsertExecuted();
        TriggerUtility.dealRegBeforeInsertExecuted();
        TriggerUtility.contactPatchManagerExecuted();
        TriggerUtility.conWhiteSpaceUpdateExecuted();
        TriggerUtility.accToContactOwnerExecuted();
        TriggerUtility.contactOwnerShipExecuted();
        TriggerUtility.oppCaseCreationExecuted();
        TriggerUtility.requestDecommissionPrExecuted();
        TriggerUtility.oppSpliSalesTeamExecuted();
        TriggerUtility.caseCreationForLeadTerrirtoryExecuted();
        TriggerUtility.prospectTypeUpdExecuted();
        
        ZscalerSetting__c zs = new ZscalerSetting__c();
        zs.Name = 'DealRegCampaign';
        zs.Value__c = ''+camp.Id;
        insert zs;
        
        ZscalerSetting__c zs1 = new ZscalerSetting__c();
        zs1.Name = 'DealRegCaseReviewOwnerId';
        zs1.Value__c = ''+userInfo.getuserId();
        insert zs1;
        
        list<Deal_Reg__c> dealRegInsertList = new list<Deal_Reg__c>();
        
      /*  Deal_Reg__c deal = new Deal_Reg__c();
        deal.End_Customer_Contact_Name__c = 'Test';
        deal.End_Customer_Contact_Last_Name__c= 'Test';
        deal.End_Customer_Country__c = 'US';
        deal.End_Customer_Domain__c = 'Test@abc.com';
        deal.End_Customer_Email__c  = 'Test@abc.com';
        deal.End_Customer_Name__c = 'ABC Inc';
        deal.End_Customer_Phone__c = '123456789';
        deal.End_Customer_State__c = 'US';
        deal.DS_Review_Status__c = 'Pending Review';
        deal.Estimated_Amount__c = 1234567;
        deal.Expected_Close_Date__c = System.today() + 30;
        deal.Market_Segment__c = 'SMB';
        deal.Number_of_Users__c = 1234567;
        deal.Partner_Company_Name__c = 'Test partner';
        deal.Partner_Contact_Email__c = 'Test@partner.com';
        deal.Partner_Contact_Name__c = 'Test';
        deal.Partner_Contact_Last_Name__c  = 'Partner';
        deal.Partner_Country__c  = 'US';
        deal.Partner_Domain__c  = 'partner.com';
        deal.Partner_Account__c = acc.Id;
        deal.Source__c = 'Deal Reg';
        deal.Status__c = 'Submitted';
        deal.AW_Partner_Intent__c = 'Interested';
        deal.POV_Partner_Intent__c = 'Interested';
        deal.Delivery_Intent__c = 'Interested';
        deal.Account_Type__c	= 'Customer';
        insert deal;
        
        deal.OwnerId = userInfo.getuserId();
        update deal; */
        
        /*Opportunity opp = new Opportunity();
        opp.Name = 'Test Opp';
        opp.CloseDate = System.today() + 30;
        opp.AccountId = acc.Id;
        opp.Amount = 123456;
        opp.StageName = Label.Stage_1_Alignment;
        opp.Deal_Reg__c = deal.Id;
        opp.Associated_Deal_Registrations__c = deal.Name;
        TriggerHandler.bypass('OpportunityTriggerHandler');
        insert Opp;
        
        Opportunity_Partner__c oppPartner = new Opportunity_Partner__c(Is_Primary__c = TRUE, Opportunity__c = opp.Id, Partner_Type__c = 'Reseller', Account__c = acc.Id);
        insert oppPartner;
        
        Opportunity_Partner__c oppPartner1 = new Opportunity_Partner__c(Is_Primary__c = true,Opportunity__c = opp.Id,Partner_Type__c = 'Deal Reg',Account__c = acc.Id);
        insert oppPartner1;
        
        Opportunity_Partner__c oppPartner2 = new Opportunity_Partner__c(Is_Primary__c = true,Opportunity__c = opp.Id,Partner_Type__c = 'Architecture Workshop',Account__c = acc.Id);
        insert oppPartner2;
        
        Test.startTest();
            PageReference pageRef = Page.DealRegConversion;
            Test.setCurrentPage(pageRef);
            pageRef.getParameters().put('id', String.valueOf(deal.Id));
            
            DealRegConversionController.dealReg = deal;
            DealRegConversionController.convertDealReg(deal.Id);
            
        Test.stopTest();
        TriggerHandler.clearBypass('OpportunityTriggerHandler');
    }*/
    
    @isTest
    static void testOpportunityConversionWithoutAcc(){
        Account acc = [SELECT Id FROM Account WHERE Name = 'Test Data'];
        Campaign camp = [SELECT Id FROM Campaign WHERE Name = 'DealRegistration'];
        Lead le = [SELECT Id FROM Lead WHERE Company = 'Test Company'];
        Contact con = [SELECT Id FROM Contact WHERE LastName = 'Smith'];
        Partner_Incentive__c partnerIncentive = [SELECT Id FROM Partner_Incentive__c WHERE Partner_Program__c = 'Summit - Federal'];

        TriggerUtility.dealRegAfterUpdateExecuted();
        TriggerUtility.dealRegAfterInsertExecuted();
        TriggerUtility.dealRegBeforeInsertExecuted();
        TriggerUtility.contactPatchManagerExecuted();
        TriggerUtility.conWhiteSpaceUpdateExecuted();
        TriggerUtility.accToContactOwnerExecuted();
        TriggerUtility.contactOwnerShipExecuted();
        TriggerUtility.oppCaseCreationExecuted();
        TriggerUtility.requestDecommissionPrExecuted();
        TriggerUtility.oppSpliSalesTeamExecuted();
        TriggerUtility.caseCreationForLeadTerrirtoryExecuted();
        TriggerUtility.prospectTypeUpdExecuted();

        ZscalerSetting__c zs = new ZscalerSetting__c();
        zs.Name = 'DealRegCampaign';
        zs.Value__c = ''+camp.Id;
        insert zs;
        
        ZscalerSetting__c zs1 = new ZscalerSetting__c();
        zs1.Name = 'DealRegCaseReviewOwnerId';
        zs1.Value__c = ''+userInfo.getuserId();
        insert zs1;
        
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
        deal.Expected_Close_Date__c = System.today() + 30;
        deal.Market_Segment__c = 'SMB';
        deal.Number_of_Users__c = 1234567;
        deal.Partner_Company_Name__c = 'Test partner';
        deal.Partner_Contact_Email__c = 'Test@partner.com';
        deal.Partner_Contact_Name__c = 'Test';
        deal.Partner_Contact_Last_Name__c  = 'Partner';
        deal.Partner_Country__c  = 'US';
        deal.Partner_Domain__c  = 'partner.com';
        deal.Partner_Account__c = acc.Id;
        deal.Source__c = 'Deal Reg';
        deal.Status__c = 'Submitted';
        deal.AW_Partner_Intent__c = 'Interested';
        deal.POV_Partner_Intent__c = 'Interested';
        deal.Delivery_Intent__c = 'Interested';
        deal.Distributor__c = acc.Id;
        deal.Account_Type__c	= 'Customer';
        insert deal;
        
        deal.OwnerId = userInfo.getuserId();
        update deal;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opp';
        opp.CloseDate = System.today() + 30;
        opp.AccountId = acc.Id;
        opp.Amount = 123456;
        opp.StageName = Label.Stage_1_Alignment;
        opp.Deal_Reg__c = deal.Id;
        opp.Associated_Deal_Registrations__c = deal.Name;
        TriggerHandler.bypass('OpportunityTriggerHandler');
        insert Opp;
        
        Test.startTest();
            PageReference pageRef = Page.DealRegConversion;
            Test.setCurrentPage(pageRef);
            pageRef.getParameters().put('id', String.valueOf(deal.Id));
            
            DealRegConversionController.dealRegId = deal.id;
            DealRegConversionController.dealReg = deal;
            DealRegConversionController.convertDealReg(deal.id);
            DealRegConversionController.contactConversion();
            DealRegConversionController.opportunityConversion();
        Test.stopTest();
        TriggerHandler.clearBypass('OpportunityTriggerHandler');
    }
    
    @isTest
    static void testConversionWithoutContactAndLead() {
        Account acc = [SELECT Id,Service_Authorizations__c,Type FROM Account WHERE Name = 'Test Partner'];
        Campaign camp = [SELECT Id FROM Campaign WHERE Name = 'DealRegistration'];
        Lead le = [SELECT Id FROM Lead WHERE Company = 'Test Company'];
        Contact con = [SELECT Id FROM Contact WHERE LastName = 'Smith'];
        Partner_Incentive__c partnerIncentive = [SELECT Id FROM Partner_Incentive__c WHERE Partner_Program__c = 'Summit - Federal'];
        Deal_Reg__c deal = [SELECT ID, Name, Partner_Category__c,End_Customer_Contact_Name__c,
		 End_Customer_Contact_Last_Name__c,End_Customer_Country__c,End_Customer_Domain__c,End_Customer_Email__c,
		 End_Customer_Name__c,End_Customer_Phone__c,End_Customer_State__c,DS_Review_Status__c,Estimated_Amount__c,
		 Expected_Close_Date__c,Market_Segment__c,Number_of_Users__c,Partner_Company_Name__c,Partner_Contact_Email__c,
		 Partner_Contact_Name__c,Partner_Contact_Last_Name__c,Partner_Country__c,Partner_Domain__c,Partner_Account__c,Source__c,Status__c,
		 Account_Manager__c,AW_Partner_Intent__c,POV_Partner_Intent__c,Delivery_Intent__c,Deal_Reg_Type__c,Account_Type__c FROM Deal_Reg__c WHERE End_Customer_Email__c = 'Test@abcd.com'];
               
        TriggerUtility.dealRegAfterUpdateExecuted();
        TriggerUtility.dealRegAfterInsertExecuted();
        TriggerUtility.dealRegBeforeInsertExecuted();
        TriggerUtility.contactPatchManagerExecuted();
        TriggerUtility.conWhiteSpaceUpdateExecuted();
        TriggerUtility.accToContactOwnerExecuted();
        TriggerUtility.contactOwnerShipExecuted();
        TriggerUtility.oppCaseCreationExecuted();
        TriggerUtility.requestDecommissionPrExecuted();
        TriggerUtility.oppSpliSalesTeamExecuted();
        TriggerUtility.caseCreationForLeadTerrirtoryExecuted();
        TriggerUtility.prospectTypeUpdExecuted();
        
        ZscalerSetting__c zs = new ZscalerSetting__c();
        zs.Name = 'DealRegCampaign';
        zs.Value__c = ''+camp.Id;
        insert zs;
        
        ZscalerSetting__c zs1 = new ZscalerSetting__c();
        zs1.Name = 'DealRegCaseReviewOwnerId';
        zs1.Value__c = ''+userInfo.getuserId();
        insert zs1;
        /*
        Deal_Reg__c deal = new Deal_Reg__c();
        deal.End_Customer_Contact_Name__c = 'Test';
        deal.End_Customer_Contact_Last_Name__c= 'Test';
        deal.End_Customer_Country__c = 'US';
        deal.End_Customer_Domain__c = 'abcd.com';
        deal.End_Customer_Email__c  = 'Test@abcd.com';
        deal.End_Customer_Name__c = 'ABC Inc';
        deal.End_Customer_Phone__c = '123456789';
        deal.End_Customer_State__c = 'US';
        deal.DS_Review_Status__c = 'Pending Review';
        deal.Estimated_Amount__c = 1234567;
        deal.Expected_Close_Date__c = System.today() + 30;
        deal.Market_Segment__c = 'SMB';
        deal.Number_of_Users__c = 1234567;
        deal.Partner_Company_Name__c = 'Test partner';
        deal.Partner_Contact_Email__c = 'Test@partner.com';
        deal.Partner_Contact_Name__c = 'Test';
        deal.Partner_Contact_Last_Name__c  = 'Partner';
        deal.Partner_Country__c  = 'US';
        deal.Partner_Domain__c  = 'partner.com';
        deal.Partner_Account__c = acc.Id;
        deal.Source__c = 'Deal Reg';
        deal.Status__c = 'Submitted';
        deal.Account_Manager__c = userInfo.getuserId();
        deal.AW_Partner_Intent__c = 'Interested';
        deal.POV_Partner_Intent__c = 'Interested';
        deal.Delivery_Intent__c = 'Interested';
        insert deal;
        
        deal.OwnerId = userInfo.getuserId();
        update deal;  */
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opp';
        opp.CloseDate = System.today() + 30;
        opp.AccountId = acc.Id;
        opp.Amount = 123456;
        opp.StageName = Label.Stage_1_Alignment;
        opp.Deal_Reg__c = deal.Id;
        opp.Associated_Deal_Registrations__c = deal.Name;
        TriggerHandler.bypass('OpportunityTriggerHandler');
        insert Opp;
        
        Test.startTest();
            PageReference pageRef = Page.DealRegConversion;
            Test.setCurrentPage(pageRef);
            pageRef.getParameters().put('id', String.valueOf(deal.Id));
            
            DealRegConversionController.dealRegId = deal.id;
            DealRegConversionController.dealReg = deal;
            
          /*  deal.Deal_Reg_Type__c = Label.Deal_Reg_Type_Teaming;
            deal.Account_Type__c ='Customer';
            deal.Partner_Account__c = acc.Id;
            update deal;  */
        
            DealRegConversionController.associateDealToOpp(null, deal.id);
            DealRegConversionController.convertDealReg(deal.id);
          //  DealRegConversionController.convertDealReg(deal.id);
        //    DealRegConversionController.opportunityConversion();
        Test.stopTest();
        TriggerHandler.clearBypass('OpportunityTriggerHandler');
    }
    
    @isTest
    static void testConversionWithContactAndLead() {
        Account acc = [SELECT Id FROM Account WHERE Name = 'Test Partner' and Service_Authorizations__c!=Null];
        Campaign camp = [SELECT Id FROM Campaign WHERE Name = 'DealRegistration'];
        Lead le = [SELECT Id,LastName,Company FROM Lead WHERE Email = 'test1234@abc.com' LIMIT 1];
        Contact con = [SELECT Id FROM Contact WHERE LastName = 'Smith'];
        Partner_Incentive__c partnerIncentive = [SELECT Id FROM Partner_Incentive__c WHERE Partner_Program__c = 'Summit - Federal'];
        System.debug('Lead List' +le);
        TriggerUtility.dealRegAfterUpdateExecuted();
        TriggerUtility.dealRegAfterInsertExecuted();
        TriggerUtility.dealRegBeforeInsertExecuted();
        TriggerUtility.contactPatchManagerExecuted();
        TriggerUtility.conWhiteSpaceUpdateExecuted();
        TriggerUtility.accToContactOwnerExecuted();
        TriggerUtility.contactOwnerShipExecuted();
        TriggerUtility.oppCaseCreationExecuted();
        TriggerUtility.requestDecommissionPrExecuted();
        TriggerUtility.oppSpliSalesTeamExecuted();
        TriggerUtility.caseCreationForLeadTerrirtoryExecuted();
        TriggerUtility.prospectTypeUpdExecuted();
        
        ZscalerSetting__c zs = new ZscalerSetting__c();
        zs.Name = 'DealRegCampaign';
        zs.Value__c = ''+camp.Id;
        insert zs;
        
        ZscalerSetting__c zs1 = new ZscalerSetting__c();
        zs1.Name = 'DealRegCaseReviewOwnerId';
        zs1.Value__c = ''+userInfo.getuserId();
        insert zs1;
        
        OnOffSwitch__c zcs1= new OnOffSwitch__c();
        zcs1.name='updateContactStatus';
        zcs1.Deactivate_Component__c=false;
        insert zcs1;
        
        Deal_Reg__c deal = new Deal_Reg__c();
        deal.End_Customer_Contact_Name__c = 'Test';
        deal.End_Customer_Contact_Last_Name__c= 'Test';
        deal.End_Customer_Country__c = 'US';
        deal.End_Customer_Domain__c = 'partner.com';
        deal.End_Customer_Email__c  = 'Test@abcd.com';
        deal.End_Customer_Name__c = 'ABC Inc';
        deal.End_Customer_Phone__c = '123456789';
        deal.End_Customer_State__c = 'US';
        deal.DS_Review_Status__c = 'Pending Review';
        deal.Estimated_Amount__c = 1234567;
        deal.Expected_Close_Date__c = System.today() + 30;
        deal.Market_Segment__c = 'SMB';
        deal.Number_of_Users__c = 1234567;
        deal.Partner_Company_Name__c = 'Test partner';
        deal.Partner_Contact_Email__c = 'Test@partner.com';
        deal.Partner_Contact_Name__c = 'Test';
        deal.Partner_Contact_Last_Name__c  = 'Partner';
        deal.Partner_Country__c  = 'US';
        deal.Partner_Domain__c  = 'partner.com';
        deal.Partner_Account__c = acc.Id;
        deal.Source__c = 'Deal Reg';
        deal.Status__c = 'Submitted';
        deal.Account_Manager__c = userInfo.getuserId();
        deal.AW_Partner_Intent__c = 'Interested';
        deal.POV_Partner_Intent__c = 'Interested';
        deal.Delivery_Intent__c = 'Interested';
        insert deal;
        
        deal.OwnerId = userInfo.getuserId();
        deal.Account_Manager__c = userInfo.getuserId();
        update deal;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opp';
        opp.CloseDate = System.today() + 30;
        opp.AccountId = acc.Id;
        opp.Amount = 123456;
        opp.StageName = Label.Stage_1_Alignment;
        opp.Deal_Reg__c = deal.Id;
        opp.Associated_Deal_Registrations__c = deal.Name;
         TriggerHandler.bypass('OpportunityTriggerHandler');
        insert Opp;
        
        Opportunity_Partner__c oppPartner = new Opportunity_Partner__c(Is_Primary__c = TRUE, Opportunity__c = opp.Id, Partner_Type__c = 'Reseller', Account__c = acc.Id);
        insert oppPartner;
        
        Opportunity_Partner__c oppPartner1 = new Opportunity_Partner__c(Is_Primary__c = true,Opportunity__c = opp.Id,Partner_Type__c = 'Deal Reg',Account__c = acc.Id);
        insert oppPartner1;
        
        Opportunity_Partner__c oppPartner2 = new Opportunity_Partner__c(Is_Primary__c = true,Opportunity__c = opp.Id,Partner_Type__c = 'Architecture Workshop',Account__c = acc.Id);
        insert oppPartner2;
        
        Opportunity_Partner__c oppPartner3 = new Opportunity_Partner__c(Is_Primary__c = true,Opportunity__c = opp.Id,Partner_Type__c = 'Professional Services',Account__c = acc.Id);
        insert oppPartner3;
        
        Cosell_Activities__c rec = new Cosell_Activities__c(partner__c = acc.Id,Opportunity__c = opp.Id,Activity__c = 'POV');
        insert rec;
        
        Cosell_Activities__c rec1 = new Cosell_Activities__c(partner__c = acc.Id,Opportunity__c = opp.Id,Activity__c = 'AW/POV',Status__c=Label.Cosell_Completed);
        insert rec1;
        Cosell_Activities__c rec2 = new Cosell_Activities__c(partner__c = acc.Id,Opportunity__c = opp.Id,Activity__c = 'AW/POV',Status__c=Label.Cosell_Invited);
        insert rec2;
        TriggerHandler.clearBypass('OpportunityTriggerHandler');
        
        Test.startTest();
            PageReference pageRef = Page.DealRegConversion;
            Test.setCurrentPage(pageRef);
            pageRef.getParameters().put('id', String.valueOf(deal.Id));
            
            DealRegConversionController.dealRegId = deal.id;
            DealRegConversionController.dealReg = deal;
            
            deal.Deal_Reg_Type__c = Label.Deal_Reg_Type_Teaming;
            update deal;
            
            deal.Contact__c = con.Id;
            update deal;
            
            DealRegConversionController.leadConversionWithAccAndOpp(le.id, acc.Id, opp.Id);
            DealRegConversionController.markNonPrimaryResellerPartner();
        Test.stopTest();
    }
    
    @isTest
    static void testOpportunityConversion() {
        Account acc = [SELECT Id FROM Account WHERE Name = 'Test Data'];
        Campaign camp = [SELECT Id FROM Campaign WHERE Name = 'DealRegistration'];
        Lead le = [SELECT Id,LastName,Company FROM Lead WHERE Company = 'Test Company'];
        Contact con = [SELECT Id FROM Contact WHERE LastName = 'Smith'];
        Partner_Incentive__c partnerIncentive = [SELECT Id FROM Partner_Incentive__c WHERE Partner_Program__c = 'Summit - Federal'];
        
        TriggerUtility.dealRegAfterUpdateExecuted();
        TriggerUtility.dealRegAfterInsertExecuted();
        TriggerUtility.dealRegBeforeInsertExecuted();
        TriggerUtility.contactPatchManagerExecuted();
        TriggerUtility.conWhiteSpaceUpdateExecuted();
        TriggerUtility.accToContactOwnerExecuted();
        TriggerUtility.contactOwnerShipExecuted();
        TriggerUtility.oppCaseCreationExecuted();
        TriggerUtility.requestDecommissionPrExecuted();
        TriggerUtility.oppSpliSalesTeamExecuted();
        TriggerUtility.caseCreationForLeadTerrirtoryExecuted();
        TriggerUtility.prospectTypeUpdExecuted();
        
        ZscalerSetting__c zs = new ZscalerSetting__c();
        zs.Name = 'DealRegCampaign';
        zs.Value__c = ''+camp.Id;
        insert zs;
        
        ZscalerSetting__c zs1 = new ZscalerSetting__c();
        zs1.Name = 'DealRegCaseReviewOwnerId';
        zs1.Value__c = ''+userInfo.getuserId();
        insert zs1;
        
        Deal_Reg__c deal = new Deal_Reg__c();
        deal.End_Customer_Contact_Name__c = 'Test';
        deal.End_Customer_Contact_Last_Name__c= 'Test';
        deal.End_Customer_Country__c = 'US';
        deal.End_Customer_Domain__c = 'abcd.com';
        deal.End_Customer_Email__c  = 'Test@abcd.com';
        deal.End_Customer_Name__c = 'ABC Inc';
        deal.End_Customer_Phone__c = '123456789';
        deal.End_Customer_State__c = 'US';
        deal.DS_Review_Status__c = 'Pending Review';
        deal.Estimated_Amount__c = 1234567;
        deal.Expected_Close_Date__c = System.today() + 30;
        deal.Market_Segment__c = 'SMB';
        deal.Number_of_Users__c = 1234567;
        deal.Partner_Company_Name__c = 'Test partner';
        deal.Partner_Contact_Email__c = 'Test@partner.com';
        deal.Partner_Contact_Name__c = 'Test';
        deal.Partner_Contact_Last_Name__c  = 'Partner';
        deal.Partner_Country__c  = 'US';
        deal.Partner_Domain__c  = 'partner.com';
        deal.Partner_Account__c = acc.Id;
        deal.Source__c = 'Deal Reg';
        deal.Status__c = 'Submitted';
        deal.Account_Manager__c = userInfo.getuserId();
        deal.AW_Partner_Intent__c = 'Interested';
        deal.POV_Partner_Intent__c = 'Interested';
        deal.AW_POV_Partner_Intent__c = 'Interested';
        deal.Distributor__c = acc.Id;
        deal.Delivery_Intent__c = 'Interested';
        insert deal;

        deal.OwnerId = userInfo.getuserId();
        deal.Account_Manager__c = userInfo.getuserId();
        update deal;
        
        Test.startTest();
            Opportunity opp = new Opportunity();
            opp.Name = 'Test Opp';
            opp.CloseDate = System.today() + 30;
            opp.AccountId = acc.Id;
            opp.Amount = 123456;
            opp.StageName = Label.Stage_1_Alignment;
            opp.Deal_Reg__c = deal.Id;
            opp.Associated_Deal_Registrations__c = deal.Name;
         	TriggerHandler.bypass('OpportunityTriggerHandler');
            insert Opp;
        
        	Cosell_Activities__c rec1 = new Cosell_Activities__c(partner__c = acc.Id,Opportunity__c = opp.Id,Activity__c = 'AW/POV',Status__c=Label.Cosell_Completed);
        	insert rec1;
        	Cosell_Activities__c rec2 = new Cosell_Activities__c(partner__c = acc.Id,Opportunity__c = opp.Id,Activity__c = 'AW/POV',Status__c=Label.Cosell_Invited);
        	insert rec2;
        
            PageReference pageRef = Page.DealRegConversion;
            Test.setCurrentPage(pageRef);
            pageRef.getParameters().put('id', String.valueOf(deal.Id));

            DealRegConversionController.dealRegId = deal.id;
            DealRegConversionController.dealReg = deal;
            DealRegConversionController.opportunityConversion();
        	TriggerHandler.clearBypass('OpportunityTriggerHandler');
        Test.stopTest();
    }    
    
    @isTest
    static void testAssociateDealToOpp() {
        Account acc = [SELECT Id,Partner_Type__c FROM Account WHERE Name = 'Test partner'];
        Campaign camp = [SELECT Id FROM Campaign WHERE Name = 'DealRegistration'];
        Lead le = [SELECT Id,LastName,Company FROM Lead WHERE Company = 'Test Company'];
        Contact con = [SELECT Id FROM Contact WHERE LastName = 'Smith'];
        Partner_Incentive__c partnerIncentive = [SELECT Id FROM Partner_Incentive__c WHERE Partner_Program__c = 'Summit - Federal'];
        
        TriggerUtility.dealRegAfterUpdateExecuted();
        TriggerUtility.dealRegAfterInsertExecuted();
        TriggerUtility.dealRegBeforeInsertExecuted();
        TriggerUtility.contactPatchManagerExecuted();
        TriggerUtility.conWhiteSpaceUpdateExecuted();
        TriggerUtility.accToContactOwnerExecuted();
        TriggerUtility.contactOwnerShipExecuted();
        TriggerUtility.oppCaseCreationExecuted();
        TriggerUtility.requestDecommissionPrExecuted();
        TriggerUtility.oppSpliSalesTeamExecuted();
        TriggerUtility.caseCreationForLeadTerrirtoryExecuted();
        TriggerUtility.prospectTypeUpdExecuted();
        
        ZscalerSetting__c zs = new ZscalerSetting__c();
        zs.Name = 'DealRegCampaign';
        zs.Value__c = ''+camp.Id;
        insert zs;
        
        ZscalerSetting__c zs1 = new ZscalerSetting__c();
        zs1.Name = 'DealRegCaseReviewOwnerId';
        zs1.Value__c = ''+userInfo.getuserId();
        insert zs1;
        
        Deal_Reg__c deal = new Deal_Reg__c();
        deal.End_Customer_Contact_Name__c = 'Test';
        deal.End_Customer_Contact_Last_Name__c= 'Test';
        deal.End_Customer_Country__c = 'US';
        deal.End_Customer_Domain__c = 'abcd.com';
        deal.End_Customer_Email__c  = 'Test@abcd.com';
        deal.End_Customer_Name__c = 'ABC Inc';
        deal.End_Customer_Phone__c = '123456789';
        deal.End_Customer_State__c = 'US';
        deal.DS_Review_Status__c = 'Pending Review';
        deal.Estimated_Amount__c = 1234567;
        deal.Expected_Close_Date__c = System.today() + 30;
        deal.Market_Segment__c = 'SMB';
        deal.Number_of_Users__c = 1234567;
        deal.Partner_Company_Name__c = 'Test partner';
        deal.Partner_Contact_Email__c = 'Test@partner.com';
        deal.Partner_Contact_Name__c = 'Test';
        deal.Partner_Contact_Last_Name__c  = 'Partner';
        deal.Partner_Country__c  = 'US';
        deal.Partner_Domain__c  = 'partner.com';
        deal.Partner_Account__c = acc.Id;
        deal.Source__c = 'Deal Reg';
        deal.Status__c = 'Submitted';
        deal.Account_Manager__c = userInfo.getuserId();
        deal.AW_Partner_Intent__c = 'Interested';
        deal.POV_Partner_Intent__c = 'Interested';
        deal.Delivery_Intent__c = 'Interested';
        insert deal;
        
        deal.OwnerId = userInfo.getuserId();
        deal.Account_Manager__c = userInfo.getuserId();
        update deal;
       
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opp';
        opp.CloseDate = System.today() + 30;
        opp.AccountId = acc.Id;
        opp.Amount = 123456;
        opp.StageName = Label.Stage_1_Alignment;
        opp.Deal_Reg__c = deal.Id;
        opp.Associated_Deal_Registrations__c = deal.Name;
        insert Opp;
        
        Opportunity_Partner__c oppPartner = new Opportunity_Partner__c(Is_Primary__c = true, Opportunity__c = opp.Id, Partner_Type__c = 'Reseller', Account__c = acc.Id);
        insert oppPartner;
            
        Opportunity_Partner__c oppPartner2 = new Opportunity_Partner__c(Is_Primary__c = true, Opportunity__c = opp.Id, Partner_Type__c = 'Architecture Workshop', Account__c = acc.Id);
        insert oppPartner2;
        
        Opportunity_Partner__c oppPartner3 = new Opportunity_Partner__c(Is_Primary__c = true, Opportunity__c = opp.Id, Partner_Type__c = 'Distributor', Account__c = acc.Id);
        insert oppPartner3;
        
        Test.startTest();
            DealRegConversionController.OpportunityListWrapper oppListWrapperObject = new DealRegConversionController.OpportunityListWrapper(FALSE, Opp,Null);
            DealRegConversionController.OpportunityListWrapper oppListWrapperObjectStr = new DealRegConversionController.OpportunityListWrapper(FALSE, 'Opp');
    
            PageReference pageRef = Page.DealRegConversion;
            Test.setCurrentPage(pageRef);
            pageRef.getParameters().put('id', String.valueOf(deal.Id));

            DealRegConversionController controller = new DealRegConversionController();
            DealRegConversionController.dealRegId = deal.id;
            DealRegConversionController.dealReg = deal;

            deal.Deal_Reg_Type__c= Label.Deal_Reg_Type_Teaming;
            update deal;

            DealRegConversionController.associateDealToOpp(null, deal.id);
            DealRegConversionController.associateDealToOpp(opp.Id, deal.id);
        Test.stopTest();
    }
    
	@isTest
    static void testAssociateDealToOpp1() {
        Account acc = [SELECT Id,Partner_Type__c FROM Account WHERE Name = 'Test partner'];
        Campaign camp = [SELECT Id FROM Campaign WHERE Name = 'DealRegistration'];
        Lead le = [SELECT Id,LastName,Company FROM Lead WHERE Company = 'Test Company'];
        Contact con = [SELECT Id FROM Contact WHERE LastName = 'Smith'];
        Partner_Incentive__c partnerIncentive = [SELECT Id FROM Partner_Incentive__c WHERE Partner_Program__c = 'Summit - Federal'];
        
        TriggerUtility.dealRegAfterUpdateExecuted();
        TriggerUtility.dealRegAfterInsertExecuted();
        TriggerUtility.dealRegBeforeInsertExecuted();
        TriggerUtility.contactPatchManagerExecuted();
        TriggerUtility.conWhiteSpaceUpdateExecuted();
        TriggerUtility.accToContactOwnerExecuted();
        TriggerUtility.contactOwnerShipExecuted();
        TriggerUtility.oppCaseCreationExecuted();
        TriggerUtility.requestDecommissionPrExecuted();
        TriggerUtility.oppSpliSalesTeamExecuted();
        TriggerUtility.caseCreationForLeadTerrirtoryExecuted();
        TriggerUtility.prospectTypeUpdExecuted();
        
        ZscalerSetting__c zs = new ZscalerSetting__c();
        zs.Name = 'DealRegCampaign';
        zs.Value__c = ''+camp.Id;
        insert zs;
        
        ZscalerSetting__c zs1 = new ZscalerSetting__c();
        zs1.Name = 'DealRegCaseReviewOwnerId';
        zs1.Value__c = ''+userInfo.getuserId();
        insert zs1;
        
        Id partnerAccRecordTypeId = Schema.SObjectType.Deal_Reg__c.getRecordTypeInfosByName().get('Renewal Deal Reg').getRecordTypeId();
        Deal_Reg__c deal = new Deal_Reg__c();
        deal.End_Customer_Contact_Name__c = 'Test';
        deal.RecordTypeId=partnerAccRecordTypeId;
        deal.End_Customer_Contact_Last_Name__c= 'Test';
        deal.End_Customer_Country__c = 'US';
        deal.End_Customer_Domain__c = 'abcd.com';
        deal.End_Customer_Email__c  = 'Test@abcd.com';
        deal.End_Customer_Name__c = 'ABC Inc';
        deal.End_Customer_Phone__c = '123456789';
        deal.End_Customer_State__c = 'US';
        deal.Expected_Close_Date__c = System.today() + 30;
        deal.Partner_Company_Name__c = 'Test partner';
        deal.Partner_Contact_Email__c = 'Test@partner.com';
        deal.Partner_Contact_Name__c = 'Test';
        deal.Partner_Contact_Last_Name__c  = 'Partner';
        deal.Partner_Country__c  = 'US';
        deal.Partner_Domain__c  = 'partner.com';
        deal.Partner_Account__c = acc.Id;
        deal.Account_Manager__c = userInfo.getuserId();
        insert deal;
        
        deal.OwnerId = userInfo.getuserId();
        deal.Account_Manager__c = userInfo.getuserId();
        update deal;
       
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opp';
        opp.CloseDate = System.today() + 30;
        opp.AccountId = acc.Id;
        opp.Amount = 123456;
        opp.StageName = Label.Stage_1_Alignment;
        opp.Deal_Reg__c = deal.Id;
        opp.Associated_Deal_Registrations__c = deal.Name;
        insert Opp;
        
        Opportunity_Partner__c oppPartner = new Opportunity_Partner__c(Is_Primary__c = TRUE, Opportunity__c = opp.Id, Partner_Type__c = 'Reseller', Account__c = acc.Id);
        insert oppPartner;
            
        Opportunity_Partner__c oppPartner2 = new Opportunity_Partner__c(Is_Primary__c = true,Opportunity__c = opp.Id,Partner_Type__c = 'Architecture Workshop',Account__c = acc.Id);
        insert oppPartner2;
        
        Opportunity_Partner__c oppPartner3 = new Opportunity_Partner__c(Is_Primary__c = true,Opportunity__c = opp.Id,Partner_Type__c = 'Distributor',Account__c = acc.Id);
        insert oppPartner3;
        
        Test.startTest();
            DealRegConversionController.OpportunityListWrapper oppListWrapperObject = new DealRegConversionController.OpportunityListWrapper(FALSE,Opp,Null);
            DealRegConversionController.OpportunityListWrapper oppListWrapperObjectStr = new DealRegConversionController.OpportunityListWrapper(FALSE,'Opp');
    
            PageReference pageRef = Page.DealRegConversion;
            Test.setCurrentPage(pageRef);
            pageRef.getParameters().put('id', String.valueOf(deal.Id));
            
            DealRegConversionController.dealRegId = deal.id;
            DealRegConversionController.dealReg = deal;
            
            deal.Deal_Reg_Type__c= Label.Deal_Reg_Type_Renewal;
            update deal;
            
            DealRegConversionController.associateDealToOpp(opp.Id, deal.id);
            DealRegConversionController.selectedOppId = opp.Id;
            DealRegConversionController.associateDealToOpp(opp.Id, deal.id);
        Test.stopTest();
    }
	  @isTest
    static void testLeadConversion(){
        Account acc = [SELECT Id FROM Account WHERE Name = 'Test partner'];
        Deal_Reg__c deal = [SELECT ID, Name,Lead__c, Partner_Category__c FROM Deal_Reg__c WHERE End_Customer_Email__c = 'Test@abc.com'];
		
         Test.startTest();
            PageReference pageRef = Page.DealRegConversion;
            Test.setCurrentPage(pageRef);
            pageRef.getParameters().put('id', String.valueOf(deal.Id));
            DealRegConversionController.dealRegId = deal.id;
            DealRegConversionController.dealReg = deal;
            DealRegConversionController.leadConversion(deal.Lead__c);
        Test.stopTest();
      }
}