@IsTest
private class DealRegConversionDateBatchTest {
    
    @TestSetup
    static void createtestData(){
        TriggerHandler.bypass('AccountTriggerHandler');
        TriggerHandler.bypass('OpportunityTriggerHandler');
        TriggerHandler.bypass('InspireProjectMasterTriggerHandler');
        
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

    
    @isTest
    static void testAssociateDealToOpp() {
        
        List<Deal_Reg__c> dealRegInsertList = [Select id,name from Deal_Reg__c];
        
        List<Deal_Reg__History> dealRegHistoryList = new List<Deal_Reg__History>();        
        Deal_Reg__History dealRegHistory = new Deal_Reg__History();
        dealRegHistory.ParentId = dealRegInsertList.get(0).Id;
        dealRegHistory.Field = 'Status__c';
        dealRegHistoryList.add(dealRegHistory);
        INSERT dealRegHistoryList;
        
        
        System.Test.startTest();
        Database.executeBatch(new DealRegConversionDateBatchController());
        System.Test.stopTest();
    }
}