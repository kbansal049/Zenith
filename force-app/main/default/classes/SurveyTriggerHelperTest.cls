@isTest
public class SurveyTriggerHelperTest {
    
    @TestSetup
    static void makeData(){
        //insert TestDatafactory_Zscaler.getDefaultData();
        RecordType recType = [select Id,name from RecordType where name='End User - Customer DS Reviewed' and sObjectType='Account'];
        
        Account cust = new Account();
        cust.Name = 'Customer1';
        cust.RecordTypeId = recType.Id;
        cust.Type = 'Customer';
        cust.DS_Review_Status__c = 'Complete';
        cust.Contract_Review__c = 'Review Complete';
        
        insert cust;
        
        List<DefaultData__c> trlst = new List<DefaultData__c>();
        trlst.add(new DefaultData__c(name = 'PRCaseCreationDefault', Account_Id__c = cust.id, Category__c='Provisioning Request',Priority__c='Medium (P3)',Product__c='ZIA', Stage_Status__c='New',Type__c='Provisioning'));
        trlst.add(new DefaultData__c(name = 'SurveyCaseDefaults', Account_Id__c = cust.Id, Category__c='DSAT',Priority__c='Medium (P3)',Product__c='', Stage_Status__c='New',Type__c=''));
        insert trlst;
        
        Triggers_Switch__c ts = new Triggers_Switch__c(name = 'SurveyBeforInsertAccountExHandler', Execute__c = true);
        insert ts;
        
        Contact custContact = new Contact();
        custContact.FirstName = 'FirstName';
        custContact.LastName = 'LastName';
        custContact.AccountId = cust.Id;
        custContact.Contact_Type__c = 'Existing Customer';
        custContact.Email = 'test@test.com';
        custContact.LeadSource = 'Webinars';
        
        insert custContact;
        
        Lead ld = new Lead();
        ld.FirstName = 'Lead';
        ld.LastName = 'LName';
        ld.Email = 'ldname@ldname.com';
        ld.LeadSource = 'Webinars';
        ld.Company = 'ABCD';
        
        Zscaler_Cloud_ID__c cloudId = new Zscaler_Cloud_ID__c();
        cloudId.Name = 'zdavav';
        cloudId.Org_Name__c = '';
        cloudId.Status__c = 'Production';
        cloudId.Account__c = cust.Id;
        
        insert cloudId;

        /*Zendesk__Zendesk_Ticket__c ticket = new Zendesk__Zendesk_Ticket__c();
        ticket.Name ='907865';
        ticket.Zendesk__Subject__c = 'Test Survey';
        ticket.Zendesk__Ticket_ID__c = '907865';
        ticket.Zendesk__Description__c = 'Test Description';
        ticket.Area__c = 'Deployment';
        ticket.Sub_Area__c = 'Project';
        ticket.Zendesk__Status__c = 'Pending';
        ticket.Org_ID__c = 'zdavav';
        ticket.Integration_Status__c = 'solved';
        ticket.Integration_Requestor_Name__c = 'Raghu Test Corp';
        ticket.Integration_Ticket_Assignee__c = 'Raghu Manchiraju';
        ticket.Integration_Requestor_Email__c ='abcd@egmail.com';
        ticket.Integration_Type__c = 'problem';
        ticket.Integration_Subject__c = 'Test Survey';
        ticket.Integration_Assignee_Id__c = '2991897443';
        ticket.Integration_Assignee_Manager_Id__c = '384558519771';
        ticket.Zendesk__Organization__c =cust.Id;
        insert ticket;*/
        
        Email_Domains_to_Exclude__c testCustomSetting = new Email_Domains_to_Exclude__c(name = 'gmail.com');
        insert testCustomSetting;
    }

