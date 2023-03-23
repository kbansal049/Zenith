public class ChangeRequestTriggerUtility {
    public static void updateParentChangeRequest(List<Tracker_Change_Request__c> newCRList){
        List<String> listOfcase = new List<String>();
        List<Case> listOfParentCase = new List<Case>();
        for(Tracker_Change_Request__c currCR : newCRList){
            if(currCR.Case__c != null){
                listOfCase.add(currCR.Case__c);
            }
        }
        if(!listOfCase.isEmpty()){
            List<Tracker_Change_Request__c> existingCR = new List<Tracker_Change_Request__c>();
            Map<Id,Id> mapOfCaseAndParentCR = new Map<Id,Id>();
            
            listOfParentCase = [select id, Business_Analyst__c, Change_Request__c from Case where Id in:listOfCase AND RecordType.name='Sales Operations Helpdesk' AND Change_Request__c !=null];
            
            for(Case parentCase : listOfParentCase){
                if(parentCase.Change_request__c != null){
                    mapOfCaseAndParentCR.put(parentCase.Id, parentCase.Change_request__c);
                }
            }

            for(Tracker_Change_Request__c currCR : newCRList){
                if(!mapOfCaseAndParentCR.isEmpty() && mapOfCaseAndParentCR.containsKey(currCR.Case__c) && mapOfCaseAndParentCR.get(currCR.Case__c) !=null){
                    currCR.Parent_Request__c = mapOfCaseAndParentCR.get(currCR.Case__c);
                }
            }
            
        }
        TriggerUtility.UpdateParentChangeRequestExecuted();
    }


    public static void updateBaAndCrOnCase(List<Tracker_Change_Request__c> newCRList){
        Map<Id, Tracker_Change_Request__c> mapOfCaseAndChangeRequest = new Map<Id, Tracker_Change_Request__c>();
        for(Tracker_Change_Request__c currCR : newCRList){
            system.debug(currCR.Case__c);
            if(currCR.Case__c != null){
                mapOfCaseAndChangeRequest.put(currCR.Case__c, currCR);
            }
        }
        
        if(!mapOfCaseAndChangeRequest.isEmpty()){
            List<Case> parentCaseData = new List<Case>();
            List<Case> listOfCaseToUpdate = new List<Case>();
            parentCaseData = [select id, Change_request__c,Change_request__r.Parent_request__c, Business_Analyst__c from Case where Id in:mapOfCaseAndChangeRequest.keyset() AND RecordType.name='Sales Operations Helpdesk'];
            for(Case currCase : parentCaseData){
                if(mapOfCaseAndChangeRequest.containsKey(currCase.Id) && mapOfCaseAndChangeRequest.get(currCase.Id) !=null){
                    if(currCase.Change_Request__c == null){
                        currCase.Change_request__c = mapOfCaseAndChangeRequest.get(currCase.Id).Id;
                    }
                    if(currCase.Business_Analyst__c!=null  && mapOfCaseAndChangeRequest.get(currCase.Id).Business_Analyst__c!=null && (currCase.Change_Request__c==mapOfCaseAndChangeRequest.get(currCase.Id).Id) && currCase.Business_Analyst__c != mapOfCaseAndChangeRequest.get(currCase.Id).Business_Analyst__c){
                        currCase.Business_Analyst__c = mapOfCaseAndChangeRequest.get(currCase.Id).Business_Analyst__c;
                    }
                    else if(currCase.Business_Analyst__c == null && mapOfCaseAndChangeRequest.get(currCase.Id).Parent_Request__c==null){
                        currCase.Business_Analyst__c = mapOfCaseAndChangeRequest.get(currCase.Id).Business_Analyst__c;
                    }
                    listOfCaseToUpdate.add(currCase);
                }
            }
            if(!listOfCaseToUpdate.isEmpty()){
                TriggerUtility.SyncBAOnCrExecuted();
                update listOfCaseToUpdate;
            }
        }
        TriggerUtility.UpdateBaCROnCaseExecuted();
    }


    public static void syncBusinessAnalyst(List<Tracker_Change_Request__c> newCRList, Map<Id, Tracker_Change_Request__c> oldMap){
        List<Case> listOfCase = new List<Case>();
        Map<Id,Id> mapOfCaseAndCrBSA = new Map<Id,Id>();
        for(Tracker_Change_Request__c currCR : newCRList){
                if(currCR.Case__c != null && oldMap.get(currCR.Id) != null && currCR.Business_Analyst__c != oldMap.get(currCr.Id).Business_Analyst__c && currCR.Parent_Request__c ==null){
                    mapOfCaseAndCrBSA.put(currCR.case__c, currCR.Business_Analyst__c);
                    
                }
        }
        if(!mapOfCaseAndCrBSA.isEmpty()){
            List<case> listOfCaseToUpdate = new List<case>();
            for(Case currCase : [select id, Business_Analyst__c from Case where Id IN:mapOfCaseAndCrBSA.keySet() AND RecordType.Name='Sales Operations Helpdesk']){
                if(mapOfCaseAndCrBSA.containsKey(currCase.Id) && mapOfCaseAndCrBSA.get(currCase.Id) !=null){
                    currCase.Business_Analyst__c = mapOfCaseAndCrBSA.get(currCase.Id);
                    listOfCaseToUpdate.add(currCase);
                    
                }
            }
            if(!listOfCaseToUpdate.isEmpty()){
                TriggerUtility.SyncBAOnCrExecuted();
                update listOfCaseToUpdate;
            }
        }
        TriggerUtility.SyncBAOnCaseExecuted();
    }
    
    //Added By Gurjinder : CR# 1372 : Start
    public static void CreateUserStoryfromCR(List<Tracker_Change_Request__c> newCRList, Map<Id, Tracker_Change_Request__c> oldMap){
        system.debug('inside CreateUserStoryfromCR metod ');
        List<Tracker_Change_Request__c> newCRListtoupdate = new List<Tracker_Change_Request__c>();
        List<copado__User_Story__c> UserStoryList = new List<copado__User_Story__c>();
        List<copado__User_Story__c> UserStoryListToUpdate = new List<copado__User_Story__c>();
        Map<id,copado__User_Story__c> CRidandUserStory= new Map<id,copado__User_Story__c>();
        for(Tracker_Change_Request__c CR: newCRList){
            system.debug('CR   '+CR);
            
            if(CR.Stage__c=='Development'&& CR.Status__c=='In Dev' && CR.Copado_User_Story__c==null){
                Id orgID = null;
                Id envId = null;
                try  {
                    //Code to get enviroment from org.
                   if(CR.Developer_Sandbox_Name__c != null)  {
                   	   List<copado__Org__c > lstOrgs = [select id, copado__Environment__c  from copado__Org__c  where id =:CR.Developer_Sandbox_Name__c ]; 
                       if(lstOrgs.size() > 0)  {
                           orgID = CR.Developer_Sandbox_Name__c;
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
                copado__User_Story__c UserStory =new copado__User_Story__c(Change_Request__c=CR.id,copado__Org_Credential__c=orgID,copado__Environment__c=envId,copado__User_Story_Title__c=CR.Summary__c,copado__Project__c=projId,RecordTypeId=usRecordID,Dev_Estimated_Efforts__c=CR.Dev_Estimated_Efforts__c, Initial_Estimates__c=CR.Estimated_Development_Efforts__c,copado__Status__c='In Progress'  ); 
                //Estimated Development Efforts (CR) , Initial_Estimates__c  (US)
                UserStoryList.add(UserStory);
                CRidandUserStory.put(CR.id,UserStory);
            }else if(CR.Stage__c == 'Ready for Release' && CR.Copado_User_Story__c != null) {
                  copado__User_Story__c cp = new copado__User_Story__c();
                  cp.Id = CR.Copado_User_Story__c;
                  cp.Actual_Effort__c  = CR.Actual_Dev_Efforts__c;
	              UserStoryListToUpdate.add(cp);
            }
        }
        system.debug('UserStoryList '+UserStoryList);
        system.debug('CRidandUserStory '+CRidandUserStory);
        if(UserStoryListToUpdate.size() > 0)  {
            update UserStoryListToUpdate;
        }
        if(UserStoryList.size()>0){
            insert CRidandUserStory.values();
            system.debug('CRidandUserStory '+CRidandUserStory);
            TriggerUtility2.CreateUserStoryfromCRExecuted();
            
            for(id CRid: CRidandUserStory.keyset()){
                system.debug('************'+CRidandUserStory.get(CRid));
                if(CRidandUserStory.get(CRid)!=null){
                    Tracker_Change_Request__c newCR =new Tracker_Change_Request__c(id=CRid,Copado_User_Story__c=CRidandUserStory.get(CRid).id);
                    newCRListtoupdate.add(newCR);
                }
            }
            if(newCRListtoupdate.size()>0){
                update newCRListtoupdate;
            }
        }
        system.debug('UserStoryList '+UserStoryList);
    }
    //Added By Gurjinder : CR# 1372 : End
    
    public static void requestChangeStatus(List<Tracker_Change_Request__c> newList,Map<Id,Tracker_Change_Request__c> oldMap){
		
        List<Id> changerId = new List<Id>();
         for (Tracker_Change_Request__c c : newList) {
            if (c.Status__c != null && (oldMap == null || c.Status__c != oldMap.get(c.Id).Status__c || c.Stage__c != oldMap.get(c.Id).Stage__c ) ){
                
                changerId.add(c.id);
            }
        }
        
        List<Audit_Logs__c> listAudit = new List<Audit_Logs__c>();
        List<Audit_Logs__c> listAuditUpdate = new List<Audit_Logs__c>();
        
        List<Tracker_Change_Request__c> lsTrack = [Select id,Name,Status__c,Stage__c,(SELECT id,Start_Date__c,End_Date__c  from Audit_Logs__r WHERE End_Date__c =:null ) from Tracker_Change_Request__c where id in:changerId ];
        
        for(Tracker_Change_Request__c tc : lsTrack){
            Audit_Logs__c ac = new Audit_Logs__c();           
            ac.Name = tc.Name;
            ac.Current_Status__c = tc.Status__c;
            ac.Current_Stage__c = tc.Stage__c;
            ac.Start_Date__c = DateTime.now();     
            ac.Change_Request__c = tc.Id;
            listAudit.add(ac);
            
            for(Audit_Logs__c auc : tc.Audit_Logs__r){
                auc.End_Date__c = ac.Start_Date__c;
                listAuditUpdate.add(auc);
            }
            
        }
        System.debug('----Change Request Trigger----');
        update listAuditUpdate;
        insert listAudit;
    }    
}