//updated logic to populate Channel_Manager__c based on new logic CR# 2795
public class updateChannelManagersBatch implements Database.Batchable<sObject>, Database.Stateful{
    ZscalerBatchFramework zb = new ZscalerBatchFramework('updateChannelManagersBatch');
    public string query; 
    
    public updateChannelManagersBatch(String query){
        //this.query = query;
        this.query = 'SELECT Id, Sales_Territory__c, RecordType.Name, Status__c,Partner_Account__c  FROM Deal_Reg__c WHERE Sales_Territory__c != null AND Channel_Manager__c = null and Partner_Type__c !=\'Technology Partner\' ';
    }
    
    public Database.QueryLocator start(Database.BatchableContext context){
        this.zb.callStart();
        return Database.getQueryLocator(query);
    }
    
    public void execute (Database.BatchableContext context, List<Deal_Reg__c> scope){
        this.zb.callExecute(scope[0]?.Id, scope.size());
        List<Deal_Reg__c> lstToUpdate = new List<Deal_Reg__c>();
        set<id> salesTerritoryIdSet = new set<id>();
        set<id> partnerAccountIdSet = new set<id>();
        for(Deal_Reg__c deal : scope){
            if(deal.Sales_Territory__c != null){
                salesTerritoryIdSet.add(deal.Sales_Territory__c);  
            }
            if(deal.Partner_Account__c != null){
                partnerAccountIdSet.add(deal.Partner_Account__c);  
            }
        }
        Set<ID> partnerAccountIds = New Set<Id>();
        for(Account acc : [Select Id,Ultimate_Parent_Account__c from Account where Id In : partnerAccountIdSet]){
            if(acc.Ultimate_Parent_Account__c != null){
                partnerAccountIds.add(acc.Ultimate_Parent_Account__c );
            }else{
                partnerAccountIds.add(acc.Id);
            }
        }        
        Map<String, Id> territorySalesUserIdMap = new Map<String, Id>();
        Map<String,Id> ramIdVsFocusPartnerkeyStrMap = new Map<String, Id>();
        if(!salesTerritoryIdSet.isEmpty()){
            for(PatchTeam__c territory : [Select id, (Select Id, Role__c, PatchTeam__c, User__c,User__r.ManagerId from PatchTeamMembers__r) 
                                         from PatchTeam__c where ID IN: salesTerritoryIdSet]){
                for(PatchTeamMember__c salesTeam : territory.PatchTeamMembers__r){
                    if(salesTeam.Role__c == 'Channel Manager'){
                        territorySalesUserIdMap.put(''+territory.id+'ChannelManager', salesTeam.User__c);
                    }
                }
            }
        }
        for(Focus_Partner__c fp : [  SELECT Id, Partner_Account__c, RAM__c,Sales_Territory__c FROM Focus_Partner__c WHERE Partner_Account__c IN :partnerAccountIdSet and Sales_Territory__c in :salesTerritoryIdSet ]){
          
                String fpKey = fp.Sales_Territory__c+'_'+ fp.Partner_Account__c;
                ramIdVsFocusPartnerkeyStrMap.put( fpKey, fp.RAM__c);
                System.debug('fpKey'+fpKey);
            
            
        }
        String ignoreRecordType = 'Renewal Deal Reg'; // Converted Renewable records
        
        for(Deal_Reg__c deal : scope){
            if(deal.RecordType.Name != ignoreRecordType && deal.Status__c != 'Converted'){
                String keyStr =  deal.Sales_Territory__c+'_'+ deal.Partner_Account__c;
                if(ramIdVsFocusPartnerkeyStrMap.containskey(keyStr)){
                    deal.Channel_Manager__c = ramIdVsFocusPartnerkeyStrMap.get(keyStr);
                }else{
                    deal.Channel_Manager__c = territorySalesUserIdMap.get(''+deal.Sales_Territory__c+'ChannelManager');
                }
                lstToUpdate.add(deal);
            }
        }
        TriggerUtility.dealRegAfterUpdateExecuted();
        TriggerUtility.dealRegBeforeUpdateExecuted();       
        if(!lstToUpdate.IsEmpty() && lstToUpdate.size() > 0){
            update lstToUpdate;
        }
    }
    
    public void finish(Database.BatchableContext context){
        this.zb.callFinish(context);
    }
}