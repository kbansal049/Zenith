public class ActionPlanTriggerUtility {
    public static void createAPHistory(List<Action_Plan__c> newList, map<Id, Action_Plan__c> oldmap){
        List<TAM_Meeting_History__c> tamhistlst = new List<TAM_Meeting_History__c>();
        for(Action_Plan__c ap: newList){
            for (FieldSetMember fm: Schema.SObjectType.Action_Plan__c.fieldSets.getMap().get('Action_Plan_History_Set').getFields()) {
                TAM_Meeting_History__c tamhist = new TAM_Meeting_History__c(Action_Plan__c = ap.Id);
                tamhist.Old_Value__c = oldmap != null && oldmap.get(ap.Id) != null ? String.valueOf(oldmap.get(ap.Id).get(fm.getFieldPath())) : null;
                tamhist.New_Value__c = String.valueOf(ap.get(fm.getFieldPath()));
                tamhist.Field_Modified__c = fm.getLabel();
                tamhist.Field_Modified_API__c = fm.getFieldPath();
                tamhist.Modified_at__c = system.now();
                tamhist.Modified_By__c = UserInfo.getUserId();
                if(tamhist.Old_Value__c != tamhist.New_Value__c){
                    tamhistlst.add(tamhist);
                }
            }
            
        }
        insert tamhistlst;
        TriggerUtility.APHistoryCreationExecuted();
    }
    public static void copyowner(List<Action_Plan__c> newList, map<Id, Action_Plan__c> oldmap){
        for(Action_Plan__c ap: newList){
            if(ap.Owner__c == null){
                ap.Owner__c = UserInfo.getName();   
            }         
        }
        TriggerUtility.OwnerDefaultLogicExecuted();
    }
    // CR#4423 Start  
    public static void UpdateCompletionDate(List<Action_Plan__c> newList, map<Id, Action_Plan__c> oldmap){
        for(Action_Plan__c ap: newList){ 
            if((oldmap==null && ap.Status__c=='Completed') || (ap.Status__c=='Completed' && oldmap!=null && ap.Status__c != oldmap.get(ap.Id).Status__c)){
                ap.Completion_Date__c=System.today();
            }    
        }
        TriggerUtility.updateCompletionDateExecuted();
    }
    // CR#4423 End  
}