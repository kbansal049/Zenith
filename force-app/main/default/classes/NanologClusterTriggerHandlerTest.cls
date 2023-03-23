@isTest
public class NanologClusterTriggerHandlerTest {
    @IsTest static void Method1(){
        Nanolog_Cluster__c nc = new Nanolog_Cluster__c();
        nc.cloud__c = 'ZSCALER';
        nc.geoRegion__c = 'test';
        nc.type__c = 'nanolog';
        nc.name = 'zs2test1';
        nc.Cluster_External_Id__c = 'nc123';
        insert nc;
        nc.cloud__c='ZSCALERTWO';
        update nc;
    }
}