@isTest
public class ProvisioningErrorHandlerTest {
	 @TestSetup
    static void testData(){
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Core Sales' LIMIT 1];
        User usr = new User(LastName = 'Lastname2',
                              FirstName='Firstname2',
                              Alias = 'testb',
                              Email = 'dummy@dummy.com2',
                              Username = 'test2@asdf.com',
                              ProfileId = profileId.id,
                              TimeZoneSidKey = 'GMT',
                              LanguageLocaleKey = 'en_US',
                              EmailEncodingKey = 'UTF-8',
                              LocaleSidKey = 'en_US'
                             );
    }
    
    @isTest
    static void testmethod1(){
        user usr = [SELECT id from user limit 1];
        List<Nanolog_Cluster__c> ncList = new List<Nanolog_Cluster__c>();
    	Nanolog_Cluster__c nc = new Nanolog_Cluster__c();
        nc.cloud__c = 'ZSCALER';
        nc.geoRegion__c = 'test';
        nc.type__c = 'nanolog';
        nc.name = 'zs2test1';
        ncList.add(nc);
        system.runAs(usr){
            Database.SaveResult[] rsList =  Database.insert(ncList, false);
            boolean isError = false;
            Database.Error err;
            for (Database.SaveResult sr : rsList) {
                if (!sr.isSuccess()){
                    isError = true;
                    err = sr.getErrors()[0];
                    }
            }
            if(isError)
                ProvisioningErrorHandler.databaseExceptionHandler('ProvisioningErrorHandlerTest','testmethod1',err);   
        }    
    }
}