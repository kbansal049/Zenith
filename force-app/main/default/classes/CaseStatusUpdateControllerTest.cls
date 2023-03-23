@isTest
public class CaseStatusUpdateControllerTest {
    @isTest
    public static void testMethod1(){
        Triggers_Switch__c setting = new Triggers_Switch__c();
        setting.Name = 'KnowledgeTrigger';
        setting.Object_Name__c = 'KB__kav';
        setting.Execute__c = true;
        insert setting;
        User usr = [SELECT id FROM User where UserPermissionsKnowledgeUser=true and Profile.name='System administrator' and isActive=true limit 1];
        System.runAs(usr){
            KB__kav kb = new KB__kav();
            kb.UrlName = 'test-url-testClass-rammted1995-122432';
            kb.Title = 'test-url';
            kb.Summary = 'Summary';
            kb.Details__c = 'test desc';
            insert kb;
            kb = [SELECT KnowledgeArticleId FROM KB__kav WHERE Id = :kb.Id];    
            Id caseSupportRT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Support').getRecordTypeId();
            Case cs = new Case(Subject='abcd', Priority='Urgent (P1)', RecordTypeId=caseSupportRT, Description='abcdDes', Case_type__c = 'Problem');
            insert cs;
            CaseArticle ca = new CaseArticle();
            ca.CaseId = cs.Id;
            ca.KnowledgeArticleId = kb.KnowledgeArticleId;
            insert ca;                   
            Test.startTest();
            CaseStatusUpdateController.associateCaseWithKnowledge(cs.Id, kb.Id, 'ZPA Administration', 'Admins and Roles', 'ZPA');
            CaseStatusUpdateController.isKnowledgeArticleAttached(cs.Id);
            Test.stopTest();
        }
        
    }
}