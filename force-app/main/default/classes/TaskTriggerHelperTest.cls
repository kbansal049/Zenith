@isTest(SeeAllData=false)
public class TaskTriggerHelperTest {

    public static final String TEST_STRING = 'Test';
    public static final String TEST_SDR_EMAIL = 'test.sdr@test.com';

    @testSetup 
    static void prepareTestData() {
        TriggerHandler.bypass('AccountTriggerHandler');
        TriggerHandler.bypass('ContactTriggerHandler');
        TriggerHandler.bypass('LeadTriggerHandler');

        User testSystemAdminUser = ZSL2OTestDataFactory.prepareTestUser(TEST_STRING, 'System Admin', ZScalarConstants.PROFILE_SYSTEM_ADMINISTRATOR, ZScalarConstants.ROLE_IT_BUSINESS_SYSTEMS);
        insert testSystemAdminUser;
        
        System.runAs(testSystemAdminUser) {
            List<PatchTeam__c> testSalesTerritoryList = TestDataFactory_SalesTerritory.prepareTestSalesTerritoryRecords(L2O_Constants.CustomerCreditsObject.PUBLIC_SECTOR_STRING, 1);
            insert testSalesTerritoryList;
            
            Account testAccount = TestDatafactory_Zscaler.insertAccount('Test Account 1', null, null, null, null, null);
            
            Contact testContact = TestDatafactory_Zscaler.insertContact('Test Contact 1', testAccount.Id, null);
            testContact.Territory__c = testSalesTerritoryList[0].Id;
            update testContact;
    
            List<Lead> testLeadsList = TestDataFactory_Lead.prepareTestLeads(L2O_Constants.LeadObject.LEAD_STATUS_ACTIVELY_ENGAGED, '0-99', 'test@test1.com', 
                L2O_Constants.LeadObject.LEAD_SOURCE_ADVERTISEMENT, 1);
            testLeadsList[0].Territory__c = testSalesTerritoryList[0].Id;
            insert testLeadsList;    
        }
        
        TriggerHandler.clearBypass('AccountTriggerHandler');
        TriggerHandler.clearBypass('ContactTriggerHandler');
        TriggerHandler.clearBypass('LeadTriggerHandler');
    }
    
    public static testMethod void testCaptureActivityDetail(){
        Triggers_Switch__c tr1 = new Triggers_Switch__c(name = 'Execute_Task_CampaignMostRecent', Execute__c = true);
        Triggers_Switch__c tr2 = new Triggers_Switch__c(name = 'Execute_ContOrLead_RelatedTask', Execute__c = true);
        insert tr1;
        insert tr2;
        Campaign camp = new Campaign(
                            Name = TEST_STRING,
                            IsActive = TRUE);
        insert camp;
        
        Contact con = new Contact(
                          FirstName = 'Robin',
                          LastName = 'Koehler',
                          Qualifying_SDR__c = UserInfo.getuserId(),
                          Most_Recent_Campaign__c = camp.Id
                          );
        insert con;
        
        Contact con1 = new Contact(
                          FirstName = 'Swathi',
                          LastName = 'Goudar',
                          Qualifying_SDR__c = UserInfo.getuserId(),
                          Most_Recent_Campaign__c = camp.Id
                          );
        insert con1;

        Lead lead=new Lead(LastName='Doe',FirstName='John',Company=TEST_STRING,Status='Inquiry', Most_Recent_Campaign2__c= camp.id,Qualifying_SDR__c=UserInfo.getuserId());
        insert lead;

        CampaignMember m1 = new CampaignMember(
            ContactId = con.Id,
            CampaignId = camp.Id
        );
        insert m1;

        CampaignMember m2 = new CampaignMember(
            LeadId = lead.Id,
            CampaignId = camp.Id
        );
        insert m2;
        
        List<Task> tasks = new List<Task>();
        tasks.add(new Task(
        ActivityDate = Date.today().addDays(7),
        Subject=L2O_Constants.TaskObject.TASK_SUBJECT_CALL,
        WhoId = con.Id,
        OwnerId = UserInfo.getUserId(),
        Status=L2O_Constants.TaskObject.TASK_STATUS_IN_PROGRESS)
        );
        
        tasks.add(new Task(
        ActivityDate = Date.today().addDays(7),
        Subject=L2O_Constants.TaskObject.TASK_SUBJECT_CALL,
        WhoId = lead.Id,
        OwnerId = UserInfo.getUserId(),
        Status=L2O_Constants.TaskObject.TASK_STATUS_IN_PROGRESS)
        );
        
        Test.startTest();
        insert tasks;
        
        TaskRelation relation2 = new TaskRelation();
        relation2.RelationId = con1.Id;
        relation2.TaskId = tasks[0].Id;
        //relation.Type = 'Contact';
        relation2.IsWhat = FALSE;
        insert relation2;
        
        update tasks;
        Set<Id> taskIds = new Set<Id>();
        for(Task task1 : tasks){
            taskIds.add(task1.Id);
        }
        UpdateTaskSDRFieldsbasedOnLeadAndCont SPFQ = new UpdateTaskSDRFieldsbasedOnLeadAndCont(taskIds);
        System.enqueueJob(SPFQ);
        Test.stopTest();
    }

