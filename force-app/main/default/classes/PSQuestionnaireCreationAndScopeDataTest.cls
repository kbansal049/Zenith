@isTest
public class PSQuestionnaireCreationAndScopeDataTest {
    
    @isTest static void provideTest(){
        Test.startTest();
        PS_Questionnaire__c questionnare =new PS_Questionnaire__c();
        questionnare.Traffic_Sources__c='Corporate Windows Workstations;Corporate MAC Workstations;Virtual Desktop Infra (VDI) Users;Kiosk/Shared Machines;Corporate Android Devices;Corporate IOS Devices;Servers;Guest Wifi Users;BYOD Users;IoT (Connected Devices)';
        insert questionnare;
                
        Map<String, String> params = new Map<String, String>();
        params.put('Id', questionnare.Id);
        PSQuestionnaireCreationAndScopeData.DataWrapper catDataWrapper = new PSQuestionnaireCreationAndScopeData.DataWrapper(System.today(),  'createdby','windows',  'macs',  'vdi',  'kiosk',  'android',  'ios',  'servers',  'iot',  'byod',  'guest');
        PSQuestionnaireCreationAndScopeData questionnare2 = new PSQuestionnaireCreationAndScopeData();
        questionnare2.provide(params);
        Test.stopTest();
    }
}