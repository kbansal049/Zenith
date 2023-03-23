/**
 * Name : CaseRelatedIssuesSendUpdates
 * Description : Send most recent updates to newly attached Cases
 * Test Class : 
 * Initial Author : Ankit Bhatnagar
 */

public with sharing class CaseRelatedIssuesSendUpdates implements Queueable {
    private List<CaseRelatedIssue> caseRelatedIssueList;
    
    public CaseRelatedIssuesSendUpdates(List<CaseRelatedIssue> criList) {
        this.caseRelatedIssueList = criList;
    }
    
    public void execute(QueueableContext context) {
        String orgWideEmail = [select Id from OrgWideEmailAddress where Address = 'support@zscaler.com' LIMIT 1].id;
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        Map<String, List<FeedAttachment>> caseFeedAttachments = new Map<String, List<FeedAttachment>>();
        Map<String, List<String>> emailContentDocumentMap = new Map<String, List<String>>();
        Map<String, FeedItem> caseFeedItems = new Map<String, FeedItem>();
        List<Zscaler_Error_Logs__c> zsErrorLogsList = new List<Zscaler_Error_Logs__c>();
        Set<Id> incidentIds=new Set<Id>(); 
        Set<Id> caseIds=new Set<Id>(); 
        Map<String,Case> caseMap; 
        for(CaseRelatedIssue cri:CaseRelatedIssueList){
            if(cri.RelatedEntityType=='Incident'){
                incidentIds.add(cri.RelatedIssueId);
                caseIds.add(cri.caseId);
            }
        }
        if(!caseIds.isEmpty()) {
            caseMap = new Map<String, Case>([SELECT id, caseNumber,Subject,contactId, Case_CC_List__c, Customer_CC_List__c, internal_CC_List__c FROM Case WHERE id IN : caseIds]);
        }
        if(!incidentIds.isEmpty() && !caseIds.isEmpty()) {
            Map<String,String> incidentMessageMap= new Map<String,String>();
            Map<String,EmailMessage> emailMessageMap= new Map<String,EmailMessage>();
            Set<String> cloudIncidentIds = new Set<String>();
            for(Incident inc : [SELECT id FROM Incident WHERE id IN : incidentIds AND recordType.DeveloperName = 'Cloud_Incident']) {
                cloudIncidentIds.add(inc.Id);
            }
            for(EmailMessage em : [ Select id,RelatedToId,FromName,FromAddress,CcAddress,BccAddress,subject,textBody,HtmlBody,toAddress 
                                    FROM EmailMessage WHERE Incoming = false AND RelatedToId IN :cloudIncidentIds AND subject like '%Z-EXT%' order by MessageDate Desc]) {
                //System.debug('##em' + em);
                if(!incidentMessageMap.containsKey(em.RelatedToId)) {
                    incidentMessageMap.put(em.RelatedToId, em.id);
                    emailMessageMap.put(em.id, em);
                }
            }
            if(!emailMessageMap.isEmpty()) {
                Map<String, ContentVersion> contentVersionMap = new Map<String, ContentVersion>();
                for(ContentDocumentLink cdl : [SELECT Id, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId IN :emailMessageMap.keyset()]) {
                    if(!emailContentDocumentMap.containsKey(cdl.linkedEntityId)) {
                        emailContentDocumentMap.put(cdl.linkedEntityId, new List<String>());
                    }
                    emailContentDocumentMap.get(cdl.linkedEntityId).add(cdl.ContentDocumentId);
                    contentVersionMap.put(cdl.ContentDocumentId, null);
                }
                if(!emailContentDocumentMap.isEmpty()) {
                    for(ContentVersion cv : [SELECT id,contentDocumentId,pathOnClient,title,versionData FROM ContentVersion WHERE ContentDocumentId IN : contentVersionMap.keyset()]) {
                        contentVersionMap.put(cv.contentDocumentId, cv);
                    }
                }

                for(CaseRelatedIssue cri : caseRelatedIssueList) {
                    if(cri.RelatedEntityType=='Incident' && incidentMessageMap.containsKey(cri.RelatedIssueId) && caseMap.containsKey(cri.caseId)){
                        EmailMessage em = emailMessageMap.get(incidentMessageMap.get(cri.RelatedIssueId));
                        Case c = caseMap.get(cri.caseId);
                        Messaging.SingleEmailMessage singleEmail = new Messaging.SingleEmailMessage();
                        List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();
                        if(emailContentDocumentMap.containsKey(em.id) && emailContentDocumentMap.get(em.id).size() > 0) {
                            //Attachment Exists
                            for(String docId : emailContentDocumentMap.get(em.id)) {
                                if(contentVersionMap.containsKey(docId)) {
                                    Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
                                    attach.setFileName(contentVersionMap.get(docId).pathOnClient);
                                    attach.setBody(contentVersionMap.get(docId).versionData);
                                    //attach.setContentType(contentVersionMap.get(docId).pathOnClient);
                                    attachments.add(attach);
        
                                    FeedAttachment feedAttachment = new FeedAttachment(recordId = contentVersionMap.get(docId).Id, type = 'CONTENT');
                                    if(!caseFeedAttachments.containsKey(c.Id)) {
                                        caseFeedAttachments.put(c.Id, new List<FeedAttachment>());
                                    }
                                    caseFeedAttachments.get(c.Id).add(feedAttachment);
                                }
                            }
                        }
                        Set<String> ccAddresses = new Set<String>();
                        if(String.isNotBlank(c.internal_CC_List__c)) {
                            ccAddresses.addAll(new Set<String>(c.internal_CC_List__c.split(';')));
                        }
                        if(String.isNotBlank(c.Customer_CC_List__c)) {
                            ccAddresses.addAll(new Set<String>(c.Customer_CC_List__c.split(';')));
                        }
                        if(String.isNotBlank(c.Case_CC_List__c)) {
                            ccAddresses.addAll(new Set<String>(c.Case_CC_List__c.split(';')));
                        }
                        singleEmail.setSubject(c.caseNumber + '-'+ c.subject +' : '+em.subject);
                        singleEmail.setOrgWideEmailAddressId(orgWideEmail);
                        singleEmail.setHTMLBody(em.HtmlBody);
                        //singleEmail.setToAddresses(new List<String>{c.contactEmail});
                        singleEmail.setCcAddresses(new List<String>(ccAddresses));
                        singleEmail.setPlainTextBody(em.textBody);
                        singleEmail.setWhatId(c.id);
                        singleEmail.setTargetObjectId(c.ContactId);
                        singleEmail.setTreatTargetObjectAsRecipient(true);
                        singleEmail.setSaveAsActivity(true);
                        singleEmail.setFileAttachments(attachments);
                        emails.add(singleEmail);
        
                        FeedItem newFI= new FeedItem(ParentId=c.id,body=em.textBody,Visibility='AllUsers');
                        caseFeedItems.put(c.id,newFI);
                    }
                }
                //System.debug('## emails'+ emails);
                if(!emails.isEmpty()) {
                     if(!Test.isRunningTest()){
                         Messaging.SendEmailResult[] result = Messaging.sendEmail(emails);         
                       }
                    //System.debug('## result: '+ result);
                    List<FeedAttachment> fAttachments = new List<FeedAttachment>();
                    if(!caseFeedItems.isEmpty()) {
                        Database.insert(caseFeedItems.values());
                        for(FeedItem fi : caseFeedItems.values()) {
                            if(caseFeedAttachments.containsKey(fi.ParentId)) {
                                for(FeedAttachment fa : caseFeedAttachments.get(fi.ParentId)) {
                                    fa.FeedEntityId = fi.id;
                                    fAttachments.add(fa);
                                }
                            }
                        }
                        if(!fAttachments.isEmpty()) {
                            Database.insert(fAttachments);
                        }
                    }
                }
            }
        }
    }
}