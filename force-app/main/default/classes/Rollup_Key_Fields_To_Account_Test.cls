@isTest
public class Rollup_Key_Fields_To_Account_Test{

    static testmethod void test1(){
        
        insert TestDatafactory_Zscaler.gettriggerswitchrecords(true);
        insert TestDatafactory_Zscaler.getstageforecastcategorymap();
        Account acct = new Account();
        acct.name = 'Test Account';
        acct.Type = 'Customer';
        acct.RecordTypeId = '01270000000EAFsAAO';
        insert acct;
        System.debug('acct ::'+acct);
        
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
        List<Account> lstAcc = [SELECT Id, Type, RecordType.Name FROM Account WHERE Id  =: acct.Id];
        System.debug('lstAcc ::'+lstAcc);
        String query = 'Select Id, Number_of_Ramped_Users__c, Link_to_Value_Output__c, Last_SCI_Date__c, Service_Owner_Present__c, Head_of_IT__c, Head_of_Networking__c, Head_of_Security__c from Account where Type = \'Customer\'';
        List<sObject> sobjList = Database.query(query);
        System.debug('sobjList ::'+sobjList);
        try{
        Rollup_Key_Fields_To_Account batch = new Rollup_Key_Fields_To_Account();
        batch = new Rollup_Key_Fields_To_Account();
        batch.errorlst.add('abc');
        Database.executeBatch(batch,1);
        }catch(Exception ex){
            
        }
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