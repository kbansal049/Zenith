/*****************************************************************************************
Name: DealRegConversionControllerCPQTest
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
Test class for DealRegConversionControllerCPQ
==========================================================================================
==========================================================================================
History
-------
VERSION        AUTHOR                  DATE              DETAIL              
1.0            Kunal Raj            4-OCT-2016    Initial Development
******************************************************************************************/ 


@isTest(SeeAllData=false)   
public class DealRegConversionControllerCPQTest{  
    
    public static final String TEST_STRING = 'Test';
    public static final String TEST_SDR_EMAIL = 'test.sdr@test.com';
    
    
    
    @testSetup
    static void testSetup(){
        
        TriggerHandler.bypass('AccountTriggerHandler');
        TriggerHandler.bypass('OpportunityTriggerHandler');
        TriggerHandler.bypass('ContactTriggerHandler');
        TriggerHandler.bypass('LeadTriggerHandler');
        
        User testSalesUser = ZSL2OTestDataFactory.prepareTestUser('Test', 'Sales User', ZScalarConstants.PROFILE_CORE_SALES, 
                                                                  ZScalarConstants.ROLE_CUSTOMER_EXPERIENCE_AND_TRANSFORMATION);
        insert testSalesUser;
        
        User testSystemAdminUser = ZSL2OTestDataFactory.prepareTestUser(TEST_STRING, 'System Admin', ZScalarConstants.PROFILE_SYSTEM_ADMINISTRATOR, ZScalarConstants.ROLE_IT_BUSINESS_SYSTEMS);
        insert testSystemAdminUser;
        
        Deal_Reg__c deal;
        Account partnerAcc1;
        Account partnerAcc2;
        Opportunity opp;
        Lead le;
        
        System.runAs(testSystemAdminUser) {
            
            Skip_Triggers__c skipTriggers = new Skip_Triggers__c();
            skipTriggers.Skip_Account_Triggers__c = true;
            skipTriggers.Skip_Opportunity_Triggers__c = true;
            skipTriggers.Name = 'SkipTriggers';
            insert skipTriggers;
            
            Skip_Triggers_User_Based__c sk = new Skip_Triggers_User_Based__c();
            sk.SetupOwnerId = userInfo.getUserId();
            sk.Object_s_to_skip__c = 'Deal_Reg__c;OpportunitySplit';
            INSERT sk;
            
            
            List<Account> accInsertList = new List<Account>();
            partnerAcc1 = new account();
            partnerAcc1.Name = 'Test Data';
            partnerAcc1.Domain__c = 'abc.com';
            accInsertList.add(partnerAcc1);
            
            partnerAcc2 = new account();
            partnerAcc2.Name = 'Test partner';
            partnerAcc2.Domain__c = 'partner.com';
            accInsertList.add(partnerAcc2);
            insert accInsertList;
            
            List<Partner_Incentive__c> piList = new List<Partner_Incentive__c>();
            piList.add((SB_TestCPQDataUtility.createPartnerIncentive(1,accInsertList[1].Id,true,system.today()+60,system.today()-30,'Traditional','MSP'))[0]);
            piList.add((SB_TestCPQDataUtility.createPartnerIncentive(1,accInsertList[1].Id,true,system.today(),system.today(),'Summit - Discount','MSP'))[1]);
            piList[1].Default__c=true;
            insert piList;
            
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
            
            Contact con = new Contact();
            con.firstName = 'Jhon';
            con.LastName = 'Smith';
            con.email = 'jhon@abcd.com';
            con.AccountId = accInsertList[0].Id;
            insert con;
            
            le = new Lead();
            le.Company = 'test Company';
            le.FirstName = 'Test';
            le.LastName = 'Name';
            le.Email = 'test@abc.com';
            insert le;
            
            list<Deal_Reg__c> dealRegInsertList = new list<Deal_Reg__c>();
            deal = new Deal_Reg__c();
            deal.End_Customer_Contact_Name__c = 'Test';
            deal.End_Customer_Contact_Last_Name__c= 'Test';
            deal.End_Customer_Country__c = 'US';
            deal.End_Customer_Domain__c = 'abc.com';
            deal.End_Customer_Email__c  = 'Test@abc.com';
            deal.End_Customer_Name__c = 'ABC Inc';
            deal.End_Customer_Phone__c = '123456789';
            deal.End_Customer_State__c = 'US';
            deal.End_Customer_City__c = 'Texas';
            deal.End_Customer_Street_Address__c = 'Downtown';
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
            deal.Partner_Account__c = accInsertList[1].Id;
            deal.Source__c = 'Deal Reg';
            deal.Status__c = 'Submitted';
            deal.AW_Partner_Intent__c = 'Interested';
            deal.POV_Partner_Intent__c = 'Interested';
            insert deal;
            
            deal.Contact__c = con.Id;
            deal.OwnerId = userInfo.getuserId();
            update deal;
            
            opp = new Opportunity();
            Opp.Name = 'Test Opp';
            Opp.CloseDate = system.Today() + 30;
            Opp.AccountId = accInsertList[0].Id;
            Opp.Amount = 123456;
            opp.StageName = Label.Stage_1_Alignment;
            opp.Deal_Reg__c = deal.Id;
            Opp.Associated_Deal_Registrations__c = deal.Name;
            insert Opp;
            
            
            Opportunity_Partner__c OppPartner = new Opportunity_Partner__c(Is_Primary__c = TRUE, Opportunity__c = opp.Id,
                                                                           Partner_Type__c = 'Reseller', Account__c = partnerAcc1.Id);
            INSERT OppPartner;
            
            Opportunity_Partner__c OppPartner1 = new Opportunity_Partner__c(Is_Primary__c = true,Opportunity__c = opp.Id,
                                                                            Partner_Type__c = 'Deal Reg',Account__c = partnerAcc1.Id);
            insert OppPartner1;
            
            Opportunity_Partner__c OppPartner2 = new Opportunity_Partner__c(Is_Primary__c = true,Opportunity__c = opp.Id,
                                                                            Partner_Type__c = 'Architecture Workshop',Account__c = partnerAcc1.Id);
            insert OppPartner2;
            
            String quoteNewBusiness = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByDeveloperName().get('New_Business').getRecordTypeId();
            SBQQ__Quote__c quoteRec = (SB_TestCPQDataUtility.createQuote(1, Opp.Id, accInsertList[0].Id, accInsertList[1].id, accInsertList[1].id,quoteNewBusiness))[0];
            insert quoteRec;     
        }
        
        TriggerHandler.clearBypass('AccountTriggerHandler');
        TriggerHandler.clearBypass('ContactTriggerHandler');
        TriggerHandler.clearBypass('LeadTriggerHandler');
    }
    
