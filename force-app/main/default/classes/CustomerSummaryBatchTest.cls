@isTest
public class CustomerSummaryBatchTest {
    
    @testSetup 
    static void createTestData() 
    {
        Skip_Triggers__c skipTriggers = new Skip_Triggers__c();
        skipTriggers.Skip_Account_Triggers__c = true;
        skipTriggers.Skip_Opportunity_Triggers__c = true;
        skipTriggers.Name = 'SkipTriggers';
        insert skipTriggers;
        
        TriggerUtility.SkipEmailMessageTriggerReset();
        TriggerUtility.SkipAccTriggerExecuted();
        
        Account acct = new Account();
        acct.name = 'Test Account';
        acct.Type = 'Customer';
        acct.RecordTypeId = '01270000000EAFsAAO';
        acct.DS_Review_Status__c = 'Complete';
        insert acct;
        Id caseSupportRT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Support').getRecordTypeId();
        Case cs = new Case(Subject='abcd', AccountId =  acct.Id, Priority='Urgent (P1)', RecordTypeId=caseSupportRT, Defcon_Level__c='3', Description='abcdDes', Case_type__c = 'Problem');
        insert cs;
        
        //Added by Anup :CR#1047 - Start
        Customer_Score_Card__c custScoreCard = new Customer_Score_Card__c();
        custScoreCard.Account__c = acct.Id;
        insert custScoreCard;
        //Added by Anup :CR#1047 - End
        
        Product2 product = new Product2(ProductCode = 'ZSC-SIP', Name = 'Zscaler Internet Security Platform', Family = 'Zscaler Products',
                                        IsActive = true);
        insert product;
        
        //Added by Anup : Cr#1047 - Start
        Product2 product2 = new Product2(ProductCode = 'ZSC-SIP', Name = 'Zscaler Internet Security Platform', Family = 'ZIA',
                                         IsActive = true);
        insert product2;
        //Added by Anup : CR#1047 - End
        
        Contract_Detail__c  contract = new Contract_Detail__c();
        contract.Name = 'Test Contract';
        contract.Account_Name__c = acct.Id;
        contract.Quantity__c = 5000;
        contract.Contract_Detail_Status__c = 'Active';
        contract.Product_Name__c = product2.Id;
        contract.Do_not_Aggregate__c = false;
        contract.Override_Contract_Detail_Status__c = false;
        contract.Start_Date__c = Date.today().addDays(-100);
        contract.End_Date__c = Date.today().addDays(100);
        contract.Amount_USD__c = 50000.00;
        //Added by Anup : CR#1047-Start
        contract.ZScaler_Product_Family__c = 'ZIA';
        contract.Is_Bundle_SKU__c = true;
        //Added by Anup : CR#1047-End
        insert contract;
        
        Date dateToday = Date.today();
        Date thisMonth = dateToday.toStartOfMonth();
        date LastMonth = thisMonth.addMonths(-1);
        
        date LastMonthPlus2Days = thisMonth.addMonths(-1).addDays(2);
        date LastMonthPlus3Days = thisMonth.addMonths(-1).addDays(3);
        
        date twoMonthsAgo = thisMonth.addMonths(-2);
        date threeMonthsAgo = thisMonth.addMonths(-3);
        date SixMonthsAgo = thisMonth.addMonths(-6);
        date lastYearSameTime1 = thisMonth.addMonths(-13);
        date lastYearSameTime2 = thisMonth.addMonths(-14);
        date lastYearSameTime3 = thisMonth.addMonths(-15);
        
        Zscaler_Cloud_ID__c  cloudId = new Zscaler_Cloud_ID__c();
        cloudId.Name = '1441203345204183';
        cloudId.Account__c = acct.Id;
        cloudId.Status__c = 'Production';
        cloudId.Cloud_Type__c = 'ZIA';
        cloudId.RecordTypeId = '0120g000000YUcQAAW';
        
        insert cloudId;
        Zscaler_Cloud_ID__c  cloudIdZPA = new Zscaler_Cloud_ID__c();
        cloudIdZPA.Name = '72064079438544896';
        cloudIdZPA.Account__c = acct.Id;
        cloudIdZPA.Status__c = 'Production';
        cloudIdZPA.Cloud_Type__c = 'ZPA';
        cloudIdZPA.RecordTypeId = '0120g000000YUcVAAW';
        
        insert cloudIdZPA;
        
        List<Cloud_Usage__c> cloudList = new List<Cloud_Usage__c>();
        
        
        Cloud_Usage__c c1 = new Cloud_Usage__c();
        c1.Zscaler_Cloud_ID__c = cloudId.Id;
        c1.Account__c = acct.Id;
        c1.Total_Policy_Blocks__c = 200;
        c1.Total_Transactions__c = 1000;
        c1.Total_Transactions_Bandwidth__c = 10000;
        c1.Total_Security_Blocks__c = 600;
        c1.total_botnet_blocks__c = 300;
        c1.total_malware_site_blocks__c   = 100; 
        c1.total_phishing_blocks__c = 200;
        c1.Usage_Pull_Date__c = lastYearSameTime1;
        c1.total_ssl_transactions__c = 300;
        c1.total_ssl_inspected_transactions__c = 150;
        c1.Cloud_Usage_Type__c = 'ZIA';
        c1.total_ssl_inspected_bytes__c = 100;
        c1.total_ssl_bytes__c = 100;
        c1.Total_Office_365_Kb__c = 200;
        c1.ZPA_Active_Users__c = 300;
        cloudList.add(c1);
        
        Cloud_Usage__c c2 = new Cloud_Usage__c();
        c2.Zscaler_Cloud_ID__c = cloudId.Id;
        c2.Account__c = acct.Id;
        c2.Total_Policy_Blocks__c = 200;
        c2.Total_Transactions__c = 1000;
        c2.Total_Transactions_Bandwidth__c = 200000;
        c2.Total_Security_Blocks__c = 600;
        c2.total_botnet_blocks__c = 300;
        c2.total_malware_site_blocks__c   = 100; 
        c2.total_phishing_blocks__c = 200;
        c2.Usage_Pull_Date__c = lastYearSameTime2;
        c2.total_ssl_transactions__c = 300;
        c2.total_ssl_inspected_transactions__c = 150;
        c2.Cloud_Usage_Type__c = 'ZIA';
        c2.total_ssl_inspected_bytes__c = 100;
        c2.total_ssl_bytes__c = 100;
        c2.Total_Office_365_Kb__c = 200;
        c2.ZPA_Active_Users__c = 300;
        cloudList.add(c2);
        
        
        Cloud_Usage__c c3 = new Cloud_Usage__c();
        c3.Zscaler_Cloud_ID__c = cloudId.Id;
        c3.Account__c = acct.Id;
        c3.Total_Policy_Blocks__c = 200;
        c3.Total_Transactions__c = 1000;
        c3.Total_Transactions_Bandwidth__c = 30000;
        c3.Total_Security_Blocks__c = 600;
        c3.total_botnet_blocks__c = 300;
        c3.total_malware_site_blocks__c  = 100; 
        c3.total_phishing_blocks__c = 200;
        c3.Usage_Pull_Date__c = lastYearSameTime3;
        c3.total_ssl_transactions__c = 300;
        c3.total_ssl_inspected_transactions__c = 250;
        c3.Cloud_Usage_Type__c = 'ZIA';
        c3.total_ssl_inspected_bytes__c = 100;
        c3.total_ssl_bytes__c = 100;
        c3.Total_Office_365_Kb__c = 200;
        c3.ZPA_Active_Users__c = 300;
        cloudList.add(c3);
        
        Cloud_Usage__c c4 = new Cloud_Usage__c();
        c4.Zscaler_Cloud_ID__c = cloudId.Id;
        c4.Account__c = acct.Id;
        c4.Total_Policy_Blocks__c = 300;
        c4.Total_Transactions__c = 1300;
        c4.Total_Transactions_Bandwidth__c = 240000;
        c4.Total_Security_Blocks__c = 630;
        c4.total_botnet_blocks__c = 310;
        c4.total_malware_site_blocks__c   = 110; 
        c4.total_phishing_blocks__c = 210;
        c4.Usage_Pull_Date__c = LastMonth;
        c4.total_ssl_transactions__c = 300;
        c4.total_ssl_inspected_transactions__c = 300;
        c4.Cloud_Usage_Type__c = 'ZIA';
        c4.total_ssl_inspected_bytes__c = 100;
        c4.total_ssl_bytes__c = 100;
        c4.Total_Office_365_Kb__c = 100;
        c4.ZPA_Active_Users__c = 500;
        cloudList.add(c4);
        
        
        Cloud_Usage__c c41 = new Cloud_Usage__c();
        c41.Zscaler_Cloud_ID__c = cloudId.Id;
        c41.Account__c = acct.Id;
        c41.Total_Policy_Blocks__c = 200;
        c41.Total_Transactions__c = 1000;
        c41.Total_Transactions_Bandwidth__c = 10000;
        c41.Total_Security_Blocks__c = 600;
        c41.total_botnet_blocks__c = 300;
        c41.total_malware_site_blocks__c   = 100; 
        c41.total_phishing_blocks__c = 200;
        c41.Usage_Pull_Date__c = LastMonthPlus2Days;
        c41.total_ssl_transactions__c = 300;
        c41.total_ssl_inspected_transactions__c = 150;
        c41.Cloud_Usage_Type__c = 'ZIA';
        c41.ZPA_Active_Users__c = 300;
        cloudList.add(c41);
        
        Cloud_Usage__c c42 = new Cloud_Usage__c();
        c42.Zscaler_Cloud_ID__c = cloudId.Id;
        c42.Account__c = acct.Id;
        c42.Total_Policy_Blocks__c = 200;
        c42.Total_Transactions__c = 1000;
        c42.Total_Transactions_Bandwidth__c = 10000;
        c42.Total_Security_Blocks__c = 600;
        c42.total_botnet_blocks__c = 300;
        c42.total_malware_site_blocks__c   = 100; 
        c42.total_phishing_blocks__c = 200;
        c42.Usage_Pull_Date__c = LastMonthPlus3Days;
        c42.total_ssl_transactions__c = 300;
        c42.total_ssl_inspected_transactions__c = 150;
        c42.Cloud_Usage_Type__c = 'ZIA';
        c42.ZPA_Active_Users__c = 300;
        cloudList.add(c42);
        
        
        
        Cloud_Usage__c c5 = new Cloud_Usage__c();
        c5.Zscaler_Cloud_ID__c = cloudId.Id;
        c5.Account__c = acct.Id;
        c5.Total_Policy_Blocks__c = 300;
        c5.Total_Transactions__c = 1300;
        c5.Total_Transactions_Bandwidth__c = 10000;
        c5.Total_Security_Blocks__c = 630;
        c5.total_botnet_blocks__c = 310;
        c5.total_malware_site_blocks__c   = 110; 
        c5.total_phishing_blocks__c = 210;
        c5.Usage_Pull_Date__c = twoMonthsAgo;
        c5.total_ssl_transactions__c = 300;
        c5.total_ssl_inspected_transactions__c = 200;
        c5.Cloud_Usage_Type__c = 'ZIA';
        c5.ZPA_Active_Users__c = 300;
        cloudList.add(c5);
        
        Cloud_Usage__c c6 = new Cloud_Usage__c();
        c6.Zscaler_Cloud_ID__c = cloudId.Id;
        c6.Account__c = acct.Id;
        c6.Total_Policy_Blocks__c = 300;
        c6.Total_Transactions__c = 1300;
        c6.Total_Transactions_Bandwidth__c = 350000;
        c6.Total_Security_Blocks__c = 630;
        c6.total_botnet_blocks__c = 310;
        c6.total_malware_site_blocks__c   = 110; 
        c6.total_phishing_blocks__c = 210;
        c6.Usage_Pull_Date__c = threeMonthsAgo;
        c6.total_ssl_transactions__c = 300;
        c6.total_ssl_inspected_transactions__c = 300;
        c6.Cloud_Usage_Type__c = 'ZIA';
        c6.ZPA_Active_Users__c = 300;
        cloudList.add(c6);
        
        Cloud_Usage__c c10 = new Cloud_Usage__c();
        c10.Zscaler_Cloud_ID__c = cloudId.Id;
        c10.Account__c = acct.Id;
        c10.Total_Policy_Blocks__c = 300;
        c10.Total_Transactions__c = 1300;
        c10.Total_Transactions_Bandwidth__c = 350000;
        c10.Total_Security_Blocks__c = 630;
        c10.total_botnet_blocks__c = 310;
        c10.total_malware_site_blocks__c   = 110; 
        c10.total_phishing_blocks__c = 210;
        c10.Usage_Pull_Date__c = SixMonthsAgo;
        c10.total_ssl_transactions__c = 300;
        c10.total_ssl_inspected_transactions__c = 300;
        c10.Cloud_Usage_Type__c = 'ZIA';
        c10.ZPA_Active_Users__c = 300;
        cloudList.add(c10);
        
         Cloud_Usage__c c11 = new Cloud_Usage__c();
        c11.Zscaler_Cloud_ID__c = cloudId.Id;
        c11.Account__c = acct.Id;
        c11.User_Count__c=15;
        c11.Authenticated_Kilobytes_del_del__c=50;
        System.debug('@@@@Account Id from test is:'+c11.Account__c);
        c11.Total_Policy_Blocks__c = 300;
        c11.Total_Transactions__c = 1300;
        c11.Total_Transactions_Bandwidth__c = 350000;
        c11.Total_Security_Blocks__c = 630;
        c11.total_botnet_blocks__c = 310;
        c11.total_malware_site_blocks__c   = 110; 
        c11.total_phishing_blocks__c = 210;
        c11.Usage_Pull_Date__c = Date.today()-1;
        c11.total_ssl_transactions__c = 300;
        c11.total_ssl_inspected_transactions__c = 300;
        c11.Cloud_Usage_Type__c = 'ZIA';
        c11.ZPA_Active_Users__c = 300;
        cloudList.add(c11);
        
        insert cloudList;
        List<BWC_Data__c> cloudMonthlyList = new List<BWC_Data__c>();
        
        BWC_Data__c cm1 = new BWC_Data__c();
        cm1.Cloud_ID__c = cloudId.Id;
        cm1.Type__c = 'ZIA';
        cm1.Monthly_Usage__c = lastYearSameTime1;
        cm1.ZPA_L31d__c = 500;
        //cm1.ZPA_L31d__c = 400;
        cm1.X90_Day_Trailing_Unique_Auth_Users__c=500;
        cm1.Total_Unique_Users__c=600;
        cloudMonthlyList.add(cm1);
        
        BWC_Data__c cm2 = new BWC_Data__c();
        cm2.Cloud_ID__c = cloudId.Id;
        cm2.Type__c = 'ZIA';
        cm2.Monthly_Usage__c = lastYearSameTime2;
        cm2.ZPA_L31d__c = 500;
        //cm2.ZPA_L31d__c = 400;
        cm2.X90_Day_Trailing_Unique_Auth_Users__c=500;
        cm2.Total_Unique_Users__c=600;
        cloudMonthlyList.add(cm2);
        
        BWC_Data__c cm3 = new BWC_Data__c();
        cm3.Cloud_ID__c = cloudId.Id;
        cm3.Type__c = 'ZIA';
        cm3.Monthly_Usage__c = lastYearSameTime3; 
        cm3.ZPA_L31d__c = 500;
        //cm3.ZPA_L31d__c = 400;
        cm3.X90_Day_Trailing_Unique_Auth_Users__c=500;
        cm3.Total_Unique_Users__c=600;
        cloudMonthlyList.add(cm3);
        
        BWC_Data__c cm4 = new BWC_Data__c();
        cm4.Cloud_ID__c = cloudId.Id;
        cm4.Type__c = 'ZIA';
        cm4.Monthly_Usage__c = LastMonth; 
        cm4.ZPA_L31d__c = 500;
        //cm4.ZPA_L31d__c = 400;
        cm4.X90_Day_Trailing_Unique_Auth_Users__c=500;
        cm4.Total_Unique_Users__c=600;
        cloudMonthlyList.add(cm4);
        
        BWC_Data__c cm5 = new BWC_Data__c();
        cm5.Cloud_ID__c = cloudId.Id;
        cm5.Type__c = 'ZIA';
        cm5.Monthly_Usage__c = LastMonthPlus2Days; 
        cm5.ZPA_L31d__c = 500;
        //cm5.ZPA_L31d__c = 400;
        cm5.X90_Day_Trailing_Unique_Auth_Users__c=500;
        cm5.Total_Unique_Users__c=600;
        cloudMonthlyList.add(cm5);
        
        BWC_Data__c cm6 = new BWC_Data__c();
        cm6.Cloud_ID__c = cloudId.Id;
        cm6.Type__c = 'ZIA';
        cm6.Monthly_Usage__c = LastMonthPlus3Days; 
        cm6.ZPA_L31d__c = 500;
        //cm6.ZPA_L31d__c = 400;
        cm6.X90_Day_Trailing_Unique_Auth_Users__c=500;
        cm6.Total_Unique_Users__c=600;
        cloudMonthlyList.add(cm6);
        
        BWC_Data__c cm8 = new BWC_Data__c();
        cm8.Cloud_ID__c = cloudId.Id;
        cm8.Type__c = 'ZIA';
        cm8.Monthly_Usage__c = threeMonthsAgo; 
        cm8.ZPA_L31d__c = 500;
        //cm8.ZPA_L31d__c = 400;
        cm8.X90_Day_Trailing_Unique_Auth_Users__c=500;
        cm8.Total_Unique_Users__c=600;
        cloudMonthlyList.add(cm8);
        
        BWC_Data__c cm7 = new BWC_Data__c();
        cm7.Cloud_ID__c = cloudId.Id;
        cm7.Type__c = 'ZIA';
        cm7.Monthly_Usage__c = twoMonthsAgo; 
        cm7.ZPA_L31d__c = 500;
        //cm7.ZPA_L31d__c = 400;
        cm7.X90_Day_Trailing_Unique_Auth_Users__c=500;
        cm7.Total_Unique_Users__c=600;
        cloudMonthlyList.add(cm7);
        
        BWC_Data__c cm9 = new BWC_Data__c();
        cm9.Cloud_ID__c = cloudId.Id;
        cm9.Type__c = 'ZIA';
        cm9.Monthly_Usage__c = SixMonthsAgo; 
        cm9.ZPA_L31d__c = 500;
        //cm9.ZPA_L31d__c = 400;
        cm9.X90_Day_Trailing_Unique_Auth_Users__c=500;
        cm9.Total_Unique_Users__c=600;
        cloudMonthlyList.add(cm9);
        
        BWC_Data__c cm10 = new BWC_Data__c();
        cm10.Cloud_ID__c = cloudIdZPA.Id;
        cm10.Type__c = 'ZPA';
        cm10.Monthly_Usage__c = lastYearSameTime1;
        cm10.ZPA_L31d__c = 500;
        //cm1.ZPA_L31d__c = 400;
        cm10.X90_Day_Trailing_Unique_Auth_Users__c=500;
        cm10.Total_Unique_Users__c=600;
        cloudMonthlyList.add(cm10);
        
        BWC_Data__c cm12 = new BWC_Data__c();
        cm12.Cloud_ID__c = cloudIdZPA.Id;
        cm12.Type__c = 'ZPA';
        cm12.Monthly_Usage__c = lastYearSameTime2;
        cm12.ZPA_L31d__c = 500;
        //cm2.ZPA_L31d__c = 400;
        cm12.X90_Day_Trailing_Unique_Auth_Users__c=500;
        cm12.Total_Unique_Users__c=600;
        cloudMonthlyList.add(cm12);
        
        BWC_Data__c cm13 = new BWC_Data__c();
        cm13.Cloud_ID__c = cloudIdZPA.Id;
        cm13.Type__c = 'ZPA';
        cm13.Monthly_Usage__c = lastYearSameTime3; 
        cm13.ZPA_L31d__c = 500;
        //cm3.ZPA_L31d__c = 400;
        cm13.X90_Day_Trailing_Unique_Auth_Users__c=500;
        cm13.Total_Unique_Users__c=600;
        cloudMonthlyList.add(cm13);
        
        BWC_Data__c cm14 = new BWC_Data__c();
        cm14.Cloud_ID__c = cloudIdZPA.Id;
        cm14.Type__c = 'ZPA';
        cm14.Monthly_Usage__c = LastMonth; 
        cm14.ZPA_L31d__c = 500;
        //cm4.ZPA_L31d__c = 400;
        cm14.X90_Day_Trailing_Unique_Auth_Users__c=500;
        cm14.Total_Unique_Users__c=600;
        cloudMonthlyList.add(cm14);
        
        BWC_Data__c cm15 = new BWC_Data__c();
        cm15.Cloud_ID__c = cloudIdZPA.Id;
        cm15.Type__c = 'ZPA';
        cm15.Monthly_Usage__c = LastMonthPlus2Days; 
        cm15.ZPA_L31d__c = 500;
        //cm5.ZPA_L31d__c = 400;
        cm15.X90_Day_Trailing_Unique_Auth_Users__c=500;
        cm15.Total_Unique_Users__c=600;
        cloudMonthlyList.add(cm15);
        
        BWC_Data__c cm16 = new BWC_Data__c();
        cm16.Cloud_ID__c = cloudIdZPA.Id;
        cm16.Type__c = 'ZPA';
        cm16.Monthly_Usage__c = LastMonthPlus3Days; 
        cm16.ZPA_L31d__c = 500;
        //cm6.ZPA_L31d__c = 400;
        cm16.X90_Day_Trailing_Unique_Auth_Users__c=500;
        cm16.Total_Unique_Users__c=600;
        cloudMonthlyList.add(cm16);
        
        BWC_Data__c cm18 = new BWC_Data__c();
        cm18.Cloud_ID__c = cloudIdZPA.Id;
        cm18.Type__c = 'ZPA';
        cm18.Monthly_Usage__c = threeMonthsAgo; 
        cm18.ZPA_L31d__c = 500;
        //cm8.ZPA_L31d__c = 400;
        cm18.X90_Day_Trailing_Unique_Auth_Users__c=500;
        cm18.Total_Unique_Users__c=600;
        cloudMonthlyList.add(cm18);
        
        BWC_Data__c cm17 = new BWC_Data__c();
        cm17.Cloud_ID__c = cloudIdZPA.Id;
        cm17.Type__c = 'ZPA';
        cm17.Monthly_Usage__c = twoMonthsAgo; 
        cm17.ZPA_L31d__c = 500;
        //cm7.ZPA_L31d__c = 400;
        cm17.X90_Day_Trailing_Unique_Auth_Users__c=500;
        cm17.Total_Unique_Users__c=600;
        cloudMonthlyList.add(cm17);
        
        BWC_Data__c cm19 = new BWC_Data__c();
        cm19.Cloud_ID__c = cloudIdZPA.Id;
        cm19.Type__c = 'ZPA';
        cm19.Monthly_Usage__c = SixMonthsAgo; 
        cm19.ZPA_L31d__c = 500;
        //cm9.ZPA_L31d__c = 400;
        cm19.X90_Day_Trailing_Unique_Auth_Users__c=500;
        cm19.Total_Unique_Users__c=600;
        cloudMonthlyList.add(cm19);
        insert cloudMonthlyList;
    }
    
