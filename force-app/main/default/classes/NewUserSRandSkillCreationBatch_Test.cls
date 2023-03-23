@isTest
public class NewUserSRandSkillCreationBatch_Test {
    
    @TestSetup
    static void setup() {
         Skip_Triggers__c skipTriggers = new Skip_Triggers__c();
        skipTriggers.Skip_Account_Triggers__c = true;
        skipTriggers.Skip_Opportunity_Triggers__c = true;
        skipTriggers.Name = 'SkipTriggers';
        insert skipTriggers;
        
        Skip_Triggers_User_Based__c sk = new Skip_Triggers_User_Based__c();
        sk.SetupOwnerId = UserInfo.getUserId();
        sk.Object_s_to_skip__c = 'User;Account';
        INSERT sk;
    }
    
    @IsTest
    static void test1(){
        
        UserRole r = new UserRole(DeveloperName = 'MyCustomRole1', Name = 'My Role');
        insert r;
        User u = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
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
            UserPermissionsSupportUser = true,
            Skills__c  = 'TAM;ZPA',
            UserRoleId = r.Id
        );
        insert u;
        
       
        
        test.startTest();
        NewUserSRandSkillCreationBatch batch = new NewUserSRandSkillCreationBatch('Select Id, Firstname, lastname, service_level__c, Skills__c, UserPermissionsSupportUser from User Limit 1');
        batch.errorlst.add('abc');
        batch.successlst.add('abc');
        Database.executeBatch(batch);
        Test.stopTest();
    }
}