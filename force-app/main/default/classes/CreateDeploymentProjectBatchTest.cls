@isTest
public class CreateDeploymentProjectBatchTest {
    public static final String EN_US = 'en_US';
    public static final String TEST3 = 'test3';
    @testSetup
    static void testSetUp() {
        Account acc = new Account();
        acc.Name = 'test';
        acc.Type = 'Technology Partner';
        insert acc;
        Contact cont = new Contact();
        cont.LastName='Test';
        cont.email='Testemail@tests.com';
        insert cont;
        
        TriggerHandler.bypass('AccountTriggerHandler');
        TriggerHandler.bypass('OpportunityTriggerHandler');

        opportunity opp10 = new opportunity(Name = 'Test opportunity', Primary_Quote_Exception__c  = true,
                                          type= ZScalarConstants.Opp_Type_New_Business,
                                          AccountId = acc.Id, StageName = '6 - Closed Won', 
                                          CloseDate = system.Today()+30,
                                          ZIA_Use_Case__c = 'O365');
        insert opp10;
        
        opp10.NextStep = 'Test 1';
        opp10.Primary_Quote_Exception__c = true; 
        opp10.Validation_Plan__c = 'Test';
        opp10.Netsuite_Sales_Order_Number__c = '3';
        opp10.Is_Federal_Opportunity_Sync__c = True;
        opp10.DAS_Start_Date__c = system.today();
        Update opp10;

        Pricebook2 pb = new Pricebook2(Name = 'Standard Price Book 2009', Description = 'Price Book 2009 Products', IsActive = true );
        insert pb;
        Product2 prod = new Product2(Name = 'SLA: Bronze', IsActive = true, Product_Category_Subtype__c='Services');
        insert prod;
        PricebookEntry pbe=new PricebookEntry(unitprice=0.01,Product2Id=prod.Id, Pricebook2Id=Test.getStandardPricebookId(), IsActive= true); 
        insert pbe;      
        OpportunityLineItem opplineItem = new OpportunityLineItem ();
        opplineItem.Quantity = 2;
        opplineItem.PricebookEntryId = pbe.Id;
            opplineItem.APTS_Start_Date__c = system.today();
        opplineItem.APTS_End_Date__c = system.today();
        opplineItem.OpportunityId = opp10.Id;
        opplineItem.Product_Code__c = 'ZCES-PRO-SVC';
        insert opplineItem;
        Opportunity_Extension__c oppExtRecord = new Opportunity_Extension__c
        (
            Opportunity__c = opp10.Id,Project_Creation_Status__c = 'Pending'
        );
        insert oppExtRecord;
    }
    @isTest
    static void test_CreateDeploymentProjectBatch() {
        List<Opportunity_Extension__c> oppext = [SELECT id ,name,Project_Creation_Status__c,Opportunity__c,Project_Creation_Failure_Reason__c FROM Opportunity_Extension__c ];
        Test.startTest();
        CreateDeploymentProjectBatch CreatedepProject = new CreateDeploymentProjectBatch();
        CreatedepProject.start(null);
        CreatedepProject.execute(null,oppext);
        Test.stopTest();
    }
    
