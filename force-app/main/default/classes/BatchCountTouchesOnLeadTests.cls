@isTest
private class BatchCountTouchesOnLeadTests {
    
    private static final String STATUS_COMPLETED_ASSERT_MESSAGE = 'Status should be completed';

    @isTest
    static void testExecuteForBothTaskAndEvent() {
        Lead testLead = new Lead(FirstName = 'Test1', LastName = 'Lead1', Phone = '9876543211', Email = 'test@test1.com', 
            LeadSource = L2O_Constants.LeadObject.LEAD_SOURCE_ADVERTISEMENT, Company = 'Test Company 1', Last_Opened_Date__c = Date.today(), Touches_Since_Last_Open__c = 3);
        insert testLead;

        Task testTask = new Task(Subject = 'Test Task', ActivityDate = Date.today().addDays(1), Status = L2O_Constants.TaskObject.TASK_STATUS_COMPLETED, WhoId = testLead.Id);
        insert testTask;

        Event testEvent = new Event(Subject = 'Test Event', ActivityDate = Date.today(), ActivityDateTime = System.now().addMinutes(-20), EndDateTime = System.now(), WhoId = testLead.Id, 
            DurationInMinutes = 20);
        insert testEvent;

        Test.startTest();
            Id jobId = Database.executeBatch(new BatchCountTouchesSinceLastOpenOnLead());
        Test.stopTest();

        AsyncApexJob apexJob = [SELECT Id, Status FROM AsyncApexJob WHERE Id = :jobId LIMIT 1];
        System.assertEquals(L2O_Constants.TaskObject.TASK_STATUS_COMPLETED, apexJob.Status, STATUS_COMPLETED_ASSERT_MESSAGE);
    }

    @isTest
    static void testExecuteForTask() {
        Lead testLead = new Lead(FirstName = 'Test2', LastName = 'Lead2', Phone = '9876543212', Email = 'test@test2.com', 
            LeadSource = L2O_Constants.LeadObject.LEAD_SOURCE_ADVERTISEMENT, Company = 'Test Company 2', Last_Opened_Date__c = Date.today(), Touches_Since_Last_Open__c = 2);
        insert testLead;

        Task testTask = new Task(Subject = 'Test Task', ActivityDate = Date.today().addDays(1), Status = L2O_Constants.TaskObject.TASK_STATUS_COMPLETED, WhoId = testLead.Id);
        insert testTask;

        Test.startTest();
            Id jobId = Database.executeBatch(new BatchCountTouchesSinceLastOpenOnLead());
        Test.stopTest();

        AsyncApexJob apexJob = [SELECT Id, Status FROM AsyncApexJob WHERE Id = :jobId LIMIT 1];
        System.assertEquals(L2O_Constants.TaskObject.TASK_STATUS_COMPLETED, apexJob.Status, STATUS_COMPLETED_ASSERT_MESSAGE);
    }

    @isTest
    static void testExecuteForEvent() {
        Lead testLead = new Lead(FirstName = 'Test3', LastName = 'Lead3', Phone = '9876543213', Email = 'test@test3.com', 
            LeadSource = L2O_Constants.LeadObject.LEAD_SOURCE_ADVERTISEMENT, Company = 'Test Company 3', Last_Opened_Date__c = Date.today(), Touches_Since_Last_Open__c = 2);
        insert testLead;

        Event testEvent = new Event(Subject = 'Test Event', ActivityDate = Date.today(), ActivityDateTime = System.now().addMinutes(-20), EndDateTime = System.now(), WhoId = testLead.Id, 
            DurationInMinutes = 20);
        insert testEvent;

        Test.startTest();
            Id jobId = Database.executeBatch(new BatchCountTouchesSinceLastOpenOnLead());
        Test.stopTest();

        AsyncApexJob apexJob = [SELECT Id, Status FROM AsyncApexJob WHERE Id = :jobId LIMIT 1];
        System.assertEquals(L2O_Constants.TaskObject.TASK_STATUS_COMPLETED, apexJob.Status, STATUS_COMPLETED_ASSERT_MESSAGE);
    }

    @isTest
    static void testExecuteForNoTaskAndEvent() {
        Lead testLead = new Lead(FirstName = 'Test4', LastName = 'Lead4', Phone = '9876543214', Email = 'test@test4.com', 
            LeadSource = L2O_Constants.LeadObject.LEAD_SOURCE_ADVERTISEMENT, Company = 'Test Company 4', Last_Opened_Date__c = Date.today(), Touches_Since_Last_Open__c = 2);
        insert testLead;

        Test.startTest();
            Id jobId = Database.executeBatch(new BatchCountTouchesSinceLastOpenOnLead());
        Test.stopTest();

        AsyncApexJob apexJob = [SELECT Id, Status FROM AsyncApexJob WHERE Id = :jobId LIMIT 1];
        System.assertEquals(L2O_Constants.TaskObject.TASK_STATUS_COMPLETED, apexJob.Status, STATUS_COMPLETED_ASSERT_MESSAGE);
    }
}