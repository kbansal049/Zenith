@isTest
public class SMCDSSClusterTriggerHandlerTest {
    @IsTest static void Method1(){ 
		 SMCDSS_DLP_Cluster__c sc = new SMCDSS_DLP_Cluster__c();
         sc.name='smba-fra-cluster';
         sc.cloud__c='ZSCALERTWO';
         sc.clusterId__c='2';
         sc.Cluster_External_Id__c='ZSCALERTWO-3';
         sc.type__c='SMBA';
         insert sc;
    	sc.cloud__c='ZSCALER';
        update sc;
    }
}