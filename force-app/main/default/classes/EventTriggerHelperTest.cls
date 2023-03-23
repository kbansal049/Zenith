@isTest
public class EventTriggerHelperTest {

	static final String PGDiscoveryEventType = 'PG - Discovery Call';
	static final String PGNewBusEventType = 'PG - New Business Meeting';
    static final String MeetingCompleted = 'Completed';
	static final String MeetingScheduled = 'Meeting Scheduled';	
	static final String MeetingScheduledMsg = 'The Contact\'s Contact Lead Status should be Meeting Scheduled.';						
	static final String USLocale = 'en_US';
    static final String FUNNEL_STAGE_DATE = 'The Lead Funnel Stage Date should be today.';

    @testSetup
    static void createDummyData()
    {
        //User usr = TestDatafactory_Zscaler.insertAdminUser('xyz@xyz.com', 'test1', 'test', 'ttest1', 'xyz@xyz.com.test', 'GMT', USLocale, 'UTF-8', USLocale);
        Profile pf= [Select Id from profile where Name='System Administrator']; 
        createUser(pf.id,'user001');

        Id RecordTypeIdAcc = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner').getRecordTypeId();
        Account acc = new Account(Name = 'Test Account for GCS',Type = 'Partner', Domain__c = 'vontier.com', Additional_Organization_Domains__c='gilbarco.com, veeder.com',recordtypeid = RecordTypeIdAcc);
        insert acc;
        
        Contact ct = new Contact(LastName='Test Contact 1', email='Testemail@tests.com');
        insert ct;
        
        Contact ct1 = new Contact(LastName='Test Contact 2', email='Testemail2@tests.com');
        insert ct1;
        
        opportunity opp = new opportunity(Name = 'Test Opportunity', Primary_Quote_Exception__c  = true, AccountId = acc.Id, StageName = label.Stage_1_Alignment, CloseDate = system.Today()+30);
        insert opp;
        
        Opportunity_Partner__c OppPartner = new Opportunity_Partner__c(Is_Primary__c = false, Opportunity__c = opp.Id,Partner_Type__c = 'Reseller',Account__c = acc.Id);
        insert OppPartner;
        
        
        List<Triggers_Switch__c> trigSwitchList = new  List<Triggers_Switch__c>();
        trigSwitchList.add(new Triggers_Switch__c(Name = 'Execute_DR_Meeting_Date_Update', execute__c = true));
        trigSwitchList.add(new Triggers_Switch__c(Name = 'updateAccountQBRDate', execute__c = true));
        trigSwitchList.add(new Triggers_Switch__c(Name = 'Execute_Meeting_Tech_Teaming_Partner', execute__c = true));
        trigSwitchList.add(new Triggers_Switch__c(Name = 'Execute_Event_Trigger', execute__c = true));
        trigSwitchList.add(new Triggers_Switch__c(Name = 'Execute_EventCustomerScroceCard', execute__c = true));
        trigSwitchList.add(new Triggers_Switch__c(Name = 'Case_Status_To_Meetting_Schedule', execute__c = true));
        trigSwitchList.add(new Triggers_Switch__c(Name = 'Execute_UpdateRelatedToField', execute__c = true));
        trigSwitchList.add(new Triggers_Switch__c(Name = 'Execute_UpdateTargetCustomerNumber', execute__c = true));

        insert trigSwitchList;

		Event testEvent = new Event(Subject = 'Test Event', DurationInMinutes = 10, ActivityDateTime = System.now());
        insert testEvent;

		Lead testLead = new Lead(LastName = 'Test Lead', Company = 'Test Company');
        insert testLead;
    }
    
    /*
    @isTest 
    static void createEvent()
    {
        Contact ct = [select Id,email,lastName from Contact where email ='Testemail@tests.com' limit 1];
        Account act = [select Id from Account where Name = 'Test Account' limit 1];
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        List<Event> events=new List<Event>();
        Event evnt = new Event();
        evnt.WhoId = ct.Id;
        evnt.Description = 'Test SCI from Groove';
        evnt.StartDateTime = DateTime.now();
        evnt.DurationInMinutes = 90;
        insert evnt;
        events.add(evnt);
        
        
        Account a= new Account ();
        a.name='Test Account';
        insert a;
        
        Event e = new Event();
        e.WhatId=act.id;
        e.Description = 'Test SCI from Groove';
        e.StartDateTime=system.today();
        e.DurationInMinutes=90;
        insert e;
        events.add(e);
        
        EventTriggerhelper obj=new EventTriggerhelper();
        EventTriggerhelper.afterInsert(events);
        
        
        Map<Id, Event> oldEvent=new Map<Id, Event>();
        oldEvent.put(evnt.id, evnt);
        EventTriggerhelper.AutocreateSCI(events, oldEvent, false, false);
        
        
        Significant_Customer_Interaction__c sc=new Significant_Customer_Interaction__c();
        sc.Meeting_ID__c=evnt.id;
        insert sc;
        
        EventTriggerhelper.DeleteSCI(events, oldEvent);
        
        Map<Id, Event> oldEvent1=new Map<Id, Event>();
        oldEvent1.put(e.id, e);
        Contact ct1 = [select Id,email,lastName from Contact where email ='Testemail2@tests.com' limit 1];
        
        EventRelation evntRelation = new EventRelation();
        evntRelation.EventId = evnt.Id;
        evntRelation.RelationId = ct1.Id;
        evntRelation.IsInvitee = true;
        evntRelation.isParent = false;
        evntRelation.IsWhat = false;
        evntRelation.Status = 'New';
        insert evntRelation;
        
    }
*/
 
