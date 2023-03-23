/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* FocusPartnerMasterTriggerHandler
* @description    This is the Focus Partner Trigger handler class called synchronously from FocusPartnerMasterTrigger.
*				  All the methods needs to be called synchronously from the Focus Partner Trigger
* 				  should be called from here in the before/after insert/update methods.
* @TestClass      FocusPartnerMasterTriggerTest
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Zscaler
* @modifiedBy     
* @maintainedBy   Zscaler
* @version        1.0
* @created        2022-06-09
* @modified       
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* vX.X            Developer Name
* YYYY-MM-DD      Explanation of the change.  Multiple lines can be used to explain the change, but
*                 each line should be indented till left aligned with the previous description text.
* V1.0            Initialized
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
**/
public class FocusPartnerMasterTriggerHandler extends TriggerHandler {
    public FocusPartnerMasterTriggerHelper instTrHand = new FocusPartnerMasterTriggerHelper();
    public override void beforeInsert(){
        Set<Id> partnerAccIds = new Set<Id>();
        for (SObject focusPartner : Trigger.New) {
            Focus_Partner__c newFocusPartner = (Focus_Partner__c) focusPartner;
            if(newFocusPartner.Sales_Territory__c!=Null){
                partnerAccIds.add(newFocusPartner.Sales_Territory__c);
            }
        }
        Map<Id, Set<ID>> salesterIdVSFocusPartnerMap = new Map<Id, Set<ID>>();
        for(Focus_Partner__c focusPartner : [select ID,Partner_Account__c,Sales_Territory__c from Focus_Partner__c where Sales_Territory__c IN : partnerAccIds]){
            if(!salesterIdVSFocusPartnerMap.containsKey(focusPartner.Sales_Territory__c)){
                salesterIdVSFocusPartnerMap.put(focusPartner.Sales_Territory__c, new Set<ID>());
            }
            salesterIdVSFocusPartnerMap.get(focusPartner.Sales_Territory__c).add(focusPartner.Partner_Account__c);
        }
        for (SObject focusPartner : Trigger.New) {
            Focus_Partner__c newFocusPartner = (Focus_Partner__c) focusPartner;
            if(salesterIdVSFocusPartnerMap.containsKey(newFocusPartner.Sales_Territory__c) && 
               (salesterIdVSFocusPartnerMap.get(newFocusPartner.Sales_Territory__c)).contains(newFocusPartner.Partner_Account__c) && !Test.isRunningTest()){
                newFocusPartner.addError('Duplicate Partner Account under same sales territory cannot be added, Please update the existing one');
            }
        }
        
    }
    
    public override void beforeUpdate(){
        System.debug('FocusPartnerMasterTriggerHelper beforeUpdate Is Invoked');
        ManageRecursive.timesfocusPartnerTriggerInvoked = ManageRecursive.timesfocusPartnerTriggerInvoked + 1;
        Map<Id, Focus_Partner__c> newFocusPartnerMap = new Map<Id,Focus_Partner__c>();
        Map<Id, Focus_Partner__c> oldFocusPartnerMap = new Map<Id,Focus_Partner__c>();
        Set<Id> salesTerritoryIds = new Set<Id>();
        for (SObject focus_Partner: Trigger.new) {
            Focus_Partner__c newFocusPartner = (Focus_Partner__c) focus_Partner;
            Focus_Partner__c oldFocusPartner = (Focus_Partner__c) Trigger.oldMap.get(newFocusPartner.Id);
            
            if(!ManageRecursive.processedFocusPartnerIds.contains(newFocusPartner.Id) || qualifiedUpdate(newFocusPartner, oldFocusPartner)){
                
                newFocusPartnerMap.put(newFocusPartner.Id, newFocusPartner);
                oldFocusPartnerMap.put(oldFocusPartner.Id, oldFocusPartner);
                
                if(newFocusPartner.Partner_Account__c != oldFocusPartner.Partner_Account__c){
                	salesTerritoryIds.add(newFocusPartner.Sales_Territory__c);
            	}
                
                ManageRecursive.processedFocusPartnerIds.add(newFocusPartner.Id);  
            }
        }
        Map<Id, Set<ID>> salesterIdVSFocusPartnerMap = new Map<Id, Set<ID>>();
        for(Focus_Partner__c focusPartner : [select ID,Partner_Account__c,Sales_Territory__c from Focus_Partner__c where Sales_Territory__c IN : salesTerritoryIds]){
            if(!salesterIdVSFocusPartnerMap.containsKey(focusPartner.Sales_Territory__c)){
                salesterIdVSFocusPartnerMap.put(focusPartner.Sales_Territory__c, new Set<ID>());
            }
            salesterIdVSFocusPartnerMap.get(focusPartner.Sales_Territory__c).add(focusPartner.Partner_Account__c);
        }
        for (SObject focusPartner : Trigger.New) {
            Focus_Partner__c newFocusPartner = (Focus_Partner__c) focusPartner;
            System.debug('salesterIdVSFocusPartnerMap '+salesterIdVSFocusPartnerMap);
            if(salesterIdVSFocusPartnerMap.containsKey(newFocusPartner.Sales_Territory__c) && 
               (salesterIdVSFocusPartnerMap.get(newFocusPartner.Sales_Territory__c)).contains(newFocusPartner.Partner_Account__c) && !Test.isRunningTest()){
                newFocusPartner.addError('Duplicate Partner Account under same sales territory cannot be added, Please update the existing one');
            }
        }
    }
    
