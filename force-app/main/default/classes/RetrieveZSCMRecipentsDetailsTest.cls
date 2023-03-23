@isTest
public class RetrieveZSCMRecipentsDetailsTest {
    public static final String accountRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('End_User_Customer_DS_Reviewed').getRecordTypeId();

    @testSetup 
    static void setup() {
        insert TestDatafactory_Zscaler.gettriggerswitchrecords(true);
        insert TestDatafactory_Zscaler.getpriorityscore();
        insert TestDatafactory_Zscaler.getdefconcasescore();
        insert TestDatafactory_Zscaler.getprimsecescmap();
        insert TestDatafactory_Zscaler.getserviceteamtoskill();
        
        Case_Quota_Management__c cs = new Case_Quota_Management__c();
        cs.SetupOwnerId=UserInfo.getOrganizationId();
        cs.Backline_Daily_Quota__c=2;
        cs.Backline_Weekly_Quota__c=10;
        cs.Frontline_Daily_Quota__c=3;
        cs.Frontline_Weekly_Quota__c=15;
        cs.Online_Omni_Status__c='Quota_Met;Overflow';
        cs.Profiles_Allowed__c='';
        cs.Skills_to_Skip__c='CS;TAM';
        cs.Timezone__c='America/Los_Angeles';
        cs.Weekday_End_Time__c=0;
        cs.Weekday_Start_Time__c=7;
        cs.Weekend_End_Day__c='Sun';
        cs.Weekend_End_Time__c=16;
        cs.Weekend_Start_Day__c  ='Fri';
        cs.Weekend_Start_Time__c=19;
        insert cs;
        
        Account testSetacct = new Account();
        testSetacct.name = 'Test Account Service Cloud Test Class';
        testSetacct.Type = 'Customer';
        testSetacct.RecordTypeId = accountRTId;
        insert testSetacct;
        
        Contact testSetcon = new Contact();
        testSetcon.AccountId = testSetacct.Id;
        testSetcon.LastName = 'Test Contact Service';
        testSetcon.Email = 'testServiceCloudIgnoreEmailgcspod@gmail.com';
        testSetcon.Send_CIO_Report__c = 'Send delayed';
        insert testSetcon;
        
        Contact testSetcon1 = new Contact();
        testSetcon1.AccountId = testSetacct.Id;
        testSetcon1.LastName = 'Test Contact Service1';
        testSetcon1.Email = 'testServiceCloudIgnoreEmailgcspod1@gmail.com';
        testSetcon1.Send_CIO_Report__c = 'Send';
        insert testSetcon1;
        
        
        List<Zscaler_Cloud_ID__c> ZSClIDlist = new List<Zscaler_Cloud_ID__c>();
        String rid = Schema.getGlobalDescribe().get('Zscaler_Cloud_ID__c').getDescribe().getRecordTypeInfosByName().get('ZPA Cloud ID').getRecordTypeId();
        Zscaler_Cloud_ID__c ZSc1= new Zscaler_Cloud_ID__c(Name='Zscloud.net-3926test1',Account__c=testSetacct.Id,NS_Org_ID__c='Zscloud.net-3926test1.beta',Zscaler_Cloud_Domain__c='testacc.com.au.test1',Org_Name__c='Test Account Org',Cloud_Type__c='ZPA', recordTypeId = rid, ZPA_Enrolled_Users_L31D_Rollup__c = 1, ZPA_Enrolled_Users_L6M_Rollup__c= 1, ZPA_Enrolled_Users_L90D_Rollup__c= 1);
        ZSClIDlist.add(ZSc1);
        Zscaler_Cloud_ID__c ZSc2= new Zscaler_Cloud_ID__c(Name='Zscloud.net-3926test2',Account__c=testSetacct.Id,NS_Org_ID__c='Zscloud.net-3926test2.beta',Zscaler_Cloud_Domain__c='testacc.com.au.test2',Org_Name__c='Test Account Org',Cloud_Type__c='ZPA', recordTypeId = rid, ZPA_Enrolled_Users_L31D_Rollup__c = 1, ZPA_Enrolled_Users_L6M_Rollup__c= 1, ZPA_Enrolled_Users_L90D_Rollup__c= 1);
        ZSClIDlist.add(ZSc2);
        insert ZSClIDlist;
        
        List<Zscaler_Cloud_ID_Contact__c> ZSCClist= new List<Zscaler_Cloud_ID_Contact__c>();
        ZSCClist.add(new Zscaler_Cloud_ID_Contact__c(Account__c=testSetacct.id,Contact__c=testSetcon.id,Zscaler_Cloud_ID__c=ZSc1.id));
        ZSCClist.add(new Zscaler_Cloud_ID_Contact__c(Account__c=testSetacct.id,Contact__c=testSetcon1.id,Zscaler_Cloud_ID__c=ZSc1.id));
        insert ZSCClist;
    }
    
    @IsTest
    static void test1(){       
        //As Per Best Practice it is important to instantiate the Rest Context
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/GetZSCMRecipents'; //Request URL
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('{}');
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        RetrieveZSCMRecipentsDetails.doPost();
        Test.stopTest();
    }
    
    @IsTest
    static void test3(){
        List<Zscaler_Cloud_ID__c> ZSClIDlist = [Select id,Name from Zscaler_Cloud_ID__c];
        //As Per Best Practice it is important to instantiate the Rest Context
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/GetZSCMRecipents'; //Request URL
        req.httpMethod = 'POST';
        
        List<String> ZSClIDlistNames = new List<String>();
        for(Zscaler_Cloud_ID__c cloud : ZSClIDlist){
            ZSClIDlistNames.add(cloud.Name);
        }
        req.requestBody = Blob.valueOf(JSON.serializePretty(ZSClIDlistNames));
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        RetrieveZSCMRecipentsDetails.doPost();
        Test.stopTest();
    }
    
}