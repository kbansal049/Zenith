@isTest
public class ContractDetailTriggerHelperTest{
    
    
     @testSetup static void setupdata(){
       
        Skip_Triggers__c skipTriggers = new Skip_Triggers__c();
        skipTriggers.Skip_Account_Triggers__c = true;
        skipTriggers.Skip_Opportunity_Triggers__c = true;
        skipTriggers.Skip_Account_Triggers__c = true; 
        skipTriggers.Name = 'SkipTriggers';
        insert skipTriggers;
         
        Account account = new Account(Name = 'Test Account');
        insert account;
              
        List<SKUs_Referred_in_Renewal_Upsell_NS_Calc__c> skuscs = new List<SKUs_Referred_in_Renewal_Upsell_NS_Calc__c>();
        skuscs.add(new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c(name='CFW_CSB_SKUs', SKU_Codes__c = 'ZFW-NG-WITH-LOG;ZSEC-WEB-ABA'));
        skuscs.add(new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c(name='CFW_ZPA_SKUs', SKU_Codes__c = 'ZFW-NG-WITH-LOG;ZIA-TRANS-BUNDLE;ZIA-ELA-BUNDLE'));
        skuscs.add(new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c(name='Credit_SKUs', SKU_Codes__c = 'ZCR-BuyBack;Z-ZPA-BuyBack;Z-CFWCSB-PROMO;Z-CFWZPA-Credit;Z-CREDIT'));
        skuscs.add(new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c(name='One_Time_SKU', SKU_Codes__c = 'ZCES-PRO-SVC;ZCES-DAS-PKG0;ZCES-DAS-PKG1;ZCES-DAS-PKG2;ZCES-DAS-PKG3;ZCES-DAS-PKG6;ZCES-EDU-CREDIT;ZCES-EDU-LABCREDIT;ZCES-Onetime-ZPA-INT'));
        skuscs.add(new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c(name='Recurring_SKU', SKU_Codes__c = 'ZCES-SUP-PREM;ZCES-SUP-PREM-SP;ZCES-SUP-TAMT'));
        skuscs.add(new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c(name='SKUs_not_To_ADD', SKU_Codes__c = 'ZCR-UPY4;ZCR-UPY5'));
        skuscs.add(new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c(name='SKUs_to_SKIP_ACV', SKU_Codes__c = 'ZCR-BuyBack;Z-ZPA-BuyBack;Z-CFWCSB-PROMO;Z-CFWZPA-Credit;Z-CREDIT;ZCR-UPY4;ZCR-UPY5'));
        skuscs.add(new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c(name='Uplift_SKUs', SKU_Codes__c = 'ZCR-UPY4;ZCR-UPY5'));
        skuscs.add(new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c(name='ZPA_Deployment_SKUs', SKU_Codes__c = 'ZCES-PRO-SVC;ZCES-DAS-PKG0;ZCES-DAS-PKG1;ZCES-DAS-PKG2;ZCES-DAS-PKG3;ZCES-DAS-PKG6;ZCES-EDU-CREDIT;ZCES-EDU-LABCREDIT'));
        skuscs.add(new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c(name='ZPA_Contract_Date', SKU_Codes__c = 'ZPA-BBA;ZPA-BUS;ZPA-ENT;ZPA-PRO;ZPA-PRO-LU;ZPA-BUS-LU;ZS-WFA-BUS-EDITION'));
        insert skuscs;
   
        List<Triggers_Switch__c> trlst = new List<Triggers_Switch__c>();
        Triggers_Switch__c tr1 = new Triggers_Switch__c(name = 'Execute_Contract_Detail_Product_Sync', Execute__c = true);
        Triggers_Switch__c tr2 = new Triggers_Switch__c(name = 'Execute_Contract_Detail_Account_Update', Execute__c = true);
        Triggers_Switch__c tr3 = new Triggers_Switch__c(name = 'Execute_Contract_Detail_Trigger', Execute__c = true);
        Triggers_Switch__c tr4 = new Triggers_Switch__c(name = 'Execute_Contract_Detail_Status', Execute__c = true);        
        Triggers_Switch__c tr5 = new Triggers_Switch__c(name = 'Count_Quantity_On_Contract_Trigger' , Execute__c =true);
        trlst.add(tr1);
        trlst.add(tr2);
        trlst.add(tr3);
        trlst.add(tr4);    
        trlst.add(tr5);
        insert trlst;
        
        // Added by Rajesh : CR# 1099 : Start
        
        List<SKUs_Referred_in_Renewal_Upsell_NS_Calc__c> skus = new List<SKUs_Referred_in_Renewal_Upsell_NS_Calc__c>();
        SKUs_Referred_in_Renewal_Upsell_NS_Calc__c ziaSKUs = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c();
        ziaSKUs.Name = 'ZIA_Contract_Date';
        ziaSKUs.SKU_Codes__c = 'ZSC-SIP;ZIA-PRO-BUNDLE;ZIA-BUS-BUNDLE;ZIA-TRANS-BUNDLE;ZCES-SUP-PREM;ZIA-ELA-BUNDLE;ZIA-PRO-BUNDLE-LU;ZIA-BUS-BUNDLE-LU;ZIA-TRANS-BUNDLE-LU;ZIA-ELA-BUNDLE-LU;ZSC-SIP-LOC;ZIA-SIP;ZS-WFA-BUS-EDITION';
        skus.add(ziaSKUs);
        
        SKUs_Referred_in_Renewal_Upsell_NS_Calc__c ziaSKUs1 = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c();
        ziaSKUs1.Name = 'ZIA_Contract_Date1';
        ziaSKUs1.SKU_Codes__c = 'ZS-WFA-BUS-EDITION';
        skus.add(ziaSKUs1);
        
        SKUs_Referred_in_Renewal_Upsell_NS_Calc__c zpaSKUs = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c();
        zpaSKUs.Name = 'ZPA_Contract_Date';
        zpaSKUs.SKU_Codes__c = 'ZPA-BBA;ZPA-BUS;ZPA-ENT;ZPA-PRO;ZPA-PRO-LU;ZPA-BUS-LU;ZPA-BUS-EDITION;ZPA-PRO-EDITION;ZPA-BUS-EDITION-LU;ZIA-PRO-EDITION-LU;ZPA-TRANS-EDITION;ZS-WFA-BUS-EDITION';
        skus.add(zpaSKUs);
        
        // Added by Rajesh : CR# 1251 : Start
        SKUs_Referred_in_Renewal_Upsell_NS_Calc__c zdxSKUs = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c();
        zdxSKUs.Name = 'ZDX_Contract_Date';
        zdxSKUs.SKU_Codes__c = 'ZPA-BBA;ZPA-BUS;ZPA-ENT;ZPA-PRO;ZPA-PRO-LU;ZPA-BUS-LU;ZPA-BUS-EDITION;ZPA-PRO-EDITION;ZPA-BUS-EDITION-LU;ZIA-PRO-EDITION-LU;ZPA-TRANS-EDITION';
        skus.add(zdxSKUs);
        // Added by Rajesh : CR# 1251 : End
        
        insert skus;
        
        // Added by Rajesh : CR# 1099 : End
        
        Contract_Sku_Bundle_Type__c    ZIA_ELA_BUNDLE_Setting = new Contract_Sku_Bundle_Type__c();
        ZIA_ELA_BUNDLE_Setting.name = 'ZIA-ELA-BUNDLE';
        ZIA_ELA_BUNDLE_Setting.value__c = 'ZIA-ELA-BUNDLE';
        insert ZIA_ELA_BUNDLE_Setting;
        
        Contract_4GB_Sku_Type__c   ZIA_4GB_BUNDLE_Setting = new Contract_4GB_Sku_Type__c();
        ZIA_4GB_BUNDLE_Setting.name = 'ZIA-SERVER-PRE';
        ZIA_4GB_BUNDLE_Setting.value__c = 'ZIA-SERVER-PRE';
        insert ZIA_4GB_BUNDLE_Setting;
        
        Contract_Detail_Sku__c  ZIA_BUNDLE_Setting = new Contract_Detail_Sku__c();
        ZIA_BUNDLE_Setting.name = 'ZIA-SERVER-EXTRA-GB-PRE';
        ZIA_BUNDLE_Setting.value__c = 'ZIA-SERVER-EXTRA-GB-PRE';
        insert ZIA_BUNDLE_Setting;
        
        List<Contract_Detail_Sku__c> SKU_Type_Setting = new List<Contract_Detail_Sku__c>();
        SKU_Type_Setting.add(new Contract_Detail_Sku__c(name = 'ZIA-GWIFI-GB',value__c = 'ZIA-GWIFI-GB'));
        SKU_Type_Setting.add(new Contract_Detail_Sku__c(name= 'ZIA-SERVER-GB',value__c = 'ZIA-SERVER-GB'));
        insert SKU_Type_Setting;

        //IBA-4095 - Start
        List<Contract_Date_SKUs__c> contractDateSKUs = new List<Contract_Date_SKUs__c>();
        contractDateSKUs.add(new Contract_Date_SKUs__c(name='ZDX_SKUs_1',Family__c='ZDX',SKU_Codes__c='ZIA-TRANS-EDITION-LU;ZIA-TFORM-EDITION;ZIA-TFORM-EDITION-LU;ZDX-M-365;ZDX-ADV-PLUS;ZS-USER-BIZ-EDITION;ZS-USER-TFORM-EDITION;ZS-USER-ELA-EDITION;ZS-USER-BIZ-EDITION-LU;ZS-USER-TFORM-EDITION-LU;ZS-USER-ELA-EDITION-LU;'));
        contractDateSKUs.add(new Contract_Date_SKUs__c(name='ZIA_SKUs_1',Family__c='ZIA',SKU_Codes__c='ZIA-O365-PRE;ZIA-ESS-EDITION;ZIA-ESS-EDITION-LU;ZIA-BIZ-EDITION;ZIA-FED-ELA-EDITION;ZIA-FED-ELA-EDITION-LU;ZIA-PRO-EDITION-LU;ZIA-PROF-EDITION-LU;ZIA-TFORM-EDITION;ZIA-TFORM-EDITION-LU;ZIA-UNLTD-EDITION;ZIA-UNLTD-EDITION-LU;EDU-ZIA-SVC-EDGE-TRANS;'));
        contractDateSKUs.add(new Contract_Date_SKUs__c(name='ZIA_SKUs_2',Family__c='ZIA',SKU_Codes__c='ZIA-PRO-EDITION-LU;ZIA-BUS-EDITION-LU;ZIA-TRANS-EDITION-LU;ZIA-ELA-EDITION-LU;ZS-USER-BIZ-EDITION;ZS-USER-TFORM-EDITION;ZS-USER-ELA-EDITION;ZS-USER-BIZ-EDITION-LU;ZS-USER-TFORM-EDITION-LU;ZS-USER-ELA-EDITION-LU;'));
        contractDateSKUs.add(new Contract_Date_SKUs__c(name='ZPA_SKUs_1',Family__c='ZPA',SKU_Codes__c='ZPA-INTERNET-PRE;ZPA-BUS-100USERS-PROMO;ZPA-ESS-EDITION;ZPA-UNLTD-EDITION;ZPA-ESS-EDITION-LU;ZPA-UNLTD-EDITION-LU;ZPA-TFORM-EDITION-LU;ZPA-TFORM-EDITION;ZPA-TRANS-EDITION-LU;ZPA-BIZ-EDITION-LU;ZPA-BIZ-EDITION;ZPA-PRO-EDITION-LU;'));
        contractDateSKUs.add(new Contract_Date_SKUs__c(name='ZPA_SKUs_2',Family__c='ZPA',SKU_Codes__c='	ZPA-BUS-EDITION-100USERS-PROMO;ZS-USER-BIZ-EDITION;ZS-USER-TFORM-EDITION;ZS-USER-ELA-EDITION;ZS-USER-BIZ-EDITION-LU;ZS-USER-TFORM-EDITION-LU;ZS-USER-ELA-EDITION-LU;'));
        
        insert contractDateSKUs;
        //IBA-4095 - End         
    }
    
