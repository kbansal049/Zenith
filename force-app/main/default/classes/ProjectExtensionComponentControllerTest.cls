/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* ProjectExtensionComponentControllerTest
* @description    This class is the test class for ProjectExtensionComponentController
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Chandan Panigrahy
* @modifiedBy     Chandan Panigrahy
* @maintainedBy   Chandan Panigrahy
* @version        1.0
* @created        2022-02-09
* @modified       
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* vX.X            Developer Name
* YYYY-MM-DD      Explanation of the change.  Multiple lines can be used to explain the change, but
*                 each line should be indented till left aligned with the previous description text.
*
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
**/

@IsTest
private class ProjectExtensionComponentControllerTest {
    @isTest
    static void inspireProjectUpdate (){
        Test.startTest();
        User testUser = new User();
        testUser.LastName = 'Test LastName';
        testUser.email = 'rberi@zscaler.com';
        testUser.Alias = 'myAlias';
        testUser.EmailEncodingKey = 'UTF-8';
        testUser.LanguageLocaleKey = 'en_US';
        testUser.LocaleSidKey = 'en_US';
        testUser.TimeZoneSidKey = 'America/Los_Angeles';
        testUser.UserName = 'abctest3012021@zscaler.com.invalid';
        testUser.profileId = [SELECT Id FROM Profile WHERE Name='System Administrator'].Id;
        INSERT testUser;
        System.runAs(testUser){
            TriggerHandler.bypass('AccountTriggerHandler');
            Account testAccount = new Account();
            testAccount.Name = 'Test Account';
            INSERT testAccount;
            
            AccountTeamMember atm = new AccountTeamMember ();
            atm.AccountId = testAccount.Id;
            atm.UserId    = testUser.Id;
            atm.TeamMemberRole = 'Customer Success Manager';
            INSERT atm;
            
            List<PatchTeam__c> patchTeamList = new List<PatchTeam__c> ();
            
            PatchTeam__c pateam1 = new PatchTeam__c();
            pateam1.Name = 'patchteam';
            pateam1.Theater__c='APJ';
            pateam1.Region__c ='US West';
            pateam1.Area__c ='APJ';
            pateam1.Territory_Type__c ='Channel';
            patchTeamList.add(pateam1);
            
            PatchTeam__c pateam2 = new PatchTeam__c();
            pateam2.Name = 'patchteam';
            pateam2.Theater__c='EMEA';
            pateam2.Region__c ='US West';
            pateam2.Area__c ='EMEA';
            pateam2.Territory_Type__c ='Channel';
            patchTeamList.add(pateam2);
            
            PatchTeam__c pateam = new PatchTeam__c();
            pateam.Name = 'patchteam';
            pateam.Theater__c='Americas';
            pateam.Region__c ='US West';
            pateam.Area__c ='Americas';
            pateam.Territory_Type__c ='Channel';
            patchTeamList.add(pateam);
            
            pateam = new PatchTeam__c();
            pateam.Name = 'patchteam';
            pateam.Theater__c='EMEA';
            pateam.Region__c ='US West';
            pateam.Area__c ='US South West';
            pateam.Territory_Type__c ='Channel';
            patchTeamList.add(pateam);
            
            pateam = new PatchTeam__c();
            pateam.Name = 'patchteam';
            pateam.Theater__c='WW Enterprise';
            pateam.Region__c ='US West';
            pateam.Area__c ='APJ ENT';
            pateam.Territory_Type__c ='Channel';
            patchTeamList.add(pateam);
            
            pateam = new PatchTeam__c();
            pateam.Name = 'patchteam';
            pateam.Theater__c='WW Enterprise';
            pateam.Region__c ='US West';
            pateam.Area__c ='AMS Enterprise';
            pateam.Territory_Type__c ='Channel';
            patchTeamList.add(pateam);
            
            pateam = new PatchTeam__c();
            pateam.Name = 'patchteam';
            pateam.Theater__c='WW Enterprise';
            pateam.Region__c ='US West';
            pateam.Area__c ='EMEA ENT';
            pateam.Territory_Type__c ='Channel';
            patchTeamList.add(pateam);
            
            pateam = new PatchTeam__c();
            pateam.Name = 'patchteam';
            pateam.Theater__c='WW Commercial';
            pateam.Region__c ='US West';
            pateam.Area__c ='AMS';
            pateam.Territory_Type__c ='Channel';
            patchTeamList.add(pateam);
            
            pateam = new PatchTeam__c();
            pateam.Name = 'patchteam';
            pateam.Theater__c='WW Commercial';
            pateam.Region__c ='US West';
            pateam.Area__c ='APJ';
            pateam.Territory_Type__c ='Channel';
            patchTeamList.add(pateam);
            
            pateam = new PatchTeam__c();
            pateam.Name = 'patchteam';
            pateam.Theater__c='WW Commercial';
            pateam.Region__c ='US West';
            pateam.Area__c ='EMEA';
            pateam.Territory_Type__c ='Channel';
            patchTeamList.add(pateam);
            
            INSERT patchTeamList;
            
            List<PatchTeamMember__c> patchTeamMemberList = new List<PatchTeamMember__c> ();
            
            PatchTeamMember__c member1 = new PatchTeamMember__c(PatchTeam__c=patchTeamList.get(0).Id, Role__c='acme', User__c=UserInfo.getUserId());
            patchTeamMemberList.add(member1);
            PatchTeamMember__c member2 = new PatchTeamMember__c(PatchTeam__c=patchTeamList.get(1).Id, Role__c='acme', User__c=UserInfo.getUserId());
            patchTeamMemberList.add(member2);
            PatchTeamMember__c member = new PatchTeamMember__c(PatchTeam__c=patchTeamList.get(2).Id, Role__c='acme', User__c=UserInfo.getUserId());
            patchTeamMemberList.add(member);
            member = new PatchTeamMember__c(PatchTeam__c=patchTeamList.get(3).Id, Role__c='acme', User__c=UserInfo.getUserId());
            patchTeamMemberList.add(member);
            member = new PatchTeamMember__c(PatchTeam__c=patchTeamList.get(4).Id, Role__c='acme', User__c=UserInfo.getUserId());
            patchTeamMemberList.add(member);
            
            member = new PatchTeamMember__c(PatchTeam__c=patchTeamList.get(5).Id, Role__c='acme', User__c=UserInfo.getUserId());
            patchTeamMemberList.add(member);
            
            member = new PatchTeamMember__c(PatchTeam__c=patchTeamList.get(6).Id, Role__c='acme', User__c=UserInfo.getUserId());
            patchTeamMemberList.add(member);
            
            member = new PatchTeamMember__c(PatchTeam__c=patchTeamList.get(7).Id, Role__c='acme', User__c=UserInfo.getUserId());
            patchTeamMemberList.add(member);
            
            member = new PatchTeamMember__c(PatchTeam__c=patchTeamList.get(8).Id, Role__c='acme', User__c=UserInfo.getUserId());
            patchTeamMemberList.add(member);
            
            member = new PatchTeamMember__c(PatchTeam__c=patchTeamList.get(9).Id, Role__c='acme', User__c=UserInfo.getUserId());
            patchTeamMemberList.add(member);
            
            INSERT patchTeamMemberList;
            
            
            List<Patch__c> patchList = new List<Patch__c> ();
            
            
            Patch__c patch1 = new Patch__c(PatchName__c='acme', Active__c=true,PatchTeam__c=patchTeamList.get(0).Id);
            
            patchList.add(patch1);
            Patch__c patch2 = new Patch__c(PatchName__c='acme', Active__c=true,PatchTeam__c=patchTeamList.get(1).Id);
            patchList.add(patch2);
            
            Patch__c patch = new Patch__c(PatchName__c='acme', Active__c=true,PatchTeam__c=patchTeamList.get(2).Id);
            patchList.add(patch);
            
            patch = new Patch__c(PatchName__c='acme', Active__c=true,PatchTeam__c=patchTeamList.get(3).Id);
            patchList.add(patch);
            
            patch = new Patch__c(PatchName__c='acme', Active__c=true,PatchTeam__c=patchTeamList.get(4).Id);
            patchList.add(patch);
            
            patch = new Patch__c(PatchName__c='acme', Active__c=true,PatchTeam__c=patchTeamList.get(5).Id);
            patchList.add(patch);
            
            patch = new Patch__c(PatchName__c='acme', Active__c=true,PatchTeam__c=patchTeamList.get(6).Id);
            patchList.add(patch);
            
            patch = new Patch__c(PatchName__c='acme', Active__c=true,PatchTeam__c=patchTeamList.get(7).Id);
            patchList.add(patch);
            
            patch = new Patch__c(PatchName__c='acme', Active__c=true,PatchTeam__c=patchTeamList.get(8).Id);
            patchList.add(patch);
            
            patch = new Patch__c(PatchName__c='acme', Active__c=true,PatchTeam__c=patchTeamList.get(9).Id);
            patchList.add(patch);
            
            
            INSERT patchList;
            
            TriggerHandler.bypass('AccountTriggerHandler');
            List<Account> accList = new List<Account> ();
            
            Account acc = new Account(Name='acme acc');
            
            acc.Patch__c = patchList.get(0).Id;
            acc.PatchLocked__c = true;
            
            accList.add(acc);
            
            Account acc1 = new Account(Name='acme acc1');
            acc1.Patch__c = patchList.get(1).Id;
            acc.PatchLocked__c = true;
            
            accList.add(acc1);
            
            Account acc2 = new Account(Name='acme acc1');
            acc2.Patch__c = patchList.get(2).Id;
            acc2.PatchLocked__c = true;
            
            accList.add(acc2);
            
            acc2 = new Account(Name='acme acc1');
            acc2.Patch__c = patchList.get(3).Id;
            acc2.PatchLocked__c = true;
            
            accList.add(acc2);
            
            acc2 = new Account(Name='acme acc1');
            acc2.Patch__c = patchList.get(4).Id;
            acc2.PatchLocked__c = true;
            
            accList.add(acc2);
            
            
            
            
            acc2 = new Account(Name='acme acc1');
            acc2.Patch__c = patchList.get(5).Id;
            acc2.PatchLocked__c = true;
            
            accList.add(acc2);
            
            
            acc2 = new Account(Name='acme acc1');
            acc2.Patch__c = patchList.get(6).Id;
            acc2.PatchLocked__c = true;
            
            accList.add(acc2);
            
            
            
            acc2 = new Account(Name='acme acc1');
            acc2.Patch__c = patchList.get(7).Id;
            acc2.PatchLocked__c = true;
            
            accList.add(acc2);
            
            
            
            acc2 = new Account(Name='acme acc1');
            acc2.Patch__c = patchList.get(8).Id;
            acc2.PatchLocked__c = true;
            
            accList.add(acc2);
            
            
            acc2 = new Account(Name='acme acc1');
            acc2.Patch__c = patchList.get(9).Id;
            acc2.PatchLocked__c = true;
            
            accList.add(acc2);
            
            INSERT accList;
            TriggerHandler.bypass('OpportunityTriggerHandler');
            List<Opportunity> relatedOppList = new List<Opportunity> ();
            
            Opportunity relatedOpportunity = new Opportunity();
            relatedOpportunity.Name = 'Test Opportunity';
            relatedOpportunity.StageName ='1 - Discovery & Qualification';
            relatedOpportunity.CloseDate = Date.today();
            relatedOpportunity.AccountId = accList.get(0).Id;
            
            relatedOppList.add(relatedOpportunity);
            
            Opportunity relatedOpportunity1 = new Opportunity();
            relatedOpportunity1.Name = 'Test Opportunity';
            relatedOpportunity1.StageName ='1 - Discovery & Qualification';
            relatedOpportunity1.CloseDate = Date.today();
            relatedOpportunity1.AccountId = accList.get(1).Id;
            
            relatedOppList.add(relatedOpportunity1);
            
            Opportunity relatedOpportunity2 = new Opportunity();
            relatedOpportunity2.Name = 'Test Opportunity';
            relatedOpportunity2.StageName ='1 - Discovery & Qualification';
            relatedOpportunity2.CloseDate = Date.today();
            relatedOpportunity2.AccountId = accList.get(2).Id;
            
            relatedOppList.add(relatedOpportunity2);
            
            relatedOpportunity2 = new Opportunity();
            relatedOpportunity2.Name = 'Test Opportunity';
            relatedOpportunity2.StageName ='1 - Discovery & Qualification';
            relatedOpportunity2.CloseDate = Date.today();
            relatedOpportunity2.AccountId = accList.get(3).Id;
            
            relatedOppList.add(relatedOpportunity2);
            
            relatedOpportunity2 = new Opportunity();
            relatedOpportunity2.Name = 'Test Opportunity';
            relatedOpportunity2.StageName ='1 - Discovery & Qualification';
            relatedOpportunity2.CloseDate = Date.today();
            relatedOpportunity2.AccountId = accList.get(4).Id;
            
            relatedOppList.add(relatedOpportunity2);
            
            
            relatedOpportunity2 = new Opportunity();
            relatedOpportunity2.Name = 'Test Opportunity';
            relatedOpportunity2.StageName ='1 - Discovery & Qualification';
            relatedOpportunity2.CloseDate = Date.today();
            relatedOpportunity2.AccountId = accList.get(5).Id;
            
            relatedOppList.add(relatedOpportunity2);
            
            relatedOpportunity2 = new Opportunity();
            relatedOpportunity2.Name = 'Test Opportunity';
            relatedOpportunity2.StageName ='1 - Discovery & Qualification';
            relatedOpportunity2.CloseDate = Date.today();
            relatedOpportunity2.AccountId = accList.get(6).Id;
            
            relatedOppList.add(relatedOpportunity2);
            
            relatedOpportunity2 = new Opportunity();
            relatedOpportunity2.Name = 'Test Opportunity';
            relatedOpportunity2.StageName ='1 - Discovery & Qualification';
            relatedOpportunity2.CloseDate = Date.today();
            relatedOpportunity2.AccountId = accList.get(7).Id;
            
            relatedOppList.add(relatedOpportunity2);
            
            relatedOpportunity2 = new Opportunity();
            relatedOpportunity2.Name = 'Test Opportunity';
            relatedOpportunity2.StageName ='1 - Discovery & Qualification';
            relatedOpportunity2.CloseDate = Date.today();
            relatedOpportunity2.AccountId = accList.get(8).Id;
            
            relatedOppList.add(relatedOpportunity2);
            
            relatedOpportunity2 = new Opportunity();
            relatedOpportunity2.Name = 'Test Opportunity';
            relatedOpportunity2.StageName ='1 - Discovery & Qualification';
            relatedOpportunity2.CloseDate = Date.today();
            relatedOpportunity2.AccountId = accList.get(9).Id;
            
            relatedOppList.add(relatedOpportunity2);
            
            INSERT relatedOppList;
            
            
            
            
            
            Id RecordTypeIdProject = Schema.SObjectType.inspire1__Project__c.RecordTypeInfosByName.get('Deployment Project').RecordTypeId;
            
            List<Inspire1__Project__c> projectList = new List<Inspire1__Project__c> ();
            
            Inspire1__Project__c newProject = new Inspire1__Project__c();
            newProject.Name = 'Test Project';
            newProject.inspire1__Account__c = testAccount.Id;
            newProject.RecordTypeId = RecordTypeIdProject ;
            newProject.Opportunity__c = relatedOppList.get(0).Id;
            
            projectList.add(newProject);
            
            newProject = new Inspire1__Project__c();
            newProject.Name = 'Test Project0';
            newProject.inspire1__Account__c = accList.get(1).Id;
            newProject.RecordTypeId = RecordTypeIdProject ;
            newProject.Opportunity__c = relatedOppList.get(1).Id;
            projectList.add(newProject);
            
            
            
            newProject = new Inspire1__Project__c();
            newProject.Name = 'Test Project1';
            newProject.inspire1__Account__c = accList.get(2).Id;
            newProject.RecordTypeId = RecordTypeIdProject ;
            newProject.Opportunity__c = relatedOppList.get(2).Id;
            projectList.add(newProject);
            
            newProject = new Inspire1__Project__c();
            newProject.Name = 'Test Project2';
            newProject.inspire1__Account__c = accList.get(1).Id;
            newProject.Opportunity__c = relatedOppList.get(3).Id;
            newProject.RecordTypeId = RecordTypeIdProject ;
            
            projectList.add(newProject);
            
            newProject = new Inspire1__Project__c();
            newProject.Name = 'Test Project3';
            newProject.inspire1__Account__c = accList.get(3).Id;
            newProject.Opportunity__c = relatedOppList.get(4).Id;
            newProject.RecordTypeId = RecordTypeIdProject;
            
            projectList.add(newProject);
            
            newProject = new Inspire1__Project__c();
            newProject.Name = 'Test Project3';
            newProject.inspire1__Account__c = accList.get(3).Id;
            newProject.Opportunity__c = relatedOppList.get(5).Id;
            newProject.RecordTypeId = RecordTypeIdProject;
            
            projectList.add(newProject);
            
            newProject = new Inspire1__Project__c();
            newProject.Name = 'Test Project3';
            newProject.inspire1__Account__c = accList.get(3).Id;
            newProject.Opportunity__c = relatedOppList.get(6).Id;
            newProject.RecordTypeId = RecordTypeIdProject;
            
            projectList.add(newProject);
            
            newProject = new Inspire1__Project__c();
            newProject.Name = 'Test Project3';
            newProject.inspire1__Account__c = accList.get(3).Id;
            newProject.Opportunity__c = relatedOppList.get(7).Id;
            newProject.RecordTypeId = RecordTypeIdProject;
            
            projectList.add(newProject);
            
            newProject = new Inspire1__Project__c();
            newProject.Name = 'Test Project3';
            newProject.inspire1__Account__c = accList.get(3).Id;
            newProject.Opportunity__c = relatedOppList.get(8).Id;
            newProject.RecordTypeId = RecordTypeIdProject;
            
            projectList.add(newProject);
            
            newProject = new Inspire1__Project__c();
            newProject.Name = 'Test Project3';
            newProject.inspire1__Account__c = accList.get(3).Id;
            newProject.Opportunity__c = relatedOppList.get(9).Id;
            newProject.RecordTypeId = RecordTypeIdProject;
            
            projectList.add(newProject);
            
            INSERT projectList;
            
            List<Professional_Service_Project__c> pspList = new List<Professional_Service_Project__c> ();
            
            Professional_Service_Project__c psp = new Professional_Service_Project__c();
            psp.Name = 'Test psp';
            psp.Extension_Type__c = '';
            psp.Account__c = accList.get(0).Id;
            psp.Opportunity__c = relatedOppList.get(0).Id;
            
            pspList.add(psp);
            
            psp = new Professional_Service_Project__c();
            psp.Name = 'Test psp';
            psp.Extension_Type__c = '';
            psp.Account__c = accList.get(1).Id;
            psp.Opportunity__c = relatedOppList.get(1).Id;
            
            pspList.add(psp);
            
            psp = new Professional_Service_Project__c();
            psp.Name = 'Test psp';
            psp.Extension_Type__c = '';
            psp.Account__c = accList.get(3).Id;
            psp.Opportunity__c = relatedOppList.get(3).Id;
            
            pspList.add(psp);
            
            psp = new Professional_Service_Project__c();
            psp.Name = 'Test psp';
            psp.Extension_Type__c = '';
            psp.Account__c = accList.get(3).Id;
            psp.Opportunity__c = relatedOppList.get(4).Id;
            
            pspList.add(psp);
            
            
            
            
            psp = new Professional_Service_Project__c();
            psp.Name = 'Test psp';
            psp.Extension_Type__c = '';
            psp.Account__c = accList.get(3).Id;
            psp.Opportunity__c = relatedOppList.get(5).Id;
            
            pspList.add(psp);
            
            
            psp = new Professional_Service_Project__c();
            psp.Name = 'Test psp';
            psp.Extension_Type__c = '';
            psp.Account__c = accList.get(3).Id;
            psp.Opportunity__c = relatedOppList.get(6).Id;
            
            pspList.add(psp);
            
            
            psp = new Professional_Service_Project__c();
            psp.Name = 'Test psp';
            psp.Extension_Type__c = '';
            psp.Account__c = accList.get(3).Id;
            psp.Opportunity__c = relatedOppList.get(7).Id;
            
            pspList.add(psp);
            
            
            psp = new Professional_Service_Project__c();
            psp.Name = 'Test psp';
            psp.Extension_Type__c = '';
            psp.Account__c = accList.get(3).Id;
            psp.Opportunity__c = relatedOppList.get(8).Id;
            
            pspList.add(psp);
            
            
            psp = new Professional_Service_Project__c();
            psp.Name = 'Test psp';
            psp.Extension_Type__c = '';
            psp.Account__c = accList.get(3).Id;
            psp.Opportunity__c = relatedOppList.get(9).Id;
            
            pspList.add(psp);
            
            
            INSERT pspList;
            
            List<PS_Extension__c> psExtList = new List<PS_Extension__c> ();
            
            
            PS_Extension__c psExtension = new PS_Extension__c();
            psExtension.Project__c = projectList.get(0).Id;
            psExtension.Extension_Type__c = '';
            psExtension.Approval_Status__c = 'Not started';
            
            psExtList.add(psExtension);
            
            
            psExtension = new PS_Extension__c();
            psExtension.Project__c = projectList.get(1).Id;
            psExtension.Extension_Type__c = '';
            psExtension.Approval_Status__c = 'Not started';
            
            psExtList.add(psExtension);
            
            psExtension = new PS_Extension__c();
            psExtension.Project__c = projectList.get(2).Id;
            psExtension.Extension_Type__c = '';
            psExtension.Approval_Status__c = 'Not started';
            
            psExtList.add(psExtension);
            
            psExtension = new PS_Extension__c();
            psExtension.Project__c = projectList.get(3).Id;
            psExtension.Extension_Type__c = '';
            psExtension.Approval_Status__c = 'Not started';
            
            psExtList.add(psExtension);
            
            psExtension = new PS_Extension__c();
            psExtension.Project__c = projectList.get(4).Id;
            psExtension.Extension_Type__c = '';
            psExtension.Approval_Status__c = 'Not started';
            
            psExtList.add(psExtension);
            
            psExtension = new PS_Extension__c();
            psExtension.Project__c = projectList.get(5).Id;
            psExtension.Extension_Type__c = '';
            psExtension.Approval_Status__c = 'Not started';
            
            psExtList.add(psExtension);
            
            psExtension = new PS_Extension__c();
            psExtension.Project__c = projectList.get(6).Id;
            psExtension.Extension_Type__c = '';
            psExtension.Approval_Status__c = 'Not started';
            
            psExtList.add(psExtension);
            
            psExtension = new PS_Extension__c();
            psExtension.Project__c = projectList.get(7).Id;
            psExtension.Extension_Type__c = '';
            psExtension.Approval_Status__c = 'Not started';
            
            psExtList.add(psExtension);
            
            psExtension = new PS_Extension__c();
            psExtension.Project__c = projectList.get(8).Id;
            psExtension.Extension_Type__c = '';
            psExtension.Approval_Status__c = 'Not started';
            
            psExtList.add(psExtension);
            
            psExtension = new PS_Extension__c();
            psExtension.Professional_Service_Project__c = pspList.get(0).Id;
            psExtension.Extension_Type__c = '';
            psExtension.Approval_Status__c = 'Not started';
            
            psExtList.add(psExtension);
            
            psExtension = new PS_Extension__c();
            psExtension.Professional_Service_Project__c = pspList.get(1).Id;
            psExtension.Extension_Type__c = '';
            psExtension.Approval_Status__c = 'Not started';
            
            psExtList.add(psExtension);
            
            psExtension = new PS_Extension__c();
            psExtension.Professional_Service_Project__c = pspList.get(2).Id;
            psExtension.Extension_Type__c = '';
            psExtension.Approval_Status__c = 'Not started';
            
            psExtList.add(psExtension);
            
            psExtension = new PS_Extension__c();
            psExtension.Professional_Service_Project__c = pspList.get(3).Id;
            psExtension.Extension_Type__c = '';
            psExtension.Approval_Status__c = 'Not started';
            
            psExtList.add(psExtension);
            
            psExtension = new PS_Extension__c();
            psExtension.Professional_Service_Project__c = pspList.get(4).Id;
            psExtension.Extension_Type__c = '';
            psExtension.Approval_Status__c = 'Not started';
            
            psExtList.add(psExtension);
            
            psExtension = new PS_Extension__c();
            psExtension.Professional_Service_Project__c = pspList.get(5).Id;
            psExtension.Extension_Type__c = '';
            psExtension.Approval_Status__c = 'Not started';
            
            psExtList.add(psExtension);
            
            psExtension = new PS_Extension__c();
            psExtension.Professional_Service_Project__c = pspList.get(6).Id;
            psExtension.Extension_Type__c = '';
            psExtension.Approval_Status__c = 'Not started';
            
            psExtList.add(psExtension);
            
            psExtension = new PS_Extension__c();
            psExtension.Professional_Service_Project__c = pspList.get(7).Id;
            psExtension.Extension_Type__c = '';
            psExtension.Approval_Status__c = 'Not started';
            
            psExtList.add(psExtension);
            
            psExtension = new PS_Extension__c();
            psExtension.Professional_Service_Project__c = pspList.get(8).Id;
            psExtension.Extension_Type__c = '';
            psExtension.Approval_Status__c = 'Not started';
            
            psExtList.add(psExtension);
            
            INSERT psExtList;
            
            ProjectExtensionComponentController instance = ProjectExtensionComponentController.getInstance();
            instance.getProjectExtList();
        }
        Test.stopTest();
    }
    @isTest
    static void testmethod2(){
        Id RecordTypeIdProject = Schema.SObjectType.inspire1__Project__c.RecordTypeInfosByName.get('Deployment Project').RecordTypeId;
        
        PatchTeam__c pateam11 = new PatchTeam__c();
        pateam11.Name = 'patchteam';
        pateam11.Theater__c='WW Enterprise';
        pateam11.Region__c ='US West';
        pateam11.Area__c ='EMEA Enterprise';
        pateam11.Territory_Type__c ='Channel';
        
        insert pateam11;
        
        Account acc20 = new Account(Name='acme acc20');
        INSERT acc20;
        
        
        Opportunity relatedOpportunity11 = new Opportunity();
        relatedOpportunity11.Name = 'Test Opportunity';
        relatedOpportunity11.StageName ='1 - Discovery & Qualification';
        relatedOpportunity11.CloseDate = Date.today();
        relatedOpportunity11.AccountId = acc20.Id;
        
        insert relatedOpportunity11;
        
        Inspire1__Project__c newProject11 = new Inspire1__Project__c();
        newProject11.Name = 'Test Project';
        newProject11.inspire1__Account__c = acc20.Id;
        newProject11.RecordTypeId = RecordTypeIdProject ;
        newProject11.Opportunity__c = relatedOpportunity11.Id;
        insert newProject11;
        
        PS_Extension__c psExtension11 = new PS_Extension__c();
        psExtension11.Project__c = newProject11.Id;
        psExtension11.Extension_Type__c = '30 Days';
        psExtension11.Approval_Status__c = 'Not started';
        insert psExtension11;
        
        Test.startTest();
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
    	req1.setComments('Submitting request for approval.');
    	req1.setObjectId(psExtension11.Id);
    	req1.setNextApproverIds(new Id[] {UserInfo.getUserId()});
    	
    	//Submit the approval request for the change
    	Approval.ProcessResult result = Approval.process(req1);
    	
    	List<Id> newWorkItemIds = result.getNewWorkItemIds();
    	
    	//Instantiate the new ProcessWorkItemRequest object and populate it
    	Approval.ProcessWorkItemRequest req2 = new Approval.ProcessWorkItemRequest();
    	req2.setComments('Approving request.');
    	req2.setAction('Reject');
    	req2.setNextApproverIds(new Id[] {UserInfo.getUserId()});
    	
    	//Use the ID from the newly created item to specify the item to be worked
    	req2.setWorkItemId(newWorkItemIds.get(0));
    	
    	//Submit the request for approval
    	Approval.ProcessResult result2 = Approval.process(req2);

        Test.stopTest();
    }
}