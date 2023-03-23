/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* FocusPartnerMasterTrigger
* @description    This is the single Lead Trigger where we call/control all Focus Partner related logic.
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
* 2022-06-09      Initialized
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
**/
trigger FocusPartnerMasterTrigger on Focus_Partner__c (after insert,before insert,before update,after update, after delete) {
    
	new FocusPartnerMasterTriggerHandler().run();
}