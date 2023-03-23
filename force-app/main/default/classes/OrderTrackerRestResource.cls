/*
 *  Created By : CSS Corp
 *  Modified by : Viral Navadiya [09/17/2021]
 *  Changes : restucture the Code, and if found the existing OTT reecord with Pending clousre then set it to In progress.
 */
@RestResource(urlMapping='/OrderTracker/*')
global class OrderTrackerRestResource {
    
    @HttpPost
    global static void createOrderTrackerAndMailChain() {
        
        RestRequest req = RestContext.request;
        RestResponse res = Restcontext.response;
        
        try
        {
            
            Map<String,Object> responseMap=new Map<String,Object>();
            
            
            String jsonInput = req.requestbody.tostring();
            
            //Get proper Email body from request
            //String emailBody = parseEmailbody(jsonInput);
           
            Map<String,Object> requestMap =(Map<String,Object>)JSON.deserializeUntyped(jsonInput);
            System.debug('---requestMap--keyset---'+requestMap.keyset());
            
            String emailBody = decodeEmailbody(String.valueOf(requestMap.get('Body__c')));
            
            //Parse the Attachments list
            Map<String,object> attachmentsMap = new Map<String,Object>();
            
            if(requestMap.containsKey('Attachments') && !((List<Object>)requestMap.get('Attachments')).isEmpty()){
                integer i=1;
                for(object ob:(List<Object>)requestMap.get('Attachments')){
                    attachmentsMap.put('Attachments'+'#'+i,ob);
                    i++;
                }
            }
            
            //get the tread id
            String threadId = requestMap.get('Thread_ID__c').toString();
            
            List<Order_Tracker__c> orderTrackerList = [Select Id,ticket__c,Thread_ID__c,Message_Id__c, Status__c,Primary_Record_Detail__c from order_tracker__c where Thread_ID__c != null and Thread_ID__c like :threadId];
            
            
            id newMailChainID;
            
            //IF Order Tracker not found using thread id
            if(orderTrackerList.isEmpty()){
                
                Order_Tracker__c newOrderTracker = prepareOTTRecordFromRequest(emailBody,  requestMap);
                insert newOrderTracker;
                
                //refresh the Record to get Formula field
                Order_Tracker__c otRecord = [Select id,name,ticket__c,Status__c from Order_Tracker__c where id = :newOrderTracker.id];
                
                Mail_Chain__c newMailChain = prepareMailChainRecordFromRequest(newOrderTracker, emailBody, requestMap);
                insert newMailChain;
                
                responseMap.put('MailChainId',newMailChain.Id);
                responseMap.put('TicketNumber',otRecord.ticket__c);
                responseMap.put('OrderTrackerId',newOrderTracker.Id);
                
                newMailChainID = newMailChain.Id;
            }
            
            //IF Order Tracker record found using thread id
            else {
                Order_Tracker__c otRecord = orderTrackerList[0];
                Id otRecordID = otRecord.ID;
                
                if(otRecord.Message_Id__c == null){
                    otRecord = prepareOTTRecordFromRequest(emailBody,  requestMap);
                    if(otRecord.Status__c == 'Merged' && String.IsNotBlank(otRecord.Primary_Record_Detail__c)){
                        otRecord.id = otRecord.Primary_Record_Detail__c;
                    }
                    else{
                        otRecord.id = otRecordID;
                    }
                }
                                
                Mail_Chain__c newMailChain = prepareMailChainRecordFromRequest(otRecord,  emailBody,  requestMap);
                insert newMailChain;
                
                
                otRecord.isNewFlag__c=true;
                otRecord.Latest_Mail_Date__c=System.now();
                update otRecord;
                
                responseMap.put('MailChainId',newMailChain.Id);
                responseMap.put('TicketNumber',otRecord.Ticket__c);
                responseMap.put('OrderTrackerId',otRecord.Id);
                
                newMailChainID = newMailChain.Id;
                
            }
            
            System.debug('----Insert attchmnet if exist---');
            insertEmailAttachment(newMailChainID, attachmentsMap);
           
            RestContext.response.statusCode=200;
            RestContext.response.responseBody = Blob.valueOf(JSON.serialize(responseMap));
            
        }
        catch(Exception e)
        {
            System.debug('----Exception Occured---');
            System.debug('----Exception e---'+e.getCause());
            System.debug('----Exception e---'+e.getLineNumber());
            RestContext.response.responseBody = Blob.valueOf('Error: '+e.getMessage()+' Line Number: '+String.valueOf(e.getLineNumber()));
            //RestContext.response.responseBody = Blob.valueOf(JSON.serialize(e));
            RestContext.response.statusCode=500;
        }
        
        
    }
    
    @HttpPut
    global static void updateOrderTrackerAndMailChain() {
        Map<String,Object> responseMap=new Map<String,Object>();
        RestRequest req = RestContext.request;
        RestResponse res = Restcontext.response;
        try
        {
            String jsonInput = req.requestbody.tostring();
            Map<String,Object> requestMap =(Map<String,Object>)JSON.deserializeUntyped(jsonInput);
            
            
            List<Object> attachments = new List<Object>();
            Map<String,object> attachmentsMap = new Map<String,Object>();
            if(requestMap.containsKey('Attachments') && !(((List<Object>)requestMap.get('Attachments')).isEmpty()))
            {
                attachments = (List<Object>)requestMap.get('Attachments');
                
                integer i=1;
                for(object ob:attachments)
                {
                    attachmentsMap.put('Attachments'+i,ob);
                    i++;
                }
            }
            
            String ordertrackerThreadId=requestMap.get('Thread_ID__c').toString();
            List<Order_Tracker__c> orderTrackerList =[Select Id,Thread_ID__c from order_tracker__c where Thread_ID__c = :ordertrackerThreadId];
            List<String> mailChainFieldNames = OrderTrackerRestResource.getAllFieldsName('Mail_Chain__c');
            if(orderTrackerList.isEmpty())
            {
                RestContext.response.statusCode=500;
                RestContext.response.responseBody = Blob.valueOf('Error Occured.\nMessage : No order tracker found with this Thread ID');
            }
            else
            {
                for(String fieldName : requestMap.keySet())
                {
                    if(fieldName != 'Attachments' && fieldName != 'Thread_ID__c')
                    {
                        if(fieldName=='Contract_End_Date__c')
                        {    if(!String.isBlank(requestMap.get(fieldName).toString()))
                            orderTrackerList[0].Contract_End_Date__c= (Date)json.deserialize('"' + requestMap.get('Contract_End_Date__c').toString() + '"', date.class);
                        }
                        else if(fieldName=='Contract_Start_Date__c')
                        {      if(!String.isBlank(requestMap.get(fieldName).toString()))
                            orderTrackerList[0].Contract_Start_Date__c= (Date)json.deserialize('"' + requestMap.get('Contract_Start_Date__c').toString() + '"', date.class);
                        }
                        else if(fieldName=='Company_size__c')
                        {
                            if(!String.isBlank(requestMap.get(fieldName).toString()))
                                orderTrackerList[0].put(fieldName, Integer.valueof(requestMap.get(fieldName).toString()));
                        }
                        else
                        {
                            if(!String.isBlank(requestMap.get(fieldName).toString()))
                                orderTrackerList[0].put(fieldName, requestMap.get(fieldName));
                        }
                        
                    }  
                }
                orderTrackerList[0].Latest_Mail_Date__c=System.now();
                update orderTrackerList[0];
                responseMap.put('Order Tracker',orderTrackerList[0]);  
                
                if((requestMap.containsKey('BOT_Auto_QC_Done__c') && requestMap.get('BOT_Auto_QC_Done__c') == 'Yes')&&(!attachments.isEmpty() || attachments != null))
                {
                    List<ContentVersion> relatedDocuments = new List<ContentVersion>();
                    for (String fields :attachmentsMap.keySet()) {
                        object ob=attachmentsMap.get(fields);
                        Map<string,object> finalMap=(Map<string,object>)ob;
                        ContentVersion contentVersionFile = new ContentVersion();
                        contentVersionFile.ContentLocation = 'S';
                        contentVersionFile.FirstPublishLocationId=orderTrackerList[0].Id;
                        contentVersionFile.PathOnClient = finalMap.get('Name').toString(); // The files name, extension is very important here which will help the file in preview.
                        contentVersionFile.Title = finalMap.get('Name').toString(); // Display name of the files
                        contentVersionFile.VersionData = EncodingUtil.base64Decode(finalMap.get('Body').toString()); // converting your binary string to Blog
                        relatedDocuments.add(contentVersionFile);
                    }
                    insert relatedDocuments;
                }
                RestContext.response.statusCode=200;
                RestContext.response.responseBody = Blob.valueOf(JSON.serialize(responseMap));
            }
            
            
        }
        catch(Exception e)
        {
            
            RestContext.response.responseBody =Blob.valueOf(JSON.serialize(e));
            RestContext.response.statusCode=500;
        }
        
        
    }
    
    
    //Prepare OTT Record From Request
    public Static Order_Tracker__c prepareOTTRecordFromRequest(String emailBody,  Map<String,Object> requestMap){+
        System.debug('----prepareETTRecordFromRequest called---');
        List<String> ettFieldNames = getAllFieldsName('Order_Tracker__c');
        Order_Tracker__c ottRecord = new Order_Tracker__c();
        for(String fieldName : requestMap.keySet()){
            if(fieldName == 'Attachments'){
                continue;
            }else if(fieldName =='Received_Date__c'){
                ottRecord.Received_Date__c = requestMap.containsKey('Received_Date__c') ? 
                    (DateTime)json.deserialize('"' + requestMap.get('Received_Date__c').toString() + '"', datetime.class) : system.now() ;
            }else if(ettFieldNames.contains(fieldName)){
                ottRecord.put(fieldName, requestMap.get(fieldName));
            }else{
                System.debug('--Not-a-valid-field-for-Order_Tracker__c--'+fieldName);
            }
        }
        ottRecord.body__c = emailBody != null && emailBody.length()> 0? emailBody : null;
        ottRecord.isNewFlag__c=true;
        ottRecord.Latest_Mail_Date__c=System.now();
        ottRecord.Status__c= ottRecord.Status__c != null ? ottRecord.Status__c : 'PO Pending for QC';                                                                                                       
        return  ottRecord;
    }
    
    
    //Prepare MC Record From Request
    public Static Mail_Chain__c prepareMailChainRecordFromRequest(Order_Tracker__c otRecord, String emailBody,  Map<String,Object> requestMap){
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
        newMailChain.Date_Time_of_Email__c= requestMap.containsKey('Received_Date__c') ? (DateTime)json.deserialize('"' + requestMap.get('Received_Date__c').toString() + '"', datetime.class) :system.now();
        newMailChain.Order_Tracker__c=otRecord.Id;
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
        System.debug('---returnStr--'+returnStr);
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
        for(Schema.SObjectField sfield : fieldMap.Values())
        {
            schema.describefieldresult dfield = sfield.getDescribe();
            fieldsNameList.add(dfield.getname());
        }
        return fieldsNameList;
    }
    
}