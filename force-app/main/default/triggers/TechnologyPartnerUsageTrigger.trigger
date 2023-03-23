/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* TechnologyPartnerUsageTrigger
* @description    This is the single Technology_Partner_Usage__c Trigger where we call/control all 
*                 Technology_Partner_Usage__c related logic.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Zscaler
* @modifiedBy     
* @maintainedBy   Zscaler
* @version        1.0
* @created        2021-12-03
* @modified       
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* vX.X            Developer Name
* YYYY-MM-DD      Explanation of the change.  Multiple lines can be used to explain the change, but
*                 each line should be indented till left aligned with the previous description text.
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
**/
trigger TechnologyPartnerUsageTrigger on Technology_Partner_Usage__c (before insert, 
                                     before update, 
                                     after insert, 
                                     after update, 
                                     before delete, 
                                     after delete, 
                                     after undelete) {
        
        new TechnologyPartnerUsageHandler().run();
}