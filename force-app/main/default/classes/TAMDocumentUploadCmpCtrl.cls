/**
 * Name : TAMDocumentUploadCmpCtrl
 * Description : Controller class for TAMDocumentUploadCmp LWC
 * Test Class : TAMDocumentUploadCmpCtrlTest
 * Initial Author : Ankit Bhatnagar
 */
public without sharing class TAMDocumentUploadCmpCtrl {
    public TAMDocumentUploadCmpCtrl() {}

    @AuraEnabled
    public static List<ContentDocumentLink> getFileData(Id recordId) {
        if(String.isNotBlank(recordId)) {
            String sObjName = recordId.getSObjectType().getDescribe().getName();  
            String fileParentId = '';
            if(sObjName == 'Account') {
                fileParentId = recordId;
            }
            else if(sObjName == 'TAM_Engagement__c') {
                TAM_Engagement__c engagement = [SELECT id,Account__c FROM TAM_Engagement__c WHERE Id=:recordId];
                fileParentId = engagement.Account__c;
            }
            return new List<ContentDocumentLink>([SELECT Id, ContentDocumentId, ContentDocument.FileType, ContentDocument.Owner.Name, ContentDocument.LatestPublishedVersion.CreatedDate, ContentDocument.LatestPublishedVersion.Title, 
                                                    ContentDocument.LatestPublishedVersion.Project_Product_Type_fileupload__c, ContentDocument.LatestPublishedVersion.Document_Type_fileupload__c  
                                                    FROM ContentDocumentLink WHERE LinkedEntityId = :fileParentId AND
                                                    ContentDocument.LatestPublishedVersion.Document_Type_fileupload__c != '' AND
                                                    ContentDocument.LatestPublishedVersion.Project_Product_Type_fileupload__c != '']);
        }
        else {
            return null;
        }
    }
    
    @AuraEnabled
    public static String updateDocTypeOnFiles(List<String> cvIds, String docType) {
        try {
            List<ContentVersion> contentVersions = new List<ContentVersion>();
            for(String cvId : cvIds) {
                contentVersions.add(
                    new ContentVersion(Id = cvId, Document_Type_fileupload__c = docType)
                );
            }
            if(!contentVersions.isEmpty()) {
                update contentVersions;
            }
            return 'Success';
        }
        catch(Exception e) {
            return 'Error';
        }
    }
    // IBA-2849 Start
    @AuraEnabled
    public static String DeleteAllDoc(List<String> records) {
        String res='false';
        try {
            if(!records.isEmpty()){
                List<ContentDocument> cd = [Select Id from ContentDocument where Id IN :records];
                delete cd;
                res = 'true';
            }
        }
        catch(Exception e){
            res = 'false';
        }
        return res;
    }
    // IBA-2849 End
}