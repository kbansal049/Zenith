/*****************************************************************************************
Name: ManageSCIControllerTest
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
Test code to unit test ManageSCIController, ManageSCIService, ManageSCIInternalAttendeeService,
ManageSCIExternalAttendeeService and DeleteSCIController
==========================================================================================
==========================================================================================
History
-------
VERSION        AUTHOR                  DATE              DETAIL              
1.0            Vijay Prakash P J     12-Jan-2017    Initial Development
******************************************************************************************/
@isTest
private class ManageSCIControllerTest {
    
    /**
* Method to test the default and overloaded constructors
*/
    @isTest static void testConstructor() {
        User me = [SELECT Id, Name FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        ManageSCITestDataHelper.createTestData();
        
        System.runAs(me) {
            Test.startTest();
            Test.setCurrentPage(Page.ManageSCI);
            ApexPages.currentPage().getParameters().put('id', '');
            ApexPages.currentPage().getParameters().put('edit', 'false');
            ApexPages.currentPage().getParameters().put('accountId', ManageSCITestDataHelper.mapAccounts.get('Test Account3').Id);
            ApexPages.currentPage().getParameters().put('opportunityId', ManageSCITestDataHelper.testOpportunity.Id);
            ApexPages.currentPage().getParameters().put('leadId', '');
            ApexPages.currentPage().getParameters().put('dealRegId', '');
            ApexPages.currentPage().getParameters().put('campaignId', '');
            ApexPages.currentPage().getParameters().put('addMe', '');
            ApexPages.currentPage().getParameters().put('dealRegId', '');
            ApexPages.currentPage().getParameters().put('retUrl', '/home/home.jsp');
            
            Significant_Customer_Interaction__c sciToTest = new Significant_Customer_Interaction__c();
            ApexPages.StandardController stdController = new ApexPages.StandardController(sciToTest);
            ManageSCIController controller = new ManageSCIController(stdController);
            
            //Test the default constructor
            ManageSCIController defaultConstructor = new ManageSCIController();
            
            controller.cancel();
            Test.stopTest();
        }
    }
    
    /**
* Method to test the new SCI creation flow
*/
    @isTest static void testCreateNewSCIScenario() {
        User me = [SELECT Id, Name FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        ManageSCITestDataHelper.createTestData();
        
        System.runAs(me) {
            Test.startTest(); 
            Test.setCurrentPage(Page.ManageSCI);
            ApexPages.currentPage().getParameters().put('id', '');
            ApexPages.currentPage().getParameters().put('edit', 'false');
            ApexPages.currentPage().getParameters().put('accountId', ManageSCITestDataHelper.mapAccounts.get('Test Account3').Id);
            ApexPages.currentPage().getParameters().put('opportunityId', ManageSCITestDataHelper.testOpportunity.Id);
            ApexPages.currentPage().getParameters().put('leadId', '');
            ApexPages.currentPage().getParameters().put('dealRegId', '');
            ApexPages.currentPage().getParameters().put('campaignId', '');
            ApexPages.currentPage().getParameters().put('addMe', '');
            
            Significant_Customer_Interaction__c sciToTest = new Significant_Customer_Interaction__c();
            ApexPages.StandardController stdController = new ApexPages.StandardController(sciToTest);
            ManageSCIController controller = new ManageSCIController(stdController);
            
            //Set SCI Record type and Date of Meeting
            controller.sciRecord.RecordTypeId = ManageSCITestDataHelper.mapSCIRecordTypes.get('Regular Meeting');
            controller.sciRecord.Date__c = Date.today();
            controller.sciDateText = Datetime.now().format('MM/dd/yyyy');
            controller.fetchExistingSCIs();
            
            controller.addNewSCI();
            controller.gotoStepNumber = 2;
            controller.setCurrentStep();
            controller.goNext();
            controller.goPrevious();
            
            controller.cancel();
            
            Test.stopTest();
        }
    }
    
    /**
* Method to test the new SCI creation flow negative test cases
*/
    @isTest static void testCreateNewSCIValidationFailureScenario() {
        User me = [SELECT Id, Name FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        ManageSCITestDataHelper.createTestData();
        
        System.runAs(me) {
            Test.startTest();
            Test.setCurrentPage(Page.ManageSCI);
            ApexPages.currentPage().getParameters().put('id', '');
            ApexPages.currentPage().getParameters().put('edit', 'false');
            ApexPages.currentPage().getParameters().put('accountId', ManageSCITestDataHelper.mapAccounts.get('Test Account3').Id);
            ApexPages.currentPage().getParameters().put('opportunityId', ManageSCITestDataHelper.testOpportunity.Id);
            ApexPages.currentPage().getParameters().put('leadId', '');
            ApexPages.currentPage().getParameters().put('dealRegId', '');
            ApexPages.currentPage().getParameters().put('campaignId', '');
            ApexPages.currentPage().getParameters().put('addMe', '');
            
            Significant_Customer_Interaction__c sciToTest = new Significant_Customer_Interaction__c();
            ApexPages.StandardController stdController = new ApexPages.StandardController(sciToTest);
            ManageSCIController controller = new ManageSCIController(stdController);
            
            //Set SCI Record type and Date of Meeting
            controller.sciRecord.RecordTypeId = ManageSCITestDataHelper.mapSCIRecordTypes.get('Regular Meeting');
            controller.sciRecord.Date__c = Date.today();
            controller.sciDateText = Datetime.now().format('MM/dd/yyyy');
            controller.fetchExistingSCIs();
            
            controller.addNewSCI();
            controller.gotoStepNumber = 4;
            controller.setCurrentStep();
            controller.goNext();
            controller.goPrevious();
            
            controller.save();
            
            Test.stopTest();
        }
    }
    
    /**
* Method to test the new SCI creation flow - No valid query parameters
*/
    @isTest static void testInvalidParameters() {
        User me = [SELECT Id, Name FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        ManageSCITestDataHelper.createTestData();
        
        System.runAs(me) {
            Test.startTest();
            Test.setCurrentPage(Page.ManageSCI);
            ApexPages.currentPage().getParameters().put('id', '');
            ApexPages.currentPage().getParameters().put('edit', 'false');
            ApexPages.currentPage().getParameters().put('accountId', '');
            ApexPages.currentPage().getParameters().put('opportunityId', '');
            ApexPages.currentPage().getParameters().put('leadId', '');
            ApexPages.currentPage().getParameters().put('dealRegId', '');
            ApexPages.currentPage().getParameters().put('campaignId', '');
            ApexPages.currentPage().getParameters().put('addMe', '');
            ApexPages.currentPage().getParameters().put('dealRegId', '');
            ApexPages.currentPage().getParameters().put('retUrl', '');
            
            Significant_Customer_Interaction__c sciToTest = new Significant_Customer_Interaction__c();
            ApexPages.StandardController stdController = new ApexPages.StandardController(sciToTest);
            ManageSCIController controller = new ManageSCIController(stdController);
            
            Test.stopTest();
        }
    }
    
    /**
* Method to test the new SCI creation flow - Automatically redirect to step 2 upon date selection
*/
    @isTest static void testAutoRedirectToStep2() {
        User me = [SELECT Id, Name FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        ManageSCITestDataHelper.createTestData();
        
        System.runAs(me) {
            Test.startTest();
            Test.setCurrentPage(Page.ManageSCI);
            ApexPages.currentPage().getParameters().put('id', '');
            ApexPages.currentPage().getParameters().put('edit', 'false');
            ApexPages.currentPage().getParameters().put('accountId', ManageSCITestDataHelper.mapAccounts.get('Test Account3').Id);
            ApexPages.currentPage().getParameters().put('opportunityId', ManageSCITestDataHelper.testOpportunity.Id);
            ApexPages.currentPage().getParameters().put('leadId', '');
            ApexPages.currentPage().getParameters().put('dealRegId', '');
            ApexPages.currentPage().getParameters().put('campaignId', '');
            ApexPages.currentPage().getParameters().put('addMe', '');
            ApexPages.currentPage().getParameters().put('dealRegId', '');
            ApexPages.currentPage().getParameters().put('retUrl', '/home/home.jsp');
            
            Significant_Customer_Interaction__c sciToTest = new Significant_Customer_Interaction__c();
            ApexPages.StandardController stdController = new ApexPages.StandardController(sciToTest);
            ManageSCIController controller = new ManageSCIController(stdController);
            
            //Set SCI Record type and Date of Meeting
            controller.sciRecord.RecordTypeId = ManageSCITestDataHelper.mapSCIRecordTypes.get('Regular Meeting');
            controller.sciRecord.Date__c = Date.today().addDays(30);
            controller.sciDateText = Datetime.now().format('MM/dd/yyyy');
            controller.fetchExistingSCIs();
            
            System.debug(controller.currentStep);
            System.debug(controller.showValidationErrors);
            System.debug(controller.isError);
            System.debug(controller.sciExternalAttendee);
            System.debug(controller.newAddMeAttendee);
            System.debug(controller.popupMessage);
            System.debug(controller.addMeToSCIId);
            
            controller.cancel();
            Test.stopTest();
        }
    }
    
    /**
* Method to test the edit SCI scenario
*/
    @isTest static void testCreateEditSCIScenario() {
        User me = [SELECT Id, Name FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        ManageSCITestDataHelper.createTestData();
        
        System.runAs(me) {
            Test.startTest();
            Test.setCurrentPage(Page.ManageSCI);
            ApexPages.currentPage().getParameters().put('id', '');
            ApexPages.currentPage().getParameters().put('edit', 'false');
            ApexPages.currentPage().getParameters().put('accountId', ManageSCITestDataHelper.mapAccounts.get('Test Account3').Id);
            ApexPages.currentPage().getParameters().put('opportunityId', ManageSCITestDataHelper.testOpportunity.Id);
            ApexPages.currentPage().getParameters().put('leadId', '');
            ApexPages.currentPage().getParameters().put('dealRegId', '');
            ApexPages.currentPage().getParameters().put('campaignId', '');
            ApexPages.currentPage().getParameters().put('addMe', '');
            ApexPages.currentPage().getParameters().put('retUrl', '/home/home.jsp');
            
            Significant_Customer_Interaction__c sciToTest = new Significant_Customer_Interaction__c();
            ApexPages.StandardController stdController = new ApexPages.StandardController(sciToTest);
            ManageSCIController controller = new ManageSCIController(stdController);
            
            //Set SCI Record type and Date of Meeting
            controller.sciRecord.RecordTypeId = ManageSCITestDataHelper.mapSCIRecordTypes.get('Regular Meeting');
            controller.sciRecord.Date__c = Date.today();
            controller.sciDateText = Datetime.now().format('MM/dd/yyyy');
            controller.fetchExistingSCIs();
            
            ApexPages.currentPage().getParameters().put('id', ManageSCITestDataHelper.mapExistingSCIs.get('sci3').Id);
            ApexPages.currentPage().getParameters().put('edit', 'true');
            ApexPages.currentPage().getParameters().put('accountId', ManageSCITestDataHelper.mapAccounts.get('Test Account3').Id);
            ApexPages.currentPage().getParameters().put('opportunityId', ManageSCITestDataHelper.testOpportunity.Id);
            ApexPages.currentPage().getParameters().put('leadId', '');
            ApexPages.currentPage().getParameters().put('dealRegId', '');
            ApexPages.currentPage().getParameters().put('campaignId', '');
            ApexPages.currentPage().getParameters().put('addMe', 'true');
            ApexPages.currentPage().getParameters().put('retUrl', '/home/home.jsp');
            sciToTest = new Significant_Customer_Interaction__c();
            stdController = new ApexPages.StandardController(sciToTest);
            controller = new ManageSCIController(stdController);
            
            //Do random navigation between steps
            controller.gotoStepNumber=2;
            controller.setCurrentStep();
            controller.gotoStepNumber=3;
            controller.setCurrentStep();
            controller.gotoStepNumber=4;
            controller.setCurrentStep();
            controller.gotoStepNumber=1;
            controller.setCurrentStep();
            
            controller.goPrevious();
            controller.goPrevious();
            controller.goPrevious();
            controller.goPrevious();
            controller.goNext();
            controller.goNext();
            controller.goNext();
            controller.goNext();
            controller.goPrevious();
            
            controller.cancel();
            Test.stopTest();
        }
    }
    
    /**
* Method to test the Add Me button click from existing SCIs list
*/
    @isTest static void testAddMeAsAttendeeScenario() {
        User me = [SELECT Id, Name FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        ManageSCITestDataHelper.createTestData();
        
        System.runAs(me) {
            Test.startTest();
            Test.setCurrentPage(Page.ManageSCI);
            ApexPages.currentPage().getParameters().put('id', '');
            ApexPages.currentPage().getParameters().put('edit', 'false');
            ApexPages.currentPage().getParameters().put('accountId', ManageSCITestDataHelper.mapAccounts.get('Test Account3').Id);
            ApexPages.currentPage().getParameters().put('opportunityId', ManageSCITestDataHelper.testOpportunity.Id);
            ApexPages.currentPage().getParameters().put('leadId', '');
            ApexPages.currentPage().getParameters().put('dealRegId', '');
            ApexPages.currentPage().getParameters().put('campaignId', '');
            ApexPages.currentPage().getParameters().put('addMe', '');
            ApexPages.currentPage().getParameters().put('retUrl', '/home/home.jsp');
            
            Significant_Customer_Interaction__c sciToTest = new Significant_Customer_Interaction__c();
            ApexPages.StandardController stdController = new ApexPages.StandardController(sciToTest);
            ManageSCIController controller = new ManageSCIController(stdController);
            
            //Set SCI Record type and Date of Meeting
            controller.sciRecord.RecordTypeId = ManageSCITestDataHelper.mapSCIRecordTypes.get('Regular Meeting');
            controller.sciRecord.Date__c = Date.today();
            controller.sciDateText = Datetime.now().format('MM/dd/yyyy');
            controller.fetchExistingSCIs();
            
            controller.addMeToSCIId = ManageSCITestDataHelper.mapExistingSCIs.get('sci3').Id;
            controller.handleAddMeClick();
            
            ApexPages.currentPage().getParameters().put('id', ManageSCITestDataHelper.mapExistingSCIs.get('sci3').Id);
            ApexPages.currentPage().getParameters().put('edit', 'true');
            ApexPages.currentPage().getParameters().put('accountId', ManageSCITestDataHelper.mapAccounts.get('Test Account3').Id);
            ApexPages.currentPage().getParameters().put('opportunityId', ManageSCITestDataHelper.testOpportunity.Id);
            ApexPages.currentPage().getParameters().put('leadId', '');
            ApexPages.currentPage().getParameters().put('dealRegId', '');
            ApexPages.currentPage().getParameters().put('campaignId', '');
            ApexPages.currentPage().getParameters().put('addMe', 'true');
            ApexPages.currentPage().getParameters().put('retUrl', '/home/home.jsp');
            
            sciToTest = new Significant_Customer_Interaction__c();
            stdController = new ApexPages.StandardController(sciToTest);
            controller = new ManageSCIController(stdController);
            
            controller.save();
            Test.stopTest();
        }
    }
    
    /**
* Method to test the Internal attendee management scenarios
*/
    @isTest static void testSCIInternalUsersScenarios() {
        User me = [SELECT Id, Name FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        ManageSCITestDataHelper.createTestData();
        
        System.runAs(me) {
            Test.startTest();
            Test.setCurrentPage(Page.ManageSCI);
            ApexPages.currentPage().getParameters().put('id', '');
            ApexPages.currentPage().getParameters().put('edit', 'false');
            ApexPages.currentPage().getParameters().put('accountId', ManageSCITestDataHelper.mapAccounts.get('Test Account3').Id);
            ApexPages.currentPage().getParameters().put('opportunityId', ManageSCITestDataHelper.testOpportunity.Id);
            ApexPages.currentPage().getParameters().put('leadId', '');
            ApexPages.currentPage().getParameters().put('dealRegId', '');
            ApexPages.currentPage().getParameters().put('campaignId', '');
            ApexPages.currentPage().getParameters().put('addMe', '');
            ApexPages.currentPage().getParameters().put('retUrl', '/home/home.jsp');
            
            Significant_Customer_Interaction__c sciToTest = new Significant_Customer_Interaction__c();
            ApexPages.StandardController stdController = new ApexPages.StandardController(sciToTest);
            ManageSCIController controller = new ManageSCIController(stdController);
            
            //Set SCI Record type and Date of Meeting
            controller.sciRecord.RecordTypeId = ManageSCITestDataHelper.mapSCIRecordTypes.get('Regular Meeting');
            controller.sciRecord.Date__c = Date.today();
            controller.sciDateText = Datetime.now().format('MM/dd/yyyy');
            controller.fetchExistingSCIs();
            
            ApexPages.currentPage().getParameters().put('id', ManageSCITestDataHelper.mapExistingSCIs.get('sci3').Id);
            ApexPages.currentPage().getParameters().put('edit', 'true');
            ApexPages.currentPage().getParameters().put('accountId', ManageSCITestDataHelper.mapAccounts.get('Test Account3').Id);
            ApexPages.currentPage().getParameters().put('opportunityId', ManageSCITestDataHelper.testOpportunity.Id);
            ApexPages.currentPage().getParameters().put('leadId', '');
            ApexPages.currentPage().getParameters().put('dealRegId', '');
            ApexPages.currentPage().getParameters().put('campaignId', '');
            ApexPages.currentPage().getParameters().put('patchTeamId', ManageSCITestDataHelper.mapPatchTeams.get('APAC|All').Id);
            ApexPages.currentPage().getParameters().put('addMe', '');
            ApexPages.currentPage().getParameters().put('retUrl', '/home/home.jsp');
            sciToTest = new Significant_Customer_Interaction__c();
            stdController = new ApexPages.StandardController(sciToTest);
            controller = new ManageSCIController(stdController);
            
            //Do random navigation between steps
            controller.goPrevious();
            controller.goPrevious();
            controller.goPrevious();
            controller.goPrevious();
            controller.goNext();
            controller.goNext();
            controller.goNext();
            controller.goNext();
            controller.goPrevious();
            
            //Goto Manage Internal Attendees step
            controller.gotoStepNumber=1;
            controller.setCurrentStep();
            controller.gotoStepNumber=3;
            controller.setCurrentStep();
            
            controller.getSuggestedInternalUsers();
            
            //Search for users with name 'Area%'
            controller.internalAttendeesSearchText = 'Area';
            ManageSCIController.searchInternalUsers(controller.internalAttendeesSearchText);
            
            //Add new user scenario
            controller.internalAttendeeToAdd = ManageSCITestDataHelper.mapUsers.get('AD').Id;
            controller.addInternalAttendee();
            
            controller.organizerId = ManageSCITestDataHelper.mapUsers.get('AD').Id;
            controller.newAttendeeType = 'Organizer';
            controller.handleOrganizerChange();
            
            //Duplicate user validation
            controller.internalAttendeeToAdd = ManageSCITestDataHelper.accountManager.Id;
            controller.addInternalAttendee();
            
            controller.internalAttendeeToRemove = ManageSCITestDataHelper.accountManager.Id;
            controller.removeInternalAttendee();
            
            controller.getInternalAttendees();
            controller.save();
            Test.stopTest();
        }
    }
    
    /**
* Method to test the External attendees management scenarios
*/
    @isTest static void testSCIExternalUsersScenarios() {
        User me = [SELECT Id, Name FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        ManageSCITestDataHelper.createTestData();
        
        System.runAs(me) {
            Test.startTest();
            Test.setCurrentPage(Page.ManageSCI);
            ApexPages.currentPage().getParameters().put('id', '');
            ApexPages.currentPage().getParameters().put('edit', 'false');
            ApexPages.currentPage().getParameters().put('accountId', ManageSCITestDataHelper.mapAccounts.get('Test Account3').Id);
            ApexPages.currentPage().getParameters().put('opportunityId', ManageSCITestDataHelper.testOpportunity.Id);
            ApexPages.currentPage().getParameters().put('leadId', '');
            ApexPages.currentPage().getParameters().put('dealRegId', '');
            ApexPages.currentPage().getParameters().put('campaignId', '');
            ApexPages.currentPage().getParameters().put('addMe', '');
            ApexPages.currentPage().getParameters().put('retUrl', '/home/home.jsp');
            
            Significant_Customer_Interaction__c sciToTest = new Significant_Customer_Interaction__c();
            ApexPages.StandardController stdController = new ApexPages.StandardController(sciToTest);
            ManageSCIController controller = new ManageSCIController(stdController);
            
            //Set SCI Record type and Date of Meeting
            controller.sciRecord.RecordTypeId = ManageSCITestDataHelper.mapSCIRecordTypes.get('Regular Meeting');
            controller.sciRecord.Date__c = Date.today();
            controller.sciDateText = Datetime.now().format('MM/dd/yyyy');
            controller.fetchExistingSCIs();
            
            ApexPages.currentPage().getParameters().put('id', ManageSCITestDataHelper.mapExistingSCIs.get('sci3').Id);
            ApexPages.currentPage().getParameters().put('edit', 'true');
            ApexPages.currentPage().getParameters().put('accountId', ManageSCITestDataHelper.mapAccounts.get('Test Account3').Id);
            ApexPages.currentPage().getParameters().put('opportunityId', ManageSCITestDataHelper.testOpportunity.Id);
            ApexPages.currentPage().getParameters().put('leadId', '');
            ApexPages.currentPage().getParameters().put('dealRegId', '');
            ApexPages.currentPage().getParameters().put('campaignId', '');
            ApexPages.currentPage().getParameters().put('patchTeamId', ManageSCITestDataHelper.mapPatchTeams.get('APAC|All').Id);
            ApexPages.currentPage().getParameters().put('addMe', '');
            ApexPages.currentPage().getParameters().put('retUrl', '/home/home.jsp');
            sciToTest = new Significant_Customer_Interaction__c();
            stdController = new ApexPages.StandardController(sciToTest);
            controller = new ManageSCIController(stdController);
            
            //Goto Manage External Attendees step
            controller.gotoStepNumber=4;
            controller.setCurrentStep();
            
            controller.getSuggestedExternalUsers();
            
            //Search for users with name 'Area%'
            controller.externalAttendeesSearchText = 'Test1';
            ManageSCIController.searchExternalUsers(controller.externalAttendeesSearchText);
            
            //Add new user scenario
            controller.externalAttendeeToAdd = ManageSCITestDataHelper.mapContacts.get('Test2 Test2').Id;
            controller.addExternalAttendee();
            
            //Duplicate user validation
            controller.externalAttendeeToAdd = ManageSCITestDataHelper.mapContacts.get('Test4 Test4').Id;
            controller.addExternalAttendee();
            
            //Add new new contact
            controller.showNewContactPopup();
            controller.newContact = new Contact(
                FirstName = 'Test5',
                LastName = 'Test5',
                AccountId = ManageSCITestDataHelper.mapAccounts.get('Test Account3').Id
                //Head_of_Networking__c = true
            );
            controller.createAndAddExternalAttendee();
            
            controller.showNewContactPopup();
            controller.cancelPopup();
            
            controller.externalAttendeeToRemove = ManageSCITestDataHelper.mapContacts.get('Test3 Test3').Id;
            controller.removeExternalAttendee();
            
            controller.getExternalAttendees();
            controller.save();
            Test.stopTest();
        }
    }
    
    /**
* Method to test SCI deletion with custom button
*/
    @isTest static void testDeleteSCI() {
        User me = [SELECT Id, Name FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        ManageSCITestDataHelper.createTestData();
        
        System.runAs(me) {
            Test.startTest();
            Test.setCurrentPage(Page.DeleteSCI);
            ApexPages.currentPage().getParameters().put('id', ManageSCITestDataHelper.mapExistingSCIs.get('sci1').Id);
            
            Significant_Customer_Interaction__c sciToDelete = ManageSCITestDataHelper.mapExistingSCIs.get('sci1');
            ApexPages.StandardController stdController = new ApexPages.StandardController(sciToDelete);
            DeleteSCIController controller = new DeleteSCIController(stdController);
            
            controller.deleteSCI();
            
            DeleteSCIController controller2 = new DeleteSCIController();
            Test.stopTest();
        }
    }
    
    /**
* Method to test the External attendees management scenarios
*/
    @isTest static void testSCIExternalUserAddFromContactScenarios() {
        User me = [SELECT Id, Name FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        ManageSCITestDataHelper.createTestData();
        
        System.runAs(me) {
            Test.startTest();
            PatchTeam__c salestert  = new PatchTeam__c();
            salestert.District__c = 'AMERICAS';
            salestert.Theater__c = 'Americas';
            salestert.Region__c = 'AMERICAS';
            salestert.Territory__c = 'SF Bay Area 1';
            salestert.Name = 'Sales Team';
            salestert.Sales_Territory_Year__c = 'Current';
            insert salestert;
            
            Patch__c patch = new Patch__c(PatchName__c='acme', Active__c=true,PatchTeam__c=salestert.Id);
            insert patch;
            
            Opportunity opp = new Opportunity();
            opp.Name = 'Test';
            opp.CloseDate = Date.today();
            opp.StageName = '6 - Closed Won';
            opp.Patch__c = patch.Id;
            insert opp;
            
            Significant_Customer_Interaction__c sci = ManageSCITestDataHelper.mapExistingSCIs.get('sci3');
            sci.Opportunity_Name__c = opp.Id;
            
            update sci;
            
            
            Test.setCurrentPage(Page.EditSCI);
            ApexPages.currentPage().getParameters().put('id', ManageSCITestDataHelper.mapExistingSCIs.get('sci3').Id);
            ApexPages.currentPage().getParameters().put('newExternalAttendeeId', ManageSCITestDataHelper.mapContacts.get('Test3 Test3').Id);
            ApexPages.currentPage().getParameters().put('step', '4');
            
            
            EditSCIController controller = new EditSCIController();
            controller.pageLoad();
            
            Test.setCurrentPage(Page.EditSCI);
            ApexPages.currentPage().getParameters().put('newExternalAttendeeId', ManageSCITestDataHelper.mapContacts.get('Test3 Test3').Id);
            
            
            EditSCIController controller2 = new EditSCIController();
            controller2.pageLoad();
            
            Lead le = new Lead();
            le.Territory__c = salestert.Id;
            le.Company = 'tests deo';
            le.FirstName = 'Test34';
            le.LastName = 'Name23';
            le.Email = 'test122@test.com';
            insert le;
            
            Significant_Customer_Interaction__c sciToEdit = ManageSCITestDataHelper.mapExistingSCIs.get('sci1');
            sciToEdit.Lead__c = le.id;
            update sciToEdit;
            
            ApexPages.StandardController sc = new ApexPages.StandardController(sciToEdit);
            EditSCIController controller3 = new EditSCIController(sc);
            controller3.pageLoad();
            
            sci.Opportunity_Name__c = null;
            update sci;
            ApexPages.currentPage().getParameters().put('id',  ManageSCITestDataHelper.mapExistingSCIs.get('sci3').Id);
            
            EditSCIController controller4 = new EditSCIController();
            controller4.pageLoad();
            
            Test.stopTest();
        }
    }
    
    
    /**
* Method to test the edit SCI scenario
*/
    @isTest static void testCloneSCIScenario() {
        User me = [SELECT Id, Name FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        ManageSCITestDataHelper.createTestData();
        
        System.runAs(me) {
            Test.startTest();
            string meetingRecTypeId =  Schema.SObjectType.Significant_Customer_Interaction__c.RecordTypeInfosByName.get('Regular Meeting').RecordTypeId;
			
			Account acc = new Account(name='Test');
			insert acc;     
            Opportunity opp = new Opportunity(name='Test');
            opp.StageName = '6 - Closed Won';
            opp.CloseDate = Date.today();
            insert opp;
            
            Significant_Customer_Interaction__c sci1 = new Significant_Customer_Interaction__c(); 
            sci1.Date__c = system.today()+1;
            sci1.Next_Steps__c = 'Test Data';
            sci1.Interaction_With__c = 'Customer';
            sci1.I_am_the__c = 'Attendee'; 
            sci1.RecordTypeId = meetingRecTypeId;
            sci1.Meeting_Notes__c = 'Test Data';
            sci1.Account_Name__c = acc.Id;
            sci1.Opportunity_Name__c = opp.Id;
            sci1.Current_POC_Phase__c = '2-Documenting Detailed POC Plan';
            sci1.Method_Of_Interaction__c = 'F2F';
            insert sci1;
            
            Test.setCurrentPage(Page.ManageSCI);
            ApexPages.currentPage().getParameters().put('id', '');
            ApexPages.currentPage().getParameters().put('sciRecord', sci1.Id);
            ApexPages.currentPage().getParameters().put('edit', 'false');
            ApexPages.currentPage().getParameters().put('accountId', ManageSCITestDataHelper.mapAccounts.get('Test Account3').Id);
            ApexPages.currentPage().getParameters().put('opportunityId', ManageSCITestDataHelper.testOpportunity.Id);
            ApexPages.currentPage().getParameters().put('leadId', '');
            ApexPages.currentPage().getParameters().put('dealRegId', '');
            ApexPages.currentPage().getParameters().put('newExternalAttendeeId', ManageSCITestDataHelper.mapContacts.get('Test3 Test3').Id);
            ApexPages.currentPage().getParameters().put('campaignId', '');
            ApexPages.currentPage().getParameters().put('participantId', ManageSCITestDataHelper.mapContacts.get('Test3 Test3').Id);
            ApexPages.currentPage().getParameters().put('addMe', '');
            ApexPages.currentPage().getParameters().put('newParticipationType', 'Test');
            ApexPages.currentPage().getParameters().put('retUrl', '/home/home.jsp');
            Significant_Customer_Interaction__c sciToTest = new Significant_Customer_Interaction__c();
            ApexPages.StandardController stdController = new ApexPages.StandardController(sciToTest);
            ManageSCIController controller = new ManageSCIController(stdController);
            
            //Set SCI Record type and Date of Meeting
            //controller.sciRecord.RecordTypeId = ManageSCITestDataHelper.mapSCIRecordTypes.get('Regular Meeting');
            //controller.sciRecord.Date__c = Date.today();
            //controller.sciDateText = Datetime.now().format('MM/dd/yyyy');
            //controller.fetchExistingSCIs();
            
            ApexPages.currentPage().getParameters().put('cloneFromId', ManageSCITestDataHelper.mapExistingSCIs.get('sci3').Id);
            ApexPages.currentPage().getParameters().put('retUrl', '/' + ManageSCITestDataHelper.mapExistingSCIs.get('sci3').Id);
            sciToTest = new Significant_Customer_Interaction__c();
            stdController = new ApexPages.StandardController(sciToTest);
            controller = new ManageSCIController(stdController);
            controller.pageLoad();
            
            //Do random navigation between steps
            controller.gotoStepNumber=2;
            controller.setCurrentStep();
            controller.gotoStepNumber=3;
            controller.setCurrentStep();
            controller.gotoStepNumber=4;
            controller.setCurrentStep();
            controller.gotoStepNumber=1;
            controller.setCurrentStep();
            
            controller.goPrevious();
            controller.goPrevious();
            controller.goPrevious();
            controller.goPrevious();
            controller.goNext();
            controller.goNext();
            controller.goNext();
            controller.goNext();
            controller.goPrevious();
            controller.pageLoad();
            controller.handleParticipationChange();
            controller.togglePartnerAccountField();
            controller.getSCIDate();
            controller.save();
            controller.addExternalAttendee();
            Test.stopTest();
        }
    }
    @isTest static void NewSCIControllerTest(){
        Test.startTest();
        Test.setCurrentPage(Page.NewSCILightningClassic);
        ManageSCITestDataHelper.createTestData();
        ApexPages.currentPage().getParameters().put('accountId', ManageSCITestDataHelper.mapAccounts.get('Test Account3').Id);
        List<Significant_Customer_Interaction__c> sciToTest = new List<Significant_Customer_Interaction__c>();
        ApexPages.StandardSetController stdController = new ApexPages.StandardSetController(sciToTest);
        NewSCIController controller = new NewSCIController(stdController);
        Test.stopTest();

        
    }
}