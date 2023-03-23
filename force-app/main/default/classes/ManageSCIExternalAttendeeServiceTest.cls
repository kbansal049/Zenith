@isTest
public class ManageSCIExternalAttendeeServiceTest{
     
    static testmethod void test1(){
        Significant_Customer_Interaction__c sci = new Significant_Customer_Interaction__c();
        sci.Interaction_With__c = 'BD';
        sci.Meeting_Notes__c = 'Test';
        sci.Next_Steps__c = 'Test';
        sci.Date__c = System.Today()-10;
        sci.Primary_Topic_Covered__c = 'Demo';
        insert sci;
        
        Lead le = new Lead();
        le.Company = 'test Company';
        le.FirstName = 'Test';
        le.LastName = 'Name';
        le.Email = 'test@abc.com';
        le.NumberOfEmployees = 20;
        insert le;
        
        Account a = new Account();
        a.Name = 'Test Co.';
        a.Head_of_IT__c = true;
        insert a;
        
        Contact c = new Contact();
        c.FirstName = 'test';
        c.LastName  = 'Test';
        c.AccountId = a.id;
        insert c;
        
        Set<id> conSet = new Set<id>();
        conSet.add(c.Id);
        
        List<SCI_External_Attendee__c> lstSCA = new  List<SCI_External_Attendee__c>();
        
        SCI_External_Attendee__c sea = new SCI_External_Attendee__c();
        sea.Significant_Customer_Interaction__c = sci.Id;
        sea.Attendee_Name__c = c.Id;
        sea.Attendee_Name_Lead__c = le.Id;
        lstSCA.add(sea);
        
        SCI_External_Attendee__c sea1 = new SCI_External_Attendee__c();
        sea1.Significant_Customer_Interaction__c = sci.Id;
        sea1.Attendee_Name__c = c.Id;
        sea1.Attendee_Name_Lead__c = le.Id;
        lstSCA.add(sea1);
        
        insert lstSCA;
        Contact c1 = new Contact();
        c1.FirstName = 'test';
        c1.LastName  = 'Test';
        c1.AccountId = a.id;
        insert c1; 
        
        sea1.Attendee_Name__c = c1.Id;
        update lstSCA;
        
        ManageSCIExternalAttendeeService.fetchExternalAttendees(sci.Id, sci.Id);        
        
        Set<Id> setExternalAttendeeContactIds = new Set<Id>();
        setExternalAttendeeContactIds.add(le.Id);
        
        ManageSCIExternalAttendeeService.getExternalContactsToSuggest(a.id, setExternalAttendeeContactIds);
        ManageSCIExternalAttendeeService.searchExternalUsers('%?=`');
        ManageSCIExternalAttendeeService.searchExternalUsers('test');
        ManageSCIExternalAttendeeService.searchLeads('%?=`');
        ManageSCIExternalAttendeeService.searchLeads('test');
        ManageSCIExternalAttendeeService.getExternalCTMsToSuggest(a.id,conSet);
         
        Map<Id, Id> sciextattendeemap = new Map<Id, Id>();
        sciextattendeemap.put(sci.Id,c.Id);
        
        ManageSCIExternalAttendeeService.createExternalAttendees(sciextattendeemap);

    }
    
}