@isTest
public class CaseCapacityMilestoneTimeTriggerTest {
	@isTest
    public static void test1(){
        Id caseSupportRT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Support').getRecordTypeId();
        Case cs = new Case(Subject='abcd', Priority='High (P2)', RecordTypeId=caseSupportRT, Description='abcdDes', Case_type__c = 'Problem',Status = 'New',origin='Support Portal',Preferred_Contact_Time_Zone__c='Asia/Kolkata');
        insert cs;
        
        Case cs1 = new Case(Subject='abcd', Priority='Urgent (P1)', RecordTypeId=caseSupportRT, Description='abcdDes', Case_type__c = 'Problem',Status = 'New',origin='Support Portal',Preferred_Contact_Time_Zone__c='Asia/Kolkata');
        insert cs1;
        
        Case cs2 = new Case(Subject='abcd', Priority='Medium (P3)', RecordTypeId=caseSupportRT, Description='abcdDes', Case_type__c = 'Problem',Status = 'New',origin='Support Portal',Preferred_Contact_Time_Zone__c='Asia/Kolkata');
        insert cs2;
        
        Case cs3 = new Case(Subject='abcd', Priority='Low (P4)', RecordTypeId=caseSupportRT, Description='abcdDes', Case_type__c = 'Problem',Status = 'New',origin='Support Portal',Preferred_Contact_Time_Zone__c='Asia/Kolkata');
        insert cs3;
        
        Test.startTest();
        CaseCapacityMilestoneTimeTrigger clsInst = new CaseCapacityMilestoneTimeTrigger();
        Integer currr = clsInst.calculateMilestoneTriggerTime(cs.Id, null);
        Integer currr1 = clsInst.calculateMilestoneTriggerTime(cs1.Id, null);
        Integer currr2 = clsInst.calculateMilestoneTriggerTime(cs2.Id, null);
        Integer currr3 = clsInst.calculateMilestoneTriggerTime(cs3.Id, null);
        Test.stopTest();
    }
}