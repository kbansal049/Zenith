@isTest
private class quoteAndProposalShareUtilTest {
    
    @istest
    static void testshareQuoteAndProdConfigWithOppTeamMembers(){
      Test.startTest();
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
            
       
      quoteAndProposalShareUtil.shareQuoteAndProdConfigWithOppTeamMembers(new List<Opportunity_Share__c>{oppshare});
        
      
        
    
      quoteAndProposalShareUtil.shareQuoteAndProdConfigWithOppTeamMembers(new List<Opportunity_Share__c>{oppshare});
    Test.stopTest();

    }
    
    @istest
    static void testshareQuoteAndProdConfigWithOppTeamMembers2(){
      Test.startTest();
        List<User> listUser = SB_TestCPQDataUtility.createUsers(2,'Test12','Admin23','System Administrator');
        listUser[1].CommunityNickname = listUser[1].CommunityNickname + 'New';    
        listUser[0].Username= listUser[1].Username+ 'ZSCPQ';   
        listUser[1].Username= listUser[1].Username+ 'ZSNew';           
        insert listUser;
        List<Account> accList = (SB_TestCPQDataUtility.createAccount(2));
        insert accList;
        Opportunity objOpp = new opportunity(Name = 'Test opportunity', AccountId = accList[0].Id, StageName = Label.Stage_1_Alignment ,Opportunity_Sales_Engineer__c=UserInfo.getUserId(), SE_name__c = listUser[0].id, NextStep = 'Test 1',CloseDate = system.Today()+30, Primary_Quote_Exception__c = true, Validation_Stage__c = '6 - Technical Win', Validation_Plan__c = 'Test');
        insert objOpp;
        
        OpportunityTeamMember objOTM = new OpportunityTeamMember(OpportunityAccessLevel='Edit',OpportunityId=objOpp.id,TeamMemberRole='Sales Engineer',UserId=listUser[1].id);
        insert objOTM;
        
        String  shareStatus = 'Ready To Share';
        Opportunity_Share__c oppshare = new Opportunity_Share__c();
        oppshare.Opportunity_Id__c =objOpp.id;
        oppshare.Status__c = shareStatus;
        insert oppshare;
        
        String quoteNewBusiness = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByDeveloperName().get('New_Business').getRecordTypeId();
        List<SBQQ__Quote__c> listQuotes = new List<SBQQ__Quote__c>();
        listQuotes = (SB_TestCPQDataUtility.createQuote(1, objOpp.Id, accList[0].Id, accList[1].id, accList[1].id,quoteNewBusiness));
        insert listQuotes;
        
        quoteAndProposalShareUtil.shareQuoteAndProdConfigWithOppTeamMembers(new List<Opportunity_Share__c>{oppshare});
        Test.stopTest();

    }
}