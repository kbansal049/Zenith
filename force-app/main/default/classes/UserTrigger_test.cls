@isTest
public class UserTrigger_test {
    public static String COMPANY_NAME = 'TEST';
    public static String TEST_EMAIL_ADDRESS = 'puser000@amamama.com';
    public static String  TAM = 'TAM';
    public static String  LA_TIMEZONE = 'America/Los_Angeles';
    public static String  USER_ALIAS = 'alias';
    public static String  USER_LASTNAME = 'last';
    public static String  USER_TITLE = 'title';

    @testSetup 
    static void setup() {
        // Create common test accounts
           Account acc4 = new Account();
            acc4.Name = 'Zscaler Internal Employee Tenant Requests';
            acc4.Type = 'Partner';
            acc4.TAM_Email__c = 'a@a.com';
            acc4.Program_Type__c = 'Reseller';
            insert acc4;   
    }
    @IsTest
    static void test1(){
        insert TestDatafactory_Zscaler.gettriggerswitchrecords(true);
        insert TestDatafactory_Zscaler.getserviceteamtoskill();
        
        System.runAs(new user(Id=Userinfo.getUserId())){
            UserRole r = [SELECT Id FROM UserRole WHERE DeveloperName = 'IT_Enterprise_Architecture' LIMIT 1];
            
            User u = new User(
                ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
                LastName =USER_LASTNAME,
                Email = TEST_EMAIL_ADDRESS,
                Username = TEST_EMAIL_ADDRESS + System.currentTimeMillis(),
                CompanyName = COMPANY_NAME,
                Title = USER_TITLE,
                Alias =USER_ALIAS,
                TimeZoneSidKey = LA_TIMEZONE,
                EmailEncodingKey = GCSCommonConstants.EMAIL_ENCODING_AS_UTF_8,
                LanguageLocaleKey = GCSCommonConstants.LANGUAGE_ENCODING_AS_EN_US,
                LocaleSidKey = GCSCommonConstants.LANGUAGE_ENCODING_AS_EN_US,
                UserRoleId = r.Id
            );
            
            insert u;
            
            u.UserPermissionsSupportUser = true;
            u.Skills__c = 'ZPA;CS';
            update u;
            
            TriggerUtility.UserAfterUpdateReset();
            TriggerUtility.UserSkillAssignmentUpdateReset();
            u.Skills__c = TAM;
            u.Service_Level__c = TAM;
            update u;
        }
    }
    
    @IsTest
    static void createServiceAgentInformation_test(){
        insert TestDatafactory_Zscaler.gettriggerswitchrecords(true);
        insert TestDatafactory_Zscaler.getserviceteamtoskill();
        
        List<Triggers_Switch__c> trlst = new List<Triggers_Switch__c>();
        trlst.add(new Triggers_Switch__c(name = 'Execute_createServiceAgentInformation', Execute__c = true));
        trlst.add(new Triggers_Switch__c(name = 'Replace_Inactive_User_On_FP_RAM', Execute__c = true));
        insert trlst;
        
        System.runAs(new user(Id=Userinfo.getUserId())){
            UserRole r = new UserRole(DeveloperName = 'MyCustomRole1', Name = 'My Role');
            insert r;
            
            User u = new User(
                ProfileId = [SELECT Id FROM Profile WHERE Name = 'TAM (Licensed)'].Id,
                LastName = USER_LASTNAME,
                Email = TEST_EMAIL_ADDRESS,
                Username = TEST_EMAIL_ADDRESS + System.currentTimeMillis(),
                CompanyName = COMPANY_NAME,
                Title = USER_TITLE,
                Alias = USER_ALIAS,
                TimeZoneSidKey = LA_TIMEZONE,
                EmailEncodingKey = GCSCommonConstants.EMAIL_ENCODING_AS_UTF_8,
                LanguageLocaleKey = GCSCommonConstants.LANGUAGE_ENCODING_AS_EN_US,
                LocaleSidKey = GCSCommonConstants.LANGUAGE_ENCODING_AS_EN_US,
                UserRoleId = r.Id
               
            );
            
            insert u;
            
            u.Service_Level__c = TAM;
            u.Skills__c = TAM;
            update u;
        }
    }
    
