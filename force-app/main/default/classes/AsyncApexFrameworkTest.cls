@isTest
public class AsyncApexFrameworkTest {
    
    
    @TestSetup static void setup(){
        TriggerHandler.bypass('AccountTriggerHandler');
        TriggerHandler.bypass('ContactTriggerHandler');
        
        TriggerUtility.SkipAccTriggerExecuted();
        
        ZscalerSetting__c newSetting = new ZscalerSetting__c(Name = 'AsyncApexFramework_Max_Retry', Value__c = '2');
        insert newSetting;
    }
    
    
    @isTest
    static void callBatchableTest() {
        
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
        
        Cloud_Usage__c c4 = new Cloud_Usage__c();
        c4.Name = 'Test Data';
        c4.Account__c = acctTest.Id;
        c4.ZPA_End_Date__c = system.today() - 200;
        c4.Cloud_Usage_Type__c = 'ZPA';
        c4.Zscaler_Cloud_ID__c = ZSClIDlist.get(1).Id;
        c4.Last_6_Months__c = true;
        insert c4 ;
        
        
        
        Cloud_Usage__c c5= new Cloud_Usage__c();
        c5.Name = 'Test Data';
        c5.Account__c = acctTest.Id;
        c5.ZPA_End_Date__c = system.today() - 30;
        c5.Cloud_Usage_Type__c = 'ZPA';
        c5.Last_31_Days__c = false;
        c5.Enrolled_Users__c = 13;
        c5.Zscaler_Cloud_ID__c = ZSClIDlist.get(1).Id;
        insert c5;
        
        test.startTest();
        
        AsyncApexFramework.submitBatch(new ZPACloudUsageSetToFalseBatch(),200,99,true);
        AsyncApexFramework.flush();

        test.stopTest();
        
    }
    
    @isTest
    static void callExecuteTest(){
        Account acc = new Account(Name = 'Test Account', TAM_Email__c = 'abc@abc.com',Type='Prospect');
        insert acc;
        
        Contact con = new Contact(FirstName='Test', LastName = 'Test1', accountid = acc.id);
        insert con;
        
        lead l= new Lead(FirstName = 'Test', LastName = 'Lead', Company = 'Test Lead Company', Status = 'Marketing Qualified: Sales Untouched');
        insert l;
        
        Id prRecordTypeId = Schema.SObjectType.Product_Demo_Instance_Request__c.getRecordTypeInfosByName().get('ZB2B Interactive').getRecordTypeId();
        Product_Demo_Instance_Request__c pr = new Product_Demo_Instance_Request__c();
        pr.RecordTypeId = prRecordTypeId;
        pr.Account__c = acc.Id;
        pr.SE__c = userinfo.getuserId();
        pr.Provisioning_Status__c = '';
        insert pr;
        
        Test.startTest();
        ZB2BInteractiveRequest ad = new ZB2BInteractiveRequest ('Contact', new List<ID>{con.id});
        AsyncApexFramework.submitQueueable(ad,99,true);
        AsyncApexFramework.flush();
        Test.stopTest();
    }
    
    @isTest
    static void callBatchableScheduleTest(){
        
        TriggerHandler.bypass('AccountTriggerHandler');
        
        Account acc = new Account(Name = 'Test Account1', TAM_Email__c = 'abc@abc.com',Type='Prospect');
        insert acc;
        
        Contact con = new Contact(FirstName='Test', LastName = 'Test2', accountid = acc.id);
        insert con;
        
        EmailNotificationCaseInSupportBatch ad = new EmailNotificationCaseInSupportBatch();
        String jbid = AsyncApexFramework.submitBatch(ad, 200, 99, true);
        
        AsyncQueue__c  q = new AsyncQueue__c (); 
        q.Is_Retry__c = true; 
        q.Class_Name__c = 'EmailNotificationCaseInSupportBatch';
        q.priority__c = 99;
        q.Job_Type__c = 'Batch';
        q.Status__c = 'Failed';
        q.Error_Collection_Status__c = 'Not Collected';
        q.Object__c = JSON.serialize(new EmailNotificationCaseInSupportBatch());
        insert q;
        
        Test.startTest();
        AsyncApexFrameworkScheduler obj1 = new AsyncApexFramework();  
        System.schedule('AsyncApexFramework 1', '0 0 * * * ?', obj1);
        Test.stopTest();
    }
    
     @isTest
    static void callQueuebleScheduleTest(){
        
        lead l= new Lead(FirstName = 'Test', LastName = 'Lead', Company = 'Test Lead Company', Status = 'Marketing Qualified: Sales Untouched');
        insert l;
        
        List <String> recordIds = new List<String>{l.id};
            
        ZB2BInteractiveRequest ad = new ZB2BInteractiveRequest ('Lead', new List<ID>{l.id});
        String jbid = AsyncApexFramework.submitQueueable(ad,99,true);
            
        AsyncQueue__c  q = new AsyncQueue__c (); 
        q.Is_Retry__c = true; 
        q.Class_Name__c = 'ZB2BInteractiveRequest';
        q.priority__c = 99;
        q.Job_Type__c = 'Queueable';
        q.Status__c = 'Failed';
        q.Job_Id__c = jbid;
        q.Error_Collection_Status__c = 'Not Collected';
        q.Retry_Count__c = 1;
        q.Object__c = JSON.serialize(new ZB2BInteractiveRequest('Lead',recordIds));
        insert q;
        
        Test.startTest();
        AsyncApexFrameworkScheduler obj1 = new AsyncApexFramework();  
        System.schedule('AsyncApexFramework 2', '0 0 * * * ?', obj1);
        Test.stopTest();
    }
    
}