    static testmethod void test1(){
        
        Account account =[Select id, name from Account limit 1];

        
        Id PricebookID=Test.getStandardPricebookId();
        
        //Insert Products
        List<Product2> listProduct = new list<Product2>();
        listProduct.add(createProduct('Zscaler Enterprise Guest Wi-Fi Security', 'ZSC-ENT-GWIFI-3YR-A', 'Products', 'Standalone'));
        listProduct.add(createProduct('Product2', 'ZCES-SUP-PREM', 'Products', 'Standalone'));
        listProduct.add(createProduct('Product3', 'CODE03', 'Products', 'Standalone'));
        listProduct.add(createProduct('Zscaler Enterprise Guest Wi-Fi Security', 'ZSC-ENT-GWIFI-3YR-A', 'Zscaler Products', 'Standalone'));
        listProduct.add(createProduct('Product22', 'ZCES-SUP-PREM', 'Zscaler Products', 'Standalone'));
        listProduct.add(createProduct('Product33', 'CODE04', 'Zscaler Products', 'Standalone'));
        listProduct.add(createProduct('Product34', 'ZPA-BBA', 'Zscaler Products', 'Standalone'));
        listProduct.add(createProduct('Product34', 'ZIA-SERVER-PRE', 'Zscaler Products', 'Standalone'));
        listProduct.add(createProduct('Product34', 'ZIA-SERVER-EXTRA-GB-PRE', 'Zscaler Products', 'Standalone'));
        insert listProduct;
        
        
        Opportunity opportunity = new Opportunity(Pricebook2Id = PricebookID, Name = 'Test Opportunity', CloseDate = Date.today() + 30, StageName = label.Stage_1_Alignment /*'1 - Qualified and Budgeted'*/, Type = 'New Business', AccountId = account.Id, Netsuite_Sales_Order_No__c = 'Test Order 1');
        insert opportunity;

        
        Order o = new Order(name = 'Test Order 1', AccountId = account.Id, Order_Date__c = date.today(), NS_Sales_Order_Number__c = 'S24867', EffectiveDate = date.today(), EndDate=date.today().adddays(200), Status = 'Draft', Location__c = 'Americas');
        insert o;
              
        
        
        Test.startTest();
        

        
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
        contractDetail2.Start_Date__c = Date.Today() + 1;
        contractDetail2.End_Date__c = Date.Today() + 365;
        contractDetail2.Quantity__c = 100;
        contractDetail2.Amount_USD__c = 1000;
        contractDetail2.Contract_No__c = '100';
        contractDetail2.MRR_USD__c = 100;
        contractDetail2.List_Price__c = 100;
        contractDetail2.Discount__c = 10;
        contractDetail2.Needs_to_Be_Migrated_to_Asset_Line__c = true;
        contractDetail2.Sales_Order__c = o.Id;
        contractDetailList.add(contractDetail2);
        
        Contract_Detail__c contractDetail3 = new Contract_Detail__c();
        contractDetail3.Name = 'Split';
        contractDetail3.Account_Name__c = account.Id;
        contractDetail3.Product_Name__c = listProduct[6].Id;
        contractDetail3.Start_Date__c = Date.Today() + 1;
        contractDetail3.End_Date__c = Date.Today() + 365;
        contractDetail3.Quantity__c = 100;
        contractDetail3.Amount_USD__c = 1000;
        contractDetail3.Contract_No__c = '100';
        contractDetail3.MRR_USD__c = 100;
        contractDetail3.List_Price__c = 100;
        contractDetail3.Discount__c = 10;
        contractDetail3.Needs_to_Be_Migrated_to_Asset_Line__c = true;
        contractDetail3.Sales_Order__c = o.Id;
        contractDetailList.add(contractDetail3);
        
        
        
        TriggerUtility.startUpdateCountractDetails();
        
        System.debug('-=-=- begin -=- '+System.Limits.getQueries());
		
        insert contractDetailList;
        
        System.debug('-=-=- end -=- '+System.Limits.getQueries());
        
        
        
        //Added by Varun - CR 1068 - Start
        contractDetail1.MRR_USD__c = 25000;
        TriggerUtility.startUpdateCountractDetails();
        update contractDetailList;
        /*contractDetail1.Product_SKU__c = 'ZIA-ELA-BUNDLE';
        TriggerUtility.startUpdateCountractDetails();
        update contractDetailList;
        contractDetail1.Product_SKU__c = 'ZIA-SERVER-EXTRA-GB-PRE';
        TriggerUtility.startUpdateCountractDetails();
        update contractDetailList;*/
        //Added by Varun - CR 1068 - End
        TriggerUtility.startUpdateCountractDetails();
        delete contractDetail3;
        
        Test.stopTest();
        
        
        
        
        
    }
    
    
    