    @isTest static void createPromoterSurvey()
    {
        Survey__c sury = new Survey__c();
        sury.recordTypeId = [select Id from RecordType where SobjectType ='Survey__c' and DeveloperName ='CSAT_Survey'].Id;
        //sury.Zendesk_ticket__c = [Select Id from Zendesk__Zendesk_Ticket__c limit 1].Id;
        sury.Contact_Email__c ='abcd@egmail.com';
        sury.Contact_Name__c = 'Contact Name';
        sury.Ticket_Assignee__c = 'Assignee Name';
        sury.Type__c = 'Problem';
        sury.Ticket_Status__c = 'Solved';
        sury.Assignee_Manager__c = 'rmanchiraju@zscaler.com';
        sury.Survey_Status__c = 'Survey Sent';
        sury.Areas_that_could_have_been_handle_better__c = 'Communication Channels |#|, Product Improvements |#|, Timely Responsiveness |#|, Escalation Handling |#|, Issue Resolution |#|, Overall Goal A customer survey is sent every time a support case is closed or a deployment project is completed by PS or a TAM. When a response received is below the satisfaction level, that triggers creation of a DSAT case in Salesforce. This ticket is assigned to the manager of the original case or deployment project to follow up with the customer. The goal of the project is to improve the data/feedback we collect in the survey as to the satisfaction level of the customer for all surveys (including DSATs) so that we are able to classify the reasons for a good survey vs. a dissatisfied one. Similarly, we want to have a closed loop back method to take actions and track the completion in the DSAT cases when a manager follows up with a customer. Here also we would like to classify the reasons that map with the reasons we collect in the survey to some extent so that we can get to the primary reasons quickly., Clear Communication |#|, Technical Expertise |#|';
        sury.Areas_that_could_have_been_handle_better__c = 'test1';
        insert sury;

        sury.Survey_Response_Received__c =true;
        sury.Survey_Status__c = 'Response Received';
        //NPS
        sury.Will_you_recommend_Zscaler__c = 10;
        sury.Easy_to_handle_Issue__c = '7 - Strongly Agree';
        sury.Rate_your_experience__c = 4.0;

        update sury;
    }


    @isTest static void createPassiveSurvey()
    {
        
        Survey__c sury = new Survey__c();
        sury.recordTypeId = [select Id from RecordType where SobjectType ='Survey__c' and DeveloperName ='CSAT_Survey'].Id;
        //sury.Zendesk_ticket__c = [Select Id from Zendesk__Zendesk_Ticket__c limit 1].Id;
        sury.Contact_Email__c ='abcd@egmail.com';
        sury.Contact_Name__c = 'Contact Name';
        sury.Ticket_Assignee__c = 'Assignee Name';
        sury.Type__c = 'Problem';
        sury.Ticket_Status__c = 'Solved';
        sury.Assignee_Manager__c = 'rmanchiraju@zscaler.com';
        sury.Survey_Status__c = 'Survey Sent';
        sury.Case_Owner_Manager__c = userinfo.getUserId();
        sury.Areas_that_could_have_been_handle_better__c = 'Communication Channels |#|, Product Improvements |#|, Timely Responsiveness |#|, Escalation Handling |#|, Issue Resolution |#|, Overall Goal A customer survey is sent every time a support case is closed or a deployment project is completed by PS or a TAM. When a response received is below the satisfaction level, that triggers creation of a DSAT case in Salesforce. This ticket is assigned to the manager of the original case or deployment project to follow up with the customer. The goal of the project is to improve the data/feedback we collect in the survey as to the satisfaction level of the customer for all surveys (including DSATs) so that we are able to classify the reasons for a good survey vs. a dissatisfied one. Similarly, we want to have a closed loop back method to take actions and track the completion in the DSAT cases when a manager follows up with a customer. Here also we would like to classify the reasons that map with the reasons we collect in the survey to some extent so that we can get to the primary reasons quickly., Clear Communication |#|, Technical Expertise |#|';
        insert sury;

        sury.Will_you_recommend_Zscaler__c = 8;
        sury.How_can_we_make_you_happier__c ='blah blah..';
        sury.Easy_to_handle_Issue__c = '5 - Somewhat Agree';
        sury.One_thing_we_could_do_to_mak__c = '';
        sury.Rate_your_experience__c = 3.0;
		TriggerUtility.CaseBeforeInsertExecuted();
        TriggerUtility.CaseBeforeUpdateExecuted();
        update sury;
        
    }


