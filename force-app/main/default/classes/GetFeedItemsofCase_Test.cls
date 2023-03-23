@isTest
public class GetFeedItemsofCase_Test{
    static testmethod void test1(){
        
        ZscalerCustomSetting__c custStng = new ZscalerCustomSetting__c();
        custStng.Name = 'OrgURL';
        custStng.Value__c = 'https://zscaler--uat.cs26.my.salesforce.com';
        insert custStng;
        
        Account acct = new Account();
        acct.name = 'Test Account';
        acct.Type = 'Customer';
        acct.RecordTypeId = '01270000000EAFsAAO';
        acct.X3rd_TAM_Name__c = UserInfo.getUserId();
        insert acct;
        
        Id caseSupportRT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Support').getRecordTypeId();
        Case cs = new Case(Subject='abcd', AccountId =  acct.Id, Priority='Urgent (P1)', RecordTypeId=caseSupportRT, Defcon_Level__c='3', Description='abcdDes', Case_type__c = 'Problem');
        insert cs;
        
        FeedItem feed = new FeedItem();
        feed.ParentId = cs.Id;
        feed.body = 'test';
        feed.Type = 'EmailMessageEvent';
        insert feed;
        
        FeedItem feed2 = new FeedItem();
        feed2.ParentId = cs.Id;
        feed2.body = 'Test Text Post';
        feed2.Type = 'TextPost';
        insert feed2;
        
        GetFeedItemsofCase tst = new GetFeedItemsofCase();
        tst.getFeedItem();
        tst.equipmentRequestRecordId = cs.Id;
        String url = tst.url;
        String Casecomment = tst.Casecomment;
        
        tst.typeofTemplate = 'test';
        tst.latestFi = feed;
        tst.Caseid = cs.Id;
        tst.Case1 = cs;
        
        GetFeedItemsofCase tst2 = new GetFeedItemsofCase();
        tst2.getFeedItem();
        tst2.equipmentRequestRecordId = cs.Id;
        String url2 = tst.url;
        String Casecomment2 = tst2.Casecomment;
        
        tst2.typeofTemplate = 'test';
        tst2.latestFi = feed2;
        tst2.Caseid = cs.Id;
        tst2.Case1 = cs;
    }
}