      //CR 977 start
    
    static testmethod void test2(){
        Test.startTest();
        Account account = new Account(Name = 'Test Account');
        insert account;
        Account_Extension__c ac = new Account_Extension__c(Account__c = account.id);
        insert ac;
        
        List<Product2> listProduct = new list<Product2>();
        listProduct.add(createProduct1('ZIA Enterprise License Agreement', 'ZIA-ELA-BUNDLE', 'ZIA'));
        insert listProduct;
        
        
        
        List<Contract_Detail__c> contractDetailList = new List<Contract_Detail__c>();
        Contract_Detail__c contractDetail1 = new Contract_Detail__c();
        contractDetail1.Name = 'test 1';
        contractDetail1.Account_Name__c = account.Id;
        contractDetail1.Product_Name__c = listProduct[0].Id;
        contractDetail1.Start_Date__c = Date.Today();
        contractDetail1.End_Date__c = Date.Today() + 365;
        contractDetail1.Quantity__c = 400000;
        contractDetail1.Amount_USD__c = 1000;
        contractDetail1.Contract_No__c = '100';
        contractDetail1.MRR_USD__c = 100;
        //contractDetail1.Product_SKU__c = listProduct[0].SKU_Type__c;
        contractDetail1.Contract_Detail_Status__c = 'Active';
        contractDetailList.add(contractDetail1);
        
        TriggerUtility.startUpdateCountractDetails();
        insert contractDetailList;
        TriggerUtility.startUpdateCountractDetails();
        delete contractDetailList;
        Test.stopTest();
        
    }
    
