@isTest
public class PSQuestionnaireFormatMSPWrapperTest {
    @isTest
    static void provideDataTest()
    {
        Test.startTest();
        PS_Questionnaire__c questionnaire =new  PS_Questionnaire__c();
        Account account = TestDatafactory_Zscaler.insertAccount('Test Account', 'test@test.com', 'test', null, null, 5);
        questionnaire.Traffic_Sources__c='Servers;BYOD Users';
        questionnaire.Internet_Egress_Points_Locations__c='USA;Canada';
        questionnaire.GRE_Device_Vendors_Currently_In_Use__c='Cisco;HP';
        questionnaire.IPSEC_Device_Vendors_Currently_In_Use__c='HP;Juniper';
        questionnaire.End_User_Traffic_Forwarded_To_The_Existi__c='Agent;Registry';
        questionnaire.Account__c=account.Id;
        insert questionnaire;
        Map<String, String> params = new Map<String, String>();
        params.put('Id', questionnaire.Id);
        PSQuestionnaireFormatMSPWrapper questionnaire2 = new PSQuestionnaireFormatMSPWrapper();
        questionnaire2.provide(params);
        Test.stopTest();
    }
}