    @IsTest
    static void testReplaceRAMOnFP(){
        insert TestDatafactory_Zscaler.gettriggerswitchrecords(true);
        
        List<Triggers_Switch__c> trlst = new List<Triggers_Switch__c>();
        trlst.add(new Triggers_Switch__c(name = 'Replace_Inactive_User_On_FP_RAM', Execute__c = true));
        insert trlst;
        
        System.runAs(new user(Id=Userinfo.getUserId())){
            UserRole r = [SELECT Id FROM UserRole WHERE DeveloperName = 'IT_Enterprise_Architecture' LIMIT 1];
            
            User userManager = TestDatafactory_Zscaler.insertAdminUser('xyz_123@xyz.com', 'test123', COMPANY_NAME, 'test123', 'xyz_123@xyz.com.test', 'GMT', GCSCommonConstants.LANGUAGE_ENCODING_AS_EN_US, GCSCommonConstants.EMAIL_ENCODING_AS_UTF_8, GCSCommonConstants.LANGUAGE_ENCODING_AS_EN_US);
            
            User u = new User(
                ProfileId = [SELECT Id FROM Profile WHERE Name = 'TAM (Licensed)'].Id,
                LastName = USER_LASTNAME,
                Email = TEST_EMAIL_ADDRESS,
                Username = TEST_EMAIL_ADDRESS + System.currentTimeMillis(),
                CompanyName = COMPANY_NAME,
                Title = USER_TITLE,
                Alias = USER_ALIAS,
                TimeZoneSidKey = LA_TIMEZONE,
                EmailEncodingKey = GCSCommonConstants.EMAIL_ENCODING_AS_UTF_8,
                LanguageLocaleKey = GCSCommonConstants.LANGUAGE_ENCODING_AS_EN_US,
                LocaleSidKey = GCSCommonConstants.LANGUAGE_ENCODING_AS_EN_US,
                UserRoleId = r.Id,
                Service_Level__c = TAM,
                Skills__c = 'ZPA',
                ManagerId = userManager.Id
            );
            
            insert u;
            
            List<PatchTeam__c> lstPatchTeamsToInsert = New List<PatchTeam__c>();
            PatchTeam__c amerPatchTeam1 = new PatchTeam__c();
            amerPatchTeam1.Area__c = 'US North Central';
            amerPatchTeam1.Region__c = 'US Central';
            amerPatchTeam1.Territory_Type__c = 'General Business';
            amerPatchTeam1.Theater__c = 'AMERICAS';
            lstPatchTeamsToInsert.add(amerPatchTeam1);
            insert lstPatchTeamsToInsert;
                
            //Account acc1 = TestDatafactory_Zscaler.insertAccount('Test Account 1', null, 'Partner', null, null, null);
            Account acc1 = new Account();
            acc1.Name = 'Test Account 1';
            acc1.Type = 'Partner';
            acc1.TAM_Email__c = 'a@a.com';
            acc1.Program_Type__c = 'Reseller';
            insert acc1;
            Focus_Partner__c fp1 = new Focus_Partner__c(
            	Partner_Account__c = acc1.id,
                RAM__c = u.id,
                Sales_Territory__c = lstPatchTeamsToInsert[0].Id,
                Comments__c = COMPANY_NAME
            );
            insert fp1;
            
           	u.isActive = false;
            update u;
            
            u.ManagerId = null;
            u.isActive = true;
            update u;
            
          //  Account acc2 = TestDatafactory_Zscaler.insertAccount('Test Account 2', null, 'Partner', null, null, null);
            
            Account accrec = [Select Id from Account where name = 'Zscaler Internal Employee Tenant Requests' LIMIT 1];

            Focus_Partner__c fp2 = new Focus_Partner__c(
            	Partner_Account__c = accrec.id,
                RAM__c = u.id,
                Sales_Territory__c = lstPatchTeamsToInsert[0].Id,
                Comments__c = COMPANY_NAME
            );
            insert fp2;
            
           	u.isActive = false;
            update u;
            
            u.isActive = true;
            update u;
            
        	Map<id, User> usrmap = new Map<id, User>();
            usrmap.put(u.id, u);
            Set<ID> userIds = new Set<ID>();
            userIds.add(u.id);
        	Map<String, ServiceResource> srmap = new Map<String, ServiceResource>();
            UserTriggerUtility.ServicecreateServiceResources(usrmap.keyset());
            Test.startTest();
            UserTriggerUtility.createserviceResourceSkill(usrmap, srmap);
            UserTriggerUtility.createContactOnUserCreation(userIds);
            
            Test.stopTest();
        }
    }

    @IsTest
    static void test2(){        

        User u = new User(
                ProfileId = [SELECT Id FROM Profile WHERE Name = 'TAM (Licensed)'].Id,
                LastName =USER_LASTNAME,
                Email = TEST_EMAIL_ADDRESS,
                Username = TEST_EMAIL_ADDRESS + System.currentTimeMillis(),
                CompanyName = COMPANY_NAME,
                Title = USER_TITLE,
                Alias = USER_ALIAS,
                TimeZoneSidKey = LA_TIMEZONE,
                EmailEncodingKey = GCSCommonConstants.EMAIL_ENCODING_AS_UTF_8,
                LanguageLocaleKey = GCSCommonConstants.LANGUAGE_ENCODING_AS_EN_US,
                LocaleSidKey = GCSCommonConstants.LANGUAGE_ENCODING_AS_EN_US,                
                Service_Level__c = TAM,
                Skills__c = TAM
                
            );
            
            insert u;

            User userAdmin = TestDatafactory_Zscaler.insertAdminUser('xyz_12323@xyz.com', 'test343223', COMPANY_NAME, 'test1323', 'xyz_123@xyz.com.t4est', 'GMT', GCSCommonConstants.LANGUAGE_ENCODING_AS_EN_US, GCSCommonConstants.EMAIL_ENCODING_AS_UTF_8, GCSCommonConstants.LANGUAGE_ENCODING_AS_EN_US);
            ServiceResource sr = new ServiceResource();
            System.runas(userAdmin){
                
                sr.IsActive = true;
                sr.RelatedRecordId = u.Id;
                sr.Type__c = TAM;
                sr.Name = 'test User';
                Insert sr;
            }

        Test.startTest();
        UserTriggerUtility.updateSRtoActive(new Set<String>{sr.Id});
        Test.stopTest();
    }
}