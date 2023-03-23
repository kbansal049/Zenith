@RestResource(urlMapping='/ClusterObjectsSoftDeleteAPI/*')
global with sharing class ClusterObjectsDataCleanupAPI {

    @HttpPatch
    global static void doDelete() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        List<Nanolog_Cluster__c> nanologClusters = [SELECT Id, Is_Disabled__c FROM Nanolog_Cluster__c];
        List<Sandbox_Cluster__c> sandboxClusters = [SELECT Id, Is_Disabled__c FROM Sandbox_Cluster__c];
        List<SMCDSS_DLP_Cluster__c> dlpClusters = [SELECT Id, Is_Disabled__c FROM SMCDSS_DLP_Cluster__c];
        
        for(Nanolog_Cluster__c nc: nanologClusters) {
            nc.Is_Disabled__c = true;
        }
        
        for(Sandbox_Cluster__c sc: sandboxClusters) {
            sc.Is_Disabled__c = true;
        }
        
        for(SMCDSS_DLP_Cluster__c dlp: dlpClusters) {
            dlp.Is_Disabled__c = true;
        }
        try{
        	update nanologClusters; 
        	update sandboxClusters;
        	update dlpClusters; 
        }
        catch(Exception ex){
        	ProvisioningErrorHandler.exceptionHandler('ClusterObjectsDataCleanupAPI','doDelete',ex);    
        }
    }
}