    @IsTest static void testDealRegConversionControllerHelper(){
        
        TriggerHandler.bypass('AccountTriggerHandler');
        TriggerHandler.bypass('OpportunityTriggerHandler');
        
        User coreSales = [Select id from user where lastname = 'Sales User' limit 1];
        User adminUser = [Select id from user where profile.Name = 'System Administrator' and IsActive=True limit 1];
        
        Deal_Reg__c deal = [Select Id, Name, Partner_Type__c, Deal_Reg_Type__c, NBM_Meeting_Date__c,
                            Discovery_Meeting_Date__c, Deal_Reg_Expiration_Date__c, Partner_Contact__c,
                            Partner_Contact_Email__c,Account_Manager__c, AW_Partner_Intent__c, POV_Partner_Intent__c, 
                            Partner_Account_Program__c, Partner_Program__c, Partner_Category__c, End_Customer_Name__c,
                            Partner_Account__c, Estimated_Amount__c,Expected_Close_Date__c,
                            Partner_Company_Name__c, Lead__c, Contact__c, Contact__r.AccountId, 
                            OwnerId, End_Customer_Domain__c, End_Customer_Street_Address__c,
                            End_Customer_City__c, End_Customer_State__c, End_Customer_Country__c, End_Customer_Postal_Code__c, 
                            Record_Type_Name__c from Deal_Reg__c limit 1];
        Account partnerAcc1 = [Select id from Account where Name = 'Test Data' limit 1];
        Account partnerAcc2 = [Select id from Account where Name = 'Test partner' limit 1];
        Opportunity opp = [Select id from Opportunity where Name = 'Test Opp' limit 1];
        Lead le = [Select id from Lead limit 1];
        Contact con = [Select id from Contact limit 1];
        
        
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
        
        
        
        
        Test.startTest(); 
        
        TriggerHandler.bypass('AccountTriggerHandler');
        TriggerHandler.bypass('OpportunityTriggerHandler');
        
        PageReference pageRef = Page.DealRegConversion;
        Test.setCurrentPage(pageRef);
        
        pageRef.getParameters().put('id', String.valueOf(deal.Id));
        DealRegConversionControllerCPQ controller = new DealRegConversionControllerCPQ();
        
        controller.dealRegId = deal.id;
        controller.dealReg = deal;
        
        System.runAs(adminUser){
            
            TriggerHandler.bypass('AccountTriggerHandler');
            TriggerHandler.bypass('OpportunityTriggerHandler');
            
            controller.convertDealReg();
            controller.contactConversion();
            controller.updateDealStatustoConverted();
            controller.updateDealStatustoExpired(deal.id);
            
            controller.createOpportunityPartner(partnerAcc1.Id, Opp.id);        
            try{
                controller.leadConversion(le.Id);  
            }catch(Exception ex){
                system.debug('---ex--'+ex.getMessage());
                system.debug('---ex--'+ex.getLineNumber());
            }
            controller.leadConversionWithAccAndOpp(le.id, partnerAcc1.Id, opp.Id);  
            
            controller.markNonPrimaryResellerPartner();
            
        }
        Test.stopTest();
    }
    
