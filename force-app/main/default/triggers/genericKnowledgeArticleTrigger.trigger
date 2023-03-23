trigger genericKnowledgeArticleTrigger on KB__kav (before insert, before update, after insert, after update) {
	Map<String, Triggers_Switch__c> tsmap = Triggers_Switch__c.getAll();
    if(tsmap != null && !tsmap.isEmpty() && tsmap.containsKey('Execute_Knowledge_After_Trigger') && tsmap.get('Execute_Knowledge_After_Trigger') != null && tsmap.get('Execute_Knowledge_After_Trigger').Execute__c){
        if(trigger.isAfter && trigger.isUpdate){
            KnowledgeTriggerHelper.afterUpdate(Trigger.new, trigger.OldMap);
        }
    }
    if(tsmap != null && !tsmap.isEmpty() && tsmap.containsKey('Execute_KBA_Before_Trigger') && tsmap.get('Execute_KBA_Before_Trigger') != null && tsmap.get('Execute_KBA_Before_Trigger').Execute__c){
        if(trigger.isBefore && trigger.isUpdate){
            KnowledgeTriggerHelper.beforeUpdate(Trigger.new, trigger.OldMap);
        }
    }
}