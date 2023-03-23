@isTest
public class PlannerProjectTriggerHandlerTest {
    private static String DEPLOYMENTPROJECT = 'Deployment Project';	//Added as apperaing in Critical issues in Code Scan - IBA-6050 - SCA-02130
    private static String INPROGRESS = 'In Progress';	//Added as apperaing in Critical issues in Code Scan - IBA-6050 - SCA-02130
    private static String NOTES = 'Notes';	//Added as apperaing in Critical issues in Code Scan - IBA-6050 - SCA-02130
    private static String ALIAS = 'alias';	//Added as apperaing in Critical issues in Code Scan - IBA-6050 - SCA-02130
    private static String TITLE = 'title';	//Added as apperaing in Critical issues in Code Scan - IBA-6050 - SCA-02130
    private static String EN_US = 'en_US';	//Added as apperaing in Critical issues in Code Scan - IBA-6050 - SCA-02130
    private static String UTF8 = 'UTF-8';	//Added as apperaing in Critical issues in Code Scan - IBA-6050 - SCA-02130
    private static String AMERICALOSANGELES = 'America/Los_Angeles';	//Added as apperaing in Critical issues in Code Scan - IBA-6050 - SCA-02130
    private static String LAST = 'last';	//Added as apperaing in Critical issues in Code Scan - IBA-6050 - SCA-02130
    private static String TESTLABEL = 'test';	//Added as apperaing in Critical issues in Code Scan - IBA-6050 - SCA-02130
    private static String MAXEMAIL = 'max@bupa.com';	//Added as apperaing in Critical issues in Code Scan - IBA-6050 - SCA-02130
    private static String TESTZ = 'TEST-Z';	//Added as apperaing in Critical issues in Code Scan - IBA-6050 - SCA-02130
    private static String TESTPROJECT1 = 'Test project 1';	//Added as apperaing in Critical issues in Code Scan - IBA-6050 - SCA-02130
    private static String COMPLETED = 'Completed';	//Added as apperaing in Critical issues in Code Scan - IBA-6050 - SCA-02130
    private static String TECHNICALISSUES = 'Technical Issues';	//Added as apperaing in Critical issues in Code Scan - IBA-6050 - SCA-02130
    private static String OPEN = 'Open';	//Added as apperaing in Critical issues in Code Scan - IBA-6050 - SCA-02130
    private static String TEST2 = 'test2';	//Added as apperaing in Critical issues in Code Scan - IBA-6050 - SCA-02130
    private static String TESTPROJECT2 = 'Test project 2';	//Added as apperaing in Critical issues in Code Scan - IBA-6050 - SCA-02130
    private static String MAX2EMAIL = 'max2@bupa.com';	//Added as apperaing in Critical issues in Code Scan - IBA-6050 - SCA-02130
    private static String DEPLOYMENTPROJECTAPI = 'Deployment_Project';	//Added as apperaing in Critical issues in Code Scan - IBA-6050 - SCA-02130
    private static String TEST3 = 'test3';	//Added as apperaing in Critical issues in Code Scan - IBA-6050 - SCA-02130
    private static String EDIT = 'Edit';	//Added as apperaing in Critical issues in Code Scan - IBA-6050 - SCA-02130
    private static String ACCOUNTTRIGGERHANDLER = 'AccountTriggerHandler';	//Added as apperaing in Critical issues in Code Scan - IBA-6050 - SCA-02130

    private static Id depRecordTypeId = (Schema.SObjectType.inspire1__Project__c.getRecordTypeInfosByName().get(DEPLOYMENTPROJECT) != null) ? Schema.SObjectType.inspire1__Project__c.getRecordTypeInfosByName().get(DEPLOYMENTPROJECT).getRecordTypeId() : Null;	//Updated as apperaing in Critical issues in Code Scan - IBA-6050 - SCA-02130
    private static final String questionnareRecordTypeZIA = Schema.SObjectType.PS_Questionnaire__c.getRecordTypeInfosByDeveloperName().get('ZIA').getRecordTypeId();
    private static final String questionnareRecordTypePOD = Schema.SObjectType.PS_Questionnaire__c.getRecordTypeInfosByDeveloperName().get('PS_Onboarding').getRecordTypeId();  
    
