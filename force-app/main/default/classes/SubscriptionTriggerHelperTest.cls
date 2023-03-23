@isTest
public class SubscriptionTriggerHelperTest {
    private static String quoteRenewal = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByDeveloperName().get('Renewal').getRecordTypeId();
    private static String oppRenewal = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Renewal_Opportunity').getRecordTypeId();
    
    @testSetup static void dataSetup() {
		Map<String, SKUs_Referred_in_Renewal_Upsell_NS_Calc__c> mapSKUs = SKUs_Referred_in_Renewal_Upsell_NS_Calc__c.getAll();
        List<SKUs_Referred_in_Renewal_Upsell_NS_Calc__c> skuscs = new List<SKUs_Referred_in_Renewal_Upsell_NS_Calc__c>();
        if(!mapSKUs.containsKey('CFW_CSB_SKUs')){
            SKUs_Referred_in_Renewal_Upsell_NS_Calc__c rec1 = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c(name='CFW_CSB_SKUs', SKU_Codes__c = 'ZFW-NG-WITH-LOG;ZSEC-WEB-ABA');
            skuscs.add(rec1);
        }
        if(!mapSKUs.containsKey('CFW_ZPA_SKUs')){
            SKUs_Referred_in_Renewal_Upsell_NS_Calc__c rec2 = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c(name='CFW_ZPA_SKUs', SKU_Codes__c = 'ZFW-NG-WITH-LOG;ZIA-TRANS-BUNDLE;ZIA-ELA-BUNDLE');
            skuscs.add(rec2);
        }
        if(!mapSKUs.containsKey('Credit_SKUs')){
            SKUs_Referred_in_Renewal_Upsell_NS_Calc__c rec3 = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c(name='Credit_SKUs', SKU_Codes__c = 'ZCR-BuyBack;Z-ZPA-BuyBack;Z-CFWCSB-PROMO;Z-CFWZPA-Credit;Z-CREDIT');
            skuscs.add(rec3);
        }
        if(!mapSKUs.containsKey('One_Time_SKU')){
            SKUs_Referred_in_Renewal_Upsell_NS_Calc__c rec4 = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c(name='One_Time_SKU', SKU_Codes__c = 'ZCES-PRO-SVC;ZCES-DAS-PKG0;ZCES-DAS-PKG1;ZCES-DAS-PKG2;ZCES-DAS-PKG3;ZCES-DAS-PKG6;ZCES-EDU-CREDIT;ZCES-EDU-LABCREDIT;ZCES-Onetime-ZPA-INT');
            skuscs.add(rec4);
        }
        if(!mapSKUs.containsKey('Recurring_SKU')){
            SKUs_Referred_in_Renewal_Upsell_NS_Calc__c rec5 = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c(name='Recurring_SKU', SKU_Codes__c = 'ZCES-SUP-PREM;ZCES-SUP-PREM-SP;ZCES-SUP-TAMT');
            skuscs.add(rec5);
        }
        if(!mapSKUs.containsKey('SKUs_not_To_ADD')){
            SKUs_Referred_in_Renewal_Upsell_NS_Calc__c rec6 = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c(name='SKUs_not_To_ADD', SKU_Codes__c = 'ZCR-UPY4;ZCR-UPY5');
            skuscs.add(rec6);
        }
        if(!mapSKUs.containsKey('SKUs_to_SKIP_ACV')){
            SKUs_Referred_in_Renewal_Upsell_NS_Calc__c rec7 = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c(name='SKUs_to_SKIP_ACV', SKU_Codes__c = 'ZCR-BuyBack;Z-ZPA-BuyBack;Z-CFWCSB-PROMO;Z-CFWZPA-Credit;Z-CREDIT;ZCR-UPY4;ZCR-UPY5');
            skuscs.add(rec7);
        }
        if(!mapSKUs.containsKey('Uplift_SKUs')){
            SKUs_Referred_in_Renewal_Upsell_NS_Calc__c rec8 = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c(name='Uplift_SKUs', SKU_Codes__c = 'ZCR-UPY4;ZCR-UPY5');
            skuscs.add(rec8);
        }
        if(!mapSKUs.containsKey('ZPA_Deployment_SKUs')){
            SKUs_Referred_in_Renewal_Upsell_NS_Calc__c rec9 = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c(name='ZPA_Deployment_SKUs', SKU_Codes__c = 'ZCES-DAS-FED1;ZCES-DAS-FED2;ZCES-DAS-FED3;ZCES-DAS-PKG0;ZCES-DAS-PKG1;ZCES-DAS-PKG2;ZCES-DAS-PKG3;ZCES-DAS-PKG4;ZCES-DAS-PKG6;ZCES-DAS-UNIT;ZCES-DEP-ADV;ZCES-DEP-ENT;ZCES-DEP-ENTPLUS;ZCES-DEP-ESS;ZCES-PRO-SVC');
            skuscs.add(rec9);
        }
        if(!mapSKUs.containsKey('One_Time_SKU1')){
            SKUs_Referred_in_Renewal_Upsell_NS_Calc__c rec10 = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c(name='One_Time_SKU1', SKU_Codes__c = 'ZCES-PRO-SVC-CUST');
            skuscs.add(rec10);
        }
        if(!mapSKUs.containsKey('ZPA_Deployment_SKUs1')){
            SKUs_Referred_in_Renewal_Upsell_NS_Calc__c rec11 = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c(name='ZPA_Deployment_SKUs1', SKU_Codes__c = 'ZCES-PRO-SVC-CUST');
            skuscs.add(rec11);
        }
        if(!mapSKUs.containsKey('Included_DAS_Package_SKUs1')){
            SKUs_Referred_in_Renewal_Upsell_NS_Calc__c rec11 = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c(name='Included_DAS_Package_SKUs1', SKU_Codes__c = 'ZCES-DAS-PKG1;ZCES-DAS-PKG2;ZCES-DAS-PKG3;ZCES-DAS-PKG4;ZCES-DAS-PKG6;ZCES-DAS-PKG0;ZCES-DEP-ADV;ZCES-DEP-ENT;ZCES-DEP-ENTPLUS;ZCES-DEP-ESS;ZCES-PRO-HEALTH;ZCES-DAS-FED1;ZCES-DAS-FED2;ZCES-DAS-FED3');
            skuscs.add(rec11);
        }
        if(!mapSKUs.containsKey('Included_DAS_Package_SKUs2')){
            SKUs_Referred_in_Renewal_Upsell_NS_Calc__c rec11 = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c(name='Included_DAS_Package_SKUs2', SKU_Codes__c = 'ZCES-PRO-SVC;ZCES-PRO-OPTADV;ZCES-PRO-OPTESS;ZCES-PRO-DZX;ZCES-PRO-OPTENT;ZCES-PRO-POL-PRE;ZCES-PRO-PMI-PRE;ZCES-PRO-SVC-CUST');
            skuscs.add(rec11);
        }
        if(!mapSKUs.containsKey('ZIA_Contract_Date')){
            SKUs_Referred_in_Renewal_Upsell_NS_Calc__c rec12 = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c(name='ZIA_Contract_Date', SKU_Codes__c = 'ZSC-SIP;ZIA-PRO-BUNDLE;ZIA-BUS-BUNDLE;ZIA-TRANS-BUNDLE;ZCES-SUP-PREM;ZIA-ELA-BUNDLE;ZIA-PRO-BUNDLE-LU;ZIA-BUS-BUNDLE-LU;ZIA-TRANS-BUNDLE-LU;ZIA-ELA-BUNDLE-LU;ZSC-SIP-LOC;ZIA-SIP');
            skuscs.add(rec12);
        }
        if(!mapSKUs.containsKey('ZIA_Contract_Date1')){
            SKUs_Referred_in_Renewal_Upsell_NS_Calc__c rec13 = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c(name='ZIA_Contract_Date1', SKU_Codes__c = 'ZS-WFA-BUS-EDITION');
            skuscs.add(rec13);
        }
        if(!mapSKUs.containsKey('ZPA_Contract_Date')){
            SKUs_Referred_in_Renewal_Upsell_NS_Calc__c rec14 = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c(name='ZPA_Contract_Date', SKU_Codes__c = 'ZPA-BBA;ZPA-BUS;ZPA-ENT;ZPA-PRO;ZPA-PRO-LU;ZPA-BUS-LU;ZPA-BUS-EDITION;ZPA-PRO-EDITION;ZPA-BUS-EDITION-LU;ZIA-PRO-EDITION-LU;ZPA-TRANS-EDITION;ZS-WFA-BUS-EDITION');
            skuscs.add(rec14);
        }
        if(!mapSKUs.containsKey('ZDX_Contract_Date')){
            SKUs_Referred_in_Renewal_Upsell_NS_Calc__c rec15 = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c(name='ZDX_Contract_Date', SKU_Codes__c = 'ZPA-BBA;ZPA-BUS;ZPA-ENT;ZPA-PRO;ZPA-PRO-LU;ZPA-BUS-LU;ZPA-BUS-EDITION;ZPA-PRO-EDITION;ZPA-BUS-EDITION-LU;ZIA-PRO-EDITION-LU;ZPA-TRANS-EDITION');
            skuscs.add(rec15);
        }
        
        if(!skuscs.isEmpty())
            insert skuscs;
	}
    
