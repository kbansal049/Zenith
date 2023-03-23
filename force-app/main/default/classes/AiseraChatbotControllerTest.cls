@isTest
public class AiseraChatbotControllerTest {
    public static testMethod void testClass(){
        Customer_Portal_Session_Id__c cs=new Customer_Portal_Session_Id__c();
        Test.StartTest();
        //AiseraChatbotController.accessChatbot();
        AiseraChatbotController.getUserDetails();
        AiseraChatbotController.getUserTimezone();
        //AiseraChatbotController.createCaseEnabled();
        //AiseraChatbotController.getSessionCustomSettings();
        Test.StopTest();
    }    
}