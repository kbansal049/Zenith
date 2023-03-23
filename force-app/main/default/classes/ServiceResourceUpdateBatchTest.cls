@isTest
public class ServiceResourceUpdateBatchTest {
    static String aliasStr = 'alias';
    static String adminStr = 'Admin';
    static String systemStr = 'System';

	@TestSetup
    static void setupData(){
		User sysUser1 = TestDatafactory_Zscaler.insertAdminUser('puser000@amamama.com', adminStr, systemStr, aliasStr, 'puser000@amamama.com' + System.currentTimeMillis(), 
                        GCSCommonConstants.AMERICA_LA_TIME_ZONE, GCSCommonConstants.LANGUAGE_ENCODING_AS_EN_US, GCSCommonConstants.EMAIL_ENCODING_AS_UTF_8, GCSCommonConstants.LANGUAGE_ENCODING_AS_EN_US);
		User sysUser2 = TestDatafactory_Zscaler.insertAdminUser('puser001@amamama.com', adminStr, systemStr, aliasStr, 'puser001@amamama.com' + System.currentTimeMillis(), 
                        GCSCommonConstants.AMERICA_LA_TIME_ZONE, GCSCommonConstants.LANGUAGE_ENCODING_AS_EN_US, GCSCommonConstants.EMAIL_ENCODING_AS_UTF_8, GCSCommonConstants.LANGUAGE_ENCODING_AS_EN_US);
        sysUser2.ManagerId = sysUser1.Id;
        update sysUser2;                
		User sysUser3 = TestDatafactory_Zscaler.insertAdminUser('puser002@amamama.com', adminStr, systemStr, aliasStr, 'puser002@amamama.com' + System.currentTimeMillis(), 
                        GCSCommonConstants.AMERICA_LA_TIME_ZONE, GCSCommonConstants.LANGUAGE_ENCODING_AS_EN_US, GCSCommonConstants.EMAIL_ENCODING_AS_UTF_8, GCSCommonConstants.LANGUAGE_ENCODING_AS_EN_US);
		User sysUser4 = TestDatafactory_Zscaler.insertAdminUser('puser003@amamama.com', adminStr, systemStr, aliasStr, 'puser003@amamama.com' + System.currentTimeMillis(), 
                        GCSCommonConstants.AMERICA_LA_TIME_ZONE, GCSCommonConstants.LANGUAGE_ENCODING_AS_EN_US, GCSCommonConstants.EMAIL_ENCODING_AS_UTF_8, GCSCommonConstants.LANGUAGE_ENCODING_AS_EN_US);

		TestDatafactory_Zscaler.insertAdminUser('sysadmin@amamama.com', adminStr, 'SF', 'sysadmin', 'sysadmin@amamama.com' + System.currentTimeMillis(), 
                        GCSCommonConstants.AMERICA_LA_TIME_ZONE, GCSCommonConstants.LANGUAGE_ENCODING_AS_EN_US, GCSCommonConstants.EMAIL_ENCODING_AS_UTF_8, GCSCommonConstants.LANGUAGE_ENCODING_AS_EN_US);

		TestDatafactory_Zscaler.insertServiceResource(GCSCommonConstants.SERVICE_RESOURCE_TYPE_TAM, sysUser1.Id, null, null, null, 0, 0, GCSCommonConstants.SERVICE_RESOURCE_TYPE_TAM);
		ServiceResource sr2 = TestDatafactory_Zscaler.insertServiceResource('Support', sysUser2.Id, 3, 5, 2, 0, 0, 'Frontline');
		ServiceResource sr3 = TestDatafactory_Zscaler.insertServiceResource('Support', sysUser3.Id, null, 5, 5, 1, 2, 'Backline');
		ServiceResource sr4 = TestDatafactory_Zscaler.insertServiceResource(GCSCommonConstants.SERVICE_RESOURCE_TYPE_TAM, sysUser4.Id, 3, 4, 2, 2, 0, GCSCommonConstants.SERVICE_RESOURCE_TYPE_TAM);

        sr2.IsActive = true;
		update sr2;

		sr3.Out_of_Office__c = true;
		update sr3;
		
		sr4.Out_of_Office__c = true;
		update sr4;

		Case_Quota_Management__c cs = new Case_Quota_Management__c();
        cs.SetupOwnerId=UserInfo.getOrganizationId();
        cs.Backline_Daily_Quota__c=2;
        cs.Backline_Weekly_Quota__c=10;
        cs.Frontline_Daily_Quota__c=3;
        cs.Frontline_Weekly_Quota__c=15;
        cs.Online_Omni_Status__c='Quota_Met;Overflow';
        cs.Profiles_Allowed__c='';
        cs.Skills_to_Skip__c='CS;TAM';
        cs.Timezone__c=GCSCommonConstants.AMERICA_LA_TIME_ZONE;
        cs.Weekday_End_Time__c=0;
        cs.Weekday_Start_Time__c=7;
        cs.Weekend_End_Day__c='Sun';
        cs.Weekend_End_Time__c=16;
        cs.Weekend_Start_Day__c ='Fri';
        cs.Weekend_Start_Time__c=19;
        insert cs;

        Account testSetacct = TestDatafactory_Zscaler.insertAccount('Test Account', 'mytestemail@test.com', 'test', null, null, 5);
        TestDatafactory_Zscaler.insertContact('Test Contact Service Cloud GCS POD Test Class', testSetacct.Id, null);

		ResourceAbsence ra = new ResourceAbsence();
		ra.ResourceId = sr2.Id;
		ra.Start = system.now().addhours(-12);
		ra.End = system.now().addhours(12);
		insert ra;
		
		ra.Description = 'Test';
		update ra;

        delete ra;
	}

	@IsTest
    static void ServiceResourceUpdateBatchTest(){
        List<ServiceResource> srList = [SELECT id,RelatedRecordId,daily_Quota__c, weekly_Quota__c,backlog__c,timezone__c,out_Of_Office__c,Batch_Run_Timestamp__c,Type__c, Overflow_Cases__c,Overflow_Cases_Weekly__c,Override_Daily_Quota__c, Override_Weekly_Quota__c, Shift_Off_Days__c, Returning_Date__c FROM ServiceResource];
        User sysAdmin = [SELECT id FROM user WHERE alias = 'sysadmin' LIMIT 1];
		
        srList.get(0).isActive = true;
        update srList.get(0);
        
        ResourceAbsence ra = new ResourceAbsence();
		ra.ResourceId = srList.get(0).Id;
		ra.Start = system.now().addhours(-12);
		ra.End = system.now().addhours(25);
		insert ra;

		System.runAs(sysAdmin) {
            Test.startTest();
            ServiceResourceUpdateBatch obj = new ServiceResourceUpdateBatch();
            Database.executeBatch(obj);
            Test.stopTest();
        }
	}
}