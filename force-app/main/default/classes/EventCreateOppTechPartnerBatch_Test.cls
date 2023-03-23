@isTest
public class EventCreateOppTechPartnerBatch_Test {
    
    @testSetup
    static void createDummyData()
    {
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        
        Account acc1 = new Account(Name = 'Test Account1');
        insert acc1;
        
        Contact ct = new Contact(LastName='Test', email='Testemail@tests.com');
        insert ct;
        
        Contact ct1 = new Contact(LastName='Test1', email='Testemail2@tests.com');
        insert ct1;
        
        opportunity opp = new opportunity(Name = 'Test opportunity', Primary_Quote_Exception__c  = true, AccountId = acc.Id, StageName = label.Stage_1_Alignment, CloseDate = system.Today()+30);
        insert opp;
        
        Opportunity_Partner__c OppPartner = new Opportunity_Partner__c(Is_Primary__c = false, Opportunity__c = opp.Id,Partner_Type__c = 'Tech Partner',Account__c = acc.Id);
        insert OppPartner;
        
        Opportunity_Partner__c OppPartner1 = new Opportunity_Partner__c(Is_Primary__c = false, Opportunity__c = opp.Id,Partner_Type__c = 'Tech Partner',Account__c = acc1.Id);
        insert OppPartner1;
        
        
        
        List<Triggers_Switch__c> trigSwitchList = new  List<Triggers_Switch__c>();
        trigSwitchList.add(new Triggers_Switch__c(Name = 'Execute_DR_Meeting_Date_Update', execute__c = true));
        trigSwitchList.add(new Triggers_Switch__c(Name = 'updateAccountQBRDate', execute__c = true));
        trigSwitchList.add(new Triggers_Switch__c(Name = 'Execute_Meeting_Tech_Teaming_Partner', execute__c = true));
        trigSwitchList.add(new Triggers_Switch__c(Name = 'Execute_Event_Trigger', execute__c = true));
        insert trigSwitchList;
    }
    
    
    @isTest 
    static void updateEvent()
    {
        Contact ct = [select Id,email,lastName from Contact where email ='Testemail@tests.com' limit 1];
        Account act = [select Id from Account limit 1];
        opportunity opp = [Select id from opportunity limit 1];
        
        Event evnt = new Event();
        evnt.WhoId = ct.Id;
        evnt.Description = 'Test SCI from Groove';
        evnt.StartDateTime = DateTime.now();
        evnt.DurationInMinutes = 90;
        insert evnt;
        
        
        TriggerUtility.createOpportunityPartnerFromEventReset();
        TriggerUtility.DRMeetingTypeReset();
        
        evnt.type = 'Discovery';
        evnt.Opportunity__c = opp.id;
        evnt.peopleai__MeetingStatus__c = 'Completed';
        evnt.peopleai__Participants__c = 'abc@microsoft.com';
        evnt.Technology_Partner_Associated__c = 'Not Associated';
        update evnt;
    
        Test.StartTest();
        EventCreateOpportunityTechPartnerBatch sh1 = new EventCreateOpportunityTechPartnerBatch();
        String sch = '0 0 23 * * ?'; 
        system.schedule('Test Ecent Tech Partner Check', sch, sh1);
        Test.stopTest(); 
    }
}