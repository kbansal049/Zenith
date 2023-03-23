@isTest
private class PSCreateEditControllerTest {
    
    private static List<Account> accList = new List<Account>();
    private static PriceBook2 customPb;
    private static List<PricebookEntry> customPbEntryList=new List<PricebookEntry>();
    private static List<Product2> productList=new List<Product2>();
    private static List<Opportunity> oppList = new List<Opportunity>();
    private static SBQQ__Quote__c quoteRec;
    private static List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>();
    private static List<Partner_Incentive__c> piList = new List<Partner_Incentive__c>();
    private static List<SBQQ__Subscription__c> subscriptionList = new List<SBQQ__Subscription__c>();
    
    private static String depRecordTypeId = (Schema.SObjectType.inspire1__Project__c.getRecordTypeInfosByName().get('Deployment Project') != null) ? Schema.SObjectType.inspire1__Project__c.getRecordTypeInfosByName().get('Deployment Project').getRecordTypeId() : Null;
    private static String oppClose = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('New_Business_Close').getRecordTypeId();
    private static String oppRenewal = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Renewal_Opportunity').getRecordTypeId();
    private static String quoteRenewal = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByDeveloperName().get('Renewal').getRecordTypeId();
    private static String professionalServicesRecordTypeId = Schema.SObjectType.Equipment_Request__c.getRecordTypeInfosByDeveloperName().get('Professional_Services').getRecordTypeId();
    