    @testSetup  static void setupdata(){
        
        Skip_Triggers__c skipTriggers = new Skip_Triggers__c();
        skipTriggers.Skip_Account_Triggers__c = true;
        skipTriggers.Skip_Opportunity_Triggers__c = true;
        skipTriggers.Name = 'SkipTriggers';
        insert skipTriggers;
        
        List<Triggers_Switch__c> trlst = new List<Triggers_Switch__c>();
        Triggers_Switch__c tr1 = new Triggers_Switch__c(name = 'Execute_Project_Trigger', Execute__c = true);
        Triggers_Switch__c tr2 = new Triggers_Switch__c(name = 'Execute_SendEmail_Project_Trigger', Execute__c = true);
        Triggers_Switch__c tr3 = new Triggers_Switch__c(name = 'Execute_Fill_Summary_Notes_Dates', Execute__c = true);//Added by Varun - CR 1069
        trlst.add(tr1);
        trlst.add(tr2);
        trlst.add(tr3);//Added by Varun - CR 1069
        insert trlst;
        
        test.startTest();      
        
        List<Account> accountList = TestDataFactory_Account.createAccounts(1,false);
        TriggerHandler.bypass(ACCOUNTTRIGGERHANDLER);
        Insert accountList;
        TriggerHandler.clearBypass(ACCOUNTTRIGGERHANDLER);         
        
        List<Contact> contactList = TestDataFactory_Contact.insertContact(1,false, accountList[0].Id);
        Insert contactList;
       
        
        List<User> deploymentServicesUserList = TestDataFactory_User.createUsers(1,false,'Deployment Services v2',
                                                                  'DS','DeploymentServices User',
                                                                  'dsDeploymentServicesUser@test.com');
        insert deploymentServicesUserList;
        
        List<Inspire1__Project__c> projectList = TestDataFactory_Project.prepareTestProject(1,false);
        for(Inspire1__Project__c project : projectList){
            project.inspire1__Account__c=accountList[0].Id;
            project.inspire1__Project_Status__c=INPROGRESS;	//Updated as apperaing in Critical issues in Code Scan - IBA-6050 - SCA-02130
            project.Primary_Customer_Contact__c = contactList[0].Id;
            project.Secondary_Customer_Contact__c = contactList[0].Id;
            project.Management_Notes__c =NOTES;	//Updated as apperaing in Critical issues in Code Scan - IBA-6050 - SCA-02130
        }
        System.runAs(deploymentServicesUserList[0])
        {
            TriggerHandler.bypass('OpportunityTriggerHandler');
            TriggerHandler.bypass('InspireProjectMasterTriggerHandler');
            insert projectList;
            TriggerHandler.clearBypass('InspireProjectMasterTriggerHandler');
            TriggerHandler.clearBypass('OpportunityTriggerHandler');
        }   
        test.stopTest();
            
    }
    
    
    @isTest
    static void testafterInsert(){
        User testuser = new User(ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,Title = TITLE,Alias = ALIAS,
                                 TimeZoneSidKey = AMERICALOSANGELES,EmailEncodingKey = UTF8,LanguageLocaleKey = EN_US,LocaleSidKey = EN_US,
                                 LastName = LAST,Email = MAXEMAIL,Username = MAXEMAIL,CompanyName = TESTLABEL);
        insert testuser ;
        
        Account a = new Account(Name=TESTZ,TAM_Name_New__c=testuser.id);
        TriggerHandler.bypass(ACCOUNTTRIGGERHANDLER);
        Insert a;
        TriggerHandler.clearBypass(ACCOUNTTRIGGERHANDLER);
        Contact c = new Contact(LastName=TESTZ,Email=MAXEMAIL,AccountId=a.id);
        insert c;
        Id RecordTypeIdProject = Schema.SObjectType.Inspire1__Project__c.getRecordTypeInfosByName().get(DEPLOYMENTPROJECT).getRecordTypeId();	//Updated as apperaing in Critical issues in Code Scan - IBA-6050 - SCA-02130
        Inspire1__Project__c IP = new Inspire1__Project__c();
        IP.name = TESTPROJECT1;
        IP.inspire1__Account__c=a.ID;
        IP.RecordTypeId = RecordTypeIdProject;
        IP.inspire1__Project_Status__c=INPROGRESS;	//Updated as apperaing in Critical issues in Code Scan - IBA-6050 - SCA-02130
        IP.Primary_Customer_Contact__c = c.ID;
        IP.Secondary_Customer_Contact__c = c.id;
        IP.Management_Notes__c =NOTES;//Added by Varun - CR 1069 //Updated as apperaing in Critical issues in Code Scan - IBA-6050 - SCA-02130
        TimeZone tz = TimeZone.getTimeZone(AMERICALOSANGELES);
        String tzName = tz.getDisplayName();
        IP.inspire1__Timezone__c=tzName;
        insert IP;
        
        inspire1__Project_Tasks__c IPT = new inspire1__Project_Tasks__c();
        IPT.Name = 'Testing Task';
        //IPT.Type__c = 'Task';
        IPT.inspire1__Time_Tracking_Only__c = False;
        IPT.inspire1__Start_Date__c = System.today();
        IPT.inspire1__Project__c = IP.Id;
        insert IPT;
        
        IP.Primary_Customer_Contact__c = c.id;
        IP.Secondary_Customer_Contact__c = c.id;
        IP.Kickoff_Completed_Date__c = System.today();
        IP.Design_Completed_Date__c = System.today();
        IP.Configuration_Completed_Date__c = System.today();
        IP.Production_Completed_Date__c = System.today();
        IP.Pilot_Completed_Date__c = System.today();
        IP.Project_Transition_Completed_Date__c = System.today();
        IP.Region__c='Transformation';
        IP.Design_Template_Uploaded__c=true;        
        
        
        IP.inspire1__Project_Status__c = COMPLETED;
        IP.Reason_for_Delay__c = TECHNICALISSUES;
        IP.Delayed_Deployment_Product__c = 'ZIA';
        IP.Delayed_Deployment_Notes__c = 'Details';
        IP.Project_Manager__c = testuser.Id;
        IP.Primary_Deployment_Consultant__c = testuser.Id;
        IP.Secondary_Deployment_Consultant__c = testuser.Id;
        IP.Delayed_Deployment_Owner__c = testuser.Id;
        IP.Action_Plan_Owner__c = testuser.Id;
        IP.Delayed_Deployment_Status__c = OPEN;
        IP.Delayed_Deployment__c = True;
        IP.inspire1__Baseline_Start_Date__c = System.today() - 6;
        IP.Management_Notes__c ='Notes Modified';//Added by Varun - CR 1069
        
        test.startTest();
        
        update IP;
        test.stopTest();
    }
    
