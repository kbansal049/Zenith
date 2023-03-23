@istest
public class CSEngagementUpdateBatchTest {
    @testSetup static void setup() {
        Account acc =new Account(Name='acme acc');
        Account acc2 =new Account(Name='acme acc2');
        acc.type='Customer';
        acc2.type='Customer';
        Account_Extension__c accEx = new Account_Extension__c();  
        Account_Extension__c accEx2 = new Account_Extension__c();
        accEx.Customer_Success_Engagement__c= 'Tech';
        accEx2.Customer_Success_Engagement__c='';
        insert acc;
        insert acc2;
        System.debug('acc.type'+acc.Type);
        System.debug('acc2.type'+acc2.Type);
        accEx.Account__c=  acc.id;
        accEx2.Account__c= acc2.id;
        insert accEx;
        insert accEx2;
        Product2 zscProd =TestDatafactory_Zscaler.createProduct('test product 1','ZCES-SUP-PREM','Zscaler Products','Standalone', 'ZIA');
        insert zscProd;
        //Product2 prod = createProduct('Zscaler Enterprise Guest Wi-Fi Security', 'ZSC-ENT-GWIFI-3YR-A', 'Products', 'Standalone');

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
        contractDetail2.Product_Name__c = zscProd.Id;
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
        insert contractDetail1;
        insert contractDetail2;
        insert contractDetail3;
    }  
    
    static testMethod void testmethod1(){
        Test.startTest();
        CSEngagementUpdateBatch batch;
        batch = new CSEngagementUpdateBatch('select id, type, Account_Renewable_ACV__c,(Select id, Customer_Success_Engagement__c  from Account_Extensions__r) from Account');

        batch.errorlst = new List<String>{'abc'};
        Database.executeBatch(batch,200);
        //Database.executeBatch(new CSEngagementUpdateBatch('select id, type, Account_Renewable_ACV__c,(Select id, Customer_Success_Engagement__c  from Account_Extensions__r) from Account where type=\'Customer\'') ,200);
        Test.stopTest();           
    }
}