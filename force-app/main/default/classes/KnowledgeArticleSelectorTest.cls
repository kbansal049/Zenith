/**
 * @description       : This is the APEX Test class for KnowledgeArticleSelector
 * @author            : Ram Sangati
 * @last modified on  : 01-11-2023
 * @last modified by  : Ram Sangati
**/

@isTest
public class KnowledgeArticleSelectorTest {
    final static String QUERY_FIELDS = 'Id, Title, UrlName, OwnerId, Owner.Name, Owner.Email, Technical_Reviewer__c, Technical_Reviewer__r.Name, Technical_Reviewer__r.Email';
    @testSetup
    static void setupTestData(){
        Id problemsKBPecordTypeId = Schema.SObjectType.KB__kav.getRecordTypeInfosByDeveloperName().get('Problems').getRecordTypeId();
        String publishedStr = 'Published';
        List<KB__kav> kbsList = new List<KB__kav>();

        KB__kav probKA = new KB__kav();
        probKA.RecordTypeId = problemsKBPecordTypeId;
        probKA.Title = 'Apex Test Article - 1';
        probKA.UrlName = 'Apex-Test-Article-1';
        probKA.Author__c = UserInfo.getUserId();
        probKA.Technical_Reviewer__c = UserInfo.getUserId();
        probKA.ValidationStatus = publishedStr;
        probKA.Article_Status__c = publishedStr;
        probKA.Product_Applicable__c = 'ZIA';
        probKA.Environment__c = 'ZSProduction';
        probKA.Summary = 'Zscaler supports a maximum of eight group memberships per user.';
        probKA.Message__c = 'IMPORTANT - Ensure the \'Visible in Public Knowledge\' and \'Visible to Customer\' checkboxes in the Additional Information section are appropriately set. Also, save the draft and then use the Edit option beside any field to author the article in full-screen mode.';
        probKA.IsVisibleInCsp = true;
        probKA.IsVisibleInPkb = true;
        probKA.IsVisibleInPrm = false;
        kbsList.add(probKA);

        KB__kav qsnKA = new KB__kav();
        qsnKA.RecordTypeId = problemsKBPecordTypeId;
        qsnKA.Title = 'Apex Test Article - 2';
        qsnKA.UrlName = 'Apex-Test-Article-2';
        qsnKA.Author__c = UserInfo.getUserId();
        qsnKA.Technical_Reviewer__c = UserInfo.getUserId();
        qsnKA.ValidationStatus = publishedStr;
        qsnKA.Article_Status__c = publishedStr;
        qsnKA.Product_Applicable__c = GCSCommonConstants.CASE_PRODUCT_ZPA;
        qsnKA.Environment__c = 'ZSProduction';
        qsnKA.Summary = 'Zscaler supports a maximum of eight group memberships per user.';
        qsnKA.Message__c = 'IMPORTANT - Ensure the \'Visible in Public Knowledge\' and \'Visible to Customer\' checkboxes in the Additional Information section are appropriately set. Also, save the draft and then use the Edit option beside any field to author the article in full-screen mode.';
        qsnKA.IsVisibleInCsp = true;
        qsnKA.IsVisibleInPkb = true;
        qsnKA.IsVisibleInPrm = false;
        kbsList.add(qsnKA);

        insert kbsList;
    }

    @isTest
    static void testGetKBWhenIdIsNotNull(){
        KB__kav kb1 = [SELECT Id, Title, UrlName, OwnerId, Owner.Name, Owner.Email, Technical_Reviewer__c, Technical_Reviewer__r.Name, Technical_Reviewer__r.Email FROM KB__kav WHERE UrlName = 'Apex-Test-Article-1' LIMIT 1];
        KB__kav kb2 = KnowledgeArticleSelector.getKB(kb1.Id, null);
        System.assertEquals(kb2.Id, kb1.Id, GCSCommonConstants.APEX_TEST_PASS);
    }

    @isTest
    static void testGetKBWhenUrlNameIsNotNull(){
        KB__kav kb = KnowledgeArticleSelector.getKB(null, 'Apex-Test-Article-1');
        System.assertEquals('Apex-Test-Article-1', kb.UrlName, GCSCommonConstants.APEX_TEST_PASS);
    }

    @isTest
    static void testGetKBWhenUrlNameORIdIsNull(){
        KB__kav kb = KnowledgeArticleSelector.getKB(null, null);
        System.assertEquals(null, kb, GCSCommonConstants.APEX_TEST_PASS);
    }

    @isTest
    static void testGetKBsWhenWhereClauseIsNotNull(){
        String whereClause = 'UrlName = \'Apex-Test-Article-1\'';
        List<KB__kav> kbsList = KnowledgeArticleSelector.getKBs(QUERY_FIELDS, whereClause, null, GCSCommonConstants.INTEGER_0);
        System.assertEquals(1, kbsList.size(), GCSCommonConstants.APEX_TEST_PASS);
    }

    @isTest
    static void testGetKBWhenOrderByClauseIsNotNull(){
        String orderByClause = 'UrlName DESC';
        List<KB__kav> kbsList = KnowledgeArticleSelector.getKBs(QUERY_FIELDS, null, orderByClause, 10);
        System.assertEquals(2, kbsList.size(), GCSCommonConstants.APEX_TEST_PASS);
        System.assertEquals('Apex-Test-Article-2', kbsList.get(0).UrlName, GCSCommonConstants.APEX_TEST_PASS);
    }

    @isTest
    static void testGetKBWhenLimitClauseIsZero(){
        List<KB__kav> kbsList = KnowledgeArticleSelector.getKBs(QUERY_FIELDS, null, null, GCSCommonConstants.INTEGER_0);
        System.assertEquals(1, kbsList.size(), GCSCommonConstants.APEX_TEST_PASS);
    }

    @isTest
    static void testGetKBWhenLimitClauseIsBetween0And50k(){
        List<KB__kav> kbsList = KnowledgeArticleSelector.getKBs(QUERY_FIELDS, null, null, 10);
        System.assertEquals(2, kbsList.size(), GCSCommonConstants.APEX_TEST_PASS);
    }

    @isTest
    static void testGetKBWhenLimitClauseIsGrearthan50k(){
        List<KB__kav> kbsList = KnowledgeArticleSelector.getKBs(QUERY_FIELDS, null, null, 50001);
        System.assertEquals(2, kbsList.size(), GCSCommonConstants.APEX_TEST_PASS);
    }
}