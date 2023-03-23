global class BatchToUpdateCisoCtoOnAccountExtention implements Database.Batchable<sObject>, Database.Stateful{
    
    ZscalerBatchFramework zb = new ZscalerBatchFramework('BatchToUpdateCisoCtoOnAccountExtention');
    global final String query;
    global BatchToUpdateCisoCtoOnAccountExtention(String q)
    {
        query=q; 
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
        this.zb.callStart();
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC,List<Account_Extension__c> AccExtList){
        this.zb.callExecute(AccExtList[0]?.Id, AccExtList.size());
        List<Account_Extension__c> AccExtListNew = new List<Account_Extension__c>();
        Map<String,Id> areaCisoMap = new Map<String,Id>();
        Map<String,Id> regionCtoMap = new Map<String,Id>();
        for(CTO_CISO_Transformation_Team_Member__c teamMember : [select type__c,Area__c,Region__c,Linked_CTO_Team_Member__c,Linked_CISO_Team_Member__c  from CTO_CISO_Transformation_Team_Member__c]){
            if(teamMember.type__c == 'Field CTO'){
                regionCtoMap.put(teamMember.Region__c,teamMember.Linked_CTO_Team_Member__c);
            }
            if(teamMember.type__c == 'Field CISO'){
                areaCisoMap.put(teamMember.Area__c,teamMember.Linked_CISO_Team_Member__c);
                    }
        }
        for(Account_Extension__c accExt : AccExtList){
            if(!areaCisoMap.isEmpty() && areaCisoMap.containsKey(accExt.Account__r.Region__c)){
                accExt.Field_CISO__c = areaCisoMap.get(accExt.Account__r.Region__c);
            }
            if(!regionCtoMap.isEmpty() && regionCtoMap.containsKey(accExt.Account__r.Area__c)){
                accExt.Field_CTO__c = regionCtoMap.get(accExt.Account__r.Area__c);
            }
            AccExtListNew.add(accExt); 
        }
        if(!AccExtListNew.isEmpty()){
            update AccExtListNew;
        }
    }    
    global void finish(Database.BatchableContext BC){
        this.zb.callFinish(BC);
    }
}