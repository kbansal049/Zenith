public class ChangeRequestTriggerHandler {
    
    public static void beforeInsert(List<Tracker_Change_Request__c> newCRList){
        Map<String, Triggers_Switch__c> tsmap = Triggers_Switch__c.getAll();
        if(tsmap.containsKey('Execute_Parent_CR_Update') && tsmap.get('Execute_Parent_CR_Update') != null && tsmap.get('Execute_Parent_CR_Update').Execute__c && !TriggerUtility.isUpdateParentChangeRequestExecuted()){
            ChangeRequestTriggerUtility.updateParentChangeRequest(newCRList);
        }
    }
    
    public static void afterInsert(List<Tracker_Change_Request__c> newCRList){
        Map<String, Triggers_Switch__c> tsmap = Triggers_Switch__c.getAll();
        if(tsmap.containsKey('Execute_BA_CR_Update_On_Case') && tsmap.get('Execute_BA_CR_Update_On_Case') != null && tsmap.get('Execute_BA_CR_Update_On_Case').Execute__c && !TriggerUtility.isUpdateBaCROnCaseExecuted()){
            ChangeRequestTriggerUtility.updateBaAndCrOnCase(newCRList);
        }
        //Added by Gurjinder : CR# 1372 :Start
        if(tsmap.containsKey('Execute_CreateUserStoryfromCR') && tsmap.get('Execute_CreateUserStoryfromCR') != null && tsmap.get('Execute_CreateUserStoryfromCR').Execute__c && !TriggerUtility2.isCreateUserStoryfromCRExecuted()){
            ChangeRequestTriggerUtility.CreateUserStoryfromCR(newCRList,null);
        }
        //Added by Gurjinder : CR# 1372 :End
        
        
    }

    public static void afterUpdate(List<Tracker_Change_Request__c> newCRList, Map<Id, Tracker_Change_Request__c> oldMap){
        Map<String, Triggers_Switch__c> tsmap = Triggers_Switch__c.getAll();
        if(tsmap.containsKey('Execute_Sync_BA_From_CR_To_Case') && tsmap.get('Execute_Sync_BA_From_CR_To_Case') != null && tsmap.get('Execute_Sync_BA_From_CR_To_Case').Execute__c && !TriggerUtility.isSyncBAOnCaseExecuted()){
            ChangeRequestTriggerUtility.syncBusinessAnalyst(newCRList,oldMap);
        }
        //Added by Gurjinder : CR# 1372 :Start
        system.debug('TriggerUtility2.isCreateUserStoryfromCRExecuted() '+TriggerUtility2.isCreateUserStoryfromCRExecuted());
        if(tsmap.containsKey('Execute_CreateUserStoryfromCR') && tsmap.get('Execute_CreateUserStoryfromCR') != null && tsmap.get('Execute_CreateUserStoryfromCR').Execute__c && !TriggerUtility2.isCreateUserStoryfromCRExecuted()){
            ChangeRequestTriggerUtility.CreateUserStoryfromCR(newCRList,oldMap);
        }
        //Added by Gurjinder : CR# 1372 :End
        //Added by Tirth: Audit CR Stage
        if(tsmap.containsKey('Execute_requestChangeStatus') && tsmap.get('Execute_requestChangeStatus') != null && tsmap.get('Execute_requestChangeStatus').Execute__c ){
            ChangeRequestTriggerUtility.requestChangeStatus(newCRList,oldMap);
        }
    }
  
    
}