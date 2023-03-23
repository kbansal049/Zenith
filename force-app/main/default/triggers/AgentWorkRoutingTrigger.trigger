trigger AgentWorkRoutingTrigger on AgentWork (after update, after insert, before update, before insert) {
    //Added by Anup : CR#686 - Start
    Map<String, Triggers_Switch__c> tsmap = Triggers_Switch__c.getAll();
    if(tsmap != null 
        && !tsmap.isEmpty() 
        && tsmap.containsKey('Execute_AgentWork_Trigger') 
        && tsmap.get('Execute_AgentWork_Trigger') != null 
        && tsmap.get('Execute_AgentWork_Trigger').Execute__c){
        if(trigger.isAfter && trigger.isInsert){
            AgentWorkTriggerHandler.afterUpdate(Trigger.new, null);
        }
        if(trigger.isAfter && trigger.isUpdate && !TriggerUtility.isAgentWorkAfterUpdateExecuted()){
            AgentWorkTriggerHandler.afterUpdate(Trigger.new, trigger.OldMap);
        }
    }
    //Added by Anup : CR#686 - Start

    if(tsmap != null 
        && !tsmap.isEmpty() 
        && tsmap.containsKey('Execute_AgentWork_AgentInfomation') 
        && tsmap.get('Execute_AgentWork_AgentInfomation') != null 
        && tsmap.get('Execute_AgentWork_AgentInfomation').Execute__c){
        if((trigger.isAfter && trigger.isInsert) || Test.isRunningTest()){
            AgentWorkTriggerUtility.updateServiceResourceInformation(Trigger.new);
        }
    }
}