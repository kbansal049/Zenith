@istest
public with sharing class RollupEnrolledUsersBatchTest {

    @testSetup static void setupdata(){
        Skip_Triggers__c skipTriggers = new Skip_Triggers__c();
        skipTriggers.Skip_Account_Triggers__c = true;
        skipTriggers.Skip_Opportunity_Triggers__c = true;
        skipTriggers.Name = 'SkipTriggers';
        insert skipTriggers;
        
        List<Triggers_Switch__c> tslist= new List<Triggers_Switch__c>();
        Triggers_Switch__c ts1= new Triggers_Switch__c(Name='Execute_Monthly_Cloud_Usage_Roll_UP',Execute__c=true,Object_Name__c='BWC_Data__c');
        tslist.add(ts1);
        insert tslist;
    }
    
    static testmethod void test1(){
        
        
        Account acctTest = new Account(Name = 'Test Account', TAM_Email__c = 'abc@abc.com', ZPA_Use_Cases__c = 'Accelerated Merger and Acquisition');
        insert acctTest;
        
        Contact con = new Contact(AccountId = acctTest.Id, LeadSource = 'Marketing Campaign', LastName = 'test con', First_Lead_Date__c = date.today(), Lead_Stage__c = 'Lead', MKTO71_Lead_Score__c = 0, Contacts_That_Matter__c  = true,Send_CIO_Report__c='Send');
        insert con; 
        test.starttest();
        
        List<Zscaler_Cloud_ID__c> ZSClIDlist = new List<Zscaler_Cloud_ID__c>();
        String rid = Schema.getGlobalDescribe().get('Zscaler_Cloud_ID__c').getDescribe().getRecordTypeInfosByName().get('ZPA Cloud ID').getRecordTypeId();
        Zscaler_Cloud_ID__c ZSc1= new Zscaler_Cloud_ID__c(Name='Zscloud.net-3926test1',Account__c=acctTest.Id,NS_Org_ID__c='Zscloud.net-3926test1.beta',Zscaler_Cloud_Domain__c='testacc.com.au.test1',Org_Name__c='Test Account Org',Cloud_Type__c='ZPA', recordTypeId = rid, ZPA_Enrolled_Users_L31D_Rollup__c = 1, ZPA_Enrolled_Users_L6M_Rollup__c= 1, ZPA_Enrolled_Users_L90D_Rollup__c= 1);
        ZSClIDlist.add(ZSc1);
        Zscaler_Cloud_ID__c ZSc2= new Zscaler_Cloud_ID__c(Name='Zscloud.net-3926test2',Account__c=acctTest.Id,NS_Org_ID__c='Zscloud.net-3926test2.beta',Zscaler_Cloud_Domain__c='testacc.com.au.test2',Org_Name__c='Test Account Org',Cloud_Type__c='ZPA', recordTypeId = rid, ZPA_Enrolled_Users_L31D_Rollup__c = 1, ZPA_Enrolled_Users_L6M_Rollup__c= 1, ZPA_Enrolled_Users_L90D_Rollup__c= 1);
        ZSClIDlist.add(ZSc2);
        insert ZSClIDlist;


        List<Cloud_Usage__c> cloudList = new List<Cloud_Usage__c>();
        Date dateToday = Date.today();
        Date thisMonth = dateToday.toStartOfMonth();
        date lastYearSameTime1 = thisMonth.addMonths(-13);
        date lastYearSameTime2 = thisMonth.addMonths(-14);
        date lastYearSameTime3 = thisMonth.addMonths(-15);
            
        Cloud_Usage__c c1 = new Cloud_Usage__c();
        c1.Zscaler_Cloud_ID__c = ZSClIDlist.get(0).Id;
        c1.Account__c = acctTest.Id;
        c1.Total_Policy_Blocks__c = 200;
        c1.Total_Transactions__c = 1000;
        c1.Total_Transactions_Bandwidth__c = 10000;
        c1.Total_Security_Blocks__c = 600;
        c1.total_botnet_blocks__c = 300;
        c1.total_malware_site_blocks__c   = 100; 
        c1.total_phishing_blocks__c = 200;
        c1.Usage_Pull_Date__c = lastYearSameTime1;
        c1.total_ssl_transactions__c = 300;
        c1.Cloud_Usage_Type__c = 'ZPA';
        c1.total_ssl_inspected_transactions__c = 150;
        c1.Last_31_Days__c = true;
        c1.Last_6_Months__c = true;
        c1.Enrolled_Users__c = 13;
        c1.Last_90_Days__c = true;
        cloudList.add(c1);
        
        Cloud_Usage__c c2 = new Cloud_Usage__c();
        c2.Zscaler_Cloud_ID__c = ZSClIDlist.get(1).Id;
        c2.Account__c = acctTest.Id;
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
        c2.Cloud_Usage_Type__c = 'ZPA';
        c2.Last_31_Days__c = true;
        c2.Last_6_Months__c = true;
        c2.Last_90_Days__c = true;
        c2.Enrolled_Users__c = 13;
        cloudList.add(c2);
        
        Cloud_Usage__c c3 = new Cloud_Usage__c();
        c3.Zscaler_Cloud_ID__c = ZSClIDlist.get(1).Id;
        c3.Account__c = acctTest.Id;
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
        c3.Cloud_Usage_Type__c = 'ZPA';
        c3.Last_31_Days__c = true;
        c3.Last_6_Months__c = true;
        c3.Last_90_Days__c = true;
        c3.Enrolled_Users__c = 13;
        cloudList.add(c3);

        insert cloudList;

        
        List<BWC_Data__c> cloudMonthlyList = new List<BWC_Data__c>();
        
        BWC_Data__c cm1 = new BWC_Data__c();
        cm1.Cloud_ID__c = ZSClIDlist.get(0).Id;
        cm1.Type__c = 'ZPA';
        cm1.Monthly_Usage__c = System.today().toStartOfMonth();
        cm1.ZPA_L31d__c = 500;
        cm1.ZPA_L31d__c = 400;
        cloudMonthlyList.add(cm1);
        
        BWC_Data__c cm2 = new BWC_Data__c();
        cm2.Cloud_ID__c = ZSClIDlist.get(1).Id;
        cm2.Type__c = 'ZPA';
        cm2.Monthly_Usage__c = System.today().toStartOfMonth();
        cm2.ZPA_L31d__c = 500;
        cm2.ZPA_L31d__c = 400;
        cloudMonthlyList.add(cm2);
        
        BWC_Data__c cm3 = new BWC_Data__c();
        cm3.Cloud_ID__c = ZSClIDlist.get(1).Id;
        cm3.Type__c = 'ZPA';
        cm3.Monthly_Usage__c = System.today().toStartOfMonth().addMonths(-1); 
        cm3.ZPA_L31d__c = 500;
        cm3.ZPA_L31d__c = 400;
        cloudMonthlyList.add(cm3);
        insert cloudMonthlyList;
        
        
        
        RollupEnrolledUsersBatchScheduler m = new RollupEnrolledUsersBatchScheduler();
        String sch = '0 36 1 * * ?';
        String jobID = system.schedule('test rollup up opp fields', sch, m);
        RollupEnrolledUsersBatchScheduler m2 = new RollupEnrolledUsersBatchScheduler();
        RollupCloudIdUpdateBatch.testClassVerify = true;
        String jobID2 = system.schedule('test rollup up opp fields 2', sch, m2);

        test.stoptest();
    }

    static testmethod void test2(){

            
        Account acctTest = new Account(Name = 'Test Account', TAM_Email__c = 'abc@abc.com', ZPA_Use_Cases__c = 'Accelerated Merger and Acquisition');
        insert acctTest;
        
        Contact con = new Contact(AccountId = acctTest.Id, LeadSource = 'Marketing Campaign', LastName = 'test con', First_Lead_Date__c = date.today(), Lead_Stage__c = 'Lead', MKTO71_Lead_Score__c = 0, Contacts_That_Matter__c  = true,Send_CIO_Report__c='Send');
        insert con; 
        test.starttest();
        
        List<Zscaler_Cloud_ID__c> ZSClIDlist = new List<Zscaler_Cloud_ID__c>();
        String rid = Schema.getGlobalDescribe().get('Zscaler_Cloud_ID__c').getDescribe().getRecordTypeInfosByName().get('ZPA Cloud ID').getRecordTypeId();
        Zscaler_Cloud_ID__c ZSc1= new Zscaler_Cloud_ID__c(Name='Zscloud.net-3926test1',Account__c=acctTest.Id,NS_Org_ID__c='Zscloud.net-3926test1.beta',Zscaler_Cloud_Domain__c='testacc.com.au.test1',Org_Name__c='Test Account Org',Cloud_Type__c='ZPA', recordTypeId = rid, ZPA_Enrolled_Users_L31D_Rollup__c = 1, ZPA_Enrolled_Users_L6M_Rollup__c= 1, ZPA_Enrolled_Users_L90D_Rollup__c= 1);
        ZSClIDlist.add(ZSc1);
        Zscaler_Cloud_ID__c ZSc2= new Zscaler_Cloud_ID__c(Name='Zscloud.net-3926test2',Account__c=acctTest.Id,NS_Org_ID__c='Zscloud.net-3926test2.beta',Zscaler_Cloud_Domain__c='testacc.com.au.test2',Org_Name__c='Test Account Org',Cloud_Type__c='ZPA', recordTypeId = rid, ZPA_Enrolled_Users_L31D_Rollup__c = 1, ZPA_Enrolled_Users_L6M_Rollup__c= 1, ZPA_Enrolled_Users_L90D_Rollup__c= 1);
        ZSClIDlist.add(ZSc2);
        insert ZSClIDlist;


        List<Cloud_Usage__c> cloudList = new List<Cloud_Usage__c>();
        Date dateToday = Date.today();
        Date thisMonth = dateToday.toStartOfMonth();
        date lastYearSameTime1 = thisMonth.addMonths(-13);
        date lastYearSameTime2 = thisMonth.addMonths(-14);
        date lastYearSameTime3 = thisMonth.addMonths(-15);
            
        Cloud_Usage__c c1 = new Cloud_Usage__c();
        c1.Zscaler_Cloud_ID__c = ZSClIDlist.get(0).Id;
        c1.Account__c = acctTest.Id;
        c1.Total_Policy_Blocks__c = 200;
        c1.Total_Transactions__c = 1000;
        c1.Total_Transactions_Bandwidth__c = 10000;
        c1.Total_Security_Blocks__c = 600;
        c1.total_botnet_blocks__c = 300;
        c1.total_malware_site_blocks__c   = 100; 
        c1.total_phishing_blocks__c = 200;
        c1.Usage_Pull_Date__c = lastYearSameTime1;
        c1.total_ssl_transactions__c = 300;
        c1.Cloud_Usage_Type__c = 'ZPA';
        c1.total_ssl_inspected_transactions__c = 150;
        c1.Last_31_Days__c = true;
        c1.Last_6_Months__c = true;
        c1.Enrolled_Users__c = 13;
        c1.Last_90_Days__c = true;
        cloudList.add(c1);
        
        Cloud_Usage__c c2 = new Cloud_Usage__c();
        c2.Zscaler_Cloud_ID__c = ZSClIDlist.get(1).Id;
        c2.Account__c = acctTest.Id;
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
        c2.Cloud_Usage_Type__c = 'ZPA';
        c2.Last_31_Days__c = true;
        c2.Last_6_Months__c = true;
        c2.Last_90_Days__c = true;
        c2.Enrolled_Users__c = 13;
        cloudList.add(c2);
        
        Cloud_Usage__c c3 = new Cloud_Usage__c();
        c3.Zscaler_Cloud_ID__c = ZSClIDlist.get(1).Id;
        c3.Account__c = acctTest.Id;
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
        c3.Cloud_Usage_Type__c = 'ZPA';
        c3.Last_31_Days__c = true;
        c3.Last_6_Months__c = true;
        c3.Last_90_Days__c = true;
        c3.Enrolled_Users__c = 13;
        cloudList.add(c3);

        insert cloudList;

        
        List<BWC_Data__c> cloudMonthlyList = new List<BWC_Data__c>();
        
        BWC_Data__c cm1 = new BWC_Data__c();
        cm1.Cloud_ID__c = ZSClIDlist.get(0).Id;
        cm1.Type__c = 'ZPA';
        cm1.Monthly_Usage__c = System.today().toStartOfMonth();
        cm1.ZPA_L31d__c = 500;
        cm1.ZPA_L31d__c = 400;
        cloudMonthlyList.add(cm1);
        
        BWC_Data__c cm2 = new BWC_Data__c();
        cm2.Cloud_ID__c = ZSClIDlist.get(1).Id;
        cm2.Type__c = 'ZPA';
        cm2.Monthly_Usage__c = System.today().toStartOfMonth();
        cm2.ZPA_L31d__c = 500;
        cm2.ZPA_L31d__c = 400;
        cloudMonthlyList.add(cm2);
        
        BWC_Data__c cm3 = new BWC_Data__c();
        cm3.Cloud_ID__c = ZSClIDlist.get(1).Id;
        cm3.Type__c = 'ZPA';
        cm3.Monthly_Usage__c = System.today().toStartOfMonth().addMonths(-1); 
        cm3.ZPA_L31d__c = 500;
        cm3.ZPA_L31d__c = 400;
        cloudMonthlyList.add(cm3);
        insert cloudMonthlyList;
        
        AccountRollupEnrolledUserBatchScheduler m = new AccountRollupEnrolledUserBatchScheduler();
        String sch = '0 36 1 * * ?';
        String jobID = system.schedule('test rollup up opp fields', sch, m);

        test.stoptest();


    }

    static testmethod void test3(){

        Account acctTest = new Account(Name = 'Test Account', TAM_Email__c = 'abc@abc.com', 
                                       ZPA_Use_Cases__c = 'Accelerated Merger and Acquisition',First_ZPA_Contract_Date__c=date.today(),
                                       Type='Customer');
        insert acctTest;
        Contact con = new Contact(AccountId = acctTest.Id, LeadSource = 'Marketing Campaign', LastName = 'test con', First_Lead_Date__c = date.today(), Lead_Stage__c = 'Lead', MKTO71_Lead_Score__c = 0, Contacts_That_Matter__c  = true,Send_CIO_Report__c='Send');
        insert con; 
        test.starttest();
        
        List<Zscaler_Cloud_ID__c> ZSClIDlist = new List<Zscaler_Cloud_ID__c>();
        String rid = Schema.getGlobalDescribe().get('Zscaler_Cloud_ID__c').getDescribe().getRecordTypeInfosByName().get('ZPA Cloud ID').getRecordTypeId();
        Zscaler_Cloud_ID__c ZSc1= new Zscaler_Cloud_ID__c(Name='Zscloud.net-3926test1',Account__c=acctTest.Id,NS_Org_ID__c='Zscloud.net-3926test1.beta',Zscaler_Cloud_Domain__c='testacc.com.au.test1',Org_Name__c='Test Account Org',Cloud_Type__c='ZPA', recordTypeId = rid, ZPA_Enrolled_Users_L31D_Rollup__c = 1, ZPA_Enrolled_Users_L6M_Rollup__c= 1, ZPA_Enrolled_Users_L90D_Rollup__c= 1);
        ZSClIDlist.add(ZSc1);
        Zscaler_Cloud_ID__c ZSc2= new Zscaler_Cloud_ID__c(Name='Zscloud.net-3926test2',Account__c=acctTest.Id,NS_Org_ID__c='Zscloud.net-3926test2.beta',Zscaler_Cloud_Domain__c='testacc.com.au.test2',Org_Name__c='Test Account Org',Cloud_Type__c='ZPA', recordTypeId = rid, ZPA_Enrolled_Users_L31D_Rollup__c = 1, ZPA_Enrolled_Users_L6M_Rollup__c= 1, ZPA_Enrolled_Users_L90D_Rollup__c= 1);
        ZSClIDlist.add(ZSc2);
        insert ZSClIDlist;


        List<Cloud_Usage__c> cloudList = new List<Cloud_Usage__c>();
        Date dateToday = Date.today();
        Date thisMonth = dateToday.toStartOfMonth();
        date lastYearSameTime1 = thisMonth.addMonths(-13);
        date lastYearSameTime2 = thisMonth.addMonths(-14);
        date lastYearSameTime3 = thisMonth.addMonths(-15);
            
        Cloud_Usage__c c1 = new Cloud_Usage__c();
        c1.Zscaler_Cloud_ID__c = ZSClIDlist.get(0).Id;
        c1.Account__c = acctTest.Id;
        c1.Total_Policy_Blocks__c = 200;
        c1.Total_Transactions__c = 1000;
        c1.Total_Transactions_Bandwidth__c = 10000;
        c1.Total_Security_Blocks__c = 600;
        c1.total_botnet_blocks__c = 300;
        c1.total_malware_site_blocks__c   = 100; 
        c1.total_phishing_blocks__c = 200;
        c1.Usage_Pull_Date__c = lastYearSameTime1;
        c1.total_ssl_transactions__c = 300;
        c1.Cloud_Usage_Type__c = 'ZPA';
        c1.total_ssl_inspected_transactions__c = 150;
        c1.Last_31_Days__c = true;
        c1.Last_6_Months__c = true;
        c1.Enrolled_Users__c = 13;
        c1.Last_90_Days__c = true;
        cloudList.add(c1);
        
        Cloud_Usage__c c2 = new Cloud_Usage__c();
        c2.Zscaler_Cloud_ID__c = ZSClIDlist.get(1).Id;
        c2.Account__c = acctTest.Id;
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
        c2.Cloud_Usage_Type__c = 'ZPA';
        c2.Last_31_Days__c = true;
        c2.Last_6_Months__c = true;
        c2.Last_90_Days__c = true;
        c2.Enrolled_Users__c = 13;
        cloudList.add(c2);
        
        Cloud_Usage__c c3 = new Cloud_Usage__c();
        c3.Zscaler_Cloud_ID__c = ZSClIDlist.get(1).Id;
        c3.Account__c = acctTest.Id;
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
        c3.Cloud_Usage_Type__c = 'ZPA';
        c3.Last_31_Days__c = true;
        c3.Last_6_Months__c = true;
        c3.Last_90_Days__c = true;
        c3.Enrolled_Users__c = 13;
        cloudList.add(c3);

        insert cloudList;

        
        List<BWC_Data__c> cloudMonthlyList = new List<BWC_Data__c>();
        
        BWC_Data__c cm1 = new BWC_Data__c();
        cm1.Cloud_ID__c = ZSClIDlist.get(0).Id;
        cm1.Type__c = 'ZPA';
        cm1.Monthly_Usage__c = System.today().toStartOfMonth();
        cm1.ZPA_L31d__c = 500;
        cm1.ZPA_L31d__c = 400;
        cloudMonthlyList.add(cm1);
        
        BWC_Data__c cm2 = new BWC_Data__c();
        cm2.Cloud_ID__c = ZSClIDlist.get(1).Id;
        cm2.Type__c = 'ZPA';
        cm2.Monthly_Usage__c = System.today().toStartOfMonth();
        cm2.ZPA_L31d__c = 500;
        cm2.ZPA_L31d__c = 400;
        cloudMonthlyList.add(cm2);
        
        BWC_Data__c cm3 = new BWC_Data__c();
        cm3.Cloud_ID__c = ZSClIDlist.get(1).Id;
        cm3.Type__c = 'ZPA';
        cm3.Monthly_Usage__c = System.today().toStartOfMonth().addMonths(-1); 
        cm3.ZPA_L31d__c = 500;
        cm3.ZPA_L31d__c = 400;
        cloudMonthlyList.add(cm3);
        insert cloudMonthlyList;
        
        String query = 'SELECT Id,ZPA_Use_Cases__c, (SELECT ID,ZPA_Active_Users_L31D_RollUp__c,ZPA_Active_Users_L90D_RollUp__c, '+
        ' ZPA_Enrolled_Users_L31D_Rollup__c, ZPA_Enrolled_Users_L6M_Rollup__c,ZPA_Enrolled_Users_L90D_Rollup__c '+
        ' FROM Zscaler_Cloud_IDs__R WHERE Cloud_Type__c = \'ZPA\') FROM Account';
        AccountRollUpEnrolledUserBatch rollup = new AccountRollUpEnrolledUserBatch(query);
        Database.executeBatch(rollup);
        test.stoptest();


    }
    
    static testmethod void test4(){

        Account acctTest = new Account(Name = 'Test Account',First_ZPA_Contract_Date__c=date.today(),Type='Customer');
        insert acctTest;
        Contact con = new Contact(AccountId = acctTest.Id, LeadSource = 'Marketing Campaign', LastName = 'test con', First_Lead_Date__c = date.today(), Lead_Stage__c = 'Lead', MKTO71_Lead_Score__c = 0, Contacts_That_Matter__c  = true,Send_CIO_Report__c='Send');
        insert con; 
        test.starttest();
        
        List<Zscaler_Cloud_ID__c> ZSClIDlist = new List<Zscaler_Cloud_ID__c>();
        //String rid = Schema.getGlobalDescribe().get('Zscaler_Cloud_ID__c').getDescribe().getRecordTypeInfosByName().get('ZPA Cloud ID').getRecordTypeId();
        Zscaler_Cloud_ID__c ZSc1= new Zscaler_Cloud_ID__c(Name='Zscloud.net-3926test1',Account__c=acctTest.Id);
        ZSClIDlist.add(ZSc1);
        Zscaler_Cloud_ID__c ZSc2= new Zscaler_Cloud_ID__c(Name='Zscloud.net-3926test2',Account__c=acctTest.Id,Cloud_Type__c='ZIA');
        ZSClIDlist.add(ZSc2);
        insert ZSClIDlist;


        List<Cloud_Usage__c> cloudList = new List<Cloud_Usage__c>();
        Date dateToday = Date.today();
        Date thisMonth = dateToday.toStartOfMonth();
        date lastYearSameTime1 = thisMonth.addMonths(-13);
        date lastYearSameTime2 = thisMonth.addMonths(-14);
        date lastYearSameTime3 = thisMonth.addMonths(-15);
            
        Cloud_Usage__c c1 = new Cloud_Usage__c();
        c1.Zscaler_Cloud_ID__c = ZSClIDlist.get(0).Id;
        c1.Account__c = acctTest.Id;
        c1.Total_Policy_Blocks__c = 200;
        c1.Total_Transactions__c = 1000;
        c1.Total_Transactions_Bandwidth__c = 10000;
        c1.Total_Security_Blocks__c = 600;
        c1.total_botnet_blocks__c = 300;
        c1.total_malware_site_blocks__c   = 100; 
        c1.total_phishing_blocks__c = 200;
        c1.Usage_Pull_Date__c = lastYearSameTime1;
        c1.total_ssl_transactions__c = 300;
        c1.Cloud_Usage_Type__c = 'ZPA';
        c1.total_ssl_inspected_transactions__c = 150;
        c1.Last_31_Days__c = true;
        c1.Last_6_Months__c = true;
        c1.Enrolled_Users__c = 13;
        c1.Last_90_Days__c = true;
        cloudList.add(c1);
        
        Cloud_Usage__c c2 = new Cloud_Usage__c();
        c2.Zscaler_Cloud_ID__c = ZSClIDlist.get(1).Id;
        c2.Account__c = acctTest.Id;
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
        c2.Cloud_Usage_Type__c = 'ZPA';
        c2.Last_31_Days__c = true;
        c2.Last_6_Months__c = true;
        c2.Last_90_Days__c = true;
        c2.Enrolled_Users__c = 13;
        cloudList.add(c2);
        
        Cloud_Usage__c c3 = new Cloud_Usage__c();
        c3.Zscaler_Cloud_ID__c = ZSClIDlist.get(1).Id;
        c3.Account__c = acctTest.Id;
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
        c3.Cloud_Usage_Type__c = 'ZPA';
        c3.Last_31_Days__c = true;
        c3.Last_6_Months__c = true;
        c3.Last_90_Days__c = true;
        c3.Enrolled_Users__c = 13;
        cloudList.add(c3);

        insert cloudList;
        
        AccountRollupEnrolledUserBatchScheduler m = new AccountRollupEnrolledUserBatchScheduler();
        String sch = '0 36 1 * * ?';
        String jobID = system.schedule('test rollup up opp fields', sch, m);

        test.stoptest();

    }
    
     @isTest
        static void testAccountRollup(){
        Test.startTest();
        String query = 'SELECT Id,ZPA_Use_Cases__c, (SELECT ID,ZPA_Active_Users_L31D_RollUp__c,ZPA_Active_Users_L90D_RollUp__c, '+
        ' ZPA_Enrolled_Users_L31D_Rollup__c, ZPA_Enrolled_Users_L6M_Rollup__c,ZPA_Enrolled_Users_L90D_Rollup__c '+
        ' FROM Zscaler_Cloud_IDs__R WHERE Cloud_Type__c = \'ZIA\') FROM Account WHERE First_ZPA_Contract_Date__c != null and Type =\'Customer\' limit 1';
        AccountRollUpEnrolledUserBatch rollup = new AccountRollUpEnrolledUserBatch(query);
        Database.executeBatch(rollup);
        Test.stopTest();
    }

}