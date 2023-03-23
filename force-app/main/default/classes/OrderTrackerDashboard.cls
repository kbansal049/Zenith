public without sharing class OrderTrackerDashboard {
    //wrapper class for attachments/content-version
    public class relatedFile {
        public String PathOnClient;
        public String Title;
        public Blob VersionData;
        public String fileId;
    }
    
    //function to get user information
    @AuraEnabled
    public static Map<String,String> getUserInformation()
    {
        
        Id userId= UserInfo.getUserId();
        Map<String,String> userInfoMap = new Map<String,String>(); 
        List<User> userList=[SELECT Id, Username, Name, Email, Profile.Name FROM User WHERE Id=:userId LIMIT 1];
        String userProfile = userList[0].Profile.Name;
        if(!test.isRunningTest())
        { Map<String,TrackersAdminAccess__c> trackerAdminMap=TrackersAdminAccess__c.getall();
         if(trackerAdminMap.containsKey(userId))
             userProfile='System Administrator';}
        userInfoMap.put('Profile',userProfile);
        userInfoMap.put('UserId',userId);
        userInfoMap.put('Email',userList[0].Email);
        return userInfoMap;
    }
    
    //function to update status from order tracker reply screen
    @AuraEnabled
    public static void updateOrderTrackerStatusFromReply(Id parentOrderTrackerId,String changedStatusValue)
    {
        Order_Tracker__c oldOrderTracker=  [Select Id, Status__c from Order_Tracker__c where Id=:parentOrderTrackerId FOR UPDATE];
        oldOrderTracker.Status__c=changedStatusValue;
        update oldOrderTracker;
    }
    
    //function to send email without saving the attachment in salesforce
    @AuraEnabled
    public static void sendMailMethod(Map<String,String> mp,List<Map<String, Object>> files,Id parentTrackerId,String messageId,Boolean isEmailTracker) 
    {
        
        String usrEmail=getUserInformation().get('Email');
        //System.debug('ThreadId' + mp.get('ThreadId'));
        Mail_Chain__c newMailChain ;
        if(isEmailTracker == true)
        {
            Email_Tracker__c parentEmailTracker = new Email_Tracker__c(Id=parentTrackerId,isNewFlag__c=false);
            update parentEmailTracker;
            newMailChain = new Mail_Chain__c(Email_Tracker__c=parentTrackerId,To__c=mp.get('To'),CC__c=mp.get('CC'),BCC__c=mp.get('BCC'),
                                             Email_Subject__c=mp.get('Subject'),Body__c=mp.get('Body'),Message_Id__c=messageId,
                                             Date_Time_of_Email__c=System.now(),From__c=usrEmail,Thread_Id__c=mp.get('ThreadId'));      
        }
        else if(isEmailTracker == false)
        {
            Order_Tracker__c parentOrderTracker =new Order_Tracker__c(Id=parentTrackerId,isNewFlag__c=false);
            update parentOrderTracker;
            newMailChain = new Mail_Chain__c(Order_Tracker__c=parentTrackerId,To__c=mp.get('To'),CC__c=mp.get('CC'),BCC__c=mp.get('BCC'),
                                             Email_Subject__c=mp.get('Subject'),Body__c=mp.get('Body'),Message_Id__c=messageId,
                                             Date_Time_of_Email__c=System.now(),From__c=usrEmail,Thread_Id__c=mp.get('ThreadId'));           
        }
        insert newMailChain;
        
        List<ContentVersion> relatedDocuments = new List<ContentVersion>();
        List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        List<Id> idsList=new List<Id>();
        //checking for attachments 
        if(files.size()!=0)
        {
            //   system.debug('files from js' +files);
            List<Id> contentDocID = new List<Id>();
            List<ContentDocumentLink> reAttachTheFiles = new List<ContentDocumentLink>();
            
            for (Map<String, Object> file : files) 
            {
                String fileJson = JSON.serialize(file);
                relatedFile relatedDocument = (relatedFile) JSON.deserialize(fileJson, relatedFile.class);
                if(relatedDocument.fileId != null)
                {
                    //Remapp the older mail chain attachments
                    reAttachTheFiles.add(new contentDocumentLink(ContentDocumentId = relatedDocument.fileId, LinkedEntityId = newMailChain.id, ShareType = 'I'));
                    contentDocID.add(relatedDocument.fileId);
                    
                }
            }
            // insert relatedDocuments;
            insert reAttachTheFiles;
            for ( ContentVersion cversion : [SELECT title,PathOnClient, FileType,versiondata FROM contentversion WHERE ContentDocumentId in :contentDocID]) {
                idsList.add(cversion.Id);
            }
            //set attachments in email
            mail.setEntityAttachments(idsList);
        }
        
        // system.debug('mail.setFileAttachments'+attachments);
        //checking and setting reciever's email in To section
        if(!String.isEmpty(mp.get('To')))
            mail.setToAddresses(mp.get('To').split(';'));
        
        //cheking and setting reciver's email in CC Section 
        if(!String.isEmpty(mp.get('CC')))
            mail.setCCAddresses(mp.get('CC').split(';'));
        
        //cheking and setting reciver's email in BCC Section        
        if(!String.isEmpty(mp.get('BCC')))
            mail.setBccAddresses(mp.get('BCC').split(';'));
        
        //set email subject
        if(!string.isEmpty(mp.get('Subject')))
            mail.setSubject(mp.get('Subject'));
        
        //set email body
        if(!String.isEmpty(mp.get('Body')))
            mail.setHtmlBody(mp.get('Body'));
        
        mail.setReferences(messageId);
        //mail.setWhatId(newMailChain.Id);
        
        //sending email
        if(!Test.isRunningTest())
        {
            // System.debug('EMail Sent' + mail);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }); 
        }
    }
    
    
    
    //function to send email without saving the attachment in salesforce
    @AuraEnabled
    public static void sendMailNotificationMethod(Id orderTrackerId) 
    {
         System.debug('---sendMailNotificationMethod called---orderTrackerId--'+orderTrackerId);
        
        Order_Tracker__c oldOrderTracker = OrderTrackerDashboard.getOrderTracker(orderTrackerId);
        
        if(oldOrderTracker.Opportunity__c != null){
            Opportunity opp = [Select id,Account.Name,Amount,owner.email,Account.Owner.Email,Opportunity_Channel_Manager__r.Email from opportunity where id = :oldOrderTracker.Opportunity__c];
            
            EmailTemplate et = null;
            if(opp.amount > 250000){
                et=[SELECT Id, Name,Subject, HtmlValue, Body FROM EmailTemplate 
                                    Where DeveloperName = 'Order_Tracker_Email_Notification_Greater_100k'];
            }else{
                et=[SELECT Id, Name,Subject, HtmlValue, Body FROM EmailTemplate 
                                    Where DeveloperName = 'Order_Tracker_Email_Notification_Less_100k'];
            }
            // New Changes START
            Mail_Chain__c mcRecord =  getFistMailChainRecord(oldOrderTracker.id);
            List<Id> contentVersionIds = new List<Id>(getFistPOEmailAttachements(oldOrderTracker.id));
            // New Changes END
            
            List<OpportunitySplit> oppTeammemeberList = [Select id,SplitOwnerID,SplitOwner.Email,SplitOwner.Manager.Email from OpportunitySplit where OpportunityId = :opp.id];
            
            if(oppTeammemeberList.size()>0){
                
                // New Changes START, moved below line upwards(outside of if condition)
                //List<Id> contentVersionIds = new List<Id>(getFistPOEmailAttachements(oldOrderTracker.id));
                // New Changes END

                System.debug('---contentVersionIds---'+contentVersionIds);
                
                // New Changes START, moved below line upwards(outside of if condition)
                //Mail_Chain__c mcRecord =  getFistMailChainRecord(oldOrderTracker.id);
                // New Changes END
                
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                //Set Subject
                mail.setSubject(et.Subject);
                
                //Set Attachments
                if(!contentVersionIds.isEmpty())       
                    mail.setEntityAttachments(contentVersionIds);
                
                //Set To
                Set<String> toEmails = new Set<String> {opp.owner.email};
                   
                
                //Set CC
                for(OpportunitySplit oppMem : oppTeammemeberList){
                    if(oppMem.SplitOwner != NULL && oppMem.SplitOwner.Email != NULL){
                        toEmails.add(oppMem.SplitOwner.Email);
                    }
                    if(oppMem.SplitOwner.Manager != null && oppMem.SplitOwner.Manager.Email != null){
                        toEmails.add(oppMem.SplitOwner.Manager.Email);
                    }
                }
                if(opp.Account.Owner.Email != NULL){
                    toEmails.add(opp.Account.Owner.Email);
                }
                if(opp.Opportunity_Channel_Manager__r.Email != NULL){
                    toEmails.add(opp.Opportunity_Channel_Manager__r.Email);
                }
                
                List<String> toEmailList = new List<String>(toEmails);
                
                
                 if(!toEmails.isEmpty())
                    mail.setToAddresses(toEmailList);
                
                
                //if(!ccEmailList.isEmpty())
                   //mail.setCCAddresses(ccEmailList);
                
                
                //Configure Body
                String emailBody = et.HtmlValue;
                emailBody = emailBody.Replace('{{TICKET#}}', oldOrderTracker.Ticket__c);
                emailBody = emailBody.Replace('{{ACC_NAME}}', opp.Account.Name);
                emailBody = emailBody.Replace('{{OPP_LINK}}', URL.getSalesforceBaseUrl().toExternalForm()+'/'+opp.Account.Id);
                emailBody = emailBody.Replace('{{THREAD_ID}}', '{['+oldOrderTracker.Thread_ID__c+']}');
                
                emailBody = emailBody+'<br>'+'<br>';
                emailBody = emailBody+'------------ Forwarded message ---------';
                emailBody = emailBody+'<br>';
                emailBody = emailBody+'From: '+ mcRecord.From__c+'<br>';
                emailBody = emailBody+'Date: '+ mcRecord.Date_Time_of_Email__c+'<br>';
                emailBody = emailBody+'Subject: '+ mcRecord.Email_Subject__c  +'<br>';
                emailBody = emailBody+'To: '+ mcRecord.To__c+'<br>'+'<br>';
                emailBody = emailBody+mcRecord.Body__c;
                
                mail.setHtmlBody(emailBody);
                
                //Set reference
                System.debug('--oldOrderTracker.Message_Id__c--'+oldOrderTracker.Message_Id__c);
                if(oldOrderTracker.Message_Id__c != null){
                    mail.setReferences(oldOrderTracker.Message_Id__c);
                }
                
                System.debug('----mail---'+mail);
                
                //sending email
                if(!Test.isRunningTest()){
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }); 
                }
            }

            // New Changes START
            attachMailChainDocumentsToOpportunity(mcRecord, opp);

            List<ContentVersion> contentVersionListToUpdate = new List<ContentVersion>();
            for (Id contentVersionId : contentVersionIds) {
                ContentVersion contentVerionToUpdate = new ContentVersion(Id = contentVersionId, Source_fileupload__c = 'PO_Document');
                contentVersionListToUpdate.add(contentVerionToUpdate);
            }

            if (!contentVersionListToUpdate.isEmpty()) {
                update contentVersionListToUpdate;
            }

            TriggerHandler.bypass('OpportunityTriggerHandler');
            Opportunity opportunityToUpdate = new Opportunity(Id = opp.Id, PO_Attached__c = true);
            update opportunityToUpdate;
            // New Changes END
        }
    }
    
    // New Changes START
    private static void attachMailChainDocumentsToOpportunity(Mail_Chain__c mailChainRecord, Opportunity opportunityRecord) {
        if (mailChainRecord != null && opportunityRecord != null) {
            List<ContentDocumentLink> contentDocumentLinksList = getAssociatedContentLinkDocuments(new Set<Id> {mailChainRecord.Id});
            List<ContentDocumentLink> contentDocumentLinksListToInsert = new List<ContentDocumentLink>();
            Set<String> fileExtensionsToDiscard = new Set<String> {'JPG', 'JPEG', 'PNG'};

            for (ContentDocumentLink currentCDL : contentDocumentLinksList) {
                ContentDocumentLink newCDL = new ContentDocumentLink();
                if (currentCDL.ContentDocument.FileExtension != null && !fileExtensionsToDiscard.contains(currentCDL.ContentDocument.FileExtension.toUpperCase())) {
                    newCDL.ContentDocumentId = currentCDL.ContentDocumentId;
                    newCDL.LinkedEntityId = opportunityRecord.Id;
                    newCDL.ShareType = 'V';
                    newCDL.Visibility = 'AllUsers';
    
                    contentDocumentLinksListToInsert.add(newCDL);   
                }
            }
            if (!contentDocumentLinksListToInsert.isEmpty()) {
                insert contentDocumentLinksListToInsert;
            }
        }
    }

    private static List<ContentDocumentLink> getAssociatedContentLinkDocuments(Set<Id> linkedEntitiyIdsSet) {
        return linkedEntitiyIdsSet.isEmpty() ? new List<ContentDocumentLink>() :
            [SELECT Id, ContentDocumentId, LinkedEntityId, ShareType, Visibility, ContentDocument.FileExtension FROM ContentDocumentLink WHERE LinkedEntityId IN: linkedEntitiyIdsSet];
    }
    // New Changes END
    
     public static Mail_Chain__c getFistMailChainRecord(id orderTrackerID){
        Mail_Chain__c mcRecord = null;
        for(Order_Tracker__c ot : [SELECT Id,Name,(SELECT Id, Name,From__c,To__c,Date_Time_of_Email__c,Email_Subject__c,Body__c from Mail_Chain__r order by CreatedDate ASC LIMIT 1) FROM Order_Tracker__c where id  = :orderTrackerID]){
            if(ot.Mail_Chain__r != null && ot.Mail_Chain__r.size()>0){
                mcRecord =  ot.Mail_Chain__r[0];
            }
        }
        return mcRecord;
    }
    
    public static Set<ID> getFistPOEmailAttachements(id orderTrackerID){
        Set<id> contentVerIDs = new Set<ID>();
        
        Set<ID> mailChainList = new  Set<ID>();
        for(Order_Tracker__c ot : [SELECT Id,Name,(SELECT Id, Name from Mail_Chain__r order by CreatedDate ASC LIMIT 1) FROM Order_Tracker__c where id  = :orderTrackerID]){
            if(ot.Mail_Chain__r != null && ot.Mail_Chain__r.size()>0){
                mailChainList.add(ot.Mail_Chain__r[0].Id);   
            }
        }
        System.debug('--mailChainList---'+mailChainList);
        if(mailChainList.size()>0){
            Set<id> contentDocIDs = new Set<ID>();
            List<ContentDocumentLink> cdls = [SELECT ContentDocumentId,LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN: mailChainList];
            for (ContentDocumentLink cdl : cdls) {
                contentDocIDs.add(cdl.ContentDocumentId);
            }
            
            MAP<Id,ContentVersion> relatedDocumentList= new MAP<Id,ContentVersion>([SELECT Id, Title, PathOnClient, FirstPublishLocationId FROM ContentVersion where ContentDocumentId IN:contentDocIDs order by CreatedDate]);
            contentVerIDs = relatedDocumentList.keyset();
        }
        System.debug('--contentVerIDs---'+contentVerIDs);
        return contentVerIDs;
    }
    
    
    
    //function to get searched records for previous and next page
    @AuraEnabled
    public static object getNextOrderTrackers(Integer pageNumber,Integer pageLimit,String selectedTab,
                                              String viewPicklistValue, String searchedPONumber,String searchedSONumber,
                                              String searchedEmailSubject,String searchedTicketValue,String searchedProposalValue, 
                                              String selectedSourcevalue,String universalSearchValue, String searchedEmailTicket)
    { 
        System.debug('viewPicklistValue' + viewPicklistValue); 
        Map<String,String> userMap = new Map<String,String>();
        userMap=OrderTrackerDashboard.getUserInformation();
        String userId=userMap.get('UserId');
        
        String viewValue=viewPicklistValue;
        Integer off = (pageNumber - 1) * pageLimit;
        Integer recordEnd = pageLimit * pageNumber;
        Integer totalOrderTrackerRecords=[Select COUNT() From Order_tracker__c];
        
        System.debug('viewValue' + viewValue); 
        System.debug('selectedTab' + selectedTab); 
        String query = 'SELECT  PO_Detail__c,PO_Detail__r.Id,PO_Detail__r.Name,PO_Detail__r.Source__c,Source__c,Mail_Forwarded__c,From__c, Id,Name, Ticket__c, PO__c, Email_Subject__c,isNewFlag__c, Status__c,Customer_ID__c,All_SFDC_Processses_Updated__c, Region__c,Received_Date__c,Partner__c, Order_Type__c, End_User__c, Checking_OP_Rep_QC_Rep__c, Processing_OP_Rep__c, OP_Rep_Following_Up__c, Final_Approver__c, SO__c,ACV__c, PO_Amount__c, X1st_Billing_Amount_USD__c,Attachment_on_NS_SF__c, Billing_Frequency__c, ZA_Updated__c, confirm_all_dependant_PRs_moved_to_prod__c, Proposal_for_initiating_QC__c, BOT_Auto_QC_Done__c, BOT_Re_QC_Required__c, NS_Integration_Status__c, Remarks__c, TAT_QC_Check__c, TAT_Order_Approval__c, TAT_Billing__c,Primary_Ticket_Number__c,Total_Remainder_Count__c,Last_Remainder_TimeStamp__c FROM Order_Tracker__c';                
        if(selectedTab == 'Assigned To Me')
        {
            searchedPONumber = '%'+ searchedPONumber +'%';
            searchedSONumber = '%'+ searchedSONumber + '%';
            searchedEmailSubject = '%'+ searchedEmailSubject +'%';
            searchedTicketValue = '%'+ searchedTicketValue+ '%';
            searchedProposalValue = '%'+ searchedProposalValue + '%';
            searchedEmailTicket = '%' + searchedEmailTicket + '%';
            if(String.isNotBlank(universalSearchValue)){
                Set<Id> setOfOTTIds = new Set<Id>();
                For(Order_Tracker__c OTT : [SELECT Id, Name, Body__c FROM Order_Tracker__c WHERE Checking_OP_Rep_QC_Rep__c=:userId OR Processing_OP_Rep__c = :userId OR OP_Rep_Following_Up__c = :userId OR Final_Approver__c = :userId]){
                    if(OTT.Body__c!=null && OTT.Body__c.contains(universalSearchValue)) {
                        setOfOTTIds.add(OTT.Id);
                    }
                }
                universalSearchValue = '%'+ universalSearchValue + '%';
                totalOrderTrackerRecords=[Select COUNT() From Order_tracker__c WHERE  (ID =:setOfOTTIds OR PO__c Like :universalSearchValue OR Ticket__c Like :universalSearchValue OR SO__c Like :universalSearchValue OR Email_Subject__c Like :universalSearchValue OR Proposal_for_initiating_QC__c Like :universalSearchValue OR Source__c =:universalSearchValue OR Email_Subject__c Like :universalSearchValue OR Primary_Ticket_Number__c Like :universalSearchValue)  AND (Checking_OP_Rep_QC_Rep__c=:userId OR Processing_OP_Rep__c = :userId OR OP_Rep_Following_Up__c = :userId OR Final_Approver__c = :userId)];
                query=query+' WHERE  (ID =:setOfOTTIds OR PO__c Like :universalSearchValue OR SO__c Like :universalSearchValue OR Ticket__c Like :universalSearchValue OR Email_Subject__c Like :universalSearchValue OR Proposal_for_initiating_QC__c Like :universalSearchValue OR Source__c =:universalSearchValue OR Email_Subject__c Like :universalSearchValue OR Primary_Ticket_Number__c Like :universalSearchValue) AND (Checking_OP_Rep_QC_Rep__c=:userId OR Processing_OP_Rep__c = :userId OR OP_Rep_Following_Up__c = :userId OR Final_Approver__c = :userId) ';
            }

            else if(viewValue=='All' && selectedSourcevalue == 'All')
            {
                totalOrderTrackerRecords=[Select COUNT() From Order_tracker__c WHERE  (PO__c Like :searchedPONumber OR Ticket__c Like :searchedEmailTicket OR SO__c Like :searchedSONumber OR Email_Subject__c Like :searchedEmailTicket OR Primary_Ticket_Number__c Like :searchedEmailTicket OR  Proposal_for_initiating_QC__c Like :searchedProposalValue)  AND (Checking_OP_Rep_QC_Rep__c=:userId OR Processing_OP_Rep__c = :userId OR OP_Rep_Following_Up__c = :userId OR Final_Approver__c = :userId)];
                query=query+' WHERE  (PO__c Like :searchedPONumber OR SO__c Like :searchedSONumber OR Ticket__c Like :searchedEmailTicket OR Email_Subject__c Like :searchedEmailTicket OR Primary_Ticket_Number__c Like :searchedEmailTicket OR Proposal_for_initiating_QC__c Like :searchedProposalValue) AND (Checking_OP_Rep_QC_Rep__c=:userId OR Processing_OP_Rep__c = :userId OR OP_Rep_Following_Up__c = :userId OR Final_Approver__c = :userId) ';
                
            }
            else if(viewValue=='All' && selectedSourcevalue != 'All'){
                totalOrderTrackerRecords=[Select COUNT() From Order_tracker__c WHERE  Source__c =:selectedSourcevalue AND (PO__c Like :searchedPONumber OR Ticket__c Like :searchedEmailTicket OR Primary_Ticket_Number__c Like :searchedEmailTicket OR SO__c Like :searchedSONumber OR Email_Subject__c Like :searchedEmailTicket OR Proposal_for_initiating_QC__c Like :searchedProposalValue)  AND (Checking_OP_Rep_QC_Rep__c=:userId OR Processing_OP_Rep__c = :userId OR OP_Rep_Following_Up__c = :userId OR Final_Approver__c = :userId)];
                query=query+' WHERE Source__c =:selectedSourcevalue AND  (PO__c Like :searchedPONumber OR SO__c Like :searchedSONumber OR Ticket__c Like :searchedEmailTicket OR Primary_Ticket_Number__c Like :searchedEmailTicket OR Email_Subject__c Like :searchedEmailTicket OR Proposal_for_initiating_QC__c Like :searchedProposalValue) AND (Checking_OP_Rep_QC_Rep__c=:userId OR Processing_OP_Rep__c = :userId OR OP_Rep_Following_Up__c = :userId OR Final_Approver__c = :userId) ';
            }
            else if(viewValue !='All' && selectedSourcevalue != 'All'){
                totalOrderTrackerRecords=[Select COUNT() From Order_tracker__c WHERE Status__c = :viewValue AND Source__c =:selectedSourcevalue AND (PO__c Like :searchedPONumber OR Ticket__c Like :searchedEmailTicket OR Primary_Ticket_Number__c Like :searchedEmailTicket OR SO__c Like :searchedSONumber OR Email_Subject__c Like :searchedEmailTicket OR Proposal_for_initiating_QC__c Like :searchedProposalValue OR Source__c =:selectedSourcevalue)  AND (Checking_OP_Rep_QC_Rep__c=:userId OR Processing_OP_Rep__c = :userId OR OP_Rep_Following_Up__c = :userId OR Final_Approver__c = :userId)];
                query=query+' WHERE Status__c = :viewValue AND Source__c =:selectedSourcevalue AND  (PO__c Like :searchedPONumber OR SO__c Like :searchedSONumber OR Ticket__c Like :searchedEmailTicket OR Email_Subject__c Like :searchedEmailTicket OR Primary_Ticket_Number__c Like :searchedEmailTicket OR  Proposal_for_initiating_QC__c Like :searchedProposalValue OR Source__c =:selectedSourcevalue) AND (Checking_OP_Rep_QC_Rep__c=:userId OR Processing_OP_Rep__c = :userId OR OP_Rep_Following_Up__c = :userId OR Final_Approver__c = :userId) '; 
            }
            else if(viewValue !='All' && selectedSourcevalue == 'All'){
                totalOrderTrackerRecords=[Select COUNT() From Order_tracker__c WHERE Status__c = :viewValue AND  (PO__c Like :searchedPONumber OR Ticket__c Like :searchedEmailTicket OR SO__c Like :searchedSONumber OR Email_Subject__c Like :searchedEmailTicket OR Primary_Ticket_Number__c Like :searchedEmailTicket OR Proposal_for_initiating_QC__c Like :searchedProposalValue)  AND (Checking_OP_Rep_QC_Rep__c=:userId OR Processing_OP_Rep__c = :userId OR OP_Rep_Following_Up__c = :userId OR Final_Approver__c = :userId)];
                query=query+' WHERE Status__c = :viewValue AND   (PO__c Like :searchedPONumber OR SO__c Like :searchedSONumber OR Ticket__c Like :searchedEmailTicket OR Email_Subject__c Like :searchedEmailTicket OR Primary_Ticket_Number__c Like :searchedEmailTicket OR Proposal_for_initiating_QC__c Like :searchedProposalValue) AND (Checking_OP_Rep_QC_Rep__c=:userId OR Processing_OP_Rep__c = :userId OR OP_Rep_Following_Up__c = :userId OR Final_Approver__c = :userId) '; 
            }
        }
        
        else if(selectedTab == 'All')
        { 
            searchedPONumber = '%'+ searchedPONumber +'%';
            searchedSONumber = '%'+ searchedSONumber + '%';
            searchedEmailSubject = '%'+ searchedEmailSubject +'%';
            searchedTicketValue = '%'+ searchedTicketValue+ '%';
            searchedProposalValue = '%'+ searchedProposalValue + '%';
            searchedEmailTicket = '%' + searchedEmailTicket + '%';
            if(String.isNotBlank(universalSearchValue)){
                Set<Id> setOfOTTIds = new Set<Id>();
                For(Order_Tracker__c OTT : [SELECT Id, Name, Body__c FROM Order_Tracker__c]){
                    if(OTT.Body__c!=null && OTT.Body__c.contains(universalSearchValue)) {
                        setOfOTTIds.add(OTT.Id);
                    }
                }
                universalSearchValue = '%'+ universalSearchValue + '%';
                totalOrderTrackerRecords=[Select COUNT() From Order_tracker__c WHERE ID =:setOfOTTIds OR PO__c Like :universalSearchValue OR Ticket__c Like :universalSearchValue OR SO__c Like :universalSearchValue OR Email_Subject__c Like :universalSearchValue OR Proposal_for_initiating_QC__c Like :universalSearchValue OR Source__c Like :universalSearchValue OR Email_Subject__c Like :universalSearchValue OR Primary_Ticket_Number__c Like :universalSearchValue];
                query=query+' WHERE ID =:setOfOTTIds OR PO__c Like :universalSearchValue OR SO__c Like :universalSearchValue OR Ticket__c Like :universalSearchValue OR Email_Subject__c Like :universalSearchValue OR Proposal_for_initiating_QC__c Like :universalSearchValue OR Source__c Like :universalSearchValue OR Email_Subject__c Like :universalSearchValue OR Primary_Ticket_Number__c Like :universalSearchValue ';
            }

            else if(viewValue=='All' && selectedSourcevalue == 'All')
            {
                totalOrderTrackerRecords=[Select COUNT() From Order_tracker__c WHERE PO__c Like :searchedPONumber OR Ticket__c Like :searchedEmailTicket OR Primary_Ticket_Number__c Like :searchedEmailTicket OR  SO__c Like :searchedSONumber OR Email_Subject__c Like :searchedEmailTicket OR Proposal_for_initiating_QC__c Like :searchedProposalValue];
                query=query+' WHERE PO__c Like :searchedPONumber OR SO__c Like :searchedSONumber OR Ticket__c Like :searchedEmailTicket OR Email_Subject__c Like :searchedEmailTicket OR Primary_Ticket_Number__c Like :searchedEmailTicket OR Proposal_for_initiating_QC__c Like :searchedProposalValue ';
                
            }
            else if(viewValue=='All' && selectedSourcevalue != 'All'){
                totalOrderTrackerRecords=[Select COUNT() From Order_tracker__c WHERE Source__c =:selectedSourcevalue AND (PO__c Like :searchedPONumber OR Ticket__c Like :searchedEmailTicket OR Primary_Ticket_Number__c Like :searchedEmailTicket OR SO__c Like :searchedSONumber OR Email_Subject__c Like :searchedEmailTicket OR Proposal_for_initiating_QC__c Like :searchedProposalValue)];
                query=query+' WHERE  Source__c =:selectedSourcevalue AND (PO__c Like :searchedPONumber OR SO__c Like :searchedSONumber OR Ticket__c Like :searchedEmailTicket OR Email_Subject__c Like :searchedEmailTicket OR Primary_Ticket_Number__c Like :searchedEmailTicket OR Proposal_for_initiating_QC__c Like :searchedProposalValue) ';
            }
            else if(viewValue !='All' && selectedSourcevalue != 'All'){ 
                totalOrderTrackerRecords=[Select COUNT() From Order_tracker__c WHERE  Status__c = :viewValue AND Source__c =:selectedSourcevalue AND (PO__c Like :searchedPONumber OR Ticket__c Like :searchedEmailTicket OR Primary_Ticket_Number__c Like :searchedEmailTicket OR SO__c Like :searchedSONumber OR Email_Subject__c Like :searchedEmailTicket OR Proposal_for_initiating_QC__c Like :searchedProposalValue)];
                query=query+' WHERE  Status__c = :viewValue AND Source__c =:selectedSourcevalue AND (PO__c Like :searchedPONumber OR SO__c Like :searchedSONumber OR Ticket__c Like :searchedEmailTicket OR Email_Subject__c Like :searchedEmailTicket OR Primary_Ticket_Number__c Like :searchedEmailTicket OR Proposal_for_initiating_QC__c Like :searchedProposalValue) ';
    
            }
            else if(viewValue !='All' && selectedSourcevalue == 'All'){
                totalOrderTrackerRecords=[Select COUNT() From Order_tracker__c WHERE  Status__c = :viewValue AND (PO__c Like :searchedPONumber OR Ticket__c Like :searchedEmailTicket OR Primary_Ticket_Number__c Like :searchedEmailTicket OR SO__c Like :searchedSONumber OR Email_Subject__c Like :searchedEmailTicket OR Proposal_for_initiating_QC__c Like :searchedProposalValue)];
                query=query+' WHERE  Status__c = :viewValue AND (PO__c Like :searchedPONumber OR SO__c Like :searchedSONumber OR Ticket__c Like :searchedEmailTicket OR Email_Subject__c Like :searchedEmailTicket OR Primary_Ticket_Number__c Like :searchedEmailTicket OR Proposal_for_initiating_QC__c Like :searchedProposalValue OR Source__c =:selectedSourcevalue) ';
            }
        }
        
        query=query + ' ORDER BY isNewFlag__c DESC, Latest_Mail_Date__c DESC NULLS LAST LIMIT :pageLimit OFFSET :off';
        
        Map<String,Object> response = new Map<String,Object>();
        list<Order_Tracker__c> orderTrackerList = Database.query(query);  
        
        Set<Id> ordertrackerIds = new Set<Id>();
        List<Object> attachmentList = new List<Object>();
        for(Order_Tracker__c ot:orderTrackerList)
        {
            ordertrackerIds.add(ot.Id);
        }
        attachmentList=OrderTrackerDashboard.getRelatedAttachments(ordertrackerIds);
        
        response.put('pageLimit',pageLimit);
        response.put('pageNumber',pageNumber);
        response.put('recordStart',off + 1);
        response.put('recordEnd',totalOrderTrackerRecords >= recordEnd ? recordEnd : totalOrderTrackerRecords);
        response.put('totalOrderTrackerRecords',totalOrderTrackerRecords);
        response.put('orderTrackerList',orderTrackerList);
        response.put('mailChainMAP',getFistMailChainMAP(ordertrackerIds));
        response.put('poFileAttachments',getFistPOMAP(ordertrackerIds));
        if(!attachmentList.isEmpty())
            response.put('attachments',attachmentList);
        return response;
    }
    
    
    
    
    public static object getFistPOMAP(Set<Id> ordertrackerIds){
        MAP<ID, object> returnMAP = new  MAP<ID, object>();
        
        MAP<ID, ID> mailChainMAP = new  MAP<ID, ID>();
        for(Order_Tracker__c ot : [SELECT Id,Name,(SELECT Id, Name from Mail_Chain__r order by CreatedDate ASC LIMIT 1) FROM Order_Tracker__c where id in :ordertrackerIds]){
            if(ot.Mail_Chain__r != null && ot.Mail_Chain__r.size()>0){
                mailChainMAP.put(ot.Mail_Chain__r[0].Id, ot.id);   
            }
        }
        
        System.debug('--mailChainMAP---'+mailChainMAP);
        
        if(mailChainMAP.size()>0){
            
            List<ContentDocumentLink> cdls = [SELECT ContentDocumentId,LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN: mailChainMAP.keyset()];
            
            
            Set<id> contentDocIDs = new Set<ID>();
            Map<ID,List<ID>> mChainIdDocuIdMap = new Map<ID,List<ID>>();
            
            for (ContentDocumentLink cdl : cdls) {
                
                List<ID> cdIdList = mChainIdDocuIdMap.containskey(cdl.LinkedEntityId) ? mChainIdDocuIdMap.get(cdl.LinkedEntityId)  : new List<ID>();
                cdIdList.add(cdl.ContentDocumentId);
                mChainIdDocuIdMap.put(cdl.LinkedEntityId,cdIdList);
                
                contentDocIDs.add(cdl.ContentDocumentId);
            }
            
            System.debug('--mChainIdDocuIdMap---'+mChainIdDocuIdMap);
            System.debug('--contentDocIDs---'+contentDocIDs);
            
            
            MAP<ID,ContentDocument> attachmentMAP = new MAP<ID,ContentDocument>([SELECT Id,Title,FileType,FileExtension FROM ContentDocument WHERE Id  IN:contentDocIDs ORDER BY LastModifiedDate desc]);
            
            System.debug('--attachmentMAP---'+attachmentMAP);
            
            for(id mailChainid : mailChainMAP.keyset()){
                id ottId = mailChainMAP.get(mailChainid);
                if(ottId != null && mChainIdDocuIdMap.containskey(mailChainid)){
                    List<Object> ottFirstMailChainAttachList = new List<Object>();
                    for(id cdid : mChainIdDocuIdMap.get(mailChainid) ){
                        if(attachmentMAP.containsKey(cdid)){
                            ContentDocument conDoc = attachmentMAP.get(cdid);
                            if(conDoc != null && conDoc.Title != null && conDoc.FileExtension != null){
                                ottFirstMailChainAttachList.add(getAattachmentMAP( conDoc));
                            }
                        }
                    }
                    returnMAP.put(ottId, ottFirstMailChainAttachList);
                }
            }
        }
        return returnMAP;
    }
    
    
    public static MAP<ID, ID> getFistMailChainMAP(Set<Id> ordertrackerIds){
        MAP<ID, ID> mailChainMAP = new  MAP<ID, ID>();
        for(Order_Tracker__c ot : [SELECT Id,Name,(SELECT Id, Name from Mail_Chain__r order by CreatedDate ASC LIMIT 1) FROM Order_Tracker__c where id in :ordertrackerIds]){
            if(ot.Mail_Chain__r != null && ot.Mail_Chain__r.size()>0){
                mailChainMAP.put(ot.id,ot.Mail_Chain__r[0].Id);   
            }
        }
        return mailChainMAP;
    }
    
    
    @testVisible
    private static MAP<String,String> getAattachmentMAP(ContentDocument cd){
        Map<String,String> mapOfAttachment=new Map<String,String>();
        mapOfAttachment.put('fileId',cd.Id);
        if((cd.Title).contains((cd.FileExtension).toLowercase()) || cd.FileExtension=='UNKNOWN'){
            mapOfAttachment.put('fileTitle',cd.Title);
        }
        else{
            mapOfAttachment.put('fileTitle',cd.Title + '.' + cd.FileExtension);
        }
        return mapOfAttachment;
    }
    
    
    //function to get metadata picklists
    @AuraEnabled
    public static object getMetadataPicklists()
    {
        map<string,object> response=new Map<string,object>();
        response.put('processing op rep',[SELECT Id, Label, User_Id__c FROM Order_Tracker_Processing_OP_Rep__mdt]);
        response.put('op rep following up',[SELECT Id, Label, User_Id__c FROM Order_Tracker_OP_Rep_Following_Up__mdt]);
        response.put('final approver',[SELECT Id, Label, User_Id__c FROM Order_Tracker_Final_Approver__mdt]);
        response.put('checking op rep',[SELECT Id, Label, User_Id__c FROM Order_Tracker_Checking_OP_Rep__mdt]);
        return response;
    }
    
    //function to get order tracker
    @AuraEnabled
    public static Order_Tracker__c getOrderTracker(Id orderTrackerId)
    {
        return ([SELECT Id,Message_Id__c,Thread_ID__c,Opportunity__c,Ticket__c,Name, PO__c, Email_Subject__c,isNewFlag__c, Status__c, Region__c, Received_Date__c,Customer_ID__c,Attachment_on_NS_SF__c,
                 Partner__c, Checking_OP_Rep_QC_Rep__c, Processing_OP_Rep__c,OP_Rep_Following_Up__c, Final_Approver__c,
                 Order_Type__c, End_User__c, SO__c, ACV__c, PO_Amount__c,X1st_Billing_Amount_USD__c,All_SFDC_Processses_Updated__c,
                 Billing_Frequency__c, ZA_Updated__c, confirm_all_dependant_PRs_moved_to_prod__c, Proposal_for_initiating_QC__c,
                 BOT_Auto_QC_Done__c, BOT_Re_QC_Required__c, NS_Integration_Status__c, Remarks__c, TAT_QC_Check__c, TAT_Order_Approval__c, 
                 TAT_Billing__c, Primary_Ticket_Number__c,
                 PO_Detail__c,PO_Detail__r.Id,PO_Detail__r.Name,PO_Detail__r.Source__c,
                 Source__c,Mail_Forwarded__c,From__c
                 FROM Order_Tracker__c where id=:orderTrackerId]);       
    }
    
    //function to update order tracker when certain picklist values are changed    
    @AuraEnabled
    public static object updateOrderTracker(Id orderTrackerId,String changedPicklistValue,String selectedPickListValue)
    {
        
        Order_Tracker__c oldOrderTracker= new Order_Tracker__c();
        oldOrderTracker.Id=orderTrackerId;
        if(selectedPickListValue == 'All SFDC Processes Updated')
            oldOrderTracker.All_SFDC_Processses_Updated__c=changedPicklistValue;
        else if(selectedPickListValue == 'Attachment on NS and SF')
            oldOrderTracker.Attachment_on_NS_SF__c=changedPicklistValue;
        else if(selectedPickListValue == 'Bot Auto QC done')
        {
            oldOrderTracker.BOT_Auto_QC_Done__c=changedPicklistValue;
        }
        
        else if(selectedPickListValue == 'Bot Re QC Required')
            oldOrderTracker.BOT_Re_QC_Required__c=changedPicklistValue;
        else if(selectedPickListValue == 'Checking OP Rep/QC Rep')
            oldOrderTracker.Checking_OP_Rep_QC_Rep__c=changedPicklistValue;
        else if(selectedPickListValue == 'Confirm if all dependent PRs are moved to Production')
            oldOrderTracker.confirm_all_dependant_PRs_moved_to_prod__c=changedPicklistValue;
        else if(selectedPickListValue == 'Final Approver')
            oldOrderTracker.Final_Approver__c=changedPicklistValue;
        else if(selectedPickListValue == 'OP Rep Following Up')
            oldOrderTracker.OP_Rep_Following_Up__c=changedPicklistValue;
        else if(selectedPickListValue == 'Processing OP Rep')
            oldOrderTracker.Processing_OP_Rep__c=changedPicklistValue;
        else if(selectedPickListValue == 'Status')
            oldOrderTracker.Status__c=changedPicklistValue;
        else if(selectedPickListValue == 'ZA Updated')
            oldOrderTracker.ZA_Updated__c=changedPicklistValue;
        else if(selectedPickListValue == 'Billing Frequency')
            oldOrderTracker.Billing_Frequency__c=changedPicklistValue; 
        else if(selectedPickListValue == 'Region')
            oldOrderTracker.Region__c=changedPicklistValue;
        else if(selectedPickListValue == 'Order Type')
            oldOrderTracker.Order_Type__c=changedPicklistValue;
        else if(selectedPickListValue == 'Mail Forwarded')
            oldOrderTracker.Mail_Forwarded__c=changedPicklistValue;
        
        
        update oldOrderTracker;
        
        
        oldOrderTracker=OrderTrackerDashboard.getOrderTracker(orderTrackerId);
        Map<String,Object> response = new Map<String,Object>();
        if(oldOrderTracker.BOT_Auto_QC_Done__c == 'Yes')
        {             
            Set<Id> ordertrackerIds = new Set<Id>();
            List<Object> attachmentList = new List<Object>();
            ordertrackerIds.add(oldOrderTracker.Id);
            attachmentList=OrderTrackerDashboard.getRelatedAttachments(ordertrackerIds); 
            response.put('updatedorderTracker',oldOrderTracker);
            if(!attachmentList.isEmpty())
                response.put('attachments',attachmentList);
        }
        else
        {
            response.put('updatedorderTracker',oldOrderTracker);
        }
        // system.debug('response'+response);
        
        return response;
    }
    
    
    public static List<Object> getRelatedAttachments(Set<id> ordertrackerIds)
    {
        List<Object> attachmentList = new List<Object>();
        if(!ordertrackerIds.isEmpty()){
            
            List<ContentDocumentLink> cdls = [SELECT ContentDocumentId,LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN: ordertrackerIds];
            Set<Id> documentIds = new Set<Id>();
            Map<String,String> mChainIdDocuIdMap = new Map<String,String>();
            for (ContentDocumentLink cdl : cdls) 
            {
                mChainIdDocuIdMap.put(cdl.ContentDocumentId,cdl.LinkedEntityId);
            }
            List<ContentDocument> attachments = [SELECT Id,Title,FileType,FileExtension FROM ContentDocument WHERE Id  IN:mChainIdDocuIdMap.keySet() ORDER BY LastModifiedDate desc];
            
            
            for(ContentDocument cd: attachments)
            {
                Map<String,String> mapOfAttachment=new Map<String,String>();
                mapOfAttachment.put('orderTrackerId',mChainIdDocuIdMap.get(cd.Id));
                mapOfAttachment.put('fileId',cd.Id);
                if((cd.Title).contains((cd.FileExtension).toLowercase()) || cd.FileExtension=='UNKNOWN'){
                    mapOfAttachment.put('fileTitle',cd.Title);
                }
                else{
                    mapOfAttachment.put('fileTitle',cd.Title + '.' + cd.FileExtension);
                }
                attachmentList.add(mapOfAttachment);
            }
            
        }
        return attachmentList;
    }
    
    
    //function to update order tracker when remarks field is edited
    @AuraEnabled
    public static Order_Tracker__c editRemarksofOrderTracker(Id orderTrackerId,String newRemarksValue)
    {
        Order_Tracker__c oldOrderTracker= new Order_Tracker__c();
        oldOrderTracker.Id=orderTrackerId;
        oldOrderTracker.Remarks__c=newRemarksValue;
        update oldOrderTracker;
        oldOrderTracker=OrderTrackerDashboard.getOrderTracker(orderTrackerId);
        
        return oldOrderTracker;
    }
    
    //function to update order tracker when end user or partner or proposal# for intiaing QC field is edited    
    @AuraEnabled
    public static Order_Tracker__c editPartnerEndUserofOrderTracker(Id orderTrackerId,String newPartnerEndUserValue,String fieldName)
    {
        Order_Tracker__c oldOrderTracker= new Order_Tracker__c();
        oldOrderTracker.Id=orderTrackerId;
        
        if(fieldName == 'Partner')
        {
            oldOrderTracker.Partner__c=newPartnerEndUserValue;
        }
        else if(fieldName == 'End User')
        {
            oldOrderTracker.End_User__c=newPartnerEndUserValue;            
        }
        else if(fieldName == 'Proposal for initiating QC')
        {
            oldOrderTracker.Proposal_for_initiating_QC__c=newPartnerEndUserValue;            
        }
        else if(fieldName == 'SO')
        {
            oldOrderTracker.SO__c=newPartnerEndUserValue;            
        }
        
        update oldOrderTracker;
        oldOrderTracker=OrderTrackerDashboard.getOrderTracker(orderTrackerId);
        return oldOrderTracker;
    }
    
    
    
    //function to edit currency fields(ACV,PO Amount,1st Biiling Amount)
    @AuraEnabled
    public static Order_Tracker__c editCurrencyNumberofOrderTracker(Id orderTrackerId,Decimal newCurrencyValue,String fieldName)
    {
        Order_Tracker__c oldOrderTracker= new Order_Tracker__c();
        oldOrderTracker.Id=orderTrackerId;
        
        if(fieldName == 'ACV')
        {
            oldOrderTracker.ACV__c=newCurrencyValue;
        }
        else if(fieldName == 'PO Amount')
        {
            oldOrderTracker.PO_Amount__c=newCurrencyValue;            
        }
        else if(fieldName == '1st Billing Amount')
        {
            oldOrderTracker.X1st_Billing_Amount_USD__c=newCurrencyValue;            
        }
        
        update oldOrderTracker;
        oldOrderTracker=OrderTrackerDashboard.getOrderTracker(orderTrackerId);
        return oldOrderTracker;
    }
    
    @AuraEnabled
    public static String getEmailTemplate(String picklistValue, String recordId, String objectName)
    {
        String emailTemplate='';
        // System.debug('picklistValue' + picklistValue);
        Map<String,Object> mapOfFields2Query=OrderTrackerDashboard.getAllFieldsName(objectName);
        Map<String,String> field2Type=(Map<String,String>)mapOfFields2Query.get('fieldTypes');
        String queryString =(String)mapOfFields2Query.get('query');
        List<String> fieldsNameList=(List<String>)mapOfFields2Query.get('fields');
        queryString += ' from ' + objectName + ' where id=:recordId LIMIT 1';
        if(objectName == 'Email_Tracker__c'){
            
            List<Email_Tracker__c> emailTrackerData = Database.query(queryString);
            list<Email_Tracker_Template__mdt> emailTemplateMdt = [SELECT Id, Label,Email_Template_Name__c  FROM Email_Tracker_Template__mdt where label = :picklistValue]; 
            if(emailTemplateMdt.isempty())
                return '';
            List<EmailTemplate> et=[SELECT Id, Name, HtmlValue, Body FROM EmailTemplate 
                                    Where DeveloperName =:emailTemplateMdt[0].Email_Template_Name__c];
            if(et.isEmpty())
                return '';
            if(!et.isEmpty() && !emailTrackerData.isEmpty()){
                emailTemplate=et[0].HtmlValue;
                for(String flds:fieldsNameList)
                {
                    if(emailTrackerData[0].get(flds)!=NULL)
                    {
                        emailTemplate=emailTemplate.replace('!'+flds, string.valueOf(emailTrackerData[0].get(flds)));
                    }
                    else
                    {
                        emailTemplate=emailTemplate.replace('!'+flds, '');   
                    }
                    
                }
            }
        }
        else if(objectName == 'Order_Tracker__c')
        {
            List<Order_Tracker__c> orderTrackerData = Database.query(queryString);
            list<Order_Tracker_Template__mdt> orderEmailTemplateMdt = [SELECT Id, Label, Email_Template_Name__c  
                                                                       FROM Order_Tracker_Template__mdt where label = :picklistValue];
            if(orderEmailTemplateMdt.isempty())
                return '';
            List<EmailTemplate> et=[SELECT Id, Name, HtmlValue, Body FROM EmailTemplate 
                                    Where DeveloperName =:orderEmailTemplateMdt[0].Email_Template_Name__c];
            if(et.isEmpty())
                return '';
            emailTemplate = et[0].HtmlValue;
            if(!et.isEmpty() && !orderTrackerData.isEmpty()) {
                for(String flds:fieldsNameList) {
                    
                    if(orderTrackerData[0].get(flds)!=NULL){
                        if(field2Type.get(flds)=='CURRENCY')
                        {
                            emailTemplate=emailTemplate.replace('!'+flds, currencyFormat((Decimal)orderTrackerData[0].get(flds)));
                        }
                        else if(field2Type.get(flds)=='DATE')
                        {
                            emailTemplate=emailTemplate.replace('!'+flds, dateFormat(''+orderTrackerData[0].get(flds)));
                        }
                        else if(flds == 'Opportunity__c')
                        {
                            emailTemplate=emailTemplate.replace('!Opportunity__r.name', '<a href=' +System.URL.getSalesforceBaseUrl().toExternalForm()+'/'+orderTrackerData[0].Opportunity__r.Id+' target="_blank" >'+ orderTrackerData[0].Opportunity__r.name+'</a>');
                        }
                        else
                        {
                            emailTemplate=emailTemplate.replace('!'+flds, string.valueOf(orderTrackerData[0].get(flds)));                            
                        }
                        
                    }
                    else{
                        if(flds == 'Opportunity__c')
                        {
                            emailTemplate=emailTemplate.replace('!Opportunity__r.name', '');
                            
                        }
                        else
                            emailTemplate=emailTemplate.replace('!'+flds, '');   
                    }
                    
                }
            }
            
        }
        
        
        return emailTemplate;
    }

    // New Changes START

    private static Boolean checkIfQuoteExist(String quoteName) {
        List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>();
        if (String.isNotBlank(quoteName)) {
            quoteList = [SELECT Id FROM SBQQ__Quote__c WHERE Name = :quoteName];
        }
        return !quoteList.isEmpty();
    }

    @AuraEnabled
    public static void attachPODocumentToOpportunity(String orderTrackerId, List<String> contentDocumentIdsList){
        try {
            Order_Tracker__c orderTrackerRecord = [SELECT Id, Proposal_for_initiating_QC__c, Opportunity__c FROM Order_Tracker__c WHERE Id = :orderTrackerId];
            if (orderTrackerRecord.Opportunity__c != null && String.isNotBlank(orderTrackerRecord.Proposal_for_initiating_QC__c) && 
                checkIfQuoteExist(orderTrackerRecord.Proposal_for_initiating_QC__c)) {

                List<ContentDocumentLink> contentDocumentLinkListToInsert = new List<ContentDocumentLink>();
                for (String contentDocumentId : contentDocumentIdsList) {
                    
                    ContentDocumentLink newContentDocumentLink = new ContentDocumentLink();
                    newContentDocumentLink.ContentDocumentId = contentDocumentId;
                    newContentDocumentLink.LinkedEntityId = orderTrackerRecord.Opportunity__c;
                    newContentDocumentLink.ShareType = 'V';
					newContentDocumentLink.Visibility = 'AllUsers';
                    
                    contentDocumentLinkListToInsert.add(newContentDocumentLink);
                }

                if (!contentDocumentLinkListToInsert.isEmpty()) {
                    insert contentDocumentLinkListToInsert;

                    TriggerHandler.bypass('OpportunityTriggerHandler');
                    Opportunity opportunityToUpdate = new Opportunity(Id = orderTrackerRecord.Opportunity__c, PO_Attached__c = true);
                    update opportunityToUpdate;
                }
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    //New Changes END

    public static Map<String,Object> getAllFieldsName(String objectName){
        Map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map <String, Schema.SObjectField> fieldMap = schemaMap.get(objectName).getDescribe().fields.getMap();
        List<String> fieldsNameList=new List<String>();
        String queryString = 'select ';
        if(objectName == 'Order_Tracker__c'){
            queryString+=' opportunity__r.name, ';
        }
        Map<String,String> field2Type=new Map<String,String>();
        for(Schema.SObjectField sfield : fieldMap.Values())
        {
            
            schema.describefieldresult dfield = sfield.getDescribe();
            fieldsNameList.add(dfield.getname());
            field2Type.put(dfield.getname(), dfield.getType()+'');
            queryString +=dfield.getname()+ ',';
        }
        queryString=queryString.substring(0, queryString.length()-1); 
        Map<String,Object> mapOfFields2Query=new Map<String,Object>();
        mapOfFields2Query.put('fields', fieldsNameList);
        mapOfFields2Query.put('query', queryString);
        mapOfFields2Query.put('fieldTypes', field2Type);
        
        return mapOfFields2Query;
    }
    
    public static string currencyFormat(Decimal rA){
        List<String> args = new String[]{'0','number','###,###,##0.00'};
            String s ='$'+String.format(rA.format(), args);
        return s;
    }
    
    public static string dateFormat(String convertDate){
        // system.debug('convertDate'+convertDate);
        Date dt=Date.valueOf(convertDate);
        /*String []closedDate=String.valueOf(dt.format()).split('/');String dateFormat=closedDate[1] +'-' + closedDate[0]+ '-'+ closedDate[2];*/
        
        Datetime dtime = datetime.newInstance(dt.year(), dT.month(),dT.day());
        String dateOutput = dTime.format('dd-MM-yyyy');
        // System.debug('Debug: '+dateOutput);   
        return dateOutput;
    }   

    @AuraEnabled
    public static String mergeRecords(String mergeRecord){
        try{
            String primaryRecordId;
            String primaryticketNumber;
            Set<Id> duplicateRecordIds = new Set<Id>();
            List<Object> objectList = (List<Object>)JSON.deserializeUntyped(mergeRecord);
            For(Object ob : objectList){
                Map<String,Object> data = (Map<String,Object>)ob;
                if(data.get('primary') == true){
                    primaryRecordId = (String)data.get('Id');
                    primaryticketNumber = (String)data.get('Ticket__c');
                }
                else{
                    if(String.isNotBlank((String)data.get('Id'))){
                        duplicateRecordIds.add((Id)data.get('Id'));
                    }
                }
            }
            if(!duplicateRecordIds.isEmpty()){
                List<Mail_Chain__c> mailChainRecords = [SELECT Id, Name, Order_Tracker__c, Thread_ID__c
                                                            FROM Mail_Chain__c
                                                            WHERE Order_Tracker__c IN : duplicateRecordIds];
            
                for(Mail_Chain__c mcRecord : mailChainRecords){
                    mcRecord.Order_Tracker__c = primaryRecordId;
                }                
                update mailChainRecords;
                List<Order_Tracker__c> lstOrdertracker = [SELECT Id,Status__c,Primary_Record_Detail__c
                                                                FROM Order_Tracker__c WHERE Id IN : duplicateRecordIds ];
                
                for(Order_Tracker__c ordertracker : lstOrdertracker){
                    ordertracker.Status__c = 'Merged';
                    ordertracker.Primary_Ticket_Number__c = primaryticketNumber;
                    ordertracker.Primary_Record_Detail__c = primaryRecordId ;
                }
                update lstOrdertracker;
            }
            return 'success';
        }
        catch(Exception ex){
            System.debug(ex.getMessage());
            return 'error'+ex.getMessage();
        }
    }
}