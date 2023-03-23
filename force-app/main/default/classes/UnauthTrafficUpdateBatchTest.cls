@istest
public class UnauthTrafficUpdateBatchTest {
    @testSetup static void setup() {
        Account acc =new Account(Name='acme acc');
        Account acc2 =new Account(Name='acme acc2');
        Account_Extension__c accEx = new Account_Extension__c();  
        Account_Extension__c accEx2 = new Account_Extension__c();
        accEx.Customer_Success_Engagement__c= 'Tech';
        accEx2.Customer_Success_Engagement__c='';
        insert acc;
        insert acc2;
        accEx.Account__c=  acc.id;
        accEx2.Account__c= acc2.id;
        insert accEx;
        insert accEx2;
        List<Product2> prodList = new List<Product2>();
        Product2 zscProd =TestDatafactory_Zscaler.createProduct('test product 1','ZIA-ELA-BUNDLE','Zscaler Products','Standalone', 'ZIA');
        Product2 zscProd2 =TestDatafactory_Zscaler.createProduct('test product 1','ZIA-SERVER-PRE','Zscaler Products','Standalone', 'ZIA');
        Product2 zscProd3 =TestDatafactory_Zscaler.createProduct('test product 1','ZIA-SERVER-EXTRA-GB-PRE','Zscaler Products','Standalone', 'ZIA');
        prodList.add(zscProd);
        prodList.add(zscProd2);
        prodList.add(zscProd3);
        insert prodList;
        //Product2 prod = createProduct('Zscaler Enterprise Guest Wi-Fi Security', 'ZSC-ENT-GWIFI-3YR-A', 'Products', 'Standalone');

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
        
        Contract_Detail__c contractDetail1 = new Contract_Detail__c();
        contractDetail1.Name = 'Test Migrate as is';
        contractDetail1.Account_Name__c = acc.Id;
        contractDetail1.Product_Name__c = zscProd.Id;
        contractDetail1.Start_Date__c = Date.Today();
        contractDetail1.End_Date__c = Date.Today() + 365;
        contractDetail1.Quantity__c = 100;
        contractDetail1.Amount_USD__c = 1000;
        contractDetail1.Contract_No__c = '100';
        contractDetail1.MRR_USD__c = 5000;
        contractDetail1.List_Price__c = 100;
        contractDetail1.Discount__c = 10;
        contractDetail1.Needs_to_Be_Migrated_to_Asset_Line__c = true;
        contractDetail1.Renew_Contract__c = 'No';
        contractDetail1.Renewed_To_Contract_Details__c = null;
        contractDetail1.SKU_Churn_Date__c = system.today() - 2;
        //contractDetail1.Sales_Order__c = o.Id;
        contractDetail1.Product_SKU__c = 'ZSC-ENT-GWIFI-3YR-A';
        
        Contract_Detail__c contractDetail2 = new Contract_Detail__c();
        contractDetail2.Name = 'Test Migrate as is';
        contractDetail2.Account_Name__c = acc2.Id;
        contractDetail2.Product_Name__c = zscProd2.Id;
        contractDetail2.Start_Date__c = Date.Today();
        contractDetail2.End_Date__c = Date.Today() + 365;
        contractDetail2.Quantity__c = 10000;
        contractDetail2.Amount_USD__c = 100000;
        contractDetail2.Contract_No__c = '100';
        contractDetail2.MRR_USD__c = 1000;
        contractDetail2.List_Price__c = 100;
        contractDetail2.Discount__c = 10;
        contractDetail2.Needs_to_Be_Migrated_to_Asset_Line__c = true;
        contractDetail2.Renew_Contract__c = 'No';
        contractDetail2.Renewed_To_Contract_Details__c = null;
        contractDetail2.SKU_Churn_Date__c = system.today() - 2;
        //contractDetail1.Sales_Order__c = o.Id;
        contractDetail2.Product_SKU__c = 'ZSC-ENT-GWIFI-3YR-A';
        Contract_Detail__c contractDetail3 = new Contract_Detail__c(Account_Name__c = acc2.Id);
        contractDetail3.Product_Name__c = zscProd3.Id;
        insert contractDetail1;
        insert contractDetail2;
        insert contractDetail3;
    }  
    
    static testMethod void testmethod1(){
        Test.startTest();
        UnauthTrafficUpdateBatch batch;
        //AccountCustomerScorecardUpdateBatch obj = new AccountCustomerScorecardUpdateBatch();
        //Database.executeBatch(new AccountCustomerScorecardUpdateBatch(acclist), 1);
       // Database.executeBatch(new CSEngagementUpdateBatch('select id, type, Account_Renewable_ACV__c,(Select id, Customer_Success_Engagement__c  from Account_Extensions__r) from Account where type=\'Customer\'') ,200);
        //Database.executeBatch(new CSEngagementUpdateBatch('') ,200);
        batch = new UnauthTrafficUpdateBatch('select id,Account_Name__c from Contract_Detail__c');

        batch.errorlst = new List<String>{'abc'};
        Database.executeBatch(batch,200);
        //Database.executeBatch(new CSEngagementUpdateBatch('select id, type, Account_Renewable_ACV__c,(Select id, Customer_Success_Engagement__c  from Account_Extensions__r) from Account where type=\'Prospect\'') ,200);
        Test.stopTest();           
    }
}