    @isTest
    static void testProcessLeadsForSDRUsers() {
        Task testTask = new Task();
        testTask.Subject = 'Test Task 1';

        User sdrUser;

        System.runAs(new User(Id = UserInfo.getUserId())) {
            UserRole userRole = new UserRole(DeveloperName = 'SDR_TEST_ROLE', Name = 'SDR Test Role');
            insert userRole;
            
            sdrUser = new User(
                ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User'].Id,
                LastName = 'last',
                Email = TEST_SDR_EMAIL,
                Username = TEST_SDR_EMAIL + System.currentTimeMillis(),
                CompanyName = TEST_STRING,
                Title = 'Mr',
                Alias = 'TSDR',
                TimeZoneSidKey = 'America/Los_Angeles',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = ZScalarConstants.LOCALE_EN_US,
                LocaleSidKey = ZScalarConstants.LOCALE_EN_US,
                UserRoleId = userRole.Id
            );

            insert sdrUser;
        }
        
        //User runningUser = [SELECT Id FROM User WHERE UserRole.Name LIKE '%SDR%' LIMIT 1];
        System.runAs(sdrUser) {
            insert testTask;
        }

        Lead testLead = new Lead(LastName = 'Test Lead 1', Company = 'Test Company');
        insert testLead;

        testTask.whoId = testLead.Id;
        update testTask;

        testTask = [SELECT Id, Role_of_Creator_When_Created1__c, WhatId, Status, CreatedById FROM Task WHERE Id = :testTask.Id LIMIT 1];

        Test.startTest();
            TaskTriggerHelper.processLeads(new Map<Id, List<Task>> {testLead.Id => new List<Task> {testTask}});
        Test.stopTest();

        Lead resultLead = [SELECT Id, Qualified_Date__c FROM Lead WHERE Id = :testLead.Id LIMIT 1];
        System.assertEquals(Date.today(), resultLead.Qualified_Date__c, 'The Lead Qualified Date should be today.');
    }

    @isTest
    static void testProcessLeadsWhenTaskStatusNotCompleted() {
        Task testTask = new Task(Subject = 'Test Task 2');
        insert testTask;

        Lead testLead = new Lead(LastName = 'Test Lead 1', Company = 'Test Company');
        insert testLead;

        testTask.whoId = testLead.Id;
        update testTask;

        testTask = [SELECT Id, Role_of_Creator_When_Created1__c, WhatId, Status, CreatedById FROM Task WHERE Id = :testTask.Id LIMIT 1];
        
        Test.startTest();
            TaskTriggerHelper.processLeads(new Map<Id, List<Task>> {testLead.Id => new List<Task> {testTask}});
        Test.stopTest();

        Lead resultLead = [SELECT Id, Status FROM Lead WHERE Id = :testLead.Id LIMIT 1];
        System.assertEquals(L2O_Constants.LeadObject.LEAD_STATUS_MEETING_SCHEDULED, resultLead.Status, 'The Lead Status should be Meeting Scheduled.');
    }

