@isTest
public class RetrieveCaseDetailsTest {
    public static final String POST = 'POST';
    public static final String REQUEST_URI = '/services/apexrest/GetCaseDetail';
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
        testSetcon.LastName = 'Test Contact Service Cloud GCS POD Test Class';
        testSetcon.Email = 'testServiceCloudIgnoreEmailgcspod@gmail.com';
        insert testSetcon;
        
        
        List<Zscaler_Cloud_ID__c> ZSClIDlist = new List<Zscaler_Cloud_ID__c>();
        String rid = Schema.getGlobalDescribe().get('Zscaler_Cloud_ID__c').getDescribe().getRecordTypeInfosByName().get('ZPA Cloud ID').getRecordTypeId();
        Zscaler_Cloud_ID__c ZSc1= new Zscaler_Cloud_ID__c(Name='Zscloud.net-3926test1',Account__c=testSetacct.Id,NS_Org_ID__c='Zscloud.net-3926test1.beta',Zscaler_Cloud_Domain__c='testacc.com.au.test1',Org_Name__c='Test Account Org',Cloud_Type__c='ZPA', recordTypeId = rid, ZPA_Enrolled_Users_L31D_Rollup__c = 1, ZPA_Enrolled_Users_L6M_Rollup__c= 1, ZPA_Enrolled_Users_L90D_Rollup__c= 1);
        ZSClIDlist.add(ZSc1);
        Zscaler_Cloud_ID__c ZSc2= new Zscaler_Cloud_ID__c(Name='Zscloud.net-3926test2',Account__c=testSetacct.Id,NS_Org_ID__c='Zscloud.net-3926test2.beta',Zscaler_Cloud_Domain__c='testacc.com.au.test2',Org_Name__c='Test Account Org',Cloud_Type__c='ZPA', recordTypeId = rid, ZPA_Enrolled_Users_L31D_Rollup__c = 1, ZPA_Enrolled_Users_L6M_Rollup__c= 1, ZPA_Enrolled_Users_L90D_Rollup__c= 1);
        ZSClIDlist.add(ZSc2);
        insert ZSClIDlist;
        
        Id caseSupportRT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Support').getRecordTypeId();
        Case cs1=new Case();
        cs1.AccountId=testSetacct.Id;
        cs1.zscaler_org_id__c='Zscloud.net-3926test1';
        cs1.RecordTypeId=caseSupportRT;
        insert cs1;        
    }
    
    @IsTest
    static void test1(){
        
        //As Per Best Practice it is important to instantiate the Rest Context
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = REQUEST_URI; //Request URL
        req.httpMethod = POST;
        req.requestBody = Blob.valueOf('{}');
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        RetrieveCaseDetails.doPost();
        Test.stopTest();
    }
    @IsTest
    static void test2(){
        //As Per Best Practice it is important to instantiate the Rest Context
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = REQUEST_URI; //Request URL
        req.httpMethod = POST;
        req.requestBody = Blob.valueOf('{"CloudID": 1}');
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        RetrieveCaseDetails.doPost();
        Test.stopTest();
    }
    
    @IsTest
    static void test3(){
        List<Zscaler_Cloud_ID__c> ZSClIDlist = [Select id from Zscaler_Cloud_ID__c];
        //As Per Best Practice it is important to instantiate the Rest Context
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = REQUEST_URI; //Request URL
        req.httpMethod = POST;
        req.requestBody = Blob.valueOf('{"CloudID": "'+ZSClIDlist[0].Id+'"}');
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        RetrieveCaseDetails.doPost();
        Test.stopTest();
    }
    
    @IsTest
    static void test4(){
        List<Zscaler_Cloud_ID__c> ZSClIDlist = [Select id from Zscaler_Cloud_ID__c];
        //As Per Best Practice it is important to instantiate the Rest Context
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = REQUEST_URI; //Request URL
        req.httpMethod = POST;
        req.requestBody = Blob.valueOf('{"CloudID": "'+ZSClIDlist[0].Id+'", "StartDate" : "20220601 000000.000" }');
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        RetrieveCaseDetails.doPost();
        Test.stopTest();
    }
    
    
    @IsTest
    static void test5(){
        Id caseSupportRT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Support').getRecordTypeId();
        User ur = TestDatafactory_Zscaler.insertAdminUser('2xyz@xyz.com', 'test12', 'test', 'ttest12', '2xyz@xyz.com.test', 'GMT', 'en_US', 'UTF-8', 'en_US');
        ur.Skills__c = 'Premium';
        update ur;
        
        Account acct = [Select id from account limit 1];
        
        System.runAs(ur){
            TriggerUtility2.setPartnerDiscountExecuted();
            TriggerHandler.bypass('AccountTriggerHandler');
            
            Case cs = new Case(Subject='abcd', AccountId =  acct.Id, Priority='Urgent (P1)', RecordTypeId=caseSupportRT, Defcon_Level__c='3', Description='abcdDes', Case_type__c = 'Problem');
            insert cs;
            
            TriggerUtility.CaseBeforeUpdateReset();
            TriggerUtility.CaseAfterUpdateReset();
            TriggerUtility.skipCaseEscalationReset();
            cs.Status = 'Closed';
            cs.Case_category__c = 'APIs';
            cs.Case_Sub_Category__c = 'Assets Fix';
            cs.Resolution_Type__c = 'Resolved by KB';
            cs.Resolution_Summary__c = 'Resolved';
            
            cs.HandOff_Cases__c = true;
            cs.Escalation_Resolution_Notes__c = 'itsnotes';
            
            try{
                update cs;
            }catch(Exception ex){
                
            }
        }
        
        List<Zscaler_Cloud_ID__c> ZSClIDlist = [Select id,name,Account__c from Zscaler_Cloud_ID__c];
        
        //As Per Best Practice it is important to instantiate the Rest Context
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = REQUEST_URI; //Request URL
        req.httpMethod = POST;
        req.requestBody = Blob.valueOf('{"CloudID": "'+ZSClIDlist[0].name+'", "StartDate" : "20220601 000000.000", "EndDate" : "20230601 000000.000" }');
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        RetrieveCaseDetails.doPost();
        //RetrieveCaseDetails.retriveCases('Zscloud.net-3926test1',ZSClIDlist[0],System.now().addDays(-90),System.now().addDays(-60));
        Test.stopTest();
    }
}