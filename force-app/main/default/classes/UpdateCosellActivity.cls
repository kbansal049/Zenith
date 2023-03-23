@RestResource(urlMapping='/UpdateCosellActivity/*')
global without sharing class UpdateCosellActivity {
    global static final String SUCCESS_MESSAGE = 'Cosell Activity is ';
    global static final String FAILURE_MESSAGE = 'Cosell is not ';
    @HttpPost
    global static void updatecosell() {
        RestRequest restReq = RestContext.request;
        RestResponse restRes = RestContext.response;
        CosellResponseModel response = new CosellResponseModel();
        System.debug(restReq.requestBody.toString());
        CosellPortalRequestModel request = (CosellPortalRequestModel)JSON.deserialize(restReq.requestBody.toString(), CosellPortalRequestModel.class);
        System.debug(request);
        String excep = '';
        if(request.csaId == null ||
            request.csaId == '' ||
            request.status == null ||
            request.status == '' || 
            request.contactName == null ||
            request.contactName == ''){
                response.status_message = 'Cosell Id, Status and Contact Id are mandatory. Please reach out to administrator.';
                response.status_code = '-1';
                restRes.responseBody = Blob.valueOf(JSON.serialize(response));
                restRes.statusCode = 400;
        }else{
            Cosell_Activities__c csa = new Cosell_Activities__c(
                                Id = request.csaId,
                                Status__c = request.status,
                                Status_Modified_By_Contact__c = request.contactName
                            );
            try {
                //TriggerUtility.SkipCosellStatusLMExecuted();
                update csa;
                //Set the response parameters
                response.status_message = SUCCESS_MESSAGE + (csa.Status__c == 'Accept' ? 'accepted.' : 'denied.');
                response.status_code = '1';
                restRes.responseBody = Blob.valueOf(JSON.serialize(response));
            } catch (Exception ex) {
                System.debug('Error: ' + ex.getMessage() + '\nStack trace: ' + ex.getStackTraceString());
                //Set the response parameters
                excep = ex.getMessage();
                response.status_message = FAILURE_MESSAGE  + (csa.Status__c == 'Accept' ? 'accepted.' : 'denied.' + '. Please contact zscaler representative.');
                response.status_code = '-1';
                restRes.responseBody = Blob.valueOf(JSON.serialize(response));
                restRes.statusCode = 400;
            }
        }
        
        CreateIntegrationLogs.createLogs(request.csaId, 'POST', '', '', restReq.requestBody.toString(), restRes.responseBody.toString(), string.valueOf(restRes.statusCode), restRes.statusCode == 200 ? 'Success': 'Failure',excep, 'UpdateCosellActivity', request.contactName);
    }

    /**
     * Wrapper class to send in the POST response body
     */
    global class CosellResponseModel {
        public String status_message;
        public String status_code;
    }

    global class CosellPortalRequestModel {

        public String csaId;
        public String status;
        public String contactName;
    
    }

}