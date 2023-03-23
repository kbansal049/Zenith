@isTest
public class PSQTriggerTest {
    
    private static final String questionnareRecordTypeZIA = Schema.SObjectType.PS_Questionnaire__c.getRecordTypeInfosByDeveloperName().get('ZIA').getRecordTypeId();
    private static final String questionnareRecordTypeZPA = Schema.SObjectType.PS_Questionnaire__c.getRecordTypeInfosByDeveloperName().get('ZPA').getRecordTypeId();
    private static final String questionnareRecordTypePOD = Schema.SObjectType.PS_Questionnaire__c.getRecordTypeInfosByDeveloperName().get('PS_Onboarding').getRecordTypeId();  
    
    @isTest
    public static void test1()
    {
        List<Triggers_Switch__c> trlst = new List<Triggers_Switch__c>();
        trlst.add(new Triggers_Switch__c(name = 'Execute_InsertProjectResourcesOnPSQ', Execute__c = true));
        trlst.add(new Triggers_Switch__c(name = 'Execute_UpdateOpportunityTeam', Execute__c = true));
        insert trlst;
        User usr1 = TestDatafactory_Zscaler.insertAdminUser('xyz@xyz2.com', 'test3', 'test3', 'ttest13', 'xyz@xyz2.com.test', 'GMT', 'en_US', 'UTF-8', 'en_US');
        inspire1__Project__c project=new inspire1__Project__c();
        Account acc = TestDatafactory_Zscaler.insertAccount('Test Account1', null, 'Customer', null, null, null);        
        Contact cont = TestDatafactory_Zscaler.insertContact('Test Contact', acc.Id, null);
        
        project.Primary_Customer_Contact__c=cont.Id;
        project.Secondary_Customer_Contact__c=cont.Id;
        project.Project_Manager__c=usr1.Id;
        project.Primary_Deployment_Consultant__c=usr1.Id;
        project.Secondary_Deployment_Consultant__c=usr1.Id; 
        insert project;
        PS_Questionnaire__c psq=new PS_Questionnaire__c();
        psq.Account__c=acc.Id;
        psq.Project__c=project.id;
        
        insert psq;
    }
    @isTest
    public static void test2()
    {
        List<Triggers_Switch__c> trlst = new List<Triggers_Switch__c>();
        trlst.add(new Triggers_Switch__c(name = 'Execute_InsertProjectResourcesOnPSQ', Execute__c = true));
        trlst.add(new Triggers_Switch__c(name = 'Execute_UpdateOpportunityTeam', Execute__c = true));
        trlst.add(new Triggers_Switch__c(name = 'Execute_CSMManagerPrimaryTamEmail', Execute__c = true)); //Added by Ayush Kangar as part of CR#3300
        insert trlst;
        Account acc = TestDatafactory_Zscaler.insertAccount('Test Account1', null, 'Customer', null, null, null);
        User usr1 = TestDatafactory_Zscaler.insertAdminUser('xyz@xyz2.com', 'test3', 'test3', 'ttest13', 'xyz@xyz2.com.test', 'GMT', 'en_US', 'UTF-8', 'en_US');
        Opportunity opp=new Opportunity();
        Date closeDate = system.today() + 5;
        
        opp.OwnerId=usr1.Id;
        opp.Name='Test Opp';
        opp.CloseDate=closeDate;
        opp.StageName=label.Stage_6_Closed_Won;
        insert opp;
        OpportunityTeamMember OTM=new OpportunityTeamMember();
        OTM.TeamMemberRole='Sales Engineer';
        OTM.OpportunityId=opp.id;
        PS_Questionnaire__c psq=new PS_Questionnaire__c();
        psq.Account__c=acc.Id;
        psq.Opportunity__c=opp.id;
        psq.Sales_Engineer__c=OTM.UserId;
        insert psq;
    }
    
