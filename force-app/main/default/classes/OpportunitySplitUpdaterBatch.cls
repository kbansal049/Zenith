global class OpportunitySplitUpdaterBatch implements Database.Batchable<sObject>,  Database.Stateful{
    ZscalerBatchFramework zscalerBatchFrameWorkObj = new ZscalerBatchFramework('OpportunitySplitUpdaterBatch');
    public Set<Id> recIds = new Set<Id>();
    global OpportunitySplitUpdaterBatch(Set<Id> ids){
        recIds = ids ;
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
        this.zscalerBatchFrameWorkObj.callStart();
        Set<String> closedStages = new Set<String>{'6 - Closed Won','7 - Closed Lost'};
        String query = 'SELECT Id,Owner_Sales_Territory__c, SplitOwnerId FROM OpportunitySplit  '+ (recIds.isEmpty() ? ' WHERE opportunity.StageName NOT IN : closedStages ' : ' WHERE ID IN:recIds ') ;
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc, List<OpportunitySplit> scope){
        this.zscalerBatchFrameWorkObj.callExecute(scope[0]?.Id, scope.size());
        Set<Id> OwnerIds = new Set<Id>();
        List<OpportunitySplit> oppSpilts = new List<OpportunitySplit>();
        for(OpportunitySplit os: scope){ 
               //LOGIC TO get split owner sales territory 
               OwnerIds.add(os.SplitOwnerId);
        }
        //Map of UserId and Patch team Id
        Map<Id, Id> ownerPatchMap = getOwnerPatch(ownerIds);
        
        for(OpportunitySplit os: scope){ 
            Id newPatchId = (!ownerPatchMap.isEmpty() && ownerPatchMap.containsKey(os.SplitOwnerId)) ? ownerPatchMap.get(os.SplitOwnerId) : null; 
            if(newPatchId!=NULL && os.Owner_Sales_Territory__c!=newPatchId){
                os.Owner_Sales_Territory__c = newPatchId;
                oppSpilts.add(os);
            }
        }
        
        
       Database.update (oppSpilts,false);
    }
    
    @TestVisible
    private static Map<Id, Id> getOwnerPatch( Set<Id> splitOwnerIds){
        Map<Id, Id> userPatchMap = new Map<Id, Id>();
        
        for(PatchTeamMember__c salesTeam : [Select Id, PatchTeam__c , User__c from PatchTeamMember__c where User__c IN: splitOwnerIds AND PatchTeam__r.Sales_Territory_Year__c = 'Current']){
            if (!userPatchMap.containsKey(salesTeam.User__c)) {
                userPatchMap.put(salesTeam.User__c,salesTeam.PatchTeam__c);
            }
        }   
        return userPatchMap;  
    }
    
    global void finish(Database.BatchableContext BC){
        this.zscalerBatchFrameWorkObj.callFinish(BC);
    }
    
}