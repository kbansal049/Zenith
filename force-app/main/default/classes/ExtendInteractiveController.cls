/*****************************************************************************************
Name: ExtendInteractiveController
Copyright © Zscaler
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
VERSION        AUTHOR                  DATE              DETAIL              
1.0            Viral                  	NA               Initial Development
2.0            Mahesh T		       	  07/07/2022         CR#5036 Fix
******************************************************************************************/
public class ExtendInteractiveController {
    
    private final Product_Demo_Instance_Request__c pDemo;
    
    public ExtendInteractiveController(ApexPages.StandardController stdController) {
        List<String> flds = new List<String>{'Lead__c','Account__c','Primary_Eval_Contact__c'};
            if(!Test.isRunningTest())
            stdController.addFields(flds);
        this.pDemo = (Product_Demo_Instance_Request__c)stdController.getRecord();
    }
    
    public PageReference doRedirectProductDemoInteractiveRequest(){
        System.debug('--doRedirectProductDemoInteractiveRequest--called-- ');
        PageReference pageRef = null;
        System.debug('--pDemo--'+pDemo);
        if(pDemo != null && pDemo.Id != null){
            pageRef = new PageReference('/'+pDemo.Id);
            pageRef.setRedirect(true);
        }
        return pageRef;
    }
    
    @future(callout=true)
    public static void ExtendInteractiveCustom(set<Id> updatedId){
        boolean isSuccess;
        List<Product_Demo_Instance_Request__c> prLst = [select id, name,Integration_Status__c,RecordType.Name,Record_Type_Name__c from Product_Demo_Instance_Request__c where id in :updatedId];
        for(Product_Demo_Instance_Request__c ProvReq : prLst){
            try{
                isSuccess = callOutZPAImpartner(ProvReq, 'Request_Extension');
                if(isSuccess){
                    ProvReq.FailedReason__c = '';
                }else{
                    ProvReq.FailedReason__c='Callout Request Failed for Extension';
                }
            }catch(Exception ex){
                system.debug('Exception :'+ex.getMessage());
            }
        }
        update prLst;
    }
    
