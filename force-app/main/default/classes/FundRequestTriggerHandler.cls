public class FundRequestTriggerHandler extends TriggerHandler {
    
    private List<PartnerFundRequest> triggerNew;
    private List<PartnerFundRequest> triggerOld;
    private Map<Id, PartnerFundRequest> triggerMapNew;
    private Map<Id, PartnerFundRequest> triggerMapOld;
    
    private FundRequestServiceLayer fundRequestServiceLayerObj;
    
    public class FundRequestTriggerHandlerException extends Exception {
    }
    
    public FundRequestTriggerHandler() {
        this.triggerOld = (List<PartnerFundRequest>) Trigger.old;
        this.triggerNew = (List<PartnerFundRequest>) Trigger.new;
        this.triggerMapNew = (Map<Id, PartnerFundRequest>) Trigger.newMap;
        this.triggerMapOld = (Map<Id, PartnerFundRequest>) Trigger.oldMap;
        
        this.fundRequestServiceLayerObj = new FundRequestServiceLayer();
    }
    
    public override void beforeInsert() {
        System.debug('FundRequestTriggerHandler beforeInsert this.triggerNew BEFORE CUSTOM LOGIC : ' + this.triggerNew);
        this.fundRequestServiceLayerObj.setFundRequestFieldValues(this.triggerNew);
        System.debug('FundRequestTriggerHandler beforeInsert this.triggerNew AFTER CUSTOM LOGIC : ' + this.triggerNew);
    }
    
    public override void afterInsert() {
        System.debug('FundRequestTriggerHandler afterInsert this.triggerNew : ' + this.triggerNew);
    }
    
    public override void beforeUpdate() {
        System.debug('FundRequestTriggerHandler beforeUpdate this.triggerNew BEFORE CUSTOM LOGIC : ' + this.triggerNew);
        this.fundRequestServiceLayerObj.customFieldValidations(this.triggerNew,this.triggerMapOld);
        this.fundRequestServiceLayerObj.setAllocationRecordOnFundRequest(this.triggerNew,this.triggerMapOld);
        this.fundRequestServiceLayerObj.approvalFieldValidation(this.triggerNew,this.triggerMapOld);
        this.fundRequestServiceLayerObj.rejectionFieldValidation(this.triggerNew,this.triggerMapOld);
        this.fundRequestServiceLayerObj.reEvaluateStatusChangeFundRequests(this.triggerNew,this.triggerMapOld);
        System.debug('FundRequestTriggerHandler beforeUpdate this.triggerNew AFTER CUSTOM LOGIC : ' + this.triggerNew);
    }
    
    public override void afterUpdate() {
        System.debug('FundRequestTriggerHandler afterUpdate this.triggerNew : ' + this.triggerNew);
    }

}