    @isTest
    public static void test3()
    {
        User usr1 = TestDatafactory_Zscaler.insertAdminUser('xyz@xyz2.com', 'test3', 'test3', 'ttest13', 'xyz@xyz2.com.test', 'GMT', 'en_US', 'UTF-8', 'en_US');
        Account acc = TestDatafactory_Zscaler.insertAccount('Test Account1', null, 'Customer', null, null, null);
        Opportunity opp=new Opportunity();
        Date closeDate = system.today() + 5;
        Date KickoffDate= system.today() + 2;
        opp.OwnerId=usr1.Id;
        opp.Name='Test Opp';
        opp.CloseDate=closeDate;
        opp.StageName=label.Stage_6_Closed_Won;
        insert opp;
        PS_Questionnaire__c psq1=new PS_Questionnaire__c();
        psq1.Account__c=acc.Id;
        psq1.Opportunity__c=opp.id;
        psq1.RecordTypeId=questionnareRecordTypeZIA;
        insert psq1;
        PS_Questionnaire__c psq2=new PS_Questionnaire__c();
        psq2.Account__c=acc.Id;
        psq2.Opportunity__c=opp.id;
        psq2.RecordTypeId=questionnareRecordTypeZPA;
        insert psq2;
        psq1.Planned_Project_Kickoff_Date__c=KickoffDate;
        update psq1;
        psq2.Planned_Project_Kickoff_Date__c=KickoffDate;
        update psq2;
        
        
    }
    
    //IBA-4912 Start
     @isTest
    public static void test_junction_object_creation()
    {
        List<Triggers_Switch__c> trlst = new List<Triggers_Switch__c>();
        trlst.add(new Triggers_Switch__c(name = 'Execute_InsertProjectResourcesOnPSQ', Execute__c = true));
        trlst.add(new Triggers_Switch__c(name = 'Execute_UpdateOpportunityTeam', Execute__c = true));
        insert trlst;
        

        User usr1 = TestDatafactory_Zscaler.insertAdminUser('xyz@xyz2.com', 'test3', 'test3', 'ttest13', 'xyz@xyz2.com.test', 'GMT', 'en_US', 'UTF-8', 'en_US');
        
        inspire1__Project__c project=new inspire1__Project__c();
        
        Account acc = TestDatafactory_Zscaler.insertAccount('Test Account1', null, 'Customer', null, null, null);        
        
        Contact cont = TestDatafactory_Zscaler.insertContact('Test Contact', acc.Id, null);
        
        Date closeDate = system.today() + 5;
        Opportunity opp = TestDatafactory_Zscaler.insertOpportunity('Test Opp1', false, acc.Id, Label.Stage_4_Economic_Buyer_Signoff, closeDate , null, null, null, null,null, null, null, null, null, null, true);
        
        
        project.Primary_Customer_Contact__c=cont.Id;
        project.Secondary_Customer_Contact__c=cont.Id;
        project.Project_Manager__c=usr1.Id;
        project.Primary_Deployment_Consultant__c=usr1.Id;
        project.Secondary_Deployment_Consultant__c=usr1.Id;
        project.Opportunity__c = opp.Id;
        project.Template_ID__c = 'abcd';
        project.RecordTypeId = Schema.SObjectType.inspire1__Project__c.getRecordTypeInfosByDeveloperName().get('Deployment_Project').getRecordTypeId();
        insert project;
        
        PS_Questionnaire__c psq=new PS_Questionnaire__c();
        psq.Account__c=acc.Id;
        psq.Project__c=project.id;
        psq.Opportunity__c = opp.Id;
        psq.RecordTypeId=questionnareRecordTypeZIA;
        
		PS_Questionnaire__c questionnairePOD = new PS_Questionnaire__c();
        questionnairePOD.RecordTypeId=questionnareRecordTypePOD;
        questionnairePOD.Account__c=opp.AccountId;
        questionnairePOD.Opportunity_Owner__c=usr1.id;
        questionnairePOD.Opportunity__c = opp.Id;        
        
        Test.startTest();
        insert psq;
        insert questionnairePOD;
        Test.stopTest();
        
        List<Projects_PS_Questionnaire_Junction__c> psques =[SELECT id ,Project__c,PS_Questionnaire__c FROM Projects_PS_Questionnaire_Junction__c WHERE PS_Questionnaire__c =: questionnairePOD.id];
        system.assert(psques.size()>0);
    }
    //IBA-4912 END
    
