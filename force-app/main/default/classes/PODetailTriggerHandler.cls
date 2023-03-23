public class PODetailTriggerHandler extends TriggerHandler {
    
    public override void beforeInsert() {
        //order Needs to be maintained
        //Step 1
        PODetailTriggerUtility.autoPopulateOpportunityBasedOnQuoteNumber(trigger.new, (Map<Id,PO_Detail__c>) trigger.oldMap);
        //Step 2
        PODetailTriggerUtility.autoPopulateBOTMail(trigger.new);   
    }
    
    public override void beforeUpdate() {    
        //order Needs to be maintained
        //Step 1
        PODetailTriggerUtility.autoPopulateOpportunityBasedOnQuoteNumber(trigger.new, (Map<Id,PO_Detail__c>) trigger.oldMap);
        PODetailTriggerUtility.autoPopulateBOTMail(trigger.new);
    }
    
    public override void afterInsert() {
        PODetailTriggerUtility.autoPopulateTrackerRecord(trigger.new);
    }
    
    public override void afterUpdate() {
        PODetailTriggerUtility.autoPopulateTrackerRecord(trigger.new);  
        PODetailTriggerUtility.updateOpportunityPOSourceToEDI(trigger.new);  
        PODetailTriggerUtility.updateOrderTrackerStatusAsPendingforQC(trigger.new, (MAP<ID, PO_Detail__c>) trigger.oldMap);
        PODetailTriggerUtility.createSalesOrder(trigger.new, (MAP<ID, PO_Detail__c>) trigger.oldMap);
    }
}