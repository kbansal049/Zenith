/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* SkillJarStudentTriggerHandler
* @description      This is the SkillJar Student Flow handler class called from Lightning Screen Flows
*
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author           Zscaler
* @modifiedBy     
* @maintainedBy     Zscaler
* @version          1.0
* @created          2022-11-29
* @modified       
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* vX.X              Author Name
* YYYY-MM-DD        Explanation of the change.  Multiple lines can be used to explain the change, but
*                   each line should be indented till left aligned with the previous description text.
*2022-11-29         Class exposes methods to invoke from Flows
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
**/
public class SkillJarStudentFlowHandler {
    
    @InvocableMethod(label='Send Welcome Email' description='Send Welcome Email to Non Partner Students')
    public static void invokeWelcomeEmail(List<skilljar__Student__c> students){
        SkillJarStudentTriggerHelper.sendWelcomeEmail(students);
        
    }

}