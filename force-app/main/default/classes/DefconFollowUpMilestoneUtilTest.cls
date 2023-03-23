@IsTest
public with sharing class DefconFollowUpMilestoneUtilTest {
    @TestSetup
    static void makeData(){
        Id escalationRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Escalation').getRecordTypeId();
        Id supportRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Support').getRecordTypeId();
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('End_User_Customer_DS_Reviewed').getRecordTypeId();
        
        //Account
        Account testSetacct = new Account();
        testSetacct.name = 'Test Account Service Cloud Test Class';
        testSetacct.Type = 'Customer';
        testSetacct.RecordTypeId = accRecordTypeId;
        testSetacct.Case_Escalation_Notification_Recipients__c = 'bdeshmukh77@z.com';
        insert testSetacct;

        //Entitlement
        Entitlement entitle = new Entitlement();
        entitle.Name = 'Defcon Escalation Entitlement (DO NOT DELETE)';
        entitle.AccountId = testSetacct.Id;        
        entitle.StartDate=date.today();        
        Insert entitle;

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
         csEsc.EntitlementId = entitle.Id;
         csEsc.Escalated_By__c = UserInfo.getUserId();
         csEsc.Defcon_Level__c = '4';
         csEsc.Next_Update_Due__c = DateTime.now().addMinutes(30);
         csEsc.Escalation_Level__c = 'Level 0';
         csEsc.RecordTypeId = escalationRecordTypeId;
         csEsc.Root_Cause_for_DEFCON__c = 'Support Technical capability lacking';         
         //csEsc.SlaStartDate = DateTime.now();
         csEsc.Follow_Up_SLA_Violated__c = false;
         Insert csEsc;         
    }

    @IsTest
    Static Void testFollowUpEsc() {
        
        String defconId = [Select Id From Case Where RecordType.Name='Escalation'].Id;
        String milestoneTypeId = [Select id, Name from MilestoneType where Name = 'Follow Up SLA'].Id;
        
        Test.StartTest();
        List<Entitlement> entitleList = [Select Id,SlaProcessId  From Entitlement WHERE Name='Defcon Escalation Entitlement (DO NOT DELETE)'];
        List<Case> escList = [SELECT Id,Defcon_Level__c,Owner.name,Follow_Up_SLA_Violated__c,OwnerId,Next_Update_Due__c,RecordTypeId,Is_Next_Update_Due_in_Future__c,EntitlementID FROM Case WHERE RecordType.Name='Escalation' limit 1 ];
        System.debug('**Is_Next_Update_Due_in_Future__c : '+escList[0].Is_Next_Update_Due_in_Future__c);
        System.debug('**Follow_Up_SLA_Violated__c : '+escList[0].Follow_Up_SLA_Violated__c);
        List<SlaProcess> lstEntitlementProcess = [SELECT Id, Name FROM SlaProcess WHERE Name='Defcon Escalations Entitlement Process' AND IsActive = true LIMIT 1];
        entitleList[0].SlaProcessId = lstEntitlementProcess[0].Id;
        Update entitleList;
       
        
        List<CaseMilestone> cmList2 = new List<CaseMilestone>([SELECT id,caseId,StartDate,targetDate FROM CaseMilestone ]);
        System.debug('&*&*cmList2 '+cmList2.size());
        DefconFollowUpMilestoneUtility utilObj = new DefconFollowUpMilestoneUtility();
        utilObj.calculateMilestoneTriggerTime(defconId,milestoneTypeId);
        Test.StopTest();
    }
}