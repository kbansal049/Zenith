@isTest
public class PODetailTriggerUtilityTest {
    
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
        sk.Object_s_to_skip__c = 'Account;Opportunity;OpportunitySplit;Apttus_Proposal__Proposal__c;SBQQ__Subscription__c';
        insert sk;
        
        //Inseret Custom settings
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
        SKUs_Referred_in_Renewal_Upsell_NS_Calc__c rec11 = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c(name='ZPA_Deployment_SKUs1', SKU_Codes__c = 'ZCES-PRO-SVC-CUST');
        SKUs_Referred_in_Renewal_Upsell_NS_Calc__c rec12 = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c(name='ZPA_Contract_Date', SKU_Codes__c = 'ZPA-BBA;ZPA-BUS;ZPA-ENT;ZPA-PRO;ZPA-PRO-LU;ZPA-BUS-LU;ZPA-BUS-EDITION;ZPA-PRO-EDITION;ZPA-BUS-EDITION-LU;ZIA-PRO-EDITION-LU;ZPA-TRANS-EDITION;ZS-WFA-BUS-EDITION');
        SKUs_Referred_in_Renewal_Upsell_NS_Calc__c rec13 = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c(name='ZIA_Contract_Date', SKU_Codes__c = 'ZSC-SIP;ZIA-PRO-BUNDLE;ZIA-BUS-BUNDLE;ZIA-TRANS-BUNDLE;ZCES-SUP-PREM;ZIA-ELA-BUNDLE;ZIA-PRO-BUNDLE-LU;ZIA-BUS-BUNDLE-LU;ZIA-TRANS-BUNDLE-LU;ZIA-ELA-BUNDLE-LU;ZSC-SIP-LOC;ZIA-SIP');
        SKUs_Referred_in_Renewal_Upsell_NS_Calc__c rec14 = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c(name='ZIA_Contract_Date1', SKU_Codes__c = 'ZS-WFA-BUS-EDITION');

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
        insert skuscs;
        
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
            insert pr;
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
        SBQQ.TriggerControl.disable();        
        insert quoteRec;
        
        renewalOpp.SBQQ__PrimaryQuote__c = quoteRec.id;
        update renewalOpp;
        
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
        
       

    }
    

     @isTest
    static void test1 () {
        test.starttest();
        TriggerUtility.SkipAccTriggerExecuted();
        TriggerUtility.SkipOppTriggerExecuted();
        TriggerUtility.prospectTypeUpdExecuted();
        triggerUtility.contactPatchManagerExecuted();
        triggerUtility.accTerritoryPatchExecuted();
        triggerUtility.oppPatchManagerAfterInsertExecuted();
        triggerUtility.oppPatchManagerAfterUpdateExecuted();
        TriggerUtility.ProspectEntitlementExecuted();
        
        List<Opportunity> oppList = [Select Id,accountId,SBQQ__PrimaryQuote__c,SBQQ__PrimaryQuote__r.name,Name, CloseDate, Amount, SBQQ__RenewedContract__c, Custom_Renewal__c from Opportunity]; 
        
        opportunity opp = oppList[0];
        
        opp.Netsuite_Sales_Order_No__c = 'Test Order 1';
        opp.Type = 'Existing Customer (Renewal)';
        opp.SO_Creation_Date__c = System.Today();
        opp.Netsuite_Partner_Internal_ID_Override__c = '1234';
        opp.Netsuite_Primary_Partner_ID_Override__c = '1234';
        update opp;  
        
        PO_Detail__c poDet = new PO_Detail__c();
        poDet.PO_Number__c = 'XYZZ';
        poDet.Source__c='EDI';
        poDet.Proposal_Quote_Number__c = opp.SBQQ__PrimaryQuote__r.name;
        insert poDet;
        
        PO_Detail__c poDet2 = new PO_Detail__c();
        poDet2.PO_Number__c = 'XYZZ';
        poDet2.Source__c='EDI';
        poDet2.Proposal_Quote_Number__c = opp.SBQQ__PrimaryQuote__r.name;
        insert poDet2;
        
        poDet = new PO_Detail__c();
        poDet.PO_Number__c = 'XYZZt';
        poDet.Source__c='EDI';
        poDet.Client_Name__c = 'Abc';
        poDet.Proposal_Quote_Number__c = opp.SBQQ__PrimaryQuote__r.name;
        insert poDet;
        
        poDet = new PO_Detail__c();
        poDet.PO_Number__c = 'XYZZt';
        poDet.Source__c='EDI';
        poDet.Client_Name__c = 'Abc';
        poDet.Proposal_Quote_Number__c = opp.SBQQ__PrimaryQuote__r.name;
        insert poDet;
      
        test.stoptest();
    }
}