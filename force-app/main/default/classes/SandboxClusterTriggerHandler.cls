public class SandboxClusterTriggerHandler extends TriggerHandler {
    
	public override void beforeInsert(){
        List<Sandbox_Cluster__c> sbList = (List<Sandbox_Cluster__c>) trigger.new;
         updateSfCloudValue(sbList, NULL, FALSE);
    }
    
    public override void beforeUpdate(){
        List<Sandbox_Cluster__c> sbList = (List<Sandbox_Cluster__c>) trigger.new;
        MAP<ID,Sandbox_Cluster__c> oldSbMap = (MAP<ID,Sandbox_Cluster__c>) trigger.oldmap;
        updateSfCloudValue(sbList, oldSbMap, TRUE);
    }
    
    public override void afterInsert() {
    }
    
    public override void afterUpdate() {
    }
    
    @testvisible
    private void updateSfCloudValue(List<Sandbox_Cluster__c> sbList, MAP<ID,Sandbox_Cluster__c> oldSbMap, Boolean isUpdate){
        Map<String, String> cloudMap = new Map<String, String>();
    	List<PreferredCloudMapping__mdt> preferredCloudList = [SELECT Id, SF_Value__c, Broker_Value__c, MasterLabel, DeveloperName FROM PreferredCloudMapping__mdt];
        for(PreferredCloudMapping__mdt pr : preferredCloudList){
            if(pr.SF_Value__c != NULL && pr.Broker_Value__c != NULL){
        		cloudMap.put(pr.Broker_Value__c,pr.SF_Value__c);   
            }
        }
        if(!isUpdate){
            for(Sandbox_Cluster__c sb : sbList){
                if(sb.cloud__c != NULL && cloudMap != NULL && cloudMap.containsKey(sb.cloud__c)){
                	sb.SF_Cloud__c = cloudMap.get(sb.cloud__c);
                }    
            }    
        }
        else{
        	for(Sandbox_Cluster__c sb : sbList){
                if(sb.cloud__c != NULL && sb.cloud__c != oldSbMap.get(sb.Id).cloud__c && cloudMap != NULL && cloudMap.containsKey(sb.cloud__c)){
                	sb.SF_Cloud__c = cloudMap.get(sb.cloud__c);
                }    
            }    
        }
    }
}