    @isTest 
    static void testSchduledJob()
    {
        test.startTest();
        CustomerSummarySchedule customerSummarySchedule = new CustomerSummarySchedule();
        String cronExp1 = '0 0 23 * * ?';
        System.schedule('Test Schedule customerSummary', cronExp1, customerSummarySchedule);
        
        CustomerSummaryBatchHelper.LastAndPreviousMonthRange(1, 2019);
        CustomerSummaryBatchHelper.LastAndPreviousMonthRange(2, 2019);
        CustomerSummaryBatchHelper.LastAndPreviousMonthRange(3, 2019);
        CustomerSummaryBatchHelper.LastAndPreviousMonthRange(4, 2019);
        CustomerSummaryBatchHelper.LastAndPreviousMonthRange(5, 2019);
        CustomerSummaryBatchHelper.LastAndPreviousMonthRange(6, 2019);
        CustomerSummaryBatchHelper.LastAndPreviousMonthRange(7, 2019);
        CustomerSummaryBatchHelper.LastAndPreviousMonthRange(8, 2019);
        CustomerSummaryBatchHelper.LastAndPreviousMonthRange(9, 2019);
        CustomerSummaryBatchHelper.LastAndPreviousMonthRange(10, 2019);
        CustomerSummaryBatchHelper.LastAndPreviousMonthRange(11, 2019);
        CustomerSummaryBatchHelper.LastAndPreviousMonthRange(12, 2019);
        
        CustomerSummaryBatchHelper.LastAnd6MonthRange(1, 2019);
        CustomerSummaryBatchHelper.LastAnd6MonthRange(2, 2019);
        CustomerSummaryBatchHelper.LastAnd6MonthRange(3, 2019);
        CustomerSummaryBatchHelper.LastAnd6MonthRange(4, 2019);
        CustomerSummaryBatchHelper.LastAnd6MonthRange(5, 2019);
        CustomerSummaryBatchHelper.LastAnd6MonthRange(6, 2019);
        CustomerSummaryBatchHelper.LastAnd6MonthRange(7, 2019);
        CustomerSummaryBatchHelper.LastAnd6MonthRange(8, 2019);
        CustomerSummaryBatchHelper.LastAnd6MonthRange(9, 2019);
        CustomerSummaryBatchHelper.LastAnd6MonthRange(10, 2019);
        CustomerSummaryBatchHelper.LastAnd6MonthRange(11, 2019);
        CustomerSummaryBatchHelper.LastAnd6MonthRange(12, 2019);
        
        CustomerSummaryBatchHelper.LastAnd12MonthRange(1, 2019);
        CustomerSummaryBatchHelper.LastAnd12MonthRange(2, 2019);
        CustomerSummaryBatchHelper.LastAnd12MonthRange(3, 2019);
        CustomerSummaryBatchHelper.LastAnd12MonthRange(4, 2019);
        CustomerSummaryBatchHelper.LastAnd12MonthRange(5, 2019);
        CustomerSummaryBatchHelper.LastAnd12MonthRange(6, 2019);
        CustomerSummaryBatchHelper.LastAnd12MonthRange(7, 2019);
        CustomerSummaryBatchHelper.LastAnd12MonthRange(8, 2019);
        CustomerSummaryBatchHelper.LastAnd12MonthRange(9, 2019);
        CustomerSummaryBatchHelper.LastAnd12MonthRange(10, 2019);
        CustomerSummaryBatchHelper.LastAnd12MonthRange(11, 2019);
        CustomerSummaryBatchHelper.LastAnd12MonthRange(12, 2019);
        
        CustomerSummaryBatchHelper csb= new CustomerSummaryBatchHelper();
        csb.last3Months(1);
        csb.last3Months(2);
        csb.last3Months(3);
        csb.last3Months(4);
        csb.last3Months(5);
        csb.last3Months(6);
        csb.last3Months(7);
        csb.last3Months(8);
        csb.last3Months(9);
        csb.last3Months(10);
        csb.last3Months(11);
        csb.last3Months(12);
        csb.last3Months(13);
        test.stopTest();
    }
    //Added by Anup : CR#1047- Start
    @isTest 
    static void testValueSummaryCS(){
        
        String query = 'select Id, Account__r.Name,account__r.No_of_Platform_Seats__c, Total_Transactions__c, Total_Policy_Blocks__c,'+
            'Total_Botnet_Calls__c, Total_Malware__c,Total_Bandwidth__c,Total_Transactions_Same_Time__c,'+
            'Total_Bandwidth_Same_Time__c,Total_Phishing_Attacks__c,Total_Security_Blocks__c, '+
            'Auth_ZIA_users_deployed_LM_Vs_LM_1__c,Auth_ZIA_users_deployed_LM_Vs_LM_12__c,Auth_ZIA_users_deployed_LM_Vs_LM_6__c, '+
            'Qualified_SSL_inspected_bytes_LM_1__c,Qualified_SSL_inspected_bytes_LM_12__c,Qualified_SSL_inspected_bytes_LM_6__c, '+
            'ZPA_Active_Users_LM_Vs_LM_1__c,ZPA_Active_Users_LM_Vs_LM_12__c,ZPA_Active_Users_LM_Vs_LM_6__c, '+
            'Client_connector_users_LM_Vs_LM_1__c,Client_connector_users_LM_Vs_LM_12__c,Client_connector_users_LM_Vs_LM_6__c, '+
            'Problem_ticket_per_b_trans_LM_Vs_LM_12__c,Problem_tickets_per_b_trans_LM_Vs_LM_1__c,Problem_tickets_per_b_trans_LM_Vs_LM_6__c, '+
            'Value_Summary_Months__c,Total_Bandwidth_Growth__c,Total_Transaction_Growth__c,Account__r.Id,Account__c, ZScaler_Customer_Summary__c from Customer_Score_card__c where Account__r.Type=\'Customer\' and Account__r.Skip_Value_Summary_Generation__c = false';
        CustomerSummaryScorecardBatch cus = new CustomerSummaryScorecardBatch(query);
        Test.startTest();
        Database.executeBatch(cus,1);
        Test.stopTest();
    }
    @isTest
    static void testValueSummarySchedule(){
        CustomerSummaryScorecardSchedule customerSummaryScoreSchedule = new CustomerSummaryScorecardSchedule();
        String cronExp1 = '0 0 23 * * ?';
        System.schedule('Test Schedule Scorecard customerSummary', cronExp1, customerSummaryScoreSchedule);
    }
    //Added by Anup : CR#1047- End
    
