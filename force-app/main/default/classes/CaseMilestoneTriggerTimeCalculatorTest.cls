@isTest
public class CaseMilestoneTriggerTimeCalculatorTest {
	@isTest
    public static void test1(){
        Id caseSupportRT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Support').getRecordTypeId();
        Case cs = new Case(Subject='abcd', Priority='High (P2)', RecordTypeId=caseSupportRT, Description='abcdDes', Case_type__c = 'Problem',Status = 'New',origin='Support Portal',Preferred_Contact_Time_Zone__c='Asia/Kolkata');
        cs.Preferred_Contact_Time_Zone__c = 'Asia/Kolkata';
        cs.Contact_Time_Slot__c = '16:00 - 18:00';
        insert cs;
        Test.startTest();
        CaseMilestoneTriggerTimeCalculator clsInst = new CaseMilestoneTriggerTimeCalculator();
        Integer currr = clsInst.calculateMilestoneTriggerTime(cs.Id, null);
        cs.Preferred_Contact_Time_Zone__c = 'America/Los_Angeles';
        cs.Contact_Time_Slot__c = '12:00 - 14:00';
        update cs;
        Integer currr2 = clsInst.calculateMilestoneTriggerTime(cs.Id, null);
        Test.stopTest();
    }
}