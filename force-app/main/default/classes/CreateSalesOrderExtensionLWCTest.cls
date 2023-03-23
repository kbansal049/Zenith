@isTest
public class CreateSalesOrderExtensionLWCTest {
    
    
    public static Account acc;
    public static Account acc1;
    
    public static Opportunity opp;
   
    public static string newProposalId;
    public static string newcartId;
    public static string cartId;
    public static string prdId;
    public static List<Contract_Detail__c> contractDetailList;
    public static List<SKUs_Referred_in_Renewal_Upsell_NS_Calc__c> skuscs;
    public static List<Upgrade_SKU_Mapping_NS_Integration__c> upgradecs;
    
    static
    {
        TriggerUtility.SkipAccTriggerExecuted();
        TriggerUtility.updateSENameFromAccountExecuted();
        TriggerUtility.prospectTypeUpdExecuted();
        triggerUtility.contactPatchManagerExecuted();
        triggerUtility.accTerritoryPatchExecuted();
        triggerUtility.oppPatchManagerAfterInsertExecuted();
        triggerUtility.oppPatchManagerAfterUpdateExecuted();
        
        
        Skip_Triggers_User_Based__c sk = new Skip_Triggers_User_Based__c();
        sk.SetupOwnerId = userInfo.getUserId();
        sk.Object_s_to_skip__c = 'Account;Opportunity;OpportunitySplit';
        insert sk;
        
        
        
        insert TestDatafactory_Zscaler.liketolike();
        insert TestDatafactory_Zscaler.skusNSInteg();
        insert TestDatafactory_Zscaler.gettriggerswitchrecords(false);
        insert TestDatafactory_Zscaler.getstageforecastcategorymap();
        
        acc = APTS_TestUtil.createAccount ();
        acc1 = APTS_TestUtil.createAccount ();
        
        acc.NS_Vendor_ID__c = 'abc';
        update acc;
               
        Pricebook2 Pricebook=new Pricebook2(Name = 'Apttus Default Price Book');
        insert Pricebook;
      
        opp = APTS_TestUtil.createOpportunity (acc.Id,null);
    opp.Primary_Competitor__c = 'None';
    opp.Secondary_Competitors__c='None';
    update opp;

        ZscalerSetting__c setting = new ZscalerSetting__c(Name = 'NSSOUrl', Value__c = 'https://www.zscaler.test');
        insert setting;
        
        Partner testOpptyPartner = new Partner();
        testOpptyPartner.AccountToId = acc1.Id;
        testOpptyPartner.IsPrimary = true;
        testOpptyPartner.OpportunityId = opp.Id;
        //testOpptyPartner.Role = 'Vendor';
        insert testOpptyPartner;
        
        Order o = new Order(name = 'Test Order 1', AccountId = acc.Id, Order_Date__c = date.today(), NS_Sales_Order_Number__c = 'S24867', EffectiveDate = date.today(), EndDate=date.today().adddays(200), Status = 'Draft', Location__c = 'Americas');
        insert o;
        
        contractDetailList = new List<Contract_Detail__c>();
        Contract_Detail__c contractDetail1 = new Contract_Detail__c();
        contractDetail1.Name = 'Migrate as is';
        contractDetail1.Account_Name__c = acc.Id;
        contractDetail1.Product_Name__c = prdId ;
        contractDetail1.Start_Date__c = Date.Today();
        contractDetail1.End_Date__c = Date.Today() + 365;
        contractDetail1.Quantity__c = 100;
        contractDetail1.Amount_USD__c = 100009; 
        contractDetail1.Contract_No__c = '100';
        contractDetail1.MRR_USD__c = 100;
        contractDetail1.List_Price__c = 100;
        contractDetail1.Discount__c = 10;
        contractDetail1.Needs_to_Be_Migrated_to_Asset_Line__c = true;
        contractDetail1.Sales_Order__c = o.Id;
        contractDetail1.Product_SKU__c = 'ZCES-SUP-PREM'; 
        contractDetail1.Contract_Detail_Status__c = 'Active';
        contractDetail1.ARR_Finance__c = 100;
        contractDetailList.add(contractDetail1);
        
        
        
        insert contractDetailList;
        
        skuscs = new List<SKUs_Referred_in_Renewal_Upsell_NS_Calc__c>();
        SKUs_Referred_in_Renewal_Upsell_NS_Calc__c rec1 = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c(name='CFW_CSB_SKUs', SKU_Codes__c = 'ZFW-NG-WITH-LOG;ZSEC-WEB-ABA');
        SKUs_Referred_in_Renewal_Upsell_NS_Calc__c rec2 = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c(name='CFW_ZPA_SKUs', SKU_Codes__c = 'ZFW-NG-WITH-LOG;ZIA-TRANS-BUNDLE;ZIA-ELA-BUNDLE');
        SKUs_Referred_in_Renewal_Upsell_NS_Calc__c rec3 = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c(name='Credit_SKUs', SKU_Codes__c = 'ZCR-BuyBack;Z-ZPA-BuyBack;Z-CFWCSB-PROMO;Z-CFWZPA-Credit;Z-CREDIT');
        SKUs_Referred_in_Renewal_Upsell_NS_Calc__c rec4 = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c(name='One_Time_SKU', SKU_Codes__c = 'ZCES-PRO-SVC;ZCES-DAS-PKG0;ZCES-DAS-PKG1;ZCES-DAS-PKG2;ZCES-DAS-PKG3;ZCES-DAS-PKG6;ZCES-EDU-CREDIT;ZCES-EDU-LABCREDIT;ZCES-Onetime-ZPA-INT');
        SKUs_Referred_in_Renewal_Upsell_NS_Calc__c rec5 = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c(name='Recurring_SKU', SKU_Codes__c = 'ZCES-SUP-PREM;ZCES-SUP-PREM-SP;ZCES-SUP-TAMT;ZIA-BUS'); //Modified by Swathi: CR#1058
        SKUs_Referred_in_Renewal_Upsell_NS_Calc__c rec6 = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c(name='SKUs_not_To_ADD', SKU_Codes__c = 'ZCR-UPY4;ZCR-UPY5');
        SKUs_Referred_in_Renewal_Upsell_NS_Calc__c rec7 = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c(name='SKUs_to_SKIP_ACV', SKU_Codes__c = 'ZCR-BuyBack;Z-ZPA-BuyBack;Z-CFWCSB-PROMO;Z-CFWZPA-Credit;Z-CREDIT;ZCR-UPY4;ZCR-UPY5');
        SKUs_Referred_in_Renewal_Upsell_NS_Calc__c rec8 = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c(name='Uplift_SKUs', SKU_Codes__c = 'ZCR-UPY4;ZCR-UPY5');
        SKUs_Referred_in_Renewal_Upsell_NS_Calc__c rec9 = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c(name='ZPA_Deployment_SKUs', SKU_Codes__c = 'ZCES-PRO-SVC;ZCES-DAS-PKG0;ZCES-DAS-PKG1;ZCES-DAS-PKG2;ZCES-DAS-PKG3;ZCES-DAS-PKG6;ZCES-EDU-CREDIT;ZCES-EDU-LABCREDIT;');
        SKUs_Referred_in_Renewal_Upsell_NS_Calc__c rec10 = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c(name='One_Time_SKU1', SKU_Codes__c = 'ZCES-PRO-SVC-CUST');
        SKUs_Referred_in_Renewal_Upsell_NS_Calc__c rec11 = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c(name='ZPA_Deployment_SKUs1', SKU_Codes__c = 'ZCES-PRO-SVC-CUST');
        
        skuscs.add(rec1);
        skuscs.add(rec2);
        skuscs.add(rec3);
        skuscs.add(rec4);
        skuscs.add(rec5);
        skuscs.add(rec6);
        skuscs.add(rec7);
        skuscs.add(rec8);
        skuscs.add(rec9);
        skuscs.add(rec10);
        skuscs.add(rec11);
        insert skuscs;
        
        upgradecs = new List<Upgrade_SKU_Mapping_NS_Integration__c>();
        upgradecs.add(new Upgrade_SKU_Mapping_NS_Integration__c(Name = 'rec1', IsrenewalorUpsell__c ='renewalupsell', Matching_SKU_On_Cart__c ='ZIA-PRO-BUNDLE', Matching_SKU_On_IB__c ='ZSC-SIP'));
        insert upgradecs;
        
    }