    //Added by Swathi : CR#1061 Start
    @isTest
    static void test1(){
        //Create account
        RecordType rt = [select id,Name from RecordType where SobjectType='Account' and Name='Partner' Limit 1]; 
        Account account1 = new Account(Name = 'TestAccount1234',recordTypeId=rt.id,Skip_Value_Summary_Generation__c=False,Type = 'Customer');
        Database.insert(account1);
        
        Product2 product = new Product2(ProductCode = 'ZIA-SIP', Name = 'Zscaler Internet Security Platform', Family = 'Zscaler Products',
                                        IsActive = true, Zscaler_Product_Family__c='ZIA',US_List__c=60);
        insert product;
        
        Customer_Score_Card__c csc = new Customer_Score_Card__c(No_of_Parent_location__c=2,Account__c=account1.Id);
        insert csc;
        
        Contract_Detail__c cdtl = TestDatafactory_Zscaler.insertContractDetail('test contract', account1.Id, product.Id, system.today(),system.today() + 10, 5000, 100, null, null, 100, null, false, false);       
        cdtl.Is_Bundle_SKU__c = true;
        cdtl.Zscaler_Product_Family__c = 'ZIA';
        cdtl.Contract_Detail_Status__c = 'Active';
        cdtl.Partner_Account_Name__c=account1.Id;
        update cdtl;
        
        Contract_Detail__c cdtl1 = TestDatafactory_Zscaler.insertContractDetail('test contract2', account1.Id, product.Id, system.today(),system.today() + 10, 5000, 100, null, null, 100, null, false, false);       
        cdtl1.Is_Bundle_SKU__c = true;
        cdtl1.Zscaler_Product_Family__c = 'ZIA';
        cdtl1.Contract_Detail_Status__c = 'Active';
        cdtl1.Partner_Account_Name__c=account1.Id;
        update cdtl1;
        
        Zscaler_Cloud_ID__c   cloudId1 = new Zscaler_Cloud_ID__c(Name = '1441203345204183222',Account__c = account1.Id,Status__c = 'Production',Cloud_Type__c = 'ZIA',RecordTypeId = '0120g000000YUcQAAW');
        insert cloudId1;
        Date dateToday = Date.today();
        Date thisMonth = dateToday.toStartOfMonth();
        date LastMonth = thisMonth.addMonths(-1);
        
        date LastMonthPlus2Days = thisMonth.addMonths(-1).addDays(2);
        date LastMonthPlus3Days = thisMonth.addMonths(-1).addDays(3);
        
        date twoMonthsAgo = thisMonth.addMonths(-2);
        date threeMonthsAgo = thisMonth.addMonths(-3);
        date lastYearSameTime1 = thisMonth.addMonths(-13);
        date lastYearSameTime2 = thisMonth.addMonths(-14);
        date lastYearSameTime3 = thisMonth.addMonths(-15);
        
        List<Cloud_Usage__c> cloudList = new List<Cloud_Usage__c>();    
        Cloud_Usage__c c1 = new Cloud_Usage__c(Zscaler_Cloud_ID__c = cloudId1.Id,Account__c = account1.Id,Total_Policy_Blocks__c = 200,Total_Transactions__c = 1000,Total_Transactions_Bandwidth__c = 10000,
                                               Total_Security_Blocks__c = 600,total_botnet_blocks__c = 300,total_malware_site_blocks__c   = 100,total_phishing_blocks__c = 200,total_ssl_bytes__c=50,
                                               Usage_Pull_Date__c = lastYearSameTime1,total_ssl_transactions__c = 300,total_ssl_inspected_transactions__c = 150,Cloud_Usage_Type__c = 'ZIA');
        cloudList.add(c1);
        
        Cloud_Usage__c c2 = new Cloud_Usage__c(Zscaler_Cloud_ID__c = cloudId1.Id,Account__c = account1.Id,Total_Policy_Blocks__c = 200,Total_Transactions__c = 1000,Total_Transactions_Bandwidth__c = 200000,
                                               Total_Security_Blocks__c = 600,total_botnet_blocks__c = 300,total_malware_site_blocks__c = 100,total_phishing_blocks__c = 200,Cloud_Usage_Type__c = 'ZIA',
                                               Usage_Pull_Date__c = lastYearSameTime2,total_ssl_transactions__c = 300,total_ssl_inspected_transactions__c = 150,total_ssl_bytes__c=50);
        cloudList.add(c2);
        
        Cloud_Usage__c c3 = new Cloud_Usage__c(Zscaler_Cloud_ID__c = cloudId1.Id,Account__c = account1.Id,Total_Policy_Blocks__c = 200,Total_Transactions__c = 1000,Total_Transactions_Bandwidth__c = 30000,
                                               Total_Security_Blocks__c = 600,total_botnet_blocks__c = 300,total_malware_site_blocks__c = 100,total_phishing_blocks__c = 200,Cloud_Usage_Type__c = 'ZIA',
                                               Usage_Pull_Date__c = lastYearSameTime3,total_ssl_transactions__c = 300,total_ssl_inspected_transactions__c = 250,total_ssl_bytes__c=50);
        cloudList.add(c3);
        
        Cloud_Usage__c c4 = new Cloud_Usage__c(Zscaler_Cloud_ID__c = cloudId1.Id,Account__c = account1.Id,Total_Policy_Blocks__c = 300,Total_Transactions__c = 1300,Total_Transactions_Bandwidth__c = 240000,total_botnet_blocks__c = 310,
                                               Total_Security_Blocks__c = 630,total_malware_site_blocks__c = 110,total_phishing_blocks__c = 210,Usage_Pull_Date__c = LastMonth,total_ssl_inspected_transactions__c = 300,
                                               total_ssl_transactions__c = 300,Cloud_Usage_Type__c = 'ZIA',total_ssl_bytes__c=50,total_ssl_inspected_bytes__c=50,Total_Office_365_Kb__c=60);
        cloudList.add(c4);
        
        Cloud_Usage__c c41 = new Cloud_Usage__c(Zscaler_Cloud_ID__c = cloudId1.Id,Account__c = account1.Id,Total_Policy_Blocks__c = 200,Total_Transactions__c = 1000,Total_Transactions_Bandwidth__c = 10000,
                                                Total_Security_Blocks__c = 600,total_botnet_blocks__c = 300,total_malware_site_blocks__c = 100,total_phishing_blocks__c = 200,total_ssl_inspected_transactions__c = 150,
                                                Usage_Pull_Date__c = LastMonthPlus2Days,total_ssl_transactions__c = 300,Cloud_Usage_Type__c = 'ZIA',total_ssl_bytes__c=50,total_ssl_inspected_bytes__c=50,Total_Office_365_Kb__c=60);
        cloudList.add(c41);
        
        Cloud_Usage__c c42 = new Cloud_Usage__c(Zscaler_Cloud_ID__c = cloudId1.Id,Account__c = account1.Id,Total_Policy_Blocks__c = 200,Total_Transactions__c = 1000,Total_Transactions_Bandwidth__c = 10000,
                                                Total_Security_Blocks__c = 600,total_botnet_blocks__c = 300,total_malware_site_blocks__c = 100,total_phishing_blocks__c = 200,total_ssl_inspected_transactions__c = 150,
                                                Usage_Pull_Date__c = LastMonthPlus3Days,total_ssl_transactions__c = 300,Cloud_Usage_Type__c = 'ZIA',total_ssl_bytes__c=50,total_ssl_inspected_bytes__c=50,Total_Office_365_Kb__c=60);
        cloudList.add(c42);
        
        Cloud_Usage__c c5 = new Cloud_Usage__c(Zscaler_Cloud_ID__c = cloudId1.Id,Account__c = account1.Id,Total_Policy_Blocks__c = 300,Total_Transactions__c = 1300,Total_Transactions_Bandwidth__c = 10000,Cloud_Usage_Type__c = 'ZIA',
                                               Total_Security_Blocks__c = 630,total_botnet_blocks__c = 310,total_malware_site_blocks__c = 110,total_phishing_blocks__c = 210,total_ssl_inspected_transactions__c = 200,
                                               Usage_Pull_Date__c = twoMonthsAgo,total_ssl_transactions__c = 300,total_ssl_bytes__c=50,total_ssl_inspected_bytes__c=50,Total_Office_365_Kb__c=60);
        cloudList.add(c5);
        
        Cloud_Usage__c c6 = new Cloud_Usage__c(Zscaler_Cloud_ID__c = cloudId1.Id,Account__c = account1.Id,Total_Policy_Blocks__c = 300,Total_Transactions__c = 1300,Total_Transactions_Bandwidth__c = 350000,
                                               Total_Security_Blocks__c = 630,total_botnet_blocks__c = 310,total_malware_site_blocks__c = 110,total_phishing_blocks__c = 210,total_ssl_inspected_transactions__c = 300,
                                               Usage_Pull_Date__c = threeMonthsAgo,total_ssl_transactions__c = 300,Cloud_Usage_Type__c = 'ZIA',total_ssl_bytes__c=50,total_ssl_inspected_bytes__c=50,Total_Office_365_Kb__c=60);
        cloudList.add(c6);
        insert cloudList;
        
        Test.startTest();
        //system.schedule('Contract Detail Status Job', '0 0 0 * * ?', new CustomerSummarySchedule());        
        CustomerSummaryBatch batch;
        batch = new CustomerSummaryBatch('select Id, Name,No_of_Platform_Seats__c, Total_Transactions__c, Total_Policy_Blocks__c,'+
                                         'Total_Botnet_Calls__c, Total_Malware__c,Total_Bandwidth__c,Total_Transactions_Same_Time__c,'+
                                         'Total_Bandwidth_Same_Time__c,Total_Phishing_Attacks__c,First_Contract_Date__c,Total_Security_Blocks__c, '+
                                         'Value_Summary_Months__c,Total_Bandwidth_Growth__c,Total_Transaction_Growth__c from Account where Name = \'TestAccount1234\' '+
                                         'and No_of_Platform_Seats__c > 0 and Type=\'Customer\' and Skip_Value_Summary_Generation__c = false limit 1');
       Database.executeBatch(batch,1);
        Test.stopTest();
    }
    //Added by Swathi : CR#1061 End

