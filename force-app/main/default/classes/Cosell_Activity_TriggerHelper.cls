public class Cosell_Activity_TriggerHelper {
    public static void beforeInsert(List<Cosell_Activities__c> newList){
        Map<String, Triggers_Switch__c> tsmap = Triggers_Switch__c.getAll();
        assignStatusStartDate(newList, null);
        assignStatusLastModified(newList, null);
        TriggerUtility.CosellBeforeInsertExecuted();
    }

    public static void beforeUpdate(List<Cosell_Activities__c> newList, Map<Id, Cosell_Activities__c> oldmap){
        Map<String, Triggers_Switch__c> tsmap = Triggers_Switch__c.getAll();

        assignStatusStartDate(newList, oldmap);
        if(!TriggerUtility.isSkipCosellStatusLMExecuted() && tsmap != null && !tsmap.isEmpty() && tsmap.containsKey('Execute_Cosell_Status_LastModified') && tsmap.get('Execute_Cosell_Status_LastModified') != null && tsmap.get('Execute_Cosell_Status_LastModified').Execute__c){
            assignStatusLastModified(newList, oldmap);
        }
        
        TriggerUtility.CosellBeforeUpdateExecuted();
    }

    public static void assignStatusStartDate(List<Cosell_Activities__c> newList, Map<Id, Cosell_Activities__c> oldmap){
        for(Cosell_Activities__c csa: newList){
            if(csa.Status__c != null && (oldmap == null || csa.Status__c != oldmap.get(csa.Id).Status__c)){
                csa.Status_Start_Date__c = System.now();
            }
        }
    }

    public static void assignStatusLastModified(List<Cosell_Activities__c> newList, Map<Id, Cosell_Activities__c> oldmap){
        for(Cosell_Activities__c csa: newList){
            if(csa.Status__c != null && (oldmap == null || csa.Status__c != oldmap.get(csa.Id).Status__c)){
                csa.Status_Modified_By_User__c = UserInfo.getUserId();
            }
        }

        if(oldmap != null){
            TriggerUtility.SkipCosellStatusLMExecuted();
        }
    }
}