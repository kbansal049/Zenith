/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* MADTriggerHandler
* @description      This is the M_A_D_Details__c Trigger handler class called synchronously 
                    from MAD_MasterTrigger.
*				    All the methods needs to be called synchronously from the MAD_MasterTrigger
* 				    should be called from here in the before/after insert/update methods.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author           Zscaler
* @modifiedBy     
* @maintainedBy     Zscaler
* @version          1.0
* @created          2022-08-20
* @modified       
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* vX.X              Author Name
* YYYY-MM-DD        Explanation of the change.  Multiple lines can be used to explain the change, but
*                   each line should be indented till left aligned with the previous description text.
*
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
**/
public with sharing class MADTriggerHandler extends TriggerHandler {
    
    public override void beforeInsert() {
        List<M_A_D_Details__c> newMADList = (List<M_A_D_Details__c>) Trigger.New;
        
        //Update the Trigger.New Context Var with new values
        MADTriggerHelper.setEnagagementType(newMADList);   
        MADTriggerHelper.setBuyerSellerDetails(newMADList);
    }

    public override void afterInsert() {    
        List<M_A_D_Details__c> newMADList = (List<M_A_D_Details__c>) Trigger.New;
    }

    public override void beforeUpdate() {
        List<M_A_D_Details__c> newMADList = (List<M_A_D_Details__c>)Trigger.New;
        Map<Id,M_A_D_Details__c> oldMADMap = (Map<Id,M_A_D_Details__c>)Trigger.oldMap;

        List<M_A_D_Details__c> setAccountLookupList = new List<M_A_D_Details__c>();
        List<M_A_D_Details__c> setBuyerSellerList = new List<M_A_D_Details__c>();        
        
        for(M_A_D_Details__c madRecord : newMADList){
            if(madRecord.Opportunity__c != oldMADMap.get(madRecord.Id).Opportunity__c){
                setAccountLookupList.add(madRecord);
            }
            if(madRecord.Buyer__c != oldMADMap.get(madRecord.Id).Buyer__c || 
                madRecord.Seller__c != oldMADMap.get(madRecord.Id).Seller__c){
                setBuyerSellerList.add(madRecord);
            }          
        }
        
        //Update the Trigger.New Context Var with new values        
        MADTriggerHelper.setEnagagementType(newMADList);
        if(!setAccountLookupList.isEmpty()) {//Set Account Lookup on opportunity change
            MADTriggerHelper.setAccountLookup(setAccountLookupList);
        }
        if(!setBuyerSellerList.isEmpty()) {
            MADTriggerHelper.setBuyerSellerDetails(setBuyerSellerList);
        }        
    }

    public override void afterUpdate() {
		List<M_A_D_Details__c> newMADList = (List<M_A_D_Details__c>)Trigger.New;
        Map<Id,M_A_D_Details__c> oldMADMap = (Map<Id,M_A_D_Details__c> )Trigger.oldMap;
    }

    /*
    public override void beforeDelete() {

    }

    public override void afterDelete() {

    }

    public override void afterUndelete() {

    }
    */
}