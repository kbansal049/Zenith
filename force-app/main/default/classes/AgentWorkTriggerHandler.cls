public class AgentWorkTriggerHandler {
    public static void afterUpdate(List<AgentWork> triggerNew, Map<Id, AgentWork> oldMap){

        Map<String, Triggers_Switch__c> tsmap = Triggers_Switch__c.getAll();
        if(tsmap != null && !tsmap.isEmpty() && tsmap.containsKey('Execute_Populate_Case_Routing') && tsmap.get('Execute_Populate_Case_Routing') != null && tsmap.get('Execute_Populate_Case_Routing').Execute__c && !TriggerUtility.isAutoCaseAssignExecuted()){
            AgentWorkTriggerUtility.populateCaseRoutingDetails(triggerNew, oldMap);
        }

        TriggerUtility.AgentWorkAfterUpdateExecuted();
    }
}