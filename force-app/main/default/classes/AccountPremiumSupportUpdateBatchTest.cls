//Test Class for Class - AccountPremiumSupportUpdateBatch
@isTest
public class AccountPremiumSupportUpdateBatchTest {

    //private static String quoteRenewal = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByDeveloperName().get('Renewal').getRecordTypeId();
    //private static String oppRenewal = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Renewal_Opportunity').getRecordTypeId();

    @TestSetup
    static void setupData(){
        
        createCustomSettings();

        List<Account> accList = SB_TestCPQDataUtility.createAccount(1);
        accList[0].Premium_Support_Type__c = 'Premium Support Plus-24';
        insert accList;
       
        String accId = accList[0].Id;
        String prodCode = 'ZCES-SUP-PREM';
        /*String oppName = 'Test Opportunity';
        String recordTypeId = '0121D0000032zdVQAQ';
        String prodName = 'Test Product';
        String subsType = 'Renewable';
        String priceMeter = 'Per User Per Year';
        Date startDate = Date.valueOf('2021-08-01');
        Date endDate = Date.valueOf('2021-08-11');
        Double quantity = 12.1;*/
        Partner_Incentive__c pi = SB_TestCPQDataUtility.createPartnerIncentive(1,accId,true,system.today()+365,system.today()-30,'Summit - Discount','MSP')[0];
        pi.Default__c=true;
        
        List<Product2> productList=new List<Product2>();
        productList = (SB_TestCPQDataUtility.createProduct(2,'Premium Support',prodCode,'Renewable','Per User Per Year'));
        productList[0].Name = 'Premium Support';
        productList[1].Name = 'Dedicated TAM';
        productList[0].ProductCode = prodCode;
        productList[1].ProductCode = 'ZCES-SUP-DED-TAM';
        insert productList;

        Order sorder = new Order(name = 'Test Order 1', AccountId = accList[0].Id, Order_Date__c = date.today(), NS_Sales_Order_Number__c = 'S24867', EffectiveDate = date.today(), EndDate=date.today().adddays(100), Status = 'Draft', Location__c = 'Americas');
        insert sorder;

        List<Contract_Detail__c> conDetail = new List<Contract_Detail__c>();            
            
        Contract_Detail__c  contract = new Contract_Detail__c();
        contract.Name = 'Premium Support Contract Detail';
        contract.Account_Name__c = accList[0].Id;        
        contract.Quantity__c = 5000;
        contract.Contract_Detail_Status__c = 'Active';
        contract.Product_Name__c = productList[0].Id;
        contract.Do_not_Aggregate__c = false;
        contract.Override_Contract_Detail_Status__c = false;
        contract.Start_Date__c = Date.today().addDays(-100);
        contract.End_Date__c = Date.today().addDays(100);
        contract.Amount_USD__c = 50000.00;
        contract.ZScaler_Product_Family__c = 'Support';
        contract.Country_Language__c = 'United States';
        contract.Is_Bundle_SKU__c = false;
        contract.Premium_Support_ACV_Number__c = 50000;
        contract.Support_Type_Name__c = 'Premium Support Plus-16';
        contract.Support_Type_Product_Code__c = 'ZCES-SUP-PREM-16';
        contract.Sales_Order__c = sorder.id;
        contract.Product_SKU__c=prodCode;
        contract.Price_Per_User__c=500.00;
        conDetail.add(contract);
        
        Contract_Detail__c  contract1 = new Contract_Detail__c();
        contract1.Name = 'Dedicated TAM Contract Detail';
        contract1.Account_Name__c = accList[0].Id;        
        contract1.Quantity__c = 5000;
        contract1.Contract_Detail_Status__c = 'Active';
        contract1.Product_Name__c = productList[1].Id;
        contract1.Do_not_Aggregate__c = false;
        contract1.Override_Contract_Detail_Status__c = false;
        contract1.Start_Date__c = Date.today().addDays(-100);
        contract1.End_Date__c = Date.today().addDays(100);
        contract1.Amount_USD__c = 50000.00;
        contract1.ZScaler_Product_Family__c = 'Support';
        contract1.Is_Bundle_SKU__c = false;
        contract1.Sales_Order__c = sorder.id;
        contract1.Product_SKU__c='ZCES-SUP-DED-TAM';
        contract1.Price_Per_User__c=500.00;
        conDetail.add(contract1);
        
        insert conDetail;
        
        /* List<PriceBook2> priceBiikList = SB_TestCPQDataUtility.createCustomPriceBooks(1);
        List<opportunity> oppList = SB_TestCPQDataUtility.createOpportunity(1, oppName, accId);
        oppList[0].RecordTypeId = oppRenewal;
        insert oppList;
        
        //List<SBQQ__Quote__c> quoteList = SB_TestCPQDataUtility.createQuote (1, oppList[0].Id, accId, accId, accId, quoteRenewal);
        SBQQ__Quote__c quoteRec = SB_TestCPQDataUtility.createQuote(1, oppList[0].Id, accId, accId,accId,quoteRenewal)[0];
        quoteRec.Partner_Incentive__c = pi.Id;
        quoteRec.Partner_Program__c = 'Summit - Discount';
        insert quoteRec;
        
        Date qlDate = system.today() + (365*3);

        SBQQ.TriggerControl.disable();
        Contract contractRec = SB_TestCPQDataUtility.createContracts(accId, accId, accId,pi,1)[0];
        contractRec.Status = 'Draft';
        insert contractRec;
        contractRec.Status = 'Activated';
        update contractRec;
        List<SBQQ__QuoteLine__c> sbqqList = new List<SBQQ__QuoteLine__c>();
        sbqqList= (SB_TestCPQDataUtility.createQuoteLine(2, quoteRec.Id, productList[0].Id, system.today(), qlDate,50));
        sbqqList[1].SBQQ__Product__c = productList[1].Id;
        sbqqList[0].SBQQ__Number__c = 1;
        sbqqList[1].SBQQ__Number__c = 2;
        insert sbqqList;
        
        List<SBQQ__Subscription__c> subscriptionList = SB_TestCPQDataUtility.createSubscriptions(contractRec,productList);
        //subscriptionList[0].SBQQ__RenewalQuantity__c = 96;
        //subscriptionList[1].SBQQ__RenewalQuantity__c = 96;
        subscriptionList[0].SBQQ__QuoteLine__c = sbqqList[0].id;
        subscriptionList[1].SBQQ__QuoteLine__c = sbqqList[1].id;
        subscriptionList[0].SBQQ__SubscriptionStartDate__c = system.today()-10;
        subscriptionList[1].SBQQ__SubscriptionStartDate__c = system.today()-10;
        subscriptionList[0].SBQQ__SubscriptionEndDate__c = system.today()+(365*3);
        subscriptionList[1].SBQQ__SubscriptionEndDate__c = system.today()+(365*3);
        subscriptionList[0].Support_Type_Name__c = 'Premium Support Plus';
        subscriptionList[0].Support_Type_Product_Code__c = 'ZCES-SUP-PREM-PLUS';
        insert subscriptionList;

        subscriptionList[1].SBQQ__RequiredById__c = subscriptionList[0].Id;
        SBQQ.TriggerControl.enable(); */
        
    }
    