    @isTest
    static void unitTest1(){
        List<Account> accList = SB_TestCPQDataUtility.createAccount(1);
        insert accList;
        String oppName = 'Test Opportunity';
        String accId = accList[0].Id;
        String recordTypeId = '0121D0000032zdVQAQ';
        String prodName = 'Test Product';
        String prodCode = 'ZCES-SUP-PREM';
        String subsType = 'Renewable';
        String priceMeter = 'Per User Per Year';
        Date startDate = Date.valueOf('2021-08-01');
        Date endDate = Date.valueOf('2021-08-11');
        Double quantity = 12.1;
        Partner_Incentive__c pi = SB_TestCPQDataUtility.createPartnerIncentive(1,accId,true,system.today()+365,system.today()-30,'Summit - Discount','MSP')[0];
        pi.Default__c=true;
        insert pi;
        
        //List<Product2> prodList = SB_TestCPQDataUtility.createProduct(1, prodName, prodCode, subsType, priceMeter);
        List<Product2> productList=new List<Product2>();
        productList = (SB_TestCPQDataUtility.createProduct(4,'Zscaler Internet Access','ZIA-','Renewable','Per User Per Year'));
        productList[0].ProductCode = '';
        productList[0].Pricing_Meter__c = '';
        productList[0].Platform_SKU_Number__c = 1;
        productList[1].Platform_SKU_Number__c = 2;
        insert productList;
        
        List<PriceBook2> priceBiikList = SB_TestCPQDataUtility.createCustomPriceBooks(1);
        List<opportunity> oppList = SB_TestCPQDataUtility.createOpportunity(1, oppName, accId);
        oppList[0].RecordTypeId = oppRenewal;
        insert oppList;
        
        Test.startTest();
        //List<SBQQ__Quote__c> quoteList = SB_TestCPQDataUtility.createQuote (1, oppList[0].Id, accId, accId, accId, quoteRenewal);
        SBQQ__Quote__c quoteRec = SB_TestCPQDataUtility.createQuote(1, oppList[0].Id, accId, accId,accId,quoteRenewal)[0];
        quoteRec.Partner_Incentive__c = pi.Id;
        quoteRec.Partner_Program__c = 'Summit - Discount';
        insert quoteRec;
        
        Date qlDate = system.today() + (365*3);
        Contract contractRec = SB_TestCPQDataUtility.createContracts(accId, accId, accId,pi,1)[0];
        List<SBQQ__QuoteLine__c> sbqqList = new List<SBQQ__QuoteLine__c>();
        sbqqList= (SB_TestCPQDataUtility.createQuoteLine(4, quoteRec.Id, productList[0].Id, system.today(), qlDate,50));
        sbqqList[1].SBQQ__Product__c = productList[1].Id;
        sbqqList[2].SBQQ__Product__c = productList[2].Id;
        sbqqList[3].SBQQ__Product__c = productList[3].Id;
        sbqqList[0].SBQQ__Number__c = 1;
        sbqqList[1].SBQQ__Number__c = 2;
        sbqqList[2].SBQQ__Number__c = 3;
        sbqqList[3].SBQQ__Number__c = 4;
        insert sbqqList;
        
        //List<SBQQ__QuoteLine__c> sbqqList = SB_TestCPQDataUtility.createQuoteLine (1, quoteList[0].Id,prodList[0].Id,startDate, endDate ,quantity);
        //List<SBQQ__Subscription__c> sbqqSubscriptionList = SB_TestCPQDataUtility.createSubscriptions(contractList[0], sbqqList);
        /*SBQQ__Subscription__c sub = new SBQQ__Subscription__c();
        sub.SBQQ__Contract__c = contractList[0].Id;
        sub.SBQQ__Account__c = contractList[0].AccountId;
        sub.SBQQ__Quantity__c = sbqqList[0].SBQQ__Quantity__c;
        //sub.SBQQ__Product__c = sbqqList[0].SBQQ__Product__c;
        sub.SBQQ__TerminatedDate__c = null;
        sub.SBQQ__RequiredById__c = 'a0t1D000002waFYQAY';
        sub.Subscription_Line_Status__c = 'New';
        //sub.SBQQ__SubscriptionType__c = 'Renewable';
        sub.SBQQ__Product__c = prodList[0].Id;
        insert sub;*/
        List<SBQQ__Subscription__c> subscriptionList = SB_TestCPQDataUtility.createSubscriptions(contractRec,productList);
        subscriptionList[0].SBQQ__RenewalQuantity__c = 96;
        subscriptionList[1].SBQQ__RenewalQuantity__c = 96;
        subscriptionList[2].SBQQ__RenewalQuantity__c = 96;
        subscriptionList[0].SBQQ__QuoteLine__c = sbqqList[0].id;
        subscriptionList[1].SBQQ__QuoteLine__c = sbqqList[1].id;
        subscriptionList[2].SBQQ__QuoteLine__c = sbqqList[2].id;
        //SBQQ.TriggerControl.disable();
        insert subscriptionList;
        //SBQQ.TriggerControl.enable();
        
       // subscriptionList[1].Required_By_Lookup__c = subscriptionList[0].Id;
       // subscriptionList[2].Required_By_Lookup__c = subscriptionList[0].Id;
        subscriptionList[1].SBQQ__RequiredById__c = subscriptionList[0].Id;
        subscriptionList[2].SBQQ__RequiredById__c = subscriptionList[0].Id; 
        subscriptionList[2].SBQQ__TerminatedDate__c = null;
        system.debug('3rd query'+limits.getQueries());
        //SBQQ.TriggerControl.disable();
        update subscriptionList;
        //SBQQ.TriggerControl.enable();
        
        /*List<SBQQ__Subscription__c> sbqqSubscriptionList = [SELECT Id, Platform_SKU_Number__c,SBQQ__RequiredById__c, SBQQ__TerminatedDate__c,
                                                            SBQQ__StartDate__c, SBQQ__EndDate__c,SBQQ__RevisedSubscription__c
                                                            FROM SBQQ__Subscription__c WHERE Id =:sub.Id];
        Map<id,SBQQ__Subscription__c> oldmap = new Map<id,SBQQ__Subscription__c>();
        oldmap.put(sub.Id, sub);
        SubscriptionTriggerHelper.updateParentContract(sbqqSubscriptionList, oldmap);
        SubscriptionTriggerHelper.updatePlatformSKUOnPhantom(sbqqSubscriptionList, oldmap);*/
        Test.stopTest();
    }
    
