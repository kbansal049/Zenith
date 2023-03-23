@isTest
public class SearchControllerTest {
    
    @isTest
    public static void testWorkflowOptimization(){
        User testUser = new User(LastName = 'TestUser',  Email = 'test@zscaler.com', Username = 'testuser@zscaler.com', alias = 'testaaa', timezonesidkey = 'America/Los_Angeles', LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US', EmailEncodingKey='ISO-8859-1', ProfileId = [SELECT Id FROM Profile WHERE  Name = 'System Administrator' LIMIT 1][0].Id/*, ContactId = [SELECT Id FROM Contact LIMIT 1][0].Id*/);
        testUser.FirstName='Test';
        insert testUser;
        
        Account acctTest = new Account(Name = 'Test Account',Sales_Engineer__c=testUser.id,Type='Prospect');
        insert acctTest;
        
        Test.startTest();
        
        List<String> fields = new  List<String>{'Name','AccountNumber'};
            SearchController.search('Account', fields, 'Acc' , 'where Type=\'Prospect\' ');
        SearchController.searchBasedOnID('Account', fields, acctTest.id);
            Test.stoptest();
    }
    
}