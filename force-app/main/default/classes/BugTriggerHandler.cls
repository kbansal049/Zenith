public class BugTriggerHandler {
    
    public static void afterInsert(List<Bug__c> newBugList){
     
        Map<String, Triggers_Switch__c> tsmap = Triggers_Switch__c.getAll(); 
        if(tsmap.containsKey('Execute_CR_Bug_Update') && tsmap.get('Execute_CR_Bug_Update') != null && tsmap.get('Execute_CR_Bug_Update').Execute__c && !TriggerUtility.isUpdateBugCreateUserStoryExecuted()){
            BugTriggerHandler.createBugToCreateUserStory(newBugList,null);
        }
        
    }
    public static void afterUpdate(List<Bug__c> newBugList, Map<Id, Bug__c> oldMap){
        Map<String, Triggers_Switch__c> tsmap = Triggers_Switch__c.getAll(); 
        if(tsmap.containsKey('Execute_CR_Bug_Update') && tsmap.get('Execute_CR_Bug_Update') != null && tsmap.get('Execute_CR_Bug_Update').Execute__c && !TriggerUtility.isUpdateBugCreateUserStoryExecuted()){
            BugTriggerHandler.createBugToCreateUserStory(newBugList,oldMap);
        }
        
    }
    public static void createBugToCreateUserStory(List<Bug__c> newBugList,Map<Id, Bug__c> oldMap){
        
        set<Id> BugIds = new Set<Id>();
        Map<Id,id> bugIdsAndCrIds = new Map<Id,Id>();
        for(Bug__c bugObj : newBugList){
            
            if((Trigger.isinsert || (Trigger.isUpdate && oldMap.get(bugObj.Id)!=null && bugObj.status__c != oldMap.get(bugobj.Id).status__c)) && bugObj.Type__c=='Bug' && bugObj.Status__c=='Work In Progress'){
                BugIds.add(bugObj.id);  
            }
        }
        list<Bug__c> bugsObjData =  [SELECT id,Copado_User_Story__c,Assignee__r.Developer_Sandbox_Name__c  ,Change_Request__r.id,Change_Request__r.Stage__c,Change_Request__r.Status__c,Change_Request__r.Summary__c,Change_Request__r.Copado_User_Story__c,Change_Request__r.Developer_Sandbox_Name__c,Change_Request__r.Estimated_Development_Efforts__c,Change_Request__r.Actual_Dev_Efforts__c,Change_Request__r.Dev_Estimated_Efforts__c, Summary__c, Status__c   FROM Bug__c where id in:BugIds ];
        if(bugsObjData.size()>0)
        	CreateUserStoryfromCR(bugsObjData);
    }
    public static void CreateUserStoryfromCR(List<Bug__c> newBugList){
        system.debug('inside CreateUserStoryfromCR metod ');
        List<Tracker_Change_Request__c> newCRListtoupdate = new List<Tracker_Change_Request__c>();
        List<copado__User_Story__c> UserStoryList = new List<copado__User_Story__c>();
        List<Bug__c> newBugUpdateList = new List<Bug__c>();
        Map<id,copado__User_Story__c> CRidandUserStory= new Map<id,copado__User_Story__c>();
        Map<id,Bug__c> CRIdAndBugMap= new Map<id,Bug__c>();
        for(Bug__c BugObj: newBugList){
            System.debug('****' + BugObj.Change_Request__r.Copado_User_Story__c);
            System.debug('****' + BugObj.Copado_User_Story__c);
            if(BugObj.Change_Request__r.Copado_User_Story__c!=null && bugObj.Copado_User_Story__c==null && bugObj.Status__c == 'Work In Progress' ){
                Id orgID = null;
                Id envId = null;
                try  {
                    //Code to get enviroment from org.
                    if(BugObj.Assignee__r.Developer_Sandbox_Name__c != null)  {
                        List<copado__Org__c > lstOrgs = [select id, copado__Environment__c  from copado__Org__c  where id =:BugObj.Change_Request__r.Developer_Sandbox_Name__c]; 
                        if(lstOrgs.size() > 0)  {
                            orgID = BugObj.Assignee__r.Developer_Sandbox_Name__c;
                            envId = lstOrgs.get(0).copado__Environment__c;
                        }
                    }
                }catch(Exception ex)  {
                    
                }
                String projId = System.Label.Default_Copado_Project;
                if(Test.isRunningTest())  {
                    projId = null;
                }
                Id usRecordID = Schema.SObjectType.copado__User_Story__c.getRecordTypeInfosByDeveloperName().get('User_Story').getRecordTypeId();
                copado__User_Story__c UserStory =new copado__User_Story__c(Bug__c=BugObj.id,Change_Request__c  = BugObj.Change_Request__r.Id, copado__Org_Credential__c=orgID,copado__Environment__c=envId,copado__User_Story_Title__c=BugObj.Summary__c,copado__Project__c=projId,RecordTypeId=usRecordID,copado__Status__c='In Progress'   ); 
                //Estimated Development Efforts (CR) , Initial_Estimates__c  (US)
                UserStoryList.add(UserStory);
                CRIdAndBugMap.put(BugObj.id,BugObj);
                CRidandUserStory.put(BugObj.id,UserStory);
            }
        }
        system.debug('UserStoryList '+UserStoryList);
        system.debug('CRidandUserStory '+CRidandUserStory);
       List<copado__Team_Dependency__c> lstParents = new List<copado__Team_Dependency__c>();  
        if(UserStoryList.size()>0){
            insert CRidandUserStory.values();
            TriggerUtility2.CreateUserStoryfromCRExecuted(); 
            for(id CRid: CRidandUserStory.keyset()){
                if(CRidandUserStory.get(CRid)!=null){
                   if(CRIdAndBugMap.get(CRid)!=null){
                    		CRIdAndBugMap.get(CRid).Copado_User_Story__c = CRidandUserStory.get(CRid).id;
                      	newBugUpdateList.add(CRIdAndBugMap.get(CRid));
                       copado__Team_Dependency__c ct = new copado__Team_Dependency__c();
                       ct.copado__Dependent_User_Story__c  = CRidandUserStory.get(CRid).id;
                       ct.copado__Provider_User_Story__c  = CRIdAndBugMap.get(CRid).Change_Request__r.Copado_User_Story__c;
                       lstParents.add(ct);
                	}
                   
                }
            }
            
            if(newBugUpdateList.size()>0){
                update newBugUpdateList;
                insert lstParents;
            }
        }
        system.debug('bugList '+newBugUpdateList);
        system.debug('UserStoryList '+UserStoryList);
    }
    
}