    public static void updateContactforSafemarch(set<Id> contactId){
        List<Contact> conLst = [select id,Safemarch_Provisioned__c from contact where Id in :contactId];
            for(Contact contactRec : conLst){
                contactRec.Safemarch_Provisioned__c = True;
            }
        TriggerUtility.SkipContactTriggerExecuted();
        update conLst;
    }
    
    
    @AuraEnabled
    public static Map<string,string> ExtendInteractive(string reqId){
        Map<string,string> ResultMap = new Map<string,string>();
        boolean isSuccess;
        if(reqId != null){
            Product_Demo_Instance_Request__c ProvReq = [select Id, Name, Provisioning_Status__c, Is_Interactive_Extended__c,
                                                        RecordTypeId,RecordType.Name,Record_Type_Name__c, Provisioning_End_Date__c
                                                        from Product_Demo_Instance_Request__c where Id =:reqId limit 1];
            
            if(ProvReq.Provisioning_Status__c == 'Decommissioned' || ProvReq.Is_Interactive_Extended__c == true){
                ResultMap.put('Status','Error');
                ResultMap.put('Message','Either this request is Decommisioned or already extended once.');
            }else {
                try{
                    ProvReq.Provisioning_Status__c = 'Request Extension';
                    if(ProvReq.Record_Type_Name__c == 'ZB2B Interactive'){
                       isSuccess = callOutZB2BInteractive(ProvReq, 'Request_Extension'); 
                    }

                    else if(ProvReq.Record_Type_Name__c == 'ZPA Interactive for Partners'){

                       isSuccess = callOutZPAImpartner(ProvReq, 'Request_Extension');
                    }
                    if(isSuccess){
                        ProvReq.FailedReason__c = '';
                        //ProvReq.Is_Interactive_Extended__c = true;
                        //ProvReq.Provisioning_Extended_Date__c = Date.Today();
                        //ProvReq.Provisioning_End_Date__c = system.today().adddays(7);
                        //ProvReq.Provisioning_Decommissioned_Date__c = null;
                    }
                    update ProvReq;
                    ResultMap.put('Status','Success');
                    ResultMap.put('Message','Updated Successfully');
                }
                catch(Exception ex){ResultMap.put('Status','Error');ResultMap.put('Message',ex.getMessage());}
            }
            return ResultMap;
        }
        return null;
    }
    
    
    @AuraEnabled
    public static Map<string,string> DisableInteractive(string reqId){
        Map<string,string> ResultMap = new Map<string,string>();
        boolean isSuccess;
        if(reqId != null){
            Product_Demo_Instance_Request__c ProvReq = [select Id,Name, Provisioning_Status__c,
                                                        RecordTypeId, RecordType.Name,Record_Type_Name__c
                                                        from Product_Demo_Instance_Request__c where Id =:reqId limit 1];
            
            if(ProvReq.Provisioning_Status__c == 'Decommissioned' || ProvReq.Provisioning_Status__c == 'Disabled'){
                ResultMap.put('Status','Error');
                ResultMap.put('Message','Either this request is Decommisioned or already Disabled.');
            } else {
                try{
                    if(ProvReq.Record_Type_Name__c == 'ZB2B Interactive'){
                       isSuccess = callOutZB2BInteractive(ProvReq, 'Request_Disable'); 
                    }

                    else if(ProvReq.Record_Type_Name__c == 'ZPA Interactive for Partners'){

                       isSuccess = callOutZPAImpartner(ProvReq, 'Request_Disable');
                    }
                    if(isSuccess){
                        ProvReq.Provisioning_Status__c = 'Request Disable';
                        ProvReq.FailedReason__c = '';
                        //ProvReq.Provisioning_Disable_Date__c = system.today();
                    }
                    update ProvReq;
                    ResultMap.put('Status','Success');
                    ResultMap.put('Message','Updated Successfully');
                }
                catch(Exception ex){ ResultMap.put('Status','Error');ResultMap.put('Message',ex.getMessage());}
            }
            return ResultMap;
        }
        return null;
    }
    
    
    @AuraEnabled
    public static Map<string,string> reEnableInteractive(string reqId){
        Map<string,string> ResultMap = new Map<string,string>();
        boolean isSuccess;
        if(reqId != null){
            Product_Demo_Instance_Request__c ProvReq = [select Id,Name, Provisioning_Status__c,
                                                        RecordTypeId, RecordType.Name,Record_Type_Name__c
                                                        from Product_Demo_Instance_Request__c where Id =:reqId limit 1];
            system.debug('Status$$'+ProvReq.Provisioning_Status__c+ ' and '+ProvReq.Record_Type_Name__c);
            if(ProvReq.Provisioning_Status__c == 'Decommissioned' || ProvReq.Provisioning_Status__c != 'Disabled'){
                ResultMap.put('Status','Error');
                ResultMap.put('Message','Either this request is Decommisioned already or not Disabled.');
            } else {
                try{
                    if(ProvReq.Record_Type_Name__c == 'ZB2B Interactive'){
                       isSuccess = callOutZB2BInteractive(ProvReq, 'Request_ReEnable'); 
                    }

                    else if(ProvReq.Record_Type_Name__c == 'ZPA Interactive for Partners'){

                       isSuccess = callOutZPAImpartner(ProvReq, 'Request_ReEnable');
                    }
                    if(isSuccess){
                        ProvReq.Provisioning_Status__c = 'Request ReEnable';
                        ProvReq.FailedReason__c = '';
                    }
                    update ProvReq;
                    ResultMap.put('Status','Success');
                    ResultMap.put('Message','Updated Successfully');
                }
                catch(Exception ex){ ResultMap.put('Status','Error');ResultMap.put('Message',ex.getMessage());}
            }
            return ResultMap;
        }
        return null;
    }
    
    
    @AuraEnabled
    public static Map<string,string> DecommissionInteractive(string reqId){
        Map<string,string> ResultMap = new Map<string,string>();
        boolean isSuccess;
        if(reqId != null){
            Product_Demo_Instance_Request__c ProvReq = [select Id,Name,Provisioning_Status__c,RecordTypeId,RecordType.Name,Record_Type_Name__c,
                                                        Provisioning_Decommissioned_Date__c 
                                                        from Product_Demo_Instance_Request__c where Id =:reqId limit 1];
            
            if(ProvReq.Provisioning_Status__c == 'Decommissioned'){
                ResultMap.put('Status','Error');
                ResultMap.put('Message','This request is Decommisioned already.');
            }else {
                try{
                    if(ProvReq.Record_Type_Name__c == 'ZB2B Interactive'){
                       isSuccess = callOutZB2BInteractive(ProvReq, 'Request_Decommission'); 
                    }

                    else if(ProvReq.Record_Type_Name__c == 'ZPA Interactive for Partners'){

                       isSuccess = callOutZPAImpartner(ProvReq, 'Request_Decommission');
                    }
                    if(isSuccess){
                        ProvReq.Provisioning_Status__c = 'Request Decommission';
                        //ProvReq.Provisioning_Decommissioned_Date__c = system.today();
                        //ProvReq.FailedReason__c = '';
                    }
                    update ProvReq;
                    ResultMap.put('Status','Success');
                    ResultMap.put('Message','Updated Successfully');
                }
                catch(Exception ex){ResultMap.put('Status','Error');ResultMap.put('Message',ex.getMessage());}
            }
            return ResultMap;
        }
        return null;
    }
    
    
    @testVisible
    private static boolean callOutZB2BInteractive(Product_Demo_Instance_Request__c pr,  String requestType) {
        Boolean isSuccess = false;
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeStringField('requestId', pr.id);
        gen.writeStringField('sourceSystem', 'salesforce');
        gen.writeStringField('sobject', 'Product Demo Instance Request');
        gen.writeStringField('requestType', requestType);
        gen.writeEndObject();
        String jsonString = gen.getAsString();
        HttpRequest req = new HttpRequest();
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Accept', 'application/json');
        req.setEndpoint('callout:ZB2B_Interactive');
        req.setMethod('POST');
        req.setBody(jsonString);
        req.setTimeout(60000);
        try {
            Http http = new Http();
            HttpResponse response = null;
            
            System.debug('----request---'+req);
            System.debug('----request body---'+jsonString);
            
            if (!Test.isRunningTest()) {
                response = http.send(req);
            }else{
                response = new HttpResponse();
                response.setStatusCode(200);
            }
            system.debug('----response---'+response);
            
            if (response.getStatusCode() == 200) {
                isSuccess = true;
                pr.Integration_Status__c = 'In Progress';
            }else {
                isSuccess = false;
                pr.Integration_Status__c = 'Failed';
                pr.FailedReason__c = response.getBody();
            }
        } 
        catch (Exception e) { pr.Integration_Status__c = 'Failed';pr.FailedReason__c = e.getMessage();}
        return isSuccess;
    }
    
    
    @testVisible
    private static boolean callOutSafeMarch(Product_Demo_Instance_Request__c pr) {
        Boolean isSuccess = false;
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeStringField('requestId', pr.id);
        gen.writeStringField('sourceSystem', 'salesforce');
        gen.writeStringField('sobject', 'Product Demo Instance Request');
        gen.writeEndObject();
        String jsonString = gen.getAsString();
        HttpRequest req = new HttpRequest();
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Accept', 'application/json');
        req.setEndpoint('callout:Safemarch');
        req.setMethod('POST');
        req.setBody(jsonString);
        req.setTimeout(60000);
        try {
            Http http = new Http();
            HttpResponse response = null;
            
            System.debug('----request---'+req);
            System.debug('----request body---'+jsonString);
            
            if (!Test.isRunningTest()) {
                response = http.send(req);
            }else{
                response = new HttpResponse();
                response.setStatusCode(200);
            }
            system.debug('----response---'+response);
            
            if (response.getStatusCode() == 200) {
                isSuccess = true;
                pr.Integration_Status__c = 'In Progress';
            }else {
                isSuccess = false;
            pr.Integration_Status__c = 'Failed';
                pr.FailedReason__c = response.getBody();
        }
        } 
        catch (Exception e) {pr.Integration_Status__c = 'Failed';pr.FailedReason__c = e.getMessage();}
        return isSuccess;
    }
    
