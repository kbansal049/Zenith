@isTest
public class NextMeetingInfoOneDocTest {
	@isTest
    public static void testmethod1(){
        TriggerUtility.SkipAccTriggerExecuted();
        Account a = new Account(Name='TEST-Z1');
        insert a;
        
        /*TriggerUtility.SkipContactTriggerExecuted();
        Contact con1 = new Contact();
        con1.AccountId = a.id;
        con1.lastname = 'Test2';
        con1.firstname = 'Test2';
        insert con1;
        
        
        Case cs = new Case(AccountId = a.id, Description='Test Desc');
        insert cs;*/
        
        
        Meeting__c mt = new Meeting__c(Date_of_meeting__c = System.now(), Next_meeting_Date__c=System.today(), Customer_Name__c = a.id,Duration__c = 15, Executive_Summary__c = 'Test');
        insert mt;
        Map<String, String> mapOfId = new Map<String, String>();
        mapOfId.put('Id',mt.Id);
        NextMeetingInfoOneDoc nextMeet = new NextMeetingInfoOneDoc();
        Object obj = nextMeet.provide(mapOfId);
    }
}