@isTest
public class AccountTriggerHelper_Test{
    
    @isTest private static void updateCustomerSupportStage_test(){
        
        User usr = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' and isActive=true LIMIT 1];
        System.runas(usr){
            Test.StartTest();
            
            Test.StopTest();
        }
    }
    //add by tirth patel CR#996
    @istest private static void updateAccount()
    {
        Test.StartTest();
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='standarduser234@testorg.com');
        insert u;
 
        Account ac = TestDatafactory_Zscaler.insertAccount('Test Account1', null, 'Customer', null, null, null);
        
        TriggerUtility.UpdateCSMAccountExtenssionMethodsetfalse();
        ac.CSM_Name_New__c = u.id;
        update ac;
        Test.stopTest();
    }
}