trigger GenericLegalTrigger on Legal__c (before insert, before update) {
    Map<String, Triggers_Switch__c> tsmap = Triggers_Switch__c.getAll();
    if(tsmap.containsKey('LegalUpdateSalesOrder') && tsmap.get('LegalUpdateSalesOrder') != null && tsmap.get('LegalUpdateSalesOrder').Execute__c){
        LegalTriggerHandler.UpdateSalesOrder(trigger.new);
    }
}