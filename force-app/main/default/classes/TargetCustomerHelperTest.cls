@isTest
public class TargetCustomerHelperTest {

    @TestSetup
    static void setupData(){

        Profile pf= [Select Id from profile where Name='System Administrator']; 
        createUser(pf.id,'user001');

        Id AccountRT = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Partner').getRecordTypeId();
        Account acc = new Account(Name = 'Test Account', TAM_Email__c = 'abc@abc.com',Type='Partner',RecordTypeId=AccountRT);
        insert acc;
        
        Account acc1 = new Account(Name = 'Test Account1', TAM_Email__c = 'abc@abc.com',Type='Prospect');
        insert acc1;

        Contact ct1 = new Contact(LastName='Test1', email='Testemail2@tests.com');
        insert ct1;
        
        Target_Customer__c TC = new Target_Customer__c(Customer__c=acc1.Id,Partner__c=acc.Id,Regional_Alliance_Manager__c=userinfo.getuserId(),Notes__c='test');
        insert TC;
    }

    @IsTest
    static void testMethod1(){
        
        User userRecord = [SELECT Id, LastName FROM User Limit 1];
        Contact ct = [select Id,email,lastName from Contact where email ='Testemail2@tests.com' limit 1];
        List<Account> accRecord1 = [SELECT Id, Domain__c,Additional_Organization_Domains__c,Type FROM Account];

        Id customerAccount = accRecord1[0].Type == 'Prospect' ? accRecord1[0].Id : accRecord1[1].Id;
        Id partnerAccount = accRecord1[0].Type == 'Partner' ? accRecord1[0].Id : accRecord1[1].Id;

        Event eventRecord = new Event();
        eventRecord.whoId = ct.Id;
        eventRecord.Description = 'Test update related to';
        eventRecord.Type = 'Channel - Opportunity'; 
        eventRecord.peopleai__Participants__c = 'peter.mcintosh@gilbarco.com, rstrohman@veeder.com More in People.ai...';
        eventRecord.Customer_Name__c = customerAccount;
        eventRecord.WhatId = partnerAccount;
        //eventRecord.Customer_Name__c = accRecord2.Id;
        eventRecord.StartDateTime = DateTime.now();
        eventRecord.DurationInMinutes = 90;
        insert eventRecord;

        Test.startTest();
            Target_Customer__c TC = new Target_Customer__c(Customer__c=customerAccount,Partner__c=partnerAccount,Regional_Alliance_Manager__c=userRecord.Id,Notes__c='test');
            insert TC;
        	
        	TriggerUtility2.TargetafterInsertAndUpdateReset();
        
            TC.Notes__c = 'updated TC';
            update TC;
        Test.stopTest();
        
    }

    public static void createUser(Id profileId, String lastName){        
        String orgId=UserInfo.getOrganizationId(); 
        String dateString=String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','') ;
        Integer RandomId=Integer.valueOf(Math.rint(Math.random()*1000000)); 
        String uniqueName=orgId+dateString+RandomId; 
        User uu=new User(firstname = 'test', 
                         lastName = lastName, 
                         email = uniqueName + '@test' + orgId + '.org', 
                         Username = uniqueName + '@test' + orgId + '.org', 
                         EmailEncodingKey = 'ISO-8859-1', 
                         Alias = uniqueName.substring(18, 23), 
                         TimeZoneSidKey = 'America/Los_Angeles', 
                         LocaleSidKey = 'en_US', 
                         LanguageLocaleKey = 'en_US', 
                         ProfileId = profileId
                        );        
        
        insert uu;
    }
}