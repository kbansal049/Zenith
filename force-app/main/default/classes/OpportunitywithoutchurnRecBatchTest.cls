@isTest
private class OpportunitywithoutchurnRecBatchTest {
    
     @testSetup 
    static void setup() {
        
        TriggerHandler.bypass('OpportunityTriggerHandler');
        TriggerHandler.bypass('AccountTriggerHandler');
        
        PatchTeam__c salestert  = new PatchTeam__c();
        salestert.District__c = 'AMERICAS';
        salestert.Theater__c = 'Americas';
        salestert.Region__c = 'AMERICAS';
        salestert.Territory__c = 'SF Bay Area 1';
        salestert.Name = 'Sales Team';
        salestert.Sales_Territory_Year__c = 'Current';
        insert salestert;
        
        Patch__c patch  = new Patch__c();
        patch.Active__c = true;
        patch.PatchTeam__c = salestert.Id ;
        patch.PatchName__c = 'Test Patch';
        insert patch;
        
        PatchTeamMember__c patchTeamMember =  new PatchTeamMember__c(
            PatchTeam__c = salestert.Id, 
            Role__c = 'Account Manager', 
            User__c = UserInfo.getUserId()
        );
        insert patchTeamMember;
        
        Id RecordTypeIdAcc = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner').getRecordTypeId();
        Account acc = new Account();
        acc.Name='Microsoft';
        acc.Type ='Prospect';
        acc.Sales_Territory__c = salestert.Id;
        acc.Patch__c = patch.Id;
        acc.RecordTypeId=RecordTypeIdAcc;
        insert acc;
        
        Account acc1 = new Account();
        acc1.Name='testacc';
        acc1.Type ='Prospect';
        acc1.Sales_Territory__c = salestert.Id;
        acc1.Patch__c = patch.Id;
        insert acc1;
        
        Campaign cm = new Campaign();
        cm.name='ZPA Interactive';
        cm.Department__c = '5000-Corporate Marketing';
        cm.Geo__c = 'GLOBAL';
        cm.StartDate = Date.today();
        cm.EndDate = Date.today()+30;
        cm.Fiscal_Year__c = 'All Time';
        cm.Type = 'Default';
        cm.Campaign_Type__c = 'Networking Event';
        cm.Activity_Details__c = 'Local Association/Chapter Meetings';
        cm.Partner_company__c=acc.Id;
        insert cm;
    }
    
    
    
    static testMethod void testmethod1(){
		Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Finance v2' LIMIT 1];
        User usr = new User(LastName = 'test',
                            FirstName='test',
                            Alias = 'pbhar',
                            Email = 'test.test@asdf.com',
                            Username = 'test.test@asdf.com',
                            ProfileId = profileId.id,
                            TimeZoneSidKey = 'GMT',
                            LanguageLocaleKey = 'en_US',
                            EmailEncodingKey = 'UTF-8',
                            LocaleSidKey = 'en_US'
                           );
        insert usr;
        Account acc = [SELECT Id FROM Account WHERE Name = 'testacc']; 
        
        TriggerHandler.bypass('OpportunityTriggerHandler');
        Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Renewal_Opportunity').getRecordTypeId();
        opportunity opp = new opportunity(Name = 'Test opportunity', 
                                          AccountId = acc.Id, 
                                          StageName = label.Stage_4_Economic_Buyer_Signoff, 
                                          Type ='Existing Customer (Renewal)',
                                          RecordTypeId = oppRecordTypeId,
                                          CloseDate = system.Today(),
                                          Forecast_Category__c = 'Closed');
        
        insert opp;
        
        opp.Has_Technology_Partner__c = TRUE;
        opp.Stagename = Label.Stage_7_Closed_Lost;
        opp.Sub_Stage__c = label.SubStage_Closed_With_No_Decision;/*'Closed With No Decision';*/
        opp.ownerid = usr.id;
        update opp;
        
        
		
        Test.startTest();
        Database.executeBatch(new OpportunitywithoutchurnRecBatch());
        Test.stopTest();
    }
}