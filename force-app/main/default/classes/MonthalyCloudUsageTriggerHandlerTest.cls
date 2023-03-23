@isTest
public class MonthalyCloudUsageTriggerHandlerTest {

    
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
    
    static testMethod void test1() {
        
        Account acctTest = new Account(Name = 'Test Account', TAM_Email__c = 'abc@abc.com', ZPA_Use_Cases__c = 'Not Applicable');
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
        
        
        List<BWC_Data__c> cloudList = new List<BWC_Data__c>();
        
        BWC_Data__c c1 = new BWC_Data__c();
        c1.Cloud_ID__c = ZSClIDlist.get(0).Id;
        c1.Type__c = 'ZPA';
        c1.Monthly_Usage__c = System.today().toStartOfMonth();
        c1.ZPA_L31d__c = 500;
        c1.ZPA_L31d__c = 400;
        cloudList.add(c1);
        
        BWC_Data__c c2 = new BWC_Data__c();
        c2.Cloud_ID__c = ZSClIDlist.get(1).Id;
        c2.Type__c = 'ZPA';
        c2.Monthly_Usage__c = System.today().toStartOfMonth();
        c2.ZPA_L31d__c = 500;
        c2.ZPA_L31d__c = 400;
        cloudList.add(c2);
        
        BWC_Data__c c3 = new BWC_Data__c();
        c3.Cloud_ID__c = ZSClIDlist.get(1).Id;
        c3.Type__c = 'ZPA';
        c3.Monthly_Usage__c = System.today().toStartOfMonth().addMonths(-1); 
        c3.ZPA_L31d__c = 500;
        c3.ZPA_L31d__c = 400;
        cloudList.add(c3);
        insert cloudList;
        
        c2.ZPA_L31d__c = 500;
        update c2;
        
        delete c2;

    }
}