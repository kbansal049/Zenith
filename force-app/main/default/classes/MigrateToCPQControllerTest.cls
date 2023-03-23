@isTest
public class MigrateToCPQControllerTest{

    @testSetup static void setup() {
        insert TestDatafactory_Zscaler.skusNSInteg();
        
        // Account
        Account acc = new Account();
        acc.Name = 'TestAccount';
        acc.TAM_Email__c = 'abc@abc.com';
        insert acc;
        
        // Contract
        Contract ct = new Contract ();
        ct.AccountId = acc.Id;
        ct.Status = 'New';
        ct.StartDate = system.today();
        ct.ContractTerm = 12;
        insert ct;
        
        // Order
        Order od = new Order();
        od.Name = 'TestOrder';
        od.Order_Date__c = system.today();
        od.AccountId = acc.Id;
        od.NS_Sales_Order_Number__c = 'test1234';
        od.EffectiveDate = system.today();
        od.EndDate = system.today() + 10; 
        od.Status = 'Draft';
        od.Location__c = 'India';
        od.NS_Sales_Order_Number__c ='NS123';
        insert od;
        
        //Product
        Product2 prod= new Product2();
        prod.Name = 'TestProduct';
        prod.Product_Line__c = 'Support';
        prod.ProductCode = 'ZIA-PRO-BUNDLE';
        prod.IsActive = true;
        prod.Zscaler_Product_Family__c = 'ZIA';
        prod.Price_List__c = 'FY20 Pricelist';  
        insert prod;
        
        // Subscription
        SBQQ__Subscription__c subs = new SBQQ__Subscription__c();
        subs.SBQQ__Quantity__c = 2;
        subs.SBQQ__Product__c = prod.Id;
        subs.SBQQ__Account__c= acc.Id;
        subs.SBQQ__Contract__c = ct.Id;
        insert subs;
        
        // Opportunity
        opportunity oppty= new opportunity();
        oppty.Name = 'Testopportunity';
        oppty.Primary_Quote_Exception__c  = true; 
        oppty.AccountId = acc.Id;
        oppty.StageName = '6 - Closed Won';
        oppty.CloseDate = system.Today()+30;
        oppty.Netsuite_Sales_Order_Number__c = 'TestOrder';
        oppty.Applied_Price_List_Name__c = 'FY20 Pricelist';
        insert Oppty;
        
        // Product Feature
        SBQQ__ProductFeature__c pf = new SBQQ__ProductFeature__c();
        pf.Name = 'TestProductFeature';
        pf.SBQQ__MinOptionCount__c = 1;
        pf.SBQQ__Number__c = 4;
        pf.SBQQ__ConfiguredSKU__c = prod.Id;
        insert pf;
        
        // Product Option 
        SBQQ__ProductOption__c po = new SBQQ__ProductOption__c();
        po.SBQQ__Number__c = 123 ;
        po.SBQQ__ConfiguredSKU__c = prod.Id;
        po.SBQQ__OptionalSKU__c =  prod.Id;
        insert po;
        
        // Contract Detail
        Contract_Detail__c cd = new Contract_Detail__c();
        cd.Name = 'TestContractDetail';
        cd.Account_Name__c = acc.Id;
        cd.Start_Date__c = system.today();
        cd.End_Date__c = system.today() + 10;
        cd.Contract_No__c = '123';
        cd.Quantity__c = 2;
        cd.MRR_USD__c = 250;
        cd.Amount_USD__c = 250;
        cd.Product_Name__c = prod.Id;
        cd.Contract_Detail_Status__c = 'Active';
        cd.Sales_Order__c = od.Id;
        insert cd;
        
        
        
    }
    
    public static testMethod void convertToContractTest1(){
    
        Account acc = [SELECT Id FROM Account WHERE Name ='TestAccount'];
        Product2 prod = [select id from Product2];
        Test.startTest();
            MigrateToCPQController.convertToContract(acc.Id);
            CPQDataMigrationBatch dataMigBatch = new CPQDataMigrationBatch('Select id,Is_Migrated__c,Use_Case__c from account limit 1');
            Database.executeBatch(dataMigBatch);
        Test.stopTest();
        
        Contract_Detail__c  cd1 = [SELECT Opportunity__c FROM Contract_Detail__c];
    }
    
    // no contract detail record
    public static testMethod void convertToContractTest2(){
    
        Account acc = [SELECT Id FROM Account WHERE Name ='TestAccount'];
        Product2 prod = [select id from Product2];
         Test.startTest();
            MigrateToCPQController.convertToContract(null);
            CPQDataMigrationBatch dataMigBatch = new CPQDataMigrationBatch('Select id,Is_Migrated__c,Use_Case__c from account limit 1');
            Database.executeBatch(dataMigBatch);
        Test.stopTest();
    }
    
