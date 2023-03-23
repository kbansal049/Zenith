@istest
public class GenericApexBatchInvocationTest{
    @isTest
    static void testmethod1() {
        String BatchClassName='ABC';
        
        test.starttest();
        RestRequest request = new RestRequest();
        RestResponse res = new RestResponse();  
        request.requestUri =URL.getSalesforceBaseUrl().toExternalForm()+'/services/apexrest/GenericApexBatchInvocation';
        request.httpMethod = 'POST';
        request.addHeader('Content-Type', 'application/json'); 
        RestContext.request = request;
        RestContext.response= res;
        GenericApexBatchInvocation.doPost(BatchClassName);  
        
        BatchClassName='CreateCloudUsageRecordsBatch';
        GenericApexBatchInvocation.doPost(BatchClassName);
        
        BatchClassName='DeleteTechPartnerUsageRecordsBatch';
        GenericApexBatchInvocation.doPost(BatchClassName);
        
        BatchClassName='CreateTechPartnerRecordsBatch';
        GenericApexBatchInvocation.doPost(BatchClassName);

		BatchClassName='UpdateZscalerCloudIDRecordsBatch';
        GenericApexBatchInvocation.doPost(BatchClassName);
        
        test.stoptest();
        /* GenericApexBatchInvocation.doPost(BatchClassName);
        
        BatchClassName='ABC';
        GenericApexBatchInvocation.doPost(BatchClassName);
        
        */
    }
}