/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 06-07-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@RestResource(urlMapping='/ZSCMTOSFDC/*')
global class BROKERTOSFDC{
    
    global static Boolean avoidtriggers = false;
    
    global static Id recTypeId = Schema.SObjectType.Provisioning_Integration_Log__c.getRecordTypeInfosByDeveloperName().get('ZscmToSfdc').getRecordTypeId();
    
    @HttpPost
    global static DoPostResponse doPost(){
        
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        String actualPayloadBrokerToSFDC;
        if(req.requestBody !=null)
         actualPayloadBrokerToSFDC = req.requestBody.toString();
        System.debug('actualPayloadBrokerToSFDC->' + actualPayloadBrokerToSFDC);
        
        DoPostResponse response = null;
        
        Boolean hasError = false;
        boolean isAccountPresent= true;
        
        Provisioning_Group__c pg;
        ProvisioningBrokerWrapper pbw;
        String failureReason;
        String subscriptionId;  //Subscription_Id__c = custInfo.subscriptionId
        String subscriptionName; 
        Account ac;

        if(actualPayloadBrokerToSFDC != null && actualPayloadBrokerToSFDC !='null'){
        //For testing purpuses have added the payloadSample locally in the class.
        try{
             System.debug('Inside if =='+actualPayloadBrokerToSFDC);
       
            //Step1. Parse the Response
            pbw = ProvisioningBrokerWrapper.parse(actualPayloadBrokerToSFDC);
            
            //Step2. Validate UInput Records.
            Account acc;
            if(pbw.prGroupId != null && !String.isBlank(pbw.prGroupId)){
                pg = [select id,name,Status__c ,Account__c,Product_Line__c from Provisioning_Group__c where  Id= :pbw.prGroupId limit 1];
            }

            if(pg == null ||  pbw.prGroupId == null || pbw.prGroupId == ''){
                hasError = true;
                response = new DoPostResponse('Failure', 'Could not recognise PG Group ID.'); 
                failureReason = 'Could not recognise PG Group ID.';
                res.responseBody = BLOB.valueOf(JSON.serializePretty(response));
                res.statusCode = 202;
            }
           
            System.debug('String.isBlank(pbw.sfdcAccountId)===='+String.isBlank(pbw.sfdcAccountId));
            if(!String.isBlank(pbw.sfdcAccountId)){
                acc = [select id,name from Account where  Id = :pbw.sfdcAccountId limit 1];
            }

            if(acc == null || pbw.sfdcAccountId == null ||  pbw.sfdcAccountId == '' || String.isBlank(pbw.sfdcAccountId)){
                isAccountPresent = false;
                hasError = true;
                response = new DoPostResponse('Failure', 'Could not recognise SFDC Account ID.');
                failureReason = 'Could not recognise SFDC Account ID.';
                res.responseBody = BLOB.valueOf(JSON.serializePretty(response));
                res.statusCode = 202;
            }
            
            if(!String.isBlank(pbw.sfdcAccountId) && acc != null && pbw.sfdcAccountId !=null && pbw.sfdcAccountId !='' &&
                pg != null &&  pbw.prGroupId !=null && pbw.prGroupId != ''){
                if(pg.Account__c != pbw.sfdcAccountId){
                    hasError = true;
                    response = new DoPostResponse('Failure', 'AccountId is not associated with this PG'); 
                    failureReason = 'AccountId is not associated with this PG.';
                    res.responseBody = BLOB.valueOf(JSON.serializePretty(response));
                    res.statusCode = 202;
                }
            }
            
            if(pbw.requestID == null){
                hasError = true;
                response = new DoPostResponse('Failure', 'ReuquestID can not by empty.');
                failureReason = 'ReuquestID can not by empty.';
                res.responseBody = BLOB.valueOf(JSON.serializePretty(response));
                res.statusCode = 202;
            }
            
            if(pbw.customerInfo != null){
                Boolean isError = false;
                Boolean isCustomerIdUpdated = false ;
                
                for(ProvisioningBrokerWrapper.cls_customerInfo custInfo : pbw.customerInfo){
                    //Update Susbcription Id and Name
                    if(String.isNotBlank(custInfo.subscriptionId)){
                    	subscriptionId =custInfo.subscriptionId;
                    }

                    if(String.isNotBlank(custInfo.subscriptionName)){
                    	 subscriptionName = custInfo.subscriptionName;
                    }
                    
                    if(custInfo.requestStatus.equalsignorecase('Failure') || custInfo.requestStatus.equalsignorecase('Failed')){
                        isError = true;
                        if(String.isBlank(failureReason)){
                            failureReason = custInfo.failureReason;
                        }else{
                            failureReason +=  custInfo.failureReason+'\n';
                        }
                        System.debug('custInfo.subscriptionId=='+custInfo.subscriptionId);
                        if(custInfo.subscriptionId !=null && custInfo.subscriptionId !=''){
                            failureReason = failureReason+'\n'+'Subscription ID is '+custInfo.subscriptionId+'\n';
                        }

                        //update customerId if we customer got created at zscm betaCustomerId
                        if(pg != null && pg.Product_Line__c != null && isAccountPresent && (custInfo.betaCustomerId != null && custInfo.betaCustomerId != '')
                           ||(custInfo.productionCustomerId != null && custInfo.productionCustomerId != '') ){
                            if(pg.Product_Line__c == 'ZIA' || pg.Product_Line__c == 'ZDX'){
                                ac = new Account( id = pbw.sfdcAccountId);
                                 if(custInfo.betaCustomerId !=null && custInfo.betaCustomerId !='')
                               		 ac.ZIA_Customer_ID__c = custInfo.betaCustomerId; 
								else if(custInfo.productionCustomerId  !=null && custInfo.productionCustomerId !='')
									 ac.ZPA_Customer_ID__c = custInfo.productionCustomerId;
                                isCustomerIdUpdated = true;
                            }
                         }
                    }
                }
                if(isError){
                    if(isCustomerIdUpdated){
                        TriggerHandler.bypass('AccountTriggerHandler');
                        update ac;
                    }
                    
                    hasError = true;
                    System.debug('failureReason=='+failureReason);
                    response = new DoPostResponse('Failure', 'Failure Status received'); 
                   	res.responseBody = BLOB.valueOf(JSON.serializePretty(response));
                    res.statusCode = 202; 
                    res.responseBody = BLOB.valueOf(JSON.serializePretty(response));
                    res.statusCode = 202; 
                }
                
            } 
            //Provisioning_Group__c pgReuestID = [select id,name,Status__c from Provisioning_Group__c where  Id= :pbw.prGroupId and Broker_Unique_Id__c =:pbw.requestID limit 1 ];
            //if(pgReuestID == null){
            //    hasError = true;
            //    response = new DoPostResponse('Failure', 'Could not found reuquestID.');                
            //    res.responseBody = BLOB.valueOf(JSON.serializePretty(response));
            //    res.statusCode = 400;
            //}
            
            if(!hasError){
                System.debug('No error till here');
                response = new DoPostResponse('Success', 'Processes Succesfully.');
                res.responseBody = BLOB.valueOf(JSON.serializePretty(response));
                res.statusCode = 202;
            }
        }catch(Exception e){
            hasError = true;
            System.debug('--doPost---Exception occured---'+ e.getMessage());
            System.debug('--doPost---Exception occured---'+ e.getStackTraceString());
            System.debug('=='+e.getMessage().contains('List has no rows for assignment to SObject'));
            if(e.getMessage().contains('List has no rows for assignment to SObject')){
                response = new DoPostResponse('Failure', 'Account Id or PG group Id doesn not exist');
            }else{
                response = new DoPostResponse('Failure', e.getMessage() + ' - ' + e.getLineNumber());
            }
            res.statusCode = 202;
            res.responseBody = BLOB.valueOf(JSON.serializePretty(response));
        }finally{
            //Step 3 : Insert Response SFDC is Sending Back to Broker.
            //System.debug(pg.Id+'====='+pg);
            Provisioning_Integration_Log__c logRecord = null;
            if(pbw != null && String.isNotBlank(pbw.requestID)){
                logRecord = generateIntegartionLogRequestResponse(req, response, hasError, pg, pbw.requestID, failureReason, subscriptionName, subscriptionId);
            }else{
                logRecord = generateIntegartionLogRequestResponse(req, response, hasError, pg, null, failureReason, subscriptionName, subscriptionId);
            }
            
            //Step 4 : Mark PG Status as Provitioning In Progress
            /*if(pg != null && pg.Id != null){
                pg.Status__c = 'Provisioning In Progress';
                update pg;
            }*/
            
            //Step 5 : Set logID for RepsonseTracking Purpose.
            response.logId = logRecord.id;
        }
        }
        else {
            System.debug('Inside else 193');
             TriggerHandler.bypass('ProvisioningIntegrationTriggerHandler');
       
              hasError = true;
             response = new DoPostResponse('Failure', 'Null Body recieved from broker !!');
            res.statusCode = 202;
            res.responseBody = BLOB.valueOf(JSON.serializePretty(response));
        
        } 
        return  response;       
    }
    
    @testVisible
    private Static Provisioning_Integration_Log__c generateIntegartionLogRequestResponse(RestRequest req, DoPostResponse response, Boolean hasError, Provisioning_Group__c pg,
                                                                                         String requestID, String failureReason, String subscriptionName, String subscriptionId){
        
        System.debug('---generateIntegartionLogRequestResponse called---');
                                                                                                                                                                                 
        Provisioning_Integration_Log__c logNew1 = new Provisioning_Integration_Log__c();
      	try{
        logNew1.Request__c = req.requestBody.toString();
        logNew1.Endpoint__c = URL.getSalesforceBaseUrl().toExternalForm() + req.resourcePath;
        logNew1.Response__c =  JSON.serializePretty(response);
        logNew1.Request_Status__c =  hasError ? 'Failure' : 'Success';
        logNew1.Status__c = logNew1.Request_Status__c == 'Success'? 'Received' : 'Failed';
        lognew1.Failure_Reason__c = hasError ? failureReason : '';
        logNew1.RecordTypeId = recTypeId;
       
       //Update PG as manual to create in case of failure
        if(pg != null && pg.Id != null){
            lognew1.Provisioning_Group__c= pg.Id;
            if(logNew1.Request_Status__c == 'Failure'){
                Provisioning_Group__c pgnew = new Provisioning_Group__c();
                pgnew.Provisioning_Type__c='Manual';
                pgnew.Id= pg.Id;
                pgnew.Subscription_Id__c = subscriptionId;
                pgnew.Subscription_Name__c = subscriptionName;
                pgnew.Failure_Reason__c =  failureReason;
                pgnew.Status__c ='Provisioning In Progress';
               
                update pgnew;
              }
        }

        if(String.isNotBlank(requestID)){
            lognew1.Broker_Request_ID__c = requestID;
        }
        logNew1.Requested_By__c = userinfo.getUserId();
        insert logNew1;
        
        //By Pass Triggers
        TriggerHandler.bypass('ProvisioningIntegrationTriggerHandler');
        response.logId = logNew1.id;
        logNew1.Response__c = JSON.serializePretty(response);
        update logNew1;
           System.debug('-----generateIntegartionLogRequestResponse called-----logNew1--'+logNew1);
        }catch(Exception ex){
                ProvisioningErrorHandler.exceptionHandler('BROKERTOSFDC','generateIntegartionLogRequestResponse',ex);
            }
        return logNew1;
    }
    
    //Response Wrapper For Broker.
    global class DoPostResponse {
        global String status;
        global String message;
        global String logId;
        global DoPostResponse(String status, String message){
            this.status = status;
            this.message = message;
        }
    }
    
    //Sample payload USed for Testing
    public static String payloadBrokerToSFDC = '{'+
        '    "requestID":"3423423",' +
        '    "prGroupId":"A023432423423",'+
        '    "sfdcAccountId": "A3345345",'+
        '    "customerInfo":['+
        '        {'+
        '            "productionCustomerId":"23424324",'+
        '            "cloudName":"ZIA",'+
        '            "tenantID":"zscaler.net-234523",'+
        '            "tenantName":"CustomerName-PRGroup",'+
        '            "domain" : "ertrt.com",'+
        '            "additionalDomains":"werwe.com,were.com",'+
        '            "tenantStatus":"Trial",'+
        '            "requestStatus":"success",'+
        '            "failureReason":""'+
        '            '+
        '        },'+
        '        {'+
        '            "productionCustomerId":"ggg",'+
        '            "cloud":"ZPA",'+
        '            "tenantID":"9334534534543534534543",'+
        '            "tenantName":"CustomerName-PRGroup",'+
        '            "domain" : "ertrt.com",'+
        '            "additionalDomains":"",'+
        '            "tenantStatus":"Subscription",'+
        '            "requestStatus":"success",'+
        '            "failureReason":""'+
        '        },'+
        '        {'+
        '            "productionCustomerId":"23424324",'+
        '            "cloudName":"ZDX",'+
        '            "tenantID":"zdxcloud.net-234523",'+
        '            "tenantName":"CustomerName-PRGroup",'+
        '            "domain" : "ertrt.com",'+
        '            "additionalDomains":"",'+
        '            "tenantStatus":"Trial",'+
        '            "requestStatus":"success",'+
        '            "failureReason":""'+
        '        }'+
        '    ]'+
        '}';
}