//Replacing Tech Partner to Influence Partner as part of IBA- 1742
@IsTest
private with sharing class TeamingTechPartnerCompControllerTest {
    @testSetup static void setup() {
        TriggerUtility.SkipAccTriggerExecuted();
        TriggerUtility.SkipOppTriggerExecuted();
        
        
        Account acc = new Account(Name = 'Test Account', TAM_Email__c = 'abc@abc.com',Area_Director__c=Userinfo.getUserId(),Type='Technology Partner',Partner_Type__c='Partner-Integrator');
        INSERT acc;
        
        Account acc1 = new Account(Name = 'Test Account1', TAM_Email__c = 'abc@abc.com',Area_Director__c=Userinfo.getUserId(),Type='Technology Partner',Partner_Type__c='Technology Partner');
        INSERT acc1;
        
        User sysAdmin = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
            LastName = 'last',
            Email = 'lastuser000@zscaler.com',
            Username = 'lastuser000@zscaler.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
        );
        
        INSERT sysAdmin;
        
        Opportunity opp = new Opportunity(Name = 'Test opportunity', Opportunity_Channel_Manager__c = sysAdmin.Id, AccountId = acc.Id, StageName = label.Stage_1_Alignment, CloseDate = system.Today()+30);
        INSERT opp;
        
        Opportunity_Partner__c OppPartner = new Opportunity_Partner__c(Is_Primary__c = false,Opportunity__c = opp.Id,Partner_Type__c = 'Influence Partner',Account__c = acc.Id);
        INSERT OppPartner;
        
    }
    
    @IsTest
    private static void testDescribePicklistEntries() {
        TeamingTechPartnerComponentController.describePicklistEntries();
    }
    
    @IsTest
    private static void testCreateOpportunityPartners() {
        TeamingTechPartnerComponentController.OpportunityPartnerWrapper wrapper = 
            new TeamingTechPartnerComponentController.OpportunityPartnerWrapper();
        
        List<TeamingTechPartnerComponentController.OpportunityPartnerWrapper> wrapperList = 
            new List<TeamingTechPartnerComponentController.OpportunityPartnerWrapper>();
        
        Opportunity opp = [SELECT Id, AccountId FROM Opportunity LIMIT 1];
        
        wrapper.activityType = new List<String> {'Test'};
        wrapper.recordId = opp.Id;
        wrapper.technologyPartnerAccount = [SELECT Id FROM Account WHERE Name = 'Test Account1' LIMIT 1].Id;
        wrapperList.add(wrapper);
        
        TeamingTechPartnerComponentController.createOpportunityPartners(wrapperList);
        
    }
    
    @IsTest
    private static void testCreateOpportunityPartnersNegative() {
        TeamingTechPartnerComponentController.OpportunityPartnerWrapper wrapper = 
            new TeamingTechPartnerComponentController.OpportunityPartnerWrapper();
        
        List<TeamingTechPartnerComponentController.OpportunityPartnerWrapper> wrapperList = 
            new List<TeamingTechPartnerComponentController.OpportunityPartnerWrapper>();
        
        Opportunity opp = [SELECT Id, AccountId FROM Opportunity LIMIT 1];
        
        wrapper.activityType = new List<String> {'Test'};
        wrapper.recordId = opp.Id;
        wrapper.technologyPartnerAccount = opp.AccountId;
        wrapperList.add(wrapper);
        
        try{
            TeamingTechPartnerComponentController.createOpportunityPartners(wrapperList);
        } catch(System.Exception e) {
            System.debug('-=- e.getMessage() -=- '+e.getMessage());
            System.assert(String.isNotBlank(e.getMessage()));
        }
        

        
    }
    
    
    
    @IsTest
    private static void testUpdateOpportunityPartners() {
        TeamingTechPartnerComponentController.OpportunityPartnerWrapper wrapper = 
            new TeamingTechPartnerComponentController.OpportunityPartnerWrapper();
        
        List<TeamingTechPartnerComponentController.OpportunityPartnerWrapper> wrapperList = 
            new List<TeamingTechPartnerComponentController.OpportunityPartnerWrapper>();
        
        Opportunity opp = [SELECT Id, AccountId FROM Opportunity LIMIT 1];
        
        wrapper.activityType = new List<String> {'Test'};
        wrapper.recordId = opp.Id;
        wrapper.technologyPartnerAccount = [SELECT Id FROM Account WHERE Name = 'Test Account1' LIMIT 1].Id;
        wrapperList.add(wrapper);
        
        TeamingTechPartnerComponentController.createOpportunityPartners(wrapperList);
        List<Opportunity_Partner__c> oppPartnerList = [SELECT Id FROM Opportunity_Partner__c LIMIT 1];
        
        System.debug('-=- oppPartnerList -=- '+oppPartnerList);
        oppPartnerList.get(0).Approval_Status__c = 'Approved';
        oppPartnerList.get(0).Partner_Type__c = 'Influence Partner';
        
        UPDATE oppPartnerList;
        
        oppPartnerList = [SELECT Id FROM Opportunity_Partner__c LIMIT 1];
		        
        oppPartnerList.get(0).Approval_Status__c = 'Approved';
        oppPartnerList.get(0).Partner_Type__c = 'Influence Partner';
        
        UPDATE oppPartnerList;
        
        
        
        //For deleting
        
        List<Opportunity_Partner__c> oppPartList = TeamingTechPartnerComponentController.fetchTeamingTechPartners(opp.Id);    
        
        TeamingTechPartnerComponentController.deleteTeamingTechPartners(oppPartList.get(0).Id); 
        
    }
    
    
    
    
}