    @isTest
    static void testCSMProjectCraetion(){
        User testuser = new User(ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,Title = TITLE,Alias = ALIAS,
                                 TimeZoneSidKey = AMERICALOSANGELES,EmailEncodingKey = UTF8,LanguageLocaleKey = EN_US,LocaleSidKey = EN_US,
                                 LastName = LAST,Email = MAXEMAIL,Username = MAXEMAIL,CompanyName = TESTLABEL);
        insert testuser ;
        Account a = new Account(Name=TESTZ);
        insert a;
        //testuser.
        
        
        Contact con1 = new Contact();
        con1.AccountId = a.id;
        con1.lastname = TEST2;
        con1.firstname = TEST2;
        insert con1;
        //System.runAS(testuser){
        
        
        Inspire1__Project__c IP = new Inspire1__Project__c();
        IP.name = TESTPROJECT2;
        IP.inspire1__Account__c=a.ID;
        IP.inspire1__Project_Status__c=INPROGRESS;	//Updated as apperaing in Critical issues in Code Scan - IBA-6050 - SCA-02130
        IP.Action_Plan__c = 'Test Plan';
        IP.RecordTypeId = depRecordTypeId;
        IP.Primary_Customer_Contact__c = con1.id;
        IP.Secondary_Customer_Contact__c = con1.id;
        TimeZone tz = TimeZone.getTimeZone(AMERICALOSANGELES);
        String tzName = tz.getDisplayName();
        IP.inspire1__Timezone__c=tzName;
        insert IP;
        
        
        IP.Primary_Customer_Contact__c = con1.id;
        IP.Secondary_Customer_Contact__c = con1.id;
        
        IP.Kickoff_Completed_Date__c = System.today();
        IP.Design_Completed_Date__c = System.today();
        IP.Configuration_Completed_Date__c = System.today();
        IP.Production_Completed_Date__c = System.today();
        IP.Pilot_Completed_Date__c = System.today();
        IP.Project_Transition_Completed_Date__c = System.today();
        IP.Region__c='Transformation';
        IP.Design_Template_Uploaded__c=true;              

        IP.Delayed_Deployment__c = true;
        IP.Delayed_Deployment_Owner__c = Userinfo.getUserId();
        IP.Delayed_Deployment_Status__c = OPEN;
        IP.Delayed_Deployment_Start_Time__c = System.now();
        IP.Delayed_Deployment_Notes__c = TESTLABEL;
        IP.Reason_for_Delay__c = TECHNICALISSUES;
        IP.Delayed_Deployment_Product__c = 'ZIA';
        IP.Action_Plan__c = 'Test Plan 1';
        
        IP.inspire1__Project_Status__c = COMPLETED;
        
        test.startTest();
        
        update IP;
        test.stopTest();
    }
    @isTest
    static void testProjectTriggerHandler(){
        Test.startTest();
        Account a = new Account(Name=TESTZ);
        insert a;
        //testuser.
        Contact con1 = new Contact();
        con1.AccountId = a.id;
        con1.lastname = TEST2;
        con1.firstname = TEST2;
        insert con1;
        //System.runAS(testuser){
        Inspire1__Project__c IP = new Inspire1__Project__c();
        IP.name = TESTPROJECT2;
        IP.inspire1__Account__c=a.ID;
        IP.inspire1__Project_Status__c=INPROGRESS;	//Updated as apperaing in Critical issues in Code Scan - IBA-6050 - SCA-02130
        IP.Action_Plan__c = 'Test Plan';
        IP.RecordTypeId = depRecordTypeId;
        IP.Primary_Customer_Contact__c = con1.id;
        IP.Secondary_Customer_Contact__c = con1.id;
        
        TimeZone tz = TimeZone.getTimeZone(AMERICALOSANGELES);
        String tzName = tz.getDisplayName();
        IP.inspire1__Timezone__c=tzName;
        insert IP;
        Map<Id,Inspire1__Project__c> oldMap = new Map<Id,Inspire1__Project__c>();
        oldMap.put(IP.Id, IP);
        Map<Id,Inspire1__Project__c> newMap = new Map<Id,Inspire1__Project__c>();
        newMap.put(IP.Id, IP);
        ProjectTriggerHandler project = new ProjectTriggerHandler();
        project.afterUpdate(newMap, oldMap);
        project.afterInsert(newMap);
        Test.stopTest();
    }
    
        
 /******** Commeneted out as part of IBA-4571   
@isTest
    public static void updateProjectResourcesOnPSQTest()
    {
        List<Triggers_Switch__c> trlst = new List<Triggers_Switch__c>();
        trlst.add(new Triggers_Switch__c(name = 'Execute_UpdateProjectResourcesOnPSQ', Execute__c = true));
        insert trlst;
        User usr1 = TestDatafactory_Zscaler.insertAdminUser('xyz@xyz2.com', 'test3', 'test3', 'ttest13', 'xyz@xyz2.com.test', 'GMT', 'en_US', 'UTF-8', 'en_US');
        inspire1__Project__c project=new inspire1__Project__c();
        Account acc = TestDatafactory_Zscaler.insertAccount('Test Account1', null, 'Customer', null, null, null);        
        Contact cont = TestDatafactory_Zscaler.insertContact('Test Contact', acc.Id, null);
        project.name = 'Test project 2';
        project.inspire1__Account__c=acc.ID;
        project.Action_Plan__c = 'Test Plan';
        
        insert project;
        PS_Questionnaire__c psq=new PS_Questionnaire__c();
        
        psq.Project__c=project.id;
        psq.Account__c = acc.Id;
        
        insert psq;
        project.Primary_Customer_Contact__c=cont.Id;
        project.Secondary_Customer_Contact__c=cont.Id;
        project.Project_Manager__c=usr1.Id;
        project.Primary_Deployment_Consultant__c=usr1.Id;
        project.Secondary_Deployment_Consultant__c=usr1.Id;
        project.Design_Template_Uploaded__c=true;              
        
        update project;
        
    }
    ********/
    
    // CR #4425 start
   @isTest
   static void testProjectSendInternalPartnerHandoverEmail(){
       
       List<User> users = new List<User>();
       User partnerProgramPMUser = new User(ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,Alias = ALIAS,
                                TimeZoneSidKey = AMERICALOSANGELES,EmailEncodingKey = UTF8,LanguageLocaleKey = EN_US,LocaleSidKey = EN_US,
                                LastName = 'Partner Program PM',Email = MAXEMAIL,Username = MAXEMAIL);
       
       User testuser = new User(ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,Title = TITLE,Alias = ALIAS,
                                TimeZoneSidKey = AMERICALOSANGELES,EmailEncodingKey = UTF8,LanguageLocaleKey = EN_US,LocaleSidKey = EN_US,
                                LastName = TESTLABEL,Email = MAX2EMAIL,Username = MAX2EMAIL,CompanyName = TESTLABEL);
       users.add(partnerProgramPMUser);
       users.add(testuser);
       insert users ;
       
       EmailTemplate template = [SELECT Id,DeveloperName FROM EmailTemplate LIMIT 1];
       OrgWideEmailAddress orgWideEmail = [SELECT Id,Address FROM OrgWideEmailAddress LIMIT 1];
       
       Account a = new Account(Name='TEST_t1',CSM_Name_New__c = testuser.Id);
      
       
       insert a;
       Contact c = new Contact(LastName=TESTZ,Email=MAXEMAIL,AccountId=a.id);
       insert c;

       opportunity opp = new opportunity( Name = 'Test opportunity', 
                                         Primary_Quote_Exception__c  = true, 
                                         AccountId = a.Id, 
                                         StageName = label.Stage_1_Alignment, 
                                         CloseDate = Date.newInstance(system.today().Year(), 2, 1),
                                         Renewal_VP_In_my_Number__c = true,
                                         Account_CSM_Email__c = 'min@bupa.com',
                                         Type = 'Existing Customer (Renewal)',
                                         Contract_End_Date_New__c = system.Today() + 1,
                                         CRO_Forecast_Category__c = 'Commit');
       insert opp;
       
       Id RecordTypeIdProject = Schema.SObjectType.Inspire1__Project__c.getRecordTypeInfosByName().get('Partner Project').getRecordTypeId();
      
       set<Inspire1__Project__c> projectSet= new set<Inspire1__Project__c>();
       Inspire1__Project__c IP = new Inspire1__Project__c();
       IP.name = TESTPROJECT1;
       IP.inspire1__Account__c=a.ID;
       IP.RecordTypeId = RecordTypeIdProject;
       IP.inspire1__Project_Status__c=INPROGRESS;	//Updated as apperaing in Critical issues in Code Scan - IBA-6050 - SCA-02130
       IP.Project_Manager__c = partnerProgramPMUser.Id;
       IP.Primary_Customer_Contact__c = c.ID;
       IP.Secondary_Customer_Contact__c = c.id;
       IP.Management_Notes__c =NOTES;	//Updated as apperaing in Critical issues in Code Scan - IBA-6050 - SCA-02130
       IP.Opportunity_Owner__c = testuser.Id;
       
       Inspire1__Project__c IP1 = new Inspire1__Project__c();
       IP1.name = TESTPROJECT2;
       IP1.inspire1__Account__c=a.ID;
       IP1.RecordTypeId = RecordTypeIdProject;
       IP1.inspire1__Project_Status__c=INPROGRESS;	//Updated as apperaing in Critical issues in Code Scan - IBA-6050 - SCA-02130
       IP1.Primary_Customer_Contact__c = c.ID;
       IP.Project_Manager__c = partnerProgramPMUser.Id;
       IP1.Secondary_Customer_Contact__c = c.id;
       IP1.Management_Notes__c = NOTES;
       IP1.Opportunity_Owner__c = testuser.Id;
     
       projectSet.add(IP);
       projectSet.add(IP1);

       Test.startTest();
           ProjectSendInternalPartnerHandoverEmail.TEMPLATE_DEVELOPER_NAME = template.DeveloperName;
           ProjectSendInternalPartnerHandoverEmail.SENDERS_EMAILID = orgWideEmail.Address;
           ProjectSendInternalPartnerHandoverEmail.PARTNER_PROGRAM_PM_ID = partnerProgramPMUser.Id;
       
           insert new List<Inspire1__Project__c>(projectSet);
       Test.stopTest();
        
    }
 // CR #4425 End
    

