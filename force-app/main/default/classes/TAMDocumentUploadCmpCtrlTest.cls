/**
 * Name : TAMDocumentUploadCmpCtrlTest
 * Description : Test Class of TAMDocumentUploadCmpCtrl
 */

@isTest
public class TAMDocumentUploadCmpCtrlTest {
    
    @testSetup
    static void setup() {
        Account a = new Account(Name = 'Test');
        insert a;
        ContentVersion cv=new Contentversion();
        cv.title='test';
        cv.PathOnClient ='test';
        Blob b=Blob.valueOf('Unit Test Attachment Body');
        cv.versiondata=EncodingUtil.base64Decode('Unit Test Attachment Body');
        cv.firstPublishLocationId = a.id;
        cv.Project_Product_Type_fileupload__c = 'ZIA';
        cv.Document_Type_fileupload__c = 'BCP';
        insert cv;
        TAM_Engagement__c eng = new TAM_Engagement__c(Account__c = a.id, Stage__c = 'STAGE 1: Onboarding', tam_engagement_Status__c = 'Work in Progress');
        insert eng;
    }

    @isTest 
    static void test_Method() {
        TAMDocumentUploadCmpCtrl cons = new TAMDocumentUploadCmpCtrl();
        List<TAM_Engagement__c> engagementList = new List<TAM_Engagement__c>([SELECT id,Account__c FROM TAM_Engagement__c]);
        System.assert(TAMDocumentUploadCmpCtrl.getFileData(engagementList.get(0).Id).size() > 0, 'Files not Found');
        System.assert(TAMDocumentUploadCmpCtrl.getFileData(engagementList.get(0).Account__c).size() > 0, 'Files not Found');
        List<String> cvIds = new List<String>();
        for(ContentVersion cv : [SELECT id FROM ContentVersion]) {
            cvIds.add(cv.id);
        }
        TAMDocumentUploadCmpCtrl.updateDocTypeOnFiles(cvIds,'BCP');
        TAMDocumentUploadCmpCtrl.DeleteAllDoc(cvIds);
    }
}