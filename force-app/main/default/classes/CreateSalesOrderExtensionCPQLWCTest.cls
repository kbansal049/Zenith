@isTest
public class CreateSalesOrderExtensionCPQLWCTest {
    
    private static List<Account> accList = new List<Account>();
    private static PriceBook2 customPb;
    private static List<PricebookEntry> customPbEntryList=new List<PricebookEntry>();
    private static List<Product2> productList=new List<Product2>();
    private static List<Opportunity> oppList = new List<Opportunity>();
    private static SBQQ__Quote__c quoteRec;
    private static List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>();
    private static List<Partner_Incentive__c> piList = new List<Partner_Incentive__c>();
    private static List<SBQQ__Subscription__c> subscriptionList = new List<SBQQ__Subscription__c>();
    private static Contract contractRec;
    private static String oppClose = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('New_Business_Close').getRecordTypeId();
    private static String oppRenewal = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Renewal_Opportunity').getRecordTypeId();
    private static String quoteRenewal = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByDeveloperName().get('Renewal').getRecordTypeId();
 
    @testSetup 
    static void createTestData(){    
        
        TriggerHandler.bypass('AccountTriggerHandler');
        TriggerHandler.bypass('OpportunityTriggerHandler');
        
        TriggerUtility.SkipAccTriggerExecuted();
        TriggerUtility.updateSENameFromAccountExecuted();
        TriggerUtility.prospectTypeUpdExecuted();
        triggerUtility.contactPatchManagerExecuted();
        triggerUtility.accTerritoryPatchExecuted();
        triggerUtility.oppPatchManagerAfterInsertExecuted();
        triggerUtility.oppPatchManagerAfterUpdateExecuted();
        TriggerUtility.createAnnualBreakdownLinesExecuted();
        
        
        List<SKUs_Referred_in_Renewal_Upsell_NS_Calc__c> skuscs = new List<SKUs_Referred_in_Renewal_Upsell_NS_Calc__c>();
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
        SKUs_Referred_in_Renewal_Upsell_NS_Calc__c rec11 = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c(name='ZPA_Deployment_SKUs1', SKU_Codes__c = 'ZCES-PRO-SVC-CUST;ZCES-PQR');
        SKUs_Referred_in_Renewal_Upsell_NS_Calc__c rec12 = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c(name='ZPA_Contract_Date', SKU_Codes__c = 'ZCES-PRO-SVC-CUST;ZCES-ABC');
        SKUs_Referred_in_Renewal_Upsell_NS_Calc__c rec16 = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c(name='ZIA_Contract_Date', SKU_Codes__c = 'ZCES-PRO-SVC-CUST;ZCES-ABE');
        SKUs_Referred_in_Renewal_Upsell_NS_Calc__c rec13 = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c(name='ZIA_Contract_Date1', SKU_Codes__c = 'ZCES-PRO-SVC-CUST;ZCES-ABE');
        SKUs_Referred_in_Renewal_Upsell_NS_Calc__c rec14 = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c(name='Included_DAS_Package_SKUs1', SKU_Codes__c = 'ZCES-DAS-PKG1;ZCES-DAS-PKG2;ZCES-DAS-PKG3;ZCES-DAS-PKG4;ZCES-DAS-PKG6;ZCES-DAS-PKG0;ZCES-DEP-ADV;ZCES-DEP-ENT;ZCES-DEP-ENTPLUS;ZCES-DEP-ESS;ZCES-PRO-HEALTH;ZCES-DAS-FED1;ZCES-DAS-FED2;ZCES-DAS-FED3');
        SKUs_Referred_in_Renewal_Upsell_NS_Calc__c rec15 = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c(name='Included_DAS_Package_SKUs2', SKU_Codes__c = 'ZCES-PRO-SVC;ZCES-PRO-OPTADV;ZCES-PRO-OPTESS;ZCES-PRO-DZX;ZCES-PRO-OPTENT;ZCES-PRO-POL-PRE;ZCES-PRO-PMI-PRE;ZCES-PRO-SVC-CUST');
        SKUs_Referred_in_Renewal_Upsell_NS_Calc__c rec17 = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c(name='ZDX_Contract_Date', SKU_Codes__c = 'ZPA-BBA;ZPA-BUS;ZPA-ENT;ZPA-PRO;ZPA-PRO-LU;ZPA-BUS-LU;ZPA-BUS-EDITION;ZPA-PRO-EDITION;ZPA-BUS-EDITION-LU;ZIA-PRO-EDITION-LU;ZPA-TRANS-EDITION');
        
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
        skuscs.add(rec12);
        skuscs.add(rec13);
        skuscs.add(rec14);
        skuscs.add(rec15);
        skuscs.add(rec16);
        skuscs.add(rec17);
        insert skuscs;
        
        
        Skip_Triggers_User_Based__c sk = new Skip_Triggers_User_Based__c();
        sk.SetupOwnerId = userInfo.getUserId();
        sk.Object_s_to_skip__c = 'Account;Opportunity;OpportunitySplit';
        insert sk;
        
        
        
        accList = (SB_TestCPQDataUtility.createAccount(3));
        accList[0].Domain__c = 'testAccount1.com';
        accList[0].Asset_SKU_Codes__c='ZSEC-ATP,ZIA-TRANS-EDITION,ZSEC-WEB-ABA,ZSEC-WEB-ABA,ZSEC-ATP';
        accList[1].Asset_SKU_Codes__c='ZIA-ELA-BUNDLE,ZIA-TRANS-EDITION,ZSEC-WEB-ABA,ZSEC-WEB-ABA,ZSEC-ATP';
        accList[2].Asset_SKU_Codes__c='ZSEC-ATP,ZIA-TRANS-EDITION,ZSEC-WEB-ABA,ZSEC-WEB-ABA,ZSEC-ATP';
        insert accList;
        
        //Contact con = SB_TestCPQDataUtility.createContact(1,accList[0].Id)[0];
        //insert con;
        
        piList.add((SB_TestCPQDataUtility.createPartnerIncentive(1,accList[1].Id,true,system.today(),system.today(),'Traditional','MSP'))[0]);
        piList.add((SB_TestCPQDataUtility.createPartnerIncentive(1,accList[1].Id,true,system.today()+365,system.today()-30,'Summit - Discount','MSP'))[1]);
        piList[1].Default__c=true;
        piList[1].Partner_Role__c='Distributor';
        piList[0].Partner_Role__c='Distributor';
        insert piList;
        
        productList = (SB_TestCPQDataUtility.createProduct(4,'Zscaler Internet Access','ZIA-','Renewable','Per User Per Year'));
        productList[0].ProductCode = 'ZIA-SVC-EDGE-3';
        productList[1].ProductCode = 'ZCES-SUP-PREM';
        productList[0].Pricing_Meter__c = '';
        productList[0].SKU_Type__c='PRE';
        productList[0].Zscaler_Product_Family__c = 'ZIA';
        productList[1].Zscaler_Product_Family__c = 'ZIA';
        productList[2].Zscaler_Product_Family__c = 'ZPA';
        productList[0].Product_Family__c='Bundle Platforms';
        productList[1].Product_Family__c='Zscaler Internet Access';
        productList[2].Product_Family__c='Zscaler Private Access';
        productList[3].Product_Family__c='Pre SKUs';
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
        renewalOpp.Primary_Competitor__c = 'None';	
        renewalOpp.Secondary_Competitors__c='None';	
        insert renewalOpp;	
                
       
        
        
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
        SBQQ.TriggerControl.disable();        
        insert quoteRec;
        
        renewalOpp.SBQQ__PrimaryQuote__c = quoteRec.id;
        update renewalOpp;
        
        Contract contractRec = (SB_TestCPQDataUtility.createContracts(String.valueOf(accList[1].Id), null, null,piList[0],1))[0];
        contractRec.Status = 'Draft';
        insert contractRec;  
        
        
        SBQQ.TriggerControl.enable();
        system.debug('2nd query'+limits.getQueries());
        List<SBQQ__Subscription__c> subscriptionList = SB_TestCPQDataUtility.createSubscriptions(contractRec,productList);
        subscriptionList[0].SBQQ__RenewalQuantity__c = 96;
        subscriptionList[1].SBQQ__RenewalQuantity__c = 96;
        subscriptionList[2].SBQQ__RenewalQuantity__c = 96;
        SBQQ.TriggerControl.disable();
        insert subscriptionList;
        
        Date qlDate = system.today() + (365*3);
        List<SBQQ__QuoteLine__c> renewalQL = new List<SBQQ__QuoteLine__c>();
        renewalQL = (SB_TestCPQDataUtility.createQuoteLine(4, quoteRec.Id, productList[0].Id, system.today(), qlDate,50));
        renewalQL[1].SBQQ__Product__c = productList[1].Id;
        renewalQL[2].SBQQ__Product__c = productList[2].Id;
        renewalQL[3].SBQQ__Product__c = productList[3].Id;
        renewalQL[0].SBQQ__Number__c = 1;
        renewalQL[1].SBQQ__Number__c = 2;
        renewalQL[2].SBQQ__Number__c = 3;
        renewalQL[3].SBQQ__Number__c = 4;
        insert renewalQL;
        
        renewalQL[0].SBQQ__Existing__c = true;
        renewalQL[1].SBQQ__RequiredBy__c = renewalQL[0].Id;
        renewalQL[2].SBQQ__RequiredBy__c = renewalQL[0].Id;
        renewalQL[3].SBQQ__RequiredBy__c = renewalQL[0].Id;
        update renewalQL;
        system.debug('renewalQL'+renewalQL);
        
        
        
        
        List<Upgrade_SKU_Mapping_NS_Integration__c> upgradecs = new List<Upgrade_SKU_Mapping_NS_Integration__c>();
        upgradecs.add(new Upgrade_SKU_Mapping_NS_Integration__c(Name = 'rec1', IsrenewalorUpsell__c ='renewalupsell', Matching_SKU_On_Cart__c ='ZIA-PRO-BUNDLE', Matching_SKU_On_IB__c ='ZSC-SIP'));
        insert upgradecs;
        
        
        Order o = new Order(name = 'Test Order 1', AccountId = accList[0].Id, Order_Date__c = date.today(), NS_Sales_Order_Number__c = 'S24867', EffectiveDate = date.today(), EndDate=date.today().adddays(200), Status = 'Draft', Location__c = 'Americas');
        insert o;
        
        
        List<Contract_Detail__c> contractDetailList = new List<Contract_Detail__c>();
        Contract_Detail__c contractDetail1 = new Contract_Detail__c();
        contractDetail1.Name = 'Migrate as is';
        contractDetail1.Account_Name__c = accList[0].Id;
        contractDetail1.Product_Name__c = productList[0].Id;
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
        
        List<Opportunity> oppList = [Select Id,accountId, Name, CloseDate, Amount, SBQQ__RenewedContract__c, Custom_Renewal__c from Opportunity]; 
       
        Opportunity opp = oppList[0];
        opp.Netsuite_Sales_Order_No__c = 'Test Order 1';
        opp.Type = 'Existing Customer (Renewal)';
        opp.SO_Creation_Date__c = System.Today();
        opp.Netsuite_Partner_Internal_ID_Override__c = '1234';
        opp.Netsuite_Primary_Partner_ID_Override__c = '1234';
        opp.Primary_Competitor__c = 'None';	
        opp.Secondary_Competitors__c='None';	
        update opp;
        
        test.starttest();
        CreateSalesOrderExtensionCPQLWC.getCustomOrder(oppList[0].id);
      
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
        
        List<Opportunity> oppList = [Select Id,accountId, Name,Netsuite_Customer_ID__c,Netsuite_Customer_ID_Override__c,Netsuite_Primary_Partner_ID__c,Netsuite_Primary_Partner_ID_Override__c, CloseDate, Amount, SBQQ__RenewedContract__c, Custom_Renewal__c from Opportunity]; 
        Opportunity opp = oppList[0];
        opp.Netsuite_Sales_Order_No__c = 'Test Order 1';
        opp.Type = 'Existing Customer (Add On)';
        opp.SO_Creation_Date__c = System.Today();
        opp.Netsuite_Partner_Internal_ID_Override__c = '1234';
        opp.Netsuite_Primary_Partner_ID_Override__c = '1234';
        update opp;
        
        SBQQ.TriggerControl.disable();
        
        SBQQ__Quote__c quoteRec = [Select id from SBQQ__Quote__c limit 1];
        quoteRec.Partner_Program__c = System.Label.Partner_Program_Traditional;
        quoteRec.Price_List__c = System.Label.FY21_SingleTier_PriceList;
        update quoteRec;
        
        
        test.starttest();
        
        CreateSalesOrderExtensionCPQLWC.getCustomOrder(oppList[0].id);
        
        List<CreateSalesOrderExtensionCPQLWC.NetSuiteCustomerInfoLine> coLineResult = CreateSalesOrderExtensionCPQLWC.getCustomerDetails(oppList[0]);
        CreateSalesOrderExtensionCPQLWC.NetSuiteCustomerInfoResponse coResp = new CreateSalesOrderExtensionCPQLWC.NetSuiteCustomerInfoResponse();
        coResp.customersandpartners = coLineResult;
        
        
        
        CreateSalesOrderExtensionCPQLWC.sendCreateSalesOrderRequest(oppList[0].id);
        
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
        TriggerUtility.createAnnualBreakdownLinesExecuted();
        
        List<Account> accList = [Select Id, Name from Account Limit 2];
        
        
        SBQQ__Quote__c quoteRec = [Select id from SBQQ__Quote__c limit 1];
        SBQQ.TriggerControl.disable();
        
        List<Opportunity> oppList = [Select Id,accountId, Name,Netsuite_Customer_ID__c,Netsuite_Customer_ID_Override__c,Netsuite_Primary_Partner_ID__c,Netsuite_Primary_Partner_ID_Override__c, CloseDate, Amount, SBQQ__RenewedContract__c, Custom_Renewal__c from Opportunity]; 
        Opportunity opp = oppList[0];
        
        opp.Deal_Reg_Margin__c = accList[0].id;
        opp.Deal_Reg_Partner_Teaming_Reseller__c = accList[1].id;
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
        
        opp.SBQQ__PrimaryQuote__c = quoteRec.id;
        update opp;
        
        List<Product2> prolist = new List<Product2>();
        Product2 ZSCProd =TestDatafactory_Zscaler.createProduct('test product 1','ZCES-SUP-PREM','Zscaler Products','Standalone', 'ZIA');
        Product2 ZSCProd1 =TestDatafactory_Zscaler.createProduct('test product 1','ZCES-PRO-SVC','Zscaler Products','Standalone', 'ZPA');
        Product2 ZSCProd2 =TestDatafactory_Zscaler.createProduct('test product 1','ZCR-BuyBack','Zscaler Products','Standalone', 'ZPA');
        Product2 ZSCProd3 =TestDatafactory_Zscaler.createProduct('test product 1','Z-ZPA-BuyBack','Zscaler Products','Standalone', 'ZPA');
        Product2 ZSCProd4 =TestDatafactory_Zscaler.createProduct('test product 1','Z-CREDIT','Zscaler Products','Standalone', 'ZPA');
        Product2 ZSCProd5 =TestDatafactory_Zscaler.createProduct('test product 1','ZCR-UPY4','Zscaler Products','Standalone', 'ZPA');
        Product2 ZSCProd6 =TestDatafactory_Zscaler.createProduct('test product 1','ZCR-UPY5','Zscaler Products','Standalone', 'ZPA');
        Product2 ZSCProd7 =TestDatafactory_Zscaler.createProduct('ZCES-PRO','ZCES-PRO','Zscaler Products','Standalone', 'ZPA');
        Product2 ZSCProd8 =TestDatafactory_Zscaler.createProduct('ZCES-DAS-PKG0','ZCES-DAS-PKG0','Zscaler Products','Standalone', 'ZPA');
        
        Product2 ZSCProd9 =TestDatafactory_Zscaler.createProduct('CFWCSB','Z-CFWCSB-PROMO','Zscaler Products','Standalone', 'ZPA');
        Product2 ZSCProd10 =TestDatafactory_Zscaler.createProduct('Z-CFWZPA-Credit','Z-CFWZPA-Credit','Zscaler Products','Standalone', 'ZPA');
        
        
        prolist.add(ZSCProd);prolist.add(ZSCProd1);
        prolist.add(ZSCProd2);prolist.add(ZSCProd3);
        prolist.add(ZSCProd4);prolist.add(ZSCProd7);
        prolist.add(ZSCProd5);prolist.add(ZSCProd6);
        prolist.add(ZSCProd8);
        prolist.add(ZSCProd9);prolist.add(ZSCProd10);
        insert prolist;
        
        
        
        
        List<SBQQ__QuoteLine__c> lstprplines = new List<SBQQ__QuoteLine__c>();
        SBQQ__QuoteLine__c proposalLine = new SBQQ__QuoteLine__c();
        proposalLine.SBQQ__Quote__c = quoteRec.Id;
        proposalLine.SBQQ__Product__c = ZSCProd.id;
        proposalLine.SBQQ__StartDate__c = Date.today();
        proposalLine.SBQQ__EndDate__c = Date.today().adddays(600);
        proposalLine.SBQQ__NetPrice__c = 1000.0;
        lstprplines.add(proposalLine);
        
        SBQQ__QuoteLine__c proposalLine1 = new SBQQ__QuoteLine__c();
        proposalLine1.SBQQ__Quote__c = quoteRec.Id;
        proposalLine1.SBQQ__Product__c = ZSCProd2.id;
        //proposalLine1.APTS_Product_Code__c = 'ZCR-BuyBack';
        lstprplines.add(proposalLine1);
        
        SBQQ__QuoteLine__c proposalLine2 = new SBQQ__QuoteLine__c();
        proposalLine2.SBQQ__Quote__c = quoteRec.Id;
        proposalLine2.SBQQ__Product__c = ZSCProd3.id;
        //proposalLine2.APTS_Product_Code__c = 'Z-ZPA-BuyBack';
        lstprplines.add(proposalLine2);
        
        SBQQ__QuoteLine__c proposalLine3 = new SBQQ__QuoteLine__c();
        proposalLine3.SBQQ__Quote__c = quoteRec.Id;
        proposalLine3.SBQQ__Product__c = ZSCProd4.id;
        //proposalLine3.APTS_Product_Code__c = 'Z-CREDIT';
        lstprplines.add(proposalLine3);
        
        SBQQ__QuoteLine__c proposalLine4 = new SBQQ__QuoteLine__c();
        proposalLine4.SBQQ__Quote__c = quoteRec.Id;
        proposalLine4.SBQQ__Product__c = ZSCProd5.id;
        //proposalLine4.APTS_Product_Code__c = 'ZCR-UPY4';
        proposalLine4.Term_after_Buyback__c = 48;
        proposalLine4.SBQQ__NetPrice__c = 125;
        lstprplines.add(proposalLine4);
        
        SBQQ__QuoteLine__c proposalLine5 = new SBQQ__QuoteLine__c();
        proposalLine5.SBQQ__Quote__c = quoteRec.Id;
        proposalLine5.SBQQ__Product__c = ZSCProd6.id;
        proposalLine5.SBQQ__NetPrice__c = 125;
        //proposalLine5.APTS_Product_Code__c = 'ZCR-UPY5';
        
        lstprplines.add(proposalLine5);
        
        SBQQ__QuoteLine__c proposalLine6 = new SBQQ__QuoteLine__c();
        proposalLine6.SBQQ__Quote__c = quoteRec.Id;
        proposalLine6.SBQQ__Product__c = ZSCProd7.id;
        proposalLine6.SBQQ__NetPrice__c = 125;
        lstprplines.add(proposalLine6);
        
        SBQQ__QuoteLine__c proposalLine7 = new SBQQ__QuoteLine__c();
        proposalLine7.SBQQ__Quote__c = quoteRec.Id;
        proposalLine7.SBQQ__Product__c = ZSCProd8.id;
        proposalLine7.SBQQ__NetPrice__c = 125;
        lstprplines.add(proposalLine7);
        
        
        SBQQ__QuoteLine__c proposalLine8 = new SBQQ__QuoteLine__c();
        proposalLine8.SBQQ__Quote__c = quoteRec.Id;
        proposalLine8.SBQQ__Product__c = ZSCProd9.id;
        proposalLine8.SBQQ__NetPrice__c = 125;
        lstprplines.add(proposalLine8);
        
        SBQQ__QuoteLine__c proposalLine9 = new SBQQ__QuoteLine__c();
        proposalLine9.SBQQ__Quote__c = quoteRec.Id;
        proposalLine9.SBQQ__Product__c = ZSCProd10.id;
        proposalLine9.SBQQ__NetPrice__c = 125;
        lstprplines.add(proposalLine9);
        TriggerUtility.createAnnualBreakdownLinesExecuted();
        insert lstprplines;
        
        
        
        test.starttest();
        CreateSalesOrderExtensionCPQLWC.CustomOrderWrapper cow  = CreateSalesOrderExtensionCPQLWC.getCustomOrder(opp.id);
        CreateSalesOrderExtensionCPQLWC.reCalculateACV(cow);
        cow.overrideBillToId = true;
        cow.overrideShipToId = true;
        cow.overridePartnerId = true;
        CreateSalesOrderExtensionCPQLWC.doReview(cow);
        CreateSalesOrderExtensionCPQLWC.doSubmit(cow);
        CreateSalesOrderExtensionCPQLWC.fillListWithoutInternalLines(cow);
        
        CreateSalesOrderExtensionCPQLWC.doesValidID(quoteRec.id);
        CreateSalesOrderExtensionCPQLWC.doesValidID('sjkd');
        
        CreateSalesOrderExtensionCPQLWC.codebooster();
        
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
    
}