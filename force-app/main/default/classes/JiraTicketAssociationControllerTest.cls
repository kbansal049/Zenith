@isTest
public class JiraTicketAssociationControllerTest {

    @isTest
    public static void testMethod1(){
        List<Triggers_Switch__c> listTriggerSwitch = new List<Triggers_Switch__c>();
        Triggers_Switch__c tr1 = new Triggers_Switch__c(name = 'Execute_JIRA_Ticket_Trigger', Execute__c = true);
        listTriggerSwitch.add(tr1);
        insert listTriggerSwitch;
        
        
        TriggerUtility.SkipAccTriggerExecuted();
        Account ac = new Account(name = 'TestAccount');
        insert ac;
        
        Account ac1 = new Account(name = 'TestAccount1');
        insert ac1;
        
        
        TriggerUtility.SkipOppTriggerExecuted();
        opportunity opp = new opportunity( Name = 'Test opportunity', 
                                          Primary_Quote_Exception__c  = true, 
                                          AccountId = ac.Id, 
                                          StageName = label.Stage_1_Alignment, 
                                          CloseDate = Date.newInstance(system.today().Year(), 2, 1),
                                          Renewal_VP_In_my_Number__c = true,
                                          Type = 'Existing Customer (Renewal)',
                                          Contract_End_Date_New__c = system.Today() + 1,
                                          CRO_Forecast_Category__c = 'Commit');
        insert opp;
        
        
       
        Test.startTest();
        
        JIRA_Ticket__c jt = new JIRA_Ticket__c(Account_IDs__c = ac.id, Assignee__c = 'test',
                                               Ticket_Number__c = 'TestTicket123', Summary__c = 'Test Summary',
                                               Ticket_Type__c = 'Improvement'
                                              );
        insert jt;
        
        Account_JIRA_Integration__c ajt = new Account_JIRA_Integration__c(Account__c = ac.id,JIRA_Ticket__c = jt.id);
        insert ajt;
        
       
        
        PageReference myVfPage = Page.associateJIRAToRecord;
        Test.setCurrentPage(myVfPage);
        
        // Put Id into the current page Parameters
        ApexPages.currentPage().getParameters().put('recordID',jt.Id);
        ApexPages.currentPage().getParameters().put('recordType','Improvement');
        
        
        myVfPage = Page.associateJIRAToRecord;
        Test.setCurrentPage(myVfPage);
        
        // Put Id into the current page Parameters
        ApexPages.currentPage().getParameters().put('recordID',jt.Id);
        ApexPages.currentPage().getParameters().put('recordType','Improvement_bad');
        
        JiraTicketAssociationController jta = new JiraTicketAssociationController();
        jta.recordID = jt.id;
        jta.recordType = 'Improvement';
        
        JiraTicketAssociationController.getAssociatedRecordsForOpportunity(opp.id, 'Improvement');
        JiraTicketAssociationController.getAssociatedRecordsForOpportunity(opp.id, 'Improvement_bad');
        JiraTicketAssociationController.getNonAssoicatedRecord(opp.id, 'Improvement');
        JiraTicketAssociationController.getNonAssoicatedRecord(ac.id, 'Improvement');
        jta.doRedirectToRecord();
        
        List<Account_JIRA_Integration__c> acjList = [Select Id from Account_JIRA_Integration__c];
        System.debug('--acjList--'+acjList);
        JiraTicketAssociationController.saveRecords(acjList, opp.id, 'Opportunity', 'Improvement');
        
        JiraTicketAssociationController.AssociateJIRARequestWrapperResult jta1 = new JiraTicketAssociationController.AssociateJIRARequestWrapperResult();
		jta1.errMsg = 'Test';

        Test.stopTest();
    }
}