    @testVisible
    private static boolean callOutZPAImpartner(Product_Demo_Instance_Request__c pr,  String requestType) {
        Boolean isSuccess = false;
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeStringField('requestId', pr.id);
        gen.writeStringField('sourceSystem', 'salesforce');
        gen.writeStringField('sobject', 'Product Demo Instance Request');
        gen.writeStringField('requestType', requestType);
        gen.writeEndObject();
        String jsonString = gen.getAsString();
        HttpRequest req = new HttpRequest();
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Accept', 'application/json');
        req.setEndpoint('callout:ZPA_Impartner');
        req.setMethod('POST');
        req.setBody(jsonString);
        req.setTimeout(60000);
        try {
            Http http = new Http();
            HttpResponse response = null;
            
            System.debug('----request---'+req);
            System.debug('----request body---'+jsonString);
            
            if (!Test.isRunningTest()) {
                response = http.send(req);
            }else{
                response = new HttpResponse();
                response.setStatusCode(200);
            }
            system.debug('----response---'+response);
            
            if (response.getStatusCode() == 200) {
                isSuccess = true;
                pr.Integration_Status__c = 'In Progress';
            }else {
                isSuccess = false;
                pr.Integration_Status__c = 'Failed';
                pr.FailedReason__c = response.getBody();
            }
        } 
        catch (Exception e) {pr.Integration_Status__c = 'Failed';pr.FailedReason__c = e.getMessage();}
        return isSuccess;
    }
    
    
    
