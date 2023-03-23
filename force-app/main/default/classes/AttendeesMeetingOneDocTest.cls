@istest
public class AttendeesMeetingOneDocTest {

    @isTest(SeeallData=true)
    public static void testMethod1(){
        
        TriggerUtility.SkipAccTriggerExecuted();
        Account a = new Account(Name='TEST-Z1');
        insert a;
        
        TriggerUtility.SkipContactTriggerExecuted();
        Contact con1 = new Contact();
        con1.AccountId = a.id;
        con1.lastname = 'Test2';
        con1.firstname = 'Test2';
        con1.Email='test@test.com';
        insert con1;
        
        Case cs = new Case(AccountId = a.id, Description='Test Desc');
        insert cs;
        
        Meeting__c mt = new Meeting__c(Date_of_meeting__c = System.now(), Participants__c = 'test@test.com',Customer_Name__c = a.id,Duration__c = 15, Executive_Summary__c = 'Test');
        insert mt;
        

        Meeting__c mt2 = new Meeting__c(Date_of_meeting__c = System.now(), Participants__c = UserInfo.getUserEmail(),Customer_Name__c = a.id,Duration__c = 15, Executive_Summary__c = 'Test');
        insert mt2;
        
        generateOneDocController.generateOneDocForMeeting(mt.id);
        generateOneDocForAccountController.generateOneDocForAccount(a.id);//Added by Varun- CR 1048
        generateOneDocController.generateOneDocForMeeting(mt2.id);

        MAP<String,String> params = new MAP<String,String>();
        
        params.put('Id', mt.id);
        new AttendeesMeetingOneDoc().provide(params);
        new OneDocObjectiveWrapper().provide(params);
        
        Action_Plan__c ap =new Action_Plan__c();
        ap.Case__c = cs.id;
        ap.Customer__c = a.id;
        ap.Detail_TAM_Notes__c = 'Test';
        ap.Status__c = 'Completed';
        ap.Meeting__c = mt.id;
        ap.Visible_in_Doc__c = True;//added by Swathi : CR#1476 
        ap.Completion_Date__c = system.today().addDays(-5);
        insert ap;
        
        new ActionPlan_ClosedThisMeeting_OneDoc().provide(params);
        
        ap.Status__c = '';
        update ap;
        new ActionPlan_OpenThisMeeting_OneDoc().provide(params); 


        Meeting__c mt1 = new Meeting__c(Date_of_meeting__c = System.now(), Participants__c = UserInfo.getUserEmail(),Customer_Name__c = a.id,Duration__c = 15, Executive_Summary__c = 'Test');
        insert mt1;
        params.put('Id', mt1.id);
        new ActionPlan_OpenPreviousMeeting_OneDoc().provide(params); 
        
        new MeetingInfoOneDoc().provide(params); 
    }
}