    @IsTest static void testopportunityConversionWithAcc(){
        
        User coreSales = [Select id from user where lastname = 'Sales User' limit 1];
        User adminUser = [Select id from user where profile.Name = 'System Administrator' and IsActive=True limit 1];
        
        Account partnerAcc1 = [Select id from Account where Name = 'Test Data' limit 1];
        Account partnerAcc2 = [Select id from Account where Name = 'Test partner' limit 1];
        Opportunity opp = [Select id from Opportunity where Name = 'Test Opp' limit 1];
        Lead le = [Select id from Lead limit 1];
        Contact con = [Select id from Contact limit 1];
        
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
        deal.AW_Partner_Intent__c = 'Interested';
        deal.POV_Partner_Intent__c = 'Interested';
        insert deal;
        
        
        deal = [Select Id, Name, Partner_Type__c, Deal_Reg_Type__c, NBM_Meeting_Date__c,
                Discovery_Meeting_Date__c, Deal_Reg_Expiration_Date__c, Partner_Contact__c,
                Partner_Contact_Email__c,Account_Manager__c, AW_Partner_Intent__c, POV_Partner_Intent__c, 
                Partner_Account_Program__c, Partner_Program__c, Partner_Category__c, End_Customer_Name__c,
                Partner_Account__c, Estimated_Amount__c,Expected_Close_Date__c,
                Partner_Company_Name__c, Lead__c, Contact__c, Contact__r.AccountId, 
                OwnerId, End_Customer_Domain__c, End_Customer_Street_Address__c,
                End_Customer_City__c, End_Customer_State__c, End_Customer_Country__c, End_Customer_Postal_Code__c, 
                Record_Type_Name__c from Deal_Reg__c limit 1];
        
        
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
        
        try{
            
            TriggerHandler.bypass('AccountTriggerHandler');
            TriggerHandler.bypass('OpportunityTriggerHandler');
            
            Test.startTest();             
            
            System.runAs(adminUser){
                
                PageReference pageRef = Page.DealRegConversion;
                Test.setCurrentPage(pageRef);
                pageRef.getParameters().put('id', String.valueOf(deal.Id));
                DealRegConversionControllerCPQ controller = new DealRegConversionControllerCPQ();
                controller.dealRegId = deal.id;
                controller.dealReg = deal;
                controller.convertDealReg();
                controller.contactConversion();
                controller.opportunityConversion();
                Test.stopTest();
            }
        }
        catch(Exception e){
            System.debug('-=- testopportunityConversionWithAcc -=- '+e.getLineNumber());
        }
        
    }
    
