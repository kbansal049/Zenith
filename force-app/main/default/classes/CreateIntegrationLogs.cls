public without sharing class CreateIntegrationLogs {
    public static void createLogs(String objectId, String typeOfOperation, String endpoint, String queryParameters,
        String request, String response, String status, String statusDetail, string excep, string callingClass, string username) {
        Integration_Log__c log = new Integration_Log__c(
                                    Related_Record_Id__c = objectId,
                                    Type_Of_Operation__c = typeOfOperation,
                                    Endpoint__c = endpoint,
                                    Query_Parameters__c = queryParameters,
                                    Request__c = request,
                                    Response__c = response,
                                    Response_Code__c = status != null && status != '' ? decimal.valueOf(status) : 200,
                                    Status__c = status != null && status != '' ? status : '200',
                                    Status_Detail__c = status != null && status != '' ? statusDetail : 'Success',
                                    Exception__c = excep,
                                    Invoked_from__c = callingClass,
                                    Invoked_By__c = username
                                );

        try {
            TriggerUtility.intLogtriggerPRLogicExecuted();
            insert log;
        } catch (Exception ex) {
            System.debug('*** Error occurred while creating Integartion Log entry ' + JSON.serialize(log) + '; ' + ex.getMessage() + ' ' + ex.getStackTraceString());
        }
    }
}