    static testmethod void test3(){
        Test.startTest();
        Account account = new Account(Name = 'Test Account');
        insert account;
        Account_Extension__c ac = new Account_Extension__c(Account__c = account.id);
        insert ac;
        
        List<Product2> listProduct = new list<Product2>();
        listProduct.add(createProduct1('Secure Internet Access for Servers', 'ZIA-SERVER-PRE', 'ZIA'));
        insert listProduct;
        
        
        
        List<Contract_Detail__c> contractDetailList = new List<Contract_Detail__c>();
        Contract_Detail__c contractDetail1 = new Contract_Detail__c();
        contractDetail1.Name = 'test 1';
        contractDetail1.Account_Name__c = account.Id;
        contractDetail1.Product_Name__c = listProduct[0].Id;
        contractDetail1.Start_Date__c = Date.Today();
        contractDetail1.End_Date__c = Date.Today() + 365;
        contractDetail1.Quantity__c = 400000;
        contractDetail1.Amount_USD__c = 1000;
        contractDetail1.Contract_No__c = '100';
        contractDetail1.MRR_USD__c = 100;
        //contractDetail1.Product_SKU__c = listProduct[0].SKU_Type__c;
        contractDetail1.Contract_Detail_Status__c = 'Active';
        contractDetailList.add(contractDetail1);
        
        TriggerUtility.startUpdateCountractDetails();
        insert contractDetailList;
        TriggerUtility.startUpdateCountractDetails();
        delete contractDetailList;
        Test.stopTest();
        
    }
    
