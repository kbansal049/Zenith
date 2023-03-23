public class KnowledgeTriggerUtility {
    public static void createFeedCommentForKBComment(List<KB__kav> newList, Map<Id, KB__kav> oldMap){
        List<FeedItem> listOfFeedItemInsert = new List<FeedItem>();
        for(KB__kav kb : newList){
            if(kb.Comments__c != null && kb.Article_Status__c!=oldMap.get(kb.Id).Article_Status__c && kb.Article_Status__c == 'Draft' && oldMap.get(kb.Id).Comments__c==null /*&& (oldMap.get(kb.Id).Article_Status__c=='In Review' || oldMap.get(kb.Id).Article_Status__c=='Approved')*/){
                FeedItem fi = new FeedItem();
                String str = kb.Comments__c;
                str = str.replaceAll('<br>', '<p></p>');
                fi.Body = str;
                fi.Visibility = 'InternalUsers';
                fi.ParentId = Kb.KnowledgeArticleId;
                fi.IsRichText = true;
                listOfFeedItemInsert.add(fi);
            }
            else{
                if(kb.Comments__c != null && kb.Comments__c != oldMap.get(kb.Id).Comments__c){
                    kb.addError(Label.Knowledge_Comment_Error);
                }
            }
        }
        if(!listOfFeedItemInsert.isEmpty()){
            TriggerUtility.SkipFeedItemTriggerExecuted();
            insert listOfFeedItemInsert;
        }
        TriggerUtility.executeFeedFromKBCommentExecuted();
    }
    
    public static void updateComments(List<KB__kav> newList, Map<Id, KB__kav> oldMap){
        for(KB__kav kb : newList){
            if(kb.Article_Status__c!=oldMap.get(kb.Id).Article_Status__c && kb.Article_Status__c != 'Draft' && kb.Comments__c!=null){
                kb.Comments__c = null;
            }
        }
    }
}