  /*static  testMethod  void createEvent3()
    {
        Try{
        opportunity opp = [Select id from opportunity limit 1];
      
        Account act = [select Id from Account where Name = 'Test Account' limit 1];
        
        
        List<Event> eventsnew=new List<Event>();
        Event e = new Event();
        e.WhatId = act.Id;
        e.StartDateTime=system.today()+1;
        e.DurationInMinutes=10;
        insert e;
        
        Event e1 = new Event();
        e1.WhatId =act.id;
        e1.Description = 'Test SCI from Groove';
        e1.StartDateTime=system.today();
        e1.DurationInMinutes=90;
        e1.type = 'Discovery';
        //e1.Opportunity__c = opp.id;
        e1.peopleai__MeetingStatus__c = MeetingCompleted;
        e1.peopleai__Participants__c = 'abc@microsoft.com';
        e1.Technology_Partner_Associated__c = 'Not Associated';
        insert e1;
        
        eventsnew.add(e);
        eventsnew.add(e1);
        
        List<event> eventi=[select whatId,AccountId from event where whatId=:act.id or AccountId=:act.id limit 1];
        EventTriggerhelper.setCountOfSCIs(eventi);
        
        }
        Catch(Exception e){
            System.debug('e');
        }
    }*/
    
    @isTest 
    static void updateEvent()
    {
        Contact ct = [select Id,email,lastName from Contact where email ='Testemail@tests.com' limit 1];
        Opportunity opp = [Select id from opportunity limit 1];
        
        Event evnt = new Event();
        evnt.WhoId = ct.Id;
        evnt.Description = 'Test SCI from Groove';
        evnt.StartDateTime = DateTime.now();
        evnt.DurationInMinutes = 90;
        evnt.Meeting_Type_CP__c = 'Support - 60 Mins';
        insert evnt;
        
       
        
        Contact ct1 = [select Id,email,lastName from Contact where email ='Testemail2@tests.com' limit 1];
        
        EventRelation evntRelation = new EventRelation();
        
        evntRelation.EventId = evnt.Id;
        evntRelation.RelationId = ct1.Id;
        evntRelation.IsInvitee = true;
        evntRelation.isParent = false;
        evntRelation.IsWhat = false;
        evntRelation.Status = 'New';
        
        insert evntRelation;
        
        
        evntRelation.Status = 'Accepted';
        evntRelation.Response ='Will join the meeting';
        evntRelation.RespondedDate = DateTime.now();
        update evntRelation;
        
        
        
        TriggerUtility.createOpportunityPartnerFromEventReset();
        TriggerUtility.DRMeetingTypeReset();
        
        evnt.type = PGDiscoveryEventType;
        evnt.Opportunity__c = opp.id;
        evnt.peopleai__MeetingStatus__c = MeetingCompleted;
        evnt.peopleai__Participants__c = 'abc@microsoft.com';
        evnt.Technology_Partner_Associated__c = 'Not Associated';
        update evnt;
        
    }
    
