@isTest
public class sendEmailForOpportunityCreationTest {
	@isTest
    public static void sendEmailTest(){
        Test.startTest();
        PatchTeam__c territory =  new PatchTeam__c();
        territory.Region__c = 'APAC';
        territory.Area__c = 'India';
        territory.District__c = 'India';
        insert territory;
        
        Patch__c patch = new Patch__c();
        patch.PatchName__c = 'Test Patch';
        Insert patch;   
        
        Id accRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Partner').getRecordTypeId();
        Account acc = new Account();
        acc.Name = 'Acc Crowdstrike test new 2';
        acc.recordTypeId = accRecTypeId;
        acc.Sales_Territory__c = territory.Id;
        acc.Patch__c = patch.id;
        acc.BillingCountry='India';
        acc.BillingCity ='Bangalore';
        TriggerHandler.bypass('AccountTriggerHandler');
        Insert acc;
        acc = [Select Name,Sales_Territory__c, sales_territory__r.District__c,sales_territory__r.Area__c from Account where Id = :acc.id];
        
        Campaign cmp = new Campaign();
        cmp.Name = 'test campaign 7';
        cmp.Geo__c = 'APAC';
        cmp.Area__c = 'India';
        cmp.Sub_Region__c = 'India';
        cmp.Partner_company__c = acc.id;
        Insert cmp;
               
        contact con = new contact();
        con.Lastname = 'test contact 6';
        con.Most_Recent_Campaign__c = cmp.id;
        insert con;
        
        opportunity opp = new opportunity();
        opp.Name = 'Test Opportunity v9';
        opp.CloseDate = system.today()+20;
        opp.stageName = '0 - Pipeline Generation';
        opp.AccountId = acc.id;
        opp.Is_Federal_Opportunity_Sync__c =true;
        TriggerHandler.bypass('OpportunityTriggerHandler');
        Insert opp;
               
        OpportunityContactRole oppRole = new OpportunityContactRole();
        oppRole.OpportunityId = opp.id;
        oppRole.ContactId = con.id;
        oppRole.IsPrimary = true;
        insert oppRole;
        List<String> oppList = new List<String>();
        oppList.add(opp.id);
        sendEmailForOpportunityCreation.sendEmailsToBusiness(oppList);
        Test.stopTest();
    }
}