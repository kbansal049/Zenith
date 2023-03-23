public class GCSProjectTriggerHandler {
    
    public static void beforeInsert(List<GCS_Project__c> newList){
        Map<String, Triggers_Switch__c> tsmap = Triggers_Switch__c.getAll();
        if(tsmap.containsKey('Execute_UpdateCompletionDate') && tsmap.get('Execute_UpdateCompletionDate') != null && tsmap.get('Execute_UpdateCompletionDate').Execute__c){
            GCSProjectTriggerUtility.UpdateCompletionDate(newList,null);
        }
    }
    
    public static void beforeUpdate(List<GCS_Project__c> newList, Map<Id, GCS_Project__c> oldmap){
        Map<String, Triggers_Switch__c> tsmap = Triggers_Switch__c.getAll();
        if(tsmap.containsKey('Execute_UpdateCompletionDate') && tsmap.get('Execute_UpdateCompletionDate') != null && tsmap.get('Execute_UpdateCompletionDate').Execute__c){
            GCSProjectTriggerUtility.UpdateCompletionDate(newList,oldmap);
        }
        if(tsmap.containsKey('Execute_ValidateAttachment') && tsmap.get('Execute_ValidateAttachment') != null && tsmap.get('Execute_ValidateAttachment').Execute__c){
            GCSProjectTriggerUtility.ValidateAttachment(newList,oldmap);
        }
    }
}