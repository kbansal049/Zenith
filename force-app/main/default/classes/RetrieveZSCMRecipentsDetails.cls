/**
* @description       : IBA-3349
* @author            : Viral
* @group             : Integartion
* @last modified on  : 11-07-2022 (MM-DD-YYYY)
* @last modified by  : Viral
**/
@RestResource(urlMapping='/GetZSCMRecipents/*')
global class RetrieveZSCMRecipentsDetails {
    
    @HttpPost
    global static void doPost(){
        
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        String actualRequest = req.requestBody.toString();
        System.debug('---actualRequest---->' + actualRequest);
        
        List<ZSCMRecipentsDetailResponse> response = null;
        
        try{
            
            //Step1. Parse the Request
            //ZSCMRecipentsDetailRequest cdr = (ZSCMRecipentsDetailRequest) System.JSON.deserialize(actualRequest, ZSCMRecipentsDetailRequest.class);
            
            List<String> cloudNames = (List<String>) System.JSON.deserialize(actualRequest, List<String>.class);
            
            //Step2. Input Validation
            if(cloudNames == null || cloudNames.isEmpty()){
                res.statusCode = 404;
                List<SalesforceError> errs = new List<SalesforceError>();
                errs.add(new SalesforceError('NOT_FOUND', 'CloudIDs are required.'));
                RestContext.response.responseBody = Blob.valueOf(JSON.serialize(errs));
                return;
            }
            
            
            //Step3. Data Retrival
            List<Zscaler_Cloud_ID__c> zscloudList = retriveCloudDetails(cloudNames);
            System.debug('---zscloudList---'+zscloudList);
            
            
            //Step4. Prepare the Response
            response = generateResponse(zscloudList);
            System.debug('---response---'+response);
            
            RestContext.response.responseBody = Blob.valueOf(JSON.serialize(response));
            
        }catch(Exception ex){
            System.debug('--Exception--Ex--'+ex.getMessage());
            System.debug('--Exception--Ex--'+ex.getLineNumber());
            System.debug('--Exception--Ex--'+ex.getStackTraceString());
            res.statusCode = 500;
            List<SalesforceError> errs = new List<SalesforceError>();
            errs.add(new SalesforceError('ERROR', ex.getMessage()));
            RestContext.response.responseBody = Blob.valueOf(JSON.serialize(errs));
        }
    }
    
    @testVisible
    private static List<ZSCMRecipentsDetailResponse> generateResponse(List<Zscaler_Cloud_ID__c> zscloudList){
        List<ZSCMRecipentsDetailResponse> response = new List<ZSCMRecipentsDetailResponse>();
        if(zscloudList != null && !zscloudList.isEmpty()){
            for(Zscaler_Cloud_ID__c zcloud : zscloudList){
                response.add(new ZSCMRecipentsDetailResponse(zcloud));
            }
        }
        return response;
    }
    
    
    @testvisible
    private static List<Zscaler_Cloud_ID__c> retriveCloudDetails (List<String> cloudIDs){
        if(cloudIDs != null){
            return [Select ID,Name,Account__c,Account_Type__c,Cloud_Type__c,Status__c,Avg_Estimated_Users_L31D__c,
                    (Select Id,Name,Contact_Email__c,Email_Insights_Report__c 
                     from Zscaler_Cloud_ID_Contacts__r where Email_Insights_Report__c in ('Send', 'Send delayed'))
                    from Zscaler_Cloud_ID__c where name in :cloudIDs];
        }
        return null;
    }
    
    
    //Request Details
    global class ZSCMRecipentsDetailRequest {
        global List<String> cloudNames;
    }
    
    //Resposne Details
    global class ZSCMRecipentsDetailResponse {
        global List<String> sendEmail;
        global List<String> delayedEmail;
        global String cloudId; 
        global Decimal avgEstimatedUsersL31D;
        
        global ZSCMRecipentsDetailResponse(Zscaler_Cloud_ID__c zscloud){
            this.cloudid = zscloud.Name;
            if(zscloud.Zscaler_Cloud_ID_Contacts__r != null){
                this.sendEmail = new List<String>();
                this.delayedEmail = new List<String>();
                this.avgEstimatedUsersL31D = zscloud.Avg_Estimated_Users_L31D__c;
                for(Zscaler_Cloud_ID_Contact__c zcc :zscloud.Zscaler_Cloud_ID_Contacts__r){
                    if(zcc.Email_Insights_Report__c == 'Send' && 
                       zcc.Contact_Email__c !=null && 
                       zcc.Contact_Email__c != '')
                    {
                        sendEmail.add(zcc.Contact_Email__c);
                    }
                    else if(zcc.Email_Insights_Report__c == 'Send delayed' &&
                            zcc.Contact_Email__c !=null && 
                            zcc.Contact_Email__c != '')
                    {
                        delayedEmail.add(zcc.Contact_Email__c);
                    }
                }
            }
        }
    }
    
    //Standard salesforce error response structure
    public class SalesforceError {
        public String errorCode;
        public String message;
        public SalesforceError(String errorCode, string message){
            this.errorCode = errorCode;
            this.message = message;
        }
    }
}