    // no sales order
    public static testMethod void convertToContractTest3(){
        
        Account acc = [SELECT Id FROM Account WHERE Name ='TestAccount'];
        Product2 prod = [select id from Product2];
        Contract_Detail__c  cd = [SELECT Sales_Order__c FROM Contract_Detail__c WHERE Name ='TestContractDetail'];
        cd.Sales_Order__c = null;
        update cd;
        
        Test.startTest();
            MigrateToCPQController.convertToContract(acc.Id);
            CPQDataMigrationBatch dataMigBatch = new CPQDataMigrationBatch('Select id,Is_Migrated__c,Use_Case__c from account limit 1');
            Database.executeBatch(dataMigBatch);
        Test.stopTest();
    }
    
    public static testMethod void updatePhantomAndPOTest1(){
    
        Account acc = [SELECT Id FROM Account WHERE Name ='TestAccount'];
        Product2 prod = [select id from Product2];
        Contract_Detail__c  cd = [SELECT Opportunity__c FROM Contract_Detail__c WHERE Name ='TestContractDetail'];
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'Testopportunity'];
        
        cd.Opportunity__c =opp.Id;
        update cd;
        
        Test.startTest();
            MigrateToCPQController.convertToContract(acc.Id);
            CPQDataMigrationBatch dataMigBatch = new CPQDataMigrationBatch('Select id,Is_Migrated__c,Use_Case__c from account limit 1');
            Database.executeBatch(dataMigBatch);
        Test.stopTest();
    
    }
    
    public static testMethod void updatePhantomAndPOTest2(){
        
        Account acc = [SELECT Id FROM Account WHERE Name ='TestAccount'];
        Product2 prod = [select id from Product2];
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'Testopportunity'];
        
        delete opp;
        
        Test.startTest();
            MigrateToCPQController.convertToContract(acc.Id);
            CPQDataMigrationBatch dataMigBatch = new CPQDataMigrationBatch('Select id,Is_Migrated__c,Use_Case__c from account limit 1');
            Database.executeBatch(dataMigBatch);
        Test.stopTest();
        
    }
    
    public static testMethod void coTermAccountTest1(){
    
        Test.startTest();
            
            Account acc = [SELECT Id, Use_case__c, Billing_Frequency__c, Model_Type_Partner__c, Partner_Tier__c  FROM Account WHERE Name ='TestAccount'];
            
            acc.Use_case__c  = 'Co-Term';
            acc.Billing_Frequency__c = 'Annual';
            acc.Model_Type_Partner__c = 'Traditional';
            acc.Partner_Tier__c = 'Zenith';
            update acc;
            
            Product2 prod = [SELECT Id, Name, pricing_meter__c, SBQQ__SubscriptionType__c FROM Product2 WHERE Name = 'TestProduct'];
            
            prod.Name = 'Premium Support';
            prod.pricing_meter__c = 'Per User Per Year';
            prod.SBQQ__SubscriptionType__c = 'Renewable';
            update prod;
            
            Contract_Detail__c  cd = [SELECT Opportunity__c, Ignore_Migration__c, Partner_Account_Name__c, Phantom_SKU__c, Product_Option__c   
                                        FROM Contract_Detail__c WHERE Name ='TestContractDetail'];
                                        
            Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'Testopportunity'];
            
            SBQQ__ProductOption__c po = [SELECT Id FROM SBQQ__ProductOption__c WHERE SBQQ__Number__c= 123];
            
            cd.Opportunity__c = opp.Id;
            cd.Ignore_Migration__c = false;
            cd.Partner_Account_Name__c = acc.Id;
            cd.Phantom_SKU__c = prod.Id;
            cd.Product_Option__c  = po.Id;
            update cd;
        
            CPQDataMigrationBatch dataMigBatch = new CPQDataMigrationBatch('Select id,Is_Migrated__c,Use_Case__c from account limit 1');
            Database.executeBatch(dataMigBatch);
            
        Test.stopTest();
    
    }
    
    public static testMethod void coTermAccountTest2(){
    
        Test.startTest();
            
            Account acc = [SELECT Id, Use_case__c, Billing_Frequency__c, Model_Type_Partner__c, Partner_Tier__c  FROM Account WHERE Name ='TestAccount'];
            
            acc.Use_case__c  = 'Co-Term';
            acc.Billing_Frequency__c = 'Annual';
            acc.Model_Type_Partner__c = 'Traditional';
            acc.Partner_Tier__c = 'Zenith';
            update acc;
            
            Product2 prod = [SELECT Id, Name, pricing_meter__c, SBQQ__SubscriptionType__c FROM Product2 WHERE Name = 'TestProduct'];
            
            prod.Name = 'Premium Support1';
            prod.pricing_meter__c = 'Per User Per Year';
            prod.SBQQ__SubscriptionType__c = 'Renewable';
            update prod;
            
            Contract_Detail__c  cd = [SELECT Opportunity__c, Ignore_Migration__c, Partner_Account_Name__c, Phantom_SKU__c, Product_Option__c   
                                        FROM Contract_Detail__c WHERE Name ='TestContractDetail'];
                                        
            Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'Testopportunity'];
            
            SBQQ__ProductOption__c po = [SELECT Id FROM SBQQ__ProductOption__c WHERE SBQQ__Number__c= 123];
            
            cd.Opportunity__c = opp.Id;
            cd.Ignore_Migration__c = false;
            cd.Partner_Account_Name__c = acc.Id;
            cd.Phantom_SKU__c = prod.Id;
            cd.Product_Option__c  = po.Id;
            update cd;
        
        
            CPQDataMigrationBatch dataMigBatch = new CPQDataMigrationBatch('Select id,Is_Migrated__c,Use_Case__c from account limit 1');
            Database.executeBatch(dataMigBatch);
            
        Test.stopTest();
    
    }
    
    public static testMethod void nonCoTermAccountTest1(){
    
        Test.startTest();
        
            Account acc = [SELECT Id, Use_case__c, Billing_Frequency__c, Model_Type_Partner__c, Partner_Tier__c  FROM Account WHERE Name ='TestAccount'];
            
            acc.Use_case__c  = 'Non Co-Term';
            acc.Billing_Frequency__c = 'Annual';
            acc.Model_Type_Partner__c = 'Traditional';
            acc.Partner_Tier__c = 'Zenith';
            update acc;
            
            Product2 prod = [SELECT Id, Name, pricing_meter__c, SBQQ__SubscriptionType__c FROM Product2 WHERE Name = 'TestProduct'];
            
            prod.Name = 'Premium Support';
            prod.pricing_meter__c = 'Per User Per Year';
            prod.SBQQ__SubscriptionType__c = 'Renewable';
            update prod;
            
            Contract_Detail__c  cd = [SELECT Opportunity__c, Ignore_Migration__c, Partner_Account_Name__c, Phantom_SKU__c, Product_Option__c   
                                        FROM Contract_Detail__c WHERE Name ='TestContractDetail'];
                                        
        
            Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'Testopportunity'];
            
            SBQQ__ProductOption__c po = [SELECT Id FROM SBQQ__ProductOption__c WHERE SBQQ__Number__c= 123];
            
            cd.Opportunity__c = opp.Id;
            cd.Ignore_Migration__c = false;
            cd.Partner_Account_Name__c = acc.Id;
            cd.Phantom_SKU__c = prod.Id;
            cd.Product_Option__c  = po.Id;
            update cd;
            
            String accIds = String.valueof(acc.id);
        
            CPQDataMigrationBatch dataMigBatch = new CPQDataMigrationBatch('Select id,Is_Migrated__c,Use_Case__c from account limit 1');
            Database.executeBatch(dataMigBatch,1);  
                      
        Test.stopTest();
    
    }
    
    public static testMethod void nonCoTermAccountTest2(){
    
        Test.startTest();
        
            Account acc = [SELECT Id, Use_case__c, Billing_Frequency__c, Model_Type_Partner__c, Partner_Tier__c  FROM Account WHERE Name ='TestAccount'];
            
            acc.Use_case__c  = 'Non Co-Term';
            acc.Billing_Frequency__c = 'Annual';
            acc.Model_Type_Partner__c = 'Traditional';
            acc.Partner_Tier__c = 'Zenith';
            update acc;
            
            Product2 prod = [SELECT Id, Name, pricing_meter__c, SBQQ__SubscriptionType__c FROM Product2 WHERE Name = 'TestProduct'];
            
            prod.Name = 'Premium Support1';
            prod.pricing_meter__c = 'Per User Per Year';
            prod.SBQQ__SubscriptionType__c = 'Renewable';
            update prod;
            
            Contract_Detail__c  cd = [SELECT Opportunity__c, Ignore_Migration__c, Partner_Account_Name__c, Phantom_SKU__c, Product_Option__c   
                                        FROM Contract_Detail__c WHERE Name ='TestContractDetail'];
                                        
        
            Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'Testopportunity'];
            
            SBQQ__ProductOption__c po = [SELECT Id FROM SBQQ__ProductOption__c WHERE SBQQ__Number__c= 123];
            
            cd.Opportunity__c = opp.Id;
            cd.Ignore_Migration__c = false;
            cd.Partner_Account_Name__c = acc.Id;
            cd.Phantom_SKU__c = prod.Id;
            cd.Product_Option__c  = po.Id;
            update cd;
            
            String accIds = String.valueof(acc.id);
        
            CPQDataMigrationBatch dataMigBatch = new CPQDataMigrationBatch('Select id,Is_Migrated__c,Use_Case__c from account limit 1');
            Database.executeBatch(dataMigBatch,1);  
                      
        Test.stopTest();
    
    }
}