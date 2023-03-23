@isTest
public class AccountCustomerLifeCycleBatchTest{
    
    static testmethod void test1(){
        List<SKUs_Referred_in_Renewal_Upsell_NS_Calc__c> skus = new List<SKUs_Referred_in_Renewal_Upsell_NS_Calc__c>();
        SKUs_Referred_in_Renewal_Upsell_NS_Calc__c ziaSKUs = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c();
        ziaSKUs.Name = 'Opportunity_Product_ZIA_SKU';
        ziaSKUs.SKU_Codes__c = 'ZIA-PRO-BUNDLE;ZIA-BUS-BUNDLE;ZIA-TRANS-BUNDLE;ZCES-SUP-PREM;ZIA-ELA-BUNDLE;ZIA-PRO-BUNDLE-LU;ZIA-BUS-BUNDLE-LU;ZIA-TRANS-BUNDLE-LU;ZIA-ELA-BUNDLE-LU;ZSC-SIP-LOC;ZIA-SIP;ZS-WFA-BUS-EDITION';
        skus.add(ziaSKUs);
        SKUs_Referred_in_Renewal_Upsell_NS_Calc__c ziaSKU1s = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c();
        ziaSKU1s.Name = 'Opportunity_Product_ZIA_SKU_1';
        ziaSKU1s.SKU_Codes__c = 'ZSC-SIP';
        skus.add(ziaSKU1s);
        
        SKUs_Referred_in_Renewal_Upsell_NS_Calc__c zpaSKUs = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c();
        zpaSKUs.Name = 'Opportunity_Product_ZPA_SKU';
        zpaSKUs.SKU_Codes__c = 'ZPA-BBA;ZPA-BUS;ZPA-ENT;ZPA-PRO;ZPA-PRO-LU;ZPA-BUS-LU;ZPA-BUS-EDITION;ZPA-PRO-EDITION;ZPA-BUS-EDITION-LU;ZIA-PRO-EDITION-LU;ZPA-TRANS-EDITION;ZS-WFA-BUS-EDITION';
        skus.add(zpaSKUs);
        
        insert skus;
        Account account = new Account(Name = 'Test Account');
        account.Type = 'Customer';
        account.Last_QBR_Date__c = null;
        account.CSM_Name_New__c = UserInfo.getUserId();
        //account.First_Contract_Date__c=date.today()-180;
        account.First_ZPA_Contract_Date__c=date.today()-180;
        account.Date_when_traffic_consumed_is_25__c=date.today()-180;
        account.X25_ZPA_Traffic_attained_date__c=date.today()-180;
        insert account;
        
        Opportunity opportunity = new Opportunity(Name = 'Test Opportunity', CloseDate = Date.today() + 30, StageName = label.Stage_1_Alignment, Type = 'Existing Customer (Renewal)', AccountId = account.Id, Netsuite_Sales_Order_No__c = 'Test Order 1',Contract_End_Date_New__c=Date.today()-1,Reason_for_Delay__c='Test');
        insert opportunity;
        
        Account_Extension__c accExt = new Account_Extension__c();
        accExt.Account__c = account.Id;
        accExt.Latest_ZIA_Contract_Date__c = date.today();
        accExt.Latest_ZPA_Contract_Date__c = date.today();
        insert accExt;
        
        Customer_Score_Card__c csc = new Customer_Score_Card__c();
        csc.Account__c = account.Id;
        insert csc;
        
        Test.StartTest();
        Database.executeBatch(new AccountCustomerLifeCycleBatch('SELECT Id, Type, CSM_Name_New__c, Last_QBR_Date__c, Avg_Estimated_Users_L31D_Vs_Purchase__c, ZPA_Enrolled_users_L31D_Vs_Purchase__c, Users_with_ZApp__c, Users_ZPA_Platform__c,No_of_Platform_Seats__c, First_Contract_Date__c, First_ZPA_Contract_Date__c,Date_when_traffic_consumed_is_25__c,X25_ZPA_Traffic_attained_date__c,Customer_Lifecycle__c FROM ACCOUNT'));
        Test.StopTest();
    }
    
    
    static testmethod void test2(){
        List<SKUs_Referred_in_Renewal_Upsell_NS_Calc__c> skus = new List<SKUs_Referred_in_Renewal_Upsell_NS_Calc__c>();
        SKUs_Referred_in_Renewal_Upsell_NS_Calc__c ziaSKUs = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c();
        ziaSKUs.Name = 'Opportunity_Product_ZIA_SKU';
        ziaSKUs.SKU_Codes__c = 'ZIA-PRO-BUNDLE;ZIA-BUS-BUNDLE;ZIA-TRANS-BUNDLE;ZCES-SUP-PREM;ZIA-ELA-BUNDLE;ZIA-PRO-BUNDLE-LU;ZIA-BUS-BUNDLE-LU;ZIA-TRANS-BUNDLE-LU;ZIA-ELA-BUNDLE-LU;ZSC-SIP-LOC;ZIA-SIP;ZS-WFA-BUS-EDITION';
        skus.add(ziaSKUs);
        
        SKUs_Referred_in_Renewal_Upsell_NS_Calc__c ziaSKU1s = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c();
        ziaSKU1s.Name = 'Opportunity_Product_ZIA_SKU_1';
        ziaSKU1s.SKU_Codes__c = 'ZSC-SIP';
        skus.add(ziaSKU1s);
        
        SKUs_Referred_in_Renewal_Upsell_NS_Calc__c zpaSKUs = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c();
        zpaSKUs.Name = 'Opportunity_Product_ZPA_SKU';
        zpaSKUs.SKU_Codes__c = 'ZPA-BBA;ZPA-BUS;ZPA-ENT;ZPA-PRO;ZPA-PRO-LU;ZPA-BUS-LU;ZPA-BUS-EDITION;ZPA-PRO-EDITION;ZPA-BUS-EDITION-LU;ZIA-PRO-EDITION-LU;ZPA-TRANS-EDITION;ZS-WFA-BUS-EDITION';
        skus.add(zpaSKUs);
        
        insert skus;
        Account account = new Account(Name = 'Test Account');
        account.Type = 'Customer';
        account.Last_QBR_Date__c = date.today();
        //account.First_Contract_Date__c=date.today()-180;
        account.First_ZPA_Contract_Date__c=date.today()-180;
        account.Date_when_traffic_consumed_is_25__c=date.today()-180;
        account.X25_ZPA_Traffic_attained_date__c=date.today()-180;
        insert account;
        
        Account_Extension__c accExt = new Account_Extension__c();
        accExt.Account__c = account.Id;
        accExt.Latest_ZIA_Contract_Date__c = date.today();
        accExt.Latest_ZPA_Contract_Date__c = date.today();
        insert accExt;
        
        Customer_Score_Card__c csc = new Customer_Score_Card__c();
        csc.Account__c = account.Id;
        insert csc;
      
        //Insert Price List
        
        
        //Insert Products
        List<Product2> listProduct = new list<Product2>();
        listProduct.add(OppotunityTriggerHelperTest.createProduct('Zscaler ZPA', 'ZPA-BBA', 'Products', 'Standalone'));
        listProduct.add(OppotunityTriggerHelperTest.createProduct('Product2', 'ZIA-PRO-BUNDLE', 'Products', 'Standalone'));
        listProduct.add(OppotunityTriggerHelperTest.createProduct('Product3', 'CODE03', 'Products', 'Standalone'));
        listProduct.add(OppotunityTriggerHelperTest.createProduct('Zscaler Enterprise Guest Wi-Fi Security', 'ZSC-ENT-GWIFI-3YR-A', 'Zscaler Products', 'Standalone'));
        listProduct.add(OppotunityTriggerHelperTest.createProduct('Product22', 'ZCES-SUP-PREM', 'Zscaler Products', 'Standalone'));
        listProduct.add(OppotunityTriggerHelperTest.createProduct('Product33', 'CODE04', 'Zscaler Products', 'Standalone'));
        insert listProduct;
        
        Pricebook2 standardPB1 = new Pricebook2(Name = 'Standard Price Book 2009', Description = 'Price Book 2009 Products', IsActive = true);
        insert standardPB1 ;
        
        Id standardPB = Test.getStandardPricebookId();
        //Insert Procebookentry
        List<PricebookEntry> listPBEntry = new List<PricebookEntry>();
        listPBEntry.add(createPriceBookEntry(listProduct[0],standardPB));
        listPBEntry.add(createPriceBookEntry(listProduct[1],standardPB ));
        insert listPBEntry;

        //create PriceListIteams
        
        opportunity opp = new opportunity(Name = 'Test opportunity', AccountId = account.Id, StageName = label.Stage_7_Closed_Lost,Sub_Stage__c='Closed Lost',SE_name__c = UserInfo.getUserId(), NextStep = 'Test 1',Type='Existing Customer (Renewal)',Reason_for_Delay__c='Test',
                            CloseDate = system.Today()+30, Primary_Quote_Exception__c = true, Validation_Stage__c = '6 - Technical Win', Validation_Plan__c = 'Test', AD_Forecast_Category__c='Pipeline',AD_Forecast_Category_Lock__c=true,Next_Steps__c  = 'fdsjsdk', Pricebook2ID=Test.getStandardPricebookId());
        insert opp;

        List<OpportunityLineItem> lstLineItems = new List<OpportunityLineItem>();
        OpportunityLineItem lineItem1 = new OpportunityLineItem(
                                            OpportunityId = opp.Id,
                                            Product2Id = listProduct[0].Id,
                                            pricebookentryId = listPBEntry[0].Id
                                        );

        lstLineItems.add(lineItem1);

        OpportunityLineItem lineItem2 = new OpportunityLineItem(
                                            OpportunityId = opp.Id,
                                            Product2Id = listProduct[1].Id,
                                            pricebookentryId = listPBEntry[1].Id
                                        );

        lstLineItems.add(lineItem2);
        insert lstLineItems;
        
        Test.StartTest();
        Database.executeBatch(new AccountCustomerLifeCycleBatch('SELECT Id, Type, CSM_Name_New__c, Last_QBR_Date__c, Avg_Estimated_Users_L31D_Vs_Purchase__c, ZPA_Enrolled_users_L31D_Vs_Purchase__c, Users_with_ZApp__c, Users_ZPA_Platform__c,No_of_Platform_Seats__c, First_Contract_Date__c, First_ZPA_Contract_Date__c,Date_when_traffic_consumed_is_25__c,X25_ZPA_Traffic_attained_date__c,Customer_Lifecycle__c FROM ACCOUNT'));
        Test.StopTest();
    }
    