    @isTest static void deleteEvent()
    {
        Test.StartTest();
        Contact ct = [select Id,email,lastName from Contact where email ='Testemail@tests.com' limit 1];
        Account act = [select Id from Account limit 1];
        
        Case testCase = new Case();
        testCase.AccountId = act.id;
        testCase.Status = 'New';
		testCase.Chili_Piper_Meeting_Status__c = 'Scheduled';
        insert testCase;
        
        //GCS Scheduler Changes - Start
        TriggerUtility.EventAfterInsertReset();
        ServiceAppointment sa = new ServiceAppointment();
        sa.ParentRecordId = testCase.Id;
        sa.Status = 'Scheduled';
        sa.Additional_Participants__c = 'testScheduler@vontier.com,testScheduler2@vontier.com,test@zscaler.com';
        sa.EarliestStartTime = DateTime.now();
        sa.DueDate = DateTime.now().addHours(1);
        sa.ContactId = ct.Id;
        sa.Subject = 'Test Scheduler';
        sa.SchedStartTime = DateTime.now();
        sa.SchedEndTime = DateTime.now().addHours(1);
        insert sa;
        
        ServiceResource sr = TestDatafactory_Zscaler.insertServiceResource('Test', UserInfo.getUserId(), 1, 5, 0, 0, 0, 'Frontline');
        sr.isActive = true;
        sr.IsPrimary = true;
        update sr;
        
        AssignedResource asr = new AssignedResource();
        asr.ServiceAppointmentId =sa.Id;
        asr.ServiceResourceId = sr.Id;
        insert asr;
        TriggerUtility.EventAfterInsertReset();
        //GCS Scheduler Changes - End
        
        Event evnt = new Event();
        evnt.WhatId = testCase.id;
        evnt.WhoId = ct.Id;
        evnt.Description = 'Test SCI from Groove';
        evnt.StartDateTime = DateTime.now();
        evnt.DurationInMinutes = 90;
        evnt.Technology_Partner_Associated__c = 'Not Applicable';
        evnt.Meeting_Type_CP__c = 'Support - 60 Mins';
        insert evnt;
        
        Contact ct1 = [select Id,email,lastName from Contact where email ='Testemail2@tests.com' limit 1];
        
        List<event> listEvent = new List<event>();
        listEvent.add(evnt);
        EventTriggerhelper.DeleteSCI(listEvent,null);
        EventRelation evntRelation = new EventRelation();
        
        evntRelation.EventId = evnt.Id;
        evntRelation.RelationId = ct1.Id;
        evntRelation.IsInvitee = true;
        evntRelation.isParent = false;
        evntRelation.IsWhat = false;
        evntRelation.Status = 'New';
        insert evntRelation;
        delete evnt;

        Test.StopTest();
        
    }
    
    
    
    @isTest static void setNextQBR()
    {
        
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User usr = new User(LastName = 'LIVESTON',
                            FirstName='JASON',
                            Alias = 'jliv',
                            Email = 'jason.liveston@asdf.com',
                            Username = 'tirth.liveston@asdf.com',
                            ProfileId = profileId.id,
                            TimeZoneSidKey = 'GMT',
                            LanguageLocaleKey = USLocale,
                            EmailEncodingKey = 'UTF-8',
                            LocaleSidKey = USLocale
                           );
        insert usr;

        Test.startTest();
            Account acc_ob=new Account();
            acc_ob.Name='acc1';
            
            Event ob=new Event();
            ob.OwnerId=usr.id;
            ob.ActivityDate=Date.today();
            ob.DurationInMinutes=0;
            ob.EndDateTime=Date.today();
            ob.StartDateTime=Date.today();
            ob.ActivityDateTime=Date.today();
            ob.Meeting_Type_CP__c = 'Support - 60 Mins';
            ob.Type='Post Sale - Operational Review';            
            
            insert acc_ob;
            TriggerUtility.stopupdateAccountQBRDate();
            TriggerUtility2.UpdateEventCustomerScroceCardExecuted();
            ob.WhatId=acc_ob.Id;
            insert ob;
        Test.stopTest();
    }
    
    @isTest static void setCustomerscoreCard()
    {
        
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User usr = new User(LastName = 'LIVESTON',
                            FirstName='JASON',
                            Alias = 'jliv',
                            Email = 'jason.liveston@asdf.com',
                            Username = 'tirth.liveston@asdf.com',
                            ProfileId = profileId.id,
                            TimeZoneSidKey = 'GMT',
                            LanguageLocaleKey = USLocale,
                            EmailEncodingKey = 'UTF-8',
                            LocaleSidKey = USLocale
                           );
        insert usr;
        Contact ct10 = new Contact(LastName='Test Contact 3', email='Testemail345@tests.com');
        insert ct10;

        Test.startTest();
            Account acc_ob=new Account();
            acc_ob.Name='acc3';
            acc_ob.HeadOfIT__c=ct10.id;
            acc_ob.Head_of_Architecture__c=ct10.id;        
            insert acc_ob;
            
            Customer_Score_Card__c custScoreCard = new Customer_Score_Card__c();
            custScoreCard.Account__c = acc_ob.Id;
            insert custScoreCard;

            TriggerUtility.stopupdateAccountQBRDate();

            Event ob=new Event();
            ob.OwnerId=usr.id;
            ob.WhatId=acc_ob.Id;
            ob.ActivityDate=Date.today();
            ob.DurationInMinutes=0;
            ob.EndDateTime=Date.today();
            ob.StartDateTime=Date.today();
            ob.ActivityDateTime=Date.today();
            ob.peopleai__Participants__c='jason.liveston@asdf.com,Testemail345@tests.com';
            ob.peopleai__MeetingStatus__c=MeetingCompleted;
            try{
                insert ob;
            }Catch(Exception e){
            
            }
        Test.stopTest();
    }