    @IsTest static void testopportunityConversionWithoutAcc(){
        
        
        TriggerHandler.bypass('AccountTriggerHandler');
        TriggerHandler.bypass('OpportunityTriggerHandler');
        TriggerHandler.bypass('DealRegTriggerHelper');
        
        User coreSales = [Select id from user where lastname = 'Sales User' limit 1];
        User adminUser = [Select id from user where profile.Name = 'System Administrator' and IsActive=True limit 1];
        
        Deal_Reg__c deal = [Select Id, Name, Partner_Type__c, Deal_Reg_Type__c, NBM_Meeting_Date__c,
                            Discovery_Meeting_Date__c, Deal_Reg_Expiration_Date__c, Partner_Contact__c,
                            Partner_Contact_Email__c,Account_Manager__c, AW_Partner_Intent__c, POV_Partner_Intent__c, 
                            Partner_Account_Program__c, Partner_Program__c, Partner_Category__c, End_Customer_Name__c,
                            Partner_Account__c, Estimated_Amount__c,Expected_Close_Date__c,
                            Partner_Company_Name__c, Lead__c, Contact__c, Contact__r.AccountId, 
                            OwnerId, End_Customer_Domain__c, End_Customer_Street_Address__c,
                            End_Customer_City__c, End_Customer_State__c, End_Customer_Country__c, End_Customer_Postal_Code__c, 
                            Record_Type_Name__c from Deal_Reg__c limit 1];
        Account partnerAcc1 = [Select id from Account where Name = 'Test Data' limit 1];
        Account partnerAcc2 = [Select id from Account where Name = 'Test partner' limit 1];
        Opportunity opp = [Select id from Opportunity where Name = 'Test Opp' limit 1];
        Lead le = [Select id from Lead limit 1];
        Contact con = [Select id from Contact limit 1];
        
        
        Test.startTest();
        
        System.runAs(adminUser){
            
            TriggerHandler.bypass('AccountTriggerHandler');
            TriggerHandler.bypass('OpportunityTriggerHandler');
            TriggerHandler.bypass('DealRegTriggerHelper');
            PageReference pageRef = Page.DealRegConversion;
            Test.setCurrentPage(pageRef);
            pageRef.getParameters().put('id', String.valueOf(deal.Id));
            DealRegConversionControllerCPQ controller = new DealRegConversionControllerCPQ();
            controller.dealRegId = deal.id;
            controller.dealReg = deal;
            controller.convertDealReg();
            controller.contactConversion();
            controller.opportunityConversion();
            
        }
        
        Test.stopTest();
        
    }
    
    @IsTest static void testConversionWithoutContactAndLead() {
        
        User coreSales = [Select id from user where lastname = 'Sales User' limit 1];
        User adminUser = [Select id from user where profile.Name = 'System Administrator' and IsActive=True limit 1];
        
        Account partnerAcc1 = [Select id from Account where Name = 'Test Data' limit 1];
        Account partnerAcc2 = [Select id from Account where Name = 'Test partner' limit 1];
        Opportunity opp = [Select id from Opportunity where Name = 'Test Opp' limit 1];
        Lead le = [Select id from Lead limit 1];
        Contact con = [Select id from Contact limit 1];
        
        
        TriggerHandler.bypass('AccountTriggerHandler');
        TriggerHandler.bypass('OpportunityTriggerHandler');
        TriggerHandler.bypass('DealRegTriggerHelper');
        
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
        
        
        
        Deal_Reg__c deal = new Deal_Reg__c();
        deal.End_Customer_Contact_Name__c = 'Test';
        deal.End_Customer_Contact_Last_Name__c= 'Test';
        deal.End_Customer_Country__c = 'US';
        deal.End_Customer_Domain__c = 'abcd.com';
        deal.End_Customer_Email__c  = 'Test@abcd.com';
        deal.End_Customer_Name__c = 'ABC Inc';
        deal.End_Customer_Phone__c = '123456789';
        deal.End_Customer_State__c = 'US';
        deal.End_Customer_City__c = 'Texas';
        deal.End_Customer_Street_Address__c = 'Downtown';
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
        deal.Partner_Account__c = partnerAcc1.Id;
        deal.Source__c = 'Deal Reg';
        deal.Status__c = 'Submitted';
        deal.Account_Manager__c = userInfo.getuserId();
        deal.AW_Partner_Intent__c = 'Interested';
        deal.POV_Partner_Intent__c = 'Interested';
        insert deal;
        
        
        Test.startTest();
        
        System.runAs(adminUser){
            deal.OwnerId = userInfo.getuserId();
            update deal;
            TriggerHandler.bypass('AccountTriggerHandler');
            TriggerHandler.bypass('OpportunityTriggerHandler');
            TriggerHandler.bypass('DealRegTriggerHelper');
            
            PageReference pageRef = Page.DealRegConversion;
            Test.setCurrentPage(pageRef);
            pageRef.getParameters().put('id', String.valueOf(deal.Id));
            DealRegConversionControllerCPQ controller = new DealRegConversionControllerCPQ();
            controller.dealRegId = deal.id;
            controller.dealReg = deal;
            TriggerHandler.bypass('AccountTriggerHandler');
            TriggerHandler.bypass('OpportunityTriggerHandler');
            controller.opportunityConversion();
            controller.selectedOppId = opp.Id;
            controller.associateDealToOpp();
            
            deal.Deal_Reg_Type__c = Label.Deal_Reg_Type_Teaming;            
            UPDATE deal;
            
            controller.dealRegId = deal.id;
            controller.dealReg = deal;
            controller.selectedOppId = opp.Id;
            TriggerHandler.bypass('AccountTriggerHandler');
            TriggerHandler.bypass('OpportunityTriggerHandler'); 
            controller.associateDealToOpp();
            
            deal.Deal_Reg_Type__c = Label.Deal_Reg_Type_Teaming;
            UPDATE deal;
            
            controller.dealRegId = deal.id;
            controller.dealReg = deal;
            
            controller.selectedOppId = opp.Id;
            //controller.associateDealToOpp();
            //controller.convertDealReg();
        }
        
        Test.stopTest();
    }
    