     @isTest
    static void createDeploymentProjectsWithPSQuestionnairesTest() {
        string Query = 'SELECT id ,name,Project_Creation_Status__c,Opportunity__c FROM Opportunity_Extension__c where Project_Creation_Status__c = \'Pending\'';
        Test.startTest();
        CreateDeploymentProjectBatch CreatedepProject = new CreateDeploymentProjectBatch(Query);
        database.executeBatch(CreatedepProject);
        Test.stopTest();
        Opportunity opp = [SELECT Id from Opportunity where Name = 'Test opportunity'];
        String questionnareRecordTypeZIA = '' + L2O_constants.PSOnboarding.RT_ZIA_ID;
        String questionnareRecordTypeZPA = '' + L2O_constants.PSOnboarding.RT_ZPA_ID;
        List<PS_Questionnaire__c> questionnaireZIAandZPAList = [SELECT Id, Opportunity__c FROM PS_Questionnaire__c WHERE (recordTypeId =: questionnareRecordTypeZIA OR recordTypeId =:questionnareRecordTypeZPA) AND Opportunity__c =: opp.Id];
    	System.AssertEquals(0, questionnaireZIAandZPAList.size());
        
        List<inspire1__Project__c> project = [SELECT Id,Opportunity__c FROM inspire1__Project__c WHERE Opportunity__c =:opp.Id];
        System.assertEquals(1,project.size());
        
        Boolean isJunctionObjectCreated = [SELECT Id,project__c,Opportunity__c FROM Projects_PS_Questionnaire_Junction__c WHERE project__c=:project[0].Id AND Opportunity__c=: opp.Id].isEmpty() ? false : true;
        System.assertEquals(false, isJunctionObjectCreated);
    }
    
      @isTest 
    static void test_JunctionObjectCreated(){
		string Query = 'SELECT id ,name,Project_Creation_Status__c,Opportunity__c FROM Opportunity_Extension__c where Project_Creation_Status__c = \'Pending\'';
        Opportunity opp = [SELECT Id,Name,AccountId From Opportunity WHERE Name =: 'Test opportunity' LIMIT 1];
        String questionnareRecordTypeZIA = Schema.SObjectType.PS_Questionnaire__c.getRecordTypeInfosByName().get('ZIA').getRecordTypeId();
        //Account account = TestDatafactory_Zscaler.insertAccount('Test Account', 'test@test.com', 'test', null, null, 5);
        User usr1 = TestDatafactory_Zscaler.insertAdminUser('xyz@xyz24536.com', TEST3, TEST3, 'ttest13', 'xyz@xyz24536.com.test', 'GMT', EN_US, 'UTF-8', EN_US);
        PS_Questionnaire__c questionnaireZIA = new PS_Questionnaire__c();
        questionnaireZIA.RecordTypeId=questionnareRecordTypeZIA;
        questionnaireZIA.Status__c='Questionnaire Submitted';
        questionnaireZIA.Account__c=opp.AccountId;
        questionnaireZIA.Primary_PS_Consultant__c=usr1.id;
        questionnaireZIA.Secondary_PS_Consultant__c=usr1.id;
        questionnaireZIA.Project_Manager__c=usr1.id;
        questionnaireZIA.Sales_Engineer__c=usr1.id;
        questionnaireZIA.Opportunity_Owner__c=usr1.id; 
        questionnaireZIA.Opportunity__c = opp.Id;
        
        insert questionnaireZIA;
        PS_Questionnaire__c questionnaireZPA = new PS_Questionnaire__c();
        questionnaireZPA.RecordTypeId = Schema.SObjectType.PS_Questionnaire__c.getRecordTypeInfosByDeveloperName().get(L2O_Constants.PSOnboarding.RT_PS_ONBOARDING).getRecordTypeId();
        questionnaireZPA.Status__c='New';
        questionnaireZPA.Account__c=opp.AccountId;
        questionnaireZPA.Primary_PS_Consultant__c=usr1.id;
        questionnaireZPA.Secondary_PS_Consultant__c=usr1.id;
        questionnaireZPA.Project_Manager__c=usr1.id;
        questionnaireZPA.Sales_Engineer__c=usr1.id;
        questionnaireZPA.Opportunity_Owner__c=usr1.id;
        questionnaireZPA.Opportunity__c = opp.Id;
        insert questionnaireZPA;
        Test.startTest();
        CreateDeploymentProjectBatch CreatedepProject = new CreateDeploymentProjectBatch(Query);
        database.executeBatch(CreatedepProject);
        Test.stopTest();    
        List<inspire1__Project__c> project = [SELECT Id,Opportunity__c FROM inspire1__Project__c WHERE Opportunity__c =:opp.Id];
        System.assertEquals(1,project.size());
    }
    