    @isTest static void test4(){
        Test.startTest();
        Account account = new Account(Name = 'Test Account');
        insert account;
        Account_Extension__c ac = new Account_Extension__c(Account__c = account.id);
        insert ac;
        
        List<Product2> listProduct = new list<Product2>();
        listProduct.add(createProduct1('Secure Internet Access for Servers - Additional Data', 'ZIA-SERVER-EXTRA-GB-PRE', 'ZIA'));
        insert listProduct;
        
        
        
        List<Contract_Detail__c> contractDetailList = new List<Contract_Detail__c>();
        Contract_Detail__c contractDetail1 = new Contract_Detail__c();
        contractDetail1.Name = 'test 1';
        contractDetail1.Account_Name__c = account.Id;
        contractDetail1.Product_Name__c = listProduct[0].Id;
        contractDetail1.Start_Date__c = Date.Today();
        contractDetail1.End_Date__c = Date.Today() + 365;
        contractDetail1.Quantity__c = 400000;
        contractDetail1.Amount_USD__c = 1000;
        contractDetail1.Contract_No__c = '100';
        contractDetail1.MRR_USD__c = 100;
        //contractDetail1.Product_SKU__c = listProduct[0].SKU_Type__c;
        contractDetail1.Contract_Detail_Status__c = 'Active';
        contractDetailList.add(contractDetail1);
        
        TriggerUtility.startUpdateCountractDetails();
        insert contractDetailList;
        TriggerUtility.startUpdateCountractDetails();
        delete contractDetailList;
        Test.stopTest();
        
    }
    
