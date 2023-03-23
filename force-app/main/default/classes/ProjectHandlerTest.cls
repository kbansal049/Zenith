@isTest
private class ProjectHandlerTest{
    
    @testSetup  static void setupdata(){
        
        Skip_Triggers__c skipTriggers = new Skip_Triggers__c();
        skipTriggers.Skip_Account_Triggers__c = true;
        skipTriggers.Skip_Opportunity_Triggers__c = true;
        skipTriggers.Name = 'SkipTriggers';
        insert skipTriggers;
        
        List<Triggers_Switch__c> trlst = new List<Triggers_Switch__c>();
        Triggers_Switch__c tr1 = new Triggers_Switch__c(name = 'Execute_Project_Trigger', Execute__c = true);
        trlst.add(tr1);
        insert trlst;
    }
    
    
    @isTest
    static void testafterInsert(){
        Account a = new Account(Name='TEST-Z');
        insert a;
        
        Inspire1__Project__c IP = new Inspire1__Project__c();
        IP.inspire1__Account__c=a.ID;
        IP.inspire1__Project_Status__c='In Progress';
        insert IP;
        
        IP.Kickoff_Completed_Date__c = System.today();
        IP.Design_Completed_Date__c = System.today();
        IP.Configuration_Completed_Date__c = System.today();
        IP.Production_Completed_Date__c = System.today();
        IP.Pilot_Completed_Date__c = System.today();
        IP.Project_Transition_Completed_Date__c = System.today();
        IP.Region__c='Transformation';
        
        IP.inspire1__Project_Status__c = 'Completed';
        
        TriggerUtility.updateProjectCloneReset();
        update IP;
        
        TriggerUtility.updateProjectCloneReset();
        delete ip;
    }
    
    @isTest
    static void testafterUpdate(){
        TriggerUtility.updateProjectCloneExecuted();
        Account a = new Account(Name='TEST-Z');
        insert a;
        
        Inspire1__Project__c IP = new Inspire1__Project__c();
        IP.inspire1__Account__c=a.ID;
        IP.inspire1__Project_Status__c='In Progress';
        insert IP;
        
        IP.Kickoff_Completed_Date__c = System.today();
        IP.Design_Completed_Date__c = System.today();
        IP.Configuration_Completed_Date__c = System.today();
        IP.Production_Completed_Date__c = System.today();
        IP.Pilot_Completed_Date__c = System.today();
        IP.Project_Transition_Completed_Date__c = System.today();
        IP.Region__c='Transformation';
        IP.inspire1__Project_Status__c = 'Completed';
        
        TriggerUtility.updateProjectCloneReset();
        update IP;
        
        TriggerUtility.updateProjectCloneReset();
        delete ip;
    }
    
}