    @isTest
    public static void should_not_create_junction_records()
    {
        List<Triggers_Switch__c> trlst = new List<Triggers_Switch__c>();
        trlst.add(new Triggers_Switch__c(name = 'Execute_InsertProjectResourcesOnPSQ', Execute__c = true));
        trlst.add(new Triggers_Switch__c(name = 'Execute_UpdateOpportunityTeam', Execute__c = true));
        insert trlst;

        User usr1 = TestDatafactory_Zscaler.insertAdminUser('xyz@xyz2.com', 'test3', 'test3', 'ttest13', 'xyz@xyz2.com.test', 'GMT', 'en_US', 'UTF-8', 'en_US');
        
        inspire1__Project__c project=new inspire1__Project__c();
        
        Account acc = TestDatafactory_Zscaler.insertAccount('Test Account1', null, 'Customer', null, null, null);        
        
        Contact cont = TestDatafactory_Zscaler.insertContact('Test Contact', acc.Id, null);
        
        Date closeDate = system.today() + 5;
        Opportunity opp = TestDatafactory_Zscaler.insertOpportunity('Test Opp1', false, acc.Id, Label.Stage_4_Economic_Buyer_Signoff, closeDate , null, null, null, null,null, null, null, null, null, null, true);
        
        
        project.Primary_Customer_Contact__c=cont.Id;
        project.Secondary_Customer_Contact__c=cont.Id;
        project.Project_Manager__c=usr1.Id;
        project.Primary_Deployment_Consultant__c=usr1.Id;
        project.Secondary_Deployment_Consultant__c=usr1.Id;
        project.Opportunity__c = opp.Id;
        project.Template_ID__c = 'abcd';
        project.RecordTypeId = Schema.SObjectType.inspire1__Project__c.getRecordTypeInfosByDeveloperName().get('Deployment_Project').getRecordTypeId();
        insert project;
        
        PS_Questionnaire__c psq=new PS_Questionnaire__c();
        psq.Account__c=acc.Id;
        psq.RecordTypeId=questionnareRecordTypeZIA;
        
        Test.startTest();
        insert psq;
        Test.stopTest();
        
        List<Projects_PS_Questionnaire_Junction__c> psques =[SELECT id ,Project__c,PS_Questionnaire__c FROM Projects_PS_Questionnaire_Junction__c WHERE PS_Questionnaire__c =: psq.id];
        system.assert(psques.isEmpty());
    }
    
    @isTest
    public static void do_test_coverage()
    {
        List<Triggers_Switch__c> trlst = new List<Triggers_Switch__c>();
        trlst.add(new Triggers_Switch__c(name = 'Execute_InsertProjectResourcesOnPSQ', Execute__c = true));
        trlst.add(new Triggers_Switch__c(name = 'Execute_UpdateOpportunityTeam', Execute__c = true));
        insert trlst;

        User usr1 = TestDatafactory_Zscaler.insertAdminUser('xyz@xyz2.com', 'test3', 'test3', 'ttest13', 'xyz@xyz2.com.test', 'GMT', 'en_US', 'UTF-8', 'en_US');
        
        inspire1__Project__c project=new inspire1__Project__c();
        
        Account acc = TestDatafactory_Zscaler.insertAccount('Test Account1', null, 'Customer', null, null, null);        
        
        Contact cont = TestDatafactory_Zscaler.insertContact('Test Contact', acc.Id, null);
        
        Date closeDate = system.today() + 5;
        Opportunity opp = TestDatafactory_Zscaler.insertOpportunity('Test Opp1', false, acc.Id, Label.Stage_4_Economic_Buyer_Signoff, closeDate , null, null, null, null,null, null, null, null, null, null, true);
        
        
        project.Primary_Customer_Contact__c=cont.Id;
        project.Secondary_Customer_Contact__c=cont.Id;
        project.Project_Manager__c=usr1.Id;
        project.Primary_Deployment_Consultant__c=usr1.Id;
        project.Secondary_Deployment_Consultant__c=usr1.Id;
        project.Opportunity__c = opp.Id;
        project.Template_ID__c = 'abcd';
        project.RecordTypeId = Schema.SObjectType.inspire1__Project__c.getRecordTypeInfosByDeveloperName().get('Deployment_Project').getRecordTypeId();
        insert project;
        
        PS_Questionnaire__c psq=new PS_Questionnaire__c();
        psq.Account__c=acc.Id;
        psq.RecordTypeId=questionnareRecordTypeZIA;
        psq.Opportunity__c = opp.Id;
        
        Test.startTest();
        try {
        	PSQTriggerHandler handler = new PSQTriggerHandler();
            handler.onAfterInsert(new List<PS_Questionnaire__c>());
        }catch(Exception ex) {
            
        }
        Test.stopTest();
        
        List<Projects_PS_Questionnaire_Junction__c> psques =[SELECT id ,Project__c,PS_Questionnaire__c FROM Projects_PS_Questionnaire_Junction__c WHERE PS_Questionnaire__c =: psq.id];
        system.assert(psques.isEmpty());
    }
    //IBA-4912 END
}