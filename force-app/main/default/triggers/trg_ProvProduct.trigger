trigger trg_ProvProduct on Provisioning_Product__c (after insert) {
    
    trg_ProvProductHandler.afterInsert(trigger.new);
    

}