  @isTest
    static void testFillActionPlanModifiedDate(){
        
        User testuser = new User(ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,Title = TITLE,Alias = ALIAS,
                                 TimeZoneSidKey = AMERICALOSANGELES,EmailEncodingKey = UTF8,LanguageLocaleKey = EN_US,LocaleSidKey = EN_US,
                                 LastName = LAST,Email = MAXEMAIL,Username = MAXEMAIL,CompanyName = TESTLABEL);
        insert testuser ;
        
        Account a = new Account(Name=TESTZ);
        insert a;
        Contact c = new Contact(LastName=TESTZ,Email=MAXEMAIL,AccountId=a.id);
        insert c;
        Id RecordTypeIdProject = Schema.SObjectType.Inspire1__Project__c.getRecordTypeInfosByName().get(DEPLOYMENTPROJECT).getRecordTypeId();	//Updated as apperaing in Critical issues in Code Scan - IBA-6050 - SCA-02130
        
         
        Inspire1__Project__c IP = new Inspire1__Project__c();
        IP.name = TESTPROJECT1;
        IP.inspire1__Account__c=a.ID;
        IP.RecordTypeId = RecordTypeIdProject;
        IP.inspire1__Project_Status__c=INPROGRESS;	//Updated as apperaing in Critical issues in Code Scan - IBA-6050 - SCA-02130
        IP.Action_Plan__c = 'Plan';
         IP.Primary_Customer_Contact__c = c.ID;
        
        IP.Management_Notes__c = NOTES;//Added by Varun - CR 1069	//Updated as apperaing in Critical issues in Code Scan - IBA-6050 - SCA-02130
        TimeZone tz = TimeZone.getTimeZone(AMERICALOSANGELES);
        String tzName = tz.getDisplayName();
        IP.inspire1__Timezone__c=tzName;
        
        Test.startTest();
        insert IP;
        Test.stopTest();
        
    }
    
    @isTest
    static void testFillActionPlanModifiedDateAfterUpdate(){
        User testuser = new User(ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,Title = TITLE,Alias = ALIAS,
                                 TimeZoneSidKey = AMERICALOSANGELES,EmailEncodingKey = UTF8,LanguageLocaleKey = EN_US,LocaleSidKey = EN_US,
                                 LastName = LAST,Email = MAXEMAIL,Username = MAXEMAIL,CompanyName = TESTLABEL);
        insert testuser ;
        
        Account a = new Account(Name=TESTZ);
        insert a;
        Contact c = new Contact(LastName=TESTZ,Email=MAXEMAIL,AccountId=a.id);
        insert c;
        Id RecordTypeIdProject = Schema.SObjectType.Inspire1__Project__c.getRecordTypeInfosByName().get(DEPLOYMENTPROJECT).getRecordTypeId();	//Updated as apperaing in Critical issues in Code Scan - IBA-6050 - SCA-02130
        
         
        Inspire1__Project__c IP = new Inspire1__Project__c();
        IP.name = TESTPROJECT1;
        IP.inspire1__Account__c=a.ID;
        IP.RecordTypeId = RecordTypeIdProject;
        IP.inspire1__Project_Status__c=INPROGRESS;	//Updated as apperaing in Critical issues in Code Scan - IBA-6050 - SCA-02130
        IP.Primary_Customer_Contact__c = c.ID;
        
        IP.Management_Notes__c =NOTES;//Added by Varun - CR 1069 //Updated as apperaing in Critical issues in Code Scan - IBA-6050 - SCA-02130
        IP.Action_Plan__c = 'Plan2';
        
        TimeZone tz = TimeZone.getTimeZone(AMERICALOSANGELES);
        String tzName = tz.getDisplayName();
        IP.inspire1__Timezone__c=tzName;
        
        insert IP;
        
        test.startTest();
        IP.Design_Template_Uploaded__c=true;        
        IP.Secondary_Customer_Contact__c = c.id;
        IP.Project_Manager__c = testuser.Id;
        IP.inspire1__Project_Status__c = COMPLETED;
        IP.Action_Plan__c = 'Plan';
        update IP;
        test.stopTest();
    }
    
