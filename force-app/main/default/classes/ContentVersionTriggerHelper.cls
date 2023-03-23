public class ContentVersionTriggerHelper{
 
    public static void UpdateEventNotes(List<ContentVersion> CVList){       
 
        Map<id,ContentVersion> ContentDocIdMAP = new Map<id,ContentVersion>();
        
        Map<ID,ID> conVersionDocIDMAP = new Map<ID,ID>();
        Map<id,id> ContentDocIdandCaseID= new Map<id,id>();
        Map<id,id> EmailMessageIDandContentDocId= new Map<id,id>();
        
        MAP<id,Case_Integration__c> patchMAP = new MAP<id,Case_Integration__c>();
        
        for(ContentVersion cv:CVList){
            system.debug('--cv--'+cv);
            if(cv.ContentDocumentId != null){
                conVersionDocIDMAP.put(cv.Id,cv.ContentDocumentId);
            }
            ContentDocIdMAP.put(cv.id, cv);
        }
        
        system.debug('--conVersionDocIDMAP---'+conVersionDocIDMAP);
        
        for (ContentDocumentLink cdl :[SELECT ContentDocumentId, LinkedEntityId FROM 
                                       ContentDocumentLink 
                                       WHERE ContentDocumentId IN:conVersionDocIDMAP.values()])
        {
            if(String.valueof(cdl.LinkedEntityId.getsobjecttype())=='Case'){
                ContentDocIdandCaseID.put(cdl.ContentDocumentId,cdl.LinkedEntityId);
            }
            if(String.valueof(cdl.LinkedEntityId.getsobjecttype())=='EmailMessage'){
                EmailMessageIDandContentDocId.put(cdl.LinkedEntityId,cdl.ContentDocumentId);
            }
            
        }
        system.debug('ContentDocIdandCaseID--'+ContentDocIdandCaseID);
        system.debug('ContentDocIdandEmailMessageID--'+EmailMessageIDandContentDocId);
        
        for(EmailMessage em : [Select id, FromName,RelatedToId,Incoming,TextBody,MessageDate 
                               from emailmessage where Incoming = false and id in :EmailMessageIDandContentDocId.values()])
        {
            if(EmailMessageIDandContentDocId.containsKey(em.id) &&  String.valueof(em.RelatedToId.getsobjecttype())=='Case'){
                ContentDocIdandCaseID.put(EmailMessageIDandContentDocId.get(em.id),em.RelatedToId);
            }
        }
        system.debug('ContentDocIdandCaseID--'+ContentDocIdandCaseID);
        
        if(ContentDocIdandCaseID.size()>0){
            
            MAP<ID,Case_Integration__c> caseIDCaseIntMAP = new MAP<ID,Case_Integration__c>();
            for(Case_Integration__c ci : [Select id,External_ID__c,Case__c from 
                                          Case_Integration__c where case__c != null and case__r.External_Reference__c != null 
                                          and Parent_Incident__c = null and Ticket_Status__c != 'Closed' and
                                          Incident_Type__c = 'Incident' and
                                          case__c in : ContentDocIdandCaseID.values() order by createdDate])
            {
                caseIDCaseIntMAP.put(ci.case__c,ci);
            }
            System.debug('--caseIDCaseIntMAP---'+caseIDCaseIntMAP);
            
            if(caseIDCaseIntMAP.size()>0){
                for(ContentVersion cv:CVList){
                    if(conVersionDocIDMAP.containskey(cv.id) 
                       && conVersionDocIDMAP.get(cv.id) != null
                       && ContentDocIdandCaseID.containskey(conVersionDocIDMAP.get(cv.id))
                      )
                    {
                        Id caseID = ContentDocIdandCaseID.get(conVersionDocIDMAP.get(cv.id));
                        if(caseIDCaseIntMAP.get(caseID) != null){
                            patchMAP.put(cv.id, caseIDCaseIntMAP.get(caseID));
                        }
                    }
                }
            }
        }
        
        System.debug('--ContentVersionTriggerHelper--patchMAP---'+patchMAP);
        System.debug('--userinfo.getUserId()---'+userinfo.getUserId());
        if(patchMAP.size()>0 && userinfo.getUserId() != '0050g000005nUT1AAM'){
             System.enqueueJob(new SiemensIncidentPatchQueue(patchMAP,true));
        }       
    }

    //Added by Ankit Bhatnagar - IBA-191 - Start
    public static void syncProjectFilesOnAccountTask(List<ContentVersion> contentVersions) {
        try {
            Map<String,List<String>> cvProjectMap = new Map<String, List<String>>(); //ProjectID => [ContentVersionId]
            Map<String, ContentVersion> contentVersionMap = new Map<String, ContentVersion>(); 
            Map<String, String> accountProjectMap = new Map<String, String>(); //Project AccountID => ProjectID
            Map<String, Inspire1__Project__c> projectMap = new Map<String, Inspire1__Project__c>();
            Map<String, Task> taskMap = new Map<String, Task>(); //Task Subject => Task 
            List<ContentDocumentLink> cdls = new List<ContentDocumentLink>();
            for(ContentVersion cv : contentVersions) {
                if( String.isNotBlank(cv.FirstPublishLocationId) &&
                    (cv.FirstPublishLocationId.getSObjectType() == inspire1__Project__c.sObjectType) &&
                    String.isNotBlank(cv.title)) { 
                    //File added on an Inspire__Project__c record.
                    if(!cvProjectMap.containsKey(cv.FirstPublishLocationId)) {
                        cvProjectMap.put(cv.FirstPublishLocationId, new List<String>());
                    }
                    cvProjectMap.get(cv.FirstPublishLocationId).add(cv.id);
                    contentVersionMap.put(cv.id, cv);
                }
            }
            if(!cvProjectMap.isEmpty()) {
                for(Inspire1__Project__c project : [ SELECT id,inspire1__Account__c,inspire1__Account__r.TAM_Name_New__c,Project_ID__c,Management_Notes__c
                                                    FROM inspire1__Project__c 
                                                    WHERE id IN :cvProjectMap.keySet() AND inspire1__Account__c!='' AND inspire1__Account__r.TAM_Name_New__c!='']) {
                    accountProjectMap.put(project.Project_ID__c,project.inspire1__Account__c);
                    projectMap.put(project.Id, project);
                }
                if(!accountProjectMap.isEmpty()) {
                    //Fill TaskMap with Existing Tasks
                    for(Task t : [ SELECT id,Subject,AccountId,whoId,OwnerId,ActivityDate,WhatId,Priority,Is_PS_Docs_Updated_on_Task__c FROM Task 
                                WHERE subject IN : accountProjectMap.keyset() AND WhatId IN : accountProjectMap.values()]) {
                        taskMap.put(t.subject, t);
                    }
                    List<Task> newTasks = new List<Task>();
                    //Fill TaskMap with New Tasks
                    for(Inspire1__Project__c pro : projectMap.values()) {
                        if(!taskMap.containsKey(pro.Project_ID__c)) {
                            Task t = new Task(Subject = pro.Project_ID__c, 
                                Description = pro.Management_Notes__c,
                                OwnerId = pro.inspire1__Account__r.TAM_Name_New__c, 
                                ActivityDate = System.today().addDays(7), 
                                WhatId = pro.inspire1__Account__c,
                                Priority = 'Low');
                                newTasks.add(t);
                        }
                    }
                    //insert Tasks
                    if(!newTasks.isEmpty()) {
                        insert newTasks;
                    }
                    for(Task t : newTasks) {
                        taskMap.put(t.subject,t);
                    }
                    System.debug('##taskMap :'+ taskMap);
                    Map<String,Task> tasksToBeUpdated = new Map<String,Task>();
                    for(String projectId : cvProjectMap.keySet()) {
                        for(String cvId : cvProjectMap.get(projectId)) {
                            ContentVersion cv = contentVersionMap.get(cvId);
                            cdls.add(new ContentDocumentLink(ContentDocumentId = cv.ContentDocumentId,
                                LinkedEntityId = taskMap.get(projectMap.get(projectId).Project_ID__c).id,
                                ShareType = 'V',
                                Visibility = 'InternalUsers')
                            );
                        }
                        if(taskMap.containsKey(projectMap.get(projectId).Project_ID__c)) {
                            Task t = taskMap.get(projectMap.get(projectId).Project_ID__c);
                            t.Is_PS_Docs_Updated_on_Task__c = true;
                            if(!tasksToBeUpdated.containsKey(t.id)) {
                                tasksToBeUpdated.put(t.id,t);
                            }
                        }
                    }
                    System.debug('## tasksToBeUpdated'+JSON.serialize(tasksToBeUpdated));
                    if(!cdls.isEmpty()) {
                        insert cdls;
                        if(!tasksToBeUpdated.isEmpty()) {
                            update tasksToBeUpdated.values();
                        }
                    }   
                }
            }
        }
        catch(Exception e) {
            ZscalerErrorLogsUtility.insertlogs('ContentVersionTriggerHelper', 'syncProjectFilesOnAccountTask', 'Apex', UserInfo.getUserId(),
            'Service cloud', e.getStackTraceString(), e.getMessage(), e.getTypeName());
        }
    }
    //Added by Ankit Bhatnagar - IBA-191 - End
}