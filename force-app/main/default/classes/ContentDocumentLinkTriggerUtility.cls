/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 09-14-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class ContentDocumentLinkTriggerUtility {
   
    public static void afterInsert(List<ContentDocumentLink> newList){
        Map<String, Triggers_Switch__c> tsmap = Triggers_Switch__c.getAll();
        if(tsmap.containsKey('Execute_EmailMessageCDL_to_CaseCDL') && tsmap.get('Execute_EmailMessageCDL_to_CaseCDL') != null && tsmap.get('Execute_EmailMessageCDL_to_CaseCDL').Execute__c && !TriggerUtility.isEmailCDLtoCaseEDLExecuted()){
            createCaseCDLfromEmailCDL(newList);
        }
        if(tsmap.containsKey('Execute_Associate_CDL_With_Case') && tsmap.get('Execute_Associate_CDL_With_Case') != null && tsmap.get('Execute_Associate_CDL_With_Case').Execute__c){
            associateDocumentWithCase(newList);
        }
        //Added by Ankit - CR# 4343 - Start
        insertFeedItemWithAttachments(newList);
        //Added by Ankit - CR# 4343 - End
        //TriggerUtility.CDLAfterInsertExecuted();
        quoteSatusToGenerated(newList);
        if(tsmap.containsKey('Execute_Project_Design_Plan_Uploaded') && tsmap.get('Execute_Project_Design_Plan_Uploaded') != null && tsmap.get('Execute_Project_Design_Plan_Uploaded').Execute__c){
            updateDesignPlanOnProject(newList);
        }
        //added by Dhawal Sharda 13-07-2021 CR# 2857 Start
        if(tsmap.containsKey('Execute_Lightning_UpdateRFPRequest') && tsmap.get('Execute_Lightning_UpdateRFPRequest') != null && tsmap.get('Execute_Lightning_UpdateRFPRequest').Execute__c && !TriggerUtility.isupdateRFPRequest_lightExecuted()){
            updateRFPRequest_light(newList);
        }
        //added by Dhawal Sharda 13-07-2021 CR# 2857 End
        
    }
    
    //Added By Anup - PS Questionnaire - Start
    public static void updateDesignPlanOnProject(List<ContentDocumentLink> newList){
        
        List<Id> listOfProjectId = new List<Id>();
        Map<Id, Id> mapOfProjectAndContentDocument = new Map<Id, Id>();
        for(ContentDocumentLink cdl : newList){
            if(cdl.LinkedEntityId!= null && String.valueOf(cdl.LinkedEntityId.getSobjectType()) == 'inspire1__Project__c'){
                listOfProjectId.add(cdl.LinkedEntityId);
                mapOfProjectAndContentDocument.put(cdl.LinkedEntityId, cdl.ContentDocumentId);
            }
        }
        if(!listOfProjectId.isEmpty()){
            system.debug('listOfProjectId--->'+listOfProjectId);
            Map<Id, Set<String>> mapOfProjectIdAndAcceptedDocument = new Map<Id, Set<String>>();
            map<Id, String> mapOfIdAndFileName = new Map<Id, String>();
            List<inspire1__project__c> listOfProjectToUpdate = new List<inspire1__Project__c>();
            for(ContentDocument conD : [select id, Title from ContentDocument where Id IN:mapOfProjectAndContentDocument.values()]){
                mapOfIdAndFileName.put(conD.Id,conD.Title);
            }
            for(inspire1__Project__c project : [select id, inspire1__Account__c, inspire1__Account__r.Name, Design_Template_Uploaded__c, ZPA_Deployment__c, ZIA_Deployment__c from inspire1__Project__c where Id IN:listOfProjectId and Design_Template_Uploaded__c=false]){
                /* Set<String> acceptedFile = new Set<String>();
                String accountName = '';
                if(project.inspire1__Account__c != null){
                    accountName = project.inspire1__Account__r.Name;
                }
                String documentZIAName = 'Zscaler Initial Design Plan Document (ZIA - '+accountName+')';
                String documentZPAName = 'Zscaler Initial Design Plan Document (ZPA - '+accountName+')';
                if(project.ZPA_Deployment__c == 'Yes'){
                    acceptedFile.add(documentZPAName);
                }
                if(project.ZIA_Deployment__c == 'Yes'){
                    acceptedFile.add(documentZIAName);
}*/
                //CR #3000 Added by Chetan-Start
                List<String> listOfKeywords=new List<String>();
                String keywords=System.Label.Design_Document_Keywords;
                if(keywords !=null)
                {
                    listOfKeywords=keywords.split(';');
                    System.debug('List Of Keywords from Label-->'+ listOfKeywords);
                }
                
                if(mapOfProjectAndContentDocument.containsKey(project.Id) && mapOfProjectAndContentDocument.get(project.Id)!= null){
                    Id fileId = mapOfProjectAndContentDocument.get(project.Id);
                    if(mapOfIdAndFileName.containsKey(fileId) && mapOfIdAndFileName.get(fileId) != null){
                        String fileName = mapOfIdAndFileName.get(fileId).tolowerCase();
                        system.debug('Name of the uploaded file-->' + fileName);
                        Boolean keywordNotPresent=false;
                        for(String keyword:listOfKeywords)
                        {
                            if(!fileName.contains(keyword))
                            {
                                keywordNotPresent=true;
                            }
                        }
                        if(!listOfKeywords.isEmpty() && keywordNotPresent==false )
                        {
                            project.Design_Template_Uploaded__c = true;
                            listOfProjectToUpdate.add(project);
                        }
                    }
                }
                //CR #3000 Added by Chetan-End
            }
            if(!listOfProjectToUpdate.isEmpty()){
                update listOfProjectToUpdate;
            }
        }
    }
    //Added By Anup - PS Questionnaire - End 
    
    public static void createCaseCDLfromEmailCDL(List<ContentDocumentLink> newList){
        System.debug('--createCaseCDLfromEmailCDL--called--');
        List<ContentDocumentLink> cdllst = new List<ContentDocumentLink>();
        
        Map<ID, ID> conDocLinkIDDocID = new Map<ID,ID>(); 
        Map<Id, id> linkedEntitytoCaseIdMap = new Map<Id,Id>();
        Map<Id, id> linkedEntitytoCaseIdMapOutgoing = new Map<Id,Id>();
        
        Set<Id> linkedEntityIds = new Set<Id>();
        for(ContentDocumentLink cdl : newList){
            System.debug('--ContentDocumentLink--cdl--'+cdl);   
            if(cdl.LinkedEntityId != null && cdl.LinkedEntityId.getSobjectType() == Schema.EmailMessage.SObjectType){
                linkedEntityIds.add(cdl.LinkedEntityId);
            }
            
            if(cdl.id != null && cdl.ContentDocumentId != null ){
                conDocLinkIDDocID.put(cdl.id, cdl.ContentDocumentId);    
            }
            
        }
        if(!linkedEntityIds.isEmpty()){
            for(EmailMessage em: [Select Id, ParentId from EmailMessage where Id in :linkedEntityIds and Incoming = true and ParentId != null]){
                linkedEntitytoCaseIdMap.put(em.Id, em.ParentId);
            }
        }
        
        if(!linkedEntityIds.isEmpty()){
            //check for siemns
            for(EmailMessage em: [Select Id, ParentId from EmailMessage where Id in :linkedEntityIds and Incoming = false and ParentId != null]){
                linkedEntitytoCaseIdMapOutgoing.put(em.Id, em.ParentId);
            }
        }
        
        System.debug('--linkedEntitytoCaseIdMap--'+linkedEntitytoCaseIdMap);
        if(!linkedEntitytoCaseIdMap.isEmpty()){
            for(ContentDocumentLink cdl : newList){
                if(cdl.LinkedEntityId != null && cdl.LinkedEntityId.getSobjectType() == Schema.EmailMessage.SObjectType){
                    ContentDocumentLink newcdl = new ContentDocumentLink();
                    newcdl.Visibility = 'AllUsers';
                    newcdl.ShareType = 'I';
                    newcdl.LinkedEntityId = linkedEntitytoCaseIdMap.containsKey(cdl.LinkedEntityId) && linkedEntitytoCaseIdMap.get(cdl.LinkedEntityId) != null ? linkedEntitytoCaseIdMap.get(cdl.LinkedEntityId) : null;
                    newcdl.ContentDocumentId = cdl.ContentDocumentId;
                    cdllst.add(newcdl);
                }
            }
            System.debug('--createCaseCDLfromEmailCDL--cdllst--'+cdllst);
            insert cdllst;
        }
        
        System.debug('--linkedEntitytoCaseIdMapOutgoing--'+linkedEntitytoCaseIdMapOutgoing);
        if(!linkedEntitytoCaseIdMapOutgoing.isEmpty()){
            
            MAP<Id,ID> contentDocandVersionID = new  MAP<Id,ID>();
            for(ContentVersion cv :  [select Id,PublishStatus,FileExtension,ContentDocumentId from 
                                      ContentVersion where ContentDocumentId in :conDocLinkIDDocID.values()]){
                contentDocandVersionID.put(cv.ContentDocumentId, cv.Id);
            }
            System.debug('--contentDocandVersionID---'+contentDocandVersionID);
            
            MAP<ID,Case_Integration__c> caseIDCaseIntMAP = new MAP<ID,Case_Integration__c>();
            for(Case_Integration__c ci : [Select id,External_ID__c,Case__c from 
                                          Case_Integration__c where case__c != null and case__r.External_Reference__c != null 
                                          and Incident_Type__c = 'Incident' 
                                          and Parent_Incident__c = null and Ticket_Status__c != 'Closed' and Case_Origin__c = 'Siemens' and 
                                          case__c in : linkedEntitytoCaseIdMapOutgoing.values() order by createdDate])
            {
                caseIDCaseIntMAP.put(ci.case__c,ci);
            }
            System.debug('--caseIDCaseIntMAP---'+caseIDCaseIntMAP);
                        
            MAP<id,Case_Integration__c> patchMAP = new MAP<id,Case_Integration__c>();
            for(ContentDocumentLink cdl : newList){
                Id conetentVerID = null;
                if(cdl.ContentDocumentId != null && 
                   contentDocandVersionID.containskey(cdl.ContentDocumentId) &&
                   contentDocandVersionID.get(cdl.ContentDocumentId) != null
                  )
                {
                   conetentVerID =  contentDocandVersionID.get(cdl.ContentDocumentId);
                }
                if(conetentVerID != null && cdl.LinkedEntityId != null && 
                   cdl.LinkedEntityId.getSobjectType() == Schema.EmailMessage.SObjectType &&
                   linkedEntitytoCaseIdMapOutgoing.containskey(cdl.LinkedEntityId) &&
                   linkedEntitytoCaseIdMapOutgoing.get(cdl.LinkedEntityId) != null &&
                   caseIDCaseIntMAP.containskey(linkedEntitytoCaseIdMapOutgoing.get(cdl.LinkedEntityId))
                  )
                {
                    patchMAP.put(conetentVerID,caseIDCaseIntMAP.get(linkedEntitytoCaseIdMapOutgoing.get(cdl.LinkedEntityId)));
                }
            }
            System.debug('--ContentDocumentLinkTriggerUtility--patchMAP---'+patchMAP);
            if(patchMAP.size()>0){
                System.enqueueJob(new SiemensIncidentPatchQueue(patchMAP,true));
            }
        }
        //TriggerUtility.EmailCDLtoCaseEDLExecuted();
    }
    //added by Dhawal Sharda 13-07-2021 CR# 2857 Start
    public static void updateRFPRequest_light(List<ContentDocumentLink> newList){
        System.debug('inside update rfp request lightning');
        List<RFP_Request__c> RFPrequestlist= new List<RFP_Request__c>();
        Set<Id> RFPid = new Set<Id>();
        for(ContentDocumentLink cdl : newList){
            System.debug('--ContentDocumentLink--cdl--'+cdl);            
            if(cdl.LinkedEntityId != null && cdl.LinkedEntityId.getSobjectType() == Schema.RFP_Request__c.SObjectType){
                RFPid.add(cdl.LinkedEntityId);
            }
        }
        system.debug('RFPid '+RFPid);
        if(RFPid.size()>0){
        
            Map<id,RFP_Request__c> RFPrequestidMap= new Map<id,RFP_Request__c>([Select id,Last_upload_Document_Submitter__c,Last_upload_Document_Title__c,Email_for_Attachment_Sent__c from  RFP_Request__c where Request_Status__c='Completed' and id IN:RFPid]);
            Map<id,ContentDocumentLink> RFPdetailsidMap = new Map<id,ContentDocumentLink>([Select id,ContentDocument.title,ContentDocument.OwnerId FROM ContentDocumentLink WHERE LinkedEntityId IN:RFPid]);
            for(ContentDocumentLink cdl : newList){
                if(RFPrequestidMap.containskey(cdl.LinkedEntityId)){
                    System.debug('last submitter'+RFPdetailsidMap.get(cdl.Id).ContentDocument.OwnerId);
                    System.debug('last document name'+ RFPdetailsidMap.get(cdl.Id).ContentDocument.title);
                    RFP_Request__c RFPrqst= new RFP_Request__c(id=cdl.LinkedEntityId,Last_upload_Document_Submitter__c=RFPdetailsidMap.get(cdl.Id).ContentDocument.OwnerId,Last_upload_Document_Title__c=RFPdetailsidMap.get(cdl.Id).ContentDocument.title,Email_for_Attachment_Sent__c=true);
                    RFPrequestlist.add(RFPrqst);
                }
            }
        system.debug('RFPrequestlist '+RFPrequestlist);
        }
        if(RFPrequestlist.size()>0){
            update RFPrequestlist;
        }
        TriggerUtility.updateRFPRequest_lightExecuted();
    }
    //added by Dhawal Sharda 13-07-2021 CR# 2857 Start
    
    //Added by Ankit - CR# 4343 - Start
    public static void insertFeedItemWithAttachments(List<ContentDocumentLink> newDocLinks) {
        Map<String, List<String>> caseContentDocumentMap = new Map<String, List<String>>();
        Set<String> cDocIds = new Set<String>();
        for(ContentDocumentLink cdl : newDocLinks) {
            if(String.valueOf(cdl.LinkedEntityId).startsWith('500') && cdl.ShareType == 'V' && cdl.visibility == 'AllUsers') {
                cDocIds.add(cdl.contentDocumentId);
            }
        }
        Set<String> cDocZacBot = new Set<String>();
        if(!cDocIds.isEmpty()) {
            for(ContentDocument cDoc : [SELECT id FROM ContentDocument WHERE Id IN : cDocIds AND CreatedBy.Name = 'Zac Bot'])    {
                cDocZacBot.add(cDoc.id);
            }
            for(ContentDocumentLink cdl : newDocLinks) {
                if(cDocZacBot.contains(cdl.contentDocumentId) || Test.isRunningTest()) {
                    if(!caseContentDocumentMap.containsKey(cdl.LinkedEntityId)) {
                        caseContentDocumentMap.put(cdl.LinkedEntityId, new List<String>());
                    }
                    caseContentDocumentMap.get(cdl.LinkedEntityId).add(String.valueOf(cdl.contentDocumentId));
                }
            }
            if(!caseContentDocumentMap.isEmpty()) {
                List<FeedItem> feedItems = new List<FeedItem>();
                List<FeedAttachment> feedAttachments = new List<FeedAttachment>();
                for(Case c : [SELECT id,origin FROM Case WHERE Id IN : caseContentDocumentMap.keySet() AND origin = 'Chatbot Portal']) {
                    String postContent = '  <b>Attachments Uploaded by Customer :'+caseContentDocumentMap.get(c.id).size() + '</b><p>&nbsp;</p>\n\n';
                    feedItems.add(
                        new FeedItem(
                            title = 'Attachments added by Customer',
                            parentId = c.id,
                            visibility = 'InternalUsers',
                            isRichText = true,
                            body = postContent
                        )
                    );
                }
                if(!feedItems.isEmpty()) {
                    insert feedItems;
                }
                Map<String, List<String>> feedItemMap = new Map<String, List<String>>();
                for(FeedItem fi : feedItems) {
                    feedItemMap.put(fi.id,caseContentDocumentMap.get(fi.parentId));
                }
                Map<String, String> cvMap = new Map<String, String>();
                for(ContentVersion cv : [SELECT id,contentDocumentId FROM ContentVersion WHERE contentDocumentId IN : cDocZacBot AND IsLatest = true]) {
                    cvMap.put(cv.contentDocumentId, cv.id);
                }
                for(String feed : feedItemMap.keySet()) {
                    for(String doc : feedItemMap.get(feed)) {
                        if(cvMap.containsKey(doc)) {
                            feedAttachments.add(
                                new feedAttachment(
                                    FeedEntityId = feed,
                                    RecordId = cvMap.get(doc),
                                    Type = 'CONTENT'
                                )
                            );
                        }
                    }
                }
                if(!feedAttachments.isEmpty()) {
                    insert feedAttachments;
                }
            }
        }
    }
    //Added by Ankit - CR# 4343 - End

    //added by Rakshitha - CR#3447
    public static void quoteSatusToGenerated(List<ContentDocumentLink> newList){
        String quoteKeyPrefix  = SBQQ__Quote__c.SObjectType.getDescribe().getKeyPrefix();
        Set<Id> quoteIdList = new Set<Id>();
        Set<Id> contentDocumentList = new Set<Id>();
        Map<Id,Id> contentDocumentQuoteMap = new Map<Id,Id>();
        for(ContentDocumentLink cdl:newList){
            if(cdl.LinkedEntityId !=null){
                String recordPrefix = String.valueOf(cdl.LinkedEntityId).substring(0,3);
                if(quoteKeyPrefix == recordPrefix ){
                    contentDocumentQuoteMap.put(cdl.ContentDocumentId,cdl.LinkedEntityId);
                }
            }   
        }
        if(!contentDocumentQuoteMap.keySet().isEmpty()){
            for(ContentDocument cd:[SELECT Id,Title FROM ContentDocument where Id In :contentDocumentQuoteMap.keySet() WITH SECURITY_ENFORCED]){
                if((cd.Title.StartsWith('Quote Template') || cd.Title.StartsWith('Quote Document')) && contentDocumentQuoteMap.containsKey(cd.Id)){
                    quoteIdList.add(contentDocumentQuoteMap.get(cd.Id));
                }
            }
            if(!quoteIdList.isEmpty()) {
                List<SBQQ__Quote__c> quoteList = [SELECT Id,SBQQ__Status__c FROM SBQQ__Quote__C where Id In :quoteIdList and SBQQ__Status__c='Approved'];
                for(SBQQ__Quote__c quoteRec: quoteList){
                    quoteRec.SBQQ__Status__c ='Generated';
                }
                update as system quoteList;
            }
            
        }        
    }

    public static void associateDocumentWithCase(List<ContentDocumentLink> newList){
        //List<Id> listOfCId = new List<Id>();
        Map<Id, List<ContentDocumentLink>> mapOfCaseIntAndCDL = new Map<Id, List<ContentDocumentLink>>();
        Map<Id, Id> mapOfCaseIntVsCaseId = new Map<Id, Id>();
        for(ContentDocumentLink cdl : newList){
            if(cdl.LinkedEntityId!=null && String.valueOf(cdl.LinkedEntityId.getSobjectType()) == 'Case_Integration__c'){
                //listOfCId.add(cdl.LinkedEntityId);
                if(!mapOfCaseIntAndCDL.containsKey(cdl.LinkedEntityId)){
                    mapOfCaseIntAndCDL.put(cdl.LinkedEntityId, new List<ContentDocumentLink>());
                }
                mapOfCaseIntAndCDL.get(cdl.LinkedEntityId).add(cdl);
            }
        }

        if(mapOfCaseIntAndCDL.size()>0){
            List<ContentDocumentLink> cdlToInsert = new List<ContentDocumentLink>();
            for(Case_Integration__c csInt : [select id, Case__c, Case__r.Id, Case_Creation_Status__c from Case_Integration__c where Id IN:mapOfCaseIntAndCDL.keySet() and Case__c!=null]){
                //mapOfCaseIntVsCaseId.put(csInt.Id, csInt.Case__r.Id);
                for(ContentDocumentLink currCdl : mapOfCaseIntAndCDL.get(csInt.Id)){
                    ContentDocumentLink newcdl = new ContentDocumentLink();
                    newcdl.Visibility = 'AllUsers';
                    newcdl.ShareType = 'V';
                    newcdl.LinkedEntityId = csInt.Case__r.Id;
                    newcdl.ContentDocumentId = currCdl.ContentDocumentId;
                    cdlToInsert.add(newcdl);
                }
            }
            if(!cdlToInsert.isEmpty()){
                insert cdlToInsert;
            }
        }
    }
   
}