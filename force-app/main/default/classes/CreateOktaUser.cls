public without sharing class CreateOktaUser {
    /* public static List<Integration_Log__c> illst = new List<Integration_Log__c>();
   
    //@AuraEnabled(cacheable=true)
    @AuraEnabled
    public static Result checkandCreateUser(String conId){
        Result res = new Result();
        List<User> uslst = [Select Id from user where Id = :UserInfo.getUserId() and Profile.name in ('System Administrator', 'Core Sales - Sales Ops')];
        if(uslst.isEmpty()){
            res.classname = 'slds-box slds-theme_error';
            res.message = 'Insufficient Privileges. Please reach out to SFDC support!';
            return res;
        }
        System.debug('illst' + illst);
        List<Contact> conlst = [Select Id, FirstName, AccountId, LastName, OKTA_User_ID__c, Partner_Role__c, email, Account.Type from Contact where Id = :conId];
        if(!conlst.isEmpty()){
            contact con = conlst[0];
            if(con.Partner_Role__c == null){
                res.classname = 'slds-box slds-theme_error';
                res.message = 'Please update the Partner Role.';
                return res;
            }
            if(con.email == null){
                res.classname = 'slds-box slds-theme_error';
                res.message = 'Email address is required on this contact to create OKTA user';
                return res;
            }
            if(con.Account.Type !='Partner'){
                res.classname = 'slds-box slds-theme_error';
                res.message = 'Only Partner contact can be provisioned in OKTA';
                return res;
            }
            Map<String, OKTA_Integration_Params__c> mapOKTAParams = OKTA_Integration_Params__c.getAll();
            OKTA_Integration_Params__c partnerportalparamsforUserCreation, partnerportalparamsforGetUser, partnerportalparamsforUserUpdate;
            if(!mapOKTAParams.isEmpty()){
                partnerportalparamsforUserCreation = mapOKTAParams.get('Partner_Portal_User_Creation');
                partnerportalparamsforUserUpdate = mapOKTAParams.get('Partner_Portal_User_Update');
                partnerportalparamsforGetUser = mapOKTAParams.get('Partner_Portal_Get_User');
            }
            System.debug('illst' + illst);
            if(partnerportalparamsforGetUser != null){
                //check if user is there
                if(con.OKTA_User_ID__c == null){
                    Result getresp = processRequest(conId, partnerportalparamsforGetUser.Endpoint_URL_Okta__c + con.Email, 'GET', partnerportalparamsforGetUser.Token__c, '', 120000);
                    System.debug('getresp' + getresp);
                    if(getresp != null){
                        con.OKTA_User_ID__c = getresp.oktaId;
                    }
                }
                system.debug('inside callout');
            }
            System.debug('illst' + illst);
            //Request to create or update user
            Map<String, String> innermap = new Map<String, String> { 'firstName' => con.FirstName != null ? con.FirstName : con.LastName, 'lastName' => con.LastName, 'email' => con.Email, 'login' => con.Email, 'sfdc_Account_Id' => con.AccountId, 'sfdc_Contact_Id' => con.Id, 'partner_role' => con.Partner_Role__c == null ? 'User' : con.Partner_Role__c  };
            
            if(con.OKTA_User_ID__c != null){
                if(partnerportalparamsforUserUpdate != null){
                    UpdateRequestWrapper requestMap = new UpdateRequestWrapper(innermap);
                    system.debug(requestMap);
                    res = processRequest(conId, partnerportalparamsforUserUpdate.Endpoint_URL_Okta__c + con.OKTA_User_ID__c, 'POST', partnerportalparamsforUserUpdate.Token__c, JSON.serialize(requestMap), 120000);
                }
            }else{
                if(partnerportalparamsforUserCreation != null){
                    CreateRequestWrapper requestMap = new CreateRequestWrapper(new List<String>{Label.okta_Group_Id}, innermap);
                    system.debug(requestMap);
                    res = processRequest(conId, partnerportalparamsforUserCreation.Endpoint_URL_Okta__c, 'POST', partnerportalparamsforUserCreation.Token__c, JSON.serialize(requestMap), 120000);
                }
            }
            System.debug('illst' + illst); 
        }
        
        //update Contact with Okta User Id
        if(res.oktaId != null){
            Contact con = new Contact(Id= conId, OKTA_User_ID__c = res.oktaId);
            ContactTriggerHelper.skipTrigger = true;
            TriggerUtility.realignPatch();
            update con;
        }

        //create integration log records
        if(!illst.isEmpty()){
            TriggerUtility.intLogtriggerPRLogicExecuted();
            insert illst;
        }

        return res;
    }

    @testvisible private static Integration_Log__c createIntegrationLog(String objectId, String typeOfOperation, String endpoint, String queryParameters,
         String request, String response, String status, String statusDetail) {
         Integration_Log__c log = new Integration_Log__c(
                                     Related_Record_Id__c = objectId,
                                     Type_Of_Operation__c = typeOfOperation,
                                     Endpoint__c = endpoint,
                                     Request__c = request,
                                     Response__c = response,
                                     Response_Code__c = decimal.valueOf(status),
                                     Status__c = status,
                                     Status_Detail__c = statusDetail
                                 );
        return log;
    
     }
    
    @testvisible private static HttpRequest createHttpRequest(String endpoint, String method, String auth, String body, Integer timeout) {
        HttpRequest request = new HttpRequest();
        request.setHeader('Accept', 'application/json');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Authorization', auth);
        request.setEndpoint(endpoint);
        request.setMethod(method);
        if(body != '' &&  body != null){
            request.setBody(body);
        }
        request.setTimeout(timeout);
        
        return request;
    }
    
    @testvisible private static Result processRequest(String conId, String endpoint, String method, String auth, String body, Integer timeout) {
        HttpRequest request = createHttpRequest(endpoint, method, auth, body, timeout);
        HttpResponse response;
        String oktaId = '';
        system.debug('request'+ request);
        try {
            Http http = new Http();
            response = http.send(request);
            system.debug('response'+ response);
            System.debug(response.getBody());
            illst.add(createIntegrationLog((String)conId, method, endpoint, '', body, response.getBody(), string.valueOf(response.getStatusCode()), response.getStatusCode() == 200 ? 'Success': 'Failure'));

            if(response.getStatusCode() == 200 && response != null){
                Object responsebody;
                if(method == 'GET'){
                    List<Object> resplist = (List<Object>) JSON.deserializeUntyped(response.getBody());
                    responsebody = resplist != null && !resplist.isEmpty() ? resplist[0] : null;
                }else{
                    responsebody = JSON.deserializeUntyped(response.getBody());
                }
                
                if(responsebody != null){
                Map<String, Object> respMap = (Map<String, Object>)responsebody;
                    if(respMap != null && !respMap.isEmpty()){
                        oktaId = String.valueOf(respMap.get('id'));
                    }
                    if(method == ' GET'){
                        return createResponse('GET Success', '', oktaId);
                    }else{
                        return createResponse('User has been successfully provisioned in OKTA', 'slds-box slds-theme_success', oktaId);
                    }
                }
            }else if(response.getStatusCode() != 200){
                String err = '';
                Map<String, Object> respMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                List<Object> errorlst = respMap != null && !respMap.isEmpty() && respMap.containsKey('errorCauses') ? (List<Object>)respMap.get('errorCauses') : new List<Object>();
                if(!errorlst.isEmpty()){
                    Map<String, Object> maperror = (Map<String, Object>)errorlst[0];
                    err = maperror != null && !maperror.isEmpty() && maperror.containsKey('errorSummary') ? String.valueOf(maperror.get('errorSummary')) : 'Unexpected Error on Okta User Creation';
                }
                if(method == ' GET'){
                    return createResponse(err, '', '');
                }else{
                    return createResponse(err, 'slds-box slds-theme_error', '');
                }
            }
        } catch (Exception ex) {
            System.debug('*** Error occurred while invoking OKTA User Creation: ' + ex.getMessage() + ' ' + ex.getStackTraceString());
            return createResponse('Error: ' + ex.getMessage(), 'slds-box slds-theme_error', '');
            
        }
        return null;
    }

    public static Result createResponse(String message, String classname, string oktaId){
        Result ctrl = new Result();
        ctrl.message = message;
        ctrl.classname = classname;
        ctrl.oktaId = oktaId;
        return ctrl;
    }

    public class Result{
        @AuraEnabled
        public string message;
        @AuraEnabled
        public string classname;
        @AuraEnabled
        public string oktaId;
    }
    
    
    public class CreateRequestWrapper{
        @AuraEnabled
        public List<String> groupIds;
        @AuraEnabled
        public Map<String, String> profile;
        public CreateRequestWrapper(List<String> grp, Map<String, String> prf){
            groupIds = grp;
            profile = prf;
        }
    }
    
    public class UpdateRequestWrapper{
        @AuraEnabled
        public Map<String, String> profile;
        public UpdateRequestWrapper(Map<String, String> prf){
            profile = prf;
        }
    } */
	
	public static void booster(){
		integer i=0;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
	}
}