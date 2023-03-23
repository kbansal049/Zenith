@isTest
public class Account_Ramped_Users_Batch_Test{

    static testmethod void test1(){
        
        insert TestDatafactory_Zscaler.gettriggerswitchrecords(true);
        insert TestDatafactory_Zscaler.getstageforecastcategorymap();
        
        User usr2 = TestDatafactory_Zscaler.insertAdminUser('2xyz@xyz.com', 'test12', 'test', 'ttest12', '2xyz@xyz.com.test', 'GMT', 'en_US', 'UTF-8', 'en_US');
        User usr3 = TestDatafactory_Zscaler.insertAdminUser('2xyz@xy1z.com', 'test121', 'tes1t', 'ttest121', '2xyz@xyz.com.test1', 'GMT', 'en_US', 'UTF-8', 'en_US');
        TriggerUtility2.setPartnerDiscountExecuted();
        
        
        TriggerHandler.bypass('AccountTriggerHandler');
        
        Account acct = new Account();
        acct.name = 'Test Account 1';
        acct.Type = 'Customer';
        acct.RecordTypeId = '01270000000EAFsAAO';
        acct.X3rd_TAM_Name__c = usr2.Id;
        acct.TAM_Name_New__c = usr2.Id;
        acct.Secondary_TAM_Name__c = usr2.Id;
        insert acct;
        
        //Insert Products
        List<Product2> listProduct = new list<Product2>();
        listProduct.add(createProduct('Zscaler Enterprise Guest Wi-Fi Security', 'ZSC-ENT-GWIFI-3YR-A', 'Products', 'Standalone'));
        listProduct.add(createProduct('Product2', 'ZCES-SUP-PREM', 'Products', 'Standalone'));
        listProduct.add(createProduct('Product3', 'CODE03', 'Products', 'Standalone'));
        listProduct.add(createProduct('Zscaler Enterprise Guest Wi-Fi Security', 'ZSC-ENT-GWIFI-3YR-A', 'Zscaler Products', 'Standalone'));
        listProduct.add(createProduct('Product22', 'ZCES-SUP-PREM', 'Zscaler Products', 'Standalone'));
        listProduct.add(createProduct('Product33', 'CODE04', 'Zscaler Products', 'Standalone'));
        insert listProduct;
        
        //Create Contractdetails
        List<Contract_Detail__c> contractDetailList = new List<Contract_Detail__c>();
        Contract_Detail__c contractDetail1 = new Contract_Detail__c();
        contractDetail1.Name = 'Migrate as is';
        contractDetail1.Account_Name__c = acct.Id;
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
        contractDetailList.add(contractDetail1);
        
        //Product2 product2 = [Select Id From Product2 Where ProductCode = 'ZSUITE-WEBSTD-1YR' Limit 1];
        Contract_Detail__c contractDetail2 = new Contract_Detail__c();
        contractDetail2.Name = 'Split';
        contractDetail2.Account_Name__c = acct.Id;
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
        contractDetailList.add(contractDetail2);
        
        insert contractDetailList;
        
        
        
        test.starttest();
        
        system.debug('--account--'+[Select id,name,type from account where id = :acct.id]);
        
        Account_Ramped_Users_Batch batch;
        batch = new Account_Ramped_Users_Batch ();
        batch.errorlst.add('abc');
        Database.executeBatch(batch,1);
        
        
        test.stoptest();
    
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