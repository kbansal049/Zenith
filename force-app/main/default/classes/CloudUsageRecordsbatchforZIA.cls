public class CloudUsageRecordsbatchforZIA {

    @InvocableMethod(label='CreateCloudUsagerecordsforZIA')
    public static void createCloudUsageRecordsforZIA() {
        String objName='ZIA_Cloud_Usage_data__c';
        Integer CloudUsagebatchsizeforZIA=integer.valueof(ZscalerCustomSetting__c.getInstance('CloudUsagebatchsizeforZIA')!=null && ZscalerCustomSetting__c.getInstance('CloudUsagebatchsizeforZIA').Value__c!=null ? ZscalerCustomSetting__c.getInstance('CloudUsagebatchsizeforZIA').Value__c:'200');
        CreateCloudUsageRecordsBatch   btch= new CreateCloudUsageRecordsBatch(objName);
        database.executebatch(btch,CloudUsagebatchsizeforZIA);
    }
    
}