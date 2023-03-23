/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* genericVCEtrigger
* @description    This is the single VCE Trigger where we call/control all Value Creation Engagement 
                  related logic.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Zscaler
* @modifiedBy     
* @maintainedBy   Zscaler
* @version        1.0
* @created        2023-01-13
* @modified       
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* v1.0            Aman Jain
* YYYY-MM-DD      Explanation of the change.  Multiple lines can be used to explain the change, but
*                 each line should be indented till left aligned with the previous description text.
* 2023-01-13      IBA-5937 Aman - Creation of the trigger for handling the automation logic during 
                  DML operations on Value Creation Engagement records.                  
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
**/
trigger genericVCEtrigger on Value_Creation_Engagements__c (
        before insert, 
        after insert,
        before update, 
        after update
    ) {
    new ValueCreationEngagementHandler().run();
}