    @future(callout = true)
    public static void callOutInteractive(Id requestId) {
        System.debug('----callOutZB2BInteractive called---');
        Product_Demo_Instance_Request__c pr = new  Product_Demo_Instance_Request__c(id = requestId);
        try{
            pr = [select id, name, Integration_Status__c,RecordType.Name,Record_Type_Name__c,Partner_OKTA_ID__c from Product_Demo_Instance_Request__c where id = : requestId limit 1];
            //pr.Integration_Status__c = 'In Progress';

                if(pr.Record_Type_Name__c == 'ZPA Interactive for Partners'){
                    callOutZPAImpartner(pr, 'Request_Provisioning');
                }
            	 // To call Safemarch callout only when Partner Okta ID is not null CR#5036 -Start --Mahesh T
                else if(pr.Record_Type_Name__c == 'Safemarch for Partners' && pr.Partner_OKTA_ID__c != null){
                    callOutSafeMarch(pr);
                }
                 else if(pr.Record_Type_Name__c == 'Safemarch for Partners' && pr.Partner_OKTA_ID__c == null){ 
                    pr.Integration_Status__c = 'Failed';
                    pr.FailedReason__c ='Partner_OKTA_ID__c is Blank' ;
                } //  CR#5036 -End
                else if(pr.Record_Type_Name__c == 'ZB2B Interactive'){
                    callOutZB2BInteractive(pr, 'Request_Provisioning');


        }
        }catch(Exception e){ pr.Integration_Status__c = 'Failed';pr.FailedReason__c = e.getMessage();}
        update pr;
    }
    
}