    @TestSetup
    private static void createTestData(){        
        TriggerUtility.SkipAccTriggerExecuted();
        TriggerUtility.SkipOppTriggerExecuted();
        TriggerUtility.updateSENameFromAccountExecuted();
        TriggerUtility.prospectTypeUpdExecuted();
        triggerUtility.contactPatchManagerExecuted();
        triggerUtility.accTerritoryPatchExecuted();
        triggerUtility.oppPatchManagerAfterInsertExecuted();
        triggerUtility.oppPatchManagerAfterUpdateExecuted();        
        
        Skip_Triggers_User_Based__c sk = new Skip_Triggers_User_Based__c();
        sk.SetupOwnerId = userInfo.getUserId();
        sk.Object_s_to_skip__c = 'Account;Opportunity;OpportunitySplit;Apttus_Proposal__Proposal__c';
        insert sk;
        
        API_Country_Mapping__c apiCountryMappingAmberRoad = new API_Country_Mapping__c();
        apiCountryMappingAmberRoad.Name = 'united states';
        apiCountryMappingAmberRoad.Amber_Road_Country_Name__c = 'UNITED STATES OF AMERICA';
        apiCountryMappingAmberRoad.Amber_Road_Country_Code__c = 'US';
        insert apiCountryMappingAmberRoad;
        
        API_States_Mapping__c apiStatesMappingAmberRoad = new API_States_Mapping__c();
        apiStatesMappingAmberRoad.Name = 'pennsylvania';
        apiStatesMappingAmberRoad.Amber_Road_State_Code__c = 'pa';
        insert apiStatesMappingAmberRoad;
        
        accList = (SB_TestCPQDataUtility.createAccount(3));
        accList[0].Domain__c = 'testAccount1.com';
        accList[0].Asset_SKU_Codes__c='ZSEC-ATP,ZIA-TRANS-EDITION,ZSEC-WEB-ABA,ZSEC-WEB-ABA,ZSEC-ATP';
        accList[1].Asset_SKU_Codes__c='ZIA-ELA-BUNDLE,ZIA-TRANS-EDITION,ZSEC-WEB-ABA,ZSEC-WEB-ABA,ZSEC-ATP';
        accList[2].Asset_SKU_Codes__c='ZSEC-ATP,ZIA-TRANS-EDITION,ZSEC-WEB-ABA,ZSEC-WEB-ABA,ZSEC-ATP';
        
        for (Account currentAccount : accList) {
            currentAccount.BillingState = 'pennsylvania';
        	currentAccount.BillingCountry = 'united states';
        }
        
        insert accList;
        
        Contact con = SB_TestCPQDataUtility.createContact(1,accList[0].Id)[0];
        insert con;
        
        piList.add((SB_TestCPQDataUtility.createPartnerIncentive(1,accList[1].Id,true,system.today(),system.today(),'Traditional','MSP'))[0]);
        piList.add((SB_TestCPQDataUtility.createPartnerIncentive(1,accList[1].Id,true,system.today()+365,system.today()-30,'Summit - Discount','MSP'))[1]);
        piList[1].Default__c=true;
        piList[1].Partner_Role__c='Distributor';
        piList[0].Partner_Role__c='Distributor';
        insert piList;
        
        productList = (SB_TestCPQDataUtility.createProduct(4,'Zscaler Internet Access','ZIA-','Renewable','Per User Per Year'));
        productList[0].ProductCode = 'ZIA-SVC-EDGE-3';
        productList[0].Pricing_Meter__c = '';
        productList[0].SKU_Type__c='PRE';
        productList[0].Product_Family__c='Bundle Platforms';
        productList[1].Product_Family__c='Zscaler Internet Access';
        productList[2].Product_Family__c='Zscaler Private Access';
        productList[3].Product_Family__c='Pre SKUs';
        
        productList[0].Zscaler_Product_Family__c = 'ZIA';
        productList[1].Zscaler_Product_Family__c = 'ZIA';
        productList[2].Zscaler_Product_Family__c = 'ZPA';
        productList[2].Zscaler_Product_Family__c = 'ZDX';
        insert productList;
        
        customPb = (SB_TestCPQDataUtility.createCustomPriceBooks(1))[0];
        insert customPb;
        
        PricebookEntry customPbEntry = new PricebookEntry();
        customPbEntryList.add((SB_TestCPQDataUtility.createPriceBookEntry(1,productList[1].Id,48))[0]);
        customPbEntryList.add((SB_TestCPQDataUtility.createPriceBookEntry(1,productList[2].Id,50))[1]);
        customPbEntryList.add((SB_TestCPQDataUtility.createPriceBookEntry(1,productList[3].Id,55))[2]);
        insert customPbEntryList;
        
        Opportunity renewalOpp = SB_TestCPQDataUtility.createOpportunity(1, 'TestOpp - Renewal', accList[0].Id)[0];
        renewalOpp.StageName = '4 - Impact Validation';
        renewalOpp.Primary_Partner_Program__c = Label.Partner_Program_Summit_Discount;
        renewalOpp.Primary_Reseller_Partner__c=accList[1].Id;
        renewalOpp.RecordTypeId = oppRenewal;
        renewalOpp.PS_SKU_System__c = 'ZCES-DEP-ENTPLUS';
        insert renewalOpp;
        
        List<Zscaler_Cloud_ID__c> ZSClIDlist = new List<Zscaler_Cloud_ID__c>();
        String ridZPA = Schema.getGlobalDescribe().get('Zscaler_Cloud_ID__c').getDescribe().getRecordTypeInfosByName().get('ZPA Cloud ID').getRecordTypeId();
        String ridZIA = Schema.getGlobalDescribe().get('Zscaler_Cloud_ID__c').getDescribe().getRecordTypeInfosByName().get('ZIA Cloud ID').getRecordTypeId();
        Zscaler_Cloud_ID__c ZSc1= new Zscaler_Cloud_ID__c(Name='Zscloud.net-3926test1',Account__c= accList[0].Id,NS_Org_ID__c='Zscloud.net-3926test1.beta',
                                                          Zscaler_Cloud_Domain__c='testacc.com.au.test1',
                                                          Org_Name__c='Test Account Org',Cloud_Type__c='ZIA',recordTypeId = ridZIA, 
                                                          ZPA_Enrolled_Users_L31D_Rollup__c = 1, ZPA_Enrolled_Users_L6M_Rollup__c= 1, ZPA_Enrolled_Users_L90D_Rollup__c= 1);
        ZSClIDlist.add(ZSc1);
        Zscaler_Cloud_ID__c ZSc2= new Zscaler_Cloud_ID__c(Name='Zscloud.net-3926test2',Account__c= accList[0].Id,
                                                          NS_Org_ID__c='Zscloud.net-3926test2.beta',Zscaler_Cloud_Domain__c='testacc.com.au.test2',
                                                          Org_Name__c='Test Account Org',Cloud_Type__c='ZPA', recordTypeId = ridZPA, 
                                                          ZPA_Enrolled_Users_L31D_Rollup__c = 1, ZPA_Enrolled_Users_L6M_Rollup__c= 1, ZPA_Enrolled_Users_L90D_Rollup__c= 1);
        ZSClIDlist.add(ZSc2);
        insert ZSClIDlist;
        
        
        Id prRecordTypeId = Schema.SObjectType.Provisioning_Request__c.getRecordTypeInfosByName().get('Zscaler Cloud Details').getRecordTypeId();
        Provisioning_Request__c pr = new Provisioning_Request__c();
        pr.Opportunity__c = renewalOpp.Id;
        pr.RecordTypeId = prRecordTypeId;
        pr.Account__c = accList[0].id;
        pr.Send_Initial_l__c = 'SE';
        pr.ZIA_Org_ID__c = ZSc1.id;
        pr.ZPA_Org_ID__c = ZSc2.id;
        pr.Preferred_Cloud__c = 'Zscaler.net';
        pr.SE__c = userinfo.getuserId();
        pr.Provisioning_Status__c = 'In Progress';
        try{
            //insert pr;
        }catch(Exception ex){   
        }
        
        Id erRecordTypeId = Schema.SObjectType.Equipment_Request__c.getRecordTypeInfosByDeveloperName().get('ZIA_Service_Edge_PZEN').getRecordTypeId();
        Equipment_Request__c er = new Equipment_Request__c();
        er.Approval_Status__c = 'Approved';
        er.RecordTypeId = erRecordTypeId;
        er.Opportunity__c = renewalOpp.Id;
        er.Localized_content__c = true;
        insert er;
        
        
        
        Opportunity_Partner__c OppPartner = new Opportunity_Partner__c(Is_Primary__c = false,Opportunity__c = renewalOpp.Id,Partner_Type__c = 'Reseller',Account__c = accList[0].Id);
        insert OppPartner;
        
        SBQQ__Quote__c quoteRec = SB_TestCPQDataUtility.createQuote(1, renewalOpp.Id, renewalOpp.AccountId, renewalOpp.Primary_Reseller_Partner__c,renewalOpp.Primary_Reseller_Partner__c,quoteRenewal)[0];
        quoteRec.Partner_Incentive__c = piList[1].Id;
        quoteRec.Partner_Program__c = Label.Partner_Program_Summit_Discount;
        quoteRec.Include_Value_Summary_Feature_Additions__c= true;
        quoteRec.Special_Terms__c='This is test terms';
        quoteRec.Include_Value_Summary_Feature_Additions__c = true;
        quoteRec.Include_Value_Summary_Feature_Additions__c =true;
        quoteRec.Include_Value_Summary_Feature_Additions__c  =true;
        quoteRec.SBQQ__partner__c=accList[0].id;
        quoteRec.Bill_to__c =accList[1].id;
        quoteRec.SBQQ__Type__c='Renewal';
        quoteRec.Line_Item_SKU_Approval__c ='ZPA-ZFED-MODERATE,ZCES-PRO-DZX,ZCES-PRO-SVC,ZCES-PRO-SVC,ZCES-DAS-PKG6,'+APTS_CONSTANTS.PROD_SKU_ZPA_PRO_LU+','+APTS_CONSTANTS.PROD_SKU_ZIA_PROBUNDLE_LU+','+APTS_CONSTANTS.PROD_SKU_ZPA_PRO_LU+','+APTS_CONSTANTS.PROD_SKU_ZIA_PROBUNDLE_LU+',ZCES-EDU-CREDIT,ZCES-PRO-OPTESS,ZCES-PRO-OPTADV,ZCES-DEP-ADV,ZCES-DEP-ENT,ZCES-DAS-PKG0,ZCR-BuyBack,ZCES-EDU-CREDIT,Z-Credit,ZIA-ELA-BUNDLE,ZIA-SANDBOX,ZSEC-WEB-ABA,ZSEC-WEB-ABA,ZIA-TRANS-EDITION,';
        quoteRec.SBQQ__BillingFrequency__c = 'Custom Schedule';
        quoteRec.ApprovalStatus__c ='Approved';
        quoteRec.SBQQ__Primary__c = true;
        quoteRec.Included_DAS_Package__c = 'ZCES-DEP-ENTPLUS';
        SBQQ.TriggerControl.disable();        
        insert quoteRec;
        
        renewalOpp.SBQQ__PrimaryQuote__c = quoteRec.id;
        update renewalOpp;
        
        //Account account = new Account(Name = 'Test Account', TAM_Email__c = 'abc@abc.com');
        //insert account;
        
        //Id accountId = account.Id;
        //Opportunity opportunity = new Opportunity(Name = 'Test Opportunity', CloseDate = Date.today() + 30, StageName = label.Stage_1_Alignment /*'1 - Qualified and Budgeted'*/, Type = 'New Business');
        //insert opportunity;
        
        Inspire1__Project__c IP = new Inspire1__Project__c();
        IP.name = 'Deployment project 1';
        IP.inspire1__Account__c=accList[1].Id;
        IP.inspire1__Project_Status__c='In Progress';
        IP.Action_Plan__c = 'Test Plan';
        IP.RecordTypeId = depRecordTypeId;
        IP.Primary_Customer_Contact__c = con.id;
        IP.Secondary_Customer_Contact__c = con.id;
        TimeZone tz = TimeZone.getTimeZone('America/Los_Angeles');
        String tzName = tz.getDisplayName();
        IP.inspire1__Timezone__c=tzName;
        insert IP;
        /*
        List<Equipment_Request__c> equipReqList = new List<Equipment_Request__c>();
        
        Equipment_Request__c equipReq1 = new Equipment_Request__c();
        equipReq1.Opportunity__c=renewalOpp.Id;
        equipReq1.Localized_content__c=true;
        equipReq1.RecordTypeId = professionalServicesRecordTypeId;
        equipReq1.Type__c = 'Early Engagement';
        equipReq1.Early_Engagement_Approval_Process_Status__c = 'Approval Process 1 (One Step Approval) - Submitted';
        equipReqList.add(equipReq1);
        
        Equipment_Request__c equipReq2 = new Equipment_Request__c();
        equipReq2.Opportunity__c=renewalOpp.Id;
        equipReq2.Localized_content__c=true;
        equipReq2.RecordTypeId = professionalServicesRecordTypeId;
        equipReq2.Type__c = 'Early Engagement';
        equipReq2.Early_Engagement_Approval_Process_Status__c = 'Approval Process 2 (Geo based approval) - Submitted';
        equipReqList.add(equipReq2);
        
        insert equipReqList;
        
        System.debug('equipReqList : ' + equipReqList);
        */
    }
    