    @isTest
    static void unitTest2(){
        List<Account> accList = SB_TestCPQDataUtility.createAccount(1);
        insert accList;
        String oppName = 'Test Opportunity';
        String accId = accList[0].Id;
        String recordTypeId = '0121D0000032zdVQAQ';
        String prodName = 'Test Product';
        String prodCode = 'ZCES-SUP-PREM';
        String subsType = 'Renewable';
        String priceMeter = 'Per User Per Year';
        Date startDate = Date.valueOf('2021-08-01');
        Date endDate = Date.valueOf('2021-08-11');
        Double quantity = 12.1;
        Partner_Incentive__c pi = SB_TestCPQDataUtility.createPartnerIncentive(1,accId,true,system.today()+365,system.today()-30,'Summit - Discount','MSP')[0];
        pi.Default__c=true;
        insert pi;
        
        //List<Product2> prodList = SB_TestCPQDataUtility.createProduct(1, prodName, prodCode, subsType, priceMeter);
        List<Product2> productList=new List<Product2>();
        productList = (SB_TestCPQDataUtility.createProduct(4,'Zscaler Internet Access','ZIA-','Renewable','Per User Per Year'));
        productList[0].ProductCode = '';
        productList[0].Pricing_Meter__c = '';
        productList[0].SBQQ__SubscriptionType__c = 'Renewable';
        productList[1].SBQQ__SubscriptionType__c = 'Renewable';
        productList[2].Platform_SKU_Number__c = 1;
        productList[3].Platform_SKU_Number__c = 2;
        insert productList;
        
        List<PriceBook2> priceBiikList = SB_TestCPQDataUtility.createCustomPriceBooks(1);
        List<opportunity> oppList = SB_TestCPQDataUtility.createOpportunity(1, oppName, accId);
        oppList[0].RecordTypeId = oppRenewal;
        insert oppList;
        
        Test.startTest();
        //List<SBQQ__Quote__c> quoteList = SB_TestCPQDataUtility.createQuote (1, oppList[0].Id, accId, accId, accId, quoteRenewal);
        SBQQ__Quote__c quoteRec = SB_TestCPQDataUtility.createQuote(1, oppList[0].Id, accId, accId,accId,quoteRenewal)[0];
        quoteRec.Partner_Incentive__c = pi.Id;
        quoteRec.Early_Renewal__c = TRUE;
        quoteRec.Partner_Program__c = 'Summit - Discount';
        insert quoteRec;
        
        Date qlDate = system.today() + (365*3);
        Contract contractRec = SB_TestCPQDataUtility.createContracts(accId, accId, accId,pi,1)[0];
        List<SBQQ__QuoteLine__c> sbqqList = new List<SBQQ__QuoteLine__c>();
        sbqqList= (SB_TestCPQDataUtility.createQuoteLine(4, quoteRec.Id, productList[0].Id, system.today(), qlDate,50));
        sbqqList[1].SBQQ__Product__c = productList[1].Id;
        sbqqList[2].SBQQ__Product__c = productList[2].Id;
        sbqqList[3].SBQQ__Product__c = productList[3].Id;
        sbqqList[0].SBQQ__Number__c = 1;
        sbqqList[1].SBQQ__Number__c = 2;
        sbqqList[2].SBQQ__Number__c = 3;
        sbqqList[3].SBQQ__Number__c = 4;
        insert sbqqList;
        
        //List<SBQQ__QuoteLine__c> sbqqList = SB_TestCPQDataUtility.createQuoteLine (1, quoteList[0].Id,prodList[0].Id,startDate, endDate ,quantity);
        //List<SBQQ__Subscription__c> sbqqSubscriptionList = SB_TestCPQDataUtility.createSubscriptions(contractList[0], sbqqList);
        /*SBQQ__Subscription__c sub = new SBQQ__Subscription__c();
        sub.SBQQ__Contract__c = contractList[0].Id;
        sub.SBQQ__Account__c = contractList[0].AccountId;
        sub.SBQQ__Quantity__c = sbqqList[0].SBQQ__Quantity__c;
        //sub.SBQQ__Product__c = sbqqList[0].SBQQ__Product__c;
        sub.SBQQ__TerminatedDate__c = null;
        sub.SBQQ__RequiredById__c = 'a0t1D000002waFYQAY';
        sub.Subscription_Line_Status__c = 'New';
        //sub.SBQQ__SubscriptionType__c = 'Renewable';
        sub.SBQQ__Product__c = prodList[0].Id;
        insert sub;*/
        List<SBQQ__Subscription__c> subscriptionList = SB_TestCPQDataUtility.createSubscriptions(contractRec,productList);
        subscriptionList[0].SBQQ__RenewalQuantity__c = 96;
        subscriptionList[1].SBQQ__RenewalQuantity__c = 96;
        subscriptionList[2].SBQQ__RenewalQuantity__c = 96;
        subscriptionList[0].SBQQ__QuoteLine__c = sbqqList[0].id;
        subscriptionList[1].SBQQ__QuoteLine__c = sbqqList[1].id;
        subscriptionList[2].SBQQ__QuoteLine__c = sbqqList[2].id;
        //SBQQ.TriggerControl.disable();
        insert subscriptionList;
        //SBQQ.TriggerControl.enable();
        
       // subscriptionList[1].Required_By_Lookup__c = subscriptionList[0].Id;
       // subscriptionList[2].Required_By_Lookup__c = subscriptionList[0].Id;
        subscriptionList[1].SBQQ__RequiredById__c = subscriptionList[0].Id;
        subscriptionList[2].SBQQ__RequiredById__c = subscriptionList[0].Id; 
        subscriptionList[2].SBQQ__RevisedSubscription__c  = subscriptionList[1].Id;
        subscriptionList[2].SBQQ__TerminatedDate__c = null;
        subscriptionList[2].SBQQ__RenewedDate__c = System.today().addDays(10);
        system.debug('3rd query'+limits.getQueries());
        //SBQQ.TriggerControl.disable();
        update subscriptionList;
        //SBQQ.TriggerControl.enable();

        Test.stopTest();
    }
    
