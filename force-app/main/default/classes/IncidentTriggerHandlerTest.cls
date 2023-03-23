@isTest
public class IncidentTriggerHandlerTest {
	@isTest
    static void testMethod_1() {
        Id cloudIncRecordTypeId = Schema.SObjectType.Incident.getRecordTypeInfosByDeveloperName().get('Cloud_Incident').getRecordTypeId();
        Incident inc = new Incident(Subject = 'Test Incident', priority = 'SEV-2', region__c = 'Global', recordTypeId = cloudIncRecordTypeId);
        insert inc;
    }

    @isTest
    static void testMethod_2() {
        Id cloudIncRecordTypeId = Schema.SObjectType.Incident.getRecordTypeInfosByDeveloperName().get('Cloud_Incident').getRecordTypeId();
        Incident inc = new Incident(Subject = 'Test Incident', priority = 'SEV-2', region__c = 'Global', recordTypeId = cloudIncRecordTypeId);
        insert inc;
        inc.CC_List__c += 'test@gmail.com';
        inc.Ticket_update__c = 'Test';
        inc.Customer_update__c = 'Test';
        inc.status = 'Resolved';
        try {
            update inc;
        }
        catch(Exception e) {
            System.debug(e.getMessage());
        }
    }
}