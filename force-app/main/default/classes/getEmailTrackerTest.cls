@isTest
public class getEmailTrackerTest{
	@isTest 
    static void testEmailMethod() 
    {
     	Email_Tracker__c eTracker = new Email_Tracker__c();
       
        eTracker.Email_Category__c = 'Trial activation';
        eTracker.Email_Subject__c = 'Test Subject';
        eTracker.Requester_Name__c = 'Test Requester';
        eTracker.Requester_Org__c = 'HQ';
        eTracker.Priority__c = 'High';
        eTracker.Status__c = 'Completed';
        eTracker.Complete__c = 0.1;
        eTracker.Remarks__c = 'Test Remarks';
        
           
      	test.startTest();
        insert eTracker;
        Email_Tracker__c newETracker = [select id, status__c from Email_Tracker__c where id = :eTracker.id];
        newETracker.Status__c = 'Duplicate';
        update newETracker;
        getEmailTrackerData.getMetadataPicklistsEmailTracker();
        getEmailTrackerData.getNextEmailTrackers(1,10,'closed','','All');
        getEmailTrackerData.getNextEmailTrackers(1,10,'closed','notfound','All');
        getEmailTrackerData.getNextEmailTrackers(2,10,'open','test','All');
        getEmailTrackerData.getNextEmailTrackers(1,10,'open','','All');
        getEmailTrackerData.getNextEmailTrackers(1,10,'All','test','All');        
        getEmailTrackerData.getNextEmailTrackers(1,10,'All','test','Assigned To Me');
        getEmailTrackerData.getNextEmailTrackers(1,10,'Open','test','Assigned To Me');
        
        test.stopTest();
    }
    
    @isTest 
    static void updateEmailMethod(){
        Email_Tracker__c eTracker = insertEmailMethod();
        List<Email_Tracker_1st_Assignee__mdt> assigneeFirstList = [SELECT Id, Label, User_Id__c FROM Email_Tracker_1st_Assignee__mdt];
        List<Email_Tracker_2nd_Assignee__mdt> assigneeSecondList = [SELECT Id, Label, User_Id__c FROM Email_Tracker_2nd_Assignee__mdt];
        List<Email_Tracker_3rd_Assignee__mdt> assigneeThirdList = [SELECT Id, Label, User_Id__c FROM Email_Tracker_3rd_Assignee__mdt];
        test.startTest();
        system.assert(getEmailTrackerData.getEmailTracker(eTracker.Id).Id == eTracker.Id,'Correct case');
        getEmailTrackerData.updateEmailTracker(eTracker.Id,'Others','Email Category', 0.04);
        getEmailTrackerData.updateEmailTracker(eTracker.Id,'Partner','Requestor Org',0.45);
        getEmailTrackerData.updateEmailTracker(eTracker.Id,'Low','Priority',0.99);
        getEmailTrackerData.updateEmailTracker(eTracker.Id,'Completed','Status',0.78);
        getEmailTrackerData.updateEmailTracker(eTracker.Id,'TestRemarks','remarks',0.78);
        getEmailTrackerData.updateEmailTracker(eTracker.Id,'TestRequester','RequesterName',0.78);
        getEmailTrackerData.updateEmailTracker(eTracker.Id,'Completed','PercentComplete',0.98);
        getEmailTrackerData.updateEmailTracker(eTracker.Id,assigneeFirstList[0].Id,'firstAssignee',0.78);
        getEmailTrackerData.updateEmailTracker(eTracker.Id,assigneeSecondList[0].Id,'secondAssignee',0.78);
        getEmailTrackerData.updateEmailTracker(eTracker.Id,assigneeThirdList[0].Id,'thirdAssignee',0.78);
        eTracker.Status__c='Completed';
        update eTracker;
        test.stopTest();
    }
    
    static Email_Tracker__c insertEmailMethod(){
        Email_Tracker__c eTracker = new Email_Tracker__c();
       
        eTracker.Email_Category__c = 'Trial activation';
        eTracker.Email_Subject__c = 'Test Subject';
        eTracker.Requester_Name__c = 'Test Requester';
        eTracker.Requester_Org__c = 'HQ';
        eTracker.Priority__c = 'High';
        eTracker.Status__c = 'Duplicate';
        eTracker.Complete__c = 0.1;
        eTracker.Remarks__c = 'Test Remarks';
        
        insert eTracker;
        return eTracker;
    }
    
    @isTest
    static void mergeRecords(){
        Email_Tracker__c eTracker = new Email_Tracker__c();
        eTracker.Email_Category__c = 'Trial activation';
        eTracker.Email_Subject__c = 'Test Subject';
        eTracker.Requester_Name__c = 'Test Requester';
        eTracker.Requester_Org__c = 'HQ';
        eTracker.Priority__c = 'High';
        eTracker.Status__c = 'Completed';
        eTracker.Complete__c = 0.1;
        eTracker.Remarks__c = 'Test Remarks';
        insert eTracker;
        
        Email_Tracker__c eTracker2 = new Email_Tracker__c();
        eTracker2.Email_Category__c = 'Trial activation';
        eTracker2.Email_Subject__c = 'Test Subject';
        eTracker2.Requester_Name__c = 'Test Requester';
        eTracker2.Requester_Org__c = 'HQ';
        eTracker2.Priority__c = 'High';
        eTracker2.Status__c = 'Completed';
        eTracker2.Complete__c = 0.1;
        eTracker2.Remarks__c = 'Test Remarks';
        insert eTracker2;
        
        String jsonString = '[{\"Id\":\"'+ eTracker.ID + '\",\"primary\":true},{\"Id\":\"'+ eTracker2.Id+ '\",\"primary\":false}]';
        getEmailTrackerData.mergeRecords(jsonString);
    }
    

}