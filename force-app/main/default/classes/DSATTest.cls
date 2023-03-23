@isTest
public class DSATTest {
    
    static testMethod void testMethod1()
    {
        Account testAccount = new Account();
        testAccount.Name = 'Test';
        insert testAccount;
            
        inspire1__Project__c testProject = new inspire1__Project__c();
        testProject.Name = 'Test';
        testProject.inspire1__Account__c = testAccount.Id;
        insert testProject;
        
        Case testCase= new Case();
        testCase.How_can_we_make_you_happier__c = '1';
        testCase.Project__c = testProject.Id; 
        testCase.Easy_to_handle_issue__c= '1';
        testCase.One_thing_we_could_do_to_make_it_easy__c = 'test';
        insert testCase;
        Test.startTest();
        DSAT dsatInstance = new DSAT();
        dsatInstance.CaseId1 = String.valueOf(testCase.id);
        Case dsatCase = dsatInstance.getER();
        test.stopTest();
    }
    
}