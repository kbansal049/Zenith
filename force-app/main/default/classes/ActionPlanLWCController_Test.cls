@isTest
public class ActionPlanLWCController_Test {
    static testmethod void test1(){
		TriggerUtility.SkipAccTriggerExecuted();
        Account a = new Account(Name='TEST-Z1');
        insert a;
        ActionPlanLWCController.updateAllInDoc(new List<Sobject>{a});
        TriggerUtility.SkipCaseTriggerExecuted();
        Id caseSupportRT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Support').getRecordTypeId();
        Case cs = new Case();
        cs.Subject='Test Subject';
        cs.AccountId=a.Id;
        cs.Origin='Internal Agent';
        cs.RecordTypeId=caseSupportRT;
        cs.Description='Test Subject';
        cs.Case_Type__c='Problem';
        cs.Status = 'New';
        cs.Visible_In_Doc__c = false;
        insert cs;
        ActionPlanLWCController.updateAllInDoc(new List<Sobject>{cs});
    }
    
}