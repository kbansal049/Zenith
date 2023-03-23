/**
* @author        Zscaler
* @modifiedBy     
* @maintainedBy   Zscaler
* @version        1.0
* @created        2021-11-16
* @modified       
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* vX.X            Developer Name
* YYYY-MM-DD      Explanation of the change.  Multiple lines can be used to explain the change, but
*                 each line should be indented till left aligned with the previous description text.
*
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
**/
public class OpportunityExtensionTriggerHandler extends TriggerHandler {
    public override void afterUpdate(){
        System.debug('OpportunityExtensionTriggerHandler.afterUpdate() is Invoked');
        System.debug('OpportunityExtensionTriggerHandler.afterUpdate() SOQLs: '+ Limits.getQueries()+'; DMLs: '+Limits.getDmlStatements()+ '; CPU: '+Limits.getCpuTime());
        
        ManageRecursive.timesOpportunityExtensionInvoked = ManageRecursive.timesOpportunityExtensionInvoked + 1;
        
        Map<Id, Opportunity_Extension__c> newOppExtMap = new Map<Id,Opportunity_Extension__c>();
        Map<Id, Opportunity_Extension__c> oldOppExtMap = new Map<Id,Opportunity_Extension__c>();
        
        Set<Id> originalOppIdSet = new Set<Id>();
        Set<Id> duplicateOppIdSet = new Set<Id>();
        
        Map<Id,Id> originalIdDuplicateIdMap = new Map<Id,Id>();
        Map<Id,Opportunity> originalOppRecordsMap = new Map<Id,Opportunity>();
        Map<Id,Opportunity> duplicateOppRecordsMap = new Map<Id,Opportunity>();
        
        for (SObject oppExt: Trigger.new) {
            Opportunity_Extension__c newOppExt = (Opportunity_Extension__c) oppExt;
            Opportunity_Extension__c oldOppExt = (Opportunity_Extension__c) Trigger.oldMap.get(newOppExt.Id);
            
            if(!ManageRecursive.processedOpportunityExtensionIds.contains(newOppExt.Id) 
                || qualifiedUpdate(newOppExt, oldOppExt)){
                newOppExtMap.put(newOppExt.Id, newOppExt);
                oldOppExtMap.put(oldOppExt.Id, oldOppExt);
                
                ManageRecursive.processedOpportunityExtensionIds.add(newOppExt.Id);
                
                System.Debug('OpportunityExtensionTriggerHandler: ' + ManageRecursive.timesOpportunityExtensionInvoked);
                System.debug('OpportunityExtensionTriggerHandler Processed Ids: ' + ManageRecursive.processedOpportunityExtensionIds);
                System.debug('OpportunityExtensionTriggerHandler newOppExtMap: ' + newOppExtMap);
            }
            //CR# 3357 START
            //Add-Update Opportunity record's Renewal_Notes__c field with Duplicate Oppotunity Name
            if(newOppExt.Duplicate_Opportunity__c != null){
                originalOppIdSet.add(newOppExt.Opportunity__c);
                duplicateOppIdSet.add(newOppExt.Duplicate_Opportunity__c);
                
                originalIdDuplicateIdMap.put(newOppExt.Opportunity__c, newOppExt.Duplicate_Opportunity__c);
            }
            //CR# 3357 END
        }
        System.debug('OpportunityExtensionTriggerHandler afterUpdate Is Invoked newOppExtMap : ' + newOppExtMap);
        System.debug('OpportunityExtensionTriggerHandler afterUpdate Is Invoked oldOppExtMap : ' + oldOppExtMap);
        
        //CR# 3357 START
        if(!originalIdDuplicateIdMap.isEmpty()){
            //get original opp records
            List<Id> oppIdList = new List<Id>();
            oppIdList.addAll(originalIdDuplicateIdMap.keySet());
            originalOppRecordsMap = getOpportunityRecords(oppIdList);
            
            //get duplicate opp records
            duplicateOppRecordsMap = getOpportunityRecords(originalIdDuplicateIdMap.values());
        }
        
        if(!duplicateOppRecordsMap.isEmpty() && !originalOppRecordsMap.isEmpty()){
            //update original opp records
            updateOriginalOpportunityRecords(duplicateOppRecordsMap, originalOppRecordsMap, originalIdDuplicateIdMap);
        }
        //CR# 3357 END
    }
    
    public boolean qualifiedUpdate(Opportunity_Extension__c newOppExt, Opportunity_Extension__c oldOppExt){
        Boolean valChanged = false;
        /*if(newOppExt.Name != oldOppExt.Name){
            valChanged = true;
        } */
        return valChanged;
    } 
    
    private Map<Id,Opportunity> getOpportunityRecords(List<Id> oppIdList){
        Map<Id,Opportunity> retrivedOppRecords = new Map<Id,Opportunity>(
            									 [SELECT Id, Name,
                                                  Renewal_Notes__c
                                                  FROM Opportunity
                                                  WHERE Id IN : oppIdList]);
        
        return retrivedOppRecords;
    }
    
    private void updateOriginalOpportunityRecords(
        Map<Id,Opportunity> duplicateOppRecordsMap, 
        Map<Id,Opportunity> originalOppRecordsMap,
        Map<Id,Id> duplicateIdOriginalIdMap){
        List<Opportunity> oppToUpdateList = new List<Opportunity>();
        for(Opportunity oppRecord : originalOppRecordsMap.values()){
            if(oppRecord.Renewal_Notes__c != NULL){
                oppRecord.Renewal_Notes__c += ' Name of Duplicate Opportunity Linked : ' + 
                    duplicateOppRecordsMap.get(duplicateIdOriginalIdMap.get(oppRecord.Id)).Name;
            }else {
                oppRecord.Renewal_Notes__c = ' Name of Duplicate Opportunity Linked : ' + 
                    duplicateOppRecordsMap.get(duplicateIdOriginalIdMap.get(oppRecord.Id)).Name + ' ';
            }
            oppToUpdateList.add(oppRecord);
        }
        
        if(!oppToUpdateList.isEmpty()){
            update oppToUpdateList;
        }
    }
}