  @isTest
    static void test1 (){
    test.startTest();
    CreateSalesOrderExtensionLWC.booster();
    test.stopTest();
  }

    @isTest
    static void test2 () {
        
        TriggerUtility.SkipAccTriggerExecuted();
        TriggerUtility.prospectTypeUpdExecuted();
        triggerUtility.contactPatchManagerExecuted();
        triggerUtility.accTerritoryPatchExecuted();
        triggerUtility.oppPatchManagerAfterInsertExecuted();
        triggerUtility.oppPatchManagerAfterUpdateExecuted();
        TriggerUtility.ProspectEntitlementExecuted();
       
        
        opp.Netsuite_Sales_Order_No__c = 'Test Order 1';
        update opp;
        
         Product2 ZSCProd =TestDatafactory_Zscaler.createProduct('test product 1','ZCES-SUP-PREM','Zscaler Products','Standalone', 'ZIA');
        insert ZSCProd;

    Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Finance v2' LIMIT 1];
        User usr = new User(LastName = 'test',
                            FirstName='test',
                            Alias = 'pbhar',
                            Email = 'test.test@asdf.com',
                            Username = 'test.test@asdf.com',
                            ProfileId = profileId.id,
                            TimeZoneSidKey = 'GMT',
                            LanguageLocaleKey = 'en_US',
                            EmailEncodingKey = 'UTF-8',
                            LocaleSidKey = 'en_US'
                           );
        insert usr;

        test.starttest();

    system.runAs(usr){
            CreateSalesOrderExtensionLWC.getCustomOrder(opp.id);
            
            List<Custom_order__c> coList = [Select id from Custom_Order__c where id = : opp.Custom_Order__c];
            delete coList;
            
            CreateSalesOrderExtensionLWC.getCustomOrder(opp.id);
        }

        test.stoptest();
    }
    
    
    @isTest
    static void test3 () {
        Test.setMock(HttpCalloutMock.class, new RestMock());
        TriggerUtility.prospectTypeUpdExecuted();
        triggerUtility.contactPatchManagerExecuted();
        triggerUtility.accTerritoryPatchExecuted();
        triggerUtility.oppPatchManagerAfterInsertExecuted();
        triggerUtility.oppPatchManagerAfterUpdateExecuted();

        opp.Type = 'New Business';
        opp.Netsuite_Primary_Partner_ID_Override__c = 'abdc';
        opp.Netsuite_Customer_ID_Override__c = 'xyz123';
        opp.Netsuite_AW_Partner_ID_Override__c = '452hd';
        opp.Netsuite_POV_Partner_ID_Override__c = 'sfdss';
        opp.Netsuite_FUL_Partner_ID_Override__c = 'qwqw';
        opp.Netsuite_DR_Partner_ID_Override__c = 'sadasd';
        opp.NS_DR_Teaming_Tech_Partner_ID_Override__c = 'qwww';
        opp.NS_DR_Teaming_Resell_Partner_ID_Override__c = 'tyty';
        opp.Netsuite_Sales_Order_No__c = 'Test Order 1';
        opp.SO_Creation_Date__c = System.Today();
        update opp;
        
        List<Product2> prolist = new List<Product2>();
        Product2 ZSCProd =TestDatafactory_Zscaler.createProduct('test product 1','ZCES-SUP-PREM','Zscaler Products','Standalone', 'ZIA');
        Product2 ZSCProd1 =TestDatafactory_Zscaler.createProduct('test product 1','ZCES-SUP-PREM','Zscaler Products','Standalone', 'ZPA');
        prolist.add(ZSCProd);prolist.add(ZSCProd1);
        insert prolist;

    Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Finance v2' LIMIT 1];
        User usr = new User(LastName = 'test',
                            FirstName='test',
                            Alias = 'pbhar',
                            Email = 'test.test@asdf.com',
                            Username = 'test.test@asdf.com',
                            ProfileId = profileId.id,
                            TimeZoneSidKey = 'GMT',
                            LanguageLocaleKey = 'en_US',
                            EmailEncodingKey = 'UTF-8',
                            LocaleSidKey = 'en_US'
                           );
        insert usr;
        
        test.starttest();

    system.runAs(usr){
        CreateSalesOrderExtensionLWC.CustomOrderWrapper cow  = CreateSalesOrderExtensionLWC.getCustomOrder(opp.id);
        CreateSalesOrderExtensionLWC.reCalculateACV(cow);
        CreateSalesOrderExtensionLWC.doReview(cow);
        CreateSalesOrderExtensionLWC.doSubmit(cow);
        }

        test.stoptest();
    }
   
    
    @isTest
    static void test4 () {
        
        Test.setMock(HttpCalloutMock.class, new RestMock());
        TriggerUtility.prospectTypeUpdExecuted();
        triggerUtility.contactPatchManagerExecuted();
        triggerUtility.accTerritoryPatchExecuted();
        triggerUtility.oppPatchManagerAfterInsertExecuted();
        triggerUtility.oppPatchManagerAfterUpdateExecuted();        
       
        opp.Netsuite_Sales_Order_No__c = 'Test Order 1';
        opp.Type = 'Existing Customer (Add On)';
        opp.SO_Creation_Date__c = System.Today();
        opp.Netsuite_Partner_Internal_ID_Override__c = '1234';
        opp.Netsuite_Primary_Partner_ID_Override__c = '1234';
        update opp;
        
        Product2 ZSCProd =TestDatafactory_Zscaler.createProduct('test product 1','ZCES-SUP-PREM','Zscaler Products','Standalone', 'ZPA');
        insert ZSCProd;        

    Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Finance v2' LIMIT 1];
        User usr = new User(LastName = 'test',
                            FirstName='test',
                            Alias = 'pbhar',
                            Email = 'test.test@asdf.com',
                            Username = 'test.test@asdf.com',
                            ProfileId = profileId.id,
                            TimeZoneSidKey = 'GMT',
                            LanguageLocaleKey = 'en_US',
                            EmailEncodingKey = 'UTF-8',
                            LocaleSidKey = 'en_US'
                           );
        insert usr;
        
        test.starttest();

    system.runAs(usr){
            List<CreateSalesOrderExtensionLWC.NetSuiteCustomerInfoLine> coLineResult = CreateSalesOrderExtensionLWC.getCustomerDetails(opp);
            CreateSalesOrderExtensionLWC.NetSuiteCustomerInfoResponse coResp = new CreateSalesOrderExtensionLWC.NetSuiteCustomerInfoResponse();
            coResp.response = coLineResult;
            
            
            CreateSalesOrderExtensionLWC.CustomOrderWrapper cow  = CreateSalesOrderExtensionLWC.getCustomOrder(opp.id);
            
            cow.requireSecPartner = true;
            cow.billToDetails = 'Test';
            cow.billToOverriddenDetails = 'Test';
            cow.shipToDetails = 'Test';
            cow.billToOverriddenDetails = 'Test';
            cow.shipToOverriddenDetails = 'Test';
            
            CreateSalesOrderExtensionLWC.reCalculateACV(cow);
            CreateSalesOrderExtensionLWC.doReview(cow);
            CreateSalesOrderExtensionLWC.doSubmit(cow);
        }

        test.stoptest();
    }
    
