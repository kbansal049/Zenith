@isTest
public class CustomerScorecardBatchTest {
    
    @isTest
    public static void testMethod1(){
        
        //Insert Account
        Account account = TestDatafactory_Zscaler.insertAccount('Test Account', 'josepadin@zscaler.com', 'test', null, null, 5);
        Account account1 = TestDatafactory_Zscaler.insertAccount('Test Account', 'josepadin@zscaler.com', 'test', null, null, 5);
        
        Zscaler_Cloud_ID__c zci = new Zscaler_Cloud_ID__c();
        zci.Account__c = account.Id;
        insert zci;
        
        Zscaler_Cloud_ID__c zci1 = new Zscaler_Cloud_ID__c();
        zci1.Account__c = account1.Id;
        insert zci1;
        
        
        Customer_Score_Card__c csc = new Customer_Score_Card__c();
        csc.Account__c = account.Id;
        csc.UnAuth_Traffic_From_Auth_Loc_L30D_TB__c = 0.00;
        csc.UnAuth_Traffic_From_UnAuth_Loc_L30D_TB__c = 0.00;
        
        insert csc;
        
        List<Cloud_Usage__c> cloudUsgs = new List<Cloud_Usage__c>();
        Cloud_Usage__c cu = new Cloud_Usage__c();
        cu.Account__c = account.Id;
        cu.Zscaler_Cloud_ID__c = zci.Id;
        cu.Auth__c =10234; 
        cu.Cloud_Usage_Type__c = 'ZIA';
        cu.Last_31_Days__c = true;
        cloudUsgs.add(cu);
        
        Cloud_Usage__c cu1 = new Cloud_Usage__c();
        cu1.Account__c = account.Id;
        cu1.Zscaler_Cloud_ID__c = zci.Id; 
        cu1.Unauth_Location_Unauth_Bytes__c = 1231424;
        cu1.Cloud_Usage_Type__c = 'ZIA';
        cu1.Last_31_Days__c = true;
        cloudUsgs.add(cu1);
        
        Cloud_Usage__c cu2 = new Cloud_Usage__c();
        cu2.Account__c = account1.Id;
        cu2.Zscaler_Cloud_ID__c = zci1.Id;
        cu2.Auth__c =10234; 
        cu2.Cloud_Usage_Type__c = 'ZIA';
        cu2.Last_31_Days__c = true;
        cloudUsgs.add(cu2);
        
        Cloud_Usage__c cu3 = new Cloud_Usage__c();
        cu3.Account__c = account1.Id;
        cu3.Zscaler_Cloud_ID__c = zci1.Id;
        cu3.Unauth_Location_Unauth_Bytes__c = 1231424;
        cu3.Cloud_Usage_Type__c = 'ZIA';
        cu3.Last_31_Days__c = true;
        cloudUsgs.add(cu3);
        
        insert cloudUsgs;
        
        
        Test.startTest();
        Database.executebatch(new CustomerScorecardBatch('Select  Account__c, Auth__c, Unauth_Location_Unauth_Bytes__c FROM Cloud_Usage__c Where Last_31_Days__c =true  and Cloud_Usage_Type__c=\'ZIA\''));
        Test.stopTest();
        
    }
    
    @isTest
    public static void testMethod2(){
        Account account = TestDatafactory_Zscaler.insertAccount('Test Account', 'josepadin@zscaler.com', 'test', null, null, 5);
        Account account1 = TestDatafactory_Zscaler.insertAccount('Test Account', 'josepadin@zscaler.com', 'test', null, null, 5);
        
        List<Customer_Score_Card__c> lstCSC = new List<Customer_Score_Card__c>();
        Customer_Score_Card__c csc = new Customer_Score_Card__c();
        csc.Account__c = account.Id;
        csc.UnAuth_Traffic_From_Auth_Loc_L30D_TB__c = 0.00;
        csc.UnAuth_Traffic_From_UnAuth_Loc_L30D_TB__c = 0.00;
        lstCSC.add(csc);
        
        Customer_Score_Card__c csc1 = new Customer_Score_Card__c();
        csc1.UnAuth_Traffic_From_Auth_Loc_L30D_TB__c = 0.00;
        csc1.UnAuth_Traffic_From_UnAuth_Loc_L30D_TB__c = 0.00;
        lstCSC.add(csc1);
        
        Test.startTest();
        CustomerScorecardBatchExt batchExt = new CustomerScorecardBatchExt(lstCSC);
        batchExt.errorlst.add('Only For Coverage');
        Database.executebatch(batchExt);
        Test.stopTest();        
    }
    
    @isTest
    public static void testMethod3(){
        Test.startTest();
        CustomerScorecardBatchSch sche = new CustomerScorecardBatchSch(); 
        String sch ='0 0 0 * * ?'; 
        System.schedule('Scheduler Test', sch,sche);
        Test.stopTest();        
    }
    
    @isTest
    public static void testMethod4(){
        Account account = TestDatafactory_Zscaler.insertAccount('Test Account', 'josepadin@zscaler.com', 'test', null, null, 5);
        Account account1 = TestDatafactory_Zscaler.insertAccount('Test Account', 'josepadin@zscaler.com', 'test', null, null, 5);
        
        List<Customer_Score_Card__c> lstCSC = new List<Customer_Score_Card__c>();
        Customer_Score_Card__c csc = new Customer_Score_Card__c();
        csc.Account__c = account.Id;
        csc.UnAuth_Traffic_From_Auth_Loc_L30D_TB__c = 0.00;
        csc.UnAuth_Traffic_From_UnAuth_Loc_L30D_TB__c = 0.00;
        lstCSC.add(csc);
        
        Customer_Score_Card__c csc1 = new Customer_Score_Card__c();
        csc1.Account__c = account1.Id;
        csc1.UnAuth_Traffic_From_Auth_Loc_L30D_TB__c = 0.00;
        csc1.UnAuth_Traffic_From_UnAuth_Loc_L30D_TB__c = 0.00;
        lstCSC.add(csc1);
        
        insert lstCSC;
        
        Test.startTest();
        CleanCustomerScorecardBatch batchExt = new CleanCustomerScorecardBatch('Select Id FROM Customer_Score_Card__c');
        Database.executebatch(batchExt);
        Test.stopTest();        
    }
    
}