    @isTest static void caseStatusChangeToMeetingSchedule()
    {
        Contact ct = [select Id,email,lastName from Contact where email ='Testemail@tests.com' limit 1];

        Case testCase1 = new Case(Subject = 'Test Case');
        insert testCase1;

        Case testCase = [select id,status from Case limit 1];
        Event evnt = new Event();
        evnt.WhoId = ct.Id;
        evnt.WhatId = testCase.id;
        evnt.Description = 'Test SCI from Groove';
        evnt.StartDateTime = DateTime.now();
        evnt.Meeting_Type_CP__c ='Support - 90 Mins';
        evnt.DurationInMinutes = 90;
        insert evnt;
        System.debug('---case status 1--'+testCase.Status);
        
        evnt.Meeting_Type_CP__c ='Support - 90 Mins - CO';
        evnt.Canceled_CP__c=true;
        update evnt;
        System.debug('---case status 2--'+testCase.Status);
        
    }

    @isTest
    public static void updateRelatedToFieldTest(){
        
        Id RecordTypeIdAcc = Schema.SObjectType.Account.getRecordTypeInfosByName().get('End User').getRecordTypeId();
        Account accRecord2 = new Account(Name = 'GCS Account for Testing', recordtypeid = RecordTypeIdAcc,Domain__c = 'apple.com', Additional_Organization_Domains__c='dell.com'); //CustomerAccount
        insert accRecord2;

        User userRecord = [SELECT Id, LastName FROM User Limit 1];
        Contact ct = [select Id,email,lastName from Contact where email ='Testemail@tests.com' limit 1];
        Account accRecord1 = [select Id, Domain__c,Additional_Organization_Domains__c from Account limit 1]; //Partner Account

        Event eventRecord = new Event();
        eventRecord.whoId = ct.Id;
        eventRecord.Description = 'Test update related to';
        eventRecord.Type = 'Channel - Opportunity'; 
        eventRecord.peopleai__Participants__c = 'peter.mcintosh@gilbarco.com, rstrohman@veeder.com More in People.ai...';
        eventRecord.Customer_Name__c = accRecord2.Id;
        eventRecord.StartDateTime = DateTime.now();
        //eventRecord.EndDateTime = DateTime.now() + DateTime.now();
        //eventRecord.ActivityDateTime = DateTime.now();
        eventRecord.DurationInMinutes = 90;

        Test.startTest();
            Target_Customer__c targetCustomer = new Target_Customer__c(Partner__c = accRecord1.Id, Customer__c = accRecord2.Id, Regional_Alliance_Manager__c = userRecord.Id); 
            insert targetCustomer;
            Id [] fixedSearchResults= new Id[1];
            fixedSearchResults[0] = accRecord1.Id;
            Test.setFixedSearchResults(fixedSearchResults);
            insert eventRecord;
        Test.stopTest();
    }

    public static void createUser(Id profileId, String lastName){        
        String orgId=UserInfo.getOrganizationId(); 
        String dateString=String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','') ;
        Integer RandomId=Integer.valueOf(Math.rint(Math.random()*1000000)); 
        String uniqueName=orgId+dateString+RandomId; 
        User uu=new User(firstname = 'fname', 
                         lastName = lastName, 
                         email = uniqueName + '@test' + orgId + '.org', 
                         Username = uniqueName + '@test' + orgId + '.org', 
                         EmailEncodingKey = 'ISO-8859-1', 
                         Alias = uniqueName.substring(18, 23), 
                         TimeZoneSidKey = 'America/Los_Angeles', 
                         LocaleSidKey = USLocale, 
                         LanguageLocaleKey = USLocale, 
                         ProfileId = profileId
                        ); 
        
        
        insert uu;
    }

    @isTest
    static void testProcessAssociatedLeadsForNBMEvents() {
        Event testEvent = [Select id from Event Limit 1];
        
        Lead testLead = [Select id from Lead Limit 1];

        testEvent.Type = 'NBM (New Business Meeting)';
        testEvent.whoId = testLead.Id;
        update testEvent;

        testEvent = [SELECT Id, Type, whoId, peopleai__MeetingStatus__c FROM Event WHERE Id = :testEvent.Id LIMIT 1];

        Test.startTest();
            EventTriggerHelper.updateLeadAndContact(new List<Event> {testEvent});
        Test.stopTest();

        Lead resultLead = [SELECT Id, Task_and_Event_Activity__c FROM Lead WHERE Id = :testLead.Id LIMIT 1];
        System.assertEquals('NBM', resultLead.Task_and_Event_Activity__c, 'The Lead Task And Event Activity should be NBM.');
    }

