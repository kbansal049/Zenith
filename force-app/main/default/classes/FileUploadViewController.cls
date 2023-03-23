public without sharing class FileUploadViewController{
    
    @AuraEnabled(cacheable=true)
    public static List<file> getRelatedFiles(String recordId){
        List<File> files = new List<File>();

        for(ContentDocumentLink conLink : [SELECT 
                                           ContentDocument.Id, 
                                           ContentDocument.Title, 
                                           ContentDocument.CreatedDate, 
                                           ContentDocument.FileType
                                           FROM ContentDocumentLink 
                                           WHERE LinkedEntityId =: recordId]){
            File file = new File();
            file.Title = conLink.ContentDocument.Title;
            file.Id = conLink.ContentDocument.Id;
            DateTime createdDateWithTime = conLink.ContentDocument.CreatedDate;
            file.CreatedDate = date.newinstance(createdDateWithTime.year(), createdDateWithTime.month(), createdDateWithTime.day());
            file.Type = (conLink.ContentDocument.FileType).toLowerCase();
            files.add(file);
        }
        return files; 
    }
    
    @AuraEnabled
    public static String updateFileOwner(Id contentDocumentId){
        //Change the owner to loggedin user id, then perform the delete operation
        //As only the file owner can delete a Salesforce file. 
        //Or a user with the Modify All Data permission can delete files that are not associated with another file or object.
        Id loggedInUserId = UserInfo.getUserId();
        List<ContentDocument> contentDocumentToUpdateList = [SELECT Id,OwnerId 
                                                   FROM ContentDocument 
                                                   WHERE Id=:contentDocumentId 
                                                   LIMIT 1];
        if(!contentDocumentToUpdateList.isEmpty()){
            contentDocumentToUpdateList[0].OwnerId = loggedInUserId;
            try{
                UPDATE contentDocumentToUpdateList;
                return 'SUCCESS';
            }
            catch(Exception ex){
                throw new AuraHandledException(ex.getMessage());
            }
        }else {
            return 'File does not exist anymore. Please refresh the page.';
        }        
    }

    
    @AuraEnabled
    public static String deleteFileRecord(Id contentDocumentId){
        
        List<ContentDocument> contentDocumentToDeleteList = [SELECT Id,OwnerId 
                                                   FROM ContentDocument 
                                                   WHERE Id=:contentDocumentId 
                                                   LIMIT 1];
        if(!contentDocumentToDeleteList.isEmpty()){
            try{
                DELETE contentDocumentToDeleteList;
                return 'SUCCESS';
            }
            catch(Exception ex){
                throw new AuraHandledException(ex.getMessage());
            }
        }else {
            return 'File does not exist anymore. Please refresh the page.';
        }        
    }
    
    //Added by Ayush Kangar as part of IBA-2879 - Start
    @AuraEnabled
    public static List<file> getRelatedFilesForPOD(String recordId){
        List<File> files = new List<File>();

        for(ContentDocumentLink conLink : [SELECT 
                                           ContentDocument.Id, 
                                           ContentDocument.Title, 
                                           ContentDocument.CreatedDate, 
                                           ContentDocument.FileType,
                                           ContentDocument.LatestPublishedVersion.Source_fileupload__c    
                                           FROM ContentDocumentLink 
                                           WHERE LinkedEntityId =: recordId]){
            File file = new File();
            file.Title = conLink.ContentDocument.Title;
            file.Id = conLink.ContentDocument.Id;
            DateTime createdDateWithTime = conLink.ContentDocument.CreatedDate;
            file.CreatedDate = date.newinstance(createdDateWithTime.year(), createdDateWithTime.month(), createdDateWithTime.day());
            file.Type = (conLink.ContentDocument.FileType).toLowerCase();
            file.SourceFileUpload = conLink.ContentDocument.LatestPublishedVersion.Source_fileupload__c; 
            files.add(file);
        }
        return files; 
    }

    //Used to create the URL for GenericFileUploadLwc.
    @AuraEnabled
    public static string getDocumentUrl(String documentId){
        String fullRecordURL = URL.getSalesforceBaseUrl().toExternalForm() + '/' + documentId;
        return fullRecordURL;
    }

    //Used to Update the URL created from GenericFileUploadLwc on the fields on PS_Questionnaire__c record.
    @AuraEnabled
    public static void updateUrlOnPsqRecord(String url, String recordId,String source){
        PS_Questionnaire__c psq = [select Id,BVA__c,X3_Whys_Link__c,Value_Pyramid__c,POV_Playback_Url__c,POV_Plan__c,Service_Proposal__c,Architecture_Document__c,POV_Test_Cases__c from PS_Questionnaire__c WHERE Id =:recordId LIMIT 1 ];
        switch on source{
            When '3 Whys'{
                psq.X3_Whys_Link__c = url;
            }
            When 'Value Pyramid'{
                psq.Value_Pyramid__c = url;
            }
            When 'POV Playback'{
                psq.POV_Playback_Url__c = url;
            }
            When 'POV Plan'{
                psq.POV_Plan__c = url;
            }   
            When 'POV Test Cases' {
                psq.POV_Test_Cases__c = url;
            }  
            When 'Service Proposal'{
                psq.Service_Proposal__c = url;
            }  
            When 'Architecture Document'{
                psq.Architecture_Document__c = url;
            }  
            When 'BVA'{
                psq.BVA__c  = url;
            }    
        }
        
        update psq;
    }
    
	//Added by Ayush Kangar as part of IBA-2879 - END
    public class File{
        @AuraEnabled public String Title;
        @AuraEnabled public String Type;
        @AuraEnabled public Id Id;
        @AuraEnabled public Date CreatedDate;
        @AuraEnabled public String SourceFileUpload;     //Added by Ayush Kangar as part of IBA-2879
    }
}