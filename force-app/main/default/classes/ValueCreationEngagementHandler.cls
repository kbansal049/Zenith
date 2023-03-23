/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* ValueCreationEngagementHandler
* @description    This is the Value Creation Engagement Trigger handler class called synchronously from genericVCETrigger.
*				  All the methods needs to be called synchronously from the trigger
* 				  should be called from here in the before/after insert/update methods.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Zscaler
* @modifiedBy     
* @maintainedBy   Zscaler
* @version        1.0
* @created        2023-01-17
* @modified       
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* v1.0            Aman Jain
* YYYY-MM-DD      Explanation of the change.  Multiple lines can be used to explain the change, but
*                 each line should be indented till left aligned with the previous description text.
* 2023-01-17      IBA-5937 Aman - Creation of the handler class for adding the trigger logic
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
**/
public class ValueCreationEngagementHandler extends TriggerHandler {
    private List<Value_Creation_Engagements__c> triggerNew;
    private List<Value_Creation_Engagements__c> triggerOld;
    private Map<Id, Value_Creation_Engagements__c> triggerNewMap;
    private Map<Id, Value_Creation_Engagements__c> triggerOldMap;
    
    public ValueCreationEngagementHandler() {
        this.triggerOld = (List<Value_Creation_Engagements__c>) Trigger.old;
        this.triggerNew = (List<Value_Creation_Engagements__c>) Trigger.new;
        this.triggerNewMap = (Map<Id, Value_Creation_Engagements__c>) Trigger.newMap;
        this.triggerOldMap = (Map<Id, Value_Creation_Engagements__c>) Trigger.oldMap;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────┐
    * This Method was added as part of JIRA ID IBA-5937 : to handle Before Insert logic during DML,
                                                          called automatically from the genericVCEtrigger.
    * ──────────────────────────────────────────────────────────────────────────────────────────────
    * @method   NAME : beforeInsert .
    * @return   TYPE : void .
    * ─────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public override void beforeInsert() {
        ValueCreationEngagementHelper.setBVAScore(this.triggerNew, this.triggerOldMap);
    }
    
    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────┐
    * This Method was added as part of JIRA ID IBA-5937 : to handle After Insert logic during DML,
                                                          called automatically from the genericVCEtrigger.
    * ──────────────────────────────────────────────────────────────────────────────────────────────
    * @method   NAME : afterInsert .
    * @return   TYPE : void .
    * ─────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public override void afterInsert() {
        ValueCreationEngagementHelper.setOpportunityStageAndScore
        (
            fetchOpportunityIdAndVceMap(
                this.triggerNew, this.triggerOldMap
            )
        );
    }
    
    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────┐
    * This Method was added as part of JIRA ID IBA-5937 : to handle Before Update Update during DML,
                                                          called automatically from the genericVCEtrigger.
    * ──────────────────────────────────────────────────────────────────────────────────────────────
    * @method   NAME : beforeUpdate .
    * @return   TYPE : void .
    * ─────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public override void beforeUpdate() {
        ValueCreationEngagementHelper.setBVAScore(this.triggerNew, this.triggerOldMap);
    }
    
    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────┐
    * This Method was added as part of JIRA ID IBA-5937 : to handle After Update logic during DML,
                                                          called automatically from the genericVCEtrigger.
    * ──────────────────────────────────────────────────────────────────────────────────────────────
    * @method   NAME : afterUpdate .
    * @return   TYPE : void .
    * ─────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public override void afterUpdate() {
        ValueCreationEngagementHelper.setOpportunityStageAndScore
        (
            fetchOpportunityIdAndVceMap(
                this.triggerNew, this.triggerOldMap
            )
        );
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────┐
    * This Method was added as part of JIRA ID IBA-5937 : to get map of Opportunity Id v/s VCE record 
    * ──────────────────────────────────────────────────────────────────────────────────────────────
    * @method   NAME : fetchOpportunityIdAndVceMap .
    * @param    NAME : List<Value_Creation_Engagements__c> VCE list .
    * @param    NAME : Map<Id, Value_Creation_Engagements__c> VCE Map.  
    * @return   TYPE : Map<Id,Value_Creation_Engagements__c> .
    * ─────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static Map<Id,Value_Creation_Engagements__c> fetchOpportunityIdAndVceMap(
        List<Value_Creation_Engagements__c> triggerNew,
        Map<Id, Value_Creation_Engagements__c> triggerOldMap
    ) {
        Map<Id,Value_Creation_Engagements__c> opportunityIdVsVceMap = new Map<Id,Value_Creation_Engagements__c>();
        for (Value_Creation_Engagements__c record : triggerNew) {
            Boolean vceStageOrScoreChanged = record.Link_to_SFDC_Opportunity__c != null
                    && (triggerOldMap == null 
                    || record.Value_Creation_Stage__c != triggerOldMap.get(record.Id).Value_Creation_Stage__c
                    || record.Overall_BVA_Score__c != triggerOldMap.get(record.Id).Overall_BVA_Score__c);
            if (vceStageOrScoreChanged) {
                opportunityIdVsVceMap.put(record.Link_to_SFDC_Opportunity__c,record);
            }
        }
        return opportunityIdVsVceMap;
    }
}