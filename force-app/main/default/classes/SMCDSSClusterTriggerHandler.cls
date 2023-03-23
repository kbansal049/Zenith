public class SMCDSSClusterTriggerHandler extends TriggerHandler {
    
	public override void beforeInsert(){
        List<SMCDSS_DLP_Cluster__c> smList = (List<SMCDSS_DLP_Cluster__c>) trigger.new;
         updateSfCloudValue(smList, NULL, FALSE);
    }
    
    public override void beforeUpdate(){
        List<SMCDSS_DLP_Cluster__c> smList = (List<SMCDSS_DLP_Cluster__c>) trigger.new;
        MAP<ID,SMCDSS_DLP_Cluster__c> oldSmMap = (MAP<ID,SMCDSS_DLP_Cluster__c>) trigger.oldmap;
        updateSfCloudValue(smList, oldSmMap, TRUE);
    }
    
    public override void afterInsert() {
    }
    
    public override void afterUpdate() {
    }
    
    @testvisible
    private void updateSfCloudValue(List<SMCDSS_DLP_Cluster__c> smList, MAP<ID,SMCDSS_DLP_Cluster__c> oldSmMap, Boolean isUpdate){
        Map<String, String> cloudMap = new Map<String, String>();
    	List<PreferredCloudMapping__mdt> preferredCloudList = [SELECT Id, SF_Value__c, Broker_Value__c, MasterLabel, DeveloperName FROM PreferredCloudMapping__mdt];
        for(PreferredCloudMapping__mdt pr : preferredCloudList){
            if(pr.SF_Value__c != NULL && pr.Broker_Value__c != NULL){
        		cloudMap.put(pr.Broker_Value__c,pr.SF_Value__c);   
            }
        }
        if(!isUpdate){
            for(SMCDSS_DLP_Cluster__c sm : smList){
                if(sm.cloud__c != NULL && cloudMap != NULL && cloudMap.containsKey(sm.cloud__c)){
                	sm.SF_Cloud__c = cloudMap.get(sm.cloud__c);
                }    
            }    
        }
        else{
        	for(SMCDSS_DLP_Cluster__c sm : smList){
                if(sm.cloud__c != NULL && sm.cloud__c != oldSmMap.get(sm.Id).cloud__c && cloudMap != NULL && cloudMap.containsKey(sm.cloud__c)){
                	sm.SF_Cloud__c = cloudMap.get(sm.cloud__c);
                }    
            }    
        }
    }
}