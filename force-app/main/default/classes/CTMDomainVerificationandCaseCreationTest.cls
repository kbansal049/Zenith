//Added by Varun - CR 1061
@isTest
public class CTMDomainVerificationandCaseCreationTest {

    @isTest
    public static void testMethod1(){
        Id caseSupportRT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Support').getRecordTypeId();
        Account account = TestDatafactory_Zscaler.insertAccount('Test Account', 'vdua@zscaler.com', 'test', null, null, 5);
        Account account2 = TestDatafactory_Zscaler.insertAccount('Test Account 2', 'vdua@zscaler.com', 'test', null, null, 5);
        Case  cs = TestDatafactory_Zscaler.insertCase('status', 'subject',  'description',  account.Id, null, account.Id, caseSupportRT);        
        account.Additional_Organization_Domains__c ='https://www.google.com';
        account.Override_CTM_Domain__c = true;
        account2.Domain__c = 'https://www.google.com';
        account2.Override_CTM_Domain__c = true;
        update Account;
        update Account2;
        Test.startTest();
        Boolean check =CTMDomainVerificationandCaseCreation.checkdomain(account.Id,'google');
        Boolean check2 =CTMDomainVerificationandCaseCreation.checkdomain(account2.Id,'yahoo');
        Boolean check3 =CTMDomainVerificationandCaseCreation.checkdomain(account2.Id,'google');
        String str =CTMDomainVerificationandCaseCreation.createCase(account.Id, account.Name, cs.Id, 'contactname');
        
        System.assertEquals(true, check);
        Test.stopTest();
    }
}