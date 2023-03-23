/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* PartnerProspectTriggerHandler
* @description    This is the Partner Prospect Trigger handler class called synchronously from PartnerProspectTrigger.
*				  All the methods needs to be called synchronously from the Partner Prospect Trigger
* 				  should be called from here in the before/after insert/update methods.
* @TestClass      PartnerProspectTriggerTest
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Zscaler
* @modifiedBy     
* @maintainedBy   Zscaler
* @version        1.0
* @created        2023-01-05
* @modified       
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* vX.X            Developer Name
* YYYY-MM-DD      Explanation of the change.  Multiple lines can be used to explain the change, but
*                 each line should be indented till left aligned with the previous description text.
* V1.0            Initialized
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
**/
public without sharing class PartnerProspectTriggerHandler extends TriggerHandler {
    
    public override void beforeInsert(){
        System.debug('---PartnerProspectTriggerHandler--beforeInsert---');
        List<Partner_Prospect__c> ppList = (List<Partner_Prospect__c>) Trigger.new;
        PartnerProspectTriggerHelper.onBeforeInsert(ppList);
    }
    
    public override void beforeUpdate(){
        System.debug('---PartnerProspectTriggerHandler--beforeUpdate---');
        List<Partner_Prospect__c> ppList = (List<Partner_Prospect__c>) Trigger.new;
        MAP<ID,Partner_Prospect__c> oldMAP = (MAP<ID,Partner_Prospect__c>) Trigger.oldMap;
        PartnerProspectTriggerHelper.onBeforeUpdate(oldMAP, ppList);
    }
    
    public override void afterUpdate(){
        System.debug('---PartnerProspectTriggerHandler--afterUpdate---');
        ManageRecursive.timesPartnerProspTriggerInvoked = ManageRecursive.timesPartnerProspTriggerInvoked + 1;
        Map<Id, Partner_Prospect__c> newPartnerProspMap = new Map<Id,Partner_Prospect__c>();
        Map<Id, Partner_Prospect__c> oldPartnerProspMap = new Map<Id,Partner_Prospect__c>();
        for (SObject partner_Prosp: Trigger.new) {
            Partner_Prospect__c newPartnerProsp = (Partner_Prospect__c) partner_Prosp;
            Partner_Prospect__c oldPartnerProsp = (Partner_Prospect__c) Trigger.oldMap.get(newPartnerProsp.Id);
            
            if(!ManageRecursive.processedPartnerProspIds.contains(newPartnerProsp.Id) || qualifiedUpdate(newPartnerProsp, oldPartnerProsp)){
                newPartnerProspMap.put(newPartnerProsp.Id, newPartnerProsp);
                oldPartnerProspMap.put(oldPartnerProsp.Id, oldPartnerProsp);
                ManageRecursive.processedPartnerProspIds.add(newPartnerProsp.Id);  
            }
        }
        PartnerProspectTriggerHelper.onAfterupdate(newPartnerProspMap,oldPartnerProspMap);
    }
    
    // Added the check for change of Approval status for the purpose of approval process stage tracking --- Rajat J
    public boolean qualifiedUpdate(Partner_Prospect__c newPartnerProsp, Partner_Prospect__c oldPartnerProsp){
        Boolean valChanged = false;
        if((newPartnerProsp.Application_Status__c != oldPartnerProsp.Application_Status__c) ||
           (newPartnerProsp.Approval_Status__c == 'D-RAM Approval Submitted' 
            && newPartnerProsp.Partner_Tier__c == 'Zenith' 
            && newPartnerProsp.Partner_Tier__c != oldPartnerProsp.Partner_Tier__c)
          )
        {
            valChanged = true;
        }
        return valChanged;   
    }
}