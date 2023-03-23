@isTest
public class DealRegConversionLWCHelperTestCPQ {
    
    static testmethod void TestLwcSimple(){
        test.startTest();
        Skip_Triggers__c skipTriggers = new Skip_Triggers__c();
        skipTriggers.Skip_Account_Triggers__c = true;
        skipTriggers.Skip_Opportunity_Triggers__c = true;
        skipTriggers.Name = 'SkipTriggers';
        insert skipTriggers;
        
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
         list<Account> accInsertList = new list<Account>();
        Account acc = new account();
        Acc.Name = 'Test2';
        acc.Domain__c = 'abcs.com';
        accInsertList.add(acc);
        
        Account acc1 = new account();
        Acc1.Name = 'Test1';
        acc1.Domain__c = 'partner1.com';
        accInsertList.add(acc1);
        
        Contact con = new Contact();
        con.firstName = 'dsd';
        con.LastName = 'sdsd';
        con.email = 'smscd@abc.com';
        con.AccountId = accInsertList[0].Id;
        insert con;
        
        Campaign camp = new Campaign();
        camp.Name = 'Deals';
        camp.EndDate = system.today() + 30;
        camp.IsActive = true;
        insert camp;
        ZscalerSetting__c zs = new ZscalerSetting__c();
        zs.Name = 'DealRegCamp';
        zs.Value__c = ''+camp.Id;
        insert zs;
        System.debug('Total Number of SOQL Queries allowed in this apex code context: ' +  Limits.getQueries());
        ZscalerSetting__c zs1 = new ZscalerSetting__c();
        zs1.Name = 'DealRegCaseReviewOwnerId';
        zs1.Value__c = ''+userInfo.getuserId();
        insert zs1;
        
       	Lead le = new Lead();
        le.Company = 'tests deo';
        le.FirstName = 'Test34';
        le.LastName = 'Name23';
        le.Email = 'test122@test.com';
        insert le;
        
        Deal_Reg__c deal = new Deal_Reg__c();
        deal.End_Customer_Contact_Name__c = 'Test1';
        deal.End_Customer_Contact_Last_Name__c= 'Test1';
        deal.End_Customer_Country__c = 'IN';
        deal.End_Customer_Domain__c = 'abcd.com';
        deal.End_Customer_Email__c  = 'asa@abcd.com';
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
        deal.Lead__c = le.id;
        deal.Contact__c = con.id;
        deal.Account_Manager__c = userinfo.getUserId();
        insert deal;
        //deal = [select Id, Name, Partner_Type__c, Market_Segment__c, Territory_Type__c, Deal_Reg_Type__c, NBM_Meeting_Date__c, Discovery_Meeting_Date__c, Deal_Reg_Expiration_Date__c, Partner_Contact__c, Partner_Contact_Email__c,Account_Manager__c, AW_Partner_Intent__c, POV_Partner_Intent__c, Partner_Account_Program__c, Partner_Program__c, Partner_Category__c, End_Customer_Name__c , Partner_Account__c, Estimated_Amount__c,Expected_Close_Date__c,
                      //  Partner_Company_Name__c , Lead__c, Contact__c, End_Customer_Domain__c, End_Customer_Street_Address__c, End_Customer_City__c, End_Customer_State__c, End_Customer_Country__c, End_Customer_Postal_Code__c  from Deal_Reg__c where Id = :deal.Id];
       // system.assertequals(deal.Market_Segment__c, 'SMB');
        //system.assertequals(deal.Territory_Type__c, null);
        //system.assertequals(deal.Deal_Reg_Type__c, null);
        DealRegToConvert ctrl = new DealRegToConvert();
        system.debug(ctrl.dealregmap);
        ctrl.dealtoconvert = deal.Id;
        ctrl.checkconvert();
        
        Opportunity opp = new Opportunity();
        Opp.Name = 'Test Opp';
        Opp.CloseDate = system.Today() + 30;
        Opp.AccountId = accInsertList[0].Id;
        Opp.Amount = 123456;
        opp.StageName = Label.Stage_1_Alignment/*'1 - Qualified and Budgeted'*/;
        opp.Deal_Reg__c = deal.Id;
        
        insert Opp;
        
        
        
        
        DealRegConversionLWCHelperCPQ.init(deal.id);
        DealRegConversionLWCHelperCPQ.convertDRtoOpportunity(Opp.id, deal.id);
        
        test.stopTest();
        
    }
    
    
    
}