    @isTest
    static void testProcessAssociatedLeadsForPGNBMNotCompletedEvents() {
        Event testEvent = [Select id from Event Limit 1];
        
        Lead testLead = [Select id from Lead Limit 1];

        testEvent.Type = PGNewBusEventType;
        testEvent.whoId = testLead.Id;
        update testEvent;

        testEvent = [SELECT Id, Type, whoId, peopleai__MeetingStatus__c FROM Event WHERE Id = :testEvent.Id LIMIT 1];

        Test.startTest();
            //EventTriggerHelper.processAssociatedLeads(new Map<Id, List<Event>> {testLead.Id => new List<Event> {testEvent}});
            EventTriggerHelper.updateLeadAndContact(new List<Event> {testEvent});
        Test.stopTest();

        Lead resultLead = [SELECT Id, Funnel_Stage_Date__c FROM Lead WHERE Id = :testLead.Id LIMIT 1];
        System.assertEquals(Date.today(), resultLead.Funnel_Stage_Date__c, FUNNEL_STAGE_DATE);
    }

    @isTest
    static void testProcessAssociatedLeadsForPGNBMCompletedEvents() {
        Event testEvent = [Select id from Event Limit 1];
        
        Lead testLead = [Select id from Lead Limit 1];

        testEvent.Type = PGNewBusEventType;
        testEvent.peopleai__MeetingStatus__c = MeetingCompleted;
        testEvent.whoId = testLead.Id;
        update testEvent;

        testEvent = [SELECT Id, Type, whoId, peopleai__MeetingStatus__c FROM Event WHERE Id = :testEvent.Id LIMIT 1];

        Test.startTest();
            // EventTriggerHelper.processAssociatedLeads(new Map<Id, List<Event>> {testLead.Id => new List<Event> {testEvent}});
            EventTriggerHelper.updateLeadAndContact(new List<Event> {testEvent});
        Test.stopTest();

        Lead resultLead = [SELECT Id, Funnel_Stage_Date__c FROM Lead WHERE Id = :testLead.Id LIMIT 1];
        System.assertEquals(Date.today(), resultLead.Funnel_Stage_Date__c, FUNNEL_STAGE_DATE);
    }

    @isTest
    static void testProcessAssociatedLeadsForPGDCNotCompletedEvents() {
        Event testEvent = [Select id from Event Limit 1];
        
        Lead testLead = [Select id from Lead Limit 1];

        testEvent.Type = PGDiscoveryEventType;
        testEvent.whoId = testLead.Id;
        update testEvent;

        testEvent = [SELECT Id, Type, whoId, peopleai__MeetingStatus__c FROM Event WHERE Id = :testEvent.Id LIMIT 1];

        Test.startTest();
            // EventTriggerHelper.processAssociatedLeads(new Map<Id, List<Event>> {testLead.Id => new List<Event> {testEvent}});
            EventTriggerHelper.updateLeadAndContact(new List<Event> {testEvent});
        Test.stopTest();

        Lead resultLead = [SELECT Id, Funnel_Stage_Date__c FROM Lead WHERE Id = :testLead.Id LIMIT 1];
        System.assertEquals(Date.today(), resultLead.Funnel_Stage_Date__c, FUNNEL_STAGE_DATE);
    }

    @isTest
    static void testProcessAssociatedLeadsForPGDCCompletedEvents() {
        Event testEvent = [Select id from Event Limit 1];
        
        Lead testLead = [Select id from Lead Limit 1];

        testEvent.Type = PGDiscoveryEventType;
        testEvent.peopleai__MeetingStatus__c = MeetingCompleted;
        testEvent.whoId = testLead.Id;
        update testEvent;

        testEvent = [SELECT Id, Type, whoId, peopleai__MeetingStatus__c FROM Event WHERE Id = :testEvent.Id LIMIT 1];

        Test.startTest();
            // EventTriggerHelper.processAssociatedLeads(new Map<Id, List<Event>> {testLead.Id => new List<Event> {testEvent}});
            EventTriggerHelper.updateLeadAndContact(new List<Event> {testEvent});
        Test.stopTest();

        Lead resultLead = [SELECT Id, Funnel_Stage_Date__c FROM Lead WHERE Id = :testLead.Id LIMIT 1];
        System.assertEquals(Date.today(), resultLead.Funnel_Stage_Date__c, FUNNEL_STAGE_DATE);
    }

    @isTest
    static void testProcessAssociatedContactsForNBMEvents() {
        Event testEvent = [Select id from Event Limit 1];
        
        Contact testContact = [Select id from Contact Limit 1];

        testEvent.Type = 'NBM (New Business Meeting)';
        testEvent.whoId = testContact.Id;
        update testEvent;

        testEvent = [SELECT Id, Type, whoId, peopleai__MeetingStatus__c FROM Event WHERE Id = :testEvent.Id LIMIT 1];

        Test.startTest();
            EventTriggerHelper.updateLeadAndContact(new List<Event> {testEvent});
        Test.stopTest();

        Contact resultContact = [SELECT Id, Task_and_Event_Activity__c FROM Contact WHERE Id = :testContact.Id LIMIT 1];
        System.assertEquals('NBM', resultContact.Task_and_Event_Activity__c, 'The Contact Task And Event Activity should be NBM.');
    }