    @isTest
    static void test5 () {
        
        Test.setMock(HttpCalloutMock.class, new RestMockError());
        TriggerUtility.prospectTypeUpdExecuted();
        triggerUtility.contactPatchManagerExecuted();
        triggerUtility.accTerritoryPatchExecuted();
        triggerUtility.oppPatchManagerAfterInsertExecuted();
        triggerUtility.oppPatchManagerAfterUpdateExecuted();
        
        

        
        
        opp.Netsuite_Sales_Order_No__c = 'Test Order 1';
        opp.Type = 'Existing Customer (Add On)';
        opp.SO_Creation_Date__c = System.Today();
        opp.Netsuite_Partner_Internal_ID_Override__c = '1234';
        opp.Netsuite_Primary_Partner_ID_Override__c = '1234';
        update opp;
        
        test.starttest();
        List<CreateSalesOrderExtensionLWC.NetSuiteCustomerInfoLine> coLineResult = CreateSalesOrderExtensionLWC.getCustomerDetails(opp);
        CreateSalesOrderExtensionLWC.NetSuiteCustomerInfoResponse coResp = new CreateSalesOrderExtensionLWC.NetSuiteCustomerInfoResponse();
        coResp.response = coLineResult;
        
        CreateSalesOrderExtensionLWC.sendCreateSalesOrderRequest(opp.id);
        
        test.stoptest();
    }
    
    
    private class RestMock implements HttpCalloutMock {
        
        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = '[{"id" : 21026, "name" : "testCustomer", "entityId" : "123", "type" : "customer"},{"id": 4883, "name": "testCustomer1", "entityId" : "123", "type" : "customer"}]';
            
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }
    
     private class RestMockError implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = 'kjkjjkjk';
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(fullJson);
            res.setStatusCode(500);
            return res;
        }
    }
    //Added by Swathi:CR#1058 End
}