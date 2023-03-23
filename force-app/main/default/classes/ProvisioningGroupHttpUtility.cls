public class ProvisioningGroupHttpUtility {
    
    public static Id caseSupportRT = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Support').getRecordTypeId();
    
    public Static String testResponse = null;
    
    public Static String createPOCEndpoint = 'callout:DB_PGBroker';
     public Static String AuthPOCEndpoint = 'callout:DB_PGBrokerAuth';
    
    //public Static String createPOCEndpoint = 'http://zes-api.webdev.zscaler.com/request';  //Updated https://zes-api-qa.webdev.zscaler.com/request
    @future(callout=true)
    public Static void callPGBroker(String objectid, String body){
        System.debug('---callPGBroker---objectid--'+objectid);
        System.debug('---callPGBroker---body--'+body);
        
        HttpRequest reqnew = new HttpRequest();
        
        String credentials = System.label.Provisioning_Auth_Credential; 
        String username = credentials.substringBefore(',');
        String password = credentials.substringAfter(',');
        Http ht = new Http();
        reqnew.setMethod('POST');
        reqnew.setHeader('Content-Type', 'application/x-www-form-urlencoded');//
        reqnew.setHeader('Content-Length', '0');
        reqnew.setHeader('Authorization', 'Basic');
        reqnew.setHeader('accept','application/json');
        reqnew.setEndpoint(AuthPOCEndpoint);
        Blob headerValue = Blob.valueOf(username + ':' + password);
        String authorizationHeader = 'Basic ' +
            EncodingUtil.base64Encode(headerValue);
        reqnew.setHeader('Authorization', authorizationHeader);
        String bodynew = 'grant_type=client_credentials'+'&scope=SFDC';
        reqnew.setBody(bodynew);
        Http http = new Http();
        Map<String, Object> responsemap = new map<String,object>();
         HTTPResponse resauth = new HTTPResponse();
        try{
         resauth = http.send(reqnew);
        responsemap = (Map<String, Object>) JSON.deserializeUntyped(resauth.getBody());
        System.debug('responsemap--'+responsemap.get('access_token'));
        
        }catch(Exception ex){
                //Error Code
                resauth.setStatusCode(500);
                resauth.setBody('SFDC Exception:'+ex.getCause()+' Error Line:'+ex.getLineNumber() + ' Error Message:'+ex.getMessage());
                
                }
      
        //  return resp1.access_token;
        //reqnew.setBody(body); DB_PGBrokerAuth
     //====================================================================================================// 
        if(responsemap !=null) {     
               HttpRequest req = new HttpRequest();
                Http h = new Http();
                req.setEndpoint(createPOCEndpoint);
                req.setMethod('POST');
                req.setHeader('Content-Type', 'application/json');
                req.setHeader('accept','application/json');
                req.setHeader('Authorization','Bearer ' + responsemap.get('access_token'));
                req.setBody(body);
                req.setTimeout(20000);
                 HttpResponse res = new HttpResponse();
                
                try{
                if(!Test.isRunningTest()){
                res = h.send(req);
                    System.debug('res=='+res);
                    System.debug('==Response recieved '+res);
                }else{
                res.setStatusCode(200);
                res.setBody('');
                }
                if(testResponse != null){
                res.setBody(testResponse);
                }   
                }catch(Exception ex){
                //Error Code
                res.setStatusCode(500);
                res.setBody('SFDC Exception:'+ex.getCause()+' Error Line:'+ex.getLineNumber() + ' Error Message:'+ex.getMessage());
                
                }finally{
                
                System.debug('----finally--called----');
                
                //Call log request insertion logic
                createIntegrationLog(objectid, createPOCEndpoint, body, res.getBody(), res.getStatusCode(),  res.getStatusCode() == 202 ? 'Success': 'Failure');
                
                //Update PG Status to Provisioning In Progress
                updateProvisioningGroup(objectid, res);
                }
                }
           }
    
    @testvisible 
    private static void createIntegrationLog(String objectId,  String endpoint,
                                             String request, String response,
                                             Integer responseCode, String responseStatus) 
    {
        System.debug('Response=='+response);
        Id recTypeId = Schema.SObjectType.Provisioning_Integration_Log__c.getRecordTypeInfosByDeveloperName().get('SfdcToZscm').getRecordTypeId();
        
        Provisioning_Integration_Log__c log = new Provisioning_Integration_Log__c(
            Provisioning_Group__c = objectId,
            Endpoint__c = endpoint,
            Request__c = request,
            Response__c = response,
            RecordTypeId = recTypeId,
            Response_Code__c = responseCode,
            Response_Status__c = responseStatus,
            Requested_By__c = userinfo.getUserId()
        );
        if(responseCode==202){
            ProvisioningGroupHttpUtility.cls_responseData_success cr = (ProvisioningGroupHttpUtility.cls_responseData_success) JSON.deserialize(response, ProvisioningGroupHttpUtility.cls_responseData_success.class);
            log.Broker_Request_ID__c=cr.id;
        }
        try {
            insert log;
        } catch (Exception ex) {
            System.debug('*** Error occurred while creating Integartion Log entry ' + JSON.serialize(log) + '; ' + ex.getMessage() + ' ' + ex.getStackTraceString());
        }
    }
    
    @testVisible
    private Static void updateProvisioningGroup(String pgID, HttpResponse response ){
        System.debug('---updateProvisioningGroup--called---');
        System.debug('---updateProvisioningGroup--pgID---'+pgID);
        Provisioning_Group__c pg = [Select id,Integration_Status__c,Status__c,Provisioning_Type__c from Provisioning_Group__c where id=:pgID limit 1];
        if(response.getStatusCode() == 202 ){
            pg.Integration_Status__c ='Requested';
            pg.Manually_Processed__c = false;
            pg.Provisioning_Type__c = 'Auto';
        }else{
            try{
                ProvisioningGroupHttpUtility.cls_responseData_success cr = (ProvisioningGroupHttpUtility.cls_responseData_success) JSON.deserialize(response.getBody(), ProvisioningGroupHttpUtility.cls_responseData_success.class);
                pg.Failure_Reason__c = cr.message;
            }catch(Exception ex){
                pg.Failure_Reason__c = response.getBody();
            }
            pg.Integration_Status__c ='Failed';
            pg.Provisioning_Type__c = 'Manual';
            pg.Manually_Processed__c = true;
        }
        pg.Status__c ='Provisioning In Progress';
        
        try{
            update pg;
        }catch(Exception ex){
            ProvisioningErrorHandler.exceptionHandler('ProvisioningGroupHttpUtility','updateProvisioningGroup',ex);
        }
    }
    
    
    public class cls_responseData_success{
        public String id;
        public String message;
    }
}