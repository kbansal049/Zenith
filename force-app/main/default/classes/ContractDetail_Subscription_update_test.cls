@isTest
public class ContractDetail_Subscription_update_test {
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
	static testmethod void test1(){
        Account account = new Account(Name = 'Test Account');
        insert account;
        
        Id PricebookID=Test.getStandardPricebookId();
        
        //Insert Products
        List<Product2> listProduct = new list<Product2>();
        listProduct.add(createProduct('Zscaler Enterprise Guest Wi-Fi Security', 'ZSC-ENT-GWIFI-3YR-A', 'Products', 'Standalone'));
        listProduct.add(createProduct('Product2', 'ZCES-SUP-PREM', 'Products', 'Standalone'));
        listProduct.add(createProduct('Product3', 'CODE03', 'Products', 'Standalone'));
        listProduct.add(createProduct('Zscaler Enterprise Guest Wi-Fi Security', 'ZSC-ENT-GWIFI-3YR-A', 'Zscaler Products', 'Standalone'));
        listProduct.add(createProduct('Product22', 'ZCES-SUP-PREM', 'Zscaler Products', 'Standalone'));
        listProduct.add(createProduct('Product33', 'CODE04', 'Zscaler Products', 'Standalone'));
        insert listProduct;
        
        Opportunity opportunity = new Opportunity(Name = 'Test Opportunity', CloseDate = Date.today() + 30, StageName = label.Stage_1_Alignment /*'1 - Qualified and Budgeted'*/, Type = 'New Business', AccountId = account.Id, Netsuite_Sales_Order_No__c = 'Test Order 1');
        insert opportunity;

        SBQQ__Quote__c proposal = new SBQQ__Quote__c(SBQQ__Account__c=account.Id, Proposal_Name__c = 'Test Proposal', SBQQ__Opportunity2__c = opportunity.Id, SBQQ__StartDate__c = Date.today(), SBQQ__EndDate__c = Date.today() + 365, Price_List__c = 'FY21 Volume Tier Price List');
        insert proposal;
        
        List<SBQQ__QuoteLine__c> qlList = new List<SBQQ__QuoteLine__c>();
        SBQQ__QuoteLine__c ql1 = new SBQQ__QuoteLine__c();
        ql1.SBQQ__Product__c = listProduct[0].Id;
        ql1.SBQQ__StartDate__c = Date.Today();
        ql1.SBQQ__EndDate__c = Date.Today() + 365;
        ql1.SBQQ__Quantity__c = 100;
        ql1.SBQQ__Quote__c = proposal.Id;
        qlList.add(ql1);
        
        SBQQ__QuoteLine__c ql2 = new SBQQ__QuoteLine__c();
        ql2.SBQQ__Product__c = listProduct[1].Id;
        ql2.SBQQ__StartDate__c = Date.Today();
        ql2.SBQQ__EndDate__c = Date.Today() + 365;
        ql2.SBQQ__Quantity__c = 100;
        ql2.SBQQ__Quote__c = proposal.Id;
        qlList.add(ql2);
        
        SBQQ__QuoteLine__c ql3 = new SBQQ__QuoteLine__c();
        ql3.SBQQ__Product__c = listProduct[1].Id;
        ql3.SBQQ__StartDate__c = Date.Today();
        ql3.SBQQ__EndDate__c = Date.Today() + 365;
        ql3.SBQQ__Quantity__c = 1000;
        ql3.SBQQ__Quote__c = proposal.Id;
        qlList.add(ql3);
        
        insert qlList;
        
        Order o = new Order(name = 'Test Order 1', AccountId = account.Id, Order_Date__c = date.today(), NS_Sales_Order_Number__c = 'S24867', EffectiveDate = date.today(), EndDate=date.today().adddays(200), Status = 'Draft', Location__c = 'Americas');
        insert o;
        
        contract con = new contract();
        con.AccountId = account.Id;
        con.StartDate = Date.Today();
        con.EndDate = Date.Today() + 365;
        con.ContractTerm = 12;
        insert con;
        
        List<SBQQ__Subscription__c> subList = new List<SBQQ__Subscription__c>();
        SBQQ__Subscription__c sb1 = new SBQQ__Subscription__c();
        sb1.SBQQ__Product__c = listProduct[0].Id;
        sb1.SBQQ__SubscriptionStartDate__c = Date.Today();
        sb1.SBQQ__SubscriptionEndDate__c = Date.Today() + 365;
        sb1.SBQQ__Quantity__c = 100;
        sb1.SBQQ__Account__c = account.Id;
        sb1.Net_Total__c = 1000;
        sb1.Sales_Order__c = o.Id;
        sb1.SBQQ__QuoteLine__c = ql1.Id;
        subList.add(sb1);
        
        SBQQ__Subscription__c sb2 = new SBQQ__Subscription__c();
        sb2.SBQQ__Product__c = listProduct[1].Id;
        sb2.SBQQ__SubscriptionStartDate__c = Date.Today();
        sb2.SBQQ__SubscriptionEndDate__c = Date.Today() + 365;
        sb2.SBQQ__Quantity__c = 100;
        sb2.SBQQ__Account__c = account.Id;
        sb2.Net_Total__c = 1000;
        sb2.Sales_Order__c = o.Id;
        sb2.Is_Ramped__c = true;
        sb2.SBQQ__QuoteLine__c = ql2.Id;
        subList.add(sb2);
        
        SBQQ__Subscription__c sb3 = new SBQQ__Subscription__c();
        sb3.SBQQ__Product__c = listProduct[1].Id;
        sb3.SBQQ__SubscriptionStartDate__c = Date.Today();
        sb3.SBQQ__SubscriptionEndDate__c = Date.Today() + 365;
        sb3.SBQQ__Quantity__c = 1000;
        sb3.SBQQ__Account__c = account.Id;
        sb3.Net_Total__c = 1000;
        sb3.Sales_Order__c = o.Id;
        sb3.Is_Ramped__c = true;
        sb3.SBQQ__QuoteLine__c = ql3.Id;
        subList.add(sb3);
        
        insert subList;
        
        //Create Contractdetails
        List<Contract_Detail__c> contractDetailList = new List<Contract_Detail__c>();
        Contract_Detail__c contractDetail1 = new Contract_Detail__c();
        contractDetail1.Name = 'Migrate as is';
        contractDetail1.Account_Name__c = account.Id;
        contractDetail1.Product_Name__c = listProduct[0].Id;
        contractDetail1.Start_Date__c = Date.Today();
        contractDetail1.End_Date__c = Date.Today() + 365;
        contractDetail1.Quantity__c = 100;
        contractDetail1.Amount_USD__c = 1000;
        contractDetail1.Contract_No__c = '100';
        contractDetail1.MRR_USD__c = 100;
        contractDetail1.List_Price__c = 100;
        contractDetail1.Discount__c = 10;
        contractDetail1.Needs_to_Be_Migrated_to_Asset_Line__c = true;
        contractDetail1.Sales_Order__c = o.Id;
        contractDetail1.Product_SKU__c = 'ZSC-ENT-GWIFI-3YR-A';
        contractDetail1.Contract_Detail_Status__c = 'Active';
        contractDetailList.add(contractDetail1);
        
        //Product2 product2 = [Select Id From Product2 Where ProductCode = 'ZSUITE-WEBSTD-1YR' Limit 1];
        Contract_Detail__c contractDetail2 = new Contract_Detail__c();
        contractDetail2.Name = 'Split';
        contractDetail2.Account_Name__c = account.Id;
        contractDetail2.Product_Name__c = listProduct[1].Id;
        contractDetail2.Start_Date__c = Date.Today();
        contractDetail2.End_Date__c = Date.Today() + 365;
        contractDetail2.Quantity__c = 100;
        contractDetail2.Amount_USD__c = 1000;
        contractDetail2.Contract_No__c = '100';
        contractDetail2.MRR_USD__c = 100;
        contractDetail2.List_Price__c = 100;
        contractDetail2.Discount__c = 10;
        contractDetail2.Needs_to_Be_Migrated_to_Asset_Line__c = true;
        contractDetail2.Sales_Order__c = o.Id;
        contractDetail2.Contract_Detail_Status__c = 'Active';
        contractDetailList.add(contractDetail2);
        
        //Product2 product2 = [Select Id From Product2 Where ProductCode = 'ZSUITE-WEBSTD-1YR' Limit 1];
        Contract_Detail__c contractDetail3= new Contract_Detail__c();
        contractDetail3.Name = 'Split';
        contractDetail3.Account_Name__c = account.Id;
        contractDetail3.Product_Name__c = listProduct[1].Id;
        contractDetail3.Start_Date__c = Date.Today();
        contractDetail3.End_Date__c = Date.Today() + 365;
        contractDetail3.Quantity__c = 1000;
        contractDetail3.Amount_USD__c = 1000;
        contractDetail3.Contract_No__c = '100';
        contractDetail3.MRR_USD__c = 100;
        contractDetail3.List_Price__c = 100;
        contractDetail3.Discount__c = 10;
        contractDetail3.Needs_to_Be_Migrated_to_Asset_Line__c = true;
        contractDetail3.Sales_Order__c = o.Id;
        contractDetail3.Contract_Detail_Status__c = 'Active';
        contractDetailList.add(contractDetail3);
        
        insert contractDetailList;
        
        ContractDetail_Subscription_update batch;
        Date sd = Date.Today();
        Date ed = Date.Today();
        String startdate = sd.year() + '-' + sd.month() + '-' + sd.day() + ' 00:00:00';
        String enddate = ed.year() + '-' + ed.month() + '-' + ed.day() + ' 23:59:59';
        String query = 'SELECT Id from Account';
        batch = new ContractDetail_Subscription_update(startdate,enddate,query);
        Database.executeBatch(batch,1);
        
    }
    
    public static Product2 createProduct(String PRoductName, String pcode, String pfamily, String sConfigType) {
        Product2 productSO = new Product2();
        productSO.Name = ProductName;
        productSO.Family = pfamily;
        productSO.ProductCode = pcode;
        productSO.IsActive = true;
        return productSO;
    }
}