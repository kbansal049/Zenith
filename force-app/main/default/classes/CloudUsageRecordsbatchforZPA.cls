public class CloudUsageRecordsbatchforZPA {

    @InvocableMethod(label='CreateCloudUsagerecordsforZPA')
    public static void createCloudUsageRecordsforZPA() {
        String objName='ZPA_Cloud_Usage_data__c';
        CreateCloudUsageRecordsBatch   btch= new CreateCloudUsageRecordsBatch  (objName);
        Integer CloudUsagebatchsizeforZPA=integer.valueof(ZscalerCustomSetting__c.getInstance('CloudUsagebatchsizeforZPA')!=null && ZscalerCustomSetting__c.getInstance('CloudUsagebatchsizeforZPA').Value__c!=null ? ZscalerCustomSetting__c.getInstance('CloudUsagebatchsizeforZPA').Value__c:'200');

        database.executebatch(btch,CloudUsagebatchsizeforZPA);
    }
    
}