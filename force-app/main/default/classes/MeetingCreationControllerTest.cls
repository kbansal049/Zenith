@isTest
public class MeetingCreationControllerTest{

    @isTest
    public static void testmethod1(){
        TriggerUtility.SkipAccTriggerExecuted();
        Account a = new Account(Name='TEST-Z1');
        insert a;
        
        TriggerUtility.SkipContactTriggerExecuted();
        Contact con1 = new Contact();
        con1.AccountId = a.id;
        con1.lastname = 'Test2'; 
        con1.firstname = 'Test2';
        insert con1;
        
        
        Case cs = new Case(AccountId = a.id, Description='Test Desc');
        insert cs;
        
        
        Meeting__c mt = new Meeting__c(Date_of_meeting__c = System.now(), Customer_Name__c = a.id,Duration__c = 15, Executive_Summary__c = 'Test');
        insert mt;
        
        mt.Duration__c = 20;
        update mt;
        
        MeetingTriggerHandler.afterInsert(null);
        MeetingTriggerHandler.beforeUpdate(null,null);
        MeetingTriggerHandler.afterUpdate(null,null,null);
        
        Event ev = new Event(subject='test',peopleai__Participants__c='test@testmail.com',
                             StartDateTime = system.now(), EndDateTime = system.now().addminutes(20),
                             DurationInMinutes = 20);
        insert ev;
        
        MeetingCreationController.getInfo(ev.id);
    }
}