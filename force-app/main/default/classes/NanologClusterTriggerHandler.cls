public class NanologClusterTriggerHandler extends TriggerHandler {
    
	public override void beforeInsert(){
        List<Nanolog_Cluster__c> ncList = (List<Nanolog_Cluster__c>) trigger.new;
         updateSfCloudValue(ncList, NULL, FALSE);
    }
    
    public override void beforeUpdate(){
        List<Nanolog_Cluster__c> ncList = (List<Nanolog_Cluster__c>) trigger.new;
        MAP<ID,Nanolog_Cluster__c> oldNcMap = (MAP<ID,Nanolog_Cluster__c>) trigger.oldmap;
        updateSfCloudValue(ncList, oldNcMap, TRUE);
    }
    
    public override void afterInsert() {
    }
    
    public override void afterUpdate() {
    }
    
    @testvisible
    private void updateSfCloudValue(List<Nanolog_Cluster__c> ncList, MAP<ID,Nanolog_Cluster__c> oldNcMap, Boolean isUpdate){
        Map<String, String> cloudMap = new Map<String, String>();
    	List<PreferredCloudMapping__mdt> preferredCloudList = [SELECT Id, SF_Value__c, Broker_Value__c, MasterLabel, DeveloperName FROM PreferredCloudMapping__mdt];
        for(PreferredCloudMapping__mdt pr : preferredCloudList){
            if(pr.SF_Value__c != NULL && pr.Broker_Value__c != NULL){
        		cloudMap.put(pr.Broker_Value__c,pr.SF_Value__c);   
            }
        }
        if(!isUpdate){
            for(Nanolog_Cluster__c nc : ncList){
                if(nc.cloud__c != NULL && cloudMap != NULL && cloudMap.containsKey(nc.cloud__c)){
                	nc.SF_Cloud__c = cloudMap.get(nc.cloud__c);
                }    
            }    
        }
        else{
        	for(Nanolog_Cluster__c nc : ncList){
                if(nc.cloud__c != NULL && nc.cloud__c != oldNcMap.get(nc.Id).cloud__c && cloudMap != NULL && cloudMap.containsKey(nc.cloud__c)){
                	nc.SF_Cloud__c = cloudMap.get(nc.cloud__c);
                }    
            }    
        }
    }
}