    @IsTest static void testConversionWithoutContactAndLead1() {
        
        User coreSales = [Select id from user where profile.Name = 'Core Sales' and IsActive=True limit 1];
        User adminUser = [Select id from user where profile.Name = 'System Administrator' and IsActive=True limit 1];
        
        Account partnerAcc1 = [Select id from Account where Name = 'Test Data' limit 1];
        Account partnerAcc2 = [Select id from Account where Name = 'Test partner' limit 1];
        Opportunity opp = [Select id from Opportunity where Name = 'Test Opp' limit 1];
        Lead le = [Select id from Lead limit 1];
        Contact con = [Select id from Contact limit 1];
        
        
        TriggerHandler.bypass('AccountTriggerHandler');
        TriggerHandler.bypass('OpportunityTriggerHandler');
        TriggerHandler.bypass('DealRegTriggerHelper');
        
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
        
        
        Deal_Reg__c deal = new Deal_Reg__c();
        deal.End_Customer_Contact_Name__c = 'Test';
        deal.End_Customer_Contact_Last_Name__c= 'Test';
        deal.End_Customer_Country__c = 'US';
        deal.End_Customer_Domain__c = 'abcd.com';
        deal.End_Customer_Email__c  = 'Test@abcd.com';
        deal.End_Customer_Name__c = 'ABC Inc';
        deal.End_Customer_Phone__c = '123456789';
        deal.End_Customer_State__c = 'US';
        deal.End_Customer_City__c = 'Texas';
        deal.End_Customer_Street_Address__c = 'Downtown';
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
        deal.Partner_Account__c = partnerAcc1.Id;
        deal.Source__c = 'Deal Reg';
        deal.Status__c = 'Submitted';
        deal.Account_Manager__c = userInfo.getuserId();
        //deal.AW_Partner_Intent__c = 'Interested';
        //deal.POV_Partner_Intent__c = 'Interested';
        insert deal;
        //deal.OwnerId = UserInfo.getUserId();
        //update deal;
        
        System.runAs(adminUser){ 
            
            PageReference pageRef = Page.DealRegConversion;
            Test.setCurrentPage(pageRef);
            pageRef.getParameters().put('id', String.valueOf(deal.Id));
            DealRegConversionControllerCPQ controller = new DealRegConversionControllerCPQ();
            
            controller.dealRegId = deal.id;
            controller.dealReg = deal;
            
            
            TriggerHandler.bypass('AccountTriggerHandler');
            TriggerHandler.bypass('OpportunityTriggerHandler');
            TriggerHandler.bypass('DealRegTriggerHelper');
            
            
            controller.selectedOppId = NULL;
            controller.convertDealReg();
            
            Test.startTest();
            
            controller.dealRegId = deal.id;
            controller.dealReg = deal;
            
            controller.selectedOppId = opp.Id;
            controller.associateDealToOpp();
            
            controller.selectedOppId = '';
            controller.associateDealToOpp();
            
            Test.stopTest();
        }
    }
    
