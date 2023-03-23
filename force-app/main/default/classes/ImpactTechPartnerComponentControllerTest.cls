@isTest
private with sharing class ImpactTechPartnerComponentControllerTest {
    @testSetup static void setup() {
        TriggerUtility.SkipAccTriggerExecuted();
        TriggerUtility.SkipOppTriggerExecuted();
        
        
        Account acc1 = new Account(Name = 'Test Account1', Tech_Partner_Referral_Agreement__c = 'Impact', Type='Technology Partner');
        INSERT acc1;
        
        Contact con = new Contact(LastName = 'Test', AccountId = acc1.Id, Email = 'test@test.com');
        insert con;

        Account_Extension__c accExt = new Account_Extension__c(Tech_Partner_Primary_Contact__c = con.id, Account__c = acc1.Id);
        INSERT accExt;

        Account acc = new Account(Name = 'Test Account', TAM_Email__c = 'abc@abc.com',Area_Director__c=Userinfo.getUserId(),Type='Technology Partner',Partner_Type__c='Technology Partner');
        INSERT acc;
        
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

        OpportunityTeamMember oppTeamMem = new OpportunityTeamMember(OpportunityId = opp.Id, UserId = sysAdmin.Id , TeamMemberRole = 'Geo VP');
        INSERT oppTeamMem;
        
        Opportunity_Partner__c OppPartner = new Opportunity_Partner__c(Is_Primary__c = false,Opportunity__c = opp.Id,Partner_Type__c = 'Impact Partner',Account__c = acc.Id);
        INSERT OppPartner;
        
    }
    
    // @IsTest
    // private static void testDescribePicklistEntries() {
    //     TeamingTechPartnerComponentController.describePicklistEntries();
    // }
    
    @IsTest
    private static void testCreateOpportunityPartners() {
        ImpactTechPartnerComponentController.OpportunityPartnerWrapper wrapper = 
            new ImpactTechPartnerComponentController.OpportunityPartnerWrapper();
        
        List<ImpactTechPartnerComponentController.OpportunityPartnerWrapper> wrapperList = 
            new List<ImpactTechPartnerComponentController.OpportunityPartnerWrapper>();
        
        Opportunity opp = [SELECT Id, AccountId FROM Opportunity LIMIT 1];
        Account acc = [SELECT Id FROM Account WHERE Name = 'Test Account1' LIMIT 1];
        Account_Extension__c accExt = [SELECT Id,Tech_Partner_Primary_Contact__c FROM Account_Extension__c WHERE Account__c =: acc.Id LIMIT 1];

       // Account acc = [SELECT Id FROM Opportunity LIMIT 1];
        
        wrapper.partnerRepEmail = 'Test@t.com';
        wrapper.recordId = opp.Id;
        
        wrapper.impactPartnerAccount = acc.Id;
        wrapper.partnerRepName = 'Test';
        wrapper.impactPartnerContact = accExt.Tech_Partner_Primary_Contact__c;
        wrapperList.add(wrapper);
        
        ImpactTechPartnerComponentController.createOpportunityPartners(wrapperList);
        
    }
    
    // @IsTest
    // private static void testCreateOpportunityPartnersNegative() {
    //     TeamingTechPartnerComponentController.OpportunityPartnerWrapper wrapper = 
    //         new TeamingTechPartnerComponentController.OpportunityPartnerWrapper();
        
    //     List<TeamingTechPartnerComponentController.OpportunityPartnerWrapper> wrapperList = 
    //         new List<TeamingTechPartnerComponentController.OpportunityPartnerWrapper>();
        
    //     Opportunity opp = [SELECT Id, AccountId FROM Opportunity LIMIT 1];
        
    //     wrapper.activityType = new List<String> {'Test'};
    //     wrapper.recordId = opp.Id;
    //     wrapper.technologyPartnerAccount = opp.AccountId;
    //     wrapperList.add(wrapper);
        
    //     try{
    //         TeamingTechPartnerComponentController.createOpportunityPartners(wrapperList);
    //     } catch(System.Exception e) {
    //         System.debug('-=- e.getMessage() -=- '+e.getMessage());
    //         System.assert(String.isNotBlank(e.getMessage()));
    //     }
        

        
    // }
    
    
    
    @IsTest
    private static void testUpdateOpportunityPartners() {
        ImpactTechPartnerComponentController.OpportunityPartnerWrapper wrapper = 
            new ImpactTechPartnerComponentController.OpportunityPartnerWrapper();
        
        List<ImpactTechPartnerComponentController.OpportunityPartnerWrapper> wrapperList = 
            new List<ImpactTechPartnerComponentController.OpportunityPartnerWrapper>();
        
            Opportunity opp = [SELECT Id, AccountId FROM Opportunity LIMIT 1];
        Account acc = [SELECT Id FROM Account WHERE Name = 'Test Account1' LIMIT 1];
        //Account_Extension__c accExt = [SELECT Id, Tech_Partner_Primary_Contact__c FROM Account_Extension__c WHERE Account__c =: acc.Id LIMIT 1];
        Account_Extension__c accExt = ImpactTechPartnerComponentController.getPrimaryContacts(acc.Id);

       // Account acc = [SELECT Id FROM Opportunity LIMIT 1];
        
        wrapper.partnerRepEmail = 'Test@t.com';
        wrapper.recordId = opp.Id;
        
        wrapper.impactPartnerAccount = acc.Id;
        wrapper.partnerRepName = 'Test';
        wrapper.impactPartnerContact = accExt.Tech_Partner_Primary_Contact__c;
        wrapperList.add(wrapper);
        
        ImpactTechPartnerComponentController.createOpportunityPartners(wrapperList);

        List<Opportunity_Partner__c> oppPartnerList = [SELECT Id FROM Opportunity_Partner__c LIMIT 1];
        
        System.debug('-=- oppPartnerList -=- '+oppPartnerList);
        oppPartnerList.get(0).Approval_Status__c = 'Invited';
        //oppPartnerList.get(0).Partner_Type__c = 'Influence Partner';
        
        UPDATE oppPartnerList;
        
        oppPartnerList = [SELECT Id FROM Opportunity_Partner__c LIMIT 1];
        oppPartnerList.get(0).MEDDPICC_Activity_Type__c = 'M - partner helped identify and understand the customer METRICS that matter?';
        //ImpactTechPartnerComponentController.updateOppotunityPartnerToImpact(oppPartnerList.get(0).id);

		        
        String status = 'Completed';
        oppPartnerList.get(0).Partner_Type__c = 'Impact Partner';
        
        UPDATE oppPartnerList;
        ImpactTechPartnerComponentController.updateStatus(oppPartnerList[0].Id, status);
        ImpactTechPartnerComponentController.updateOppotunityPartnerToImpact(oppPartnerList[0].Id);
        
        
        
        
       
         ImpactTechPartnerComponentController.fetchImpactTechPartners(opp.Id);
         ImpactTechPartnerComponentController.findLoggedInUserProfile(opp.Id);
        /*
        opp = [SELECT Secondary_Partner__c FROM Opportunity WHERE Id = :opp.Id];
        Opportunity_Partner__c oppPartner = [SELECT Account__c FROM Opportunity_Partner__c where Id = :oppPartnerList[0].Id];
         System.assertEquals(opp.Secondary_Partner__c, oppPartner.Account__c);
         System.assertEquals(oppPartnerList[0]., oppPartnerList[0].Account__c);
        */

    }
}