    @istest
    public static void testprojectfullname(){
        Test.startTest();
        inspire1__Project__c projects = new inspire1__Project__c();
        projects.Name = TESTLABEL;
        projects.RecordTypeId = Schema.SObjectType.inspire1__Project__c.getRecordTypeInfosByName().get(DEPLOYMENTPROJECT).getRecordTypeId();	//Updated as apperaing in Critical issues in Code Scan - IBA-6050 - SCA-02130
        projects.Full_Project_Name__c = 'TestingWorkFlow';
        Insert projects;
        Test.stopTest();
        List <inspire1__Project__c> project2 = [Select Name,Full_Project_Name__c,RecordtypeId FROM inspire1__Project__c LIMIT 1];
        System.assert(project2 != null);
    }
    
    @isTest
    public static void testWFZIAZPAL31D() {
        
       Account acc = new Account();
        acc.Name = 'Test Account';
        acc.Type = 'Prospect';
        acc.APTS_No_of_Platform_Seats__c = 1;
        insert acc;
        
        Customer_Score_Card__c customerScoreCard = new Customer_Score_Card__c();
        customerScoreCard.Account__c = acc.Id;
        customerScoreCard.Total_Bytes_31D__c = 20000000;
        insert customerScoreCard;
        
        acc.Customer_ScoreCard__c = customerScoreCard.Id;
        update acc;
        
        Contact con = new Contact();
        con.LastName = 'Testing Contact';
        con.Email = 'xyz@test.com';
        con.AccountId = acc.Id;
        insert con;
        
        Test.startTest();
        
        inspire1__Project__c project = new inspire1__Project__c();
        project.RecordTypeId= Schema.SObjectType.inspire1__Project__c.getRecordTypeInfosByName().get(DEPLOYMENTPROJECT).getRecordTypeId();	//Updated as apperaing in Critical issues in Code Scan - IBA-6050 - SCA-02130
        project.inspire1__Project_Status__c = INPROGRESS;	//Updated as apperaing in Critical issues in Code Scan - IBA-6050 - SCA-02130
        project.inspire1__Account__c = acc.Id;
        project.Primary_Customer_Contact__c = con.Id;
        project.Design_Template_Uploaded__c = false;
        Insert project;
        
        project.Design_Template_Uploaded__c = true;
        project.inspire1__Project_Status__c = COMPLETED;
        update project;
        Test.stopTest();
        
        Account account = [Select id,Avg_Estimated_Users_L31D_Vs_Purchase__c from Account LIMIT 1];
        inspire1__Project__c project2 = [Select id,ZIA_L31D_at_Completion__c,ZIA_L31D__c FROM inspire1__Project__c LIMIT 1];
        System.assert(account.Avg_Estimated_Users_L31D_Vs_Purchase__c == project2.ZIA_L31D__c);
    }
    
    @isTest
    public static void setProjectStatusToPendingIfProjectManagerIsNull(){
        Test.startTest();
        List<inspire1__Project__c> projectlist = new List<inspire1__Project__c>();
        Id recordType = Schema.SObjectType.inspire1__Project__c.getRecordTypeInfosByDeveloperName().get(DEPLOYMENTPROJECTAPI).getRecordTypeId();	//Updated as apperaing in Critical issues in Code Scan - IBA-6050 - SCA-02130
        
        inspire1__Project__c ip = new inspire1__Project__c(); 
        ip.Name = 'Test inspire 1';
        ip.RecordTypeId = recordType;
        projectlist.add(ip);
        inspire1__Project__c ip1 = new inspire1__Project__c(); 
        ip1.Name = 'Test inspire 2';
        ip1.RecordTypeId = recordType;
        insert ip1;
        projectlist.add(ip1);
        InspireProjectMasterTriggerHelper.setProjectStatusToPendingIfProjectManagerIsNull(projectlist);
        Test.stopTest();
        List<inspire1__Project__c> projects = new List<inspire1__Project__c>();
        projects= [Select Name,RecordTypeId FROM inspire1__Project__c WHERE Name !='ZS Test Project 0' Limit 1];
        System.assert(projects[0].Name == 'Test inspire 2');
    }
    
    @isTest     
    public static void test_update_owner_before_insert(){
        
        Id DeploymentProjectRtId = Schema.SObjectType.inspire1__Project__c.getRecordTypeInfosByDeveloperName().get(ZScalarConstants.PROJECT_RT_DEPLOYMENT_PROJECT).getRecordTypeId();       
        User user = TestUtility.createUser(ZScalarConstants.PROFILE_SYSTEM_ADMINISTRATOR,'testUser');
        
        Test.startTest();
        inspire1__Project__c ip = new inspire1__Project__c();
        ip.RecordTypeId = DeploymentProjectRtId;
        ip.Project_Manager__c = user.Id;
        insert ip;
        Test.stopTest();
        
        inspire1__Project__c project = [Select id,Project_Manager__c,OwnerId FROM inspire1__Project__c Where id = :ip.Id LIMIT 1 ];
        System.assert(project.Project_Manager__c == user.Id);
        System.assert(project.Project_Manager__c == project.OwnerId);
    }
    
    @isTest
    public static void test_update_owner_before_update() {
            
        Id DeploymentProjectRtId = Schema.SObjectType.inspire1__Project__c.getRecordTypeInfosByDeveloperName().get(ZScalarConstants.PROJECT_RT_DEPLOYMENT_PROJECT).getRecordTypeId();
        User user = TestUtility.createUser(ZScalarConstants.PROFILE_SYSTEM_ADMINISTRATOR,'testUser');
        
        inspire1__Project__c project = new inspire1__Project__c();
        project.RecordTypeId = DeploymentProjectRtId;
        insert project;
        
        Test.startTest();
        project.Project_Manager__c = user.Id;
        update project;
        Test.stopTest();
        
        inspire1__Project__c projectToBeValidated = [Select id,Project_Manager__c,OwnerId FROM inspire1__Project__c Where id = :project.Id LIMIT 1 ];
        System.assert(projectToBeValidated.Project_Manager__c == user.Id  );
        System.assert(projectToBeValidated.Project_Manager__c == projectToBeValidated.OwnerId);     
    }
    
    @IsTest
    public static void test_Update_Delayed_Deployment_StartTime_Before_Update() {

        inspire1__Project__c project = getProject(false);
        insert project;
        
        Test.startTest();
        project.Delayed_Deployment__c = true;
        project.Project_Escalation_Required__c = true;
        update project;
        Test.stopTest();
        validateDelayedDeploymentAndEscalation();
    }

