public class WorkatoAPIUtility {
    
    private Static String workatoToken = 'callout:Workato_Token';
    private Static String retrivePartnerDetails = 'callout:Workato_API_PartnerDetails';

    
    //Usage: To retrive Partner and Customer Details
    //Retrun: Access_Token

    @testvisible
    private Static Integer test_TokenStatusCode = 200;
    @testvisible
    private Static String test_TokenResponse = '{ "access_token": "TEST_CODE" }';
    
      
    @testvisible
    private Static HTTPResponse retriveWorkatoToken(){
        HTTPResponse resauth = new HTTPResponse();
        
        HttpRequest reqnew = new HttpRequest();
        
        String clientSecret = System.label.Workato_Client_Secret;
        String ClientID = System.label.Workato_Client_Id;
        
        reqnew.setMethod('POST');
        reqnew.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        reqnew.setHeader('accept','application/json');
        reqnew.setEndpoint(workatoToken);
         
        String bodynew = 'grant_type=client_credentials'+'&client_id='+ClientID+'&client_secret='+clientSecret;
        reqnew.setBody(bodynew);
        
        Http http = new Http();
        try{
            if(!Test.isRunningTest()){
                resauth = http.send(reqnew);
            }else{
                resauth.setStatusCode(test_TokenStatusCode);
                resauth.setBody(test_TokenResponse);
            }
            System.debug('---retriveWorkatoToken--response---recieved--'+resauth);
            System.debug('---retriveWorkatoToken--response---recieved--'+resauth.getBody());
        }catch(Exception ex){
            //Error Code
            resauth.setStatusCode(500);
            resauth.setBody('SFDC Exception:'+ex.getCause()+' Error Line:'+ex.getLineNumber() + ' Error Message:'+ex.getMessage());
        }
        return resauth;
    }
    
    
    
    
    //Usage: To retrive Partner and Customer Details
    @testvisible
    private Static Integer testStatusCode = 200;
    @testvisible
    private Static String testResponse = '[{"id" : 21026, "name" : "testCustomer", "entityId" : "123", "type" : "customer"},{"id": 4883, "name": "testCustomer1", "entityId" : "123", "type" : "customer"}]';
    
    
    public Static  HTTPResponse retrivePartnerAndCustomerDetails(String body){
        HTTPResponse resAPI = new HTTPResponse();
        
        try{
            
            HTTPResponse  authTokenRes = retriveWorkatoToken();
            
            //Token retrival is Failed
            if(authTokenRes.getStatusCode() != 200){
                resAPI.setStatusCode(authTokenRes.getStatusCode());
                resAPI.setBody(authTokenRes.getBody());
                return resAPI;
            }
                
            Map<String, Object> responsemap = (Map<String, Object>) JSON.deserializeUntyped(authTokenRes.getBody());
            
            HttpRequest req = new HttpRequest();
            Http h = new Http();
            req.setEndpoint(retrivePartnerDetails);
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('accept','application/json');
            req.setHeader('Authorization','Bearer ' + responsemap.get('access_token'));
            req.setBody(body);
            
            resAPI = new HttpResponse();
            
            if(!Test.isRunningTest()){
                resAPI = h.send(req);
            }else{
                resAPI.setStatusCode(testStatusCode);
                resAPI.setBody(testResponse);
            }
            System.debug('---retrivePartnerAndCustomerDetails--response---recieved--'+resAPI);
            System.debug('---retrivePartnerAndCustomerDetails--response---recieved--'+resAPI.getBody());
            
        }catch(Exception ex){
            resAPI.setStatusCode(500);
            resAPI.setBody('SFDC Exception:'+ex.getCause()+' Error Line:'+ex.getLineNumber() + ' Error Message:'+ex.getMessage());
        }
        
        return resAPI;
    }
}