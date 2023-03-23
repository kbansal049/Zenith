/*****************************************************************************************
Name: SurveyResponseTranslationControllerTest 
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
1. Test class for SurveyResponseTranslationController Class
==========================================================================================
==========================================================================================
History
-------
VERSION            AUTHOR                   DATE            DETAIL              
1.0                Adarsh Pidaparthy        07/21/2022      CR#5100    Translate survey responses to user's native language
******************************************************************************************/ 
@isTest
public class SurveyResponseTranslationControllerTest {
    static testMethod void testPostCallout() {
        
        Account eachAcc = new Account(Name = 'Test Account',TAM_Email__c = 'test@test.com',Type= 'Customer',NumberOfEmployees = 5,Load_CSM_Or_TAM_To_Account_Team__c = true);
        TriggerHandler.bypass('AccountTriggerHandler'); 
        insert eachAcc;
        Id deployProjectRecordTypeId = Schema.SObjectType.inspire1__Project__c.getRecordTypeInfosByDeveloperName().get('Deployment_Project').getRecordTypeId();
        Inspire1__Project__c newProject = new Inspire1__Project__c(name = 'Test project 22',inspire1__Account__c = eachAcc.id,inspire1__Project_Status__c='In Progress',RecordTypeID = deployProjectRecordTypeId);
        insert newProject;
        Id deployRecordTypeId = Schema.SObjectType.Survey__c.getRecordTypeInfosByDeveloperName().get('Deployment_Survey').getRecordTypeId();
        Survey__c newSurvey = new Survey__c(RecordTypeId = deployRecordTypeId,Question_1_Comments__c='diga-nos o motivo da sua pontuação',Question_2_Comments__c='motivo da sua pontuação',Question_3_Comments__c='Por favor, diga-nos,da sua pontuação,feedback adicional',Question_4_Comments__c='como o desempenho do(s) engenheiro(s)',How_can_we_make_you_happier__c='o que fizemos bem ou onde podemos melhorar',Project_Name__c=newProject.Id,Language_Code__c = 'pt');
        insert newSurvey;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SurveyResponseTranslationMock());  
        SurveyResponseTranslationController.makeGoogleApiCallout(newSurvey);
        Test.stopTest();
        
    } 
}