@isTest
public class CreateCaseControllerTest {
    public static testMethod void CreateCaseTest(){
        
        Account acctTest = new Account(Name = 'Test Account', TAM_Email__c = 'abc@abc.com');
        insert acctTest;
        
        Case c = new Case();
        c.Status = 'Pending Customer';
        c.Subject = 'test';
        c.Description = 'test dessc';
        
        
        SSO_SAML_History__c smh = new SSO_SAML_History__c();
        smh.Portal_UserName__c = Userinfo.getUserName();
        smh.Cloud_Id__c = 'ABCD1234';
        insert smh;
        
        Zscaler_Cloud_ID__c zci = new Zscaler_Cloud_ID__c();
        zci.Name = 'ABCD1234';
        zci.Cloud_Type__c = 'ZIA';
        zci.Account__c = acctTest.id;
        insert zci;
        
        //Added by Anup : CR#613 - Start
        ContentVersion cv = new ContentVersion();
        cv.ContentLocation = 'S';
        cv.ContentDocumentId = null;
        cv.VersionData = EncodingUtil.base64Decode('Test Data');
        cv.Title = 'file1';
        cv.PathOnClient = 'file1';
        insert cv;
        
        List<ContentVersion> cdlst = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: cv.Id];
		List<Id> listOfCDId = new List<Id>();
        for(ContentVersion cv1 : cdlst){
            listOfCDId.add(cv1.ContentDocumentId);
        }
        //Added by Anup : CR#613 - End
        
        test.startTest();
        CreateCaseController.saveCaseRecord(c, listOfCDId);
        CreateCaseController.getPortalContent('partners');
        CreateCaseController.getPortalContent('customers');
        CreateCaseController.fetchPreferredFields();
        CreateCaseController.getZscalerPortalDetails();
        CreateCaseController.saveFile(c.Id, 'strFileName', 'base64Data');
        test.stopTest();
    }
}