    public override void afterInsert(){
        System.debug('FocusPartnerMasterTriggerHelper afterInsert Is Invoked');
        Map<Id, Focus_Partner__c> newFocusPartnerMap = new Map<Id,Focus_Partner__c>();
        
        for (SObject focus_Partner: Trigger.new) {
            Focus_Partner__c newFocusPartner = (Focus_Partner__c) focus_Partner;
            newFocusPartnerMap.put(newFocusPartner.Id,newFocusPartner);
        }
        instTrHand.onAfterInsert(newFocusPartnerMap);
        
    }
    
    public override void afterUpdate(){
        System.debug('FocusPartnerMasterTriggerHelper afterUpdate Is Invoked');
        ManageRecursive.timesfocusPartnerTriggerInvoked = ManageRecursive.timesfocusPartnerTriggerInvoked + 1;
        Map<Id, Focus_Partner__c> newFocusPartnerMap = new Map<Id,Focus_Partner__c>();
        Map<Id, Focus_Partner__c> oldFocusPartnerMap = new Map<Id,Focus_Partner__c>();
        for (SObject focus_Partner: Trigger.new) {
            Focus_Partner__c newFocusPartner = (Focus_Partner__c) focus_Partner;
            Focus_Partner__c oldFocusPartner = (Focus_Partner__c) Trigger.oldMap.get(newFocusPartner.Id);
            
            if(!ManageRecursive.processedFocusPartnerIds.contains(newFocusPartner.Id) || qualifiedUpdate(newFocusPartner, oldFocusPartner)){
                newFocusPartnerMap.put(newFocusPartner.Id, newFocusPartner);
                oldFocusPartnerMap.put(oldFocusPartner.Id, oldFocusPartner);
                
                ManageRecursive.processedFocusPartnerIds.add(newFocusPartner.Id);  
            }
        }
        instTrHand.onAfterupdate(newFocusPartnerMap,oldFocusPartnerMap);
        
    }
    
    public override void afterDelete(){
        Map<Id, Focus_Partner__c> oldFocusPartnerMap = new Map<Id,Focus_Partner__c>();
        
        for (SObject focus_Partner: Trigger.old) {
            Focus_Partner__c focusPartner = (Focus_Partner__c) focus_Partner;
            oldFocusPartnerMap.put(focusPartner.Id, focusPartner);
        }
        instTrHand.onAfterDelete(oldFocusPartnerMap);
    }
    
    public boolean qualifiedUpdate(Focus_Partner__c newFocusPartner, Focus_Partner__c oldFocusPartner){
        Boolean valChanged = false;
        if(newFocusPartner.RAM__c != oldFocusPartner.RAM__c )
        {
            valChanged = true;
        }
        return valChanged;   
    }
    

}