    @isTest static void createDetractorSurvey()
    {
        Survey__c sury = new Survey__c();
        sury.recordTypeId = [select Id from RecordType where SobjectType ='Survey__c' and DeveloperName ='CSAT_Survey'].Id;
        //sury.Zendesk_ticket__c = [Select Id from Zendesk__Zendesk_Ticket__c limit 1].Id;
        sury.Contact_Email__c ='abcd@egmail.com';
        sury.Contact_Name__c = 'Contact Name';
        sury.Ticket_Assignee__c = 'Assignee Name';
        sury.Type__c = 'Problem';
        sury.Ticket_Status__c = 'Solved';
        sury.Assignee_Manager__c = 'rmanchiraju@zscaler.com';
        sury.Case_Owner_Manager__c = userinfo.getUserId();
        sury.Survey_Status__c = 'Survey Sent';
        sury.Areas_that_could_have_been_handle_better__c = 'Communication Channels |#|, Product Improvements |#|, Timely Responsiveness |#|, Escalation Handling |#|, Issue Resolution |#|, Overall Goal A customer survey is sent every time a support case is closed or a deployment project is completed by PS or a TAM. When a response received is below the satisfaction level, that triggers creation of a DSAT case in Salesforce. This ticket is assigned to the manager of the original case or deployment project to follow up with the customer. The goal of the project is to improve the data/feedback we collect in the survey as to the satisfaction level of the customer for all surveys (including DSATs) so that we are able to classify the reasons for a good survey vs. a dissatisfied one. Similarly, we want to have a closed loop back method to take actions and track the completion in the DSAT cases when a manager follows up with a customer. Here also we would like to classify the reasons that map with the reasons we collect in the survey to some extent so that we can get to the primary reasons quickly., Clear Communication |#|, Technical Expertise |#|';
        insert sury;
		
        sury.Product_Support_Team_Makes_it_Easier__c = 'yes';
        sury.Will_you_recommend_Zscaler__c = 10;
        sury.How_can_we_make_you_happier__c ='blah blah..';
        sury.Easy_to_handle_Issue__c = '3 - Somewhat Disagree';
        sury.One_thing_we_could_do_to_mak__c = '';

        sury.Rate_your_experience__c = 2.0;
        sury.Project_Manager_Primary__c = userinfo.getUserId();
        sury.Project_Manager_Secondary__c = userinfo.getUserId();
        sury.PS_Consultant_Primary__c = userinfo.getUserId();
        sury.PS_Consultant_Secondary__c = userinfo.getUserId();
        
        //List<Survey__c> surlst = new List<Survey__c>{sury};
		TriggerUtility.CaseBeforeInsertExecuted();
        TriggerUtility.CaseBeforeUpdateExecuted();
        update sury;
        
        delete sury;
        undelete sury;
    }
    
    @isTest static void createPartnerOwnedDeploymentProjectSurvey()
    {
        Survey__c sury = new Survey__c();
        sury.recordTypeId = [select Id from RecordType where SobjectType ='Survey__c' and DeveloperName ='Partner_Owned_Deployment_Project'].Id;
        sury.Project_Name_For_Authorized_Partners__c = 'Test Survey';
        sury.Customer_Account__c = 'Test Account';
        sury.Customer_Contact__c = 'Test Contact';
        sury.Customer_Email__c = 'test1@gmail.com';
        sury.Survey_Status__c = 'Not Started';
    
        insert sury;
        
        sury.Product_Support_Team_Makes_it_Easier__c = 'yes';
        sury.Will_you_recommend_Zscaler__c = 5;
        sury.How_can_we_make_you_happier__c ='blah blah..';
        sury.Easy_to_handle_Issue__c = '3 - Somewhat Disagree';
        sury.One_thing_we_could_do_to_mak__c = '';
        sury.Customer_Email__c = 'test2@gmail.com';
        
        Update sury;
  
    }
    
    static testMethod void myUnitSurveyTest() {
        insert TestDatafactory_Zscaler.gettriggerswitchrecords(true);
        
        Account testAccount = new Account(Name='My test Survey account');
        insert testAccount;
        
        Account_Extension__c testAccountEx = new Account_Extension__c(Account__c = testAccount.id);
        insert testAccountEx; 
        
        Test.startTest();
        Survey__c testSurvey = new Survey__c(Account__c= testAccountEx.Account__c);
        insert testSurvey;
        Test.stopTest();
       
    }
}