    // IBA-3197 START
    @isTest
    static void testPopulateOldUsage() {
        Date time13MonthsAgo = Date.today().toStartOfMonth().addMonths(-13);

        Account testAccountRecord = new Account();
        testAccountRecord.name = 'Test Account';
        testAccountRecord.Type = 'Customer';
        testAccountRecord.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Partner').getRecordTypeId();
        testAccountRecord.DS_Review_Status__c = 'Complete';
        insert testAccountRecord;

        Zscaler_Cloud_ID__c  testCloudIdRecord = new Zscaler_Cloud_ID__c();
        testCloudIdRecord.Name = '1441203345204191';
        testCloudIdRecord.Account__c = testAccountRecord.Id;
        testCloudIdRecord.Status__c = 'Production';
        testCloudIdRecord.Cloud_Type__c = 'ZIA';
        testCloudIdRecord.RecordTypeId = Schema.SObjectType.Zscaler_Cloud_ID__c.getRecordTypeInfosByDeveloperName().get('ZIA_Cloud_ID').getRecordTypeId();
        insert testCloudIdRecord;

        Cloud_Usage__c testCloudUsageRecord = new Cloud_Usage__c();
        testCloudUsageRecord.Zscaler_Cloud_ID__c = testCloudIdRecord.Id;
        testCloudUsageRecord.Account__c = testAccountRecord.Id;
        testCloudUsageRecord.Total_Policy_Blocks__c = 200;
        testCloudUsageRecord.Total_Transactions__c = 1000;
        testCloudUsageRecord.Total_Transactions_Bandwidth__c = 10000;
        testCloudUsageRecord.Total_Security_Blocks__c = 600;
        testCloudUsageRecord.total_botnet_blocks__c = 300;
        testCloudUsageRecord.total_malware_site_blocks__c   = 100; 
        testCloudUsageRecord.total_phishing_blocks__c = 200;
        testCloudUsageRecord.Usage_Pull_Date__c = time13MonthsAgo;
        testCloudUsageRecord.total_ssl_transactions__c = 300;
        testCloudUsageRecord.total_ssl_inspected_transactions__c = 150;
        testCloudUsageRecord.Cloud_Usage_Type__c = 'ZIA';
        testCloudUsageRecord.total_ssl_inspected_bytes__c = 100;
        testCloudUsageRecord.total_ssl_bytes__c = 100;
        testCloudUsageRecord.Total_Office_365_Kb__c = 200;
        testCloudUsageRecord.ZPA_Active_Users__c = 300;
        insert testCloudUsageRecord;

        Test.startTest();
            Map<String, Decimal> variableNameToValueMap = new Map<String, Decimal>();
            CustomerSummaryBatchHelper helperInstance = new CustomerSummaryBatchHelper();
            variableNameToValueMap = helperInstance.populateOldUsage(testAccountRecord);
        Test.stopTest();

        System.assertNotEquals(0, variableNameToValueMap.get('totalOldTransactions'), 'totalOldTransactions should not be zero.');
    }

