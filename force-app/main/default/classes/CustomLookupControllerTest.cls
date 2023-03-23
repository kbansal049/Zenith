@IsTest
private with sharing class CustomLookupControllerTest {
    
    @testSetup static void setup() {
        TriggerUtility.SkipAccTriggerExecuted();

        Account acc = new Account(Name = 'Test Account', TAM_Email__c = 'abc@abc.com',Type='Technology Partner',Partner_Type__c='Partner-Integrator',Tech_Partner_Referral_Agreement__c = 'Impact');
        INSERT acc;
        
        Account acc1 = new Account(Name = 'Test Account1', TAM_Email__c = 'abc@abc.com',Type='Technology Partner',Partner_Type__c='Partner-Integrator',Tech_Partner_Referral_Agreement__c = 'Impact');
        INSERT acc1;
        
       
    }
    
    
	@IsTest
    private static void testFindRecords() {
        CustomLookupController.RecordDetailsWrapper recordDetailsWrap = 
            new CustomLookupController.RecordDetailsWrapper();
        
        recordDetailsWrap.searchKey = 'Test';
        recordDetailsWrap.objectName = 'Account';
        recordDetailsWrap.searchField = 'Name';
        recordDetailsWrap.partnerType = 'Impact';
        
        CustomLookupController.findRecords(recordDetailsWrap);
    }
    @IsTest
    private static void testFindRecorddetails() {
        CustomLookupController.RecordDetailsWrapper recordDetailsWrap = 
            new CustomLookupController.RecordDetailsWrapper();
        
        recordDetailsWrap.searchKey = 'Test';
        recordDetailsWrap.objectName = 'Account';
        recordDetailsWrap.searchField = 'Name';
        recordDetailsWrap.partnerType = 'Influence';
        
        CustomLookupController.findRecords(recordDetailsWrap);
    }
}