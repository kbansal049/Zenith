@isTest
public class CaseRelatedIssueTriggerHandlerTest {
	@TestSetup
    static void dataSetup() {
        Id caseSupportRT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Support').getRecordTypeId();
        User ur = TestDatafactory_Zscaler.insertAdminUser('2xyz@xyz.com', 'test12', 'test', 'ttest12', '2xyz@xyz.com.test', 'GMT', 'en_US', 'UTF-8', 'en_US');
        ur.skills__c = 'Premium Plus';
        update ur;
        TriggerUtility2.setPartnerDiscountExecuted();
        Account acct = new Account();
        acct.name = 'Test Account';
        acct.Type = 'Customer';
        acct.RecordTypeId = '01270000000EAFsAAO';
        acct.TAM_Name_New__c = UserInfo.getUserId();
        insert acct;
        System.runAs(ur){
            TriggerUtility.skipCaseEscalationReset();
            TriggerUtility.SyncBAOnCrReset();
            TriggerUtility.CaseCCtoTeamReset();
            TriggerUtility.UpdateTAMemailReset();
            TriggerUtility.UpdateSEonCaseReset();
            TriggerUtility.startUpdateCaseAccountExtension();
            TriggerUtility.caseCloseCompleteActionPlanSetFalse();
            TriggerUtility.TAMAgentWorkReset();
            TriggerUtility.CaseTAMNotesHistoryReset();
            TriggerUtility.startUpdateAccountDataTime();
            TriggerUtility.ManualCaseAssignReset();
            TriggerUtility.UpdateCSMonCaseReset();
            TriggerUtility.CaseSkillAssignmentReset();
            Case cs = new Case(Subject='test 1', AccountId =  acct.Id, Priority='Medium (P3)', RecordTypeId=caseSupportRT, Description='abcdDes', Case_type__c = 'Problem', Customer_CC_List__c='test@test.com;test2@test2.com',Status='New');
            insert cs;
            Case cs2 = new Case(Subject='test 2', AccountId =  acct.Id, Priority='Medium (P3)', RecordTypeId=caseSupportRT, Description='abcdDes', Case_type__c = 'Problem', Customer_CC_List__c='test@test.com;test2@test2.com',Status='New');
            insert cs2;
        }
        Id cloudIncRecordTypeId = Schema.SObjectType.Incident.getRecordTypeInfosByDeveloperName().get('Cloud_Incident').getRecordTypeId();
        Incident inc = new Incident(Subject = 'Test Incident', priority = 'SEV-2', region__c = 'Global', recordTypeId = cloudIncRecordTypeId);
        insert inc;
    }

    @isTest
    static void testMethod_1() {
        List<Case> cases = new List<Case>([SELECT id FROM Case]);
        List<Incident> incidents = new List<Incident>([SELECT id FROM Incident LIMIT 1]);
        List<CaseRelatedIssue> caseRelatedIssues = new List<caseRelatedIssue>();
        for(Case c : cases) {
            caseRelatedIssues.add(
                new CaseRelatedIssue(caseId = c.id, relatedIssueId = incidents.get(0).id)
            );
        }
        insert caseRelatedIssues;
    }
    
    @isTest
    static void testMethod_2() {
        List<Case> cases = new List<Case>([SELECT id FROM Case]);
        List<Incident> incidents = new List<Incident>([SELECT id FROM Incident LIMIT 1]);
        List<CaseRelatedIssue> caseRelatedIssues = new List<caseRelatedIssue>();
        for(Case c : cases) {
            caseRelatedIssues.add(
                new CaseRelatedIssue(caseId = c.id, relatedIssueId = incidents.get(0).id)
            );
        }
        insert caseRelatedIssues;
        delete caseRelatedIssues;
        incidents.get(0).status = 'Closed';
        update incidents.get(0);
        caseRelatedIssues = new List<CaseRelatedIssue>();
        for(Case c : cases) {
            caseRelatedIssues.add(
                new CaseRelatedIssue(caseId = c.id, relatedIssueId = incidents.get(0).id)
            );
        }
        try {
        	insert caseRelatedIssues;     
        }
        catch(Exception e) {
            System.debug('Error');
        }
    }

}