/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* LeadMasterTrigger
* @description    This is the single Lead Trigger where we call/control all Lead related logic.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Zscaler
* @modifiedBy     
* @maintainedBy   Zscaler
* @version        1.0
* @created        2022-01-27
* @modified       
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* vX.X            Developer Name
* YYYY-MM-DD      Explanation of the change.  Multiple lines can be used to explain the change, but
*                 each line should be indented till left aligned with the previous description text.
*
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
**/
trigger LeadMasterTrigger on Lead (before insert, 
                                   before update, 
                                   after insert, 
                                   after update, 
                                   before delete, 
                                   after delete, 
                                   after undelete) {
        
       new LeadTriggerHandler().run();
                                       
}