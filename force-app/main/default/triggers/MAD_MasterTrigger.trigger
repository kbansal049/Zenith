/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* MAD_MasterTrigger
* @description      This is the single M_A_D_Details__c Trigger where we call/control all M_A_D_Details__c logic.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Zscaler
* @modifiedBy     
* @maintainedBy   Zscaler
* @version        1.0
* @created        2022-08-20
* @modified       
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* vX.X            Author Name
* YYYY-MM-DD      Explanation of the change.  Multiple lines can be used to explain the change, but
*                 each line should be indented till left aligned with the previous description text.
*
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
**/
trigger MAD_MasterTrigger on M_A_D_Details__c (before insert, 
    before update, 
    after insert, 
    after update, 
    before delete, 
    after delete, 
    after undelete) {
        
    new MADTriggerHandler().run();
}