    @isTest
    static void testProcessAssociatedContactsForPGNBMNotCompletedEvents() {
        Event testEvent = [Select id from Event Limit 1];
        
        Contact testContact = [Select id from Contact Limit 1];

        testEvent.Type = PGNewBusEventType;
        testEvent.whoId = testContact.Id;
        update testEvent;

        testEvent = [SELECT Id, Type, whoId, peopleai__MeetingStatus__c FROM Event WHERE Id = :testEvent.Id LIMIT 1];

        Test.startTest();
            //EventTriggerHelper.processAssociatedContacts(new Map<Id, List<Event>> {testContact.Id => new List<Event> {testEvent}});
            EventTriggerHelper.updateLeadAndContact(new List<Event> {testEvent});
        Test.stopTest();

        Contact resultContact = [SELECT Id, Contact_Lead_Status__c FROM Contact WHERE Id = :testContact.Id LIMIT 1];
        System.assertEquals(MeetingScheduled, resultContact.Contact_Lead_Status__c, MeetingScheduledMsg);
    }

    @isTest
    static void testProcessAssociatedContactsForPGNBMCompletedEvents() {
        Event testEvent = [Select id from Event Limit 1];
        
        Contact testContact = [Select id from Contact Limit 1];

        testEvent.Type = PGNewBusEventType;
        testEvent.peopleai__MeetingStatus__c = MeetingCompleted;
        testEvent.whoId = testContact.Id;
        update testEvent;

        testEvent = [SELECT Id, Type, whoId, peopleai__MeetingStatus__c FROM Event WHERE Id = :testEvent.Id LIMIT 1];

        Test.startTest();
            // EventTriggerHelper.processAssociatedContacts(new Map<Id, List<Event>> {testContact.Id => new List<Event> {testEvent}});
            EventTriggerHelper.updateLeadAndContact(new List<Event> {testEvent});
        Test.stopTest();

        Contact resultContact = [SELECT Id, Contact_Lead_Status__c FROM Contact WHERE Id = :testContact.Id LIMIT 1];
        System.assertEquals(MeetingScheduled, resultContact.Contact_Lead_Status__c, MeetingScheduledMsg);
    }

    @isTest
    static void testProcessAssociatedContactsForPGDCNotCompletedEvents() {
        Event testEvent = [Select id from Event Limit 1];
        
        Contact testContact = [Select id from Contact Limit 1];

        testEvent.Type = PGDiscoveryEventType;
        testEvent.whoId = testContact.Id;
        update testEvent;

        testEvent = [SELECT Id, Type, whoId, peopleai__MeetingStatus__c FROM Event WHERE Id = :testEvent.Id LIMIT 1];

        Test.startTest();
            // EventTriggerHelper.processAssociatedContacts(new Map<Id, List<Event>> {testContact.Id => new List<Event> {testEvent}});
            EventTriggerHelper.updateLeadAndContact(new List<Event> {testEvent});
        Test.stopTest();

        Contact resultContact = [SELECT Id, Contact_Lead_Status__c FROM Contact WHERE Id = :testContact.Id LIMIT 1];
        System.assertEquals(MeetingScheduled, resultContact.Contact_Lead_Status__c, MeetingScheduledMsg);
    }

    @isTest
    static void testProcessAssociatedContactsForPGDCCompletedEvents() {
        Event testEvent = [Select id from Event Limit 1];
        
        Contact testContact = [Select id from Contact Limit 1];

        testEvent.Type = PGDiscoveryEventType;
        testEvent.peopleai__MeetingStatus__c = MeetingCompleted;
        testEvent.whoId = testContact.Id;
        update testEvent;

        testEvent = [SELECT Id, Type, whoId, peopleai__MeetingStatus__c FROM Event WHERE Id = :testEvent.Id LIMIT 1];

        Test.startTest();
            // EventTriggerHelper.processAssociatedContacts(new Map<Id, List<Event>> {testContact.Id => new List<Event> {testEvent}});
            EventTriggerHelper.updateLeadAndContact(new List<Event> {testEvent});
        Test.stopTest();

        Contact resultContact = [SELECT Id, Contact_Lead_Status__c FROM Contact WHERE Id = :testContact.Id LIMIT 1];
        System.assertEquals(MeetingScheduled, resultContact.Contact_Lead_Status__c, MeetingScheduledMsg);
    }

    @isTest
    static void testProcessAssociatedLeadsForPGNBMNotCompletedEventsForUpdate() {
        Event testEvent = [Select id from Event Limit 1];
        
        Lead testLead = [Select id from Lead Limit 1];

        testEvent.Type = PGNewBusEventType;
        testEvent.whoId = testLead.Id;
        update testEvent;

        Event oldEvent = new Event(Id = testEvent.Id);

        testEvent = [SELECT Id, Type, whoId, peopleai__MeetingStatus__c FROM Event WHERE Id = :testEvent.Id LIMIT 1];

        Test.startTest();
            //EventTriggerHelper.processAssociatedLeads(new Map<Id, List<Event>> {testLead.Id => new List<Event> {testEvent}});
            EventTriggerHelper.updateLeadAndContactForUpdate(new List<Event> {testEvent}, new Map<Id, Event> {oldEvent.Id => oldEvent});
        Test.stopTest();

        Lead resultLead = [SELECT Id, Funnel_Stage_Date__c FROM Lead WHERE Id = :testLead.Id LIMIT 1];
        System.assertEquals(Date.today(), resultLead.Funnel_Stage_Date__c, FUNNEL_STAGE_DATE);
    }

