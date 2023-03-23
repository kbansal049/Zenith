public without sharing class getEmailTrackerData {
    
    
    @AuraEnabled
    public static map<string,List<object>> getMetadataPicklistsEmailTracker()
    {
        map<string,List<object>> response=new Map<string,List<object>>();
        response.put('firstAssignee',[SELECT Id, Label, User_Id__c FROM 	Email_Tracker_1st_Assignee__mdt]);
        response.put('secondAssignee',[SELECT Id, Label, User_Id__c FROM Email_Tracker_2nd_Assignee__mdt]);
        response.put('thirdAssignee',[SELECT Id, Label, User_Id__c FROM 	Email_Tracker_3rd_Assignee__mdt]);
        return response;
    }
    
    
    @AuraEnabled
    public static object getNextEmailTrackers(Integer pageNumber,Integer pageLimit,
                                              String viewPicklistValue, String searchFilterStr,String selectedTab)
    { 
        List<String> openStatus=new List<String>{'TL Input Required','Not Started','In Progress','Deferred'};
        Map<String,String> userMap = new Map<String,String>();
        userMap=OrderTrackerDashboard.getUserInformation();
        String userId=userMap.get('UserId');
        Integer off = (pageNumber - 1) * pageLimit;
        Integer recordEnd = pageLimit * pageNumber;
        Integer totalEmailTrackerRecords=[Select COUNT() From Email_Tracker__c];
        String query = 'SELECT Id, Ticket__c, Email_Category__c, Email_Subject__c,isNewFlag__c, Requester_Name__c, Requester_Org__c, Priority__c, Status__c, Complete__c, Assigned_To_1st_Assignee__c, Assigned_To_2nd_Assignee__c, Assigned_To_3rd_Assignee__c, Date_Received__c, Completion_Date__c, TAT__c, Remarks__c,Primary_Ticket_Number__c FROM Email_Tracker__c';            
        if(selectedTab == 'Assigned To Me')
        {
            if(viewPicklistValue != 'All')
            {           
                if(searchFilterStr != '' && viewPicklistValue == 'open')
                {	
                    searchFilterStr = '%'+ searchFilterStr +'%';
                    totalEmailTrackerRecords=[Select COUNT() From Email_Tracker__c WHERE (Ticket__c Like :searchFilterStr OR Email_Subject__c LIKE :searchFilterStr OR Primary_Ticket_Number__c LIKE :searchFilterStr ) AND (Status__c IN :openStatus)  AND (Assigned_To_1st_Assignee__c=:userId OR Assigned_To_2nd_Assignee__c = :userId OR Assigned_To_3rd_Assignee__c = :userId)];
                    query=query+' WHERE (Ticket__c Like :searchFilterStr OR Email_Subject__c LIKE :searchFilterStr OR Primary_Ticket_Number__c LIKE :searchFilterStr ) AND (Status__c IN :openStatus AND (Assigned_To_1st_Assignee__c=:userId OR Assigned_To_2nd_Assignee__c = :userId OR Assigned_To_3rd_Assignee__c = :userId))';
                }
                else if(searchFilterStr != '' && viewPicklistValue == 'closed')
                {	
                    searchFilterStr = '%'+ searchFilterStr +'%';
                    totalEmailTrackerRecords=[Select COUNT() From Email_Tracker__c WHERE (Ticket__c Like :searchFilterStr OR Email_Subject__c LIKE :searchFilterStr OR Primary_Ticket_Number__c LIKE :searchFilterStr ) AND (Status__c NOT IN :openStatus) AND (Assigned_To_1st_Assignee__c=:userId OR Assigned_To_2nd_Assignee__c = :userId OR Assigned_To_3rd_Assignee__c = :userId)];
                    query=query+' WHERE (Ticket__c Like :searchFilterStr OR Email_Subject__c LIKE :searchFilterStr OR Primary_Ticket_Number__c LIKE :searchFilterStr ) AND (Status__c NOT IN :openStatus AND (Assigned_To_1st_Assignee__c=:userId OR Assigned_To_2nd_Assignee__c = :userId OR Assigned_To_3rd_Assignee__c = :userId))';
                }
                else if(searchFilterStr == '' && viewPicklistValue == 'open')
                {
                    totalEmailTrackerRecords=[Select COUNT() From Email_Tracker__c WHERE (Status__c IN :openStatus) AND (Assigned_To_1st_Assignee__c=:userId OR Assigned_To_2nd_Assignee__c = :userId OR Assigned_To_3rd_Assignee__c = :userId)];
                    query=query+' WHERE Status__c IN :openStatus AND (Assigned_To_1st_Assignee__c=:userId OR Assigned_To_2nd_Assignee__c = :userId OR Assigned_To_3rd_Assignee__c = :userId)';
                }
                else if(searchFilterStr == '' && viewPicklistValue == 'closed')
                {
                    totalEmailTrackerRecords=[Select COUNT() From Email_Tracker__c WHERE (Status__c NOT IN :openStatus) AND (Assigned_To_1st_Assignee__c=:userId OR Assigned_To_2nd_Assignee__c = :userId OR Assigned_To_3rd_Assignee__c = :userId)];
                    query=query+' WHERE (Status__c NOT IN :openStatus) AND (Assigned_To_1st_Assignee__c=:userId OR Assigned_To_2nd_Assignee__c = :userId OR Assigned_To_3rd_Assignee__c = :userId)';
                }
                
            }
            else if(viewPicklistValue == 'All')
            {
                if(searchFilterStr != '')
                {	
                    searchFilterStr = '%'+ searchFilterStr +'%';
                    totalEmailTrackerRecords=[Select COUNT() From Email_Tracker__c WHERE (Ticket__c Like :searchFilterStr OR Email_Subject__c Like :searchFilterStr OR Primary_Ticket_Number__c LIKE :searchFilterStr ) AND (Assigned_To_1st_Assignee__c=:userId OR Assigned_To_2nd_Assignee__c = :userId OR Assigned_To_3rd_Assignee__c = :userId)];
                    query=query+' WHERE (Ticket__c Like :searchFilterStr OR Email_Subject__c LIKE :searchFilterStr OR Primary_Ticket_Number__c LIKE :searchFilterStr) AND (Assigned_To_1st_Assignee__c=:userId OR Assigned_To_2nd_Assignee__c = :userId OR Assigned_To_3rd_Assignee__c = :userId)';
                }
                else if(searchFilterStr == '')
                {	
                    totalEmailTrackerRecords=[Select COUNT() From Email_Tracker__c WHERE (Assigned_To_1st_Assignee__c=:userId OR Assigned_To_2nd_Assignee__c = :userId OR Assigned_To_3rd_Assignee__c = :userId)];
                    query=query+' WHERE (Assigned_To_1st_Assignee__c=:userId OR Assigned_To_2nd_Assignee__c = :userId OR Assigned_To_3rd_Assignee__c = :userId)';
                }
                
            }
            
        }
        else if(selectedTab == 'All')
        {
            if(viewPicklistValue != 'All')
            {           
                if(searchFilterStr != '' && viewPicklistValue == 'open')
                {	
                    searchFilterStr = '%'+ searchFilterStr +'%';
                    totalEmailTrackerRecords=[Select COUNT() From Email_Tracker__c WHERE (Ticket__c Like :searchFilterStr OR Email_Subject__c LIKE :searchFilterStr OR Primary_Ticket_Number__c LIKE :searchFilterStr ) AND (Status__c IN :openStatus)];
                    query=query+' WHERE (Ticket__c Like :searchFilterStr OR Email_Subject__c LIKE :searchFilterStr OR Primary_Ticket_Number__c LIKE :searchFilterStr) AND (Status__c IN :openStatus)';
                }
                else if(searchFilterStr != '' && viewPicklistValue == 'closed')
                {	
                    searchFilterStr = '%'+ searchFilterStr +'%';
                    totalEmailTrackerRecords=[Select COUNT() From Email_Tracker__c WHERE (Ticket__c Like :searchFilterStr OR Email_Subject__c LIKE :searchFilterStr OR Primary_Ticket_Number__c LIKE :searchFilterStr) AND (Status__c NOT IN :openStatus)];
                    query=query+' WHERE (Ticket__c Like :searchFilterStr OR Email_Subject__c LIKE :searchFilterStr OR Primary_Ticket_Number__c LIKE :searchFilterStr ) AND (Status__c NOT IN :openStatus)';
                }
                else if(searchFilterStr == '' && viewPicklistValue == 'open')
                {
                    totalEmailTrackerRecords=[Select COUNT() From Email_Tracker__c WHERE Status__c IN :openStatus];
                    query=query+' WHERE Status__c IN :openStatus';
                }
                else if(searchFilterStr == '' && viewPicklistValue == 'closed')
                {
                    totalEmailTrackerRecords=[Select COUNT() From Email_Tracker__c WHERE Status__c NOT IN :openStatus];
                    query=query+' WHERE Status__c NOT IN :openStatus';
                }
                
            }
            else if(viewPicklistValue == 'All')
            {
                if(searchFilterStr != '')
                {	
                    searchFilterStr = '%'+ searchFilterStr +'%';
                    totalEmailTrackerRecords=[Select COUNT() From Email_Tracker__c WHERE Ticket__c Like :searchFilterStr OR Email_Subject__c Like :searchFilterStr OR Primary_Ticket_Number__c LIKE :searchFilterStr];
                    query=query+' WHERE Ticket__c Like :searchFilterStr OR Email_Subject__c LIKE :searchFilterStr OR Primary_Ticket_Number__c LIKE :searchFilterStr';
                }                
            }
            
        }
        
        
        query=query + ' ORDER BY isNewFlag__c DESC,Latest_Mail_Date__c DESC NULLS LAST LIMIT :pageLimit OFFSET :off';
        Map<String,Object> response = new Map<String,Object>();
        list<Email_Tracker__c> emailTrackerList = Database.query(query);   
        response.put('pageLimit',pageLimit);
        response.put('pageNumber',pageNumber);
        response.put('recordStart',off + 1);
        response.put('recordEnd',totalEmailTrackerRecords >= recordEnd ? recordEnd : totalEmailTrackerRecords);
        response.put('totalEmailTrackerRecords',totalEmailTrackerRecords);
        response.put('emailTrackerList',emailTrackerList);
        return response;
    }
    
    //function to get email tracke
    @AuraEnabled
    public static Email_Tracker__c getEmailTracker(Id emailTrackerId)
    {
        return ([SELECT Id,Ticket__c,  Email_Category__c, Email_Subject__c, Requester_Name__c, Requester_Org__c, Priority__c,
                 Status__c, Complete__c, Assigned_To_1st_Assignee__c, Assigned_To_2nd_Assignee__c, isNewFlag__c,
                 Assigned_To_3rd_Assignee__c, Date_Received__c, Completion_Date__c, TAT__c, Remarks__c
                 FROM Email_Tracker__c where id=:emailTrackerId]);       
    }
    
    @AuraEnabled
    public static Email_Tracker__c updateEmailTracker(string emailTrackerId, string changedPicklistValue, string typeOfPicklist, Decimal changedPicklistValuePercent){
        
        Email_Tracker__c updateEmailTracker = new Email_Tracker__c();
        updateEmailTracker.Id = emailTrackerId;
        if(typeOfPicklist=='Email Category'){
            updateEmailTracker.Email_Category__c = changedPicklistValue;
        }
        else if(typeOfPicklist=='Requestor Org'){
            updateEmailTracker.Requester_Org__c = changedPicklistValue;
        }
        else if(typeOfPicklist=='Priority'){
            updateEmailTracker.Priority__c = changedPicklistValue;
        }
        else if(typeOfPicklist=='Status'){
            updateEmailTracker.Status__c = changedPicklistValue;
        }
        else if(typeOfPicklist=='remarks'){
            updateEmailTracker.Remarks__c = changedPicklistValue;
        }
        else if(typeOfPicklist=='RequesterName'){
            updateEmailTracker.Requester_Name__c = changedPicklistValue;
        }
        else if(typeOfPicklist=='PercentComplete'){
            updateEmailTracker.Complete__c = changedPicklistValuePercent;
        }
        else if(typeOfPicklist=='firstAssignee'){
            updateEmailTracker.Assigned_To_1st_Assignee__c = changedPicklistValue;
        }
        else if(typeOfPicklist=='secondAssignee'){
            updateEmailTracker.Assigned_To_2nd_Assignee__c = changedPicklistValue;
        }
        else if(typeOfPicklist=='thirdAssignee'){
            updateEmailTracker.Assigned_To_3rd_Assignee__c = changedPicklistValue;
        }
        update updateEmailTracker;
        updateEmailTracker=getEmailTrackerData.getEmailTracker(emailTrackerId);
        
        return updateEmailTracker;
        
    }

    @AuraEnabled
    public static String mergeRecords(String mergeRecord){
        try{
            String primaryRecordId;
            String primaryTicketNumber;
            Set<Id> duplicateRecordIds = new Set<Id>();
            List<Object> objectList = (List<Object>)JSON.deserializeUntyped(mergeRecord);
            system.debug(objectList);
            For(Object ob : objectList){
                Map<String,Object> data = (Map<String,Object>)ob;
                if(data.get('primary') == true){
                    primaryRecordId = (String)data.get('Id');
                    primaryTicketNumber = (String)data.get('Ticket__c');
                }
                else{
                    if(String.isNotBlank((String)data.get('Id'))){
                        duplicateRecordIds.add((Id)data.get('Id'));
                    }
                }
            }
            if(!duplicateRecordIds.isEmpty()){
                List<Mail_Chain__c> mailChainRecords = [SELECT Id, Name, Email_Tracker__c, Thread_ID__c
                                                            FROM Mail_Chain__c
                                                            WHERE Email_Tracker__c IN : duplicateRecordIds];
            
                for(Mail_Chain__c mcRecord : mailChainRecords){
                    mcRecord.Email_Tracker__c = primaryRecordId;
                }                
                update mailChainRecords;
                List<Email_Tracker__c> lstEmailtracker = [SELECT Id,Status__c,Primary_Record_Detail__c
                                                                FROM Email_Tracker__c WHERE Id IN : duplicateRecordIds ];
                
                for(Email_Tracker__c emailtracker : lstEmailtracker){
                    emailtracker.Status__c = 'Merged';
                    emailtracker.Primary_Ticket_Number__c = primaryTicketNumber;
                    emailtracker.Primary_Record_Detail__c = primaryRecordId ;
                }
                update lstEmailtracker;
            }
            return 'success';
        }
        catch(Exception ex){
            System.debug(ex.getMessage());
            return 'error'+ex.getMessage();
        }
    }
    
    
}