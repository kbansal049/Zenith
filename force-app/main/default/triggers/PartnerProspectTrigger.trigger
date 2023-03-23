/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* PartnerProspectTrigger
* @description    This is the single Partner Prospect Trigger where we call/control all Partner related logic.
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
* 2023-02-05      Initialized
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
**/
trigger PartnerProspectTrigger on Partner_Prospect__c (after insert,before insert,before update,after update, after delete) {
    
	new PartnerProspectTriggerHandler().run();
}