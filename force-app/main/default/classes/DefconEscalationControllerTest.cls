@isTest
public with sharing class DefconEscalationControllerTest {
    static final String CASE_SUPPORT_RT_ID = GCSCommonUtility.getCaseRecordTypeId(GCSCommonConstants.CASE_SUPPORT_RECORD_TYPE_NAME);
    static final String CASE_ESCALATION_RT_ID = GCSCommonUtility.getCaseRecordTypeId(GCSCommonConstants.CASE_ESCALATION_RECORD_TYPE_NAME);

    @testSetup static void setup() {
        Account incountrySupportAcct = new Account();
        incountrySupportAcct.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('End_User').getRecordTypeId();
        incountrySupportAcct.Name = 'Service Cloud Test Account';
        incountrySupportAcct.Type = 'Customer';
        incountrySupportAcct.Support_Type__c = GCSCommonConstants.PREMIUM_SUPPORT_PLUS_IN_COUNTRY;
        incountrySupportAcct.Support_Offering__c = GCSCommonConstants.PREMIUM_SUPPORT_PLUS + GCSCommonConstants.SEMI_COLON_STRING + GCSCommonConstants.UNITED_STATES;
        insert incountrySupportAcct;
        
        //Support Case for In-Country Account
        Case supportCase = new Case();
        supportCase.Subject = 'Test Support Case For In-Country Account';
        supportCase.Product_New__c = 'ZIA';
        supportCase.Status = 'New';
        supportCase.Priority = 'Medium (P2)';
        supportCase.Case_Type__c = 'Problem';
        supportCase.Preferred_Contact_Time_Zone__c = 'Pacific/Chatham';
        supportCase.Preferred_Method_of_Contact__c = 'Phone';
        supportCase.RecordTypeId = CASE_SUPPORT_RT_ID;
        supportCase.AccountId = incountrySupportAcct.Id;
        insert supportCase;
        
        //Support Case for Non In-Country Account
        Case supportCase1 = new Case();
        supportCase1.Subject = 'Test Support Case For Non In-Country Account';
        supportCase1.Product_New__c = 'ZIA';
        supportCase1.Status = 'New';
        supportCase1.Priority = 'Medium (P3)';
        supportCase1.Case_Type__c = 'Question';
        supportCase1.Preferred_Contact_Time_Zone__c = 'Pacific/Chatham';
        supportCase1.Preferred_Method_of_Contact__c = 'Phone';
        supportCase1.RecordTypeId = CASE_SUPPORT_RT_ID;
        insert supportCase1;
    }

    @IsTest
    Static void testDefconCreation() {
        String reason = 'testing';
        Boolean escalationOnBehalf = true;
        Test.StartTest();
            String caseId = [SELECT Id From Case WHERE RecordType.Name = :GCSCommonConstants.CASE_SUPPORT_RECORD_TYPE_NAME AND Subject = 'Test Support Case For Non In-Country Account' LIMIT 1].Id;
            DefconEscalationController.createDefcon(reason, escalationOnBehalf, caseId);
        Test.StopTest();
    }

    @IsTest
    Static void testDefconCreation2() {
        List<Case> supportCase = [SELECT Id, IsEscalated, CaseNUmber FROM Case WHERE RecordType.Name = :GCSCommonConstants.CASE_SUPPORT_RECORD_TYPE_NAME LIMIT 1];
        supportCase[0].IsEscalated = true;
        Update supportCase;

        //Escalation Case
        Case csEsc = new Case();
        csEsc.Subject = 'Defcon raised for ' + supportCase[0].CaseNumber;
        csEsc.Case_Escalated_per_Defcon_Process__c = true;
        csEsc.Status = 'New';
        csEsc.Escalation_Reason__c = 'Test Escalation';
        csEsc.Escalation_Category__c = 'Unsatisfied with current support';
        csEsc.ParentId = supportCase[0].Id;
        csEsc.Escalated_By__c = UserInfo.getUserId();
        csEsc.Defcon_Level__c = '4';
        csEsc.RecordTypeId = CASE_ESCALATION_RT_ID;
        csEsc.Root_Cause_for_DEFCON__c = 'Support Technical capability lacking';
        Insert csEsc;

        String reason='testing1';
        Boolean escalationOnBehalf=false;
        Test.StartTest();
            DefconEscalationController.createDefcon(reason, escalationOnBehalf, '');
        Test.StopTest();
    }

    @IsTest
    Static void testDefconCreation3() {
        List<Case> supportCase = [SELECT Id,IsEscalated,CaseNUmber From Case WHERE RecordType.Name = :GCSCommonConstants.CASE_SUPPORT_RECORD_TYPE_NAME LIMIT 1];
        supportCase[0].IsEscalated = true;
        Update supportCase;

        //Escalation Case
        Case csEsc = new Case();
        csEsc.Subject = 'Defcon raised for '+supportCase[0].CaseNumber;
        csEsc.Case_Escalated_per_Defcon_Process__c = true;
        csEsc.Status = 'New';
        csEsc.Escalation_Reason__c = 'Test Escalation';
        csEsc.Escalation_Category__c = 'Unsatisfied with current support';
        csEsc.ParentId = supportCase[0].Id;
        csEsc.Escalated_By__c = UserInfo.getUserId();
        csEsc.Defcon_Level__c = '4';
        csEsc.RecordTypeId = CASE_ESCALATION_RT_ID;
        csEsc.Root_Cause_for_DEFCON__c = 'Support Technical capability lacking';
        insert csEsc;
       
        String reason = 'testing1';
        Boolean escalationOnBehalf=false;
        Test.StartTest();
            String caseId = supportCase[0].Id;
            try{
                DefconEscalationController.createDefcon(reason, escalationOnBehalf, caseId);
            }Catch(AuraHandledException ex){
                System.debug('exception ' + ex.getMessage());
            }
        Test.StopTest();
    }

    @IsTest
    Static void testDefconCreationForIncountryAccount() {
        String reason = 'testing';
        Boolean escalationOnBehalf = true;
        Test.StartTest();
            String caseId = [SELECT Id From Case WHERE RecordType.Name = :GCSCommonConstants.CASE_SUPPORT_RECORD_TYPE_NAME AND Subject = 'Test Support Case For In-Country Account' LIMIT 1].Id;
            DefconEscalationController.createDefcon(reason, escalationOnBehalf, caseId);
        Test.StopTest();
    }
}