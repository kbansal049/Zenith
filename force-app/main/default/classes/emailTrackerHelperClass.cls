public without sharing class emailTrackerHelperClass {
    public static void updateCompletedDateBeforeInsert(List<Email_Tracker__c> newEmailTracker){
        Set<String> reqsName=new Set<String>();
        for(Email_Tracker__c et:newEmailTracker)
        {
            reqsName.add(et.Requester_Name__c);   
        }
        Map<String ,String> email2Dept=getDepartment(reqsName);
        for(Email_Tracker__c eTracker : newEmailTracker){
            if(eTracker.Date_Received__c==NULL)
            {
                 eTracker.Date_Received__c = system.now();
            }
            if(eTracker.Status__c=='Completed'){
                eTracker.Completion_Date__c = system.now();
            }
            if(eTracker.Requester_Name__c!=NULL)
            {
                eTracker.Requester_Org__c=setDepartment(eTracker.Requester_Name__c,email2Dept);
            }
        }
    }
    public static void updateCompletedDateBeforeUpdate(List<Email_Tracker__c> newEmailTracker,Map<ID,Email_Tracker__c> oldEmailTrackerMap){
        Set<String> reqsName=new Set<String>();
        for(Email_Tracker__c et:newEmailTracker)
        {
            reqsName.add(et.Requester_Name__c);   
        }
         
        Map<String ,String> email2Dept=getDepartment(reqsName);
        for(Email_Tracker__c eTracker : newEmailTracker){
            
            if(eTracker.Requester_Name__c!=NULL && eTracker.Requester_Name__c!=oldEmailTrackerMap.get(eTracker.Id).Requester_Name__c)
            {
                eTracker.Requester_Org__c=setDepartment(eTracker.Requester_Name__c,email2Dept);
            }
            if(eTracker.Status__c=='Pending Closure' && eTracker.Status__c!=oldEmailTrackerMap.get(eTracker.Id).Status__c)
            {
                eTracker.Soft_Closed__c=true;
            }
            
            if(eTracker.Status__c=='Completed' && oldEmailTrackerMap.get(eTracker.Id).Status__c!='Completed'){
                eTracker.Completion_Date__c =  system.now();
                eTracker.Thread_ID__c = eTracker.Thread_ID__c+'-Closed';
            }
            else if(eTracker.Status__c!='Completed' && oldEmailTrackerMap.get(eTracker.Id).Status__c=='Completed'){
                eTracker.Completion_Date__c = null;
            }
        }        
    }
    
    public static map<String,String> getDepartment(Set<String> reqsNames)
    {
        Map<String ,String> email2Dept=new Map<String,String>();
        List<User> userList=[SELECT Id, Name, Department, Email FROM User WHERE Email IN:reqsNames];
        for(User usr:userList)
        {
            email2Dept.put(usr.Email, usr.Department)  ; 
        }
        
        return email2Dept;
    }
    
    public static string setDepartment(String reqsName,Map<String,String> email2Dept)
    {
        String dept='';
      
        if(email2Dept.containsKey(reqsName) && email2Dept.get(reqsName) != Null)
        {
            dept=email2Dept.get(reqsName);
        }
        else
        {
            dept='Other';
        }
        
        return dept;
    }
    
    
    
}