    @isTest
    static void testProcessAssociatedLeadsForPGNBMCompletedEventsForUpdate() {
        Event testEvent = [Select id from Event Limit 1];
        
        Lead testLead = [Select id from Lead Limit 1];

        testEvent.Type = PGNewBusEventType;
        testEvent.peopleai__MeetingStatus__c = MeetingCompleted;
        testEvent.whoId = testLead.Id;
        update testEvent;

        Event oldEvent = new Event(Id = testEvent.Id);

        testEvent = [SELECT Id, Type, whoId, peopleai__MeetingStatus__c FROM Event WHERE Id = :testEvent.Id LIMIT 1];

        Test.startTest();
            // EventTriggerHelper.processAssociatedLeads(new Map<Id, List<Event>> {testLead.Id => new List<Event> {testEvent}});
            EventTriggerHelper.updateLeadAndContactForUpdate(new List<Event> {testEvent}, new Map<Id, Event> {oldEvent.Id => oldEvent});
        Test.stopTest();

        Lead resultLead = [SELECT Id, Funnel_Stage_Date__c FROM Lead WHERE Id = :testLead.Id LIMIT 1];
        System.assertEquals(Date.today(), resultLead.Funnel_Stage_Date__c, FUNNEL_STAGE_DATE);
    }

    @isTest
    static void testProcessAssociatedLeadsForPGDCNotCompletedEventsForUpdate() {
        Event testEvent = [Select id from Event Limit 1];
        
        Lead testLead = [Select id from Lead Limit 1];

        testEvent.Type = PGDiscoveryEventType;
        testEvent.whoId = testLead.Id;
        update testEvent;

        Event oldEvent = new Event(Id = testEvent.Id);

        testEvent = [SELECT Id, Type, whoId, peopleai__MeetingStatus__c FROM Event WHERE Id = :testEvent.Id LIMIT 1];

        Test.startTest();
            // EventTriggerHelper.processAssociatedLeads(new Map<Id, List<Event>> {testLead.Id => new List<Event> {testEvent}});
            EventTriggerHelper.updateLeadAndContactForUpdate(new List<Event> {testEvent}, new Map<Id, Event> {oldEvent.Id => oldEvent});
        Test.stopTest();

        Lead resultLead = [SELECT Id, Funnel_Stage_Date__c FROM Lead WHERE Id = :testLead.Id LIMIT 1];
        System.assertEquals(Date.today(), resultLead.Funnel_Stage_Date__c, FUNNEL_STAGE_DATE);
    }

    @isTest
    static void testProcessAssociatedLeadsForPGDCCompletedEventsForUpdate() {
        Event testEvent = [Select id from Event Limit 1];
        
        Lead testLead = [Select id from Lead Limit 1];

        testEvent.Type = PGDiscoveryEventType;
        testEvent.peopleai__MeetingStatus__c = MeetingCompleted;
        testEvent.whoId = testLead.Id;
        update testEvent;

        Event oldEvent = new Event(Id = testEvent.Id);

        testEvent = [SELECT Id, Type, whoId, peopleai__MeetingStatus__c FROM Event WHERE Id = :testEvent.Id LIMIT 1];

        Test.startTest();
            // EventTriggerHelper.processAssociatedLeads(new Map<Id, List<Event>> {testLead.Id => new List<Event> {testEvent}});
            EventTriggerHelper.updateLeadAndContactForUpdate(new List<Event> {testEvent}, new Map<Id, Event> {oldEvent.Id => oldEvent});
        Test.stopTest();

        Lead resultLead = [SELECT Id, Funnel_Stage_Date__c FROM Lead WHERE Id = :testLead.Id LIMIT 1];
        System.assertEquals(Date.today(), resultLead.Funnel_Stage_Date__c, FUNNEL_STAGE_DATE);
    }

