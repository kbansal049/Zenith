/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* CampaignTrigger
* @description    This is the single Campaign Trigger where we call/control all Campaign related logic.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Zscaler
* @modifiedBy     
* @maintainedBy   Zscaler
* @version        1.0
* @created        2021-03-02
* @modified       
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* vX.X            Developer Name
* YYYY-MM-DD      Explanation of the change.  Multiple lines can be used to explain the change, but
*                 each line should be indented till left aligned with the previous description text.
* 2021-03-02	  Parth Doshi - Initial Development CR# 1520
* 2021-11-29	  Bikram - Added Trigger Framework
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
**/

trigger CampaignTrigger on Campaign (before insert, 
                                     before update, 
                                     after insert, 
                                     after update, 
                                     before delete, 
                                     after delete, 
                                     after undelete) {
        
        new CampaignTriggerHandler().run();
    
    /*                                     
    Boolean skiptrigger = false;
    Skip_Triggers_User_Based__c usertoskip = Skip_Triggers_User_Based__c.getInstance(Userinfo.getUserId());
    String objname = Trigger.New.getSObjectType().getDescribe().getName();
    if(objname != null && usertoskip.Id != null && usertoskip.Object_s_to_skip__c != null && usertoskip.Object_s_to_skip__c.split(';') != null && !usertoskip.Object_s_to_skip__c.split(';').isEmpty() && usertoskip.Object_s_to_skip__c.split(';').contains(objname)){
        skiptrigger = true;
    }
    
    if(!skiptrigger && Trigger.isAfter && Trigger.isUpdate && !TriggerUtility.isafterUpdateRelatedLeadExecuted() && !system.isbatch()){
        CampaignTriggerHelper.updateRelatedLeads(Trigger.NewMap.keySet());
    }
    
    if(!skiptrigger && Trigger.isAfter && Trigger.isUpdate && !TriggerUtility.isafterUpdateRelatedContactExecuted() && !system.isbatch()){
        CampaignTriggerHelper.updateRelatedContacts(Trigger.NewMap.keySet());
    }
	*/
}