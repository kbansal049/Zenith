trigger PODetailTrigger on PO_Detail__c (before insert, before update, after insert, after update) {
    
     new PODetailTriggerHandler().run();
}