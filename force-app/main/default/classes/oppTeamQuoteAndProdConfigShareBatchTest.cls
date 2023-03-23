@isTest
private class oppTeamQuoteAndProdConfigShareBatchTest {
    
    @testSetup 
    static void setup() {
            
        TriggerHandler.bypass('AccountTriggerHandler');
        TriggerHandler.bypass('OpportunityTriggerHandler');
        OpportunityShareTriggerHandler.OpportunityShareTriggerHandlerBypass = true;
        
        Account acc = new Account();
        acc.Name='testacc';
        acc.Type ='Prospect';
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
        
        System.runAs(uu) {
            
            opportunity opp = new opportunity(Name = 'Test opportunity', AccountId = acc.Id, StageName = Label.Stage_1_Alignment /*'1 - Qualified and Budgeted'*/,Opportunity_Sales_Engineer__c=UserInfo.getUserId(), SE_name__c = uu.id, NextStep = 'Test 1',
                                              CloseDate = system.Today()+30, Primary_Quote_Exception__c = true, Validation_Stage__c = '6 - Technical Win', Validation_Plan__c = 'Test');
            insert opp;
            
            OpportunityTeamMember otm = new OpportunityTeamMember (OpportunityId = opp.id,UserId = uu.id,TeamMemberRole = 'Opportunity Split',OpportunityAccessLevel ='Edit');
            insert otm;
            //delete otm;
            
            String  shareStatus = 'Ready To Share';
            Opportunity_Share__c oppshare = new Opportunity_Share__c();
            oppshare.Opportunity_Id__c =opp.id;
            oppshare.Status__c = shareStatus;
            insert oppshare;
        }
        
    }
    
    static testMethod void testexcute(){
        Test.startTest();       
        
        oppTeamQuoteAndProdConfigShareBatch obj = new oppTeamQuoteAndProdConfigShareBatch();
        DataBase.executeBatch(obj);
        
        Test.stopTest();
    }
    
    
    @istest
    static void testshareQuoteAndProdConfigWithOppTeamMembers(){
        
        TriggerHandler.bypass('AccountTriggerHandler');
        TriggerHandler.bypass('OpportunityTriggerHandler');
        OpportunityShareTriggerHandler.OpportunityShareTriggerHandlerBypass = false;
        
        Account acc = new Account();
        acc.Name='testacc';
        acc.Type ='Prospect';
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
        
        opportunity opp = new opportunity(Name = 'Test opportunity', AccountId = acc.Id, StageName = Label.Stage_1_Alignment /*'1 - Qualified and Budgeted'*/,Opportunity_Sales_Engineer__c=UserInfo.getUserId(), SE_name__c = uu.id, NextStep = 'Test 1',
                                          CloseDate = system.Today()+30, Primary_Quote_Exception__c = true, Validation_Stage__c = '6 - Technical Win', Validation_Plan__c = 'Test');
        insert opp;
        
        String  shareStatus = 'Ready To Share';
        Opportunity_Share__c oppshare = new Opportunity_Share__c();
        oppshare.Opportunity_Id__c =opp.id;
        oppshare.Status__c = shareStatus;
        insert oppshare;
        
        Test.startTest();
        quoteAndProposalShareUtil.shareQuoteAndProdConfigWithOppTeamMembers(new List<Opportunity_Share__c>{oppshare});
        Test.stopTest();
        
    }
}