    @isTest
    static void testProcessLeadsWhenTaskStatusCompleted() {
        Task testTask = new Task(Subject = 'Test Task 3');
        insert testTask;

        Lead testLead = new Lead(LastName = 'Test Lead 1', Company = 'Test Company');
        insert testLead;

        testTask.whoId = testLead.Id;
        testTask.Status = 'Completed';
        update testTask;

        testTask = [SELECT Id, Role_of_Creator_When_Created1__c, WhatId, Status, CreatedById FROM Task WHERE Id = :testTask.Id LIMIT 1];
        
        Test.startTest();
            TaskTriggerHelper.processLeads(new Map<Id, List<Task>> {testLead.Id => new List<Task> {testTask}});
        Test.stopTest();

        Lead resultLead = [SELECT Id, Status FROM Lead WHERE Id = :testLead.Id LIMIT 1];
        System.assertEquals(L2O_Constants.LeadObject.LEAD_STATUS_MEETING_SCHEDULED, resultLead.Status, 'The Lead Status should be Meeting Scheduled.');
    }

    @isTest
    static void testProcessContactsForSDRUsers() {
        Task testTask = new Task();
        testTask.Subject = 'Test Task 4';
        
        User sdrUser;

        System.runAs(new User(Id = UserInfo.getUserId())) {
            UserRole userRole = new UserRole(DeveloperName = 'SDR_TEST_ROLE', Name = 'SDR Test Role');
            insert userRole;
            
            sdrUser = new User(
                ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User'].Id,
                LastName = 'last',
                Email = TEST_SDR_EMAIL,
                Username = TEST_SDR_EMAIL + System.currentTimeMillis(),
                CompanyName = TEST_STRING,
                Title = 'Mr',
                Alias = 'TSDR',
                TimeZoneSidKey = 'America/Los_Angeles',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = ZScalarConstants.LOCALE_EN_US,
                LocaleSidKey = ZScalarConstants.LOCALE_EN_US,
                UserRoleId = userRole.Id
            );

            insert sdrUser;
        }

        //User runningUser = [SELECT Id FROM User WHERE UserRole.Name LIKE '%SDR%' LIMIT 1];
        System.runAs(sdrUser) {
            insert testTask;
        }

        Contact testContact = new Contact(LastName = 'Test Contact 2');
        insert testContact;

        testTask.whoId = testContact.Id;
        update testTask;

        testTask = [SELECT Id, Role_of_Creator_When_Created1__c, WhatId, Status, CreatedById FROM Task WHERE Id = :testTask.Id LIMIT 1];

        Test.startTest();
            TaskTriggerHelper.processContacts(new Map<Id, List<Task>> {testContact.Id => new List<Task> {testTask}});
        Test.stopTest();
    }

    @isTest
    static void testProcessContactsWhenTaskStatusNotCompleted() {
        Task testTask = new Task(Subject = 'Test Task 5');
        insert testTask;

        Contact testContact = new Contact(LastName = 'Test Contact 3');
        insert testContact;

        testTask.whoId = testContact.Id;
        update testTask;

        testTask = [SELECT Id, Role_of_Creator_When_Created1__c, WhatId, Status, CreatedById FROM Task WHERE Id = :testTask.Id LIMIT 1];
        
        Test.startTest();
            TaskTriggerHelper.processContacts(new Map<Id, List<Task>> {testContact.Id => new List<Task> {testTask}});
        Test.stopTest();

        Contact resultContact = [SELECT Id, Contact_Lead_Status__c FROM Contact WHERE Id = :testContact.Id LIMIT 1];
        System.assertEquals(L2O_Constants.LeadObject.LEAD_STATUS_MEETING_SCHEDULED, resultContact.Contact_Lead_Status__c, 'The Contact Lead Status field should be Meeting Scheduled.');
    }

