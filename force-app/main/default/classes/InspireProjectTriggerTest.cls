@isTest
private class InspireProjectTriggerTest {
    
    private static Id deploymentProjectRecordTypeId = Schema.SObjectType.inspire1__Project__c.getRecordTypeInfosByDeveloperName().get('Deployment_Project').getRecordTypeId();
    @testSetup  static void setupdata(){
        
        Skip_Triggers__c skipTriggers = new Skip_Triggers__c();
        skipTriggers.Skip_Account_Triggers__c = true;
        skipTriggers.Skip_Opportunity_Triggers__c = true;
        skipTriggers.Name = 'SkipTriggers';
        INSERT skipTriggers;
        
        List<Triggers_Switch__c> trlst = new List<Triggers_Switch__c>();
        Triggers_Switch__c tr1 = new Triggers_Switch__c(name = 'Execute_Project_Trigger', Execute__c = true);
        Triggers_Switch__c tr2 = new Triggers_Switch__c(name = 'Execute_SendEmail_Project_Trigger', Execute__c = true);
        Triggers_Switch__c tr3 = new Triggers_Switch__c(name = 'Execute_Fill_Summary_Notes_Dates', Execute__c = true);//Added by Varun - CR 1069
        trlst.add(tr1);
        trlst.add(tr2);
        trlst.add(tr3);
        INSERT trlst;
        
    }     
    
    
    @isTest
    static void inspireProjectUpdate (){
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
        
        TriggerHandler.bypass('AccountTriggerHandler');
        TriggerHandler.bypass('OpportunityTriggerHandler');

        System.runAs(testUser){
            Account testAccount = new Account();
            testAccount.Name = 'Test Account';
            INSERT testAccount;
            
            AccountTeamMember atm = new AccountTeamMember ();
            atm.AccountId = testAccount.Id;
            atm.UserId    = testUser.Id;
            atm.TeamMemberRole = 'Customer Success Manager';
            INSERT atm;
            
            Opportunity relatedOpportunity = new Opportunity();
            relatedOpportunity.Name = 'Test Opportunity';
            relatedOpportunity.StageName ='1 - Discovery & Qualification';
            relatedOpportunity.CloseDate = date.today();
            INSERT relatedOpportunity;
            
            Id RecordTypeIdProject = Schema.SObjectType.inspire1__Project__c.RecordTypeInfosByName.get('Deployment Project').RecordTypeId;
            
            List<Inspire1__Project__c> projectList = new List<Inspire1__Project__c> ();
            
            Inspire1__Project__c newProject = new Inspire1__Project__c();
            newProject.Name = 'Test Project';
            newProject.inspire1__Account__c = testAccount.Id;
            newProject.RecordTypeId = RecordTypeIdProject ;
            newProject.Opportunity__c = relatedOpportunity.Id;
            
            projectList.add(newProject);
            
            newProject = new Inspire1__Project__c();
            newProject.Name = 'Test Project';
            newProject.inspire1__Account__c = testAccount.Id;
            newProject.RecordTypeId = RecordTypeIdProject ;
            
            projectList.add(newProject);
            
            
            INSERT projectList;
            
            InspireProjectMasterTriggerHandler instance = new InspireProjectMasterTriggerHandler();
            instance.qualifiedUpdate(projectList.get(0), projectList.get(1));
            
        }
        
        
    }
    
    @isTest
    static void early_engagement_should_be_populated_on_project(){
        User userRecord = TestDatafactory_Zscaler.insertAdminUser('dummy1@dummy.com1','test','testdata','testf','test11@asdf1234.com','GMT','en_US','UTF-8','en_US');
        
        System.runAs(userRecord){
            Account accountRecord = TestDatafactory_Zscaler.insertAccount('Test Account1', null, 'Customer', null, null, null);
            Date closeDate = system.today() + 5;
            Opportunity opp = TestDatafactory_Zscaler.insertOpportunity('Test Opp1', false, accountRecord.Id, label.Stage_6_Closed_Won, closeDate, null, null, null, null,null, null, null, null, null, null, true);     
            
            Inspire1__Project__c project = createProject(opp.Id);
            insert project;
            
            Test.startTest();
            
            Map<Id,Inspire1__Project__c> oldProjectIdPojectRecordMap = new Map<Id,Inspire1__Project__c>();
            oldProjectIdPojectRecordMap.put(project.Id, project);
            Map<Id,Inspire1__Project__c> newProjectIdPojectRecordMap = new Map<Id,Inspire1__Project__c>();
            project.Early_Engagements__c = false;
            update project;
            
            newProjectIdPojectRecordMap.put(project.Id, project);
            InspireProjectMasterTriggerService.checkEarlyEngagementsOnProject(oldProjectIdPojectRecordMap,newProjectIdPojectRecordMap);
        }
        Test.stopTest();
        Inspire1__Project__c project =[SELECT id ,Name,Early_Engagements__c FROM Inspire1__Project__c LIMIT 1];
        System.assertEquals(project.Early_Engagements__c, false);
    }
    @isTest
    static void early_engagement_should_not_be_populated_on_project(){
        User userRecord = TestDatafactory_Zscaler.insertAdminUser('dummy1@dummy.com1','test','testdata','testf','test11@asdf1234.com','GMT','en_US','UTF-8','en_US');
        Test.startTest();
        
        System.runAs(userRecord){
            Account accountRecord = TestDatafactory_Zscaler.insertAccount('Test Account1', null, 'Customer', null, null, null);
            Date closeDate = system.today() + 5;
            Opportunity opp = TestDatafactory_Zscaler.insertOpportunity('Test Opp1', false, accountRecord.Id, label.Stage_4_Economic_Buyer_Signoff, closeDate, null, null, null, null,null, null, null, null, null, null, true);
            
            Inspire1__Project__c project = createProject(opp.Id);
            insert project;
            
            Map<Id,Inspire1__Project__c> oldProjectIdPojectRecordMap = new Map<Id,Inspire1__Project__c>();
            oldProjectIdPojectRecordMap.put(project.Id, project);
            Map<Id,Inspire1__Project__c> newProjectIdPojectRecordMap = new Map<Id,Inspire1__Project__c>();
            project.Early_Engagements__c = false;
            update project;
            
            newProjectIdPojectRecordMap.put(project.Id, project);
            InspireProjectMasterTriggerService.checkEarlyEngagementsOnProject(oldProjectIdPojectRecordMap,newProjectIdPojectRecordMap);
            
            Test.stopTest();
            
            Inspire1__Project__c testproject =[SELECT id ,Name,Early_Engagements__c FROM Inspire1__Project__c LIMIT 1];
            System.assertEquals(testproject.Early_Engagements__c, true);
        }        
    }
    
    private static inspire1__Project__c createProject(Id oppId) {
        Inspire1__Project__c project = new Inspire1__Project__c();
        project.name = 'Test project 2';
        project.Opportunity__c = oppId;
        project.Early_Engagements__c = true;
        project.inspire1__Project_Status__c='In Progress';
        project.Action_Plan__c = 'Test Plan';
        project.RecordTypeId = deploymentProjectRecordTypeId;
        
        return project;
   }
}