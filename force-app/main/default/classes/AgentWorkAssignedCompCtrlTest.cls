@isTest
public class AgentWorkAssignedCompCtrlTest {
    static String testEmailStr = 'puser000@amamama.com';
    static String backlogStr = 'backlog';

    @IsTest
    static void testController(){
        List<Triggers_Switch__c> switchList = TestDatafactory_Zscaler.gettriggerswitchrecords(true);       
        insert switchList;

        List<Service_Team_to_Skill_Map__c> trlst = TestDatafactory_Zscaler.getserviceteamtoskill();
        Insert trlst;

        User sysUser = TestDatafactory_Zscaler.insertAdminUser(testEmailStr, 'Admin', 'System', 'alias', testEmailStr + System.currentTimeMillis(), 
        GCSCommonConstants.AMERICA_LA_TIME_ZONE, GCSCommonConstants.LANGUAGE_ENCODING_AS_EN_US, GCSCommonConstants.EMAIL_ENCODING_AS_UTF_8, GCSCommonConstants.LANGUAGE_ENCODING_AS_EN_US);
        sysUser.Skills__c = 'CS;TAM;Backline';
        Update sysUser;

        Timezone pstTz = Timezone.getTimeZone(GCSCommonConstants.AMERICA_LA_TIME_ZONE);
        DateTime currentTimePst1 = Datetime.now().addSeconds((pstTz.getOffset(Datetime.now())/1000));
        DateTime currentTimePst2 = Datetime.now().addSeconds((pstTz.getOffset(Datetime.now())/1000)).addHours(8);
        
        Datetime targetDate = System.today();
        String dayOfWeek = targetDate.format('EEEE');

		System.runAs(sysUser){
			Case_Quota_Management__c cs = new Case_Quota_Management__c();
            cs.SetupOwnerId=UserInfo.getOrganizationId();
            cs.Backline_Daily_Quota__c=2;
            cs.Backline_Weekly_Quota__c=10;
            cs.Frontline_Daily_Quota__c=3;
            cs.Frontline_Weekly_Quota__c=15;
            cs.Online_Omni_Status__c='Quota_Met;Overflow';
            cs.Profiles_Allowed__c='';
            cs.Skills_to_Skip__c='CS;TAM';
            cs.Timezone__c= GCSCommonConstants.AMERICA_LA_TIME_ZONE;
            cs.Weekday_End_Time__c=0;
            cs.Weekday_Start_Time__c=7;
            cs.Weekend_End_Day__c='Sun';
            cs.Weekend_End_Time__c=16;
            cs.Weekend_Start_Day__c ='Fri';
            cs.Weekend_Start_Time__c=19;
            insert cs;

			OperatingHours oh = new OperatingHours();
			oh.name = 'Test oh';
			oh.TimeZone = GCSCommonConstants.AMERICA_LA_TIME_ZONE;
			insert oh;

			ServiceTerritory st = new ServiceTerritory();
            st.Name = 'Zscaler Service Territory';
            st.IsActive = true;
            st.OperatingHoursId = oh.id;
            insert st;

            ServiceResource sr = TestDatafactory_Zscaler.insertServiceResource('Test', sysUser.Id, 1, 5, 0, 0, 0, 'Frontline');
            sr.Out_of_Office__c = false;
            sr.isActive = true;
            sr.Daily_Quota__c = 1;
            update sr;

			ServiceTerritoryMember stm = new ServiceTerritoryMember();
			stm.ServiceResourceId = sr.id;
			stm.ServiceTerritoryId = st.id;
			stm.OperatingHoursId= oh.id;
			stm.EffectiveStartDate = currentTimePst1.addDays(-2);
			stm.EffectiveEndDate = currentTimePst2.addDays(30);
			insert stm;

            Shift sf = TestDatafactory_Zscaler.insertShift(sr.Id, GCSCommonConstants.SHIFT_TYPE_BACKLINE, dayOfWeek, currentTimePst1.addHours(7), currentTimePst2.addHours(12), 'Extended', st.id, 'Recurring');
            sf.RecurrenceStartDate = Date.newInstance(currentTimePst1.year(), currentTimePst1.month(), currentTimePst1.day());
            sf.RecurrenceEndDate = System.today().addDays(30);
            update sf;

            AgentWorkAssignedCompCtrl.agentPriorityChangeCheck();
            AgentWorkAssignedCompCtrl.getAgentStatus('P1',GCSCommonConstants.AMERICA_LA_TIME_ZONE);

            AgentWorkAssignedCompCtrl.checkAgentQuotaMet();
            AgentWorkAssignedCompCtrl.skipOmniControlLogic();
            sr.daily_Quota__c = 0;
            update sr;

            sf.Shift_Type__c='P2-P4';
            update sf;

            AgentWorkAssignedCompCtrl.getAgentStatus('P1',GCSCommonConstants.AMERICA_LA_TIME_ZONE);
            
            sr.Overflow_Cases__c = 1;
            update sr;

            sf.Shift_Type__c='P1-P4';
            update sf;

            AgentWorkAssignedCompCtrl.getAgentStatus('P1',GCSCommonConstants.AMERICA_LA_TIME_ZONE);
            sf.Shift_Type__c=GCSCommonConstants.SHIFT_TYPE_BACKLINE;
            update sf;
            
            Test.StartTest();
                AgentWorkAssignedCompCtrl.getAgentStatus('P1',GCSCommonConstants.AMERICA_LA_TIME_ZONE);
                AgentWorkAssignedCompCtrl.temporaryCoverage();
                AgentWorkAssignedCompCtrl.getActiveShift(sysUser.Id , GCSCommonConstants.AMERICA_LA_TIME_ZONE );
            Test.StopTest();
        }       
    }

