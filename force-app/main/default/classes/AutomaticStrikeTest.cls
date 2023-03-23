@isTest
public class AutomaticStrikeTest {

    @isTest
    static void Test2(){
        List<Triggers_Switch__c> trlst = new List<Triggers_Switch__c>();
        trlst.add(new Triggers_Switch__c(name = 'Execute_Case_Trigger', Execute__c = true));
        insert trlst;
        Id caseSupportRT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Support').getRecordTypeId();
        User ur = TestDatafactory_Zscaler.insertAdminUser('2xyz@xyz.com', 'test12', 'test', 'ttest12', '2xyz@xyz.com.test', 'GMT', 'en_US', 'UTF-8', 'en_US');
        Account acct = new Account();
        acct.name = 'Test Account';
        acct.Type = 'Customer';
        acct.RecordTypeId = '01270000000EAFsAAO';
        insert acct;
        Contact con = new Contact();
        con.AccountId = acct.Id;
        con.LastName = 'Test Contact';
        con.Email='customercontact@contact.com';
        insert con;
        Case cs2 = new Case();
        cs2.Subject='Test Subject 2';
        cs2.OwnerId=ur.id;
        cs2.AccountId=acct.Id;
        cs2.Origin='Internal Agent';
        cs2.RecordTypeId=caseSupportRT;
        cs2.Description='Test Subject 2';
        cs2.ContactId=con.id;
        cs2.Case_Type__c='Problem';
        cs2.Status = 'Pending Customer';
        cs2.Internal_CC_List__c='test@test.com';
        cs2.Customer_CC_List__c='customer@customer.com';
        cs2.Pending_Customer_Timestamp__c=DateTime.Now().AddDays(-13);
        cs2.X3_Strike_Policy__c=false;
        insert cs2;
        Test.StartTest();
        AutomaticStrike.callAutomaticStrikeBatch();
        Test.StopTest();
    }
    @isTest
    static void Test3(){
        List<Triggers_Switch__c> trlst = new List<Triggers_Switch__c>();
        trlst.add(new Triggers_Switch__c(name = 'Execute_Case_Trigger', Execute__c = true));
        insert trlst;
        Id caseSupportRT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Support').getRecordTypeId();
        User ur = TestDatafactory_Zscaler.insertAdminUser('2xyz@xyz.com', 'test12', 'test', 'ttest12', '2xyz@xyz.com.test', 'GMT', 'en_US', 'UTF-8', 'en_US');
        Account acct = new Account();
        acct.name = 'Test Account';
        acct.Type = 'Customer';
        acct.RecordTypeId = '01270000000EAFsAAO';
        insert acct;
        Contact con = new Contact();
        con.AccountId = acct.Id;
        con.LastName = 'Test Contact';
        con.Email='customercontact@contact.com';
        insert con;
        Case cs3 = new Case();
        cs3.Subject='Test Subject 3';
        cs3.OwnerId=ur.id;
        cs3.AccountId=acct.Id;
        cs3.Origin='Internal Agent';
        cs3.RecordTypeId=caseSupportRT;
        cs3.Description='Test Subject 3';
        cs3.ContactId=con.id;
        cs3.Case_Type__c='Problem';
        cs3.Status = 'Pending Customer';
        cs3.Internal_CC_List__c='test@test.com';
        cs3.Customer_CC_List__c='customer@customer.com';
        cs3.Pending_Customer_Timestamp__c=DateTime.Now().AddDays(-16);
        cs3.X3_Strike_Policy__c=false;
        insert cs3;
        Test.StartTest();
        AutomaticStrike.callAutomaticStrikeBatch();
        Test.StopTest();
    }
    
}