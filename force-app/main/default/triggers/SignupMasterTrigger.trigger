/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* SignupMasterTrigger
* @description    This is the single Signup Trigger where we call/control all Signup related logic.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Zscaler
* @modifiedBy     
* @maintainedBy   Zscaler
* @version        1.0
* @created        2021-11-08
* @modified       
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* vX.X            Developer Name
* YYYY-MM-DD      Explanation of the change.  Multiple lines can be used to explain the change, but
*                 each line should be indented till left aligned with the previous description text.
* 2023-03-21      Digvijay Singh, Created as part of IBA-8286 for Zenith Live project 
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
**/
trigger SignupMasterTrigger on Signup__c (before insert, 
                                          before update, 
                                          after insert, 
                                          after update, 
                                          before delete, 
                                          after delete, 
                                          after undelete) {
    new SignupTriggerHandler().run();
}