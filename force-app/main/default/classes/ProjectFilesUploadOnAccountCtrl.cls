/**
 * Name : ProjectFilesUploadOnAccountCtrl
 * Description : Controller class for ProjectFilesUploadOnAccountCmp LWC
 * Test Class : ProjectFilesUploadOnAccountCtrlTest
 * Initial Author : Ankit Bhatnagar
 */
public with sharing class ProjectFilesUploadOnAccountCtrl {
    public ProjectFilesUploadOnAccountCtrl() {}

    //Added by Ankit Bhatnagar - IBA-191 - Start
    @AuraEnabled
    public static List<ContentDocumentLink> getFileData(String recordId, String fileType) {
        if(String.isNotBlank(recordId) && String.isNotBlank(fileType)) {
            return new List<ContentDocumentLink>([SELECT Id, ContentDocumentId, ContentDocument.FileType, ContentDocument.Owner.Name, ContentDocument.LatestPublishedVersion.CreatedDate, ContentDocument.LatestPublishedVersion.Title  FROM ContentDocumentLink WHERE ContentDocument.LatestPublishedVersion.Project_Product_Type_fileupload__c = :fileType AND LinkedEntityId = :recordId]);
        }
        else {
            return null;
        }
    }
    //Added by Ankit Bhatnagar - IBA-191 - End
}