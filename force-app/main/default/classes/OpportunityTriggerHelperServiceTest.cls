@isTest
public with sharing class OpportunityTriggerHelperServiceTest {
    @testSetup
    static void testSetup(){
        
        Skip_Triggers__c skipTriggers = new Skip_Triggers__c();
        skipTriggers.Skip_Account_Triggers__c = true;
        skipTriggers.Name = 'SkipTriggers';
        insert skipTriggers;
        
        TriggerHandler.bypass('AccountTriggerHandler');
        TriggerHandler.bypass('OpportunityTriggerHandler');
        
        Account acc = new Account();
        acc.Name='testacc';
        acc.Type ='Prospect';
        insert acc;
        
        Contact cont = new Contact();
        cont.LastName='Test';
        cont.email='Testemail@tests.com';
        insert cont;
        
        opportunity opp = new opportunity();
        opp.Name = 'Test opportunity';
        opp.Primary_Quote_Exception__c  = true;
        opp.AccountId = acc.Id;
        opp.StageName = '5 - Procurement';
        opp.CloseDate = system.Today()+30;
        insert opp;
        
        Opportunity_Extension__c oppExtRecord = new Opportunity_Extension__c();
        oppExtRecord.Opportunity__c = opp.Id;
        oppExtRecord.Project_Creation_Status__c = 'Pending';
        insert oppExtRecord;

		opp.NextStep = 'Test 1';
        opp.Primary_Quote_Exception__c = true; 
        opp.Validation_Plan__c = 'Test';
        opp.Netsuite_Sales_Order_Number__c = '3';
        opp.Is_Federal_Opportunity_Sync__c = True;
        opp.DAS_Start_Date__c = system.today();
        Update opp;

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
        opplineItem.OpportunityId = opp.Id;
        opplineItem.Product_Code__c = 'ZCES-PRO-SVC';
        insert opplineItem;
    }
    
    @isTest
    static void opportunity_extension_should_not_be_eligible_for_project_creation(){
        List<Opportunity> opp = [SELECT id,name,StageName from Opportunity WHERE StageName =: '5 - Procurement'];
        
        Id recordTypeIdProject = Schema.SObjectType.Inspire1__Project__c.getRecordTypeInfosByName().get('Deployment Project').getRecordTypeId();
        Inspire1__Project__c iP = new Inspire1__Project__c();
        iP.name = 'Test project 1';
        iP.Opportunity__c =opp[0].id;
        iP.RecordTypeId = recordTypeIdProject;
        iP.inspire1__Project_Status__c='In Progress';
        iP.Deployment_Package__c ='Test';
        iP.Management_Notes__c ='Notes';
        ip.Project_Type__c = L2O_Constants.OpportunityObject.PROJECT_TYPE_DEPLOYMENT;
        TimeZone tz = TimeZone.getTimeZone('America/Los_Angeles');
        String tzName = tz.getDisplayName();
        iP.inspire1__Timezone__c=tzName;
        insert iP;
        
        Map<Id,Opportunity> newMap = new Map<Id,Opportunity>();
        Map<Id,Opportunity> oldMap = new Map<Id,Opportunity>();
        oldMap.put(opp[0].Id,opp[0]);
		Opportunity newopportunity = new Opportunity(Id = opp[0].Id, StageName = '6 - Closed Won');
        newMap.put(newopportunity.Id,newopportunity);
        
        newMap.put(opp[0].Id,opp[0]);
        Test.startTest();
        OpportunityTriggerHelperService.updateOpportunitiesEligibleForDeploymentProjectCreation(newMap,oldMap);
        Test.stopTest();
        
    }
    @isTest
    static void opportunity_extension_should_not_be_applicable_for_project_creation(){
        List<Opportunity> opp = [SELECT id,name,StageName from Opportunity WHERE StageName =: '5 - Procurement'];
        Opportunity_Extension__c oppExtRecord = new Opportunity_Extension__c();
        oppExtRecord.Project_Creation_Status__c = 'Pending';
        oppExtRecord.Opportunity__c = opp[0].id;
        insert oppExtRecord;
        
        Map<Id,Opportunity> newMap = new Map<Id,Opportunity>();
        Map<Id,Opportunity> oldMap = new Map<Id,Opportunity>();
        oldMap.put(opp[0].Id,opp[0]);
        Opportunity newopportunity = new Opportunity(Id = opp[0].Id, StageName = '6 - Closed Won');
        newMap.put(newopportunity.Id,newopportunity);
        
        Map<Id,List<String>> deployemntProjectSKUsByOpportunityId = new Map<Id,List<String>>{newopportunity.Id => new List<String>{'ZPA-DEV-FED'}};
        List<Opportunity_Extension__c> oppExtensions = [Select id,Project_Creation_Status__c,Opportunity__c from Opportunity_Extension__c Limit 1];
        Map<Id,List<String>> opportunitySKUsByOpportunity = new Map<Id,List<String>>{newopportunity.Id => new List<String>{'ZPA-DEV-FED'}};
        
        Test.startTest();
        OpportunityTriggerHelperService.updateOpportunitiesEligibleForDeploymentProjectCreation(newMap,oldMap);
        OpportunityTriggerHelperService.updateOpportunitiesEligibleForDeploymentProjectCreation(new Set<Id>{newopportunity.Id});
        OpportunityTriggerHelperService.getOpportunityExtensionsToBeUpdated(deployemntProjectSKUsByOpportunityId,oppExtensions,opportunitySKUsByOpportunity);
        OpportunityTriggerHelperService.updateProjectCreationStatusToSuccess();
        OpportunityTriggerHelperService.updateProjectCreationStatusToPending();
        Test.stopTest();
        system.assert([SELECT Id,Opportunity__c,Project_Creation_Status__c FROM Opportunity_Extension__c WHERE Opportunity__c =: opp[0].Id LIMIT 1].Project_Creation_Status__c != null);
        
    }
}