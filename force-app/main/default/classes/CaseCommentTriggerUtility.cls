public class CaseCommentTriggerUtility {
    public static void afterInsert(List<CaseComment> newList){
        Map<String, Triggers_Switch__c> tsmap = Triggers_Switch__c.getAll();
        if(tsmap.containsKey('Execute_FRT_CustomerNoteAdded') && tsmap.get('Execute_FRT_CustomerNoteAdded') != null && tsmap.get('Execute_FRT_CustomerNoteAdded').Execute__c && !TriggerUtility.isFRTandCustomerNoteExecuted()){
            updateFRTandCustomerNote(newList);
        }
        TriggerUtility.CaseCommentAfterInsertExecuted();
    }
    public static void beforeInsert(List<CaseComment> newList){
        Map<String, Triggers_Switch__c> tsmap = Triggers_Switch__c.getAll();
        if(tsmap.containsKey('Execute_CustomerNoteAdded') && tsmap.get('Execute_CustomerNoteAdded') != null && tsmap.get('Execute_CustomerNoteAdded').Execute__c && !TriggerUtility.isCustomerNotePublicExecuted()){
            updatePubliconCustomerNote(newList);
        }
        
        TriggerUtility.CaseCommentBeforeInsertExecuted();
    }
    public static void updateFRTandCustomerNote(List<CaseComment> cclst){
        Set<Id> CaseIds = new Set<Id>();
        Set<Id> caseIdstoupdate = new Set<Id>();
        List<Case> casetoudpate = new List<case>();
        for(CaseComment cc: cclst){
            CaseIds.add(cc.ParentId);
        }
        Map<Id, case> csmap = new Map<Id, Case>([select id, status, First_Response_Timestamp__c from Case where Id in :CaseIds and Recordtype.Developername = 'Support']);
        List<User> usrinf = [Select Id, profile.name, service_Level__c, ContactId from User where Id = :Userinfo.getUserId()];
        for(CaseComment cc: cclst){
            if(!usrinf.isEmpty() && usrinf[0].Service_Level__c != null && cc.IsPublished && !csmap.isEmpty() && csmap.containsKey(cc.ParentId) && csmap.get(cc.ParentId).First_Response_Timestamp__c == null){
                caseIdstoupdate.add(cc.ParentId);
            }else if(!csmap.isEmpty() && csmap.containsKey(cc.ParentId) && !usrinf.isEmpty() && usrinf[0].ContactId != null){
                csmap.get(cc.ParentId).Status = 'Customer Note Added';
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
        
        if(!caseIdstoupdate.isEmpty()){
            TriggerUtility.CaseBeforeUpdateExecuted();
            TriggerUtility.CaseAfterUpdateExecuted();
            MilestoneUtils.completeMilestone(caseIdstoupdate, 'First Response', System.now());
        }
        TriggerUtility.FRTandCustomerNoteExecuted();
    }
    public static void updatePubliconCustomerNote(List<CaseComment> cclst){
        
        List<User> usrinf = [Select Id, profile.name, service_Level__c, ContactId from User where Id = :Userinfo.getUserId()];
        for(CaseComment cc: cclst){
            if(!usrinf.isEmpty() && usrinf[0].ContactId != null){
                cc.isPublished = true;
            }
        }
        
        TriggerUtility.CustomerNotePublicExecuted();
        
    }
	
}