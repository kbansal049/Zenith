@isTest
public class ServiceResourceOOOUpdateBatchTest {
	@TestSetup
    static void setupData(){
		User sysUser = TestDatafactory_Zscaler.insertAdminUser('puser001@amamama.com', 'Admin', 'System', 'alias', 'puser001@amamama.com' + System.currentTimeMillis(), 
                        GCSCommonConstants.AMERICA_LA_TIME_ZONE, GCSCommonConstants.LANGUAGE_ENCODING_AS_EN_US, GCSCommonConstants.EMAIL_ENCODING_AS_UTF_8, GCSCommonConstants.LANGUAGE_ENCODING_AS_EN_US);

		TestDatafactory_Zscaler.insertAdminUser('sysadmin@amamama.com', 'Admin', 'SF', 'sysadmin', 'sysadmin@amamama.com' + System.currentTimeMillis(), 
                        GCSCommonConstants.AMERICA_LA_TIME_ZONE, GCSCommonConstants.LANGUAGE_ENCODING_AS_EN_US, GCSCommonConstants.EMAIL_ENCODING_AS_UTF_8, GCSCommonConstants.LANGUAGE_ENCODING_AS_EN_US);

		ServiceResource sr = TestDatafactory_Zscaler.insertServiceResource('Support', sysUser.Id, 3, 5, 2, 0, 0, 'Frontline');
        sr.IsActive = true;
		update sr;

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
        
		ResourceAbsence ra = new ResourceAbsence();
		ra.ResourceId = sr.Id;
		ra.Start = system.now().addhours(2);
        ra.Start = ra.Start.addMinutes(30);
		ra.End = system.now().addhours(12);
		insert ra;
		
		ra.Description = 'Test';
		update ra;
	}

	@isTest
    static void ServiceResourceOOOUpdateBatchTest(){
        User sysAdmin = [Select id FROM user where alias = 'sysadmin' Limit 1];
		System.runAs(sysAdmin) {
            Test.startTest();
                ServiceResourceOOOUpdateBatch obj = new ServiceResourceOOOUpdateBatch();
                Database.executeBatch(obj);
            Test.stopTest();
        }
	}
}