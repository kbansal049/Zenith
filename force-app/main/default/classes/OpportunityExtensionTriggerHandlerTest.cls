@IsTest 
private class OpportunityExtensionTriggerHandlerTest {
    
    @TestSetup 
    private static void createTestData() {
        
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
        
        Account acc = new Account();
        acc.Name='testacc';
        acc.Type ='Prospect';
        acc.Sales_Territory__c = salestert.Id;
        acc.Patch__c = patch.Id;
        insert acc;
        
        User u = [Select id, name, email from User where id=: UserInfo.getUserId()];
        Profile pf= [Select Id from profile where Name='System Administrator']; 
        
        String orgId=UserInfo.getOrganizationId(); 
        String dateString=String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','') ;
        Integer RandomId=Integer.valueOf(Math.rint(Math.random()*1000000)); 
        String uniqueName=orgId+dateString+RandomId; 
        User uu=new User(firstname = 'ABC', 
                         lastName = 'XYZ', 
                         email = uniqueName + '@test' + orgId + '.org', 
                         Username = uniqueName + '@test' + orgId + '.org', 
                         EmailEncodingKey = 'ISO-8859-1', 
                         Alias = uniqueName.substring(18, 23), 
                         TimeZoneSidKey = 'America/Los_Angeles', 
                         LocaleSidKey = 'en_US', 
                         LanguageLocaleKey = 'en_US', 
                         ProfileId = pf.Id
                        ); 
        
        
        insert uu;
        
        opportunity originalOppRecord = new opportunity
            (Name = 'Original Opportunity', 
             AccountId = acc.Id, 
             StageName = label.Stage_1_Alignment /*'1 - Qualified and Budgeted'*/,
             Opportunity_Sales_Engineer__c=UserInfo.getUserId(), 
             SE_name__c = uu.id, NextStep = 'Test 1',
             CloseDate = system.Today()+30, 
             Primary_Quote_Exception__c = true, 
             Validation_Stage__c = '6 - Technical Win', 
             Validation_Plan__c = 'Test',
             Renewal_Notes__c = 'RenewalNotes');
        
        insert originalOppRecord;
        
        opportunity duplicateOppRecord = new opportunity
            (Name = 'Duplicate Opportunity', 
             AccountId = acc.Id, 
             StageName = label.Stage_5_Contracts_Complete,
             Opportunity_Sales_Engineer__c=UserInfo.getUserId(), 
             SE_name__c = uu.id, NextStep = 'Test 1',
             CloseDate = system.Today()+30, 
             Primary_Quote_Exception__c = true, 
             Validation_Stage__c = '6 - Technical Win', 
             Validation_Plan__c = 'Test',
             Applied_Price_List_Name__c = 'FY20 Pricelist');
        
        insert duplicateOppRecord;
        
        Opportunity_Extension__c oppExtRecord = new Opportunity_Extension__c
            (
                Opportunity__c = originalOppRecord.Id
        	);
        insert oppExtRecord;
        
    }
    
    //CR# 3357
    @isTest
    private static void renewalNotesUpdateTest() { 
        
        List<Triggers_Switch__c> trlst1 = new List<Triggers_Switch__c>();
        trlst1 = TestDatafactory_Zscaler.gettriggerswitchrecords(true);
        trlst1.add(new Triggers_Switch__c(name = 'Execute_Opp_Trigger', Execute__c = true));
        trlst1.add(new Triggers_Switch__c(name = 'Execute_UpdateQualifierRole', Execute__c = true));
        trlst1.add(new Triggers_Switch__c(name = 'Execute_UpdateRelatedOpportunity', Execute__c = true));
        trlst1.add(new Triggers_Switch__c(name = 'Execute_Opportunity_Extention', Execute__c = true));
        TriggerUtility.SkipAccTriggerExecuted();
        insert trlst1;
        
        List<Opportunity_Extension__c> oppExtToUpdateList = new List<Opportunity_Extension__c>();
        
        Opportunity duplicateOpportunity = [SELECT Id
                                            FROM Opportunity
                                            WHERE Name = 'Duplicate Opportunity'
                                            LIMIT 1];
        
        for(Opportunity_Extension__c oppExt :[SELECT Id,
                                              Opportunity__c, 
                                              Duplicate_Opportunity__c 
                                              FROM Opportunity_Extension__c 
                                              LIMIT 1]){
                                                  oppExt.Duplicate_Opportunity__c = duplicateOpportunity.Id;
                                                  oppExtToUpdateList.add(oppExt);
                                              }
        if(!oppExtToUpdateList.isEmpty()){
            Test.startTest();
            update oppExtToUpdateList;
            Test.stopTest();
        }
        
        Opportunity originalOpportunity = [SELECT Id,Renewal_Notes__c
                                            FROM Opportunity
                                            WHERE Name = 'Original Opportunity'
                                            LIMIT 1];
        System.debug('originalOpportunity : ' + originalOpportunity);        
        
    }

}