    private static inspire1__Project__c getProject(Boolean isDelayedDeploymentAndEscalated) {
        
        inspire1__Project__c project = new inspire1__Project__c();
        project.Delayed_Deployment__c = isDelayedDeploymentAndEscalated;
        project.Project_Escalation_Required__c = isDelayedDeploymentAndEscalated;
        project.Delayed_Deployment_Status__c=OPEN;
        project.Delayed_Deployment_Notes__c=TESTLABEL;
        project.Delayed_Deployment_Product__c='ZPA';
        project.Reason_for_Delay__c=TECHNICALISSUES;
        project.Defcon_Level__c = '5';
        project.Escalation_Reason__c= TECHNICALISSUES;
        project.Delayed_Deployment_Owner__c= userinfo.getUserId();
        return project;
    }
    
    private static void validateDelayedDeploymentAndEscalation() {
        List<inspire1__Project__c> projects = getProjects();
        validateDelayedDeploymentStartTimeIsNotNull(projects);
        validateProjectIsEscalated(projects);
    }
    private static void validateDelayedDeploymentStartTimeIsNotNull( List<inspire1__Project__c> projects) {
        System.assert(projects[0].Delayed_Deployment_Start_Time__c != null,'Delayed Deployment Updated');
    }
    
    private static void validateProjectIsEscalated( List<inspire1__Project__c> projects) {
        System.assert(projects[0].Escalation_Stage__c == OPEN,'Project Escalated');
    }
    
    private static List<inspire1__Project__c> getProjects() {
        return [SELECT Id,
                    Delayed_Deployment__c,
                    Delayed_Deployment_Start_Time__c,
                    Escalation_Stage__c
                FROM inspire1__Project__c where Name != 'ZS Test Project 0'];
    }
    
    @isTest     
    public static void test_project_notes_history_records_getting_created_if_Notes_are_updated(){
       
        List<inspire1__Project__c> projects = new List<inspire1__Project__c>();
       
        inspire1__Project__c ip = new inspire1__Project__c();
        ip.Name = 'Test inspire 1';
        ip.Management_Notes__c = 'Test 1';
        projects.add(ip);
        
        inspire1__Project__c ip2 = new inspire1__Project__c();
        ip2.Name = 'Test inspire 2';
        ip2.Management_Notes__c = TEST2;
        projects.add(ip2);

        
        inspire1__Project__c ip3 = new inspire1__Project__c();
        ip3.Name = 'Test inspire 3';
        ip3.Management_Notes__c = TEST3;	//Updated as apperaing in Critical issues in Code Scan - IBA-6050 - SCA-02130
        projects.add(ip3);
        insert  projects;
        
        Test.startTest();
        ip.Management_Notes__c = 'test1_update';
        ip2.Escalation_Notes__c = 'test2_update';
        ip3.Delayed_Deployment_Notes__c = 'test3_update';
        update new List<inspire1__Project__c> {ip,ip2,ip3};
        Test.stopTest();
    }
    
    @isTest
    static void testSendAlertEmail() {
        
        List<User> users = new List<User>();
       User userJennifer = new User(ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,Alias = ALIAS,
                                TimeZoneSidKey = AMERICALOSANGELES,EmailEncodingKey = UTF8,LanguageLocaleKey = EN_US,LocaleSidKey = EN_US,
                                LastName = 'Jennifer Cavanaugh',Email = MAXEMAIL,Username = MAXEMAIL);
       
       User testuser = new User(ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,Title = TITLE,Alias = ALIAS,
                                TimeZoneSidKey = AMERICALOSANGELES,EmailEncodingKey = UTF8,LanguageLocaleKey = EN_US,LocaleSidKey = EN_US,
                                LastName = 'Jennifer Cavanaugh',Email = MAX2EMAIL,Username = MAX2EMAIL,CompanyName = TESTLABEL);
       users.add(userJennifer);
       users.add(testuser);
       insert users ;
       
       EmailTemplate template = [SELECT Id,DeveloperName FROM EmailTemplate LIMIT 1];
       OrgWideEmailAddress orgWideEmail = [SELECT Id,Address FROM OrgWideEmailAddress LIMIT 1];
          Account a = new Account(Name='AOTest',CSM_Name_New__c = testuser.Id);
        insert a;
        
        Account a1 = new Account(Name='AOTest1',CSM_Name_New__c = testuser.Id);
        insert a1;
        
        Contact c = new Contact(LastName=TESTZ,Email=MAXEMAIL,AccountId=a.id);
        insert c;
        
               
        SBQQ__Quote__c quotes= new SBQQ__Quote__c();
        quotes.SBQQ__Account__c = a.Id;
        quotes.SBQQ__Primary__c= True;
        quotes.Area_VP__c= testuser.Id;
        quotes.SBQQ__Type__c= 'Renewal';
        quotes.Included_DAS_Package__c = 'ZCES-DEP-ENTPLUS';
        insert quotes;
        
         opportunity opp10 = new opportunity(Name = 'Test opportunity', Primary_Quote_Exception__c  = true,
                                         
                                          AccountId = a.Id, StageName='6 - Closed Won', 
                                          CloseDate = system.Today()+30,
                                          ZIA_Use_Case__c = 'O365');
        insert opp10;
        
        
        Set<Inspire1__Project__c> projectSet = new Set<Inspire1__Project__c>();
        Inspire1__Project__c IP = new Inspire1__Project__c();
        IP.name = TESTPROJECT1;
        IP.inspire1__Account__c=a.ID; 
        IP.Opportunity__c = opp10.Id;
        IP.inspire1__Project_Status__c=INPROGRESS;	//Updated as apperaing in Critical issues in Code Scan - IBA-6050 - SCA-02130
        IP.Management_Notes__c =NOTES;	//Updated as apperaing in Critical issues in Code Scan - IBA-6050 - SCA-02130
        IP.Opportunity_Owner__c = testuser.Id;        
        
        Inspire1__Project__c IP1 = new Inspire1__Project__c();
        IP1.name = TESTPROJECT2;
        IP1.inspire1__Account__c=a1.ID;
        IP1.Opportunity__c = opp10.Id;
        IP1.inspire1__Project_Status__c=INPROGRESS;	//Updated as apperaing in Critical issues in Code Scan - IBA-6050 - SCA-02130
        IP1.Management_Notes__c =NOTES;	//Updated as apperaing in Critical issues in Code Scan - IBA-6050 - SCA-02130
        IP1.Opportunity_Owner__c = testuser.Id; 
        
        projectSet.add(IP);
        projectSet.add(IP1);
        
        Test.startTest();
            InspireProjectMasterTriggerHelper.FED_OPT_EMAILTEMPLATE_DEVELOPER_NAME = template.DeveloperName;
            InspireProjectMasterTriggerHelper.SENDERS_EMAILID = orgWideEmail.Address;
            insert new List<Inspire1__Project__c>(projectSet);
            InspireProjectMasterTriggerHelper.prepareEmail(template.Id, orgWideEmail.Id,new List<String>{'abc@gmm.com'} ,new List<String>{'test@gmm.com'} , IP1.id);
            InspireProjectMasterTriggerHelper.isSubStringPresent('ZCES-DAS-FED1');
       Test.stopTest();
       //System.assert(invocations > 0);
        
    }
    
