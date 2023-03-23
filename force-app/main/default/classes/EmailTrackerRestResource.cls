/*
 *  Created By : CSS Corp
 *  Modified by : Viral Navadiya [09/17/2021]
 *  Changes : restucture the Code, and if found the existing ETT reecord with Pending clousre then set it to In progress.
 */
@RestResource(urlMapping='/EmailTracker/*')
global class EmailTrackerRestResource {
    
    @HttpPost
    global static void createEmailTrackerAndMailChain() {
        RestRequest req = RestContext.request;
        RestResponse res = Restcontext.response;
        Map<String,Object> responseMap=new Map<String,Object>();
        
        try
        {
            String jsonInput = req.requestbody.tostring();
            
            //Get proper Email body from request
            //String emailBody = parseEmailbody(jsonInput);
            
            Map<String,Object> requestMap =(Map<String,Object>)JSON.deserializeUntyped(jsonInput);
            System.debug('---requestMap--keyset---'+requestMap.keyset());
            
            String emailBody = decodeEmailbody(String.valueOf(requestMap.get('Body__c')));
            
            //parse the Attachments list
            Map<String,object> attachmentsMap = new Map<String,Object>();
            
            if(requestMap.containsKey('Attachments') && !((List<Object>)requestMap.get('Attachments')).isEmpty()){
                integer i=1;
                for(object ob:(List<Object>)requestMap.get('Attachments')){
                    attachmentsMap.put('Attachments'+'#'+i,ob);
                    i++;
                }
            }
            
            //get the tread id
            String threadId=requestMap.get('Thread_ID__c').toString();
            
            List<Email_Tracker__c> emailTrackerList = [Select Id,ticket__c,status__c from Email_tracker__c where Thread_ID__c != null and Thread_ID__c like :threadId];
            
            
            id newMailChainID;
            
            //IF emailTracker not found using thread id
            if(emailTrackerList.isEmpty()){
                
                Email_tracker__c newEmailTracker = prepareETTRecordFromRequest(emailBody,  requestMap);
                insert newEmailTracker;
                
                //refresh the Record to get Formula field
                Email_Tracker__c etRecord = [Select id,name,ticket__c,Status__c,Primary_Record_Detail__c from Email_Tracker__c where id = :newEmailTracker.id];
                
                Mail_Chain__c newMailChain = prepareMailChainRecordFromRequest(newEmailTracker, emailBody, requestMap);
                insert newMailChain;
                
                responseMap.put('MailChainId',newMailChain.Id);
                responseMap.put('TicketNumber',etRecord.ticket__c);
                responseMap.put('EmailTrackerId',newEmailTracker.Id);
                
                newMailChainID = newMailChain.Id;
            }
            
            //IF emailTracker found using thread id
            else {
                
                Email_Tracker__c etRecord = emailTrackerList[0];
                if(etRecord.Status__c == 'Merged' && etRecord.Primary_Record_Detail__c != NULL){
                    etRecord.Id = etRecord.Primary_Record_Detail__c;
                }
                
                Mail_Chain__c newMailChain = prepareMailChainRecordFromRequest(etRecord, emailBody, requestMap);
                insert newMailChain;
                
                etRecord.Soft_Closed__c=false;
                etRecord.isNewFlag__c=true;
                etRecord.status__c= etRecord.status__c == 'Pending Closure' ? 'In Progress' : etRecord.status__c;
                etRecord.Latest_Mail_Date__c=System.now();
                update etRecord;
                
                responseMap.put('MailChainId',newMailChain.Id);
                responseMap.put('TicketNumber',etRecord.Ticket__c);
                responseMap.put('EmailTrackerId',etRecord.Id);
                newMailChainID = newMailChain.Id;
            }
            
            System.debug('----Insert attchmnet if exist---');
            insertEmailAttachment(newMailChainID, attachmentsMap);
            
            RestContext.response.statusCode=200;
            RestContext.response.responseBody = Blob.valueOf(JSON.serialize(responseMap));
        }
        catch(Exception e){
            System.debug('----Exception Occured---');
            System.debug('----Exception e---'+e.getCause());
            System.debug('----Exception e---'+e.getLineNumber());
            RestContext.response.responseBody = Blob.valueOf('Error: '+e.getMessage()+' Line Number: '+String.valueOf(e.getLineNumber()));
            RestContext.response.statusCode=500;
        }
    }
    
    //Prepare ETT Record From Request
    public Static Email_tracker__c prepareETTRecordFromRequest(String emailBody,  Map<String,Object> requestMap){+
        System.debug('----prepareETTRecordFromRequest called---');
        List<String> ettFieldNames = getAllFieldsName('Email_tracker__c');
        Email_tracker__c ettRecord = new Email_tracker__c();
        for(String fieldName : requestMap.keySet()){
            if(fieldName == 'Attachments'){
                continue;
            }else if(fieldName =='Date_Received__c'){
                ettRecord.Date_Received__c= requestMap.containsKey('Date_Received__c') ? 
                    (DateTime)json.deserialize('"' + requestMap.get('Date_Received__c').toString() + '"', datetime.class) : system.now() ;
            }else if(ettFieldNames.contains(fieldName)){
                ettRecord.put(fieldName, requestMap.get(fieldName));
            }else{
                System.debug('--Not-a-valid-field-for-Email_tracker__c--'+fieldName);
            }
        }
        ettRecord.body__c = emailBody != null && emailBody.length()> 0? emailBody : null;
        ettRecord.isNewFlag__c=true;
        ettRecord.Latest_Mail_Date__c=System.now();
        ettRecord.Priority__c= ettRecord.Priority__c != null ? ettRecord.Priority__c : 'Normal';                                                                                                       
        return  ettRecord;
    }
    
    //Prepare MC Record From Request
    public Static Mail_Chain__c prepareMailChainRecordFromRequest(Email_Tracker__c etRecord, String emailBody,  Map<String,Object> requestMap){
        System.debug('----prepareMailChainRecordFromRequest called---');
        List<String> mailChainFieldNames = getAllFieldsName('Mail_Chain__c');
        Mail_Chain__c newMailChain = new Mail_Chain__c();
        for(String fieldName : requestMap.keySet()){
            if(fieldName == 'Attachments' || fieldName == 'Email_Category__c'){
                continue;
            }
            if(mailChainFieldNames.contains(fieldName)){
                newMailChain.put(fieldName, requestMap.get(fieldName));
            }
        }
        newMailChain.body__c = emailBody != null && emailBody.length()> 0? emailBody : null;
        newMailChain.Date_Time_of_Email__c= requestMap.containsKey('Date_Received__c') ? (DateTime)json.deserialize('"' + requestMap.get('Date_Received__c').toString() + '"', datetime.class) :system.now();
        newMailChain.Email_Tracker__c=etRecord.Id;
        return  newMailChain;
    }


    
    //Get body from the Request.
    public static String parseEmailbody(String jsonInput){
        String emailBody = null;
        if(jsonInput.contains('Body__c')){
            emailBody= jsonInput.substring(jsonInput.lastIndexOf('"Body__c":'),jsonInput.lastIndexOf('}'));  
            jsonInput=jsonInput.replace(emailBody,'');
            jsonInput=(jsonInput.substring(0,jsonInput.lastIndexOf(',')))+'}';
            emailBody=emailBody.replace('"Body__c": "','');
            emailBody=emailBody.substring(0,emailBody.lastIndexOf('"'));
        }
        return emailBody;
    }
    
    //Get body from the Request.
    public static String decodeEmailbody(String jsonInput){
        System.debug('---jsonInput--'+jsonInput);
        String returnStr = null;
        if(jsonInput != null){
            returnStr = EncodingUtil.base64Decode(jsonInput).toString();
        }
        return returnStr;
    }
    
    //Insert all Email attachements sent in api.
    public static void insertEmailAttachment(ID newMailChainID, Map<String,object> attachmentsMap){
        system.debug('--insertEmailAttachment---called---newMailChainID:'+newMailChainID);
        
        if(attachmentsMap != null && attachmentsMap.size() > 0){
            List<ContentVersion> relatedDocuments = new List<ContentVersion>();
            for (String fields :attachmentsMap.keySet()) {
                object ob=attachmentsMap.get(fields);
                system.debug(ob.toString());
                Map<string,object> finalMap=(Map<string,object>)ob;
                system.debug('---attach finalMap --keyset---'+finalMap.keyset());
                
                ContentVersion contentVersionFile = new ContentVersion();
                contentVersionFile.ContentLocation = 'S';
                contentVersionFile.FirstPublishLocationId=newMailChainID;
                // The files name, extension is very important here which will help the file in preview.
                contentVersionFile.PathOnClient = finalMap.get('Name').toString(); 
                // Display name of the files
                contentVersionFile.Title = finalMap.get('Name').toString(); 
                // converting your binary string to Blog
                contentVersionFile.VersionData = EncodingUtil.base64Decode(finalMap.get('Body').toString()); 
                relatedDocuments.add(contentVersionFile);
            }
            insert relatedDocuments;
        }
    }
    
    
    //Get list of Field API names based on obejct Name.
    public static List<String> getAllFieldsName(String objectName){
        Map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map <String, Schema.SObjectField> fieldMap = schemaMap.get(objectName).getDescribe().fields.getMap();
        List<String> fieldsNameList=new List<String>();
        for(Schema.SObjectField sfield : fieldMap.Values()){
            schema.describefieldresult dfield = sfield.getDescribe();
            fieldsNameList.add(dfield.getname());
        }
        return fieldsNameList;
    }
}