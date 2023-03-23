/*
 * @description       : 
 * Modifications Log 
 * Ver   Date         Author        Modification
 * 1.0   NA				NA		    Initial Version
 * 2.0   09-05-2022   Mahesh T      Fixed Code Coverage CR# 3678
*/
@isTest
public class updateLatestContractDatesBatchTest{
    
    @testSetup static void setup(){
        
        List<SKUs_Referred_in_Renewal_Upsell_NS_Calc__c> skus = new List<SKUs_Referred_in_Renewal_Upsell_NS_Calc__c>();
        SKUs_Referred_in_Renewal_Upsell_NS_Calc__c ziaSKUs = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c();
        ziaSKUs.Name = 'ZIA_Contract_Date';
        ziaSKUs.SKU_Codes__c = 'ZSC-SIP;ZIA-PRO-BUNDLE;ZIA-BUS-BUNDLE;ZIA-TRANS-BUNDLE;ZCES-SUP-PREM;ZIA-ELA-BUNDLE;ZIA-PRO-BUNDLE-LU;ZIA-BUS-BUNDLE-LU;ZIA-TRANS-BUNDLE-LU;ZIA-ELA-BUNDLE-LU;ZSC-SIP-LOC;ZIA-SIP';
        skus.add(ziaSKUs);
        
        SKUs_Referred_in_Renewal_Upsell_NS_Calc__c ziaSKUs1 = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c();
        ziaSKUs1.Name = 'ZIA_Contract_Date1';
        ziaSKUs1.SKU_Codes__c = 'ZS-WFA-BUS-EDITION';
        skus.add(ziaSKUs1);
        
        SKUs_Referred_in_Renewal_Upsell_NS_Calc__c zpaSKUs = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c();
        zpaSKUs.Name = 'ZPA_Contract_Date';
        zpaSKUs.SKU_Codes__c = 'ZIA-PRO-BUNDLE;ZPA-BBA;ZPA-BUS;ZPA-ENT;ZPA-PRO;ZPA-PRO-LU;ZPA-BUS-LU;ZPA-BUS-EDITION;ZPA-PRO-EDITION;ZPA-BUS-EDITION-LU;ZIA-PRO-EDITION-LU;ZPA-TRANS-EDITION;ZS-WFA-BUS-EDITION';
        skus.add(zpaSKUs);
        
         // Added by Rajesh : CR# 1251 : Start
        SKUs_Referred_in_Renewal_Upsell_NS_Calc__c zdxSKUs = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c();
        zdxSKUs.Name = 'ZDX_Contract_Date';
        zdxSKUs.SKU_Codes__c = 'ZIA-PRO-BUNDLE;ZPA-BBA;ZPA-BUS;ZPA-ENT;ZPA-PRO;ZPA-PRO-LU;ZPA-BUS-LU;ZPA-BUS-EDITION;ZPA-PRO-EDITION;ZPA-BUS-EDITION-LU;ZIA-PRO-EDITION-LU;ZPA-TRANS-EDITION';
        skus.add(zdxSKUs);
        // Added by Rajesh : CR# 1251 : End
        
        //CR# 2711 : Bikram, ZCP Logic START
         SKUs_Referred_in_Renewal_Upsell_NS_Calc__c zcpSKUs1 = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c();
         zcpSKUs1.Name = 'ZCP_Contract_Date1';
         zcpSKUs1.SKU_Codes__c = 'ZIA-PRO-BUNDLE;ZPA-BBA;ZPA-BUS-EDITION;ZIA-TRANS-BUNDLE;ZIA-ELA-BUNDLE;ZS-CSPM-Cloud-Infra;ZCSPM-Cloud-Infra;ZS-SSPM-M365;ZSSPM-M365;ZT-WPL-Server;ZPA-TRANS-Edition';
         skus.add(zcpSKUs1);
         SKUs_Referred_in_Renewal_Upsell_NS_Calc__c zcpSKUs2 = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c();
         zcpSKUs2.Name = 'ZCP_Contract_Date2';
         zcpSKUs2.SKU_Codes__c = 'ZS-CSPM-Cloud-Infra;ZCSPM-Cloud-Infra;ZS-SSPM-M365;ZSSPM-M365;ZT-WPL-Server;ZPA-TRANS-Edition';
         skus.add(zcpSKUs2);
         SKUs_Referred_in_Renewal_Upsell_NS_Calc__c zcpSKUs3 = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c();
         zcpSKUs3.Name = 'ZCP_Contract_Date3';
         zcpSKUs3.SKU_Codes__c = 'ZS-CSPM-Cloud-Infra;ZCSPM-Cloud-Infra;ZS-SSPM-M365;ZSSPM-M365;ZT-WPL-Server;ZPA-TRANS-Edition';
         skus.add(zcpSKUs3);
        //CR# 2711 : Bikram, ZCP Logic END
        
        insert skus;
        
    }
    
    
    static testmethod void test1(){
        Account account = new Account(Name = 'Test Account');
        account.Type = 'Customer';
        insert account;
        
        Account_Extension__c accExt = new Account_Extension__c();
        accExt.Account__c = account.Id;
        insert accExt;
        
        
        Id PricebookID=Test.getStandardPricebookId();
        
        //Insert Products
        List<Product2> listProduct = new list<Product2>();
        listProduct.add(createProduct('Zscaler Enterprise Guest Wi-Fi Security', 'ZIA-PRO-BUNDLE', 'Products', 'Standalone'));
        listProduct.add(createProduct('Product2', 'ZIA-TRANS-BUNDLE', 'Products', 'Standalone'));
        listProduct.add(createProduct('Product4', 'ZIA-ELA-EDITION', 'Products', 'Standalone'));
        listProduct.add(createProduct('Product3', 'ZIA-TRANS-EDITION', 'Products', 'Standalone'));
        listProduct.add(createProduct('Product34', 'ZPA-BBA', 'Zscaler Products', 'Standalone'));
        listProduct.add(createProduct('ZPA-BBA', 'ZPA-BBA', 'Zscaler Products', 'Standalone'));//CR# 2711 : Bikram, ZPA Logic
        listProduct.add(createProduct('ZS-CSPM-Cloud-Infra', 'ZS-CSPM-Cloud-Infra', 'Zscaler Products', 'Standalone'));//CR# 2711 : Bikram, ZCP Logic
        listProduct.add(createProduct('ZIA-ELA-EDITION', 'ZIA-ELA-EDITION', 'Zscaler Products', 'Standalone'));//CR# 3656
        insert listProduct;
        System.debug('@@listProduct'+listProduct[2]);
        
        Order o = new Order(name = 'Test Order 1', AccountId = account.Id, Order_Date__c = date.today(), NS_Sales_Order_Number__c = 'S24867', EffectiveDate = date.today(), EndDate=date.today().adddays(200), Status = 'Draft', Location__c = 'Americas');
        insert o;
        
        
        //Create Contractdetails
        List<Contract_Detail__c> contractDetailList = new List<Contract_Detail__c>();
        Contract_Detail__c contractDetail1 = new Contract_Detail__c();
        contractDetail1.Name = 'Migrate as is';
        contractDetail1.Account_Name__c = account.Id;
        contractDetail1.Product_Name__c = listProduct[0].Id;
        contractDetail1.Start_Date__c = Date.Today() - 365;
        contractDetail1.End_Date__c = Date.Today() + 365;
        contractDetail1.Quantity__c = 100;
        contractDetail1.Amount_USD__c = 1000;
        contractDetail1.Contract_No__c = '100';
        contractDetail1.MRR_USD__c = 100;
        contractDetail1.List_Price__c = 100;
        contractDetail1.Discount__c = 10;
        contractDetail1.Needs_to_Be_Migrated_to_Asset_Line__c = true;
        //contractDetail1.Sales_Order__c = o.Id;
        contractDetail1.Product_SKU__c = 'ZIA-ELA-BUNDLE';
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
        contractDetail2.Product_SKU__c = 'ZIA-BUS-EDITION';
        contractDetailList.add(contractDetail2);
        
        Contract_Detail__c contractDetail3 = new Contract_Detail__c();
        contractDetail3.Name = 'Split';
        contractDetail3.Account_Name__c = account.Id;
        contractDetail3.Product_Name__c = listProduct[2].Id;
        contractDetail3.Start_Date__c = Date.Today() - 1;
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
        
        Contract_Detail__c contractDetail4 = new Contract_Detail__c();
        contractDetail4.Name = 'Split';
        contractDetail4.Account_Name__c = account.Id;
        contractDetail4.Product_Name__c = listProduct[3].Id;
        contractDetail4.Start_Date__c = Date.Today() - 1;
        contractDetail4.End_Date__c = Date.Today() + 365;
        contractDetail4.Quantity__c = 100;
        contractDetail4.Amount_USD__c = 1000;
        contractDetail4.Contract_No__c = '100';
        contractDetail4.MRR_USD__c = 100;
        contractDetail4.List_Price__c = 100;
        contractDetail4.Discount__c = 10;
        contractDetail4.Needs_to_Be_Migrated_to_Asset_Line__c = true;
        contractDetail4.Sales_Order__c = o.Id;
        contractDetailList.add(contractDetail4);
        
        //CR# 2711 : Bikram, ZCP Logic START
        
        Contract_Detail__c contractDetailZPA = new Contract_Detail__c();
        contractDetailZPA.Name = 'Migrate as is';
        contractDetailZPA.Account_Name__c = account.Id;
        contractDetailZPA.Product_Name__c = listProduct[0].Id;
        contractDetailZPA.Start_Date__c = Date.Today() - 365;
        contractDetailZPA.End_Date__c = Date.Today() + 365;
        contractDetailZPA.Quantity__c = 100;
        contractDetailZPA.Amount_USD__c = 1000;
        contractDetailZPA.Contract_No__c = '100';
        contractDetailZPA.MRR_USD__c = 100;
        contractDetailZPA.List_Price__c = 100;
        contractDetailZPA.Discount__c = 10;
        contractDetailZPA.Needs_to_Be_Migrated_to_Asset_Line__c = true;
        contractDetailZPA.Sales_Order__c = o.Id;
        contractDetailZPA.Product_SKU__c = 'ZPA-BBA';
        contractDetailZPA.Contract_Detail_Status__c = 'Active';
        contractDetailList.add(contractDetailZPA);
        
        Contract_Detail__c contractDetailZCP = new Contract_Detail__c();
        contractDetailZCP.Name = 'Migrate as is';
        contractDetailZCP.Account_Name__c = account.Id;
        contractDetailZCP.Product_Name__c = listProduct[0].Id;
        contractDetailZCP.Start_Date__c = Date.Today() - 365;
        contractDetailZCP.End_Date__c = Date.Today() + 365;
        contractDetailZCP.Quantity__c = 100;
        contractDetailZCP.Amount_USD__c = 1000;
        contractDetailZCP.Contract_No__c = '100';
        contractDetailZCP.MRR_USD__c = 100;
        contractDetailZCP.List_Price__c = 100;
        contractDetailZCP.Discount__c = 10;
        contractDetailZCP.Needs_to_Be_Migrated_to_Asset_Line__c = true;
        contractDetailZCP.Sales_Order__c = o.Id;
        contractDetailZCP.Product_SKU__c = 'ZS-CSPM-Cloud-Infra';
        contractDetailZCP.Contract_Detail_Status__c = 'Active';
        contractDetailList.add(contractDetailZCP);
        //CR# 2711 : Bikram, ZCP Logic END        
        /**
        Contract_Detail__c contractDetailZDX = new Contract_Detail__c();
        contractDetailZDX.Name = 'Migrate as is';
        contractDetailZDX.Account_Name__c = account.Id;
        contractDetailZDX.Product_Name__c = listProduct[0].Id;
        contractDetailZDX.Start_Date__c = Date.Today() - 365;
        contractDetailZDX.End_Date__c = Date.Today() + 365;
        contractDetailZDX.Quantity__c = 100;
        contractDetailZDX.Amount_USD__c = 1000;
        contractDetailZDX.Contract_No__c = '100';
        contractDetailZDX.MRR_USD__c = 100;
        contractDetailZDX.List_Price__c = 100;
        contractDetailZDX.Discount__c = 10;
        contractDetailZDX.Needs_to_Be_Migrated_to_Asset_Line__c = true;
        contractDetailZDX.Sales_Order__c = o.Id;
        contractDetailZDX.Product_SKU__c = 'ZIA-BUS-EDITION';
        contractDetailZDX.Contract_Detail_Status__c = 'Active';
        contractDetailZDX.Is_Bundle_SKU__c = false;
        contractDetailZDX.Do_not_Aggregate__c = false;
        contractDetailList.add(contractDetailZDX);*/
        //CR# 3656 Start
        Contract_Detail__c contractDetail5 = new Contract_Detail__c();
        contractDetail5.Name = 'Split';
        contractDetail5.Account_Name__c = account.Id;
        contractDetail5.Product_Name__c = listProduct[7].Id;
        contractDetail5.Start_Date__c = Date.Today() - 1;
        contractDetail5.End_Date__c = Date.Today() + 365;
        contractDetail5.Quantity__c = 100;
        contractDetail5.Amount_USD__c = 1000;
        contractDetail5.Contract_No__c = '100';
        contractDetail5.MRR_USD__c = 100;
        contractDetail5.List_Price__c = 100;
        contractDetail5.Discount__c = 10;
        contractDetail5.Needs_to_Be_Migrated_to_Asset_Line__c = true;
        contractDetail5.Sales_Order__c = o.Id;
        contractDetail5.Product_SKU__c = 'ZIA-ELA-EDITION';
        contractDetail5.Contract_Detail_Status__c = 'Active';
        contractDetailList.add(contractDetail5);
        //CR# 3656 End
       
        insert contractDetailList;
        
        System.debug('@@@contractDetailList'+contractDetailList);
        System.debug('@@@contractDetailList[2]'+contractDetailList[2]);
        System.debug('@@@contractDetail2'+contractDetailList[2].Product_SKU__c);
        System.debug('@@@contractDetail2'+contractDetailList[2].APTS_SKU__c);
        System.debug('@@@contractDetail3'+contractDetailList[3].Product_SKU__c);
        System.debug('@@@contractDetail3'+contractDetailList[3].APTS_SKU__c);
        System.debug('@@@contractDetailName'+contractDetailList[2].Product_Name__c);
        Test.StartTest();
        Database.executeBatch(new updateLatestContractDatesBatch('SELECT Id  FROM ACCOUNT WHERE Type = \'Customer\''));
        Test.StopTest();
    }
    
