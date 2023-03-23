/**
 * @description       : This is the APEX Test class for KnowledgeArticleFeedbackController
 * @author            : Ram Sangati
 * @last modified on  : 01-11-2023
 * @last modified by  : Ram Sangati
**/

@isTest
public class KnowledgeArticleFeedbackControllerTest {
    @testSetup
    static void setupTestData(){
        Id problemsKBPecordTypeId = Schema.SObjectType.KB__kav.getRecordTypeInfosByDeveloperName().get('Problems').getRecordTypeId();

        KB__kav kb = new KB__kav();
        kb.RecordTypeId = problemsKBPecordTypeId;
        kb.Title = 'Apex Test Article - 1';
        kb.UrlName = 'Apex-Test-Article-1';
        kb.Author__c = UserInfo.getUserId();
        kb.Technical_Reviewer__c = UserInfo.getUserId();
        kb.ValidationStatus = 'Published';
        kb.Article_Status__c = 'Published';
        kb.Product_Applicable__c = 'ZIA';
        kb.Environment__c = 'ZSProduction';
        kb.Summary = 'Zscaler supports a maximum of eight group memberships per user.';
        kb.Message__c = 'IMPORTANT - Ensure the \'Visible in Public Knowledge\' and \'Visible to Customer\' checkboxes in the Additional Information section are appropriately set. Also, save the draft and then use the Edit option beside any field to author the article in full-screen mode.';
        kb.IsVisibleInCsp = true;
        kb.IsVisibleInPkb = true;
        kb.IsVisibleInPrm = false;
        insert kb;
    }

    @isTest
    static void testSendKAFeedbackWhenUrlNameIsNotNull(){
        String feedbackRespose = KnowledgeArticleFeedbackController.sendKAFeedback(null, 'Apex-Test-Article-1', 'Like', 'General Comments', 'Test Comments');
        System.assertEquals('Success', feedbackRespose, 'Pass');
    }

    @isTest
    static void testSendKAFeedbackWhenIdIsNotNull(){
        KB__kav kb = [SELECT Id, Title, UrlName, OwnerId, Owner.Name, Owner.Email, Technical_Reviewer__c, Technical_Reviewer__r.Name, Technical_Reviewer__r.Email FROM KB__kav WHERE UrlName = 'Apex-Test-Article-1' LIMIT 1];
        String feedbackRespose = KnowledgeArticleFeedbackController.sendKAFeedback(kb.Id, null, 'Like', 'General Comments', 'Test Comments');
        System.assertEquals('Success', feedbackRespose, 'Pass');
    }

    @isTest
    static void testSendKAFeedbackWhenUrlNameORIdIsNull(){
        String feedbackRespose = KnowledgeArticleFeedbackController.sendKAFeedback(null, null, 'Like', 'General Comments', 'Test Comments');
        System.assertEquals('No Record found.', feedbackRespose, 'Pass');
    }
}