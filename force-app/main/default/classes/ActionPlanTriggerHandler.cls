public class ActionPlanTriggerHandler {
    public static void beforeInsert(List<Action_Plan__c> newList){
        Map<String, Triggers_Switch__c> tsmap = Triggers_Switch__c.getAll();
        if(tsmap.containsKey('Execute_AP_Owner_Defaulting') && tsmap.get('Execute_AP_Owner_Defaulting') != null && tsmap.get('Execute_AP_Owner_Defaulting').Execute__c && !TriggerUtility.isOwnerDefaultLogicExecuted()){
            ActionPlanTriggerUtility.copyowner(newList, null);
        }
        if(tsmap.containsKey('Execute_AP_CompletionDate') && tsmap.get('Execute_AP_CompletionDate') != null && tsmap.get('Execute_AP_CompletionDate').Execute__c && !TriggerUtility.isupdateCompletionDateExecuted()){
            ActionPlanTriggerUtility.UpdateCompletionDate(newList, null);
        }
        TriggerUtility.ActionPlanBeforeInsertExecuted();
    }
    public static void afterInsert(List<Action_Plan__c> newList){
        Map<String, Triggers_Switch__c> tsmap = Triggers_Switch__c.getAll();
        if(tsmap.containsKey('Execute_AP_History_Creation') && tsmap.get('Execute_AP_History_Creation') != null && tsmap.get('Execute_AP_History_Creation').Execute__c && !TriggerUtility.isAPHistoryCreationExecuted()){
            ActionPlanTriggerUtility.createAPHistory(newList, null);
        }
        TriggerUtility.ActionPlanAfterInsertExecuted();
    }
    public static void afterUpdate(List<Action_Plan__c> newList, Map<Id, Action_Plan__c> oldmap){
        Map<String, Triggers_Switch__c> tsmap = Triggers_Switch__c.getAll();
        
        if(tsmap.containsKey('Execute_AP_History_Creation') && tsmap.get('Execute_AP_History_Creation') != null && tsmap.get('Execute_AP_History_Creation').Execute__c && !TriggerUtility.isAPHistoryCreationExecuted()){
            ActionPlanTriggerUtility.createAPHistory(newList, oldmap);
        }
    
        TriggerUtility.ActionPlanAfterUpdateExecuted();
    }

    public static void beforeUpdate(List<Action_Plan__c> newList, Map<Id, Action_Plan__c> oldmap){
        Map<String, Triggers_Switch__c> tsmap = Triggers_Switch__c.getAll();
        if(tsmap.containsKey('Execute_AP_CompletionDate') && tsmap.get('Execute_AP_CompletionDate') != null && tsmap.get('Execute_AP_CompletionDate').Execute__c && !TriggerUtility.isupdateCompletionDateExecuted()){
            ActionPlanTriggerUtility.UpdateCompletionDate(newList,oldmap);
        }

    }
}