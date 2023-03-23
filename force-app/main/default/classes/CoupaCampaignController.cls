public class CoupaCampaignController {
    
    public integer Step     { get; set; }
    public Id recId         { get; set; }
    public Campaign camp     { get; set; }
    
    public Boolean showMessage   { get; set; }
    public Boolean showError   { get; set; }
    
    public String errors     { get; set; }
    
    
    public CoupaCampaignController(ApexPages.StandardController controller) {
        System.debug('--CoupaCampaignController--called-- ');
        showMessage = false;
        showError = false;
        camp =  (Campaign) controller.getRecord();
        recId = camp.Id;
        System.debug('---Campaign_Record---' + camp);
    }
    
    
    public PageReference initCopaProcess() {
        System.debug('--initCopaProcess--called-- ');
        Step = 1;
        return null;
    }
    
    
    public PageReference callCoupaIntegraion() {
        System.debug('--callCoupaIntegraion--called-- ');
        System.debug('--Campaign Id--' + recId);
        //sendCoupaIntegrationRequest();
        sendCoupaIntegrationRequestNew(); //Added for CR#3774
        return null;
    }
    
    public PageReference doCancel() {
        System.debug('--doCancel--called-- ');
        PageReference pageRef = new PageReference('/'+recId);
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    @testvisible  //CR#3774
    private  void sendCoupaIntegrationRequestNew() {
        System.debug('--sendCoupaIntegrationRequestNew--called-- ');
        System.debug('--camp--'+camp);
        System.debug('--recId--'+recId);
        
        if (camp == null || recId == null) {
            return;
        }
       
        try {
          
            
            camp.Coupa_Integration_Status__c = 'Initiated';
            camp.Coupa_Integration_Error__c = '';
            errors = '';
            showMessage = true;
            showError = false;
            update camp;
            
        }catch (Exception ex) {
            System.debug('*** Error occurred while saving Campaign: ' + ex.getMessage() + ' ' + ex.getStackTraceString());
            showError = true;
            showMessage = false;
            errors = ex.getMessage();
        }
    }
    
    
/*    @testvisible   
    private  void sendCoupaIntegrationRequest() {
        System.debug('--sendCoupaIntegrationRequest--called-- ');
        System.debug('--camp--'+camp);
        System.debug('--recId--'+recId);
        
        if (camp == null || recId == null) {
            return;
        }
        Map<String, String> requestMap = new Map<String, String> { 'Campaign ID' => recId };
            HttpRequest request = createHttpRequest('callout:Coupa_Campaign/V1/CreateCampaign/', 'POST', JSON.serialize(requestMap));
        HttpResponse response;
        try {
            Http http = new Http();
            if(!Test.isRunningTest()){
                response = http.send(request); 
            }else{
                response = new HttpResponse();
                response.setStatusCode(200);
                response.setBody('{"Campaign ID": "tsetRecordID", "Status": "Request Received"}');
            }
            
            System.debug('--sendCoupaIntegrationRequest--response--'+response.getBody());
        } catch (Exception ex) {
            System.debug('*** Error occurred while invoking SFDC to NS Integration Job: ' + ex.getMessage() + ' ' + ex.getStackTraceString());
            throw new SFDCNSIntegrationException(ex);
        }
        
        //Create Integratoion Log Entry
        createIntegrationLog((String)recId, '', 'callout:Coupa_Campaign/V1/CreateCampaign/', '',
                             JSON.serialize(requestMap), response.getBody(), string.valueOf(response.getStatusCode()),
                             response.getStatusCode() == 200 ? 'Success': 'Failure');
        
        try{
            if(response.getStatusCode() == 200 && response.getBody() != null){
                String resBody = response.getBody().replace('Campaign ID','Campaign_Id');
                CoupaCampaignController.CoupaResponse cr = (CoupaCampaignController.CoupaResponse) JSON.deserialize(resBody, CoupaCampaignController.CoupaResponse.class);
                System.debug('--cr--'+JSON.serializePretty(cr));
                if(cr.Campaign_id == String.valueOf(recId)  &&  cr.Status != null && cr.Status.contains('Request Received')){
                    camp.Coupa_Integration_Status__c = 'Initiated';
                    camp.Coupa_Integration_Error__c = '';
                    errors = '';
                    showMessage = true;
                    showError = false;
                }else{
                    camp.Coupa_Integration_Status__c = 'Not Started';
                    camp.Coupa_Integration_Error__c = 'Error occured while connecting Please try agian.';
                    errors = 'Error occured while connecting Please try agian.';
                    showMessage = false;
                    showError = true;
                }
            }else{
                camp.Coupa_Integration_Status__c = 'Failed';
                camp.Coupa_Integration_Error__c = response.getBody();
                showMessage = false;
                errors = 'Error occured while connecting Please try agian.';
                showError = true;
            }
            update camp;
            
        }catch (Exception ex) {
            System.debug('*** Error occurred while saving Campaign: ' + ex.getMessage() + ' ' + ex.getStackTraceString());
            showError = true;
            showMessage = false;
            errors = ex.getMessage();
        }
    }
    
    
    @testvisible
    private void createIntegrationLog(String objectId, String typeOfOperation, String endpoint, String queryParameters,
                                      String request, String response, String status, String statusDetail)
    {
        Integration_Log__c log = new Integration_Log__c(
            Related_Record_Id__c = objectId,
            Campaign__c = objectId,
            Type_Of_Operation__c = typeOfOperation,
            Endpoint__c = endpoint,
            Query_Parameters__c = queryParameters,
            Request__c = request,
            Response__c = response,
            Response_Code__c = decimal.valueOf(status),
            Status__c = status,
            Status_Detail__c = statusDetail
        );
        try {
            insert log;
        } catch (Exception ex) {
            System.debug('*** Error occurred while creating Integartion Log entry ' + JSON.serialize(log) + '; ' + ex.getMessage() + ' ' + ex.getStackTraceString());
        }
    }
    
    @testvisible 
    private static HttpRequest createHttpRequest(String endpoint, String method, String body) {
        return createHttpRequest(endpoint, method, body, 120000);
    }
    
    @testvisible 
    private static HttpRequest createHttpRequest(String endpoint, String method, String body, Integer timeout) {
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod(method);
        request.setBody(body);
        request.setTimeout(timeout);
        return request;
    }
    */
    public class SFDCNSIntegrationException extends Exception {}
    
    public class CoupaResponse{
        public string Campaign_Id;
        public string Status;
    }
    
}