@isTest
public class ProjectFilesUploadOnAccountCtrlTest {
    
    @testSetup
    static void createDummyData() {
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        ContentVersion cv=new Contentversion();
        cv.title='ABC';
        cv.PathOnClient ='test';
        Blob b=Blob.valueOf('Unit Test Attachment Body');
        cv.versiondata=EncodingUtil.base64Decode('Unit Test Attachment Body');
        cv.FirstPublishLocationId = [SELECT id FROM Account LIMIT 1].id;
        cv.Project_Product_Type_fileupload__c = 'ZPA';
        insert cv;
    }
    
    @isTest 
    static void getFileData_Test() {
        String accId = [SELECT id FROM Account LIMIT 1].id;
        ProjectFilesUploadOnAccountCtrl p = new ProjectFilesUploadOnAccountCtrl();
        List<ContentDocumentLink> cdlList = ProjectFilesUploadOnAccountCtrl.getFileData(accId, 'ZPA');
        System.assert(cdlList.size()!=0, 'No files Found');
        ProjectFilesUploadOnAccountCtrl.getFileData(accId, '');
    }
}