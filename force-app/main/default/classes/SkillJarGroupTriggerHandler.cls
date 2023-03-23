/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* SkillJarStudentTriggerHandler
* @description      This is the SkillJar Group Trigger handler class called synchronously 
from SkillJarGroupMasterTrigger.
*				    All the methods needs to be called synchronously from the SkillJar Group Trigger
* 				    should be called from here in the before/after insert/update methods.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author           Zscaler
* @modifiedBy     
* @maintainedBy     Zscaler
* @version          1.0
* @created          2022-07-25
* @modified       
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* vX.X              Author Name
* YYYY-MM-DD        Explanation of the change.  Multiple lines can be used to explain the change, but
*                   each line should be indented till left aligned with the previous description text.
*
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
**/

public class SkillJarGroupTriggerHandler extends TriggerHandler {
    
    public override void beforeInsert() {
        
    }
    
    public override void afterInsert() {
        SkillJarGroupTriggerHelper.updateGroupIdOnAccount((Map<Id,skilljar__Group__c>)Trigger.newMap);
    }
    
    /*public override void beforeUpdate() {
        
    }
    
    public override void afterUpdate() {
        
    }
    
    public override void beforeDelete() {
        
    }
    
    public override void afterDelete() {
        
    }
    
    public override void afterUndelete() {
        
    }*/
}