    @isTest
    static void testProcessAssociatedContactsForPGNBMNotCompletedEventsForUpdate() {
        Event testEvent = [Select id from Event Limit 1];
        
        Contact testContact = [Select id from Contact Limit 1];

        testEvent.Type = PGNewBusEventType;
        testEvent.whoId = testContact.Id;
        update testEvent;

        Event oldEvent = new Event(Id = testEvent.Id);

        testEvent = [SELECT Id, Type, whoId, peopleai__MeetingStatus__c FROM Event WHERE Id = :testEvent.Id LIMIT 1];

        Test.startTest();
            //EventTriggerHelper.processAssociatedContacts(new Map<Id, List<Event>> {testContact.Id => new List<Event> {testEvent}});
            EventTriggerHelper.updateLeadAndContactForUpdate(new List<Event> {testEvent}, new Map<Id, Event> {oldEvent.Id => oldEvent});
        Test.stopTest();

        Contact resultContact = [SELECT Id, Contact_Lead_Status__c FROM Contact WHERE Id = :testContact.Id LIMIT 1];
        System.assertEquals(MeetingScheduled, resultContact.Contact_Lead_Status__c, MeetingScheduledMsg);
    }

    @isTest
    static void testProcessAssociatedContactsForPGNBMCompletedEventsForUpdate() {
        Event testEvent = [Select id from Event Limit 1];
        
        Contact testContact = [Select id from Contact Limit 1];

        testEvent.Type = PGNewBusEventType;
        testEvent.peopleai__MeetingStatus__c = MeetingCompleted;
        testEvent.whoId = testContact.Id;
        update testEvent;

        Event oldEvent = new Event(Id = testEvent.Id);

        testEvent = [SELECT Id, Type, whoId, peopleai__MeetingStatus__c FROM Event WHERE Id = :testEvent.Id LIMIT 1];

        Test.startTest();
            // EventTriggerHelper.processAssociatedContacts(new Map<Id, List<Event>> {testContact.Id => new List<Event> {testEvent}});
            EventTriggerHelper.updateLeadAndContactForUpdate(new List<Event> {testEvent}, new Map<Id, Event> {oldEvent.Id => oldEvent});
        Test.stopTest();

        Contact resultContact = [SELECT Id, Contact_Lead_Status__c FROM Contact WHERE Id = :testContact.Id LIMIT 1];
        System.assertEquals(MeetingScheduled, resultContact.Contact_Lead_Status__c, MeetingScheduledMsg);
    }

    @isTest
    static void testProcessAssociatedContactsForPGDCNotCompletedEventsForUpdate() {
        Event testEvent = [Select id from Event Limit 1];
        
        Contact testContact = [Select id from Contact Limit 1];

        testEvent.Type = PGDiscoveryEventType;
        testEvent.whoId = testContact.Id;
        update testEvent;

        Event oldEvent = new Event(Id = testEvent.Id);

        testEvent = [SELECT Id, Type, whoId, peopleai__MeetingStatus__c FROM Event WHERE Id = :testEvent.Id LIMIT 1];

        Test.startTest();
            // EventTriggerHelper.processAssociatedContacts(new Map<Id, List<Event>> {testContact.Id => new List<Event> {testEvent}});
            EventTriggerHelper.updateLeadAndContactForUpdate(new List<Event> {testEvent}, new Map<Id, Event> {oldEvent.Id => oldEvent});
        Test.stopTest();

        Contact resultContact = [SELECT Id, Contact_Lead_Status__c FROM Contact WHERE Id = :testContact.Id LIMIT 1];
        System.assertEquals(MeetingScheduled, resultContact.Contact_Lead_Status__c, MeetingScheduledMsg);
    }

    @isTest
    static void testProcessAssociatedContactsForPGDCCompletedEventsForUpdate() {
        Event testEvent = [Select id from Event Limit 1];
        
        Contact testContact = [Select id from Contact Limit 1];

        testEvent.Type = PGDiscoveryEventType;
        testEvent.peopleai__MeetingStatus__c = MeetingCompleted;
        testEvent.whoId = testContact.Id;
        update testEvent;

        Event oldEvent = new Event(Id = testEvent.Id);

        testEvent = [SELECT Id, Type, whoId, peopleai__MeetingStatus__c FROM Event WHERE Id = :testEvent.Id LIMIT 1];

        Test.startTest();
            // EventTriggerHelper.processAssociatedContacts(new Map<Id, List<Event>> {testContact.Id => new List<Event> {testEvent}});
            EventTriggerHelper.updateLeadAndContactForUpdate(new List<Event> {testEvent}, new Map<Id, Event> {oldEvent.Id => oldEvent});
        Test.stopTest();

        Contact resultContact = [SELECT Id, Contact_Lead_Status__c FROM Contact WHERE Id = :testContact.Id LIMIT 1];
        System.assertEquals(MeetingScheduled, resultContact.Contact_Lead_Status__c, MeetingScheduledMsg);
    }

	@isTest
    static void testUpdateCheckbox(){
		Event testEvent = [Select id, peopleai__MeetingStatus__c from Event Limit 1];
		List<Event> eventLst = new List<Event>();
		eventLst.add(testEvent);
		EventTriggerhelper.updateCheckbox(eventLst);

		testEvent.peopleai__MeetingStatus__c = MeetingCompleted;
		EventTriggerhelper.updateCheckbox(eventLst);
	}
}