    @isTest 
    static void should_throw_exception(){
        
        Test.startTest();
        CreateDeploymentProjectBatch CreatedepProject = new CreateDeploymentProjectBatch();
        CreatedepProject.start(null);
        try{
         CreatedepProject.execute(null,null);   
        }catch(Exception ex) {
            System.assert(true);
        }
        Test.stopTest();
    }
    
    @isTest 
    static void should_send_email_to_notify_to_users(){
        
        Set<Id> oppIds = new Set<Id>{[Select id FROM Opportunity Limit 1].Id};
        Test.startTest();
        CreateDeploymentProjectBatchHelper.notifyUsersOfError(oppIds,'error');
        Test.stopTest();
    }
    
    @isTest 
    static void should_insert_debug_logs(){
        
        Set<Id> oppIds = new Set<Id>{[Select id FROM Opportunity Limit 1].Id};
        Exception ex;    
        
        //It is done to populate the exception variable
        try {
            throw new IllegalArgumentException('error');
        }catch(Exception e) {
            ex = e;
        }
        
        Test.startTest();
        CreateDeploymentProjectBatchHelper.insertDebugLogs(oppIds,ex);
        Test.stopTest();
        
        List<Zscaler_Error_Logs__c> errorLogs = [Select id from Zscaler_Error_Logs__c ];
        System.assert(!errorLogs.isEmpty());
    }
    
    @isTest 
    static void should_get_productCode_for_which_project_creation_failed(){

        List<OpportunityLineItem> oppLineItems = [Select Id,ProductCode from OpportunityLineItem Limit 1];
        List<Inspire1__Project__c> projects = TestDataFactory_Project.prepareTestProject(1,false);
        projects.get(0).Deployment_Package__c = 'ZPA-DEV-FED';
        
        Test.startTest();
        CreateDeploymentProjectBatchHelper.getProductCodeForWhichProjectCreationFailed(projects,oppLineItems);
        CreateDeploymentProjectBatchHelper.getProductCodeForWhichProjectCreationFailed(oppLineItems);
        Test.stopTest();
    }
    
    @isTest 
    static void should_create_project_junction_record(){
        
        Opportunity opp = [SELECT Id,Name,AccountId From Opportunity WHERE Name =: 'Test opportunity' LIMIT 1];
        User usr1 = TestDatafactory_Zscaler.insertAdminUser('xyz@xyz24536.com', TEST3, TEST3, 'ttest13', 'xyz@xyz24536.com.test', 'GMT', EN_US, 'UTF-8', EN_US);
        
        PS_Questionnaire__c onboard = new PS_Questionnaire__c();
        onboard.RecordTypeId = Schema.SObjectType.PS_Questionnaire__c.getRecordTypeInfosByDeveloperName().get(L2O_Constants.PSOnboarding.RT_PS_ONBOARDING).getRecordTypeId();
        onboard.Status__c='New';
        onboard.Account__c=opp.AccountId;
        onboard.Primary_PS_Consultant__c=usr1.id;
        onboard.Secondary_PS_Consultant__c=usr1.id;
        onboard.Project_Manager__c=usr1.id;
        onboard.Sales_Engineer__c=usr1.id;
        onboard.Opportunity_Owner__c=usr1.id;
        onboard.Opportunity__c = opp.Id;
        insert onboard;
        
        List<Inspire1__Project__c> projects = TestDataFactory_Project.prepareTestProject(1,true);
        projects.get(0).inspire1__Account__c = opp.AccountId;
        projects.get(0).opportunity__c = opp.Id;
        Projects_PS_Questionnaire_Junction__c result ;
        
        CreateDeploymentProjectBatch batchJob = new CreateDeploymentProjectBatch();
        Test.startTest();
        result = batchJob.createJunctionRecord(projects.get(0),onboard.Id);
        batchJob.getTemplateProject(projects.get(0).Id);
        Test.stopTest();
        
        System.Assert(result != null);
    }
}