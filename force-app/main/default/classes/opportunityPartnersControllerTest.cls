/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 02-09-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public class opportunityPartnersControllerTest {
    
    @testSetup static void setup(){
        Account acc = new Account();
        acc.Name='testacc';
        acc.Type ='Prospect';
        insert acc;
        
        
        Opportunity opportunity = new Opportunity(Name = 'Test Opportunity',AccountId = acc.Id, CloseDate = Date.today() + 30, StageName = label.Stage_1_Alignment, Type = 'Existing Customer (Add On)');
        insert opportunity;
        
        Opportunity_Partner__c OppPartner = new Opportunity_Partner__c(Is_Primary__c = true,Opportunity__c = opportunity.Id,Partner_Type__c = 'Reseller');
        insert OppPartner;
    }
    
    public static testMethod void TestController(){
        Opportunity_Partner__c Partner = [select Id,Opportunity__c from Opportunity_Partner__c limit 1];
        ApexPages.StandardController stdPartner = new ApexPages.StandardController(Partner);
        opportunityPartnersController controller = new opportunityPartnersController(stdPartner);
        Test.startTest();
        delete Partner;
        ApexPages.StandardController stdPartner1 = new ApexPages.StandardController(Partner);
        opportunityPartnersController controller1 = new opportunityPartnersController(stdPartner1);
        Test.stopTest();
    }
}