    @isTest
    static void testProcessContactsWhenTaskStatusCompleted() {
        Task testTask = new Task(Subject = 'Test Task 6');
        insert testTask;

        Contact testContact = new Contact(LastName = 'Test Contact 4');
        insert testContact;

        testTask.whoId = testContact.Id;
        testTask.Status = 'Completed';
        update testTask;

        testTask = [SELECT Id, Role_of_Creator_When_Created1__c, WhatId, Status, CreatedById FROM Task WHERE Id = :testTask.Id LIMIT 1];
        
        Test.startTest();
            TaskTriggerHelper.processContacts(new Map<Id, List<Task>> {testContact.Id => new List<Task> {testTask}});
        Test.stopTest();

        Contact resultContact = [SELECT Id, Contact_Lead_Status__c FROM Contact WHERE Id = :testContact.Id LIMIT 1];
        System.assertEquals(L2O_Constants.LeadObject.LEAD_STATUS_MEETING_SCHEDULED, resultContact.Contact_Lead_Status__c, 'The Contact Lead Status field should be Meeting Scheduled.');
    }
   //Start CR #4571
    public static testMethod void testPopulateSDROnContactLead(){
        Triggers_Switch__c tr1 = new Triggers_Switch__c(name = 'Execute_Task_PopulateSDR', Execute__c = true);
        insert tr1;

        Contact con = new Contact(
                          FirstName = 'Robin',
                          LastName = 'Koehler',
                          Qualifying_SDR__c = UserInfo.getuserId()
                          );
        insert con;
        
        Contact con1 = new Contact(
                          FirstName = 'Swathi',
                          LastName = 'Goudar'
                          );
        insert con1;

        Lead lead=new Lead(LastName='Doe',FirstName='John',Company=TEST_STRING,Status='Inquiry',Qualifying_SDR__c=UserInfo.getuserId());
        insert lead;

        List<Task> tasks = new List<Task>();
        tasks.add(new Task(
        ActivityDate = Date.today().addDays(7),
        Subject=L2O_Constants.TaskObject.TASK_SUBJECT_CALL,
        Type = System.Label.Task_Type_Discovery_Meeting,
        WhoId = con.Id,
        OwnerId = UserInfo.getUserId(),
        Status=L2O_Constants.TaskObject.TASK_STATUS_IN_PROGRESS)
        );

        tasks.add(new Task(
            ActivityDate = Date.today().addDays(7),
            Subject=L2O_Constants.TaskObject.TASK_SUBJECT_CALL,
            Type = System.Label.Task_Type_Discovery_Meeting,
            WhoId = con1.Id,
            OwnerId = UserInfo.getUserId(),
            Status=L2O_Constants.TaskObject.TASK_STATUS_IN_PROGRESS) 
            );
        
        tasks.add(new Task(
        ActivityDate = Date.today().addDays(7),
        Subject=L2O_Constants.TaskObject.TASK_SUBJECT_CALL,
        Type = System.Label.Task_Type_Discovery_Meeting,
        WhoId = lead.Id,
        OwnerId = UserInfo.getUserId(),
        Status=L2O_Constants.TaskObject.TASK_STATUS_IN_PROGRESS)
        );

        insert tasks;

    }
    //End CR #4571

    @isTest
    static void testPopulateTerritoryFieldsForLead() {
        User testSystemAdminUser = [SELECT Id FROM User WHERE Name = 'Test System Admin' LIMIT 1];

        System.runAs(testSystemAdminUser) {
            Lead testLead = [SELECT Id, Territory__r.Name FROM Lead WHERE Email = 'test@test1.com' LIMIT 1];
            List<Task> testTasksList = TestDataFactory_Task.prepareTestTasks(L2O_Constants.TaskObject.TASK_STATUS_COMPLETED, null, null, testLead.Id, 1);
    
            Test.startTest();
                insert testTasksList;
            Test.stopTest();
    
            Task resultTask = [SELECT Id, Sales_Territory__c FROM Task WHERE Id IN :testTasksList];
            System.assertEquals(testLead.Territory__r.Name, resultTask.Sales_Territory__c, 'Territory on task should be same as on Lead');
        }
    }   

    @isTest
    static void testPopulateTerritoryFieldsForContact() {
        User testSystemAdminUser = [SELECT Id FROM User WHERE Name = 'Test System Admin' LIMIT 1];

        System.runAs(testSystemAdminUser) {
            Contact testContact = [SELECT Id, Territory__r.Name FROM Contact WHERE LastName = 'Test Contact 1' LIMIT 1];
            List<Task> testTasksList = TestDataFactory_Task.prepareTestTasks(L2O_Constants.TaskObject.TASK_STATUS_COMPLETED, null, null, testContact.Id, 1);
    
            Test.startTest();
                insert testTasksList;
            Test.stopTest();
    
            Task resultTask = [SELECT Id, Sales_Territory__c FROM Task WHERE Id IN :testTasksList];
            System.assertEquals(testContact.Territory__r.Name, resultTask.Sales_Territory__c, 'Territory on task should be same as on Contact');
        }
    }
}