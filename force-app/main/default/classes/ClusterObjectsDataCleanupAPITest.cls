@isTest
public class ClusterObjectsDataCleanupAPITest {
    
    @TestSetup
    static void testData(){
		Nanolog_Cluster__c nc = new Nanolog_Cluster__c();
        nc.cloud__c = 'ZSCALER';
        nc.geoRegion__c = 'test';
        nc.type__c = 'nanolog';
        nc.name = 'zs2test1';
        nc.Cluster_External_Id__c = 'nc123';
        insert nc;
        
    	Sandbox_Cluster__c sc = new Sandbox_Cluster__c();
        sc.name='smba-fra-cluster';
        sc.cloud__c='ZSCALERTWO';
        sc.clusterId__c='2';
        sc.Cluster_External_Id__c='ZSCALERTWO-3';
        sc.type__c='SMBA';
        insert sc;
        
    	SMCDSS_DLP_Cluster__c sm = new SMCDSS_DLP_Cluster__c();
        sm.name='smba-fra-cluster';
        sm.cloud__c='ZSCALERTWO';
        sm.clusterId__c='2';
        sm.Cluster_External_Id__c='ZSCALERTWO-3';
        sm.type__c='SMBA';
        insert sm;
    }
  @isTest
	static void testmethod1(){
        
		RestRequest request = new RestRequest();
        request.requestUri ='/services/apexrest/ClusterObjectsDataCleanupAPI';
        request.httpMethod = 'POST';
		
        RestContext.request = request;
		ClusterObjectsDataCleanupAPI.doDelete();
		
		
	}
}