@isTest
private class Test_Equipment_RequestTrigger{
    
    @testSetup
    static void setup() {
        Triggers_Switch__c setting = new Triggers_Switch__c();
        setting.Name = 'Equipment_RequestTrigger';
        setting.Object_Name__c = 'Equipment_Request__c';
        setting.Execute__c = true;
        insert setting;
    }

    private static testMethod void test() {
        
        Contact ct = new Contact();
        ct.FirstName = 'test';
        ct.LastName = 'test';
        ct.Email = 'test@test.com';
        insert ct;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'test';
        opp.StageName = '4 - Impact Validation';
        opp.CloseDate = System.today();
        opp.ZIA_Use_Case__c = 'SD-WAN';
        insert opp;
        
        Id RecordTypeId = Schema.SObjectType.Equipment_Request__c.getRecordTypeInfosByName().get('Professional Services').getRecordTypeId();
        
        Equipment_Request__c er = new Equipment_Request__c();
        er.Opportunity__c = opp.Id;
        er.RecordTypeId = RecordTypeId;
        //er.Type__c = 'Federal';
        
        test.startTest();
        insert er;
        opp.Deployment_contact__c = ct.Id;
        //er.Type__c = 'Extensions';
        update er;
        delete er;
        undelete er;
        test.stopTest();
    }
    
