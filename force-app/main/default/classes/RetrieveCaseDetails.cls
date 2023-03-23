/**
 * @description       : IBA-3349
 * @author            : Viral
 * @group             : Integartion
 * @last modified on  : 09-28-2022
 * @last modified by  : Viral
**/
@RestResource(urlMapping='/GetCaseDetail/*')
global class RetrieveCaseDetails {
    
    public static Id caseSupportRT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Support').getRecordTypeId();
    
    @HttpPost
    global static void doPost(){
        
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        String actualRequest = req.requestBody.toString();
        System.debug('---actualRequest---->' + actualRequest);
        
        CaseDetailResponse response = null;
        
        try{
            
            //Step1. Parse the Request
            CaseDetailRequest cdr = (CaseDetailRequest) System.JSON.deserialize(actualRequest, CaseDetailRequest.class);
            
            //Step2. Input Validation
            if(cdr.CloudID == null || String.isEmpty(cdr.CloudID.trim())){
                res.statusCode = 404;
                List<SalesforceError> errs = new List<SalesforceError>();
                errs.add(new SalesforceError('NOT_FOUND', 'CloudID is required.'));
                RestContext.response.responseBody = Blob.valueOf(JSON.serialize(errs));
                return;
            }
            
            if(cdr.StartDate == null || String.isEmpty(cdr.StartDate.trim())){
                res.statusCode = 404;
                List<SalesforceError> errs = new List<SalesforceError>();
                errs.add(new SalesforceError('NOT_FOUND', 'StartDate is required.'));
                RestContext.response.responseBody = Blob.valueOf(JSON.serialize(errs));
                return;
            }
            
            if(cdr.EndDate == null || String.isEmpty(cdr.EndDate.trim())){
                res.statusCode = 404;
                List<SalesforceError> errs = new List<SalesforceError>();
                errs.add(new SalesforceError('NOT_FOUND', 'EndDate is required.'));
                RestContext.response.responseBody = Blob.valueOf(JSON.serialize(errs));
                return;
            }
            
            //Step3. Data Retrival
            Zscaler_Cloud_ID__c zscloud = retriveCloudDetail(cdr.CloudID);
            System.debug('---zscloud---'+zscloud);
            DateTime StartDate = retriveDateTimeValue(cdr.StartDate);
            DateTime EndDate = retriveDateTimeValue(cdr.EndDate);
            List<Case> caseList = retriveCases(cdr.CloudID, zscloud, StartDate, EndDate); 
            System.debug('---caseList---'+caseList);
            System.debug('---caseList-Size--'+caseList.size());
            
            //Step4. Prepare the Response
            response = new CaseDetailResponse(zscloud, caseList);
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
    
    
    @testvisible
    private static DatetIme retriveDateTimeValue (String dt){
        //"Start Date":"20220601 000000.000" -->  2022-06-01T04:00:00.000Z
        //"End Date": "20220831 235959.999" -->  2022-08-31T04:00:00.000Z    
        try{
            System.debug('--retriveDateTimeValue--dt--'+dt);
            List<String> dateStringList = dt.split(' ');
            if(!dateStringList.isEmpty()){
                String datePart = dateStringList[0];
                Integer yyyy = Integer.valueOf(datePart.left(4));
                Integer mm = Integer.valueOf(datePart.substring(4, 6));
                Integer dd = Integer.valueOf(datePart.substring(6, 8));
                
                String timePart = dateStringList[1];
                
                Integer HH = Integer.valueOf(timePart.left(2));
                Integer MI = Integer.valueOf(timePart.substring(2, 4));
                Integer SS = Integer.valueOf(timePart.substring(4, 6));
                
                Datetime rtDT = Datetime.newInstanceGMT(yyyy, mm, dd, HH, MI, SS);
                System.debug('--retriveDateTimeValue--rtDT--'+rtDT);
                return rtDT;
            }
        }catch(Exception ex){
            System.debug('--retriveDateTimeValue--Exception--'+ex.getMessage());
            System.debug('--retriveDateTimeValue--Exception--'+ex.getLineNumber());
        }
        return null;
    }
    
    @testvisible
    private static Zscaler_Cloud_ID__c retriveCloudDetail (String cloudID){
        if(cloudID != null){
            return [Select ID,Name,Account__c,Account_Type__c,Cloud_Type__c,Status__c from Zscaler_Cloud_ID__c where name =:cloudID limit 1];
        }
        return null;
    }
    
    
    @testvisible
    private static List<Case> retriveCases (String cloudID, Zscaler_Cloud_ID__c zCloud, DateTime StartDate, DateTime EndDate){
        List<Case> caseDetails = new List<Case>();
        if(zCloud != null){
            for(Case cs : [Select id,CaseNumber,Subject,Case_Type__c,Status,Priority,
                           Product_New__c,
                           Case_Category__c,Case_Sub_Category__c,
                           AccountID,Account.Name,Account_Name__c,
                           Requester__c,Requester__r.Name,Requester__r.Email,Requestor_s_Email__c,
                           CreatedDate,LastModifiedDate
                           from Case 
                           where 
                           AccountID = :zCloud.Account__c 
                           and zscaler_org_id__c = :cloudID
                           and recordTypeId = :caseSupportRT
                           and CreatedDate != null
                           and CreatedDate >= :StartDate 
                           and CreatedDate <= :EndDate
                          ])
            {
                caseDetails.add(cs);
            }
        }
        return caseDetails;
    }
    
    
    //Request Details
    global class CaseDetailRequest {
        global String CloudID;
        global String StartDate;
        global String EndDate;
    }
    
    //Resposne Details
    global class CaseDetailResponse {
        global String AccountID;
        global String CloudID;
        global List<CaseDetailWrapper> CaseDetails;
        
        global CaseDetailResponse(Zscaler_Cloud_ID__c zscloud, List<Case> caseList){
            this.AccountID = zscloud.Account__c;
            this.CloudID = zscloud.Name;
            this.CaseDetails = new List<CaseDetailWrapper>();            
            if(caseList != null){
                for(Case cs : caseList){
                    this.CaseDetails.add(new CaseDetailWrapper(cs));
                }
            }
        }
    }
    
    global class CaseDetailWrapper {
        global String CaseID;
        global String Type;
        global String Status;
        global String CreatedDate;
        global String Product;
        global String CaseCategory;
        global String CaseSubCategory;
        global String Subject;
        global String AccountName;
        global String RequestedByID;
        global String RequestedByName;
        global String RequestedByEmail;
        global String Priority;
        global String CaseNumber;
        
        global CaseDetailWrapper(Case cs){
            this.CaseID = cs.Id;
            this.Type = cs.Case_Type__c;
            this.Status = cs.Status;
            this.CreatedDate = String.valueOf(cs.CreatedDate);
            this.Product = cs.Product_New__c;
            this.CaseCategory = cs.Case_Category__c;
            this.CaseSubCategory = cs.Case_Sub_Category__c;
            this.Subject = cs.Subject;
            this.AccountName = cs.Account_Name__c;
            this.RequestedByID = cs.Requester__c;
            this.RequestedByName = cs.Requester__r.Name;
            this.RequestedByEmail = cs.Requestor_s_Email__c;
            this.Priority = cs.Priority;
            this.CaseNumber = cs.CaseNumber;
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