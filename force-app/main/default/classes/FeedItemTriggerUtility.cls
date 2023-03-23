public class FeedItemTriggerUtility {
    public static void beforeInsert(List<FeedItem> newList){
        Map<String, Triggers_Switch__c> tsmap = Triggers_Switch__c.getAll();
        if(tsmap.containsKey('Execute_FeedItem_Internal') && tsmap.get('Execute_FeedItem_Internal') != null && tsmap.get('Execute_FeedItem_Internal').Execute__c && !TriggerUtility.isFeedItemInternalPostExecuted()){
            updateVisibilitytoInternal(newList);
        }
        TriggerUtility.FeedItemBeforeTriggerExecuted();
    }
    public static void afterInsert(List<FeedItem> newList){
        Map<String, Triggers_Switch__c> tsmap = Triggers_Switch__c.getAll();
        if(tsmap.containsKey('Execute_FRT_CustomerNoteAdded') && tsmap.get('Execute_FRT_CustomerNoteAdded') != null && tsmap.get('Execute_FRT_CustomerNoteAdded').Execute__c && !TriggerUtility.isFRTandCustomerNoteExecuted()){
            updateCustomerNote(newList);
        }
        
         //Added by Anup CR#1202 - Start
        if(tsmap.containsKey('Execute_UpdateKnowledgeComment') && tsmap.get('Execute_UpdateKnowledgeComment') != null && tsmap.get('Execute_UpdateKnowledgeComment').Execute__c){
            updateKnowledgeComment(newList);
        }
        //Added by Anup CR#1202 - End
        
        TriggerUtility.FeedItemAfterTriggerExecuted();
    }
    public static void updateCustomerNote(List<FeedItem> filst){
        Set<Id> CaseIds = new Set<Id>();
        Set<Id> caseIdstoupdate = new Set<Id>();
        List<Case> casetoudpate = new List<case>();
        Set<Id> usrIds = new Set<Id>();
        for(FeedItem cc: filst){
            if(cc.ParentId != null && Schema.Case.SObjectType == cc.ParentId.getSobjectType()){
                CaseIds.add(cc.ParentId);
                usrIds.add(cc.InsertedById);
            }
        }
        Map<Id, case> csmap = new Map<Id, Case>([select id, status, First_Response_Timestamp__c,Customer_Commented__c from Case where Id in :CaseIds and Recordtype.Developername = 'Support']);
        Map<Id, User> usrinf = new Map<Id, USer>([Select Id, profile.name, service_Level__c, ContactId from User where Id = :usrIds]);
        for(FeedItem cc: filst){
            if(!csmap.isEmpty() && csmap.containsKey(cc.ParentId) && usrinf != null && !usrinf.isEmpty() && usrinf.containsKey(cc.InsertedById) && usrinf.get(cc.InsertedById).ContactId != null && (cc.Type == 'TextPost' || cc.Type == 'LinkPost' || cc.Type == 'ContentPost')){
                csmap.get(cc.ParentId).Status = 'Customer Note Added';
                csmap.get(cc.ParentId).Customer_Commented__c = true;
                casetoudpate.add(csmap.get(cc.ParentId));
            }
        }
        if(!casetoudpate.isEmpty()){
            TriggerUtility.skipCaseEscalationExecuted();
            TriggerUtility.CaseEscalationNotesExecuted();
            TriggerUtility.CaseEscalationHistoryExecuted();
            TriggerUtility.ManualSLAExecuted();
            update casetoudpate;
        }

        TriggerUtility.FRTandCustomerNoteExecuted();
    }
    public static void updateVisibilitytoInternal(List<FeedItem> filst){
        Set<Id> CaseIds = new Set<Id>();
        Set<Id> usrIds = new Set<Id>();

        for(FeedItem cc: filst){
            if(cc.ParentId != null && Schema.Case.SObjectType == cc.ParentId.getSobjectType()){
                CaseIds.add(cc.ParentId);
            }
        }
        Map<Id, case> csmap = new Map<Id, Case>([select id, status, First_Response_Timestamp__c from Case where Id in :CaseIds and Recordtype.Developername = 'Support']);
        Map<Id, User> usrinf = new Map<Id, USer>([Select Id, profile.name, service_Level__c, ContactId from User where Id = :UserInfo.getUserId()]);
        for(FeedItem cc: filst){
            if(usrinf != null && !usrinf.isEmpty()  && usrinf.containsKey(UserInfo.getUserId()) && usrinf.get(UserInfo.getUserId()).Service_Level__c != null && cc.Visibility == 'AllUsers' && (cc.Type == 'TextPost' || cc.Type == 'LinkPost' || cc.Type == 'ContentPost')){
                cc.Visibility = 'InternalUsers';
            }
        }
        
        TriggerUtility.FeedItemInternalPostExecuted();
    }
    
    //Added by Anup : CR#1202 - Start
    public static void updateKnowledgeComment(List<FeedItem> newList){
        Map<Id, String> mapOfKnowledgeAndComment = new Map<Id, String>();
        String str;
        for(FeedItem fd : newList){
            if(fd.ParentId != null && String.valueOf(fd.ParentId.getSobjectType()) == 'KB__ka'){
                mapOfKnowledgeAndComment.put(fd.ParentId, fd.Body);
            }
        }
        
        if(!mapOfKnowledgeAndComment.isEmpty()){
            List<KB__kav> listOfKnowledgeVersion = [select Id,KnowledgeArticleId, Comments__c from KB__kav where KnowledgeArticleId IN:mapOfKnowledgeAndComment.Keyset() and isLatestVersion=true and PublishStatus = 'Draft'];
            
            for(KB__kav kver : listOfKnowledgeVersion){
                if(mapOfKnowledgeAndComment.containsKey(kver.KnowledgeArticleId)){
                    str = mapOfKnowledgeAndComment.get(kver.KnowledgeArticleId);
                    kver.Comments__c =str.replaceAll('<br />','\n');
                }
            }
            if(!listOfKnowledgeVersion.isEmpty()){
                //Database.update(listOfKnowledgeVersion, false);
                //Added By Anup : CR#1770 - Start
                TriggerUtility.executeFeedFromKBCommentExecuted();
                //Added By Anup : CR#1770 - End
                Database.update((sObject[])listOfKnowledgeVersion, false);
                
            }
        }
    }
    //Added by Anup : CR#1202 - End
}