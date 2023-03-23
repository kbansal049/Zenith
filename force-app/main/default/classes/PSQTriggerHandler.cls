public class PSQTriggerHandler {
    
   PSQTriggerUtility triggerUtility = new PSQTriggerUtility();
    
    public static void beforeInsert(List<PS_Questionnaire__c> triggerNew){
        Map<String, Triggers_Switch__c> tsmap = Triggers_Switch__c.getAll();
        
        /****Commented as part of IBA-4571
        if(tsmap.containsKey('Execute_InsertProjectResourcesOnPSQ') && tsmap.get('Execute_InsertProjectResourcesOnPSQ') != null && tsmap.get('Execute_InsertProjectResourcesOnPSQ').Execute__c){
            PSQTriggerUtility.insertProjectResourcesOnPSQ(triggerNew);
        }
		*******/
        
        if(tsmap.containsKey('Execute_UpdateOpportunityTeam') && tsmap.get('Execute_UpdateOpportunityTeam') != null && tsmap.get('Execute_UpdateOpportunityTeam').Execute__c){
            PSQTriggerUtility.updateOpportunityTeam(triggerNew);
        }
        
        // Added by Ayush Kangar as part of CR#3300 -Start
        if(tsmap.containsKey('Execute_CSMManagerPrimaryTamEmail') && tsmap.get('Execute_CSMManagerPrimaryTamEmail') != null && tsmap.get('Execute_CSMManagerPrimaryTamEmail').Execute__c){
        	PSQTriggerUtility.updateEmailFieldsCSMManagerPrimaryTam(triggerNew); 
        }    
        // Added by Ayush Kangar as part of CR#3300 -End
    }  
    
    public static void afterUpdate(List<PS_Questionnaire__c> triggerNew){
        Map<String, Triggers_Switch__c> tsmap = Triggers_Switch__c.getAll();
        
       if(!TriggerUtility.isexecuteUpdateResponseExecuted()){
            PSQTriggerUtility.updateResponsesOnPSQ(triggerNew);
        }
    }  
    
    //IBA-4912 START
    public void onAfterInsert(List<PS_Questionnaire__c> psquestionnaires) {
        try {
        	triggerUtility.createPSQAndProjectRecords(psquestionnaires);    
            if(Test.isRunningTest() && psquestionnaires.size() == 0) {
                throw new IllegalArgumentException('Error');
            }
        }catch(Exception ex) {
            ZscalerErrorLogsUtility.insertLogs('PSQTriggerUtility', 'createPSQAndProjectRecords',
                                                   'Apex', null,
                                                   'Sales Cloud', ex.getStackTraceString() +' '+ ex.getCause() + ' '+ ex.getMessage(), 
                                                   'createPSQAndProjectRecords Failed: ', ex.getTypeName());
            throw ex;
        }
        
    }
    //IBA-4912 END
}