    static testmethod void test3(){
        AccountCustomerLifeCycleBatchSch m = new AccountCustomerLifeCycleBatchSch();
        String sch = '0 36 1 * * ?';
        String jobID = system.schedule('test ren notification exp rem', sch, m);
    }
    
    static testmethod void test4(){
        List<SKUs_Referred_in_Renewal_Upsell_NS_Calc__c> skus = new List<SKUs_Referred_in_Renewal_Upsell_NS_Calc__c>();
        SKUs_Referred_in_Renewal_Upsell_NS_Calc__c ziaSKUs = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c();
        ziaSKUs.Name = 'Opportunity_Product_ZIA_SKU';
        ziaSKUs.SKU_Codes__c = 'ZIA-PRO-BUNDLE;ZIA-BUS-BUNDLE;ZIA-TRANS-BUNDLE;ZCES-SUP-PREM;ZIA-ELA-BUNDLE;ZIA-PRO-BUNDLE-LU;ZIA-BUS-BUNDLE-LU;ZIA-TRANS-BUNDLE-LU;ZIA-ELA-BUNDLE-LU;ZSC-SIP-LOC;ZIA-SIP;ZS-WFA-BUS-EDITION';
        skus.add(ziaSKUs);
        
        SKUs_Referred_in_Renewal_Upsell_NS_Calc__c ziaSKU1s = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c();
        ziaSKU1s.Name = 'Opportunity_Product_ZIA_SKU_1';
        ziaSKU1s.SKU_Codes__c = 'ZSC-SIP';
        skus.add(ziaSKU1s);
        
        SKUs_Referred_in_Renewal_Upsell_NS_Calc__c zpaSKUs = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c();
        zpaSKUs.Name = 'Opportunity_Product_ZPA_SKU';
        zpaSKUs.SKU_Codes__c = 'ZPA-BBA;ZPA-BUS;ZPA-ENT;ZPA-PRO;ZPA-PRO-LU;ZPA-BUS-LU;ZPA-BUS-EDITION;ZPA-PRO-EDITION;ZPA-BUS-EDITION-LU;ZIA-PRO-EDITION-LU;ZPA-TRANS-EDITION;ZS-WFA-BUS-EDITION';
        skus.add(zpaSKUs);
        
        insert skus;
        Account account = new Account(Name = 'Test Account');
        account.Type = 'Customer';
        account.Last_QBR_Date__c = date.today();
        //account.First_Contract_Date__c=date.today()-180;
        account.First_ZPA_Contract_Date__c=date.today()-180;
        account.Date_when_traffic_consumed_is_25__c=date.today()-180;
        account.X25_ZPA_Traffic_attained_date__c=date.today()-180;
        insert account;
        
        Account_Extension__c accExt = new Account_Extension__c();
        accExt.Account__c = account.Id;
        insert accExt;
        
        Customer_Score_Card__c csc = new Customer_Score_Card__c();
        csc.Account__c = account.Id;
        insert csc;
        
        Test.StartTest();
        Database.executeBatch(new AccountCustomerLifeCycleBatch('SELECT Id, Type, CSM_Name_New__c, Last_QBR_Date__c, Avg_Estimated_Users_L31D_Vs_Purchase__c, ZPA_Enrolled_users_L31D_Vs_Purchase__c, Users_with_ZApp__c, Users_ZPA_Platform__c,No_of_Platform_Seats__c, First_Contract_Date__c, First_ZPA_Contract_Date__c,Date_when_traffic_consumed_is_25__c,X25_ZPA_Traffic_attained_date__c,Customer_Lifecycle__c FROM ACCOUNT'));
        Test.StopTest();
    }
    
    public static PricebookEntry createPriceBookEntry(Product2 prod, Id pricBookID){
        PricebookEntry PBEntry = new PricebookEntry();
        PBEntry.IsActive =true;
        PBEntry.UnitPrice = 100;
        PBEntry.Product2Id = Prod.Id;
        PBEntry.Pricebook2Id = pricBookID;
        return PBEntry;
    }
}