@isTest
public class ServiceAgentInformationSchedulerTest {
    
    public static Account createZscalerInternalAccount () {
        Account acc = new Account ();
        acc.Name = System.Label.Zscaler_Internal_Account;
        acc.APTS_Platform_Subscription_End_Date__c = Date.today();
        insert acc;
        return acc;
    }

    
    @isTest
    static void test(){
        insert TestDatafactory_Zscaler.gettriggerswitchrecords(true);
        insert TestDatafactory_Zscaler.getserviceteamtoskill();
        
        createZscalerInternalAccount();
        
        List<Triggers_Switch__c> trlst = new List<Triggers_Switch__c>();
        trlst.add(new Triggers_Switch__c(name = 'Execute_createServiceAgentInformation', Execute__c = true));
        insert trlst;
        system.runAs(new user(Id=Userinfo.getUserId())){
            UserRole r = new UserRole(DeveloperName = 'MyCustomRole123', Name = 'My Role');
            insert r;
            User u = new User(
                ProfileId = [SELECT Id FROM Profile WHERE Name = 'TAM (Licensed)'].Id,
                LastName = 'last',
                Email = 'puser000@amamama.com',
                Username = 'puser000@amamama.com' + System.currentTimeMillis(),
                CompanyName = 'TEST',
                Title = 'title',
                Alias = 'alias',
                TimeZoneSidKey = 'America/Los_Angeles',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                UserRoleId = r.Id,
                Service_Level__c = 'TAM'
            );
            insert u;
           	Service_Agent_Information__c sai = new Service_Agent_Information__c(user__c=u.id,daily_Quota__c = 1, weekly_quota__c = 5, backlog__c = 0, Type__c='TAM');
        	insert sai;
        }
        ServiceAgentInformationScheduler sch = new ServiceAgentInformationScheduler();
        SchedulableContext sc = null;
        sch.execute(sc);
    }
    
    @isTest
    static void test2(){
        insert TestDatafactory_Zscaler.gettriggerswitchrecords(true);
        insert TestDatafactory_Zscaler.getserviceteamtoskill();
        
        createZscalerInternalAccount();
        
        List<Triggers_Switch__c> trlst = new List<Triggers_Switch__c>();
        trlst.add(new Triggers_Switch__c(name = 'Execute_createServiceAgentInformation', Execute__c = true));
        insert trlst;
        system.runAs(new user(Id=Userinfo.getUserId())){
            UserRole r = new UserRole(DeveloperName = 'MyCustomRole456', Name = 'My Role');
            insert r;
            User u = new User(
                ProfileId = [SELECT Id FROM Profile WHERE Name = 'TAM (Licensed)'].Id,
                LastName = 'last',
                Email = 'puser000@amamama.com',
                Username = 'puser000@amamama.com' + System.currentTimeMillis(),
                CompanyName = 'TEST',
                Title = 'title',
                Alias = 'alias',
                TimeZoneSidKey = 'America/Los_Angeles',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                Out_Of_Office__c = true,
                Start_Date__c = System.today(),
                returning_Date__c = System.Today().addDays(1),
                UserRoleId = r.Id,
                Service_Level__c = 'TAM'
            );
            insert u;
           	Service_Agent_Information__c sai = new Service_Agent_Information__c(user__c=u.id,daily_Quota__c = 1, weekly_quota__c = 5, backlog__c = 0, Type__c='TAM');
        	insert sai;
        }
        ServiceAgentInformationScheduler sch = new ServiceAgentInformationScheduler();
        SchedulableContext sc = null;
        sch.execute(sc);
    }
    
    @isTest
    static void test3(){
        insert TestDatafactory_Zscaler.gettriggerswitchrecords(true);
        insert TestDatafactory_Zscaler.getserviceteamtoskill();
        Id userId = UserInfo.getUserId();
        Service_Agent_Information__c sai = new Service_Agent_Information__c(user__c=userId,daily_Quota__c = 1, weekly_quota__c = 5, backlog__c = 0, Overflow_Cases__c=0, Overflow_Cases_Weekly__c=0, Type__c='Frontline',Shift_Off_Days__c='Tuesday;Wednesday');
        insert sai;
        Service_Agent_Information__c sai1 = new Service_Agent_Information__c(user__c=userId,daily_Quota__c = 1, weekly_quota__c = 5, backlog__c = 0, Overflow_Cases__c=0, Overflow_Cases_Weekly__c=0, Type__c='Frontline',Shift_Off_Days__c='Saturday;Sunday');
        insert sai1;
        ServiceAgentInformationScheduler sch = new ServiceAgentInformationScheduler();
        SchedulableContext sc = null;
        sch.execute(sc);

        ServiceAgentInformationBatch.logError('This is custom exception');
    }
    
    @testSetup static void setup(){
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
        cs.Weekend_End_Day__c='Fri';
        cs.Weekend_End_Time__c=19;
        cs.Weekend_Start_Day__c	='Fri';
        cs.Weekend_Start_Time__c=19;
        insert cs;
    }
}