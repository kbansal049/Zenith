/**
 * @description       : 
 * @author            : Jade Global
 * @group             : 
 * @last modified on  : 06-11-2021
 * @last modified by  : Jade Global
 * Modifications Log 
 * Ver   Date         Author        Modification
 * 1.0   06-09-2021   Jade Global   Initial Version
**/
public with sharing class QuoteApproval_VFController {

    public Id quoteApprovalId;
    public Id quoteId;
    public String comment;
    public PageReference returnPage = null;
    public static String APPROVE_API = 'sbaa.ApprovalRestApiProvider.Approve';
    public static String REJECT_API = 'sbaa.ApprovalRestApiProvider.Reject';

    public string approvalComments {get; set;}
    public sbaa__Approval__c approval {get; set;}
    public id userId {get; set;}

    public QuoteApproval_VFController() {
        
        approval = new sbaa__Approval__c();
        userId = userInfo.getUserId();
        string appReqId = '';
        appReqId = ApexPages.currentPage().getParameters().get('Id');
        system.debug('inside## '+appReqId);  
        quoteApprovalId = appReqId;
        if(appReqId != null && appReqId != ''){
            approval = [Select Id, Quote__c  from sbaa__Approval__c where Id =: appReqId];
        }
        if(approval.Quote__c != null) {
           returnPage = new PageReference('/lightning/page/home');
        }

    }
    
      public PageReference approve() {
        system.debug('inside approve 1');    
        String payload = generateApprovalPayload(APPROVE_API);
        executeRestAPI(payload, 'approve');
        system.debug('payload '+payload);
        returnPage = new PageReference('/lightning/page/home');
        system.debug('inside approve 2 '+returnPage);  
        return returnPage;
      }
    
      public PageReference reject() {
        String payload = generateRejectionPayload(REJECT_API);
        executeRestAPI(payload, 'reject');
        returnPage = new PageReference('/lightning/page/home');
        return returnPage;
      }
    
      public void executeRestAPI(String payload, String type) {
        Boolean failed = false;
        String errorMessage = '';
    
        try {
          HttpRequest req = new HttpRequest();
          req.setMethod('POST');
          req.setHeader('Content-Type', 'application/json');
          req.setHeader('Accept', 'application/json');
          req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
    
          String baseUrl = URL.getOrgDomainUrl().toExternalForm();
          req.setEndpoint(baseUrl + '/services/apexrest/sbaa/ServiceRouter');
          req.setTimeout(30000);
          req.setBody(payload);
          system.debug('request '+req);
    
          Http http = new Http();
          HTTPResponse resp = http.send(req);
          system.debug('response '+resp);
          if (resp.getStatusCode() != 200) {
            failed = true;
            errorMessage = resp.getBody();
          }
        } catch (Exception ex) {
          failed = true;
          errorMessage = ex.getMessage();
        }
    
        if (failed) {
          ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Unable to ' + type + ' quote'));
          ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, payload));
          ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, errorMessage));
          returnPage = null;
        }
      }
    
      public String generateApprovalPayload(String saver) {
        system.debug('inside payload quoteApprovalId '+quoteApprovalId);
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject(); 
        gen.writeStringField('model', '{"approvalId": "' + quoteApprovalId + '", "comments" : " '+approvalComments+'"}');
        gen.writeStringField('saver', 'sbaa.ApprovalRestApiProvider.Approve');
        gen.writeEndObject();
    
        return gen.getAsString();
      }


      public String generateRejectionPayload(String saver) {

        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject(); 
        gen.writeStringField('model', '{"approvalId": "' + quoteApprovalId + '", "comments" : " '+approvalComments+'"}');
        gen.writeStringField('saver', 'sbaa.ApprovalRestApiProvider.Reject');
        gen.writeEndObject();
    
        return gen.getAsString();
      }
}