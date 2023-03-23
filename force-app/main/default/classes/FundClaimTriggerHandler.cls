public class FundClaimTriggerHandler extends TriggerHandler {
    
    private List<PartnerFundClaim> triggerNew;
    private List<PartnerFundClaim> triggerOld;
    private Map<Id, PartnerFundClaim> triggerMapNew;
    private Map<Id, PartnerFundClaim> triggerMapOld;
    
    private FundClaimServiceLayer fundClaimServiceLayerObj;
    
    public class FundClaimTriggerHandlerException extends Exception {
    }
    
    public FundClaimTriggerHandler() {
        this.triggerOld = (List<PartnerFundClaim>) Trigger.old;
        this.triggerNew = (List<PartnerFundClaim>) Trigger.new;
        this.triggerMapNew = (Map<Id, PartnerFundClaim>) Trigger.newMap;
        this.triggerMapOld = (Map<Id, PartnerFundClaim>) Trigger.oldMap;
        
        this.fundClaimServiceLayerObj = new FundClaimServiceLayer();
    }
    
    public override void beforeInsert() { 
        this.fundClaimServiceLayerObj.changeFundClaimStatusAndAmount(this.triggerNew);
    }
    
    public override void afterInsert() {
    }
    
    public override void beforeUpdate() {
        this.fundClaimServiceLayerObj.statusUpdateAndFieldValidation(this.triggerNew,this.triggerMapOld);
    }
    
    public override void afterUpdate() {
    }

}