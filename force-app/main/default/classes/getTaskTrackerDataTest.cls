@isTest
public class getTaskTrackerDataTest {
    
    @testSetup static void setup()
    {
        
        Triggers_Switch__c ts = new Triggers_Switch__c(name = 'Execute_TaskTrackerTrigger', Execute__c = true);
        insert ts;
        
        Customers__c customers = new Customers__c();
        customers.Name='test custom setting';
        customers.Latest_Number__c=0;
        insert customers;
        Order_tracker__c testordertracker = new Order_Tracker__c(Email_Subject__c='test class email subject', Status__c='PO Pending for QR', Region__c='EMEA', 
                                                                 Order_Type__c='New', End_User__c='Test class end user');
        insert testordertracker;
        Date scheduleDate = date.newInstance(2021,07,11);
        List<Task_Tracker__c> taskTrackerList=new List<Task_Tracker__c>();
        for(Integer i=1;i<=4;i++)
        {
            task_tracker__c testtasktracker= new task_tracker__c(Task_Name__c='test task '+i,Ticket_No__c='test tc '+i,
                                                                 Customer_Name__c='test customer '+i, SO_Number__c='test so '+i,Order_tracker__c = testordertracker.id,Schedule_date__c=scheduleDate ); 
            taskTrackerList.add(testtasktracker);
        }
        insert taskTrackerList;
        
        Email_tracker__c testemailtracker = new Email_Tracker__c(Email_Subject__c='test class email subject', Status__c='Completed', Email_Category__c='Decommissioning',Priority__c='Low');
        insert testemailtracker;
    }
    
    @isTest 
    static void method1() 
    {
        test.startTest();
        getTaskTrackerData.getSearchTicketNumber('tn 23');
        test.stopTest();
    }
    
    @isTest 
    static void method2() 
    {
        Order_Tracker__c testordertracker = [select id from Order_Tracker__c limit 1];
        test.startTest();
        getTaskTrackerData.updateTasksFromReply(testordertracker.id);
        getTaskTrackerData.getTasks(testordertracker.id);
        test.stopTest();
    }
    
    
    @isTest 
    static void method4() 
    {
        Order_tracker__c testordertracker = new Order_Tracker__c(Email_Subject__c='test class email subject', Status__c='PO Pending for QR', Region__c='EMEA', 
                                                                 Order_Type__c='New', End_User__c='Test class end user');
        insert testordertracker;
        list<task_tracker__c> testupdatetasklist= new  list<task_tracker__c>();
        list<task_tracker__c> testdeletetasklist= new  list<task_tracker__c>();
        Date scheduleDate = date.newInstance(2021,07,11);
        for(integer i=1;i<3;i++)
        {
            task_tracker__c testtasktracker = new task_tracker__c(Task_Name__c='test task '+i ,Order_tracker__c = testordertracker.id,Schedule_date__c=scheduleDate);
            testupdatetasklist.add(testtasktracker);
        }
		
        for(integer i=4;i<7;i++)
        {
            task_tracker__c testtasktracker = new task_tracker__c(Task_Name__c='test task ' +i ,Order_tracker__c = testordertracker.id);
            testdeletetasklist.add(testtasktracker);
        }
        insert testdeletetasklist;
        
        test.startTest();
        insert testupdatetasklist;
        task_tracker__c updateTask = new task_tracker__c(id=testupdatetasklist[0].Id);
        getTaskTrackerData.createTasksFromOrderTracker(testupdatetasklist,testdeletetasklist);
        getTaskTrackerData.getMetadataPicklists();
        updateTask.Schedule_date__c = scheduleDate+1;
        update updateTask;
        test.stopTest();
    }
    
    @isTest 
    static void method8() 
    {
        task_tracker__c testtasktracker = [select id from task_tracker__c limit 1];
        system.debug('testtasktracker in test'+testtasktracker);
        test.startTest();
        getTaskTrackerData.updateTaskTracker(testtasktracker.id,'Extension','Ticket Type');
        getTaskTrackerData.updateTaskTracker(testtasktracker.id,'Open','Status');
        getTaskTrackerData.updateTaskTracker(testtasktracker.id,'test customer','Customer');
        test.stopTest();
    }
    
    @isTest 
    static void method9() 
    {
        test.startTest();
        getTaskTrackerData.getNextTaskTrackers(1,10,'All','test','Assigned To Me');
        getTaskTrackerData.getNextTaskTrackers(1,10,'Open','test','Assigned To Me');
        getTaskTrackerData.getNextTaskTrackers(1,10,'closed','test','Assigned To Me');
        getTaskTrackerData.getNextTaskTrackers(1,10,'closed','','Assigned To Me');
        getTaskTrackerData.getNextTaskTrackers(1,10,'Open','','Assigned To Me');
        getTaskTrackerData.getNextTaskTrackers(1,10,'All','','Assigned To Me');
        getTaskTrackerData.getNextTaskTrackers(1,10,'closed','test','All');
        getTaskTrackerData.getNextTaskTrackers(1,10,'closed','','All');
        getTaskTrackerData.getNextTaskTrackers(1,10,'open','','All');
        getTaskTrackerData.getNextTaskTrackers(1,10,'closed','', 'All');
        getTaskTrackerData.getNextTaskTrackers(1,10,'Open','test', 'All');
        getTaskTrackerData.getNextTaskTrackers(1,10,'All','test', 'All');
        getTaskTrackerData.getNextTaskTrackers(1,10,'All','', 'All');
        test.stopTest();
    }
    
}