    @IsTest
    static void testBatch(){
        Account acc = [SELECT Id FROM Account Limit 1];
        Test.startTest();
        //Database.executeBatch(new AccountPremiumSupportUpdateBatch(), 200);
        Database.executeBatch(new AccountPremiumSupportUpdateBatch(new Set<Id>{acc.id}), 200);
        Test.stopTest();
        
    }

    public static void createCustomSettings(){
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
            SKUs_Referred_in_Renewal_Upsell_NS_Calc__c rec14 = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c(name='ZPA_Contract_Date', SKU_Codes__c = 'ZPA-BBA;ZPA-BUS;ZPA-ENT;ZPA-PRO;ZPA-PRO-LU;ZPA-BUS-LU;ZPA-BUS-EDITION;ZPA-PRO-EDITION;ZPA-BUS-EDITION-LU;ZIA-PRO-EDITION-LU;ZPA-TRANS-EDITION;ZPA-Remote-PRE;ZS-WFA-BUS-EDITION;ZPA-FED-BUNDLE;ZPA-ZFED-MODERATE');
            skuscs.add(rec14);
        }
        if(!mapSKUs.containsKey('ZDX_Contract_Date')){
            SKUs_Referred_in_Renewal_Upsell_NS_Calc__c rec15 = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c(name='ZDX_Contract_Date', SKU_Codes__c = 'ZDX-BUS-PRE;ZDX-ADV-PRE;ZIA-BUS-EDITION;ZIA-TRANS-EDITION;ZIA-ELA-EDITION;ZDX-ADVANCED;ZDX-ADV;ZDX-M365');
            skuscs.add(rec15);
        }
        if(!mapSKUs.containsKey('ZDX_Adv')){
            SKUs_Referred_in_Renewal_Upsell_NS_Calc__c rec16 = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c(name='ZDX_Adv', SKU_Codes__c = 'ZDX-BUS-PRE;ZDX-ADV-PRE;ZDX-ADVANCED;ZDX-ADV;ZDX-M365');
            skuscs.add(rec16);
        }
        if(!mapSKUs.containsKey('ZDX_Standard')){
            SKUs_Referred_in_Renewal_Upsell_NS_Calc__c rec17 = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c(name='ZDX_Standard', SKU_Codes__c = 'ZIA-BUS-EDITION;ZIA-TRANS-EDITION;ZIA-ELA-EDITION');
            skuscs.add(rec17);
        }

        if(!skuscs.isEmpty())
            insert skuscs;
    }
}//End of Class