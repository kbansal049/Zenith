@isTest
private class TaskTriggerHandlerTests {
    
    @isTest
    static void testBeforeInsert() {
        Task testTask = new Task(Subject = 'Kronologic - Meeting Accepted', Type = 'Test Task');
        
        Test.startTest();
            insert testTask;
        Test.stopTest();
    }

    @isTest
    static void testBeforeUpdate() {
        Task testTask = new Task(Subject = 'Kronologic - Meeting Accepted');
        insert testTask;
        
        testTask.Type = 'Test Task';
        Test.startTest();
            update testTask;
        Test.stopTest();

        Task resultTask = [SELECT Id, Activity_Type__c FROM Task WHERE Id = :testTask.Id LIMIT 1];
        System.assertEquals(testTask.Type, resultTask.Activity_Type__c, 'Task\'s Activity Type should be ' + testTask.Type);
    }

    @isTest
    static void testAfterInsert() {
        Contact testContact = new Contact(LastName = 'Test Contact 1');
        insert testContact;

        Task testTask = new Task(Subject = 'Cloned from Proposal', Status = 'Completed', whoId = testContact.Id);

        Test.startTest();
            insert testTask;
        Test.stopTest();
    }

    @isTest
    static void testAfterUpdate() {
        Contact testContact = new Contact(LastName = 'Test Contact 1');
        insert testContact;

        Task testTask = new Task(Subject = 'Cloned from Proposal', Type = 'Discovery Meeting', whoId = testContact.Id);
        insert testTask;

        Task testTask2 = new Task(Subject = 'Cloned from Proposal', Type = 'Discovery Meeting', whoId = testContact.Id);
        insert testTask2;

        testTask.Status = 'Completed';
        testTask2.Status = 'Completed';

        List<Task> taskList = new List<Task> {testTask, testTask2};
        Test.startTest();
            update taskList;
        Test.stopTest();
    }

    @isTest
    static void testAfterUpdateForLeads() {
        Lead testLead = new Lead();
        testLead.mkto71_Lead_Score__c = 69;
        testLead.Email = 'test@test.com';
        testLead.FirstName = 'test';
        testLead.LastName = 'test lead';
        testLead.Company = 'test Company 2';
        testLead.Status = 'Marketing Qualified: Sales Untouched';
        testLead.Kronologic_Status__c = 'Meeting Accepted';
        insert testLead;
        
        Task testTask = new Task(Subject = 'Cloned from Proposal', Type = 'Discovery Meeting', whoId = testLead.Id);
        insert testTask;

        Task testTask2 = new Task(Subject = 'Cloned from Proposal', Type = 'Discovery Meeting', whoId = testLead.Id);
        insert testTask2;

        testTask.Status = 'Completed';
        testTask2.Status = 'Completed';

        List<Task> taskList = new List<Task> {testTask, testTask2};
        Test.startTest();
            update taskList;
        Test.stopTest();
    }

    @isTest
    static void testAfterDelete() {
        Task testTask = new Task(Subject = 'Cloned from Proposal', Type = 'Discovery Meeting');
        insert testTask;

        Test.startTest();
            delete testTask;
        Test.stopTest();
    }

    @isTest
    static void testAfterUndelete() {
        Task testTask = new Task(Subject = 'Cloned from Proposal', Type = 'Discovery Meeting');
        insert testTask;
        Id taskId = testTask.Id;
        delete testTask;

        Task taskToRetrieve = new Task(Id = taskId);
        Test.startTest();
            undelete taskToRetrieve;
        Test.stopTest();
    }
}