    @isTest
    static void unitTest3(){
        List<Account> accList = SB_TestCPQDataUtility.createAccount(1);
        insert accList;
        String oppName = 'Test Opportunity 2';
        String accId = accList[0].Id;
        String recordTypeId = oppRenewal;
        String prodName = 'Test Product';
        String prodCode = 'ZCES-SUP-PREM';
        String subsType = 'Renewable';
        String priceMeter = 'Per User Per Year';
        Date startDate = Date.valueOf('2021-08-01');
        Date endDate = Date.valueOf('2021-08-11');
        Double quantity = 12.1;
        
        Partner_Incentive__c pi = SB_TestCPQDataUtility.createPartnerIncentive(1,accId,true,system.today()+365,system.today()-30,'Summit - Discount','MSP')[0];
        pi.Default__c=true;
        insert pi;
        
        List<Product2> productList=new List<Product2>();
        productList = (SB_TestCPQDataUtility.createProduct(4,'Zscaler Internet Access','ZIA-','Renewable','Per User Per Year'));
        productList[0].ProductCode = '';
        productList[0].Pricing_Meter__c = '';
        productList[2].Platform_SKU_Number__c = 1;
        productList[3].Platform_SKU_Number__c = 2;
        insert productList;
        
        List<PriceBook2> priceBiikList = SB_TestCPQDataUtility.createCustomPriceBooks(1);
        List<opportunity> oppList = SB_TestCPQDataUtility.createOpportunity(1, oppName, accId);
        oppList[0].RecordTypeId = oppRenewal;
        insert oppList;
        
        Test.startTest();
        SBQQ__Quote__c quoteRec = SB_TestCPQDataUtility.createQuote(1, oppList[0].Id, accId, accId,accId,quoteRenewal)[0];
        quoteRec.Partner_Incentive__c = pi.Id;
        quoteRec.Early_Renewal__c = TRUE;
        quoteRec.Partner_Program__c = 'Summit - Discount';
        insert quoteRec;
        
        Date qlDate = system.today() + (365*3);
        Contract contractRec = SB_TestCPQDataUtility.createContracts(accId, accId, accId,pi,1)[0];
        
        List<SBQQ__QuoteLine__c> sbqqList = new List<SBQQ__QuoteLine__c>();
        sbqqList= (SB_TestCPQDataUtility.createQuoteLine(4, quoteRec.Id, productList[0].Id, system.today(), qlDate,50));
        sbqqList[1].SBQQ__Product__c = productList[1].Id;
        sbqqList[2].SBQQ__Product__c = productList[2].Id;
        sbqqList[3].SBQQ__Product__c = productList[3].Id;
        sbqqList[0].SBQQ__Number__c = 1;
        sbqqList[1].SBQQ__Number__c = 2;
        sbqqList[2].SBQQ__Number__c = 3;
        sbqqList[3].SBQQ__Number__c = 4;
        insert sbqqList;
        
        List<SBQQ__Subscription__c> subscriptionList = SB_TestCPQDataUtility.createSubscriptions(contractRec,productList);
        subscriptionList[0].SBQQ__RenewalQuantity__c = 96;
        subscriptionList[1].SBQQ__RenewalQuantity__c = 96;
        subscriptionList[2].SBQQ__RenewalQuantity__c = 96;
        subscriptionList[0].SBQQ__QuoteLine__c = sbqqList[0].id;
        subscriptionList[1].SBQQ__QuoteLine__c = sbqqList[1].id;
        subscriptionList[2].SBQQ__QuoteLine__c = sbqqList[2].id;
        subscriptionList[1].Subscription_Line_Status__c = 'New';
        subscriptionList[2].Subscription_Line_Status__c = 'New';
        insert subscriptionList;
        
        subscriptionList[0].SBQQ__SubscriptionEndDate__c = system.today()+(365*2);
        subscriptionList[0].SBQQ__TerminatedDate__c = null;
        
        subscriptionList[1].SBQQ__RequiredById__c = subscriptionList[0].Id;
        subscriptionList[2].SBQQ__RequiredById__c = subscriptionList[0].Id; 
        subscriptionList[2].SBQQ__RevisedSubscription__c  = subscriptionList[1].Id;
        subscriptionList[2].SBQQ__TerminatedDate__c = null;
        subscriptionList[3].SBQQ__TerminatedDate__c = null;
        subscriptionList[2].SBQQ__RenewedDate__c = System.today().addDays(10);
        update subscriptionList;

        Test.stopTest();
    }
    
