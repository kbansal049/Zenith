@isTest
public class cloudUsageTriggerHandlerTest {
	 public static testMethod void cloudUsageTriggerTest(){
        
        
        test.startTest(); 
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        
        Id ZscalerCloudRecordTypeId = Schema.SObjectType.Zscaler_Cloud_ID__C.getRecordTypeInfosByDeveloperName().get('ZPA_Cloud_ID').getRecordTypeId();
        
         Zscaler_Cloud_ID__C zc = new Zscaler_Cloud_ID__C(Account__c=acc.id,Name='test cloud id',Cloud_Type__c='ZPA',RecordTypeID=ZscalerCloudRecordTypeId);
        insert zc; 
        
        Cloud_Usage__c cu = new Cloud_Usage__c(Zscaler_Cloud_ID__c = zc.id,Name = 'test cloud usage',Cloud_Usage_Type__c = 'ZPA');
        insert cu;
         
        cu.ZPA_last_14_days__c = 450;
        update cu; 
        
        test.stopTest();
    }
}