    @isTest 
    static void getColumnDetailsTest1(){       
		String fieldSetName = 'ProfessionalServicesCreateEditLWC';
        String objectAPIName = 'Equipment_Request__c';
        Test.startTest();
        ProfessionalServicesCreateEditController.getColumnDetails(fieldSetName,objectAPIName);
        Test.stopTest();
    }
    
    @isTest 
    static void validateEarlyEngagementRequestTest1(){
        
        Opportunity oppRecord = [SELECT Id,Amount FROM Opportunity
                                WHERE Name = 'TestOpp - Renewal0'];
        System.debug('oppRecord : ' + oppRecord);
        Test.startTest();
        ProfessionalServicesCreateEditController.validateEarlyEngagementRequest(oppRecord.Id);
        ProfessionalServicesCreateEditController.FetchAcountNameFromOpportunity(oppRecord.Id);  //Added by Ayush Kangar As part of CR#4575
        Test.stopTest();
    }
    
    @isTest 
    static void validateEarlyEngagementRequestTest2(){ 
        Test.startTest();
        Account accountRec = new Account(Name = 'Test Account', TAM_Email__c = 'abc@abc.com', 
                                         BillingState = 'pennsylvania', BillingCountry = 'united states');
        
        insert accountRec;
        PriceBook2 customPb1 = (SB_TestCPQDataUtility.createCustomPriceBooks(1))[0];
        insert customPb1;

        Opportunity renewalOpp = SB_TestCPQDataUtility.createOpportunity(1, 'PS_SKU_BLANK', accountRec.Id)[0];
        renewalOpp.StageName = '4 - Impact Validation';
        renewalOpp.Primary_Partner_Program__c = Label.Partner_Program_Summit_Discount;
        renewalOpp.Primary_Reseller_Partner__c = accountRec.Id;
        renewalOpp.RecordTypeId = oppRenewal;
        insert renewalOpp;
        
        Opportunity oppRecord = [SELECT Id,Amount FROM Opportunity
                                WHERE Name = 'PS_SKU_BLANK0'];
        System.debug('oppRecord : ' + oppRecord);
        
        ProfessionalServicesCreateEditController.validateEarlyEngagementRequest(oppRecord.Id);
        Test.stopTest();
    }
    