    @isTest
    static void testPopulateLastAndPreviousMonthUsage() {
        Date todaysDate = Date.today();
        Map<String, List<Datetime>> monthAndYear = CustomerSummaryBatchHelper.LastAndPreviousMonthRange(todaysDate.month(), todaysDate.year());
        Date time1MonthAgo = Date.valueOf(monthAndYear.get('last')[0]);
        Date time2MonthsAgo = Date.valueOf(monthAndYear.get('previous')[0]);

        Account testAccountRecord = new Account();
        testAccountRecord.name = 'Test Account';
        testAccountRecord.Type = 'Customer';
        testAccountRecord.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Partner').getRecordTypeId();
        testAccountRecord.DS_Review_Status__c = 'Complete';
        insert testAccountRecord;

        Zscaler_Cloud_ID__c  testCloudIdRecord = new Zscaler_Cloud_ID__c();
        testCloudIdRecord.Name = '1441203345204192';
        testCloudIdRecord.Account__c = testAccountRecord.Id;
        testCloudIdRecord.Status__c = 'Production';
        testCloudIdRecord.Cloud_Type__c = 'ZIA';
        testCloudIdRecord.RecordTypeId = Schema.SObjectType.Zscaler_Cloud_ID__c.getRecordTypeInfosByDeveloperName().get('ZIA_Cloud_ID').getRecordTypeId();
        insert testCloudIdRecord;

        List<Cloud_Usage__c> testCloudUsageRecordsList = new List<Cloud_Usage__c>();

        Cloud_Usage__c testCloudUsageRecord1 = new Cloud_Usage__c();
        testCloudUsageRecord1.Zscaler_Cloud_ID__c = testCloudIdRecord.Id;
        testCloudUsageRecord1.Account__c = testAccountRecord.Id;
        testCloudUsageRecord1.Total_Policy_Blocks__c = 200;
        testCloudUsageRecord1.Total_Transactions__c = 1000;
        testCloudUsageRecord1.Total_Transactions_Bandwidth__c = 10000;
        testCloudUsageRecord1.Total_Security_Blocks__c = 600;
        testCloudUsageRecord1.total_botnet_blocks__c = 300;
        testCloudUsageRecord1.total_malware_site_blocks__c   = 100; 
        testCloudUsageRecord1.total_phishing_blocks__c = 200;
        testCloudUsageRecord1.Usage_Pull_Date__c = time1MonthAgo;
        testCloudUsageRecord1.total_ssl_transactions__c = 300;
        testCloudUsageRecord1.total_ssl_inspected_transactions__c = 150;
        testCloudUsageRecord1.Cloud_Usage_Type__c = 'ZIA';
        testCloudUsageRecord1.total_ssl_inspected_bytes__c = 100;
        testCloudUsageRecord1.total_ssl_bytes__c = 100;
        testCloudUsageRecord1.Total_Office_365_Kb__c = 200;
        testCloudUsageRecord1.ZPA_Active_Users__c = 300;
        testCloudUsageRecordsList.add(testCloudUsageRecord1);

        Cloud_Usage__c testCloudUsageRecord2 = new Cloud_Usage__c();
        testCloudUsageRecord2.Zscaler_Cloud_ID__c = testCloudIdRecord.Id;
        testCloudUsageRecord2.Account__c = testAccountRecord.Id;
        testCloudUsageRecord2.Total_Policy_Blocks__c = 200;
        testCloudUsageRecord2.Total_Transactions__c = 100;
        testCloudUsageRecord2.Total_Transactions_Bandwidth__c = 10000;
        testCloudUsageRecord2.Total_Security_Blocks__c = 600;
        testCloudUsageRecord2.total_botnet_blocks__c = 300;
        testCloudUsageRecord2.total_malware_site_blocks__c   = 100; 
        testCloudUsageRecord2.total_phishing_blocks__c = 200;
        testCloudUsageRecord2.Usage_Pull_Date__c = time2MonthsAgo;
        testCloudUsageRecord2.total_ssl_transactions__c = 300;
        testCloudUsageRecord2.total_ssl_inspected_transactions__c = 150;
        testCloudUsageRecord2.Cloud_Usage_Type__c = 'ZIA';
        testCloudUsageRecord2.total_ssl_inspected_bytes__c = 100;
        testCloudUsageRecord2.total_ssl_bytes__c = 100;
        testCloudUsageRecord2.Total_Office_365_Kb__c = 200;
        testCloudUsageRecord2.ZPA_Active_Users__c = 300;
        testCloudUsageRecordsList.add(testCloudUsageRecord2);

        insert testCloudUsageRecordsList;

        Test.startTest();
            CustomerSummaryBatchHelper helperInstance = new CustomerSummaryBatchHelper();
            helperInstance.populateLastAndPreviousMonthUsage(testAccountRecord);
        Test.stopTest();

        System.assertNotEquals(0, testAccountRecord.Transactions_LM_vs_PM__c, 'Transactions LM vs PM should not be zero.');
    }

