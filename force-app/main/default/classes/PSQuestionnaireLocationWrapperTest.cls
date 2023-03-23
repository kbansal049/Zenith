@isTest(SeeAllData=true)
public class PSQuestionnaireLocationWrapperTest {

    @isTest static void provideTest(){
        Test.startTest();
        PS_Questionnaire__c questionnare =new  PS_Questionnaire__c();
        questionnare.Location_Name_1__c='Test';
        questionnare.Location_City_State_Country_1__c='Test';
        insert questionnare;
        questionnare.Location_Name_2__c=questionnare.Location_Name_1__c;
        questionnare.Location_Name_3__c=questionnare.Location_Name_1__c;
        questionnare.Location_Name_4__c=questionnare.Location_Name_1__c;
        questionnare.Location_Name_5__c=questionnare.Location_Name_1__c;
        questionnare.Location_City_State_Country_2__c =questionnare.Location_City_State_Country_1__c;
        questionnare.Location_City_State_Country_3__c =questionnare.Location_City_State_Country_1__c;
        questionnare.Location_City_State_Country_4__c =questionnare.Location_City_State_Country_1__c;
        questionnare.Location_City_State_Country_5__c =questionnare.Location_City_State_Country_1__c;
        update questionnare;
        Map<String, String> params = new Map<String, String>();
        params.put('Id', questionnare.Id);
        PSQuestionnaireLocationWrapper.LocationWrapper catDataWrapper = new PSQuestionnaireLocationWrapper.LocationWrapper( 'locationName',  'locationCity',  'bandwidth',  'availableInfra',  'topology');
        PSQuestionnaireLocationWrapper questionnare2 = new PSQuestionnaireLocationWrapper();
        questionnare2.provide(params);
        Test.stopTest();
    }
}