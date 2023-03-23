@isTest
public class KBReminderTest {

    @testSetup
    static void setup() {
        Triggers_Switch__c setting = new Triggers_Switch__c();
        setting.Name = 'KnowledgeTrigger';
        setting.Object_Name__c = 'KB__kav';
        setting.Execute__c = true;
        insert setting;
        List<KB__kav> knowledgeList = new List<KB__kav>();
        for(Integer i = 0; i < 10; i++) {
            Integer randomNumber = Integer.valueof((Math.random() * 100));
            knowledgeList.add(new KB__kav(title = 'Test'+i+randomNumber, UrlName = 'Test'+i+randomNumber,Summary = 'Test Summary'+i,Product_Applicable__c='ZIA'));
        }
        insert knowledgeList;
        Account testSetacct = new Account();
        testSetacct.name = 'Test Account';
        testSetacct.Type = 'Customer';
        testSetacct.RecordTypeId = '01270000000EAFsAAO';
        insert testSetacct;
        Contact testSetcon = new Contact();
        testSetcon.AccountId = testSetacct.Id;
        testSetcon.LastName = 'Test Contact';
        testSetcon.Email = 'contact@customer.com';
        insert testSetcon;       
    }

    @isTest
    static void Test(){
        KBReminder.callKBReminderBatch();
    }

}