    @isTest
    static void testPopulateLastAnd6MonthUsage() {
        Date todaysDate = Date.today();
        Map<String, List<Datetime>> monthAndYear = CustomerSummaryBatchHelper.LastAnd6MonthRange(todaysDate.month(), todaysDate.year());
        Date time1MonthAgo = Date.valueOf(monthAndYear.get('last')[0]);
        Date time6MonthsAgo = Date.valueOf(monthAndYear.get('previous')[0]);

        Account testAccountRecord = new Account();
        testAccountRecord.name = 'Test Account';
        testAccountRecord.Type = 'Customer';
        testAccountRecord.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Partner').getRecordTypeId();
        testAccountRecord.DS_Review_Status__c = 'Complete';
        insert testAccountRecord;

        Zscaler_Cloud_ID__c  testCloudIdRecord = new Zscaler_Cloud_ID__c();
        testCloudIdRecord.Name = '1441203345204193';
        testCloudIdRecord.Account__c = testAccountRecord.Id;
        testCloudIdRecord.Status__c = 'Production';
        testCloudIdRecord.Cloud_Type__c = 'ZIA';
        testCloudIdRecord.RecordTypeId = Schema.SObjectType.Zscaler_Cloud_ID__c.getRecordTypeInfosByDeveloperName().get('ZIA_Cloud_ID').getRecordTypeId();
        insert testCloudIdRecord;

        List<Cloud_Usage__c> testCloudUsageRecordsList = new List<Cloud_Usage__c>();

        Cloud_Usage__c testCloudUsageRecord1 = new Cloud_Usage__c();
        testCloudUsageRecord1.Zscaler_Cloud_ID__c = testCloudIdRecord.Id;
        testCloudUsageRecord1.Account__c = testAccountRecord.Id;
        testCloudUsageRecord1.Total_Policy_Blocks__c = 200;
        testCloudUsageRecord1.Total_Transactions__c = 1000;
        testCloudUsageRecord1.Total_Transactions_Bandwidth__c = 10000;
        testCloudUsageRecord1.Total_Security_Blocks__c = 600;
        testCloudUsageRecord1.total_botnet_blocks__c = 300;
        testCloudUsageRecord1.total_malware_site_blocks__c   = 100; 
        testCloudUsageRecord1.total_phishing_blocks__c = 200;
        testCloudUsageRecord1.Usage_Pull_Date__c = time1MonthAgo;
        testCloudUsageRecord1.total_ssl_transactions__c = 300;
        testCloudUsageRecord1.total_ssl_inspected_transactions__c = 150;
        testCloudUsageRecord1.Cloud_Usage_Type__c = 'ZIA';
        testCloudUsageRecord1.total_ssl_inspected_bytes__c = 100;
        testCloudUsageRecord1.total_ssl_bytes__c = 100;
        testCloudUsageRecord1.Total_Office_365_Kb__c = 200;
        testCloudUsageRecord1.ZPA_Active_Users__c = 300;
        testCloudUsageRecordsList.add(testCloudUsageRecord1);

        Cloud_Usage__c testCloudUsageRecord2 = new Cloud_Usage__c();
        testCloudUsageRecord2.Zscaler_Cloud_ID__c = testCloudIdRecord.Id;
        testCloudUsageRecord2.Account__c = testAccountRecord.Id;
        testCloudUsageRecord2.Total_Policy_Blocks__c = 200;
        testCloudUsageRecord2.Total_Transactions__c = 100;
        testCloudUsageRecord2.Total_Transactions_Bandwidth__c = 10000;
        testCloudUsageRecord2.Total_Security_Blocks__c = 600;
        testCloudUsageRecord2.total_botnet_blocks__c = 300;
        testCloudUsageRecord2.total_malware_site_blocks__c   = 100; 
        testCloudUsageRecord2.total_phishing_blocks__c = 200;
        testCloudUsageRecord2.Usage_Pull_Date__c = time6MonthsAgo;
        testCloudUsageRecord2.total_ssl_transactions__c = 300;
        testCloudUsageRecord2.total_ssl_inspected_transactions__c = 150;
        testCloudUsageRecord2.Cloud_Usage_Type__c = 'ZIA';
        testCloudUsageRecord2.total_ssl_inspected_bytes__c = 100;
        testCloudUsageRecord2.total_ssl_bytes__c = 100;
        testCloudUsageRecord2.Total_Office_365_Kb__c = 200;
        testCloudUsageRecord2.ZPA_Active_Users__c = 300;
        testCloudUsageRecordsList.add(testCloudUsageRecord2);

        insert testCloudUsageRecordsList;

        Test.startTest();
            CustomerSummaryBatchHelper helperInstance = new CustomerSummaryBatchHelper();
            helperInstance.populateLastAnd6MonthUsage(testAccountRecord);
        Test.stopTest();

        System.assertNotEquals(0, testAccountRecord.Transactions_LM_vs_6M_Ago__c, 'Transactions LM vs 6M Age should not be zero.');
    }

