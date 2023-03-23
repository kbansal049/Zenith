@isTest
public class ServiceQualityAuditLWCCtrlTest {

    @isTest
    public static void Test1(){
        Id caseSupportRT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Support').getRecordTypeId();
        Account acct = new Account();
        acct.name = 'Test Account';
        acct.Type = 'Customer';
        insert acct;
        Case cs = new Case();
        cs.Subject='Test Subject';
        cs.AccountId=acct.Id;
        cs.Origin='Internal Agent';
        cs.RecordTypeId=caseSupportRT;
        cs.Description='Test Subject';
        cs.Case_Type__c='Problem';
        cs.Status = 'New';
        TriggerUtility.SkipCaseTriggerReset();
        insert cs;
        Survey__c sur=new Survey__c();
        sur.Case__c=cs.Id;
        insert sur;
        ServiceQualityAuditLWCCtrl.getSurveyRecords(cs.Id);
    }

    @isTest
    public static void Test2(){
        Account acct = new Account();
        acct.name = 'Test Account';
        acct.Type = 'Customer';
        insert acct;
        Meeting__c meet = new Meeting__c();
        meet.Customer_Name__c = acct.Id;
        meet.Date_of_meeting__c = System.now();
        meet.Executive_Summary__c = 'Test';
        meet.Status__c = 'Completed';
        insert meet;
        Survey__c sur=new Survey__c();
        sur.TAM_Meeting__c=meet.Id;
        insert sur;
        ServiceQualityAuditLWCCtrl.getTAMAuditRecords(meet.Id);
    }
}