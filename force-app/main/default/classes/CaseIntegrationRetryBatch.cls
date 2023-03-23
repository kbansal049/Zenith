/**
 * CaseIntegrationRetryBatch
 * Added by : Anup Dhole
 * Description : Insert cases for Failed & Not Started records .
 */
public with sharing class CaseIntegrationRetryBatch implements Database.Batchable<sObject>, Database.Stateful {
    ZscalerBatchFramework zb = new ZscalerBatchFramework('CaseIntegrationRetryBatch');
    List<Case_Integration__c> thresholdCsInt = new List<Case_Integration__c>();//IBA-5947
    Integer retryThreshold = Integer.valueOf(Label.Case_Integration_retry_Threshold);//IBA-5947
    public Database.QueryLocator start(Database.BatchableContext context){
        this.zb.callStart();
        String status = Label.Case_Upsert_Status_For_Retry;
        List<String> listOfStatus = new List<String>();
        if(status!=null){
            listOfStatus = status.split(';');
        }else{
            listOfStatus.add('Failure');
        }
        
        String query = 'Select Id, Name, Case_Origin__c, CreatedDate, Case_Creation_Status__c, Retry_Counter__c from Case_Integration__c WHERE Case_Creation_Status__c IN:listOfStatus and (Retry_Counter__c=null or Retry_Counter__c < :retryThreshold)';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext context, List<Case_Integration__c> scope){
        this.zb.callExecute(scope[0]?.Id, scope.size());
        for(Case_Integration__c ci : scope)
        {
            ci.Case_Creation_Status__c = 'Initiated';
        }
        update scope;    
        
        //Added By Anup - IBA-5947 - Start
        for(Case_Integration__c csInt : [select id, Name, CreatedDate, Case_Origin__c, Retry_Counter__c from Case_Integration__c where Id IN:scope]){
            if(csInt.Retry_Counter__c >= retryThreshold){
                thresholdCsInt.add(csInt);
            }
        }
        //Added By Anup - IBA-5947 - End
    }

    public void finish(Database.BatchableContext bc){
        this.zb.callFinish(bc);
        //Added By Anup - IBA-5947 - Start
        if(!thresholdCsInt.isEmpty()){
            createCsvAttachmentAndSendEmail(thresholdCsInt);
        }
        //Added By Anup - IBA-5947 - Start
    }
    
    //Added By Anup - IBA-5947
    public static void createCsvAttachmentAndSendEmail(List<Case_Integration__c> csIntList){
        string header = 'Case Integration Id, Name , Origin, Created Date\n';
        String finalCsvStr = header;
        for(Case_Integration__c csInt: csIntList)
        {
        	string recordString = csInt.id+','+csInt.Name+','+csInt.Case_Origin__c+','+csInt.CreatedDate +'\n';
        	finalCsvStr = finalCsvStr +recordString;
        }
        Messaging.EmailFileAttachment csvAttachment = new Messaging.EmailFileAttachment();
        blob csvBlob = Blob.valueOf(finalCsvStr);
        string csvname= 'Case Integration Retry Failure Records ('+System.now()+').csv';
        csvAttachment.setFileName(csvname);
        csvAttachment.setBody(csvBlob);
        Messaging.SingleEmailMessage email =new Messaging.SingleEmailMessage();
        String emailAddress = Label.Case_Integration_Retry_Email_Addresses;
        List<String> toAddresses = emailAddress.split(';');
        String subject ='Case Integration Retry Failure';
        email.setSubject(subject);
        email.setToAddresses( toAddresses );
        email.setPlainTextBody('Hi Team,\n\nPlease find attached the failure records and take appriopriate action.\n\nRegards');
        email.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttachment});
        Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
    }
}