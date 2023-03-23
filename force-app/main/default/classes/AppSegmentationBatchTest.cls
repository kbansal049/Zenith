@isTest
public class AppSegmentationBatchTest{
    
    @testSetup static void setup(){
        
        List<SKUs_Referred_in_Renewal_Upsell_NS_Calc__c> skus = new List<SKUs_Referred_in_Renewal_Upsell_NS_Calc__c>();
        SKUs_Referred_in_Renewal_Upsell_NS_Calc__c ziaSKUs = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c();
        ziaSKUs.Name = 'ZIA_Contract_Date';
        ziaSKUs.SKU_Codes__c = 'ZSC-SIP;ZIA-PRO-BUNDLE;ZIA-BUS-BUNDLE;ZIA-TRANS-BUNDLE;ZCES-SUP-PREM;ZIA-ELA-BUNDLE;ZIA-PRO-BUNDLE-LU;ZIA-BUS-BUNDLE-LU;ZIA-TRANS-BUNDLE-LU;ZIA-ELA-BUNDLE-LU;ZSC-SIP-LOC;ZIA-SIP';
        skus.add(ziaSKUs);
        
        SKUs_Referred_in_Renewal_Upsell_NS_Calc__c zpaSKUs = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c();
        zpaSKUs.Name = 'ZPA_Contract_Date';
        zpaSKUs.SKU_Codes__c = 'ZPA-BBA;ZPA-BUS;ZPA-ENT;ZPA-PRO;ZPA-PRO-LU;ZPA-BUS-LU;ZPA-BUS-EDITION;ZPA-PRO-EDITION;ZPA-BUS-EDITION-LU;ZIA-PRO-EDITION-LU;ZPA-TRANS-EDITION';
        skus.add(zpaSKUs);
        
         // Added by Rajesh : CR# 1251 : Start
        SKUs_Referred_in_Renewal_Upsell_NS_Calc__c zdxSKUs = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c();
        zdxSKUs.Name = 'ZDX_Contract_Date';
        zdxSKUs.SKU_Codes__c = 'ZPA-BBA;ZPA-BUS;ZPA-ENT;ZPA-PRO;ZPA-PRO-LU;ZPA-BUS-LU;ZPA-BUS-EDITION;ZPA-PRO-EDITION;ZPA-BUS-EDITION-LU;ZIA-PRO-EDITION-LU;ZPA-TRANS-EDITION';
        skus.add(zdxSKUs);
        // Added by Rajesh : CR# 1251 : End
        
        insert skus;
        
    }
    
    
    static testmethod void test1(){
        Account account = new Account(Name = 'Test Account');
        insert account;
        
        Account_Extension__c accExt = new Account_Extension__c();
        accExt.Account__c = account.Id;
        insert accExt;
        
        Id PricebookID=Test.getStandardPricebookId();
        
        //Insert Products
        List<Product2> listProduct = new list<Product2>();
        listProduct.add(createProduct('Zscaler Enterprise Guest Wi-Fi Security', 'ZPA-PRO-EDITION', 'Products', 'Standalone'));
        listProduct.add(createProduct('Product2', 'ZPA-BUS-EDITION', 'Products', 'Standalone'));
        listProduct.add(createProduct('Product3', 'ZPA-TRANS-EDITION', 'Products', 'Standalone'));
        listProduct.add(createProduct('Product34', 'ZPA-PRO', 'Zscaler Products', 'Standalone'));
        listProduct.add(createProduct('Product34', 'ZPA-BUS', 'Zscaler Products', 'Standalone'));
        listProduct.add(createProduct('Product34', 'ZPA-ENT', 'Zscaler Products', 'Standalone'));
        listProduct.add(createProduct('Product34', 'ZT-APP-SEGMENT', 'Zscaler Products', 'Standalone'));
        insert listProduct;
        
        
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
        
        Contract_Detail__c contractDetail5 = new Contract_Detail__c();
        contractDetail5.Name = 'Split';
        contractDetail5.Account_Name__c = account.Id;
        contractDetail5.Product_Name__c = listProduct[4].Id;
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
        contractDetailList.add(contractDetail5);
        
        Contract_Detail__c contractDetail6 = new Contract_Detail__c();
        contractDetail6.Name = 'Split';
        contractDetail6.Account_Name__c = account.Id;
        contractDetail6.Product_Name__c = listProduct[5].Id;
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
        contractDetailList.add(contractDetail6);
        
        Contract_Detail__c contractDetail7 = new Contract_Detail__c();
        contractDetail7.Name = 'Split';
        contractDetail7.Account_Name__c = account.Id;
        contractDetail7.Product_Name__c = listProduct[6].Id;
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
        contractDetailList.add(contractDetail7);
        
        Contract_Detail__c contractDetail8 = new Contract_Detail__c();
        contractDetail8.Name = 'Migrate as is';
        contractDetail8.Account_Name__c = account.Id;
        contractDetail8.Product_Name__c = listProduct[0].Id;
        contractDetail8.Start_Date__c = Date.Today() - 365;
        contractDetail8.End_Date__c = Date.Today() + 365;
        contractDetail8.Quantity__c = 100;
        contractDetail8.Amount_USD__c = 1000;
        contractDetail8.Contract_No__c = '100';
        contractDetail8.MRR_USD__c = 100;
        contractDetail8.List_Price__c = 100;
        contractDetail8.Discount__c = 10;
        contractDetail8.Needs_to_Be_Migrated_to_Asset_Line__c = true;
        //contractDetail1.Sales_Order__c = o.Id;
        contractDetail8.Product_SKU__c = 'ZPA-PRO-EDITION';
        contractDetail8.Contract_Detail_Status__c = 'Active';
        contractDetailList.add(contractDetail8);
        
        Contract_Detail__c contractDetail9 = new Contract_Detail__c();
        contractDetail9.Name = 'Migrate as is';
        contractDetail9.Account_Name__c = account.Id;
        contractDetail9.Product_Name__c = listProduct[0].Id;
        contractDetail9.Start_Date__c = Date.Today() - 365;
        contractDetail9.End_Date__c = Date.Today() + 365;
        contractDetail9.Quantity__c = 100;
        contractDetail9.Amount_USD__c = 1000;
        contractDetail9.Contract_No__c = '100';
        contractDetail9.MRR_USD__c = 100;
        contractDetail9.List_Price__c = 100;
        contractDetail9.Discount__c = 10;
        contractDetail9.Needs_to_Be_Migrated_to_Asset_Line__c = true;
        //contractDetail1.Sales_Order__c = o.Id;
        contractDetail9.Product_SKU__c = 'ZPA-BUS-EDITION';
        contractDetail9.Contract_Detail_Status__c = 'Active';
        contractDetailList.add(contractDetail9);
        
        Contract_Detail__c contractDetail10 = new Contract_Detail__c();
        contractDetail10.Name = 'Migrate as is';
        contractDetail10.Account_Name__c = account.Id;
        contractDetail10.Product_Name__c = listProduct[0].Id;
        contractDetail10.Start_Date__c = Date.Today() - 365;
        contractDetail10.End_Date__c = Date.Today() + 365;
        contractDetail10.Quantity__c = 100;
        contractDetail10.Amount_USD__c = 1000;
        contractDetail10.Contract_No__c = '100';
        contractDetail10.MRR_USD__c = 100;
        contractDetail10.List_Price__c = 100;
        contractDetail10.Discount__c = 10;
        contractDetail10.Needs_to_Be_Migrated_to_Asset_Line__c = true;
        //contractDetail1.Sales_Order__c = o.Id;
        contractDetail10.Product_SKU__c = 'ZPA-TRANS-EDITION';
        contractDetail10.Contract_Detail_Status__c = 'Active';
        contractDetailList.add(contractDetail10);
        
        Contract_Detail__c contractDetail11 = new Contract_Detail__c();
        contractDetail11.Name = 'Migrate as is';
        contractDetail11.Account_Name__c = account.Id;
        contractDetail11.Product_Name__c = listProduct[0].Id;
        contractDetail11.Start_Date__c = Date.Today() - 365;
        contractDetail11.End_Date__c = Date.Today() + 365;
        contractDetail11.Quantity__c = 100;
        contractDetail11.Amount_USD__c = 1000;
        contractDetail11.Contract_No__c = '100';
        contractDetail11.MRR_USD__c = 100;
        contractDetail11.List_Price__c = 100;
        contractDetail11.Discount__c = 10;
        contractDetail11.Needs_to_Be_Migrated_to_Asset_Line__c = true;
        //contractDetail1.Sales_Order__c = o.Id;
        contractDetail11.Product_SKU__c = 'ZPA-PRO';
        contractDetail11.Contract_Detail_Status__c = 'Active';
        contractDetailList.add(contractDetail11);
        
        Contract_Detail__c contractDetail12 = new Contract_Detail__c();
        contractDetail12.Name = 'Migrate as is';
        contractDetail12.Account_Name__c = account.Id;
        contractDetail12.Product_Name__c = listProduct[0].Id;
        contractDetail12.Start_Date__c = Date.Today() - 365;
        contractDetail12.End_Date__c = Date.Today() + 365;
        contractDetail12.Quantity__c = 100;
        contractDetail12.Amount_USD__c = 1000;
        contractDetail12.Contract_No__c = '100';
        contractDetail12.MRR_USD__c = 100;
        contractDetail12.List_Price__c = 100;
        contractDetail12.Discount__c = 10;
        contractDetail12.Needs_to_Be_Migrated_to_Asset_Line__c = true;
        //contractDetail1.Sales_Order__c = o.Id;
        contractDetail12.Product_SKU__c = 'ZPA-BUS';
        contractDetail12.Contract_Detail_Status__c = 'Active';
        contractDetailList.add(contractDetail12);
        
        Contract_Detail__c contractDetail13 = new Contract_Detail__c();
        contractDetail13.Name = 'Migrate as is';
        contractDetail13.Account_Name__c = account.Id;
        contractDetail13.Product_Name__c = listProduct[0].Id;
        contractDetail13.Start_Date__c = Date.Today() - 365;
        contractDetail13.End_Date__c = Date.Today() + 365;
        contractDetail13.Quantity__c = 100;
        contractDetail13.Amount_USD__c = 1000;
        contractDetail13.Contract_No__c = '100';
        contractDetail13.MRR_USD__c = 100;
        contractDetail13.List_Price__c = 100;
        contractDetail13.Discount__c = 10;
        contractDetail13.Needs_to_Be_Migrated_to_Asset_Line__c = true;
        //contractDetail1.Sales_Order__c = o.Id;
        contractDetail13.Product_SKU__c = 'ZPA-ENT';
        contractDetail13.Contract_Detail_Status__c = 'Active';
        contractDetailList.add(contractDetail13);
        
        insert contractDetailList;
        Test.StartTest();
        Database.executeBatch(new AppSegmentationBatch('Select Id from Account'));
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
        AppSegmentationBatchSch m = new AppSegmentationBatchSch();
        String sch = '0 36 1 * * ?';
        String jobID = system.schedule('test ren notification exp rem', sch, m);
    }
    
}