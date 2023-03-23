@isTest
public class PrepareMySandboxTest {
    @isTest
    static void testSandboxPostCopyScript() {
		Account org = new Account(Name = 'org');
        Account sandbox = new Account(Name = 'sandbox');
        insert new Account[]{org, sandbox};

        Test.startTest();

        Test.testSandboxPostCopyScript(new PrepareMySandbox(), org.Id, sandbox.Id, 'Test');

        Test.stopTest();
    }

}