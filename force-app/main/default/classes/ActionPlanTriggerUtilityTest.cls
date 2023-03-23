@isTest
public class ActionPlanTriggerUtilityTest {

    @isTest
    public static void testmethod1(){
        
        List<Triggers_Switch__c> listTriggerSwitch = new List<Triggers_Switch__c>();
        Triggers_Switch__c tr1 = new Triggers_Switch__c(name = 'Execute_Action_Plan_Trigger', Execute__c = true);
        Triggers_Switch__c tr2 = new Triggers_Switch__c(name = 'Execute_AP_Owner_Defaulting', Execute__c = true);
        Triggers_Switch__c tr3 = new Triggers_Switch__c(name = 'Execute_AP_History_Creation', Execute__c = true);
        Triggers_Switch__c tr4 = new Triggers_Switch__c(name = 'Execute_AP_CompletionDate', Execute__c = true);
        listTriggerSwitch.add(tr1);
        listTriggerSwitch.add(tr2);
        listTriggerSwitch.add(tr3);
        listTriggerSwitch.add(tr4);
        insert listTriggerSwitch;
        
        
        TriggerUtility.SkipAccTriggerExecuted();
        Account a = new Account(Name='TEST-Z1');
        insert a;
        
        TriggerUtility.SkipContactTriggerExecuted();
        Contact con1 = new Contact();
        con1.AccountId = a.id;
        con1.lastname = 'Test2';
        con1.firstname = 'Test2';
        insert con1;
        
        Case cs = new Case(AccountId = a.id, Description='Test Desc');
        insert cs;
        
        Meeting__c mt = new Meeting__c(Date_of_meeting__c = System.now(), Customer_Name__c = a.id,Duration__c = 15, Executive_Summary__c = 'Test');
        insert mt;
        
        
        Objective__c obj = new Objective__c(Meeting_ID__c = mt.id,TAM_Notes__c = 'test notes');
        insert obj;
        
        
          Id depRecordTypeId = (Schema.SObjectType.inspire1__Project__c.getRecordTypeInfosByName().get('Deployment Project') != null) ?
            Schema.SObjectType.inspire1__Project__c.getRecordTypeInfosByName().get('Deployment Project').getRecordTypeId() :
        Null;
        
        Inspire1__Project__c IP = new Inspire1__Project__c();
        IP.name = 'Test project 2';
        IP.inspire1__Account__c=a.ID;
        IP.inspire1__Project_Status__c='In Progress';
        IP.Action_Plan__c = 'Test Plan';
        IP.RecordTypeId = depRecordTypeId;
        IP.Primary_Customer_Contact__c = con1.id;
        IP.Secondary_Customer_Contact__c = con1.id;
        insert IP;
        
        
        TriggerUtility.SkipActionPlanTriggerReset();
        TriggerUtility.ActionPlanBeforeInsertReset();
        TriggerUtility.ActionPlanAfterInsertReset();
        Action_Plan__c ap =new Action_Plan__c();
        ap.Case__c = cs.id;
        ap.Customer__c = a.id;
        ap.Project__c = IP.id;
        ap.Objective__c = obj.id;
        ap.Detail_TAM_Notes__c = 'Test';
        insert ap;
        
        TriggerUtility.ActionPlanAfterUpdateReset();
        ap.Detail_TAM_Notes__c = 'Test 1';
        update ap;
        
        
    }
}