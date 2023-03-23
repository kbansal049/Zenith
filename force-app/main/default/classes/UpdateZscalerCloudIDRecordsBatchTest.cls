@istest
public class UpdateZscalerCloudIDRecordsBatchTest{
     @TestSetup
    private static void createTestData(){
        RecordType recType = [select Id,name from RecordType where name='End User - Customer DS Reviewed' and sObjectType='Account'];
        
        Account cust = new Account();
        cust.Name = 'Customer1';
        cust.RecordTypeId = recType.Id;
        cust.Type = 'Customer';
        cust.DS_Review_Status__c = 'Complete';
        cust.Contract_Review__c = 'Review Complete';
        
        insert cust;
        
        Zscaler_Cloud_ID__c cloudId = new Zscaler_Cloud_ID__c();
        cloudId.Name = 'zdavav';
        cloudId.Org_Name__c = '';
        cloudId.Status__c = 'Production';
        cloudId.Account__c = cust.Id;
        
        insert cloudId;
    }
    
    @isTest 
    static void CreateTechPartnerRecordsBatchTest1(){
        ZDX_Cloud_Usage__c zdxCU = new ZDX_Cloud_Usage__c();
        zdxCU.Org_Name__c = 'Test Customer Org';
        zdxCU.External_ID__c = 'Zscloud.net-'+ Math.mod(Math.abs(Crypto.getRandomInteger()),4);
        zdxCU.Zscaler_Cloud_ID__c = [Select id from Zscaler_Cloud_ID__c where Account__c != null limit 1].id;
        zdxCU.cloud_id__c = 'zdavav';
        
        test.startTest();
        insert zdxCU;
        
        UpdateZscalerCloudIDRecordsBatch btch= new UpdateZscalerCloudIDRecordsBatch();
        database.executebatch(btch);
        
        Test.stopTest();
    }
}