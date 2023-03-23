/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 10-17-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public class ClusterDetailsControllerTest {
	@isTest
    private static void testGetALLClusterRecords(){
        
        
        //List<ClusterDetailsController.ClusterDetailsWrapper> prodlist = new List<ClusterDetailsController.ClusterDetailsWrapper>();
        
        Nanolog_Cluster__c nc = new Nanolog_Cluster__c();
        nc.name = 'smsm-pdx-cluster';
        nc.SF_Cloud__c = 'Zscalerone.net';
        nc.cloud__c = 'ZSCALERONE';
        nc.Cluster_External_Id__c = 'ZSCALERONE-2';
        insert nc;
        
        Sandbox_Cluster__c sc = new Sandbox_Cluster__c();
        sc.name = 'smba-pdx-cluster';
        sc.SF_Cloud__c = 'Zscalerone.net';
        sc.cloud__c = 'ZSCALERONE';
        sc.Cluster_External_Id__c = 'ZSCALERONE-4';
        insert sc;
        
        
        
        SMCDSS_DLP_Cluster__c smcdss = new SMCDSS_DLP_Cluster__c();
        smcdss.name = 'smsm-pdx-cluster';
        smcdss.SF_Cloud__c = 'Zscalerone.net';
        smcdss.cloud__c = 'ZSCALERONE';
        smcdss.Cluster_External_Id__c = 'ZSCALERONE-2';
        insert smcdss;
        
        
        ClusterDetailsController.getALLClusterRecords();

    }
}