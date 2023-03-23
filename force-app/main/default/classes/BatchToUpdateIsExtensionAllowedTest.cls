@isTest
public class BatchToUpdateIsExtensionAllowedTest {
    
    private static Id depRecordTypeId = (Schema.SObjectType.inspire1__Project__c.getRecordTypeInfosByName().get('Deployment Project') != null) ? Schema.SObjectType.inspire1__Project__c.getRecordTypeInfosByName().get('Deployment Project').getRecordTypeId() : Null;
    private static final String questionnareRecordTypeZIA = Schema.SObjectType.PS_Questionnaire__c.getRecordTypeInfosByDeveloperName().get('ZIA').getRecordTypeId();
    
    @testSetup  static void setupdata(){
        
        Skip_Triggers__c skipTriggers = new Skip_Triggers__c();
        skipTriggers.Skip_Account_Triggers__c = true;
        skipTriggers.Skip_Opportunity_Triggers__c = true;
        skipTriggers.Name = 'SkipTriggers';
        insert skipTriggers;
        
        List<Triggers_Switch__c> trlst = new List<Triggers_Switch__c>();
        Triggers_Switch__c tr1 = new Triggers_Switch__c(name = 'Execute_Project_Trigger', Execute__c = true);
        Triggers_Switch__c tr2 = new Triggers_Switch__c(name = 'Execute_SendEmail_Project_Trigger', Execute__c = true);
        Triggers_Switch__c tr3 = new Triggers_Switch__c(name = 'Execute_Fill_Summary_Notes_Dates', Execute__c = true);//Added by Varun - CR 1069
        trlst.add(tr1);
        trlst.add(tr2);
        trlst.add(tr3);
        insert trlst;
        
        
        TriggerHandler.bypass('AccountTriggerHandler');
        TriggerHandler.bypass('OpportunityTriggerHandler');
        TriggerHandler.bypass('InspireProjectMasterTriggerHandler');
        
        TriggerUtility.isskipentireproposaltriggerExecuted();
        
        TriggerUtility.prospectTypeUpdExecuted();
        triggerUtility.contactPatchManagerExecuted();
        triggerUtility.accTerritoryPatchExecuted();
        triggerUtility.oppPatchManagerAfterInsertExecuted();
        triggerUtility.oppPatchManagerAfterUpdateExecuted();
        
    }
    
    
    static testMethod void testMethod1(){
        
        TriggerHandler.bypass('AccountTriggerHandler');
        TriggerHandler.bypass('OpportunityTriggerHandler');
        TriggerHandler.bypass('InspireProjectMasterTriggerHandler');
        
        
        Account a12 = new Account(Name='AOTest12');
        insert a12;
        
        
        opportunity opp21 = new opportunity(Name = 'Test opportunity21',
                                            
                                            AccountId = a12.Id, StageName='4 - Impact Validation', 
                                            CloseDate = system.Today()+30,
                                            ZIA_Use_Case__c = 'O365');
        insert opp21;
        
        
        Contact con1 = new Contact();
        con1.AccountId = a12.id;
        con1.lastname = 'Test2';
        con1.firstname = 'Test2';
        insert con1;
        
        TimeZone tz = TimeZone.getTimeZone('America/Los_Angeles');
        String tzName = tz.getDisplayName();
        
        
        Inspire1__Project__c IP = new Inspire1__Project__c();
        IP.name = 'Test project 2';
        IP.inspire1__Account__c=a12.ID;
        IP.inspire1__Project_Status__c='In Progress';
        IP.Action_Plan__c = 'Test Plan';
        IP.RecordTypeId = depRecordTypeId;
        IP.Primary_Customer_Contact__c = con1.id;
        IP.Secondary_Customer_Contact__c = con1.id;
        IP.Deployment_Package__c = 'ZCES-TEST';
        IP.inspire1__Timezone__c=tzName;
        insert IP;
        
        
        
        Test.startTest();
        BatchToUpdateIsExtensionAllowed accextn = new BatchToUpdateIsExtensionAllowed();        
        Database.executeBatch(accextn,40);
        Test.stopTest();
    }
}