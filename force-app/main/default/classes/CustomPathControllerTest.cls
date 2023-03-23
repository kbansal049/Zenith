@isTest(SeeAllData=true)
public class CustomPathControllerTest {
    
    @isTest static void getPathCategoryMappingTest(){
        Account acc = TestDatafactory_Zscaler.insertAccount('Test Account1', null, 'Customer', null, null, null);
        PS_Questionnaire__c questionnare = new PS_Questionnaire__c();
        questionnare.Account__c = acc.Id;
        insert questionnare;
        
        inspire1__Project__c testProject = new inspire1__Project__c();
        testProject.Name = 'Test';
        testProject.inspire1__Account__c = acc.Id;
        insert testProject;        
        Test.startTest();
        
        String questionnareRecordTypeZIA = Schema.SObjectType.PS_Questionnaire__c.getRecordTypeInfosByDeveloperName().get('ZIA').getRecordTypeId();
        String questionnareRecordTypeZPA = Schema.SObjectType.PS_Questionnaire__c.getRecordTypeInfosByDeveloperName().get('ZPA').getRecordTypeId();   
        CustomPathController.CategoryDataWrapper catDataWrapper = new CustomPathController.CategoryDataWrapper('category',  'subCategory',  'subCatId', 5,  'pathClass',  'fieldSetName',  'recordFormClass', 5);
        CustomPathController.getPathCategoryMapping('Traffic Forwarding', true, questionnare.Id, questionnareRecordTypeZIA);
        CustomPathController.getPathCategoryMapping('Traffic Forwarding', true, questionnare.Id, questionnareRecordTypeZPA);
        CustomPathController.getPathCategoryMapping('Traffic Forwarding', false, questionnare.Id, questionnareRecordTypeZIA);
        CustomPathController.getPathCategoryMapping('Traffic Forwarding', false, questionnare.Id, questionnareRecordTypeZPA);
        Date closeDate = system.today() + 5;
        Opportunity opp = TestDatafactory_Zscaler.insertOpportunity('Test Opp1', false, acc.Id, Label.Stage_4_Economic_Buyer_Signoff, closeDate , null, null, null, null,null, null, null, null, null, null, true);
        System.debug('opp'+opp.Id +'   '+!String.isBlank(opp.Id));
        CustomPathController.getMainDetails(opp.Id, testProject.id);
        CustomPathController.getAllMainCategories(questionnare.Id, questionnareRecordTypeZIA);
        CustomPathController.getAllMainCategories(questionnare.Id, questionnareRecordTypeZPA);
        CustomPathController.getAllMainCategories(questionnare.Id, null);
        Test.stopTest();
    }
}