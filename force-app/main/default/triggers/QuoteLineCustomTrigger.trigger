/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 01-20-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
trigger QuoteLineCustomTrigger on SBQQ__QuoteLine__c (after insert, after update, after delete,before update, before insert) {   
   try{
        QuoteLineTriggerServices services = new QuoteLineTriggerServices(Trigger.new,Trigger.newMap,Trigger.oldMap);
                
        if (Trigger.isBefore) {
            if (Trigger.isInsert) {
                TriggerUtility.blnQLInsert = TRUE;
                services.resetAdditionalDiscountAmountForRenewals(Trigger.new);
                services.resetRampFieldsOnRenewal(Trigger.new);
                services.upgradeProducts(Trigger.new);
        
            }
            
            if (Trigger.isUpdate) {
                services.resetAdditionalDiscountAmountForRenewals(Trigger.new);
                services.updateSubscriptionType(Trigger.new);
                //services.upgradeProducts(Trigger.new);
                //services.upgradeProducts(Trigger.new);
                //services.setFinanceTerm(Trigger.new);
            }
        }
        
        if (Trigger.isAfter) {
            if (Trigger.isInsert) {
                //services.createYWSLines(Trigger.new);
                //services.createAnnualBreakdownLines(Trigger.new);
                services.createAnnualBreakdownYWSLines(Trigger.new);
                //services.setSortOrder(Trigger.new);
            }
            if (Trigger.isUpdate) {
                //services.createAnnualBreakdownLines(Trigger.new);
                //services.checkUpdatedValues(Trigger.new,Trigger.oldMap);
                services.createAnnualBreakdownYWSLines(Trigger.new);
            }
            if (Trigger.isDelete) {
                //services.deleteYWSLines(Trigger.old);
                //services.deleteAnnualBreakdownLines(Trigger.old);
                services.deleteAnnualBreakdownYWSLines(Trigger.old);
            }
        }
    }
    catch(Exception ex){
        system.debug('excpetion has occurred===>'+ex.getMessage());
    }
}