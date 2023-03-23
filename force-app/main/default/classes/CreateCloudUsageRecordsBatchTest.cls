@istest
public class CreateCloudUsageRecordsBatchTest{
static testmethod void testmethod1() {
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        
        List<Zscaler_Cloud_ID__c> zscalercloudlist= new List<Zscaler_Cloud_ID__c> ();
        Zscaler_Cloud_ID__c zsCloud = new Zscaler_Cloud_ID__c();
        zsCloud.Name = 'Test.Data';
        zsCloud.Status__c = 'Test';
        zsCloud.Account__c = acc.Id;
        zsCloud.Org_Name__c = 'Test';
        zsCloud.Cloud_Type__c = 'ZIA';
        zscalercloudlist.add(zsCloud);
        
        /* Zscaler_Cloud_ID__c zsCloud2 = new Zscaler_Cloud_ID__c();
        zsCloud2.Name = 'Test.ZPAData';
        zsCloud2.Status__c = 'Test';
        zsCloud2.Account__c = acc.Id;
        zsCloud2.Org_Name__c = 'TestZPA';
        zsCloud2.Cloud_Type__c = 'ZPA';
        zscalercloudlist.add(zsCloud2); */
        
        insert zscalercloudlist;
        
        ZIA_Cloud_Usage_data__c ziacu1= new ZIA_Cloud_Usage_data__c();
        ziacu1.Account_ID__c=(String)acc.id;
        ziacu1.Externalid__c='12345';
        ziacu1.Zscaler_Cloud_ID__c=(String)zsCloud.id;      
        ziacu1.Auth_location_count__c=1234;     
        ziacu1.Usage_Date__c=system.today();        
        insert ziacu1;
        
        String objName='ZIA_Cloud_Usage_data__c';
        //CreateCloudUsageRecordsBatch  btch= new CreateCloudUsageRecordsBatch (objName);
        //database.executebatch(btch,5);
        CloudUsageRecordsbatchforZIA.createCloudUsageRecordsforZIA();
        
        ZPA_Cloud_Usage_data__c zpacu1= new ZPA_Cloud_Usage_data__c();
        zpacu1.Account__c=(String)acc.id;
        zpacu1.Zscaler_Cloud_ID__c=(String)zsCloud.id;
        zpacu1.Cloud_Usage_External_Id__c='123';
        zpacu1.ActiveConnectors__c=1235;
        zpacu1.Total_Bandwidth__c='test1235';
        zpacu1.ZPA_Start_Date__c=system.today()-7;
        zpacu1.ZPA_End_Date__c=system.today()+2;
        insert zpacu1;
        
        String objName2='ZPA_Cloud_Usage_data__c';
        //CreateCloudUsageRecordsBatch  btch2= new CreateCloudUsageRecordsBatch (objName2);
        //database.executebatch(btch,5);
        CloudUsageRecordsbatchforZPA.createCloudUsageRecordsforZPA();
        
        CloudUsageDatafixbatch cs= new CloudUsageDatafixbatch();
        database.executebatch(cs);

    }
}