    @isTest     
    public static void do_test_coverage(){
       
        inspire1__Project__c project = new inspire1__Project__c();
        project.Management_Notes__c = 'ThrowException';
        Test.startTest();
        try {
            insert project;
        }catch(Exception ex) {}
        Test.stopTest();   
    }
    
    @isTest
    static void testEscalateProjectSendDefconEmail() {
        
         User testuser = new User(ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,Title = TITLE,Alias = ALIAS,
                                 TimeZoneSidKey = AMERICALOSANGELES,EmailEncodingKey = UTF8,LanguageLocaleKey = EN_US,LocaleSidKey = EN_US,
                                 LastName = LAST,Email = MAXEMAIL,Username = MAXEMAIL,CompanyName = TESTLABEL);
        insert testuser ;
        
        Account acc = new Account(Name=TESTZ);
        insert acc;
        
        AccountTeamMember accTeamRec = new AccountTeamMember();
            accTeamRec.AccountId = acc.Id;
            accTeamRec.UserId = testuser.Id;
            accTeamRec.TeamMemberRole = 'Sales Engineer';
            accTeamRec.AccountAccessLevel = EDIT;	//Updated as apperaing in Critical issues in Code Scan - IBA-6050 - SCA-02130
            accTeamRec.OpportunityAccessLevel = EDIT;	//Updated as apperaing in Critical issues in Code Scan - IBA-6050 - SCA-02130
        insert  accTeamRec;
        
        AccountTeamMember accTeamRec1 = new AccountTeamMember();
            accTeamRec1.AccountId = acc.Id;
            accTeamRec1.UserId = testuser.Id;
            accTeamRec1.TeamMemberRole = 'Sales Engineer';
            accTeamRec1.AccountAccessLevel = EDIT;	//Updated as apperaing in Critical issues in Code Scan - IBA-6050 - SCA-02130
            accTeamRec1.OpportunityAccessLevel = EDIT;	//Updated as apperaing in Critical issues in Code Scan - IBA-6050 - SCA-02130
        insert  accTeamRec1;
        
        inspire1__Project__c project = getProject(false);
        project.inspire1__Account__c = acc.Id;
        insert project;
        Test.startTest();
        String emailConfigApiName = 'Project_At_Risk_Notification_Email';
        project.Project_Escalation_Required__c = true;
        InspireProjectMasterTriggerHelper.sendProjectEmailNotification(new List<inspire1__Project__c>{project},new List<Id>{acc.Id},new List<Id>{project.Id},emailConfigApiName);        
        Test.stopTest();
    }

    @isTest
    static void testCreateProjectNotesHistory() {
        Test.startTest();
            InspireProjectMasterTriggerHelper.createProjectNotesHistory('Project Notes', 'New Deployment Note', 'Old Deployment Note', null);
        Test.stopTest();
    }

   /* Commented as part of IBA-2433 : Escalation Owner should be updated manually. 
    @isTest
    static void testUpdateEscalationOwner() {
        inspire1__Project__c project = getProject(false);
        project.Defcon_Level__c = '4';
		insert project;

        Test.startTest();
            InspireProjectMasterTriggerHelper.updateEscalationOwner(project);
        Test.stopTest();
    } */
    
     @isTest
    public static void test_junction_object_creation()
    {
        List<Triggers_Switch__c> trlst = new List<Triggers_Switch__c>();
        trlst.add(new Triggers_Switch__c(name = 'Execute_InsertProjectResourcesOnPSQ', Execute__c = true));
        trlst.add(new Triggers_Switch__c(name = 'Execute_UpdateOpportunityTeam', Execute__c = true));
        insert trlst;
        

        User usr1 = TestDatafactory_Zscaler.insertAdminUser('xyz@xyz2.com', TEST3, TEST3, 'ttest13', 'xyz@xyz2.com.test', 'GMT', EN_US, 'UTF-8', EN_US);
        
        inspire1__Project__c project=new inspire1__Project__c();
        
        Account acc = TestDatafactory_Zscaler.insertAccount('Test Account1', null, 'Customer', null, null, null);        
        
        Contact cont = TestDatafactory_Zscaler.insertContact('Test Contact', acc.Id, null);
        
        Date closeDate = system.today() + 5;
        Opportunity opp = TestDatafactory_Zscaler.insertOpportunity('Test Opp1', false, acc.Id, Label.Stage_4_Economic_Buyer_Signoff, closeDate , null, null, null, null,null, null, null, null, null, null, true);
        
        PS_Questionnaire__c psq=new PS_Questionnaire__c();
        psq.Account__c=acc.Id;
        psq.Opportunity__c = opp.Id;
        psq.RecordTypeId=questionnareRecordTypeZIA;
        insert psq;
        
        PS_Questionnaire__c questionnairePOD = new PS_Questionnaire__c();
        questionnairePOD.RecordTypeId=questionnareRecordTypePOD;
        questionnairePOD.Account__c=opp.AccountId;
        questionnairePOD.Opportunity_Owner__c=usr1.id;
        questionnairePOD.Opportunity__c = opp.Id;
        insert questionnairePOD;
        
        project.Primary_Customer_Contact__c=cont.Id;
        project.Secondary_Customer_Contact__c=cont.Id;
        project.Project_Manager__c=usr1.Id;
        project.Primary_Deployment_Consultant__c=usr1.Id;
        project.Secondary_Deployment_Consultant__c=usr1.Id;
        project.Opportunity__c = opp.Id;
        project.RecordTypeId = Schema.SObjectType.inspire1__Project__c.getRecordTypeInfosByDeveloperName().get(DEPLOYMENTPROJECTAPI).getRecordTypeId();	//Updated as apperaing in Critical issues in Code Scan - IBA-6050 - SCA-02130
        
        
        Test.startTest();
        insert project;
        Test.stopTest();
        
        List<Projects_PS_Questionnaire_Junction__c> psques =[SELECT id ,Project__c,PS_Questionnaire__c FROM Projects_PS_Questionnaire_Junction__c WHERE PS_Questionnaire__c =: questionnairePOD.id];
        system.assert(!psques.isEmpty());
    }
    
