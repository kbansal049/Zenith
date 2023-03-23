@isTest
private class OpportunityShareWithSETest {
	
    @testSetup 
    static void setup() {
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

		TriggerHandler.bypass('OpportunityTriggerHandler');
        opportunity opp = new opportunity(Name = 'Test opportunity', AccountId = acc.Id, StageName = label.Stage_1_Alignment /*'1 - Qualified and Budgeted'*/,Opportunity_Sales_Engineer__c=UserInfo.getUserId(), SE_name__c = uu.id, NextStep = 'Test 1',
                                          CloseDate = system.Today()+30, Primary_Quote_Exception__c = true, Validation_Stage__c = '6 - Technical Win', Validation_Plan__c = 'Test');
        insert opp;
        opportunity opp1 = new opportunity(Name = 'Test opportunity1', AccountId = acc.Id, StageName = label.Stage_5_Contracts_Complete,Opportunity_Sales_Engineer__c=UserInfo.getUserId(), SE_name__c = uu.id, NextStep = 'Test 1',
                                           CloseDate = system.Today()+30, Primary_Quote_Exception__c = true, Validation_Stage__c = '6 - Technical Win', Validation_Plan__c = 'Test',Applied_Price_List_Name__c = 'FY20 Pricelist');
        insert opp1;
        OpportunityTeamMember otm = new OpportunityTeamMember (OpportunityId = opp.id,UserId = uu.id,TeamMemberRole = 'Account Manager');
        insert otm;
		TriggerHandler.clearBypass('OpportunityTriggerHandler');

        Id prRecordTypeId = Schema.SObjectType.Provisioning_Request__c.getRecordTypeInfosByName().get('Zscaler Cloud Details').getRecordTypeId();
        Provisioning_Request__c pr = new Provisioning_Request__c();
        pr.Opportunity__c = opp.Id;
        pr.RecordTypeId = prRecordTypeId;
        pr.Account__c = acc.Id;
        pr.Send_Initial_l__c = 'SE';
        pr.SE__c = userinfo.getuserId();
        pr.Provisioning_Status__c = 'In Progress';
        try{
            insert pr;
        }catch(Exception ex){
            
        }
        
    }
    
    @isTest
    static void updateSharingTest(){

        TriggerHandler.bypass('OpportunityTriggerHandler');
        List<Opportunity> opportunityToShareSE = [SELECT Id,SE_Name__c FROM Opportunity];
        List<Opportunity> opportunityToDeleShareSE = [SELECT Id,SE_Name__c FROM Opportunity];
        TriggerHandler.clearBypass('OpportunityTriggerHandler');
        Test.startTest();
        OpportunityShareWithSE.updateSharing(opportunityToShareSE,opportunityToDeleShareSE);
		Test.stopTest();
    }
}