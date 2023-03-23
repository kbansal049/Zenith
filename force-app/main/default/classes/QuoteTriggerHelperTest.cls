/**
* @description       : 
* @author            : ChangeMeIn@UserSettingsUnder.SFDoc
* @group             : 
* @last modified on  : 03-13-2023
* @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public class QuoteTriggerHelperTest {
    
    private static List<Account> accList = new List<Account>();
    private static PriceBook2 customPb;
    private static List<PricebookEntry> customPbEntryList=new List<PricebookEntry>();
    private static List<Product2> productList=new List<Product2>();
    private static List<Partner_Incentive__c> piList = new List<Partner_Incentive__c>();
    private static String RENEWAL='Renewal';
    private static String SUMMIT_DISC='Summit - Discount';
    private static String DISTRIBUTOR='Distributor';
    private static String BUNDLEPL='Bundle Platforms';
    private static String IMPVALID='4 - Impact Validation';
    private static String RESELLER='Reseller';
    private static String TESTTERM='This is test terms';
    private static String SKUAPPROVAL=',ZCES-EDU-CREDIT,ZCES-PRO-OPTESS,ZCES-PRO-OPTADV,ZCES-DEP-ADV,ZCES-DEP-ENT,ZCES-DAS-PKG0,ZCR-BuyBack,ZCES-EDU-CREDIT,Z-Credit,ZIA-ELA-BUNDLE,ZIA-SANDBOX,ZSEC-WEB-ABA,ZSEC-WEB-ABA,ZIA-TRANS-EDITION,';
    private static String SKUAPPROVAL2='ZPA-ZFED-MODERATE,ZCES-PRO-DZX,ZCES-PRO-SVC,ZCES-PRO-SVC,ZCES-DAS-PKG6,';
    private static String CUSTSCHEDULE='Custom Schedule';
    private static String NEWBUS='New Business';
    private static String TESTOPPNB='TestOpp - NB'; 
    private static String TESTOPPUPSELL='TestOpp - Upsell';
    private static String STATUSNEW ='New';
    private static String oppRenewal = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Renewal_Opportunity').getRecordTypeId();
    private static String quoteRenewal = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByDeveloperName().get(RENEWAL).getRecordTypeId();
    
    /**
*  Description: method to create test data
*  @name      : createTestData
**/
    @testSetup static void createTestData(){    
        
        
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
        List<SKUs_Referred_in_Renewal_Upsell_NS_Calc__c> listofSkuCustomSetting = new List<SKUs_Referred_in_Renewal_Upsell_NS_Calc__c>();
        SKUs_Referred_in_Renewal_Upsell_NS_Calc__c zpaContractEndate = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c();
        zpaContractEndate.Name='ZPA_Contract_Date';
        zpaContractEndate.SKU_Codes__c='ZPA-BBA;ZPA-BUS;ZPA-ENT;ZPA-PRO;ZPA-PRO-LU;ZPA-BUS-LU;ZPA-BUS-EDITION;ZPA-PRO-EDITION;ZPA-BUS-EDITION-LU;ZIA-PRO-EDITION-LU;ZPA-TRANS-EDITION;ZPA-Remote-PRE;ZS-WFA-BUS-EDITION;ZPA-FED-BUNDLE;ZPA-ZFED-MODERATE';
        listofSkuCustomSetting.add(zpaContractEndate);
        SKUs_Referred_in_Renewal_Upsell_NS_Calc__c ziaContractEndate = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c();
        ziaContractEndate.Name='ZIA_Contract_Date';
        ziaContractEndate.SKU_Codes__c='ZSC-SIP;ZIA-PRO-BUNDLE;ZIA-BUS-BUNDLE;ZIA-TRANS-BUNDLE;ZIA-ELA-BUNDLE;ZIA-PRO-BUNDLE-LU;ZIA-BUS-BUNDLE-LU;ZIA-TRANS-BUNDLE-LU;ZIA-ELA-BUNDLE-LU;ZSC-SIP-LOC;ZIA-SIP;ZIA-PRO-EDITION;ZIA-BUS-EDITION;ZIA-TRANS-EDITION;ZIA-ELA-EDITION;ZIA-PRO-EDITION-LU;';
        listofSkuCustomSetting.add(ziaContractEndate);
        SKUs_Referred_in_Renewal_Upsell_NS_Calc__c ziaContractEndate1 = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c();
        ziaContractEndate1.Name='ZIA_Contract_Date1';
        ziaContractEndate1.SKU_Codes__c='ZIA-BUS-EDITION-LU;ZIA-TRANS-EDITION-LU;ZIA-ELA-EDITION-LU;ZSC-RET-KIOSK;Z-O365-PRE;ZS-WFA-BUS-EDITION;EDU-ZIA-SVC-EDGE-BUS;ZIA-FED-BUNDLE;ZIA-ZFED-MODERATE';
        listofSkuCustomSetting.add(ziaContractEndate1);
        SKUs_Referred_in_Renewal_Upsell_NS_Calc__c skuCredit = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c();
        skuCredit.Name = 'Credit SKU Line - Exception Product';
        listofSkuCustomSetting.add(skuCredit);
        insert listofSkuCustomSetting;
        
        accList = (SB_TestCPQDataUtility.createAccount(3));
        accList[0].Domain__c = 'testAccount1.com';
        accList[0].Asset_SKU_Codes__c='ZSEC-ATP,ZIA-TRANS-EDITION,ZSEC-WEB-ABA,ZSEC-WEB-ABA,ZSEC-ATP';
        accList[1].Asset_SKU_Codes__c='ZIA-ELA-BUNDLE,ZIA-TRANS-EDITION,ZSEC-WEB-ABA,ZSEC-WEB-ABA,ZSEC-ATP';
        accList[2].Asset_SKU_Codes__c='ZSEC-ATP,ZIA-TRANS-EDITION,ZSEC-WEB-ABA,ZSEC-WEB-ABA,ZSEC-ATP';
        insert accList;
        
        //Contact con = SB_TestCPQDataUtility.createContact(1,accList[0].Id)[0];
        //insert con;
        
        piList.add((SB_TestCPQDataUtility.createPartnerIncentive(1,accList[1].Id,true,system.today(),system.today(),'Traditional','MSP'))[0]);
        piList.add((SB_TestCPQDataUtility.createPartnerIncentive(1,accList[1].Id,true,system.today()+365,system.today()-30,SUMMIT_DISC,'MSP'))[1]);
        piList[1].Default__c=true;
        piList[1].Partner_Role__c=DISTRIBUTOR;
        piList[0].Partner_Role__c=DISTRIBUTOR;
        insert piList;
        
        productList = (SB_TestCPQDataUtility.createProduct(4,'Zscaler Internet Access','ZIA-','Renewable','Per User Per Year'));
        productList[0].ProductCode = '';
        productList[0].Pricing_Meter__c = '';
        productList[0].SKU_Type__c='PRE';
        productList[0].ProductCode='ZPA 123';
        productList[0].Product_Family__c=BUNDLEPL;
        productList[1].Product_Family__c=BUNDLEPL;
        productList[0].ProductCode='ZPA 1234';
        productList[2].Product_Family__c=BUNDLEPL;
        productList[0].ProductCode='ZPA 1235';
        productList[3].Product_Family__c=BUNDLEPL;
        productList[0].ProductCode='ZPA 1236';
        insert productList;
        
        customPb = (SB_TestCPQDataUtility.createCustomPriceBooks(1))[0];
        insert customPb;
        
        // PricebookEntry customPbEntry = new PricebookEntry();
        customPbEntryList.add((SB_TestCPQDataUtility.createPriceBookEntry(1,productList[1].Id,48))[0]);
        customPbEntryList.add((SB_TestCPQDataUtility.createPriceBookEntry(1,productList[2].Id,50))[1]);
        customPbEntryList.add((SB_TestCPQDataUtility.createPriceBookEntry(1,productList[3].Id,55))[2]);
        insert customPbEntryList;
        
        Opportunity renewalOpp = SB_TestCPQDataUtility.createOpportunity(1, 'TestOpp - Renewal', accList[0].Id)[0];
        renewalOpp.StageName = IMPVALID;
        renewalOpp.Primary_Partner_Program__c = SUMMIT_DISC;
        renewalOpp.Primary_Reseller_Partner__c=accList[1].Id;
        renewalOpp.RecordTypeId = oppRenewal;
        insert renewalOpp;
        Opportunity_Partner__c OppPartner = new Opportunity_Partner__c(Is_Primary__c = false,Opportunity__c = renewalOpp.Id,Partner_Type__c = RESELLER,Account__c = accList[0].Id);
        insert OppPartner;
        SBQQ__Quote__c quoteRec = SB_TestCPQDataUtility.createQuote(1, renewalOpp.Id, renewalOpp.AccountId, renewalOpp.Primary_Reseller_Partner__c,renewalOpp.Primary_Reseller_Partner__c,quoteRenewal)[0];
        quoteRec.Partner_Incentive__c = piList[1].Id;
        quoteRec.Partner_Program__c = SUMMIT_DISC;
        quoteRec.Include_Value_Summary_Feature_Additions__c= true;
        quoteRec.Special_Terms__c=TESTTERM;
        quoteRec.Include_Value_Summary_Feature_Additions__c = true;
        quoteRec.SBQQ__partner__c=accList[0].id;
        quoteRec.Bill_to__c =accList[1].id;
        quoteRec.SBQQ__Type__c=RENEWAL;
        quoteRec.Line_Item_SKU_Approval__c =SKUAPPROVAL2+APTS_CONSTANTS.PROD_SKU_ZPA_PRO_LU+','+APTS_CONSTANTS.PROD_SKU_ZIA_PROBUNDLE_LU+','+APTS_CONSTANTS.PROD_SKU_ZPA_PRO_LU+','+APTS_CONSTANTS.PROD_SKU_ZIA_PROBUNDLE_LU+SKUAPPROVAL;
        quoteRec.SBQQ__BillingFrequency__c = CUSTSCHEDULE;
        
        SBQQ.TriggerControl.disable();        
        insert quoteRec;
        
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
        renewalQL[0].SBQQ__RenewedSubscription__c = subscriptionList[0].Id;
        //renewalQL[1].SBQQ__Quote__r.Quote_Extension__r.Approved_FullSku__c = '{}';
        // renewalQL[3].Legal_terms__c = 'Test';
        insert renewalQL;
        
        renewalQL[0].SBQQ__Existing__c = true;
        renewalQL[1].SBQQ__RequiredBy__c = renewalQL[0].Id;
        renewalQL[2].SBQQ__RequiredBy__c = renewalQL[0].Id;
        renewalQL[3].SBQQ__RequiredBy__c = renewalQL[0].Id;
        renewalQL[0].Net_Variance__c = 10;
        renewalQL[1].Net_Variance__c = 20;
        renewalQL[2].Net_Variance__c = 30;
        update renewalQL;
        system.debug('renewalQL'+renewalQL);
    }
    
    @isTest static void updateChecboxesOnQETest() {
        //Account acc = [Select Id, Name from Account Limit 1];
        List<Opportunity> oppList = [Select Id,accountId, Name, CloseDate, Amount, SBQQ__RenewedContract__c, Custom_Renewal__c from Opportunity]; 
        
        List<SBQQ__Quote__c> quoteList = [Select Id,Name,SBQQ__MasterContract__c,Subscription_ProductCodes__c,SBQQ__opportunity2__c,Opportunity_Record_Type__c,
                                          Record_Type_Name__c,Partner_Program__c,Price_List__c,Rep_Comp_Impacted__c,Net_Variance_Weighted_Avg_Approval__c,
                                          ACV_New__c,Total_Discount_Without_Support__c,Auto_Generated_Quote__c,Previous_Record_Type_Name_Text__c,
                                          ACV__c,SBQQ__EndDate__c,ApprovalStatus__c,SBQQ__Partner__c,SBQQ__SubscriptionTerm__c,Approved_Subscription_Term__c,
                                          Generate_Year_wise_Split__c,SBQQ__Primary__c,Bill_to__c,Enterprise_Account_Approval__c
                                          from SBQQ__Quote__c];
        
        /*Map<Id,SBQQ__Quote__c> quoteMap = new Map<ID, SBQQ__Quote__c>([Select Id,Name,SBQQ__MasterContract__c,Subscription_ProductCodes__c,SBQQ__opportunity2__c,Opportunity_Record_Type__c,
Record_Type_Name__c,Partner_Program__c,Price_List__c,Rep_Comp_Impacted__c,Net_Variance_Weighted_Avg_Approval__c,
ACV_New__c,Total_Discount_Without_Support__c,Auto_Generated_Quote__c,Previous_Record_Type_Name_Text__c,
ACV__c,SBQQ__EndDate__c,ApprovalStatus__c,SBQQ__Partner__c,SBQQ__SubscriptionTerm__c,Approved_Subscription_Term__c,
Generate_Year_wise_Split__c,SBQQ__Primary__c,Bill_to__c,Enterprise_Account_Approval__c
from SBQQ__Quote__c LIMIT 1]);*/
        List<SBQQ__QuoteLine__c> ql = [SELECT Id,SBQQ__Quote__c,SBQQ__Quote__r.ACV_New__c,Is_Platform_SKU__c,SBQQ__Quantity__c,SBQQ__SubscriptionType__c,Net_Variance__c,SBQQ__ProductCode__c,Line_Status__c,SBQQ__NetTotal__c, ACV_New__c,MRR_New__c,SBQQ__Product__C,SBQQ__Product__r.Products_Type__c,SBQQ__product__r.SKU_Category__c,SBQQ__product__r.Zscaler_Product_Family__c FROM SBQQ__QuoteLine__c where Net_Variance__c < -20 and ACV_New__c > 100000 and Line_Status__c = 'New'  and Is_Platform_SKU__c =true limit 20];
        
        Test.startTest();
        /*QuoteTriggerHelper.assignRecordType(quoteList);
QuoteTriggerHelper.updateChecboxesOnQE(quoteMap);
QuoteTriggerHelper.updateQuoteSubsTerm(quoteList,quoteMap);
QuoteTriggerHelper.assignProductCodes(quoteList);
QuoteTriggerHelper.setApprovedSubscriptionTerm(quoteList,quoteMap);
QuoteTriggerHelper.setPrimaryQuote(quoteList,quoteMap,true);
QuoteTriggerHelper.setRenewableACV(quoteMap,quoteMap);*/
        
        UPDATE ql;
        UPDATE quoteList;
        Id newBusReTypeID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(NEWBUS).getRecordTypeId();
        Id UpsellTypeID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Upsell Opportunity').getRecordTypeId();
        
        //SBQQ__Quote__c quot =[SELECT id FROM SBQQ__Quote__c WHERE Include_Value_Summary_Feature_Additions__c=true];
        SB_TestCPQDataUtility.priceBooksToBeInsertedList = SB_TestCPQDataUtility.createCustomPriceBooks(1);
        insert SB_TestCPQDataUtility.priceBooksToBeInsertedList;
        
        Opportunity NBOpp = SB_TestCPQDataUtility.createOpportunity(1, TESTOPPNB, oppList[0].accountId)[0];
        NBOpp.StageName = IMPVALID;
        NBOpp.Primary_Partner_Program__c = SUMMIT_DISC;
        NBOpp.Primary_Reseller_Partner__c=oppList[0].accountId;
        NBOpp.RecordTypeId = newBusReTypeID;
        
        Opportunity UpsellTypeOpp = SB_TestCPQDataUtility.createOpportunity(1, TESTOPPUPSELL, oppList[0].accountId)[0];
        UpsellTypeOpp.StageName = IMPVALID;
        UpsellTypeOpp.Primary_Partner_Program__c = SUMMIT_DISC;
        UpsellTypeOpp.Primary_Reseller_Partner__c=oppList[0].accountId;
        UpsellTypeOpp.RecordTypeId = UpsellTypeID;
        UpsellTypeOpp.closedate =System.today().addMonths(1) +10;      
        List<Opportunity> OppListInsert = new  List<Opportunity>();
        OppListInsert.add(NBOpp);
        //OppListInsert.add(UpsellTypeOpp);
        
        INSERT OppListInsert;
        List<SBQQ__Quote__c> NewQuoteInsert = new List<SBQQ__Quote__c>();
        Id QuoteNewBusReTypeID = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get(NEWBUS).getRecordTypeId();
        
        SBQQ__Quote__c quoteRec = SB_TestCPQDataUtility.createQuote(1, NBOpp.Id, NBOpp.AccountId, NBOpp.Primary_Reseller_Partner__c,NBOpp.Primary_Reseller_Partner__c,QuoteNewBusReTypeID)[0];
        quoteRec.Partner_Incentive__c =null;
        //SBQQ__Quote__c quoteRec1 = SB_TestCPQDataUtility.createQuote(1, UpsellTypeOpp.Id, UpsellTypeOpp.AccountId, UpsellTypeOpp.Primary_Reseller_Partner__c,UpsellTypeOpp.Primary_Reseller_Partner__c,null)[0];
        
        NewQuoteInsert.add(quoteRec);
        // NewQuoteInsert.add(quoteRec1);
        INSERT NewQuoteInsert;
        Test.stopTest();
    }
    
    
    
    @isTest static void Test2() {
        
        List<SBQQ__Quote__c> quoteList = [Select Id,Name,SBQQ__MasterContract__c,Subscription_ProductCodes__c,SBQQ__opportunity2__c,Opportunity_Record_Type__c,
                                          Record_Type_Name__c,Partner_Program__c,Price_List__c,Rep_Comp_Impacted__c,Net_Variance_Weighted_Avg_Approval__c,
                                          ACV_New__c,Total_Discount_Without_Support__c,Auto_Generated_Quote__c,Previous_Record_Type_Name_Text__c,
                                          ACV__c,SBQQ__EndDate__c,ApprovalStatus__c,SBQQ__Partner__c,SBQQ__SubscriptionTerm__c,Approved_Subscription_Term__c,
                                          Generate_Year_wise_Split__c,Early_Renewal__c,SBQQ__Type__c,SBQQ__Primary__c,Bill_to__c,SBQQ__Account__c,Enterprise_Account_Approval__c
                                          from SBQQ__Quote__c];
        //QuoteTriggerHelper.CPQObjectInitialization();
        List<SBQQ__QuoteLine__c> quoteLines = [select id, name,SBQQ__ProductCode__c, Net_Variance__c, Line_Status__c, SBQQ__Quote__r.Name,Is_Platform_SKU__c,ACV_New__c   from SBQQ__QuoteLine__c where Line_Status__c ='New' and Net_Variance__c < -20 and ACV_New__c > 100000 and Is_Platform_SKU__c =true  limit 100];
        Test.startTest();
        UPDATE quoteList;
        UPDATE quoteLines;
        Test.stopTest();
    }
    
    @isTest static void Test3() {
        List<Account> accList = [Select Id, Name from Account Limit 1];
        List<Product2> productList = [Select Id, Name from Product2 Limit 1];
        List<Partner_Incentive__c> piList =  [Select Id, Name,Partner_Program__c from Partner_Incentive__c Limit 1];
        
        Test.startTest();
        
        List<Contract> contractList = SB_TestCPQDataUtility.createContracts(accList[0].Id, accList[0].Id, accList[0].Id,piList[0],1);
        SBQQ.TriggerControl.disable(); 
        insert contractList;
        SBQQ.TriggerControl.enable();
        
        SBQQ__Subscription__c sub = new SBQQ__Subscription__c();
        sub.SBQQ__Contract__c = contractList[0].Id;
        sub.SBQQ__Account__c = contractList[0].AccountId;
        sub.SBQQ__Quantity__c = 100;
        sub.SBQQ__TerminatedDate__c = null;
        sub.SBQQ__RequiredById__c = null;
        sub.Subscription_Line_Status__c = STATUSNEW;
        sub.SBQQ__Product__c = productList[0].Id;
        SBQQ.TriggerControl.disable(); 
        insert sub;
        SBQQ.TriggerControl.enable();
        
        List<SBQQ__Quote__c> quoteList = [Select Id,Name,SBQQ__MasterContract__c,Subscription_ProductCodes__c,SBQQ__opportunity2__c,Opportunity_Record_Type__c,
                                          Record_Type_Name__c,Partner_Program__c,Price_List__c,Rep_Comp_Impacted__c,Net_Variance_Weighted_Avg_Approval__c,
                                          ACV_New__c,Total_Discount_Without_Support__c,Auto_Generated_Quote__c,Previous_Record_Type_Name_Text__c,
                                          ACV__c,SBQQ__EndDate__c,ApprovalStatus__c,SBQQ__Partner__c,SBQQ__SubscriptionTerm__c,Approved_Subscription_Term__c,
                                          Generate_Year_wise_Split__c,SBQQ__Primary__c,Bill_to__c,Enterprise_Account_Approval__c,SBQQ__StartDate__c
                                          from SBQQ__Quote__c];
        
        quoteList[0].ApprovalStatus__c = 'Approved';
        quoteList[0].SBQQ__MasterContract__c = contractList[0].Id;
        quoteList[0].Subscription_ProductCodes__c = null;
        update quoteList;
        
        
        Test.stopTest();
    }
    
    @isTest static void setSubscriptionProductCodesTest() {
        
        // Id newBusReTypeID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(NEWBUS).getRecordTypeId();
        Id UpsellTypeID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Upsell Opportunity').getRecordTypeId();
        
        SB_TestCPQDataUtility.priceBooksToBeInsertedList = SB_TestCPQDataUtility.createCustomPriceBooks(1);
        insert SB_TestCPQDataUtility.priceBooksToBeInsertedList;
        
        List<SBQQ__Subscription__c> subscriptionList = [SELECT id ,SBQQ__Contract__r.accountId FROM SBQQ__Subscription__c WHERE SBQQ__Contract__r.accountId!=null LIMIT 1];
        System.assertEquals(subscriptionList.size(),1);
        
        Opportunity NBOpp = SB_TestCPQDataUtility.createOpportunity(1, TESTOPPNB, subscriptionList[0].SBQQ__Contract__r.accountId)[0];
        NBOpp.StageName = IMPVALID;
        NBOpp.Primary_Partner_Program__c = SUMMIT_DISC;
        //  NBOpp.Primary_Reseller_Partner__c=oppList[0].accountId;
        NBOpp.RecordTypeId = UpsellTypeID;
        
        List<Opportunity> OppListInsert = new  List<Opportunity>();
        OppListInsert.add(NBOpp);
        Test.startTest();
        INSERT OppListInsert;
        
        List<SBQQ__Quote__c> NewQuoteInsert = new List<SBQQ__Quote__c>();
        Id QuoteNewBusReTypeID = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get(NEWBUS).getRecordTypeId();
        
        SBQQ__Quote__c quoteRec = SB_TestCPQDataUtility.createQuote(1, NBOpp.Id, subscriptionList[0].SBQQ__Contract__r.accountId, NBOpp.Primary_Reseller_Partner__c,NBOpp.Primary_Reseller_Partner__c,QuoteNewBusReTypeID)[0];
        quoteRec.Partner_Incentive__c =null;
        quoteRec.SBQQ__MasterContract__c  = null;
        quoteRec.SBQQ__Type__c=RENEWAL;
        
        NewQuoteInsert.add(quoteRec);
        
        INSERT NewQuoteInsert;
        //List<SBQQ__Subscription__c> subscriptionList2 = [SELECT id ,SBQQ__Contract__r.accountId FROM SBQQ__Subscription__c WHERE SBQQ__Contract__r.accountId!=:NewQuoteInsert[0].SBQQ__Account__c];
        //System.assertEquals(subscriptionList2.size(),33);
        Test.stopTest();
    }//ENd of method setSubscriptionProductCodesTest
    
    @isTest static void setPrimaryQuoteTest() {
        Account acc = [Select Id, Name from Account Limit 1];
        List<Opportunity> oppList = [Select Id,accountId, Name, CloseDate, Amount, SBQQ__RenewedContract__c, Custom_Renewal__c from Opportunity]; 
        
        List<Partner_Incentive__c> piList =  [Select Id, Name,Partner_Program__c from Partner_Incentive__c Limit 1];
        List<Contract> contractList = SB_TestCPQDataUtility.createContracts(acc.Id, acc.Id, acc.Id,piList[0],1);
        List<Product2> productList = [Select Id, Name from Product2 Limit 1];
        
        SBQQ.TriggerControl.disable(); 
        insert contractList;
        SBQQ.TriggerControl.enable();
        
        SBQQ__Subscription__c sub = new SBQQ__Subscription__c();
        sub.SBQQ__Contract__c = contractList[0].Id;
        sub.SBQQ__Account__c = contractList[0].AccountId;
        sub.SBQQ__Quantity__c = 100;
        sub.SBQQ__TerminatedDate__c = null;
        sub.SBQQ__RequiredById__c = null;
        sub.Subscription_Line_Status__c = STATUSNEW;
        sub.SBQQ__Product__c = productList[0].Id;
        SBQQ.TriggerControl.disable(); 
        insert sub;
        SBQQ.TriggerControl.enable();
        
        Test.startTest();
        Id renewalOpptyRT = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal Opportunity').getRecordTypeId();
        SB_TestCPQDataUtility.priceBooksToBeInsertedList = SB_TestCPQDataUtility.createCustomPriceBooks(1);
        insert SB_TestCPQDataUtility.priceBooksToBeInsertedList;
        
        Opportunity NBOpp = SB_TestCPQDataUtility.createOpportunity(1, TESTOPPNB, oppList[0].accountId)[0];
        NBOpp.StageName = IMPVALID;
        NBOpp.Primary_Partner_Program__c = SUMMIT_DISC;
        NBOpp.Primary_Reseller_Partner__c=oppList[0].accountId;
        NBOpp.RecordTypeId = renewalOpptyRT;
        
        Opportunity objOpptyRenewal = SB_TestCPQDataUtility.createOpportunity(1, TESTOPPUPSELL, oppList[0].accountId)[0];
        objOpptyRenewal.StageName = IMPVALID;
        objOpptyRenewal.Primary_Partner_Program__c = SUMMIT_DISC;
        objOpptyRenewal.Primary_Reseller_Partner__c=oppList[0].accountId;
        objOpptyRenewal.RecordTypeId = renewalOpptyRT;
        objOpptyRenewal.closedate =System.today().addMonths(1) +10;    
        objOpptyRenewal.SBQQ__RenewedContract__c =contractList[0].id;           
        List<Opportunity> OppListInsert = new  List<Opportunity>();
        OppListInsert.add(objOpptyRenewal);
        //OppListInsert.add(NBOpp);
        //OppListInsert.add(UpsellTypeOpp);
        
        INSERT OppListInsert;
        
        List<Opportunity_Partner__c> listOpptyPartner = new List<Opportunity_Partner__c>();
        listOpptyPartner.add(new Opportunity_Partner__c(Is_Primary__c = false,Opportunity__c = OppListInsert[0].Id,Partner_Type__c = RESELLER,Account__c = acc.Id));
        listOpptyPartner.add(new Opportunity_Partner__c(Is_Primary__c = true,Opportunity__c = OppListInsert[0].Id,Partner_Type__c = DISTRIBUTOR,Account__c = acc.Id));
        insert listOpptyPartner;
        
        List<SBQQ__Quote__c> NewQuoteInsert = new List<SBQQ__Quote__c>();
        Id QuoteNewBusReTypeID = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get(NEWBUS).getRecordTypeId();
        
        SBQQ__Quote__c quoteRec = SB_TestCPQDataUtility.createQuote(1, OppListInsert[0].Id, OppListInsert[0].AccountId, OppListInsert[0].Primary_Reseller_Partner__c,OppListInsert[0].Primary_Reseller_Partner__c,QuoteNewBusReTypeID)[0];
        quoteRec.Partner_Incentive__c =null;
        quoteRec.SBQQ__EndDate__c = null;
        NewQuoteInsert.add(quoteRec);
        system.debug('@@@'+quoteRec);
        system.debug('@@'+NewQuoteInsert);
        // NewQuoteInsert.add(quoteRec1);
        INSERT NewQuoteInsert;
        Test.stopTest();
    }
    @isTest 
    static void setNetSuiteInternalIdTest(){
        Test.startTest();
        Account acc = [Select Id, Name from Account Limit 1];
        acc.Name='Zscaler';
        update acc;
        List<Opportunity> oppList = [Select Id,accountId, Name, CloseDate, Amount, SBQQ__RenewedContract__c, Custom_Renewal__c,Primary_Reseller_Partner__c from Opportunity]; 
        
        List<Partner_Incentive__c> piList =  [Select Id, Name,Partner_Program__c from Partner_Incentive__c Limit 1];
        //<Contract> contractList = SB_TestCPQDataUtility.createContracts(acc.Id, acc.Id, acc.Id,piList[0],1);
        // List<Product2> productList = [Select Id, Name from Product2 Limit 1];
        
        SBQQ__Quote__c quoteRec = SB_TestCPQDataUtility.createQuote(1, oppList[0].Id, oppList[0].AccountId, oppList[0].Primary_Reseller_Partner__c,oppList[0].Primary_Reseller_Partner__c,quoteRenewal)[0];
        quoteRec.Partner_Incentive__c = piList[0].Id;
        quoteRec.Partner_Program__c = SUMMIT_DISC;
        quoteRec.Include_Value_Summary_Feature_Additions__c= true;
        quoteRec.Special_Terms__c=TESTTERM;
        quoteRec.Include_Value_Summary_Feature_Additions__c = true;
        quoteRec.Include_Value_Summary_Feature_Additions__c =true;
        quoteRec.Include_Value_Summary_Feature_Additions__c  =true;
        quoteRec.SBQQ__partner__c=acc.id;
        quoteRec.Bill_to__c =acc.id;
        quoteRec.SBQQ__Type__c=RENEWAL;
        quoteRec.Line_Item_SKU_Approval__c =SKUAPPROVAL2+APTS_CONSTANTS.PROD_SKU_ZPA_PRO_LU+','+APTS_CONSTANTS.PROD_SKU_ZIA_PROBUNDLE_LU+','+APTS_CONSTANTS.PROD_SKU_ZPA_PRO_LU+','+APTS_CONSTANTS.PROD_SKU_ZIA_PROBUNDLE_LU+SKUAPPROVAL;
        quoteRec.SBQQ__BillingFrequency__c = CUSTSCHEDULE;
        
        insert quoteRec;
        Test.stopTest();
        
    }
    @isTest 
    static void setPartnerTest(){
        List<Account> acc = [Select Id, Name from Account Limit 2];
        Test.startTest();
        List<Opportunity> oppList = [Select Id,accountId, Name, CloseDate, Amount, SBQQ__RenewedContract__c, Custom_Renewal__c,Primary_Reseller_Partner__c from Opportunity]; 
        OpportunityPartner partner = new OpportunityPartner();
        partner.OpportunityId=oppList[0].Id;
        partner.AccountToId= acc[1].Id;
        partner.isPrimary = true;
        insert partner;
        List<Partner_Incentive__c> piList =  [Select Id, Name,Partner_Program__c from Partner_Incentive__c Limit 1];
        //<Contract> contractList = SB_TestCPQDataUtility.createContracts(acc.Id, acc.Id, acc.Id,piList[0],1);
        // List<Product2> productList = [Select Id, Name from Product2 Limit 1];
        
        SBQQ__Quote__c quoteRec = SB_TestCPQDataUtility.createQuote(1, oppList[0].Id, oppList[0].AccountId, oppList[0].Primary_Reseller_Partner__c,oppList[0].Primary_Reseller_Partner__c,quoteRenewal)[0];
        quoteRec.Partner_Incentive__c = piList[0].Id;
        quoteRec.Partner_Program__c = SUMMIT_DISC;
        quoteRec.Include_Value_Summary_Feature_Additions__c= true;
        quoteRec.Special_Terms__c=TESTTERM;
        quoteRec.Include_Value_Summary_Feature_Additions__c = true;
        quoteRec.Include_Value_Summary_Feature_Additions__c =true;
        quoteRec.Include_Value_Summary_Feature_Additions__c  =true;
        quoteRec.SBQQ__partner__c=acc[1].Id;
        quoteRec.Bill_to__c =acc[1].Id;
        quoteRec.Early_Renewal__c = true;
        quoteRec.SBQQ__Type__c=RENEWAL;
        quoteRec.Line_Item_SKU_Approval__c =SKUAPPROVAL2+APTS_CONSTANTS.PROD_SKU_ZPA_PRO_LU+','+APTS_CONSTANTS.PROD_SKU_ZIA_PROBUNDLE_LU+','+APTS_CONSTANTS.PROD_SKU_ZPA_PRO_LU+','+APTS_CONSTANTS.PROD_SKU_ZIA_PROBUNDLE_LU+SKUAPPROVAL;
        quoteRec.SBQQ__BillingFrequency__c = CUSTSCHEDULE;
        
        insert quoteRec;
        Test.stopTest();
    }
    @isTest static void setAmendmentFieldsRenewaltest() {
        Account acc = [Select Id, Name from Account Limit 1];
        List<Opportunity> oppList = [Select Id,accountId, Name, CloseDate, Amount, SBQQ__RenewedContract__c, Custom_Renewal__c from Opportunity]; 
        
        List<Partner_Incentive__c> piList =  [Select Id, Name,Partner_Program__c from Partner_Incentive__c Limit 1];
        List<Contract> contractList = SB_TestCPQDataUtility.createContracts(acc.Id, acc.Id, acc.Id,piList[0],1);
        List<Product2> productList = [Select Id, Name from Product2 Limit 1];
        
        SBQQ.TriggerControl.disable(); 
        insert contractList;
        SBQQ.TriggerControl.enable();
        
        SBQQ__Subscription__c sub = new SBQQ__Subscription__c();
        sub.SBQQ__Contract__c = contractList[0].Id;
        sub.SBQQ__Account__c = contractList[0].AccountId;
        sub.SBQQ__Quantity__c = 100;
        sub.SBQQ__TerminatedDate__c = null;
        sub.SBQQ__RequiredById__c = null;
        sub.Subscription_Line_Status__c = STATUSNEW;
        sub.SBQQ__Product__c = productList[0].Id;
        SBQQ.TriggerControl.disable(); 
        insert sub;
        SBQQ.TriggerControl.enable();
        
        Test.startTest();
        Id renewalOpptyRT = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal Opportunity').getRecordTypeId();
        SB_TestCPQDataUtility.priceBooksToBeInsertedList = SB_TestCPQDataUtility.createCustomPriceBooks(1);
        insert SB_TestCPQDataUtility.priceBooksToBeInsertedList;
        
        Opportunity NBOpp = SB_TestCPQDataUtility.createOpportunity(1, TESTOPPNB, oppList[0].accountId)[0];
        NBOpp.StageName = IMPVALID;
        NBOpp.Primary_Partner_Program__c = SUMMIT_DISC;
        NBOpp.Primary_Reseller_Partner__c=oppList[0].accountId;
        NBOpp.RecordTypeId = renewalOpptyRT;
        
        Opportunity objOpptyRenewal = SB_TestCPQDataUtility.createOpportunity(1, TESTOPPUPSELL, oppList[0].accountId)[0];
        objOpptyRenewal.StageName = IMPVALID;
        objOpptyRenewal.Primary_Partner_Program__c = SUMMIT_DISC;
        objOpptyRenewal.Primary_Reseller_Partner__c=oppList[0].accountId;
        objOpptyRenewal.RecordTypeId = renewalOpptyRT;
        objOpptyRenewal.closedate =System.today().addMonths(1) +10;    
        objOpptyRenewal.SBQQ__RenewedContract__c =contractList[0].id;           
        List<Opportunity> OppListInsert = new  List<Opportunity>();
        OppListInsert.add(objOpptyRenewal);
        //OppListInsert.add(NBOpp);
        //OppListInsert.add(UpsellTypeOpp);
        
        INSERT OppListInsert;
        
        List<Opportunity_Partner__c> listOpptyPartner = new List<Opportunity_Partner__c>();
        listOpptyPartner.add(new Opportunity_Partner__c(Is_Primary__c = true,Opportunity__c = OppListInsert[0].Id,Partner_Type__c = RESELLER,Account__c = acc.Id));
        listOpptyPartner.add(new Opportunity_Partner__c(Is_Primary__c = true,Opportunity__c = OppListInsert[0].Id,Partner_Type__c = DISTRIBUTOR,Account__c = acc.Id));
        insert listOpptyPartner;
        
        List<SBQQ__Quote__c> NewQuoteInsert = new List<SBQQ__Quote__c>();
        Id QuoteNewBusReTypeID = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get(NEWBUS).getRecordTypeId();
        
        SBQQ__Quote__c quoteRec = SB_TestCPQDataUtility.createQuote(1, OppListInsert[0].Id, OppListInsert[0].AccountId, OppListInsert[0].Primary_Reseller_Partner__c,OppListInsert[0].Primary_Reseller_Partner__c,QuoteNewBusReTypeID)[0];
        quoteRec.Partner_Incentive__c =null;
        quoteRec.SBQQ__EndDate__c = null;
        quoteRec.SBQQ__MasterContract__c = contractList[0].Id;
        NewQuoteInsert.add(quoteRec);
        system.debug('@@@'+quoteRec);
        system.debug('@@'+NewQuoteInsert);
        // NewQuoteInsert.add(quoteRec1);
        INSERT NewQuoteInsert;
        Test.stopTest();
    }
    
    @isTest static void setAmendmentFieldstest() {
        Account acc = [Select Id, Name from Account Limit 1];
        List<Opportunity> oppList = [Select Id,accountId, Name, CloseDate, Amount, SBQQ__RenewedContract__c, Custom_Renewal__c from Opportunity]; 
        
        List<Partner_Incentive__c> piList =  [Select Id, Name,Partner_Program__c from Partner_Incentive__c Limit 1];
        List<Contract> contractList = SB_TestCPQDataUtility.createContracts(acc.Id, acc.Id, acc.Id,piList[0],1);
        List<Product2> productList = [Select Id, Name from Product2 Limit 1];
        
        SBQQ.TriggerControl.disable(); 
        insert contractList;
        SBQQ.TriggerControl.enable();
        
        SBQQ__Subscription__c sub = new SBQQ__Subscription__c();
        sub.SBQQ__Contract__c = contractList[0].Id;
        sub.SBQQ__Account__c = contractList[0].AccountId;
        sub.SBQQ__Quantity__c = 100;
        sub.SBQQ__TerminatedDate__c = null;
        sub.SBQQ__RequiredById__c = null;
        sub.Subscription_Line_Status__c = STATUSNEW;
        sub.SBQQ__Product__c = productList[0].Id;
        SBQQ.TriggerControl.disable(); 
        insert sub;
        SBQQ.TriggerControl.enable();
        
        Test.startTest();
        Id upsellOpptyRT = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Upsell Opportunity').getRecordTypeId();
        SB_TestCPQDataUtility.priceBooksToBeInsertedList = SB_TestCPQDataUtility.createCustomPriceBooks(1);
        insert SB_TestCPQDataUtility.priceBooksToBeInsertedList;
        
        Opportunity NBOpp = SB_TestCPQDataUtility.createOpportunity(1, TESTOPPNB, oppList[0].accountId)[0];
        NBOpp.StageName = IMPVALID;
        NBOpp.Primary_Partner_Program__c = SUMMIT_DISC;
        NBOpp.Primary_Reseller_Partner__c=oppList[0].accountId;
        NBOpp.RecordTypeId = upsellOpptyRT;
        
        Opportunity objOpptyRenewal = SB_TestCPQDataUtility.createOpportunity(1, TESTOPPUPSELL, oppList[0].accountId)[0];
        objOpptyRenewal.StageName = IMPVALID;
        objOpptyRenewal.Primary_Partner_Program__c = SUMMIT_DISC;
        objOpptyRenewal.Primary_Reseller_Partner__c=oppList[0].accountId;
        objOpptyRenewal.RecordTypeId = upsellOpptyRT;
        objOpptyRenewal.closedate =System.today().addMonths(1) +10;    
        objOpptyRenewal.SBQQ__AmendedContract__c =contractList[0].id;           
        List<Opportunity> OppListInsert = new  List<Opportunity>();
        OppListInsert.add(objOpptyRenewal);
        //OppListInsert.add(NBOpp);
        //OppListInsert.add(UpsellTypeOpp);
        
        INSERT OppListInsert;
        
        List<Opportunity_Partner__c> listOpptyPartner = new List<Opportunity_Partner__c>();
        listOpptyPartner.add(new Opportunity_Partner__c(Is_Primary__c = true,Opportunity__c = OppListInsert[0].Id,Partner_Type__c = RESELLER,Account__c = acc.Id));
        listOpptyPartner.add(new Opportunity_Partner__c(Is_Primary__c = true,Opportunity__c = OppListInsert[0].Id,Partner_Type__c = DISTRIBUTOR,Account__c = acc.Id));
        insert listOpptyPartner;
        
        List<SBQQ__Quote__c> NewQuoteInsert = new List<SBQQ__Quote__c>();
        Id QuoteNewBusReTypeID = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get(NEWBUS).getRecordTypeId();
        
        SBQQ__Quote__c quoteRec = SB_TestCPQDataUtility.createQuote(1, OppListInsert[0].Id, OppListInsert[0].AccountId, OppListInsert[0].Primary_Reseller_Partner__c,OppListInsert[0].Primary_Reseller_Partner__c,QuoteNewBusReTypeID)[0];
        quoteRec.Partner_Incentive__c =null;
        quoteRec.SBQQ__EndDate__c = null;
        quoteRec.SBQQ__MasterContract__c = contractList[0].Id;
        NewQuoteInsert.add(quoteRec);
        system.debug('@@@'+quoteRec);
        system.debug('@@'+NewQuoteInsert);
        // NewQuoteInsert.add(quoteRec1);
        INSERT NewQuoteInsert;
        Test.stopTest();
    }
    @isTest 
    static void setDocumentTypeTest(){
        List<Account> acc = [Select Id, Name from Account Limit 2];
        acc[1].Name = 'CDW Corporation';
        update acc[1];
        List<Opportunity> oppList = [Select Id,accountId, Name, CloseDate, Amount, SBQQ__RenewedContract__c, Custom_Renewal__c,Primary_Reseller_Partner__c from Opportunity]; 
        OpportunityPartner partner = new OpportunityPartner();
        partner.OpportunityId=oppList[0].Id;
        partner.AccountToId= acc[1].Id;
        partner.isPrimary = true;
        insert partner;
        List<Partner_Incentive__c> piList =  [Select Id, Name,Partner_Program__c from Partner_Incentive__c Limit 1];
        //<Contract> contractList = SB_TestCPQDataUtility.createContracts(acc.Id, acc.Id, acc.Id,piList[0],1);
        // List<Product2> productList = [Select Id, Name from Product2 Limit 1];
        
        SBQQ__Quote__c quoteRec = SB_TestCPQDataUtility.createQuote(1, oppList[0].Id, oppList[0].AccountId, oppList[0].Primary_Reseller_Partner__c,oppList[0].Primary_Reseller_Partner__c,quoteRenewal)[0];
        quoteRec.Partner_Incentive__c = piList[0].Id;
        quoteRec.Partner_Program__c = SUMMIT_DISC;
        quoteRec.Include_Value_Summary_Feature_Additions__c= true;
        quoteRec.Special_Terms__c=TESTTERM;
        quoteRec.Include_Value_Summary_Feature_Additions__c = true;
        quoteRec.Include_Value_Summary_Feature_Additions__c =true;
        quoteRec.Include_Value_Summary_Feature_Additions__c  =true;
        quoteRec.SBQQ__partner__c=acc[1].Id;
        quoteRec.Bill_to__c =acc[1].Id;
        quoteRec.SBQQ__Type__c=RENEWAL;
        quoteRec.Line_Item_SKU_Approval__c =SKUAPPROVAL2+APTS_CONSTANTS.PROD_SKU_ZPA_PRO_LU+','+APTS_CONSTANTS.PROD_SKU_ZIA_PROBUNDLE_LU+','+APTS_CONSTANTS.PROD_SKU_ZPA_PRO_LU+','+APTS_CONSTANTS.PROD_SKU_ZIA_PROBUNDLE_LU+SKUAPPROVAL;
        quoteRec.SBQQ__BillingFrequency__c = CUSTSCHEDULE;
        Test.startTest();     
        insert quoteRec;
        quoteRec.generate_year_wise_split__c = true;
        update quoteRec;
        Test.stopTest();
    }
    
    @isTest 
    static void lineItemSkuApprovalTest(){
        List<SBQQ__QuoteLine__c> quoteline =[SELECT Id,SBQQ__Quote__c from SBQQ__QuoteLine__c];
        Id quoteId = quoteline[0].SBQQ__Quote__c;
        Delete quoteline;
        SBQQ__Quote__c quote =[SELECT Id,Line_Item_SKU_Approval__c from SBQQ__Quote__c where Id =:quoteId];
        System.assertEquals(quote.Line_Item_SKU_Approval__c,null);
    }
    @isTest
    static void testFullSku(){
        List<SBQQ__QuoteLine__c> quoteline =[SELECT Id,SBQQ__Quote__r.Quote_Extension__r.Approved_Internal_Restricted_Pre_SKU__c,Eligible_Deep_Discounting_Approval__c,SBQQ__ProductCode__c,SBQQ__Quote__r.Pending_FullSku_approval__c,SBQQ__Quote__r.Quote_Extension__c,SBQQ__Quote__r.Quote_Extension__r.Approved_FullSku__c,SBQQ__Quote__c from SBQQ__QuoteLine__c limit 5];
        Test.startTest();
        quoteline[0].Eligible_Deep_Discounting_Approval__c = 'Full SKU deep discounting approval';
        quoteline[1].Eligible_Deep_Discounting_Approval__c = 'Internal/Restricted/Pre-SKU Deep discounting approval';
        quoteline[2].Eligible_Deep_Discounting_Approval__c = 'Full SKU deep discounting approval';
        quoteline[2].SBQQ__Quote__r.Quote_Extension__r.Approved_FullSku__c = quoteline[2].SBQQ__ProductCode__c;
        quoteline[3].Eligible_Deep_Discounting_Approval__c = 'Internal/Restricted/Pre-SKU Deep discounting approval';
        quoteline[3].SBQQ__Quote__r.Quote_Extension__r.Approved_Internal_Restricted_Pre_SKU__c = quoteline[2].SBQQ__ProductCode__c;
        quoteline[0].SBQQ__Quote__r.Quote_Extension__r.Approved_FullSku__c = '{}';
        quoteline[1].SBQQ__Quote__r.Quote_Extension__r.Approved_FullSku__c = quoteline[1].SBQQ__ProductCode__c;
        //update quoteline;
        Test.stopTest();
    }
    
}