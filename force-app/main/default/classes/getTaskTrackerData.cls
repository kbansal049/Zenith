public without sharing class getTaskTrackerData {
    
    @AuraEnabled
    public static List<object> getMetadataPicklists()
    {
        List<object> response=[SELECT Id, Label, User_Id_c__c FROM Task_Tracker_Assignee__mdt];
        return response;
    }  
    @AuraEnabled
    public static object getNextTaskTrackers(Integer pageNumber,Integer pageLimit,
                                             String viewPicklistValue, String searchFilterStr, String selectedTab)
    { 
        // String viewPicklistValue='All';
        Integer off = (pageNumber - 1) * pageLimit;
        Integer recordEnd = pageLimit * pageNumber;
        Integer totalTaskTrackerRecords;
        Map<String,String> userMap = new Map<String,String>();
        userMap=OrderTrackerDashboard.getUserInformation();
        String userId=userMap.get('UserId');
        String query = 'SELECT Id, Name, CreatedById,CreatedBy.Name, Order_Tracker__c, Assignee__c,is_Appoved_Mail_Sent__c, Customer_Name__c, SO_Number__c,Task_Name__c, Actionable_Item__c, Ticket_Type__c, Status__c, Ticket_No__c, Schedule_date__c FROM Task_Tracker__c WHERE (is_Appoved_Mail_Sent__c=true) ';            
        if(selectedTab == 'Assigned To Me')
        {
            if(viewPicklistValue != 'All')
            {           
                if(searchFilterStr != '' && viewPicklistValue == 'open')
                {	
                    searchFilterStr = '%'+ searchFilterStr +'%';
                    totalTaskTrackerRecords=[Select COUNT() From Task_Tracker__c WHERE (is_Appoved_Mail_Sent__c=true) AND (Ticket_No__c LIKE :searchFilterStr OR Customer_Name__c LIKE :searchFilterStr OR SO_Number__c LIKE :searchFilterStr ) AND (Status__c != 'Completed' AND Status__c != 'Duplicate') AND Assignee__c =:userId];
                    query=query+' AND (Ticket_No__c LIKE :searchFilterStr OR Customer_Name__c LIKE :searchFilterStr OR SO_Number__c LIKE :searchFilterStr) AND (Status__c != \'Completed\' AND Status__c != \'Duplicate\') AND Assignee__c =:userId ORDER BY Schedule_date__c ASC NULLS LAST LIMIT :pageLimit OFFSET :off';
                }
                else if(searchFilterStr != '' && viewPicklistValue == 'closed')
                {	
                    searchFilterStr = '%'+ searchFilterStr +'%';
                    totalTaskTrackerRecords=[Select COUNT() From Task_Tracker__c WHERE (is_Appoved_Mail_Sent__c=true) AND (Ticket_No__c LIKE :searchFilterStr OR Customer_Name__c LIKE :searchFilterStr OR SO_Number__c LIKE :searchFilterStr) AND (Status__c = 'Completed' OR Status__c = 'Duplicate') AND Assignee__c =:userId];
                    query=query+' AND (Ticket_No__c LIKE :searchFilterStr OR Customer_Name__c LIKE :searchFilterStr OR SO_Number__c LIKE :searchFilterStr ) AND (Status__c = \'Completed\' OR Status__c = \'Duplicate\') AND Assignee__c =:userId ORDER BY Schedule_date__c ASC NULLS LAST LIMIT :pageLimit OFFSET :off';
                }
                else if(searchFilterStr == '' && viewPicklistValue == 'open')
                {
                    totalTaskTrackerRecords=[Select COUNT() From Task_Tracker__c WHERE (is_Appoved_Mail_Sent__c=true) AND (Status__c != 'Completed' AND Status__c != 'Duplicate') AND Assignee__c =:userId];
                    query=query+' AND (Status__c != \'Completed\' AND Status__c != \'Duplicate\') AND Assignee__c =:userId ORDER BY Schedule_date__c ASC NULLS LAST LIMIT :pageLimit OFFSET :off';
                }
                else if(searchFilterStr == '' && viewPicklistValue == 'closed')
                {
                    totalTaskTrackerRecords=[Select COUNT() From Task_Tracker__c WHERE (is_Appoved_Mail_Sent__c=true) AND (Status__c = 'Completed' OR Status__c = 'Duplicate')AND Assignee__c =:userId];
                    query=query+' AND (Status__c = \'Completed\' OR Status__c = \'Duplicate\') AND Assignee__c =:userId ORDER BY Schedule_date__c ASC NULLS LAST LIMIT :pageLimit OFFSET :off';
                }
                
            }
            else if(viewPicklistValue == 'All')
            {
                if(searchFilterStr != '')
                {	
                    searchFilterStr = '%'+ searchFilterStr +'%';
                    totalTaskTrackerRecords=[Select COUNT() From Task_Tracker__c WHERE (is_Appoved_Mail_Sent__c=true) AND (Ticket_No__c LIKE :searchFilterStr OR Customer_Name__c LIKE :searchFilterStr OR SO_Number__c LIKE :searchFilterStr) AND Assignee__c =:userId ];
                    query=query+' AND (Ticket_No__c LIKE :searchFilterStr OR Customer_Name__c LIKE :searchFilterStr OR SO_Number__c LIKE :searchFilterStr) AND Assignee__c =:userId ORDER BY Schedule_date__c ASC NULLS LAST LIMIT :pageLimit OFFSET :off';
                }
                else{
                    totalTaskTrackerRecords=[Select COUNT() From Task_Tracker__c WHERE (is_Appoved_Mail_Sent__c=true) AND Assignee__c =:userId];
                    query=query + ' AND Assignee__c =:userId ORDER BY Schedule_date__c ASC NULLS LAST LIMIT :pageLimit OFFSET :off';
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
                    totalTaskTrackerRecords=[Select COUNT() From Task_Tracker__c WHERE (is_Appoved_Mail_Sent__c=true) AND (Ticket_No__c LIKE :searchFilterStr OR Customer_Name__c LIKE :searchFilterStr OR SO_Number__c LIKE :searchFilterStr ) AND (Status__c != 'Completed' AND Status__c != 'Duplicate')];
                    query=query+' AND (Ticket_No__c LIKE :searchFilterStr OR Customer_Name__c LIKE :searchFilterStr OR SO_Number__c LIKE :searchFilterStr) AND (Status__c != \'Completed\' AND Status__c != \'Duplicate\') ORDER BY Schedule_date__c ASC NULLS LAST LIMIT :pageLimit OFFSET :off';
                }
                else if(searchFilterStr != '' && viewPicklistValue == 'closed')
                {	
                    searchFilterStr = '%'+ searchFilterStr +'%';
                    totalTaskTrackerRecords=[Select COUNT() From Task_Tracker__c WHERE (is_Appoved_Mail_Sent__c=true) AND (Ticket_No__c LIKE :searchFilterStr OR Customer_Name__c LIKE :searchFilterStr OR SO_Number__c LIKE :searchFilterStr) AND (Status__c = 'Completed' OR Status__c = 'Duplicate')];
                    query=query+' AND (Ticket_No__c LIKE :searchFilterStr OR Customer_Name__c LIKE :searchFilterStr OR SO_Number__c LIKE :searchFilterStr ) AND (Status__c = \'Completed\' OR Status__c = \'Duplicate\') ORDER BY Schedule_date__c ASC NULLS LAST LIMIT :pageLimit OFFSET :off';
                }
                else if(searchFilterStr == '' && viewPicklistValue == 'open')
                {
                    totalTaskTrackerRecords=[Select COUNT() From Task_Tracker__c WHERE (is_Appoved_Mail_Sent__c=true) AND (Status__c != 'Completed' AND Status__c != 'Duplicate') ];
                    query=query+' AND (Status__c != \'Completed\' AND Status__c != \'Duplicate\') ORDER BY Schedule_date__c ASC NULLS LAST LIMIT :pageLimit OFFSET :off';
                }
                else if(searchFilterStr == '' && viewPicklistValue == 'closed')
                {
                    totalTaskTrackerRecords=[Select COUNT() From Task_Tracker__c WHERE (is_Appoved_Mail_Sent__c=true) AND (Status__c = 'Completed' OR Status__c = 'Duplicate')];
                    query=query+' AND (Status__c = \'Completed\' OR Status__c = \'Duplicate\') ORDER BY Schedule_date__c ASC NULLS LAST LIMIT :pageLimit OFFSET :off';
                }
                
            }
            else if(viewPicklistValue == 'All')
            {
                if(searchFilterStr != '')
                {	
                    searchFilterStr = '%'+ searchFilterStr +'%';
                    totalTaskTrackerRecords=[Select COUNT() From Task_Tracker__c WHERE (is_Appoved_Mail_Sent__c=true) AND (Ticket_No__c LIKE :searchFilterStr OR Customer_Name__c LIKE :searchFilterStr OR SO_Number__c LIKE :searchFilterStr) ];
                    query=query+' AND (Ticket_No__c LIKE :searchFilterStr OR Customer_Name__c LIKE :searchFilterStr OR SO_Number__c LIKE :searchFilterStr) ORDER BY Schedule_date__c ASC NULLS LAST LIMIT :pageLimit OFFSET :off';
                }
                else{
                    totalTaskTrackerRecords=[Select COUNT() From Task_Tracker__c WHERE (is_Appoved_Mail_Sent__c=true)];
                    query=query + ' ORDER BY Schedule_date__c ASC NULLS LAST LIMIT :pageLimit OFFSET :off';
                }                
            }            
        }

        //query=query + ' ORDER BY Schedule_date__c ASC NULLS LAST LIMIT :pageLimit OFFSET :off';
        Map<String,Object> response = new Map<String,Object>();
        list<Task_Tracker__c> taskTrackerList = Database.query(query);   
        response.put('pageLimit',pageLimit);
        response.put('pageNumber',pageNumber);
        response.put('recordStart',off + 1);
        response.put('recordEnd',totalTaskTrackerRecords >= recordEnd ? recordEnd : totalTaskTrackerRecords);
        response.put('totalTaskTrackerRecords',totalTaskTrackerRecords);
        response.put('taskTrackerList',taskTrackerList);
        return response;
    }
    
    
    @AuraEnabled
    public static Task_Tracker__c updateTaskTracker(string taskTrackerId, string changedPicklistValue, string typeOfPicklist){
        
      
            Task_Tracker__c updatTaskTracker = new Task_Tracker__c();
            updatTaskTracker.Id = taskTrackerId;
            if(typeOfPicklist=='Ticket Type'){
                updatTaskTracker.Ticket_Type__c = changedPicklistValue;
            }
            else if(typeOfPicklist=='Status'){
                updatTaskTracker.Status__c = changedPicklistValue;
            }
            else if(typeOfPicklist=='Assignee'){
                updatTaskTracker.Assignee__c = changedPicklistValue;
            }
            else if(typeOfPicklist=='Customer'){
                updatTaskTracker.Customer_Name__c = changedPicklistValue;
            }
            update updatTaskTracker;  
             updatTaskTracker=getTaskTracker(taskTrackerId);
            return updatTaskTracker;
        
    }
    
    @AuraEnabled
    public static void createTasksFromOrderTracker(List<Task_Tracker__c> updatedTasksList,List<Task_Tracker__c> deletedTasksList)
    { 
        if(!updatedTasksList.isEmpty())
            upsert updatedTasksList;
        if(!deletedTasksList.isEmpty())
            delete deletedTasksList;
    }
    
    @AuraEnabled
    public static List<Task_Tracker__c> getTasks(Id orderTrackerId)
    { 
        return ([Select Id,Task_Name__c ,Ticket_Type__c ,Actionable_Item__c,Schedule_date__c from Task_Tracker__c where order_tracker__c = :orderTrackerId]);
    }
    
    @AuraEnabled
    public static List<task_tracker__c> updateTasksFromReply(Id orderTrackerId)
    { 
        List<task_tracker__c> oldTaskTrackers = [Select Id,Task_Name__c ,Ticket_Type__c ,Actionable_Item__c,Schedule_date__c,is_Appoved_Mail_Sent__c from Task_Tracker__c where order_tracker__c = :orderTrackerId];
        List<task_tracker__c> updateTaskTrackers = new List<task_tracker__c>();
        for(task_tracker__c tasks:oldTaskTrackers)
        {
            if(!tasks.is_Appoved_Mail_Sent__c)
            {
                tasks.is_Appoved_Mail_Sent__c=true;
                updateTaskTrackers.add(tasks);
            }
        }
            
        update updateTaskTrackers;
        return oldTaskTrackers;
    }
    
    
    @AuraEnabled
    public static Map<string,List<sObject>> getSearchTicketNumber(String searchTerm) {
        Map<string,List<sObject>> mapTrackerList = new Map<string,List<sObject>>();
        List<Order_Tracker__c> orderTrackerList = [Select Id,name,End_User__c,SO__c,Ticket__c from Order_Tracker__c where Ticket__c = :searchTerm];
        List<Email_Tracker__c> emailTrackerList = new List<Email_Tracker__c>();
        if(orderTrackerList.isEmpty()){
            emailTrackerList = [Select Id,name from Email_Tracker__c where Ticket__c = :searchTerm];
            if(!emailTrackerList.isEmpty()){
                mapTrackerList.put('emailTracker', emailTrackerList);
            }
        }
        else{
            mapTrackerList.put('orderTracker', orderTrackerList);
        }
        return mapTrackerList;
        
    }
    
    @AuraEnabled
    public static Task_Tracker__c getTaskTracker(Id taskTrackerId)
    {
        return ([SELECT Id, Name, CreatedById,CreatedBy.Name, Order_Tracker__c, Assignee__c,is_Appoved_Mail_Sent__c, Customer_Name__c, SO_Number__c,Task_Name__c, Actionable_Item__c, Ticket_Type__c, Status__c, Ticket_No__c, Schedule_date__c FROM Task_Tracker__c WHERE id=:taskTrackerId]);
    }
    
    
}