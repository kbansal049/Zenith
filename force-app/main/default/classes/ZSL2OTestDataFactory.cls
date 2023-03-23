/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* ZSL2OTestDataFactory
* @description    This is the Test Data Factory class, used to prepare test data.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Zscaler
* @modifiedBy     
* @maintainedBy   Zscaler
* @version        1.0
* @created        2022-12-07
* @modified       2023-01-13
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* v1.1            Digvijay Singh
* YYYY-MM-DD      Explanation of the change.  Multiple lines can be used to explain the change, but
*                 each line should be indented till left aligned with the previous description text.
* 2022-12-07      IBA-4849 Digvijay - Creation of the class to have reusable methods to prepare test
                  data related for Speakers Bureau Functionality.
* 2023-01-13      IBA-5937 Aman - Added reusable methods to prepare test data related 
                  for Value Creation Engagement Functionality.
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
**/
@isTest
public class ZSL2OTestDataFactory {

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────┐
    * This Method was added as part of JIRA ID IBA-4849 : to prepare test Account records.
    * ──────────────────────────────────────────────────────────────────────────────────────────────
    * @method   NAME : prepareTestAccounts .
    * @param    NAME : String type             : Type of Account .
    * @param    NAME : Id headOfItCio          : Lookup to Contact .
    * @param    NAME : Id headOfSecurity       : Lookup to Contact .
    * @param    NAME : Id headOfNetworkingCto  : Lookup to Contact .
    * @param    NAME : Id headOfArchitecture   : Lookup to Contact .
    * @param    NAME : Integer numberOfRecords : Number of records to prepare .
    * @return   TYPE : List<Account> .
    * ─────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static List<Account> prepareTestAccounts(String type, Id headOfItCio, Id headOfSecurity, Id headOfNetworkingCto, 
        Id headOfArchitecture, Integer numberOfRecords) {
        
        List<Account> testAccountList = new List<Account>();
        for (Integer count = 1; count <= numberOfRecords; count++) {
            Account testAccount = new Account();
            testAccount.Name = 'Test Account ' + count;
            testAccount.Type = type;
            testAccount.HeadOfIT__c = headOfItCio;
            testAccount.HeadOfSecurity__c = headOfSecurity;
            testAccount.HeadOfNetworking__c = headOfNetworkingCto;
            testAccount.Head_of_Architecture__c = headOfArchitecture;

            testAccountList.add(testAccount);
        }

        return testAccountList;
    }
    
    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────┐
    * This Method was added as part of JIRA ID IBA-4849 : to prepare test Contact records.
    * ──────────────────────────────────────────────────────────────────────────────────────────────
    * @method   NAME : preareTestContacts .
    * @param    NAME : Id accountId            : Associated Account Id .
    * @param    NAME : Integer numberOfRecords : Number of records to prepare .
    * @return   TYPE : List<Contact> .
    * ─────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static List<Contact> preareTestContacts(Id accountId, Integer numberOfRecords) {
        List<Contact> testContactList = new List<Contact>();
        for (Integer count = 1; count <= numberOfRecords; count++) {
            Contact testContact = new Contact();
            testContact.LastName = 'Test Contact ' + count;
            testContact.AccountId = accountId;

            testContactList.add(testContact);
        }

        return testContactList;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────┐
    * This Method was added as part of JIRA ID IBA-4849 : to prepare test Speakers records.
    * ──────────────────────────────────────────────────────────────────────────────────────────────
    * @method   NAME : prepareTestSpeakers .
    * @param    NAME : Id campaignId                      : Associated Campaign Id .
    * @param    NAME : Id cxoSpeakerContactId             : Associated CXO Speaker Id .
    * @param    NAME : String status                      : Speaker Status .
    * @param    NAME : String techSavvyRating             : Tech Savvy Rating .
    * @param    NAME : String presenceCommunicationRating : Presence Communication Rating .
    * @param    NAME : String ratedBy                     : Person Name .
    * @param    NAME : Id recordTypeId                    : Record Type Id .
    * @param    NAME : Integer numberOfRecords            : Number of records to prepare .
    * @return   TYPE : List<Speakers__c> .
    * ─────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static List<Speakers__c> prepareTestSpeakers(Id campaignId, Id cxoSpeakerContactId, String status, 
        String techSavvyRating, String presenceCommunicationRating, String ratedBy, Id recordTypeId, Integer numberOfRecords) {

        List<Speakers__c> testSpeakersList = new List<Speakers__c>();
        for (Integer count = 1; count <= numberOfRecords; count++) {
            Speakers__c testSpeaker = new Speakers__c();
            testSpeaker.Campaign__c = campaignId;
            testSpeaker.CXO_Speaker__c = cxoSpeakerContactId;
            testSpeaker.Status__c = status;
            testSpeaker.Tech_Savvy__c = techSavvyRating;
            testSpeaker.Presence_Communication__c = presenceCommunicationRating;
            testSpeaker.Rated_By__c = ratedBy;
            testSpeaker.RecordTypeId = recordTypeId;

            testSpeakersList.add(testSpeaker);
        }

        return testSpeakersList;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────┐
    * This Method was added as part of JIRA ID IBA-4849 : to prepare test Campaign records.
    * ──────────────────────────────────────────────────────────────────────────────────────────────
    * @method   NAME : prepareTestCampaigns .
    * @param    NAME : String fiscalYear              : Fiscal Year .
    * @param    NAME : Decimal budgetedCostInCampaign : Budgeted Cost In Campaign .
    * @param    NAME : Integer numberOfRecords        : Number of records to prepare .
    * @return   TYPE : List<Campaign> .
    * ─────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static List<Campaign> prepareTestCampaigns(String fiscalYear, Decimal budgetedCostInCampaign, Integer numberOfRecords) {

        List<Campaign> testCampaignList = new List<Campaign>();
        for (Integer count = 1; count <= numberOfRecords; count++) {
            Campaign testCampaign = new Campaign();
            testCampaign.Name = 'Test Campaign ' + count;
            testCampaign.Department__c = '5000-Corporate Marketing';
            testCampaign.Fiscal_Year__c = fiscalYear;
            testCampaign.StartDate = Date.today();
            testCampaign.EndDate = Date.today().addDays(10);
            testCampaign.Campaign_Theme__c = 'Brand';
            testCampaign.Marketing_Initiatives__c = 'Brand';
            testCampaign.Overarching_Theme__c = 'Brand';
            testCampaign.Product_Type__c = 'ZIA/ZPA';
            testCampaign.BudgetedCost = budgetedCostInCampaign;

            testCampaignList.add(testCampaign);
        }

        return testCampaignList;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────┐
    * This Method was added as part of JIRA ID IBA-5937 : to prepare test Opportunity records.
    * ──────────────────────────────────────────────────────────────────────────────────────────────
    * @method   NAME : prepareTestOpportunities .
    * @param    NAME : String AccountId : Account Linked to Opportunity.
    * @param    NAME : String ForecastCategory : Forecast Category of Opportunity.
    * @param    NAME : String StageName : Stage of Opportunity.
    * @param    NAME : String RecordTypeId : Record Type of Opportunity.
    * @param    NAME : Integer numberOfRecords : Number of records to prepare.
    * @return   TYPE : List<Opportunity> .
    * ─────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static List<Opportunity> prepareTestOpportunities(
        String accountId,
        String forecastCategory,
        String stageName,
        String recordTypeId,
        Integer numberOfRecords
    ) {
        
        List<Opportunity> testOpportunityList = new List<Opportunity>();
        for (Integer count = 1; count <= numberOfRecords; count++) {
            Opportunity testOpportunity = new Opportunity();
            testOpportunity.Name = 'Test Opportunity ' + count;
            testOpportunity.AccountId = accountId;
            testOpportunity.Amount = 100000.0 + count;
            testOpportunity.CloseDate = Date.today().addMonths(4);
            testOpportunity.ForecastCategoryName = forecastCategory;
            testOpportunity.StageName = stageName;
            testOpportunity.RecordTypeId = recordTypeId;
            testOpportunityList.add(testOpportunity);
        }

        return testOpportunityList;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────┐
    * This Method was added as part of JIRA ID IBA-5937 : to prepare test Value Creation Engagment records.
    * ──────────────────────────────────────────────────────────────────────────────────────────────
    * @method   NAME : prepareTestValueCreationEngagments.
    * @param    NAME : String Link_to_SFDC_Opportunity__c : Opportunity linked to Value Creation Engagment.
    * @param    NAME : String Engagement_Type__c : Forecast Category of Value Creation Engagment.
    * @param    NAME : String Value_Creation_Stage__c : Stage of Value Creation Engagment.
    * @param    NAME : String RecordTypeId : Record Type of Value Creation Engagment.
    * @param    NAME : Integer numberOfRecords : Number of records to prepare.
    * @return   TYPE : List<Value_Creation_Engagements__c> .
    * ─────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static List<Value_Creation_Engagements__c> prepareTestValueCreationEngagments (
        String opportunityId,
        String engagementType,
        String valueCreationStage,
        String recordTypeId,
        Integer numberOfRecords
    ) {
        
        List<Value_Creation_Engagements__c> testVCEList = new List<Value_Creation_Engagements__c>();
        for (Integer count = 1; count <= numberOfRecords; count++) {
            Value_Creation_Engagements__c testVCERecord = new Value_Creation_Engagements__c();
            testVCERecord.Link_to_SFDC_Opportunity__c = opportunityId;
            testVCERecord.Engagement_Type__c = engagementType;
            testVCERecord.Value_Creation_Stage__c = valueCreationStage;
            testVCERecord.Value_Creation_Scope__c = 'ZDX;CSPM';
            testVCERecord.Collaboration__c = ' Internal Team Interviews';
            testVCERecord.Customer_Metrics__c = 'None';
            testVCERecord.EB_Read_out__c = 'No';
            testVCERecord.Timeliness__c = 'Last minute';
            testVCERecord.RecordTypeId = recordTypeId;
            testVCEList.add(testVCERecord);
        }

        return testVCEList;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────┐
    * This Method was added as part of JIRA ID IBA-4849 : to prepare test User record.
    * ──────────────────────────────────────────────────────────────────────────────────────────────
    * @method   NAME : prepareTestUser .
    * @param    NAME : String firstName .             
    * @param    NAME : String lastName .           
    * @param    NAME : String profileName .
    * @param    NAME : String roleName .
    * @return   TYPE : User .
    * ─────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static User prepareTestUser(String firstName, String lastName, String profileName, String roleName){
        
        if (String.isBlank(profileName)) {
            return null;
        }
        
        Profile profileRecord = [SELECT Id FROM Profile WHERE Name = :profileName LIMIT 1];
        UserRole userRoleRecord = String.isNotBlank(roleName) ? [SELECT Id FROM UserRole WHERE Name = :roleName] : null;

        String uniqueUserName = generateUniqueUserName();
        final Integer ALIAS_START_INDEX = 18;
        final Integer ALIAS_END_INDEX = 23;
        
        User testUser = new User(
            FirstName = firstName,
            LastName = lastName,
            Email = uniqueUserName,
            Alias = uniqueUserName.substring(ALIAS_START_INDEX, ALIAS_END_INDEX),
            Username = uniqueUserName,
            ProfileId = profileRecord.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            LanguageLocaleKey = 'en_US',
            EmailEncodingKey = 'ISO-8859-1',
            LocaleSidKey = 'en_US',
            UserRoleId = (userRoleRecord != null ? userRoleRecord.Id : null)
        );
        
        return testUser;       
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────┐
    * This Method was added as part of JIRA ID IBA-4849 : to assign permission set to the specified 
                                                          user.
    * ──────────────────────────────────────────────────────────────────────────────────────────────
    * @method   NAME : assignPermissionSet .
    * @param    NAME : Id assigneeUserId .             
    * @param    NAME : String permissionSetName .           
    * @return   TYPE : void .
    * ─────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static void assignPermissionSet(Id assigneeUserId, String permissionSetName) {
        if (String.isBlank(assigneeUserId) || String.isBlank(permissionSetName)) {
            throw new ZSL2OTestDataFactoryException('Assignee User Id and Permission Set Name should not be blank or null');
        }

        PermissionSet permissionSetRecord = [SELECT Id FROM PermissionSet WHERE Label = :permissionSetName LIMIT 1];

        PermissionSetAssignment permissionSetAssignmentRecord = new PermissionSetAssignment(
            AssigneeId = assigneeUserId,
            PermissionSetId = permissionSetRecord.Id
        );

        insert permissionSetAssignmentRecord;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────┐
    * This Method was added as part of JIRA ID IBA-4849 : to generate unique user name.
    * ──────────────────────────────────────────────────────────────────────────────────────────────
    * @method   NAME : generateUniqueUserName .
    * @return   TYPE : String : unique user name .
    * ─────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static String generateUniqueUserName() {
        String orgId = UserInfo.getOrganizationId();  
        String dateString = String.valueof(Datetime.now()).replace(' ', '').replace(':', '').replace('-', '');  
        Integer randomInt = Integer.valueOf(Math.rint(math.random() * 1000000));  
        String uniqueName = orgId + dateString + randomInt;  
        String uniqueUserName = uniqueName + '@test' + orgId + '.org';  
        return uniqueUserName;
    }

    private class ZSL2OTestDataFactoryException extends Exception {}
}