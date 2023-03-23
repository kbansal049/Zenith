/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* NodeConfigurationTriggerHandler
* @description    This is the NodeConfigurationTriggerHandler class called synchronously from genericNodeConfig.
*                   All the methods needs to be called synchronously from the Node Configuration Trigger
*                   should be called from here in the before/after insert/update methods.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Udit Jain
* @modifiedBy     Udit Jain
* @maintainedBy   Udit Jain
* @version        1.0
* @created        2022-11-29
* @modified       
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* vX.X            Developer Name
* YYYY-MM-DD      Explanation of the change.  Multiple lines can be used to explain the change, but
*                 each line should be indented till left aligned with the previous description text.
* 2022-11-29      IBA-2983 : Automated email to be sent to Customer (CR# 5205)
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
**/

public class NodeConfigurationTriggerHandler extends TriggerHandler {
    
    private List<Node_Configuration__c> triggerNew;
    private List<Node_Configuration__c> triggerOld;
    private Map<Id, Node_Configuration__c> triggerMapNew;
    private Map<Id, Node_Configuration__c> triggerMapOld;
    
    private NodeConfigurationServiceLayer nodeConfigurationServiceLayerObj;
    
    public NodeConfigurationTriggerHandler() {
        this.triggerOld = (List<Node_Configuration__c>) Trigger.old;
        this.triggerNew = (List<Node_Configuration__c>) Trigger.new;
        this.triggerMapNew = (Map<Id, Node_Configuration__c>) Trigger.newMap;
        this.triggerMapOld = (Map<Id, Node_Configuration__c>) Trigger.oldMap;
        
        this.nodeConfigurationServiceLayerObj = new NodeConfigurationServiceLayer();
    }
    
    public override void afterUpdate(){
        this.nodeConfigurationServiceLayerObj.sendEmailToNcBusiness(this.triggerNew, this.triggerMapOld);
    }

}