    @isTest
    static void unitTest4(){
    	List<Account> accList = SB_TestCPQDataUtility.createAccount(1);
        insert accList;
        String oppName = 'Test Opportunity 2';
        String accId = accList[0].Id;
        String recordTypeId = oppRenewal;
        String prodName = 'Test Product';
        String prodCode = 'ZCES-SUP-PREM';
        String subsType = 'Renewable';
        String priceMeter = 'Per User Per Year';
        Date startDate = Date.valueOf('2021-08-01');
        Date endDate = Date.valueOf('2021-08-11');
        Double quantity = 12.1;
        
        Partner_Incentive__c pi = SB_TestCPQDataUtility.createPartnerIncentive(1,accId,true,system.today()+365,system.today()-30,'Summit - Discount','MSP')[0];
        pi.Default__c=true;
        insert pi;
        
        List<Product2> productList=new List<Product2>();
        Product2 objProd = new Product2();
        objProd.Name = 'ZPA Business Edition';
        objProd.ProductCode = 'ZPA-BUS';
        objProd.isActive = true;   
        objProd.SBQQ__SubscriptionType__c = 'Renewable';   
        objProd.SBQQ__SubscriptionTerm__c=12;
        objProd.Pricing_Meter__c='Per User Per Year';   
        productList.add(objProd);
        Product2 objProd1 = new Product2();
        objProd1.Name = 'ZIA Business Edition';
        objProd1.ProductCode = 'ZIA-BUS-BUNDLE';
        objProd1.isActive = true;   
        objProd1.SBQQ__SubscriptionType__c = 'Renewable';   
        objProd1.SBQQ__SubscriptionTerm__c=12;
        objProd1.Pricing_Meter__c='Per User Per Year';   
        productList.add(objProd1);
        Product2 objProd2 = new Product2();
        objProd2.Name = 'ZIA Prof Edition';
        objProd2.ProductCode = 'ZIA-PRO-BUNDLE';
        objProd2.isActive = true;   
        objProd2.SBQQ__SubscriptionType__c = 'Renewable';   
        objProd2.SBQQ__SubscriptionTerm__c=12;
        objProd2.Pricing_Meter__c='Per User Per Year';   
        productList.add(objProd2);
        insert productList;
        
        List<PriceBook2> priceBiikList = SB_TestCPQDataUtility.createCustomPriceBooks(1);
        List<opportunity> oppList = SB_TestCPQDataUtility.createOpportunity(1, oppName, accId);
        oppList[0].RecordTypeId = oppRenewal;
        insert oppList;
        
        Test.startTest();
        SBQQ__Quote__c quoteRec = SB_TestCPQDataUtility.createQuote(1, oppList[0].Id, accId, accId,accId,quoteRenewal)[0];
        quoteRec.Partner_Incentive__c = pi.Id;
        quoteRec.Early_Renewal__c = TRUE;
        quoteRec.Partner_Program__c = 'Summit - Discount';
        insert quoteRec;
        
        Date qlDate = system.today() + (365*3);
        Contract contractRec = SB_TestCPQDataUtility.createContracts(accId, accId, accId,pi,1)[0];
        
        List<SBQQ__QuoteLine__c> sbqqList = new List<SBQQ__QuoteLine__c>();
        sbqqList= (SB_TestCPQDataUtility.createQuoteLine(4, quoteRec.Id, productList[0].Id, system.today(), qlDate,50));
        sbqqList[1].SBQQ__Product__c = productList[1].Id;
        sbqqList[2].SBQQ__Product__c = productList[2].Id;
        sbqqList[0].SBQQ__Number__c = 1;
        sbqqList[1].SBQQ__Number__c = 2;
        sbqqList[2].SBQQ__Number__c = 3;
        insert sbqqList;
        
        List<SBQQ__Subscription__c> subscriptionList = SB_TestCPQDataUtility.createSubscriptions(contractRec,productList);
        subscriptionList[0].SBQQ__RenewalQuantity__c = 96;
        subscriptionList[1].SBQQ__RenewalQuantity__c = 96;
        subscriptionList[2].SBQQ__RenewalQuantity__c = 96;
        subscriptionList[0].SBQQ__QuoteLine__c = sbqqList[0].id;
        subscriptionList[1].SBQQ__QuoteLine__c = sbqqList[1].id;
        subscriptionList[2].SBQQ__QuoteLine__c = sbqqList[2].id;
        subscriptionList[1].Subscription_Line_Status__c = 'New';
        subscriptionList[2].Subscription_Line_Status__c = 'New';
        insert subscriptionList;
        
        subscriptionList[0].SBQQ__SubscriptionEndDate__c = system.today()+(365*2);
        subscriptionList[1].SBQQ__SubscriptionEndDate__c = system.today()+(365*2);
        subscriptionList[2].SBQQ__SubscriptionEndDate__c = system.today()+(365*2);
        update subscriptionList;

        Test.stopTest();    
    }
    
}