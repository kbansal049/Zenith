@isTest
public class generatePSQuestionnaireControllerTest {
    
    @isTest
    public static void exportQuestionnaireTest()
    {
        PS_Questionnaire__c questionnaireZIA = new PS_Questionnaire__c();
        PS_Questionnaire__c questionnaireZPA = new PS_Questionnaire__c();
        
        String questionnareRecordTypeZIA = Schema.SObjectType.PS_Questionnaire__c.getRecordTypeInfosByName().get('ZIA').getRecordTypeId();
        String questionnareRecordTypeZPA = Schema.SObjectType.PS_Questionnaire__c.getRecordTypeInfosByName().get('ZPA').getRecordTypeId();   
        Account account = TestDatafactory_Zscaler.insertAccount('Test Account', 'test@test.com', 'test', null, null, 5);
        User usr1 = TestDatafactory_Zscaler.insertAdminUser('xyz@xyz2.com', 'test3', 'test3', 'ttest13', 'xyz@xyz2.com.test', 'GMT', 'en_US', 'UTF-8', 'en_US');
        
        questionnaireZIA.RecordTypeId=questionnareRecordTypeZIA;
        questionnaireZIA.Status__c='Questionnaire Submitted';
        questionnaireZIA.Account__c=account.id;
        questionnaireZIA.Primary_PS_Consultant__c=usr1.id;
        questionnaireZIA.Secondary_PS_Consultant__c=usr1.id;
        questionnaireZIA.Project_Manager__c=usr1.id;
        questionnaireZIA.Sales_Engineer__c=usr1.id;
        questionnaireZIA.Opportunity_Owner__c=usr1.id; 
        
        insert questionnaireZIA;
        questionnaireZPA.RecordTypeId=questionnareRecordTypeZPA;
        questionnaireZPA.Status__c='New';
        questionnaireZPA.Account__c=account.id;
        questionnaireZPA.Primary_PS_Consultant__c=usr1.id;
        questionnaireZPA.Secondary_PS_Consultant__c=usr1.id;
        questionnaireZPA.Project_Manager__c=usr1.id;
        questionnaireZPA.Sales_Engineer__c=usr1.id;
        questionnaireZPA.Opportunity_Owner__c=usr1.id; 
        insert questionnaireZPA;
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Document';
        cv.PathOnClient = 'TestDocument.docx';
        cv.VersionData = Blob.valueOf('Test Content');
        cv.IsMajorVersion = true;
        Insert cv;
        OneDoc__Template__c oneDoc1=new OneDoc__Template__c();
        oneDoc1.Name='PS Questionnaire Template ZPA';
        oneDoc1.OneDoc__ObjectType__c='PS_Questionnaire__c';
        insert oneDoc1;
        OneDoc__Template__c oneDoc2=new OneDoc__Template__c();
        oneDoc2.Name='PS Questionnaire Template ZIA';
        oneDoc2.OneDoc__ObjectType__c='PS_Questionnaire__c';
        insert oneDoc2;
        OneDoc__Template__c oneDoc3=new OneDoc__Template__c();
        oneDoc3.Name='Design Document ZPA';
        oneDoc3.OneDoc__ObjectType__c='PS_Questionnaire__c';
        insert oneDoc3;
        OneDoc__Template__c oneDoc4=new OneDoc__Template__c();
        oneDoc4.Name='Design Document ZIA';
        oneDoc4.OneDoc__ObjectType__c='PS_Questionnaire__c';
        insert oneDoc4;
        generatePSQuestionnaireController.exportDocumentFromQuestionnaire(questionnaireZIA.id);
        generatePSQuestionnaireController.generateDesignPlanFromQuestionnaire(questionnaireZIA.id);
        generatePSQuestionnaireController.exportDocumentFromQuestionnaire(questionnaireZPA.id);
        generatePSQuestionnaireController.generateDesignPlanFromQuestionnaire(questionnaireZPA.id);
        generatePSQuestionnaireController.sendEmailWithDesignDoc(questionnaireZIA.id,cv.ContentDocumentId); 
        
        
    }
    
}