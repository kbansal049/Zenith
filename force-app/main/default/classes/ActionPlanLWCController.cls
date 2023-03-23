public class ActionPlanLWCController {
@auraenabled 
Public static void updateAllInDoc(List<SObject> records){
TriggerUtility.SkipCaseTriggerExecuted();
if(records[0].getSObjectType().getDescribe().getName() == 'Case'){
    Map<Id, Boolean> visibleInDocRecords= new Map<Id,Boolean>(); 
    List<Case> listToUpdate=new List<Case>();
    for(SObject cs : records){
        Id caseId = (Id)cs.get('Id');
        Boolean cDoc = (Boolean)cs.get('Visible_In_Doc__c');
        visibleInDocRecords.put(caseId,cDoc);
    }
    for(Case cs : [select id,Visible_In_Doc__c from Case where Id IN :visibleInDocRecords.keySet()]){
        cs.Visible_In_Doc__c = visibleInDocRecords.get(cs.Id);
        listToUpdate.add(cs);
    }
    if(!listToUpdate.isEmpty()){
        update listToUpdate;
    }
}else{
    update records;
}



}

}