    @isTest 
    static void validateEarlyEngagementRequestTest3(){ 
        Test.startTest();
        Account accountRec = new Account(Name = 'Test Account', TAM_Email__c = 'abc@abc.com', 
                                         BillingState = 'pennsylvania', BillingCountry = 'united states');
        insert accountRec;
        PriceBook2 customPb1 = (SB_TestCPQDataUtility.createCustomPriceBooks(1))[0];
        insert customPb1;
        
        Opportunity renewalOpp = SB_TestCPQDataUtility.createOpportunity(1, 'PS_SKU_NOT_BLANK',accountRec.Id)[0];
        renewalOpp.StageName = '4 - Impact Validation';
        renewalOpp.Primary_Partner_Program__c = Label.Partner_Program_Summit_Discount;
        renewalOpp.Primary_Reseller_Partner__c = accountRec.Id;
        renewalOpp.RecordTypeId = oppRenewal;
        renewalOpp.PS_SKU_System__c = 'ZCES-DEP-ENTPLUS';
        renewalOpp.Amount = 751000.00;
        insert renewalOpp;
        
        Opportunity oppRecord = [SELECT Id,Amount FROM Opportunity
                                WHERE Name = 'PS_SKU_NOT_BLANK0'];
        System.debug('oppRecord : ' + oppRecord);
        
        ProfessionalServicesCreateEditController.validateEarlyEngagementRequest(oppRecord.Id);
        Test.stopTest();
    }
    