    @IsTest static void testConversionWithContactAndLead() {
        User adminUser = [Select id from user where profile.Name = 'System Administrator' and IsActive=True limit 1];
        TriggerHandler.bypass('AccountTriggerHandler');
        TriggerHandler.bypass('OpportunityTriggerHandler');
        
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
        
        
        Account acc1 = new account();
        Acc1.Name = 'Test partner';
        acc1.Domain__c = 'partner.com';
        acc1.Is_Federal_Account_Sync__c=true;
        acc1.BillingCountry = 'India';
        acc1.BillingCity = 'Delhi';
        acc1.BillingStreet = 'India Gate';
        accInsertList.add(acc1);
        
        insert accInsertList;
        
        List<Partner_Incentive__c> piList = new List<Partner_Incentive__c>();
        piList.add((SB_TestCPQDataUtility.createPartnerIncentive(1,accInsertList[0].Id,true,system.today()+60,system.today()-30,'Traditional','MSP'))[0]);
        piList.add((SB_TestCPQDataUtility.createPartnerIncentive(1,accInsertList[0].Id,true,system.today(),system.today(),'Summit - Federal','MSP'))[1]);
        piList[1].Default__c=true;
        insert piList;
        
        Contact con = new Contact();
        con.firstName = 'Jhon';
        con.LastName = 'Smith';
        con.email = 'mike@abcd.com';
        con.AccountId = accInsertList[0].Id;
        insert con;
        
        Lead le = new Lead();
        le.Company = 'test Company';
        le.FirstName = 'Test';
        le.LastName = 'Name';
        le.Email = 'test@abc.com';
        le.Street = '2100 Woodward Ave';
        le.City = 'Detroit';
        le.State = 'MI';
        le.PostalCode = '48201';
        le.Country = 'US';
        insert le;
        
        
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
        deal.Expected_Close_Date__c = system.today() + 30;
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
        deal.Account_Manager__c = userInfo.getuserId();
        deal.AW_Partner_Intent__c = 'Interested';
        deal.POV_Partner_Intent__c = 'Interested';
        deal.End_Customer_Street_Address__c = 'India Gate';
        deal.End_Customer_Country__c = 'India';
        deal.End_Customer_City__c = 'Delhi';
        insert deal;
        deal.OwnerId = userInfo.getuserId();
        deal.Account_Manager__c = userInfo.getuserId();
        update deal;
        
        Opportunity opp = new Opportunity();
        Opp.Name = 'Test Opp';
        Opp.CloseDate = system.Today() + 30;
        Opp.AccountId = accInsertList[0].Id;
        Opp.Amount = 123456;
        opp.StageName = Label.Stage_1_Alignment/*'1 - Qualified and Budgeted'*/;
        opp.Deal_Reg__c = deal.Id;
        Opp.Associated_Deal_Registrations__c = deal.Name;
        insert Opp;
        opp.OwnerId = userInfo.getuserId();
        update opp;
        
        Test.startTest();        
        
        TriggerHandler.bypass('AccountTriggerHandler');
        TriggerHandler.bypass('OpportunityTriggerHandler');
        
        
        PageReference pageRef = Page.DealRegConversion;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('id', String.valueOf(deal.Id));
        DealRegConversionControllerCPQ controller = new DealRegConversionControllerCPQ();
        controller.dealRegId = deal.id;
        //controller.dealReg = deal;
        controller.opportunityConversion();
        controller.selectedOppId = opp.Id;
        //controller.associateDealToOpp();
        
        deal.Deal_Reg_Type__c = Label.Deal_Reg_Type_Teaming;
        
        controller.dealRegId = deal.id;
        controller.dealReg = deal;
        
        controller.selectedOppId = opp.Id;
        controller.associateDealToOpp();
        
        //controller.dealRegId = deal.id;
        //controller.dealReg = deal;
        
        
        deal.Contact__c = con.Id;
        TriggerHandler.bypass('AccountTriggerHandler');
        TriggerHandler.bypass('OpportunityTriggerHandler');
        UPDATE deal;
        
        //controller.dealRegId = deal.id;
        controller.dealReg = deal;
        controller.leadConversionWithAccAndOpp(le.id, acc1.Id, opp.Id); 
        controller.dealRegId = deal.id;
        controller.markNonPrimaryResellerPartner(); 
        
        Test.stopTest();
    }
    
}