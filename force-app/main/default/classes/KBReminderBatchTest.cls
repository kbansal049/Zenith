@IsTest
public class KBReminderBatchTest {
    @testSetup
    static void setup() {
        Triggers_Switch__c setting = new Triggers_Switch__c();
        setting.Name = 'KnowledgeTrigger';
        setting.Object_Name__c = 'KB__kav';
        setting.Execute__c = true;
        insert setting;
        Account acct = new Account();
        acct.name = 'Test Account 1';
        acct.Type = 'Customer';
        acct.RecordTypeId = '01270000000EAFsAAO';
        insert acct;
        
        Contact con = new Contact();
        con.AccountId = acct.Id;
        con.LastName = 'Test Contact';
        insert con;
    }
    @isTest
    static void Test(){
        List<KB__kav> kbList=new List<KB__kav>();
        KB__kav kb1 = new KB__kav();
        kb1.UrlName = 'test-url';
        kb1.Title = 'test-url';
        kbList.add(kb1);
        KB__kav kb2 = new KB__kav();
        kb2.UrlName = 'test-url4';
        kb2.Title = 'test-url4';
        kbList.add(kb2);
        insert kbList;
        kb2.validationStatus='Ready for Tech Review';
        update kb2;
        kb2.ready_for_Tech_review_Timestamp__c=DateTime.Now().AddDays(-7);
        update kb2;
        
        KBRemindersBatch batch=new KBRemindersBatch('SELECT id,validationStatus,PublishStatus,CreatedDate,ready_for_Tech_review_Timestamp__c,CreatedBy.Email,Owner_s_Manager__c,Owner_s_Manager_Email__c,Owner.Email,Reassigned_To_Manager__c FROM KB__kav WHERE validationStatus IN (\'Draft\',\'Ready for Tech Review\')');
    	Database.executeBatch(batch);
    }
}