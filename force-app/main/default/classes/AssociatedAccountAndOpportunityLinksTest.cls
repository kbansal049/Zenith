@isTest
public class AssociatedAccountAndOpportunityLinksTest {
    @isTest
    public static void accountAndOpportunityTest(){
        
        id UserId = userInfo.getUserId();
        
        Account acc = new Account();
        acc.Name = 'Test Account';
        
        Insert acc;
        Account acc1 = new Account();
        acc1.Name = 'Test Account 1';
        
        Insert acc1;
        
        String accIds = ''+acc.id +','+ acc1.id+'';
        
        Opportunity opp = new Opportunity();
        opp.CloseDate = date.today()+7;
        opp.StageName = '1 - Discovery & Qualification';
        opp.Name='test opp';
        
        Insert opp;
        
        Opportunity opp1 = new Opportunity();
        opp1.CloseDate = date.today()+7;
        opp1.StageName = '1 - Discovery & Qualification';
        opp1.Name='test opp';
        opp1.AccountId = acc.id;
        
        Insert opp1;
        
        String oppIds = ''+opp.id +','+ opp1.id+'';
        
        Transformation_Team_Speaker_Request__c TeamSpeaker = new Transformation_Team_Speaker_Request__c();
        TeamSpeaker.Already_had_word_with_Transform_Team__c = 'Yes';
        //TeamSpeaker.Event_DateTime__c = Datetime.newInstance(2022, 2, 17);
        //TeamSpeaker.Event_Time__c = 'Test Time';
        TeamSpeaker.Event_Type__c = 'Breakout Session';
        TeamSpeaker.Hosted_By__c = 'Other';
        TeamSpeaker.Audience__c = 'Test Audience';
        TeamSpeaker.Preferred_Speaker__c = 'Brett James';
        TeamSpeaker.Supporting_Data__c = 'Test Data';
        TeamSpeaker.Lead_Responsibles__c = UserId;
        TeamSpeaker.Session_Topic_and_or_Event_Theme__c = 'Test Session';
        TeamSpeaker.Geo__c = 'AMS';
        TeamSpeaker.Associated_Accounts__c = acc.id;
        TeamSpeaker.Associated_Opportunity__c = opp.id;
        
        Insert TeamSpeaker;
        
        Test.startTest();
            AssociatedAccountAndOpportunityLinks.AccountsAndOpportunityLink(accIds,oppIds,userId,TeamSpeaker.id);
            AssociatedAccountAndOpportunityLinks.accountNames(accIds);
            //AssociatedAccountAndOpportunityLinks.opportunityNames(oppIds);
            AssociatedAccountAndOpportunityLinks.userNames(userId);
        	AssociatedAccountAndOpportunityLinks.opportunityNames(oppIds,accIds);
        	AssociatedAccountAndOpportunityLinks.opportunityRemovedNames(oppIds,accIds);
        	AssociatedAccountAndOpportunityLinks.fetchAVPLinks(TeamSpeaker.id);
            
        Test.stopTest();
        
        
        Transformation_Team_Speaker_Request__c SpeakerRequest = [Select Associated_Accounts_Links__c, Opportunity_Link_s__c FROM Transformation_Team_Speaker_Request__c Where Id = :TeamSpeaker.id ]; 
        System.assert(SpeakerRequest.Associated_Accounts_Links__c != null);
        System.assert(SpeakerRequest.Opportunity_Link_s__c != null);
    }
}