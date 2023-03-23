public Without Sharing class getMailChainData {
    
    // To get data of mail chain for connected callback method in js with Particular Email Tracker or Order Tracker Record
    @AuraEnabled
    public static Map<String,Object> getMainChainTableData(string orderTrackerId, string isEmailTracker) 
    {
        Map<String,Object> mapMailChainTable = new Map<String,Object>();
        Integer pageLimit=10 ;
        Integer pageNumber= 0;
        list<Object> trackerList = new list<Object>(); 
        Integer totalMainChainRecords;
        // Email Tracker Query and Total Mail Chains for particular Email Tracker subject clicked on parent Email Tracker Component
        if(isEmailTracker=='emailTracker'){
            trackerList = [SELECT Id,Ticket__c,Email_Category__c,Email_Subject__c, Requester_Name__c, Requester_Org__c, Priority__c, Status__c,
                           Complete__c, Assigned_To_1st_Assignee__c,Thread_ID__c, 
                           Assigned_To_2nd_Assignee__c, Assigned_To_3rd_Assignee__c, 
                           Date_Received__c, Completion_Date__c, TAT__c 
                           FROM Email_Tracker__c WHERE Id=: orderTrackerId];
            
            // to count total main chain records for particular Email Tracker
            totalMainChainRecords=[SELECT Count() From Mail_Chain__c Where Email_Tracker__c =:orderTrackerId];
        }
        // Order Tracker Query and Total Mail Chains for particular Order Tracker subject clicked on parent Order Tracker Component
        else if(isEmailTracker=='orderTracker' || isEmailTracker=='Order Tracker Dashboard'){
            trackerList =[SELECT Id,BCC__c,Body__c,BOT_Email_Id__c,CC__c,From__c,Message_Id__c,Requester_Name__c,Ticket__c,Name, PO__c, Email_Subject__c, 
                          Status__c, Region__c, Received_Date__c,Customer_ID__c,Attachment_on_NS_SF__c,Thread_ID__c,To__c,
                          Partner__c, Checking_OP_Rep_QC_Rep__c, Processing_OP_Rep__c,OP_Rep_Following_Up__c, Final_Approver__c,
                          Order_Type__c, End_User__c, SO__c, ACV__c, PO_Amount__c,X1st_Billing_Amount_USD__c,All_SFDC_Processses_Updated__c,
                          Billing_Frequency__c, ZA_Updated__c, confirm_all_dependant_PRs_moved_to_prod__c, Proposal_for_initiating_QC__c,
                          BOT_Auto_QC_Done__c, BOT_Re_QC_Required__c, NS_Integration_Status__c, Remarks__c, TAT_QC_Check__c, TAT_Order_Approval__c, 
                          TAT_Billing__c
                          FROM Order_Tracker__c 
                          Where Id =: orderTrackerId];
            
            // to count total main chain records for particular Order Tracker
            totalMainChainRecords=[SELECT Count() From Mail_Chain__c Where Order_Tracker__c =:orderTrackerId];
        }
        
        
        
        
        // mapMailChainTable for returning result at JS in component
        mapMailChainTable.put('count',totalMainChainRecords);
        mapMailChainTable.put('OrderTrackerData',trackerList);
        mapMailChainTable.put('mailChainData',getNextMailChainData(pageNumber, pageLimit, orderTrackerId, isEmailTracker,False).get('mailChainData'));
        mapMailChainTable.put('attachments',getNextMailChainData(pageNumber,pageLimit, orderTrackerId, isEmailTracker,False).get('attachments'));
        return mapMailChainTable;
    }
    
    // Method for Pagination and To Fetch Main Chain Data And Attachments Regarding Mail Chains
    @AuraEnabled
    public static Map<String,Object> getNextMailChainData(Integer pageNumber,Integer pageLimit,string orderTrackerId,string isEmailTracker,Boolean fromConvertFunction)
    { 
        Set<Id> mailChainIds = new Set<Id>();
        Map<String,Object> mapGetNextMChain = new Map<String,Object>();
        List<Object> attachmentList = new List<Object>();
        List<Mail_Chain__c> mailChainDetails = new List<Mail_Chain__c>();
        system.debug('pageNumber'+pageNumber);
        // To fetch data of Mail Chain according to Pagination and According to Trackers 
        integer off = pageNumber * pageLimit;
        system.debug('off'+off);
        String query='SELECT Id, Date_Time_of_Email__c, Email_Tracker__c,Order_Tracker__c, From__c, To__c, CC__c, BCC__c,Email_Subject__c, Body__c,Message_Id__c FROM Mail_Chain__c';
        if(!fromConvertFunction)
        {
            if(isEmailTracker=='emailTracker'){
                query+=' WHERE Email_Tracker__c =: orderTrackerId ORDER BY LastModifiedDate desc LIMIT :pageLimit OFFSET :off';
            }
            else if(isEmailTracker=='orderTracker' || isEmailTracker=='Order Tracker Dashboard'){
                query+=' WHERE Order_Tracker__c =: orderTrackerId ORDER BY LastModifiedDate desc LIMIT :pageLimit OFFSET :off';
            }
            mailChainDetails = Database.query(query);
            
        }
        else if(fromConvertFunction)
        {
            if(isEmailTracker=='emailTracker'){
                query+=' WHERE Email_Tracker__c =: orderTrackerId';
            }
            else if(isEmailTracker=='orderTracker' || isEmailTracker=='Order Tracker Dashboard'){
                query+=' WHERE Order_Tracker__c =: orderTrackerId';
            }
            mailChainDetails = Database.query(query);            
        }
        
        for(Mail_Chain__c mc:mailChainDetails)
        {
            mailChainIds.add(mc.Id);
        }
        
        // To fetch Attachments Associated with Particular Mail Chains
        if(!mailChainIds.isEmpty()){
            List<ContentDocumentLink> cdls = [SELECT ContentDocumentId,LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN: mailChainIds];
            Set<Id> documentIds = new Set<Id>();
            
            //Map<String,String> mChainIdDocuIdMap = new Map<String,String>();
            
            Map<String,List<String>> mChainIdDocuIdMap = new Map<String,List<String>>();
            for (ContentDocumentLink cdl : cdls) 
            {
                List<String> linkedEntrityList = mChainIdDocuIdMap.containskey(cdl.ContentDocumentId) ? mChainIdDocuIdMap.get(cdl.ContentDocumentId) : New List<String>();
                linkedEntrityList.add(cdl.LinkedEntityId);
                mChainIdDocuIdMap.put(cdl.ContentDocumentId,linkedEntrityList);
            }
            List<ContentDocument> attachments = [SELECT Id,Title,FileType,FileExtension FROM ContentDocument WHERE Id  IN:mChainIdDocuIdMap.keySet() ORDER BY LastModifiedDate desc];
            
            
            for(ContentDocument cd: attachments)
            {
                if(mChainIdDocuIdMap.containskey(cd.Id)){
                    for(String mailChainId  : mChainIdDocuIdMap.get(cd.Id)){
                        Map<String,String> mapOfAttachment=new Map<String,String>();
                        mapOfAttachment.put('mailChainId',mailChainId);
                        mapOfAttachment.put('fileId',cd.Id);
                        if((cd.Title).contains((cd.FileType).toLowercase()) || cd.FileType=='UNKNOWN'){
                            mapOfAttachment.put('fileTitle',cd.Title);
                        }
                        else{
                            mapOfAttachment.put('fileTitle',cd.Title + '.' + cd.FileExtension);
                        }
                        attachmentList.add(mapOfAttachment);
                    }
                }
            }
        } 
        
        // to get data in js for pagination 
        mapGetNextMChain.put('mailChainData',mailChainDetails);
        mapGetNextMChain.put('attachments',attachmentList);
        
        return mapGetNextMChain;
    }
    
    
    //method to convert order tracker to email tracker
    @AuraEnabled
    public static Boolean convertTracker(String trackerType,String trackerId)
    {
        Boolean isSuccess=false;
        Map<String,Object> mailChainMap = getMainChainTableData(trackerId,trackerType);
        List<mail_chain__c> mailChainList=(List<mail_chain__c>)getNextMailChainData(10,0,trackerId,trackerType,True).get('mailChainData');

        List<String> emailTrackerFieldSetList = getFieldSet('email_Tracker__c');

        List<String> orderTrackerfieldsList =getAllFieldsName('Order_Tracker__c');

        List<String> emailTrackerfieldsList =getAllFieldsName('email_Tracker__c');
        if(trackerType=='emailTracker'){
            List<Email_tracker__c> emailtrackerList = (List<Email_tracker__c>)mailChainMap.get('OrderTrackerData');
            
        }
        else if(trackerType=='orderTracker')
        {
            List<Email_tracker__c> convertedEmailTrackerList = new List<Email_tracker__c>();
            Email_tracker__c convertedEmailTracker = new Email_tracker__c();
            List<Order_tracker__c> ordertrackerList = (List<Order_tracker__c>)mailChainMap.get('OrderTrackerData');
            for(String fields:orderTrackerfieldsList)
            {
                
                if(fields == 'Received_Date__c')
                {
                    convertedEmailTracker.put('Date_Received__c',ordertrackerList[0].Received_Date__c);
                }
                else if(fields != 'Received_Date__c' && emailTrackerFieldSetList.indexOf(fields)>-1)
                {
                    if(fields == 'From__c')
                    {
                        convertedEmailTracker.Requester_Name__c=ordertrackerList[0].From__c;
                    }
                    else
                    {
                     	convertedEmailTracker.put(fields,ordertrackerList[0].get(fields));   
                    }
                    
                }
            }
            List<Email_Tracker__c> emailTrackerList=[SELECT Id From Email_Tracker__c WHERE Thread_ID__c=:ordertrackerList[0].Thread_ID__c];
            if(!emailTrackerList.isEmpty())
            {
            convertedEmailTracker =new Email_Tracker__c(); 
            convertedEmailTracker.Id=emailTrackerList[0].Id;
            }

            convertedEmailTracker.isNewFlag__c=true;
            convertedEmailTracker.Latest_Mail_Date__c=system.now();
            convertedEmailTrackerList.add(convertedEmailTracker);
            Database.UpsertResult[] srList = Database.upsert(convertedEmailTrackerList, false);

            if(srList[0].isSuccess())
            {
                isSuccess=true;
                for(Mail_chain__c mChain:mailChainList)
                {
                    mChain.Order_Tracker__c=Null;
                    mchain.Email_tracker__c=convertedEmailTracker.Id;
                }
                update mailChainList;
                delete ordertrackerList[0];

            }

            
        }
        return isSuccess;
        
        
    }

    @AuraEnabled
    public static String convertToOrderTracker(String trackerType,String trackerId,String quoteNumber,String primaryTicketNumber){
        Email_Tracker__c tracker = new Email_Tracker__c();
        List<Messaging.EmailFileAttachment> emlAttList = new List<Messaging.EmailFileAttachment>();
        List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();
        List<ContentVersion> cvList = new List<ContentVersion>();
        Set<Id> contentDocsId = new Set<Id>();
        String status;
        String query;
        if(trackerType=='emailTracker'){
           query='SELECT Id, Ticket__c, Thread_ID__c FROM Email_Tracker__c WHERE Id =: trackerId LIMIT 1';           
        }
        tracker = Database.query(query);
        if(String.isNotBlank(primaryTicketNumber)){
            List<Order_Tracker__c> ordertracker = [SELECT Id,Name,Ticket__c FROM Order_Tracker__c WHERE Ticket__c =: primaryTicketNumber];
            Email_Tracker__c Et = new Email_Tracker__c();
            if(ordertracker.size()>0){
                Et.Id = tracker.Id;
                Et.Primary_Ticket_Number__c = primaryTicketNumber;
                Et.Primary_Record_Detail__c = ordertracker[0].Id;
                Et.Status__c = 'Merged';
            }
            else{
                throw new customException('Order tracker ticket Number '+String.valueOf(primaryTicketNumber)+ ' is not present. Please enter a  Valid Ticket Number' );
            }
            if(Et != NULL){
                update Et;
            }
        }
        Mail_chain__c mailchainRecord = [SELECT id,name,Email_Tracker__c,createdDate from mail_chain__c where Email_Tracker__c =:trackerId  order by createdDate Asc LIMIT 1];
           if(mailchainRecord != NULL){

              cdlList = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :mailchainRecord.Id];
              for(ContentDocumentLink cdl : [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :mailchainRecord.Id]){
                contentDocsId.add(cdl.ContentDocumentId);
              }
           }
           if(cdlList.size()>0){
              cvList = [SELECT VersionData, Title FROM ContentVersion WHERE ContentDocumentId  IN: contentDocsId AND IsLatest = true];
           }
           if(cvList.size()>0) {
               for(ContentVersion cv : cvList){
                Messaging.EmailFileAttachment emlAtt = new Messaging.EmailFileAttachment();
                Blob fileData = cv.VersionData; // <= This step converts the version data into a blob for the attachment
                emlAtt.setFilename(cv.Title);
                emlAtt.setBody(fileData);
                emlAttList.add(emlAtt);
               }
           }

            User us = [SELECT Id, FirstName, Email, LastName FROM USER WHERE Name= 'RPA Integration' LIMIT 1];
            if(us != NULL){
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                message.toAddresses = new String[] {us.Email};
                string Subject = 'Moving ' + tracker.Ticket__c + ' to Order Tracker';
                message.setsenderDisplayName('Sales Ops System Admin');
                message.setSubject(Subject);
                String body = '<div style="display:none">*Moving ticket to order tracker* </div><br>';
                body += 'Ticket No:' +tracker.Ticket__c + '<br>';
                body += 'Thread Id:{['+tracker.Thread_ID__c +']} <br>'; 
                if(string.isNotBlank(quoteNumber)){
                    body +='Quote Number:'+quoteNumber+ '<br>';
                }
                if(string.isNotBlank(primaryTicketNumber)){
                    body += 'Primary Ticket:{['+ primaryTicketNumber +']} <br>'; 
                }
                message.setHtmlBody(body);
                message.setFileAttachments(emlAttList);
                Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
                Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
        
                if (results[0].success) {
                    Status = String.valueof(results[0].success);
                } else {
                    Status = 'The email failed to send: ' + results[0].errors[0].message;
                }
            }
        return Status;
    }
    
    public static List<String> getAllFieldsName(String objectName)
    {
        Map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map <String, Schema.SObjectField> fieldMap = schemaMap.get(objectName).getDescribe().fields.getMap();
        List<String> fieldsNameList=new List<String>();
        
        for(Schema.SObjectField sfield : fieldMap.Values())
        {
            schema.describefieldresult dfield = sfield.getDescribe();
            fieldsNameList.add(dfield.getname());            
        }
        
        return fieldsNameList;
    }
    
    public static List<String> getFieldSet(String objectName)
    {
        List<string> fieldApiList = new List<string>();
        Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe(); 
        Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(objectName);
        Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
        
        Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get('Email_Tracker_Field_Set');
        List<Schema.FieldSetMember> fieldSetMemberList = fieldSetObj.getFields();
 
        for(Schema.FieldSetMember fieldSetMemberObj : fieldSetMemberList)
        {
            fieldApiList.add(fieldSetMemberObj.getFieldPath());
        }
        return fieldApiList;         
    }

    public class customException extends Exception {

    }
    
}