    public static Product2 createProduct1(String PRoductName, String skuType, String pfamily) {
        Product2 product = new Product2();
        product.Name = PRoductName;
        product.ProductCode = skuType;
        product.US_List__c = 0.00;
        Product.Zscaler_Product_Family__c = pfamily;
        return  product;  
    }
    //CR 977 end
    
    public static Product2 createProduct(String PRoductName, String pcode, String pfamily, String sConfigType) {
        Product2 productSO = new Product2();
        productSO.Name = ProductName;
        productSO.Family = pfamily;
        productSO.ProductCode = pcode;
        productSO.IsActive = true;
        return productSO;
    }
    
  @isTest static void test5(){
        Test.startTest();
        Account account = new Account(Name = 'Test Account');
        insert account;
        Account_Extension__c ac = new Account_Extension__c(Account__c = account.id);
        insert ac;
        
        List<Product2> listProduct = new list<Product2>();
        listProduct.add(createProduct1('Secure Internet Access for Servers - Additional Data', 'ZIA-SERVER-EXTRA-GB-PRE', 'ZIA'));
           listProduct.add(createProduct1('ZIA Enterprise License Agreement', 'ZIA-ELA-BUNDLE', 'ZIA'));
        
        insert listProduct;
        
        
        
        List<Contract_Detail__c> contractDetailList = new List<Contract_Detail__c>();
        Contract_Detail__c contractDetail1 = new Contract_Detail__c();
        contractDetail1.Name = 'test 1';
        contractDetail1.Account_Name__c = account.Id;
        contractDetail1.Product_Name__c = listProduct[0].Id;
        contractDetail1.Start_Date__c = Date.Today();
        contractDetail1.End_Date__c = Date.Today() + 365;
        contractDetail1.Quantity__c = 400000;
        contractDetail1.Amount_USD__c = 1000;
        contractDetail1.Contract_No__c = '100';
        contractDetail1.MRR_USD__c = 100;
        //contractDetail1.Product_SKU__c = listProduct[0].SKU_Type__c;
        contractDetail1.Contract_Detail_Status__c = 'Active';
        contractDetailList.add(contractDetail1);
        
        TriggerUtility.startUpdateCountractDetails();
        insert contractDetailList;
           Map<Id,Contract_Detail__c> maptopass = new Map<Id,Contract_Detail__c>();
           for(Contract_Detail__c cdobj:contractDetailList ){
               maptopass.put(cdobj.id,cdobj);
           }
           
           ContractDetailTriggerHelper.executeCDProductSynconUpdate(contractDetailList,maptopass);
      
        Test.stopTest();
        
    }

    
}