    @isTest
    static void testPopulateLastAnd12MonthUsage() {
        Date todaysDate = Date.today();
        Map<String, List<Datetime>> monthAndYear = CustomerSummaryBatchHelper.LastAnd12MonthRange(todaysDate.month(), todaysDate.year());
        Date time1MonthAgo = Date.valueOf(monthAndYear.get('last')[0]);
        Date time12MonthsAgo = Date.valueOf(monthAndYear.get('previous')[0]);

        Account testAccountRecord = new Account();
        testAccountRecord.name = 'Test Account';
        testAccountRecord.Type = 'Customer';
        testAccountRecord.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Partner').getRecordTypeId();
        testAccountRecord.DS_Review_Status__c = 'Complete';
        insert testAccountRecord;

        Zscaler_Cloud_ID__c  testCloudIdRecord = new Zscaler_Cloud_ID__c();
        testCloudIdRecord.Name = '1441203345204194';
        testCloudIdRecord.Account__c = testAccountRecord.Id;
        testCloudIdRecord.Status__c = 'Production';
        testCloudIdRecord.Cloud_Type__c = 'ZIA';
        testCloudIdRecord.RecordTypeId = Schema.SObjectType.Zscaler_Cloud_ID__c.getRecordTypeInfosByDeveloperName().get('ZIA_Cloud_ID').getRecordTypeId();
        insert testCloudIdRecord;

        List<Cloud_Usage__c> testCloudUsageRecordsList = new List<Cloud_Usage__c>();

        Cloud_Usage__c testCloudUsageRecord1 = new Cloud_Usage__c();
        testCloudUsageRecord1.Zscaler_Cloud_ID__c = testCloudIdRecord.Id;
        testCloudUsageRecord1.Account__c = testAccountRecord.Id;
        testCloudUsageRecord1.Total_Policy_Blocks__c = 200;
        testCloudUsageRecord1.Total_Transactions__c = 1000;
        testCloudUsageRecord1.Total_Transactions_Bandwidth__c = 10000;
        testCloudUsageRecord1.Total_Security_Blocks__c = 600;
        testCloudUsageRecord1.total_botnet_blocks__c = 300;
        testCloudUsageRecord1.total_malware_site_blocks__c   = 100; 
        testCloudUsageRecord1.total_phishing_blocks__c = 200;
        testCloudUsageRecord1.Usage_Pull_Date__c = time1MonthAgo;
        testCloudUsageRecord1.total_ssl_transactions__c = 300;
        testCloudUsageRecord1.total_ssl_inspected_transactions__c = 150;
        testCloudUsageRecord1.Cloud_Usage_Type__c = 'ZIA';
        testCloudUsageRecord1.total_ssl_inspected_bytes__c = 100;
        testCloudUsageRecord1.total_ssl_bytes__c = 100;
        testCloudUsageRecord1.Total_Office_365_Kb__c = 200;
        testCloudUsageRecord1.ZPA_Active_Users__c = 300;
        testCloudUsageRecordsList.add(testCloudUsageRecord1);

        Cloud_Usage__c testCloudUsageRecord2 = new Cloud_Usage__c();
        testCloudUsageRecord2.Zscaler_Cloud_ID__c = testCloudIdRecord.Id;
        testCloudUsageRecord2.Account__c = testAccountRecord.Id;
        testCloudUsageRecord2.Total_Policy_Blocks__c = 200;
        testCloudUsageRecord2.Total_Transactions__c = 100;
        testCloudUsageRecord2.Total_Transactions_Bandwidth__c = 10000;
        testCloudUsageRecord2.Total_Security_Blocks__c = 600;
        testCloudUsageRecord2.total_botnet_blocks__c = 300;
        testCloudUsageRecord2.total_malware_site_blocks__c   = 100; 
        testCloudUsageRecord2.total_phishing_blocks__c = 200;
        testCloudUsageRecord2.Usage_Pull_Date__c = time12MonthsAgo;
        testCloudUsageRecord2.total_ssl_transactions__c = 300;
        testCloudUsageRecord2.total_ssl_inspected_transactions__c = 150;
        testCloudUsageRecord2.Cloud_Usage_Type__c = 'ZIA';
        testCloudUsageRecord2.total_ssl_inspected_bytes__c = 100;
        testCloudUsageRecord2.total_ssl_bytes__c = 100;
        testCloudUsageRecord2.Total_Office_365_Kb__c = 200;
        testCloudUsageRecord2.ZPA_Active_Users__c = 300;
        testCloudUsageRecordsList.add(testCloudUsageRecord2);

        insert testCloudUsageRecordsList;

        Test.startTest();
            CustomerSummaryBatchHelper helperInstance = new CustomerSummaryBatchHelper();
            helperInstance.populateLastAnd12MonthUsage(testAccountRecord);
        Test.stopTest();

        System.assertNotEquals(0, testAccountRecord.Transactions_LM_vs_12M_Ago__c, 'Transactions LM vs 12M Age should not be zero.');
    }

