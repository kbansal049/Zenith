/**
 * Name : KnowledgeTriggerHandlerTest
 * Description : Test Class of KnowledgeTrigger and KnowledgeTriggerHandler
 */
@isTest
private with sharing class KnowledgeTriggerHandlerTest {
    @testSetup
    static void setup() {
        Triggers_Switch__c setting = new Triggers_Switch__c();
        setting.Name = 'KnowledgeTrigger';
        setting.Object_Name__c = 'KB__kav';
        setting.Execute__c = true;
        insert setting;
        List<KB__kav> knowledgeList = new List<KB__kav>();
        for(Integer i = 0; i < 10; i++) {
            Integer randomNumber = Integer.valueof((Math.random() * 100));
            knowledgeList.add(new KB__kav(title = 'Test'+i+randomNumber, UrlName = 'Test'+i+randomNumber,Summary = 'Test Summary'+i,Product_Applicable__c='ZIA'));
        }
        insert knowledgeList;
        Account testSetacct = new Account();
        testSetacct.name = 'Test Account';
        testSetacct.Type = 'Customer';
        testSetacct.RecordTypeId = '01270000000EAFsAAO';
        insert testSetacct;
        Contact testSetcon = new Contact();
        testSetcon.AccountId = testSetacct.Id;
        testSetcon.LastName = 'Test Contact';
        testSetcon.Email = 'contact@customer.com';
        insert testSetcon;
        
    }

    @isTest
    private static void setValidationStatusAsDraft_Test() {
        List<KB__kav> knowledgeList = new List<KB__kav>([SELECT id, title, Author__c, Technical_Reviewer__c, 
                                                        Editorial_Reviewer__c, Article_Publisher__c, ValidationStatus 
                                                        FROM KB__kav]);
        for(KB__kav k : knowledgeList) {
            System.assert(k.validationStatus == 'Draft', 'New Article Status must have validation Status as Draft');
            System.assert(k.Technical_Reviewer__c == null, 'New Article Status must have not have a Tech Reviewer populated');
            System.assert(k.Editorial_Reviewer__c == null, 'New Article Status must have not have an Editorial Reviewer populated');
            System.assert(k.Article_Publisher__c == null, 'New Article Status must have not have aPublisher populated');
        } 
    }

    @isTest
    private static void setValidationStatusAsReadyTechReview_Test() {
        List<KB__kav> knowledgeList = new List<KB__kav>([SELECT id, title, ValidationStatus FROM KB__kav]);
        System.debug('KnowledgeList ReadyTech'+knowledgeList);
        for(KB__kav k : knowledgeList) {
            k.validationStatus = 'Ready for Tech Review';
        } 
        update knowledgeList;
        knowledgeList = new List<KB__kav>([SELECT id, title, Author__c FROM KB__kav]);
        for(KB__kav k : knowledgeList) {
            System.assert(k.Author__c == UserInfo.getUserId(), 'User shouldve been set as author');
        }                                  

    }
    
    @isTest
    private static void setValidationStatusAsInTechReview_Test() {
        List<KB__kav> knowledgeList = new List<KB__kav>([SELECT id, title, validationStatus FROM KB__kav]);
        for(KB__kav k : knowledgeList) {
            k.validationStatus = 'In Tech Review';
        } 
        update knowledgeList;
        knowledgeList = new List<KB__kav>([SELECT id, title, Technical_Reviewer__c FROM KB__kav]);
        for(KB__kav k : knowledgeList) {
            System.assert(k.Technical_Reviewer__c == UserInfo.getUserId(), 'User shouldve been set as Tech Reviewer');
        }  
    }

    @isTest
    private static void setValidationStatusAsInEditorialReview_Test() {
        List<KB__kav> knowledgeList = new List<KB__kav>([SELECT id, title, validationStatus FROM KB__kav]);
        for(KB__kav k : knowledgeList) {
            k.validationStatus = 'In Editorial Review';
        } 
        update knowledgeList;
        knowledgeList = new List<KB__kav>([SELECT id, title, Editorial_Reviewer__c FROM KB__kav]);
        for(KB__kav k : knowledgeList) {
            System.assert(k.Editorial_Reviewer__c == UserInfo.getUserId(), 'User shouldve been set as Editorial Reviewer');
        }  
    }

    @isTest
    private static void setValidationStatusAsPublished_Test() {
        List<KB__kav> knowledgeList = new List<KB__kav>([SELECT id, title, validationStatus FROM KB__kav]);
        for(KB__kav k : knowledgeList) {
            k.validationStatus = 'Published';
        } 
        update knowledgeList;
        knowledgeList = new List<KB__kav>([SELECT id, title, Article_Publisher__c FROM KB__kav]);
        for(KB__kav k : knowledgeList) {
            System.assert(k.Article_Publisher__c == UserInfo.getUserId(), 'User shouldve been set as Publisher');
        }  
    }
    
    @isTest
    private static void pushToDraft_Test() {
        List<KB__kav> knowledgeList = new List<KB__kav>([SELECT id, title, push_to_draft__c FROM KB__kav]);
        for(KB__kav k : knowledgeList) {
            k.author__c = UserInfo.getUserId();
        } 
        update knowledgeList;
        for(KB__kav k : knowledgeList) {
            k.push_to_draft__c = True;
        } 
        update knowledgeList;
        knowledgeList = new List<KB__kav>([SELECT id, title, Author__c,push_to_draft__c,ValidationStatus FROM KB__kav]);
        for(KB__kav k : knowledgeList) {
            System.assert(k.ValidationStatus =='Draft rework', 'ValidationStatus shouldve been Draft Rework');
        }                                  

    }
    
    @isTest
    private static void knowledgeRecallApprovals_Test() {
        List<KB__kav> knowledgeList = new List<KB__kav>([SELECT id, title, Author__c,push_to_draft__c,ValidationStatus FROM KB__kav LIMIT 1]);
        System.debug('KnowledgeList Approvals'+knowledgeList);
        Approval.ProcessSubmitRequest app = new Approval.ProcessSubmitRequest();
		app.setObjectId(knowledgeList.get(0).id);
		Approval.ProcessResult result = Approval.process(app);
       	System.assert([ SELECT Id FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId = :knowledgeList.get(0).id AND ProcessInstance.Status='Pending'].size()==1, 'Approval records must be present');
        KnowledgeRecallApprovals.recallKnowledgeApprovals(new List<String>{knowledgeList.get(0).id});
		System.assert([ SELECT Id FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId = :knowledgeList.get(0).id AND ProcessInstance.Status='Pending'].size()==0, 'Approval records must\'ve been recalled');
    }
}