    @IsTest
    static void testController2(){
        List<Triggers_Switch__c> switchList = TestDatafactory_Zscaler.gettriggerswitchrecords(true);       
        insert switchList;

        List<Service_Team_to_Skill_Map__c> trlst = TestDatafactory_Zscaler.getserviceteamtoskill();
        Insert trlst;

        User sysUser = TestDatafactory_Zscaler.insertAdminUser(testEmailStr, 'Admin', 'System', 'alias', testEmailStr + System.currentTimeMillis(), 
        GCSCommonConstants.AMERICA_LA_TIME_ZONE, GCSCommonConstants.LANGUAGE_ENCODING_AS_EN_US, GCSCommonConstants.EMAIL_ENCODING_AS_UTF_8, GCSCommonConstants.LANGUAGE_ENCODING_AS_EN_US);
        sysUser.Skills__c = 'CS;TAM;Backline';
        Update sysUser;

        Timezone pstTz = Timezone.getTimeZone(GCSCommonConstants.AMERICA_LA_TIME_ZONE);
        DateTime currentTimePst1 = Datetime.now().addSeconds((pstTz.getOffset(Datetime.now())/1000));
        DateTime currentTimePst2 = Datetime.now().addSeconds((pstTz.getOffset(Datetime.now())/1000)).addHours(8);
        
        Datetime targetDate = System.today();
        String dayOfWeek = targetDate.format('EEEE');

		System.runAs(sysUser){
			Case_Quota_Management__c cs = new Case_Quota_Management__c();
            cs.SetupOwnerId=sysUser.Id;
            cs.Backline_Daily_Quota__c=2;
            cs.Backline_Weekly_Quota__c=10;
            cs.Frontline_Daily_Quota__c=3;
            cs.Frontline_Weekly_Quota__c=15;
            cs.Online_Omni_Status__c='Quota_Met;Overflow';
            cs.Profiles_Allowed__c='';
            cs.Skills_to_Skip__c='CS;TAM';
            cs.Timezone__c= GCSCommonConstants.AMERICA_LA_TIME_ZONE;
            cs.Weekday_End_Time__c=0;
            cs.Weekday_Start_Time__c=7;
            cs.Weekend_End_Day__c='Sun';
            cs.Weekend_End_Time__c=16;
            cs.Weekend_Start_Day__c ='Fri';
            cs.Weekend_Start_Time__c=19;
            insert cs;

			OperatingHours oh = new OperatingHours();
			oh.name = 'Test oh';
			oh.TimeZone = GCSCommonConstants.AMERICA_LA_TIME_ZONE;
			insert oh;

			ServiceTerritory st = new ServiceTerritory();
            st.Name = 'Zscaler Service Territory';
            st.IsActive = true;
            st.OperatingHoursId = oh.id;
            insert st;

            ServiceResource sr = TestDatafactory_Zscaler.insertServiceResource('Test', sysUser.Id, 1, 5, 0, 0, 0, 'Frontline');
            sr.Out_of_Office__c = false;
            sr.isActive = true;
            sr.Daily_Quota__c = 1;
            update sr;

			ServiceTerritoryMember stm = new ServiceTerritoryMember();
			stm.ServiceResourceId = sr.id;
			stm.ServiceTerritoryId = st.id;
			stm.OperatingHoursId= oh.id;
			stm.EffectiveStartDate = currentTimePst1.addDays(-2);
			stm.EffectiveEndDate = currentTimePst2.addDays(30);
			insert stm;

            Shift sf = TestDatafactory_Zscaler.insertShift(sr.Id, GCSCommonConstants.SHIFT_TYPE_BACKLINE, dayOfWeek, currentTimePst1, currentTimePst2, 'Extended', st.id, 'Recurring');
            sf.RecurrenceStartDate = currentTimePst1.addDays(-1).date();
            sf.RecurrenceEndDate = currentTimePst1.addDays(30).date();
            update sf;
    
            AgentWorkAssignedCompCtrl.agentPriorityChangeCheck();
            AgentWorkAssignedCompCtrl.getAgentStatus('P1',GCSCommonConstants.AMERICA_LA_TIME_ZONE);

            AgentWorkAssignedCompCtrl.checkAgentQuotaMet();
            AgentWorkAssignedCompCtrl.skipOmniControlLogic();
            sr.daily_Quota__c = 0;
            update sr;

            sf.Shift_Type__c='P2-P4';
            update sf;

            AgentWorkAssignedCompCtrl.getAgentStatus('P1',GCSCommonConstants.AMERICA_LA_TIME_ZONE);
            
            sr.Overflow_Cases__c = 1;
            update sr;

            sf.Shift_Type__c='P1-P4';
            update sf;

            AgentWorkAssignedCompCtrl.getAgentStatus('P1',GCSCommonConstants.AMERICA_LA_TIME_ZONE);
            sf.Shift_Type__c=GCSCommonConstants.SHIFT_TYPE_BACKLINE;
            update sf;

            Test.StartTest();
                AgentWorkAssignedCompCtrl.agentPriorityChangeCheck();
                AgentWorkAssignedCompCtrl.getAgentStatus('P1',GCSCommonConstants.AMERICA_LA_TIME_ZONE);
                AgentWorkAssignedCompCtrl.temporaryCoverage();
                AgentWorkAssignedCompCtrl.getActiveShift(sysUser.Id , GCSCommonConstants.AMERICA_LA_TIME_ZONE );
            Test.StopTest();
        }
    }
}