    @isTest 
    static void validateEarlyEngagementRequestTest4(){
        Test.startTest();
        Opportunity renewalOpp = [SELECT Id,Amount,AccountId,Primary_Reseller_Partner__c FROM Opportunity
                                WHERE Name = 'TestOpp - Renewal0'];
        Account accountRec = new Account(Name = 'Test Account', TAM_Email__c = 'abc@abc.com', 
                                         BillingState = 'pennsylvania', BillingCountry = 'united states');
        insert accountRec;
        
        SBQQ__Quote__c quoteRec2 = SB_TestCPQDataUtility.createQuote(1, renewalOpp.Id, renewalOpp.AccountId, renewalOpp.Primary_Reseller_Partner__c,renewalOpp.Primary_Reseller_Partner__c,quoteRenewal)[0];
        quoteRec2.Include_Value_Summary_Feature_Additions__c= true;
        quoteRec2.Special_Terms__c='This is test terms';
        quoteRec2.Include_Value_Summary_Feature_Additions__c = true;
        quoteRec2.Include_Value_Summary_Feature_Additions__c =true;
        quoteRec2.Include_Value_Summary_Feature_Additions__c  =true;
        quoteRec2.SBQQ__partner__c=accountRec.id;
        quoteRec2.Bill_to__c =accountRec.id;
        quoteRec2.SBQQ__Type__c='Renewal';
        quoteRec2.Line_Item_SKU_Approval__c ='ZPA-ZFED-MODERATE,ZCES-PRO-DZX,ZCES-PRO-SVC,ZCES-PRO-SVC,ZCES-DAS-PKG6,'+APTS_CONSTANTS.PROD_SKU_ZPA_PRO_LU+','+APTS_CONSTANTS.PROD_SKU_ZIA_PROBUNDLE_LU+','+APTS_CONSTANTS.PROD_SKU_ZPA_PRO_LU+','+APTS_CONSTANTS.PROD_SKU_ZIA_PROBUNDLE_LU+',ZCES-EDU-CREDIT,ZCES-PRO-OPTESS,ZCES-PRO-OPTADV,ZCES-DEP-ADV,ZCES-DEP-ENT,ZCES-DAS-PKG0,ZCR-BuyBack,ZCES-EDU-CREDIT,Z-Credit,ZIA-ELA-BUNDLE,ZIA-SANDBOX,ZSEC-WEB-ABA,ZSEC-WEB-ABA,ZIA-TRANS-EDITION,';
        quoteRec2.SBQQ__BillingFrequency__c = 'Custom Schedule';
        quoteRec2.ApprovalStatus__c ='Approved';
        quoteRec2.SBQQ__Primary__c = true;
        quoteRec2.Included_DAS_Package__c = 'ZCES-DEP-ESS';
        SBQQ.TriggerControl.disable();        
        insert quoteRec2;
        
        renewalOpp.Amount = 751000.00;
        renewalOpp.SBQQ__PrimaryQuote__c = quoteRec2.id;
        update renewalOpp;
        
        List<Product2> products = (SB_TestCPQDataUtility.createProduct(4,'Zscaler Internet Access','ZIA-','Renewable','Per User Per Year'));
        products[0].ProductCode = 'ZCES-DEP-ESS';
        products[0].SKU_Type__c='PRE';
        products[0].Product_Family__c='Zscaler Internet Access';
        products[0].Zscaler_Product_Family__c = 'ZIA';
        insert products;
        
        SBQQ__QuoteLine__c q1 = new SBQQ__QuoteLine__c();
        Date qlDate = system.today() + (365*3);
        quoteLines = (SB_TestCPQDataUtility.createQuoteLine(1, quoteRec2.Id, products[0].Id, system.today(), qlDate,50));
        
        quoteLines[0].SBQQ__DefaultSubscriptionTerm__c = 2;
        quoteLines[0].ACV_New__c = 10000; 
        quoteLines[0].SBQQ__Product__c = products[0].Id;
        quoteLines[0].SBQQ__Quantity__c =5;
        quoteLines[0].SBQQ__Renewal__c = false;
        quoteLines[0].SBQQ__NetPrice__c = 35000;
        quoteLines[0].SBQQ__Existing__c = false;
        quoteLines[0].SBQQ__CarryoverLine__c = false;
        
        insert quoteLines;
        System.debug('oppRecord : ' + renewalOpp);
        
        ProfessionalServicesCreateEditController.validateEarlyEngagementRequest(renewalOpp.Id);
               
        Test.stopTest();
    }
	
