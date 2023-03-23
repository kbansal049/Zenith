@isTest 
public class EmailUtilityTest {
    public static final String TEST_EMAIL_ID = 'test@gmail.com';
    @isTest
    static void test_EmailUtility(){
        String flowName = 'Optimized Create Project when Opportunity in Stage 6';      
        Zscaler_Error_Logs__c errorlog = new Zscaler_Error_Logs__c( Class_Name__c = flowName,
                                                                   Error_in__c = 'Flow',
                                                                   Error_Type__c= 'test',
                                                                   Stack_Trace_String__c = 'error');
        insert errorlog;
        Test.startTest();
        String emailConfig = 'Project_Creation_Failed'; 
        EmailUtility utility = new EmailUtility(emailConfig);
        Messaging.SingleEmailMessage mail = utility.prepareEmail(errorlog.Id);
        Messaging.SingleEmailMessage mail1 = utility.prepareEmail(new List<String>{TEST_EMAIL_ID},new List<String>{TEST_EMAIL_ID}, errorlog.Id);
        Messaging.SingleEmailMessage mail2 = utility.prepareEmail(errorlog.Id,'Test');
        Messaging.SingleEmailMessage mail3 = utility.prepareEmail(new List<String>{TEST_EMAIL_ID},errorlog.Id);
        Messaging.SingleEmailMessage mail4 = utility.prepareEmailWithCustomSubject(new List<String>{TEST_EMAIL_ID},new List<String>{TEST_EMAIL_ID}, errorlog.Id,'test');
        utility.sendEmails(new List<Messaging.SingleEmailMessage>{mail1});
        Test.stopTest();
        system.assert(mail != null);
        system.assert(mail1 != null);
        system.assert(mail2 != null);
        system.assert(mail3 != null);
        system.assert(mail4 != null);
    }
    
}