    /*
    @isTest
    public static void test2() {
        List<Triggers_Switch__c> trlst = new List<Triggers_Switch__c>();
        Triggers_Switch__c tr1 = new Triggers_Switch__c(name = 'Execute_APTS_Proposal_Trigger', Execute__c = true);
        trlst.add(tr1);
        insert trlst;

        TriggerUtility.prospectTypeUpdExecuted();
        insert TestDatafactory_Zscaler.skusNSInteg();
        
       
        
        Account acc1 = APTS_TestUtil.creatAccount();
        TriggerUtility.prospectTypeUpdExecuted();
        Account acct = new Account(Name = 'Test Account 2', APTS_Platform_Subscription_End_Date__c = Date.today(), APTS_Asset_SKU__c = 'ZSC-SIP, ZSUITE-WEBBUS, ZCES-SUP-PREM', DAS_SKU__c = 'ZSC-SIP, ZSUITE-WEBBUS, ZCES-SUP-PREM', Asset_SKU_Codes__c = 'ZSC-SIP;ZSUITE-WEBBUS;Z-LOGFEED;ZMAN-WEB-BAND');
        insert acct;
        Account acct2 = new Account(Name = 'Test Account 3', APTS_Platform_Subscription_End_Date__c = Date.today(), APTS_Asset_SKU__c = 'ZSC-SIP, ZSUITE-WEBBUS, ZCES-SUP-PREM', DAS_SKU__c = 'ZSC-SIP, ZSUITE-WEBBUS, ZCES-SUP-PREM', Asset_SKU_Codes__c = 'ZSC-SIP;ZSUITE-WEBBUS;Z-LOGFEED;ZMAN-WEB-BAND');
        insert acct2;
    
        
        //Opportunity
        List<Opportunity> oppList = new List<Opportunity>();
        Opportunity testOppty2 = new Opportunity(Name = 'Test Opportunity', StageName = '5 - Procurement', closeDate = Date.today() + 10, Amount=300000 );
        testOppty2.AccountID = acct.Id;
        testOppty2.PriceBook2Id = Test.getStandardPricebookId();
        Opportunity testOppty1 = new Opportunity(Name = 'Test Opportunity', StageName = '4 - Impact Validation', closeDate = Date.today() + 10, Amount=300000 );
        testOppty1.AccountID = acct.Id;
        testOppty1.PriceBook2Id = Test.getStandardPricebookId();
        oppList.add(testOppty1);
        oppList.add(testOppty2);
        insert oppList;
        
        //Insert Opportunity Partner CR# 840
        List<Opportunity_Partner__c> oppyPartners = new List<Opportunity_Partner__c>();
        Opportunity_Partner__c oppResellerPartner = new Opportunity_Partner__c(Account__c=acct.id,Partner_Type__c='Reseller',Opportunity__c=testOppty2.id,Is_Primary__c=True);
        oppyPartners.add(oppResellerPartner);
        Opportunity_Partner__c oppResellerPartner2 = new Opportunity_Partner__c(Account__c=acct.id,Partner_Type__c='Reseller',Opportunity__c=testOppty1.id,Is_Primary__c=True);
        oppyPartners.add(oppResellerPartner2);
        insert oppyPartners;
        
        Test.startTest();
        //Insert Proposal CR# 840
        List<Apttus_Proposal__Proposal__c> ProposalList = new List<Apttus_Proposal__Proposal__c>();
        Apttus_Proposal__Proposal__c testProposal1 = new Apttus_Proposal__Proposal__c(Apttus_QPConfig__PONumber__c = 'Test Proposal 1',Apttus_QPConfig__ConfigurationFinalizedDate__c = Date.today(),Apttus_Proposal__Opportunity__c = testOppty1.Id,Apttus_QPConfig__BillToAccountId__c = acct.Id,
                                                                                      RecordTypeID = Schema.SObjectType.Apttus_Proposal__Proposal__c.getRecordTypeInfosByName().get('Upsell').getRecordTypeId(),APTS_Billing_Frequency__c='Annual',Apttus_Proposal__Account__c = acct.Id,
                                                                                      Apttus_Proposal__Approval_Stage__c = 'Denied',Apttus_Proposal__ExpectedStartDate__c = Date.today().addDays(-180),Apttus_Proposal__ExpectedEndDate__c = Date.today(),
                                                                                      Apttus_Proposal__Primary__c = true,Apttus_Proposal__Valid_Until_Date__c = Date.today(),Apttus_QPConfig__ShipToAccountId__c = acct.Id,Distributor__c = acct.id,
                                                                                     Line_Item_SKU__c='Z-O365-PRE',Approved_Z_O365_PRE__c=False,Included_DAS_Package__c='ZIA-ISO-5-PRE,Z-O365-PRE,ZIA-SVC-RI-2-PRE');
        ProposalList.add(testProposal1);
        Apttus_Proposal__Proposal__c testProposal2 = new Apttus_Proposal__Proposal__c(Apttus_QPConfig__PONumber__c = 'Test Proposal 2',Apttus_QPConfig__ConfigurationFinalizedDate__c = Date.today(),Apttus_Proposal__Opportunity__c = testOppty2.Id,Apttus_QPConfig__BillToAccountId__c = acct.Id,
                                                                                      RecordTypeID = Schema.SObjectType.Apttus_Proposal__Proposal__c.getRecordTypeInfosByName().get('Upsell').getRecordTypeId(),APTS_Billing_Frequency__c='Annual',Apttus_Proposal__Account__c = acct.Id,
                                                                                      Apttus_Proposal__Approval_Stage__c = 'Denied',Apttus_Proposal__ExpectedStartDate__c = Date.today().addDays(-180),Apttus_Proposal__ExpectedEndDate__c = Date.today(),
                                                                                      Apttus_Proposal__Primary__c = true,Apttus_Proposal__Valid_Until_Date__c = Date.today(),Apttus_QPConfig__ShipToAccountId__c = acct.Id,Distributor__c = acct.id,
                                                                                     Line_Item_SKU__c='Z-O365-PRE',Approved_Z_O365_PRE__c=False,Included_DAS_Package__c='ZIA-ISO-5-PRE,Z-O365-PRE,ZIA-SVC-RI-2-PRE');
        ProposalList.add(testProposal2);
        
        Insert ProposalList;
        
        Id RecordTypeId = Schema.SObjectType.Equipment_Request__c.getRecordTypeInfosByName().get('Professional Services').getRecordTypeId();
        
        List<Equipment_Request__c> ers = new List<Equipment_Request__c>();
        Equipment_Request__c er = new Equipment_Request__c();
        er.Opportunity__c = testOppty1.Id;
        er.RecordTypeId = RecordTypeId;
        er.Type__c = 'Early Engagement';
        ers.add(er);
        Equipment_Request__c er2 = new Equipment_Request__c();
        er2.Opportunity__c = testOppty2.Id;
        er2.RecordTypeId = RecordTypeId;
        er2.Type__c = 'Early Engagement';
        ers.add(er2);
        
        insert ers;
        
        Test.stopTest();
    }
    
    @isTest
    public static void test3() {
        try{
            Id caviumcardER = Schema.SObjectType.Equipment_Request__c.getRecordTypeInfosByName().get('Professional Services').getRecordTypeId();
            Test.startTest();
            //Admin Entries
            Apttus__APTS_Admin__c adminPriceBook = new Apttus__APTS_Admin__c(Name = 'APTS_DefaultPriceBook', Apttus__Value__c = 'Apttus Default Price Book');
            Apttus__APTS_Admin__c adminPriceList = new Apttus__APTS_Admin__c(Name = 'APTS_DefaultPriceList', Apttus__Value__c = 'ZScaler Price List');
            insert adminPriceBook;
            insert adminPriceList;
            Account account = new Account(Name = 'Test Account');
            insert account;
            Id accountId = account.Id;
            
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
            deal.Partner_Account__c = accountId;
            deal.Source__c = 'Deal Reg';
            deal.Status__c = 'Submitted';
            insert deal;
            
            Opportunity opportunity = new Opportunity(AccountId = account.id, PriceBook2Id=Test.getStandardPricebookId(), Name = 'Test Opportunity', CloseDate = Date.today() + 30, StageName = '4 - Impact Validation', Type = 'New Business', ZIA_Use_Case__c = 'SD-WAN');
            insert opportunity;
        
            //Insert Opportunity Partner CR# 840
            List<Opportunity_Partner__c> oppyPartners = new List<Opportunity_Partner__c>();
            Opportunity_Partner__c oppResellerPartner = new Opportunity_Partner__c(Account__c=account.id,Partner_Type__c='Reseller',Opportunity__c=opportunity.id,Is_Primary__c=True);
            oppyPartners.add(oppResellerPartner);
            Opportunity_Partner__c oppResellerPartner2 = new Opportunity_Partner__c(Account__c=account.id,Partner_Type__c='Reseller',Opportunity__c=opportunity.id,Is_Primary__c=True);
            oppyPartners.add(oppResellerPartner2);
            insert oppyPartners;
            
            List<Apttus_Proposal__Proposal__c> ProposalList = new List<Apttus_Proposal__Proposal__c>();
            Apttus_Proposal__Proposal__c testProposal1 = new Apttus_Proposal__Proposal__c(Apttus_QPConfig__PONumber__c = 'Test Proposal 1',Apttus_QPConfig__ConfigurationFinalizedDate__c = Date.today(),Apttus_Proposal__Opportunity__c = opportunity.Id,Apttus_QPConfig__BillToAccountId__c = account.Id,
                                                                                            RecordTypeID = Schema.SObjectType.Apttus_Proposal__Proposal__c.getRecordTypeInfosByName().get('Upsell').getRecordTypeId(),APTS_Billing_Frequency__c='Annual',Apttus_Proposal__Account__c = account.Id,
                                                                                            Apttus_Proposal__Approval_Stage__c = 'Denied',Apttus_Proposal__ExpectedStartDate__c = Date.today().addDays(-180),Apttus_Proposal__ExpectedEndDate__c = Date.today(),
                                                                                            Apttus_Proposal__Primary__c = true,Apttus_Proposal__Valid_Until_Date__c = Date.today(),Apttus_QPConfig__ShipToAccountId__c = account.Id,Distributor__c = account.id,
                                                                                            Line_Item_SKU__c='Z-O365-PRE',Approved_Z_O365_PRE__c=False,Included_DAS_Package__c='ZIA-ISO-5-PRE,Z-O365-PRE,ZIA-SVC-RI-2-PRE,ZCES-DEP-ESS');
            ProposalList.add(testProposal1);
            Apttus_Proposal__Proposal__c testProposal2 = new Apttus_Proposal__Proposal__c(Apttus_QPConfig__PONumber__c = 'Test Proposal 2',Apttus_QPConfig__ConfigurationFinalizedDate__c = Date.today(),Apttus_Proposal__Opportunity__c = opportunity.Id,Apttus_QPConfig__BillToAccountId__c = account.Id,
                                                                                            RecordTypeID = Schema.SObjectType.Apttus_Proposal__Proposal__c.getRecordTypeInfosByName().get('Upsell').getRecordTypeId(),APTS_Billing_Frequency__c='Annual',Apttus_Proposal__Account__c = account.Id,
                                                                                            Apttus_Proposal__Approval_Stage__c = 'Denied',Apttus_Proposal__ExpectedStartDate__c = Date.today().addDays(-180),Apttus_Proposal__ExpectedEndDate__c = Date.today(),
                                                                                            Apttus_Proposal__Primary__c = true,Apttus_Proposal__Valid_Until_Date__c = Date.today(),Apttus_QPConfig__ShipToAccountId__c = account.Id,Distributor__c = account.id,
                                                                                            Line_Item_SKU__c='Z-O365-PRE',Approved_Z_O365_PRE__c=False,Included_DAS_Package__c='ZIA-ISO-5-PRE,Z-O365-PRE,ZIA-SVC-RI-2-PRE,ZCES-DEP-ESS');
            ProposalList.add(testProposal2);
            
            Insert ProposalList;

            
            Id RecordTypeId = Schema.SObjectType.Equipment_Request__c.getRecordTypeInfosByName().get('Professional Services').getRecordTypeId();
            
            List<Equipment_Request__c> ers = new List<Equipment_Request__c>();
            Equipment_Request__c er = new Equipment_Request__c();
            er.Opportunity__c = opportunity.Id;
            er.RecordTypeId = RecordTypeId;
            er.Type__c = 'Early Engagement';
            ers.add(er);
            Equipment_Request__c er2 = new Equipment_Request__c();
            er2.Opportunity__c = opportunity.Id;
            er2.RecordTypeId = RecordTypeId;
            er2.Type__c = 'Early Engagement';
            ers.add(er2);
            
            insert ers;
            
            Test.stopTest();  
        }
        catch(Exception e) {
            System.debug('Error Condition' + e.getMessage() + e.getLineNumber() + e.getStackTraceString());
        }
    }

    @isTest
    public static void test4() {
        try{
            Id caviumcardER = Schema.SObjectType.Equipment_Request__c.getRecordTypeInfosByName().get('Professional Services').getRecordTypeId();
            Test.startTest();
            //Admin Entries
            Apttus__APTS_Admin__c adminPriceBook = new Apttus__APTS_Admin__c(Name = 'APTS_DefaultPriceBook', Apttus__Value__c = 'Apttus Default Price Book');
            Apttus__APTS_Admin__c adminPriceList = new Apttus__APTS_Admin__c(Name = 'APTS_DefaultPriceList', Apttus__Value__c = 'ZScaler Price List');
            insert adminPriceBook;
            insert adminPriceList;
            Account account = new Account(Name = 'Test Account');
            insert account;
            Id accountId = account.Id;
            
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
            deal.Partner_Account__c = accountId;
            deal.Source__c = 'Deal Reg';
            deal.Status__c = 'Submitted';
            insert deal;
            
            Opportunity opportunity = new Opportunity(Name = 'Test Opportunity', CloseDate = Date.today() + 30, StageName = '3 - Sponsorship', Type = 'New Business', ZIA_Use_Case__c = 'SD-WAN');
            insert opportunity;
            
            Id RecordTypeId = Schema.SObjectType.Equipment_Request__c.getRecordTypeInfosByName().get('Professional Services').getRecordTypeId();
            
            List<Equipment_Request__c> ers = new List<Equipment_Request__c>();
            Equipment_Request__c er = new Equipment_Request__c();
            er.Opportunity__c = opportunity.Id;
            er.RecordTypeId = RecordTypeId;
            er.Type__c = 'Early Engagement';
            ers.add(er);
            Equipment_Request__c er2 = new Equipment_Request__c();
            er2.Opportunity__c = opportunity.Id;
            er2.RecordTypeId = RecordTypeId;
            er2.Type__c = 'Early Engagement';
            ers.add(er2);
            
            insert ers;
            
            Test.stopTest();  
        }
        catch(Exception e) {
            System.debug('Error Condition' + e.getMessage() + e.getLineNumber() + e.getStackTraceString());
        }
    }
	*/
    
}