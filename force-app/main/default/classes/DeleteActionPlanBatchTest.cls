@isTest
public class DeleteActionPlanBatchTest {
    @isTest 
    public static void deleteActionPlan(){
        User ur = TestDatafactory_Zscaler.insertAdminUser('2xyz@xyz.com', 'test12', 'test', 'ttest12', '2xyz@xyz.com.test', 'GMT', 'en_US', 'UTF-8', 'en_US');
        Action_Plan__c action=new Action_Plan__c();
        action.Name='Test Action Plan';
        action.Owner__c=ur.Id;
        action.Due_Date__c = system.today().addDays(-180);
        insert action;
        Test.startTest();
        DeleteActionUpdateHandler.updateActionPlan();
        Test.stopTest();
    }
}