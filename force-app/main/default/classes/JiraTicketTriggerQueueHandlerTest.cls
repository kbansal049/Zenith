@istest
public class JiraTicketTriggerQueueHandlerTest {
    
    @isTest
    public static void testmethod1(){
        
        List<Triggers_Switch__c> listTriggerSwitch = new List<Triggers_Switch__c>();
        Triggers_Switch__c tr1 = new Triggers_Switch__c(name = 'Execute_JIRA_Ticket_Trigger', Execute__c = true);
        listTriggerSwitch.add(tr1);
        insert listTriggerSwitch;
        
        
        TriggerUtility.SkipAccTriggerExecuted();
        Account ac = new Account(name = 'TestAccount');
        insert ac;
        
         Account ac1 = new Account(name = 'TestAccount1');
        insert ac1;
        
        
        JIRA_Ticket__c jt = new JIRA_Ticket__c(Account_IDs__c = ac.id, Assignee__c = 'test',
                                               Ticket_Number__c = 'TestTicket123', Summary__c = 'Test Summary',
                                               Ticket_Type__c = 'Improvement'
                                              );
        insert jt;
        
        JIRA_Ticket__c jt1 = new JIRA_Ticket__c(Account_IDs__c = ac1.id, Assignee__c = 'test1',
                                               Ticket_Number__c = 'TestTicket12345', Summary__c = 'Test Summary2',
                                               Ticket_Type__c = 'Bug'
                                              );
        insert jt1;
        
        
        
        TriggerUtility.jiraTicketReset();
        jt.Account_IDs__c = ac1.id;
        update jt;
        
    }
    

}