    @isTest 
    static void validateEarlyEngagementRequestTest5(){
        Test.startTest();
        Opportunity renewalOpp = [SELECT Id,Amount,AccountId,Primary_Reseller_Partner__c FROM Opportunity
                                WHERE Name = 'TestOpp - Renewal0'];
        Account accountRec = new Account(Name = 'Test Account', TAM_Email__c = 'abc@abc.com', 
                                         BillingState = 'pennsylvania', BillingCountry = 'united states');
        insert accountRec;
            
        SBQQ__Quote__c quoteRec2 = SB_TestCPQDataUtility.createQuote(1, renewalOpp.Id, renewalOpp.AccountId, renewalOpp.Primary_Reseller_Partner__c,renewalOpp.Primary_Reseller_Partner__c,quoteRenewal)[0];
        quoteRec2.Include_Value_Summary_Feature_Additions__c= true;
        quoteRec2.Special_Terms__c='This is test terms';
        quoteRec2.Include_Value_Summary_Feature_Additions__c = true;
        quoteRec2.Include_Value_Summary_Feature_Additions__c =true;
        quoteRec2.Include_Value_Summary_Feature_Additions__c  =true;
        quoteRec2.SBQQ__partner__c=accountRec.id;
        quoteRec2.Bill_to__c =accountRec.id;
        quoteRec2.SBQQ__Type__c='Renewal';
        quoteRec2.Line_Item_SKU_Approval__c ='ZPA-ZFED-MODERATE,ZCES-PRO-DZX,ZCES-PRO-SVC,ZCES-PRO-SVC,ZCES-DAS-PKG6,'+APTS_CONSTANTS.PROD_SKU_ZPA_PRO_LU+','+APTS_CONSTANTS.PROD_SKU_ZIA_PROBUNDLE_LU+','+APTS_CONSTANTS.PROD_SKU_ZPA_PRO_LU+','+APTS_CONSTANTS.PROD_SKU_ZIA_PROBUNDLE_LU+',ZCES-EDU-CREDIT,ZCES-PRO-OPTESS,ZCES-PRO-OPTADV,ZCES-DEP-ADV,ZCES-DEP-ENT,ZCES-DAS-PKG0,ZCR-BuyBack,ZCES-EDU-CREDIT,Z-Credit,ZIA-ELA-BUNDLE,ZIA-SANDBOX,ZSEC-WEB-ABA,ZSEC-WEB-ABA,ZIA-TRANS-EDITION,';
        quoteRec2.SBQQ__BillingFrequency__c = 'Custom Schedule';
        quoteRec2.ApprovalStatus__c ='Approved';
        quoteRec2.SBQQ__Primary__c = true;
        quoteRec2.Included_DAS_Package__c = 'ZCES-DEP-ENTPLUS,ZCES-DEP-ENT';
        SBQQ.TriggerControl.disable();        
        insert quoteRec2;
        
        renewalOpp.Amount = 698000.00;
        renewalOpp.SBQQ__PrimaryQuote__c = quoteRec2.id;
        update renewalOpp;
        
        List<Product2> products = (SB_TestCPQDataUtility.createProduct(2,'Zscaler Internet Access','ZIA-','Renewable','Per User Per Year'));
        products[0].ProductCode = 'ZCES-DEP-ENT';
        products[0].SKU_Type__c='PRE';
        products[0].Product_Family__c='Zscaler Internet Access';
        products[0].Zscaler_Product_Family__c = 'ZIA';
        products[1].ProductCode = 'ZCES-DEP-ENT';
        products[1].SKU_Type__c='PRE';
        products[1].Product_Family__c='Zscaler Internet Access';
        products[1].Zscaler_Product_Family__c = 'ZIA';
        products[1].Product_Category_Subtype__c = 'Support';
        insert products;
        
        
        SBQQ__QuoteLine__c q1 = new SBQQ__QuoteLine__c();
        Date qlDate = system.today() + (365*3);
        quoteLines = (SB_TestCPQDataUtility.createQuoteLine(2, quoteRec2.Id, products[0].Id, system.today(), qlDate,50));
        
        quoteLines[0].SBQQ__DefaultSubscriptionTerm__c = 2;
        quoteLines[0].ACV_New__c = 10000; 
        quoteLines[0].SBQQ__Product__c = products[0].Id;
        quoteLines[0].SBQQ__Quantity__c =5;
        quoteLines[0].SBQQ__Renewal__c = false;
        quoteLines[0].SBQQ__NetPrice__c = 35000;
        quoteLines[0].SBQQ__Existing__c = false;
        quoteLines[0].SBQQ__CarryoverLine__c = false;
        
        quoteLines[1].SBQQ__Product__c = products[1].id;
        quoteLines[1].SBQQ__DefaultSubscriptionTerm__c = 2;
        quoteLines[1].ACV_New__c = 10000; 
        quoteLines[1].SBQQ__Product__c = products[0].Id;
        quoteLines[1].SBQQ__Quantity__c =5;
        quoteLines[1].SBQQ__Renewal__c = false;
        quoteLines[1].SBQQ__NetPrice__c = 300;
        quoteLines[1].SBQQ__Existing__c = false;
        quoteLines[1].SBQQ__CarryoverLine__c = false;
        insert quoteLines;
        
        System.debug('oppRecord : ' + renewalOpp);
        
        ProfessionalServicesCreateEditController.validateEarlyEngagementRequest(renewalOpp.Id);
               
        Test.stopTest();
    }
}