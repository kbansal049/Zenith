@isTest
public class genericKnowledgeTriggerTest {
	@isTest
    public static void checkUpdate(){
        List<Triggers_Switch__c> trLst = new List<Triggers_Switch__c>();
        Triggers_Switch__c ts = new Triggers_Switch__c(name = 'Execute_Knowledge_After_Trigger', Execute__c = true);
        trLst.add(ts);
        Triggers_Switch__c ts1 = new Triggers_Switch__c(name = 'Execute_CreateFeed_KB_Comment', Execute__c = true);
        trLst.add(ts1);
        Triggers_Switch__c ts2 = new Triggers_Switch__c(name = 'Execute_KBA_Before_Trigger', Execute__c = true);
        trLst.add(ts2);
        Triggers_Switch__c ts3 = new Triggers_Switch__c(name = 'Execute_UpdateKBComments', Execute__c = true);
        trLst.add(ts3);
        insert trLst;
        KB__kav kb = new KB__kav();
        kb.UrlName = 'test-url';
        kb.Title = 'test-url';
        kb.Article_Status__c = 'Draft';
        kb.Description__c = 'test desc';
        insert kb;
        
        kb.Article_Status__c = 'In Review';
        update kb;
        TriggerUtility.executeFeedFromKBCommentReset();
        kb.Article_Status__c = 'Draft';
        kb.Comments__c = 'Test Comment';
        update kb;
    }
}