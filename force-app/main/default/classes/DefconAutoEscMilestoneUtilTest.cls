@IsTest
public with sharing class DefconAutoEscMilestoneUtilTest {
    @TestSetup
    static void makeData(){
        Id escalationRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Escalation').getRecordTypeId();
        Id supportRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Support').getRecordTypeId();

        //Support Case
        Case csSupport = new Case();
        csSupport.Subject = 'Test Support Case';
        csSupport.Product_New__c = 'ZIA';
        csSupport.Status = 'New';
        csSupport.Priority = 'Medium (P3)';
        csSupport.Case_Type__c = 'Problem';
        csSupport.Preferred_Contact_Time_Zone__c = 'Pacific/Chatham';
        csSupport.Preferred_Method_of_Contact__c = 'Phone';  
        csSupport.RecordTypeId = supportRecordTypeId;     
        
        
        Insert csSupport;

         //Escalation Case
         Case csEsc = new Case();
         csEsc.Subject = 'Defcon raised for '+csSupport.CaseNumber;
         csEsc.Case_Escalated_per_Defcon_Process__c = true;
         csEsc.Status = 'New';
         csEsc.Escalation_Reason__c = 'Test Escalation';
         csEsc.Escalation_Category__c = 'Unsatisfied with current support';
         csEsc.ParentId = csSupport.Id;         
         csEsc.Escalated_By__c = UserInfo.getUserId();
         csEsc.Defcon_Level__c = '4';
         csEsc.RecordTypeId = escalationRecordTypeId;
         csEsc.Root_Cause_for_DEFCON__c = 'Support Technical capability lacking';
         csEsc.Escalation_Level__c = 'Level 0';
         Insert csEsc;         
        
    }
    @IsTest
    static void test() {
        String defconId = [Select Id From Case Where RecordType.Name='Escalation'].Id;
        DefconAutoEscMilestoneUtility utilObj = new DefconAutoEscMilestoneUtility();
        utilObj.calculateMilestoneTriggerTime(defconId,'');
    }

    @IsTest
    static void test2() {
        List<Case> defconList = [Select Id ,Escalation_Level__c From Case Where RecordType.Name='Escalation'];
        defconList[0].Escalation_Level__c = 'Level 1';
        Update defconList[0];
        DefconAutoEscMilestoneUtility utilObj = new DefconAutoEscMilestoneUtility();
        utilObj.calculateMilestoneTriggerTime(defconList[0].Id,'');
    }

    @IsTest
    static void test3() {
        List<Case> defconList = [Select Id ,Escalation_Level__c From Case Where RecordType.Name='Escalation'];
        defconList[0].Escalation_Level__c = 'Level 2';
        Update defconList[0];
        DefconAutoEscMilestoneUtility utilObj = new DefconAutoEscMilestoneUtility();
        utilObj.calculateMilestoneTriggerTime(defconList[0].Id,'');
    }
}