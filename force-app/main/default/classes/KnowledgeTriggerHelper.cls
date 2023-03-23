public class KnowledgeTriggerHelper {
    public static void afterUpdate(List<KB__kav> newList, Map<Id, KB__kav> oldMap){
        Map<String, Triggers_Switch__c> tsmap = Triggers_Switch__c.getAll();
        if(tsmap != null && !tsmap.isEmpty() && tsmap.containsKey('Execute_CreateFeed_KB_Comment') && tsmap.get('Execute_CreateFeed_KB_Comment') != null && tsmap.get('Execute_CreateFeed_KB_Comment').Execute__c && !TriggerUtility.isexecuteFeedFromKBCommentExecuted()){
            KnowledgeTriggerUtility.createFeedCommentForKBComment(newList, oldMap);
        }
    }
    public static void beforeUpdate(List<KB__kav> newList, Map<Id, KB__kav> oldMap){
        Map<String, Triggers_Switch__c> tsmap = Triggers_Switch__c.getAll();
        if(tsmap != null && !tsmap.isEmpty() && tsmap.containsKey('Execute_UpdateKBComments') && tsmap.get('Execute_UpdateKBComments') != null && tsmap.get('Execute_UpdateKBComments').Execute__c){
            KnowledgeTriggerUtility.updateComments(newList, oldMap);
        }
    }
}