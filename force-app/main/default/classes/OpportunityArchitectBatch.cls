global class OpportunityArchitectBatch implements Database.Batchable<sObject>,  Database.Stateful{
    
    ZscalerBatchFramework zscalerBatchFrameWorkObj = new ZscalerBatchFramework('OpportunityArchitectBatch');

    global Database.QueryLocator start(Database.BatchableContext BC){
        this.zscalerBatchFrameWorkObj.callStart();
        String query = 'SELECT Id,Name,Solution_Architect__c FROM Account where Solution_Architect__c != null';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC,List<Account> scope){
        this.zscalerBatchFrameWorkObj.callExecute(scope[0]?.Id, scope.size());
        Map<Id,List<Opportunity>> accOppMap = getOppAccMap(scope);
        List<Opportunity> oppList = new List<Opportunity>();
        for(Account a : scope)
        { 
            for (Opportunity o:accOppMap.containsKey(a.Id) ? accOppMap.get(a.Id) : new List<Opportunity>()){
                o.Architect__c = a.Solution_Architect__c; 
                oppList.add(o);
            }
        }       
        
        Database.update(oppList);
    }

    @testVisible
    private static Map<Id,list<Opportunity>> getOppAccMap(list<Account> accounts){
        Map<Id,List<Opportunity>> oppAccMap =  new Map<Id,List<Opportunity>>();
        for(Opportunity o :[SELECT Id,Name,Architect__c,AccountId FROM Opportunity where AccountId In:accounts]){
           if(!oppAccMap.containsKey(o.AccountId)){
                oppAccMap.put(o.AccountId, new List<Opportunity>());
            }
                List<Opportunity> opplist = oppAccMap.get(o.AccountId);
            opplist.add(o);
                oppAccMap.put(o.AccountId, opplist);
            
        }
       
        return oppAccMap;
        }
    
    global void finish(Database.BatchableContext BC){
        this.zscalerBatchFrameWorkObj.callFinish(BC);
    }
}