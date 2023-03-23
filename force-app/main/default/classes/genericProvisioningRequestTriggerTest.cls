/*

 *  Modifications Log 
 * Ver   Date         Author        Modification
 * 1.0   NA				NA		    Initial Version
 * 2.0   26-05-2022   Mahesh T      Fixed Code coverage
 */ 
@isTest
public with sharing class genericProvisioningRequestTriggerTest {
        @testSetup static void setup() {
       		Id recordTypeId = Schema.SObjectType.Provisioning_Request__c.getRecordTypeInfosByName().get('FeVa Cloud').getRecordTypeId();
            Id inlineRecordTypeId = Schema.SObjectType.Provisioning_Request__c.getRecordTypeInfosByName().get('Zscaler Cloud').getRecordTypeId();
           
            //create test User
        	User testUser = new User(LastName = 'TestUser', Email = 'test@zscaler.com', Username = 'testuser@zscaler.com', alias = 'testaaa', timezonesidkey = 'America/Los_Angeles', LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US', EmailEncodingKey='ISO-8859-1', ProfileId = [SELECT Id FROM Profile WHERE  Name = 'System Administrator' LIMIT 1][0].Id/*, ContactId = [SELECT Id FROM Contact LIMIT 1][0].Id*/);
        	insert testUser;

        	//Account
        	Account acctTest = new Account(Name = 'Test Account');
        	insert acctTest;

        	//Opportunity
        	Opportunity testOppty = new Opportunity(Name = 'Test Opportunity', StageName = '1 - Discovery & Qualification',CloseDate = Date.today());
       	 	testOppty.AccountID = acctTest.Id;
        	insert testOppty;
             
           //create test PR
        	Provisioning_Request__c testPR = new Provisioning_Request__c(Organization_Domain__c = 'test.domain.com', Preferred_Cloud__c = 'Zscaler.net', Send_Initial_l__c = 'SE', SE__c = testUser.Id,Account__c = acctTest.Id, Opportunity__c=testOppty.Id, RecordTypeId = inlineRecordTypeId);
        	insert testPR;
            
            Provisioning_Request__c testPR1 = new Provisioning_Request__c(Organization_Domain__c = 'test1.domain.com', Preferred_Cloud__c = 'Zscaler.net', Send_Initial_l__c = 'SE', SE__c = testUser.Id,Account__c = acctTest.Id, Opportunity__c=testOppty.Id, RecordTypeId = recordTypeId);
        	insert testPR1;
            
       }
 
    
   // @isTest 
   // public static void test() {
        //create test Account
        //Account testAccount = new Account(Name = 'Test Account');
        //insert testAccount;
        	
        //create test contact
        //Contact testContact = new Contact(LastName = 'TestUser');
        //insert testContact;

        //create test User
    //    User testUser = new User(LastName = 'TestUser', Email = 'test@zscaler.com', Username = 'testuser@zscaler.com', alias = 'testaaa', timezonesidkey = 'America/Los_Angeles', LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US', EmailEncodingKey='ISO-8859-1', ProfileId = [SELECT Id FROM Profile WHERE  Name = 'System Administrator' LIMIT 1][0].Id/*, ContactId = [SELECT Id FROM Contact LIMIT 1][0].Id*/);
    //    insert testUser;

        //create test PR
     //   Provisioning_Request__c testPR = new Provisioning_Request__c(Organization_Domain__c = 'test.domain.com', Preferred_Cloud__c = 'Zscaler.net', Send_Initial_l__c = 'SE', SE__c = testUser.Id);
     //   insert testPR;
   // }
    
    @isTest
    public static void test2(){
        List<Provisioning_Request__c> newPRRec = [select Provisioning_Status__c from Provisioning_Request__c limit 1];
        system.debug(newPRRec.size());
        if(!newPRRec.isEmpty()){
            newPRRec[0].Provisioning_Status__c = 'Awaiting Rep Confirmation';
            update newPRRec;
        }
    }
    
     @isTest
    public static void test3(){
        List<Provisioning_Request__c> newPRRec = [select Id from Provisioning_Request__c where Organization_Domain__c = 'test1.domain.com' ];
        delete newPRRec;      
    }
    
    
}