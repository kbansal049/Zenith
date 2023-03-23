/**
 * NotifyCustomersOnIncidentCasesBatch
 * Added by : Ankit Bhatnagar
 * Description : 
 * 10/03/2022 : IBA-3350 - Implemented RaisesPlatformEvents for error handling
 * 10/26/2022 : IBA-2887 - Added AccountAsyncTrigger, AccountEventTrigger and AmberRoadAccountScreenListener trigger bypass logic.
 */
public class NotifyCustomersOnIncidentCasesBatch implements Database.Batchable<sObject>, Database.Stateful, Database.RaisesPlatformEvents{
    ZscalerBatchFramework zscalerBatchFrameWorkObj = new ZscalerBatchFramework('NotifyCustomersOnIncidentCasesBatch');
    Map<String, String> emailIncidentMap;
    String query;

    public NotifyCustomersOnIncidentCasesBatch(Map<String, String> emailIncidentMap){
        this.emailIncidentMap = emailIncidentMap;
        this.query = 'SELECT id,CaseId,RelatedIssueId FROM CaseRelatedIssue WHERE RelatedIssueId IN :keys';
    }

    public Database.QueryLocator start(Database.BatchableContext context){
        this.zscalerBatchFrameWorkObj.callStart();
        Set<String> keys = emailIncidentMap.keySet(); 
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext context, List<CaseRelatedIssue> scope){
        this.zscalerBatchFrameWorkObj.callExecute(scope[0]?.Id, scope.size());
        TriggerHandler.bypass('TaskTriggerHandler'); 			    //Bypass'TaskMasterTrigger on Task'
        TriggerHandler.bypass('AccountTriggerHandler');			    //IBA-3350 - Bypass 'AccountMasterTrigger on Account'
        TriggerHandler.bypass('ContactTriggerHandler');				    //IBA-3350 - Bypass 'ContactTriggerHelper'

        //IBA-2887 Added by Ram Sangati - Starts here.
        TriggerHandler.bypass('AccountAsyncTriggerHandler');	    //IBA-2887 - Bypass 'AccountAsyncTrigger on AccountChangeEvent'
        TriggerHandler.bypass('AccountEventTriggerHandler');	    //IBA-2887 - Bypass 'AccountEventTrigger on Account_Event__e'
        TriggerHandler.bypass('AmberRoadAccountScreenListener');	//IBA-2887 - Bypass 'AmberRoadAccountScreenListener on Amber_Road_Screen_Account__e'
        //IBA-2887 Added by Ram Sangati - Ends here.
        
        TriggerUtility.SkipContentDocLinkTriggerExecuted();
        if(!scope.isEmpty()) {
            Set<String> emailIds = new Set<String>(); 
            for(CaseRelatedIssue cri : scope) {
                if(emailIncidentMap.containsKey(cri.relatedIssueId)) {
                    emailIds.add(emailIncidentMap.get(cri.relatedIssueId));
                }
            }

            if(!emailIds.isEmpty()) {
                String orgWideEmail = [select Id from OrgWideEmailAddress where Address = 'support@zscaler.com' LIMIT 1].id;
                List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
                Map<String, List<String>> caseIncidentMap = new Map<String, List<String>>();
                Map<String, Case> caseMap = new Map<String, Case>();
                Map<String, EmailMessage> emailMap = new Map<String, EmailMessage>([SELECT id,RelatedToId,FromName,FromAddress,CcAddress,BccAddress,subject,textBody,HtmlBody,toAddress FROM EmailMessage WHERE ID IN :emailIds]);            
                Map<String, FeedItem> caseFeedItems = new Map<String, FeedItem>();
                Map<String, List<FeedAttachment>> caseFeedAttachments = new Map<String, List<FeedAttachment>>();
                //New Changes- Start
                Map<String, List<String>> emailContentDocumentMap = new Map<String, List<String>>();
                Map<String, ContentVersion> contentVersionMap = new Map<String, ContentVersion>();
                for(ContentDocumentLink cdl : [SELECT Id, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId IN :emailIds]) {
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
                
                for(CaseRelatedIssue cri : scope) {
                    if(!caseIncidentMap.containsKey(cri.RelatedIssueId)) {
                        caseIncidentMap.put(cri.RelatedIssueId, new List<String>());
                    }
                    caseIncidentMap.get(cri.RelatedIssueId).add(cri.caseId);
                    caseMap.put(cri.caseId, null);
                }
                
                if(!caseIncidentMap.isEmpty()) {
                    for(Case c : [SELECT id,caseNumber,subject,Internal_CC_List__c,Customer_CC_List__c,Case_CC_List__c,ContactEmail,contactId FROM Case WHERE id IN :caseMap.keyset() Order by caseNumber ]) {
                        caseMap.put(c.id, c);
                    }
                    //System.debug('## caseMap: '+ JSON.serialize(caseMap));
                    for(EmailMessage email : emailMap.values()) {
                        for(String caseId : caseIncidentMap.get(email.relatedToId)) {
                            Case c = caseMap.get(caseId);
                            Messaging.SingleEmailMessage singleEmail = new Messaging.SingleEmailMessage();
                            List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();
                            //New Changes - Start
                            if(emailContentDocumentMap.containsKey(email.id) && emailContentDocumentMap.get(email.id).size() > 0) {
                                //Attachment Exists
                                for(String docId : emailContentDocumentMap.get(email.id)) {
                                    if(contentVersionMap.containsKey(docId)) {
                                        Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
                                        attach.setFileName(contentVersionMap.get(docId).pathOnClient);
                                        attach.setBody(contentVersionMap.get(docId).versionData);
                                        //attach.setContentType(contentVersionMap.get(docId).pathOnClient);
                                        attachments.add(attach);
                                        
                                        FeedAttachment feedAttachment = new FeedAttachment(recordId = contentVersionMap.get(docId).Id,
                                                                                           type = 'CONTENT'
                                                                                          );
                                        if(!caseFeedAttachments.containsKey(c.Id)) {
                                            caseFeedAttachments.put(c.Id, new List<FeedAttachment>());
                                        }
                                        caseFeedAttachments.get(c.Id).add(feedAttachment);
                                    }
                                }
                            }
                            //New Changes - End
                            Set<String> ccAddresses = new Set<String>();
                            //IBA-3454 - Commenting following changes to restrict email to Internal alias
                            /* if(String.isNotBlank(c.internal_CC_List__c)) {
                                ccAddresses.addAll(new Set<String>(c.internal_CC_List__c.split(';')));
                            } */
                            if(String.isNotBlank(c.Customer_CC_List__c)) {
                                ccAddresses.addAll(new Set<String>(c.Customer_CC_List__c.split(';')));
                            }
                            if(String.isNotBlank(c.Case_CC_List__c)) {
                                ccAddresses.addAll(new Set<String>(c.Case_CC_List__c.split(';')));
                            }
                            singleEmail.setSubject(c.caseNumber + '-'+ c.subject +' : '+email.subject);
                            singleEmail.setOrgWideEmailAddressId(orgWideEmail);
                            singleEmail.setHTMLBody(email.HtmlBody);
                            //singleEmail.setToAddresses(new List<String>{c.contactEmail});
                            singleEmail.setCcAddresses(new List<String>(ccAddresses));
                            singleEmail.setPlainTextBody(email.textBody);
                            singleEmail.setWhatId(c.id);
                            singleEmail.setTargetObjectId(c.ContactId);
                            singleEmail.setTreatTargetObjectAsRecipient(true);
                            singleEmail.setSaveAsActivity(true);
                            singleEmail.setFileAttachments(attachments);
                            emails.add(singleEmail);
                            
                            FeedItem newFI= new FeedItem(ParentId=c.id,body=email.textBody,Visibility='AllUsers');
                            caseFeedItems.put(c.id,newFI);
                        }
                    }
                }   
                if(!emails.isEmpty()) {
                    if(!Test.isRunningTest()){
                        TriggerUtility.SkipEmailMessageTriggerExecured();
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
                    //System.debug('## feedItems'+ JSON.serialize(caseFeedItems));
                    
                    List<EntityMilestone> entityMilestones = [SELECT Id, completionDate FROM EntityMilestone WHERE ParentEntityId in :caseIncidentMap.keySet() AND completionDate = null];
                    if(!entityMilestones.isEmpty()){
                        for (EntityMilestone em : entityMilestones){
                            em.completionDate = System.now();
                        }
                        update entityMilestones;
                    }
                }
            }
        }
    }

    public void finish(Database.BatchableContext bc){
        this.zscalerBatchFrameWorkObj.callFinish(bc);
        // execute any post-processing operations
    }

}