    public static Product2 createProduct(String PRoductName, String pcode, String pfamily, String sConfigType) {
        Product2 productSO = new Product2();
        productSO.Name = ProductName;
        productSO.Family = pfamily;
        productSO.ProductCode = pcode;
        productSO.IsActive = true;
        return productSO;
    }
    
    static testmethod void test2(){
        updateLatestContractDatesBatchSch m = new updateLatestContractDatesBatchSch();
        String sch = '0 36 1 * * ?';
        String jobID = system.schedule('test ren notification exp rem', sch, m);
    }
    
    //CR# 3656 Start
    static testmethod void test3(){
        Account account = new Account(Name = 'Test Account1');
        account.Type = 'Customer';
        insert account;
        
        Account_Extension__c accExt = new Account_Extension__c();
        accExt.Account__c = account.Id;
        insert accExt;
        
        Account account1 = new Account(Name = 'Test Account1');
        account1.Type = 'Customer';
        insert account1;
        
        Account_Extension__c accExt1 = new Account_Extension__c();
        accExt1.Account__c = account1.Id;
        accExt1.Latest_ZPA_Contract_Date__c=Date.Today()-10;
        insert accExt1;
        
        Id PricebookID=Test.getStandardPricebookId();
        
        //Insert Products
        List<Product2> listProduct = new list<Product2>();
        listProduct.add(createProduct('ZS-SIPA-EXTRA-GB', 'ZS-SIPA-EXTRA-GB', 'Products', 'Standalone'));
        listProduct.add(createProduct('ZIA-ELA-EDITION', 'ZIA-ELA-EDITION', 'Zscaler Products', 'Standalone'));
        listProduct.add(createProduct('ZPA-BUS-EDITION', 'ZPA-BUS-EDITION', 'Zscaler Products', 'Standalone'));
        listProduct.add(createProduct( 'ZPA-BUS', 'ZPA-BUS', 'Zscaler Products', 'Standalone'));
        listProduct.add(createProduct('ZPA-BUS-LU', 'ZPA-BUS-LU', 'Zscaler Products', 'Standalone'));
        listProduct.add(createProduct('ZS-SIPA', 'ZS-SIPA', 'Zscaler Products', 'Standalone'));
        
        insert listProduct;
        //System.debug('@@listProduct'+listProduct[2]);
        
        Order o = new Order(name = 'Test Order 1', AccountId = account.Id, Order_Date__c = date.today(), NS_Sales_Order_Number__c = 'S24867', EffectiveDate = date.today(), EndDate=date.today().adddays(200), Status = 'Draft', Location__c = 'Americas');
        insert o;
        
        
        //Create Contractdetails
        List<Contract_Detail__c> contractDetailList = new List<Contract_Detail__c>();
        Contract_Detail__c contractDetail1 = new Contract_Detail__c();
        contractDetail1.Name = 'Migrate as is';
        contractDetail1.Account_Name__c = account.Id;
        contractDetail1.Product_Name__c = listProduct[0].Id;
        contractDetail1.Start_Date__c = Date.Today() - 365;
        contractDetail1.End_Date__c = Date.Today() + 365;
        contractDetail1.Quantity__c = 100;
        contractDetail1.Amount_USD__c = 1000;
        contractDetail1.Contract_No__c = '100';
        contractDetail1.MRR_USD__c = 100;
        contractDetail1.List_Price__c = 100;
        contractDetail1.Discount__c = 10;
        contractDetail1.Needs_to_Be_Migrated_to_Asset_Line__c = true;
        contractDetail1.Sales_Order__c = o.Id;
        contractDetail1.Product_SKU__c = 'ZS-SIPA-EXTRA-GB';
        contractDetail1.Contract_Detail_Status__c = 'Active';
        contractDetailList.add(contractDetail1);
        
        
        Contract_Detail__c contractDetail5 = new Contract_Detail__c();
        contractDetail5.Name = 'Split';
        contractDetail5.Account_Name__c = account.Id;
        contractDetail5.Product_Name__c = listProduct[1].Id;
        contractDetail5.Start_Date__c = Date.Today() - 1;
        contractDetail5.End_Date__c = Date.Today() + 365;
        contractDetail5.Quantity__c = 100;
        contractDetail5.Amount_USD__c = 1000;
        contractDetail5.Contract_No__c = '100';
        contractDetail5.MRR_USD__c = 100;
        contractDetail5.List_Price__c = 100;
        contractDetail5.Discount__c = 10;
        contractDetail5.Needs_to_Be_Migrated_to_Asset_Line__c = true;
        contractDetail5.Sales_Order__c = o.Id;
        contractDetail5.Product_SKU__c = 'ZIA-ELA-EDITION';
        contractDetail5.Contract_Detail_Status__c = 'Active';
        contractDetailList.add(contractDetail5);
        
        Contract_Detail__c contractDetail6 = new Contract_Detail__c();
        contractDetail6.Name = 'Split';
        contractDetail6.Account_Name__c = account.Id;
        contractDetail6.Product_Name__c = listProduct[1].Id;
        contractDetail6.Start_Date__c = Date.Today() - 1;
        contractDetail6.End_Date__c = Date.Today() + 365;
        contractDetail6.Quantity__c = 100;
        contractDetail6.Amount_USD__c = 1000;
        contractDetail6.Contract_No__c = '100';
        contractDetail6.MRR_USD__c = 100;
        contractDetail6.List_Price__c = 100;
        contractDetail6.Discount__c = 10;
        contractDetail6.Needs_to_Be_Migrated_to_Asset_Line__c = true;
        contractDetail6.Sales_Order__c = o.Id;
        contractDetail6.Product_SKU__c = 'ZPA-BUS-EDITION';
        contractDetail6.Contract_Detail_Status__c = 'Active';
        contractDetailList.add(contractDetail6);
               
        
        Contract_Detail__c contractDetail7 = new Contract_Detail__c();
        contractDetail7.Name = 'Test7';
        contractDetail7.Account_Name__c = account.Id;
        contractDetail7.Product_Name__c = listProduct[3].Id;
        contractDetail7.Start_Date__c = Date.Today() - 1;
        contractDetail7.End_Date__c = Date.Today() + 365;
        contractDetail7.Quantity__c = 100;
        contractDetail7.Amount_USD__c = 1000;
        contractDetail7.Contract_No__c = '100';
        contractDetail7.MRR_USD__c = 100;
        contractDetail7.List_Price__c = 100;
        contractDetail7.Discount__c = 10;
        contractDetail7.Needs_to_Be_Migrated_to_Asset_Line__c = true;
        contractDetail7.Sales_Order__c = o.Id;
        contractDetail7.Product_SKU__c = 'ZPA-BUS';
        contractDetail7.Contract_Detail_Status__c = 'Active';
        contractDetailList.add(contractDetail7);
        
        Contract_Detail__c contractDetail8 = new Contract_Detail__c();
        contractDetail8.Name = 'Test8';
        contractDetail8.Account_Name__c = account.Id;
        contractDetail8.Product_Name__c = listProduct[5].Id;
        contractDetail8.Start_Date__c = Date.Today() - 1;
        contractDetail8.End_Date__c = Date.Today() + 365;
        contractDetail8.Quantity__c = 100;
        contractDetail8.Amount_USD__c = 1000;
        contractDetail8.Contract_No__c = '100';
        contractDetail8.MRR_USD__c = 100;
        contractDetail8.List_Price__c = 100;
        contractDetail8.Discount__c = 10;
        contractDetail8.Needs_to_Be_Migrated_to_Asset_Line__c = true;
        contractDetail8.Sales_Order__c = o.Id;
        contractDetail8.Product_SKU__c = 'ZS-SIPA';
        contractDetail8.Contract_Detail_Status__c = 'Active';
        contractDetailList.add(contractDetail8);
        
        Contract_Detail__c contractDetail9 = new Contract_Detail__c();
        contractDetail9.Name = 'Test9';
        contractDetail9.Account_Name__c = account1.Id;
        contractDetail9.Product_Name__c = listProduct[5].Id;
        contractDetail9.Start_Date__c = Date.Today() - 15;
        contractDetail9.End_Date__c = Date.Today() + 365;
        contractDetail9.Quantity__c = 100;
        contractDetail9.Amount_USD__c = 1000;
        contractDetail9.Contract_No__c = '100';
        contractDetail9.MRR_USD__c = 100;
        contractDetail9.List_Price__c = 100;
        contractDetail9.Discount__c = 10;
        contractDetail9.Needs_to_Be_Migrated_to_Asset_Line__c = true;
        contractDetail9.Sales_Order__c = o.Id;
        contractDetail9.Product_SKU__c = 'ZS-SIPA';
        contractDetail9.Contract_Detail_Status__c = 'Active';
        contractDetailList.add(contractDetail9);
        insert contractDetailList;
        
        Test.StartTest();
        Database.executeBatch(new updateLatestContractDatesBatch('SELECT Id  FROM ACCOUNT WHERE Type = \'Customer\''));
        Test.StopTest();
    }
    //CR# 3656 End
    
}