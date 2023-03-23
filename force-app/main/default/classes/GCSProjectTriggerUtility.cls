public class GCSProjectTriggerUtility {
    public static void UpdateCompletionDate(List<GCS_Project__c> projectList,Map<Id,GCS_Project__c> mapOldProjects){
        for(GCS_Project__c pr:projectList){
            if((mapOldProjects==null && pr.Project_Status__c=='Completed') || (pr.Project_Status__c=='Completed' && mapOldProjects!=null && pr.Project_Status__c != mapOldProjects.get(pr.Id).Project_Status__c )){
                pr.Project_Completion_Date_Actual__c=System.today();
            }
            //Added by Ankit - IBA-630 - Start
            if((pr.Project_Status__c!='Completed' && mapOldProjects!=null && pr.Project_Status__c != mapOldProjects.get(pr.Id).Project_Status__c )) {
                pr.Project_Completion_Date_Actual__c=null;
            }
            //Added by Ankit - IBA-630 - End
        }
    }

    public static void ValidateAttachment(List<GCS_Project__c> projectList,Map<Id,GCS_Project__c> mapOldProjects){
        Map<Id,Id> projectContentDocument = new Map<Id,Id>();
        Set<Id> setOfProjectIds=new Set<Id>();
        for(GCS_Project__c pr:projectList){
            setOfProjectIds.add(pr.Id);
        }
        if(!setOfProjectIds.isEmpty()){
            for(ContentDocumentLink conLink: [select id , LinkedEntityId, ContentDocumentId from ContentDocumentLink where LinkedEntityId IN:setOfProjectIds]){
                projectContentDocument.put(conLink.LinkedEntityId,conLink.ContentDocumentId);
            }
        }     
        for(GCS_Project__c pr:projectList){
            if((!projectContentDocument.containsKey(pr.Id)) && pr.Project_Status__c=='Completed' && pr.Project_Status__c != mapOldProjects.get(pr.Id).Project_Status__c && (pr.Project_Sub_Type__c=='Configuration Audit' ||pr.Project_Sub_Type__c=='Business Continuity Plan')){
                pr.addError('This project cannot be completed until an attachment is added. To add an attachment please go to TAM Weekly->Select View/Edit Project, then upload a file under Notes and Attachments');
            }
        }
    }
    
}