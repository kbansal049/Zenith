@isTest
public class BatchJobMonitoringHelperTest {
    @isTest
    public static void insertBatchJobMonitoringTest(){
        BatchJobMonitoringHelper.insertBatchJobMonitoring('BatchJobMonitoringHelperTest', 10, '123456789' ,datetime.now());
        LIST<Batch_Job_Monitoring__c> lstBTM = [SELECT Id FROM Batch_Job_Monitoring__c WHERE JobId__c = '123456789'];
        System.assertEquals(1, lstBTM.Size() , 'assert failed');
        BatchJobMonitoringHelper.insertBatchJobMonitoring('BatchJobMonitoringHelperTest', 10, '12345678' ,datetime.now(),'Batch_Job_Monitoring__c',datetime.now());
    }
    
    @isTest
    public static void insertBatchJobMonitoringTest1(){
        BatchJobMonitoringHelper.insertBatchJobMonitoring('BatchJobMonitoringHelperTest', 10, '123456789' ,datetime.now());
        LIST<Batch_Job_Monitoring__c> lstBTM = [SELECT Id FROM Batch_Job_Monitoring__c WHERE JobId__c = '123456789'];
        System.assertEquals(1, lstBTM.Size() , 'assert failed');
        BatchJobMonitoringHelper.insertBatchJobMonitoring('BatchJobMonitoringHelperTest', 10, '12345678' ,datetime.now(),'Batch_Job_Monitoring__c',datetime.now());
    }
    
    @isTest
    public static void insertBatchJobMonitoringTest2(){
        
        TriggerHandler.bypass('AccountTriggerHandler');
        
        Account acctTest = new Account(Name = 'Test Account', TAM_Email__c = 'abc@abc.com');
        insert acctTest;
        Contact con = new Contact(AccountId = acctTest.Id, LeadSource = 'Marketing Campaign', LastName = 'test con', First_Lead_Date__c = date.today(), Lead_Stage__c = 'Lead', MKTO71_Lead_Score__c = 0, Contacts_That_Matter__c  = true,Send_CIO_Report__c='Send');
        insert con; 
        
        
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
        
        insert cloudList;
        
        test.startTest();
        
        Id batchjobid = database.executeBatch(new ZPACloudUsageSetToFalseBatch(), 1);
 
        
        
        BatchJobMonitoringHelper.insertBatchJobMonitoring('ABC', batchjobid,
                                                          System.now(), 
                                                          System.now());
        test.stopTest();
    }
}