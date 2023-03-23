@isTest
public class OneDocObjectiveWrapperTest {
	@isTest
    public static void testmethod1(){
        TriggerUtility.SkipAccTriggerExecuted();
        Account a = new Account(Name='TEST-Z1');
        insert a;
        
        Meeting__c mt = new Meeting__c(Date_of_meeting__c = System.now(), Next_meeting_Date__c=System.today(), Customer_Name__c = a.id,Duration__c = 15, Executive_Summary__c = 'Test');
        insert mt;
        Objective__c obj1 = new Objective__c();
        obj1.Measurable__c = 5;
        obj1.Calculations__c = 50.0;
        obj1.Meeting_ID__c = mt.Id;
        obj1.Plan__c = 50;
        obj1.TAM_Notes__c = 'Test TAM Notes';
        obj1.Visible_in_Doc__c = true;
        insert obj1;
        
        Test.startTest();
        OneDocObjectiveWrapper obj = new OneDocObjectiveWrapper();
        OneDocObjectiveWrapper.objWrapper objInternal = new OneDocObjectiveWrapper.objWrapper(1.1, 'test', true);
        Map<String, String> parameters = new Map<String, String>();
        parameters.put('Id', String.valueOf(mt.Id));
        obj.provide(parameters);
        Test.stopTest();
    }
}