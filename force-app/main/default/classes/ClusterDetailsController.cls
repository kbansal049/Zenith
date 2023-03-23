public without sharing class ClusterDetailsController {

    @AuraEnabled(Cacheable=true)
    public static List<ClusterDetailsWrapper> getALLClusterRecords(){
        List<ClusterDetailsWrapper> prodlist = new List<ClusterDetailsWrapper>();
        
        List<Nanolog_Cluster__c> nanoLogList = [Select Id,name,  SF_Cloud__c, Cloud__c from Nanolog_Cluster__c];
        for(Nanolog_Cluster__c nan:nanoLogList){
            ClusterDetailsWrapper cdw = new ClusterDetailsWrapper();
            cdw.name = nan.name;
            cdw.sfCloud = nan.SF_Cloud__c;
            cdw.cloud = nan.Cloud__c;
            cdw.clusterObject = 'Nanalog Clusters';
            prodlist.add(cdw);
        }

        List<Sandbox_Cluster__c> sandboxList = [Select Id,name,  SF_Cloud__c, Cloud__c from Sandbox_Cluster__c];
        for(Sandbox_Cluster__c nan:sandboxList){
            ClusterDetailsWrapper cdw = new ClusterDetailsWrapper();
            cdw.name = nan.name;
            cdw.sfCloud = nan.SF_Cloud__c;
            cdw.cloud = nan.Cloud__c;
            cdw.clusterObject = 'Sandbox Clusters';
            prodlist.add(cdw);
        }

        List<SMCDSS_DLP_Cluster__c> smcdssLogList = [Select Id,name,  SF_Cloud__c, Cloud__c from SMCDSS_DLP_Cluster__c];
        for(SMCDSS_DLP_Cluster__c nan:smcdssLogList){
            ClusterDetailsWrapper cdw = new ClusterDetailsWrapper();
            cdw.name = nan.name;
            cdw.sfCloud = nan.SF_Cloud__c;
            cdw.cloud = nan.Cloud__c;
            cdw.clusterObject = 'SMCDSS DLP Clusters';
            prodlist.add(cdw);
        }
        
        return prodlist;
    }

    public class ClusterDetailsWrapper{
        @AuraEnabled
        public String name;
        @AuraEnabled
        public String sfCloud;
        @AuraEnabled
        public String cloud;
        @AuraEnabled
        public String clusterObject;

        public ClusterDetailsWrapper(){
        }
    }
}