    @isTest 
    static void testPopulateTotalUsage() {
        Date time2MonthsAgo = Date.today().toStartOfMonth().addMonths(-2);

        Account testAccountRecord = new Account();
        testAccountRecord.name = 'Test Account';
        testAccountRecord.Type = 'Customer';
        testAccountRecord.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Partner').getRecordTypeId();
        testAccountRecord.DS_Review_Status__c = 'Complete';
        testAccountRecord.Total_Transactions__c = 0;
        testAccountRecord.Total_Bandwidth__c = 0;
        testAccountRecord.Total_Policy_Blocks__c = 0;
        testAccountRecord.Total_Botnet_Calls__c = 0;
        testAccountRecord.Total_Malware__c = 0;
        testAccountRecord.Total_Phishing_Attacks__c = 0;
        testAccountRecord.Total_Security_Blocks__c = 0;
        insert testAccountRecord;

        Zscaler_Cloud_ID__c  testCloudIdRecord = new Zscaler_Cloud_ID__c();
        testCloudIdRecord.Name = '1441203345204195';
        testCloudIdRecord.Account__c = testAccountRecord.Id;
        testCloudIdRecord.Status__c = 'Production';
        testCloudIdRecord.Cloud_Type__c = 'ZIA';
        testCloudIdRecord.RecordTypeId = Schema.SObjectType.Zscaler_Cloud_ID__c.getRecordTypeInfosByDeveloperName().get('ZIA_Cloud_ID').getRecordTypeId();
        insert testCloudIdRecord;

        Cloud_Usage__c testCloudUsageRecord = new Cloud_Usage__c();
        testCloudUsageRecord.Zscaler_Cloud_ID__c = testCloudIdRecord.Id;
        testCloudUsageRecord.Account__c = testAccountRecord.Id;
        testCloudUsageRecord.Total_Policy_Blocks__c = 200;
        testCloudUsageRecord.Total_Transactions__c = 1000;
        testCloudUsageRecord.total_ssl_inspected_bytes__c = 1000;
        testCloudUsageRecord.Total_Transactions_Bandwidth__c = 10000;
        testCloudUsageRecord.Total_Security_Blocks__c = 600;
        testCloudUsageRecord.total_botnet_blocks__c = 300;
        testCloudUsageRecord.total_malware_site_blocks__c   = 100; 
        testCloudUsageRecord.total_phishing_blocks__c = 200;
        testCloudUsageRecord.Usage_Pull_Date__c = time2MonthsAgo;
        testCloudUsageRecord.total_ssl_transactions__c = 300;
        testCloudUsageRecord.total_ssl_inspected_transactions__c = 150;
        testCloudUsageRecord.Cloud_Usage_Type__c = 'ZIA';
        testCloudUsageRecord.total_ssl_inspected_bytes__c = 100;
        testCloudUsageRecord.total_ssl_bytes__c = 100;
        testCloudUsageRecord.Total_Office_365_Kb__c = 200;
        testCloudUsageRecord.ZPA_Active_Users__c = 300;
        insert testCloudUsageRecord;

        Test.startTest();
            Map<String, Decimal> variableNameToValueMap = new Map<String, Decimal>();
            CustomerSummaryBatchHelper helperInstance = new CustomerSummaryBatchHelper();
            variableNameToValueMap = helperInstance.populateTotalUsage(testAccountRecord);
        Test.stopTest();

        System.assertNotEquals(0, variableNameToValueMap.get('SSLinspectedBytes'), 'SSL Inspected Bytes should not be zero.');
    }
    // IBA-3197 END
}