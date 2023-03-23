// Added by Abhijit for CR851
public class CXOAdvisorRequestTriggerHandler {
    public static void afterInsert(List<CXO_Advisor_Request__c> triggerNew){

        Map<String, Triggers_Switch__c> tsmap = Triggers_Switch__c.getAll();
        if(tsmap != null && !tsmap.isEmpty() && tsmap.containsKey('Execute_Populate_CXO_Advisor') && tsmap.get('Execute_Populate_CXO_Advisor') != null && tsmap.get('Execute_Populate_CXO_Advisor').Execute__c && !TriggerUtility.isPopulateCXOAdvisorExecuted()){
            TriggerUtility.cXOAdvisorRequestAfterInsertExecuted();
            CXOAdvisorRequestTriggerUtility.populateCXOAdvisor(triggerNew, null);
        }
        
    }
    
    public static void afterUpdate(List<CXO_Advisor_Request__c> triggerNew, Map<Id, CXO_Advisor_Request__c> oldMap){

        Map<String, Triggers_Switch__c> tsmap = Triggers_Switch__c.getAll();
        if(tsmap != null && !tsmap.isEmpty() && tsmap.containsKey('Execute_Populate_CXO_Advisor') && tsmap.get('Execute_Populate_CXO_Advisor') != null && tsmap.get('Execute_Populate_CXO_Advisor').Execute__c && !TriggerUtility.isPopulateCXOAdvisorExecuted()){
            TriggerUtility.cXOAdvisorRequestAfterUpdateExecuted();
            CXOAdvisorRequestTriggerUtility.populateCXOAdvisor(triggerNew, oldMap);            
        }

    }
    
    // Added by Ayush Kangar as part of CR# 3856 - Start
        public static void beforeInsertAndUpdate(List<CXO_Advisor_Request__c> triggerNew){
        if(!TriggerUtility.ispopulateTeamAdvisorExecuted()){
            TriggerUtility.populateTeamAdvisorExecuted();
            CXOAdvisorRequestTriggerUtility.populateTeamAdvisor(triggerNew);
        }     
    }
        public static void beforeUpdate(List<CXO_Advisor_Request__c> triggerNew,Map<Id, CXO_Advisor_Request__c> oldMap){
            CXOAdvisorRequestTriggerUtility.populateRequestType(triggerNew,oldMap);    
            CXOAdvisorRequestTriggerUtility.updateCisoCtoFromAccountExt(triggerNew,oldMap);    // Added by Ayush Kangar as part of CR# 4587
    }
    // Added by Ayush Kangar as part of CR# 3856 - End
    // Added by Ayush Kangar as part of CR# 4587 - Start
    public static void beforeInsert(List<CXO_Advisor_Request__c> triggerNew){
            CXOAdvisorRequestTriggerUtility.populateCisoCtoFromAccountExt(triggerNew);    
    }
    // Added by Ayush Kangar as part of CR# 4587 - End
}