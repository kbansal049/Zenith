/**
 * Name : TAMEngagementCmpCtrlTest
 * Description : Test Class of TAMEngagementCmpCtrl
 */

@isTest
public class TAMEngagementCmpCtrlTest {
    
    @testSetup
    static void setup() {
        List<TAM_Engagement__c> engagementList = new List<TAM_Engagement__c>();
        Account acc = new Account(Name='Test Account');
        insert acc;
        engagementList.add(new TAM_Engagement__c(Account__c = acc.id, Product__c = 'ZIA',tam_engagement_Status__c='Work in Progress',stage__c = 'STAGE 1: Onboarding'));
        insert engagementList;
    }

    @isTest
    static void getTAMEngagementStage_Test() {
        TAM_Engagement__c eng = [SELECT id,Name,account__c,stage__c, tam_engagement_Status__c FROM TAM_Engagement__c LIMIT 1];
        TAMEngagementCmpCtrl.getTAMEngagementStage(eng.id);
    }

    @isTest
    static void getPageLayoutFields_test(){
        TAM_Engagement__c eng = [SELECT id,Name,account__c,stage__c, tam_engagement_Status__c FROM TAM_Engagement__c LIMIT 1];
        TAMEngagementCmpCtrl.getPageLayoutFields(eng.stage__c,eng.Id);
        TAMEngagementCmpCtrl.getPageLayoutFields(eng.stage__c,'');
        TAMEngagementCmpCtrl.removeQuotes('Test');
    }

    @isTest
    static void checkIfTAMAccount_test(){
        TAM_Engagement__c eng = [SELECT id,Name,account__c,stage__c, tam_engagement_Status__c FROM TAM_Engagement__c LIMIT 1];
        TAMEngagementCmpCtrl.checkIfTAMAccount(eng.account__c);
        TAMEngagementCmpCtrl.checkIfTAMAccount(eng.Id);
    }

    @isTest
    static void productsValidation_test(){
        TAM_Engagement__c eng = [SELECT id,Name,account__c,stage__c, tam_engagement_Status__c FROM TAM_Engagement__c LIMIT 1];
        TAMEngagementCmpCtrl.productsValidation(eng.account__c);
        TAMEngagementCmpCtrl.productsValidation(eng.Id);
    }

    @isTest
    static void getStagePicklistValue_test(){
        TAMEngagementCmpCtrl.getStagePicklistValue();
    }

    @isTest
    static void tamEngagementSetStage_test(){
        TAM_Engagement__c eng = [SELECT id,Name,account__c,stage__c, tam_engagement_Status__c FROM TAM_Engagement__c LIMIT 1];
        TAMEngagementCmpCtrl.tamEngagementSetStage(eng.Id, 'STAGE 6: Business Continuity');
    }

    
    @isTest
    static void tamEngagementSetProducts_test(){
        TAM_Engagement__c eng = [SELECT id,Name,account__c,stage__c, tam_engagement_Status__c FROM TAM_Engagement__c LIMIT 1];
        TAMEngagementCmpCtrl.tamEngagementSetProducts(eng.Id, 'ZIA');
    }

    @isTest
    static void setClosingComments_test(){
        TAM_Engagement__c eng = [SELECT id,Name,account__c,stage__c, tam_engagement_Status__c FROM TAM_Engagement__c LIMIT 1];
        TAMEngagementCmpCtrl.setClosingComments(eng.Id, 'Closing Test Comments');
    }

    @isTest
    static void getAccountDetails_test(){
        TAM_Engagement__c eng = [SELECT id,Name,account__c,stage__c, tam_engagement_Status__c FROM TAM_Engagement__c LIMIT 1];
        TAMEngagementCmpCtrl.getAccountDetails(eng.Account__c);
    }


    @isTest
    static void submitForApproval_test(){
        UserRole r = new UserRole(DeveloperName = 'MyCustomRole1', Name = 'My Role1');
        insert r;
        String pId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
        User manager = new User(
            ProfileId = pId,
            LastName = 'last',
            Email = 'puser000@amamama.com',
            Username = 'puser+Manager@amamama.com' + System.currentTimeMillis(),
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
        insert manager;
        User u = new User(
            ProfileId = pId,
            managerId = manager.Id,
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
        TAM_Engagement__c eng = [SELECT id,Name,account__c,stage__c, tam_engagement_Status__c FROM TAM_Engagement__c LIMIT 1];
        System.runAs(u) {
         	TAMEngagementCmpCtrl.checkIfUserCanApprove(u.id, eng.Id);
            eng.stage__c = 'Stage 2: Establish Alignment';
            update eng;
            TAMEngagementCmpCtrl.checkIfUserCanSubmit(u.id, eng.id);
            TAMEngagementCmpCtrl.submitForApproval(eng.id,'',eng.stage__c); 
        }
        System.runAs(manager) {
            TAMEngagementCmpCtrl.checkIfUserCanApprove(manager.Id, eng.Id);
            TAMEngagementCmpCtrl.handleApprovalResponse(eng.Id,'Approve','');  
        }
    }

}