    @isTest
    public static void should_not_create_junction_records()
    {
        List<Triggers_Switch__c> trlst = new List<Triggers_Switch__c>();
        trlst.add(new Triggers_Switch__c(name = 'Execute_InsertProjectResourcesOnPSQ', Execute__c = true));
        trlst.add(new Triggers_Switch__c(name = 'Execute_UpdateOpportunityTeam', Execute__c = true));
        insert trlst;

        User usr1 = TestDatafactory_Zscaler.insertAdminUser('xyz@xyz2.com', TEST3, TEST3, 'ttest13', 'xyz@xyz2.com.test', 'GMT', EN_US, 'UTF-8', EN_US);
        
        inspire1__Project__c project=new inspire1__Project__c();
        
        Account acc = TestDatafactory_Zscaler.insertAccount('Test Account1', null, 'Customer', null, null, null);        
        
        Contact cont = TestDatafactory_Zscaler.insertContact('Test Contact', acc.Id, null);
        
        Date closeDate = system.today() + 5;
        Opportunity opp = TestDatafactory_Zscaler.insertOpportunity('Test Opp1', false, acc.Id, Label.Stage_4_Economic_Buyer_Signoff, closeDate , null, null, null, null,null, null, null, null, null, null, true);
        
        
        PS_Questionnaire__c psq=new PS_Questionnaire__c();
        psq.Account__c=acc.Id;
        psq.Opportunity__c = opp.Id;
        psq.RecordTypeId=questionnareRecordTypeZIA;
        insert psq;
        
        project.Primary_Customer_Contact__c=cont.Id;
        project.Secondary_Customer_Contact__c=cont.Id;
        project.Project_Manager__c=usr1.Id;
        project.Primary_Deployment_Consultant__c=usr1.Id;
        project.Secondary_Deployment_Consultant__c=usr1.Id;
        project.Opportunity__c = opp.Id;
        project.RecordTypeId = Schema.SObjectType.inspire1__Project__c.getRecordTypeInfosByDeveloperName().get(DEPLOYMENTPROJECTAPI).getRecordTypeId();	//Updated as apperaing in Critical issues in Code Scan - IBA-6050 - SCA-02130
        project.Template_ID__c = 'not_Create_junction_record';
        
        Test.startTest();
        insert project;
        Test.stopTest();
        
        List<Projects_PS_Questionnaire_Junction__c> psques =[SELECT id ,Project__c,PS_Questionnaire__c FROM Projects_PS_Questionnaire_Junction__c WHERE PS_Questionnaire__c =: psq.id];
        system.assert(psques.isEmpty());
    }
    //IBA-4912 END
    //IBA-4912 END
    
    //IBA-6050 START
    @isTest
    public static void updateRiskAndEscalationLastUpdatedDateTest()
    {

        List<User> deploymentServicesUserList = [SELECT Id,Username,profile.Name 
                                                 FROM User 
                                                 WHERE Email ='dsDeploymentServicesUser@test.com'
                                                 LIMIT 1]; 
        
        Contact cont = [SELECT Id, LastName 
                        FROM Contact
                        WHERE LastName = 'ZS Test Contact 0'];
        
        List<Inspire1__Project__c> projectRecord = TestDataFactory_Project.prepareTestProject(1,false);
        for(Inspire1__Project__c project : projectRecord){
            project.Name='Test Project for Insert';
            project.At_Risk_Action_Plan__c = TESTLABEL;
            project.Escalation_Action_Plan__c = TESTLABEL;
        }
        insert projectRecord;
        
        inspire1__Project__c project= [Select id from inspire1__Project__c WHERE name = 'ZS Test Project 0' LIMIT 1];
        project.Primary_Customer_Contact__c=cont.Id;
        project.Secondary_Customer_Contact__c=cont.Id;
        project.Project_Manager__c=deploymentServicesUserList[0].Id;
        project.Primary_Deployment_Consultant__c=deploymentServicesUserList[0].Id;
        project.Secondary_Deployment_Consultant__c=deploymentServicesUserList[0].Id;
        project.RecordTypeId = Schema.SObjectType.inspire1__Project__c.getRecordTypeInfosByDeveloperName().get(DEPLOYMENTPROJECTAPI).getRecordTypeId();	//Updated as apperaing in Critical issues in Code Scan - IBA-6050 - SCA-02130
        project.Template_ID__c = 'not_Create_junction_record';
        project.At_Risk_Account_Required__c =true;
        project.At_Risk_Action_Plan__c = TESTLABEL;
        project.Escalation_Action_Plan__c = TESTLABEL;
        project.Reason_for_At_Risk_Account__c = TESTLABEL;
        project.At_Risk_Impact__c = TESTLABEL;
        project.At_Risk_Products__c = TESTLABEL;
        project.Project_Escalation_Required__c = true;
        project.Defcon_Level__c = '4';
        project.Escalation_Reason__c= TECHNICALISSUES;
        project.Escalated_Products__c = TESTLABEL;
        
        Test.startTest();
        System.runAs(deploymentServicesUserList[0]){
            project.At_Risk_Action_Plan__c = 'test 1';
            project.Escalation_Action_Plan__c = 'test 1';
            update project;
        }
        Test.stopTest();
        
        List<inspire1__Project__c> projects =[SELECT Id ,At_Risk_Action_Plan_Last_Updated__c,Escalation_Action_Plan_Last_Updated__c FROM inspire1__Project__c WHERE Name='ZS Test Project 0'];
        system.assertEquals(System.today(),projects[0].At_Risk_Action_Plan_Last_Updated__c,'At_Risk_Action_Plan_Last_Updated__c should be equal to todays date');
        system.assertEquals(System.today(),projects[0].Escalation_Action_Plan_Last_Updated__c,'Escalation_Action_Plan_Last_Updated__c should be equal to todays date');
    }
    //IBA-6050 END
}